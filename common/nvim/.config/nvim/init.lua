local impatient_present, impatient = pcall(require, 'impatient')

if impatient_present then
    impatient.enable_profile()
end

function P(object)
    print(vim.inspect(object))
end

local function install_lazy()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable",
            lazypath
        })
    end
    vim.opt.rtp:prepend(lazypath)
end

local function load_modules()
    local modules = {
        "core.options",
        "core.autocmds",
        "core.winbar",
        "core.mappings",
        "core.statuscolumn",
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

install_lazy()
load_modules()
