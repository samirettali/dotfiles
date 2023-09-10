local fn = vim.fn
local api = vim.api
local fmt = string.format
local utils = require("core.utils")
local icons = require("core.icons")

local modes = {
    ["n"] = "NORMAL",
    ["no"] = "NORMAL",
    ["v"] = "VISUAL",
    ["V"] = "VISUAL LINE",
    [""] = "VISUAL BLOCK",
    ["s"] = "SELECT",
    ["S"] = "SELECT LINE",
    [""] = "SELECT BLOCK",
    ["i"] = "INSERT",
    ["ic"] = "INSERT",
    ["R"] = "REPLACE",
    ["Rv"] = "VISUAL REPLACE",
    ["c"] = "COMMAND",
    ["cv"] = "VIM EX",
    ["ce"] = "EX",
    ["r"] = "PROMPT",
    ["rm"] = "MOAR",
    ["r?"] = "CONFIRM",
    ["!"] = "SHELL",
    ["t"] = "TERMINAL",
}

local function ruler()
    if utils.is_plugin_filetype() then
        return ""
    end
    return "%P"
end

local function lineinfo()
    if utils.is_plugin_filetype() then
        return ""
    end
    return "%l:%c"
end

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
        return " " .. result
    end

    return ""
end

local function mode()
    local current_mode = vim.api.nvim_get_mode().mode
    return string.format("%s", modes[current_mode]):upper()
end

Statusline = {}

local function git_branch()
    local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
    if branch ~= "" then
        return icons.git.branch .. " " .. branch
    else
        return ""
    end
end

Statusline.active = function()
    return table.concat {
        "%#StatuslineBGBlue# ",
        mode(),
        " %#Statusline# ",
        git_branch(),
        -- " ",
        "%=",
        utils.get_current_filename(),
        "%#Statusline#",
        lsp(),
        "%#Statusline#",
        "%=",
        ruler(),
        " ",
        lineinfo(),
        " "
    }
end

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    pattern = "*",
    callback = function()
        vim.cmd("setlocal statusline=%!v:lua.Statusline.active()")
    end
})
