local cjson = require("cjson")
local colors = require("colors")

-- Agents waiting for you: blocked, and finished-but-unseen. Hidden while nothing
-- is pending, like the status items, so it only shows up as something to act on.
--
-- Counts are pushed by `herdr-sketchybar`, a launchd agent holding Herdr's
-- socket open, which triggers `herdr_agents`. Nothing here polls. The per-agent
-- rows come from a file that agent writes, read only when the popup opens.
--
-- Both counts stay visible at once: blocked and done are different urgencies,
-- and with several agents pending the colour alone cannot say which is which.
local DETAIL = (os.getenv("HOME") or "") .. "/.cache/sketchybar/herdr-agents.json"

-- Herdr draws every state needing attention as a filled dot; the colour carries
-- the meaning (`state_dot` / `state_label_color` in its sidebar).
local DOT = "●"
local STATE_COLOR = { blocked = colors.red, done = colors.turquoise }

-- Rows are created once and shown or hidden. Adding and removing them per event
-- would need the ordering kept in sync, and a failure halfway leaves ghosts.
local MAX_ROWS = 10

-- Focusing the pane only moves Herdr's own focus; without activating the
-- terminal the click changes something you cannot see.
local TERMINAL_APP = "Ghostty"

sbar.add("event", "herdr_agents")

local item = sbar.add("item", "herdr.agents", {
	position = "right",
	drawing = false,
	updates = "on",
	icon = { font = { style = "Bold" }, color = STATE_COLOR.blocked },
	label = { font = { style = "Bold" }, color = STATE_COLOR.done },
	-- The popup background is not drawn by default, which leaves the rows
	-- floating over the desktop. Matched to `bar.lua`.
	popup = {
		align = "right",
		background = {
			color = colors.black,
			border_color = colors.grey,
			border_width = 1,
			corner_radius = 6,
			padding_left = 6,
			padding_right = 6,
		},
	},
})

local rows = {}
for index = 1, MAX_ROWS do
	rows[index] = sbar.add("item", "herdr.agents.row." .. index, {
		position = "popup.herdr.agents",
		drawing = false,
		icon = { string = DOT, padding_right = 6 },
		label = { max_chars = 40 },
	})
end

local function close_popup()
	item:set({ popup = { drawing = false } })
end

local function read_pending()
	local handle = io.open(DETAIL, "r")
	if not handle then
		return {}
	end
	local contents = handle:read("a")
	handle:close()
	local ok, decoded = pcall(cjson.decode, contents)
	if not ok or type(decoded) ~= "table" or type(decoded.agents) ~= "table" then
		return {}
	end
	return decoded.agents
end

local function fill_popup()
	local pending = read_pending()
	for index = 1, MAX_ROWS do
		local entry = pending[index]
		if entry then
			local color = STATE_COLOR[entry.status] or colors.grey70
			rows[index]:set({
				drawing = true,
				icon = { color = color },
				label = { string = ("%s · %s"):format(entry.project, entry.status) },
				-- `agent focus` jumps to a pane by id, switching workspace and
				-- tab on the way; `pane focus` is directional (left/right/up/
				-- down) and silently prints usage when handed an id.
				--
				-- HERDR_BIN is set in sketchybarrc: a click_script runs through
				-- a shell that does not have the nix profile on PATH.
				click_script = ("%s agent focus %q; open -a %q; sketchybar --set %s popup.drawing=off"):format(
					HERDR_BIN,
					entry.pane_id,
					TERMINAL_APP,
					item.name
				),
			})
		else
			rows[index]:set({ drawing = false })
		end
	end
	-- More pending than rows: say so rather than silently dropping them.
	if #pending > MAX_ROWS then
		rows[MAX_ROWS]:set({
			label = { string = ("+%d more"):format(#pending - MAX_ROWS + 1) },
			click_script = "",
		})
	end
end

item:subscribe("herdr_agents", function(env)
	local blocked = tonumber(env.blocked) or 0
	local done = tonumber(env.done) or 0

	if blocked + done == 0 then
		item:set({ drawing = false, popup = { drawing = false } })
		return
	end

	item:set({
		drawing = true,
		icon = { string = blocked > 0 and (DOT .. " " .. blocked) or "" },
		label = { string = done > 0 and (DOT .. " " .. done) or "" },
	})

	-- Keep an open popup honest instead of showing the previous state.
	local popup = item:query()
	if popup and popup.popup and popup.popup.drawing == "on" then
		fill_popup()
	end
end)

item:subscribe("mouse.clicked", function()
	local current = item:query()
	local open = current and current.popup and current.popup.drawing == "on"
	if open then
		close_popup()
		return
	end
	fill_popup()
	item:set({ popup = { drawing = true } })
end)

item:subscribe("mouse.exited.global", close_popup)
