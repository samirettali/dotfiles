return {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
        local treesitter = require('nvim-treesitter.configs')
        local options = {
            ensure_installed = { "lua", "rust", "go", "sql", "c", "cpp", "python", "tsx", "javascript", "typescript",
                "vimdoc", "vim", "query" },
            matchup = {
                enable = true,
            },
            highlight = {
                enable = true,
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
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
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
                        ['<Leader>a'] = '@parameter.inner',
                    },
                    swap_previous = {
                        ['<Leader>A'] = '@parameter.inner',
                    },
                },
            },
        }

        treesitter.setup(options)
    end
}
