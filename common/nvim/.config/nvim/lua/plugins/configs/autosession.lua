local present, autosession = pcall(require, "auto-session")

if not present then
    return false
end

local options = {
    auto_session_enabled = true,
    auto_restore_enabled = true,
    auto_session_enable_last_session = true,
    auto_session_suppress_dir = { "~/", "/tmp" },
    post_cwd_changed_hook = function() -- example refreshing the lualine status line _after_ the cwd changes
        local present_lualine, lualine = pcall(require, "lualine")
        if present_lualine and lualine ~= nil then
            lualine.refresh() -- refresh lualine so the new session name is displayed in the status bar
        end
    end,
}

autosession.setup(options)
