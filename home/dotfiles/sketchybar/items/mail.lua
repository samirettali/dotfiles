local icons = require("icons")

-- Unread mail in the Fastmail inbox. Hidden at zero, like the status items.
--
-- The count is pushed by `mail-sketchybar`, a launchd agent holding Fastmail's
-- JMAP event stream open, which triggers `mail_unread`. Nothing here polls.
sbar.add("event", "mail_unread")

local mail = sbar.add("item", "mail", {
	position = "right",
	drawing = false,
	updates = "on",
	icon = { string = icons.mail },
	click_script = "/usr/bin/open 'https://app.fastmail.com/mail/Inbox/'",
})

mail:subscribe("mail_unread", function(env)
	local count = tonumber(env.count) or 0
	mail:set({
		drawing = count > 0,
		label = { string = tostring(count) },
	})
end)
