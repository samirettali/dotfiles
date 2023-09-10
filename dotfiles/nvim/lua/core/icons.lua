local icons = {
    ui = {
        cmd = "",
        search_up = "",
        search_down = "",
        filter = "",
        icons = "",
        help = "",
        lua = "󰢱",
        git = "",
        remote = "",
        lsp = "",
        block = "▊",
    },
    debug = {
        debug = "",
        breakpoint = "",
        condition = "",
        stopped = "",
        rejected = "",
        log = "",

        disconnect = "",
        pause = "",
        play = "",
        run_last = "",
        step_back = "",
        step_into = "",
        step_out = "",
        step_over = "",
        terminate = "",
    },
    file = {
        file = "",
        modified = "",
        readonly = "",
        new = "",
    },
    test = {
        failed = "",
        skipped = "",
        running = "",
        passed = "",
        unknown = "",
        running_animated = {
            "⠋",
            "⠙",
            "⠹",
            "⠸",
            "⠼",
            "⠴",
            "⠦",
            "⠧",
            "⠇",
            "⠏",
        },
    },
    indent = {
        collapsible = "─",
        prefix = "├",
        marker = "│",
        dotted_marker = "┆",
        last = "└",
        collapsed = "─",
        expanded = "┐",
    },
    folder = {
        closed = "",
        open = "",
        empty = "ﰊ",
        collapsed = "",
        expanded = "",
    },
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
        error = "",
        warn = "",
        hint = "",
        info = "",
    },
    kinds = {
        Array = "",
        Boolean = "",
        Class = "",
        Color = "",
        Constant = "",
        Constructor = "",
        Enum = "",
        EnumMember = "",
        Event = "",
        Field = "",
        File = "",
        Folder = "",
        Function = "",
        Interface = "",
        Key = "",
        Keyword = "",
        Method = "",
        Module = "",
        Namespace = "",
        Null = "ﳠ",
        Number = "",
        Object = "",
        Operator = "",
        Package = "",
        Property = "",
        Reference = "",
        Snippet = "",
        String = "",
        Struct = "",
        Text = "",
        TypeParameter = "",
        Unit = "",
        Value = "",
        Variable = "",
        Unknown = "",
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
}

-- M.border_chars_none = { '', '', '', '', '', '', '', '' }
-- M.border_chars_empty = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' }
--
-- M.border_chars_tmux = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' }
--
-- M.border_chars_inner_thick = { ' ', '▄', ' ', '▌', ' ', '▀', ' ', '▐' }
-- M.border_chars_outer_thick = { '▛', '▀', '▜', '▐', '▟', '▄', '▙', '▌' }
--
-- M.border_chars_outer_thin = { '🭽', '▔', '🭾', '▕', '🭿', '▁', '🭼', '▏' }
-- M.border_chars_inner_thin = { ' ', '▁', ' ', '▏', ' ', '▔', ' ', '▕' }
--
-- M.top_right_corner_thin = '🭾'
-- M.top_left_corner_thin = '🭽'
--
-- M.border_chars_outer_thin_telescope = { '▔', '▕', '▁', '▏', '🭽', '🭾', '🭿', '🭼' }
-- M.border_chars_outer_thick_telescope = { '▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' }
--
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
