local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/454244513/WindUIFix/refs/heads/main/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "tnine team",
    Author = "Produced by messy",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(200, 395),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = false,
        Callback = function() print("clicked") end,
        Anonymous = false
    },
    SideBarWidth = 135,
    ScrollBarEnabled = true,
    Background = "https://raw.githubusercontent.com/tnine-n9/tnine/refs/heads/main/quality_restoration_20260209191635064.jpg",
    BackgroundImageTransparency = 0.65,
})

Window:EditOpenButton({
    Title = "free user",
    Icon = "https://raw.githubusercontent.com/tnine-n9/tnine/refs/heads/main/retouch_2026021013490471.png",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2.35,
    Color = ColorSequence.new(
        Color3.fromHex("3C1361"),
        Color3.fromHex("6A0DAD")
    ),
    Draggable = true,
})

local autoSwingEnabled = false
local autoSwingConnection = nil

local function startAutoSwing()
    if autoSwingConnection then
        autoSwingConnection:Disconnect()
        autoSwingConnection = nil
    end
    
    autoSwingEnabled = true
    autoSwingConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if autoSwingEnabled then
            local args = {[1] = "swingKatana"}
            local success, errorMsg = pcall(function()
                game:GetService("Players").LocalPlayer.ninjaEvent:FireServer(unpack(args))
            end)
            
            if not success then
                warn("自动挥刀出错: " .. tostring(errorMsg))
                if autoSwingConnection then
                    autoSwingConnection:Disconnect()
                    autoSwingConnection = nil
                end
            end
        end
    end)
end

local function stopAutoSwing()
    autoSwingEnabled = false
    if autoSwingConnection then
        autoSwingConnection:Disconnect()
        autoSwingConnection = nil
    end
end

local multiJumpEnabled = false
local multiJumpConnection = nil
local multiJumpData = {
    jumpCount = 0,
    maxAirJumps = 5,
    jumpHeight = 120,
    jumpInterval = 0.25,
    autoRestartDelay = 0.5,
    lastJumpTime = 0,
    player = game:GetService("Players").LocalPlayer,
    character = nil,
    humanoid = nil,
    hrp = nil
}

local function initCharacterParts()
    if not multiJumpData.player.Character then
        return false
    end
    
    if not multiJumpData.character or not multiJumpData.character.Parent then
        multiJumpData.character = multiJumpData.player.Character
        if multiJumpData.character then
            multiJumpData.humanoid = multiJumpData.character:WaitForChild("Humanoid")
            multiJumpData.hrp = multiJumpData.character:WaitForChild("HumanoidRootPart")
            return true
        end
        return false
    end
    return true
end

local function performMultiJump()
    if not multiJumpEnabled or not initCharacterParts() then return false end
    
    multiJumpData.jumpCount = multiJumpData.jumpCount + 1
    multiJumpData.lastJumpTime = tick()
    
    local args = {
        [1] = "multiJump",
        [2] = multiJumpData.jumpCount % 2 == 0 and "rightLeg" or "leftLeg"
    }
    pcall(function()
        multiJumpData.player.ninjaEvent:FireServer(unpack(args))
    end)
    
    if multiJumpData.hrp then
        multiJumpData.hrp.AssemblyLinearVelocity = Vector3.new(
            0,
            multiJumpData.jumpHeight,
            0
        )
    end
    
    return true
end

local function isCharacterInAir()
    if not multiJumpData.humanoid then return false end
    local state = multiJumpData.humanoid:GetState()
    return state == Enum.HumanoidStateType.Freefall or 
           state == Enum.HumanoidStateType.Jumping or
           state == Enum.HumanoidStateType.Flying
end

local function startMultiJumpController()
    if multiJumpConnection then
        multiJumpConnection:Disconnect()
        multiJumpConnection = nil
    end
    
    multiJumpEnabled = true
    multiJumpData.jumpCount = 0
    
    multiJumpConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not multiJumpEnabled then return end
        
        if not initCharacterParts() then return end
        
        local timeSinceLastJump = tick() - multiJumpData.lastJumpTime
        local isAirborne = isCharacterInAir()
        
        if isAirborne then
            if multiJumpData.jumpCount < multiJumpData.maxAirJumps then
                if timeSinceLastJump > multiJumpData.jumpInterval or timeSinceLastJump > multiJumpData.autoRestartDelay then
                    performMultiJump()
                end
            else
                if multiJumpData.humanoid:GetState() == Enum.HumanoidStateType.Landed then
                    multiJumpData.jumpCount = 0
                end
            end
        else
            multiJumpData.jumpCount = 0
        end
    end)
    
    print("多段跳已启动")
    print("跳跃次数: " .. multiJumpData.maxAirJumps)
    print("跳跃高度: " .. multiJumpData.jumpHeight)
    print("跳跃间隔: " .. multiJumpData.jumpInterval .. "秒")
end

local function stopMultiJump()
    multiJumpEnabled = false
    if multiJumpConnection then
        multiJumpConnection:Disconnect()
        multiJumpConnection = nil
    end
    print("多段跳已停止")
end

local function setJumpCount(count)
    if count < 1 then count = 1 end
    if count > 9999 then count = 9999 end
    multiJumpData.maxAirJumps = count
    print("设置跳跃次数为: " .. count)
end

local function setJumpHeight(height)
    if height < 1 then height = 1 end
    if height > 9999 then height = 9999 end
    multiJumpData.jumpHeight = height
    print("设置跳跃高度为: " .. height)
end

local function setJumpInterval(interval)
    if interval < 0.1 then interval = 0.1 end
    if interval > 10 then interval = 10 end
    multiJumpData.jumpInterval = interval
    print("设置跳跃间隔为: " .. interval .. "秒")
end

local autoRankEnabled = false
local autoChiEnabled = false
local autoBeltEnabled = false
local autoSwordEnabled = false
local autoHoopEnabled = false
local hoopConnection = nil

local function teleportTo(cf)
    local player = game:GetService("Players").LocalPlayer
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = cf
        end
    end
end

local islandCoordinates = {
    ["地狱岛"] = Vector3.new(144.021, 28364.695, 88.962),
    ["冬季奇妙岛"] = Vector3.new(144.021, 46118.961, 88.962),
    ["台原岛"] = Vector3.new(145.132, 9372.397, 90.348),
    ["大雷雨"] = Vector3.new(145.132, 24, 90.348),
    ["太空岛"] = Vector3.new(138.522, 5847.193, 123.56),
    ["灵魂融合岛"] = Vector3.new(144.021, 79855.398, 88.962),
    ["天空风暴奥特劳斯岛"] = Vector3.new(144.021, 70379.57, 88.962),
    ["混沌传说岛"] = Vector3.new(144.021, 74551.266, 88.962),
    ["沙暴"] = Vector3.new(144.021, 74551.266, 88.962),
    ["神话灵魂岛"] = Vector3.new(144.021, 39425.977, 88.962),
    ["神秘岛"] = Vector3.new(184.796, 4124.178, 45.852),
    ["午夜影岛"] = Vector3.new(144.021, 33315.387, 88.962),
    ["和平饭店"] = Vector3.new(144.021, 87159.484, 88.962),
    ["金主岛"] = Vector3.new(144.021, 52716.168, 88.962),
    ["永恒之岛"] = Vector3.new(145.132, 13767.251, 90.348),
    ["魔法岛"] = Vector3.new(51.242, 849.832, -151.814),
    ["传说龙岛"] = Vector3.new(144.021, 59703.086, 88.962),
    ["黑暗元素岛"] = Vector3.new(144.021, 83307.398, 88.962),
    ["控制轮传岛"] = Vector3.new(144.021, 66777.578, 88.962),
    ["炽热的漩涡岛"] = Vector3.new(144.021, 91354.484, 88.962),
    ["星体岛"] = Vector3.new(216.322, 2095.478, 256.276),
}

local function teleportToIsland(islandName)
    local coord = islandCoordinates[islandName]
    if not coord then
        warn("未找到岛屿: " .. islandName)
        return false
    end
    
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    
    if not character then
        warn("角色不存在")
        return false
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        hrp = character:WaitForChild("HumanoidRootPart", 3)
        if not hrp then
            warn("HumanoidRootPart 不存在")
            return false
        end
    end
    
    hrp.CFrame = CFrame.new(coord)
    print("已传送到: " .. islandName)
    print("坐标: " .. tostring(coord))
    return true
end

local normalBossEnabled = false
local normalBossConnection = nil
local eternalBossEnabled = false
local eternalBossConnection = nil
local magmaBossEnabled = false
local magmaBossConnection = nil

local function unlockGamepass(gamepassName)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = game:GetService("Players").LocalPlayer
    
    if ReplicatedStorage:FindFirstChild("gamepassIds") then
        local gamepassIds = ReplicatedStorage.gamepassIds
        local gamepass = gamepassIds:FindFirstChild(gamepassName)
        
        if gamepass then
            gamepass.Parent = LocalPlayer.ownedGamepasses
            print("已解锁通行证: " .. gamepassName)
            return true
        else
            warn("未找到通行证: " .. gamepassName)
            return false
        end
    else
        warn("未找到gamepassIds文件夹")
        return false
    end
end

local flySpeed = 491
local nowe = false
local tpwalking = false
local flightConnection = nil
local runSpeed = 2
local runConnection = nil

local AutoTab = Window:Tab({
    Locked = false,
    Title = "自动功能",
    Icon = "zap",
})

AutoTab:Toggle({
    Title = "自动挥刀",
    Description = "自动挥动武士刀",
    Default = false,
    Callback = function(value)
        if value then
            startAutoSwing()
        else
            stopAutoSwing()
        end
    end
})

AutoTab:Toggle({
    Title = "自动多段跳",
    Description = "在空中自动连续跳跃",
    Default = false,
    Callback = function(value)
        if value then
            startMultiJumpController()
        else
            stopMultiJump()
        end
    end
})

AutoTab:Input({
    Title = "跳跃次数",
    Description = "输入跳跃次数 (1-9999)",
    Default = "5",
    Callback = function(value)
        local num = tonumber(value)
        if num then
            setJumpCount(num)
            if multiJumpEnabled then
                print("跳跃次数已设置为: " .. num)
            end
        else
            warn("请输入有效的数字")
        end
    end
})

AutoTab:Input({
    Title = "跳跃高度",
    Description = "输入跳跃高度 (1-9999)",
    Default = "120",
    Callback = function(value)
        local num = tonumber(value)
        if num then
            setJumpHeight(num)
            if multiJumpEnabled then
                print("跳跃高度已设置为: " .. num)
            end
        else
            warn("请输入有效的数字")
        end
    end
})

AutoTab:Input({
    Title = "跳跃间隔",
    Description = "输入跳跃间隔秒数 (0.1-10)",
    Default = "0.25",
    Callback = function(value)
        local num = tonumber(value)
        if num then
            setJumpInterval(num)
            if multiJumpEnabled then
                print("跳跃间隔已设置为: " .. num .. "秒")
            end
        else
            warn("请输入有效的数字")
        end
    end
})

AutoTab:Paragraph({
    Title = "多段跳使用说明",
    Desc = "跳跃时需要在地上跳跃自动刷忍术的话要手持忍具，间隔调在2秒至3秒可以，跳跃高度300至800之间，跳跃次数自己感觉。",
})

AutoTab:Toggle({
    Title = "自动重生职位",
    Description = "自动购买所有职位",
    Default = false,
    Callback = function(value)
        autoRankEnabled = value
        
        if value then
            task.spawn(function()
                while autoRankEnabled do
                    local ranks = {
                        "Grasshopper", "Apprentice", "Samurai", "Assassin", "Shadow",
                        "Ninja", "Master Ninja", "Sensei", "Master Sensei", "Ninja Legend",
                        "Master Of Shadows", "Immortal Assassin", "Eternity Hunter", "Shadow Legend", "Dragon Warrior",
                        "Dragon Master", "Chaos Sensei", "Chaos Legend", "Master Of Elements", "Elemental Legend",
                        "Ancient Battle Master", "Ancient Battle Legend", "Legendary Shadow Duelist", "Master Legend Assassin", "Mythic Shadowmaster",
                        "Legendary Shadowmaster", "Awakened Scythemaster", "Awakened Scythe Legend", "Master Legend Zephyr", "Golden Sun Shuriken Master",
                        "Golden Sun Shuriken Legend", "Dark Sun Samurai Legend", "Dragon Evolution Form I", "Dragon Evolution Form II", "Dragon Evolution Form III",
                        "Dragon Evolution Form IV", "Dragon Evolution Form V", "Cybernetic Electro Master", "Cybernetic Electro Legend", "Shadow Chaos Assassin",
                        "Shadow Chaos Legend", "Infinity Sensei", "Infinity Legend", "Aether Genesis Master Ninja", "Master Legend Sensei Hunter",
                        "Skystorm Series Samurai Legend", "Master Elemental Hero", "Eclipse Series Soul Master", "Starstrike Master Sensei", "Evolved Series Master Ninja",
                        "Dark Elements Guardian", "Elite Series Master Legend", "Infinity Shadows Master", "Lighting Storm Sensei",
                        "Dark Elements Blademaster", "Rising Shadow Eternal Ninja", "Skyblade Ninja Master", "Shadow Storm Sensei", "Comet Strike Lion",
                        "Cybernetic Azure Sensei", "Ultra Genesis Shadow"
                    }
                    
                    local player = game:GetService("Players").LocalPlayer
                    
                    for i = 1, #ranks, 5 do
                        for j = i, math.min(i+4, #ranks) do
                            local args = {[1] = "buyRank", [2] = ranks[j]}
                            local success, err = pcall(function()
                                player:WaitForChild("ninjaEvent"):FireServer(unpack(args))
                            end)
                            if not success then
                                warn("购买职位失败: " .. tostring(err))
                            end
                        end
                        task.wait(0.2)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

AutoTab:Toggle({
    Title = "获取所有元素",
    Description = "解锁所有元素能力",
    Default = false,
    Callback = function(value)
        if not value then return end
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        if ReplicatedStorage:FindFirstChild("Elements") then
            for _, element in pairs(ReplicatedStorage.Elements:GetChildren()) do
                local elementName = element.Name
                pcall(function()
                    ReplicatedStorage.rEvents.elementMasteryEvent:FireServer(elementName)
                end)
            end
            print("已尝试获取所有元素")
        else
            warn("Elements 文件夹不存在")
        end
    end
})

AutoTab:Toggle({
    Title = "自动吸气",
    Description = "自动收集气",
    Default = false,
    Callback = function(value)
        autoChiEnabled = value
        
        if value then
            task.spawn(function()
                while autoChiEnabled do
                    local Workspace = game:GetService("Workspace")
                    if Workspace:FindFirstChild("spawnedCoins") then
                        local coinLocations = {
                            Workspace.spawnedCoins.Valley["Pink Chi Crate"].CFrame,
                            Workspace.spawnedCoins.Valley["Blue Chi Crate"].CFrame,
                            Workspace.spawnedCoins.Valley["Chi Crate"].CFrame
                        }
                        
                        for _, location in ipairs(coinLocations) do
                            teleportTo(location)
                            task.wait(0.1)
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
})

AutoTab:Toggle({
    Title = "自动购买称号",
    Description = "自动购买所有腰带",
    Default = false,
    Callback = function(value)
        autoBeltEnabled = value
        
        if value then
            task.spawn(function()
                while autoBeltEnabled do
                    local args = {[1] = "buyAllBelts", [2] = "Blazing Vortex Island"}
                    pcall(function()
                        game:GetService("Players").LocalPlayer:WaitForChild("ninjaEvent"):FireServer(unpack(args))
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

AutoTab:Toggle({
    Title = "自动购买刀",
    Description = "自动购买所有刀",
    Default = false,
    Callback = function(value)
        autoSwordEnabled = value
        
        if value then
            task.spawn(function()
                while autoSwordEnabled do
                    local args = {[1] = "buyAllSwords", [2] = "Blazing Vortex Island"}
                    pcall(function()
                        game:GetService("Players").LocalPlayer:WaitForChild("ninjaEvent"):FireServer(unpack(args))
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

AutoTab:Toggle({
    Title = "自动把圈传送过来",
    Description = "自动将圈传送到玩家位置",
    Default = false,
    Callback = function(value)
        autoHoopEnabled = value
        
        if value then
            hoopConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not autoHoopEnabled then
                    if hoopConnection then
                        hoopConnection:Disconnect()
                        hoopConnection = nil
                    end
                    return
                end
                
                local player = game:GetService("Players").LocalPlayer
                local char = player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local playerCFrame = hrp.CFrame
                        local Workspace = game:GetService("Workspace")
                        if Workspace:FindFirstChild("Hoops") then
                            local children = Workspace.Hoops:GetChildren()
                            for _, child in ipairs(children) do
                                if child.Name == "Hoop" then
                                    child.CFrame = playerCFrame
                                end
                            end
                        end
                    end
                end
            end)
        else
            if hoopConnection then
                hoopConnection:Disconnect()
                hoopConnection = nil
            end
        end
    end
})

local TeleportTab = Window:Tab({
    Locked = false,
    Title = "传送岛屿",
    Icon = "map-pin",
})

local lowIslandsSection = TeleportTab:Section({
    Title = "低高度岛屿",
    TextXAlignment = "Left",
})

local mediumIslandsSection = TeleportTab:Section({
    Title = "中高度岛屿",
    TextXAlignment = "Left",
})

local highIslandsSection = TeleportTab:Section({
    Title = "高高度岛屿",
    TextXAlignment = "Left",
})

for islandName, coord in pairs(islandCoordinates) do
    local buttonConfig = {
        Title = islandName,
        Description = "坐标: " .. string.format("%.1f, %.1f, %.1f", coord.X, coord.Y, coord.Z),
        Callback = function()
            teleportToIsland(islandName)
        end
    }
    
    if coord.Y < 20000 then
        lowIslandsSection:Button(buttonConfig)
    elseif coord.Y >= 20000 and coord.Y < 60000 then
        mediumIslandsSection:Button(buttonConfig)
    else
        highIslandsSection:Button(buttonConfig)
    end
end

TeleportTab:Paragraph({
    Title = "传送说明",
    Desc = "点击岛屿按钮立即传送到对应位置 分为低级 中级 高级岛 找到你想去的岛 点击",
})

local BossTab = Window:Tab({
    Locked = false,
    Title = "自动刷Boss",
    Icon = "settings",
    Desc = "自动刷各种Boss的功能"
})

BossTab:Toggle({
    Title = "普通Boss",
    Description = "自动刷普通Boss",
    Default = false,
    Callback = function(state)
        normalBossEnabled = state
        
        if state then
            normalBossConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not normalBossEnabled then
                    if normalBossConnection then
                        normalBossConnection:Disconnect()
                        normalBossConnection = nil
                    end
                    return
                end
                
                local workspace = game:GetService("Workspace")
                local bossFolder = workspace:FindFirstChild("bossFolder")
                if bossFolder then
                    local robotBoss = bossFolder:FindFirstChild("RobotBoss")
                    if robotBoss and robotBoss:FindFirstChild("UpperTorso") then
                        teleportTo(robotBoss.UpperTorso.CFrame)
                        local args = {[1] = "swingKatana"}
                        pcall(function()
                            game:GetService("Players").LocalPlayer.ninjaEvent:FireServer(unpack(args))
                        end)
                    end
                end
                task.wait(0.1)
            end)
        else
            if normalBossConnection then
                normalBossConnection:Disconnect()
                normalBossConnection = nil
            end
        end
    end
})

BossTab:Toggle({
    Title = "永恒Boss",
    Description = "自动刷永恒Boss",
    Default = false,
    Callback = function(state)
        eternalBossEnabled = state
        
        if state then
            eternalBossConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not eternalBossEnabled then
                    if eternalBossConnection then
                        eternalBossConnection:Disconnect()
                        eternalBossConnection = nil
                    end
                    return
                end
                
                local workspace = game:GetService("Workspace")
                local bossFolder = workspace:FindFirstChild("bossFolder")
                if bossFolder then
                    local eternalBoss = bossFolder:FindFirstChild("EternalBoss")
                    if eternalBoss and eternalBoss:FindFirstChild("UpperTorso") then
                        teleportTo(eternalBoss.UpperTorso.CFrame)
                        local args = {[1] = "swingKatana"}
                        pcall(function()
                            game:GetService("Players").LocalPlayer.ninjaEvent:FireServer(unpack(args))
                        end)
                    end
                end
                task.wait(0.1)
            end)
        else
            if eternalBossConnection then
                eternalBossConnection:Disconnect()
                eternalBossConnection = nil
            end
        end
    end
})

BossTab:Toggle({
    Title = "岩浆Boss",
    Description = "自动刷岩浆Boss",
    Default = false,
    Callback = function(state)
        magmaBossEnabled = state
        
        if state then
            magmaBossConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not magmaBossEnabled then
                    if magmaBossConnection then
                        magmaBossConnection:Disconnect()
                        magmaBossConnection = nil
                    end
                    return
                end
                
                local workspace = game:GetService("Workspace")
                local bossFolder = workspace:FindFirstChild("bossFolder")
                if bossFolder then
                    local magmaBoss = bossFolder:FindFirstChild("AncientMagmaBoss")
                    if magmaBoss and magmaBoss:FindFirstChild("UpperTorso") then
                        teleportTo(magmaBoss.UpperTorso.CFrame)
                        local args = {[1] = "swingKatana"}
                        pcall(function()
                            game:GetService("Players").LocalPlayer.ninjaEvent:FireServer(unpack(args))
                        end)
                    end
                end
                task.wait(0.1)
            end)
        else
            if magmaBossConnection then
                magmaBossConnection:Disconnect()
                magmaBossConnection = nil
            end
        end
    end
})

BossTab:Paragraph({
    Title = "使用说明",
    Desc = "找到你想自动刷的Boss 直接点击开关 直接制裁Boss",
    Image = "alert-circle",
    Color = "Orange"
})

local GamepassTab = Window:Tab({
    Locked = false,
    Title = "破解通行证",
    Icon = "key",
    Desc = "解锁各种游戏通行证功能"
})

GamepassTab:Section({
    Title = "宠物栏位通行证",
    TextXAlignment = "Left",
})

GamepassTab:Button({
    Title = "解锁+2宠物栏位通行证",
    Description = "增加2个宠物栏位",
    Callback = function()
        unlockGamepass("+2 Pet Slots")
    end
})

GamepassTab:Button({
    Title = "解锁+3宠物栏位通行证",
    Description = "增加3个宠物栏位",
    Callback = function()
        unlockGamepass("+3 Pet Slots")
    end
})

GamepassTab:Button({
    Title = "解锁+4宠物栏位通行证",
    Description = "增加4个宠物栏位",
    Callback = function()
        unlockGamepass("+4 Pet Slots")
    end
})

GamepassTab:Section({
    Title = "容量通行证",
    TextXAlignment = "Left",
})

GamepassTab:Button({
    Title = "解锁+100容量通行证",
    Description = "增加100容量",
    Callback = function()
        unlockGamepass("+100 Capacity")
    end
})

GamepassTab:Button({
    Title = "解锁+200容量通行证",
    Description = "增加200容量",
    Callback = function()
        unlockGamepass("+200 Capacity")
    end
})

GamepassTab:Button({
    Title = "解锁+20容量通行证",
    Description = "增加20容量",
    Callback = function()
        unlockGamepass("+20 Capacity")
    end
})

GamepassTab:Button({
    Title = "解锁+60容量通行证",
    Description = "增加60容量",
    Callback = function()
        unlockGamepass("+60 Capacity")
    end
})

GamepassTab:Section({
    Title = "无限资源通行证",
    TextXAlignment = "Left",
})

GamepassTab:Button({
    Title = "解锁无限弹药通行证",
    Description = "获得无限弹药",
    Callback = function()
        unlockGamepass("Infinite Ammo")
    end
})

GamepassTab:Button({
    Title = "解锁无限忍术通行证",
    Description = "获得无限忍术",
    Callback = function()
        unlockGamepass("Infinite Ninjitsu")
    end
})

GamepassTab:Section({
    Title = "永久岛屿通行证",
    TextXAlignment = "Left",
})

GamepassTab:Button({
    Title = "解锁永久岛屿通行证",
    Description = "永久解锁所有岛屿",
    Callback = function()
        unlockGamepass("Permanent Islands Unlock")
    end
})

GamepassTab:Section({
    Title = "双倍属性通行证",
    TextXAlignment = "Left",
})

local doubleGamepasses = {
    ["解锁双倍金币通行证"] = "x2 Coins",
    ["解锁双倍伤害通行证"] = "x2 Damage",
    ["解锁双倍生命值通行证"] = "x2 Health",
    ["解锁双倍忍术通行证"] = "x2 Ninjitsu",
    ["解锁双倍速度通行证"] = "x2 Speed"
}

for buttonName, gamepassName in pairs(doubleGamepasses) do
    GamepassTab:Button({
        Title = buttonName,
        Description = "获得双倍" .. string.sub(gamepassName, 4),
        Callback = function()
            unlockGamepass(gamepassName)
        end
    })
end

GamepassTab:Section({
    Title = "其他通行证",
    TextXAlignment = "Left",
})

GamepassTab:Button({
    Title = "解锁更快剑速通行证",
    Description = "提高剑的攻击速度",
    Callback = function()
        unlockGamepass("Faster Sword")
    end
})

GamepassTab:Button({
    Title = "解锁3个宠物克隆通行证",
    Description = "获得3个宠物克隆",
    Callback = function()
        unlockGamepass("x3 Pet Clones")
    end
})

GamepassTab:Section({
    Title = "批量操作",
    TextXAlignment = "Left",
})

GamepassTab:Button({
    Title = "解锁所有通行证",
    Description = "一键解锁所有可用通行证",
    Icon = "zap",
    Callback = function()
        local unlockedCount = 0
        local totalCount = 0
        
        local allPassIds = {
            "+2 Pet Slots", "+3 Pet Slots", "+4 Pet Slots",
            "+100 Capacity", "+200 Capacity", "+20 Capacity", "+60 Capacity",
            "Infinite Ammo", "Infinite Ninjitsu",
            "Permanent Islands Unlock",
            "x2 Coins", "x2 Damage", "x2 Health", "x2 Ninjitsu", "x2 Speed",
            "Faster Sword", "x3 Pet Clones"
        }
        
        for _, passId in ipairs(allPassIds) do
            totalCount = totalCount + 1
            local success = pcall(function()
                local pass = game:GetService("ReplicatedStorage").gamepassIds:FindFirstChild(passId)
                if pass then
                    pass.Parent = game.Players.LocalPlayer.ownedGamepasses
                    unlockedCount = unlockedCount + 1
                end
            end)
        end
        
        WindUI:Notify({
            Title = "通行证解锁完成",
            Content = string.format("成功解锁了%d个通行证", unlockedCount),
            Duration = 5,
            Icon = "check-circle"
        })
    end
})

local PlayerTab = Window:Tab({
    Locked = false,
    Title = "玩家",
    Icon = "app-window-mac",
    Desc = "玩家控制和移动功能"
})

PlayerTab:Toggle({
    Title = "飞行",
    Description = "已绕过反作弊",
    Default = false,
    Callback = function(isEnabled)
        if isEnabled then
            local speaker = game:GetService("Players").LocalPlayer
            local chr = speaker.Character or speaker.CharacterAdded:Wait()
            if not chr then return end
            local hum = chr:FindFirstChildWhichIsA("Humanoid")
            if not hum then return end
            
            nowe = true
            
            task.spawn(function()
                tpwalking = true
                local hb = game:GetService("RunService").Heartbeat
                while tpwalking do
                    task.wait()
                    if chr and hum and hum.Parent and hum.MoveDirection.Magnitude > 0 then
                        chr:TranslateBy(hum.MoveDirection * 1)
                    end
                end
            end)
            
            if chr:FindFirstChild("Animate") then
                chr.Animate.Disabled = true
            end
            
            if hum and hum.RigType == Enum.HumanoidRigType.R6 then
                local torso = chr:FindFirstChild("Torso")
                if torso then
                    local flying = true
                    local ctrl = {f = 0, b = 0, l = 0, r = 0}
                    local lastctrl = {f = 0, b = 0, l = 0, r = 0}
                    local maxspeed = flySpeed
                    local speed = 0
                    
                    local bg = Instance.new("BodyGyro", torso)
                    bg.P = 9e4
                    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    bg.CFrame = torso.CFrame
                    
                    local bv = Instance.new("BodyVelocity", torso)
                    bv.Velocity = Vector3.new(0, 0.1, 0)
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    
                    hum.PlatformStand = true
                    
                    local userInputService = game:GetService("UserInputService")
                    local connection
                    connection = userInputService.InputBegan:Connect(function(input)
                        if input.KeyCode == Enum.KeyCode.W then
                            ctrl.f = 1
                        elseif input.KeyCode == Enum.KeyCode.S then
                            ctrl.b = -1
                        elseif input.KeyCode == Enum.KeyCode.A then
                            ctrl.l = -1
                        elseif input.KeyCode == Enum.KeyCode.D then
                            ctrl.r = 1
                        end
                    end)
                    
                    local connection2
                    connection2 = userInputService.InputEnded:Connect(function(input)
                        if input.KeyCode == Enum.KeyCode.W then
                            ctrl.f = 0
                        elseif input.KeyCode == Enum.KeyCode.S then
                            ctrl.b = 0
                        elseif input.KeyCode == Enum.KeyCode.A then
                            ctrl.l = 0
                        elseif input.KeyCode == Enum.KeyCode.D then
                            ctrl.r = 0
                        end
                    end)
                    
                    flightConnection = game:GetService("RunService").RenderStepped:Connect(function()
                        if not nowe or not hum or hum.Health <= 0 then
                            if bg then bg:Destroy() end
                            if bv then bv:Destroy() end
                            if connection then connection:Disconnect() end
                            if connection2 then connection2:Disconnect() end
                            if flightConnection then flightConnection:Disconnect() end
                            return
                        end
                        
                        if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                            speed = speed + 0.5 + (speed / maxspeed)
                            if speed > maxspeed then
                                speed = maxspeed
                            end
                        elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                            speed = speed - 1
                            if speed < 0 then
                                speed = 0
                            end
                        end
                        
                        if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                            bv.Velocity = ((game.Workspace.CurrentCamera.CFrame.LookVector * (ctrl.f + ctrl.b)) + 
                                         ((game.Workspace.CurrentCamera.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).Position) - 
                                          game.Workspace.CurrentCamera.CFrame.Position)) * speed
                            lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                        elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                            bv.Velocity = ((game.Workspace.CurrentCamera.CFrame.LookVector * (lastctrl.f + lastctrl.b)) + 
                                         ((game.Workspace.CurrentCamera.CFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).Position) - 
                                          game.Workspace.CurrentCamera.CFrame.Position)) * speed
                        else
                            bv.Velocity = Vector3.new(0, 0, 0)
                        end
                        
                        bg.CFrame = game.Workspace.CurrentCamera.CFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / maxspeed), 0, 0)
                    end)
                end
            end
            
        else
            nowe = false
            tpwalking = false
            
            if flightConnection then
                flightConnection:Disconnect()
                flightConnection = nil
            end
            
            local speaker = game:GetService("Players").LocalPlayer
            if speaker.Character then
                local chr = speaker.Character
                local hum = chr:FindFirstChildWhichIsA("Humanoid")
                if hum then
                    hum.PlatformStand = false
                end
                
                if chr:FindFirstChild("Animate") then
                    chr.Animate.Disabled = false
                end
            end
        end
    end
})

PlayerTab:Toggle({
    Title = "快速跑",
    Description = "飞一般的感觉",
    Default = false,
    Callback = function(enabled)
        if enabled then
            runConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character
                if character and character:FindFirstChild("Humanoid") then
                    local humanoid = character.Humanoid
                    if humanoid.MoveDirection.Magnitude > 0 then
                        character:TranslateBy(humanoid.MoveDirection * runSpeed)
                    end
                end
            end)
        elseif not enabled and runConnection then
            runConnection:Disconnect()
            runConnection = nil
        end
    end
})

PlayerTab:Input({
    Title = "飞行速度",
    Description = "设置飞行速度",
    Default = "50",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 1 and num <= 500 then
            flySpeed = num
            print("飞行速度已设置为: " .. num)
        else
            warn("输入有效速度值pls")
        end
    end
})

PlayerTab:Input({
    Title = "跑步速度",
    Description = "设置跑步速度",
    Default = "2",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 1 and num <= 10 then
            runSpeed = num
            print("跑步速度已设置为: " .. num)
        else
            warn("输入有效数字pls")
        end
    end
})