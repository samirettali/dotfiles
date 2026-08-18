vim.pack.add({
	"https://github.com/seblyng/roslyn.nvim",
})

-- Plugin behaviour (root_dir detection, solution targeting, filewatching, ...)
require("roslyn").setup({
	-- "auto" | "roslyn" | "off" -- set to "roslyn" or "off" if filewatching is slow
	filewatching = "auto",
	broad_search = false,
	lock_target = false,
})

-- Language-server-specific settings sent to the server. The plugin registers the
-- server under the name `roslyn` (and enables it itself via its plugin/ file), so
-- we extend that config here instead of the old `lsp/roslyn_ls.lua`.
-- Point straight at the roslyn-language-server binary installed as a dotnet
-- global tool. This avoids depending on a correct shell PATH inside nvim (the
-- `~/.dotnet/tools` entry in the login shell has an unexpanded tilde, so the
-- server would otherwise not be found). The symlink is stable across tool
-- updates, so this keeps working after `dotnet tool update`.
local roslyn_bin = vim.fn.expand("~/.dotnet/tools/roslyn-language-server")

vim.lsp.config("roslyn", {
	cmd = { roslyn_bin, "--stdio" },
	-- Roslyn expects utf-8 positions; matches the previous working config.
	offset_encoding = "utf-8",
	settings = {
		["csharp|background_analysis"] = {
			-- NOTE: use openFiles instead of fullSolution if too slow
			dotnet_analyzer_diagnostics_scope = "fullSolution",
			dotnet_compiler_diagnostics_scope = "fullSolution",
		},
		["csharp|inlay_hints"] = {
			csharp_enable_inlay_hints_for_implicit_object_creation = true,
			csharp_enable_inlay_hints_for_implicit_variable_types = true,
			csharp_enable_inlay_hints_for_lambda_parameter_types = true,
			csharp_enable_inlay_hints_for_types = true,
			dotnet_enable_inlay_hints_for_indexer_parameters = true,
			dotnet_enable_inlay_hints_for_literal_parameters = true,
			dotnet_enable_inlay_hints_for_object_creation_parameters = true,
			dotnet_enable_inlay_hints_for_other_parameters = true,
			dotnet_enable_inlay_hints_for_parameters = true,
			dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
			dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
			dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
		},
		["csharp|symbol_search"] = {
			dotnet_search_reference_assemblies = true,
		},
		["csharp|completion"] = {
			dotnet_show_name_completion_suggestions = true,
			dotnet_show_completion_items_from_unimported_namespaces = true,
			dotnet_provide_regex_completions = true,
		},
		["csharp|code_lens"] = {
			dotnet_enable_references_code_lens = false,
		},
	},
})
