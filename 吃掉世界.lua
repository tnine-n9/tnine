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

local Tabs = {}
local AutoTab = Window:Tab({Title = "自动功能", Icon = "zap"})
local AttackTab = Window:Tab({Title = "攻击功能", Icon = "swords"})

local autoGrabEnabled = false
local autoEatEnabled = false
local autoAttackEnabled = false
local attackInterval = 0.5
local grabInterval = 0.8
local eatInterval = 0.2

local grabThread = nil
local eatThread = nil
local attackThread = nil

local function PerformGrab()
    local args = {[1] = false, [2] = false, [3] = false}
    local success, err = pcall(function()
        game:GetService("Players").LocalPlayer.Character.Events.Grab:FireServer(unpack(args))
    end)
    return success
end

local function StartAutoGrab()
    if grabThread then return end
    grabThread = task.spawn(function()
        while autoGrabEnabled do
            PerformGrab()
            task.wait(grabInterval)
        end
        grabThread = nil
    end)
end

local function StopAutoGrab()
    autoGrabEnabled = false
    if grabThread then
        task.cancel(grabThread)
        grabThread = nil
    end
end

local function PerformEat()
    local success, err = pcall(function()
        game:GetService("Players").LocalPlayer.Character.Events.Eat:FireServer()
    end)
    return success
end

local function StartAutoEat()
    if eatThread then return end
    eatThread = task.spawn(function()
        while autoEatEnabled do
            PerformEat()
            task.wait(eatInterval)
        end
        eatThread = nil
    end)
end

local function StopAutoEat()
    autoEatEnabled = false
    if eatThread then
        task.cancel(eatThread)
        eatThread = nil
    end
end

local function PerformAttack()
    local success, err = pcall(function()
        game:GetService("Players").LocalPlayer.Character.Events.Throw:FireServer()
    end)
    return success
end

local function StartAutoAttack()
    if attackThread then return end
    attackThread = task.spawn(function()
        while autoAttackEnabled do
            PerformAttack()
            task.wait(attackInterval)
        end
        attackThread = nil
    end)
end

local function StopAutoAttack()
    autoAttackEnabled = false
    if attackThread then
        task.cancel(attackThread)
        attackThread = nil
    end
end

AutoTab:Toggle({
    Title = "启用自动抓取",
    Value = autoGrabEnabled,
    Callback = function(Value)
        autoGrabEnabled = Value
        if Value then
            StartAutoGrab()
            WindUI:Notify({
                Title = "自动抓取",
                Content = "已启用自动抓取功能",
                Duration = 2,
                Icon = "4483362458"
            })
        else
            StopAutoGrab()
            WindUI:Notify({
                Title = "自动抓取",
                Content = "已关闭自动抓取功能",
                Duration = 2,
                Icon = "4483362458"
            })
        end
    end
})

AutoTab:Toggle({
    Title = "启用自动吃",
    Value = autoEatEnabled,
    Callback = function(Value)
        autoEatEnabled = Value
        if Value then
            StartAutoEat()
            WindUI:Notify({
                Title = "自动吃",
                Content = "已启用自动吃功能",
                Duration = 2,
                Icon = "4483362458"
            })
        else
            StopAutoEat()
            WindUI:Notify({
                Title = "自动吃",
                Content = "已关闭自动吃功能",
                Duration = 2,
                Icon = "4483362458"
            })
        end
    end
})

AttackTab:Toggle({
    Title = "启用自动攻击",
    Value = autoAttackEnabled,
    Callback = function(Value)
        autoAttackEnabled = Value
        if Value then
            StartAutoAttack()
            WindUI:Notify({
                Title = "自动攻击",
                Content = "已启用自动攻击功能",
                Duration = 2,
                Icon = "4483362458"
            })
        else
            StopAutoAttack()
            WindUI:Notify({
                Title = "自动攻击",
                Content = "已关闭自动攻击功能",
                Duration = 2,
                Icon = "4483362458"
            })
        end
    end
})

AttackTab:Slider({
    Title = "攻击间隔 (秒)",
    Desc = "调整攻击间隔时间",
    Value = {
        Min = 0.1,
        Max = 3,
        Default = 0.5,
    },
    Step = 0.1,
    Callback = function(Value)
        attackInterval = Value
        WindUI:Notify({
            Title = "攻击间隔",
            Content = "已设置为 " .. Value .. " 秒",
            Duration = 1.5,
            Icon = "4483362458"
        })
    end
})