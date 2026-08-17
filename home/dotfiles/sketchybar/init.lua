sbar = require("sketchybar")

sbar.begin_config()

require("bar")
require("items")

sbar.hotload(false)
sbar.end_config()

sbar.event_loop()
