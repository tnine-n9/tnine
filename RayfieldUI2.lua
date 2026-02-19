if debugX then
    warn('Initialising Rayfield')
end
local function getService(name)
    local service = game:GetService(name)
    return if cloneref then cloneref(service) else service
end
local function loadWithTimeout(url: string, timeout: number?): ...any
    assert(type(url) == "string", "Expected string, got " .. type(url))
    timeout = timeout or 5
    local requestCompleted = false
    local success, result = false, nil
    local requestThread = task.spawn(function()
        local fetchSuccess, fetchResult = pcall(game.HttpGet, game, url)
        if not fetchSuccess or #fetchResult == 0 then
            if #fetchResult == 0 then
                fetchResult = "Empty response"
            end
            success, result = false, fetchResult
            requestCompleted = true
            return
        end
        local content = fetchResult
        local execSuccess, execResult = pcall(function()
            return loadstring(content)()
        end)
        success, result = execSuccess, execResult
        requestCompleted = true
    end)
    local timeoutThread = task.delay(timeout, function()
        if not requestCompleted then
            warn("Request for " .. url .. " timed out after " .. tostring(timeout) .. " seconds")
            task.cancel(requestThread)
            result = "Request timed out"
            requestCompleted = true
        end
    end)
    while not requestCompleted do
        task.wait()
    end
    if coroutine.status(timeoutThread) ~= "dead" then
        task.cancel(timeoutThread)
    end
    if not success then
        warn("Failed to process " .. tostring(url) .. ": " .. tostring(result))
    end
    return if success then result else nil
end
local requestsDisabled = true
local InterfaceBuild = '3K3W'
local Release = "Build 1.68"
local RayfieldFolder = "Rayfield"
local ConfigurationFolder = RayfieldFolder.."/Configurations"
local ConfigurationExtension = ".rfld"
local settingsTable = {
    General = {
        rayfieldOpen = {Type = 'bind', Value = 'K', Name = 'Rayfield Keybind'},
    },
    System = {
        usageAnalytics = {Type = 'toggle', Value = true, Name = 'Anonymised Analytics'},
    }
}
local overriddenSettings: { [string]: any } = {}
local function overrideSetting(category: string, name: string, value: any)
    overriddenSettings[category .. "." .. name] = value
end
local function getSetting(category: string, name: string): any
    if overriddenSettings[category .. "." .. name] ~= nil then
        return overriddenSettings[category .. "." .. name]
    elseif settingsTable[category][name] ~= nil then
        return settingsTable[category][name].Value
    end
end
if requestsDisabled then
    overrideSetting("System", "usageAnalytics", false)
end
local HttpService = getService('HttpService')
local RunService = getService('RunService')
local useStudio = RunService:IsStudio() or false
local settingsCreated = false
local settingsInitialized = false
local cachedSettings
local prompt = useStudio and require(script.Parent.prompt) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/prompt.lua')
local requestFunc = (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request
if not prompt and not useStudio then
    warn("Failed to load prompt library, using fallback")
    prompt = {
        create = function() end
    }
end
local function callSafely(func, ...)
    if func then
        local success, result = pcall(func, ...)
        if not success then
            warn("Rayfield | Function failed with error: ", result)
            return false
        else
            return result
        end
    end
end
local function ensureFolder(folderPath)
    if isfolder and not callSafely(isfolder, folderPath) then
        callSafely(makefolder, folderPath)
    end
end
local function loadSettings()
    local file = nil
    local success, result = pcall(function()
        task.spawn(function()
            if callSafely(isfolder, RayfieldFolder) then
                if callSafely(isfile, RayfieldFolder..'/settings'..ConfigurationExtension) then
                    file = callSafely(readfile, RayfieldFolder..'/settings'..ConfigurationExtension)
                end
            end
            if useStudio then
                file = [[
        {"General":{"rayfieldOpen":{"Value":"K","Type":"bind","Name":"Rayfield Keybind","Element":{"HoldToInteract":false,"Ext":true,"Name":"Rayfield Keybind","Set":null,"CallOnChange":true,"Callback":null,"CurrentKeybind":"K"}}},"System":{"usageAnalytics":{"Value":false,"Type":"toggle","Name":"Anonymised Analytics","Element":{"Ext":true,"Name":"Anonymised Analytics","Set":null,"CurrentValue":false,"Callback":null}}}}
    ]]
            end
            if file then
                local success, decodedFile = pcall(function() return HttpService:JSONDecode(file) end)
                if success then
                    file = decodedFile
                else
                    file = {}
                end
            else
                file = {}
            end
            if not settingsCreated then
                cachedSettings = file
                return
            end
            if #file > 0 then
                for categoryName, settingCategory in pairs(settingsTable) do
                    if file[categoryName] then
                        for settingName, setting in pairs(settingCategory) do
                            if file[categoryName][settingName] then
                                setting.Value = file[categoryName][settingName].Value
                                setting.Element:Set(getSetting(categoryName, settingName))
                            end
                        end
                    end
                end
            else
                for settingName, settingValue in overriddenSettings do
                    local split = string.split(settingName, ".")
                    assert(#split == 2, "Rayfield | Invalid overridden setting name: " .. settingName)
                    local categoryName = split[1]
                    local settingNameOnly = split[2]
                    if settingsTable[categoryName] and settingsTable[categoryName][settingNameOnly] then
                        settingsTable[categoryName][settingNameOnly].Element:Set(settingValue)
                    end
                end
            end
            settingsInitialized = true
        end)
    end)
    if not success then
        if writefile then
            warn('Rayfield had an issue accessing configuration saving capability.')
        end
    end
end
if debugX then
    warn('Now Loading Settings Configuration')
end
loadSettings()
if debugX then
    warn('Settings Loaded')
end
local analyticsLib
local sendReport = function(ev_n, sc_n) warn("Failed to load report function") end
if not requestsDisabled then
    if debugX then
        warn('Querying Settings for Reporter Information')
    end
    analyticsLib = loadWithTimeout("https://analytics.sirius.menu/script")
    if not analyticsLib then
        warn("Failed to load analytics reporter")
        analyticsLib = nil
    elseif analyticsLib and type(analyticsLib.load) == "function" then
        analyticsLib:load()
    else
        warn("Analytics library loaded but missing load function")
        analyticsLib = nil
    end
    sendReport = function(ev_n, sc_n)
        if not (type(analyticsLib) == "table" and type(analyticsLib.isLoaded) == "function" and analyticsLib:isLoaded()) then
            warn("Analytics library not loaded")
            return
        end
        if useStudio then
            print('Sending Analytics')
        else
            if debugX then warn('Reporting Analytics') end
            analyticsLib:report(
                {
                    ["name"] = ev_n,
                    ["script"] = {["name"] = sc_n, ["version"] = Release}
                },
                {
                    ["version"] = InterfaceBuild
                }
            )
            if debugX then warn('Finished Report') end
        end
    end
    if cachedSettings and (#cachedSettings == 0 or (cachedSettings.System and cachedSettings.System.usageAnalytics and cachedSettings.System.usageAnalytics.Value)) then
        sendReport("execution", "Rayfield")
    elseif not cachedSettings then
        sendReport("execution", "Rayfield")
    end
end
local promptUser = 2
if promptUser == 1 and prompt and type(prompt.create) == "function" then
    prompt.create(
        'Be cautious when running scripts',
        [[Please be careful when running scripts from unknown developers. This script has already been ran. <font transparency='0.3'>Some scripts may steal your items or in-game goods.</font>]],
        'Okay',
        '',
        function()
        end
    )
end
if debugX then
    warn('Moving on to continue initialisation')
end
local RayfieldLibrary = {
    Flags = {},
    Theme = {
        Default = {
            TextColor = Color3.fromRGB(240, 240, 240),
            Background = Color3.fromRGB(25, 25, 25),
            Topbar = Color3.fromRGB(34, 34, 34),
            Shadow = Color3.fromRGB(20, 20, 20),
            NotificationBackground = Color3.fromRGB(20, 20, 20),
            NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
            TabBackground = Color3.fromRGB(80, 80, 80),
            TabStroke = Color3.fromRGB(85, 85, 85),
            TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
            TabTextColor = Color3.fromRGB(240, 240, 240),
            SelectedTabTextColor = Color3.fromRGB(50, 50, 50),
            ElementBackground = Color3.fromRGB(35, 35, 35),
            ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
            SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
            ElementStroke = Color3.fromRGB(50, 50, 50),
            SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
            SliderBackground = Color3.fromRGB(50, 138, 220),
            SliderProgress = Color3.fromRGB(50, 138, 220),
            SliderStroke = Color3.fromRGB(58, 163, 255),
            ToggleBackground = Color3.fromRGB(30, 30, 30),
            ToggleEnabled = Color3.fromRGB(0, 146, 214),
            ToggleDisabled = Color3.fromRGB(100, 100, 100),
            ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
            ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
            ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
            ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),
            DropdownSelected = Color3.fromRGB(40, 40, 40),
            DropdownUnselected = Color3.fromRGB(30, 30, 30),
            InputBackground = Color3.fromRGB(30, 30, 30),
            InputStroke = Color3.fromRGB(65, 65, 65),
            PlaceholderColor = Color3.fromRGB(178, 178, 178)
        },
        Ocean = {
            TextColor = Color3.fromRGB(230, 240, 240),
            Background = Color3.fromRGB(20, 30, 30),
            Topbar = Color3.fromRGB(25, 40, 40),
            Shadow = Color3.fromRGB(15, 20, 20),
            NotificationBackground = Color3.fromRGB(25, 35, 35),
            NotificationActionsBackground = Color3.fromRGB(230, 240, 240),
            TabBackground = Color3.fromRGB(40, 60, 60),
            TabStroke = Color3.fromRGB(50, 70, 70),
            TabBackgroundSelected = Color3.fromRGB(100, 180, 180),
            TabTextColor = Color3.fromRGB(210, 230, 230),
            SelectedTabTextColor = Color3.fromRGB(20, 50, 50),
            ElementBackground = Color3.fromRGB(30, 50, 50),
            ElementBackgroundHover = Color3.fromRGB(40, 60, 60),
            SecondaryElementBackground = Color3.fromRGB(30, 45, 45),
            ElementStroke = Color3.fromRGB(45, 70, 70),
            SecondaryElementStroke = Color3.fromRGB(40, 65, 65),
            SliderBackground = Color3.fromRGB(0, 110, 110),
            SliderProgress = Color3.fromRGB(0, 140, 140),
            SliderStroke = Color3.fromRGB(0, 160, 160),
            ToggleBackground = Color3.fromRGB(30, 50, 50),
            ToggleEnabled = Color3.fromRGB(0, 130, 130),
            ToggleDisabled = Color3.fromRGB(70, 90, 90),
            ToggleEnabledStroke = Color3.fromRGB(0, 160, 160),
            ToggleDisabledStroke = Color3.fromRGB(85, 105, 105),
            ToggleEnabledOuterStroke = Color3.fromRGB(50, 100, 100),
            ToggleDisabledOuterStroke = Color3.fromRGB(45, 65, 65),
            DropdownSelected = Color3.fromRGB(30, 60, 60),
            DropdownUnselected = Color3.fromRGB(25, 40, 40),
            InputBackground = Color3.fromRGB(30, 50, 50),
            InputStroke = Color3.fromRGB(50, 70, 70),
            PlaceholderColor = Color3.fromRGB(140, 160, 160)
        },
        AmberGlow = {
            TextColor = Color3.fromRGB(255, 245, 230),
            Background = Color3.fromRGB(45, 30, 20),
            Topbar = Color3.fromRGB(55, 40, 25),
            Shadow = Color3.fromRGB(35, 25, 15),
            NotificationBackground = Color3.fromRGB(50, 35, 25),
            NotificationActionsBackground = Color3.fromRGB(245, 230, 215),
            TabBackground = Color3.fromRGB(75, 50, 35),
            TabStroke = Color3.fromRGB(90, 60, 45),
            TabBackgroundSelected = Color3.fromRGB(230, 180, 100),
            TabTextColor = Color3.fromRGB(250, 220, 200),
            SelectedTabTextColor = Color3.fromRGB(50, 30, 10),
            ElementBackground = Color3.fromRGB(60, 45, 35),
            ElementBackgroundHover = Color3.fromRGB(70, 50, 40),
            SecondaryElementBackground = Color3.fromRGB(55, 40, 30),
            ElementStroke = Color3.fromRGB(85, 60, 45),
            SecondaryElementStroke = Color3.fromRGB(75, 50, 35),
            SliderBackground = Color3.fromRGB(220, 130, 60),
            SliderProgress = Color3.fromRGB(250, 150, 75),
            SliderStroke = Color3.fromRGB(255, 170, 85),
            ToggleBackground = Color3.fromRGB(55, 40, 30),
            ToggleEnabled = Color3.fromRGB(240, 130, 30),
            ToggleDisabled = Color3.fromRGB(90, 70, 60),
            ToggleEnabledStroke = Color3.fromRGB(255, 160, 50),
            ToggleDisabledStroke = Color3.fromRGB(110, 85, 75),
            ToggleEnabledOuterStroke = Color3.fromRGB(200, 100, 50),
            ToggleDisabledOuterStroke = Color3.fromRGB(75, 60, 55),
            DropdownSelected = Color3.fromRGB(70, 50, 40),
            DropdownUnselected = Color3.fromRGB(55, 40, 30),
            InputBackground = Color3.fromRGB(60, 45, 35),
            InputStroke = Color3.fromRGB(90, 65, 50),
            PlaceholderColor = Color3.fromRGB(190, 150, 130)
        },
        Light = {
            TextColor = Color3.fromRGB(40, 40, 40),
            Background = Color3.fromRGB(245, 245, 245),
            Topbar = Color3.fromRGB(230, 230, 230),
            Shadow = Color3.fromRGB(200, 200, 200),
            NotificationBackground = Color3.fromRGB(250, 250, 250),
            NotificationActionsBackground = Color3.fromRGB(240, 240, 240),
            TabBackground = Color3.fromRGB(235, 235, 235),
            TabStroke = Color3.fromRGB(215, 215, 215),
            TabBackgroundSelected = Color3.fromRGB(255, 255, 255),
            TabTextColor = Color3.fromRGB(80, 80, 80),
            SelectedTabTextColor = Color3.fromRGB(0, 0, 0),
            ElementBackground = Color3.fromRGB(240, 240, 240),
            ElementBackgroundHover = Color3.fromRGB(225, 225, 225),
            SecondaryElementBackground = Color3.fromRGB(235, 235, 235),
            ElementStroke = Color3.fromRGB(210, 210, 210),
            SecondaryElementStroke = Color3.fromRGB(210, 210, 210),
            SliderBackground = Color3.fromRGB(150, 180, 220),
            SliderProgress = Color3.fromRGB(100, 150, 200),
            SliderStroke = Color3.fromRGB(120, 170, 220),
            ToggleBackground = Color3.fromRGB(220, 220, 220),
            ToggleEnabled = Color3.fromRGB(0, 146, 214),
            ToggleDisabled = Color3.fromRGB(150, 150, 150),
            ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
            ToggleDisabledStroke = Color3.fromRGB(170, 170, 170),
            ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
            ToggleDisabledOuterStroke = Color3.fromRGB(180, 180, 180),
            DropdownSelected = Color3.fromRGB(230, 230, 230),
            DropdownUnselected = Color3.fromRGB(220, 220, 220),
            InputBackground = Color3.fromRGB(240, 240, 240),
            InputStroke = Color3.fromRGB(180, 180, 180),
            PlaceholderColor = Color3.fromRGB(140, 140, 140)
        },
        Amethyst = {
            TextColor = Color3.fromRGB(240, 240, 240),
            Background = Color3.fromRGB(30, 20, 40),
            Topbar = Color3.fromRGB(40, 25, 50),
            Shadow = Color3.fromRGB(20, 15, 30),
            NotificationBackground = Color3.fromRGB(35, 20, 40),
            NotificationActionsBackground = Color3.fromRGB(240, 240, 250),
            TabBackground = Color3.fromRGB(60, 40, 80),
            TabStroke = Color3.fromRGB(70, 45, 90),
            TabBackgroundSelected = Color3.fromRGB(180, 140, 200),
            TabTextColor = Color3.fromRGB(230, 230, 240),
            SelectedTabTextColor = Color3.fromRGB(50, 20, 50),
            ElementBackground = Color3.fromRGB(45, 30, 60),
            ElementBackgroundHover = Color3.fromRGB(50, 35, 70),
            SecondaryElementBackground = Color3.fromRGB(40, 30, 55),
            ElementStroke = Color3.fromRGB(70, 50, 85),
            SecondaryElementStroke = Color3.fromRGB(65, 45, 80),
            SliderBackground = Color3.fromRGB(100, 60, 150),
            SliderProgress = Color3.fromRGB(130, 80, 180),
            SliderStroke = Color3.fromRGB(150, 100, 200),
            ToggleBackground = Color3.fromRGB(45, 30, 55),
            ToggleEnabled = Color3.fromRGB(120, 60, 150),
            ToggleDisabled = Color3.fromRGB(94, 47, 117),
            ToggleEnabledStroke = Color3.fromRGB(140, 80, 170),
            ToggleDisabledStroke = Color3.fromRGB(124, 71, 150),
            ToggleEnabledOuterStroke = Color3.fromRGB(90, 40, 120),
            ToggleDisabledOuterStroke = Color3.fromRGB(80, 50, 110),
            DropdownSelected = Color3.fromRGB(50, 35, 70),
            DropdownUnselected = Color3.fromRGB(35, 25, 50),
            InputBackground = Color3.fromRGB(45, 30, 60),
            InputStroke = Color3.fromRGB(80, 50, 110),
            PlaceholderColor = Color3.fromRGB(178, 150, 200)
        },
        Green = {
            TextColor = Color3.fromRGB(30, 60, 30),
            Background = Color3.fromRGB(235, 245, 235),
            Topbar = Color3.fromRGB(210, 230, 210),
            Shadow = Color3.fromRGB(200, 220, 200),
            NotificationBackground = Color3.fromRGB(240, 250, 240),
            NotificationActionsBackground = Color3.fromRGB(220, 235, 220),
            TabBackground = Color3.fromRGB(215, 235, 215),
            TabStroke = Color3.fromRGB(190, 210, 190),
            TabBackgroundSelected = Color3.fromRGB(245, 255, 245),
            TabTextColor = Color3.fromRGB(50, 80, 50),
            SelectedTabTextColor = Color3.fromRGB(20, 60, 20),
            ElementBackground = Color3.fromRGB(225, 240, 225),
            ElementBackgroundHover = Color3.fromRGB(210, 225, 210),
            SecondaryElementBackground = Color3.fromRGB(235, 245, 235),
            ElementStroke = Color3.fromRGB(180, 200, 180),
            SecondaryElementStroke = Color3.fromRGB(180, 200, 180),
            SliderBackground = Color3.fromRGB(90, 160, 90),
            SliderProgress = Color3.fromRGB(70, 130, 70),
            SliderStroke = Color3.fromRGB(100, 180, 100),
            ToggleBackground = Color3.fromRGB(215, 235, 215),
            ToggleEnabled = Color3.fromRGB(60, 130, 60),
            ToggleDisabled = Color3.fromRGB(150, 175, 150),
            ToggleEnabledStroke = Color3.fromRGB(80, 150, 80),
            ToggleDisabledStroke = Color3.fromRGB(130, 150, 130),
            ToggleEnabledOuterStroke = Color3.fromRGB(100, 160, 100),
            ToggleDisabledOuterStroke = Color3.fromRGB(160, 180, 160),
            DropdownSelected = Color3.fromRGB(225, 240, 225),
            DropdownUnselected = Color3.fromRGB(210, 225, 210),
            InputBackground = Color3.fromRGB(235, 245, 235),
            InputStroke = Color3.fromRGB(180, 200, 180),
            PlaceholderColor = Color3.fromRGB(120, 140, 120)
        },
        Bloom = {
            TextColor = Color3.fromRGB(60, 40, 50),
            Background = Color3.fromRGB(255, 240, 245),
            Topbar = Color3.fromRGB(250, 220, 225),
            Shadow = Color3.fromRGB(230, 190, 195),
            NotificationBackground = Color3.fromRGB(255, 235, 240),
            NotificationActionsBackground = Color3.fromRGB(245, 215, 225),
            TabBackground = Color3.fromRGB(240, 210, 220),
            TabStroke = Color3.fromRGB(230, 200, 210),
            TabBackgroundSelected = Color3.fromRGB(255, 225, 235),
            TabTextColor = Color3.fromRGB(80, 40, 60),
            SelectedTabTextColor = Color3.fromRGB(50, 30, 50),
            ElementBackground = Color3.fromRGB(255, 235, 240),
            ElementBackgroundHover = Color3.fromRGB(245, 220, 230),
            SecondaryElementBackground = Color3.fromRGB(255, 235, 240),
            ElementStroke = Color3.fromRGB(230, 200, 210),
            SecondaryElementStroke = Color3.fromRGB(230, 200, 210),
            SliderBackground = Color3.fromRGB(240, 130, 160),
            SliderProgress = Color3.fromRGB(250, 160, 180),
            SliderStroke = Color3.fromRGB(255, 180, 200),
            ToggleBackground = Color3.fromRGB(240, 210, 220),
            ToggleEnabled = Color3.fromRGB(255, 140, 170),
            ToggleDisabled = Color3.fromRGB(200, 180, 185),
            ToggleEnabledStroke = Color3.fromRGB(250, 160, 190),
            ToggleDisabledStroke = Color3.fromRGB(210, 180, 190),
            ToggleEnabledOuterStroke = Color3.fromRGB(220, 160, 180),
            ToggleDisabledOuterStroke = Color3.fromRGB(190, 170, 180),
            DropdownSelected = Color3.fromRGB(250, 220, 225),
            DropdownUnselected = Color3.fromRGB(240, 210, 220),
            InputBackground = Color3.fromRGB(255, 235, 240),
            InputStroke = Color3.fromRGB(220, 190, 200),
            PlaceholderColor = Color3.fromRGB(170, 130, 140)
        },
        DarkBlue = {
            TextColor = Color3.fromRGB(230, 230, 230),
            Background = Color3.fromRGB(20, 25, 30),
            Topbar = Color3.fromRGB(30, 35, 40),
            Shadow = Color3.fromRGB(15, 20, 25),
            NotificationBackground = Color3.fromRGB(25, 30, 35),
            NotificationActionsBackground = Color3.fromRGB(45, 50, 55),
            TabBackground = Color3.fromRGB(35, 40, 45),
            TabStroke = Color3.fromRGB(45, 50, 60),
            TabBackgroundSelected = Color3.fromRGB(40, 70, 100),
            TabTextColor = Color3.fromRGB(200, 200, 200),
            SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
            ElementBackground = Color3.fromRGB(30, 35, 40),
            ElementBackgroundHover = Color3.fromRGB(40, 45, 50),
            SecondaryElementBackground = Color3.fromRGB(35, 40, 45),
            ElementStroke = Color3.fromRGB(45, 50, 60),
            SecondaryElementStroke = Color3.fromRGB(40, 45, 55),
            SliderBackground = Color3.fromRGB(0, 90, 180),
            SliderProgress = Color3.fromRGB(0, 120, 210),
            SliderStroke = Color3.fromRGB(0, 150, 240),
            ToggleBackground = Color3.fromRGB(35, 40, 45),
            ToggleEnabled = Color3.fromRGB(0, 120, 210),
            ToggleDisabled = Color3.fromRGB(70, 70, 80),
            ToggleEnabledStroke = Color3.fromRGB(0, 150, 240),
            ToggleDisabledStroke = Color3.fromRGB(75, 75, 85),
            ToggleEnabledOuterStroke = Color3.fromRGB(20, 100, 180),
            ToggleDisabledOuterStroke = Color3.fromRGB(55, 55, 65),
            DropdownSelected = Color3.fromRGB(30, 70, 90),
            DropdownUnselected = Color3.fromRGB(25, 30, 35),
            InputBackground = Color3.fromRGB(25, 30, 35),
            InputStroke = Color3.fromRGB(45, 50, 60),
            PlaceholderColor = Color3.fromRGB(150, 150, 160)
        },
        Serenity = {
            TextColor = Color3.fromRGB(50, 55, 60),
            Background = Color3.fromRGB(240, 245, 250),
            Topbar = Color3.fromRGB(215, 225, 235),
            Shadow = Color3.fromRGB(200, 210, 220),
            NotificationBackground = Color3.fromRGB(210, 220, 230),
            NotificationActionsBackground = Color3.fromRGB(225, 230, 240),
            TabBackground = Color3.fromRGB(200, 210, 220),
            TabStroke = Color3.fromRGB(180, 190, 200),
            TabBackgroundSelected = Color3.fromRGB(175, 185, 200),
            TabTextColor = Color3.fromRGB(50, 55, 60),
            SelectedTabTextColor = Color3.fromRGB(30, 35, 40),
            ElementBackground = Color3.fromRGB(210, 220, 230),
            ElementBackgroundHover = Color3.fromRGB(220, 230, 240),
            SecondaryElementBackground = Color3.fromRGB(200, 210, 220),
            ElementStroke = Color3.fromRGB(190, 200, 210),
            SecondaryElementStroke = Color3.fromRGB(180, 190, 200),
            SliderBackground = Color3.fromRGB(200, 220, 235),
            SliderProgress = Color3.fromRGB(70, 130, 180),
            SliderStroke = Color3.fromRGB(150, 180, 220),
            ToggleBackground = Color3.fromRGB(210, 220, 230),
            ToggleEnabled = Color3.fromRGB(70, 160, 210),
            ToggleDisabled = Color3.fromRGB(180, 180, 180),
            ToggleEnabledStroke = Color3.fromRGB(60, 150, 200),
            ToggleDisabledStroke = Color3.fromRGB(140, 140, 140),
            ToggleEnabledOuterStroke = Color3.fromRGB(100, 120, 140),
            ToggleDisabledOuterStroke = Color3.fromRGB(120, 120, 130),
            DropdownSelected = Color3.fromRGB(220, 230, 240),
            DropdownUnselected = Color3.fromRGB(200, 210, 220),
            InputBackground = Color3.fromRGB(220, 230, 240),
            InputStroke = Color3.fromRGB(180, 190, 200),
            PlaceholderColor = Color3.fromRGB(150, 150, 150)
        },
    }
}
local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")
local Rayfield = useStudio and script.Parent:FindFirstChild('Rayfield') or game:GetObjects("rbxassetid://10804731440")[1]
local buildAttempts = 0
local correctBuild = false
local warned
local globalLoaded
local rayfieldDestroyed = false
repeat
    if Rayfield:FindFirstChild('Build') and Rayfield.Build.Value == InterfaceBuild then
        correctBuild = true
        break
    end
    correctBuild = false
    if not warned then
        warn('Rayfield | Build Mismatch')
        print('Rayfield may encounter issues as you are running an incompatible interface version ('.. ((Rayfield:FindFirstChild('Build') and Rayfield.Build.Value) or 'No Build') ..').\n\nThis version of Rayfield is intended for interface build '..InterfaceBuild..'.')
        warned = true
    end
    toDestroy, Rayfield = Rayfield, useStudio and script.Parent:FindFirstChild('Rayfield') or game:GetObjects("rbxassetid://10804731440")[1]
    if toDestroy and not useStudio then toDestroy:Destroy() end
    buildAttempts = buildAttempts + 1
until buildAttempts >= 2
Rayfield.Enabled = false
if gethui then
    Rayfield.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(Rayfield)
    Rayfield.Parent = CoreGui
elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
    Rayfield.Parent = CoreGui:FindFirstChild("RobloxGui")
elseif not useStudio then
    Rayfield.Parent = CoreGui
end
if gethui then
    for _, Interface in ipairs(gethui():GetChildren()) do
        if Interface.Name == Rayfield.Name and Interface ~= Rayfield then
            Interface.Enabled = false
            Interface.Name = "Rayfield-Old"
        end
    end
elseif not useStudio then
    for _, Interface in ipairs(CoreGui:GetChildren()) do
        if Interface.Name == Rayfield.Name and Interface ~= Rayfield then
            Interface.Enabled = false
            Interface.Name = "Rayfield-Old"
        end
    end
end
local minSize = Vector2.new(1024, 768)
local useMobileSizing
if Rayfield.AbsoluteSize.X < minSize.X and Rayfield.AbsoluteSize.Y < minSize.Y then
    useMobileSizing = true
end
if UserInputService.TouchEnabled then
    useMobilePrompt = true
end
local Main = Rayfield.Main
local MPrompt = Rayfield:FindFirstChild('Prompt')
local Topbar = Main.Topbar
local Elements = Main.Elements
local LoadingFrame = Main.LoadingFrame
local TabList = Main.TabList
local dragBar = Rayfield:FindFirstChild('Drag')
local dragInteract = dragBar and dragBar.Interact or nil
local dragBarCosmetic = dragBar and dragBar.Drag or nil
local dragOffset = 255
local dragOffsetMobile = 150
Rayfield.DisplayOrder = 100
LoadingFrame.Version.Text = Release
local Icons = useStudio and require(script.Parent.icons) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua')
local CFileName = nil
local CEnabled = false
local Minimised = false
local Hidden = false
local Debounce = false
local searchOpen = false
local Notifications = Rayfield.Notifications
local keybindConnections = {}
local SelectedTheme = RayfieldLibrary.Theme.Default
local function ChangeTheme(Theme)
    if typeof(Theme) == 'string' then
        SelectedTheme = RayfieldLibrary.Theme[Theme]
    elseif typeof(Theme) == 'table' then
        SelectedTheme = Theme
    end
    Rayfield.Main.BackgroundColor3 = SelectedTheme.Background
    Rayfield.Main.Topbar.BackgroundColor3 = SelectedTheme.Topbar
    Rayfield.Main.Topbar.CornerRepair.BackgroundColor3 = SelectedTheme.Topbar
    Rayfield.Main.Shadow.Image.ImageColor3 = SelectedTheme.Shadow
    Rayfield.Main.Topbar.ChangeSize.ImageColor3 = SelectedTheme.TextColor
    Rayfield.Main.Topbar.Hide.ImageColor3 = SelectedTheme.TextColor
    Rayfield.Main.Topbar.Search.ImageColor3 = SelectedTheme.TextColor
    if Topbar:FindFirstChild('Settings') then
        Rayfield.Main.Topbar.Settings.ImageColor3 = SelectedTheme.TextColor
        Rayfield.Main.Topbar.Divider.BackgroundColor3 = SelectedTheme.ElementStroke
    end
    Main.Search.BackgroundColor3 = SelectedTheme.TextColor
    Main.Search.Shadow.ImageColor3 = SelectedTheme.TextColor
    Main.Search.Search.ImageColor3 = SelectedTheme.TextColor
    Main.Search.Input.PlaceholderColor3 = SelectedTheme.TextColor
    Main.Search.UIStroke.Color = SelectedTheme.SecondaryElementStroke
    if Main:FindFirstChild('Notice') then
        Main.Notice.BackgroundColor3 = SelectedTheme.Background
    end
    for _, text in ipairs(Rayfield:GetDescendants()) do
        if text.Parent.Parent ~= Notifications then
            if text:IsA('TextLabel') or text:IsA('TextBox') then text.TextColor3 = SelectedTheme.TextColor end
        end
    end
    for _, TabPage in ipairs(Elements:GetChildren()) do
        for _, Element in ipairs(TabPage:GetChildren()) do
            if Element.ClassName == "Frame" and Element.Name ~= "Placeholder" and Element.Name ~= "SectionSpacing" and Element.Name ~= "Divider" and Element.Name ~= "SectionTitle" and Element.Name ~= "SearchTitle-fsefsefesfsefesfesfThanks" then
                Element.BackgroundColor3 = SelectedTheme.ElementBackground
                Element.UIStroke.Color = SelectedTheme.ElementStroke
            end
        end
    end
end
local function getIcon(name : string): {id: number, imageRectSize: Vector2, imageRectOffset: Vector2}
    if not Icons then
        warn("Lucide Icons: Cannot use icons as icons library is not loaded")
        return
    end
    name = string.match(string.lower(name), "^%s*(.*)%s*$") :: string
    local sizedicons = Icons['48px']
    local r = sizedicons[name]
    if not r then
        error("Lucide Icons: Failed to find icon by the name of \"" .. name .. "\"", 2)
    end
    local rirs = r[2]
    local riro = r[3]
    if type(r[1]) ~= "number" or type(rirs) ~= "table" or type(riro) ~= "table" then
        error("Lucide Icons: Internal error: Invalid auto-generated asset entry")
    end
    local irs = Vector2.new(rirs[1], rirs[2])
    local iro = Vector2.new(riro[1], riro[2])
    local asset = {
        id = r[1],
        imageRectSize = irs,
        imageRectOffset = iro,
    }
    return asset
end
local function getAssetUri(id: any): string
    local assetUri = "rbxassetid://0"
    if type(id) == "number" then
        assetUri = "rbxassetid://" .. id
    elseif type(id) == "string" and not Icons then
        warn("Rayfield | Cannot use Lucide icons as icons library is not loaded")
    else
        warn("Rayfield | The icon argument must either be an icon ID (number) or a Lucide icon name (string)")
    end
    return assetUri
end
local function makeDraggable(object, dragObject, enableTaptic, tapticOffset)
    local dragging = false
    local relative = nil
    local offset = Vector2.zero
    local screenGui = object:FindFirstAncestorWhichIsA("ScreenGui")
    if screenGui and screenGui.IgnoreGuiInset then
        offset += getService('GuiService'):GetGuiInset()
    end
    local function connectFunctions()
        if dragBar and enableTaptic then
            dragBar.MouseEnter:Connect(function()
                if not dragging and not Hidden then
                    TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5, Size = UDim2.new(0, 120, 0, 4)}):Play()
                end
            end)
            dragBar.MouseLeave:Connect(function()
                if not dragging and not Hidden then
                    TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7, Size = UDim2.new(0, 100, 0, 4)}):Play()
                end
            end)
        end
    end
    connectFunctions()
    dragObject.InputBegan:Connect(function(input, processed)
        if processed then return end
        local inputType = input.UserInputType.Name
        if inputType == "MouseButton1" or inputType == "Touch" then
            dragging = true
            relative = object.AbsolutePosition + object.AbsoluteSize * object.AnchorPoint - UserInputService:GetMouseLocation()
            if enableTaptic and not Hidden then
                TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 110, 0, 4), BackgroundTransparency = 0}):Play()
            end
        end
    end)
    local inputEnded = UserInputService.InputEnded:Connect(function(input)
        if not dragging then return end
        local inputType = input.UserInputType.Name
        if inputType == "MouseButton1" or inputType == "Touch" then
            dragging = false
            connectFunctions()
            if enableTaptic and not Hidden then
                TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 100, 0, 4), BackgroundTransparency = 0.7}):Play()
            end
        end
    end)
    local renderStepped = RunService.RenderStepped:Connect(function()
        if dragging and not Hidden then
            local position = UserInputService:GetMouseLocation() + relative + offset
            if enableTaptic and tapticOffset then
                TweenService:Create(object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(position.X, position.Y)}):Play()
                TweenService:Create(dragObject.Parent, TweenInfo.new(0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(position.X, position.Y + ((useMobileSizing and tapticOffset[2]) or tapticOffset[1]))}):Play()
            else
                if dragBar and tapticOffset then
                    dragBar.Position = UDim2.fromOffset(position.X, position.Y + ((useMobileSizing and tapticOffset[2]) or tapticOffset[1]))
                end
                object.Position = UDim2.fromOffset(position.X, position.Y)
            end
        end
    end)
    object.Destroying:Connect(function()
        if inputEnded then inputEnded:Disconnect() end
        if renderStepped then renderStepped:Disconnect() end
    end)
end
local function PackColor(Color)
    return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end
local function UnpackColor(Color)
    return Color3.fromRGB(Color.R, Color.G, Color.B)
end
local function LoadConfiguration(Configuration)
    local success, Data = pcall(function() return HttpService:JSONDecode(Configuration) end)
    local changed
    if not success then warn('Rayfield had an issue decoding the configuration file, please try delete the file and reopen Rayfield.') return end
    for FlagName, Flag in pairs(RayfieldLibrary.Flags) do
        local FlagValue = Data[FlagName]
        if (typeof(FlagValue) == 'boolean' and FlagValue == false) or FlagValue then
            task.spawn(function()
                if Flag.Type == "ColorPicker" then
                    changed = true
                    Flag:Set(UnpackColor(FlagValue))
                else
                    if (Flag.CurrentValue or Flag.CurrentKeybind or Flag.CurrentOption or Flag.Color) ~= FlagValue then
                        changed = true
                        Flag:Set(FlagValue)
                    end
                end
            end)
        else
            warn("Rayfield | Unable to find '"..FlagName.. "' in the save file.")
            print("The error above may not be an issue if new elements have been added or not been set values.")
        end
    end
    return changed
end
local function SaveConfiguration()
    if not CEnabled or not globalLoaded then return end
    if debugX then
        print('Saving')
    end
    local Data = {}
    for i, v in pairs(RayfieldLibrary.Flags) do
        if v.Type == "ColorPicker" then
            Data[i] = PackColor(v.Color)
        else
            if typeof(v.CurrentValue) == 'boolean' then
                if v.CurrentValue == false then
                    Data[i] = false
                else
                    Data[i] = v.CurrentValue or v.CurrentKeybind or v.CurrentOption or v.Color
                end
            else
                Data[i] = v.CurrentValue or v.CurrentKeybind or v.CurrentOption or v.Color
            end
        end
    end
    if useStudio then
        if script.Parent:FindFirstChild('configuration') then script.Parent.configuration:Destroy() end
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = script.Parent
        ScreenGui.Name = 'configuration'
        local TextBox = Instance.new("TextBox")
        TextBox.Parent = ScreenGui
        TextBox.Size = UDim2.new(0, 800, 0, 50)
        TextBox.AnchorPoint = Vector2.new(0.5, 0)
        TextBox.Position = UDim2.new(0.5, 0, 0, 30)
        TextBox.Text = HttpService:JSONEncode(Data)
        TextBox.ClearTextOnFocus = false
    end
    if debugX then
        warn(HttpService:JSONEncode(Data))
    end
    callSafely(writefile, ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension, tostring(HttpService:JSONEncode(Data)))
end
function RayfieldLibrary:Notify(data)
    task.spawn(function()
        local newNotification = Notifications.Template:Clone()
        newNotification.Name = data.Title or 'No Title Provided'
        newNotification.Parent = Notifications
        newNotification.LayoutOrder = #Notifications:GetChildren()
        newNotification.Visible = false
        newNotification.Title.Text = data.Title or "Unknown Title"
        newNotification.Description.Text = data.Content or "Unknown Content"
        if data.Image then
            if typeof(data.Image) == 'string' and Icons then
                local asset = getIcon(data.Image)
                newNotification.Icon.Image = 'rbxassetid://'..asset.id
                newNotification.Icon.ImageRectOffset = asset.imageRectOffset
                newNotification.Icon.ImageRectSize = asset.imageRectSize
            else
                newNotification.Icon.Image = getAssetUri(data.Image)
            end
        else
            newNotification.Icon.Image = "rbxassetid://" .. 0
        end
        newNotification.Title.TextColor3 = SelectedTheme.TextColor
        newNotification.Description.TextColor3 = SelectedTheme.TextColor
        newNotification.BackgroundColor3 = SelectedTheme.Background
        newNotification.UIStroke.Color = SelectedTheme.TextColor
        newNotification.Icon.ImageColor3 = SelectedTheme.TextColor
        newNotification.BackgroundTransparency = 1
        newNotification.Title.TextTransparency = 1
        newNotification.Description.TextTransparency = 1
        newNotification.UIStroke.Transparency = 1
        newNotification.Shadow.ImageTransparency = 1
        newNotification.Size = UDim2.new(1, 0, 0, 800)
        newNotification.Icon.ImageTransparency = 1
        newNotification.Icon.BackgroundTransparency = 1
        task.wait()
        newNotification.Visible = true
        if data.Actions then
            warn('Rayfield | Not seeing your actions in notifications?')
            print("Notification Actions are being sunset for now, keep up to date on when they're back in the discord. (sirius.menu/discord)")
        end
        local bounds = {newNotification.Title.TextBounds.Y, newNotification.Description.TextBounds.Y}
        newNotification.Size = UDim2.new(1, -60, 0, -Notifications:FindFirstChild("UIListLayout").Padding.Offset)
        newNotification.Icon.Size = UDim2.new(0, 32, 0, 32)
        newNotification.Icon.Position = UDim2.new(0, 20, 0.5, 0)
        TweenService:Create(newNotification, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, math.max(bounds[1] + bounds[2] + 31, 60))}):Play()
        task.wait(0.15)
        TweenService:Create(newNotification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.45}):Play()
        TweenService:Create(newNotification.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
        task.wait(0.05)
        TweenService:Create(newNotification.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
        task.wait(0.05)
        TweenService:Create(newNotification.Description, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.35}):Play()
        TweenService:Create(newNotification.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.95}):Play()
        TweenService:Create(newNotification.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.82}):Play()
        local waitDuration = math.min(math.max((#newNotification.Description.Text * 0.1) + 2.5, 3), 10)
        task.wait(data.Duration or waitDuration)
        newNotification.Icon.Visible = false
        TweenService:Create(newNotification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
        TweenService:Create(newNotification.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
        TweenService:Create(newNotification.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
        TweenService:Create(newNotification.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
        TweenService:Create(newNotification.Description, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
        TweenService:Create(newNotification, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -90, 0, 0)}):Play()
        task.wait(1)
        TweenService:Create(newNotification, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -90, 0, -Notifications:FindFirstChild("UIListLayout").Padding.Offset)}):Play()
        newNotification.Visible = false
        newNotification:Destroy()
    end)
end
local function openSearch()
    searchOpen = true
    Main.Search.BackgroundTransparency = 1
    Main.Search.Shadow.ImageTransparency = 1
    Main.Search.Input.TextTransparency = 1
    Main.Search.Search.ImageTransparency = 1
    Main.Search.UIStroke.Transparency = 1
    Main.Search.Size = UDim2.new(1, 0, 0, 80)
    Main.Search.Position = UDim2.new(0.5, 0, 0, 70)
    Main.Search.Input.Interactable = true
    Main.Search.Visible = true
    for _, tabbtn in ipairs(TabList:GetChildren()) do
        if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
            tabbtn.Interact.Visible = false
            TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
            TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
            TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
            TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
        end
    end
    Main.Search.Input:CaptureFocus()
    TweenService:Create(Main.Search.Shadow, TweenInfo.new(0.05, Enum.EasingStyle.Quint), {ImageTransparency = 0.95}):Play()
    TweenService:Create(Main.Search, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 0, 0, 57), BackgroundTransparency = 0.9}):Play()
    TweenService:Create(Main.Search.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.8}):Play()
    TweenService:Create(Main.Search.Input, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
    TweenService:Create(Main.Search.Search, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.5}):Play()
    TweenService:Create(Main.Search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -35, 0, 35)}):Play()
end
local function closeSearch()
    searchOpen = false
    TweenService:Create(Main.Search, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {BackgroundTransparency = 1, Size = UDim2.new(1, -55, 0, 30)}):Play()
    TweenService:Create(Main.Search.Search, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
    TweenService:Create(Main.Search.Shadow, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
    TweenService:Create(Main.Search.UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
    TweenService:Create(Main.Search.Input, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
    for _, tabbtn in ipairs(TabList:GetChildren()) do
        if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
            tabbtn.Interact.Visible = true
            if tostring(Elements.UIPageLayout.CurrentPage) == tabbtn.Title.Text then
                TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
                TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
                TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
                TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
            else
                TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
                TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
                TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
                TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
            end
        end
    end
    Main.Search.Input.Text = ''
    Main.Search.Input.Interactable = false
end
local function Hide(notify: boolean?)
    if MPrompt then
        MPrompt.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        MPrompt.Position = UDim2.new(0.5, 0, 0, -50)
        MPrompt.Size = UDim2.new(0, 40, 0, 10)
        MPrompt.BackgroundTransparency = 1
        MPrompt.Title.TextTransparency = 1
        MPrompt.Visible = true
    end
    task.spawn(closeSearch)
    Debounce = true
    if notify then
        if useMobilePrompt then
            RayfieldLibrary:Notify({Title = "Interface Hidden", Content = "The interface has been hidden, you can unhide the interface by tapping 'Show'.", Duration = 7, Image = 4400697855})
        else
            RayfieldLibrary:Notify({Title = "Interface Hidden", Content = "The interface has been hidden, you can unhide the interface by tapping " .. tostring(getSetting("General", "rayfieldOpen")) .. ".", Duration = 7, Image = 4400697855})
        end
    end
    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 470, 0, 0)}):Play()
    TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 470, 0, 45)}):Play()
    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Main.Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Main.Topbar.CornerRepair, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Main.Topbar.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
    TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
    TweenService:Create(Topbar.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
    TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    if useMobilePrompt and MPrompt then
        TweenService:Create(MPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 120, 0, 30), Position = UDim2.new(0.5, 0, 0, 20), BackgroundTransparency = 0.3}):Play()
        TweenService:Create(MPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.3}):Play()
    end
    for _, TopbarButton in ipairs(Topbar:GetChildren()) do
        if TopbarButton.ClassName == "ImageButton" then
            TweenService:Create(TopbarButton, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
        end
    end
    for _, tabbtn in ipairs(TabList:GetChildren()) do
        if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
            TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
            TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
            TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
            TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
        end
    end
    dragInteract.Visible = false
    for _, tab in ipairs(Elements:GetChildren()) do
        if tab.Name ~= "Template" and tab.ClassName == "ScrollingFrame" and tab.Name ~= "Placeholder" then
            for _, element in ipairs(tab:GetChildren()) do
                if element.ClassName == "Frame" then
                    if element.Name ~= "SectionSpacing" and element.Name ~= "Placeholder" then
                        if element.Name == "SectionTitle" or element.Name == 'SearchTitle-fsefsefesfsefesfesfThanks' then
                            TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                        elseif element.Name == 'Divider' then
                            TweenService:Create(element.Divider, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
                        else
                            TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
                            TweenService:Create(element.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
                            TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                        end
                        for _, child in ipairs(element:GetChildren()) do
                            if child.ClassName == "Frame" or child.ClassName == "TextLabel" or child.ClassName == "TextBox" or child.ClassName == "ImageButton" or child.ClassName == "ImageLabel" then
                                child.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end
    task.wait(0.5)
    Main.Visible = false
    Debounce = false
end
local function Maximise()
    Debounce = true
    Topbar.ChangeSize.Image = "rbxassetid://"..10137941941
    TweenService:Create(Topbar.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
    TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()
    TweenService:Create(Topbar.CornerRepair, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
    TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7}):Play()
    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 400, 0, 600)}):Play()
    TweenService:Create(Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 400, 0, 45)}):Play()
    TabList.Visible = true
    task.wait(0.2)
    Elements.Visible = true
    for _, tab in ipairs(Elements:GetChildren()) do
        if tab.Name ~= "Template" and tab.ClassName == "ScrollingFrame" and tab.Name ~= "Placeholder" then
            for _, element in ipairs(tab:GetChildren()) do
                if element.ClassName == "Frame" then
                    if element.Name ~= "SectionSpacing" and element.Name ~= "Placeholder" then
                        if element.Name == "SectionTitle" or element.Name == 'SearchTitle-fsefsefesfsefesfesfThanks' then
                            TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.4}):Play()
                        elseif element.Name == 'Divider' then
                            TweenService:Create(element.Divider, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.85}):Play()
                        else
                            TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
                            TweenService:Create(element.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
                            TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
                        end
                        for _, child in ipairs(element:GetChildren()) do
                            if child.ClassName == "Frame" or child.ClassName == "TextLabel" or child.ClassName == "TextBox" or child.ClassName == "ImageButton" or child.ClassName == "ImageLabel" then
                                child.Visible = true
                            end
                        end
                    end
                end
            end
        end
    end
    task.wait(0.1)
    for _, tabbtn in ipairs(TabList:GetChildren()) do
        if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
            if tostring(Elements.UIPageLayout.CurrentPage) == tabbtn.Title.Text then
                TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
                TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
                TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
                TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
            else
                TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
                TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
                TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
                TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
            end
        end
    end
    task.wait(0.5)
    Debounce = false
end
local function Unhide()
    Debounce = true
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Visible = true
    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 400, 0, 600)}):Play()
    TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 400, 0, 45)}):Play()
    TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()
    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Main.Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Main.Topbar.CornerRepair, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Main.Topbar.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
    if MPrompt then
        TweenService:Create(MPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 40, 0, 10), Position = UDim2.new(0.5, 0, 0, -50), BackgroundTransparency = 1}):Play()
        TweenService:Create(MPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
        task.spawn(function()
            task.wait(0.5)
            MPrompt.Visible = false
        end)
    end
    if Minimised then
        task.spawn(Maximise)
    end
    dragBar.Position = useMobileSizing and UDim2.new(0.5, 0, 0.5, dragOffsetMobile) or UDim2.new(0.5, 0, 0.5, dragOffset)
    dragInteract.Visible = true
    for _, TopbarButton in ipairs(Topbar:GetChildren()) do
        if TopbarButton.ClassName == "ImageButton" then
            if TopbarButton.Name == 'Icon' then
                TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
            else
                TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
            end
        end
    end
    for _, tabbtn in ipairs(TabList:GetChildren()) do
        if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
            if tostring(Elements.UIPageLayout.CurrentPage) == tabbtn.Title.Text then
                TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
                TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
                TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
                TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
            else
                TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
                TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
                TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
                TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
            end
        end
    end
    for _, tab in ipairs(Elements:GetChildren()) do
        if tab.Name ~= "Template" and tab.ClassName == "ScrollingFrame" and tab.Name ~= "Placeholder" then
            for _, element in ipairs(tab:GetChildren()) do
                if element.ClassName == "Frame" then
                    if element.Name ~= "SectionSpacing" and element.Name ~= "Placeholder" then
                        if element.Name == "SectionTitle" or element.Name == 'SearchTitle-fsefsefesfsefesfesfThanks' then
                            TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.4}):Play()
                        elseif element.Name == 'Divider' then
                            TweenService:Create(element.Divider, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.85}):Play()
                        else
                            TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
                            TweenService:Create(element.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
                            TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
                        end
                        for _, child in ipairs(element:GetChildren()) do
                            if child.ClassName == "Frame" or child.ClassName == "TextLabel" or child.ClassName == "TextBox" or child.ClassName == "ImageButton" or child.ClassName == "ImageLabel" then
                                child.Visible = true
                            end
                        end
                    end
                end
            end
        end
    end
    TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5}):Play()
    task.wait(0.5)
    Minimised = false
    Debounce = false
end
local function Minimise()
    Debounce = true
    Topbar.ChangeSize.Image = "rbxassetid://"..11036884234
    Topbar.UIStroke.Color = SelectedTheme.ElementStroke
    task.spawn(closeSearch)
    for _, tabbtn in ipairs(TabList:GetChildren()) do
        if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
            TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
            TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
            TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
            TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
        end
    end
    for _, tab in ipairs(Elements:GetChildren()) do
        if tab.Name ~= "Template" and tab.ClassName == "ScrollingFrame" and tab.Name ~= "Placeholder" then
            for _, element in ipairs(tab:GetChildren()) do
                if element.ClassName == "Frame" then
                    if element.Name ~= "SectionSpacing" and element.Name ~= "Placeholder" then
                        if element.Name == "SectionTitle" or element.Name == 'SearchTitle-fsefsefesfsefesfesfThanks' then
                            TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                        elseif element.Name == 'Divider' then
                            TweenService:Create(element.Divider, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
                        else
                            TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
                            TweenService:Create(element.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
                            TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                        end
                        for _, child in ipairs(element:GetChildren()) do
                            if child.ClassName == "Frame" or child.ClassName == "TextLabel" or child.ClassName == "TextBox" or child.ClassName == "ImageButton" or child.ClassName == "ImageLabel" then
                                child.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end
    TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Topbar.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
    TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
    TweenService:Create(Topbar.CornerRepair, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 495, 0, 45)}):Play()
    TweenService:Create(Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 495, 0, 45)}):Play()
    task.wait(0.3)
    Elements.Visible = false
    TabList.Visible = false
    task.wait(0.2)
    Debounce = false
end
local function saveSettings()
    local encoded
    local success, err = pcall(function()
        encoded = HttpService:JSONEncode(settingsTable)
    end)
    if success then
        if useStudio then
            if script.Parent['get.val'] then
                script.Parent['get.val'].Value = encoded
            end
        end
        callSafely(writefile, RayfieldFolder..'/settings'..ConfigurationExtension, encoded)
    end
end
local function updateSetting(category: string, setting: string, value: any)
    if not settingsInitialized then
        return
    end
    settingsTable[category][setting].Value = value
    overriddenSettings[category .. "." .. setting] = nil
    saveSettings()
end
local function createSettings(window)
    if not (writefile and isfile and readfile and isfolder and makefolder) and not useStudio then
        if Topbar['Settings'] then Topbar.Settings.Visible = false end
        Topbar['Search'].Position = UDim2.new(1, -75, 0.5, 0)
        warn('Can\'t create settings as no file-saving functionality is available.')
        return
    end
    local newTab = window:CreateTab('Rayfield Settings', 0, true)
    if TabList['Rayfield Settings'] then
        TabList['Rayfield Settings'].LayoutOrder = 1000
    end
    if Elements['Rayfield Settings'] then
        Elements['Rayfield Settings'].LayoutOrder = 1000
    end
    for categoryName, settingCategory in pairs(settingsTable) do
        newTab:CreateSection(categoryName)
        for settingName, setting in pairs(settingCategory) do
            if setting.Type == 'input' then
                setting.Element = newTab:CreateInput({
                    Name = setting.Name,
                    CurrentValue = setting.Value,
                    PlaceholderText = setting.Placeholder,
                    Ext = true,
                    RemoveTextAfterFocusLost = setting.ClearOnFocus,
                    Callback = function(Value)
                        updateSetting(categoryName, settingName, Value)
                    end,
                })
            elseif setting.Type == 'toggle' then
                setting.Element = newTab:CreateToggle({
                    Name = setting.Name,
                    CurrentValue = setting.Value,
                    Ext = true,
                    Callback = function(Value)
                        updateSetting(categoryName, settingName, Value)
                    end,
                })
            elseif setting.Type == 'bind' then
                setting.Element = newTab:CreateKeybind({
                    Name = setting.Name,
                    CurrentKeybind = setting.Value,
                    HoldToInteract = false,
                    Ext = true,
                    CallOnChange = true,
                    Callback = function(Value)
                        updateSetting(categoryName, settingName, Value)
                    end,
                })
            end
        end
    end
    settingsCreated = true
    loadSettings()
    saveSettings()
end
function RayfieldLibrary:CreateWindow(Settings)
    if Rayfield:FindFirstChild('Loading') then
        if getgenv and not getgenv().rayfieldCached then
            Rayfield.Enabled = true
            Rayfield.Loading.Visible = true
            task.wait(1.4)
            Rayfield.Loading.Visible = false
        end
    end
    if getgenv then getgenv().rayfieldCached = true end
    if not correctBuild and not Settings.DisableBuildWarnings then
        task.delay(3,
            function()
                RayfieldLibrary:Notify({Title = 'Build Mismatch', Content = 'Rayfield may encounter issues as you are running an incompatible interface version ('.. ((Rayfield:FindFirstChild('Build') and Rayfield.Build.Value) or 'No Build') ..').\n\nThis version of Rayfield is intended for interface build '..InterfaceBuild..'.\n\nTry rejoining and then run the script twice.', Image = 4335487866, Duration = 15})
            end)
    end
    if Settings.ToggleUIKeybind then
        local keybind = Settings.ToggleUIKeybind
        if type(keybind) == "string" then
            keybind = string.upper(keybind)
            assert(pcall(function()
                return Enum.KeyCode[keybind]
            end), "ToggleUIKeybind must be a valid KeyCode")
            overrideSetting("General", "rayfieldOpen", keybind)
        elseif typeof(keybind) == "EnumItem" then
            assert(keybind.EnumType == Enum.KeyCode, "ToggleUIKeybind must be a KeyCode enum")
            overrideSetting("General", "rayfieldOpen", keybind.Name)
        else
            error("ToggleUIKeybind must be a string or KeyCode enum")
        end
    end
    ensureFolder(RayfieldFolder)
    if not requestsDisabled then
        sendReport("window_created", Settings.Name or "Unknown")
    end
    local Passthrough = false
    Topbar.Title.Text = Settings.Name
    Main.Size = UDim2.new(0, 420, 0, 100)
    Main.Visible = true
    Main.BackgroundTransparency = 1
    if Main:FindFirstChild('Notice') then Main.Notice.Visible = false end
    Main.Shadow.Image.ImageTransparency = 1
    LoadingFrame.Title.TextTransparency = 1
    LoadingFrame.Subtitle.TextTransparency = 1
    if Settings.ShowText then
        MPrompt.Title.Text = 'Show '..Settings.ShowText
    end
    LoadingFrame.Version.TextTransparency = 1
    LoadingFrame.Title.Text = Settings.LoadingTitle or "Rayfield"
    LoadingFrame.Subtitle.Text = Settings.LoadingSubtitle or "Interface Suite"
    if Settings.LoadingTitle ~= "Rayfield Interface Suite" then
        LoadingFrame.Version.Text = "Rayfield UI"
    end
    if Settings.Icon and Settings.Icon ~= 0 and Topbar:FindFirstChild('Icon') then
        Topbar.Icon.Visible = true
        Topbar.Title.Position = UDim2.new(0, 47, 0.5, 0)
        if Settings.Icon then
            if typeof(Settings.Icon) == 'string' and Icons then
                local asset = getIcon(Settings.Icon)
                Topbar.Icon.Image = 'rbxassetid://'..asset.id
                Topbar.Icon.ImageRectOffset = asset.imageRectOffset
                Topbar.Icon.ImageRectSize = asset.imageRectSize
            else
                Topbar.Icon.Image = getAssetUri(Settings.Icon)
            end
        else
            Topbar.Icon.Image = "rbxassetid://" .. 0
        end
    end
    if dragBar then
        dragBar.Visible = false
        dragBarCosmetic.BackgroundTransparency = 1
        dragBar.Visible = true
    end
    if Settings.Theme then
        local success, result = pcall(ChangeTheme, Settings.Theme)
        if not success then
            local success, result2 = pcall(ChangeTheme, 'Default')
            if not success then
                warn('CRITICAL ERROR - NO DEFAULT THEME')
                print(result2)
            end
            warn('issue rendering theme. no theme on file')
            print(result)
        end
    end
    Topbar.Visible = true
    Elements.Visible = true
    LoadingFrame.Visible = false
    if not Settings.DisableRayfieldPrompts then
        task.spawn(function()
            while true do
                task.wait(math.random(180, 600))
                RayfieldLibrary:Notify({
                    Title = "Rayfield Interface",
                    Content = "Enjoying this UI library? Find it at sirius.menu/discord",
                    Duration = 7,
                    Image = 4370033185,
                })
            end
        end)
    end
    pcall(function()
        if not Settings.ConfigurationSaving.FileName then
            Settings.ConfigurationSaving.FileName = tostring(game.PlaceId)
        end
        if Settings.ConfigurationSaving.Enabled == nil then
            Settings.ConfigurationSaving.Enabled = false
        end
        CFileName = Settings.ConfigurationSaving.FileName
        ConfigurationFolder = Settings.ConfigurationSaving.FolderName or ConfigurationFolder
        CEnabled = Settings.ConfigurationSaving.Enabled
        if Settings.ConfigurationSaving.Enabled then
            ensureFolder(ConfigurationFolder)
        end
    end)
    makeDraggable(Main, Topbar, false, {dragOffset, dragOffsetMobile})
    if dragBar then dragBar.Position = useMobileSizing and UDim2.new(0.5, 0, 0.5, dragOffsetMobile) or UDim2.new(0.5, 0, 0.5, dragOffset) makeDraggable(Main, dragInteract, true, {dragOffset, dragOffsetMobile}) end
    for _, TabButton in ipairs(TabList:GetChildren()) do
        if TabButton.ClassName == "Frame" and TabButton.Name ~= "Placeholder" then
            TabButton.BackgroundTransparency = 1
            TabButton.Title.TextTransparency = 1
            TabButton.Image.ImageTransparency = 1
            TabButton.UIStroke.Transparency = 1
        end
    end
    if Settings.Discord and Settings.Discord.Enabled and not useStudio then
        ensureFolder(RayfieldFolder.."/Discord Invites")
        if callSafely(isfile, RayfieldFolder.."/Discord Invites".."/"..Settings.Discord.Invite..ConfigurationExtension) then
            if requestFunc then
                pcall(function()
                    requestFunc({
                        Url = 'http://127.0.0.1:6463/rpc?v=1',
                        Method = 'POST',
                        Headers = {
                            ['Content-Type'] = 'application/json',
                            Origin = 'https://discord.com'
                        },
                        Body = HttpService:JSONEncode({
                            cmd = 'INVITE_BROWSER',
                            nonce = HttpService:GenerateGUID(false),
                            args = {code = Settings.Discord.Invite}
                        })
                    })
                end)
            end
            if Settings.Discord.RememberJoins then
                callSafely(writefile, RayfieldFolder.."/Discord Invites".."/"..Settings.Discord.Invite..ConfigurationExtension,"Rayfield RememberJoins is true for this invite, this invite will not ask you to join again")
            end
        end
    end
    if (Settings.KeySystem) then
        if not Settings.KeySettings then
            Passthrough = true
            return
        end
        ensureFolder(RayfieldFolder.."/Key System")
        if typeof(Settings.KeySettings.Key) == "string" then Settings.KeySettings.Key = {Settings.KeySettings.Key} end
        if Settings.KeySettings.GrabKeyFromSite then
            for i, Key in ipairs(Settings.KeySettings.Key) do
                local Success, Response = pcall(function()
                    Settings.KeySettings.Key[i] = tostring(game:HttpGet(Key):gsub("[\n\r]", " "))
                    Settings.KeySettings.Key[i] = string.gsub(Settings.KeySettings.Key[i], " ", "")
                end)
                if not Success then
                    print("Rayfield | "..Key.." Error " ..tostring(Response))
                    warn('Check docs.sirius.menu for help with Rayfield specific development.')
                end
            end
        end
        if not Settings.KeySettings.FileName then
            Settings.KeySettings.FileName = "No file name specified"
        end
        if callSafely(isfile, RayfieldFolder.."/Key System".."/"..Settings.KeySettings.FileName..ConfigurationExtension) then
            for _, MKey in ipairs(Settings.KeySettings.Key) do
                local savedKeys = callSafely(readfile, RayfieldFolder.."/Key System".."/"..Settings.KeySettings.FileName..ConfigurationExtension)
                if keyFileContents and string.find(savedKeys, MKey) then
                    Passthrough = true
                end
            end
        end
        if not Passthrough then
            local AttemptsRemaining = math.random(2, 5)
            Rayfield.Enabled = false
            local KeyUI = useStudio and script.Parent:FindFirstChild('Key') or game:GetObjects("rbxassetid://11380036235")[1]
            KeyUI.Enabled = true
            if gethui then
                KeyUI.Parent = gethui()
            elseif syn and syn.protect_gui then
                syn.protect_gui(KeyUI)
                KeyUI.Parent = CoreGui
            elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
                KeyUI.Parent = CoreGui:FindFirstChild("RobloxGui")
            elseif not useStudio then
                KeyUI.Parent = CoreGui
            end
            if gethui then
                for _, Interface in ipairs(gethui():GetChildren()) do
                    if Interface.Name == KeyUI.Name and Interface ~= KeyUI then
                        Interface.Enabled = false
                        Interface.Name = "KeyUI-Old"
                    end
                end
            elseif not useStudio then
                for _, Interface in ipairs(CoreGui:GetChildren()) do
                    if Interface.Name == KeyUI.Name and Interface ~= KeyUI then
                        Interface.Enabled = false
                        Interface.Name = "KeyUI-Old"
                    end
                end
            end
            local KeyMain = KeyUI.Main
            KeyMain.Title.Text = Settings.KeySettings.Title or Settings.Name
            KeyMain.Subtitle.Text = Settings.KeySettings.Subtitle or "Key System"
            KeyMain.NoteMessage.Text = Settings.KeySettings.Note or "No instructions"
            KeyMain.Size = UDim2.new(0, 467, 0, 175)
            KeyMain.BackgroundTransparency = 1
            KeyMain.Shadow.Image.ImageTransparency = 1
            KeyMain.Title.TextTransparency = 1
            KeyMain.Subtitle.TextTransparency = 1
            KeyMain.KeyNote.TextTransparency = 1
            KeyMain.Input.BackgroundTransparency = 1
            KeyMain.Input.UIStroke.Transparency = 1
            KeyMain.Input.InputBox.TextTransparency = 1
            KeyMain.NoteTitle.TextTransparency = 1
            KeyMain.NoteMessage.TextTransparency = 1
            KeyMain.Hide.ImageTransparency = 1
            TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
            TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 500, 0, 187)}):Play()
            TweenService:Create(KeyMain.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.5}):Play()
            task.wait(0.05)
            TweenService:Create(KeyMain.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
            TweenService:Create(KeyMain.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
            task.wait(0.05)
            TweenService:Create(KeyMain.KeyNote, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
            TweenService:Create(KeyMain.Input, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
            TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
            TweenService:Create(KeyMain.Input.InputBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
            task.wait(0.05)
            TweenService:Create(KeyMain.NoteTitle, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
            TweenService:Create(KeyMain.NoteMessage, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
            task.wait(0.15)
            TweenService:Create(KeyMain.Hide, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 0.3}):Play()
            KeyUI.Main.Input.InputBox.FocusLost:Connect(function()
                if #KeyUI.Main.Input.InputBox.Text == 0 then return end
                local KeyFound = false
                local FoundKey = ''
                for _, MKey in ipairs(Settings.KeySettings.Key) do
                    if KeyMain.Input.InputBox.Text == MKey then
                        KeyFound = true
                        FoundKey = MKey
                    end
                end
                if KeyFound then
                    TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
                    TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 467, 0, 175)}):Play()
                    TweenService:Create(KeyMain.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
                    TweenService:Create(KeyMain.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                    TweenService:Create(KeyMain.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                    TweenService:Create(KeyMain.KeyNote, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                    TweenService:Create(KeyMain.Input, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
                    TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
                    TweenService:Create(KeyMain.Input.InputBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                    TweenService:Create(KeyMain.NoteTitle, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                    TweenService:Create(KeyMain.NoteMessage, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                    TweenService:Create(KeyMain.Hide, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
                    task.wait(0.51)
                    Passthrough = true
                    KeyMain.Visible = false
                    if Settings.KeySettings.SaveKey then
                        callSafely(writefile, RayfieldFolder.."/Key System".."/"..Settings.KeySettings.FileName..ConfigurationExtension, FoundKey)
                        RayfieldLibrary:Notify({Title = "Key System", Content = "The key for this script has been saved successfully.", Image = 3605522284})
                    end
                else
                    if AttemptsRemaining == 0 then
                        TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
                        TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 467, 0, 175)}):Play()
                        TweenService:Create(KeyMain.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
                        TweenService:Create(KeyMain.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                        TweenService:Create(KeyMain.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                        TweenService:Create(KeyMain.KeyNote, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                        TweenService:Create(KeyMain.Input, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
                        TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
                        TweenService:Create(KeyMain.Input.InputBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                        TweenService:Create(KeyMain.NoteTitle, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                        TweenService:Create(KeyMain.NoteMessage, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                        TweenService:Create(KeyMain.Hide, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
                        task.wait(0.45)
                        Players.LocalPlayer:Kick("No Attempts Remaining")
                        game:Shutdown()
                    end
                    KeyMain.Input.InputBox.Text = ""
                    AttemptsRemaining = AttemptsRemaining - 1
                    TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 467, 0, 175)}):Play()
                    TweenService:Create(KeyMain, TweenInfo.new(0.4, Enum.EasingStyle.Elastic), {Position = UDim2.new(0.495,0,0.5,0)}):Play()
                    task.wait(0.1)
                    TweenService:Create(KeyMain, TweenInfo.new(0.4, Enum.EasingStyle.Elastic), {Position = UDim2.new(0.505,0,0.5,0)}):Play()
                    task.wait(0.1)
                    TweenService:Create(KeyMain, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5,0,0.5,0)}):Play()
                    TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 500, 0, 187)}):Play()
                end
            end)
            KeyMain.Hide.MouseButton1Click:Connect(function()
                TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
                TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 467, 0, 175)}):Play()
                TweenService:Create(KeyMain.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
                TweenService:Create(KeyMain.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                TweenService:Create(KeyMain.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                TweenService:Create(KeyMain.KeyNote, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                TweenService:Create(KeyMain.Input, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
                TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
                TweenService:Create(KeyMain.Input.InputBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                TweenService:Create(KeyMain.NoteTitle, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                TweenService:Create(KeyMain.NoteMessage, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
                TweenService:Create(KeyMain.Hide, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
                task.wait(0.51)
                RayfieldLibrary:Destroy()
                KeyUI:Destroy()
            end)
        else
            Passthrough = true
        end
    end
    if Settings.KeySystem then
        repeat task.wait() until Passthrough
    end
    Notifications.Template.Visible = false
    Notifications.Visible = true
    Rayfield.Enabled = true
    Main.Size = UDim2.new(0, 400, 0, 600)
    Main.BackgroundTransparency = 0
    Main.Shadow.Image.ImageTransparency = 0.6
    Topbar.Size = UDim2.new(0, 400, 0, 45)
    Topbar.BackgroundTransparency = 0
    Topbar.CornerRepair.BackgroundTransparency = 0
    Topbar.Divider.Size = UDim2.new(1, 0, 0, 1)
    Topbar.Title.TextTransparency = 0
    Topbar.Search.ImageTransparency = 0.8
    if Topbar:FindFirstChild('Settings') then
        Topbar.Settings.ImageTransparency = 0.8
    end
    Topbar.ChangeSize.ImageTransparency = 0.8
    Topbar.Hide.ImageTransparency = 0.8
    if dragBar then
        dragBarCosmetic.BackgroundTransparency = 0.7
    end
    local layout = TabList:FindFirstChildOfClass("UIListLayout")
    if not layout then
        layout = Instance.new("UIListLayout")
        layout.Parent = TabList
    end
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Padding = UDim.new(0, 5)
    TabList.Size = UDim2.new(0, 150, 1, -50)
    TabList.Position = UDim2.new(0, 10, 0, 50)
    Elements.Size = UDim2.new(1, -170, 1, -60)
    Elements.Position = UDim2.new(0, 170, 0, 50)
    Elements.Visible = true
    for _, tabbtn in ipairs(TabList:GetChildren()) do
        if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
            if tostring(Elements.UIPageLayout.CurrentPage) == tabbtn.Title.Text then
                tabbtn.BackgroundTransparency = 0
                tabbtn.Title.TextTransparency = 0
                tabbtn.Image.ImageTransparency = 0
                tabbtn.UIStroke.Transparency = 1
            else
                tabbtn.BackgroundTransparency = 0.7
                tabbtn.Title.TextTransparency = 0.2
                tabbtn.Image.ImageTransparency = 0.2
                tabbtn.UIStroke.Transparency = 0.5
            end
        end
    end
    function Window.ModifyTheme(NewTheme)
        local success = pcall(ChangeTheme, NewTheme)
        if not success then
            RayfieldLibrary:Notify({Title = 'Unable to Change Theme', Content = 'We are unable find a theme on file.', Image = 4400704299})
        else
            RayfieldLibrary:Notify({Title = 'Theme Changed', Content = 'Successfully changed theme to '..(typeof(NewTheme) == 'string' and NewTheme or 'Custom Theme')..'.', Image = 4483362748})
        end
    end
    local success, result = pcall(function()
        createSettings(Window)
    end)
    if not success then warn('Rayfield had an issue creating settings.') end
    return Window
end
local function setVisibility(visibility: boolean, notify: boolean?)
    if Debounce then return end
    if visibility then
        Hidden = false
        Unhide()
    else
        Hidden = true
        Hide(notify)
    end
end
function RayfieldLibrary:SetVisibility(visibility: boolean)
    setVisibility(visibility, false)
end
function RayfieldLibrary:IsVisible(): boolean
    return not Hidden
end
local hideHotkeyConnection
function RayfieldLibrary:Destroy()
    rayfieldDestroyed = true
    hideHotkeyConnection:Disconnect()
    for _, connection in keybindConnections do
        connection:Disconnect()
    end
    Rayfield:Destroy()
end
Topbar.ChangeSize.MouseButton1Click:Connect(function()
    if Debounce then return end
    if Minimised then
        Minimised = false
        Maximise()
    else
        Minimised = true
        Minimise()
    end
end)
Main.Search.Input:GetPropertyChangedSignal('Text'):Connect(function()
    if #Main.Search.Input.Text > 0 then
        if not Elements.UIPageLayout.CurrentPage:FindFirstChild('SearchTitle-fsefsefesfsefesfesfThanks') then
            local searchTitle = Elements.Template.SectionTitle:Clone()
            searchTitle.Parent = Elements.UIPageLayout.CurrentPage
            searchTitle.Name = 'SearchTitle-fsefsefesfsefesfesfThanks'
            searchTitle.LayoutOrder = -100
            searchTitle.Title.Text = "Results from '"..Elements.UIPageLayout.CurrentPage.Name.."'"
            searchTitle.Visible = true
        end
    else
        local searchTitle = Elements.UIPageLayout.CurrentPage:FindFirstChild('SearchTitle-fsefsefesfsefesfesfThanks')
        if searchTitle then
            searchTitle:Destroy()
        end
    end
    for _, element in ipairs(Elements.UIPageLayout.CurrentPage:GetChildren()) do
        if element.ClassName ~= 'UIListLayout' and element.Name ~= 'Placeholder' and element.Name ~= 'SearchTitle-fsefsefesfsefesfesfThanks' then
            if element.Name == 'SectionTitle' then
                if #Main.Search.Input.Text == 0 then
                    element.Visible = true
                else
                    element.Visible = false
                end
            else
                if string.lower(element.Name):find(string.lower(Main.Search.Input.Text), 1, true) then
                    element.Visible = true
                else
                    element.Visible = false
                end
            end
        end
    end
end)
Main.Search.Input.FocusLost:Connect(function(enterPressed)
    if #Main.Search.Input.Text == 0 and searchOpen then
        task.wait(0.12)
        closeSearch()
    end
end)
Topbar.Search.MouseButton1Click:Connect(function()
    task.spawn(function()
        if searchOpen then
            closeSearch()
        else
            openSearch()
        end
    end)
end)
if Topbar:FindFirstChild('Settings') then
    Topbar.Settings.MouseButton1Click:Connect(function()
        task.spawn(function()
            for _, OtherTabButton in ipairs(TabList:GetChildren()) do
                if OtherTabButton.Name ~= "Template" and OtherTabButton.ClassName == "Frame" and OtherTabButton ~= TabButton and OtherTabButton.Name ~= "Placeholder" then
                    TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.TabBackground}):Play()
                    TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextColor3 = SelectedTheme.TabTextColor}):Play()
                    TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageColor3 = SelectedTheme.TabTextColor}):Play()
                    TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
                    TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
                    TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
                    TweenService:Create(OtherTabButton.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
                end
            end
            Elements.UIPageLayout:JumpTo(Elements['Rayfield Settings'])
        end)
    end)
end
Topbar.Hide.MouseButton1Click:Connect(function()
    setVisibility(Hidden, not useMobileSizing)
end)
hideHotkeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if (input.KeyCode == Enum.KeyCode[getSetting("General", "rayfieldOpen")]) and not processed then
        if Debounce then return end
        if Hidden then
            Hidden = false
            Unhide()
        else
            Hidden = true
            Hide()
        end
    end
end)
if MPrompt then
    MPrompt.Interact.MouseButton1Click:Connect(function()
        if Debounce then return end
        if Hidden then
            Hidden = false
            Unhide()
        end
    end)
end
for _, TopbarButton in ipairs(Topbar:GetChildren()) do
    if TopbarButton.ClassName == "ImageButton" and TopbarButton.Name ~= 'Icon' then
        TopbarButton.MouseEnter:Connect(function()
            TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
        end)
        TopbarButton.MouseLeave:Connect(function()
            TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
        end)
    end
end
function RayfieldLibrary:LoadConfiguration()
    local config
    if debugX then
        warn('Loading Configuration')
    end
    if useStudio then
        config = [[{"Toggle1adwawd":true,"ColorPicker1awd":{"B":255,"G":255,"R":255},"Slider1dawd":100,"ColorPicfsefker1":{"B":255,"G":255,"R":255},"Slidefefsr1":80,"dawdawd":"","Input1":"hh","Keybind1":"B","Dropdown1":["Ocean"]}]]
    end
    if CEnabled then
        local notified
        local loaded
        local success, result = pcall(function()
            if useStudio and config then
                loaded = LoadConfiguration(config)
                return
            end
            if isfile then
                if callSafely(isfile, ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension) then
                    loaded = LoadConfiguration(callSafely(readfile, ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension))
                end
            else
                notified = true
                RayfieldLibrary:Notify({Title = "Rayfield Configurations", Content = "We couldn't enable Configuration Saving as you are not using software with filesystem support.", Image = 4384402990})
            end
        end)
        if success and loaded and not notified then
            RayfieldLibrary:Notify({Title = "Rayfield Configurations", Content = "The configuration file for this script has been loaded from a previous session.", Image = 4384403532})
        elseif not success and not notified then
            warn('Rayfield Configurations Error | '..tostring(result))
            RayfieldLibrary:Notify({Title = "Rayfield Configurations", Content = "We've encountered an issue loading your configuration correctly.\n\nCheck the Developer Console for more information.", Image = 4384402990})
        end
    end
    globalLoaded = true
end
if useStudio then
end
if CEnabled and Main:FindFirstChild('Notice') then
    Main.Notice.BackgroundTransparency = 1
    Main.Notice.Title.TextTransparency = 1
    Main.Notice.Size = UDim2.new(0, 0, 0, 0)
    Main.Notice.Position = UDim2.new(0.5, 0, 0, -100)
    Main.Notice.Visible = true
    TweenService:Create(Main.Notice, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 280, 0, 35), Position = UDim2.new(0.5, 0, 0, -50), BackgroundTransparency = 0.5}):Play()
    TweenService:Create(Main.Notice.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.1}):Play()
end
task.delay(4, function()
    RayfieldLibrary.LoadConfiguration()
    if Main:FindFirstChild('Notice') and Main.Notice.Visible then
        TweenService:Create(Main.Notice, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 100, 0, 25), Position = UDim2.new(0.5, 0, 0, -100), BackgroundTransparency = 1}):Play()
        TweenService:Create(Main.Notice.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
        task.wait(0.5)
        Main.Notice.Visible = false
    end
end)
return RayfieldLibrary