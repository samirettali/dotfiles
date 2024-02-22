function P(object)
    print(vim.inspect(object))
end

vim.loader.enable()

local function load_modules()
    local modules = {
        "core.options",
        "core.abbreviations",
        "core.autocmds",
        "core.statusline",
        "core.winbar",
        "core.mappings",
        "core.largefile",
        "plugins",
    }

    for _, module in ipairs(modules) do
        package.loaded[module] = nil
        local ok, err = pcall(require, module)
        if not ok then
            error("Error loading " .. module .. "\n\n" .. err)
        end
    end
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

load_modules()
