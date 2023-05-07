local present, nvimtree = pcall(require, "nvim-tree")

if not present then
    return false
end

local options = {
    auto_reload_on_write = true,
    renderer = {
        root_folder_label = false,
    },
}

nvimtree.setup(options)
