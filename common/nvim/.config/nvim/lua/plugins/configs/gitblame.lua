local present, _ = pcall(require, "gitblame")

if not present then
    print("uuuuuu")
    return false
end

local map = require("core.utils").map

map("n", "<Leader>gb", ":GitBlameToggle<CR>")
