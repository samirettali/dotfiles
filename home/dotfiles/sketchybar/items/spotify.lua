local colors = require("colors")
local icons = require("icons")
local separator = require("separator")

local spotify = sbar.add("item", "spotify", {
	position = "right",
	drawing = false,
	icon = {
		string = icons.spotify,
		color = colors.spotify,
	},
})

-- Owned here rather than by `items.init` so it hides with the item and the bar
-- never shows two adjacent rules around an empty section.
local media_separator = separator.add("media")
media_separator:set({ drawing = false })

local current_track_id

local function track_id(uri)
	return uri and uri:match("^spotify:track:([%w]+)$")
end

local function update(info)
	local state = info.state or info["Player State"]
	local id = track_id(info.id or info["Track ID"])
	local title = info.title or info.Name
	local artist = info.artist or info.Artist

	if not state or state:lower() == "stopped" or not id or not title or not artist then
		current_track_id = nil
		spotify:set({ drawing = false })
		media_separator:set({ drawing = false })
		return
	end

	current_track_id = id
	spotify:set({
		drawing = true,
		label = { string = ("%s — %s"):format(title, artist) },
	})
	media_separator:set({ drawing = true })
end

local function refresh()
	sbar.exec(
		[[/usr/bin/osascript -l JavaScript -e 'const spotify = Application("Spotify"); if (!spotify.running()) { JSON.stringify({}); } else { const state = spotify.playerState(); if (state === "stopped") { JSON.stringify({ state }); } else { const track = spotify.currentTrack; JSON.stringify({ state, title: track.name(), artist: track.artist(), id: track.spotifyUrl() }); } }']],
		function(info)
			if type(info) == "table" then
				update(info)
			end
		end
	)
end

-- `media_change` is missed while the machine sleeps or the screen is locked, so
-- the item would keep whatever it showed before. Both wake paths re-query.
sbar.add("event", "screen_unlocked", "com.apple.screenIsUnlocked")

spotify:subscribe({ "media_change", "system_woke", "screen_unlocked" }, refresh)

spotify:subscribe("mouse.clicked", function(_)
	if current_track_id then
		sbar.exec(("/usr/bin/open 'https://sottotesto.samirettali.com/?track=%s'"):format(current_track_id))
	end
end)

refresh()
