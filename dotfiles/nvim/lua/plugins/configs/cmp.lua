return {
    {
        "hrsh7th/nvim-cmp",
        config = function()
            local cmp = require "cmp"
            local cmp_window = require "cmp.utils.window"

            function cmp_window:has_scrollbar()
                return false
            end

            local options = {
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered()
                },
                mapping = {
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-n>"] = cmp.mapping.select_next_item({
                        behavior = cmp.SelectBehavior.Insert
                    }),
                    ["<C-p>"] = cmp.mapping.select_prev_item({
                        behavior = cmp.SelectBehavior.Insert
                    }),
                    ["<C-e>"] = cmp.mapping({
                        i = cmp.mapping.abort(),
                        c = cmp.mapping.close()
                    }),
                    ["<CR>"] = cmp.mapping.confirm({
                        select = true
                    }),
                    -- ["<C-y>"] = cmp.mapping.complete(),
                },
                sources = {
                    { name = "nvim_lua" },
                    { name = "nvim_lsp" },
                    { name = "path" },
                    -- { name = "cmdline" },
                    -- { name = "buffer",  keyword_length = 3 },
                },
                experimental = {
                    native_menu = false,
                    ghost_text = true
                }
            }

            cmp.setup(options)
        end
    },
    -- { "hrsh7th/cmp-nvim-lua" },
    { "hrsh7th/cmp-nvim-lsp" },
    -- { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    -- { "hrsh7th/cmp-cmdline" },
}
