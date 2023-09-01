-- local function OrgImports(wait_ms)
--     local params = vim.lsp.util.make_range_params()
--     params.context = {
--         only = { "source.organizeImports" }
--     }
--     -- P(params)
--     local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
--     -- P(result)
--     for cid, res in pairs(result or {}) do
--         for _, r in pairs(res.result or {}) do
--             if r.edit then
--                 local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
--
--                 vim.lsp.util.apply_workspace_edit(r.edit, enc)
--             else
--                 vim.lsp.buf.execute_command(r.command)
--             end
--         end
--     end
-- end
--
-- local function custom_attach(client, bufnr)
--     local severity_levels = {
--         vim.diagnostic.severity.ERROR,
--         vim.diagnostic.severity.WARN,
--         vim.diagnostic.severity.INFO,
--         vim.diagnostic.severity.HINT,
--     }
--
--     local get_highest_error_severity = function()
--         for _, level in ipairs(severity_levels) do
--             local diags = vim.diagnostic.get(0, { severity = { min = level } })
--             if #diags > 0 then
--                 return level, diags
--             end
--         end
--     end
--
--     local opts = { buffer = bufnr, remap = false }
--     vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
--
--     vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
--     vim.keymap.set("n", "gT", function() vim.lsp.buf.type_definition() end, opts)
--     vim.keymap.set("n", "ga", function() vim.lsp.buf.code_action() end, opts)
--     vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
--
--     vim.keymap.set("n", "gI", function() vim.lsp.buf.incoming_calls() end, opts)
--     vim.keymap.set("n", "gI", function() vim.lsp.buf.outgoing_calls() end, opts)
--
--     vim.keymap.set("n", "gs", function() vim.lsp.buf.document_symbol() end, opts)
--     vim.keymap.set("n", "gS", function() vim.lsp.buf.workspace_symbol() end, opts)
--     vim.keymap.set("n", "gr", function() vim.lsp.buf.rename() end, opts)
--
--     vim.keymap.set("n", "ds", function() vim.diagnostic.get() end, opts)
--     vim.keymap.set("n", "<leader>sl", function() vim.diagnostic.open_float() end, opts) -- TODO opt scope = "line"
--     vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
--     vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
--
--     vim.keymap.set('n', '[d', function() vim.diagnostic.goto_next {
--         severity = get_highest_error_severity(),
--         wrap = true,
--         float = true,
--     } end, opts)
--
--     vim.keymap.set('n', ']d', function() vim.diagnostic.goto_prev {
--         severity = get_highest_error_severity(),
--         wrap = true,
--         float = true,
--     } end, opts)
--
--     vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
--     vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
--
--     vim.api.nvim_create_autocmd("BufWritePre", {
--         callback = function()
--             -- vim.lsp.buf.code_action { context = { only = { 'source.organizeImports' } }, apply = true, async = false }
--             print("calling format")
--             OrgImports(1000)
--             vim.lsp.buf.format {
--                 async = false
--             }
--             print("called format")
--         end
--     })
--     print("done")
-- end
--
--
-- return {
--     {
--         'VonHeikemen/lsp-zero.nvim',
--         branch = 'v2.x',
--         dependencies = {
--             -- LSP Support
--             { 'neovim/nvim-lspconfig' }, -- Required
--             {
--                 -- Optional
--                 'williamboman/mason.nvim',
--                 build = function()
--                     pcall(vim.cmd, 'MasonUpdate')
--                 end,
--             },
--             { 'williamboman/mason-lspconfig.nvim' }, -- Optional
--
--             -- Autocompletion
--             { 'hrsh7th/nvim-cmp' },     -- Required
--             { 'hrsh7th/cmp-nvim-lsp' }, -- Required
--             { "hrsh7th/cmp-nvim-lua" },
--             { "hrsh7th/cmp-buffer" },
--             { "hrsh7th/cmp-path" },
--             { 'L3MON4D3/LuaSnip' },     -- Required
--             { 'simrat39/rust-tools.nvim' },
--             "onsails/lspkind-nvim",
--         },
--         config = function()
--             local lsp = require('lsp-zero').preset({
--                 name = 'minimal',
--                 set_lsp_keymaps = true,
--                 manage_nvim_cmp = true,
--                 suggest_lsp_servers = false,
--             })
--
--             lsp.set_sign_icons({
--                 error = '✘',
--                 warn = '▲',
--                 hint = '⚑',
--                 info = '»'
--             })
--
--             vim.diagnostic.config({
--                 virtual_text = true
--             })
--
--             lsp.ensure_installed({
--                 'tsserver',
--                 'rust_analyzer',
--                 'gopls',
--             })
--
--             lsp.skip_server_setup({'rust_analyzer'})
--
--             lsp.setup()
--
--             lsp.setup_servers({
--                 'gopls',
--                 'lua_ls',
--                 opts = {
--                     single_file_support = false,
--                     on_attach = custom_attach,
--                 }
--             })
--
--             lsp.nvim_workspace()
--
--             lsp.setup()
--
--             local rust_lsp = lsp.build_options('rust_analyzer', {
--                 single_file_support = false,
--                 on_attach = function(client, bufnr)
--                     custom_attach(client, bufnr)
--                 end
--             })
--
--             require('rust-tools').setup({server = rust_lsp})
--
--             local cmp = require('cmp')
--             local cmp_select = { behavior = cmp.SelectBehavior.Select }
--             local cmp_mappings = lsp.defaults.cmp_mappings({
--                 ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
--                 ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
--                 ['<CR>'] = cmp.mapping.confirm({ select = true }),
--                 ["<C-Space>"] = cmp.mapping.complete(),
--             })
--
--             cmp.setup({
--                 window = {
--                     completion = cmp.config.window.bordered(),
--                     documentation = cmp.config.window.bordered(),
--                 },
--                 mapping = cmp_mappings,
--                 formatting = {
--                     fields = {
--                         cmp.ItemField.Kind,
--                         cmp.ItemField.Abbr,
--                         cmp.ItemField.Menu,
--                     },
--                     format = require('lspkind').cmp_format({
--                         mode = 'symbol',
--                         maxwidth = 50,
--                         ellipsis_char = '...',
--                     })
--                 },
--                 sources = {
--                     {name = 'path'},
--                     {name = 'nvim_lsp'},
--                     {name = 'buffer', keyword_length = 3},
--                     {name = 'luasnip', keyword_length = 2},
--                 }
--
--             })
--         end,
--     },
--     {
--         -- Autopair brackets and other symbols
--         "windwp/nvim-autopairs",
--         -- after = "nvim-cmp",
--         config = function()
--             local present1, autopairs = pcall(require, "nvim-autopairs")
--             local present2, cmp = pcall(require, "cmp")
--
--             if not present1 and present2 then
--                 return
--             end
--
--             autopairs.setup {
--                 fast_wrap = {},
--                 disable_filetype = { "TelescopePrompt", "vim" },
--             }
--
--             local cmp_autopairs = require "nvim-autopairs.completion.cmp"
--
--             cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
--         end
--     },
--     {
--         "ray-x/lsp_signature.nvim",
--         config = function()
--             require("lsp_signature").setup {}
--         end,
--     },
-- }

local function config()
    local present, lspconfig = pcall(require, "lspconfig")

    if not present then
        return false
    end

    local util = lspconfig.util

    -- Borders for LspInfo winodw
    local win = require "lspconfig.ui.windows"
    local _default_opts = win.default_opts

    local utils = require("core.utils")
    local map = utils.map

    win.default_opts = function(options)
        local opts = _default_opts(options)
        opts.border = "single"
        return opts
    end

    local lsp_handlers = function()
        local function lspSymbol(name, icon)
            local hl = "DiagnosticSign" .. name
            vim.fn.sign_define(hl, {
                text = icon,
                numhl = hl,
                texthl = hl
            })
        end
        local icons = require("core.icons")

        lspSymbol("Error", icons.diagnostics.error)
        lspSymbol("Info", icons.diagnostics.info)
        lspSymbol("Hint", icons.diagnostics.hint)
        lspSymbol("Warn", icons.diagnostics.warn)


        vim.diagnostic.config {
            virtual_text = {
                prefix = ""
            },
            signs = false,
            underline = true,
            update_in_insert = false
        }

        -- local pop_opts = { border = "rounded", max_width = 80 }

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
            border = "single"
        })
        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
            border = "single"
        })

        -- suppress error messages from lang servers
        vim.notify = function(msg, log_level)
            if msg:match "exit code" then
                return
            end

            if log_level == vim.log.levels.ERROR then
                vim.api.nvim_err_writeln(msg)
            else
                vim.api.nvim_echo({ { msg } }, true, {})
            end
        end
    end

    local function OrgImports(wait_ms)
        local params = vim.lsp.util.make_range_params()
        params.context = {
            only = { "source.organizeImports" }
        }
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
        for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
                if r.edit then
                    local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"

                    vim.lsp.util.apply_workspace_edit(r.edit, enc)
                else
                    vim.lsp.buf.execute_command(r.command)
                end
            end
        end
    end

    lsp_handlers()

    local updated_capabilities = vim.lsp.protocol.make_client_capabilities()
    -- local function capabilities()
    --     local caps = vim.lsp.protocol.make_client_capabilities()
    --     return caps
    --     -- caps.textDocument.foldingRange = {
    --     --     dynamicRegistration = false,
    --     --     lineFoldingOnly = true,
    --     -- }
    --     -- return require("cmp_nvim_lsp").default_capabilities(caps)
    -- end

    vim.g.completion_trigger_on_delete = 1
    vim.g.lsp_document_highlight_enabled = 1

    local function custom_attach(client, bufnr)
        local caps = client.server_capabilities

        -- Show diagnostic on hover
        vim.api.nvim_create_autocmd("CursorHold", {
            callback = function()
                vim.diagnostic.get()
            end
        })

        vim.api.nvim_create_autocmd("LspDetach", {
            callback = function(_)
                if caps.completionProvider then
                    vim.cmd("setlocal tagfunc< omnifunc<")
                end
            end
        })

        if caps.completionProvider then
            vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
        end

        if caps.definitionProvider then
            vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
        end

        if client.server_capabilities.documentSymbolProvider then
            local navic_present, navic = pcall(require, "nvim-navic")
            if navic_present then
                navic.attach(client, bufnr)
            end
        end

        -- if caps.codeActionProvider ~= nil and utils.has_value(caps.codeActionProvider.codeActionKinds, "source.organizeImports") and caps.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
            callback = function()
                -- vim.lsp.buf.code_action { context = { only = { 'source.organizeImports' } }, apply = true, async = false }
                OrgImports(1000)
                vim.lsp.buf.format {
                    async = false
                }
            end
        })
        -- elseif caps.documentFormattingProvider then
        --     vim.api.nvim_create_autocmd("BufWritePre", {
        --         callback = function()
        --             vim.lsp.buf.format {
        --                 async = false
        --             }
        --         end
        --     })
        -- elseif caps.codeActionProvider ~= nil and
        --     utils.has_value(caps.codeActionProvider.codeActionKinds, "source.organizeImports") then
        --     vim.api.nvim_create_autocmd("BufWritePre", {
        --         callback = function()
        --             OrgImports(1000)
        --             -- vim.lsp.buf.code_action { context = { only = { 'source.organizeImports' } }, apply = true }
        --         end
        --     })
        -- end

        if caps.codeActionProvider ~= nil and utils.has_value(caps.codeActionProvider.codeActionKinds, "source.organizeImports") and caps.documentFormattingProvider then
            vim.api.nvim_create_autocmd("BufWritePre", {
                callback = function()
                    -- vim.lsp.buf.code_action { context = { only = { 'source.organizeImports' } }, apply = true, async = false }
                    OrgImports(1000)
                    vim.lsp.buf.format {
                        async = false
                    }
                end
            })
        elseif caps.documentFormattingProvider then
            vim.api.nvim_create_autocmd("BufWritePre", {
                callback = function()
                    vim.lsp.buf.format {
                        async = false
                    }
                end
            })
        elseif caps.codeActionProvider ~= nil and
            utils.has_value(caps.codeActionProvider.codeActionKinds, "source.organizeImports") then
            vim.api.nvim_create_autocmd("BufWritePre", {
                callback = function()
                    OrgImports(1000)
                    -- vim.lsp.buf.code_action { context = { only = { 'source.organizeImports' } }, apply = true }
                end
            })
        end

        if caps.documentHighlightProvider then
            vim.api.nvim_create_augroup("lsp_document_highlight", {
                clear = true
            })
            vim.api.nvim_clear_autocmds {
                buffer = bufnr,
                group = "lsp_document_highlight"
            }
            vim.api.nvim_create_autocmd("CursorHold", {
                callback = vim.lsp.buf.document_highlight,
                buffer = bufnr,
                group = "lsp_document_highlight",
                desc = "Document Highlight"
            })
            vim.api.nvim_create_autocmd("CursorMoved", {
                callback = vim.lsp.buf.clear_references,
                buffer = bufnr,
                group = "lsp_document_highlight",
                desc = "Clear All the References"
            })
        end

        local opts = {
            buffer = bufnr
        }

        if caps.hoverProvider then
            map('n', 'K', vim.lsp.buf.hover, opts)
        end

        if caps.definitionProvider then
            map('n', 'gd', vim.lsp.buf.definition, opts)
        end

        if caps.typeDefinitionProvider then
            map('n', 'gT', vim.lsp.buf.type_definition, opts)
        end

        if caps.documentSymbolProvider then
            map('n', 'gs', vim.lsp.buf.document_symbol, opts)
        end

        if caps.workspaceSymbolProvider then
            map('n', 'gS', vim.lsp.buf.workspace_symbol, opts)
        end

        if caps.codeActionProvider ~= nil then
            map('n', 'ga', vim.lsp.buf.code_action, opts)
        end

        if caps.renameProvider then
            map('n', 'gr', vim.lsp.buf.rename, opts)
        end

        map('n', 'gD', vim.lsp.buf.declaration, opts)

        if caps.implementationProvider then
            map('n', 'gi', function()
                local params = vim.lsp.util.make_position_params()

                vim.lsp.buf_request(0, "textDocument/implementation", params, function(err, result, ctx, config)
                    if result == nil then
                        return
                    end

                    local bufnr = ctx.bufnr
                    local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")

                    -- In go code, I do not like to see any mocks for impls
                    if ft == "go" then
                        local new_result = vim.tbl_filter(function(v)
                            return not string.find(v.uri, "mock_")
                        end, result)

                        if #new_result > 0 then
                            result = new_result
                        end
                    end

                    vim.lsp.handlers["textDocument/implementation"](err, result, ctx, config)
                    vim.cmd [[normal! zz]]
                end)
            end, opts)
        end

        if caps.callHierarchyProvider then
            map('n', 'gI', vim.lsp.buf.incoming_calls, opts)
            map('n', 'gO', vim.lsp.buf.outgoing_calls, opts)
        end

        local severity_levels = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
            vim.diagnostic.severity.INFO,
            vim.diagnostic.severity.HINT,
        }

        local get_highest_error_severity = function()
            for _, level in ipairs(severity_levels) do
                local diags = vim.diagnostic.get(0, { severity = { min = level } })
                if #diags > 0 then
                    return level, diags
                end
            end
        end

        -- map('n', '<Leader>ds', vim.diagnostic.get)
        -- map('n', '<Leader>sl', vim.diagnostic.open_float {
        --     scope = "line",
        -- })

        -- map('n', '<Leader>dn', vim.diagnostic.goto_next {
        --     severity = get_highest_error_severity(),
        --     wrap = true,
        --     float = true,
        -- })

        -- map('n', '<Leader>dp', vim.diagnostic.goto_prev {
        --     severity = get_highest_error_severity(),
        --     wrap = true,
        --     float = true,
        -- })

        -- map('n', '<Leader>fe', function() require("telescope.functions").diagnostics() end)

        -- client.server_capabilities.document_formatting = true
        -- client.server_capabilities.document_range_formatting = true
    end

    vim.fn.sign_define("LspDiagnosticsSignError", {
        text = "",
        texthl = "LspDiagnosticsSignError"
    })
    vim.fn.sign_define("LspDiagnosticsSignWarning", {
        text = "",
        texthl = "LspDiagnosticsSignWarning"
    })
    vim.fn.sign_define("LspDiagnosticsSignInformation", {
        text = "i",
        texthl = "LspDiagnosticsSignInformation"
    })
    vim.fn.sign_define("LspDiagnosticsSignHint", {
        text = "!",
        texthl = "LspDiagnosticsSignHint"
    })

    -- local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

    -- capabilities.textDocument.completion.completionItem = {
    --     documentationFormat = { "markdown", "plaintext" },
    --     snippetSupport = true,
    --     preselectSupport = true,
    --     insertReplaceSupport = true,
    --     labelDetailsSupport = true,
    --     deprecatedSupport = true,
    --     commitCharactersSupport = true,
    --     tagSupport = { valueSet = { 1 } },
    --     resolveSupport = {
    --         properties = {
    --             "documentation",
    --             "detail",
    --             "additionalTextEdits",
    --         },
    --     },
    -- }

    -- capabilities.textDocument.codeAction = {
    --     dynamicRegistration = true,
    --     codeActionLiteralSupport = {
    --         codeActionKind = {
    --             valueSet = (function()
    --                 local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
    --                 table.sort(res)
    --                 return res
    --             end)()
    --         }
    --     }
    -- }

    vim.lsp.handlers["textDocument/declaration"] = require "lsputil.locations".declaration_handler

    -- vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    --   require("lsp_extensions.workspace.diagnostic").handler, {
    --     virtual_text = true,
    --     signs = true,
    --     underline = true,
    --     update_in_insert = false,
    --   }
    -- )

    local servers = {
        bashls = {},
        -- hls = {},
        -- tsserver = {},
        -- html = {},
        -- yamlls = {},
        -- cssls = {},
        pylsp = {},
        -- clangd = {},
        -- java_language_server = {},
        -- solc = {
        --     solc = {
        --         cmd = { "solc", "--lsp" },
        --         filetypes = { "solidity" },
        --         root_dir = util.root_pattern(".git")
        --     }
        -- },
        csharp_ls = {
            csharp_ls = {}
        }
    }

    -- lspconfig.sqls.setup {
    --     on_attach = function(client, bufnr)
    --         -- custom_attach(client, bufnr)
    --         local sqls = require('sqls')
    --         sqls.on_attach(client, bufnr)
    --         map('n', 'qq', ':SqlsExecuteQuery<CR>', {
    --             buffer = bufnr
    --         })
    --     end,
    --     capabilities = updated_capabilities,
    --     settings = {
    --         sqls = {
    --             connections = { {
    --                 driver = 'mssql',
    --                 dataSourceName =
    --                 'Data Source=localhost; Initial Catalog=test_v2; User ID=sa; Password=Winter2019; Max Pool size=1000; Connection Timeout=30'
    --             } }
    --         }
    --     }
    -- }

    lspconfig.golangci_lint_ls.setup {
        on_attach = custom_attach,
        capabilities = updated_capabilities,
        command = { "golangci-lint", "run", "--enable-all", "--disable", "lll", "--out-format", "json",
            "--issues-exit-code=1" }
    }

    lspconfig.gopls.setup {
        on_attach = custom_attach,
        capabilities = updated_capabilities,
        settings = {
            gopls = {
                hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true
                },
                analyses = {
                    unusedparams = true,
                    shadow = true,
                    unreachable = true,
                    assign = true,
                    fieldalignment = true,
                    nilness = true,
                    useany = true,
                    unusedwrite = true,
                    unusedvariable = true
                },
                staticcheck = true,
                vulncheck = "Imports",
                gofumpt = true
            }
        }
    }

    lspconfig.tsserver.setup {
        on_attach = custom_attach,
        capabilities = updated_capabilities,
        filetypes = { "typescriptreact", "typescript" },
    }

    for lsp, settings in pairs(servers) do
        lspconfig[lsp].setup {
            on_attach = custom_attach,
            -- filetypes = opts.filetypes,
            capabilities = updated_capabilities,
            settings = settings,
            flags = {
                debounce_text_changes = 200
            }
        }
    end

    -- local rt = require("rust-tools")
    --
    -- rt.setup({
    --     server = {
    --         capabilities = updated_capabilities,
    --         on_attach = custom_attach,
    --         settings = {
    --             cargo = {
    --                 autoReload = true,
    --             },
    --         },
    --         -- on_attach = function(_, bufnr)
    --         --     -- Hover actions
    --         --     vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
    --         --     -- Code action groups
    --         --     vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    --         -- end,
    --     },
    -- })
    lspconfig.rust_analyzer.setup {
        capabilities = updated_capabilities,
        on_attach = custom_attach,
        settings = {
            checkOnSave = {
                command = "clippy"
            },
            flags = {
                debounce_text_changes = 200
            }
        }
    }

    lspconfig.csharp_ls.setup {
        cmd = { "csharp-ls" },
        on_attach = custom_attach,
        filetypes = { "cs" }
    }

    -- lspconfig.terraformls.setup {}

    lspconfig.lua_ls.setup {
        on_attach = custom_attach,
        capabilities = updated_capabilities,

        settings = {
            Lua = {
                runtime = {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = 'LuaJIT'
                },
                diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = { 'vim' }
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = vim.api.nvim_get_runtime_file("", true)
                },
                -- Do not send telemetry data containing a randomized but unique identifier
                telemetry = {
                    enable = false
                }
            }
        }
    }
end


return {
    {
        "neovim/nvim-lspconfig",
        dependencies = "nvim-lua/plenary.nvim",
        config = config
    },
    {
        "ray-x/lsp_signature.nvim",
        config = function()
            require("lsp_signature").setup {
                bind = true,
                doc_lines = 0,
                floating_window = true,
                fix_pos = true,
                hint_enable = true,
                hint_prefix = " ",
                hint_scheme = "String",
                hi_parameter = "Search",
                max_height = 22,
                max_width = 120,       -- max_width of signature floating_window, line will be wrapped if exceed max_width
                handler_opts = {
                    border = "single", -- double, single, shadow, none
                },
                zindex = 200,          -- by default it will be on top of all floating windows, set to 50 send it to bottom
                padding = "",          -- character to pad on left and right of signature can be ' ', or '|'  etc
            }
        end,
    },
    {
        "onsails/lspkind-nvim",
        opt = false,
        config = function()
            local lspkind = require "lspkind"

            local options = {
                mode = 'symbol',
                preset = 'default',
            }

            lspkind.init(options)
        end,
    },
    {
        -- Autopair brackets and other symbols
        "windwp/nvim-autopairs",
        -- after = "nvim-cmp",
        config = function()
            local present1, autopairs = pcall(require, "nvim-autopairs")
            local present2, cmp = pcall(require, "cmp")

            if not present1 and present2 then
                return
            end

            autopairs.setup {
                fast_wrap = {},
                disable_filetype = { "TelescopePrompt", "vim" },
            }

            local cmp_autopairs = require "nvim-autopairs.completion.cmp"

            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end
    },
    {
        "simrat39/rust-tools.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        config = function()
        end,
    },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim",
            "rouge8/neotest-rust",
            "nvim-neotest/neotest-vim-test",
            "nvim-neotest/neotest-go",
        },
        config = function()
            require("neotest").setup({
                status = {
                    enabled = true,
                    signs = true,
                    virtual_text = false,
                },
                adapters = {
                    require("neotest-rust"),
                    require("neotest-go"),
                    require("neotest-vim-test")({
                        ignore_file_types = { "python", "vim", "lua" },
                    }),
                },
            })
        end,
    }
}
