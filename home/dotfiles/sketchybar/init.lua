sbar = require("sketchybar")

sbar.begin_config()

require("bar")
require("items")

sbar.hotload(true)
sbar.end_config()

sbar.event_loop()
