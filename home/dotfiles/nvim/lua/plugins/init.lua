require("plugins.snacks")
require("plugins.persistence")
require("plugins.quicker")
require("plugins.obsidian")
require("plugins.redraft")
require("plugins.dap")
require("plugins.actions-preview")
require("plugins.split")
require("plugins.codediff")
require("plugins.csvview")
require("plugins.fluoride")
require("plugins.pi")

vim.pack.add({
	"https://github.com/wincent/shannon",
})

require("wincent.shannon").setup()
