-- local spotify = require("spotify")
local canvas = require("canvas")
local display = require("display")

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

urls = {}

local function openURL(url)
	table.insert(urls, url)

	return function()
		hs.urlevent.openURL(url)
		return true
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

local function search(template)
	return function()
		local focusedWindow = hs.window.focusedWindow()
		local domain = string.match(template, "https?://([^/]+)")
		local prompt = ("search %s"):format(domain)

		canvas.prompt({
			prompt = prompt,
			height = 150,
			onSubmit = function(userInput)
				if focusedWindow then
					focusedWindow:focus()
				end

				if userInput == "" then
					return
				end

				local url = string.gsub(template, "{input}", userInput)
				hs.urlevent.openURL(url)
			end,
			onCancel = function()
				if focusedWindow then
					focusedWindow:focus()
				end
			end,
		})
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

-- hs.timer.doEvery(60, spotify.fetch_playlists)

local config = {
	-- { "m", "music", spotify.play_playlist },
	{ "b", "browser", openDefaultBrowser() },
	{ "t", "terminal", launch("Ghostty") },
	{
		"o",
		"[open]",
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
			{ "c", "claude", openURL("https://claude.ai") },
			{ "y", "youtube", openURL("youtube.com") },
			{ "t", "twitter", openURL("https://twitter.com") },
			{ "c", "chat", openURL("https://chat.openai.com") },
			{ "g", "google", openURL("https://google.com") },
			{ "w", "whatsapp", openURL("https://web.whatsapp.com") },
			{ "m", "mail", openURL("https://fastmail.com") },
		},
	},
	{
		"p",
		"[paste]",
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
		"[search]",
		{
			{ "c", "code", search("https://github.com/search?q={input}&type=code") },
			{ "g", "google", search("https://google.com/search?q={input}") },
			-- { "g", "grep.app", search("https://grep.app/search?q={input}") },
			-- { "l", "greppers.com", search("https://www.greppers.com/?q={input}") },
			{ "m", "maps", search("https://www.google.com/maps/search/{input}") },
			{ "n", "nixos", search("https://mynixos.com/search?q={input}") },
			{ "p", "perplexity", search("https://perplexity.ai/search?q={input}") },
			{ "r", "repos", search("https://github.com/search?q={input}&type=repositories") },
			{ "t", "twitter", search("https://x.com/search?q={input}&src=typed_query") },
			{ "y", "youtube", search("https://www.youtube.com/results?search_query={input}") },
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
