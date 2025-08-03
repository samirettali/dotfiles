local M = {}

local function nav(short_direction, direction, action)
	local cur_winnr = vim.fn.winnr()
	vim.api.nvim_command("wincmd " .. short_direction)

	local new_winnr = vim.fn.winnr()

	-- if the window ID didn't change, then we didn't switch
	if cur_winnr == new_winnr then
		-- os.execute has much less latency than vim.fn.system
		os.execute("zellij action " .. action .. " " .. direction)
	end
end

function M.up()
	nav("k", "up", "move-focus")
end

function M.down()
	nav("j", "down", "move-focus")
end

function M.right()
	nav("l", "right", "move-focus")
end

function M.left()
	nav("h", "left", "move-focus")
end

function M.up_tab()
	nav("k", "up", "move-focus-or-tab")
end

function M.down_tab()
	nav("j", "down", "move-focus-or-tab")
end

function M.right_tab()
	nav("l", "right", "move-focus-or-tab")
end

function M.left_tab()
	nav("h", "left", "move-focus-or-tab")
end

return M
