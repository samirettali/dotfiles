local present, biscuits = pcall(require, "nvim-biscuits")

if not present then
    return false
end

local options = {
    show_on_start = true,
    cursor_line_only = false,
    toggle_keybind = "<Leader>cb",
    default_config = {
        max_length = 12,
        min_distance = 5,
        prefix_string = " 📎 "
    },
    language_config = {
        go = {
            prefix_string = " 🌐 "
        },
        html = {
            prefix_string = " 🌐 "
        },
        javascript = {
            prefix_string = " ✨ ",
            max_length = 80
        },
        python = {
            disabled = true
        }
    }
}

biscuits.setup(options)
