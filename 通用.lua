local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local cloneref = cloneref or function(instance) return instance end

local WindUI
do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    if ok then
        WindUI = result
    else
        if RunService:IsStudio() then
            WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/gycgchgyfytdttr/shenqin/refs/heads/main/ui.lua"))()
        end
    end
end

local ESPEnabled = false
local ESP_ScreenGui = nil
local ESPFolder = nil
local ESPNameColor = Color3.fromRGB(0, 255, 127)
local ESPBodyColor = Color3.fromRGB(0, 255, 127)
local ESPNameSize = 14
local ESPRainbowEnabled = false
local ESPRainbowSpeed = 5
local CurrentESPHue = 0
local ESPTeamCheck = false

local BackstabCheckEnabled = false
local BackstabCooldown = 0
local BACKSTAB_COOLDOWN_TIME = 3
local DeathCheckEnabled = false

local InfiniteJumpEnabled = false
local JumpConnection = nil
local SpeedEnabled = false
local SpeedValue = 1
local SpeedConnection = nil
local GravityLoop = nil
local originalGravity = workspace.Gravity

local NightVisionEnabled = false
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient

local RainbowUIEnabled = false
local RainbowUIScreenGui = nil
local StatusIndicator = nil
local animationConnection = nil

local AimSettings = {
    Enabled = false,
    FOV = 100,
    Smoothness = 10,
    CrosshairDistance = 5,
    FOVColor = Color3.fromRGB(0, 255, 0),
    FriendCheck = true,
    WallCheck = true,
    TargetPlayer = nil,
    TargetAll = true,
    FOVRainbowEnabled = true,
    FOVRainbowSpeed = 8,
    FOVEnabled = true
}

local DrawingObjects = {}
local AimConnection = nil
local FOVCircle = nil
local TargetPlayers = {}
local CurrentFOVHue = 0
local CurrentTarget = nil

local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Green = Color3.fromHex("#10C550")
local Grey = Color3.fromHex("#83889E")
local Blue = Color3.fromHex("#257AF7")
local Red = Color3.fromHex("#EF4F1D")

local AimBlacklist = {}
local AimTeamCheck = false
local AimTargetPart = "头"
local ESPMaxDistance = 1000

local blacklistInput

local function GetRainbowColor(hue)
    hue = hue % 1
    local r, g, b
    local i = math.floor(hue * 6)
    local f = hue * 6 - i
    local p = 1
    local q = 1 - f
    local t = f
    if i % 6 == 0 then r, g, b = 1, t, p
    elseif i % 6 == 1 then r, g, b = q, 1, p
    elseif i % 6 == 2 then r, g, b = p, 1, t
    elseif i % 6 == 3 then r, g, b = p, q, 1
    elseif i % 6 == 4 then r, g, b = t, p, 1
    else r, g, b = 1, p, q end
    return Color3.new(r, g, b)
end

local function InitESP()
    ESP_ScreenGui = Instance.new("ScreenGui")
    ESP_ScreenGui.Name = "PlayerESP_System"
    ESP_ScreenGui.ResetOnSpawn = false
    ESP_ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ESP_ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "PlayerESPFolder"
    ESPFolder.Parent = ESP_ScreenGui
end

local function UpdateESPColors()
    if not ESPEnabled or not ESPFolder then return end
    pcall(function()
        for _, child in ipairs(ESPFolder:GetChildren()) do
            if child:IsA("BillboardGui") then
                local nameLabel = child:FindFirstChild("NameLabel")
                if nameLabel then
                    nameLabel.TextColor3 = ESPRainbowEnabled and GetRainbowColor(CurrentESPHue) or ESPNameColor
                    nameLabel.TextSize = ESPNameSize
                end
            elseif child:IsA("Highlight") then
                child.FillColor = ESPRainbowEnabled and GetRainbowColor(CurrentESPHue) or ESPBodyColor
                child.OutlineColor = ESPRainbowEnabled and GetRainbowColor(CurrentESPHue) or ESPBodyColor
            end
        end
    end)
end

local function UpdateESPNameSize()
    if not ESPEnabled or not ESPFolder then return end
    pcall(function()
        for _, child in ipairs(ESPFolder:GetChildren()) do
            if child:IsA("BillboardGui") then
                local nameLabel = child:FindFirstChild("NameLabel")
                if nameLabel then
                    nameLabel.TextSize = ESPNameSize
                end
            end
        end
    end)
end

local function CreatePlayerESP(player)
    if player == LocalPlayer or not ESPEnabled then return end
    pcall(function()
        local character = player.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        local existingESP = ESPFolder:FindFirstChild(player.Name)
        if existingESP then existingESP:Destroy() end
        local ESPGui = Instance.new("BillboardGui")
        ESPGui.Name = player.Name
        ESPGui.Adornee = humanoidRootPart
        ESPGui.Size = UDim2.new(0, 100, 0, 40)
        ESPGui.StudsOffset = Vector3.new(0, 3, 0)
        ESPGui.AlwaysOnTop = true
        ESPGui.MaxDistance = 10000
        ESPGui.Enabled = true
        ESPGui.Parent = ESPFolder
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextSize = ESPNameSize
        NameLabel.TextColor3 = ESPRainbowEnabled and GetRainbowColor(CurrentESPHue) or ESPNameColor
        NameLabel.TextStrokeTransparency = 0.5
        NameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        NameLabel.Text = player.Name
        NameLabel.Parent = ESPGui
        local DistanceLabel = Instance.new("TextLabel")
        DistanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
        DistanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
        DistanceLabel.BackgroundTransparency = 1
        DistanceLabel.Font = Enum.Font.Gotham
        DistanceLabel.TextSize = 12
        DistanceLabel.TextColor3 = Color3.fromRGB(240, 255, 245)
        DistanceLabel.TextStrokeTransparency = 0.5
        DistanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        DistanceLabel.Name = "DistanceLabel"
        DistanceLabel.Parent = ESPGui
        local Highlight = Instance.new("Highlight")
        Highlight.Name = player.Name .. "_Highlight"
        Highlight.Adornee = character
        Highlight.FillColor = ESPRainbowEnabled and GetRainbowColor(CurrentESPHue) or ESPBodyColor
        Highlight.FillTransparency = 0.7
        Highlight.OutlineColor = ESPRainbowEnabled and GetRainbowColor(CurrentESPHue) or ESPBodyColor
        Highlight.OutlineTransparency = 0
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.Enabled = true
        Highlight.Parent = ESPFolder
    end)
end

local function CheckBackstabThreat()
    if not BackstabCheckEnabled then return end
    if BackstabCooldown > 0 then return end
    pcall(function()
        local myCharacter = LocalPlayer.Character
        local myHRP = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local myPosition = myHRP.Position
        local myCFrame = myHRP.CFrame
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if hrp and humanoid and humanoid.Health > 0 then
                    local enemyPosition = hrp.Position
                    local distance = (myPosition - enemyPosition).Magnitude
                    if distance < 30 then
                        local toEnemy = (enemyPosition - myPosition).Unit
                        local myForward = myCFrame.LookVector
                        local dotProduct = toEnemy:Dot(myForward)
                        if dotProduct < 0.5 then
                            WindUI:Notify({
                                Title = "有基吧人偷袭🥵",
                                Content = "小心有人要偷袭你：" .. player.Name,
                                Icon = "alert-triangle",
                                Color = Color3.fromRGB(255, 100, 100),
                                Duration = 5
                            })
                            BackstabCooldown = BACKSTAB_COOLDOWN_TIME
                            break
                        end
                    end
                end
            end
        end
    end)
end

local function SetupDeathDetection()
    LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        pcall(function()
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.Died:Connect(function()
                if DeathCheckEnabled then
                    WindUI:Notify({
                        Title = "死亡提醒",
                        Content = "咋死了 messy帮你诅咒击杀者",
                        Icon = "skull",
                        Color = Color3.fromRGB(255, 0, 0),
                        Duration = 8
                    })
                end
            end)
        end)
    end)
    if LocalPlayer.Character then
        pcall(function()
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Died:Connect(function()
                    if DeathCheckEnabled then
                        WindUI:Notify({
                            Title = "死亡提醒",
                            Content = "咋死了 messy帮你诅咒击杀者",
                            Icon = "skull",
                            Color = Color3.fromRGB(255, 0, 0),
                            Duration = 8
                        })
                    end
                end)
            end
        end)
    end
end

local function UpdateESP()
    if not ESPEnabled then return end
    pcall(function()
        local myCharacter = LocalPlayer.Character
        local myHRP = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character
                if character then
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local espGui = ESPFolder:FindFirstChild(player.Name)
                        if not espGui then
                            CreatePlayerESP(player)
                            espGui = ESPFolder:FindFirstChild(player.Name)
                        end
                        if espGui then
                            local distance = (myHRP.Position - hrp.Position).Magnitude
                            local distanceLabel = espGui:FindFirstChild("DistanceLabel")
                            if distanceLabel then
                                distanceLabel.Text = string.format("%.0f studs", distance)
                            end
                            if distance > ESPMaxDistance then
                                espGui.Enabled = false
                                local highlight = ESPFolder:FindFirstChild(player.Name .. "_Highlight")
                                if highlight then highlight.Enabled = false end
                            else
                                local teamHide = false
                                if ESPTeamCheck and LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
                                    teamHide = true
                                end
                                if teamHide then
                                    espGui.Enabled = false
                                    local highlight = ESPFolder:FindFirstChild(player.Name .. "_Highlight")
                                    if highlight then highlight.Enabled = false end
                                else
                                    espGui.Enabled = true
                                    local highlight = ESPFolder:FindFirstChild(player.Name .. "_Highlight")
                                    if highlight then highlight.Enabled = true end
                                end
                            end
                        end
                    else
                        local espGui = ESPFolder:FindFirstChild(player.Name)
                        if espGui then espGui:Destroy() end
                        local highlight = ESPFolder:FindFirstChild(player.Name .. "_Highlight")
                        if highlight then highlight:Destroy() end
                    end
                else
                    local esp = ESPFolder:FindFirstChild(player.Name)
                    if esp then esp:Destroy() end
                    local highlight = ESPFolder:FindFirstChild(player.Name .. "_Highlight")
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end)
end

local function ToggleESP(state)
    ESPEnabled = state
    if state then
        pcall(function()
            if not ESP_ScreenGui then InitESP() end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    CreatePlayerESP(player)
                end
            end
            WindUI:Notify({
                Title = "透视",
                Content = "玩家透视已开启",
                Icon = "eye",
            })
        end)
    else
        pcall(function()
            if ESPFolder then
                for _, esp in ipairs(ESPFolder:GetChildren()) do
                    esp:Destroy()
                end
            end
            WindUI:Notify({
                Title = "透视",
                Content = "玩家透视已关闭",
                Icon = "eye",
            })
        end)
    end
end

InitESP()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if ESPEnabled then
        pcall(function()
            if ESPFolder then
                for _, esp in ipairs(ESPFolder:GetChildren()) do
                    esp:Destroy()
                end
            end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    CreatePlayerESP(player)
                end
            end
        end)
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPEnabled then
            task.wait(1)
            pcall(function()
                CreatePlayerESP(player)
            end)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    pcall(function()
        if ESPFolder then
            local espGui = ESPFolder:FindFirstChild(player.Name)
            if espGui then espGui:Destroy() end
            local highlight = ESPFolder:FindFirstChild(player.Name .. "_Highlight")
            if highlight then highlight:Destroy() end
        end
        if CurrentTarget == player then
            CurrentTarget = nil
        end
        for i, name in ipairs(AimBlacklist) do
            if name == player.Name then
                table.remove(AimBlacklist, i)
                break
            end
        end
        if blacklistInput and blacklistInput.SetValue then
            blacklistInput:SetValue(table.concat(AimBlacklist, ", "))
        end
    end)
end)

local function heartBeatLoop(deltaTime)
    pcall(function()
        UpdateESP()
        if ESPRainbowEnabled then
            CurrentESPHue = CurrentESPHue + deltaTime * ESPRainbowSpeed / 10
            UpdateESPColors()
        end
        if BackstabCooldown > 0 then
            BackstabCooldown = BackstabCooldown - deltaTime
        end
        CheckBackstabThreat()
    end)
end

RunService.Heartbeat:Connect(heartBeatLoop)

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

    local PlayerTab = Window:Tab({  
        Title = "本地玩家",  
        Icon = "crown",  
        Locked = false,
    })

do
    PlayerTab:Section({
        Title = "主要功能",
        TextSize = 16,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    PlayerTab:Toggle({
        Title = "无限跳跃",
        Desc = "启用后可以无限跳跃",
        Callback = function(enabled)
            InfiniteJumpEnabled = enabled
            if enabled then
                if JumpConnection then
                    JumpConnection:Disconnect()
                end
                JumpConnection = UserInputService.JumpRequest:Connect(function()
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            char.Humanoid:ChangeState("Jumping")
                        end
                    end)
                end)
                WindUI:Notify({
                    Title = "无限跳跃",
                    Content = "已开启无限跳跃",
                    Icon = "jump-rope",
                })
            else
                if JumpConnection then
                    JumpConnection:Disconnect()
                    JumpConnection = nil
                end
                WindUI:Notify({
                    Title = "无限跳跃",
                    Content = "已关闭无限跳跃",
                    Icon = "jump-rope",
                })
            end
        end
    })
    PlayerTab:Space()
    PlayerTab:Input({
        Title = "设置重力",
        Desc = "输入重力值 (默认:196" .. tostring(originalGravity) .. ")",
        Placeholder = "输入重力值",
        Callback = function(value)
            local numValue = tonumber(value)
            if numValue then
                if GravityLoop then
                    GravityLoop:Disconnect()
                    GravityLoop = nil
                end
                workspace.Gravity = numValue
                WindUI:Notify({
                    Title = "重力设置",
                    Content = "重力已设置为: " .. tostring(numValue),
                    Icon = "weight",
                })
            else
                WindUI:Notify({
                    Title = "错误来了",
                    Content = "请输入数字",
                    Icon = "alert-circle",
                    Color = Red,
                })
            end
        end
    })
    PlayerTab:Space()
    PlayerTab:Input({
        Title = "设置快速跑步速度",
        Desc = "输入速度 (默认: 1)",
        Placeholder = "输入速度",
        Callback = function(value)
            local numValue = tonumber(value)
            if numValue then
                SpeedValue = numValue
                WindUI:Notify({
                    Title = "速度设置",
                    Content = "速度已设置为: " .. tostring(numValue) .. "速度",
                    Icon = "zap",
                })
            else
                WindUI:Notify({
                    Title = "依旧错误来了",
                    Content = "请输入有效数字",
                    Icon = "alert-circle",
                    Color = Red,
                })
            end
        end
    })
    PlayerTab:Toggle({
        Title = "开启快速跑步",
        Desc = "启用快速跑步功能",
        Callback = function(enabled)
            SpeedEnabled = enabled
            if enabled then
                if SpeedConnection then
                    SpeedConnection:Disconnect()
                end
                SpeedConnection = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local player = LocalPlayer
                        local char = player.Character
                        if char and char:FindFirstChild("Humanoid") then
                            local humanoid = char.Humanoid
                            if humanoid.MoveDirection.Magnitude > 0 then
                                char:TranslateBy(humanoid.MoveDirection * SpeedValue / 2)
                            end
                        end
                    end)
                end)
            else
                if SpeedConnection then
                    SpeedConnection:Disconnect()
                    SpeedConnection = nil
                end
            end
        end
    })
end

    local AimTab = Window:Tab({  
        Title = "自瞄设置",  
        Icon = "crown",  
        Locked = false,
    })

local function InitializeAimDrawings()
    pcall(function()
        if not FOVCircle then
            FOVCircle = Drawing.new("Circle")
            FOVCircle.Visible = AimSettings.Enabled and AimSettings.FOVEnabled
            FOVCircle.Thickness = 2
            FOVCircle.Filled = false
            FOVCircle.Radius = AimSettings.FOV
            FOVCircle.Position = workspace.CurrentCamera.ViewportSize / 2
            table.insert(DrawingObjects, FOVCircle)
        end
    end)
end

local function UpdateFOVCircle()
    pcall(function()
        if FOVCircle then
            FOVCircle.Visible = AimSettings.Enabled and AimSettings.FOVEnabled
            FOVCircle.Radius = AimSettings.FOV
            if AimSettings.FOVRainbowEnabled then
                FOVCircle.Color = GetRainbowColor(CurrentFOVHue)
            else
                FOVCircle.Color = AimSettings.FOVColor
            end
            FOVCircle.Position = workspace.CurrentCamera.ViewportSize / 2
        end
    end)
end

local function CleanupDrawings()
    pcall(function()
        for _, drawing in ipairs(DrawingObjects) do
            if drawing then
                drawing:Remove()
            end
        end
        DrawingObjects = {}
        FOVCircle = nil
    end)
end

local function IsFriend(player)
    if not AimSettings.FriendCheck then
        return false
    end
    local success, result = pcall(function()
        if LocalPlayer:IsFriendsWith(player.UserId) then
            return true
        end
        return false
    end)
    return success and result
end

local function WallCheck(targetPosition, targetCharacter)
    if not AimSettings.WallCheck then
        return true
    end
    local success, result = pcall(function()
        local camera = workspace.CurrentCamera
        local origin = camera.CFrame.Position
        local direction = (targetPosition - origin).Unit
        local distance = (targetPosition - origin).Magnitude
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.IgnoreWater = true
        raycastParams.CollisionGroup = "Default"
        local raycastResult = workspace:Raycast(origin, direction * distance, raycastParams)
        return raycastResult == nil
    end)
    return success and result
end

local function GetTargetPosition(character, partName)
    if not character then return nil end
    local part
    if partName == "头" then
        part = character:FindFirstChild("Head")
    elseif partName == "上身" then
        part = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
    elseif partName == "左腿" then
        part = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("LeftUpperLeg")
    elseif partName == "右腿" then
        part = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("RightUpperLeg")
    elseif partName == "裆部" then
        part = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("LowerTorso")
    elseif partName == "胸部" then
        part = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    else
        part = character:FindFirstChild("Head")
    end
    return part and part.Position
end

local function GetClosestPlayer()
    local camera = workspace.CurrentCamera
    local mousePos = camera.ViewportSize / 2
    local nearestPlayer = nil
    local shortestDistance = AimSettings.FOV

    if AimSettings.TargetPlayer and not AimSettings.TargetAll then
        local target = Players:FindFirstChild(AimSettings.TargetPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local inBlacklist = false
            for _, blackName in ipairs(AimBlacklist) do
                if target.Name == blackName then
                    inBlacklist = true
                    break
                end
            end
            if not inBlacklist then
                if AimTeamCheck then
                    local myTeam = LocalPlayer.Team
                    if myTeam and target.Team == myTeam then
                        CurrentTarget = nil
                        return nil
                    end
                end
                local humanoid = target.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetPos = target.Character.HumanoidRootPart.Position
                    local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distance <= AimSettings.FOV and WallCheck(targetPos, target.Character) then
                            if not AimSettings.FriendCheck or not IsFriend(target) then
                                CurrentTarget = target
                                return target
                            end
                        end
                    end
                end
            end
        end
        CurrentTarget = nil
        return nil
    end

    if CurrentTarget and CurrentTarget ~= LocalPlayer and CurrentTarget.Character then
        local hrp = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = CurrentTarget.Character:FindFirstChild("Humanoid")
        if hrp and humanoid and humanoid.Health > 0 then
            local inBlacklist = false
            for _, blackName in ipairs(AimBlacklist) do
                if CurrentTarget.Name == blackName then
                    inBlacklist = true
                    break
                end
            end
            if not inBlacklist then
                if AimTeamCheck then
                    local myTeam = LocalPlayer.Team
                    if myTeam and CurrentTarget.Team == myTeam then
                        CurrentTarget = nil
                        return nil
                    end
                end
                local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance <= AimSettings.FOV and WallCheck(hrp.Position, CurrentTarget.Character) then
                        if not AimSettings.FriendCheck or not IsFriend(CurrentTarget) then
                            return CurrentTarget
                        end
                    end
                end
            end
        end
    end

    CurrentTarget = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local skip = false
            if AimSettings.FriendCheck and IsFriend(player) then
                skip = true
            end
            if not skip then
                for _, blackName in ipairs(AimBlacklist) do
                    if player.Name == blackName then
                        skip = true
                        break
                    end
                end
            end
            if not skip then
                if AimTeamCheck then
                    local myTeam = LocalPlayer.Team
                    if myTeam and player.Team == myTeam then
                        skip = true
                    end
                end
            end
            if not skip then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoidRootPart and humanoid and humanoid.Health > 0 then
                    if WallCheck(humanoidRootPart.Position, player.Character) then
                        local screenPos, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
                        if onScreen then
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                nearestPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end
    if nearestPlayer then
        CurrentTarget = nearestPlayer
    end
    return nearestPlayer
end

local function AimBot()
    if not AimSettings.Enabled then
        return
    end
    pcall(function()
        local camera = workspace.CurrentCamera
        local target = GetClosestPlayer()
        if target and target.Character then
            local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
            local head = target.Character:FindFirstChild("Head")
            local targetPosition = GetTargetPosition(target.Character, AimTargetPart) or (head and head.Position) or (humanoidRootPart and humanoidRootPart.Position)
            if not targetPosition then return end
            if humanoidRootPart then
                local targetVelocity = humanoidRootPart.Velocity
                if AimSettings.CrosshairDistance > 0 then
                    local distance = (targetPosition - camera.CFrame.Position).Magnitude
                    local timeToTarget = distance / 1000
                    targetPosition = targetPosition + (targetVelocity * timeToTarget * AimSettings.CrosshairDistance)
                end
            end
            local currentCFrame = camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetPosition)
            local smoothedCFrame = currentCFrame:Lerp(targetCFrame, 1 / AimSettings.Smoothness)
            camera.CFrame = smoothedCFrame
        end
    end)
end

local function CreateRainbowUI()
    if RainbowUIScreenGui then
        RainbowUIScreenGui:Destroy()
        RainbowUIScreenGui = nil
    end
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    RainbowUIScreenGui = Instance.new("ScreenGui")
    RainbowUIScreenGui.Name = "RainbowCircleUI"
    RainbowUIScreenGui.ResetOnSpawn = false
    RainbowUIScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    RainbowUIScreenGui.DisplayOrder = 99999
    RainbowUIScreenGui.IgnoreGuiInset = true
    RainbowUIScreenGui.Enabled = true
    RainbowUIScreenGui.Parent = playerGui
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "RainbowCircle"
    mainFrame.Size = UDim2.new(0, 80, 0, 80)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundTransparency = 1
    mainFrame.ZIndex = 100000
    mainFrame.Parent = RainbowUIScreenGui
    mainFrame.Active = true
    mainFrame.Selectable = true
    mainFrame.Draggable = false
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(1, 0)
    uiCorner.Parent = mainFrame
    local rainbowBackground = Instance.new("Frame")
    rainbowBackground.Name = "RainbowBackground"
    rainbowBackground.Size = UDim2.new(1, 0, 1, 0)
    rainbowBackground.Position = UDim2.new(0, 0, 0, 0)
    rainbowBackground.BackgroundTransparency = 0
    rainbowBackground.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    rainbowBackground.ZIndex = 100001
    rainbowBackground.Parent = mainFrame
    rainbowBackground.Active = true
    rainbowBackground.Selectable = true
    local rainbowCorner = Instance.new("UICorner")
    rainbowCorner.CornerRadius = UDim.new(1, 0)
    rainbowCorner.Parent = rainbowBackground
    local rainbowStroke = Instance.new("UIStroke")
    rainbowStroke.Name = "RainbowStroke"
    rainbowStroke.Color = Color3.fromRGB(255, 255, 255)
    rainbowStroke.Thickness = 3
    rainbowStroke.Transparency = 0
    rainbowStroke.Parent = mainFrame
    local innerStroke = Instance.new("UIStroke")
    innerStroke.Name = "InnerStroke"
    innerStroke.Color = Color3.fromRGB(0, 0, 0)
    innerStroke.Thickness = 1
    innerStroke.Transparency = 0.3
    innerStroke.Parent = rainbowBackground
    StatusIndicator = Instance.new("Frame")
    StatusIndicator.Name = "StatusIndicator"
    StatusIndicator.Size = UDim2.new(0, 15, 0, 15)
    StatusIndicator.Position = UDim2.new(1, -18, 1, -18)
    StatusIndicator.BackgroundColor3 = AimSettings.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    StatusIndicator.BackgroundTransparency = 0
    StatusIndicator.ZIndex = 100002
    StatusIndicator.Parent = mainFrame
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = StatusIndicator
    local indicatorStroke = Instance.new("UIStroke")
    indicatorStroke.Color = Color3.fromRGB(255, 255, 255)
    indicatorStroke.Thickness = 2
    indicatorStroke.Parent = StatusIndicator
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, 0, 0, 25)
    statusText.Position = UDim2.new(0, 0, 1, 5)
    statusText.BackgroundTransparency = 1
    statusText.Text = AimSettings.Enabled and "自瞄开" or "自瞄关"
    statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusText.TextSize = 14
    statusText.Font = Enum.Font.GothamBold
    statusText.TextStrokeTransparency = 0.3
    statusText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    statusText.TextStrokeTransparency = 0.3
    statusText.ZIndex = 100002
    statusText.Parent = mainFrame
    local clickArea = Instance.new("TextButton")
    clickArea.Name = "ClickArea"
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.Position = UDim2.new(0, 0, 0, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 100003
    clickArea.Parent = mainFrame
    local rainbowColors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 95, 0),
        Color3.fromRGB(255, 165, 0),
        Color3.fromRGB(255, 215, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(144, 238, 144),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 200, 200),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(75, 0, 130),
        Color3.fromRGB(138, 43, 226),
        Color3.fromRGB(148, 0, 211),
        Color3.fromRGB(199, 21, 133),
        Color3.fromRGB(255, 20, 147)
    }
    local rainbowColors2 = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 127, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(75, 0, 130),
        Color3.fromRGB(148, 0, 211)
    }
    local timeOffset = 0
    local hoverAmplitude = 4
    local hoverSpeed = 4
    local pulseSpeed = 2
    local pulseAmount = 0.1
    local colorIndex = 1
    local colorIndex2 = 3
    local transitionTime = 0.8
    local transitionTime2 = 0.5
    local elapsedTime = 0
    local elapsedTime2 = 0
    local pulseScale = 1
    local isPulsingOut = true
    if animationConnection then
        animationConnection:Disconnect()
    end
    animationConnection = RunService.RenderStepped:Connect(function(deltaTime)
        pcall(function()
            if not RainbowUIEnabled or not RainbowUIScreenGui or not RainbowUIScreenGui.Parent then
                animationConnection:Disconnect()
                animationConnection = nil
                return
            end
            elapsedTime = elapsedTime + deltaTime
            if elapsedTime >= transitionTime then
                elapsedTime = 0
                colorIndex = colorIndex + 1
                if colorIndex > #rainbowColors then
                    colorIndex = 1
                end
            end
            local nextColorIndex = colorIndex + 1
            if nextColorIndex > #rainbowColors then
                nextColorIndex = 1
            end
            local alpha = elapsedTime / transitionTime
            local currentBgColor = rainbowColors[colorIndex]:Lerp(rainbowColors[nextColorIndex], alpha)
            rainbowBackground.BackgroundColor3 = currentBgColor
            elapsedTime2 = elapsedTime2 + deltaTime
            if elapsedTime2 >= transitionTime2 then
                elapsedTime2 = 0
                colorIndex2 = colorIndex2 + 1
                if colorIndex2 > #rainbowColors2 then
                    colorIndex2 = 1
                end
            end
            local nextColorIndex2 = colorIndex2 + 1
            if nextColorIndex2 > #rainbowColors2 then
                nextColorIndex2 = 1
            end
            local alpha2 = elapsedTime2 / transitionTime2
            local currentStrokeColor = rainbowColors2[colorIndex2]:Lerp(rainbowColors2[nextColorIndex2], alpha2)
            rainbowStroke.Color = currentStrokeColor
            if isPulsingOut then
                pulseScale = pulseScale + deltaTime * pulseSpeed * pulseAmount
                if pulseScale >= 1 + pulseAmount then
                    isPulsingOut = false
                end
            else
                pulseScale = pulseScale - deltaTime * pulseSpeed * pulseAmount
                if pulseScale <= 1 - pulseAmount then
                    isPulsingOut = true
                end
            end
            rainbowBackground.Size = UDim2.new(pulseScale, 0, pulseScale, 0)
            rainbowBackground.Position = UDim2.new((1 - pulseScale) / 2, 0, (1 - pulseScale) / 2, 0)
            timeOffset = timeOffset + deltaTime * hoverSpeed
            local hoverOffset = math.sin(timeOffset) * hoverAmplitude
            mainFrame.Position = UDim2.new(0, 10, 0, 10 + hoverOffset)
            innerStroke.Transparency = 0.2 + 0.3 * math.sin(timeOffset * 2)
            if StatusIndicator then
                StatusIndicator.BackgroundColor3 = AimSettings.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end
            if statusText then
                statusText.Text = AimSettings.Enabled and "自瞄开" or "自瞄关"
                statusText.TextColor3 = AimSettings.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
            end
        end)
    end)
    local function handleClick()
        AimSettings.Enabled = not AimSettings.Enabled
        if AimSettings.Enabled then
            InitializeAimDrawings()
            UpdateFOVCircle()
            if AimConnection then
                AimConnection:Disconnect()
            end
            AimConnection = RunService.RenderStepped:Connect(function(deltaTime)
                pcall(function()
                    if AimSettings.FOVRainbowEnabled then
                        CurrentFOVHue = CurrentFOVHue + deltaTime * AimSettings.FOVRainbowSpeed / 10
                    end
                    UpdateFOVCircle()
                    AimBot()
                end)
            end)
        else
            if AimConnection then
                AimConnection:Disconnect()
                AimConnection = nil
            end
            CleanupDrawings()
            CurrentTarget = nil
        end
        if StatusIndicator then
            StatusIndicator.BackgroundColor3 = AimSettings.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end
        if statusText then
            statusText.Text = AimSettings.Enabled and "自瞄开" or "自瞄关"
            statusText.TextColor3 = AimSettings.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        end
        local originalSize = rainbowBackground.Size
        local originalPosition = rainbowBackground.Position
        local tweenInfo1 = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tweenInfo2 = TweenInfo.new(0.15, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
        local clickScaleUp = TweenService:Create(rainbowBackground, tweenInfo1, {
            Size = originalSize * 0.7,
            Position = UDim2.new(0.15, 0, 0.15, 0)
        })
        local clickScaleDown = TweenService:Create(rainbowBackground, tweenInfo2, {
            Size = originalSize,
            Position = originalPosition
        })
        local originalStrokeColor = rainbowStroke.Color
        local flashTween = TweenService:Create(rainbowStroke, tweenInfo1, {
            Color = Color3.fromRGB(255, 255, 255)
        })
        local revertStroke = TweenService:Create(rainbowStroke, tweenInfo2, {
            Color = originalStrokeColor
        })
        clickScaleUp:Play()
        flashTween:Play()
        clickScaleUp.Completed:Connect(function()
            clickScaleDown:Play()
            revertStroke:Play()
        end)
    end
    clickArea.MouseButton1Click:Connect(handleClick)
    mainFrame.MouseButton1Click:Connect(handleClick)
    mainFrame.MouseEnter:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween1 = TweenService:Create(rainbowStroke, tweenInfo, {
            Thickness = 6
        })
        pulseAmount = 0.15
        tween1:Play()
    end)
    mainFrame.MouseLeave:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween1 = TweenService:Create(rainbowStroke, tweenInfo, {
            Thickness = 3
        })
        pulseAmount = 0.1
        tween1:Play()
    end)
    rainbowBackground.BackgroundTransparency = 1
    rainbowStroke.Transparency = 1
    local fadeIn = TweenService:Create(rainbowBackground, TweenInfo.new(0.5), {
        BackgroundTransparency = 0
    })
    local strokeFadeIn = TweenService:Create(rainbowStroke, TweenInfo.new(0.5), {
        Transparency = 0
    })
    task.wait(0.2)
    fadeIn:Play()
    strokeFadeIn:Play()
    return true
end

local function ToggleRainbowUI(state)
    RainbowUIEnabled = state
    if state then
        local success = CreateRainbowUI()
        if success then
            WindUI:Notify({
                Title = "自瞄快捷UI",
                Content = "快捷UI 让你秒人更加高效",
                Icon = "sparkles",
            })
        end
    else
        if RainbowUIScreenGui then
            RainbowUIScreenGui:Destroy()
            RainbowUIScreenGui = nil
        end
        WindUI:Notify({
            Title = "自瞄快捷UI",
            Content = "快捷UI已隐藏",
            Icon = "sparkles",
        })
    end
end

do
    AimTab:Section({
        Title = "自瞄设置",
        TextSize = 16,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    AimTab:Toggle({
        Title = "启用自瞄",
        Desc = "开启/关闭自瞄功能",
        Callback = function(enabled)
            AimSettings.Enabled = enabled
            if enabled then
                InitializeAimDrawings()
                UpdateFOVCircle()
                if AimConnection then
                    AimConnection:Disconnect()
                end
                AimConnection = RunService.RenderStepped:Connect(function(deltaTime)
                    pcall(function()
                        if AimSettings.FOVRainbowEnabled then
                            CurrentFOVHue = CurrentFOVHue + deltaTime * AimSettings.FOVRainbowSpeed / 10
                        end
                        UpdateFOVCircle()
                        AimBot()
                    end)
                end)
                WindUI:Notify({
                    Title = "自瞄",
                    Content = "自瞄功能已开启",
                    Icon = "crosshair",
                })
            else
                if AimConnection then
                    AimConnection:Disconnect()
                    AimConnection = nil
                end
                CleanupDrawings()
                CurrentTarget = nil
                WindUI:Notify({
                    Title = "自瞄",
                    Content = "自瞄功能已关闭",
                    Icon = "crosshair",
                })
            end
            if StatusIndicator then
                StatusIndicator.BackgroundColor3 = AimSettings.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end
        end
    })
    AimTab:Space()
    AimTab:Toggle({
        Title = "自瞄快捷UI",
        Desc = "快捷UI 让你秒人更加高效",
        Callback = function(enabled)
            ToggleRainbowUI(enabled)
        end
    })
    AimTab:Toggle({
        Title = "FOV开关",
        Desc = "显示自瞄范围圆圈",
        Value = AimSettings.FOVEnabled,
        Callback = function(enabled)
            AimSettings.FOVEnabled = enabled
            UpdateFOVCircle()
        end
    })
    AimTab:Toggle({
        Title = "FOV彩虹效果",
        Desc = "开启FOV圆圈彩虹效果",
        Value = AimSettings.FOVRainbowEnabled,
        Callback = function(enabled)
            AimSettings.FOVRainbowEnabled = enabled
            UpdateFOVCircle()
        end
    })
    AimTab:Slider({
        Title = "FOV彩虹速度",
        Desc = "调整彩虹流动的速度",
        Value = {
            Min = 1,
            Max = 20,
            Default = AimSettings.FOVRainbowSpeed,
        },
        Callback = function(value)
            AimSettings.FOVRainbowSpeed = value
        end
    })
    AimTab:Space()
    AimTab:Slider({
        Title = "自瞄范围 (FOV)",
        Desc = "设置自瞄FOV大小",
        Value = {
            Min = 50,
            Max = 500,
            Default = AimSettings.FOV,
        },
        Callback = function(value)
            AimSettings.FOV = value
            UpdateFOVCircle()
        end
    })
    AimTab:Space()
    AimTab:Slider({
        Title = "自瞄平滑度",
        Desc = "数值越小越强锁",
        Value = {
            Min = 1,
            Max = 50,
            Default = AimSettings.Smoothness,
        },
        Callback = function(value)
            AimSettings.Smoothness = value
        end
    })
    AimTab:Space()
    AimTab:Slider({
        Title = "预判距离",
        Desc = "设置预判距离(需要强锁直接调到0-3)",
        Value = {
            Min = 0,
            Max = 20,
            Default = AimSettings.CrosshairDistance,
        },
        Callback = function(value)
            AimSettings.CrosshairDistance = value
        end
    })
    AimTab:Space()
    AimTab:Colorpicker({
        Title = "FOV圆圈颜色",
        Desc = "彩虹模式关闭时生效",
        Default = AimSettings.FOVColor,
        Callback = function(color)
            AimSettings.FOVColor = color
            UpdateFOVCircle()
        end
    })
    AimTab:Space()
    AimTab:Toggle({
        Title = "好友检测",
        Desc = "不秒好友",
        Value = AimSettings.FriendCheck,
        Callback = function(enabled)
            AimSettings.FriendCheck = enabled
        end
    })
    AimTab:Space()
    AimTab:Toggle({
        Title = "墙壁检测",
        Desc = "开启墙壁检测 避免自瞄乱飞",
        Value = AimSettings.WallCheck,
        Callback = function(enabled)
            AimSettings.WallCheck = enabled
        end
    })
    AimTab:Space()
    AimTab:Toggle({
        Title = "队伍检测",
        Desc = "不攻击同队队友",
        Value = AimTeamCheck,
        Callback = function(enabled)
            AimTeamCheck = enabled
        end
    })
    AimTab:Space()
    AimTab:Toggle({
        Title = "目标自瞄模式",
        Desc = "开启后可以选择目标进行制裁",
        Value = false,
        Callback = function(enabled)
            AimSettings.TargetAll = not enabled
            CurrentTarget = nil
        end
    })
    local playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    local targetDropdown = AimTab:Dropdown({
        Title = "选择目标玩家",
        Desc = "选择要自瞄的玩家",
        Values = playerList,
        Value = nil,
        AllowNone = true,
        Callback = function(selected)
            AimSettings.TargetPlayer = selected
            CurrentTarget = nil
        end
    })
    Players.PlayerAdded:Connect(function(player)
        table.insert(playerList, player.Name)
        if targetDropdown and targetDropdown.Refresh then
            targetDropdown:Refresh(playerList)
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        for i, name in ipairs(playerList) do
            if name == player.Name then
                table.remove(playerList, i)
                break
            end
        end
        if targetDropdown and targetDropdown.Refresh then
            targetDropdown:Refresh(playerList)
        end
    end)
    AimTab:Space()
    AimTab:Section({
        Title = "自瞄部位设置",
        TextSize = 16,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    AimTab:Dropdown({
        Title = "自瞄部位",
        Desc = "选择要瞄准的身体部位",
        Values = {"头", "上身", "左腿", "右腿", "鸡巴", "奶子"},
        Value = AimTargetPart,
        Callback = function(selected)
            AimTargetPart = selected
        end
    })
    AimTab:Space()
    AimTab:Section({
        Title = "黑名单管理",
        TextSize = 16,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    blacklistInput = AimTab:Input({
        Title = "自瞄黑名单",
        Desc = "输入不攻击的玩家名字，多个用逗号分隔",
        Placeholder = "例如: Player1,Player2,Player3",
        Callback = function(value)
            local names = {}
            for name in string.gmatch(value, "[^,]+") do
                name = name:match("^%s*(.-)%s*$")
                if name ~= "" then
                    table.insert(names, name)
                end
            end
            AimBlacklist = names
        end
    })
    AimTab:Button({
        Title = "添加当前目标到黑名单",
        Justify = "Center",
        Callback = function()
            if CurrentTarget and CurrentTarget.Name then
                local targetName = CurrentTarget.Name
                for _, name in ipairs(AimBlacklist) do
                    if name == targetName then
                        WindUI:Notify({
                            Title = "黑名单",
                            Content = targetName .. " 已在黑名单中",
                            Icon = "info",
                        })
                        return
                    end
                end
                table.insert(AimBlacklist, targetName)
                local newValue = table.concat(AimBlacklist, ", ")
                if blacklistInput and blacklistInput.SetValue then
                    blacklistInput:SetValue(newValue)
                else
                    WindUI:Notify({
                        Title = "黑名单",
                        Content = "已添加 " .. targetName .. "，请手动更新输入框",
                        Icon = "info",
                    })
                end
            else
                WindUI:Notify({
                    Title = "黑名单",
                    Content = "没有当前目标",
                    Icon = "alert-circle",
                })
            end
        end
    })
    AimTab:Space()
    AimTab:Button({
        Title = "清空白名单",
        Justify = "Center",
        Callback = function()
            AimBlacklist = {}
            if blacklistInput and blacklistInput.SetValue then
                blacklistInput:SetValue("")
            end
            WindUI:Notify({
                Title = "黑名单",
                Content = "黑名单已清空",
                Icon = "check",
            })
        end
    })
    AimTab:Space()
    local statusText = "自瞄状态: 未启用"
    if AimSettings.Enabled then
        statusText = "自瞄状态: 已启用 模式: " .. (AimSettings.TargetAll and "全部玩家" or "目标玩家")
    end
    AimTab:Section({
        Title = statusText,
        TextSize = 14,
        FontWeight = Enum.FontWeight.Medium,
        TextColor = AimSettings.Enabled and Green or Grey,
    })
    local QuickSettings = AimTab:Group({})
    QuickSettings:Button({
        Title = "快速设置: 强锁[子弹有延迟类]",
        Desc = "FOV99 平滑1 预判0.96",
        Justify = "Center",
        Callback = function()
            AimSettings.FOV = 99
            AimSettings.Smoothness = 1
            AimSettings.CrosshairDistance = 0.96
            UpdateFOVCircle()
            WindUI:Notify({
                Title = "快速设置",
                Content = "已使用近距离设置",
                Icon = "settings",
            })
        end
    })
    QuickSettings:Space()
    QuickSettings:Button({
        Title = "快速设置: 强锁[子弹无延迟]",
        Desc = "FOV120, 平滑1 预判0",
        Justify = "Center",
        Callback = function()
            AimSettings.FOV = 120
            AimSettings.Smoothness = 1
            AimSettings.CrosshairDistance = 0
            UpdateFOVCircle()
            WindUI:Notify({
                Title = "快速设置",
                Content = "已使用强锁设置",
                Icon = "settings",
            })
        end
    })
    QuickSettings:Space()
    QuickSettings:Button({
        Title = "快速设置: 平滑类[]",
        Desc = "FOV130 平滑6 预判1",
        Justify = "Center",
        Callback = function()
            AimSettings.FOV = 130
            AimSettings.Smoothness = 6
            AimSettings.CrosshairDistance = 1
            UpdateFOVCircle()
            WindUI:Notify({
                Title = "快速设置",
                Content = "已使用远距离设置",
                Icon = "settings",
            })
        end
    })
end

    local OtherTab = Window:Tab({  
        Title = "绘制功能",  
        Icon = "crown",  
        Locked = false,
    })

do
    OtherTab:Section({
        Title = "ESP",
        TextSize = 16,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    OtherTab:Toggle({
        Title = "玩家透视 (ESP)",
        Desc = "显示玩家描边和距离",
        Callback = function(enabled)
            ToggleESP(enabled)
        end
    })
    OtherTab:Space()
    OtherTab:Colorpicker({
        Title = "ESP玩家名字颜色",
        Desc = "设置玩家名字显示颜色",
        Default = ESPNameColor,
        Callback = function(color)
            ESPNameColor = color
            if ESPEnabled and not ESPRainbowEnabled then
                UpdateESPColors()
            end
        end
    })
    OtherTab:Colorpicker({
        Title = "ESP身体绘制颜色",
        Desc = "设置玩家身体颜色",
        Default = ESPBodyColor,
        Callback = function(color)
            ESPBodyColor = color
            if ESPEnabled and not ESPRainbowEnabled then
                UpdateESPColors()
            end
        end
    })
    OtherTab:Slider({
        Title = "ESP玩家名字大小",
        Desc = "设置玩家名字的文本大小",
        Value = {
            Min = 8,
            Max = 24,
            Default = ESPNameSize,
        },
        Callback = function(value)
            ESPNameSize = value
            if ESPEnabled then
                UpdateESPNameSize()
            end
        end
    })
    OtherTab:Space()
    OtherTab:Toggle({
        Title = "ESP彩虹渐变",
        Desc = "开启透视彩虹效果",
        Callback = function(enabled)
            ESPRainbowEnabled = enabled
            if ESPEnabled then
                UpdateESPColors()
            end
        end
    })
    OtherTab:Slider({
        Title = "ESP彩虹速度",
        Desc = "调整彩虹的速度",
        Value = {
            Min = 1,
            Max = 10,
            Default = ESPRainbowSpeed,
        },
        Callback = function(value)
            ESPRainbowSpeed = value
        end
    })
    OtherTab:Space()
    OtherTab:Slider({
        Title = "ESP最大显示距离",
        Desc = "设置ESP显示的最大距离（单位：studs）",
        Value = {
            Min = 50,
            Max = 10000,
            Default = ESPMaxDistance,
        },
        Callback = function(value)
            ESPMaxDistance = value
        end
    })
    OtherTab:Space()
    OtherTab:Toggle({
        Title = "队伍检测",
        Desc = "开启后只显示敌方队伍",
        Value = ESPTeamCheck,
        Callback = function(enabled)
            ESPTeamCheck = enabled
            if ESPEnabled then
                UpdateESP()
            end
        end
    })
    OtherTab:Space()
    OtherTab:Toggle({
        Title = "偷袭检测提醒",
        Desc = "检测背后或侧面的敌人并提醒",
        Callback = function(enabled)
            BackstabCheckEnabled = enabled
            WindUI:Notify({
                Title = "偷袭检测",
                Content = enabled and "偷袭检测已开启" or "偷袭检测已关闭",
                Icon = "shield-alert",
            })
        end
    })
    OtherTab:Toggle({
        Title = "死亡提醒",
        Desc = "玩家死亡时显示提醒消息",
        Callback = function(enabled)
            DeathCheckEnabled = enabled
            if enabled then
                SetupDeathDetection()
            end
            WindUI:Notify({
                Title = "死亡提醒",
                Content = enabled and "死亡提醒已开启" or "死亡提醒已关闭",
                Icon = "heart",
            })
        end
    })
    OtherTab:Space()
    OtherTab:Toggle({
        Title = "夜视模式",
        Desc = "开启夜间模式",
        Callback = function(enabled)
            NightVisionEnabled = enabled
            if enabled then
                originalBrightness = Lighting.Brightness
                originalAmbient = Lighting.Ambient
                Lighting.Brightness = 2
                Lighting.Ambient = Color3.fromRGB(200, 200, 200)
                Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
                WindUI:Notify({
                    Title = "夜视模式",
                    Content = "夜视模式已开启",
                    Icon = "moon",
                })
            else
                Lighting.Brightness = originalBrightness
                Lighting.Ambient = originalAmbient
                Lighting.OutdoorAmbient = Color3.fromRGB(0.5, 0.5, 0.5)
                WindUI:Notify({
                    Title = "夜视模式",
                    Content = "夜视模式已关闭",
                    Icon = "moon",
                })
            end
        end
    })
end

    local MusicTab = Window:Tab({  
        Title = "音乐库",  
        Icon = "crown",  
        Locked = false,
    })

local activeSounds = {}
local customMusic = nil
local customMusicPlaying = false

do
    MusicTab:Section({
        Title = "音乐库",
        TextSize = 20,
        FontWeight = Enum.FontWeight.Bold,
    })
    MusicTab:Space()
    MusicTab:Section({
        Title = "预定义音乐列表",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    MusicTab:Space()
    MusicTab:Button({
        Title = "关闭所有音乐",
        Color = Color3.fromHex("#FF3B30"),
        Justify = "Center",
        Callback = function()
            pcall(function()
                for _, sound in pairs(activeSounds) do
                    if sound and sound:IsA("Sound") then
                        sound:Stop()
                        sound:Destroy()
                    end
                end
                activeSounds = {}
                if customMusic then
                    customMusic:Stop()
                    customMusicPlaying = false
                end
                WindUI:Notify({
                    Icon = "stop",
                    Title = "音乐已停止",
                    Content = "所有正在播放的音乐已关闭",
                })
            end)
        end,
        Icon = "stop",
        IconAlign = "Left",
    })
    MusicTab:Space()
    local musicList = {
        {"柔慢日语歌", "rbxassetid://88942576563851"},
        {"唯一", "rbxassetid://138570939058838"},
        {"Qian Li", "rbxassetid://9042630735"},
        {"DJ伤感歌", "rbxassetid://112834898401032"},
    }
    for _, music in ipairs(musicList) do
        local title, soundId = music[1], music[2]
        MusicTab:Button({
            Title = title,
            Color = Color3.fromHex("#257AF7"),
            Justify = "Center",
            Callback = function()
                pcall(function()
                    local sound = Instance.new("Sound")
                    sound.SoundId = soundId
                    sound.Parent = workspace
                    sound:Play()
                    table.insert(activeSounds, sound)
                    WindUI:Notify({
                        Icon = "play",
                        Title = "播放音乐",
                        Content = "正在播放: " .. title,
                    })
                    sound.Ended:Connect(function()
                        for i, s in ipairs(activeSounds) do
                            if s == sound then
                                table.remove(activeSounds, i)
                                break
                            end
                        end
                        sound:Destroy()
                    end)
                end)
            end,
            Icon = "music",
            IconAlign = "Left",
        })
    end
end

--此处添加标签栏

    local AboutTab = Window:Tab({  
        Title = "关于作者",  
        Icon = "crown",  
        Locked = false,
    })

do
    AboutTab:Section({
        Title = "TnineHub",
        TextSize = 20,
        FontWeight = Enum.FontWeight.Bold,
    })
    AboutTab:Space()
    AboutTab:Section({
        Title = "一个强大的PVP脚本\n包含多种游戏内功能",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    AboutTab:Section({
        Title = "作者messy(凌乱)",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    AboutTab:Section({
        Title = "如有问题及时找我修复",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    AboutTab:Section({
        Title = "有可能会闪退 看你自己的设备吧 电脑平板端有可能不闪退 中低端会闪退应该",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    AboutTab:Section({
        Title = "TnineHub企鹅主群717897412 用户可以加一下",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    AboutTab:Space({ Columns = 2 })
    AboutTab:Button({
        Title = "销毁UI",
        Color = Red,
        Justify = "Center",
        Callback = function()
            pcall(function()
                if JumpConnection then
                    JumpConnection:Disconnect()
                end
                if SpeedConnection then
                    SpeedConnection:Disconnect()
                end
                if AimConnection then
                    AimConnection:Disconnect()
                end
                CleanupDrawings()
                if RainbowUIScreenGui then
                    RainbowUIScreenGui:Destroy()
                end
                workspace.Gravity = originalGravity
                if NightVisionEnabled then
                    Lighting.Brightness = originalBrightness
                    Lighting.Ambient = originalAmbient
                end
                if ESPEnabled then
                    ToggleESP(false)
                end
                Window:Destroy()
            end)
        end
    })
    AboutTab:Space()
    AboutTab:Button({
        Title = "重置所有配置",
        Color = Yellow,
        Justify = "Center",
        Callback = function()
            pcall(function()
                AimSettings = {
                    Enabled = false,
                    FOV = 100,
                    Smoothness = 10,
                    CrosshairDistance = 5,
                    FOVColor = Color3.fromRGB(0, 255, 0),
                    FriendCheck = true,
                    WallCheck = true,
                    TargetPlayer = nil,
                    TargetAll = true,
                    FOVRainbowEnabled = true,
                    FOVRainbowSpeed = 8,
                    FOVEnabled = true
                }
                ESPNameColor = Color3.fromRGB(0, 255, 127)
                ESPBodyColor = Color3.fromRGB(0, 255, 127)
                ESPNameSize = 14
                ESPRainbowEnabled = false
                ESPRainbowSpeed = 5
                CurrentESPHue = 0
                RainbowUIEnabled = false
                BackstabCheckEnabled = false
                DeathCheckEnabled = false
                CurrentTarget = nil
                ESPTeamCheck = false
                if RainbowUIScreenGui then
                    RainbowUIScreenGui:Destroy()
                    RainbowUIScreenGui = nil
                end
                workspace.Gravity = originalGravity
                if NightVisionEnabled then
                    Lighting.Brightness = originalBrightness
                    Lighting.Ambient = originalAmbient
                    NightVisionEnabled = false
                end
                if ESPEnabled then
                    ToggleESP(false)
                end
                WindUI:Notify({
                    Title = "重置",
                    Content = "所有设置已重置",
                    Icon = "refresh-cw",
                })
            end)
        end
    })
end

game:BindToClose(function()
    pcall(function()
        CleanupDrawings()
        if JumpConnection then
            JumpConnection:Disconnect()
        end
        if SpeedConnection then
            SpeedConnection:Disconnect()
        end
        if AimConnection then
            AimConnection:Disconnect()
        end
        if ESPEnabled then
            ToggleESP(false)
        end
        if RainbowUIScreenGui then
            RainbowUIScreenGui:Destroy()
        end
        workspace.Gravity = originalGravity
        if NightVisionEnabled then
            Lighting.Brightness = originalBrightness
            Lighting.Ambient = originalAmbient
        end
    end)
end)

coroutine.wrap(function()
    while true do
        task.wait(5)
        pcall(function()
            if ESPEnabled then
                if ESPFolder then
                    for _, child in ipairs(ESPFolder:GetChildren()) do
                        child:Destroy()
                    end
                end
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        CreatePlayerESP(player)
                    end
                end
            end
            CurrentTarget = nil
        end)
    end
end)()

if WindUI and WindUI.InitComplete then
    WindUI.InitComplete:Wait()
end

WindUI:Notify({
    Title = "pvp",
    Content = "TnineHub!",
    Icon = "check-circle",
    Duration = 5,
})