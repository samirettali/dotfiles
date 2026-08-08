local M = {}

-- zoxide style: a use count that decays with age, so something used constantly
-- outranks something used once a year without ever forgetting either
local function decay(age)
	if age < 3600 then
		return 4
	end

	if age < 86400 then
		return 2
	end

	if age < 604800 then
		return 0.5
	end

	return 0.25
end

-- Capped so frecency only breaks ties between comparable matches: an entry you
-- use daily should beat one you never touch, but it must not outrank a plainly
-- better match on the name.
local CAP = 30

-- key is an hs.settings key, which is NSUserDefaults, so counts survive
-- reloads and restarts
function M.new(key)
	local store = {}

	local function all()
		return hs.settings.get(key) or {}
	end

	-- one settings read for a whole list, rather than one per candidate
	function store.scores()
		local uses = all()
		local now = os.time()

		return function(id)
			local entry = uses[id]

			if not entry or not entry.last then
				return 0
			end

			return math.min(entry.count * decay(now - entry.last) * 3, CAP)
		end
	end

	function store.remember(id)
		local uses = all()
		local entry = uses[id] or { count = 0 }

		entry.count = entry.count + 1
		entry.last = os.time()
		uses[id] = entry

		hs.settings.set(key, uses)
	end

	return store
end

return M
