local keyboardToggleShortcut = { "cmd", "alt", "shift", "ctrl" }

local function toggleKeyboard()
	if isKeyboardDisabled then
		-- stop blocking keyboard events
		if keyboardTap then
			keyboardTap:stop()
		end

		hs.alert.show("Keyboard enabled")
	else
		keyboardTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
			local flags = event:getFlags()

			-- allow the toggle shortcut to pass through
			if flags:containExactly(keyboardToggleShortcut) and event:getKeyCode() == hs.keycodes.map["K"] then
				return false
			end

			-- block all other key events
			return true
		end)

		keyboardTap:start()
		hs.alert.show("Keyboard disabled")
	end
	isKeyboardDisabled = not isKeyboardDisabled
end

hs.hotkey.bind(keyboardToggleShortcut, "K", toggleKeyboard)
