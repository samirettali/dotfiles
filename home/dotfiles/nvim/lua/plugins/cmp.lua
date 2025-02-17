if true then
	return {}
end

return {
	"hrsh7th/nvim-cmp",
	lazy = false,
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
	},
	config = function()
		local cmp = require("cmp")

		cmp.setup({
			sources = cmp.config.sources({
				{ name = "luasnip" },
				{ name = "nvim_lsp" },
				{ name = "path" },
				{ name = "buffer", keyword_length = 5 },
			}),
			mapping = cmp.mapping.preset.insert({
				["<C-n>"] = cmp.mapping.select_next_item({
					behavior = cmp.SelectBehavior.Select,
				}),
				["<C-p>"] = cmp.mapping.select_prev_item({
					behavior = cmp.SelectBehavior.Select,
				}),
				["<C-e>"] = cmp.mapping({
					i = cmp.mapping.abort(),
					c = cmp.mapping.close(),
				}),
				["<C-y>"] = cmp.mapping.confirm({
					select = true,
				}),
				["<C-k>"] = cmp.mapping.scroll_docs(-4),
				["<C-j>"] = cmp.mapping.scroll_docs(4),
				["<Tab>"] = cmp.config.disable,
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			formatting = {
				format = function(entry, vim_item)
					vim_item.kind = string.format("%s", vim_item.kind)
					vim_item.menu = ({
						luasnip = "[snip]",
						buffer = "[buf]",
						nvim_lsp = "[lsp]",
						nvim_lua = "[lua]",
						path = "[path]",
					})[entry.source.name]

					local highlights_info = require("colorful-menu").cmp_highlights(entry)

					-- highlight_info is nil means we are missing the ts parser, it's
					-- better to fallback to use default `vim_item.abbr`. What this plugin
					-- offers is two fields: `vim_item.abbr_hl_group` and `vim_item.abbr`.
					if highlights_info ~= nil then
						vim_item.abbr_hl_group = highlights_info.highlights
						vim_item.abbr = highlights_info.text
					end

					return vim_item
				end,
			},
		})

		local ls = require("luasnip")
		ls.config.set_config({
			history = false,
			updateevents = "TextChanged,TextChangedI",
		})

		for _, ft_path in ipairs(vim.api.nvim_get_runtime_file("lua/plugins/snippets/*.lua", true)) do
			loadfile(ft_path)()
		end

		vim.keymap.set({ "i", "s" }, "<C-k>", function()
			if ls.expand_or_jumpable() then
				ls.expand_or_jump()
			end
		end, { silent = true })

		vim.keymap.set({ "i", "s" }, "<C-j>", function()
			if ls.jumpable(-1) then
				ls.jump(-1)
			end
		end, { silent = true })
	end,
}
