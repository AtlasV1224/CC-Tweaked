-- AtlasV: AVPackageManager

-- Welcome! This is the package manager for all my CC Tweaked scripts. When this script is run, it will present the user with an installation menu for all my programs hosted over on GitHub: https://github.com/AtlasV1224/CC-Tweaked


-- Config
local DATA_URL = "https://raw.githubusercontent.com/AtlasV1224/CC-Tweaked/refs/heads/main/PackageManager/CCTweakedPrograms.json"


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

-- Draws UI
local function drawMenu(programs, selected, startIdx, pageSize)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()

    local width, height = term.getSize()

    -- Draw title bar
    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.gray)
    term.clearLine()
    local title = " AV Package Manager "
    term.setCursorPos(math.floor((width - #title) / 2), 1)
    term.write(title)

    term.setBackgroundColor(colors.black)
    local endIdx = math.min(startIdx + pageSize - 1, #programs)

    for i = startIdx, endIdx do
        local y = (i - startIdx + 2) -- +2 because of title bar
        term.setCursorPos(1, y)

        if i == selected then
            term.setBackgroundColor(colors.lightGray)
            term.setTextColor(colors.black)
            local line = "  " .. programs[i].name .. " "
            line = line .. string.rep(" ", math.max(0, width - #line))
            term.write(line)
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
        else
            local line = " " .. programs[i].name
            line = line .. string.rep(" ", math.max(0, width - #line))
            term.write(line)
        end
    end
end

-- Menu Nav
local function menu(programs)
    local width, height = term.getSize()
    local pageSize = height - 1  -- Leave room for title bar
    local selected = 1
    local startIdx = 1

    drawMenu(programs, selected, startIdx, pageSize)

    while true do
        local event, key = os.pullEvent("key")

        if key == keys.up and selected > 1 then
            selected = selected - 1
            if selected < startIdx then
                startIdx = selected
            end
            drawMenu(programs, selected, startIdx, pageSize)
        elseif key == keys.down and selected < #programs then
            selected = selected + 1
            if selected > startIdx + pageSize - 1 then
                startIdx = selected - pageSize + 1
            end
            drawMenu(programs, selected, startIdx, pageSize)
        elseif key == keys.enter then
            return programs[selected]
        end
    end
end

-- Download and run program
local function downloadAndRun(program)
    term.clear()
    term.setCursorPos(1, 1)
    print("Downloading " .. program.name .. "...")
    local success, response = pcall(http.get, program.url)
    if not success or not response then
        print("Failed to download program")
        sleep(2)
        return
    end

    local code = response.readAll()
    response.close()

    local func, err = load(code, program.name)
    if not func then
        print("Failed to load program: " .. err)
        sleep(2)
        return
    end

    print("Running " .. program.name .. "...")
    sleep(1)
    term.clear()
    term.setCursorPos(1, 1)
    func()
end

-- Main
local programs = fetchPrograms(DATA_URL)
if #programs == 0 then
    print("No programs available")
    return
end

local selectedProgram = menu(programs)
downloadAndRun(selectedProgram)