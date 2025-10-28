local rift = sbar.rift

if not rift then
	return
end

-- Query all workspaces and create items
rift:query_workspaces(function(workspaces)
	for _, ws in ipairs(workspaces) do
		local item = sbar.add("item", {
			position = "left",
			icon = {
				drawing = false,
			},
			label = {
				string = ws.name,
				highlight = ws.is_active,
				color = 0xff444444,
				highlight_color = 0xffffffff,
			},
			click_script = string.format(
				"/Users/s.ettali/proj/rift/target/release/rift-cli execute workspace switch %d",
				ws.index
			),
			drawing = true,
		})

		-- Subscribe to workspace change events
		item:subscribe("rift_workspace_changed", function(env)
			local current_focused_name = env.RIFT_WORKSPACE_NAME or env.FOCUSED_WORKSPACE
			local update = {
				label = {
					highlight = ws.name == current_focused_name,
				},
			}
			item:set(update)
		end)
	end
end)
