-- AV Packager repace turtle test

-- Init
local packager = peripheral.wrap("top")
local address = "store"
packager.setAddress(address)
local taskNo = 0

-- Poll Inventory
while true do
    local hasItems = false

    -- Loop through all slots
    for i = 1, 16 do
        if turtle.getItemCount(i) > 0 then
            hasItems = true
            break
        end
    end

    -- Print task number so its easier to see when it updates
    print("Task Number: " .. taskNo)
    taskNo = taskNo + 1

    if hasItems then
        packager.makePackage()
        print("Package made with address: " .. address)
    else
        print("Inv empty, Address: " .. address)
    end

    sleep(2.5)
end