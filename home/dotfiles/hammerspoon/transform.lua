local M = {}

-- Everything here runs on the clipboard and writes the result back to it, so a
-- transform is a keystroke rather than a trip to a website. Pure Lua on purpose:
-- shelling out would mean quoting whatever happens to be on the pasteboard.

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64Encode(input)
	local out = {}

	local function char(value)
		local at = (value & 63) + 1

		return B64:sub(at, at)
	end

	for i = 1, #input, 3 do
		local a, b, c = input:byte(i, i + 2)
		local n = a * 65536 + (b or 0) * 256 + (c or 0)

		out[#out + 1] = char(n >> 18) .. char(n >> 12) .. (b and char(n >> 6) or "=") .. (c and char(n) or "=")
	end

	return table.concat(out)
end

-- takes base64url too, which is what a JWT carries
local function base64Decode(input)
	local clean = input:gsub("%s+", "")
	clean = clean:gsub("%-", "+")
	clean = clean:gsub("_", "/")
	clean = clean:gsub("=+$", "")

	local out, value, bits = {}, 0, 0

	for i = 1, #clean do
		local at = B64:find(clean:sub(i, i), 1, true)

		if not at then
			return nil, "not base64"
		end

		value = value * 64 + (at - 1)
		bits = bits + 6

		if bits >= 8 then
			bits = bits - 8
			out[#out + 1] = string.char((value >> bits) & 255)
			value = value & ((1 << bits) - 1)
		end
	end

	return table.concat(out)
end

local function hexEncode(input)
	return (input:gsub(".", function(char)
		return ("%02x"):format(char:byte())
	end))
end

local function hexDecode(input)
	local clean = input:gsub("%s+", "")
	clean = clean:gsub("^0[xX]", "")

	if #clean % 2 == 1 or clean:find("%X") then
		return nil, "not hex"
	end

	return (clean:gsub("%x%x", function(pair)
		return string.char(tonumber(pair, 16))
	end))
end

local function urlEncode(input)
	return (input:gsub("[^%w%-%.%_%~]", function(char)
		return ("%%%02X"):format(char:byte())
	end))
end

local function urlDecode(input)
	local clean = input:gsub("+", " ")

	return (clean:gsub("%%(%x%x)", function(pair)
		return string.char(tonumber(pair, 16))
	end))
end

local function formatJSON(input)
	local decoded = hs.json.decode(input)

	if decoded == nil then
		return nil, "not json"
	end

	return hs.json.encode(decoded, true)
end

local function jwt(input)
	local parts = {}

	for part in input:gsub("%s+", ""):gmatch("[^%.]+") do
		table.insert(parts, part)
	end

	if #parts < 2 then
		return nil, "not a jwt"
	end

	local out = {}

	for i = 1, 2 do
		local decoded, message = base64Decode(parts[i])

		if not decoded then
			return nil, message
		end

		out[i] = formatJSON(decoded) or decoded
	end

	-- the signature stays out: it is bytes, and nothing readable comes of it
	return out[1] .. "\n" .. out[2]
end

local function fromTimestamp(input)
	local seconds = tonumber((input:gsub("%s+", "")))

	if not seconds then
		return nil, "not a number"
	end

	-- a value this large is milliseconds, which is what a JS payload carries
	if seconds > 1e11 then
		seconds = seconds // 1000
	end

	return os.date("!%Y-%m-%d %H:%M:%S UTC", math.floor(seconds))
end

-- a toast is there to confirm, not to read the whole result in
local function preview(text)
	local lines = {}

	for line in (text .. "\n"):gmatch("([^\n]*)\n") do
		if #lines == 8 then
			table.insert(lines, "…")
			break
		end

		table.insert(lines, #line > 60 and (line:sub(1, 59) .. "…") or line)
	end

	return table.concat(lines, "\n")
end

local function apply(fn)
	return function()
		local input = hs.pasteboard.getContents()

		if type(input) ~= "string" or input:match("^%s*$") then
			hs.alert.show("transform: the clipboard is empty")
			return true
		end

		local result, message = fn(input)

		if not result then
			hs.alert.show("transform: " .. (message or "failed"))
			return true
		end

		hs.pasteboard.setContents(result)
		hs.alert.show(preview(result), 4)

		return true
	end
end

M.base64Decode = apply(base64Decode)
M.base64Encode = apply(base64Encode)
M.hexDecode = apply(hexDecode)
M.hexEncode = apply(hexEncode)
M.urlDecode = apply(urlDecode)
M.urlEncode = apply(urlEncode)
M.formatJSON = apply(formatJSON)
M.jwt = apply(jwt)
M.fromTimestamp = apply(fromTimestamp)

return M
