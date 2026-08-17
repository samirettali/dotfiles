local colors = require("colors")
local Aerospace = require("aerospace")

local initialized = false
local items = {}
local bootstrap = sbar.add("item", "workspace.bootstrap", {
	position = "left",
	drawing = false,
	updates = "on",
	update_freq = 1,
})

local function query(include_workspaces, focused)
	local aerospace
	local ok, state = pcall(function()
		aerospace = Aerospace.new()
		return {
			focused = focused or aerospace:list_current():match("[^\r\n]+") or "",
			windows = aerospace:list_all_windows(),
			workspaces = include_workspaces and aerospace:query_workspaces() or nil,
		}
	end)

	if aerospace then
		aerospace:close()
	end

	return ok and state or nil
end

local function refresh(focused)
	local state = query(false, focused)
	if not state then
		return
	end

	local occupied = {}
	for _, window in ipairs(state.windows) do
		occupied[window.workspace] = true
	end

	for workspace, item in pairs(items) do
		local is_focused = workspace == state.focused
		item:set({
			drawing = is_focused or occupied[workspace] or false,
			label = { highlight = is_focused },
		})
	end
end

local function initialize()
	if initialized then
		return
	end

	local state = query(true)
	if not state then
		return
	end

	local occupied = {}
	for _, window in ipairs(state.windows) do
		occupied[window.workspace] = true
	end

	local item_names = {}
	for _, entry in ipairs(state.workspaces) do
		local workspace = entry.workspace
		local item_name = "workspace." .. workspace
		local is_focused = workspace == state.focused

		table.insert(item_names, item_name)
		items[workspace] = sbar.add("item", item_name, {
			position = "left",
			drawing = is_focused or occupied[workspace] or false,
			icon = { drawing = false },
			label = {
				string = workspace,
				highlight = is_focused,
				color = colors.grey,
				highlight_color = colors.white,
				-- Paddings are trimmed per item so every ink gap on the bar is 14.
				padding_left = 3,
				padding_right = 3,
			},
			click_script = AEROSPACE_BIN .. " workspace " .. workspace,
		})
	end

	local moves = {}
	for _, item_name in ipairs(item_names) do
		table.insert(moves, "--move " .. item_name .. " before front_app")
	end
	sbar.exec(SKETCHYBAR_BIN .. " " .. table.concat(moves, " "))

	initialized = true
	bootstrap:set({ update_freq = 0 })
end

bootstrap:subscribe({ "forced", "routine" }, initialize)
bootstrap:subscribe("aerospace_workspace_change", function(env)
	if initialized then
		refresh(env.FOCUSED_WORKSPACE)
	else
		initialize()
	end
end)
bootstrap:subscribe({ "front_app_switched", "space_windows_change", "system_woke" }, function()
	if initialized then
		refresh()
	else
		initialize()
	end
end)

initialize()
