local present, lspconfig = pcall(require, "lspconfig")

if not present then
    return false
end

local util = lspconfig.util

-- Borders for LspInfo winodw
local win = require "lspconfig.ui.windows"
local _default_opts = win.default_opts

win.default_opts = function(options)
    local opts = _default_opts(options)
    opts.border = "single"
    return opts
end

local lsp_handlers = function()
    local function lspSymbol(name, icon)
        local hl = "DiagnosticSign" .. name
        vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
    end

    lspSymbol("Error", "")
    lspSymbol("Info", "")
    lspSymbol("Hint", "")
    lspSymbol("Warn", "")

    vim.diagnostic.config {
        virtual_text = {
            prefix = "",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
    }

    -- local pop_opts = { border = "rounded", max_width = 80 }

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "single",
    })
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "single",
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

lsp_handlers()

vim.g.completion_trigger_on_delete = 1
vim.g.lsp_document_highlight_enabled = 1

local function custom_attach(client, bufnr)
    vim.cmd("setlocal omnifunc=v:lua.vim.lsp.omnifunc")

    -- Show diagnostic on hover
    vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
            vim.diagnostic.get()
        end,
    })

    -- Auto format
    vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function()
            vim.lsp.buf.format()
        end,
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
            OrgImports(1000)
        end,
    })

    client.server_capabilities.document_formatting = true
    client.server_capabilities.document_range_formatting = true

    if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
        vim.api.nvim_clear_autocmds { buffer = bufnr, group = "lsp_document_highlight" }
        vim.api.nvim_create_autocmd("CursorHold", {
            callback = vim.lsp.buf.document_highlight,
            buffer = bufnr,
            group = "lsp_document_highlight",
            desc = "Document Highlight",
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
            callback = vim.lsp.buf.clear_references,
            buffer = bufnr,
            group = "lsp_document_highlight",
            desc = "Clear All the References",
        })
    end
end

vim.fn.sign_define("LspDiagnosticsSignError", { text = "", texthl = "LspDiagnosticsSignError" })
vim.fn.sign_define("LspDiagnosticsSignWarning", { text = "", texthl = "LspDiagnosticsSignWarning" })
vim.fn.sign_define("LspDiagnosticsSignInformation", { text = "i", texthl = "LspDiagnosticsSignInformation" })
vim.fn.sign_define("LspDiagnosticsSignHint", { text = "!", texthl = "LspDiagnosticsSignHint" })

-- local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem = {
    documentationFormat = { "markdown", "plaintext" },
    snippetSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
        properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
        },
    },
}
capabilities.textDocument.codeAction = {
    dynamicRegistration = true,
    codeActionLiteralSupport = {
        codeActionKind = {
            valueSet = (function()
                local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
                table.sort(res)
                return res
            end)()
        }
    }
}

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
    hls = {},
    tsserver = {},
    html = {},
    yamlls = {},
    cssls = {},
    pylsp = {},
    sqls = {},
    clangd = {},
    java_language_server = {},
    gopls = {
        gopls = {
            analyses = {
                unusedparams = true,
                shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
        },
    },
    solc = {
        solc = {
            cmd = {
                "solc",
                "--lsp"
            },
            filetypes = {
                "solidity"
            },
            root_dir = util.root_pattern(".git"),
        }
    },
    csharp_ls = {
        csharp_ls = {
        }
    }
}

for lsp, settings in pairs(servers) do
    lspconfig[lsp].setup {
        on_attach = custom_attach,
        -- filetypes = opts.filetypes,
        capabilities = capabilities,
        settings = settings,
        flags = {
            debounce_text_changes = 200,
        },
    }
end

lspconfig.rust_analyzer.setup {
    capabilities = capabilities,
    on_attach = custom_attach,
    cmd = {
        "rustup", "run", "stable", "rust-analyzer",
    },
    settings = {
        assist = {
            importGranularity = "module",
            importPrefix = "by_self",
        },
        cargo = {
            loadOutDirsFromCheck = true
        },
        procMacro = {
            enable = true
        },
        checkOnSave = {
            command = "clippy",
        },
        flags = {
            debounce_text_changes = 200,
        },
    },
}

lspconfig.csharp_ls.setup {
    cmd = { "csharp-ls" },
    on_attach = custom_attach,
    filetypes = { "cs" },
}

function OrgImports(wait_ms)
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
    for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
            if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
            else
                vim.lsp.buf.execute_command(r.command)
            end
        end
    end
end

lspconfig.lua_ls.setup {
    on_attach = custom_attach,
    capabilities = capabilities,

    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}
