local present, biscuits = pcall(require, "nvim-biscuits")

if not present then
    return false
end

local options = {
    show_on_start = true,
    cursor_line_only = true,
    toggle_keybind = "<Leader>cb",
    default_config = {
        max_length = 30,
        min_distance = 5,
        prefix_string = "⌃ "
    },
    language_config = {
        go = {
            disabled = false,
        },
    }
}

biscuits.setup(options)
