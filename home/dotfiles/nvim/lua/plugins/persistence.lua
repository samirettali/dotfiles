return {
    "folke/persistence.nvim",     -- Session manager
    opts = {},
    event = "BufReadPre",
    keys = {
        { "<leader>s", [[<cmd>lua require("persistence").load()<cr>]] },
    }
}
