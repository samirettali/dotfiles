local cjson = require("cjson")
local colors = require("colors")

-- Subscription usage for Claude and Codex, hidden until a window is close to
-- its cap — like the status items, this is an alert rather than a gauge. The
-- percentages come from the same endpoints the two CLIs draw themselves
-- (`/usage` and Codex's rate limits), through `ai-usage`.
--
-- Only the worst window is shown: with several buckets per provider the label
-- would be a paragraph, and the one about to run out is the one that matters.
local WARN = 70
local CRITICAL = 90

-- Slow while nothing is near the cap, near-live once something is: the number
-- is only worth watching when you are deciding whether to keep going.
local IDLE_FREQ = 300
local ALERT_FREQ = 60

local PAGES = {
	claude = "https://claude.ai/settings/usage",
	codex = "https://chatgpt.com/codex/settings/usage",
}

-- No glyph: nerd fonts have no OpenAI mark, and one provider iconified while
-- the other spells its name would read as two unrelated items.
local items = {}

for _, key in ipairs({ "claude", "codex" }) do
	items[key] = sbar.add("item", "usage." .. key, {
		position = "right",
		drawing = false,
		icon = { drawing = false },
		label = { font = { style = "Bold" } },
		click_script = ("open %q"):format(PAGES[key]),
	})
end

-- One fetch answers for both providers, so the timer lives on an item of its
-- own rather than on either of them. It is never drawn, and `updates = "on"`
-- keeps it ticking while the visible items are hidden — which is all the time.
local poller = sbar.add("item", "usage.poller", {
	position = "right",
	drawing = false,
	updates = "on",
	update_freq = IDLE_FREQ,
})

local function worst(windows)
	local top
	for _, window in ipairs(windows or {}) do
		local percent = tonumber(window.percent) or 0
		if not top or percent > top.percent then
			top = { label = window.label, percent = percent }
		end
	end
	return top
end

local function refresh()
	sbar.exec(AI_USAGE_BIN, function(out)
		-- SbarLua decodes JSON stdout into a table before invoking the callback;
		-- anything else (a crash, an empty body) arrives as a string and leaves
		-- the current state alone.
		local payload = out
		if type(payload) == "string" then
			local ok, decoded = pcall(cjson.decode, payload)
			if not ok then
				return
			end
			payload = decoded
		end

		if type(payload) ~= "table" or type(payload.providers) ~= "table" then
			return
		end

		local alerting = false

		for _, provider in ipairs(payload.providers) do
			local item = items[provider.key]
			-- A failed fetch keeps whatever was on screen: a transient 403 while
			-- a token is being renewed should not read as "back under the cap".
			if item and not provider.error then
				local top = worst(provider.windows)
				if not top or top.percent < WARN then
					item:set({ drawing = false })
				else
					alerting = true
					local color = top.percent >= CRITICAL and colors.red or colors.yellow
					item:set({
						drawing = true,
						label = {
							string = ("%s %s %d%%"):format(provider.name, top.label, top.percent),
							color = color,
						},
					})
				end
			end
		end

		poller:set({ update_freq = alerting and ALERT_FREQ or IDLE_FREQ })
	end)
end

-- Wrapped: the event handler is called with an env table, which the callback
-- would otherwise read as an argument.
poller:subscribe({ "forced", "routine", "system_woke" }, function()
	refresh()
end)

-- "routine" only fires after the first update_freq window, and 5 minutes of a
-- blank bar after a restart would hide a limit that is already spent.
refresh()
