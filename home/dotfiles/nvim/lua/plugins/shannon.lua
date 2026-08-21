vim.pack.add({ "https://github.com/wincent/shannon" })

local config = {
	-- Agent process names, in priority order, for picking the target pane.
	agents = { "pi", "claude" },
	-- Prefix on the first line of an annotation, pointing at the line above.
	-- Set to "" for none; the trailing space is the gap before the text.
	marker = "⌃ ",
}

require("wincent.shannon").setup({ agents = config.agents })

-- Shannon delivers prompts through tmux: it reads TMUX_PANE, walks the process
-- tree to find the agent's pane, and pastes into it with load-buffer /
-- paste-buffer / send-keys. This machine runs herdr, so none of that resolves.
--
-- Replace the two tmux-bound halves of the private API. Sibling panes in herdr
-- share a tab_id, `herdr agent list` already knows which pane runs which agent,
-- and `herdr agent prompt` injects text verbatim -- so the tmpfile, the named
-- buffer and the bracketed-paste dance all disappear.
--
-- The prompt layout below mirrors wincent.shannon.private.send. Keep it in sync
-- if upstream changes the context line or the footer: the footer is what tells
-- the agent which Neovim server to talk back to.
local private = require("wincent.shannon.private")

local function herdr(args)
	local result = vim.system(vim.list_extend({ "herdr" }, args), { text = true }):wait()
	if result.code ~= 0 then
		return nil
	end
	local ok, decoded = pcall(vim.json.decode, result.stdout)
	if not ok or type(decoded) ~= "table" then
		return nil
	end
	return decoded.result
end

local function find_agent_pane()
	local self_pane = vim.env.HERDR_PANE_ID
	if not self_pane then
		return nil
	end

	local pane_info = herdr({ "pane", "get", self_pane })
	local tab_id = pane_info and pane_info.pane and pane_info.pane.tab_id
	if not tab_id then
		return nil
	end

	local agent_list = herdr({ "agent", "list" })
	if not agent_list then
		return nil
	end

	for _, name in ipairs(config.agents) do
		for _, agent in ipairs(agent_list.agents or {}) do
			if agent.agent == name and agent.tab_id == tab_id and agent.pane_id ~= self_pane then
				return agent.pane_id
			end
		end
	end

	return nil
end

local function location_for(context)
	if context.col_start and context.col_end then
		if context.line_start == context.line_end then
			return string.format("%s:%d:%d-%d", context.file, context.line_start, context.col_start, context.col_end)
		end
		return string.format(
			"%s:%d:%d-%d:%d",
			context.file,
			context.line_start,
			context.col_start,
			context.line_end,
			context.col_end
		)
	end
	if context.line_start == context.line_end then
		return string.format("%s:%d", context.file, context.line_start)
	end
	return string.format("%s:%d-%d", context.file, context.line_start, context.line_end)
end

-- The agent otherwise reads the file from disk, which is a different document
-- whenever there are unsaved changes, and does not exist at all for a new buffer.
local buffer_note = table.concat({
	"NOTE: this context comes from the Neovim buffer and may hold unsaved changes",
	"newer than the file on disk, which may not exist yet. Treat it as the source",
	"of truth, and read the buffer over RPC rather than the file if they disagree.",
}, " ")

local function context_block(context)
	local location = location_for(context)

	if not context.lines or #context.lines == 0 then
		return string.format("Context: %s", location)
	end
	if #context.lines == 1 then
		return string.format("Context: %s: %s", location, context.lines[1])
	end
	return string.format("Context: %s\n```\n%s\n```", location, table.concat(context.lines, "\n"))
end

local function send(context, text)
	local block = context_block(context)
	local footer = string.format("(Shannon prompt via Neovim server %s)", vim.v.servername)

	local prompt
	if text:match("^/btw") then
		-- A slash command has to come first, so the context follows it.
		prompt = string.format("%s\n\n%s\n\n%s\n\n%s", text, block, buffer_note, footer)
	else
		prompt = string.format("%s\n\n%s\n\n%s\n\n%s", block, text, buffer_note, footer)
	end

	local pane = find_agent_pane()
	if not pane then
		vim.api.nvim_err_writeln(
			"shannon: no agent session (" .. table.concat(config.agents, ", ") .. ") in this herdr tab"
		)
		return
	end

	if not herdr({ "agent", "prompt", pane, prompt }) then
		vim.api.nvim_err_writeln("shannon: herdr agent prompt failed for pane " .. pane)
	end
end

-- Upstream includes the selected text only for charwise and blockwise visual,
-- so a normal-mode or linewise prompt carries a line number and nothing else.
-- Fill in the lines here, while the source buffer is still current: by the time
-- send() runs, the floating prompt has taken its place.
local original_open = private.open

private.open = function(context)
	if not context.lines then
		local buf = vim.api.nvim_get_current_buf()
		context.lines = vim.api.nvim_buf_get_lines(buf, context.line_start - 1, context.line_end, false)
	end
	return original_open(context)
end

if vim.env.HERDR_PANE_ID then
	private.get_pane = find_agent_pane
	private.send = send
end

-- Annotations rendered flat, in a colour the file already uses for strings and
-- constants, so they read as another line of code. Give them a background: no
-- syntax group has one, which makes them unmistakable at a glance.
local function define_highlights()
	local function fg_of(name)
		local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
		return hl and hl.fg
	end

	local cursorline = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
	local tint = cursorline and cursorline.bg

	for suffix, source in pairs({
		Info = "DiagnosticInfo",
		Hint = "DiagnosticHint",
		Warn = "DiagnosticWarn",
		Error = "DiagnosticError",
	}) do
		vim.api.nvim_set_hl(0, "Shannon" .. suffix, { fg = fg_of(source), bg = tint, italic = true })
	end
	vim.api.nvim_set_hl(0, "ShannonSign", { fg = fg_of("DiagnosticInfo") })
end

define_highlights()

-- Reloading the colorscheme wipes custom groups, and auto-dark-mode swaps
-- moonfly for nightfly under our feet.
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("ShannonHighlights", { clear = true }),
	callback = define_highlights,
})

-- Split text into lines no wider than width, each padded to exactly width so the
-- tinted block is a rectangle that ends at the window edge.
local function wrap(text, width)
	local lines, current = {}, ""
	for word in text:gmatch("%S+") do
		if current == "" then
			current = word
		elseif vim.fn.strdisplaywidth(current .. " " .. word) <= width then
			current = current .. " " .. word
		else
			table.insert(lines, current)
			current = word
		end
	end
	if current ~= "" then
		table.insert(lines, current)
	end

	for i, line in ipairs(lines) do
		lines[i] = line .. string.rep(" ", math.max(width - vim.fn.strdisplaywidth(line), 0))
	end
	return lines
end

-- Upstream's annotate emits one chunk with virt_lines_overflow = "trunc", so a
-- long annotation is cut at the window edge and the rest is unreachable: virtual
-- lines never wrap, whatever 'wrap' says. Replace the module in the loader cache
-- (it returns a bare function, so there is no field to reassign) and emit one
-- virtual line per wrapped line instead.
local annotate_aliases = {
	DiagnosticInfo = "ShannonInfo",
	DiagnosticHint = "ShannonHint",
	DiagnosticWarn = "ShannonWarn",
	DiagnosticError = "ShannonError",
}

-- Wrap to the narrowest window showing the buffer: with the same buffer open in
-- two splits, the wider one would overflow the other.
local function annotation_width(buf)
	local width
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		local info = vim.fn.getwininfo(win)[1]
		local usable = info.width - info.textoff
		width = math.min(width or usable, usable)
	end
	return width or 100
end

-- Leading whitespace of the annotated line, as spaces: a literal tab in virtual
-- text does not expand, so copying it would misalign every indented line.
local function alignment(buf, row)
	local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
	return string.rep(" ", vim.fn.strdisplaywidth(line:match("^%s*")))
end

local function virt_lines_for(text, group, usable, lead)
	local marker_width = vim.fn.strdisplaywidth(config.marker)
	local width = math.max(usable - #lead - marker_width, 20)

	local virt_lines = {}
	for i, line in ipairs(wrap(text, width)) do
		-- Continuation lines align under the text, not under the marker.
		local prefix = lead .. (i == 1 and config.marker or string.rep(" ", marker_width))
		table.insert(virt_lines, { { prefix .. line, group } })
	end
	return virt_lines
end

package.loaded["wincent.shannon.private.annotate"] = function(line, text, highlight)
	local buf = vim.api.nvim_get_current_buf()
	local group = annotate_aliases[highlight] or highlight or "ShannonInfo"
	local row = line - 1

	vim.api.nvim_buf_set_extmark(buf, vim.api.nvim_create_namespace("shannon"), row, 0, {
		virt_lines = virt_lines_for(text, group, annotation_width(buf), alignment(buf, row)),
	})
end

-- The wrap is frozen at annotation time, so resizing the window truncates it.
-- Re-wrap from the marks themselves: wrap() splits on whitespace and the lines
-- are rejoined with single spaces, so re-running it is idempotent and no copy of
-- the original text has to be kept anywhere.
local function rewrap(buf)
	local ns = vim.api.nvim_create_namespace("shannon")
	local width = annotation_width(buf)

	for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })) do
		local id, row, details = mark[1], mark[2], mark[4]
		if details.virt_lines then
			local parts, group = {}, nil
			for _, virt_line in ipairs(details.virt_lines) do
				for _, chunk in ipairs(virt_line) do
					-- Drop the marker along with the padding, or it would be
					-- read back as the first word of the text. Escaped: a
					-- marker like "^" or "." is also a pattern.
					local stripped = vim.trim(chunk[1]):gsub("^" .. vim.pesc(vim.trim(config.marker)) .. "%s*", "")
					table.insert(parts, stripped)
					group = group or chunk[2]
				end
			end

			vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
				id = id,
				virt_lines = virt_lines_for(table.concat(parts, " "), group, width, alignment(buf, row)),
				sign_text = details.sign_text,
				sign_hl_group = details.sign_hl_group,
			})
		end
	end
end

vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
	group = vim.api.nvim_create_augroup("ShannonRewrap", { clear = true }),
	callback = function()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buf) then
				rewrap(buf)
			end
		end
	end,
})

-- Every annotation in every loaded buffer, shaped as snacks picker items.
local function annotations()
	local ns = vim.api.nvim_create_namespace("shannon")
	local items = {}

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local file = vim.api.nvim_buf_get_name(buf)
			for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })) do
				local row, details = mark[2], mark[4]
				local parts, group = {}, nil
				for _, virt_line in ipairs(details.virt_lines or {}) do
					for _, chunk in ipairs(virt_line) do
						table.insert(parts, vim.trim(chunk[1]))
						group = group or chunk[2]
					end
				end
				local text = vim.trim(table.concat(parts, " "))
				if text ~= "" then
					table.insert(items, {
						text = file .. " " .. text,
						line = text,
						hl = group,
						buf = buf,
						file = file,
						pos = { row + 1, 0 },
					})
				end
			end
		end
	end

	table.sort(items, function(a, b)
		if a.file ~= b.file then
			return a.file < b.file
		end
		return a.pos[1] < b.pos[1]
	end)
	return items
end

vim.api.nvim_create_user_command("ShannonPicker", function()
	local items = annotations()
	if #items == 0 then
		vim.api.nvim_echo({ { "shannon: no annotations", "WarningMsg" } }, false, {})
		return
	end

	Snacks.picker.pick({
		source = "shannon",
		title = "Shannon",
		finder = function()
			return items
		end,
		format = function(item)
			return {
				{ vim.fn.fnamemodify(item.file, ":t") .. ":" .. item.pos[1], "SnacksPickerFile" },
				{ "  " },
				{ item.line, item.hl or "SnacksPickerComment" },
			}
		end,
		preview = "file",
		confirm = "jump",
	})
end, { desc = "Shannon annotations picker" })

local changeset = require("shannon.changeset")

local function complete(_, _, _)
	return changeset.labels()
end

vim.api.nvim_create_user_command("ShannonAccept", function(args)
	changeset.accept(args.args)
end, { desc = "Accept a changeset", nargs = "?", complete = complete })

vim.api.nvim_create_user_command("ShannonReject", function(args)
	changeset.reject(args.args)
end, { desc = "Reject a changeset", nargs = "?", complete = complete })

vim.api.nvim_create_user_command("ShannonUndo", function(args)
	changeset.undo(args.args ~= "" and args.args or nil)
end, { desc = "Put back what an accepted changeset replaced", nargs = "?" })
vim.api.nvim_create_user_command("ShannonChangeset", function()
	vim.api.nvim_echo({ { changeset.status(), "Normal" } }, false, {})
end, { desc = "Status of the open changeset" })

vim.api.nvim_create_user_command("ShannonQuickfix", function()
	local qf = {}
	for _, item in ipairs(annotations()) do
		table.insert(qf, { bufnr = item.buf, lnum = item.pos[1], col = 1, text = item.line, valid = 1 })
	end
	vim.fn.setqflist({}, "r", { title = "Shannon", items = qf })
	if #qf > 0 then
		vim.cmd.copen()
	end
end, { desc = "Shannon annotations to quickfix" })
