local cjson = require("cjson")
local colors = require("colors")
local icons = require("icons")
local mono = require("mono")
local popup = require("popup")
local separator = require("separator")

-- Crypto and stocks, one figure each in the bar: the change of their total
-- market cap, crypto first. Clicking either opens a popup with every price and
-- its change, under a heading per group. The macro group (indices, currencies,
-- commodities) has no market cap and so no figure in the bar.
--
-- MARKETS, set in sketchybarrc, is the list declared in `home/mac/sketchybar.nix`.
-- Prices are pushed by `market-sketchybar`, a launchd agent holding Binance's
-- and Yahoo's streams open, which writes STATE and triggers `market_update`.
-- A figure whose stream is down arrives marked stale and turns grey.
local STATE = (os.getenv("HOME") or "") .. "/.cache/sketchybar/market.json"
local CHANGE_COLOR = { up = colors.green, down = colors.red, flat = colors.grey70 }
-- A dot after each name shows its market's status: open, pre, post, night or
-- closed. A label carries one colour, so the dot is the row's background image,
-- moved right past the name by the image's own padding. MARKET_DOTS, set in
-- sketchybarrc, holds one 16-pixel PNG per status, shown as 8 points.
local DOT_SCALE = 0.5
local DOT_SIZE = 8
-- Spaces between the longest name and the price column; the dot sits in the
-- first two after each name.
local NAME_GAP = 4
local DOT_ROOM = 2
-- Points between the price and the change.
local CHANGE_GAP = 16
local ICON_PADDING_LEFT = 4
local ICON_PADDING_RIGHT = 4
-- Popup rows default to the bar's height, which spreads a long list out.
local ROW_HEIGHT = 28
-- A popup cell is as tall as its item's background, so a taller, invisible one
-- opens space above every heading but the first; the title drops to its foot.
local HEADING_HEIGHT = 46
local HEADING_DROP = -7
local SIDES = {
	{ key = "crypto", title = "Crypto" },
	{ key = "stocks", title = "Stocks" },
	{ key = "macro", title = "Macro" },
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
	icon = { string = icons.market, font = icons.app_font },
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
for position, side in ipairs(SIDES) do
	local spaced = position > 1
	headers[side.key] = sbar.add("item", "market.header." .. side.key, {
		position = "popup." .. stocks.name,
		drawing = false,
		icon = {
			string = side.title,
			color = colors.grey70,
			align = "left",
			y_offset = spaced and HEADING_DROP or 0,
		},
		label = { drawing = false },
		background = { drawing = spaced, color = 0x00000000, height = HEADING_HEIGHT },
	})
	-- One row per market of the group. The rows are slots: the watcher orders
	-- crypto and stocks by market cap, so a row shows whichever market ranks there.
	rows[side.key] = {}
	for _, market in ipairs(markets) do
		if market.group == side.key then
			local slot = #rows[side.key] + 1
			rows[side.key][slot] = sbar.add("item", ("market.row.%s.%d"):format(side.key, slot), {
				position = "popup." .. stocks.name,
				drawing = false,
			})
		end
	end
end

local function read_state()
	local state = read_json(STATE) or {}
	local quotes = type(state.quotes) == "table" and state.quotes or {}
	local sides = type(state.sides) == "table" and state.sides or {}
	local order = type(state.order) == "table" and state.order or {}
	return quotes, sides, order
end

local function widest(values)
	local width = 0
	for _, value in pairs(values) do
		width = math.max(width, utf8.len(value) or #value)
	end
	return width
end

-- The group's markets in the watcher's order, then any it left out in list order.
local function ordered(group, order)
	local by_symbol, result, placed = {}, {}, {}
	for _, market in ipairs(markets) do
		if market.group == group then
			by_symbol[market.symbol] = market
		end
	end
	for _, symbol in ipairs(type(order[group]) == "table" and order[group] or {}) do
		if by_symbol[symbol] and not placed[symbol] then
			result[#result + 1], placed[symbol] = by_symbol[symbol], true
		end
	end
	for _, market in ipairs(markets) do
		if market.group == group and not placed[market.symbol] then
			result[#result + 1] = market
		end
	end
	return result
end

local function change_color(figure)
	if figure.stale == true then
		return colors.grey70
	end
	return CHANGE_COLOR[figure.direction] or colors.grey70
end

-- Monospace columns: the name and price, then the change in its own colour.
local function fill_popup()
	local quotes, _, order = read_state()
	local names, prices, changes = {}, {}, {}
	for index, market in ipairs(markets) do
		local quote = quotes[market.symbol]
		if quote then
			names[index], prices[index], changes[index] = market.name, quote.price, quote.change
		end
	end
	local format = ("%%-%ds%s%%%ds"):format(widest(names), (" "):rep(NAME_GAP), widest(prices))
	-- `%0s` is an error in Lua, and every change can be empty.
	local change_format = ("%%%ds"):format(math.max(1, widest(changes)))
	local icon_width = mono.width(format:format("", ""), ICON_PADDING_LEFT + ICON_PADDING_RIGHT)

	-- A group shows while any of its markets has a price.
	local shown = {}
	for _, market in ipairs(markets) do
		if quotes[market.symbol] then
			shown[market.group] = true
		end
	end
	local row_width = icon_width + mono.width(change_format:format(""), CHANGE_GAP + 4)
	for _, side in ipairs(SIDES) do
		headers[side.key]:set({ drawing = shown[side.key] == true, icon = { width = row_width } })
	end

	for _, side in ipairs(SIDES) do
		for slot, market in ipairs(ordered(side.key, order)) do
			local row = rows[side.key][slot]
			local quote = quotes[market.symbol]
			if quote then
				local stale = quote.stale == true
				row:set({
					drawing = true,
					click_script = ("/usr/bin/open %q; %s --set %s popup.drawing=off"):format(
						page(market),
						SKETCHYBAR_BIN,
						stocks.name
					),
					background = {
						drawing = true,
						color = 0x00000000,
						image = {
							string = ("%s/%s.png"):format(MARKET_DOTS, quote.status or "closed"),
							scale = DOT_SCALE,
							-- Centred in the gap that follows this row's name.
							padding_left = math.floor(
								ICON_PADDING_LEFT
									+ mono.width(market.name, 0)
									+ (mono.width((" "):rep(DOT_ROOM), 0) - DOT_SIZE) / 2
							),
						},
					},
					icon = {
						string = format:format(market.name, quote.price),
						width = icon_width,
						align = "left",
						padding_left = ICON_PADDING_LEFT,
						padding_right = ICON_PADDING_RIGHT,
						color = stale and colors.grey70 or colors.white,
					},
					label = {
						string = change_format:format(quote.change),
						width = mono.width(change_format:format(quote.change), CHANGE_GAP + 4),
						align = "right",
						padding_left = CHANGE_GAP,
						color = change_color(quote),
					},
				})
			else
				row:set({ drawing = false })
			end
		end
	end
end

local function render()
	local _, sides = read_state()
	local any = next(sides) ~= nil
	crypto:set({ drawing = any })
	for key, item in pairs(labels) do
		local figure = sides[key]
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
stocks:set({ popup = { height = ROW_HEIGHT } })
crypto:subscribe("mouse.clicked", toggle)
stocks:subscribe("market_update", render)
render()
