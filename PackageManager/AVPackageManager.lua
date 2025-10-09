-- AtlasV: AVPackageManager

-- Welcome! This is the package manager for all my CC Tweaked scripts. When this script is run, it will present the user with an installation menu for all my programs hosted over on GitHub: https://github.com/AtlasV1224/CC-Tweaked


-- Config
local DATA_URL = "http://example.com/programs.json"  -- Replace with your JSON link

-- Fetch program list from URL
local function fetchPrograms(url)
    local success, response = pcall(http.get, url)
    if not success or not response then
        print("Failed to fetch programs from URL")
        return {}
    end

    local data = response.readAll()
    response.close()

    local ok, programs = pcall(textutils.unserializeJSON, data)
    if not ok then
        print("Failed to parse JSON")
        return {}
    end

    return programs
end

-- Draw menu with paging
local function drawMenu(programs, selected)
    term.clear()
    local width, height = term.getSize()
    local pageSize = height
    local page = math.floor((selected-1)/pageSize)
    local startIdx = page * pageSize + 1
    local endIdx = math.min(startIdx + pageSize - 1, #programs)

    for i = startIdx, endIdx do
        if i == selected then
            term.setTextColor(colors.yellow)
            print("> " .. programs[i].name)
            term.setTextColor(colors.white)
        else
            print("  " .. programs[i].name)
        end
    end
end

-- Handle menu input (keyboard + touchscreen)
local function menu(programs)
    local selected = 1
    while true do
        drawMenu(programs, selected)
        local event, param1, param2, param3 = os.pullEvent()
        
        if event == "key" then
            if param1 == keys.up and selected > 1 then
                selected = selected - 1
            elseif param1 == keys.down and selected < #programs then
                selected = selected + 1
            elseif param1 == keys.enter then
                return programs[selected]
            end
        elseif event == "mouse_click" then
            local x, y = param2, param3
            local width, height = term.getSize()
            local pageSize = height
            local page = math.floor((selected-1)/pageSize)
            local startIdx = page * pageSize + 1
            local clickedIndex = startIdx + y - 1
            if programs[clickedIndex] then
                return programs[clickedIndex]
            end
        end
    end
end

-- Download and run program
local function downloadAndRun(program)
    print("Downloading " .. program.name .. "...")
    local success, response = pcall(http.get, program.url)
    if not success or not response then
        print("Failed to download program")
        return
    end

    local code = response.readAll()
    response.close()

    local func, err = load(code, program.name)
    if not func then
        print("Failed to load program: " .. err)
        return
    end

    print("Running " .. program.name .. "...")
    func()
end

-- Main loop
local programs = fetchPrograms(DATA_URL)
if #programs == 0 then
    print("No programs available")
    return
end

local selectedProgram = menu(programs)
downloadAndRun(selectedProgram)