local M = {}

M.close_buffer = function(force)
    if vim.bo.buftype == "terminal" then
        vim.api.nvim_win_hide(0)
        return
    end

    local fileExists = vim.fn.filereadable(vim.fn.expand "%p")
    local modified = vim.api.nvim_buf_get_option(vim.fn.bufnr(), "modified")

    -- if file doesnt exist & its modified
    if fileExists == 0 and modified then
        print "no file name? add it now!"
        return
    end

    force = force or not vim.bo.buflisted or vim.bo.buftype == "nofile"

    -- if not force, change to prev buf and then close current
    local close_cmd = force and ":bd!" or ":bp | bd" .. vim.fn.bufnr()
    vim.cmd(close_cmd)
end

M.load_config = function()
    local conf = require "core.default_config"
    return conf
end

-- reduces a given keymap to a table of modes each containing a list of key maps
M.reduce_key_map = function(key_map, ignore_modes)
    local prune_keys = {}
    for _, modes in pairs(key_map) do
        for mode, mappings in pairs(modes) do
            if not vim.tbl_contains(ignore_modes, mode) then
                prune_keys[mode] = prune_keys[mode] and prune_keys[mode] or {}
                prune_keys[mode] = vim.list_extend(prune_keys[mode], vim.tbl_keys(mappings))
            end
        end
    end
    return prune_keys
end

-- remove disabled mappings from a given key map
M.remove_disabled_mappings = function(key_map)
    local clean_map = {}
    if type(key_map) == "table" then
        for k, v in pairs(key_map) do
            if v ~= nil and v ~= "" then clean_map[k] = v end
        end
    else
        return key_map
    end
    return clean_map
end

-- prune keys from a key map table by matching against another key map table
M.prune_key_map = function(key_map, prune_map, ignore_modes)
    if not prune_map then return key_map end
    if not key_map then return prune_map end
    local prune_keys = type(prune_map) == "table" and M.reduce_key_map(prune_map, ignore_modes)
        or { n = {}, v = {}, i = {}, t = {} }

    -- for ext, modes in pairs(key_map) do
    --    for mode, mappings in pairs(modes) do
    --       if not vim.tbl_contains(ignore_modes, mode) then
    --          if prune_keys[mode] then
    --             -- filter mappings table so that only keys that are not in user_mappings are left
    --             local filtered_mappings = {}
    --             for k, v in pairs(mappings) do
    --                if not vim.tbl_contains(prune_keys[mode], k) then
    --                   filtered_mappings[k] = M.remove_disabled_mappings(v)
    --                end
    --             end
    --             key_map[ext][mode] = filtered_mappings
    --          end
    --       end
    --    end
    -- end

    return key_map
end

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

M.telescope_map = function(key, f)
    local map_key = vim.api.nvim_replace_termcodes(key .. f, true, true, true)

    local mode = "n"
    local rhs = string.format("<Cmd>lua require('telescope.builtin')['%s']()<CR>", f, map_key)

    local map_options = {
        noremap = true,
        silent = true,
    }

    vim.api.nvim_set_keymap(mode, key, rhs, map_options)
end

M.get_hex = function(hlgroup_name, attr)
    local hlgroup_ID = vim.fn.synIDtrans(vim.fn.hlID(hlgroup_name))
    local hex = vim.fn.synIDattr(hlgroup_ID, attr)
    return hex ~= "" and hex or "NONE"
end


local function reverse(tbl)
    for i = 1, math.floor(#tbl / 2) do
        local j = #tbl - i + 1
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end

M.get_tail = function(filename)
    return vim.fn.fnamemodify(filename, ":t")
end

M.split_filename = function(filename)
    local nodes = {}
    for parent in string.gmatch(filename, "[^/]+/") do
        table.insert(nodes, parent)
    end
    table.insert(nodes, M.get_tail(filename))
    return nodes
end

M.reverse_filename = function(filename)
    local parents = M.split_filename(filename)
    reverse(parents)
    return parents
end

local function same_until(first, second)
    for i = 1, #first do
        if first[i] ~= second[i] then
            return i
        end
    end
    return 1
end

M.get_unique_filename = function(filename, other_filenames)
    local rv = ''

    local others_reversed = vim.tbl_map(M.reverse_filename, other_filenames)
    local filename_reversed = M.reverse_filename(filename)
    local same_until_map = vim.tbl_map(function(second) return same_until(filename_reversed, second) end, others_reversed)

    local max = 0
    for _, v in ipairs(same_until_map) do
        if v > max then max = v end
    end
    for i = max, 1, -1 do
        rv = rv .. filename_reversed[i]
    end

    return rv
end

M.get_current_ufn = function()
    local buffers = vim.fn.getbufinfo()
    local listed = vim.tbl_filter(function(buffer) return buffer.listed == 1 end, buffers)
    local names = vim.tbl_map(function(buffer) return buffer.name end, listed)
    local current_name = vim.fn.expand("%")
    return M.get_unique_filename(current_name, names)
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

M.command = function(cmd)
    return vim.fn.system(cmd)
end

M.reload_config = function()
    for name, _ in pairs(package.loaded) do
        if name:match('^core') and not name:match('nvim-tree') then
            package.loaded[name] = nil
        end
    end

    dofile(vim.env.MYVIMRC)
    vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
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
    "neo-tree"
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


return M
