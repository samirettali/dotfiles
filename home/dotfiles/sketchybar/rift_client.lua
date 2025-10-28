--- rift module for communicating with the Rift window manager via Mach ports
-- @module Rift
-- @copyright 2025
-- @license MIT

local cjson = require("cjson")
local rift_lib = require("rift")

local ERR = {
	NOT_CONNECTED = "not connected to rift",
	JSON = "failed to encode/decode JSON",
	REQUEST_FAILED = "request failed",
}

local Rift = {}
Rift.__index = Rift

function Rift.new()
	local client, err = rift_lib.connect()
	if not client then
		error("Failed to connect to Rift: " .. tostring(err))
	end

	return setmetatable({ client = client }, Rift)
end

function Rift:is_connected()
	return self.client ~= nil
end

function Rift:close()
	if self.client then
		rift_lib.disconnect(self.client)
		self.client = nil
	end
end

Rift.__gc = Rift.close

--- Send a request to rift and return the response
-- @param request string|table The request - can be a JSON string or a table to encode
-- @param await boolean Whether to wait for a response (default true)
-- @return table|nil The response data or nil on error
-- @return string|nil Error message if request failed
function Rift:_request(request, await)
	if not self:is_connected() then
		return nil, ERR.NOT_CONNECTED
	end

	if await == nil then
		await = true
	end

	local request_json
	if type(request) == "string" then
		request_json = request
	else
		request_json = cjson.encode(request)
	end
	local response = rift_lib.send_request(self.client, request_json, await)

	if not response then
		return nil, ERR.REQUEST_FAILED
	end

	-- If we didn't await response, just return success
	if not await then
		return true
	end

	-- Response is already a Lua table (parsed by the C module)
	return response
end

--- Query all workspaces
-- @param cb function Optional callback function(workspaces)
-- @return table Array of workspace data
function Rift:query_workspaces(cb)
	local request = '"get_workspaces"'
	local response, err = self:_request(request)

	if not response then
		error(err)
	end

	-- Extract workspaces from response
	local workspaces = response.data or {}

	if cb then
		cb(workspaces)
	end

	return workspaces
end

--- Get the currently focused workspace
-- @param cb function Optional callback function(workspace_index, workspace_name)
-- @return number, string Workspace index and name
function Rift:get_focused_workspace(cb)
	local workspaces = self:query_workspaces()

	for _, ws in ipairs(workspaces) do
		if ws.is_active then
			if cb then
				cb(ws.index, ws.name)
			end
			return ws.index, ws.name
		end
	end

	return nil, nil
end

--- Get windows for a specific workspace
-- @param space_id number Optional workspace ID to filter by
-- @param cb function Optional callback function(windows)
-- @return table Array of window data
function Rift:get_windows(space_id, cb)
	-- GetWindows has a space_id field, so we use object notation
	local request = {
		get_windows = {
			space_id = space_id,
		},
	}
	local response, err = self:_request(request)

	if not response then
		error(err)
	end

	local windows = response.data or {}

	if cb then
		cb(windows)
	end

	return windows
end

--- Switch to a workspace
-- @param workspace_id number The workspace index to switch to
function Rift:switch_workspace(workspace_id)
	local request = {
		execute_command = {
			command = '{"Reactor":{"Layout":{"SwitchToWorkspace":' .. tostring(workspace_id) .. "}}}",
			args = {},
		},
	}
	return self:_request(request, false)
end

--- Subscribe to Mach IPC events
-- @param event string Event name to subscribe to (e.g., "workspace_changed", "windows_changed", "*")
-- @return boolean, string Success status and error message if failed
function Rift:subscribe(event)
	local request = {
		subscribe = {
			event = event,
		},
	}
	local response, err = self:_request(request)

	if not response then
		return false, err
	end

	return true, nil
end

--- Unsubscribe from Mach IPC events
-- @param event string Event name to unsubscribe from
-- @return boolean, string Success status and error message if failed
function Rift:unsubscribe(event)
	local request = {
		unsubscribe = {
			event = event,
		},
	}
	local response, err = self:_request(request)

	if not response then
		return false, err
	end

	return true, nil
end

return Rift
