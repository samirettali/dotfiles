local M = {}

M.map = function(mode, keys, command, opt)
    local options = { silent = true }

    if opt then
        options = vim.tbl_extend("force", options, opt)
    else
        opt = options
    end

    if type(keys) == "table" then
        for _, keymap in ipairs(keys) do
            M.map(mode, keymap, command, opt)
        end
        return
    end

    vim.keymap.set(mode, keys, command, opt)
end

M.isempty = function(s)
    return s == nil or s == ""
end

M.get_buf_option = function(opt)
    local status_ok, buf_option = pcall(vim.api.nvim_buf_get_option, 0, opt)
    if not status_ok then
        return nil
    else
        return buf_option
    end
end

M.plugin_filetypes = {
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
    "neo-tree",
    "TelescopePrompt"
}

M.is_plugin_filetype = function()
    if vim.tbl_contains(M.plugin_filetypes, vim.bo.filetype) then
        return true
    end
    return false
end

M.has_value = function(tab, val)
    for _, value in ipairs(tab) do
        -- We grab the first index of our sub-table instead
        if value == val then
            return true
        end
    end
    return false
end

M.get_parent_folder = function()
    local current_buffer = vim.api.nvim_get_current_buf()
    local current_file = vim.api.nvim_buf_get_name(current_buffer)
    local parent = vim.fn.fnamemodify(current_file, ':h:t')
    if parent == '.' then return '' end
    return parent .. '/'
end

M.get_current_filename = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local filename = bufname ~= '' and vim.fn.fnamemodify(bufname, ':t') or ''
    return M.get_parent_folder() .. filename
end

return M
