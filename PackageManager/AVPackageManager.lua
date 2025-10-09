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

-- Draw only the visible lines
local function drawMenu(programs, selected, startIdx, pageSize)
    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.black)
    term.clear()

    local endIdx = math.min(startIdx + pageSize - 1, #programs)
    for i = startIdx, endIdx do
        term.setCursorPos(1, i - startIdx + 1)
        if i == selected then
            term.setTextColor(colors.yellow)
            term.write("> " .. programs[i].name)
            term.setTextColor(colors.white)
        else
            term.write("  " .. programs[i].name)
        end
    end
end

-- Keyboard-only menu navigation
local function menu(programs)
    local width, height = term.getSize()
    local pageSize = height
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

-- Main
local programs = fetchPrograms(DATA_URL)
if #programs == 0 then
    print("No programs available")
    return
end

local selectedProgram = menu(programs)
downloadAndRun(selectedProgram)