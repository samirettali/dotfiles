return {
    "folke/trouble.nvim",
    config = function()
        local trouble = require("trouble")

        trouble.setup()

        vim.keymap.set("n", "<leader>td", function() trouble.toggle("diagnostics") end)
    end,
}
