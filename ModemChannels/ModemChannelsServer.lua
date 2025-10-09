-- Identifier: Community Area Computer

-- Initialisation
    -- Monitor
    local mon = peripheral.wrap("bottom")
    mon.clear()
    mon.setCursorPos(1,1)

    -- Modem
    local modem = peripheral.wrap("top")
    modem.open(1)

    -- File
    local fileName = "ReservedChannels.data"
    local initData = {Community = {1,999}}
    if not fs.exists(fileName) then
        local file = fs.open(fileName, "w")
        file.write("return " .. textutils.serialize(initData))
        file.close()
    end

-- Functions
    -- Update monitor
    local function updateMonitor(mon, fileName)
        -- Clear the monitor
        mon.clear()
        mon.setCursorPos(1, 1)
        
        -- Load the data file safely
        local f, err = loadfile(fileName)
        if not f then
            mon.setCursorPos(1,1)
            mon.write("Error loading ReservedChannels.data")
            print("Error loading file:", err)
            return
        end

        local ok, data = pcall(f)
        if not ok then
            mon.setCursorPos(1,1)
            mon.write("Error reading ReservedChannels.data")
            print("Error executing file:", data)
            return
        end

        data = data or {}

        -- Convert table to list for sorting
        local entries = {}
        for key, range in pairs(data) do
            if type(range) == "table" and #range == 2 then
                table.insert(entries, { key = key, start = range[1], finish = range[2] })
            end
        end

        -- Sort entries by starting channel
        table.sort(entries, function(a, b) return a.start < b.start end)

        -- Print sorted entries to the monitor
        local line = 1
        mon.setCursorPos(1, line)
        mon.write("Reserved Channels:")
        line = line + 2

        for _, entry in ipairs(entries) do
            mon.setCursorPos(1, line)
            mon.write(string.format("%s: %d - %d", entry.key, entry.start, entry.finish))
            line = line + 1
        end
    end

    -- Append to file
    local function appendFileName(fileName, keyName, entry)
        -- Load the Lua table from the file
        local f = loadfile(fileName)
        local data = f()

        -- Add entry as a new top-level key
        data[keyName] = entry

        -- Save data back to the file
        local file = fs.open(fileName, "w")
        file.write("return " .. textutils.serialize(data))
        file.close()

        -- Probably not needed?
        -- updateMonitor(mon, fileName)

        -- DEBUG Print
        -- for k, v in pairs(data) do
        --     print(k, v)
        -- end

        -- Example Usage
        -- appendFileName(fileName, "Button", {3000,3999} )
    end

    -- Handle modem messages
    local function handleMessage(event, side, senderChannel, replyChannel, message, distance)
        print("-----------")
        print("Incoming message:", tostring(message))
        print("From channel:", senderChannel, "Reply to:", replyChannel)
        print("-----------")

        -- Ensure message is a string
        if type(message) ~= "string" then
            modem.transmit(replyChannel, senderChannel, "Invalid message type")
            return
        end

        -- Get
        if message:lower() == "get" then
            local f, err = loadfile(fileName)
            if not f then
                modem.transmit(replyChannel, senderChannel, "Error loading file: " .. tostring(err))
                return
            end

            local ok, data = pcall(f)
            if not ok then
                modem.transmit(replyChannel, senderChannel, "Error reading data file")
                return
            end

            -- Send data as a readable string
            local serialized = textutils.serialize(data)
            modem.transmit(replyChannel, senderChannel, "Reserved Channels:\n" .. serialized)
            return
        end


        -- Add
        if type(message) == "string" then
            local keyName, idStr = message:match([[%s*["']?(%w+)["']?%s*,%s*["']?(%d+)["']?%s*]])
            if keyName and idStr then
                -- Remove any surrounding quotes
                keyName = keyName:gsub('^"(.*)"$', '%1')
                keyName = keyName:gsub("^'(.*)'$", "%1")

                idStr = idStr:gsub('^"(.*)"$', '%1')
                idStr = idStr:gsub("^'(.*)'$", "%1")
                idStr = idStr:match("^%s*(.-)%s*$") -- trim whitespace

                local base = tonumber(idStr)
                if not base then
                    modem.transmit(replyChannel, senderChannel, "Invalid number: " .. tostring(idStr))
                    return
                end

                -- Convert to {3000, 3999}
                local entry = { base * 1000, base * 1000 + 999 }
                appendFileName(fileName, keyName, entry)

                modem.transmit(replyChannel, senderChannel, keyName .. " = {" .. entry[1] .. ", " .. entry[2] .. "}")
                return
            end
        end

        modem.transmit(replyChannel, senderChannel, "Invalid format, expected: keyName, number")
    end

-- Main Loop
while true do
    updateMonitor(mon, fileName)
    print("\nWaiting for modem_message...")
    local eventData = {os.pullEvent("modem_message")}
    print("Event received:", table.unpack(eventData))
    handleMessage(table.unpack(eventData))
end