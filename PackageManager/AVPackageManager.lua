-- AtlasV: AVPackageManager

-- Welcome! This is the package manager for all my CC Tweaked scripts. When this script is run, it will present the user with an installation menu for all my programs hosted over on GitHub: https://github.com/AtlasV1224/CC-Tweaked


-- Config
local DATA_URL = "https://raw.githubusercontent.com/AtlasV1224/CC-Tweaked/refs/heads/main/PackageManager/CCTweakedPrograms.json"
local PROGRAMS_DIR = "Programs"


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

-- Download and program
local function downloadProgram(program)
    term.clear()
    term.setCursorPos(1, 1)
    print("Downloading " .. program.name .. "...")

    local success, response = pcall(http.get, program.url)
    if not success or not response then
        print("Failed to download program.")
        sleep(2)
        return false
    end

    local code = response.readAll()
    response.close()

    -- Ensure Programs directory exists
    if not fs.exists(PROGRAMS_DIR) then
        fs.makeDir(PROGRAMS_DIR)
    end

    -- Save file
    local filePath = fs.combine(PROGRAMS_DIR, program.name .. ".lua")
    local file = fs.open(filePath, "w")
    file.write(code)
    file.close()

    print("Saved to " .. filePath)
    sleep(1)

    return filePath
end

-- Run Program
local function runProgram(filePath)
    term.clear()
    term.setCursorPos(1, 1)
    print("Running program...")
    sleep(1)
    shell.run(filePath)
end

-- Reinstall, Deletes and installs anew
local function reinstallProgram(program)
    local filePath = fs.combine(PROGRAMS_DIR, program.name .. ".lua")
    if fs.exists(filePath) then
        fs.delete(filePath)
        print("Old version removed.")
        sleep(0.5)
    end
    return downloadProgram(program)
end

-- App options Submenu
local function programSubMenu(program)
    local options = {"Download", "Run", "Reinstall"}
    local selected = 1

    while true do
        term.clear()
        term.setCursorPos(1, 1)
        print("Program: " .. program.name)
        print("----------------------")

        for i, opt in ipairs(options) do
            local filePath = fs.combine(PROGRAMS_DIR, program.name .. ".lua")
            local installed = fs.exists(filePath)

            -- Disable Run/Reinstall if not installed
            local disabled = (opt ~= "Download" and not installed)

            if i == selected then
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
            end

            if disabled then
                term.setTextColor(colors.gray)
            end

            print("  " .. opt)
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
        end

        local event, key = os.pullEvent("key")
        if key == keys.up and selected > 1 then
            selected = selected - 1
        elseif key == keys.down and selected < #options then
            selected = selected + 1
        elseif key == keys.enter then
            local choice = options[selected]
            local filePath = fs.combine(PROGRAMS_DIR, program.name .. ".lua")
            local installed = fs.exists(filePath)

            -- Ignore disabled options
            if choice ~= "Download" and not installed then
                -- Do nothing
            elseif choice == "Download" then
                downloadProgram(program)
            elseif choice == "Run" then
                runProgram(filePath)
            elseif choice == "Reinstall" then
                reinstallProgram(program)
            end
        elseif key == keys.backspace then
            return
        end
    end
end

-- Main
local programs = fetchPrograms(DATA_URL)
if #programs == 0 then
    print("No programs available")
    return
end

while true do
    local selectedProgram = menu(programs)
    programSubMenu(selectedProgram)
end