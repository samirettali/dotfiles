--- Get diagnostic signs for a line
--- @param buf number Buffer number
--- @param lnum number Line number
local function get_diagnostic_sign(buf, lnum)
	local diagnostics = vim.diagnostic.get(buf, { lnum = lnum - 1 })
	if #diagnostics == 0 then
		return nil
	end

	local max_severity = vim.diagnostic.severity.HINT
	for _, diag in ipairs(diagnostics) do
		if diag.severity < max_severity then
			max_severity = diag.severity
		end
	end

	local signs = {
		[vim.diagnostic.severity.ERROR] = { text = "E", hl = "DiagnosticSignError" },
		[vim.diagnostic.severity.WARN] = { text = "W", hl = "DiagnosticSignWarn" },
		[vim.diagnostic.severity.HINT] = { text = "H", hl = "DiagnosticSignHint" },
		[vim.diagnostic.severity.INFO] = { text = "I", hl = "DiagnosticSignInfo" },
	}

	return signs[max_severity]
end

--- Get DAP breakpoint signs for a line
--- @param buf number Buffer number
--- @param lnum number Line number
local function get_dap_sign(buf, lnum)
	local ok, placements = pcall(vim.fn.sign_getplaced, buf, { group = "dap_breakpoints", lnum = lnum })
	if ok and placements and placements[1] and placements[1].signs then
		local signs = placements[1].signs
		if #signs > 0 then
			local sign = signs[1]
			local sign_info = vim.fn.sign_getdefined(sign.name)
			if sign_info and #sign_info > 0 then
				return {
					-- text = sign_info[1].text or "●",
					text = "●",
					-- hl = sign_info[1].texthl or "DapBreakpoint",
					hl = "DiagnosticSignError",
				}
			end
		end
	end
end

-- Format sign with highlight and padding
local function format_sign(sign, width)
	sign = sign or {}
	width = width or 2

	local text = sign.text or ""

	if width then
		text = vim.fn.strcharpart(text, 0, width)
		text = text .. string.rep(" ", width - vim.fn.strchars(text))
	end

	if not sign.hl then
		return text
	end

	return "%#" .. sign.hl .. "#" .. text .. "%*"
end

local function get_line_number(win)
	local rnu = vim.wo[win].relativenumber
	local nu = vim.wo[win].number

	if nu or rnu then
		local num
		if rnu and nu and vim.v.relnum == 0 then
			num = vim.v.lnum
		elseif rnu then
			num = vim.v.relnum
		else
			num = vim.v.lnum
		end
		return "%=" .. num .. " "
	end

	return "" -- TODO: ?
end

local bqf_sign_ns = vim.api.nvim_create_namespace("BqfSignGroup")

--- Get Bqf signs for a line
--- @param bufnr number Buffer number
--- @param lnum number Line number
local function get_bqf_sign(bufnr, lnum)
	local signs = vim.api.nvim_buf_get_extmarks(
		bufnr,
		bqf_sign_ns,
		{ lnum - 1, 0 },
		{ lnum - 1, -1 },
		{ details = true }
	)

	if #signs == 0 then
		return {}
	end

	local sign_data = signs[1][4]
	if not sign_data or not sign_data.sign_text then
		return {}
	end

	local result = { text = sign_data.sign_text, hl = sign_data.sign_hl_group }
	return result
end

--- Get git signs for a line
--- @param buf number Buffer number
--- @param lnum number Line number
local function get_git_sign(buf, lnum)
	local namespaces = vim.api.nvim_get_namespaces()

	for name, ns_id in pairs(namespaces) do
		if name:find("gitsigns") then
			local ok, extmarks = pcall(vim.api.nvim_buf_get_extmarks, buf, ns_id, lnum, lnum, { details = true })
			if ok then
				for _, extmark in pairs(extmarks) do
					local details = extmark[4] or {}
					if details.sign_text then
						return {
							text = details.sign_text,
							hl = details.sign_hl_group,
						}
					end
				end
			end
		end
	end

	return nil
end

function Statuscolumn()
	local win = vim.g.statusline_winid
	local buf = vim.api.nvim_win_get_buf(win)
	local lnum = vim.v.lnum

	local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
	local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })

	-- Skip virtual lines
	if vim.v.virtnum ~= 0 then
		return ""
	end

	local components = {}

	if buftype == "terminal" or filetype == "codecompanion" then
		local ln = get_line_number(win)
		table.insert(components, ln)
	elseif buftype == "quickfix" then
		local bqf_sign = get_bqf_sign(buf, lnum)
		table.insert(components, format_sign(bqf_sign))
	else
		-- Diagnostics
		local diagnostic = get_diagnostic_sign(buf, lnum)
		table.insert(components, format_sign(diagnostic, 2))

		-- Dap breakpoints
		local dap = get_dap_sign(buf, lnum)
		table.insert(components, format_sign(dap, 2))

		-- Marks
		-- local mark = utils.get_mark_sign(buf, lnum)
		-- table.insert(components, format_sign(mark, 2))

		-- Line numbers
		local ln = get_line_number(win)
		table.insert(components, ln)

		-- Git signs
		local git = get_git_sign(buf, lnum)
		table.insert(components, format_sign(git, 2))
	end

	return table.concat(components, "")
end

vim.o.statuscolumn = "%!v:lua.Statuscolumn()"
