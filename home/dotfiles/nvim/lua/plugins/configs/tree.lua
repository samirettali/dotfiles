return {
    "nvim-tree/nvim-tree.lua",
    opts = {
        renderer = {
            icons = {
                show = {
                    git = false,
                },
            },
        },
        update_focused_file = {
            enable = true,
        },
    },
    keys = {
        { "n", "<C-t>", ":NvimTreeToggle<CR>", { silent = true } },
    },
}
