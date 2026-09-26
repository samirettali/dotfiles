-- :make runs the tests. The built-in compiler only builds, and a failing test
-- reports an indented file:line, which its errorformat does not read.
vim.cmd.compiler("go")
vim.bo.makeprg = "go test -fullpath ./..."
vim.opt_local.errorformat:prepend("%\\s%#%f:%l: %m")
