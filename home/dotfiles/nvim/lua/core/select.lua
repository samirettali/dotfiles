local function custom_select(items, opts, on_choice)
	if not items or #items == 0 then
		return
	end

	opts = opts or {}

	-- Create buffer for the menu
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "select_menu"

	-- Format items and create lines
	local lines = {}
	local formatted_items = {}

	for i, item in ipairs(items) do
		local text = item
		if opts.format_item then
			text = opts.format_item(item)
		end

		-- Add number prefix for selection
		local line = string.format("%d. %s", i, text)
		table.insert(lines, line)
		table.insert(formatted_items, { text = text, original = item, index = i })
	end

	-- Set buffer content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	-- Calculate window position and size
	local win = vim.api.nvim_get_current_win()
	local screenrow = vim.fn.screenpos(win, vim.fn.line("."), 0).row
	local screenrows_left = vim.go.lines - screenrow

	-- Determine window placement (above or below cursor)
	local win_configs = {
		relative = "cursor",
		col = 0,
		width = math.max(20, math.min(60, vim.fn.max(vim.tbl_map(vim.fn.strdisplaywidth, lines)) + 2)),
		height = math.min(#lines, 10),
		style = "minimal",
		border = vim.api.nvim_get_option_value("winborder"),
		title = opts.prompt or "Select item",
		title_pos = "center",
	}

	if screenrow > screenrows_left then
		win_configs.row = 0
		win_configs.anchor = "SW"
	else
		win_configs.row = 1
		win_configs.anchor = "NW"
	end

	-- Open window
	local menu_win = vim.api.nvim_open_win(buf, true, win_configs)
	vim.wo[menu_win].cursorline = true

	-- Set up keymaps
	local closed = false

	local function close_and_select(index)
		if closed then
			return
		end
		closed = true
		if vim.api.nvim_win_is_valid(menu_win) then
			vim.api.nvim_win_close(menu_win, true)
		end
		if on_choice and index and formatted_items[index] then
			on_choice(formatted_items[index].original, index)
		end
	end

	local function close_without_select()
		if closed then
			return
		end
		closed = true
		if vim.api.nvim_win_is_valid(menu_win) then
			vim.api.nvim_win_close(menu_win, true)
		end
		if on_choice then
			on_choice(nil, nil)
		end
	end

	-- Number key mappings (1-9)
	for i = 1, math.min(9, #items) do
		vim.keymap.set("n", tostring(i), function()
			close_and_select(i)
		end, { buffer = buf, nowait = true })
	end

	-- Navigation and selection
	vim.keymap.set("n", "<CR>", function()
		local cursor = vim.api.nvim_win_get_cursor(menu_win)
		close_and_select(cursor[1])
	end, { buffer = buf, nowait = true })

	vim.keymap.set("n", "<Esc>", close_without_select, { buffer = buf, nowait = true })
	vim.keymap.set("n", "q", close_without_select, { buffer = buf, nowait = true })

	-- Mouse support
	vim.keymap.set("n", "<LeftMouse>", function()
		local mouse = vim.fn.getmousepos()
		if mouse.winid == menu_win and mouse.line > 0 and mouse.line <= #items then
			close_and_select(mouse.line)
		end
	end, { buffer = buf, nowait = true })

	-- Auto-close when leaving buffer
	vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
		buffer = buf,
		once = true,
		callback = function()
			if vim.api.nvim_win_is_valid(menu_win) then
				vim.schedule(close_without_select)
			end
		end,
	})

	-- Set cursor to first item
	vim.api.nvim_win_set_cursor(menu_win, { 1, 0 })
end

vim.ui.select = custom_select
