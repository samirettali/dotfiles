return {
    "laytan/cloak.nvim",
    config = function()
        local cloak = require("cloak")

        local map = require("core.utils").map

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

        map("n", "<Leader>tc", cloak.toggle)
    end
}
