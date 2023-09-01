return {
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            -- Nvim-Tree.lua advises to do this at the start.
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            local function root_label(path)
                path = path:gsub('/Users/s.ettali', ' ') .. '/'
                local path_len = path:len()
                local win_nr = require('nvim-tree.view').get_winnr()
                local win_width = vim.fn.winwidth(win_nr)
                if path_len > (win_width - 2) then
                    local max_str = path:sub(path_len - win_width + 5)
                    local pos = max_str:find '/'
                    if pos then
                        return '󰉒 ' .. max_str:sub(pos)
                    else
                        return '󰉒 ' .. max_str
                    end
                end
                return path
            end

            local icons = {
                git_placement = 'after',
                modified_placement = 'after',
                padding = ' ',
                glyphs = {
                    default = '󰈔',
                    folder = {
                        arrow_closed = '',
                        arrow_open = '',
                        default = ' ',
                        open = ' ',
                        empty = ' ',
                        empty_open = ' ',
                        symlink = '󰉒 ',
                        symlink_open = '󰉒 ',
                    },
                    git = {
                        deleted = '',
                        unstaged = '',
                        untracked = '',
                        staged = '',
                        unmerged = '',
                    },
                },
            }

            local renderer = {
                root_folder_label = root_label,
                indent_width = 2,
                indent_markers = {
                    enable = true,
                    inline_arrows = true,
                    icons = { corner = '╰' },
                },
                icons = icons,
            }

            local system_open = { cmd = 'zathura' }

            local view = {
                cursorline = false,
                hide_root_folder = false,
                signcolumn = 'no',
                mappings = {
                    list = {
                        -- Allow moving out of the explorer.
                        { key = '<C-i>', action = 'toggle_file_info' },
                        { key = '<C-k>', action = '' },
                        { key = '[', action = 'dir_up' },
                        { key = ']', action = 'cd' },
                        { key = '<Tab>', action = 'edit' },
                        { key = 'o', action = 'system_open' },
                    },
                },
                width = { max = 41, min = 40, padding = 1 },
            }

            -- Setup.
            require('nvim-tree').setup {
                hijack_cursor = true,
                sync_root_with_cwd = true,
                view = view,
                system_open = system_open,
                renderer = renderer,
                git = { ignore = false },
                diagnostics = { enable = true },
            }

            -- Set window local options.
            local api = require 'nvim-tree.api'
            local Event = api.events.Event
            api.events.subscribe(Event.TreeOpen, function(_)
                vim.cmd [[setlocal statuscolumn=\ ]]
                vim.cmd [[setlocal cursorlineopt=number]]
                vim.cmd('setlocal fillchars+=vert:' .. '▏')
                vim.cmd('setlocal fillchars+=vertright:' .. '▏')
            end)

            -- When neovim opens.
            -- local function open_nvim_tree(data)
            --     vim.cmd.cd(data.file:match '(.+)/[^/]*$')
            --     local directory = vim.fn.isdirectory(data.file) == 1
            --     if not directory then return end
            --     require('nvim-tree.api').tree.open()
            -- end
            -- vim.api.nvim_create_autocmd({ 'VimEnter' }, { callback = open_nvim_tree })
        end
    }
}


-- return {
--     {
--         "nvim-neo-tree/neo-tree.nvim",
--         branch = "v2.x",
--         dependencies = {
--             "nvim-lua/plenary.nvim",
--             -- "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
--             "MunifTanjim/nui.nvim",
--         },
--         config = function()
--             local icons = require("core.icons")
--             -- Unless you are still migrating, remove the deprecated commands from v1.x
--             vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
--
--             -- If you want icons for diagnostic errors, you'll need to define them somewhere:
--             vim.fn.sign_define("DiagnosticSignError",
--                 { text = icons.diagnostics.error, texthl = "DiagnosticSignError" })
--             vim.fn.sign_define("DiagnosticSignWarn",
--                 { text = icons.diagnostics.warn, texthl = "DiagnosticSignWarn" })
--             vim.fn.sign_define("DiagnosticSignInfo",
--                 { text = icons.diagnostics.info, texthl = "DiagnosticSignInfo" })
--             vim.fn.sign_define("DiagnosticSignHint",
--                 { text = icons.diagnostics.hint, texthl = "DiagnosticSignHint" })
--             -- NOTE: this is changed from v1.x, which used the old style of highlight groups
--             -- in the form "LspDiagnosticsSignWarning"
--
--             require("neo-tree").setup({
--                 close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
--                 popup_border_style = "rounded",
--                 enable_git_status = true,
--                 enable_diagnostics = true,
--                 open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes
--                 sort_case_insensitive = false,                             -- used when sorting files and directories in the tree
--                 sort_function = nil,                                       -- use a custom function for sorting files and directories in the tree
--                 -- sort_function = function (a,b)
--                 --       if a.type == b.type then
--                 --           return a.path > b.path
--                 --       else
--                 --           return a.type > b.type
--                 --       end
--                 --   end , -- this sorts files and directories descendantly
--                 default_component_configs = {
--                     container = {
--                         enable_character_fade = false
--                     },
--                     indent = {
--                         indent_size = 2,
--                         padding = 1, -- extra padding on left hand side
--                         -- indent guides
--                         with_markers = true,
--                         indent_marker = "│",
--                         last_indent_marker = "└",
--                         highlight = "NeoTreeIndentMarker",
--                         -- expander config, needed for nesting files
--                         with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
--                         expander_collapsed = "",
--                         expander_expanded = "",
--                         expander_highlight = "NeoTreeExpander",
--                     },
--                     icon = {
--                         folder_closed = "",
--                         folder_open = "",
--                         folder_empty = "ﰊ",
--                         -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
--                         -- then these will never be used.
--                         default = "*",
--                         highlight = "NeoTreeFileIcon"
--                     },
--                     modified = {
--                         symbol = "[+]",
--                         highlight = "NeoTreeModified",
--                     },
--                     name = {
--                         trailing_slash = false,
--                         use_git_status_colors = true,
--                         highlight = "NeoTreeFileName",
--                     },
--                     git_status = {
--                         symbols = {
--                             -- Change type
--                             added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
--                             modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
--                             deleted   = "✖", -- this can only be used in the git_status source
--                             renamed   = "", -- this can only be used in the git_status source
--                             -- Status type
--                             untracked = "",
--                             ignored   = "",
--                             unstaged  = "",
--                             staged    = "",
--                             conflict  = "",
--                         }
--                     },
--                 },
--                 -- A list of functions, each representing a global custom command
--                 -- that will be available in all sources (if not overridden in `opts[source_name].commands`)
--                 -- see `:h neo-tree-global-custom-commands`
--                 commands = {},
--                 window = {
--                     position = "left",
--                     width = 40,
--                     mapping_options = {
--                         noremap = true,
--                         nowait = true,
--                     },
--                     mappings = {
--                         ["<space>"] = {
--                             "toggle_node",
--                             nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
--                         },
--                         ["<2-LeftMouse>"] = "open",
--                         ["<cr>"] = "open",
--                         ["<esc>"] = "revert_preview",
--                         ["P"] = { "toggle_preview", config = { use_float = true } },
--                         ["l"] = "focus_preview",
--                         ["S"] = "open_split",
--                         ["s"] = "open_vsplit",
--                         -- ["S"] = "split_with_window_picker",
--                         -- ["s"] = "vsplit_with_window_picker",
--                         ["t"] = "open_tabnew",
--                         -- ["<cr>"] = "open_drop",
--                         -- ["t"] = "open_tab_drop",
--                         ["w"] = "open_with_window_picker",
--                         --["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
--                         ["C"] = "close_node",
--                         -- ['C'] = 'close_all_subnodes',
--                         ["z"] = "close_all_nodes",
--                         --["Z"] = "expand_all_nodes",
--                         ["a"] = {
--                             "add",
--                             -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
--                             -- some commands may take optional config options, see `:h neo-tree-mappings` for details
--                             config = {
--                                 show_path = "none" -- "none", "relative", "absolute"
--                             }
--                         },
--                         ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
--                         ["d"] = "delete",
--                         ["r"] = "rename",
--                         ["y"] = "copy_to_clipboard",
--                         ["x"] = "cut_to_clipboard",
--                         ["p"] = "paste_from_clipboard",
--                         ["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
--                         -- ["c"] = {
--                         --  "copy",
--                         --  config = {
--                         --    show_path = "none" -- "none", "relative", "absolute"
--                         --  }
--                         --}
--                         ["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
--                         ["q"] = "close_window",
--                         ["R"] = "refresh",
--                         ["?"] = "show_help",
--                         ["<"] = "prev_source",
--                         [">"] = "next_source",
--                     }
--                 },
--                 nesting_rules = {},
--                 filesystem = {
--                     filtered_items = {
--                         visible = false, -- when true, they will just be displayed differently than normal items
--                         hide_dotfiles = true,
--                         hide_gitignored = true,
--                         hide_hidden = true, -- only works on Windows for hidden files/directories
--                         hide_by_name = {
--                             --"node_modules"
--                         },
--                         hide_by_pattern = { -- uses glob style patterns
--                             --"*.meta",
--                             --"*/src/*/tsconfig.json",
--                         },
--                         always_show = { -- remains visible even if other settings would normally hide it
--                             ".gitignored",
--                         },
--                         never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
--                             ".DS_Store",
--                             "thumbs.db"
--                         },
--                         never_show_by_pattern = { -- uses glob style patterns
--                             --".null-ls_*",
--                         },
--                     },
--                     follow_current_file = true,   -- This will find and focus the file in the active buffer every
--                     -- time the current file is changed while the tree is open.
--                     group_empty_dirs = false,     -- when true, empty folders will be grouped together
--                     hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
--                     -- in whatever position is specified in window.position
--                     -- "open_current",  -- netrw disabled, opening a directory opens within the
--                     -- window like netrw would, regardless of window.position
--                     -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
--                     use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
--                     -- instead of relying on nvim autocmd events.
--                     window = {
--                         mappings = {
--                             ["<bs>"] = "navigate_up",
--                             ["."] = "set_root",
--                             ["H"] = "toggle_hidden",
--                             ["/"] = "fuzzy_finder",
--                             ["D"] = "fuzzy_finder_directory",
--                             ["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
--                             -- ["D"] = "fuzzy_sorter_directory",
--                             ["f"] = "filter_on_submit",
--                             ["<c-x>"] = "clear_filter",
--                             ["[g"] = "prev_git_modified",
--                             ["]g"] = "next_git_modified",
--                         },
--                         fuzzy_finder_mappings = {
--                                       -- define keymaps for filter popup window in fuzzy_finder_mode
--                             ["<down>"] = "move_cursor_down",
--                             ["<C-n>"] = "move_cursor_down",
--                             ["<up>"] = "move_cursor_up",
--                             ["<C-p>"] = "move_cursor_up",
--                         },
--                     },
--
--                     commands = {} -- Add a custom command or override a global one using the same function name
--                 },
--                 buffers = {
--                     follow_current_file = true, -- This will find and focus the file in the active buffer every
--                     -- time the current file is changed while the tree is open.
--                     group_empty_dirs = true, -- when true, empty folders will be grouped together
--                     show_unloaded = true,
--                     window = {
--                         mappings = {
--                             ["bd"] = "buffer_delete",
--                             ["<bs>"] = "navigate_up",
--                             ["."] = "set_root",
--                         }
--                     },
--                 },
--                 git_status = {
--                     window = {
--                         position = "float",
--                         mappings = {
--                             ["A"]  = "git_add_all",
--                             ["gu"] = "git_unstage_file",
--                             ["ga"] = "git_add_file",
--                             ["gr"] = "git_revert_file",
--                             ["gc"] = "git_commit",
--                             ["gp"] = "git_push",
--                             ["gg"] = "git_commit_and_push",
--                         }
--                     }
--                 }
--             })
--
--             vim.cmd([[nnoremap <C-t> :Neotree toggle<cr>]])
--         end
--     }
-- }
