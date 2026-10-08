local cjson = require("cjson")
local colors = require("colors")
local mono = require("mono")
local popup = require("popup")
local separator = require("separator")

-- Live crypto and stock prices. The ones marked `bar` sit in the bar, price
-- only; clicking any of them opens a popup with every price and its change.
--
-- MARKETS, set in sketchybarrc, is the list declared in `home/mac/sketchybar.nix`.
-- Prices are pushed by `market-sketchybar`, a launchd agent holding Binance's
-- and Yahoo's streams open, which writes STATE and triggers `market_update`.
-- A price whose stream is down arrives marked stale and turns grey.
local STATE = (os.getenv("HOME") or "") .. "/.cache/sketchybar/market.json"
local CHANGE_COLOR = { up = colors.green, down = colors.red, flat = colors.grey70 }

local function read_json(path)
	local handle = path and io.open(path, "r")
	if not handle then
		return nil
	end
	local contents = handle:read("a")
	handle:close()
	local ok, decoded = pcall(cjson.decode, contents)
	if not ok or type(decoded) ~= "table" then
		return nil
	end
	return decoded
end

local markets = read_json(MARKETS) or {}

local function page(market)
	if market.source == "binance" then
		return "https://www.binance.com/en/trade/" .. market.symbol
	end
	-- Yahoo symbols carry `^` and `=`, as in `^GSPC` and `EURUSD=X`.
	local encoded = market.symbol:gsub("[^%w%-%.]", function(char)
		return ("%%%02X"):format(char:byte())
	end)
	return "https://finance.yahoo.com/quote/" .. encoded
end

sbar.add("event", "market_update")

-- Right-side items render rightmost first, so the bar ones are created last to
-- first. Items are named by position: a symbol like `EURUSD=X` would break
-- `--set` in a click script.
local bar = {}
local anchor
for index = #markets, 1, -1 do
	local market = markets[index]
	if market.bar then
		local item = sbar.add("item", "market.bar." .. index, {
			position = "right",
			drawing = false,
			updates = "on",
			icon = { string = market.name, color = colors.grey70 },
		})
		bar[index] = item
		-- The popup hangs from the rightmost, so its right-aligned rows line up
		-- with the group.
		anchor = anchor or item
	end
end

-- Created after the items, so it sits on their left. It follows their
-- visibility, which keeps an empty group from leaving two separators side by side.
local market_separator = separator.add("market")
market_separator:set({ drawing = false })

local rows = {}
if anchor then
	for index, market in ipairs(markets) do
		rows[index] = sbar.add("item", "market.row." .. index, {
			position = "popup." .. anchor.name,
			drawing = false,
			click_script = ("/usr/bin/open %q; %s --set %s popup.drawing=off"):format(
				page(market),
				SKETCHYBAR_BIN,
				anchor.name
			),
		})
	end
end

local function quotes()
	local state = read_json(STATE)
	return state and type(state.quotes) == "table" and state.quotes or {}
end

local function widest(values)
	local width = 0
	for _, value in pairs(values) do
		width = math.max(width, utf8.len(value) or #value)
	end
	return width
end

-- Monospace columns: name, session, price, then the change in its own colour.
local function fill_popup()
	local current = quotes()
	local names, sessions, prices, changes = {}, {}, {}, {}
	for index, market in ipairs(markets) do
		local quote = current[market.symbol]
		if quote then
			names[index], sessions[index] = market.name, quote.session
			prices[index], changes[index] = quote.price, quote.change
		end
	end
	-- The session column is there only while some market is outside regular hours.
	local session_width = widest(sessions)
	local format = session_width > 0
			and ("%%-%ds %%-%ds %%%ds"):format(widest(names), session_width, widest(prices))
		or ("%%-%ds%%s %%%ds"):format(widest(names), widest(prices))
	-- `%0s` is an error in Lua, and every change can be empty.
	local change_format = ("%%%ds"):format(math.max(1, widest(changes)))

	for index, market in ipairs(markets) do
		local quote = current[market.symbol]
		if quote then
			local stale = quote.stale == true
			local icon_text = format:format(market.name, quote.session, quote.price)
			local change_text = change_format:format(quote.change)
			rows[index]:set({
				drawing = true,
				icon = {
					string = icon_text,
					width = mono.width(icon_text),
					align = "left",
					color = stale and colors.grey70 or colors.white,
				},
				label = {
					string = change_text,
					width = mono.width(change_text),
					align = "right",
					color = stale and colors.grey70 or CHANGE_COLOR[quote.direction] or colors.grey70,
				},
			})
		else
			rows[index]:set({ drawing = false })
		end
	end
end

local function render()
	local current = quotes()
	local any = false
	for index in pairs(bar) do
		any = any or current[markets[index].symbol] ~= nil
	end
	for index, item in pairs(bar) do
		local quote = current[markets[index].symbol]
		local shown = quote ~= nil
		-- Sketchybar draws no popup for an item it does not draw, so the anchor
		-- stays drawn, empty and without padding, while any other market shows.
		local drawn = shown or (item == anchor and any)
		local padding = shown and 4 or 0
		item:set({
			drawing = drawn,
			padding_left = padding,
			padding_right = padding,
			icon = { drawing = shown },
			label = {
				drawing = shown,
				string = quote and quote.price or "",
				width = quote and mono.width(quote.price) or 0,
				color = quote and quote.stale == true and colors.grey70 or colors.white,
			},
		})
	end
	market_separator:set({ drawing = any })

	-- Keep an open popup current instead of showing the prices it opened with.
	if anchor then
		local state = anchor:query()
		if state and state.popup and state.popup.drawing == "on" then
			fill_popup()
		end
	end
end

if anchor then
	local toggle = popup.setup(anchor, fill_popup)
	for _, item in pairs(bar) do
		if item ~= anchor then
			item:subscribe("mouse.clicked", toggle)
		end
	end
	anchor:subscribe("market_update", render)
	render()
end
