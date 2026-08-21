-- Changeset review for agent edits.
--
-- The agent proposes a group of edits over one or more files. You take the
-- group or leave it: adding a parameter to a signature without adding it to the
-- callers produces code that does not compile, so per-hunk choice would be a
-- foot-gun.
--
-- Nothing is written until you accept, and nothing is written to disk ever.
-- Accepting changes buffers; you save.
--
-- The proposal is drawn, not inserted. The lines that would go are real text
-- with a red background; the lines that would arrive are virtual, drawn by an
-- extmark, and exist nowhere in the file:
--
--    10   def fibonacci(n):                 <- real, marked as leaving
--         def fibonacci(n, cache=None):     <- virtual, marked as arriving
--    11       return n
--
-- Conflict markers in the buffer were the obvious way to do this, and they are
-- wrong: they are text, so they enter the undo history. One u would bring half
-- a changeset back, and since undo is per buffer while a changeset is not, a
-- three-file changeset came back one file at a time. Drawing instead of writing
-- removes that whole class of problem: during a review there is nothing to
-- undo, rejecting leaves no trace, the file is never syntactically broken so
-- diagnostics stay on, and the hunks follow your edits because extmarks move on
-- their own.

local M = {}

-- Anchors survive edits and say where a hunk went. The view is thrown away and
-- redrawn on every change.
local NS_ANCHOR = vim.api.nvim_create_namespace("shannon-changeset-anchors")
local NS_VIEW = vim.api.nvim_create_namespace("shannon-changeset-view")
local AUGROUP = vim.api.nvim_create_augroup("ShannonChangeset", { clear = true })

M.config = {
	mappings = {
		accept = "<leader>ca",
		reject = "<leader>cr",
		next = "]x",
		prev = "[x",
	},
	highlights = {
		leaving = "DiffDelete",
		arriving = "DiffAdd",
		label = "Comment",
	},
}

-- Open changesets by label.
local open = {}
local sequence = 0

-- Accepted changesets, for :ShannonUndo.
local applied = {}

-- Buffers whose keymaps are currently set.
local mapped = {}

local function buffers_of(changeset)
	local seen, list = {}, {}
	for _, hunk in ipairs(changeset.hunks) do
		if not seen[hunk.buf] and vim.api.nvim_buf_is_valid(hunk.buf) then
			seen[hunk.buf] = true
			table.insert(list, hunk.buf)
		end
	end
	return list
end

--- Where a hunk is now, or nil if you deleted the lines it was over.
--- @return integer|nil start_row, integer|nil end_row 0-indexed, end exclusive
local function span(hunk)
	if not vim.api.nvim_buf_is_valid(hunk.buf) then
		return nil
	end

	local mark = vim.api.nvim_buf_get_extmark_by_id(hunk.buf, NS_ANCHOR, hunk.anchor, { details = true })
	if #mark == 0 or (mark[3] and mark[3].invalid) then
		return nil
	end

	local details = mark[3] or {}
	return mark[1], details.end_row or mark[1]
end

--- The hunks of one changeset, or of all of them, that are still anchored.
local function hunks(label)
	local all = {}
	for open_label, changeset in pairs(open) do
		if not label or open_label == label then
			for _, hunk in ipairs(changeset.hunks) do
				local first, last = span(hunk)
				if first then
					table.insert(all, {
						hunk = hunk,
						label = open_label,
						buf = hunk.buf,
						first = first,
						last = last,
					})
				end
			end
		end
	end

	table.sort(all, function(a, b)
		if a.buf ~= b.buf then
			return a.buf < b.buf
		end
		return a.first < b.first
	end)

	return all
end

local function hunk_at_cursor()
	local buf = vim.api.nvim_get_current_buf()
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1

	for _, entry in ipairs(hunks()) do
		if entry.buf == buf and row >= entry.first and row <= math.max(entry.last - 1, entry.first) then
			return entry
		end
	end
	return nil
end

--- The changeset a command acts on: the one under the cursor, or the only one.
--- @return string|nil label, string|nil error
local function target(label)
	if label and label ~= "" then
		if not open[label] then
			return nil, string.format("shannon: no changeset named %q", label)
		end
		return label
	end

	local entry = hunk_at_cursor()
	if entry then
		return entry.label
	end

	local labels = vim.tbl_keys(open)
	if #labels == 1 then
		return labels[1]
	end
	if #labels == 0 then
		return nil, "shannon: no changeset open"
	end

	table.sort(labels)
	return nil, "shannon: put the cursor on a hunk, open: " .. table.concat(labels, ", ")
end

-- === presentation =========================================================

local function set_mappings(buf)
	local keys = M.config.mappings
	local function opts(desc)
		return { buffer = buf, silent = true, desc = "shannon changeset: " .. desc }
	end

	vim.keymap.set("n", keys.accept, function()
		M.accept()
	end, opts("accept the changeset"))
	vim.keymap.set("n", keys.reject, function()
		M.reject()
	end, opts("reject the changeset"))
	vim.keymap.set("n", keys.next, M.next, opts("next hunk"))
	vim.keymap.set("n", keys.prev, M.prev, opts("previous hunk"))
end

local function clear_mappings(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	for _, lhs in pairs(M.config.mappings) do
		pcall(vim.keymap.del, "n", lhs, { buffer = buf })
	end
end

--- Colours the proposed lines with the buffer's own treesitter parser. Virtual
--- text carries no syntax of its own, so without this the proposal is a slab of
--- one colour next to highlighted code.
--- @return table[] lines each a list of { text, { capture, background } } chunks
local function highlighted(lines, buf)
	local background = M.config.highlights.arriving

	local plain = {}
	for _, line in ipairs(lines) do
		table.insert(plain, { { line, background } })
	end

	local ok, lang = pcall(vim.treesitter.language.get_lang, vim.bo[buf].filetype)
	if not ok or not lang then
		return plain
	end

	local source = table.concat(lines, "\n")
	local parsed, parser = pcall(vim.treesitter.get_string_parser, source, lang)
	if not parsed or not parser then
		return plain
	end

	local query = vim.treesitter.query.get(lang, "highlights")
	local tree = parser:parse()[1]
	if not query or not tree then
		return plain
	end

	-- One capture per byte, last one wins, the way the highlighter resolves
	-- overlapping captures.
	local groups = {}
	for id, node in query:iter_captures(tree:root(), source) do
		local capture = "@" .. query.captures[id] .. "." .. lang
		local start_row, start_col, end_row, end_col = node:range()

		for row = start_row, math.min(end_row, #lines - 1) do
			local from = row == start_row and start_col or 0
			local to = row == end_row and end_col or #lines[row + 1]

			groups[row] = groups[row] or {}
			for col = from, to - 1 do
				groups[row][col] = capture
			end
		end
	end

	local coloured = {}
	for row, line in ipairs(lines) do
		local chunks = {}
		local column = 0

		while column < #line do
			local group = groups[row - 1] and groups[row - 1][column]
			local last = column
			while last < #line and (groups[row - 1] and groups[row - 1][last]) == group do
				last = last + 1
			end

			local text = line:sub(column + 1, last)
			table.insert(chunks, { text, group and { group, background } or background })
			column = last
		end

		if #chunks == 0 then
			chunks = { { "", background } }
		end
		table.insert(coloured, chunks)
	end

	return coloured
end

--- Width of the narrowest window showing the buffer, for padding the virtual
--- lines into a solid block.
local function width_of(buf)
	local width
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		local info = vim.fn.getwininfo(win)[1]
		local usable = info.width - info.textoff
		width = math.min(width or usable, usable)
	end
	return width or 100
end

local function draw(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return 0
	end

	vim.api.nvim_buf_clear_namespace(buf, NS_VIEW, 0, -1)

	local here = {}
	for _, entry in ipairs(hunks()) do
		if entry.buf == buf then
			table.insert(here, entry)
		end
	end

	local keys = M.config.mappings
	local hint = string.format("  %s accept  %s reject  %s/%s", keys.accept, keys.reject, keys.prev, keys.next)
	local cursor = hunk_at_cursor()
	local width = width_of(buf)

	local totals, index = {}, {}
	for _, entry in ipairs(hunks()) do
		totals[entry.label] = (totals[entry.label] or 0) + 1
	end

	for _, entry in ipairs(here) do
		index[entry.label] = (index[entry.label] or 0) + 1

		-- The lines that would go. An insertion takes none.
		if not entry.hunk.insertion and entry.last > entry.first then
			vim.api.nvim_buf_set_extmark(buf, NS_VIEW, entry.first, 0, {
				end_row = entry.last,
				end_col = 0,
				hl_group = M.config.highlights.leaving,
				hl_eol = true,
				priority = 100,
			})
		end

		-- The lines that would arrive, padded so the block has a straight edge.
		local virt_lines = {}
		for row, chunks in ipairs(highlighted(entry.hunk.incoming, buf)) do
			local padding = math.max(width - vim.fn.strdisplaywidth(entry.hunk.incoming[row]), 0)
			local line = vim.deepcopy(chunks)
			table.insert(line, { string.rep(" ", padding), M.config.highlights.arriving })
			table.insert(virt_lines, line)
		end

		local label = string.format("  %s (%d/%d)", entry.label, index[entry.label], totals[entry.label])
		if cursor and cursor.hunk == entry.hunk then
			label = label .. hint
		end

		vim.api.nvim_buf_set_extmark(buf, NS_VIEW, math.max(entry.last - 1, entry.first), 0, {
			virt_lines = virt_lines,
			virt_text = { { label, M.config.highlights.label } },
			virt_text_pos = "eol",
			priority = 100,
		})
	end

	if #here > 0 and not mapped[buf] then
		mapped[buf] = true
		set_mappings(buf)
	elseif #here == 0 and mapped[buf] then
		mapped[buf] = nil
		clear_mappings(buf)
	end

	return #here
end

--- Drops changesets that have no anchored hunk left, and redraws the rest.
local function refresh()
	for label, changeset in pairs(open) do
		if #hunks(label) == 0 then
			for _, buf in ipairs(buffers_of(changeset)) do
				draw(buf)
			end
			open[label] = nil
		end
	end

	local seen = {}
	for _, entry in ipairs(hunks()) do
		if not seen[entry.buf] then
			seen[entry.buf] = true
			draw(entry.buf)
		end
	end

	for buf in pairs(mapped) do
		if not seen[buf] then
			draw(buf)
		end
	end
end

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave", "BufEnter", "CursorMoved" }, {
	group = AUGROUP,
	callback = refresh,
})

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
	group = AUGROUP,
	callback = function(args)
		mapped[args.buf] = nil
		refresh()
	end,
})

-- === resolution ===========================================================

local function forget(label)
	local changeset = open[label]
	if not changeset then
		return {}
	end

	local touched = buffers_of(changeset)
	for _, hunk in ipairs(changeset.hunks) do
		if vim.api.nvim_buf_is_valid(hunk.buf) then
			pcall(vim.api.nvim_buf_del_extmark, hunk.buf, NS_ANCHOR, hunk.anchor)
		end
	end
	open[label] = nil
	return touched
end

function M.accept(label)
	local resolved, err = target(label)
	if not resolved then
		vim.api.nvim_echo({ { err, "WarningMsg" } }, false, {})
		return
	end

	local changeset = open[resolved]
	local entries = hunks(resolved)
	local lost = #changeset.hunks - #entries

	-- Bottom-up per buffer, so an earlier replacement does not move a later one.
	table.sort(entries, function(a, b)
		if a.buf ~= b.buf then
			return a.buf < b.buf
		end
		return a.first > b.first
	end)

	local record = { label = resolved, hunks = {} }

	for _, entry in ipairs(entries) do
		-- An insertion goes after the line it is anchored to, and replaces none.
		local first = entry.hunk.insertion and entry.last or entry.first
		local last = entry.hunk.insertion and entry.last or entry.last

		vim.api.nvim_buf_set_lines(entry.buf, first, last, false, entry.hunk.incoming)
		table.insert(record.hunks, {
			buf = entry.buf,
			row = first,
			original = entry.hunk.original,
			incoming = entry.hunk.incoming,
		})
	end

	local touched = forget(resolved)
	applied[resolved] = record

	for _, buf in ipairs(touched) do
		draw(buf)
	end

	local message = string.format("shannon: %s, %d hunks accepted, not saved", resolved, #entries)
	if lost > 0 then
		message = message .. string.format(", %d skipped (their lines are gone)", lost)
	end
	vim.api.nvim_echo({ { message, "Normal" } }, false, {})
end

function M.reject(label)
	local resolved, err = target(label)
	if not resolved then
		vim.api.nvim_echo({ { err, "WarningMsg" } }, false, {})
		return
	end

	local changeset = open[resolved]
	local count = #hunks(resolved)
	local opened = changeset.opened

	local touched = forget(resolved)

	for _, buf in ipairs(touched) do
		draw(buf)
	end

	-- Buffers loaded for this changeset hold nothing of yours and were never
	-- written to, so wiping them leaves the buffer list as it was.
	for _, buf in ipairs(opened) do
		if vim.api.nvim_buf_is_valid(buf) and not vim.bo[buf].modified then
			mapped[buf] = nil
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end

	vim.api.nvim_echo({ { string.format("shannon: %s, %d hunks rejected", resolved, count), "Normal" } }, false, {})
end

--- Puts back what an accepted changeset replaced, matching by content so that
--- edits elsewhere in the file do not get in the way.
function M.undo(label)
	local record = applied[label]
	if not record then
		local labels = vim.tbl_keys(applied)
		if #labels == 1 then
			record = applied[labels[1]]
		elseif #labels == 0 then
			vim.api.nvim_echo({ { "shannon: no changeset has been accepted", "WarningMsg" } }, false, {})
			return
		else
			table.sort(labels)
			local message = "shannon: which one? " .. table.concat(labels, ", ")
			vim.api.nvim_echo({ { message, "WarningMsg" } }, false, {})
			return
		end
	end

	local restored, skipped = 0, {}

	for _, hunk in ipairs(record.hunks) do
		if not vim.api.nvim_buf_is_valid(hunk.buf) then
			table.insert(skipped, "a closed buffer")
		else
			local lines = vim.api.nvim_buf_get_lines(hunk.buf, 0, -1, false)
			local needle = table.concat(hunk.incoming, "\n")
			local found = {}

			for row = 0, #lines - #hunk.incoming do
				local window = table.concat(vim.list_slice(lines, row + 1, row + #hunk.incoming), "\n")
				if window == needle then
					table.insert(found, row)
				end
			end

			if #found == 1 then
				vim.api.nvim_buf_set_lines(hunk.buf, found[1], found[1] + #hunk.incoming, false, hunk.original)
				restored = restored + 1
			else
				local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(hunk.buf), ":t")
				table.insert(skipped, #found == 0 and name .. " (the text is gone)" or name .. " (ambiguous)")
			end
		end
	end

	applied[record.label] = nil

	local message = string.format("shannon: %d hunks put back", restored)
	if #skipped > 0 then
		message = message .. ", skipped: " .. table.concat(skipped, ", ")
	end
	vim.api.nvim_echo({ { message, "Normal" } }, false, {})
end

-- === navigation ===========================================================

local function jump(entry)
	local windows = vim.fn.win_findbuf(entry.buf)
	if #windows > 0 then
		vim.api.nvim_set_current_win(windows[1])
	else
		vim.api.nvim_win_set_buf(0, entry.buf)
	end
	vim.api.nvim_win_set_cursor(0, { entry.first + 1, 0 })
	vim.cmd("normal! zz")
end

--- Walks the hunks of one changeset only: stepping into another changeset would
--- make accept act on something else.
local function step(offset)
	local here = hunk_at_cursor()
	local label = here and here.label

	if not label then
		local newest, best = nil, -1
		for open_label, changeset in pairs(open) do
			if changeset.sequence > best then
				newest, best = open_label, changeset.sequence
			end
		end
		label = newest
	end

	if not label then
		return
	end

	local all = hunks(label)
	if #all == 0 then
		return
	end

	local at = 0
	if here then
		for index, entry in ipairs(all) do
			if entry.hunk == here.hunk then
				at = index
			end
		end
	end

	jump(all[(at + offset - 1) % #all + 1])
end

function M.next()
	step(1)
end

function M.prev()
	step(-1)
end

function M.quickfix()
	local items = {}
	local counters = {}

	for _, entry in ipairs(hunks()) do
		counters[entry.label] = (counters[entry.label] or 0) + 1
		table.insert(items, {
			bufnr = entry.buf,
			lnum = entry.first + 1,
			col = 1,
			text = string.format("%s (%d)", entry.label, counters[entry.label]),
			valid = 1,
		})
	end

	vim.fn.setqflist({}, "r", { title = "Shannon changeset", items = items })
	return #items
end

function M.status()
	local labels = vim.tbl_keys(open)
	if #labels == 0 then
		return "shannon: no changeset open"
	end

	table.sort(labels)
	local parts = {}
	for _, label in ipairs(labels) do
		local entries = hunks(label)
		local seen, files = {}, 0
		for _, entry in ipairs(entries) do
			if not seen[entry.buf] then
				seen[entry.buf] = true
				files = files + 1
			end
		end
		table.insert(parts, string.format("%s: %d hunks in %d files", label, #entries, files))
	end
	return "shannon: " .. table.concat(parts, " | ")
end

function M.labels()
	local labels = vim.tbl_keys(open)
	table.sort(labels)
	return labels
end

-- === proposing ============================================================

--- Loads a file into a buffer without stealing a window.
local function buffer_for(file)
	local buf = vim.fn.bufnr(file)
	if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
		return buf, false
	end

	buf = vim.fn.bufadd(file)
	vim.fn.bufload(buf)
	vim.bo[buf].buflisted = true
	return buf, true
end

--- Turns an insertion into a replacement of nothing: an empty range after the
--- anchored line.
--- @return table|nil hunk, string|nil error
local function normalise(hunk, index)
	if type(hunk.file) ~= "string" then
		return nil, string.format("shannon: hunk %d has no file", index)
	end

	if type(hunk.after_line) == "number" then
		return {
			file = hunk.file,
			start_line = hunk.after_line + 1,
			end_line = hunk.after_line,
			original = {},
			incoming = hunk.incoming or {},
			anchor_line = hunk.after_line,
			anchor_text = hunk.anchor,
		}
	end

	if type(hunk.start_line) ~= "number" or type(hunk.end_line) ~= "number" then
		return nil, string.format("shannon: hunk %d has neither start_line/end_line nor after_line", index)
	end

	return {
		file = hunk.file,
		start_line = hunk.start_line,
		end_line = hunk.end_line,
		original = hunk.original or {},
		incoming = hunk.incoming or {},
	}
end

--- Proposes a changeset. A hunk either replaces lines:
---
---   { file = "/abs/a.py", start_line = 10, end_line = 12,
---     original = { "def fetch(url):", "    return url" },
---     incoming = { "def fetch(url, signal):", "    return url" } }
---
--- or inserts after a line, replacing nothing:
---
---   { file = "/abs/a.py", after_line = 7,
---     anchor = "def mat_mul(a, b):",
---     incoming = { "def transpose(m):", "    return list(zip(*m))" } }
---
--- after_line = 0 inserts at the top of the file. The description labels the
--- changeset, so it has to be unique among the open ones.
---
--- @return string status
function M.propose(spec)
	if type(spec) ~= "table" or type(spec.hunks) ~= "table" or #spec.hunks == 0 then
		return "shannon: changeset with no hunks"
	end

	local label = spec.description or "changeset"
	if open[label] then
		return string.format("shannon: %q is already open, use another description", label)
	end

	local prepared, opened = {}, {}

	local function give_up(message)
		for _, buffer in ipairs(opened) do
			pcall(vim.api.nvim_buf_delete, buffer, { force = true })
		end
		return message
	end

	for index, raw in ipairs(spec.hunks) do
		local hunk, err = normalise(raw, index)
		if not hunk then
			return give_up(err)
		end

		local buf, did_open = buffer_for(hunk.file)
		if did_open then
			table.insert(opened, buf)
		end

		-- Check before drawing anything: you may have typed since the agent read
		-- the buffer, and a hunk drawn over the wrong lines is a lie.
		local actual = vim.api.nvim_buf_get_lines(buf, hunk.start_line - 1, hunk.end_line, false)
		if table.concat(actual, "\n") ~= table.concat(hunk.original, "\n") then
			return give_up(
				string.format(
					"shannon: hunk %d does not match %s:%d-%d, the buffer has changed",
					index,
					hunk.file,
					hunk.start_line,
					hunk.end_line
				)
			)
		end

		-- An insertion has nothing to compare, so check the line it goes after.
		if hunk.anchor_text and hunk.anchor_line > 0 then
			local at = vim.api.nvim_buf_get_lines(buf, hunk.anchor_line - 1, hunk.anchor_line, false)[1]
			if at ~= hunk.anchor_text then
				return give_up(
					string.format(
						"shannon: hunk %d, line %d of %s is no longer %q but %q",
						index,
						hunk.anchor_line,
						hunk.file,
						hunk.anchor_text,
						at or ""
					)
				)
			end
		end

		table.insert(prepared, {
			buf = buf,
			first = hunk.start_line - 1,
			last = hunk.end_line,
			original = actual,
			incoming = hunk.incoming,
			anchor_line = hunk.anchor_line,
		})
	end

	local placed = {}
	for _, hunk in ipairs(prepared) do
		-- An insertion anchors to the line it follows, so that deleting that
		-- line takes the hunk with it.
		local first = hunk.anchor_line and math.max(hunk.anchor_line - 1, 0) or hunk.first
		local last = hunk.anchor_line and hunk.anchor_line or hunk.last

		local anchor = vim.api.nvim_buf_set_extmark(hunk.buf, NS_ANCHOR, first, 0, {
			end_row = math.max(last, first),
			end_col = 0,
			invalidate = true,
			undo_restore = true,
			-- Both ends shift right, so text typed above pushes the hunk down
			-- instead of ending up inside it.
			right_gravity = true,
			end_right_gravity = true,
		})

		table.insert(placed, {
			buf = hunk.buf,
			anchor = anchor,
			original = hunk.original,
			incoming = hunk.incoming,
			insertion = hunk.anchor_line ~= nil,
		})
	end

	sequence = sequence + 1
	open[label] = { hunks = placed, opened = opened, sequence = sequence }

	local seen, files = {}, 0
	for _, hunk in ipairs(placed) do
		if not seen[hunk.buf] then
			seen[hunk.buf] = true
			files = files + 1
			draw(hunk.buf)
		end
	end

	M.quickfix()

	return string.format("shannon: %d hunks in %d files, %s", #placed, files, label)
end

return M
