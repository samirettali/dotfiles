#!/usr/bin/env lua

local socket = require("socket")
local cjson = require("cjson")

local SpotifyClient = {}
SpotifyClient.__index = SpotifyClient

-- Default configuration
local DEFAULT_HOST = "127.0.0.1"
local DEFAULT_PORT = 8080
local MAX_REQUEST_SIZE = 4096

-- Create a new Spotify client instance
function SpotifyClient.new(host, port)
	local self = setmetatable({}, SpotifyClient)
	self.host = host or DEFAULT_HOST
	self.port = port or DEFAULT_PORT
	self.socket = nil
	return self
end

-- Connect to the spotify-player socket
function SpotifyClient:connect()
	self.socket = socket.udp()
	if not self.socket then
		error("Failed to create UDP socket")
	end

	-- Connect to the server
	local success, err = self.socket:setpeername(self.host, self.port)
	if not success then
		error("Failed to connect to spotify-player: " .. (err or "unknown error"))
	end

	-- Send connection request (empty message)
	self.socket:send("")

	-- Wait for acknowledgment
	local ack = self.socket:receive()
	if not ack then
		error("Failed to establish connection with spotify-player")
	end

	return true
end

-- Close the connection
function SpotifyClient:close()
	if self.socket then
		self.socket:close()
		self.socket = nil
	end
end

-- Send a request and receive response
function SpotifyClient:_send_request(request)
	if not self.socket then
		self:connect()
	end

	-- Serialize request to JSON
	local json_request = cjson.encode(request)
	if #json_request > MAX_REQUEST_SIZE then
		error("Request too large: " .. #json_request .. " bytes (max: " .. MAX_REQUEST_SIZE .. ")")
	end

	-- Send request
	local success, err = self.socket:send(json_request)
	if not success then
		error("Failed to send request: " .. (err or "unknown error"))
	end

	-- Receive response chunks
	local response_data = ""
	while true do
		local chunk, err = self.socket:receive()
		if not chunk then
			error("Failed to receive response: " .. (err or "unknown error"))
		end

		-- Empty chunk indicates end of response
		if #chunk == 0 then
			break
		end

		response_data = response_data .. chunk
	end

	local json_response = "{"
	for byte_str in response_data:gmatch("([^,]+)") do
		local byte_val = tonumber(byte_str)
		if byte_val ~= nil then
			json_response = json_response .. string.char(byte_val)
		end
	end
	json_response = json_response .. "}"

	local response = cjson.decode(json_response)

	return response
end

-- Get current playback information
function SpotifyClient:get_playback()
	local request = {
		Get = {
			Key = "Playback",
		},
	}
	return self:_send_request(request)
end

-- Get available devices
function SpotifyClient:get_devices()
	local request = {
		Get = {
			Key = "Devices",
		},
	}
	return self:_send_request(request)
end

-- Get user playlists
function SpotifyClient:get_user_playlists()
	local request = {
		Get = {
			Key = "UserPlaylists",
		},
	}
	return self:_send_request(request)
end

-- Get user liked tracks
function SpotifyClient:get_user_liked_tracks()
	local request = {
		Get = {
			Key = "UserLikedTracks",
		},
	}
	return self:_send_request(request)
end

-- Get user saved albums
function SpotifyClient:get_user_saved_albums()
	local request = {
		Get = {
			Key = "UserSavedAlbums",
		},
	}
	return self:_send_request(request)
end

-- Get user followed artists
function SpotifyClient:get_user_followed_artists()
	local request = {
		Get = {
			Key = "UserFollowedArtists",
		},
	}
	return self:_send_request(request)
end

-- Get user top tracks
function SpotifyClient:get_user_top_tracks()
	local request = {
		Get = {
			Key = "UserTopTracks",
		},
	}
	return self:_send_request(request)
end

-- Get queue
function SpotifyClient:get_queue()
	local request = {
		Get = {
			Key = "Queue",
		},
	}
	return self:_send_request(request)
end

-- Get playlist by ID or name
function SpotifyClient:get_playlist(id_or_name)
	local id_type = type(id_or_name) == "table" and id_or_name or { Id = id_or_name }
	local request = {
		Get = {
			Item = { "Playlist", id_type },
		},
	}
	return self:_send_request(request)
end

-- Get album by ID or name
function SpotifyClient:get_album(id_or_name)
	local id_type = type(id_or_name) == "table" and id_or_name or { Id = id_or_name }
	local request = {
		Get = {
			Item = { "Album", id_type },
		},
	}
	return self:_send_request(request)
end

-- Get artist by ID or name
function SpotifyClient:get_artist(id_or_name)
	local id_type = type(id_or_name) == "table" and id_or_name or { Id = id_or_name }
	local request = {
		Get = {
			Item = { "Artist", id_type },
		},
	}
	return self:_send_request(request)
end

-- Get track by ID or name
function SpotifyClient:get_track(id_or_name)
	local id_type = type(id_or_name) == "table" and id_or_name or { Id = id_or_name }
	local request = {
		Get = {
			Item = { "Track", id_type },
		},
	}
	return self:_send_request(request)
end

-- Search Spotify
function SpotifyClient:search(query)
	local request = {
		Search = {
			query = query,
		},
	}
	return self:_send_request(request)
end

-- Playback control methods
function SpotifyClient:play_pause()
	local request = {
		Playback = "PlayPause",
	}
	return self:_send_request(request)
end

function SpotifyClient:play()
	local request = {
		Playback = "Play",
	}
	return self:_send_request(request)
end

function SpotifyClient:pause()
	local request = {
		Playback = "Pause",
	}
	return self:_send_request(request)
end

function SpotifyClient:next_track()
	local request = {
		Playback = "Next",
	}
	return self:_send_request(request)
end

function SpotifyClient:previous_track()
	local request = {
		Playback = "Previous",
	}
	return self:_send_request(request)
end

function SpotifyClient:shuffle()
	local request = {
		Playback = "Shuffle",
	}
	return self:_send_request(request)
end

function SpotifyClient:repeat_mode()
	local request = {
		Playback = "Repeat",
	}
	return self:_send_request(request)
end

-- Set volume (0-100)
function SpotifyClient:set_volume(percent)
	local request = {
		Playback = {
			Volume = {
				percent = percent,
				is_offset = false,
			},
		},
	}
	return self:_send_request(request)
end

-- Adjust volume by offset (-100 to +100)
function SpotifyClient:adjust_volume(offset)
	local request = {
		Playback = {
			Volume = {
				percent = offset,
				is_offset = true,
			},
		},
	}
	return self:_send_request(request)
end

-- Seek track by milliseconds offset
function SpotifyClient:seek(offset_ms)
	local request = {
		Playback = {
			Seek = offset_ms,
		},
	}
	return self:_send_request(request)
end

-- Start playing a track
function SpotifyClient:start_track(id_or_name)
	local id_type = type(id_or_name) == "table" and id_or_name or { Id = id_or_name }
	local request = {
		Playback = {
			StartTrack = id_type,
		},
	}
	return self:_send_request(request)
end

-- Start playing a context (playlist, album, artist)
function SpotifyClient:start_context(context_type, id_or_name, shuffle)
	local id_type = type(id_or_name) == "table" and id_or_name or { Id = id_or_name }
	shuffle = shuffle or false
	local request = {
		Playback = {
			StartContext = {
				context_type = context_type,
				id_or_name = id_type,
				shuffle = shuffle,
			},
		},
	}
	return self:_send_request(request)
end

-- Start playing liked tracks
function SpotifyClient:start_liked_tracks(limit, random)
	limit = limit or 50
	random = random or false
	local request = {
		Playback = {
			StartLikedTracks = {
				limit = limit,
				random = random,
			},
		},
	}
	return self:_send_request(request)
end

-- Start radio based on item
function SpotifyClient:start_radio(item_type, id_or_name)
	local id_type = type(id_or_name) == "table" and id_or_name or { Id = id_or_name }
	local request = {
		Playback = {
			StartRadio = { item_type, id_type },
		},
	}
	return self:_send_request(request)
end

-- Connect to device
function SpotifyClient:connect_device(id_or_name)
	local id_type = type(id_or_name) == "table" and id_or_name or { Id = id_or_name }
	local request = {
		Connect = id_type,
	}
	return self:_send_request(request)
end

-- Like/unlike current track
function SpotifyClient:like_track(unlike)
	unlike = unlike or false
	local request = {
		Like = {
			unlike = unlike,
		},
	}
	return self:_send_request(request)
end

-- Playlist management
function SpotifyClient:create_playlist(name, public, collaborative, description)
	public = public ~= false -- default to true
	collaborative = collaborative or false
	description = description or ""

	local request = {
		Playlist = {
			New = {
				name = name,
				public = public,
				collab = collaborative,
				description = description,
			},
		},
	}
	return self:_send_request(request)
end

function SpotifyClient:list_playlists()
	local request = {
		Playlist = "List",
	}
	return self:_send_request(request)
end

-- Utility function to create ID or Name objects
function SpotifyClient.id(id_string)
	return { Id = id_string }
end

function SpotifyClient.name(name_string)
	return { Name = name_string }
end

return SpotifyClient
