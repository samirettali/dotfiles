return {
    {
        -- Auto completion
        "hrsh7th/nvim-cmp",
        dependencies = {
            "onsails/lspkind-nvim",
        },
        config = function()
            local cmp = require "cmp"
            local cmp_window = require "cmp.utils.window"

            function cmp_window:has_scrollbar()
                return false
            end

            local lspkind = require "lspkind"

            local options = {
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered()
                },
                formatting = {
                    format = lspkind.cmp_format({
                        maxwidth = 50
                    }),
                    fields = {
                        cmp.ItemField.Kind,
                        cmp.ItemField.Abbr,
                        cmp.ItemField.Menu,
                    },
                },
                mapping = {
                    -- ["<C-d>"] = cmp.mapping.scroll_docs(-4), -- TODO cosi o come sotto
                    -- ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    -- ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
                    -- ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),

                    ["<C-y>"] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true
                    },
                    ["<C-n>"] = cmp.mapping.select_next_item({
                        behavior = cmp.SelectBehavior.Insert
                    }),
                    ["<C-p>"] = cmp.mapping.select_prev_item({
                        behavior = cmp.SelectBehavior.Insert
                    }),
                    -- ["<C-e>"] = cmp.mapping.close(), -- TJ
                    ["<C-e>"] = cmp.mapping({
                        i = cmp.mapping.abort(),
                        c = cmp.mapping.close()
                    }),
                    ["<CR>"] = cmp.mapping.confirm({
                        select = true
                    })
                },
                sources = {
                    { name = "nvim_lua" },
                    { name = "nvim_lsp" },
                    { name = "path" },
                    { name = "cmdline" },
                    { name = "buffer",  keyword_length = 3 },
                },
                experimental = {
                    -- TODO
                    native_menu = false,
                    ghost_text = true
                }
            }
            cmp.setup(options)
        end
    },
    { "hrsh7th/cmp-nvim-lua" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-cmdline" },
}