return {
    "numToStr/Comment.nvim",
    config = function()
        require("Comment").setup()
        vim.keymap.set('n', '<Leader>c', 'gcip', {
            remap = true,
            desc = "Toggle paragraph comments"
        })
    end
}
