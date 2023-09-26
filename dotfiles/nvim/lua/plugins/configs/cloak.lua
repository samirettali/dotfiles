return {
    "laytan/cloak.nvim",
    config = function()
        local cloak = require("cloak")

        local config = {
            enabled = true,
            cloak_character = '*',
            highlight_group = 'Comment',
            patterns = {
                {
                    file_pattern = { ".env*", "*.env" },
                    cloak_pattern = '=.+'
                },
            },
        }

        cloak.setup(config)

        vim.keymap.set("n", "<Leader>tc", cloak.toggle)
    end
}
