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

-- The plugin registers the server as `roslyn` and enables it from its own
-- plugin/ file, so this extends that config.
--
-- The path is spelled out because the login shell puts `~/.dotnet/tools` in
-- PATH with the tilde unexpanded, and the plugin finds the binary with
-- vim.fn.executable(). The symlink survives `dotnet tool update`.
local roslyn_bin = vim.fn.expand("~/.dotnet/tools/roslyn-language-server")

vim.lsp.config("roslyn", {
	-- Same arguments the plugin passes in lsp/roslyn.lua, with the binary
	-- spelled out: assigning `cmd` replaces that list instead of merging it.
	cmd = {
		roslyn_bin,
		"--stdio",
		"--daemon-mode",
		"--clientProcessId",
		tostring(vim.uv.os_getpid()),
	},
	cmd_env = {
		Configuration = vim.env.Configuration or "Debug",
		-- Roslyn writes decompiled sources under TMPDIR, which macOS points at
		-- through a symlink. Resolving it keeps go-to-definition working there.
		TMPDIR = vim.env.TMPDIR and vim.fn.resolve(vim.env.TMPDIR) or nil,
	},
	-- Roslyn expects utf-8 positions.
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
