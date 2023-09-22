return {
    "numToStr/Comment.nvim",
    config = function()
        require("Comment").setup()
        vim.keymap.set('n', '<Leader>k', 'gcip', {
            remap = true,
            desc = "Toggle paragraph comments"
        })
    end
}
