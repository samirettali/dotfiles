local present, gps = pcall(require, "nvim-gps")

if not present then
    return false
end

local options = {
  icons = {
    ["class-name"] = " ",
    ["function-name"] = "λ ",
    ["method-name"] = " "
  },
  languages = {
    ["c"] = true,
    ["cpp"] = true,
    ["go"] = true,
    ["java"] = true,
    ["javascript"] = true,
    ["lua"] = true,
    ["python"] = true,
    ["rust"] = true,
  },
  separator = " ➜ ",
}

gps.setup(options)
