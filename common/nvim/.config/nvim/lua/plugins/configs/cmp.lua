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

local lspkind = require("lspkind")

local options = {
    -- window = {
    --     completion = { border = border "CmpBorder", },
    --     documentation = { border = border "CmpDocBorder", },
    -- },
    snippet = {
        expand = function(args)
            local present, luasnip = pcall(require, "luasnip")
            if not present then
                print("cmp: luasnip not found")
            end

            luasnip.lsp_expand(args.body)
        end,
    },
    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol_text', -- show only symbol annotations
            maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            menu = ({
                buffer = "[buf]",
                nvim_lsp = "[lsp]",
                luasnip = "[snip]",
                path = "[path]",
                nvim_lua = "[lua]",
                gh_issues = "[issues]",
            }),
            --
            -- -- The function below will be called before any actual modifications from lspkind
            -- -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            -- -- before = function (entry, vim_item)
            -- --  ...
            -- --   return vim_item
            -- -- end
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
    -- Completion sources. Ordering matters.
    -- Additional parameters: [priority, max_item_count]
    sources = {
        { name = "gh_issues" },
        { name = "nvim_lua" },
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "luasnip" },
        { name = "cmdline" },
        { name = "buffer", keyword_length = 3 },
    },
    experimental = { -- TODO
        native_menu = false,
        ghost_text = true,
    }
}

vim.cmd [[
    augroup DadbodSql
    au!
    autocmd FileType sql,mysql,plsql lua require('cmp').setup_buffer { sources = { { name = 'vim-dadbod-completion' } } }
    augroup END
]]

cmp.setup(options)

-- cmp.setup.cmdline("/", {
--     sources = {
--         { name = "buffer" }
--     }
-- })
--
-- cmp.setup.cmdline(":", {
--     sources = cmp.config.sources({
--         { name = "path" }
--     }, {
--         { name = "cmdline" }
--     })
-- })
