return {
    -- Highlights undo region
    "machakann/vim-highlightedundo",
    config = function()
        local map = require("core.utils").map

        map('n', 'u', '<Plug>(highlightedundo-undo)', { noremap = false })
        map('n', '<C-r>', '<Plug>(highlightedundo-redo)', { noremap = false })
        map('n', 'U', '<Plug>(highlightedundo-Undo)', { noremap = false })
        map('n', 'g-', '<Plug>(highlightedundo-gminus)', { noremap = false })
        map('n', 'g+', '<Plug>(highlightedundo-gplus)', { noremap = false })
    end
}