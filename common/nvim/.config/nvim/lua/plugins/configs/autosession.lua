local present, autosession = pcall(require, "auto-session")

if not present then
    return false
end

local options = {
    auto_session_enabled = true,
    auto_restore_enabled = true,
    auto_session_enable_last_session=true,
    auto_session_suppress_dir = { "~/", "/tmp" }
}

autosession.setup(options)
