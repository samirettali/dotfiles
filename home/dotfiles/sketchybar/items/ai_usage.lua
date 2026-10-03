local cjson = require("cjson")
local colors = require("colors")
local icons = require("icons")
local popup = require("popup")

local WARN = 70
local CRITICAL = 90
local BAR_WIDTH = 90
local WINDOWS = { "5h", "7d" }
local USAGE_FILE = (os.getenv("HOME") or "") .. "/.cache/sketchybar/claude-usage.json"
local USAGE_PAGE = "https://claude.ai/settings/usage"

-- Claude's 5-hour and 7-day usage, one percentage each, beside the Claude mark.
--
-- Claude Code's statusLine command writes the windows to USAGE_FILE and
-- triggers `claude_usage`, so the bar shows what the last active session saw.
-- The minute timer only re-reads the file, to zero a window once it resets.

-- Right-side items render rightmost first: the 7d label is created before the
-- item that carries the icon and the 5h label.
local week = sbar.add("item", "usage.7d", {
	position = "right",
	updates = "on",
	icon = { drawing = false },
	label = { padding_left = 0 },
})

local usage = sbar.add("item", "usage", {
	position = "right",
	updates = "on",
	update_freq = 60,
	icon = {
		string = icons.claude,
		font = { family = "sketchybar-app-font" },
		color = colors.claude,
	},
	label = { padding_right = 0 },
})

local rows = {}
for index, window in ipairs(WINDOWS) do
	rows[window] = sbar.add("slider", "usage.row." .. index, BAR_WIDTH, {
		position = "popup.usage.7d",
		icon = {
			font = { family = FONT },
			color = colors.grey70,
			width = 142,
			align = "left",
		},
		label = { align = "right", width = 44, padding_left = 6 },
		slider = popup.slider,
		click_script = ("/usr/bin/open %q; %s --set %s popup.drawing=off"):format(USAGE_PAGE, SKETCHYBAR_BIN, week.name),
	})
end

local function color_for(percent)
	if percent >= CRITICAL then
		return colors.red
	end
	if percent >= WARN then
		return colors.yellow
	end
	return colors.white
end

-- A window at 0% says nothing on its own; the reset instant says when it moves.
local function window_text(label, at)
	if not at then
		return label
	end
	-- Monospace plus a fixed field: the reset times stack in one column, whether
	-- they carry a weekday or not.
	local format = at - os.time() < 20 * 3600 and "%H:%M" or "%a %H:%M"
	return ("%-2s %11s"):format(label, os.date(format, at))
end

local function read_windows()
	local handle = io.open(USAGE_FILE, "r")
	if not handle then
		return {}
	end
	local contents = handle:read("a")
	handle:close()
	local ok, document = pcall(cjson.decode, contents)
	if not ok or type(document) ~= "table" or type(document.providers) ~= "table" then
		return {}
	end

	local windows = {}
	for _, provider in ipairs(document.providers) do
		if provider.key == "claude" and type(provider.windows) == "table" then
			for _, window in ipairs(provider.windows) do
				local at = tonumber(window.resets_at)
				local percent = math.ceil(tonumber(window.percent) or 0)
				-- The file only changes while a session runs, so a window that
				-- reset since then still carries its old percentage.
				if at and at <= os.time() then
					percent, at = 0, nil
				end
				windows[window.label] = { percent = percent, resets_at = at }
			end
		end
	end
	return windows
end

local function render()
	local windows = read_windows()
	local labels = { ["5h"] = usage, ["7d"] = week }
	for _, label in ipairs(WINDOWS) do
		local window = windows[label]
		-- The 5h item carries the mark, so only its label hides. The 7d item
		-- owns the popup, so it stays drawn while any window exists and drops
		-- its padding instead, which would otherwise leave an empty gap.
		if label == "7d" then
			local padding = window and 4 or 0
			week:set({
				drawing = next(windows) ~= nil,
				label = { drawing = window ~= nil },
				padding_left = padding,
				padding_right = padding,
			})
		else
			usage:set({ label = { drawing = window ~= nil } })
		end
		rows[label]:set({ drawing = window ~= nil })
		if window then
			local color = color_for(window.percent)
			labels[label]:set({ label = { string = ("%d%%"):format(window.percent), color = color } })
			rows[label]:set({
				icon = { string = window_text(label, window.resets_at) },
				slider = { percentage = window.percent, highlight_color = color },
				label = { string = ("%d%%"):format(window.percent), color = color },
			})
		end
	end
end

sbar.add("event", "claude_usage")
usage:subscribe({ "forced", "routine", "system_woke", "claude_usage" }, render)

-- The popup hangs from the 7d item, the right edge of the pair, so its
-- right-aligned rows line up with the widget. The mark opens it too.
local toggle = popup.setup(week, render)
usage:subscribe("mouse.clicked", toggle)

render()
