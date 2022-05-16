local utils = require 'core.utils'
local map = utils.map
local colorizer = require('colorizer')

local options = {
    'css';
    'javascript';
    css = { css = true };
    html = { css = true };
}

colorizer.setup(options)

map('n', '<Leader>c', ':ColorizerToggle<CR>', { silent = true })
