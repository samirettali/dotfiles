local present, impatient = pcall(require, 'impatient')

if present then
    impatient.enable_profile()
end

local modules = {
   "core.options",
   "core.autocmds",
   "core.mappings",
   "plugins"
}

for _, module in ipairs(modules) do
   local ok, err = pcall(require, module)
   if not ok then
      error("Error loading " .. module .. "\n\n" .. err)
   end
end

function P(object)
    print(vim.inspect(object))
end
