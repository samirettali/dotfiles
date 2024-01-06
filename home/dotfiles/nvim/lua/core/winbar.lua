local utils = require("core.utils")

local function get_filename()
    local filename = vim.fn.expand "%:~:."
    local extension = vim.fn.expand "%:e"

    if not utils.isempty(filename) then
        -- local file_icon, file_icon_color = require("nvim-web-devicons").get_icon_color(
        --     filename,
        --     extension,
        --     { default = true }
        -- )
        --
        -- local hl_group = "FileIconColor" .. extension
        --
        -- vim.api.nvim_set_hl(0, hl_group, { fg = file_icon_color })
        -- if utils.isempty(file_icon) then
        --     file_icon = " "
        --     file_icon_color = ""
        -- end
        --
        local filename_hl_group = vim.bo.modified and 'FilenameModified' or 'FilenameNormal'

        vim.api.nvim_set_hl(0, 'FilenameNormal', { italic = false })
        vim.api.nvim_set_hl(0, 'FilenameModified', { italic = true })

        -- return hl_group .. "#" .. file_icon .. "%*" .. "%{&modified?'  ':' '}" .. filename .. "%*"
        -- return "%#" .. hl_group .. "#" .. file_icon .. "%* " .. "%#" .. filename_hl_group .. "#" .. filename .. "%*"
        return " %#" .. filename_hl_group .. "#" .. filename .. "%*"
    end
end

local function excludes()
    if utils.is_plugin_filetype() then
        vim.opt_local.winbar = nil
        return true
    end
    return false
end

local function get_winbar()
    if excludes() then
        return
    end
    local value = table.concat {
        -- "%=",
        -- utils.get_current_filename(),
        " ",
        get_filename(),
    }

    -- if not utils.isempty(value) and utils.get_buf_option "mod" then
    --     local mod = "%#LineNr#" .. "%*"
    --     value = value .. mod
    -- end

    local status_ok, _ = pcall(vim.api.nvim_set_option_value, "winbar", value, { scope = "local" })
    if not status_ok then
        return
    end
end

-- vim.api.nvim_create_autocmd({ "CursorMoved", "BufWinEnter", "BufFilePost", "InsertEnter", "BufWritePost" }, {
--     callback = function()
--         get_winbar()
--     end,
-- })

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    callback = function()
        get_winbar()
    end,
})
