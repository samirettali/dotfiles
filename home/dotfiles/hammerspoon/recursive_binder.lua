local canvas = require("canvas")
local clipboard = require("clipboard")
local display = require("display")
local emoji = require("emoji")
local transform = require("transform")

-- rbw.lua is only rendered when programs.rbw is enabled
local hasRbw, rbw = pcall(require, "rbw")
local hasSpotctl, spotctl = pcall(require, "spotctl")
local hasBookmarks, bookmarks = pcall(require, "bookmarks")

hs.loadSpoon("RecursiveBinder")

spoon.RecursiveBinder.helperShow = canvas.helper
spoon.RecursiveBinder.helperHide = canvas.hideHelper

local singleKey = spoon.RecursiveBinder.singleKey

local function launch(app)
	return function()
		-- Launch asynchronously using hs.task
		hs.task.new("/usr/bin/open", function() end, { "-a", app }):start()
		return true -- This closes the RecursiveBinder popup immediately
	end
end

local function openDefaultBrowser()
	return function()
		local bundleID = hs.urlevent.getDefaultHandler("https") or hs.urlevent.getDefaultHandler("http")

		if bundleID then
			hs.application.launchOrFocusByBundleID(bundleID)
		else
			hs.urlevent.openURL("https://")
		end

		return true -- This closes the RecursiveBinder popup immediately
	end
end

local function paste(text)
	return function()
		hs.eventtap.keyStrokes(text)
	end
end

local function paste_fn(fn)
	return function()
		hs.eventtap.keyStrokes(fn())
	end
end

local function open(template, query)
	if query == "" then
		return
	end

	hs.urlevent.openURL((string.gsub(template, "{input}", query)))
end

local function search(template)
	return function()
		local domain = string.match(template, "https?://([^/]+)")

		canvas.prompt({
			prompt = ("search %s"):format(domain),
			height = 150,
			onSubmit = function(userInput)
				open(template, userInput)
			end,
		})
	end
end

-- macOS exposes no selection, so the only way to read one is to copy it and put
-- the pasteboard back. The launcher has already handed focus to the app it was
-- called over by the time this runs, which is what cmd+c needs.
local function withSelection(callback)
	local saved = hs.pasteboard.getContents()
	local stamp = hs.pasteboard.changeCount()

	clipboard.pause()

	hs.timer.doAfter(0.2, function()
		hs.eventtap.keyStroke({ "cmd" }, "c")

		hs.timer.doAfter(0.2, function()
			local copied = hs.pasteboard.changeCount() ~= stamp and hs.pasteboard.getContents() or nil

			if saved then
				hs.pasteboard.setContents(saved)
			end

			clipboard.resume()

			if not copied or copied:match("^%s*$") then
				hs.alert.show("search: nothing selected")
				return
			end

			callback((copied:gsub("%s+", " "):match("^%s*(.-)%s*$")))
		end)
	end)
end

local function searchSelection(template)
	return function()
		withSelection(function(query)
			open(template, query)
		end)

		return true
	end
end

local function cmd(c)
	local handle = io.popen(c)
	local result = handle:read("*l")

	handle:close()

	return result
end

local function unixTimestamp()
	return tostring(os.time())
end

local function date()
	return tostring(os.date("!%Y-%m-%d %H:%M:%S"))
end

local function uuid()
	return cmd("uuidgen")
end

local ENGINES = {
	{ "c", "code", "https://github.com/search?q={input}&type=code" },
	{ "g", "google", "https://google.com/search?q={input}" },
	-- { "g", "grep.app", "https://grep.app/search?q={input}" },
	-- { "l", "greppers.com", "https://www.greppers.com/?q={input}" },
	{ "m", "maps", "https://www.google.com/maps/search/{input}" },
	{ "n", "nixos", "https://mynixos.com/search?q={input}" },
	{ "p", "perplexity", "https://perplexity.ai/search?q={input}" },
	{ "r", "repos", "https://github.com/search?q={input}&type=repositories" },
	{ "t", "twitter", "https://x.com/search?q={input}&src=typed_query" },
	{ "y", "youtube", "https://www.youtube.com/results?search_query={input}" },
}

local searchLayer = {}

for _, engine in ipairs(ENGINES) do
	local key, name, template = engine[1], engine[2], engine[3]

	table.insert(searchLayer, { key, name, search(template) })
	-- shift searches whatever is selected instead of asking. Left without a
	-- description on purpose: it binds, but it stays out of the helper rather
	-- than listing every engine twice.
	table.insert(searchLayer, { { "shift" }, key, nil, searchSelection(template) })
end

local config = {
	{ "b", "browser", openDefaultBrowser() },
	{ "c", "clipboard", clipboard.open },
	{ "e", "emoji", emoji.open },
	{ "t", "terminal", launch("Ghostty") },
	{
		"o",
		"open",
		{
			{ "c", "code", launch("Visual Studio Code") },
			{ "d", "discord", launch("Discord") },
			{ "e", "eqMac", launch("eqMac") },
			{ "f", "finder", launch("Finder") },
			{ "m", "monitor", launch("Activity Monitor") },
			{ "o", "obsidian", launch("Obsidian") },
			{ "p", "preferences", launch("System Preferences") },
			{ "s", "spotify", launch("Spotify") },
			{ "z", "zed", launch("Zed") },
		},
	},
	{
		"w",
		"work",
		{
			{ "c", "compass", launch("MongoDB Compass") },
			{ "d", "datagrip", launch("Datagrip") },
			{ "p", "postman", launch("Postman") },
			{ "r", "redis", launch("Redis Insight") },
			{ "s", "slack", launch("Slack") },
		},
	},
	{
		"p",
		"paste",
		{
			{ "e", "email", paste("samir@ettali.com") },
			{ "u", "username", paste("samirettali") },
			{ "t", "timestamp", paste_fn(unixTimestamp) },
			{ "d", "date", paste_fn(date) },
			{ "g", "uuid", paste_fn(uuid) },
		},
	},
	{
		"s",
		"search",
		searchLayer,
	},
	{
		"x",
		"transform",
		{
			{ "d", "base64 decode", transform.base64Decode },
			{ "e", "base64 encode", transform.base64Encode },
			{ "h", "hex decode", transform.hexDecode },
			{ "x", "hex encode", transform.hexEncode },
			{ "u", "url decode", transform.urlDecode },
			{ "p", "url encode", transform.urlEncode },
			{ "j", "jwt", transform.jwt },
			{ "f", "format json", transform.formatJSON },
			{ "t", "timestamp", transform.fromTimestamp },
		},
	},
	{
		"d",
		"display",
		{
			{ "d", "docked", display.docked },
			{ "s", "side by side", display.side_by_side },
			{ "e", "external", display.external },
		},
	},
}

if hasSpotctl then
	table.insert(config, { "m", "music", spotctl.play_playlist })
end

-- this replaced a submenu of seven hardcoded openURL entries: they are all in
-- linkding now, tagged daily, and frecency floats them back to the top
if hasBookmarks then
	table.insert(config, { "l", "links", bookmarks.open })
end

if hasRbw then
	table.insert(config, {
		"v",
		"vault",
		{
			{ "p", "password", rbw.password },
			{ "t", "type", rbw.type_password },
			{ "u", "username", rbw.username },
			{ "o", "otp", rbw.code },
		},
	})
end

-- An entry is { key, name, value }, or { modifiers, key, name, value } when it
-- needs a modifier. A nil name binds the key without listing it in the helper:
-- the spoon only shows an entry that carries a third element.
local function binding(layer)
	if type(layer[1]) == "table" then
		local mods, key, name = layer[1], layer[2], layer[3]

		return name and { mods, key, name } or { mods, key }, layer[4]
	end

	return singleKey(layer[1], layer[2]), layer[3]
end

local function parseConfig(c)
	local result = {}

	for _, layer in pairs(c) do
		local key, value = binding(layer)

		if type(value) == "function" then
			result[key] = value
		end
		if type(value) == "table" then
			result[key] = parseConfig(value)
		end
	end

	return result
end

local keymap = parseConfig(config)

hs.hotkey.bind({ "cmd" }, "space", spoon.RecursiveBinder.recursiveBind(keymap))
