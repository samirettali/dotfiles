local utils = require("core.utils")

local M = {}

M.winbar_filetype_exclude = {
    "help",
    "startify",
    "dashboard",
    "packer",
    "neogitstatus",
    "NvimTree",
    "Trouble",
    "alpha",
    "lir",
    "Outline",
    "spectre_panel",
    "toggleterm",
    "vista_kind",
    "NEO-TREE"
}

local function get_filename()
    local filename = vim.fn.expand "%:~:."
    local extension = vim.fn.expand "%:e"

    if not utils.isempty(filename) then
        local file_icon, file_icon_color = require("nvim-web-devicons").get_icon_color(
            filename,
            extension,
            { default = true }
        )

        local hl_group = "FileIconColor" .. extension

        vim.api.nvim_set_hl(0, hl_group, { fg = file_icon_color })
        if utils.isempty(file_icon) then
            file_icon = ""
            file_icon_color = ""
        end

        return " " ..
            "%#" ..
            hl_group .. "#" .. file_icon .. "%*" .. "%#LineNr#" .. "%{&modified?'  ':' '}" .. filename .. "%*"
    end
end

local function get_gps()
    local status_gps_ok, gps = pcall(require, "nvim-gps")
    if not status_gps_ok then
        return ""
    end

    local status_ok, gps_location = pcall(gps.get_location, {})
    if not status_ok then
        return ""
    end

    if not gps.is_available() or gps_location == "error" then
        return ""
    end

    if not utils.isempty(gps_location) then
        return "> " .. gps_location
    else
        return ""
    end
end

local excludes = function()
    if vim.tbl_contains(M.winbar_filetype_exclude, vim.bo.filetype) then
        vim.opt_local.winbar = nil
        return true
    end
    return false
end

-- TODO: add git blame
M.get_winbar = function()
    if excludes() then
        return
    end
    local value = get_filename()

    local gps_added = false
    if not utils.isempty(value) then
        local gps_value = get_gps()
        value = value .. " " .. gps_value
        if not utils.isempty(gps_value) then
            gps_added = true
        end
    end

    if not utils.isempty(value) and utils.get_buf_option "mod" then
        -- local mod = "%#LineNr#" .. require("user.icons").ui.Circle .. "%*"
        local mod = "%#LineNr#" .. "%*"
        if gps_added then
            value = value .. " " .. mod
        else
            value = value .. mod
        end
    end

    local status_ok, _ = pcall(vim.api.nvim_set_option_value, "winbar", value, { scope = "local" })
    if not status_ok then
        return
    end
end

return M
