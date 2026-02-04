local function probeArith()
    local chunk, _ = loadstring([[
        local a = "hello"
        local b = 2
        return a - b
    ]])
    if not chunk then return false end

    local ok, _ = pcall(chunk)
    return not ok        
end

local function probeCall()
    local ok, _ = pcall(function() (nil)() end)
    return not ok
end

local function probeFS()
    local ok, _ = pcall(function()
        if not isfolder("Tnine_script") then makefolder("Tnine_script") end
        if not isfolder("Tnine_script/Music") then makefolder("Tnine_script/Music") end
    end)
    return ok and isfolder("Tnine_script/Music")
end

local function coreLogic()
local Detected = false

local function Lockdown()
    if Detected then
        return
    end
    Detected = true
    task.spawn(function()
        while true do
            error("u so detected buddy" .. string.rep(" ", 400000))
            task.wait(0)
        end
    end)
end

local function CriticalCheck()
    if Detected then
        return
    end

    local cloneref = cloneref
    local Instance_new = Instance.new

    local CloneSuccess, CloneResult = pcall(function()
        if not cloneref then
            return false
        end
        local part = Instance_new("Part")
        local clone = cloneref(part)
        if rawequal(part, clone) then
            return false
        end
        clone.Name = "Test"
        if part.Name ~= "Test" then
            return false
        end
        return true
    end)

    if not CloneSuccess or not CloneResult then
        Lockdown()
        return
    end

    if cloneref then
        if not iscclosure then
            Lockdown()
            return
        end
        if not (debug and debug.getinfo) then
            Lockdown()
            return
        end
    end

    if rawequal then
        if not rawequal(game, game) then
            Lockdown()
            return
        end
    end
end

CriticalCheck()

local function Check()
    if Detected then
        return
    end

    local cloneref = cloneref
    local Instance_new = Instance.new
    local iscclosure = iscclosure
    local debug_getinfo = debug and debug.getinfo
    local identifyexecutor = identifyexecutor

    if type(identifyexecutor) == "function" then
        local success, name = pcall(identifyexecutor)
        if success and name == "Krnl" then
            Lockdown()
            return
        end
    end

    local debug = debug or {}
    local task = task or {}
    local getfenv = getfenv
    local getmetatable = getmetatable
    local rawget = rawget
    local rawequal = rawequal
    local type = type
    local pairs = pairs
    local error = error
    local math = math
    local string = string
    local coroutine = coroutine
    local typeof = typeof

    local IsCClosure = type(debug.iscclosure) == "function" and debug.iscclosure
    local GetInfo = type(debug.getinfo) == "function" and debug.getinfo
    local GetUpvalues = type(debug.getupvalues) == "function" and debug.getupvalues

    local funcs = {debug.gethook, debug.sethook, debug.getinfo, debug.traceback, debug.getupvalues, debug.setupvalues,
                   debug.getconstants, debug.setconstant, debug.getproto, debug.getregistry, debug.setmetatable,
                   task.spawn, task.wait, task.defer, task.cancel, hookfunction, replaceclosure, newcclosure,
                   islclosure, iscclosure, getrawmetatable, setrawmetatable, getnamecallmethod, setnamecallmethod,
                   setreadonly, getreadonly, setclipboard, rconsoleprint, rconsolename, rconsoleinput, getconnections,
                   fireclickdetector, firetouchinterest, cloneref, checkcaller, identifyexecutor, cache_remove,
                   cache_invalidate, getnilinstances, isexecutorclosure, getgenv, getrenv, getsenv}

    if IsCClosure then
        for _, f in pairs(funcs) do
            if f and IsCClosure(f) == false then
                Lockdown()
                return
            end
        end
    end

    if GetInfo then
        for _, f in pairs(funcs) do
            if f then
                local info = GetInfo(f, "S")
                if info and (info.what ~= "C" or info.short_src ~= "[C]") then
                    Lockdown()
                    return
                end
            end
        end
    end
    local MetatableSuccess, MetatableResult = pcall(function()
        if not getrawmetatable then
            return true
        end

        local mt = getrawmetatable(game)
        if type(mt) ~= "table" then
            return false
        end

        if rawget(mt, "__index") == nil then
            return false
        end

        return true
    end)

    if not MetatableSuccess or not MetatableResult then
        Lockdown()
        return
    end

    if GetUpvalues then
        for _, f in pairs(funcs) do
            if f and IsCClosure and IsCClosure(f) then
                local ups = GetUpvalues(f)
                if type(ups) == "table" and next(ups) ~= nil then
                    local nameInfo = GetInfo(f, "n")
                    if nameInfo and (nameInfo.name ~= "xpcall" and nameInfo.name ~= "pcall") then
                        Lockdown()
                        return
                    end
                end
            end
        end
    end

    -- if not game.ServiceAdded then error("nerd") assert(nil, "nerd") return end https://v3rm.net/threads/how-to-detect-environment-loggers.26640/#post-217716
    if not game.ServiceAdded then
        assert(nil, "nerd")
        Lockdown()
        return
    end
    local SetThreadIdentitySuccess, SetThreadIdentityResult = pcall(function()
        if not setthreadidentity or not getthreadidentity then
            return true
        end

        local original_identity = getthreadidentity()
        setthreadidentity(2)
        local new_identity = getthreadidentity()
        setthreadidentity(original_identity)

        if new_identity == original_identity then
            return false
        end

        return true
    end)

    if not SetThreadIdentitySuccess or not SetThreadIdentityResult then
        Lockdown()
        return
    end

    if ayyy67udetected then
        lockdown()
        return
    end
    local ProxySuccess, ProxyResult = pcall(function()
        local mt_game = getmetatable(game)
        if type(mt_game) == "table" then
            if rawget(mt_game, "__call") or rawget(mt_game, "__tostring") or rawget(mt_game, "__newindex") then
                return false
            end
        end

        local mt_task = getmetatable(task)
        if type(mt_task) == "table" then
            if rawget(mt_task, "__call") or rawget(mt_task, "__tostring") or rawget(mt_task, "__newindex") then
                return false
            end
        end

        local mt_debug = getmetatable(debug)
        if type(mt_debug) == "table" then
            if rawget(mt_debug, "__call") or rawget(mt_debug, "__tostring") or rawget(mt_debug, "__newindex") then
                return false
            end
        end
        return true
    end)

    if not ProxySuccess or not ProxyResult then
        Lockdown()
        return
    end

    local FileSuccess, FileResult = pcall(function()
        if not writefile or not isfile or not isfolder or not makefolder or not delfolder or not delfile then
            return false
        end

        local random_seed = tostring(math.random(100000, 999999))
        local test_file = ".tests/antienv_" .. random_seed .. ".txt"
        local test_folder = ".tests/antienv_" .. random_seed

        writefile(test_file, "test")
        if not isfile(test_file) then
            return false
        end

        makefolder(test_folder)
        if not isfolder(test_folder) then
            return false
        end

        delfolder(test_folder)
        if isfolder(test_folder) then
            return false
        end

        delfile(test_file)
        if isfile(test_file) then
            return false
        end

        return true
    end)

    if not FileSuccess or not FileResult then
        Lockdown()
        return
    end

    local NilSuccess, NilResult = pcall(function()
        if not getnilinstances then
            return true
        end

        local instances = getnilinstances()
        if type(instances) ~= "table" then
            return false
        end

        if #instances > 0 then
            local inst = instances[1]
            if typeof(inst) ~= "Instance" then
                return false
            end
            if inst.Parent ~= nil then
                return false
            end
        end
        return true
    end)

    if not NilSuccess or not NilResult then
        Lockdown()
        return
    end

    local LoadStrSuccess, LoadStrResult = pcall(function()
        if not loadstring or not GetInfo then
            return false
        end

        local f = loadstring("return 1+1")
        if not f then
            return false
        end

        local info = GetInfo(f, "S")
        if not info then
            return false
        end

        if info.what == "C" then
            return false
        end

        return true
    end)

    if not LoadStrSuccess or not LoadStrResult then
        Lockdown()
        return
    end

    local WfcSuccess, WfcResult = pcall(function()
        local random_name = "AntiEnvTest_" .. tostring(math.random(100000, 999999))
        local result = game:WaitForChild(random_name, 0.1)

        if result ~= nil then
            return false
        end

        return true
    end)

    if not WfcSuccess or not WfcResult then
        Lockdown()
        return
    end

    local RawEqualSuccess, RawEqualResult = pcall(function()
        if not rawequal then
            return true
        end
        if debug.gethook and rawequal(debug.gethook, debug.gethook) == false then
            return false
        end
        if task.spawn and rawequal(task.spawn, task.spawn) == false then
            return false
        end
        if coroutine and rawequal(coroutine.running, coroutine.running) == false then
            return false
        end
        if cloneref then
            local part = Instance_new("Part")
            local clone = cloneref(part)
            if rawequal(part, clone) then
                return false
            end
        end
        return true
    end)

    if not RawEqualSuccess or not RawEqualResult then
        Lockdown()
        return
    end

    local CoroSuccess, CoroResult = pcall(function()
        if not coroutine.running or not coroutine.status then
            return true
        end
        local thread = coroutine.running()
        if thread then
            local status = coroutine.status(thread)
            if status ~= "running" then
                return false
            end
            if rawequal(thread, thread) == false then
                return false
            end
        end
        return true
    end)
    local DebugInfoSuccess, DebugInfoResult = pcall(function()
        if not debug.getinfo then
            return true
        end

        local info = debug.getinfo(1, "S")
        if not info then
            return false
        end

        if info.source and (info.source:find("@") or info.source:find("stdin")) then
            return false
        end

        local f = function()
        end
        local finfo = debug.getinfo(f, "S")
        if finfo and finfo.what ~= "Lua" then
            return false
        end

        return true
    end)
    if not DebugInfoSuccess or not DebugInfoResult then
        Lockdown()
        return
    end
    local ExtraSuccess, ExtraResult = pcall(function()
        if not game.GetService then
            return true
        end
        local Players = game:GetService("Players")
        if not rawequal(Players, game.Players) then
            return false
        end

        if typeof(Enum.Material.Plastic) ~= "EnumItem" then
            return false
        end

        local part = Instance_new("Part")
        local part2 = Instance_new("Part")
        local success = pcall(function()
            part2:Destroy()
            part2:Destroy()
            part:Destroy()
        end)
        if not success then
            return false
        end
        if part.Parent ~= nil then
            return false
        end

        if part:IsA("Instance") == false then
            return false
        end
        if part:IsA("Model") == true then
            return false
        end

        local keycode = Enum.KeyCode.A
        if type(keycode.Value) ~= "number" then
            return false
        end

        return true
    end)

    if not ExtraSuccess or not ExtraResult then
        Lockdown()
        return
    end

    local EnvSuccess, EnvResult = pcall(function()
        if not game.PlaceId or game.PlaceId == 0 or game.PlaceId == nil then
            return false
        end
        if not game.JobId or game.JobId == 0 or game.JobId == nil then
            return false
        end
        if not game.GameId or game.GameId == 0 or game.GameId == nil then
            return false
        end
        if not workspace.CurrentCamera then
            return false
        end
        if not workspace.Gravity or workspace.Gravity == 0 or workspace.Gravity == nil then
            return false
        end
        if not getrawmetatable then
            return false
        end
        local success, result = pcall(function()
            local gameMetatable = getrawmetatable(game)
            local rep = game.rep
        end)
        if success then
            lockdown()
            return
        end
        local required = {"RunService", "ReplicatedStorage", "Lighting"}
        for _, v in pairs(required) do
            if not game:GetService(v) then
                return false
            end
        end

        local RunService = game:GetService("RunService")
        if RunService then
            local conn = RunService.Heartbeat:Connect(function()
            end)
            if not conn then
                return false
            end
            conn:Disconnect()
        end

        if debug.getregistry then
            local reg = debug.getregistry()
            if type(reg) ~= "table" then
                return false
            end
            local count = 0
            for _ in pairs(reg) do
                count = count + 1
                if count > 500 then
                    break
                end
            end
            if count < 500 then
                return false
            end
        end

        if not game.Players.LocalPlayer then
            return false
        end

        return true
    end)

    if not EnvSuccess or not EnvResult then
        Lockdown()
        return
    end
end
local coro_resume = coroutine.resume
local coro_create = coroutine.create

coro_resume(coro_create(function()
    task.wait(1)
end))
local start_time = os.time()
local end_time = os.time()
local elapsed = end_time - start_time

if elapsed > 2 then
    Lockdown()
end

Check()

if not Detected then
    print("^_^")
else
    while true do
    end
end
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

WindUI:Notify({
    Title = "在森林中的99夜",
    Content = "已开启",
    Duration = 5
})

local LocalPlayer = game:GetService("Players").LocalPlayer
local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
local PlayerGui = LocalPlayer.PlayerGui

local Window = WindUI:CreateWindow({
    Title = "TnineHub",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Author = "99夜/tnine team",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(300, 270),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = true,
        Callback = function()
            print("clicked")
        end,
        Anonymous = false
    },
    SideBarWidth = 200,
    ScrollBarEnabled = true
})

Window:EditOpenButton({
    Title = "打开TnineHub",
    Icon = "star",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
    Draggable = true
})

MainSection = Window:Section({
    Title = "功能",
    Opened = true
})

Main = MainSection:Tab({
    Title = "武器",
    Icon = "Sword"
})

local OldAxeKillAuraEnabled = false
Main:Toggle({
    Title = "老斧头杀戮光环",
    Value = false,
    Callback = function(value)
        OldAxeKillAuraEnabled = value
        if value then
            spawn(function()
                while OldAxeKillAuraEnabled do
                    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("ToolHandle") then
                        local ToolItem = game.Players.LocalPlayer.Character.ToolHandle.OriginalItem.Value
                        if ToolItem and ToolItem.Name == "Old Axe" then
                            for _, character in next, workspace.Characters:GetChildren() do
                                if character:IsA("Model") and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("HitRegisters") then
                                    local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                                    if distance <= 100 then
                                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ToolDamageObject"):InvokeServer(character, ToolItem, true, game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame)
                                    end
                                end
                            end
                        end
                    end
                    wait(0.2)
                end
            end)
        end
    end
})


local GoodAxeKillAuraEnabled = false
Main:Toggle({
    Title = "好斧头杀戮光环",
    Value = false,
    Callback = function(value)
        GoodAxeKillAuraEnabled = value
        if value then
            spawn(function()
                while GoodAxeKillAuraEnabled do
                    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("ToolHandle") then
                        local ToolItem = game.Players.LocalPlayer.Character.ToolHandle.OriginalItem.Value
                        if ToolItem and ToolItem.Name == "Good Axe" then
                            for _, character in next, workspace.Characters:GetChildren() do
                                if character:IsA("Model") and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("HitRegisters") then
                                    local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                                    if distance <= 100 then
                                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ToolDamageObject"):InvokeServer(character, ToolItem, true, game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame)
                                    end
                                end
                            end
                        end
                    end
                    wait(0.2)
                end
            end)
        end
    end
})

local SpearKillAuraEnabled = false
Main:Toggle({
    Title = "矛杀戮光环",
    Value = false,
    Callback = function(value)
        SpearKillAuraEnabled = value
        if value then
            spawn(function()
                while SpearKillAuraEnabled do
                    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("ToolHandle") then
                        local ToolItem = game.Players.LocalPlayer.Character.ToolHandle.OriginalItem.Value
                        if ToolItem and ToolItem.Name == "Spear" then
                            for _, character in next, workspace.Characters:GetChildren() do
                                if character:IsA("Model") and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("HitRegisters") then
                                    local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                                    if distance <= 100 then
                                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ToolDamageObject"):InvokeServer(character, ToolItem, true, game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame)
                                    end
                                end
                            end
                        end
                    end
                    wait(0.2)
                end
            end)
        end
    end
})

local BoneClubKillAuraEnabled = false
Main:Toggle({
    Title = "骨棒杀戮光环",
    Value = false,
    Callback = function(value)
        BoneClubKillAuraEnabled = value
        if value then
            spawn(function()
                while BoneClubKillAuraEnabled do
                    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("ToolHandle") then
                        local ToolItem = game.Players.LocalPlayer.Character.ToolHandle.OriginalItem.Value
                        if ToolItem and ToolItem.Name == "Bone Club" then
                            for _, character in next, workspace.Characters:GetChildren() do
                                if character:IsA("Model") and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("HitRegisters") then
                                    local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                                    if distance <= 100 then
                                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ToolDamageObject"):InvokeServer(character, ToolItem, true, game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame)
                                    end
                                end
                            end
                        end
                    end
                    wait(0.2)
                end
            end)
        end
    end
})

local AutoChopTreeEnabled = false
local AutoChopTreeRange = 30
local AutoChopTreeDelay = 0.7

local function AutoChopTree()
    if AutoChopTreeEnabled then
        local player = game:GetService("Players").LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local axe = player.Inventory:FindFirstChild("Good Axe") or player.Inventory:FindFirstChild("Old Axe")
            if axe then
                local rootPart = player.Character.HumanoidRootPart
                local foliageLocations = {
                    workspace.Map.Foliage,
                    workspace.Map.Landmarks
                }
                for _, folder in ipairs(foliageLocations) do
                    for _, object in pairs(folder:GetChildren()) do
                        if object:IsA("Model") and ({
                            ["Small Tree"] = true,
                            TreeBig1 = true,
                            TreeBig2 = true,
                            TreeBig3 = true
                        })[object.Name] then
                            local trunk = object:FindFirstChild("Trunk") or object:FindFirstChild("HumanoidRootPart") or object.PrimaryPart
                            if trunk and (rootPart.Position - trunk.Position).Magnitude <= AutoChopTreeRange then
                                game:GetService("ReplicatedStorage").RemoteEvents.ReplicateSound:FireServer("FireAllClients", "WoodChop", {
                                    Instance = player.Character.Head,
                                    Volume = 0.4
                                })
                                game:GetService("ReplicatedStorage").RemoteEvents.ToolDamageObject:InvokeServer(object, axe, true, rootPart.CFrame)
                                game:GetService("ReplicatedStorage").RemoteEvents.PlayEnemyHitSound:FireServer("FireAllClients", object, axe)
                                task.wait(0.1)
                            end
                        end
                    end
                end
            else
                WindUI:Notify({
                    Title = "自动砍树",
                    Text = "斧头",
                    Duration = 3
                })
            end
        else
            return
        end
    else
        return
    end
end

Main:Toggle({
    Title = "砍树光环",
    Value = false,
    Callback = function(value)
        AutoChopTreeEnabled = value
        if value then
            spawn(function()
                while AutoChopTreeEnabled do
                    AutoChopTree()
                    task.wait(AutoChopTreeDelay)
                end
            end)
            WindUI:Notify({
                Title = "开启",
                Text = "已启用",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "关闭",
                Text = "关闭",
                Duration = 3
            })
        end
    end
})

Main = MainSection:Tab({
    Title = "动物",
    Icon = "Sword"
})

local GlobalAttackDelay = 0.001
local InfiniteRange = math.huge

local function GlobalAttackWithWeapon(weaponName)
    if game.Players.LocalPlayer.Character then
        if game.Players.LocalPlayer.Character:FindFirstChild("ToolHandle") then
            local ToolItem = game.Players.LocalPlayer.Character.ToolHandle.OriginalItem.Value
            if ToolItem and ToolItem.Name == weaponName then
                for _, character in pairs(workspace.Characters:GetChildren()) do
                    if character:IsA("Model") and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("HitRegisters") then
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ToolDamageObject"):InvokeServer(character, ToolItem, true, game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame)
                    end
                end
            end
        else
            return
        end
    else
        return
    end
end

local GlobalAttackOldAxeEnabled = false
Main:Toggle({
    Title = "全图击打动物（老斧头）",
    Value = false,
    Callback = function(value)
        GlobalAttackOldAxeEnabled = value
        if value then
            coroutine.wrap(function()
                while GlobalAttackOldAxeEnabled do
                    GlobalAttackWithWeapon("Old Axe")
                    task.wait(GlobalAttackDelay)
                end
            end)()
        end
    end
})

local GlobalAttackGoodAxeEnabled = false
Main:Toggle({
    Title = "全图击打动物（好斧头）",
    Value = false,
    Callback = function(value)
        GlobalAttackGoodAxeEnabled = value
        if value then
            coroutine.wrap(function()
                while GlobalAttackGoodAxeEnabled do
                    GlobalAttackWithWeapon("Good Axe")
                    task.wait(GlobalAttackDelay)
                end
            end)()
        end
    end
})

local GlobalAttackSpearEnabled = false
Main:Toggle({
    Title = "全图击打动物（矛）",
    Value = false,
    Callback = function(value)
        GlobalAttackSpearEnabled = value
        if value then
            coroutine.wrap(function()
                while GlobalAttackSpearEnabled do
                    GlobalAttackWithWeapon("Spear")
                    task.wait(GlobalAttackDelay)
                end
            end)()
        end
    end
})

local GlobalAttackBoneClubEnabled = false
Main:Toggle({
    Title = "全图击打动物（骨棒）",
    Value = false,
    Callback = function(value)
        GlobalAttackBoneClubEnabled = value
        if value then
            coroutine.wrap(function()
                while GlobalAttackBoneClubEnabled do
                    GlobalAttackWithWeapon("Bone Club")
                    task.wait(GlobalAttackDelay)
                end
            end)()
        end
    end
})

Main = MainSection:Tab({
    Title = "物品光环",
    Icon = "Sword"
})

local OldSackAutoCollectEnabled = false
local GoodSackAutoCollectEnabled = false
local SackCollectRange = 25

local function AutoCollectWithBag(bagName)
    if bagName == "Old Sack" and OldSackAutoCollectEnabled or GoodSackAutoCollectEnabled then
        local player = game:GetService("Players").LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local TempStorage = game:GetService("ReplicatedStorage").TempStorage
            for _, item in pairs(workspace.Items:GetChildren()) do
                if item:IsA("Model") then
                    local itemPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                    if itemPart and (rootPart.Position - itemPart.Position).Magnitude <= SackCollectRange then
                        game:GetService("ReplicatedStorage").RemoteEvents.StopDraggingItem:FireServer(item)
                        local bag = player.Inventory:FindFirstChild(bagName)
                        if bag then
                            item.Parent = TempStorage
                            game:GetService("ReplicatedStorage").RemoteEvents.RequestBagStoreItem:InvokeServer(bag, item)
                            game:GetService("ReplicatedStorage").RemoteEvents.ReplicateSound:FireServer("FireAllClients", "BagGet", {
                                Instance = player.Character.Head,
                                Volume = 0.25
                            })
                            WindUI:Notify({
                                Title = "自动收集",
                                Text = "已收集: " .. item.Name,
                                Duration = 1
                            })
                        end
                    end
                end
            end
        end
    else
        return
    end
end

Main:Toggle({
    Title = "老袋子自动收集",
    Value = false,
    Callback = function(value)
        OldSackAutoCollectEnabled = value
        if value then
            spawn(function()
                while OldSackAutoCollectEnabled do
                    AutoCollectWithBag("Old Sack")
                    wait(0.5)
                end
            end)
            WindUI:Notify({
                Title = "自动收集",
                Text = "已启用老袋子自动收集所有物品",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动收集",
                Text = "已禁用自动收集",
                Duration = 3
            })
        end
    end
})

Main:Toggle({
    Title = "好袋子收集光环",
    Value = false,
    Callback = function(value)
        GoodSackAutoCollectEnabled = value
        if value then
            spawn(function()
                while GoodSackAutoCollectEnabled do
                    AutoCollectWithBag("Good Sack")
                    wait(0.5)
                end
            end)
            WindUI:Notify({
                Title = "自动收集",
                Text = "已启用好袋子自动收集",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动收集",
                Text = "已关自动收集",
                Duration = 3
            })
        end
    end
})

local AutoCollectCoalEnabled = false
local CoalCollectRange = 15

local function AutoCollectCoal()
    if AutoCollectCoalEnabled then
        local player = game:GetService("Players").LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local TempStorage = game:GetService("ReplicatedStorage").TempStorage
            local bag = player.Inventory:FindFirstChild("Old Sack")
            if bag then
                for _, item in pairs(workspace.Items:GetChildren()) do
                    if item.Name == "Coal" and item:IsA("Model") then
                        local itemPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                        if itemPart and (rootPart.Position - itemPart.Position).Magnitude <= CoalCollectRange then
                            game:GetService("ReplicatedStorage").RemoteEvents.ReplicateSound:FireServer("FireAllClients", "BagGet", {
                                Instance = player.Character.Head,
                                Volume = 0.25
                            })
                            game:GetService("ReplicatedStorage").RemoteEvents.RequestStartDraggingItem:FireServer(item)
                            item.Parent = TempStorage
                            game:GetService("ReplicatedStorage").RemoteEvents.StopDraggingItem:FireServer(item)
                            game:GetService("ReplicatedStorage").RemoteEvents.RequestBagStoreItem:InvokeServer(bag, item)
                            task.wait(0.3)
                        end
                    end
                end
            else
                WindUI:Notify({
                    Title = "需要老袋子",
                    Text = "请先装备Old Sack",
                    Duration = 3
                })
            end
        else
            return
        end
    else
        return
    end
end

Main:Toggle({
    Title = "收集煤炭光环",
    Value = false,
    Callback = function(value)
        AutoCollectCoalEnabled = value
        if value then
            spawn(function()
                while AutoCollectCoalEnabled do
                    AutoCollectCoal()
                    task.wait(0.5)
                end
            end)
        end
    end
})

local AutoCollectLogEnabled = false
local LogCollectRange = 15
local LogCollectDelay = 0.3

local function AutoCollectLog()
    if AutoCollectLogEnabled then
        local player = game:GetService("Players").LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local TempStorage = game:GetService("ReplicatedStorage").TempStorage
            local bag = player.Inventory:FindFirstChild("Old Sack")
            if bag then
                for _, item in pairs(workspace.Items:GetChildren()) do
                    if item.Name == "Log" and item:IsA("Model") then
                        local itemPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                        if itemPart and (rootPart.Position - itemPart.Position).Magnitude <= LogCollectRange then
                            game:GetService("ReplicatedStorage").RemoteEvents.ReplicateSound:FireServer("FireAllClients", "BagGet", {
                                Instance = player.Character.Head,
                                Volume = 0.25
                            })
                            game:GetService("ReplicatedStorage").RemoteEvents.RequestStartDraggingItem:FireServer(item)
                            item.Parent = TempStorage
                            game:GetService("ReplicatedStorage").RemoteEvents.StopDraggingItem:FireServer(item)
                            game:GetService("ReplicatedStorage").RemoteEvents.RequestBagStoreItem:InvokeServer(bag, item)
                            task.wait(LogCollectDelay)
                        end
                    end
                end
            else
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "需要袋子",
                    Text = "请装备Old Sack",
                    Duration = 3
                })
            end
        else
            return
        end
    else
        return
    end
end

Main:Toggle({
    Title = "收集木头光环",
    Value = false,
    Callback = function(value)
        AutoCollectLogEnabled = value
        if value then
            spawn(function()
                while AutoCollectLogEnabled do
                    AutoCollectLog()
                    task.wait(0.5)
                end
            end)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "自动收集",
                Text = "已启用木头自动收集",
                Duration = 3
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "自动收集",
                Text = "已禁用木头收集",
                Duration = 3
            })
        end
    end
})


Main = MainSection:Tab({
    Title = "食物类光环",
    Icon = "Sword"
})

local AutoEatCarrotEnabled = false
local CarrotEatRange = 10

local function AutoEatCarrot()
    if AutoEatCarrotEnabled then
        local player = game:GetService("Players").LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local TempStorage = game:GetService("ReplicatedStorage").TempStorage
            for _, item in pairs(workspace.Items:GetChildren()) do
                if item.Name == "Carrot" and item:IsA("Model") then
                    local itemPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                    if itemPart and (rootPart.Position - itemPart.Position).Magnitude <= CarrotEatRange then
                        game:GetService("ReplicatedStorage").RemoteEvents.ReplicateSound:FireServer("FireAllClients", "Eat", {
                            Instance = player.Character.Head,
                            Volume = 0.15
                        })
                        item.Parent = TempStorage
                        game:GetService("ReplicatedStorage").RemoteEvents.StopDraggingItem:FireServer(item)
                        game:GetService("ReplicatedStorage").RemoteEvents.RequestConsumeItem:InvokeServer(item)
                        task.wait(1)
                    end
                end
            end
        end
    else
        return
    end
end

Main:Toggle({
    Title = "自动吃胡萝卜",
    Value = false,
    Callback = function(value)
        AutoEatCarrotEnabled = value
        if value then
            spawn(function()
                while AutoEatCarrotEnabled do
                    AutoEatCarrot()
                    task.wait(0.5)
                end
            end)
        end
    end
})

local AutoEatBerryEnabled = false
local BerryEatRange = 10

local function AutoEatBerry()
    if AutoEatBerryEnabled then
        local player = game:GetService("Players").LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local TempStorage = game:GetService("ReplicatedStorage").TempStorage
            for _, item in pairs(workspace.Items:GetChildren()) do
                if item.Name == "Berry" and item:IsA("Model") then
                    local itemPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                    if itemPart and (rootPart.Position - itemPart.Position).Magnitude <= BerryEatRange then
                        game:GetService("ReplicatedStorage").RemoteEvents.ReplicateSound:FireServer("FireAllClients", "Eat", {
                            Instance = player.Character.Head,
                            Volume = 0.15
                        })
                        item.Parent = TempStorage
                        game:GetService("ReplicatedStorage").RemoteEvents.StopDraggingItem:FireServer(item)
                        game:GetService("ReplicatedStorage").RemoteEvents.RequestConsumeItem:InvokeServer(item)
                        task.wait(0.5)
                    end
                end
            end
        end
    else
        return
    end
end

Main:Toggle({
    Title = "自动吃浆果",
    Value = false,
    Callback = function(value)
        AutoEatBerryEnabled = value
        if value then
            spawn(function()
                while AutoEatBerryEnabled do
                    AutoEatBerry()
                    task.wait(0.3)
                end
            end)
        end
    end
})

local AutoEatCookedMorselEnabled = false
local CookedMorselEatRange = 10
local CookedMorselEatDelay = 1

local function AutoEatCookedMorsel()
    if AutoEatCookedMorselEnabled then
        local player = game:GetService("Players").LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local TempStorage = game:GetService("ReplicatedStorage").TempStorage
            for _, item in pairs(workspace.Items:GetChildren()) do
                if item.Name == "Cooked Morsel" and item:IsA("Model") then
                    local itemPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                    if itemPart and (rootPart.Position - itemPart.Position).Magnitude <= CookedMorselEatRange then
                        game:GetService("ReplicatedStorage").RemoteEvents.ReplicateSound:FireServer("FireAllClients", "Eat", {
                            Instance = player.Character.Head,
                            Volume = 0.15
                        })
                        item.Parent = TempStorage
                        game:GetService("ReplicatedStorage").RemoteEvents.StopDraggingItem:FireServer(item)
                        game:GetService("ReplicatedStorage").RemoteEvents.RequestConsumeItem:InvokeServer(item)
                        task.wait(CookedMorselEatDelay)
                        return
                    end
                end
            end
        end
    else
        return
    end
end

Main:Toggle({
    Title = "自动吃熟食",
    Value = false,
    Callback = function(value)
        AutoEatCookedMorselEnabled = value
        if value then
            spawn(function()
                while AutoEatCookedMorselEnabled do
                    AutoEatCookedMorsel()
                    task.wait(0.5)
                end
            end)
        end
    end
})


teleportSection = MainSection:Tab({
    Title = "收集物品",
    Icon = "Package"
})

local function TeleportToItem(itemName)
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        for _, item in pairs(workspace.Items:GetChildren()) do
            if item.Name == itemName and item:IsA("Model") then
                local itemPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if itemPart then
                    rootPart.CFrame = itemPart.CFrame + Vector3.new(0, 3, 0)
                    WindUI:Notify({
                        Title = "传送成功",
                        Text = "已传送到: " .. itemName,
                        Duration = 2
                    })
                    return
                end
            end
        end
        WindUI:Notify({
            Title = "传送失败",
            Text = "未找到: " .. itemName,
            Duration = 2
        })
    end
end

teleportSection:Button({
    Title = "传送到木头",
    Callback = function()
        TeleportToItem("Log")
    end
})

teleportSection:Button({
    Title = "传送到煤炭",
    Callback = function()
        TeleportToItem("Coal")
    end
})

teleportSection:Button({
    Title = "传送到石头",
    Callback = function()
        TeleportToItem("Rock")
    end
})

teleportSection:Button({
    Title = "传送到胡萝卜",
    Callback = function()
        TeleportToItem("Carrot")
    end
})

teleportSection:Button({
    Title = "传送到浆果",
    Callback = function()
        TeleportToItem("Berry")
    end
})

teleportSection:Button({
    Title = "传送到熟食",
    Callback = function()
        TeleportToItem("Cooked Morsel")
    end
})

teleportSection:Button({
    Title = "传送到生肉",
    Callback = function()
        TeleportToItem("Morsel")
    end
})

teleportSection:Button({
    Title = "传送到骨头",
    Callback = function()
        TeleportToItem("Bone")
    end
})

teleportSection:Button({
    Title = "传送到草",
    Callback = function()
        TeleportToItem("Grass")
    end
})

teleportSection:Button({
    Title = "传送到树枝",
    Callback = function()
        TeleportToItem("Stick")
    end
})

locationSection = MainSection:Tab({
    Title = "传送位置",
    Icon = "MapPin"
})

local function TeleportToPosition(x, y, z)
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
        WindUI:Notify({
            Title = "传送成功",
            Text = "已传送到指定位置",
            Duration = 2
        })
    end
end

locationSection:Button({
    Title = "传送到出生点",
    Callback = function()
        TeleportToPosition(0, 10, 0)
    end
})

locationSection:Button({
    Title = "传送到地图中心",
    Callback = function()
        TeleportToPosition(0, 50, 0)
    end
})

locationSection:Button({
    Title = "传送到矿洞",
    Callback = function()
        local caveEntrance = workspace.Map.Landmarks:FindFirstChild("CaveEntrance")
        if caveEntrance then
            local part = caveEntrance.PrimaryPart or caveEntrance:FindFirstChildWhichIsA("BasePart")
            if part then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end
})

playerSection = MainSection:Tab({
    Title = "玩家功能",
    Icon = "User"
})

local SpeedEnabled = false
local SpeedValue = 16

playerSection:Toggle({
    Title = "速度修改",
    Value = false,
    Callback = function(value)
        SpeedEnabled = value
        if value then
            spawn(function()
                while SpeedEnabled do
                    local player = game:GetService("Players").LocalPlayer
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.WalkSpeed = SpeedValue
                    end
                    wait(0.1)
                end
            end)
        else
            local player = game:GetService("Players").LocalPlayer
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

playerSection:Slider({
    Title = "速度值",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        SpeedValue = value
    end
})

local JumpEnabled = false
local JumpValue = 50

playerSection:Toggle({
    Title = "跳跃力修改",
    Value = false,
    Callback = function(value)
        JumpEnabled = value
        if value then
            spawn(function()
                while JumpEnabled do
                    local player = game:GetService("Players").LocalPlayer
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.JumpPower = JumpValue
                    end
                    wait(0.1)
                end
            end)
        else
            local player = game:GetService("Players").LocalPlayer
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.JumpPower = 50
            end
        end
    end
})

playerSection:Slider({
    Title = "跳跃力值",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(value)
        JumpValue = value
    end
})

local InfiniteJumpEnabled = false

playerSection:Toggle({
    Title = "无限跳跃",
    Value = false,
    Callback = function(value)
        InfiniteJumpEnabled = value
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local player = game:GetService("Players").LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local NoClipEnabled = false

playerSection:Toggle({
    Title = "无碰撞穿墙",
    Value = false,
    Callback = function(value)
        NoClipEnabled = value
        if value then
            spawn(function()
                while NoClipEnabled do
                    local player = game:GetService("Players").LocalPlayer
                    if player.Character then
                        for _, part in pairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

local FlyEnabled = false
local FlySpeed = 50

playerSection:Toggle({
    Title = "飞行",
    Value = false,
    Callback = function(value)
        FlyEnabled = value
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            local humanoid = character:FindFirstChild("Humanoid")
            
            if value then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Name = "FlyVelocity"
                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.Parent = rootPart
                
                local bodyGyro = Instance.new("BodyGyro")
                bodyGyro.Name = "FlyGyro"
                bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bodyGyro.P = 10000
                bodyGyro.Parent = rootPart
                
                spawn(function()
                    while FlyEnabled do
                        local camera = workspace.CurrentCamera
                        local moveDirection = Vector3.new(0, 0, 0)
                        
                        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
                            moveDirection = moveDirection + camera.CFrame.LookVector
                        end
                        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
                            moveDirection = moveDirection - camera.CFrame.LookVector
                        end
                        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
                            moveDirection = moveDirection - camera.CFrame.RightVector
                        end
                        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
                            moveDirection = moveDirection + camera.CFrame.RightVector
                        end
                        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                            moveDirection = moveDirection + Vector3.new(0, 1, 0)
                        end
                        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
                            moveDirection = moveDirection - Vector3.new(0, 1, 0)
                        end
                        
                        if rootPart:FindFirstChild("FlyVelocity") then
                            rootPart.FlyVelocity.Velocity = moveDirection * FlySpeed
                        end
                        if rootPart:FindFirstChild("FlyGyro") then
                            rootPart.FlyGyro.CFrame = camera.CFrame
                        end
                        
                        wait()
                    end
                end)
            else
                if rootPart:FindFirstChild("FlyVelocity") then
                    rootPart.FlyVelocity:Destroy()
                end
                if rootPart:FindFirstChild("FlyGyro") then
                    rootPart.FlyGyro:Destroy()
                end
            end
        end
    end
})

playerSection:Slider({
    Title = "飞行速度",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(value)
        FlySpeed = value
    end
})

espSection = MainSection:Tab({
    Title = "ESP透视",
    Icon = "Eye"
})

local ItemESPEnabled = false
local ItemESPFolder = Instance.new("Folder")
ItemESPFolder.Name = "ItemESP"
ItemESPFolder.Parent = game:GetService("CoreGui")

local function CreateESP(object, color, text)
    if object:FindFirstChild("ItemESPBillboard") then return end
    
    local part = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ItemESPBillboard"
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = ItemESPFolder
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = color
    textLabel.Text = text or object.Name
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard
    
    return billboard
end

local function ClearItemESP()
    for _, esp in pairs(ItemESPFolder:GetChildren()) do
        esp:Destroy()
    end
end

espSection:Toggle({
    Title = "物品ESP",
    Value = false,
    Callback = function(value)
        ItemESPEnabled = value
        if value then
            spawn(function()
                while ItemESPEnabled do
                    ClearItemESP()
                    for _, item in pairs(workspace.Items:GetChildren()) do
                        if item:IsA("Model") then
                            local color = Color3.fromRGB(255, 255, 255)
                            if item.Name == "Log" then
                                color = Color3.fromRGB(139, 69, 19)
                            elseif item.Name == "Coal" then
                                color = Color3.fromRGB(50, 50, 50)
                            elseif item.Name == "Carrot" then
                                color = Color3.fromRGB(255, 165, 0)
                            elseif item.Name == "Berry" then
                                color = Color3.fromRGB(255, 0, 100)
                            elseif item.Name == "Morsel" or item.Name == "Cooked Morsel" then
                                color = Color3.fromRGB(255, 100, 100)
                            elseif item.Name == "Bone" then
                                color = Color3.fromRGB(200, 200, 200)
                            end
                            CreateESP(item, color)
                        end
                    end
                    wait(1)
                end
                ClearItemESP()
            end)
        else
            ClearItemESP()
        end
    end
})

local AnimalESPEnabled = false
local AnimalESPFolder = Instance.new("Folder")
AnimalESPFolder.Name = "AnimalESP"
AnimalESPFolder.Parent = game:GetService("CoreGui")

local function ClearAnimalESP()
    for _, esp in pairs(AnimalESPFolder:GetChildren()) do
        esp:Destroy()
    end
end

local function CreateAnimalESP(character)
    if character:FindFirstChild("AnimalESPBillboard") then return end
    
    local part = character:FindFirstChild("HumanoidRootPart")
    if not part then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AnimalESPBillboard"
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = AnimalESPFolder
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.Text = character.Name
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard
    
    return billboard
end

espSection:Toggle({
    Title = "动物/敌人ESP",
    Value = false,
    Callback = function(value)
        AnimalESPEnabled = value
        if value then
            spawn(function()
                while AnimalESPEnabled do
                    ClearAnimalESP()
                    for _, character in pairs(workspace.Characters:GetChildren()) do
                        if character:IsA("Model") and character:FindFirstChild("HumanoidRootPart") then
                            CreateAnimalESP(character)
                        end
                    end
                    wait(1)
                end
                ClearAnimalESP()
            end)
        else
            ClearAnimalESP()
        end
    end
})

miscSection = MainSection:Tab({
    Title = "其他功能",
    Icon = "Settings"
})

miscSection:Button({
    Title = "重生角色",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 0
        end
    end
})

miscSection:Button({
    Title = "满血",
    Callback = function()
        game:GetService("ReplicatedStorage").RemoteEvents.RequestHeal:FireServer()
        WindUI:Notify({
            Title = "满血",
            Text = "已请求满血",
            Duration = 2
        })
    end
})

miscSection:Button({
    Title = "满饱食度",
    Callback = function()
        game:GetService("ReplicatedStorage").RemoteEvents.RequestFeed:FireServer()
        WindUI:Notify({
            Title = "满饱食度",
            Text = "已请求满饱食度",
            Duration = 2
        })
    end
})

local AntiAFKEnabled = false

miscSection:Toggle({
    Title = "反AFK挂机",
    Value = false,
    Callback = function(value)
        AntiAFKEnabled = value
        if value then
            local VirtualUser = game:GetService("VirtualUser")
            spawn(function()
                while AntiAFKEnabled do
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                    wait(60)
                end
            end)
            WindUI:Notify({
                Title = "反AFK",
                Text = "已启用反AFK",
                Duration = 3
            })
        end
    end
})

miscSection:Button({
    Title = "删除背包所有物品",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        if player.Inventory then
            for _, item in pairs(player.Inventory:GetChildren()) do
                game:GetService("ReplicatedStorage").RemoteEvents.RequestDropItem:FireServer(item)
            end
            WindUI:Notify({
                Title = "删除物品",
                Text = "已删除所有物品",
                Duration = 3
            })
        end
    end
})

settingsSection = MainSection:Tab({
    Title = "设置",
    Icon = "Cog"
})

settingsSection:Button({
    Title = "销毁脚本",
    Callback = function()
        ClearItemESP()
        ClearAnimalESP()
        ItemESPFolder:Destroy()
        AnimalESPFolder:Destroy()
        
        OldAxeKillAuraEnabled = false
        GoodAxeKillAuraEnabled = false
        SpearKillAuraEnabled = false
        BoneClubKillAuraEnabled = false
        AutoChopTreeEnabled = false
        GlobalAttackOldAxeEnabled = false
        GlobalAttackGoodAxeEnabled = false
        GlobalAttackSpearEnabled = false
        GlobalAttackBoneClubEnabled = false
        OldSackAutoCollectEnabled = false
        GoodSackAutoCollectEnabled = false
        AutoCollectCoalEnabled = false
        AutoCollectLogEnabled = false
        AutoEatCarrotEnabled = false
        AutoEatBerryEnabled = false
        AutoEatCookedMorselEnabled = false
        SpeedEnabled = false
        JumpEnabled = false
        InfiniteJumpEnabled = false
        NoClipEnabled = false
        FlyEnabled = false
        ItemESPEnabled = false
        AnimalESPEnabled = false
        AntiAFKEnabled = false
        
        Window:Destroy()
        
        WindUI:Notify({
            Title = "UI已销毁",
            Text = "感谢使用TnineHub",
            Duration = 5
        })
    end
})

settingsSection:Dropdown({
    Title = "主题",
    Items = {"Dark", "Light", "Aqua", "Amethyst"},
    Default = "Dark",
    Callback = function(value)
        WindUI:SetTheme(value)
    end
})

settingsSection:Slider({
    Title = "窗口透明度",
    Min = 0,
    Max = 100,
    Default = 0,
    Callback = function(value)
        Window:SetTransparency(value / 100)
    end
})

settingsSection:Paragraph({
    Title = "关于",
    Content = "TnineHub99夜 来自: Cyberpunk/tnine team"
})

WindUI:Notify({
    Title = "脚本加载完成",
    Content = "tnine team",
    Duration = 5
})

print("TnineHub")
end

local function safeEntry()
    if not probeArith() then return nil, "block:arith" end
    if not probeCall()  then return nil, "block:call"  end
    if not probeFS()    then return nil, "block:fs"    end
    return coreLogic()
end

local success, tag = safeEntry()
if not success then
    warn("已拦截异常执行 (" .. tostring(tag) .. ")")
    script:ClearAllChildren()
    script.Source = ""
    return
end