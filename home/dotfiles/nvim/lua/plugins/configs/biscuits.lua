return {
    "code-biscuits/nvim-biscuits",
    config = function()
        local biscuits = require("nvim-biscuits")

        local options = {
            show_on_start = true,
            cursor_line_only = true,
            toggle_keybind = "<Leader>tb",
            default_config = {
                max_length = 30,
                min_distance = 5,
                prefix_string = "⌃ "
            },
            language_config = {
                lua = {
                    disabled = false,
                },
                go = {
                    disabled = false,
                },
                rust = {
                    disabled = false,
                },
                help = {
                    disabled = true,
                }
            }
        }

        biscuits.setup(options)
    end
}
