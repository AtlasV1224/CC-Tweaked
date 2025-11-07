-- This example draws a single large button that works as a toggle similarly to a lever, useful for a single advanced monitors when you want a bit of a fancier solution to a standard lever

-- Init
local mon = peripheral.wrap("back")
local active = false
mon.setBackgroundColor(colors.black)
mon.clear()

local function drawButton()
    mon.setCursorPos(1,1)
    mon.setBackgroundColor(active and colors.green or colors.red)
    mon.clear()
    mon.setCursorPos(2,3)
    mon.setTextColor(colors.black)
    mon.write(active and " ON " or " OFF")
end

drawButton()

while true do
    local e, side, x, y = os.pullEvent("monitor_touch")
    -- we only have one button entire screen so any touch toggles
    active = not active
    redstone.setOutput("back", active)
    drawButton()
end