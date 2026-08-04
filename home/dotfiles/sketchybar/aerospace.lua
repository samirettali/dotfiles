--- aerospace module for sending commands to the AeroSpace window manager server
-- @module Aerospace
-- @copyright 2025
-- @license MIT
--
-- Wire protocol (Sources/Common/util/NWConnectionEx.swift): on connect both sides
-- exchange a uint32 protocol version, then every message is a uint32 little-endian
-- length followed by that many bytes of JSON. The connection is long-lived: the
-- server loops reading requests until the client goes away.

local socket = require("posix.sys.socket")
local unistd = require("posix.unistd")
local cjson = require("cjson")
local simdjson = require("simdjson")

local PROTOCOL_VERSION = 1
local SOCK_FMT = "/tmp/bobko.aerospace-%s.sock"

local ERR = {
	SOCKET = "socket error",
	NOT_INIT = "socket not connected",
	EOF = "unexpected end of stream",
	JSON = "failed to decode JSON",
}

local AF_UNIX, SOCK_STREAM = socket.AF_UNIX, socket.SOCK_STREAM
local write, read, close = unistd.write, unistd.read, unistd.close
local encode = cjson.encode

local use_simd = true
local function decode(str)
	if use_simd then
		local ok, val = pcall(simdjson.parse, str)
		if ok then
			return val
		end
		use_simd = false
	end
	local ok, val = pcall(cjson.decode, str)
	if not ok then
		error(ERR.JSON .. ": " .. tostring(val))
	end
	return val
end

local function write_all(fd, data)
	local sent = 0
	while sent < #data do
		local n = write(fd, data:sub(sent + 1))
		if not n or n <= 0 then
			error(ERR.SOCKET .. ": short write")
		end
		sent = sent + n
	end
end

local function read_exactly(fd, size)
	local buf = ""
	while #buf < size do
		local chunk = read(fd, size - #buf)
		if not chunk or #chunk == 0 then
			error(ERR.EOF)
		end
		buf = buf .. chunk
	end
	return buf
end

local function connect(path)
	local fd, err = socket.socket(AF_UNIX, SOCK_STREAM, 0)
	if not fd then
		error(ERR.SOCKET .. ": " .. tostring(err))
	end
	if socket.connect(fd, { family = AF_UNIX, path = path }) ~= 0 then
		close(fd)
		error("cannot connect to " .. path)
	end

	write_all(fd, string.pack("<I4", PROTOCOL_VERSION))
	local server_version = string.unpack("<I4", read_exactly(fd, 4))
	if server_version ~= PROTOCOL_VERSION then
		close(fd)
		error(("protocol mismatch: client %d, server %d"):format(PROTOCOL_VERSION, server_version))
	end

	return fd
end

local Aerospace = {}
Aerospace.__index = Aerospace

function Aerospace.new(path)
	if not path then
		local handle = io.popen("id -un")
		local username = handle:read("*l")
		handle:close()
		path = SOCK_FMT:format(username)
	end

	return setmetatable({ sockPath = path, fd = connect(path) }, Aerospace)
end

function Aerospace:close()
	if self.fd then
		close(self.fd)
		self.fd = nil
	end
end

Aerospace.__gc = Aerospace.close

function Aerospace:reconnect()
	self:close()
	self.fd = connect(self.sockPath)
end

function Aerospace:is_initialized()
	return self.fd ~= nil
end

function Aerospace:_query(args, want_json)
	if not self:is_initialized() then
		error(ERR.NOT_INIT)
	end

	-- windowId/workspace must be explicit nulls, otherwise the server appends a
	-- warning to stderr about an incomplete request
	local payload = encode({
		args = args,
		stdin = "",
		windowId = cjson.null,
		workspace = cjson.null,
	})
	write_all(self.fd, string.pack("<I4", #payload) .. payload)

	local size = string.unpack("<I4", read_exactly(self.fd, 4))
	local answer = decode(read_exactly(self.fd, size))
	if answer.exitCode ~= 0 then
		error("aerospace: " .. tostring(answer.stderr))
	end

	return want_json and decode(answer.stdout) or answer.stdout
end

function Aerospace:list_apps()
	return self:_query({ "list-apps", "--json" }, true)
end

function Aerospace:query_workspaces()
	return self:_query({
		"list-workspaces",
		"--all",
		"--format",
		"%{workspace-is-focused}%{workspace-is-visible}%{workspace}%{monitor-appkit-nsscreen-screens-id}",
		"--json",
	}, true)
end

function Aerospace:list_current()
	return self:_query({ "list-workspaces", "--focused" }, false)
end

function Aerospace:list_windows(space)
	return self:_query({ "list-windows", "--workspace", space, "--json" }, true)
end

function Aerospace:focused_window()
	return self:_query({ "list-windows", "--focused", "--json" }, true)
end

function Aerospace:workspace(ws)
	return self:_query({ "workspace", ws }, false)
end

function Aerospace:list_all_windows()
	return self:_query({
		"list-windows",
		"--all",
		"--json",
		"--format",
		"%{window-id}%{app-name}%{window-title}%{workspace}",
	}, true)
end

return Aerospace
