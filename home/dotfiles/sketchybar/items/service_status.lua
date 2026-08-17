local cjson = require("cjson")
local colors = require("colors")
local icons = require("icons")

-- Statuspage (Atlassian) pages, one item per provider. Each item stays hidden
-- while every watched component is operational and becomes an icon-only alert.
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
local CACHE_DIR = (os.getenv("HOME") or "") .. "/.cache/sketchybar"

for _, provider in ipairs(providers) do
	local watched = {}
	for _, entry in ipairs(provider.components) do
		watched[entry[1]] = entry[2]
	end

	local item = sbar.add("item", "status." .. provider.key, {
		position = "right",
		drawing = false,
		updates = "on",
		update_freq = UPDATE_FREQ,
		icon = { string = provider.icon },
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
	for index = 1, #provider.components do
		rows[index] = sbar.add("item", ("status.%s.row.%d"):format(provider.key, index), {
			position = "popup.status." .. provider.key,
			drawing = false,
			icon = { drawing = false },
			click_script = ("open %q"):format(provider.page),
		})
	end

	local etag_file = ("%s/status-%s.etag"):format(CACHE_DIR, provider.key)
	local conditional = ("mkdir -p %q && curl -sfL --max-time 10 --etag-compare %q --etag-save %q %q"):format(
		CACHE_DIR,
		etag_file,
		etag_file,
		provider.api
	)
	local unconditional = ("mkdir -p %q && curl -sfL --max-time 10 --etag-save %q %q"):format(
		CACHE_DIR,
		etag_file,
		provider.api
	)

	local function close_popup()
		item:set({ popup = { drawing = false } })
	end

	local function set_rows(affected)
		for index, row in ipairs(rows) do
			local component = affected[index]
			if component then
				local color = severity_color[component.level]
				row:set({
					drawing = true,
					label = { string = component.label, color = color },
				})
			else
				row:set({ drawing = false })
			end
		end
	end

	local function refresh(force)
		sbar.exec(force and unconditional or conditional, function(out)
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
					affected[#affected + 1] = {
						order = #affected,
						label = short,
						level = level,
					}
				end
			end

			if worst == 0 then
				set_rows({})
				item:set({ drawing = false, popup = { drawing = false } })
				return
			end

			table.sort(affected, function(a, b)
				if a.level ~= b.level then
					return a.level > b.level
				end
				return a.order < b.order
			end)

			set_rows(affected)
			item:set({
				drawing = true,
				icon = { color = severity_color[worst] },
			})
		end)
	end

	item:subscribe({ "forced", "routine", "system_woke" }, function()
		refresh()
	end)

	item:subscribe("mouse.clicked", function()
		local current = item:query()
		local open = current and current.popup and current.popup.drawing == "on"
		item:set({ popup = { drawing = not open } })
	end)

	item:subscribe("mouse.exited.global", close_popup)

	refresh(true)
end
