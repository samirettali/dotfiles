local utils = require("core.utils")

local function get_filename()
    local filename = vim.fn.expand "%:~:."

    if not utils.isempty(filename) then
        return filename .. vim.bo.modified and "[+]" or ""
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

-- { "CursorMoved", "BufWinEnter", "BufFilePost", "InsertEnter", "BufWritePost" }
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    callback = function()
        get_winbar()
    end,
})
