local present, telescope = pcall(require, "telescope")

if not present then
    return false
end

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
            ".git", "gen", ".cache", "*.pdf", "*.zip", "*.dll" },
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
    }
}

telescope.setup(options)
telescope.load_extension("file_browser")
