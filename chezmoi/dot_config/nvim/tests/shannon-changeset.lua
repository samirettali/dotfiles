-- Tests for lua/shannon/changeset.lua.
--
-- Run from this directory, or from anywhere:
--
--   nvim --headless -u NONE -l tests/shannon-changeset.lua
--
-- Exits non-zero if anything fails.

local here = debug.getinfo(1, "S").source:sub(2)
local lua = vim.fs.joinpath(vim.fs.dirname(vim.fs.dirname(here)), "lua")
package.path = lua .. "/?.lua;" .. package.path

local changeset = require("shannon.changeset")

local dir = vim.fs.joinpath(vim.fn.tempname(), "changeset")
vim.fn.mkdir(dir, "p")
local A = vim.fs.joinpath(dir, "a.py")
local B = vim.fs.joinpath(dir, "b.py")

local failures = 0

local function check(name, ok, detail)
	if ok then
		print("PASS " .. name)
	else
		failures = failures + 1
		print("FAIL " .. name .. (detail and (" -- " .. detail) or ""))
	end
end

local function reset()
	vim.cmd("silent! %bwipeout!")
	vim.fn.writefile({ "def fetch(url):", "    return url" }, A)
	vim.fn.writefile({ "from a import fetch", "", "def main():", "    return fetch('x')" }, B)
	vim.cmd.edit(A)
end

local function text(path)
	return table.concat(vim.api.nvim_buf_get_lines(vim.fn.bufnr(path), 0, -1, false), "\n")
end

--- The module reacts to buffer changes, which the API does not fire on its own.
local function changed()
	vim.api.nvim_exec_autocmds("TextChanged", { buffer = vim.api.nvim_get_current_buf() })
end

local function proposal()
	return {
		description = "signal parameter",
		hunks = {
			{
				file = A,
				start_line = 1,
				end_line = 1,
				original = { "def fetch(url):" },
				incoming = { "def fetch(url, signal):" },
			},
			{
				file = B,
				start_line = 4,
				end_line = 4,
				original = { "    return fetch('x')" },
				incoming = { "    return fetch('x', signal)" },
			},
		},
	}
end

local ORIGINAL_A = "def fetch(url):\n    return url"
local ORIGINAL_B = "from a import fetch\n\ndef main():\n    return fetch('x')"

-- === proposing leaves the buffers alone ===================================
reset()
check("propose reports the hunks", changeset.propose(proposal()):match("2 hunks in 2 files") ~= nil)
check("a.py untouched", text(A) == ORIGINAL_A, text(A))
check("b.py untouched", text(B) == ORIGINAL_B, text(B))
check("nothing to save", vim.bo[vim.fn.bufnr(A)].modified == false)

local has_virt = false
for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(vim.fn.bufnr(A), -1, 0, -1, { details = true })) do
	if mark[4] and mark[4].virt_lines then
		has_virt = true
	end
end
check("the proposed lines are virtual", has_virt)

-- === undo has nothing to undo during a review =============================
local before = vim.fn.undotree().seq_cur
vim.cmd("silent! undo")
check("undo leaves the review alone", text(A) == ORIGINAL_A, text(A))
check("undo history unchanged", vim.fn.undotree().seq_cur == before)
check("changeset still open", #changeset.labels() == 1)

-- === rejecting leaves no trace ============================================
changeset.reject()
check("a.py unchanged after reject", text(A) == ORIGINAL_A)
check("still nothing to save", vim.bo[vim.fn.bufnr(A)].modified == false)
check("no changeset left", #changeset.labels() == 0)

-- === accepting writes every file ==========================================
reset()
changeset.propose(proposal())
changeset.accept()
check("a.py accepted", text(A) == "def fetch(url, signal):\n    return url", text(A))
check("b.py accepted", text(B):match("fetch%('x', signal%)") ~= nil, text(B))
check("disk untouched", table.concat(vim.fn.readfile(A), "\n") == ORIGINAL_A)

-- === undoing a whole accepted changeset ===================================
changeset.undo("signal parameter")
check("a.py put back", text(A) == ORIGINAL_A, text(A))
check("b.py put back", text(B) == ORIGINAL_B, text(B))

-- === undo when a file moved on in the meantime ============================
reset()
changeset.propose(proposal())
changeset.accept()

vim.api.nvim_buf_set_lines(vim.fn.bufnr(B), 3, 4, false, { "    return fetch('x', signal, retries=3)" })

local messages = vim.fn.execute("lua require('shannon.changeset').undo('signal parameter')")
check("a.py put back anyway", text(A) == ORIGINAL_A, text(A))
check("b.py left alone", text(B):match("retries=3") ~= nil, text(B))
check("it names what it skipped", messages:match("skipped") ~= nil and messages:match("b%.py") ~= nil, messages)

-- === hunks follow your edits ==============================================
reset()
changeset.propose(proposal())
vim.api.nvim_buf_set_lines(vim.fn.bufnr(A), 0, 0, false, { "import sys", "" })
changed()
changeset.accept()
check("applied where the hunk moved to", text(A) == "import sys\n\ndef fetch(url, signal):\n    return url", text(A))

-- === deleting the lines of a hunk drops it ================================
reset()
changeset.propose(proposal())
vim.api.nvim_buf_set_lines(vim.fn.bufnr(A), 0, 1, false, {})
changed()
check("one hunk lost", changeset.status():match("1 hunks in 1 files") ~= nil, changeset.status())

changeset.accept()
check("only the surviving hunk applied", text(A) == "    return url", text(A))
check("b.py accepted all the same", text(B):match("fetch%('x', signal%)") ~= nil)

-- === insertion ============================================================
reset()
changeset.propose({
	description = "add transpose",
	hunks = {
		{
			file = A,
			after_line = 2,
			anchor = "    return url",
			incoming = { "", "", "def transpose(m):", "    return list(zip(*m))" },
		},
	},
})
check("insertion leaves the buffer alone", text(A) == ORIGINAL_A)
changeset.accept()
check(
	"inserted at the end",
	text(A) == "def fetch(url):\n    return url\n\n\ndef transpose(m):\n    return list(zip(*m))",
	text(A)
)

-- === two changesets at once ===============================================
reset()
changeset.propose(proposal())
changeset.propose({
	description = "docstring",
	hunks = {
		{ file = A, after_line = 1, anchor = "def fetch(url):", incoming = { '    """Fetch it."""' } },
	},
})
check("two open", #changeset.labels() == 2, table.concat(changeset.labels(), ", "))

changeset.accept("docstring")
check("only the docstring applied", text(A):match('"""Fetch it."""') ~= nil, text(A))
check("the other one stays open", #changeset.labels() == 1)
check("a.py has no signal yet", text(A):match("def fetch%(url%):") ~= nil, text(A))

changeset.accept("signal parameter")
check("then the other one too", text(A):match("def fetch%(url, signal%):") ~= nil, text(A))

print(failures == 0 and "\nALL TESTS PASSED" or ("\n" .. failures .. " TESTS FAILED"))
os.exit(failures == 0 and 0 or 1)
