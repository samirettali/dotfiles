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
local BAR_WIDTH = 90

-- One poller per credential source; a source may expose several providers,
-- because Claude reports model-scoped caps alongside the plan-wide ones.
local POLL_ORDER = { "claude", "codex" }
local provider_order = { "claude", "codex" }
local provider_names = { claude = "Claude", codex = "Codex" }

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

local limits_by_provider = {}
local updated_at_by_provider = {}
local stale_providers = {}
local provider_urls = {}
local keys_by_owner = { claude = { "claude" }, codex = { "codex" } }
local popup_items = {}
local view = {}
local view_signature

local function add_popup(kind, name, ...)
	local item = sbar.add(kind, name, ...)
	popup_items[#popup_items + 1] = item
	return item
end

-- Every row of a provider opens that provider's own usage page.
local function open_provider(key)
	local url = provider_urls[key]
	if not url then
		return
	end
	usage:set({ popup = { drawing = false } })
	sbar.exec(("open %q"):format(url))
end

local function add_provider_header(key)
	return add_popup("item", "usage." .. key .. ".header", {
		position = "popup.usage",
		icon = {
			string = provider_names[key],
			color = colors.white,
			font = { family = "JetBrainsMonoNL Nerd Font", style = "Bold" },
			padding_right = 2,
		},
		label = {
			drawing = false,
			string = "(cached)",
			color = colors.grey70,
			padding_left = 2,
		},
	})
end

local function signature()
	local parts = {}
	for _, key in ipairs(provider_order) do
		parts[#parts + 1] = ("%s=%d"):format(key, #(limits_by_provider[key] or {}))
	end
	return table.concat(parts, ":")
end

-- Order the sections by poller, then by the order each poller returned them.
local function reorder_providers()
	local order = {}
	for _, poller_key in ipairs(POLL_ORDER) do
		for _, key in ipairs(keys_by_owner[poller_key] or {}) do
			order[#order + 1] = key
		end
	end
	provider_order = order
end

local function rebuild_view()
	local next_signature = signature()
	if view_signature == next_signature then
		return
	end

	for _, item in ipairs(popup_items) do
		sbar.remove(item)
	end
	popup_items = {}
	view = {}

	view.sections = {}
	for _, key in ipairs(provider_order) do
		local section = { header = add_provider_header(key), rows = {} }
		section.header:subscribe("mouse.clicked", function()
			open_provider(key)
		end)
		for index = 1, #(limits_by_provider[key] or {}) do
			local row = add_popup("slider", ("usage.%s.%d"):format(key, index), BAR_WIDTH, {
				position = "popup.usage",
				icon = {
					font = { family = "JetBrainsMonoNL Nerd Font" },
					color = colors.grey70,
					width = 142,
					align = "left",
				},
				label = { align = "right", width = 44, padding_left = 6 },
				slider = {
					highlight_color = colors.white,
					background = {
						color = colors.grey23,
						height = 10,
						corner_radius = 2,
					},
					knob = { drawing = false },
				},
			})
			row:subscribe("mouse.clicked", function()
				open_provider(key)
			end)
			section.rows[index] = row
		end
		view.sections[key] = section
	end

	view_signature = next_signature
end

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

	limits_by_provider = cached.providers or cached
	updated_at_by_provider = cached.updated_at or {}
	if type(cached.names) == "table" then
		provider_names = cached.names
	end
	if type(cached.urls) == "table" then
		provider_urls = cached.urls
	end
	if type(cached.owners) == "table" then
		keys_by_owner = cached.owners
		reorder_providers()
	end
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
			names = provider_names,
			urls = provider_urls,
			owners = keys_by_owner,
		}))
		handle:close()
	end)
end

-- A window at 0% says nothing on its own; the reset instant says when it moves.
local function window_text(limit)
	local at = tonumber(limit.resets_at)
	if not at or at <= os.time() then
		return limit.label
	end
	-- Monospace plus a fixed field: the reset times stack in one column, whether
	-- they carry a weekday or not.
	local format = at - os.time() < 20 * 3600 and "%H:%M" or "%a %H:%M"
	return ("%-2s %11s"):format(limit.label, os.date(format, at))
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

local pollers = {}
for _, key in ipairs(POLL_ORDER) do
	pollers[key] = sbar.add("item", "usage.poller." .. key, {
		position = "right",
		drawing = false,
		updates = "on",
		update_freq = IDLE_FREQ,
	})
end

local function render()
	local worst = 0
	rebuild_view()

	for _, key in ipairs(provider_order) do
		local limits = limits_by_provider[key] or {}
		local section = view.sections[key]
		section.header:set({ label = { drawing = stale_providers[key] or false } })

		for index, row in ipairs(section.rows) do
			local limit = limits[index]
			worst = math.max(worst, limit.percent)
			row:set({
				icon = { string = window_text(limit) },
				slider = {
					percentage = limit.percent,
					highlight_color = color_for(limit.percent),
				},
				label = {
					string = ("%d%%"):format(limit.percent),
					color = color_for(limit.percent),
				},
			})
		end
	end

	-- One endpoint serves every provider a poller owns, so the poller follows
	-- the worst of them.
	for _, poller_key in ipairs(POLL_ORDER) do
		local poller_worst = 0
		for _, key in ipairs(keys_by_owner[poller_key] or {}) do
			for _, limit in ipairs(limits_by_provider[key] or {}) do
				poller_worst = math.max(poller_worst, limit.percent)
			end
		end
		pollers[poller_key]:set({ update_freq = poller_worst >= WARN and ALERT_FREQ or IDLE_FREQ })
	end

	usage:set({ icon = { color = color_for(worst) } })
end

-- A failed fetch leaves every provider of that poller cached, never emptied.
local function mark_stale(poller_key)
	for _, key in ipairs(keys_by_owner[poller_key] or {}) do
		if limits_by_provider[key] then
			stale_providers[key] = true
		end
	end
	render()
end

local function refresh(poller_key)
	sbar.exec(("%s %s"):format(AI_USAGE_BIN, poller_key), function(out)
		local payload = out
		if type(payload) == "string" then
			local ok, decoded = pcall(cjson.decode, payload)
			if not ok then
				mark_stale(poller_key)
				return
			end
			payload = decoded
		end

		if type(payload) ~= "table" or type(payload.providers) ~= "table" then
			mark_stale(poller_key)
			return
		end

		local updated = false
		local returned_keys = {}
		for _, provider in ipairs(payload.providers) do
			returned_keys[#returned_keys + 1] = provider.key
			provider_names[provider.key] = provider.name or provider.key
			provider_urls[provider.key] = provider.url
			if provider.error then
				stale_providers[provider.key] = true
			else
				local limits = {}
				for _, window in ipairs(provider.windows or {}) do
					limits[#limits + 1] = {
						label = window.label == "week" and "7d" or window.label,
						percent = math.ceil(tonumber(window.percent) or 0),
						resets_at = window.resets_at,
					}
				end
				limits_by_provider[provider.key] = limits
				updated_at_by_provider[provider.key] = os.time()
				stale_providers[provider.key] = false
				updated = true
			end
		end

		if updated then
			-- Only a successful fetch redefines the poller's providers, so a
			-- failure keeps the cached sections in place.
			for _, key in ipairs(keys_by_owner[poller_key] or {}) do
				local still_returned = false
				for _, returned in ipairs(returned_keys) do
					still_returned = still_returned or returned == key
				end
				if not still_returned then
					limits_by_provider[key] = nil
					updated_at_by_provider[key] = nil
					stale_providers[key] = nil
					provider_names[key] = nil
				end
			end
			keys_by_owner[poller_key] = returned_keys
			reorder_providers()
			save_cache()
		end
		render()
	end)
end

for _, key in ipairs(POLL_ORDER) do
	pollers[key]:subscribe({ "forced", "routine", "system_woke" }, function()
		refresh(key)
	end)
end

popup.setup(usage, function()
	for _, key in ipairs(POLL_ORDER) do
		refresh(key)
	end
end)

load_cache()
render()
for _, key in ipairs(POLL_ORDER) do
	refresh(key)
end
