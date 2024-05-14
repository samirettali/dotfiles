return {
    "folke/trouble.nvim",
    config = function()
        local trouble = require("trouble")
        trouble.setup()
        vim.keymap.set("n", "<leader>tt", function() trouble.toggle() end)
    end,
}
