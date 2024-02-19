return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        local treesitter = require('nvim-treesitter.configs')
        local options = {
            ensure_installed = {
                "lua",
                "rust",
                "go",
                "solidity",
                "c",
                "cpp",
                "c_sharp",
                "sql",
                "python",

                "html",
                "tsx",
                "javascript",
                "typescript",

                "json",
                "toml",
                "markdown",

                "vim",
                "vimdoc",
                "query",
            },
            matchup = {
                enable = true,
            },
            highlight = {
                enable = true,
                disable = function(_, bufnr) -- Disable in files with more than 5K
                    return vim.api.nvim_buf_line_count(bufnr) > 5000
                end,
            },
            autotag = {
                enable = true,
            },
            indent = {
                enable = true,
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = '<c-space>',
                    node_incremental = '<c-space>',
                    scope_incremental = '<c-s>',
                    node_decremental = '<M-space>',
                },
            },
            context_commentstring = {
                enable = true
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ['aa'] = '@parameter.outer',
                        ['ia'] = '@parameter.inner',
                        ['af'] = '@function.outer',
                        ['if'] = '@function.inner',
                        ['ac'] = '@class.outer',
                        ['ic'] = '@class.inner',
                        ['al'] = '@loop.outer',
                        ['il'] = '@loop.inner',
                        ['at'] = '@comment.outer',
                        ['it'] = '@comment.inner',
                        ['ai'] = '@conditional.outer',
                        ['ii'] = '@conditional.inner',
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true, -- Whether to set jumps in the jumplist
                    goto_next_start = {
                        [']m'] = '@function.outer',
                        [']]'] = '@class.outer',
                    },
                    goto_next_end = {
                        [']M'] = '@function.outer',
                        [']['] = '@class.outer',
                    },
                    goto_previous_start = {
                        ['[m'] = '@function.outer',
                        ['[['] = '@class.outer',
                    },
                    goto_previous_end = {
                        ['[M'] = '@function.outer',
                        ['[]'] = '@class.outer',
                    },
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ['g>'] = { query = '@parameter.inner', desc = "Swap parameter with next" },
                    },
                    swap_previous = {
                        ['g<'] = { query = '@parameter.inner', desc = "Swap parameter with previous" },
                    },
                },
            },
        }

        treesitter.setup(options)
    end
}
