local present, lualine = pcall(require, "lualine")
if not present then
    return
end

local gps_present, gps = pcall(require, "nvim-gps")
if not gps_present then
    return
end

vim.cmd("au User LspProgressUpdate let &ro = &ro")

local function lsp_progress(_, is_active)
    if not is_active then
        return
    end
    local messages = vim.lsp.util.get_progress_messages()

    if #messages == 0 then
        return ""
    end

    local status = {}

    for _, msg in pairs(messages) do
        local title = ""
        if msg.title then
            title = msg.title
        end
        table.insert(status, (msg.percentage or 0) .. "%% " .. title)
    end
    local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    local ms = vim.loop.hrtime() / 1000000
    local frame = math.floor(ms / 120) % #spinners
    return table.concat(status, "  ") .. " " .. spinners[frame + 1]
end

local colors = {
    color0 = '#1c1c1c',
    color1 = '#ff5189',
    color2 = '#c6c6c6',
    color3 = '#303030',
    color4 = '#181818',
    color6 = '#9e9e9e',
    color7 = '#80a0ff',
    color8 = '#ae81ff',
}

local theme = {
    replace = {
        a = { fg = colors.color0, bg = colors.color1, gui = 'bold' },
        b = { fg = colors.color2, bg = colors.color3 },
    },
    inactive = {
        a = { fg = colors.color6, bg = colors.color3, gui = 'bold' },
        b = { fg = colors.color6, bg = colors.color3 },
        c = { fg = colors.color6, bg = colors.color4 },
    },
    normal = {
        a = { fg = colors.color0, bg = colors.color7, gui = 'bold' },
        b = { fg = colors.color2, bg = colors.color3 },
        c = { fg = colors.color2, bg = colors.color4 },
    },
    visual = {
        a = { fg = colors.color0, bg = colors.color8, gui = 'bold' },
        b = { fg = colors.color2, bg = colors.color3 },
    },
    insert = {
        a = { fg = colors.color0, bg = colors.color2, gui = 'bold' },
        b = { fg = colors.color2, bg = colors.color3 },
    },
}

local options = {
    options = {
        theme = theme,
        section_separators = { left = "", right = "" },
        component_separators = "",
        icons_enabled = true,
        globalstatus = true,
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = {
            { "branch" },
        },
        lualine_c = {
            { "diagnostics", sources = { "nvim_diagnostic" } },
            -- { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
        },
        lualine_x = { lsp_progress },
        lualine_y = {
            -- { "progress" },
            { gps.get_location, cond = gps.is_available },
        },
        lualine_z = { "location" },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {}
    },
}

lualine.setup(options)
