local cjson = require("cjson")
local colors = require("colors")
local icons = require("icons")
local mono = require("mono")
local popup = require("popup")
local separator = require("separator")

-- Crypto and stocks, one figure each in the bar: the change of their total
-- market cap, crypto first. Clicking either opens a popup with every price and
-- its change, grouped under the same two headings.
--
-- MARKETS, set in sketchybarrc, is the list declared in `home/mac/sketchybar.nix`.
-- Prices are pushed by `market-sketchybar`, a launchd agent holding Binance's
-- and Yahoo's streams open, which writes STATE and triggers `market_update`.
-- A figure whose stream is down arrives marked stale and turns grey.
local STATE = (os.getenv("HOME") or "") .. "/.cache/sketchybar/market.json"
local CHANGE_COLOR = { up = colors.green, down = colors.red, flat = colors.grey70 }
local SIDES = {
	{ key = "crypto", source = "binance", title = "Crypto" },
	{ key = "stocks", source = "yahoo", title = "Stocks" },
}

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

-- Right-side items render rightmost first: the stocks figure is created before
-- the item that carries the icon and the crypto figure.
local stocks = sbar.add("item", "market.stocks", {
	position = "right",
	drawing = false,
	updates = "on",
	icon = { drawing = false },
	label = { padding_left = 0 },
})

local crypto = sbar.add("item", "market", {
	position = "right",
	drawing = false,
	updates = "on",
	icon = { string = icons.market },
	label = { padding_right = 0 },
})

local labels = { crypto = crypto, stocks = stocks }

-- Created after the items, so it sits on their left. It follows their
-- visibility, which keeps an empty group from leaving two separators side by side.
local market_separator = separator.add("market")
market_separator:set({ drawing = false })

-- The popup hangs from the stocks figure, the right edge of the pair, so its
-- right-aligned rows line up with the widget. Items are named by position: a
-- symbol like `EURUSD=X` would break `--set` in a click script.
local headers, rows = {}, {}
for _, side in ipairs(SIDES) do
	headers[side.key] = sbar.add("item", "market.header." .. side.key, {
		position = "popup." .. stocks.name,
		drawing = false,
		icon = { string = side.title, color = colors.grey70, align = "left" },
	})
	for index, market in ipairs(markets) do
		if market.source == side.source then
			rows[index] = sbar.add("item", "market.row." .. index, {
				position = "popup." .. stocks.name,
				drawing = false,
				click_script = ("/usr/bin/open %q; %s --set %s popup.drawing=off"):format(
					page(market),
					SKETCHYBAR_BIN,
					stocks.name
				),
			})
		end
	end
end

local function read_state()
	local state = read_json(STATE) or {}
	local quotes = type(state.quotes) == "table" and state.quotes or {}
	local sides = type(state.sides) == "table" and state.sides or {}
	return quotes, sides
end

local function widest(values)
	local width = 0
	for _, value in pairs(values) do
		width = math.max(width, utf8.len(value) or #value)
	end
	return width
end

local function change_color(figure)
	if figure.stale == true then
		return colors.grey70
	end
	return CHANGE_COLOR[figure.direction] or colors.grey70
end

-- Monospace columns: name, session, price, then the change in its own colour.
-- Each heading spans the first three and carries its side's figure in the last.
local function fill_popup()
	local quotes, sides = read_state()
	local names, sessions, prices, changes = {}, {}, {}, {}
	for index, market in ipairs(markets) do
		local quote = quotes[market.symbol]
		if quote then
			names[index], sessions[index] = market.name, quote.session
			prices[index], changes[index] = quote.price, quote.change
		end
	end
	local figures = {}
	for _, side in ipairs(SIDES) do
		figures[side.key] = sides[side.key] and sides[side.key].change
	end
	-- The session column is there only while some market is outside regular hours.
	local session_width = widest(sessions)
	local format = session_width > 0
			and ("%%-%ds %%-%ds %%%ds"):format(widest(names), session_width, widest(prices))
		or ("%%-%ds%%s %%%ds"):format(widest(names), widest(prices))
	-- `%0s` is an error in Lua, and every change can be empty.
	local change_format = ("%%%ds"):format(math.max(1, widest(changes), widest(figures)))
	local icon_width = mono.width(format:format("", "", ""))

	for _, side in ipairs(SIDES) do
		local figure = sides[side.key]
		headers[side.key]:set({
			drawing = figure ~= nil,
			icon = { width = icon_width },
			label = figure and {
				string = change_format:format(figure.change),
				width = mono.width(change_format:format(figure.change)),
				align = "right",
				color = change_color(figure),
			} or nil,
		})
	end

	for index, market in ipairs(markets) do
		local quote = quotes[market.symbol]
		if quote then
			local stale = quote.stale == true
			local icon_text = format:format(market.name, quote.session, quote.price)
			local change_text = change_format:format(quote.change)
			rows[index]:set({
				drawing = true,
				icon = {
					string = icon_text,
					width = icon_width,
					align = "left",
					color = stale and colors.grey70 or colors.white,
				},
				label = {
					string = change_text,
					width = mono.width(change_text),
					align = "right",
					color = change_color(quote),
				},
			})
		else
			rows[index]:set({ drawing = false })
		end
	end
end

local function render()
	local _, sides = read_state()
	local any = next(sides) ~= nil
	crypto:set({ drawing = any })
	for _, side in ipairs(SIDES) do
		local figure = sides[side.key]
		local item = labels[side.key]
		item:set({
			label = {
				drawing = figure ~= nil,
				string = figure and figure.change or "",
				-- Each label keeps one padding of 4: the pair is drawn as one.
				width = figure and mono.width(figure.change, 4) or 0,
				color = figure and change_color(figure) or colors.grey70,
			},
		})
	end
	-- Sketchybar draws no popup for an item it does not draw, so the stocks item
	-- stays drawn, empty and without padding, while the crypto figure shows.
	local padding = sides.stocks and 4 or 0
	stocks:set({ drawing = any, padding_left = padding, padding_right = padding })
	market_separator:set({ drawing = any })

	-- Keep an open popup current instead of showing the prices it opened with.
	local state = stocks:query()
	if state and state.popup and state.popup.drawing == "on" then
		fill_popup()
	end
end

local toggle = popup.setup(stocks, fill_popup)
crypto:subscribe("mouse.clicked", toggle)
stocks:subscribe("market_update", render)
render()
