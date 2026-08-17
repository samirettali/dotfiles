sbar.add("event", "keyboard_layout_change")

local item = sbar.add("item", "keyboard_layout", {
	position = "right",
	padding_left = 3,
	icon = { drawing = false },
})

local labels = {
	["com.apple.keylayout.US"] = "US",
	["com.apple.keylayout.Italian-Pro"] = "IT",
	["com.apple.keylayout.Italian"] = "IT",
}

local function set(source_id)
	item:set({ label = { string = labels[source_id] or source_id:match("[^.]+$") or "?" } })
end

item:subscribe("keyboard_layout_change", function(env)
	set(env.SOURCE_ID or "")
end)

-- The event is pushed by hammerspoon, which sketchybar can outlive, so resolve
-- the current source once at startup. Text Input Services is the authoritative
-- answer, unlike the com.apple.HIToolbox prefs.
local read_source_id = table.concat({
	'osascript -l JavaScript -e \'ObjC.import("Carbon");',
	"ObjC.unwrap($.NSString.stringWithString(ObjC.castRefToObject(",
	"$.TISGetInputSourceProperty($.TISCopyCurrentKeyboardInputSource(),",
	"$.kTISPropertyInputSourceID))))'",
}, " ")

sbar.exec(read_source_id, function(out)
	set((out or ""):gsub("%s+", ""))
end)
