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

local UPDATE_FREQ = 120
local MAX_LABELS = 3

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
		click_script = ("open %q"):format(provider.page),
	})

	local function refresh()
		local command = ("curl -sfL --max-time 10 %q"):format(provider.api)

		sbar.exec(command, function(out)
			local ok, summary = pcall(cjson.decode, out or "")
			if not ok or type(summary) ~= "table" or type(summary.components) ~= "table" then
				item:set({ drawing = false })
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

	item:subscribe({ "forced", "routine", "system_woke" }, refresh)
end
