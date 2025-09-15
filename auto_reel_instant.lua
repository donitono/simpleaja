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
flags['superinstantsilent'] = false -- NEW: Combined super instant + zero animation mode
flags['instantbobber'] = false

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

-- ENHANCED Super Instant Silent Reel System (ZERO ANIMATION + INSTANT CATCH)
local function setupSuperInstantSilentReel()
    if not superInstantReelActive then
        superInstantReelActive = true
        
        print("🤫 [SUPER INSTANT SILENT] System activated - Zero movement mode!")
        
        -- Main monitoring loop with aggressive animation blocking
        lureMonitorConnection = RunService.Heartbeat:Connect(function()
            if flags['superinstantsilent'] then
                pcall(function()
                    local rod = FindRod()
                    if rod and rod.values then
                        local lureValue = rod.values.lure and rod.values.lure.Value or 0
                        local biteValue = rod.values.bite and rod.values.bite.Value or false
                        
                        -- AGGRESSIVE ANIMATION BLOCKING (Every frame)
                        local character = lp.Character
                        if character and character:FindFirstChild("Humanoid") then
                            local humanoid = character.Humanoid
                            
                            -- Stop ALL fishing-related animations immediately
                            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                                local animName = track.Name:lower()
                                local animId = tostring(track.Animation.AnimationId):lower()
                                
                                -- Comprehensive animation detection and blocking
                                if animName:find("fish") or animName:find("reel") or animName:find("cast") or 
                                   animName:find("rod") or animName:find("catch") or animName:find("lift") or
                                   animName:find("pull") or animName:find("bobber") or animName:find("yank") or
                                   animName:find("swing") or animName:find("throw") or animName:find("hook") or
                                   animId:find("fish") or animId:find("reel") or animId:find("cast") or
                                   animId:find("rod") or animId:find("catch") or animId:find("lift") or
                                   animId:find("pull") or animId:find("bobber") or animId:find("yank") then
                                    track:Stop() -- Immediately stop
                                    track:AdjustSpeed(0) -- Set speed to zero
                                    track:Destroy() -- Completely remove if possible
                                end
                            end
                            
                            -- Force character to idle position (no movement)
                            humanoid.PlatformStand = false
                            humanoid.Sit = false
                        end
                        
                        -- ULTRA-INSTANT SILENT CATCH (No animations, no delays)
                        if lureValue >= 90 or biteValue == true then -- Lower threshold for faster response
                            -- IMMEDIATE completion with multiple rapid fires
                            for i = 1, 10 do -- Increased to 10 for better reliability
                                ReplicatedStorage.events.reelfinished:FireServer(100, true)
                                task.wait(0.001) -- Minimal delay between fires
                            end
                            
                            -- Instantly destroy any GUI that appears
                            local reelGui = lp.PlayerGui:FindFirstChild("reel")
                            if reelGui then
                                reelGui:Destroy()
                            end
                            
                            -- Force stop any animations that might have started
                            if character and character:FindFirstChild("Humanoid") then
                                local humanoid = character.Humanoid
                                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                                    track:Stop()
                                    track:AdjustSpeed(0)
                                end
                            end
                            
                            print("🤫 [SILENT CATCH] Lure:" .. lureValue .. "% - ZERO MOVEMENT!")
                        end
                    end
                end)
            end
        end)
        
        -- GUI intercept and immediate destruction
        lp.PlayerGui.ChildAdded:Connect(function(gui)
            if flags['superinstantsilent'] then
                if gui.Name == "reel" or gui.Name == "shakeui" then
                    -- Immediately destroy without any delay
                    pcall(function()
                        gui:Destroy()
                        -- Fire completion events
                        if gui.Name == "reel" then
                            ReplicatedStorage.events.reelfinished:FireServer(100, true)
                        elseif gui.Name == "shakeui" then
                            ReplicatedStorage.events.shakecomplete:FireServer()
                        end
                    end)
                end
            end
        end)
        
        -- Continuous animation prevention loop
        task.spawn(function()
            while superInstantReelActive do
                task.wait(0.01) -- Check every 10ms for maximum responsiveness
                if flags['superinstantsilent'] then
                    pcall(function()
                        local character = lp.Character
                        if character and character:FindFirstChild("Humanoid") then
                            local humanoid = character.Humanoid
                            
                            -- Aggressive animation stopping
                            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                                local animName = track.Name:lower()
                                local animId = tostring(track.Animation.AnimationId):lower()
                                
                                -- Extended animation pattern matching
                                local fishingPatterns = {
                                    "fish", "reel", "cast", "rod", "catch", "lift", "pull", 
                                    "bobber", "yank", "swing", "throw", "hook", "bait"
                                }
                                
                                for _, pattern in pairs(fishingPatterns) do
                                    if animName:find(pattern) or animId:find(pattern) then
                                        track:Stop()
                                        track:AdjustSpeed(0)
                                        break
                                    end
                                end
                            end
                            
                            -- Keep character in neutral state
                            humanoid.PlatformStand = false
                            humanoid.Sit = false
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

-- Auto Shake Function (Enhanced for silent mode)
local function autoShake()
    lp.PlayerGui.ChildAdded:Connect(function(gui)
        if gui.Name == "shakeui" and (flags['autoreel'] or flags['superinstantsilent']) then
            pcall(function()
                -- Immediate destruction for silent mode, small delay for normal mode
                if flags['superinstantsilent'] then
                    gui:Destroy()
                    ReplicatedStorage.events.shakecomplete:FireServer()
                else
                    task.wait(0.1)
                    if gui and gui.Parent then
                        gui:Destroy()
                        ReplicatedStorage.events.shakecomplete:FireServer()
                    end
                end
            end)
        end
    end)
end

-- Setup functions
setupSuperInstantSilentReel()
autoShake()

-- GUI Setup
local MainTab = Window:NewTab("Auto Reel")
local ReelSection = MainTab:NewSection("Reel Settings")
local AdvancedSection = MainTab:NewSection("Advanced Settings")

-- Normal Auto Reel Toggle
ReelSection:NewToggle("Auto Reel", "Normal automatic reeling with visible animations", function(state)
    flags['autoreel'] = state
    if state then
        flags['superinstantsilent'] = false -- Disable silent mode
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

-- Super Instant Silent Reel Toggle (COMBINED MODE)
ReelSection:NewToggle("Super Instant Silent Reel", "🤫 ZERO MOVEMENT + INSTANT CATCH - No animations, no delays, just results!", function(state)
    flags['superinstantsilent'] = state
    if state then
        flags['autoreel'] = false -- Disable normal auto reel
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Reel";
            Text = "🤫 SILENT MODE Activated! Zero movement fishing!";
            Duration = 3;
        })
        print("🤫 [Super Instant Silent] GHOST MODE - No animations, no movement!")
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Reel";
            Text = "Silent Mode Disabled";
            Duration = 2;
        })
        print("⏸️ [Silent Mode] Deactivated")
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
local silentReelLabel = StatusSection:NewLabel("Silent Instant Reel: Disabled")

-- Update status labels
task.spawn(function()
    while true do
        task.wait(1)
        
        local normalStatus = flags['autoreel'] and "Enabled" or "Disabled"
        local silentStatus = flags['superinstantsilent'] and "Enabled" or "Disabled"
        
        normalReelLabel:UpdateLabel("Normal Auto Reel: " .. normalStatus)
        silentReelLabel:UpdateLabel("Silent Instant Reel: " .. silentStatus)
    end
end)

-- Info Section
local InfoSection = MainTab:NewSection("Information")
InfoSection:NewLabel("🎣 Normal Auto Reel: Standard reeling with animations")
InfoSection:NewLabel("🤫 Silent Instant Reel: ZERO movement + instant catch")
InfoSection:NewLabel("� Ghost Mode: Fish appear in inventory instantly")
InfoSection:NewLabel("⚡ No delays, no animations, no movement!")
InfoSection:NewLabel("⚠️ Silent mode is very powerful - use carefully")

game.StarterGui:SetCore("SendNotification", {
    Title = "Auto Reel Instant";
    Text = "Script loaded successfully!";
    Duration = 3;
})

print("🤫 Auto Reel Silent Instant Script Loaded!")
print("Features:")
print("- Normal Auto Reel with visible animations")
print("- Silent Instant Reel with ZERO movement")
print("- Ghost Mode: Fish appear instantly without any animation")
print("- Auto Shake bypass for both modes")
print("- Real-time aggressive animation blocking")
print("- Character kept in neutral state (no fishing movements)")