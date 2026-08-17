local colors = require("colors")
local icons = require("icons")

local spotify = sbar.add("item", "spotify", {
	position = "right",
	drawing = false,
	icon = {
		string = icons.spotify,
		color = colors.spotify,
	},
})

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
		return
	end

	current_track_id = id
	spotify:set({
		drawing = true,
		label = { string = ("%s — %s"):format(title, artist) },
	})
end

sbar.add("event", "spotify_change", "com.spotify.client.PlaybackStateChanged")

spotify:subscribe("spotify_change", function(env)
	update(env.INFO)
end)

spotify:subscribe("mouse.clicked", function(_)
	if current_track_id then
		sbar.exec(("/usr/bin/open 'https://sottotesto.samirettali.com/?track=%s'"):format(current_track_id))
	end
end)

sbar.exec([[/usr/bin/osascript -l JavaScript -e 'const spotify = Application("Spotify"); if (!spotify.running()) { JSON.stringify({}); } else { const track = spotify.currentTrack; JSON.stringify({ state: spotify.playerState(), title: track.name(), artist: track.artist(), id: track.spotifyUrl() }); }']], function(info)
	if type(info) == "table" then
		update(info)
	end
end)
