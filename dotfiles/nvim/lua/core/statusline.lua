local icons = require("core.icons")

local function lsp()
    local count = {}
    local levels = {
        errors = "Error",
        warnings = "Warn",
        info = "Info",
        hints = "Hint",
    }

    for k, level in pairs(levels) do
        count[k] = vim.tbl_count(vim.diagnostic.get(0, { severity = level }))
    end

    local errors = ""
    local warnings = ""
    local hints = ""
    local info = ""

    if count["errors"] ~= 0 then
        errors = "%#DiagnosticSignError#" .. icons.diagnostics.error .. " " .. count["errors"] .. " "
    end
    if count["warnings"] ~= 0 then
        warnings = "%#DiagnosticSignWarn#" .. icons.diagnostics.warn .. " " .. count["warnings"] .. " "
    end
    if count["hints"] ~= 0 then
        hints = "%#DiagnosticSignHint#" .. icons.diagnostics.hint .. " " .. count["hints"] .. " "
    end
    if count["info"] ~= 0 then
        info = "%#DiagnosticSignInfo#" .. icons.diagnostics.info .. " " .. count["info"] .. " "
    end

    local result = errors .. warnings .. hints .. info
    if result ~= "" then
        return " " .. result .. "%#Statusline#"
    end

    return ""
end

function Statusline()
    local branch = vim.fn.FugitiveHead()

    if branch and #branch > 0 then
        branch = '%#StatuslineBGBlue#  ' .. branch .. ' %#Statusline#'
    end

    local lsp = lsp()

    return branch .. ' %f %m ' .. lsp .. '%=%p%% %l:%c '
end

vim.opt.statusline = [[%!luaeval("Statusline()")]]
