local aerospace = sbar.aerospace

aerospace:list_current(function(focused_workspace_output)
	local focused_workspace = focused_workspace_output:match("[^\r\n]+") or ""

	aerospace:query_workspaces(function(workspaces_and_monitors)
		for _, entry in ipairs(workspaces_and_monitors) do
			local item = sbar.add("item", {
				position = "left",
				icon = {
					drawing = false,
				},
				label = {
					string = entry.workspace,
					highlight = entry.workspace == focused_workspace,
					color = 0xff444444,
					highlight_color = 0xffffffff,
				},
				click_script = "/etc/profiles/per-user/s.ettali/bin/aerospace workspace " .. entry.workspace,
				drawing = true,
			})

			item:subscribe("aerospace_workspace_change", function(env)
				local update = {
					label = {
						highlight = entry.workspace == env.FOCUSED_WORKSPACE,
					},
				}
				item:set(update)
			end)
		end
	end)
end)

-- space_window_observer:subscribe({ "front_app_switched" }, updateAllWorkspaces())
