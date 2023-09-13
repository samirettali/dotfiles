if true then return end

local formatter = function(text)
    local bin = vim.api.nvim_get_runtime_file("bin/sql-format-via-python.py", false)[1]

    local j = require("plenary.job"):new {
        command = "python3",
        args = { bin },
        writer = { text },
    }
    return j:sync()
end

local embedded_sql = vim.treesitter.query.parse(
    "go",
    [[
                (call_expression
                  (selector_expression
                    operand: (identifier) @operand
                    field: (field_identifier) @field (#contains? @field "QueryRow" "Exec" "Query" ))
                  (argument_list
                    (raw_string_literal) @sql
                )
                )
        ]]
)

local get_root = function(bufnr)
    local parser = vim.treesitter.get_parser(bufnr, "go", {})
    local tree = parser:parse()[1]
    return tree:root()
end

local function replace_node(node, replacement, opts)
    if type(replacement) ~= "table" then
        replacement = { replacement }
    end

    local start_row, start_col, end_row, end_col = (opts.target or node):range()
    vim.api.nvim_buf_set_text(
        vim.api.nvim_get_current_buf(),
        start_row, start_col, end_row, end_col, replacement
    )

    if opts.cursor then
        vim.api.nvim_win_set_cursor(
            vim.api.nvim_get_current_win(),
            {
                start_row + (opts.cursor.row or 0) + 1,
                start_col + (opts.cursor.col or 0)
            }
        )
    end
end

local format_sql = function(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    if vim.bo[bufnr].filetype ~= "go" then
        vim.notify "can only be used in go"
        return
    end

    local root = get_root(bufnr)

    local changes = {}
    for id, node in embedded_sql:iter_captures(root, bufnr, 0, -1) do
        local name = embedded_sql.captures[id]
        if name == "sql" then
            local content = vim.treesitter.get_node_text(node, bufnr)
            content = content:sub(1, -2)
            content = content:sub(2)

            local formatted = formatter(content)

            formatted[1] = "`" .. formatted[1]
            formatted[#formatted] = formatted[#formatted] .. "`"

            replace_node(node, formatted, {})
        end
    end
end

if false then
    vim.api.nvim_create_user_command("SqlMagic", function()
        format_sql()
    end, {})

    vim.api.nvim_create_autocmd({ "BufWritePre", "BufWritePost" }, {
        pattern = { "*.go" },
        callback = function()
            format_sql()
        end,
    })
end
