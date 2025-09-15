-- Auto Reel Super Instant Script for Fisch Game
-- Extracted and optimized from ori.lua
-- Features: Ultra-fast instant reel with zero animation

-- Load Kavo UI Library
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/kavo.lua"))()
local Window = Kavo.CreateLib("Auto Reel Instant", "Ocean")

-- Services
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local VirtualInputManager = game:GetService('VirtualInputManager')

-- Variables
local lp = Players.LocalPlayer
local flags = {}

-- Auto Reel Settings
flags['autoreel'] = false
flags['autoreeldelay'] = 0.1
flags['superinstantreel'] = false
flags['instantbobber'] = false
flags['superinstantnoanimation'] = false
flags['disableallanimations'] = false

-- Super Instant Variables
local superInstantReelActive = false
local lureMonitorConnection = nil

-- Find Rod Function
local function FindRod()
    local character = lp.Character
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                return tool
            end
        end
    end
    return nil
end

-- ENHANCED Super Instant Reel System
local function setupSuperInstantReel()
    if not superInstantReelActive then
        superInstantReelActive = true
        
        print("🚀 [SUPER INSTANT REEL] System activated!")
        
        -- Main monitoring loop
        lureMonitorConnection = RunService.Heartbeat:Connect(function()
            if flags['superinstantreel'] then
                pcall(function()
                    local rod = FindRod()
                    if rod and rod.values then
                        local lureValue = rod.values.lure and rod.values.lure.Value or 0
                        local biteValue = rod.values.bite and rod.values.bite.Value or false
                        
                        -- Handle animations based on settings
                        if flags['disableallanimations'] then
                            local character = lp.Character
                            if character and character:FindFirstChild("Humanoid") then
                                local humanoid = character.Humanoid
                                
                                -- Stop ALL fishing animations
                                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                                    local animName = track.Name:lower()
                                    local animId = tostring(track.Animation.AnimationId):lower()
                                    
                                    if animName:find("fish") or animName:find("reel") or animName:find("cast") or 
                                       animName:find("rod") or animName:find("catch") or animName:find("lift") or
                                       animId:find("fish") or animId:find("reel") or animId:find("cast") then
                                        track:Stop()
                                        track:AdjustSpeed(0)
                                    end
                                end
                            end
                        end
                        
                        -- ULTRA-INSTANT catch when fish detected
                        if lureValue >= 95 or biteValue == true then
                            -- Multiple rapid fire for instant completion
                            for i = 1, 5 do
                                ReplicatedStorage.events.reelfinished:FireServer(100, true)
                            end
                            
                            -- Destroy reel GUI instantly
                            local reelGui = lp.PlayerGui:FindFirstChild("reel")
                            if reelGui then
                                reelGui:Destroy()
                            end
                            
                            print("⚡ [INSTANT CATCH] Lure:" .. lureValue .. "%")
                        end
                    end
                end)
            end
        end)
        
        -- GUI intercept for reel interface
        lp.PlayerGui.ChildAdded:Connect(function(gui)
            if flags['superinstantreel'] and gui.Name == "reel" then
                task.wait(0.05)
                pcall(function()
                    gui:Destroy()
                    ReplicatedStorage.events.reelfinished:FireServer(100, true)
                end)
            end
        end)
        
        -- Continuous animation blocking
        task.spawn(function()
            while superInstantReelActive do
                task.wait(0.05)
                if flags['superinstantreel'] and flags['disableallanimations'] then
                    pcall(function()
                        local character = lp.Character
                        if character and character:FindFirstChild("Humanoid") then
                            local humanoid = character.Humanoid
                            
                            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                                local animName = track.Name:lower()
                                local animId = tostring(track.Animation.AnimationId):lower()
                                
                                -- Expanded animation detection
                                if animName:find("fish") or animName:find("reel") or animName:find("cast") or 
                                   animName:find("rod") or animName:find("catch") or animName:find("lift") or
                                   animName:find("pull") or animName:find("bobber") or animName:find("yank") or
                                   animId:find("fish") or animId:find("reel") or animId:find("cast") then
                                    track:Stop()
                                    track:AdjustSpeed(0)
                                end
                            end
                        end
                    end)
                end
            end
        end)
    end
end

-- Normal Auto Reel Function
local function normalAutoReel()
    task.spawn(function()
        while flags['autoreel'] do
            task.wait(flags['autoreeldelay'])
            
            pcall(function()
                local reelGui = lp.PlayerGui:FindFirstChild("reel")
                if reelGui and reelGui.Enabled then
                    local reelFrame = reelGui:FindFirstChild("bar")
                    if reelFrame then
                        local playerBar = reelFrame:FindFirstChild("playerbar")
                        local fishBar = reelFrame:FindFirstChild("fish")
                        
                        if playerBar and fishBar then
                            local playerPos = playerBar.Position.X.Scale
                            local fishPos = fishBar.Position.X.Scale
                            
                            -- Simple auto reel logic
                            if math.abs(playerPos - fishPos) > 0.1 then
                                if playerPos < fishPos then
                                    VirtualInputManager:SendKeyEvent(true, "D", false, game)
                                else
                                    VirtualInputManager:SendKeyEvent(true, "A", false, game)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Auto Shake Function
local function autoShake()
    lp.PlayerGui.ChildAdded:Connect(function(gui)
        if gui.Name == "shakeui" and flags['autoreel'] then
            task.wait(0.1)
            pcall(function()
                if gui and gui.Parent then
                    gui:Destroy()
                    ReplicatedStorage.events.shakecomplete:FireServer()
                end
            end)
        end
    end)
end

-- Setup functions
setupSuperInstantReel()
autoShake()

-- GUI Setup
local MainTab = Window:NewTab("Auto Reel")
local ReelSection = MainTab:NewSection("Reel Settings")
local AdvancedSection = MainTab:NewSection("Advanced Settings")

-- Normal Auto Reel Toggle
ReelSection:NewToggle("Auto Reel", "Normal automatic reeling", function(state)
    flags['autoreel'] = state
    if state then
        flags['superinstantreel'] = false -- Disable super instant
        normalAutoReel()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Reel";
            Text = "Normal Auto Reel Enabled!";
            Duration = 2;
        })
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Reel";
            Text = "Auto Reel Disabled!";
            Duration = 2;
        })
    end
end)

-- Super Instant Reel Toggle
ReelSection:NewToggle("Super Instant Reel", "⚡ Ultra-fast instant catch with zero delay", function(state)
    flags['superinstantreel'] = state
    if state then
        flags['autoreel'] = false -- Disable normal auto reel
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Reel";
            Text = "🚀 SUPER INSTANT REEL Activated!";
            Duration = 3;
        })
        print("🚀 [Super Instant Reel] MAXIMUM SPEED MODE!")
    else
        flags['disableallanimations'] = false
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Reel";
            Text = "Super Instant Reel Disabled";
            Duration = 2;
        })
    end
end)

-- Disable All Animations Toggle
ReelSection:NewToggle("Disable All Animations", "🚫 Completely disable fishing animations", function(state)
    flags['disableallanimations'] = state
    if state and not flags['superinstantreel'] then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Reel";
            Text = "⚠️ Enable Super Instant Reel first!";
            Duration = 2;
        })
        flags['disableallanimations'] = false
    elseif state then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Reel";
            Text = "🚫 All animations disabled!";
            Duration = 2;
        })
    end
end)

-- Auto Reel Delay Slider
AdvancedSection:NewSlider("Auto Reel Delay", "Delay between reel actions (seconds)", 2, 0.01, function(value)
    flags['autoreeldelay'] = value
end)

-- Instant Bobber Toggle
AdvancedSection:NewToggle("Instant Bobber", "Makes bobber appear instantly", function(state)
    flags['instantbobber'] = state
    if state then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Reel";
            Text = "Instant Bobber Enabled!";
            Duration = 2;
        })
    end
end)

-- Status Section
local StatusSection = MainTab:NewSection("Status")

-- Status Labels
local normalReelLabel = StatusSection:NewLabel("Normal Auto Reel: Disabled")
local superReelLabel = StatusSection:NewLabel("Super Instant Reel: Disabled")
local animationLabel = StatusSection:NewLabel("Animation Block: Disabled")

-- Update status labels
task.spawn(function()
    while true do
        task.wait(1)
        
        local normalStatus = flags['autoreel'] and "Enabled" or "Disabled"
        local superStatus = flags['superinstantreel'] and "Enabled" or "Disabled"
        local animStatus = flags['disableallanimations'] and "Enabled" or "Disabled"
        
        normalReelLabel:UpdateLabel("Normal Auto Reel: " .. normalStatus)
        superReelLabel:UpdateLabel("Super Instant Reel: " .. superStatus)
        animationLabel:UpdateLabel("Animation Block: " .. animStatus)
    end
end)

-- Info Section
local InfoSection = MainTab:NewSection("Information")
InfoSection:NewLabel("🎣 Normal Auto Reel: Standard automatic reeling")
InfoSection:NewLabel("⚡ Super Instant Reel: Ultra-fast zero-delay catch")
InfoSection:NewLabel("🚫 Disable Animations: Remove all fishing animations")
InfoSection:NewLabel("⚠️ Use Super Instant carefully - may be detectable")

game.StarterGui:SetCore("SendNotification", {
    Title = "Auto Reel Instant";
    Text = "Script loaded successfully!";
    Duration = 3;
})

print("🎣 Auto Reel Super Instant Script Loaded!")
print("Features:")
print("- Normal Auto Reel with customizable delay")
print("- Super Instant Reel with zero animation")
print("- Auto Shake bypass")
print("- Animation disabling system")
print("- Real-time status monitoring")