return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
    },
    config = function()
        local cmp = require("cmp")

        cmp.setup({
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered()
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-e>"] = cmp.mapping({
                    i = cmp.mapping.abort(),
                    c = cmp.mapping.close()
                }),
                ["<CR>"] = cmp.mapping.confirm({
                    select = false -- Only confirm explicitly selected items
                }),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<Tab>"] = cmp.config.disable,
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "path" },
                { name = "buffer",  keyword_length = 5 },
            }),
            experimental = {
                native_menu = false,
                ghost_text = true
            },
            -- formatting = {
            --     format = lspkind.cmp_format {
            --         with_text = true,
            --         menu = {
            --             buffer = "[buf]",
            --             nvim_lsp = "[lsp]",
            --             nvim_lua = "[api]",
            --             path = "[path]",
            --             luasnip = "[snip]",
            --         },
            --     },
            -- },
        })

        cmp.setup.filetype("lua", {
            sources = cmp.config.sources({
                { name = "nvim_lua" },
            }, {
                { name = "buffer" },
            })
        })
    end
}
