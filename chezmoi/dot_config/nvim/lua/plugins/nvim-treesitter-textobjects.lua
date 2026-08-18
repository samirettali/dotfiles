vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" })

require("nvim-treesitter-textobjects").setup({
	select = {
		lookahead = true,
	},
	move = {
		set_jumps = true,
	},
})

local select = require("nvim-treesitter-textobjects.select")
local swap = require("nvim-treesitter-textobjects.swap")
local move = require("nvim-treesitter-textobjects.move")

-- Selection objects
vim.keymap.set({ "x", "o" }, "aa", function()
	select.select_textobject("@parameter.outer", "textobjects")
end, { desc = "around a parameter" })
vim.keymap.set({ "x", "o" }, "ia", function()
	select.select_textobject("@parameter.inner", "textobjects")
end, { desc = "inside a parameter" })

vim.keymap.set({ "x", "o" }, "af", function()
	select.select_textobject("@function.outer", "textobjects")
end, { desc = "around a function" })
vim.keymap.set({ "x", "o" }, "if", function()
	select.select_textobject("@function.inner", "textobjects")
end, { desc = "inside a function" })

vim.keymap.set({ "x", "o" }, "ac", function()
	select.select_textobject("@class.outer", "textobjects")
end, { desc = "around a class" })
vim.keymap.set({ "x", "o" }, "ic", function()
	select.select_textobject("@class.inner", "textobjects")
end, { desc = "inside a class" })

vim.keymap.set({ "x", "o" }, "aL", function()
	select.select_textobject("@loop.outer", "textobjects")
end, { desc = "around a loop" })
vim.keymap.set({ "x", "o" }, "iL", function()
	select.select_textobject("@loop.inner", "textobjects")
end, { desc = "inside a loop" })

vim.keymap.set({ "x", "o" }, "ai", function()
	select.select_textobject("@conditional.outer", "textobjects")
end, { desc = "around an if statement" })
vim.keymap.set({ "x", "o" }, "ii", function()
	select.select_textobject("@conditional.inner", "textobjects")
end, { desc = "inside an if statement" })

vim.keymap.set({ "x", "o" }, "a=", function()
	select.select_textobject("@assignment.outer", "textobjects")
end, { desc = "around an assignment" })
vim.keymap.set({ "x", "o" }, "i=", function()
	select.select_textobject("@assignment.inner", "textobjects")
end, { desc = "inside an assignment" })

vim.keymap.set({ "x", "o" }, "l=", function()
	select.select_textobject("@assignment.lhs", "textobjects")
end, { desc = "left-hand side of an assignment" })
vim.keymap.set({ "x", "o" }, "r=", function()
	select.select_textobject("@assignment.rhs", "textobjects")
end, { desc = "right-hand side of an assignment" })

-- Movement between objects
vim.keymap.set("n", "[f", function()
	move.goto_previous_start("@function.outer", "textobjects")
end, { desc = "Previous function" })
vim.keymap.set("n", "]f", function()
	move.goto_next_start("@function.outer", "textobjects")
end, { desc = "Next function" })

vim.keymap.set("n", "[F", function()
	move.goto_previous_end("@function.outer", "textobjects")
end, { desc = "Previous function end" })
vim.keymap.set("n", "]F", function()
	move.goto_next_end("@function.outer", "textobjects")
end, { desc = "Next function end" })

-- TODO: this conflicts with diff jump
-- vim.keymap.set("n", "[c", function()
-- 	move.goto_previous_start("@class.outer", "textobjects")
-- end, { desc = "Previous class" })
-- vim.keymap.set("n", "]c", function()
-- 	move.goto_next_start("@class.outer", "textobjects")
-- end, { desc = "Next class" })

vim.keymap.set("n", "[C", function()
	move.goto_previous_end("@class.outer", "textobjects")
end, { desc = "Previous class end" })
vim.keymap.set("n", "]C", function()
	move.goto_next_end("@class.outer", "textobjects")
end, { desc = "Next class end" })

vim.keymap.set("n", "[p", function()
	move.goto_previous_start("@parameter.inner", "textobjects")
end, { desc = "Previous parameter" })
vim.keymap.set("n", "]p", function()
	move.goto_next_start("@parameter.inner", "textobjects")
end, { desc = "Next parameter" })

-- Swap objects
vim.keymap.set("n", "g>", function()
	swap.swap_next("@parameter.inner")
end, { desc = "Swap parameter with next" })
vim.keymap.set("n", "g<", function()
	swap.swap_previous("@parameter.inner")
end, { desc = "Swap parameter with previous" })

