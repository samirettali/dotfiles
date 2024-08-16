return {
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
    },
    {
        "Marskey/telescope-sg"
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release',
        config = function()
            require("telescope").load_extension("fzf")
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            local telescope = require("telescope")

            local options = {
                defaults = {
                    file_ignore_patterns = {
                        "^node_modules/",
                        "^vendor/",
                        "^contracts/mocks/",
                        "^.git/",
                        "^.cache/",
                        "%.mmdb",
                        "%.pdf",
                        "%.zip",
                        "%.dll",
                    },
                    mappings = {
                        n = { ["q"] = require("telescope.actions").close },
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                    },
                    file_browser = {
                        theme = "ivy",
                    },
                }
            }

            local builtin = require("telescope.builtin")

            -- Telescope
            vim.keymap.set("n", "<C-f>", builtin.find_files)
            vim.keymap.set("n", "<C-g>", builtin.live_grep)

            vim.keymap.set("n", "<leader>ps", function()
                builtin.grep_string { search = vim.fn.input("grep: ") }
            end)

            vim.keymap.set("n", "<leader>pb", builtin.buffers)

            vim.keymap.set("n", "<leader>pws", function()
                local word = vim.fn.expand("<cword>")
                builtin.grep_string { search = word }
            end)

            vim.keymap.set("n", "<C-s>", builtin.lsp_document_symbols)
            vim.keymap.set("n", "gR", builtin.lsp_references)

            telescope.setup(options)
            telescope.load_extension("file_browser")
            telescope.load_extension("ast_grep")
        end
    },
}
