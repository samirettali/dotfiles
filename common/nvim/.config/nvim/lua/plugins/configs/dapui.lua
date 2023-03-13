local present_dap, dap = pcall(require, "dap")
if not present_dap then
    return false
end

local present_dapui, dapui = pcall(require, "dapui")
if not present_dapui then
    return false
end

local map = require("core.utils").map

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

map("v", "<M-k>", dapui.eval)

local config = {
    icons = { expanded = "▾", collapsed = "▸" },
    mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
    },
    sidebar = {
        open_on_start = false,
        elements = {
            -- Provide as ID strings or tables with "id" and "size" keys
            { id = "scopes",      size = 0.25, },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks",      size = 0.25 },
            { id = "watches",     size = 00.25 },
        },
        size = 40,
        position = "right",
    },
    tray = {
        open_on_start = false,
        elements = { "repl" },
        size = 10,
        position = "bottom",
    },
    floating = {
        max_height = 0.25,
        max_width = 0.25,
        mappings = {
            close = { "q", "<Esc>" },
        },
    },
    windows = { indent = 1 },
}

dapui.setup(config)
