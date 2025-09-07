local spotify = require("spotify")
local display = require("display")
-- local bookmarks = require("bookmarks") -- TODO
-- local nur = require("nur") -- TODO

hs.loadSpoon("RecursiveBinder")

spoon.RecursiveBinder.helperFormat = hs.alert.defaultStyle
spoon.RecursiveBinder.helperEntryEachLine = 1
spoon.RecursiveBinder.helperEntryLengthInChar = 0

local singleKey = spoon.RecursiveBinder.singleKey

local function launch(app)
	return function()
		-- Launch asynchronously using hs.task
		hs.task.new("/usr/bin/open", function() end, { "-a", app }):start()
		return true -- This closes the RecursiveBinder popup immediately
	end
end

urls = {}

local function openURL(url)
	table.insert(urls, url)

	return function()
		hs.urlevent.openURL(url)
	end
end

local function fuzzyOpenURL(url)
	local chooser = hs.chooser.new(function(selected)
		if not selected then
			return
		end
		hs.urlevent.openURL(selected.uuid)
	end)

	local choices = {}

	for _, url in pairs(urls) do
		local choice = {
			["text"] = url,
			["subText"] = "",
			["uuid"] = url,
		}

		table.insert(choices, choice)
	end

	chooser:choices(choices)
	-- add queryChangedCallback and if only one result is shown then open the url
	chooser:queryChangedCallback(function(query)
		if #query == 0 then
			return
		end

		-- use fzy to filter the choices
		local filteredChoices = hs.fnutils.filter(choices, function(choice)
			return string.find(choice.text:lower(), query:lower(), 1, true) ~= nil
		end)

		if #filteredChoices == 1 then
			-- If only one result is shown, open the URL immediately
			chooser:hide()
			hs.urlevent.openURL(filteredChoices[1].uuid)
			return
		end

		chooser:choices(filteredChoices)
	end)

	chooser:show()
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

local function search(template)
	return function()
		local focusedWindow = hs.window.focusedWindow()
		local button, userInput = hs.dialog.textPrompt("", "", "", "Submit", "Cancel")

		if focusedWindow then
			focusedWindow:focus()
		end

		if button == "Cancel" then
			return
		end

		local url = string.gsub(template, "{input}", userInput)

		hs.urlevent.openURL(url)
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

hs.timer.doEvery(60, spotify.fetch_playlists)

local config = {
	{ "m", "music", spotify.play_playlist },
	{ "b", "browser", launch("Firefox") },
	{ "t", "terminal", launch("Ghostty") },
	{
		"o",
		"[open]",
		{
			{ "c", "code", launch("Visual Studio Code - Insiders") },
			{ "d", "discord", launch("Discord") },
			{ "e", "eqMac", launch("eqMac") },
			{ "f", "finder", launch("Finder") },
			{ "k", "keepassxc", launch("KeepassXC") },
			{ "m", "monitor", launch("Activity Monitor") },
			{ "p", "preferences", launch("System Preferences") },
			{ "s", "spotify", launch("Spotify") },
		},
	},
	{
		"w",
		"[work]",
		{
			{ "c", "compass", launch("MongoDB Compass") },
			{ "d", "datagrip", launch("Datagrip") },
			{ "p", "postman", launch("Postman") },
			{ "r", "redis", launch("Redis Insight") },
			{ "s", "slack", launch("Slack") },
		},
	},
	{
		"l",
		"[links]",
		{
			{
				"c",
				"claude",
				openURL("https://claude.ai"),
			},
			{ "y", "youtube", openURL("youtube.com") },
			{
				"t",
				"[t]",
				{
					{ "w", "twitter", openURL("https://twitter.com") },
					{ "3", "t3.chat", openURL("https://t3.chat") },
					{ "r", "tradingview", openURL("https://www.tradingview.com/chart/4ztWXosm") },
				},
			},
			{
				"g",
				"[g]",
				{
					{ "e", "gemini", openURL("https://gemini.google.com") },
					{ "o", "google", openURL("https://google.com") },
					{ "m", "gmail", openURL("https://mail.google.com") },
				},
			},
			{ "d", "drive", openURL("https://drive.google.com") },
			{ "w", "whatsapp", openURL("https://web.whatsapp.com") },
		},
	},
	{
		"p",
		"[paste]",
		{
			{ "e", "email", paste("ettali.samir@gmail.com") },
			{ "u", "username", paste("samirettali") },
			{ "t", "timestamp", paste_fn(unixTimestamp) },
			{ "d", "timestamp", paste_fn(date) },
			{ "g", "uuid", paste_fn(uuid) },
		},
	},
	{
		"s",
		"[search]",
		{
			{ "c", "code", search("https://github.com/search?q={input}&type=code") },
			{ "d", "duckduckgo", search("https://duckduckgo.com?q={input}") },
			{ "g", "grep.app", search("https://grep.app/search?q={input}") },
			{ "l", "greppers.com", search("https://www.greppers.com/?q={input}") },
			{ "m", "maps", search("https://www.google.com/maps/search/{input}") },
			{ "n", "nixos", search("https://mynixos.com/search?q={input}") },
			{ "p", "perplexity", search("https://perplexity.ai/search?q={input}") },
			{ "r", "repos", search("https://github.com/search?q={input}&type=repositories") },
			{ "t", "twitter", search("https://x.com/search?q={input}&src=typed_query") },
			{ "w", "google", search("https://google.com/search?q={input}") },
			{ "y", "youtube", search("https://www.youtube.com/results?search_query={input}") },
			-- { "u", "nur", nur.show },
			-- {
			-- 	"b",
			-- 	"bookmarks",
			-- 	bookmarks.show,
			-- },
		},
	},
	{
		"d",
		"[display]",
		{
			{ "d", "docked", display.docked },
			{ "s", "side by side", display.side_by_side },
			{ "e", "external", display.external },
		},
	},
	{
		"u",
		"urls",
		fuzzyOpenURL,
	},
}

local function parseConfig(c)
	local result = {}

	for _, layer in pairs(c) do
		if type(layer[3]) == "function" then
			result[singleKey(layer[1], layer[2])] = layer[3]
		end
		if type(layer[3]) == "table" then
			result[singleKey(layer[1], layer[2])] = parseConfig(layer[3])
		end
	end

	return result
end

local keymap = parseConfig(config)

hs.hotkey.bind({ "cmd" }, "space", spoon.RecursiveBinder.recursiveBind(keymap))
