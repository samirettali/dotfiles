return {
    -- Fuzzy file finder
    "nvim-telescope/telescope.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
        local telescope = require("telescope")

        local options = {
            defaults = {
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                },
                border = {},
                borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
                color_devicons = true,
                entry_prefix = "  ",
                file_ignore_patterns = { "node_modules", "docker", "*.mmdb", "vendor",
                    ".git/", "gen", ".cache/", "*.pdf", "*.zip", "*.dll" },
                file_previewer = require("telescope.previewers").vim_buffer_cat.new,
                file_sorter = require("telescope.sorters").get_fuzzy_file,
                generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
                grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
                initial_mode = "insert",
                path_display = { "truncate" },
                prompt_prefix = "   ",
                qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
                selection_caret = "  ",
                selection_strategy = "reset",
                set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
                sorting_strategy = "ascending",
                use_less = true,
                winblend = 0,
                mappings = {
                    n = { ["q"] = require("telescope.actions").close },
                },
                layout_strategy = "horizontal",
                layout_config = {
                    horizontal = {
                        prompt_position = "bottom",
                        preview_width = 0.55,
                        results_width = 0.8,
                    },
                    vertical = {
                        mirror = false,
                    },
                    width = 0.87,
                    height = 0.80,
                    preview_cutoff = 120,
                },
            },
            extensions = {
                fzy_native = {
                    override_generic_sorter = true,
                    override_file_sorter = true,
                },
                file_browser = {
                    theme = "ivy",
                    -- disables netrw and use telescope-file-browser in its place
                    hijack_netrw = true,
                    -- mappings = {
                    --     ["i"] = {
                    --         -- your custom insert mode mappings
                    --     },
                    --     ["n"] = {
                    --         -- your custom normal mode mappings
                    --     },
                    -- },
                },
                -- advanced_git_search = {
                --     -- fugitive or diffview
                --     diff_plugin = "fugitive",
                --     -- customize git in previewer
                --     -- e.g. flags such as { "--no-pager" }, or { "-c", "delta.side-by-side=false" }
                --     git_flags = {},
                --     -- customize git diff in previewer
                --     -- e.g. flags such as { "--raw" }
                --     git_diff_flags = {},
                --     -- Show builtin git pickers when executing "show_custom_functions" or :AdvancedGitSearch
                --     show_builtin_git_pickers = false,
                -- }
            }
        }

        local builtin = require("telescope.builtin")

        -- Telescope
        vim.keymap.set("n", "<C-f>", builtin.find_files)
        -- vim.keymap.set("n", "<C-b>", builtin.buffers)
        vim.keymap.set("n", "<C-g>", builtin.live_grep)
        -- vim.keymap.set("n", "<C-g>", builtin.git_files)

        vim.keymap.set("n", "<leader>ps", function()
            builtin.grep_string { search = vim.fn.input("grep: ") }
        end)

        vim.keymap.set("n", "<C-s>", builtin.lsp_document_symbols)
        vim.keymap.set("n", "<leader>gs", builtin.git_status)
        -- map("n",set "<C-q>", builtin.lsp_workspace_diagnostics)
        -- TODO
        -- map("n", "<C-w>", builtin.lsp_dynamic_workspace_symbols)
        -- telescope_map("<Leader>fR", builtin.lsp_references)
        -- telescope_map("<Leader>fS", "lsp_document_symbols")
        -- telescope_map("<Leader>fs", "lsp_workspace_symbols")
        vim.keymap.set("n", "gR", builtin.lsp_references)

        telescope.setup(options)
        -- telescope.load_extension("file_browser")
        -- telescope.load_extension("advanced_git_search")
    end
}