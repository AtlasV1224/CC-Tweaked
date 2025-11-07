-- This example draws a single large button that works as a toggle similarly to a lever, useful for a single advanced monitors when you want a bit of a fancier solution to a standard lever

-- Initialises the monitor and variable that tracks the state of the redstone output
local mon = peripheral.wrap("back")
local active = false
mon.setBackgroundColor(colors.black)
mon.clear()

-- Resposible for drawing the button and controlling the colours for the on and off state when called
local function drawButton()
    mon.setCursorPos(1,1)
    mon.setBackgroundColor(active and colors.green or colors.red)
    mon.clear()
    mon.setCursorPos(2,3)
    mon.setTextColor(colors.black)
    mon.write(active and " ON " or " OFF")
end

drawButton()

-- Resposible for handling the touchscreen input, as there's only 1 button on the entire screen, it waits for the screen to be touch without regard for location 
while true do
    local e, side, x, y = os.pullEvent("monitor_touch")
    active = not active
    -- Toggles the redstone output
    redstone.setOutput("front", active)
    -- Redraws the button in the new toggle state
    drawButton()
end