return {
    {
        "m4xshen/smartcolumn.nvim",
        config = function()
            require("smartcolumn").setup {
                colorcolumn = "120",
                disabled_filetypes = { "help", "text", "markdown" },
                custom_colorcolumn = {},
                scope = "file",
            }
        end
    }
}
