local canvas = require("canvas")
local frecency = require("frecency")
local task = require("task")

local M = {}

local MDFIND = "/usr/bin/mdfind"
local QUERY = 'kMDItemContentType == "com.apple.application-bundle"'
local HOME = os.getenv("HOME")

local uses = frecency.new("applications.uses")
local cached = nil
local icons = {}
local loading = false
local waiting = {}

local function location(path)
	local parent = path:match("^(.*)/[^/]+%.app$") or ""

	if parent:sub(1, #HOME) == HOME then
		return "~" .. parent:sub(#HOME + 1)
	end

	return parent
end

local function startsWith(value, prefix)
	return value:sub(1, #prefix) == prefix
end

local function isUserFacing(path)
	if path:find("%.app/") then
		return false
	end

	return startsWith(path, "/Applications/")
		or startsWith(path, "/System/Applications/")
		or startsWith(path, HOME .. "/Applications/")
		or path == "/System/Library/CoreServices/Finder.app"
		or startsWith(path, "/System/Library/CoreServices/Applications/")
end

local function iconProvider(path)
	return function()
		if icons[path] == nil then
			icons[path] = hs.image.iconForFile(path) or false
		end

		return icons[path] or nil
	end
end

local function choices(stdout)
	local result = {}
	local seen = {}

	for record in stdout:gmatch("[^%z]+") do
		local path, displayName = record:match("^(.-)%s%s%skMDItemDisplayName = (.*)$")
		local bundleName = path and path:match("/([^/]+)%.app$")
		local name = displayName ~= "(null)" and displayName or bundleName

		if name and isUserFacing(path) and not seen[path] then
			seen[path] = true
			table.insert(result, {
				text = name,
				subText = location(path),
				path = path,
				imageProvider = iconProvider(path),
			})
		end
	end

	return result
end

local function refresh(done)
	if done then
		table.insert(waiting, done)
	end

	if loading then
		return
	end

	loading = true
	task.run(MDFIND, { "-0", "-attr", "kMDItemDisplayName", QUERY }, function(stdout)
		loading = false
		local found = choices(stdout)

		if #found > 0 then
			cached = found
		end

		local callbacks = waiting
		waiting = {}

		for _, callback in ipairs(callbacks) do
			callback(cached)
		end
	end, function(message)
		loading = false
		local callbacks = waiting
		waiting = {}

		for _, callback in ipairs(callbacks) do
			callback(cached)
		end

		hs.alert.show("applications: " .. message)
	end)
end

local function openPicker(apps)
	if not apps or #apps == 0 then
		hs.alert.show("applications: none found")
		return
	end

	local score = uses.scores()

	for _, app in ipairs(apps) do
		app.boost = score(app.path)
	end

	canvas.picker({
		prompt = "applications",
		choices = apps,
		onSelect = function(choice)
			uses.remember(choice.path)
			hs.application.open(choice.path)
		end,
	})
end

function M.show()
	if cached then
		openPicker(cached)
		refresh()
	else
		refresh(openPicker)
	end

	return true
end

return M
