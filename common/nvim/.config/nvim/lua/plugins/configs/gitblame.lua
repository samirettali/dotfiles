vim.g.gitblame_date_format = '%c'

local present, gitblame = pcall(require, "gitblame")

if not present then
    return
end

gitblame.init()
