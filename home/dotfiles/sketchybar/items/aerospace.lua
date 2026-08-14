local colors = require("colors")
local Aerospace = require("aerospace")

local initialized = false
local bootstrap = sbar.add("item", "workspace.bootstrap", {
	position = "left",
	drawing = false,
	updates = "on",
	update_freq = 1,
})

local function initialize()
	if initialized then
		return
	end

	local aerospace
	local ok, state = pcall(function()
		aerospace = Aerospace.new()
		return {
			focused = aerospace:list_current():match("[^\r\n]+") or "",
			workspaces = aerospace:query_workspaces(),
		}
	end)

	if aerospace then
		aerospace:close()
	end
	if not ok then
		return
	end

	for _, entry in ipairs(state.workspaces) do
		local workspace = entry.workspace

		local item = sbar.add("item", "workspace." .. workspace, {
			position = "left",
			icon = { drawing = false },
			label = {
				string = workspace,
				highlight = workspace == state.focused,
				color = colors.grey,
				highlight_color = colors.white,
			},
			click_script = AEROSPACE_BIN .. " workspace " .. workspace,
		})

		item:subscribe("aerospace_workspace_change", function(env)
			item:set({ label = { highlight = workspace == env.FOCUSED_WORKSPACE } })
		end)
	end

	initialized = true
	bootstrap:set({ update_freq = 0 })
end

bootstrap:subscribe({ "forced", "routine", "system_woke" }, initialize)
initialize()
