return {
    "sindrets/diffview.nvim", -- Improve diff view
    "rhysd/committia.vim",    -- Better commit editing
    {
        -- Git signs integration
        "lewis6991/gitsigns.nvim",
        config = true,
    },
    {
        "rhysd/git-messenger.vim",
        config = function()
            vim.g.git_messenger_include_diff = "current"
            vim.keymap.set("n", "<Leader>gm", "<Plug>(git-messenger)", { silent = true })
        end
    },
}
