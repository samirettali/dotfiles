local wezterm = require("wezterm");

---cycle through builtin dark schemes in dark mode,
---and through light schemes in light mode
local function themeCycler(window, _)
    local allSchemes = wezterm.color.get_builtin_schemes()
    local currentMode = wezterm.gui.get_appearance()
    local currentScheme = window:effective_config().color_scheme
    local darkSchemes = {}
    local lightSchemes = {}

    for name, scheme in pairs(allSchemes) do
        if scheme.background then
            local bg = wezterm.color.parse(scheme.background) -- parse into a color object
            ---@diagnostic disable-next-line: unused-local
            local h, s, l, a = bg:hsla()                      -- and extract HSLA information
            if l < 0.4 then
                table.insert(darkSchemes, name)
            else
                table.insert(lightSchemes, name)
            end
        end
    end
    local schemesToSearch = currentMode:find("Dark") and darkSchemes or lightSchemes

    for i = 1, #schemesToSearch, 1 do
        if schemesToSearch[i] == currentScheme then
            local overrides = window:get_config_overrides() or {}
            overrides.color_scheme = schemesToSearch[i + 1]
            wezterm.log_info("Switched to: " .. schemesToSearch[i + 1])
            window:set_config_overrides(overrides)
            return
        end
    end
end

return {
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Medium" }),
    font_size = 14.5,
    font_rules = {
        intensity = "Half",
    },
    freetype_load_target = "Light",
    enable_tab_bar = false,
    color_scheme = "Builtin Dark",
    keys = {
        { key = "t", mods = "ALT", action = wezterm.action_callback(themeCycler) },
    }
}
