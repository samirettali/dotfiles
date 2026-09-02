---@brief
---
--- https://github.com/godotengine/godot
---
--- Language server for GDScript, served by the running Godot editor
--- (Editor Settings > Network > Language Server, port 6005).

---@type vim.lsp.Config
return {
	cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
	filetypes = { "gd", "gdscript", "gdscript3" },
	root_markers = { "project.godot", ".git" },
}
