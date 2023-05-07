local function config()
    local statuscol = require "statuscol"

    local builtin = require "statuscol.builtin"
    local utils = require "core.utils"
    local icons = require "core.icons"

    local options = {
        setopt = true,
        relculright = true,
        segments = {
            { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
            {
                sign = {
                    name = { "Git*" },
                    maxwidth = 1,
                    auto = true,
                    wrap = true,
                    fillchar = "",
                    fillcharhl = "StatusColumnSeparator",
                },
                click = "v:lua.ScSa",
            },
            -- {
            --     sign = {
            --         name = { "Diagnostic" },
            --         maxwidth = 2,
            --         auto = true
            --     },
            --     click = "v:lua.ScSa",
            -- },
            {
                text = { builtin.lnumfunc, "  " },
                -- condition = { true, builtin.not_empty },
                click = "v:lua.ScLa",
            },
            -- {
            --     sign = { name = { ".*" }, maxwidth = 2, colwidth = 1, auto = true },
            --     click = "v:lua.ScSa"
            -- },
        },
        clickmod = "c",
        ft_ignore = utils.plugin_filetypes,
        clickhandlers = {
            Lnum                    = builtin.lnum_click,
            FoldClose               = builtin.foldclose_click,
            FoldOpen                = builtin.foldopen_click,
            FoldOther               = builtin.foldother_click,
            DapBreakpointRejected   = builtin.toggle_breakpoint,
            DapBreakpoint           = builtin.toggle_breakpoint,
            DapBreakpointCondition  = builtin.toggle_breakpoint,
            DiagnosticSignError     = builtin.diagnostic_click,
            DiagnosticSignHint      = builtin.diagnostic_click,
            DiagnosticSignInfo      = builtin.diagnostic_click,
            DiagnosticSignWarn      = builtin.diagnostic_click,
            GitSignsTopdelete       = builtin.gitsigns_click,
            GitSignsUntracked       = builtin.gitsigns_click,
            GitSignsAdd             = builtin.gitsigns_click,
            GitSignsChange          = builtin.gitsigns_click,
            GitSignsChangedelete    = builtin.gitsigns_click,
            GitSignsDelete          = builtin.gitsigns_click,
            gitsigns_extmark_signs_ = builtin.gitsigns_click,
        },
    }

    statuscol.setup(options)
end

return {
    "luukvbaal/statuscol.nvim",
    event = "BufReadPost",
    dependencies = {
        "mfussenegger/nvim-dap",
        "lewis6991/gitsigns.nvim"
    },
    config = config,
}
