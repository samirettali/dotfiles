local cjson = require("cjson")
local colors = require("colors")
local icons = require("icons")
local popup = require("popup")

local WARN = 70
local CRITICAL = 90
local IDLE_FREQ = 300
local ALERT_FREQ = 60
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

local provider_order = { "claude", "codex" }
local provider_names = { claude = "Claude", codex = "Codex" }
local sections = {}

local function rebuild_sections(limits_by_provider)
	local changed = false
	for _, key in ipairs(provider_order) do
		local count = #(limits_by_provider[key] or {})
		if not sections[key] or #sections[key].rows ~= count then
			changed = true
		end
	end
	if not changed then
		return
	end

	for _, section in pairs(sections) do
		sbar.remove(section.header)
		for _, row in ipairs(section.rows) do
			sbar.remove(row)
		end
	end

	sections = {}
	for _, key in ipairs(provider_order) do
		local section = {
			header = sbar.add("item", "usage." .. key .. ".header", {
				position = "popup.usage",
				icon = { drawing = false },
				label = { string = provider_names[key], font = { style = "Bold" } },
			}),
			rows = {},
		}
		for index = 1, #(limits_by_provider[key] or {}) do
			section.rows[index] = sbar.add("item", ("usage.%s.row.%d"):format(key, index), {
				position = "popup.usage",
				icon = { drawing = false },
			})
		end
		sections[key] = section
	end
end

-- One fetch answers for both providers, so a hidden item owns the timer.
local poller = sbar.add("item", "usage.poller", {
	position = "right",
	drawing = false,
	updates = "on",
	update_freq = IDLE_FREQ,
})

local limits_by_provider = {}
local updated_at_by_provider = {}
local stale_providers = {}

local function load_cache()
	local handle = io.open(CACHE_FILE, "r")
	if not handle then
		return
	end
	local contents = handle:read("a")
	handle:close()
	local ok, cached = pcall(cjson.decode, contents)
	if not ok or type(cached) ~= "table" then
		return
	end

	-- Accept the original provider-only cache once, then rewrite it in the new
	-- envelope after the first successful refresh.
	limits_by_provider = cached.providers or cached
	updated_at_by_provider = cached.updated_at or {}
	for key, limits in pairs(limits_by_provider) do
		stale_providers[key] = true
		for _, limit in ipairs(limits) do
			limit.percent = math.ceil(tonumber(limit.percent) or 0)
			if limit.label == "week" then
				limit.label = "7d"
			end
		end
	end
end

local function save_cache()
	sbar.exec(("mkdir -p %q"):format(CACHE_DIR), function()
		local handle = io.open(CACHE_FILE, "w")
		if not handle then
			return
		end
		handle:write(cjson.encode({
			providers = limits_by_provider,
			updated_at = updated_at_by_provider,
		}))
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
	local worst = 0
	rebuild_sections(limits_by_provider)

	for _, key in ipairs(provider_order) do
		local limits = limits_by_provider[key] or {}
		local section = sections[key]
		local stale = stale_providers[key] or false

		section.header:set({
			label = {
				string = stale and (provider_names[key] .. " · cached") or provider_names[key],
				color = stale and colors.grey70 or colors.white,
			},
		})

		for index, row in ipairs(section.rows) do
			local limit = limits[index]
			if limit then
				worst = math.max(worst, limit.percent)
				row:set({
					drawing = true,
					label = {
						string = ("%-5s · %3d%%"):format(limit.label, limit.percent),
						color = color_for(limit.percent),
					},
				})
			else
				row:set({ drawing = false })
			end
		end
	end

	usage:set({ icon = { color = color_for(worst) } })
	poller:set({ update_freq = worst >= WARN and ALERT_FREQ or IDLE_FREQ })
end

local function mark_all_stale()
	for key in pairs(limits_by_provider) do
		stale_providers[key] = true
	end
	render()
end

local function refresh()
	sbar.exec(AI_USAGE_BIN, function(out)
		local payload = out
		if type(payload) == "string" then
			local ok, decoded = pcall(cjson.decode, payload)
			if not ok then
				mark_all_stale()
				return
			end
			payload = decoded
		end

		if type(payload) ~= "table" or type(payload.providers) ~= "table" then
			mark_all_stale()
			return
		end

		local updated = false
		for _, provider in ipairs(payload.providers) do
			if provider.error then
				stale_providers[provider.key] = true
			else
				local limits = {}
				for _, window in ipairs(provider.windows or {}) do
					limits[#limits + 1] = {
						label = window.label == "week" and "7d" or window.label,
						-- Conservative display: never show less usage than the API returned.
						percent = math.ceil(tonumber(window.percent) or 0),
					}
				end
				limits_by_provider[provider.key] = limits
				updated_at_by_provider[provider.key] = os.time()
				stale_providers[provider.key] = false
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
