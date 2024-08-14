local utils = require("core.utils")

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

-- TODO: check if BufFilePost and InsertEnter are needed
-- TODO: maybe we can optimize it by return early if winbar is not changed
vim.api.nvim_create_autocmd({ "BufWinEnter", "CursorMoved", "CursorMovedI", "BufWritePost" }, {
    callback = function()
        local function update_winbar()
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

            return table.concat(parts, " ")
        end

        local winbar = update_winbar()

        -- Update winbar for all windows displaying the current buffer
        for _, win in ipairs(vim.fn.getbufinfo(vim.fn.bufnr())[1].windows) do
            vim.wo[win].winbar = winbar
        end
    end,
})
