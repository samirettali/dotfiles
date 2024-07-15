return {
    {
        'rmagatti/auto-session',
        dependencies = {
            'nvim-telescope/telescope.nvim',
        },
        config = function()
            local config = {
                auto_session_enable_last_session = true,
                auto_save_enabled = true,
                auto_restore_enabled = true,
            }

            require('auto-session').setup(config)
        end,
    },
}
