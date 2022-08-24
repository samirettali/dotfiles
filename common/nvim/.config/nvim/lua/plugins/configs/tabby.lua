local present, tabby = pcall(require, "tabby")

if not present then
    return false
end

local config = {
    tabline = require("tabby.presets").active_wins_at_tail,
}

tabby.setup(config)

local map = require("core.utils").map

map("n", "<C-n>", ":bn<CR>")
map("n", "<C-p>", ":bp<CR>")
map("n", "<Leader>tn", ":tabn<CR>")
map("n", "<Leader>tp", ":tabp<CR>")
