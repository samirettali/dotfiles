local M = {}

local inputBuffer = ""
local promptCanvas = nil
local keyboardHandler = nil
local onSubmit = nil
local onCancel = nil

local function reset()
	if keyboardHandler then
		keyboardHandler:stop()
	end
	if promptCanvas then
		promptCanvas:delete()
	end

	keyboardHandler = nil
	promptCanvas = nil
	onSubmit = nil
	onCancel = nil
	inputBuffer = ""
end

local function closePrompt(finalText)
	local submit = onSubmit
	local cancel = onCancel

	reset()

	if finalText ~= nil then
		if submit then
			submit(finalText)
		end
		return
	end

	if cancel then
		cancel()
	end
end

function M.prompt(opts)
	opts = opts or {}

	if promptCanvas then
		return false
	end

	inputBuffer = opts.initialText or ""
	onSubmit = opts.onSubmit
	onCancel = opts.onCancel

	local style = hs.alert.defaultStyle or {}
	local screen = hs.screen.mainScreen()
	local max = screen:fullFrame()
	local width = opts.width or 600
	local height = opts.height or 100
	local borderRadius = opts.borderRadius or style.radius or 27
	local promptText = opts.prompt or ""
	local fillColor = opts.fillColor or style.fillColor or { black = 1, alpha = 1 }
	local strokeColor = opts.strokeColor or style.strokeColor or { white = 1, alpha = 1 }
	local strokeWidth = opts.strokeWidth or style.strokeWidth or 2
	local textColor = opts.textColor or style.textColor or { white = 1, alpha = 1 }
	local textFont = opts.textFont or style.textFont or "JetBrainsMono Nerd Font"
	local textSize = opts.textSize or style.textSize or 18
	local promptTextColor = opts.promptTextColor or { white = textColor.white or 1, alpha = 0.7 }
	local promptTextSize = opts.promptTextSize or math.max(14, textSize - 4)

	local alertTop = max.y + (max.h * (1 - 1 / 1.55) + 55)

	local geom = {
		x = max.x + (max.w - width) / 2,
		y = opts.y or alertTop,
		w = width,
		h = height,
	}

	promptCanvas = hs.canvas.new(geom)
	promptCanvas:level(hs.canvas.windowLevels.mainMenu)
	promptCanvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)

	promptCanvas[1] = {
		type = "rectangle",
		action = "fill",
		fillColor = fillColor,
		roundedRectRadii = { xRadius = borderRadius, yRadius = borderRadius },
	}

	local inset = strokeWidth / 2

	promptCanvas[2] = {
		type = "rectangle",
		action = "stroke",
		strokeColor = strokeColor,
		strokeWidth = strokeWidth,
		roundedRectRadii = { xRadius = borderRadius, yRadius = borderRadius },
		frame = { x = inset, y = inset, w = width - strokeWidth, h = height - strokeWidth },
	}

	promptCanvas[3] = {
		type = "text",
		text = promptText,
		textColor = promptTextColor,
		textSize = promptTextSize,
		textFont = textFont,
		textAlignment = "center",
		frame = { x = 20, y = 12, w = width - 40, h = 20 },
	}

	promptCanvas[4] = {
		type = "text",
		text = inputBuffer .. "|",
		textColor = textColor,
		textSize = textSize,
		textFont = textFont,
		textAlignment = "center",
		frame = { x = 20, y = 34, w = width - 40, h = height - 48 },
	}

	promptCanvas:show()

	keyboardHandler = hs.eventtap
		.new({ hs.eventtap.event.types.keyDown }, function(event)
			local keyCode = event:getKeyCode()
			local char = event:getCharacters()
			local flags = event:getFlags()

			if keyCode == hs.keycodes.map["return"] then
				closePrompt(inputBuffer)
				return true
			end

			if keyCode == hs.keycodes.map["escape"] then
				closePrompt(nil)
				return true
			end

			if keyCode == hs.keycodes.map["delete"] then
				inputBuffer = inputBuffer:sub(1, -2)
				promptCanvas[4].text = inputBuffer .. "|"
				return true
			end

			if flags.cmd and keyCode == hs.keycodes.map["v"] then
				local pasted = hs.pasteboard.getContents()
				if pasted then
					inputBuffer = inputBuffer .. pasted
					promptCanvas[4].text = inputBuffer .. "|"
				end
				return true
			end

			if char and #char > 0 and not (flags.cmd or flags.ctrl or flags.alt) then
				inputBuffer = inputBuffer .. char
				promptCanvas[4].text = inputBuffer .. "|"
				return true
			end

			return true
		end)
		:start()

	return true
end

return M
