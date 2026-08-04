local colors = require("colors")
local Aerospace = require("aerospace")

local ok, aerospace = pcall(Aerospace.new)
if not ok then
	return
end

local focused = aerospace:list_current():match("[^\r\n]+") or ""

for _, entry in ipairs(aerospace:query_workspaces()) do
	local workspace = entry.workspace

	local item = sbar.add("item", "workspace." .. workspace, {
		position = "left",
		icon = { drawing = false },
		label = {
			string = workspace,
			highlight = workspace == focused,
			color = colors.grey,
			highlight_color = colors.white,
		},
		click_script = AEROSPACE_BIN .. " workspace " .. workspace,
	})

	item:subscribe("aerospace_workspace_change", function(env)
		item:set({ label = { highlight = workspace == env.FOCUSED_WORKSPACE } })
	end)
end

aerospace:close()
