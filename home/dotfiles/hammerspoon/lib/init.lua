local M = {}

M.file_exists = function(file)
	local f = io.open(file, "rb")
	if f ~= nil then
		f:close()
	end

	return f ~= nil
end

return M
