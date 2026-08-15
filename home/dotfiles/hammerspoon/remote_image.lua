local M = {}

local images = {}
local waiters = {}

function M.provider(url)
	if not url or url == "" then
		return nil
	end

	return function(done)
		if images[url] ~= nil then
			return images[url] or nil
		end

		if waiters[url] then
			table.insert(waiters[url], done)
			return nil
		end

		waiters[url] = { done }
		hs.image.imageFromURL(url, function(image)
			images[url] = image or false
			local callbacks = waiters[url]
			waiters[url] = nil

			for _, callback in ipairs(callbacks) do
				callback(image)
			end
		end)

		return nil
	end
end

return M
