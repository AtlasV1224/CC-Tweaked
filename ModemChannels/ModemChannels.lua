local args = {...}
local modem = peripheral.find("modem")
modem.open(2) -- reply channel



-- Safety check
if #args < 1 then
    print("---------------")
    print("Usage:")
    print("")
    print("ModemChannels get")
    print("- Returns a list of the reserved channels")
    print("")
    print("ModemChannels add <Name> <KiloBand>")
    print("- Reserves a KiloBand for your usage.")
    print("Please use `ModemChannels get` first to see which bands are already used")
    print("---------------")
    return
end

local command = args[1]
local name = args[2]
local band = args[3]

if command == "get" then
    modem.transmit(1, 2, command)
    while true do
        local event, side, senderChannel, replyChannel, message, distance = os.pullEvent("modem_message")

        if replyChannel == 1 then
            -- Attempt to parse the message table
            local f, err = load("return " .. message:match("Reserved Channels:%s*(.*)"))
            if f then
                local ok, data = pcall(f)
                if ok and type(data) == "table" then
                    -- Convert table into a list for sorting
                    local entries = {}
                    for key, range in pairs(data) do
                        if type(range) == "table" and #range == 2 then
                            table.insert(entries, { key = key, start = range[1], finish = range[2] })
                        end
                    end

                    -- Sort by start channel
                    table.sort(entries, function(a, b) return a.start < b.start end)

                    -- Print sorted entries
                    print("-----------")
                    print("Reserved Channels:")
                    print("")
                    for _, entry in ipairs(entries) do
                        print(string.format("%s: %d - %d", entry.key, entry.start, entry.finish))
                    end
                    print("-----------")
                else
                    print("Error parsing server data:", data)
                end
            else
                print("Could not parse server response:", err)
            end
            break
        end
    end

elseif command == "add" then
    if not name or not band then
        print("-----------")
        print("Error: Missing arguments for `add` command.")
        print("Run `ModemChannels` for help")
        print("-----------")
        return
    end
    local addData = '"' .. name .. ', ' .. band .. '"'
    modem.transmit(1, 2, addData)
    while true do
        local event, side, senderChannel, replyChannel, message, distance = os.pullEvent("modem_message")

        if replyChannel == 1 then
            print("-----------")
            print("Thank you for reserving a KiloBand!")
            print("Successfully reserved:", message)
            print("-----------")
            break
        end
    end

else
    print("-----------")
    print("Unknown command:", command)
    print("Run `ModemChannels` for help")
    print("-----------")
end