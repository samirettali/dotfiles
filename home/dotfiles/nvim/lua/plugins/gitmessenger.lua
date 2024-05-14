return {
    "rhysd/git-messenger.vim",
    config = function()
        vim.g.git_messenger_include_diff = "current"
        vim.keymap.set("n", "<Leader>gm", "<Plug>(git-messenger)", { silent = true })
    end
}
