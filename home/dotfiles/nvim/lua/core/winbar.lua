local utils = require("core.utils")

-- "%=",

local function get_lsp_position()
    local ok, navic = pcall(require, "nvim-navic")

    if not ok then
        return nil
    end

    if not navic.is_available() then
        return nil
    end

    return navic.get_location()
end

-- { "CursorMoved", "BufWinEnter", "BufFilePost", "InsertEnter", "BufWritePost" }
vim.api.nvim_create_autocmd({ "BufWinEnter", "CursorMoved", "CursorMovedI", "BufWritePost" }, {
    callback = function()
        if utils.is_plugin_filetype() then
            vim.opt_local.winbar = nil
            return
        end

        local parts = {}

        local filename = vim.fn.expand("%:~:.")

        if not utils.is_empty(filename) then
            table.insert(parts, "")

            if vim.bo.modified then
                table.insert(parts, "")
            end

            table.insert(parts, filename)
        end

        local lsp = get_lsp_position()

        if not utils.is_empty(lsp) then
            table.insert(parts, ">")
            table.insert(parts, lsp)
        end

        vim.opt_local.winbar = table.concat(parts, " ")
    end,
})
