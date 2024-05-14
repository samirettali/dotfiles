return {
    "nvimtools/none-ls.nvim",
    config = function()
        local null = require("null-ls")
        null.setup({
            sources = {
                null.builtins.diagnostics.revive
            }
        })
    end,
}
