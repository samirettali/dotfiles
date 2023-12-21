local icons = {
    lsp = "",
    block = "▊",
    -- file = {
    --     file = "",
    --     modified = "",
    --     readonly = "",
    --     new = "",
    -- },
    git = {
        signs = {
            add = "┃",
            topdelete = "󱨉",
            delete = "┃",
            changedelete = "┃",
            change = "┃",
            untracked = "┃",
        },
        git = "",
        add = "",
        branch = "",
        change = "",
        conflict = "",
        delete = " ",
        ignored = "◌",
        renamed = "",
        staged = "✓",
        unstaged = "✗",
        untracked = "★ ",
        unmerged = " "
    },
    diagnostics = {
        error = "",
        warn = "",
        hint = "󱤅",
        info = "",
    },
    borders = {
        inner = {
            all = { " ", "▁", " ", "▏", " ", "▔", " ", "▕" },
            top_bottom = { " ", "▁", " ", " ", " ", "▔", " ", " " },
        },
        outer = {
            all = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
        },
        none = { "", "", "", "", "", "", "", "" },
        left_right = { "", "", " ", "", "", "", "", " " },
        empty = { " ", " ", " ", " ", " ", " ", " ", " " },
    },
    file = "",
    empty_file = ""
}

-- M.diagnostic_signs = {
--     error = ' ',
--     warning = ' ',
--     info = ' ',
--     hint = '󱤅 ',
--     other = '󰠠 ',
-- }
--
-- M.kind_icons = {
--     Text = ' ',
--     Method = ' ',
--     Function = '󰊕 ',
--     Constructor = ' ',
--     Field = ' ',
--     Variable = ' ',
--     Class = '󰠱 ',
--     Interface = ' ',
--     Module = '󰏓 ',
--     Property = ' ',
--     Unit = ' ',
--     Value = ' ',
--     Enum = ' ',
--     EnumMember = ' ',
--     Keyword = '󰌋 ',
--     Snippet = '󰲋 ',
--     Color = ' ',
--     File = ' ',
--     Reference = ' ',
--     Folder = ' ',
--     Constant = '󰏿 ',
--     Struct = '󰠱 ',
--     Event = ' ',
--     Operator = ' ',
--     TypeParameter = '󰘦 ',
--     TabNine = '󰚩 ',
--     Unknown = '  ',
-- }

function icons:get_diagnostic(severity)
    severity = vim.diagnostic.severity[severity]
    if severity then
        local icon = self.diagnostics[severity:lower()]
        if icon then
            return icon
        end
    end
    return "!"
end

return icons
