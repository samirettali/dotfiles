local function config()
    local lspconfig = require("lspconfig")
    local utils = require("core.utils")

    -- Set borders for floating windows
    local border = {
        { "╭", "FloatBorder" },
        { "─", "FloatBorder" },
        { "╮", "FloatBorder" },
        { "│", "FloatBorder" },
        { "╯", "FloatBorder" },
        { "─", "FloatBorder" },
        { "╰", "FloatBorder" },
        { "│", "FloatBorder" },
    }

    local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or border
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
    end

    local function lspSymbol(name, icon)
        local hl = "DiagnosticSign" .. name
        vim.fn.sign_define(hl, {
            text = icon,
            numhl = hl,
            texthl = hl
        })
    end

    lspSymbol("Error", "")
    lspSymbol("Info", "")
    lspSymbol("Hint", "󱤅")
    lspSymbol("Warn", "")

    local augroup_lsp_user = vim.api.nvim_create_augroup("lsp_user", {})
    local augroup_completion = vim.api.nvim_create_augroup("lsp_completion", {})
    local augroup_highlight = vim.api.nvim_create_augroup("lsp_document_highlight", {})

    -- vim.keymap.set("n", "<leader>xq", vim.diagnostic.setqflist, { silent = true })

    vim.keymap.set("n", "<Leader>ti", function()
        vim.g.lsp_hints_enabled = not vim.g.lsp_hints_enabled
        vim.cmd [[doautocmd User lsp_toggle_inlays]]
    end)

    vim.api.nvim_create_autocmd("LspAttach", {
        group = augroup_lsp_user,
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client == nil then
                return
            end

            local bufnr = args.buf

            if client.server_capabilities.inlayHintProvider then
                vim.api.nvim_create_autocmd("User", {
                    pattern = "lsp_toggle_inlays",
                    callback = function()
                        vim.lsp.inlay_hint.enable(bufnr, vim.g.lsp_hints_enabled)
                    end
                })
            end

            local caps = client.server_capabilities

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

            local augroup_format = vim.api.nvim_create_augroup("CustomLspFormat", { clear = true })

            if caps.codeActionProvider ~= nil and utils.has_value(caps.codeActionProvider.codeActionKinds, "source.organizeImports") and caps.documentFormattingProvider then
                vim.api.nvim_clear_autocmds { buffer = 0, group = augroup_format }
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = 0,
                    callback = function()
                        local params = vim.lsp.util.make_range_params()
                        params.context = {
                            only = { "source.organizeImports" }
                        }
                        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
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
                        vim.lsp.buf.format {
                            async = false
                        }
                    end
                })
            elseif caps.documentFormattingProvider then
                vim.api.nvim_clear_autocmds { buffer = 0, group = augroup_format }
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = 0,
                    callback = function()
                        vim.lsp.buf.format {
                            async = false
                        }
                    end
                })
            elseif caps.codeActionProvider ~= nil and
                utils.has_value(caps.codeActionProvider.codeActionKinds, "source.organizeImports") then
                vim.api.nvim_clear_autocmds { buffer = 0, group = augroup_format }
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = 0,
                    callback = function()
                        vim.lsp.buf.code_action {
                            context = {
                                only = { 'source.organizeImports' }
                            },
                            apply = true,
                            async = false
                        }
                    end
                })
            end

            if caps.documentHighlightProvider then
                vim.api.nvim_clear_autocmds {
                    group = augroup_highlight,
                    buffer = 0,
                }

                vim.api.nvim_create_autocmd("CursorHold", {
                    group = augroup_highlight,
                    callback = vim.lsp.buf.document_highlight,
                    buffer = 0,
                })

                vim.api.nvim_create_autocmd("CursorMoved", {
                    group = augroup_highlight,
                    callback = vim.lsp.buf.clear_references,
                    buffer = 0,
                })
            end

            local opts = { buffer = bufnr, remap = false }

            if caps.hoverProvider then
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            end

            if caps.definitionProvider then
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            end

            if caps.declarationProvider then
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            end

            if caps.typeDefinitionProvider then
                vim.keymap.set('n', 'gT', vim.lsp.buf.type_definition, opts)
            end

            if caps.documentSymbolProvider then
                vim.keymap.set('n', 'gs', vim.lsp.buf.document_symbol, opts)
            end

            if caps.workspaceSymbolProvider then
                vim.keymap.set('n', 'gS', vim.lsp.buf.workspace_symbol, opts)
            end

            if caps.codeActionProvider ~= nil then
                vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, opts)
            end

            if caps.renameProvider then
                vim.keymap.set('n', 'gr', vim.lsp.buf.rename, opts)
            end

            if caps.implementationProvider then
                vim.keymap.set('n', 'gi', function()
                    local params = vim.lsp.util.make_position_params()

                    vim.lsp.buf_request(0, "textDocument/implementation", params, function(err, result, ctx, config)
                        if result == nil then
                            return
                        end

                        local ft = vim.api.nvim_buf_get_option(ctx.bufnr, "filetype")

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
                vim.keymap.set('n', 'gI', vim.lsp.buf.incoming_calls, opts)
                vim.keymap.set('n', 'gO', vim.lsp.buf.outgoing_calls, opts)
            end

            vim.keymap.set('n', 'ds', vim.diagnostic.open_float, opts)

            vim.keymap.set('n', ']d', function()
                vim.diagnostic.goto_next {
                    wrap = true,
                    float = true
                }
            end)

            vim.keymap.set('n', '[d', function()
                vim.diagnostic.goto_prev {
                    wrap = true,
                    float = true,
                }
            end)
        end
    })

    vim.api.nvim_create_autocmd("LspDetach", {
        group = augroup_completion,
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client == nil then
                return
            end
            if client.server_capabilities.completionProvider then
                vim.cmd("setlocal tagfunc< omnifunc<")
            end
        end
    })

    vim.diagnostic.config {
        virtual_text = {
            source = "if_many",
        },
        signs = false,
        underline = false,
        severity_sort = true,
        update_in_insert = false
    }

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Fix for cmp when not using a snipper engine
    capabilities.textDocument.completion.completionItem.snippetSupport = false

    lspconfig.golangci_lint_ls.setup {
        capabilities = capabilities,
        command = { "golangci-lint", "run", "--enable-all", "--disable", "lll", "--out-format", "json",
            "--issues-exit-code=1" }
    }

    lspconfig.gopls.setup {
        capabilities = capabilities,
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
        capabilities = capabilities,
        filetypes = { "typescriptreact", "typescript" }
    }

    lspconfig.rust_analyzer.setup {
        capabilities = capabilities,
        settings = {
            checkOnSave = {
                command = "clippy"
            },
            flags = {
                debounce_text_changes = 200
            }
        }
    }

    lspconfig.lua_ls.setup {
        capabilities = capabilities,
        settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT'
                },
                workspace = {
                    checkThirdParty = false,
                    library = { vim.env.VIMRUNTIME }
                },
                telemetry = {
                    enable = false
                },
                hint = {
                    enable = true,
                    arrayIndex = "enable",
                    setType = true
                }
            }
        }
    }

    lspconfig.rnix.setup {}

    lspconfig.csharp_ls.setup {}
    lspconfig.clangd.setup {}
end


return {
    {
        "neovim/nvim-lspconfig",
        config = config
    },
    {
        "ray-x/lsp_signature.nvim",
        config = function()
            require("lsp_signature").setup {}
        end
    },
    {
        -- Autopair brackets and other symbols
        "windwp/nvim-autopairs",
        dependencies = "hrsh7th/nvim-cmp",
        config = function()
            local autopairs = require("nvim-autopairs")
            local cmp = require("cmp")

            autopairs.setup {
                fast_wrap = {},
                disable_filetype = { "TelescopePrompt", "vim" },
            }

            local cmp_autopairs = require "nvim-autopairs.completion.cmp"

            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end
    }
}
