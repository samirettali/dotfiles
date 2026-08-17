local cjson = require("cjson")
local colors = require("colors")
local icons = require("icons")
local popup = require("popup")

local WARN = 70
local CRITICAL = 90
local IDLE_FREQ = 300
local ALERT_FREQ = 60
local MAX_ROWS = 8
local CACHE_DIR = (os.getenv("HOME") or "") .. "/.cache/sketchybar"
local CACHE_FILE = CACHE_DIR .. "/ai-usage.json"

local usage = sbar.add("item", "usage", {
	position = "right",
	updates = "on",
	icon = { string = icons.usage },
	label = { drawing = false },
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
	rows[index] = sbar.add("item", "usage.row." .. index, {
		position = "popup.usage",
		drawing = false,
		icon = { drawing = false },
	})
end

-- One fetch answers for both providers, so a hidden item owns the timer.
local poller = sbar.add("item", "usage.poller", {
	position = "right",
	drawing = false,
	updates = "on",
	update_freq = IDLE_FREQ,
})

-- Keep the last successful limits for each provider. A transient auth renewal
-- must not empty half of an open popup.
local limits_by_provider = {}
local provider_order = { "claude", "codex" }

local function load_cache()
	local handle = io.open(CACHE_FILE, "r")
	if not handle then
		return
	end
	local contents = handle:read("a")
	handle:close()
	local ok, cached = pcall(cjson.decode, contents)
	if ok and type(cached) == "table" then
		limits_by_provider = cached
	end
end

local function save_cache()
	sbar.exec(("mkdir -p %q"):format(CACHE_DIR), function()
		local handle = io.open(CACHE_FILE, "w")
		if not handle then
			return
		end
		handle:write(cjson.encode(limits_by_provider))
		handle:close()
	end)
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

local function render()
	local limits = {}
	local worst = 0

	for _, key in ipairs(provider_order) do
		for _, limit in ipairs(limits_by_provider[key] or {}) do
			limits[#limits + 1] = limit
			worst = math.max(worst, limit.percent)
		end
	end

	for index, row in ipairs(rows) do
		local limit = limits[index]
		if limit then
			local color = color_for(limit.percent)
			row:set({
				drawing = true,
				label = {
					string = ("%-6s · %-5s · %3d%%"):format(limit.provider, limit.label, limit.percent),
					color = color,
				},
			})
		else
			row:set({ drawing = false })
		end
	end

	usage:set({ icon = { color = color_for(worst) } })
	poller:set({ update_freq = worst >= WARN and ALERT_FREQ or IDLE_FREQ })
end

local function refresh()
	sbar.exec(AI_USAGE_BIN, function(out)
		local payload = out
		if type(payload) == "string" then
			local ok, decoded = pcall(cjson.decode, payload)
			if not ok then
				return
			end
			payload = decoded
		end

		if type(payload) ~= "table" or type(payload.providers) ~= "table" then
			return
		end

		local updated = false
		for _, provider in ipairs(payload.providers) do
			if not provider.error then
				local limits = {}
				for _, window in ipairs(provider.windows or {}) do
					limits[#limits + 1] = {
						provider = provider.name,
						label = window.label,
						percent = tonumber(window.percent) or 0,
					}
				end
				limits_by_provider[provider.key] = limits
				updated = true
			end
		end

		if updated then
			save_cache()
		end
		render()
	end)
end

poller:subscribe({ "forced", "routine", "system_woke" }, refresh)

popup.setup(usage, refresh)

load_cache()
render()
refresh()
