local present, cmp = pcall(require, "cmp")

if not present then
    return
end

local function border(hl_name)
    return {
        { "╭", hl_name },
        { "─", hl_name },
        { "╮", hl_name },
        { "│", hl_name },
        { "╯", hl_name },
        { "─", hl_name },
        { "╰", hl_name },
        { "│", hl_name },
    }
end

local cmp_window = require "cmp.utils.window"

function cmp_window:has_scrollbar()
    return false
end

local kind_present, lspkind = pcall(require, "lspkind")
if not kind_present then
    return false
end

local options = {
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    snippet = {
        expand = function(args)
            local snip_present, luasnip = pcall(require, "luasnip")
            if not snip_present then
                print("cmp: luasnip not found")
            end

            luasnip.lsp_expand(args.body)
        end,
    },
    formatting = {
        format = lspkind.cmp_format({
            maxwidth = 50,
        }),
    },
    mapping = {
        -- ["<C-d>"] = cmp.mapping.scroll_docs(-4), -- TODO cosi o come sotto
        -- ["<C-f>"] = cmp.mapping.scroll_docs(4),
        -- ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),

        ["<C-y>"] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
        },
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        -- ["<C-e>"] = cmp.mapping.close(), -- TJ
        ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    },
    sources = {
        -- { name = "gh_issues" },
        { name = "nvim_lua" },
        { name = "nvim_lsp" },
        { name = "path" },
        -- { name = "luasnip" },
        -- { name = "cmdline" },
        -- { name = "buffer", keyword_length = 3 },
    },
    experimental = { -- TODO
        native_menu = false,
        ghost_text = true,
    }
}

-- vim.cmd [[
--     augroup DadbodSql
--     au!
--     autocmd FileType sql,mysql,plsql lua require('cmp').setup_buffer { sources = { { name = 'vim-dadbod-completion' } } }
--     augroup END
-- ]]

cmp.setup(options)
