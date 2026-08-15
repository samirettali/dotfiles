local M = {}

function M.take()
	local focus = {
		window = hs.window.focusedWindow(),
		application = hs.application.frontmostApplication(),
	}

	local finder = hs.application.get("com.apple.finder")

	if finder then
		finder:activate()
	else
		hs.focus()
	end

	return focus
end

function M.restore(focus)
	if not focus then
		return
	end

	if focus.window then
		focus.window:focus()
	elseif focus.application then
		focus.application:activate()
	end
end

return M
