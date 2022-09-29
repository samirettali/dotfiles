local notify_present, notify = pcall(require, "notify")
if notify_present then
    vim.notify = notify
end

local impatient_present, impatient = pcall(require, 'impatient')

if impatient_present then
    impatient.enable_profile()
end

function P(object)
    print(vim.inspect(object))
end

function load_modules()
    local modules = {
        "core.options",
        "core.autocmds",
        "core.mappings",
        "plugins"
    }

    for _, module in ipairs(modules) do
        package.loaded[module] = nil
        local ok, err = pcall(require, module)
        if not ok then
            error("Error loading " .. module .. "\n\n" .. err)
        end
    end
end

load_modules()
