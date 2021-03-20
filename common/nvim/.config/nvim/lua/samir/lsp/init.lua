-- local completion = require('completion')
local lspconfig = require('lspconfig')
local saga = require('lspsaga')
saga.init_lsp_saga()

--[[ vim.g.completion_trigger_on_delete = 1
vim.g.completion_enable_snippet = 'vim-vsnip'
 ]]
-- vim.lsp.handlers['textDocument/codeAction'] = require'lsputil.codeAction'.code_action_handler
-- vim.lsp.handlers['textDocument/references'] = require'lsputil.locations'.references_handler
-- vim.lsp.handlers['textDocument/definition'] = require'lsputil.locations'.definition_handler
-- vim.lsp.handlers['textDocument/declaration'] = require'lsputil.locations'.declaration_handler
-- vim.lsp.handlers['textDocument/typeDefinition'] = require'lsputil.locations'.typeDefinition_handler
-- vim.lsp.handlers['textDocument/implementation'] = require'lsputil.locations'.implementation_handler
-- vim.lsp.handlers['textDocument/documentSymbol'] = require'lsputil.symbols'.document_handler
-- vim.lsp.handlers['workspace/symbol'] = require'lsputil.symbols'.workspace_handler
--
do
  local method = "textDocument/publishDiagnostics"
  local default_handler = vim.lsp.handlers[method]
  vim.lsp.handlers[method] = function(err, method, result, client_id, bufnr, config)
    default_handler(err, method, result, client_id, bufnr, config)
    local diagnostics = vim.lsp.diagnostic.get_all()
    local qflist = {}
    for bufnr, diagnostic in pairs(diagnostics) do
      for _, d in ipairs(diagnostic) do
        d.bufnr = bufnr
        d.lnum = d.range.start.line + 1
        d.col = d.range.start.character + 1
        d.text = d.message
        table.insert(qflist, d)
      end
    end
    vim.lsp.util.set_qflist(qflist)
  end
end

local function custom_attach(client)
  -- completion.on_attach(client)
  -- map('n', 'gd',         '<cmd>lua vim.lsp.buf.type_definition()<CR>')
  map('n', 'gD',         '<cmd>lua vim.lsp.buf.declaration()<CR>')

  map('n', 'gi',         '<cmd>lua vim.lsp.buf.implementation()<CR>')
  -- map('n', 'gr',         '<cmd>lua vim.lsp.buf.references()<CR>')
  map('n', 'gR',         '<cmd>lua require("telescope.builtin").lsp_references()<CR>')
  map('n', 'dn',         '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
  map('n', 'dp',         '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
  map('n', 'ds',         '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
  map('n', '<Leader>gw', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
  map('n', '<Leader>gW', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
  map('n', '<Leader>=',  '<cmd>lua vim.lsp.buf.formatting()<CR>')
  map('n', 'gu',         '<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
  map('n', '<Leader>ao', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')
  map('n', '<Leader>fe', '<cmd>lua require("telescope.functions").show_diagnostics()<CR>')

  --[[ map('n', 'gd',         '<cmd>lua vim.lsp.buf.definition()<CR>')
  map('n', 'gr',         '<cmd>lua vim.lsp.buf.rename()<CR>')
  map('n', 'gh',         '<cmd>lua vim.lsp.buf.signature_help()<CR>')
  map('n', 'ds',         '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
  map('n', 'K',          '<cmd>lua vim.lsp.buf.hover()<CR>')
  map('n', 'ga',         '<cmd>lua vim.lsp.buf.code_action()<CR>')
 ]]


  map('n', 'cd', '<cmd>lua require("lspsaga.diagnostic").show_line_diagnostics()<CR>')
  map('n', 'ga', '<cmd>lua require("lspsaga.codeaction").code_action()<CR>')
  map('n', 'gs', '<cmd>lua require("lspsaga.signaturehelp").signature_help()<CR>')
  map('n', 'rn', '<cmd>lua require("lspsaga.rename").rename()<CR>')
  map('n', 'gr', '<cmd>lua require("lspsaga.provider").lsp_finder()<CR>', { silent = true })
  map('n', 'gd', '<cmd>lua require("lspsaga.provider").preview_definition()<CR>')
  map('n', 'K',  '<cmd>lua require("lspsaga.hover").render_hover_doc()<CR>')
  map('n', '[e', '<cmd>lua require("lspsaga.diagnostic").lsp_jump_diagnostic_prev()<CR>')
  map('n', ']e', '<cmd>lua require("lspsaga.diagnostic").lsp_jump_diagnostic_next()<CR>')

  -- vim.cmd [[augroup lsp]]
  -- vim.cmd       [[au! BufWritePre <buffer> :lua vim.lsp.buf.formatting_sync()]]
  -- vim.cmd [[augroup END]]
  -- vim.cmd [[autocmd CursorHold <buffer> lua vim.lsp.diagnostic.show_line_diagnostics()]]

  vim.cmd("setlocal omnifunc=v:lua.vim.lsp.omnifunc")
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = false,
  }
)

vim.fn.sign_define("LspDiagnosticsSignError",
    {text = "", texthl = "LspDiagnosticsSignError"})
vim.fn.sign_define("LspDiagnosticsSignWarning",
    {text = "", texthl = "LspDiagnosticsSignWarning"})
vim.fn.sign_define("LspDiagnosticsSignInformation",
    {text = "i", texthl = "LspDiagnosticsSignInformation"})
vim.fn.sign_define("LspDiagnosticsSignHint",
    {text = "!", texthl = "LspDiagnosticsSignHint"})


--[[ vim.api.nvim_exec([[
  autocmd BufWritePre *.ts lua vim.lsp.buf.formatting_sync(nil, 100)
  autocmd BufWritePre *.tsx lua vim.lsp.buf.formatting_sync(nil, 100)

  autocmd BufWritePre *.js lua vim.lsp.buf.formatting_sync(nil, 100)
  autocmd BufWritePre *.jsx lua vim.lsp.buf.formatting_sync(nil, 100)

  " autocmd BufWritePre *.css lua vim.lsp.buf.formatting_sync(nil, 100)
  " autocmd BufWritePre *.less lua vim.lsp.buf.formatting_sync(nil, 100)
  " autocmd BufWritePre *.scss lua vim.lsp.buf.formatting_sync(nil, 100)
, false) --]]

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

--[[ 'clangd',
  'cssls',
  'jdtls',
  'pyls',
  'rls',
]]

-- cssls = { filetypes = { 'css', 'less', 'scss' } },
local servers = {
  bashls = { filetypes = { 'bash' } },
  tsserver = {
    filetypes = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx'
    }
  },
  html = { filetypes = { 'html' } },
  gopls = { filetypes = { 'go' } },
  rls = { filetypes = { 'rust' } }
}

for lsp, opts in pairs(servers) do
  lspconfig[lsp].setup {
    -- root_dir = lspconfig.util.root_pattern('.git', vim.fn.getcwd()),
    on_attach = custom_attach,
    filetypes = opts.filetypes,
    capabilities = capabilities,
  }
end

lspconfig['cssls'].setup {
  on_attach = custom_attach,
  filetypes = { 'css', 'less', 'scss' },
  capabilities = capabilities,
  css = {
    validate = true,
  },
  scss = {
    validate = true,
  },
  less = {
    validate =true,
  },
}
