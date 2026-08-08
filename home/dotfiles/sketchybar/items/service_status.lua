local cjson = require("cjson")
local colors = require("colors")
local icons = require("icons")

-- Statuspage (Atlassian) pages, one item per provider. The item is hidden while
-- every watched component is operational, so it only ever shows up as an alert.
-- Components are listed explicitly: a GitHub Pages outage is not interesting.
local providers = {
	{
		key = "github",
		icon = icons.status.github,
		api = "https://www.githubstatus.com/api/v2/summary.json",
		page = "https://www.githubstatus.com",
		components = {
			{ "Actions", "Actions" },
			{ "Git Operations", "Git" },
			{ "API Requests", "API" },
			{ "Pull Requests", "PRs" },
			{ "Issues", "Issues" },
			{ "Packages", "Packages" },
		},
	},
	{
		key = "claude",
		icon = icons.status.claude,
		-- status.anthropic.com 302s here; hitting it directly avoids the redirect.
		api = "https://status.claude.com/api/v2/summary.json",
		page = "https://status.claude.com",
		components = {
			{ "Claude API (api.anthropic.com)", "API" },
			{ "Claude Code", "Code" },
			{ "claude.ai", "claude.ai" },
			{ "Claude Console (platform.claude.com)", "Console" },
		},
	},
}

local severity = {
	degraded_performance = 1,
	partial_outage = 2,
	major_outage = 3,
}

local severity_color = {
	[1] = colors.yellow,
	[2] = colors.orange,
	[3] = colors.red,
}

local UPDATE_FREQ = 15
local MAX_LABELS = 3
local CACHE_DIR = (os.getenv("HOME") or "") .. "/.cache/sketchybar"

for _, provider in ipairs(providers) do
	local watched = {}
	for _, entry in ipairs(provider.components) do
		watched[entry[1]] = entry[2]
	end

	local item = sbar.add("item", "status." .. provider.key, {
		position = "right",
		drawing = false,
		-- Not "when_shown": the item spends most of its life hidden and would
		-- otherwise stop polling and never come back.
		updates = "on",
		update_freq = UPDATE_FREQ,
		icon = { string = provider.icon },
		label = { font = { style = "Bold" } },
		click_script = ("open %q"):format(provider.page),
	})

	-- Conditional GET: curl sends If-None-Match from the file and rewrites it on
	-- a 200. A 304 comes back with an empty body, which we read as "unchanged".
	local etag_file = ("%s/status-%s.etag"):format(CACHE_DIR, provider.key)

	local conditional = ("mkdir -p %q && curl -sfL --max-time 10 --etag-compare %q --etag-save %q %q")
		:format(CACHE_DIR, etag_file, etag_file, provider.api)

	-- The etag file outlives the process while the item state does not, so the
	-- first fetch has to be unconditional or a restart during an outage would
	-- get a 304 and leave the item hidden.
	local unconditional = ("mkdir -p %q && curl -sfL --max-time 10 --etag-save %q %q")
		:format(CACHE_DIR, etag_file, provider.api)

	local function refresh(force)
		sbar.exec(force and unconditional or conditional, function(out)
			-- SbarLua decodes JSON stdout into a table before invoking the
			-- callback; anything else (an empty 304 body, a failed request)
			-- arrives as a string and leaves the current state alone.
			local summary = out
			if type(summary) == "string" then
				local ok, decoded = pcall(cjson.decode, summary)
				if not ok then
					return
				end
				summary = decoded
			end

			if type(summary) ~= "table" or type(summary.components) ~= "table" then
				return
			end

			local worst = 0
			local affected = {}

			for _, component in ipairs(summary.components) do
				local short = watched[component.name]
				local level = short and severity[component.status] or nil
				if level then
					worst = math.max(worst, level)
					affected[#affected + 1] = { order = #affected, label = short, level = level }
				end
			end

			if worst == 0 then
				item:set({ drawing = false })
				return
			end

			table.sort(affected, function(a, b)
				if a.level ~= b.level then
					return a.level > b.level
				end
				return a.order < b.order
			end)

			local shown = {}
			for i = 1, math.min(#affected, MAX_LABELS) do
				shown[i] = affected[i].label
			end

			local label = table.concat(shown, ", ")
			if #affected > MAX_LABELS then
				label = ("%s +%d"):format(label, #affected - MAX_LABELS)
			end

			local color = severity_color[worst]

			item:set({
				drawing = true,
				icon = { color = color },
				label = { string = label, color = color },
			})
		end)
	end

	-- Wrapped: the event handler is called with an env table, which would
	-- otherwise be read as the `force` argument.
	item:subscribe({ "forced", "routine", "system_woke" }, function()
		refresh()
	end)

	-- "routine" only fires after the first update_freq window, so resolve the
	-- initial state at startup.
	refresh(true)
end
