return {
	"nanozuki/tabby.nvim",
	event = "BufWinEnter",
	opts = {
		line = function(line)
			local theme = {
				fill = "TabLineFill",
				head = "TabLine",
				current_tab = "TabLineSel",
				tab = "TabLine",
				win = "TabLine",
				tail = "TabLine",
			}

			-- vim.opt.sessionoptions = 'curdir,folds,globals,help,tabpages,terminal,winsize'

			return {
				{ "  ", hl = theme.head },
				line.sep("", theme.head, theme.fill),
				line.tabs().foreach(function(tab)
					local hl = not tab.in_jump_mode() and tab.is_current() and theme.current_tab or theme.tab

					local name = tab.name()
					-- TODO: this should be done in a better way
					name = name:gsub("%[", " [")

					if tab.in_jump_mode() then
						local jump_key = tab.jump_key()
						for i = 1, #name do
							local char = name:sub(i, i):upper()
							-- lower

							if char == jump_key then
								local char_hl = vim.api.nvim_get_hl(0, { name = hl })
								char_hl.fg = palette.red
								name = {
									{
										name:sub(1, i - 1),
									},
									{
										jump_key,
										hl = char_hl,
									},
									{ name:sub(i + 1) },
								}
								break
							end
						end
					end

					-- local x = line.sep("", hl, theme.fill)
					-- vim.notify(vim.inspect(x))

					return {
						line.sep("", hl, theme.fill),
						name,
						-- tab.number(),
						-- tab.in_jump_mode() and tab.jump_key() .. " " .. tab.name() or tab.name(),
						-- tab.in_jump_mode() and tab.jump_key() or tab.number(),
						line.sep("", hl, theme.fill),
						hl = hl,
						margin = " ",
					}
				end),
				line.spacer(),
				line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
					return {
						line.sep("", theme.win, theme.fill),
						win.is_current() and "" or "",
						win.buf_name(),
						line.sep("", theme.win, theme.fill),
						hl = theme.win,
						margin = " ",
					}
				end),
				line.sep("", theme.tail, theme.fill),
				{ "  ", hl = theme.tail },
				hl = theme.fill,
			}
		end,
	},
	keys = {
		{
			"tj",
			"<cmd>Tabby jump_to_tab<cr>",
			desc = "Jump to tab",
		},
	},
}
