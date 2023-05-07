local present, hover = pcall(require, "pretty_hover")

if not present then
    return false
end

local options = {
    line = {
        "@brief",
    },
    word = {
        "@param",
        "@tparam",
        "@see",
    },
    header = {
        "@class",
    },
    stylers = {
        line = "**",
        word = "`",
        header = "###",
    },
    border = "rounded",
}

hover.setup(options)
