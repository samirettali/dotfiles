local icons = require("icons")
local colors = require("colors")
local spotify = require("spotify_client").new("127.0.0.1", "9999")

sbar.add("event", "spotify_player_event_hook")

local item = sbar.add("item", "music", {
	position = "right",
})

local function set()
	local playback = spotify:get_playback()

	local parts = {
		playback and playback.item and playback.item.name or "No track playing",
		playback and playback.item and playback.item.album and playback.item.album.name or nil,
	}

	local label = table.concat(parts, " - ")
	local icon = playback.is_playing and icons.media.play or icons.media.pause

	sbar.set("music", {
		icon = {
			string = icon,
		},
		label = {
			string = label,
		},
	})
end

set()

item:subscribe("spotify_player_event_hook", function(env)
	local track_id = env.ITEM_ID:gsub("spotify:track:", "")
	local track = spotify:get_track(track_id)

	local parts = {
		track and track.name or "No track playing",
		track and track.album and track.album.name or nil,
	}

	local label = table.concat(parts, " - ")
	local icon = (env.STATE == "Playing" or env.STATE == "Changed") and icons.media.play or icons.media.pause

	sbar.set("music", {
		icon = { string = icon },
		label = { string = label },
	})
end)
