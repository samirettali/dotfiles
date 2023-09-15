return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    config = function()
        local treesitter = require("nvim-treesitter.configs")

        local options = {
            textobjects = {
                select = {
                    enable = true,

                    -- Automatically jump forward to textobj, similar to targets.vim
                    lookahead = true,

                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",

                        -- Or you can define your own textobjects like this
                        ["iF"] = {
                            python = "(function_definition) @function",
                            cpp = "(function_definition) @function",
                            c = "(function_definition) @function",
                            java = "(method_declaration) @function",
                        },
                    },
                },
            },
        }

        treesitter.setup(options)
    end
}
