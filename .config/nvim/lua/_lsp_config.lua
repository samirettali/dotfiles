local completion = require('completion')
local lspconfig = require('lspconfig')

local map = function(mode, key, result)
  vim.api.nvim_buf_set_keymap(0, mode, key, result, {noremap = true, silent = true})
end

vim.lsp.handlers['textDocument/codeAction'] = require'lsputil.codeAction'.code_action_handler
vim.lsp.handlers['textDocument/references'] = require'lsputil.locations'.references_handler
vim.lsp.handlers['textDocument/definition'] = require'lsputil.locations'.definition_handler
vim.lsp.handlers['textDocument/declaration'] = require'lsputil.locations'.declaration_handler
vim.lsp.handlers['textDocument/typeDefinition'] = require'lsputil.locations'.typeDefinition_handler
vim.lsp.handlers['textDocument/implementation'] = require'lsputil.locations'.implementation_handler
vim.lsp.handlers['textDocument/documentSymbol'] = require'lsputil.symbols'.document_handler
vim.lsp.handlers['workspace/symbol'] = require'lsputil.symbols'.workspace_handler

local function custom_attach(client)
  completion.on_attach(client)

  map('n', 'gd',         '<cmd>lua vim.lsp.buf.definition()<CR>')
  map('n', 'gD',         '<cmd>lua vim.lsp.buf.declaration()<CR>')
  map('n', 'gi',         '<cmd>lua vim.lsp.buf.implementation()<CR>')
  map('n', 'gt',         '<cmd>lua vim.lsp.buf.type_definition()<CR>')
  map('n', 'gr',         '<cmd>lua vim.lsp.buf.rename()<CR>')
  map('n', 'gR',         '<cmd>lua vim.lsp.buf.references()<CR>')
  map('n', 'gh',         '<cmd>lua vim.lsp.buf.signature_help()<CR>')
  map('n', 'dn',         '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
  map('n', 'dp',         '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
  map('n', '<C-s>',      '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
  map('n', 'K',          '<cmd>lua vim.lsp.buf.hover()<CR>')
  map('n', '<Leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
  map('n', '<Leader>gw', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
  map('n', '<Leader>gW', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
  map('n', '<Leader>=',  '<cmd>lua vim.lsp.buf.formatting()<CR>')
  map('n', '<leader>ai', '<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
  map('n', '<leader>ao', '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')

  -- vim.cmd [[augroup lsp]]
  -- vim.cmd       [[au! BufWritePre <buffer> :lua vim.lsp.buf.formatting_sync()]]
  -- vim.cmd [[augroup END]]

  vim.cmd("setlocal omnifunc=v:lua.vim.lsp.omnifunc")
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    signs = true,
    update_in_insert = false,
  }
)

local servers = {
  'bashls',
  'clangd',
  'cssls',
  'gopls',
  'html',
  'jdtls',
  'pyls',
  'rls',
  'tsserver'
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = custom_attach,
  }
end
