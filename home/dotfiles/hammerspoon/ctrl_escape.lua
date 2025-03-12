local ctrlKeyPressed = false
local sendEscapeOnRelease = false
local ctrlTimer = nil
local ctrlThreshold = 0.15 -- seconds (adjust if necessary)

local eventHandler = hs.eventtap.new(
  {hs.eventtap.event.types.flagsChanged, hs.eventtap.event.types.keyDown},
  function(e)
    local eventType = e:getType()

    if eventType == hs.eventtap.event.types.flagsChanged then
      local flags = e:getFlags()

      -- When the Control key is pressed:
      if flags.ctrl and not ctrlKeyPressed then
        ctrlKeyPressed = true
        sendEscapeOnRelease = true
        ctrlTimer = hs.timer.doAfter(ctrlThreshold, function()
          -- Timer expired: do not send Escape on release.
          sendEscapeOnRelease = false
        end)

      -- When the Control key is released:
      elseif not flags.ctrl and ctrlKeyPressed then
        if sendEscapeOnRelease then
          hs.eventtap.keyStroke({}, "escape", 0)
        end
        ctrlKeyPressed = false
        sendEscapeOnRelease = false
        if ctrlTimer then
          ctrlTimer:stop()
          ctrlTimer = nil
        end
      end

    -- On any non-Control key press while Control is held, cancel
    elseif eventType == hs.eventtap.event.types.keyDown then
      if ctrlKeyPressed then
        sendEscapeOnRelease = false
      end
    end

    return false
  end
)

eventHandler:start()