local present, feline = pcall(require, "feline")

if not present then
    return false
end

-- local theme = {
--     -- aqua = "#7AB0DF",
--     -- blue = "#5FB0FC",
--     blue = "#7AB0DF",
--     aqua = "#5FB0FC",
--     bg = "#101010",
--     cyan = "#70C0BA",
--     darkred = "#ff5189",
--     fg = "#C7C7CA",
--     gray = "#222730",
--     green = "#36C692",
--     lime = "#54CED6",
--     orange = "#FFD064",
--     pink = "#D997C8",
--     purple = "#ae81ff",
--     red = "#ff5454",
--     yellow = "#c2c292"
-- }
local nordic_colors = require("nordic.colors")

local theme = {
    -- aqua = "#7AB0DF",
    -- blue = "#5FB0FC",
    blue = "#7AB0DF",
    aqua = nordic_colors.orange.bright,
    bg = nordic_colors.bg_statusline,
    cyan = "#70C0BA",
    darkred = "#ff5189",
    fg = "#C7C7CA",
    gray = nordic_colors.gray1,
    green = nordic_colors.green.bright,
    lime = "#54CED6",
    orange = nordic_colors.yellow.bright,
    pink = "#D997C8",
    purple = "#ae81ff",
    red = "#ff5454",
    yellow = "#c2c292"
}


local lsp = require "feline.providers.lsp"

local assets = {
    left_separator = "",
    right_separator = "",
    mode_icon = "",
    dir = "",
    file = "",
    lsp = {
        server = "",
        error = "",
        warning = "",
        info = "",
        hint = "",
    },
    git = {
        branch = "",
        added = "+",
        changed = "~",
        removed = "-",
    },
}

local C = theme

local sett = {
    diffstest = C.fg,
    text = C.bg,
    bkg = C.bg,
    diffs = C.gray,
    extras = C.overlay1,
    curr_file = C.gray,
    curr_dir = C.aqua,
    show_modified = false,
}

local mode_colors = {
    ["n"] = { "NORMAL", C.aqua },
    ["no"] = { "N-PENDING", C.aqua },
    ["i"] = { "INSERT", C.green },
    ["ic"] = { "INSERT", C.green },
    ["t"] = { "TERMINAL", C.green },
    ["v"] = { "VISUAL", C.red },
    ["V"] = { "V-LINE", C.red },
    [""] = { "V-BLOCK", C.red },
    ["R"] = { "REPLACE", C.gray },
    ["Rv"] = { "V-REPLACE", C.gray },
    ["s"] = { "SELECT", C.gray },
    ["S"] = { "S-LINE", C.gray },
    [""] = { "S-BLOCK", C.gray },
    ["c"] = { "COMMAND", C.yellow },
    ["cv"] = { "COMMAND", C.yellow },
    ["ce"] = { "COMMAND", C.yellow },
    ["r"] = { "PROMPT", C.purple },
    ["rm"] = { "MORE", C.purple },
    ["r?"] = { "CONFIRM", C.lime },
    ["!"] = { "SHELL", C.green },
}

local shortline = false

local components = {
    active = { {}, {}, {} }, -- left, center, right
    inactive = { {} },
}

local function is_enabled(min_width)
    if shortline then return true end

    return vim.api.nvim_win_get_width(0) > min_width
end

-- global components
local invi_sep = {
    str = " ",
    hl = {
        fg = sett.bkg,
        bg = sett.bkg,
    },
}

-- helpers
local function any_git_changes()
    local gst = vim.b.gitsigns_status_dict -- git stats
    if gst then
        if gst["added"] and gst["added"] > 0
            or gst["removed"] and gst["removed"] > 0
            or gst["changed"] and gst["changed"] > 0
        then
            return true
        end
    end
    return false
end

-- #################### STATUSLINE ->

-- ######## Left

-- Current vi mode ------>
local vi_mode_hl = function()
    return {
        fg = theme.bg,
        bg = mode_colors[vim.fn.mode()][2],
        style = "bold",
    }
end

components.active[1][1] = {
    provider = " " .. assets.mode_icon .. " ",
    hl = function()
        return {
            fg = sett.text,
            bg = mode_colors[vim.fn.mode()][2],
        }
    end,
}

components.active[1][2] = {
    provider = function() return mode_colors[vim.fn.mode()][1] .. " " end,
    hl = vi_mode_hl,
}

-- there is a dilema: we need to hide Diffs if ther is no git info. We can do that, but this will
-- leave the right_separator colored with purple, and since we can't change the color conditonally
-- then the solution is to create two right_separators: one with a lime sett.bkg and the other one normal
-- sett.bkg; both have the same fg (vi mode). The lime one appears if there is git info, else the one with
-- the normal sett.bkg appears. Fixed :)

-- enable if git diffs are not available
components.active[1][3] = {
    provider = assets.right_separator,
    hl = function()
        return {
            fg = mode_colors[vim.fn.mode()][2],
            bg = sett.bkg,
        }
    end,
    enabled = function() return not any_git_changes() end,
}

-- enable if git diffs are available
components.active[1][4] = {
    provider = assets.right_separator,
    hl = function()
        return {
            fg = mode_colors[vim.fn.mode()][2],
            bg = sett.diffs,
        }
    end,
    enabled = function() return any_git_changes() end,
}
-- Current vi mode ------>

-- Diffs ------>
components.active[1][5] = {
    provider = "git_diff_added",
    hl = {
        fg = C.green,
        bg = sett.diffs,
    },
    icon = " " .. assets.git.added .. " ",
}

components.active[1][6] = {
    provider = "git_diff_changed",
    hl = {
        fg = C.orange,
        bg = sett.diffs,
    },
    icon = " " .. assets.git.changed .. " ",
}

components.active[1][7] = {
    provider = "git_diff_removed",
    hl = {
        fg = C.red,
        bg = sett.diffs,
    },
    icon = " " .. assets.git.removed .. " ",
}

components.active[1][8] = {
    provider = " ",
    hl = {
        fg = sett.bkg,
        bg = sett.diffs,
    },
    enabled = function() return any_git_changes() end,
}

components.active[1][9] = {
    provider = assets.right_separator,
    hl = {
        fg = sett.diffs,
        bg = sett.bkg,
    },
    enabled = function() return any_git_changes() end,
}
-- Diffs ------>

-- Extras ------>

-- file progess
components.active[1][10] = {
    provider = function()
        return ""
        -- local current_line = vim.fn.line "."
        -- local total_line = vim.fn.line "$"

        -- if current_line == 1 then
        --     return "Top"
        -- elseif current_line == vim.fn.line "$" then
        --     return "Bot"
        -- end
        -- local result, _ = math.modf((current_line / total_line) * 100)
        -- return result .. "%%"
    end,
    -- enabled = shortline or function(winid)
    -- 	return vim.api.nvim_win_get_width(winid) > 90
    -- end,
    hl = {
        fg = sett.extras,
        bg = sett.bkg,
    },
    left_sep = invi_sep,
}

-- position
components.active[1][11] = {
    provider = "position",
    -- enabled = shortline or function(winid)
    -- 	return vim.api.nvim_win_get_width(winid) > 90
    -- end,
    hl = {
        fg = sett.extras,
        bg = sett.bkg,
    },
    left_sep = invi_sep,
}

-- macro
components.active[1][12] = {
    provider = "macro",
    enabled = function() return vim.api.nvim_get_option "cmdheight" == 0 end,
    hl = {
        fg = sett.extras,
        bg = sett.bkg,
    },
    left_sep = invi_sep,
}

-- search count
components.active[1][13] = {
    provider = "search_count",
    enabled = function() return vim.api.nvim_get_option "cmdheight" == 0 end,
    hl = {
        fg = sett.extras,
        bg = sett.bkg,
    },
    left_sep = invi_sep,
}
-- Extras ------>

-- ######## Left

-- ######## Center

-- Diagnostics ------>
-- workspace loader
components.active[2][1] = {
    provider = function()
        local Lsp = vim.lsp.util.get_progress_messages()[1]

        if Lsp then
            local msg = Lsp.message or ""
            local percentage = Lsp.percentage
            if not percentage then return "" end
            local title = Lsp.title or ""
            local spinners = {
                "",
                "",
                "",
            }
            local success_icon = {
                "",
                "",
                "",
            }
            local ms = vim.loop.hrtime() / 1000000
            local frame = math.floor(ms / 120) % #spinners

            if percentage >= 70 then
                return string.format(" %%<%s %s %s (%s%%%%) ", success_icon[frame + 1], title, msg, percentage)
            end

            return string.format(" %%<%s %s %s (%s%%%%) ", spinners[frame + 1], title, msg, percentage)
        end

        return ""
    end,
    enabled = is_enabled(80),
    hl = {
        fg = C.rosewater,
        bg = sett.bkg,
    },
}

-- genral diagnostics (errors, warnings. info and hints)
components.active[2][2] = {
    provider = "diagnostic_errors",
    enabled = function() return lsp.diagnostics_exist(vim.diagnostic.severity.ERROR) end,

    hl = {
        fg = C.red,
        bg = sett.bkg,
    },
    icon = " " .. assets.lsp.error .. " ",
}

components.active[2][3] = {
    provider = "diagnostic_warnings",
    enabled = function() return lsp.diagnostics_exist(vim.diagnostic.severity.WARN) end,
    hl = {
        fg = C.yellow,
        bg = sett.bkg,
    },
    icon = " " .. assets.lsp.warning .. " ",
}

components.active[2][4] = {
    provider = "diagnostic_info",
    enabled = function() return lsp.diagnostics_exist(vim.diagnostic.severity.INFO) end,
    hl = {
        fg = C.sky,
        bg = sett.bkg,
    },
    icon = " " .. assets.lsp.info .. " ",
}

components.active[2][5] = {
    provider = "diagnostic_hints",
    enabled = function() return lsp.diagnostics_exist(vim.diagnostic.severity.HINT) end,
    hl = {
        fg = C.rosewater,
        bg = sett.bkg,
    },
    icon = " " .. assets.lsp.hint .. " ",
}
-- Diagnostics ------>

-- ######## Center

-- ######## Right

-- components.active[3][1] = {
--     provider = "git_branch",
--     enabled = is_enabled(70),
--     hl = {
--         fg = sett.extras,
--         bg = sett.bkg,
--     },
--     icon = assets.git.branch .. " ",
--     right_sep = invi_sep,
-- }

-- components.active[3][2] = {
--     provider = function()
--         if next(vim.lsp.buf_get_clients()) ~= nil then
--             return assets.lsp.server .. " " .. "Lsp"
--         else
--             return ""
--         end
--     end,
--     hl = {
--         fg = sett.extras,
--         bg = sett.bkg,
--     },
--     right_sep = invi_sep,
-- }

-- components.active[3][3] = {
components.active[3][1] = {
    provider = function()
        local provider = require("feline.providers.git")
        local info = provider.git_info_exists()
        if info ~= nil then
            return "  " .. info .. " "
        end
        return ""
    end,
    -- provider = "git_branch",
    enabled = is_enabled(70),
    hl = {
        fg = sett.diffstext,
        bg = sett.curr_file,
    },
    left_sep = {
        str = assets.left_separator,
        hl = {
            fg = sett.curr_file,
            bg = sett.bkg,
        },
    },
}

components.active[3][2] = {
    provider = function()
        local dir_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        return " " .. assets.dir .. " " .. dir_name .. " "
    end,
    enabled = is_enabled(80),
    hl = {
        fg = sett.text,
        bg = sett.curr_dir,
    },
    left_sep = {
        str = assets.left_separator,
        hl = {
            fg = sett.curr_dir,
            bg = sett.curr_file,
        },
    },
}
-- ######## Right

-- Inanctive components
components.inactive[1][1] = {
    provider = function() return " " .. string.upper(vim.bo.ft) .. " " end,
    hl = {
        fg = C.overlay2,
        bg = C.mantle,
    },
}


feline.setup({
    components = components,
    theme = theme,
})
