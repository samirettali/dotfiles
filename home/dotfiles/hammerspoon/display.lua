-- TODO: this configuration is a bit hardcoded
local M = {
	mirror = nil,
}

M.getScreens = function()
	local allScreens = hs.screen.allScreens()
	local internal = hs.screen.find("Built%-in")

	if M.mirror then
		-- add it to allScreens if not present
		found = false
		for _, screen in pairs(allScreens) do
			if screen:getUUID() == M.mirror:getUUID() then
				found = true
			end
		end

		if not found then
			table.insert(allScreens, M.mirror)
		end

		-- TODO: this assumes that the mirror screen is always the internal one
		internal = M.mirror
	end

	local external

	if #allScreens == 2 then
		for _, screen in pairs(allScreens) do
			if screen:getUUID() ~= internal:getUUID() then
				external = screen
			end
		end
	elseif #allScreens == 1 then
		-- If only one screen is connected, assume it's the external one
		-- for the 'externalOnly' case, or the internal if it's the only one.
		if allScreens[1]:getUUID() == internal:getUUID() then
			internal = allScreens[1]
		else
			external = allScreens[1]
		end
	end

	if M.mirror then
		internal:mirrorStop(true)
		M.mirror = nil
		hs.brightness.set(100)
	end

	return internal, external
end

-- --- Layout Functions ---

-- Layout 1: Docked
-- Positions the laptop screen below the external monitor.
M.docked = function()
	local internal, external = M.getScreens()

	if not internal or not external then
		hs.alert.show("Two monitors not detected for docked layout.")
		return
	end

	-- Set the external monitor as the primary screen at (0,0)
	external:setOrigin(0, 0)
	-- Position the internal monitor below the external one
	internal:setOrigin((external:currentMode().w / 2) - (internal:currentMode().w / 2), external:currentMode().h)
end

M.side_by_side = function()
	local internal, external = M.getScreens()

	if not internal or not external then
		hs.alert.show("Two monitors not detected for side-by-side layout.")
		return
	end

	external:setOrigin(0, 0)
	internal:setOrigin(-external:currentMode().w, external:currentMode().h - internal:currentMode().h)
end

-- TODO: when this configuration is used, if hammerspoon restarts then the script configuration is broken
M.external = function()
	local internal, external = M.getScreens()

	external:setOrigin(0, 0)
	external:setPrimary()
	if internal then
		M.mirror = internal
		hs.brightness.set(0)
		internal:mirrorOf(external)
	end
end

return M
