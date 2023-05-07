local present, nvimtree = pcall(require, "nvim-tree")

if not present then
    return false
end

local options = {
    auto_reload_on_write = true,
    update_focused_file = {
        enable = true,
    },
    renderer = {
        root_folder_label = false,
        icons = {
            webdev_colors = true,
            git_placement = "after",
            glyphs = {
                git = {
                    unstaged = "✗",
                    staged = "✓",
                    unmerged = "",
                    renamed = "➜",
                    untracked = "★",
                    deleted = "",
                    ignored = "◌",
                },

            }
        },
    },
}

nvimtree.setup(options)
