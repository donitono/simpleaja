-- Main Script for Fisch Game Auto Tools
-- Combines Auto Appraiser and Auto Reel Silent in one interface
-- Author: donitono
-- Repository: https://github.com/donitono/simpleaja

-- Load Kavo UI Library
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/kavo.lua"))()
local Window = Kavo.CreateLib("Fisch Auto Tools", "Ocean")

-- Services
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local VirtualInputManager = game:GetService('VirtualInputManager')
local TweenService = game:GetService('TweenService')

-- Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Global Flags
local flags = {}

-- ======================================================================================
-- AUTO APPRAISER SECTION
-- ======================================================================================

-- Auto Appraiser Settings
local AutoAppraise = {
    Enabled = false,
    SelectedAppraiser = "Any",
    AppraiseDelay = 1,
    StopWhenFound = true,
    MaxAttempts = 100,
    CurrentAttempts = 0
}

-- Appraiser Mutation Types (based on Fischipedia wiki)
local Appraisers = {
    "Any",
    "Albino", "Darkened", "Negative", "Glossy", "Translucent",
    "Lunar", "Electric", "Silver", "Hexed", "Frozen", 
    "Mosaic", "Scorched", "Amber", "Abyssal", "Fossilized",
    "Midas", "Greedy", "Spirit", "Mythical"
}

-- Auto Appraiser Functions
local function findNearestAppraiser()
    local nearestAppraiser = nil
    local shortestDistance = math.huge
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("appraiser") and obj:FindFirstChild("HumanoidRootPart") then
            local distance = (HumanoidRootPart.Position - obj.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance and distance <= 50 then
                shortestDistance = distance
                nearestAppraiser = obj
            end
        end
    end
    
    return nearestAppraiser
end

local function teleportToAppraiser(appraiser)
    if appraiser and appraiser:FindFirstChild("HumanoidRootPart") then
        HumanoidRootPart.CFrame = appraiser.HumanoidRootPart.CFrame + Vector3.new(0, 0, -5)
    end
end

local function interactWithAppraiser(appraiser)
    -- Multiple interaction methods
    local remotes = ReplicatedStorage:GetDescendants()
    for _, remote in pairs(remotes) do
        if remote:IsA("RemoteEvent") then
            local remoteName = remote.Name:lower()
            if remoteName:find("apprai") or remoteName:find("npc") or remoteName:find("dialog") then
                pcall(function()
                    remote:FireServer("StartConversation", appraiser)
                    wait(0.2)
                    remote:FireServer("SelectOption", "Appraise")
                    wait(0.2)
                    remote:FireServer("ConfirmAppraisal")
                end)
                break
            end
        end
    end
    
    -- Try proximity prompt
    local proximityPrompt = appraiser:FindFirstChildOfClass("ProximityPrompt", true)
    if proximityPrompt then
        fireproximityprompt(proximityPrompt)
    end
    
    -- Try click detector
    local clickDetector = appraiser:FindFirstChildOfClass("ClickDetector", true)
    if clickDetector then
        fireclickdetector(clickDetector)
    end
end

local function checkAppraisalResult()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local resultGui = playerGui:FindFirstChild("AppraisalGUI") or 
                         playerGui:FindFirstChild("ItemAppraisalGUI") or
                         playerGui:FindFirstChild("AppraisalResult")
        
        if resultGui then
            local textLabels = resultGui:GetDescendants()
            for _, label in pairs(textLabels) do
                if label:IsA("TextLabel") or label:IsA("TextButton") then
                    local text = label.Text
                    if AutoAppraise.SelectedAppraiser ~= "Any" then
                        for _, mutationType in pairs(Appraisers) do
                            if text:find(mutationType) and mutationType == AutoAppraise.SelectedAppraiser then
                                return true
                            end
                        end
                    else
                        for _, mutationType in pairs(Appraisers) do
                            if text:find(mutationType) then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

local function autoAppraise()
    if not AutoAppraise.Enabled then return end
    
    AutoAppraise.CurrentAttempts = AutoAppraise.CurrentAttempts + 1
    
    if AutoAppraise.CurrentAttempts >= AutoAppraise.MaxAttempts then
        AutoAppraise.Enabled = false
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Appraiser";
            Text = "Max attempts reached!";
            Duration = 3;
        })
        return
    end
    
    local appraiser = findNearestAppraiser()
    if not appraiser then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Appraiser";
            Text = "No appraiser found nearby!";
            Duration = 3;
        })
        wait(2)
        return
    end
    
    teleportToAppraiser(appraiser)
    wait(1)
    interactWithAppraiser(appraiser)
    wait(3)
    
    if AutoAppraise.StopWhenFound and checkAppraisalResult() then
        AutoAppraise.Enabled = false
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Appraiser";
            Text = "Target mutation found!";
            Duration = 5;
        })
        return
    end
    
    wait(AutoAppraise.AppraiseDelay)
end

-- ======================================================================================
-- AUTO REEL SILENT SECTION
-- ======================================================================================

-- Auto Reel Settings
flags['autoreel'] = false
flags['autoreeldelay'] = 0.1
flags['superinstantsilent'] = false
flags['instantbobber'] = false

-- Super Instant Variables
local superInstantReelActive = false
local lureMonitorConnection = nil

-- Find Rod Function
local function FindRod()
    local character = LocalPlayer.Character
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                return tool
            end
        end
    end
    return nil
end

-- Silent Reel System
local function setupSuperInstantSilentReel()
    if not superInstantReelActive then
        superInstantReelActive = true
        
        lureMonitorConnection = RunService.Heartbeat:Connect(function()
            if flags['superinstantsilent'] then
                pcall(function()
                    local rod = FindRod()
                    if rod and rod.values then
                        local lureValue = rod.values.lure and rod.values.lure.Value or 0
                        local biteValue = rod.values.bite and rod.values.bite.Value or false
                        
                        -- Aggressive animation blocking
                        local character = LocalPlayer.Character
                        if character and character:FindFirstChild("Humanoid") then
                            local humanoid = character.Humanoid
                            
                            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                                local animName = track.Name:lower()
                                local animId = tostring(track.Animation.AnimationId):lower()
                                
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
                            
                            humanoid.PlatformStand = false
                            humanoid.Sit = false
                        end
                        
                        -- Ultra-instant catch
                        if lureValue >= 90 or biteValue == true then
                            for i = 1, 10 do
                                ReplicatedStorage.events.reelfinished:FireServer(100, true)
                                task.wait(0.001)
                            end
                            
                            local reelGui = LocalPlayer.PlayerGui:FindFirstChild("reel")
                            if reelGui then
                                reelGui:Destroy()
                            end
                        end
                    end
                end)
            end
        end)
        
        -- GUI intercept
        LocalPlayer.PlayerGui.ChildAdded:Connect(function(gui)
            if flags['superinstantsilent'] then
                if gui.Name == "reel" or gui.Name == "shakeui" then
                    pcall(function()
                        gui:Destroy()
                        if gui.Name == "reel" then
                            ReplicatedStorage.events.reelfinished:FireServer(100, true)
                        elseif gui.Name == "shakeui" then
                            ReplicatedStorage.events.shakecomplete:FireServer()
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
                local reelGui = LocalPlayer.PlayerGui:FindFirstChild("reel")
                if reelGui and reelGui.Enabled then
                    local reelFrame = reelGui:FindFirstChild("bar")
                    if reelFrame then
                        local playerBar = reelFrame:FindFirstChild("playerbar")
                        local fishBar = reelFrame:FindFirstChild("fish")
                        
                        if playerBar and fishBar then
                            local playerPos = playerBar.Position.X.Scale
                            local fishPos = fishBar.Position.X.Scale
                            
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

-- Setup functions
setupSuperInstantSilentReel()

-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end)

-- ======================================================================================
-- GUI SETUP
-- ======================================================================================

-- Tab 1: Auto Appraiser
local AppraiserTab = Window:NewTab("🎯 Auto Appraiser")
local AppraisalSection = AppraiserTab:NewSection("Appraisal Settings")
local AppraisalStatusSection = AppraiserTab:NewSection("Status & Control")

-- Appraiser Controls
AppraisalSection:NewDropdown("Target Mutation", "Select which mutation/variant to target", Appraisers, function(selected)
    AutoAppraise.SelectedAppraiser = selected
    game.StarterGui:SetCore("SendNotification", {
        Title = "Auto Appraiser";
        Text = "Target set to: " .. selected;
        Duration = 2;
    })
end)

AppraisalSection:NewToggle("Auto Appraiser", "Toggle automatic appraising", function(state)
    AutoAppraise.Enabled = state
    AutoAppraise.CurrentAttempts = 0
    
    if state then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Appraiser";
            Text = "🎯 Auto Appraiser Enabled!";
            Duration = 2;
        })
        
        spawn(function()
            while AutoAppraise.Enabled do
                autoAppraise()
                wait(AutoAppraise.AppraiseDelay)
            end
        end)
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Appraiser";
            Text = "Auto Appraiser Disabled!";
            Duration = 2;
        })
    end
end)

AppraisalSection:NewSlider("Appraise Delay", "Delay between appraisals (seconds)", 10, 0.1, function(value)
    AutoAppraise.AppraiseDelay = value
end)

AppraisalSection:NewSlider("Max Attempts", "Maximum attempts before stopping", 1000, 10, function(value)
    AutoAppraise.MaxAttempts = value
end)

AppraisalSection:NewToggle("Stop When Found", "Stop when target mutation is found", function(state)
    AutoAppraise.StopWhenFound = state
end)

-- Appraiser Status Controls
AppraisalStatusSection:NewButton("Find Nearest Appraiser", "Teleport to nearest appraiser", function()
    local appraiser = findNearestAppraiser()
    if appraiser then
        teleportToAppraiser(appraiser)
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Appraiser";
            Text = "Teleported to appraiser!";
            Duration = 2;
        })
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Appraiser";
            Text = "No appraiser found!";
            Duration = 2;
        })
    end
end)

AppraisalStatusSection:NewButton("Reset Attempts", "Reset attempts counter", function()
    AutoAppraise.CurrentAttempts = 0
    game.StarterGui:SetCore("SendNotification", {
        Title = "Auto Appraiser";
        Text = "Attempts reset!";
        Duration = 2;
    })
end)

-- Tab 2: Auto Reel Silent
local ReelTab = Window:NewTab("🎣 Auto Reel Silent")
local ReelSection = ReelTab:NewSection("Reel Settings")
local ReelAdvancedSection = ReelTab:NewSection("Advanced Settings")
local ReelStatusSection = ReelTab:NewSection("Status")

-- Reel Controls
ReelSection:NewToggle("Normal Auto Reel", "Standard automatic reeling with animations", function(state)
    flags['autoreel'] = state
    if state then
        flags['superinstantsilent'] = false
        normalAutoReel()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Reel";
            Text = "🎣 Normal Auto Reel Enabled!";
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

ReelSection:NewToggle("Silent Instant Reel", "🤫 ZERO MOVEMENT + INSTANT CATCH", function(state)
    flags['superinstantsilent'] = state
    if state then
        flags['autoreel'] = false
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Reel";
            Text = "🤫 GHOST MODE Activated!";
            Duration = 3;
        })
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Reel";
            Text = "Silent Mode Disabled";
            Duration = 2;
        })
    end
end)

ReelAdvancedSection:NewSlider("Auto Reel Delay", "Delay between reel actions", 2, 0.01, function(value)
    flags['autoreeldelay'] = value
end)

ReelAdvancedSection:NewToggle("Instant Bobber", "Makes bobber appear instantly", function(state)
    flags['instantbobber'] = state
    if state then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Reel";
            Text = "Instant Bobber Enabled!";
            Duration = 2;
        })
    end
end)

-- Tab 3: Information & Status
local InfoTab = Window:NewTab("ℹ️ Information")
local StatusInfoSection = InfoTab:NewSection("Live Status")
local UsageInfoSection = InfoTab:NewSection("Usage Guide")

-- Live Status Labels
local appraiserStatusLabel = StatusInfoSection:NewLabel("Appraiser Status: Ready")
local appraiserAttemptsLabel = StatusInfoSection:NewLabel("Attempts: 0/100")
local appraiserTargetLabel = StatusInfoSection:NewLabel("Target: Any")

local reelNormalLabel = StatusInfoSection:NewLabel("Normal Reel: Disabled")
local reelSilentLabel = StatusInfoSection:NewLabel("Silent Reel: Disabled")

-- Usage Information
UsageInfoSection:NewLabel("🎯 AUTO APPRAISER:")
UsageInfoSection:NewLabel("• Select target mutation from dropdown")
UsageInfoSection:NewLabel("• Enable Auto Appraiser toggle")
UsageInfoSection:NewLabel("• Script will find & teleport to appraiser")
UsageInfoSection:NewLabel("• Automatically interact until target found")

UsageInfoSection:NewLabel("")
UsageInfoSection:NewLabel("🤫 SILENT REEL MODE:")
UsageInfoSection:NewLabel("• Zero movement instant fishing")
UsageInfoSection:NewLabel("• Fish appear in inventory instantly")
UsageInfoSection:NewLabel("• No animations or character movement")
UsageInfoSection:NewLabel("• Very powerful but may be detectable")

UsageInfoSection:NewLabel("")
UsageInfoSection:NewLabel("⚠️ SAFETY TIPS:")
UsageInfoSection:NewLabel("• Use in private servers when possible")
UsageInfoSection:NewLabel("• Don't use with other players nearby")
UsageInfoSection:NewLabel("• Start with lower attempt limits")

-- Status Update Loop
task.spawn(function()
    while true do
        wait(1)
        
        -- Update Appraiser Status
        local appraiserStatus = AutoAppraise.Enabled and "Running" or "Stopped"
        appraiserStatusLabel:UpdateLabel("Appraiser Status: " .. appraiserStatus)
        appraiserAttemptsLabel:UpdateLabel("Attempts: " .. AutoAppraise.CurrentAttempts .. "/" .. AutoAppraise.MaxAttempts)
        appraiserTargetLabel:UpdateLabel("Target: " .. AutoAppraise.SelectedAppraiser)
        
        -- Update Reel Status
        local normalStatus = flags['autoreel'] and "Enabled" or "Disabled"
        local silentStatus = flags['superinstantsilent'] and "Enabled" or "Disabled"
        reelNormalLabel:UpdateLabel("Normal Reel: " .. normalStatus)
        reelSilentLabel:UpdateLabel("Silent Reel: " .. silentStatus)
    end
end)

-- Welcome Message
game.StarterGui:SetCore("SendNotification", {
    Title = "Fisch Auto Tools";
    Text = "All systems loaded successfully! 🎣🎯";
    Duration = 3;
})

print("🎣 Fisch Auto Tools Main Script Loaded!")
print("Features Available:")
print("• 🎯 Auto Appraiser with mutation filtering")
print("• 🤫 Silent Instant Reel (Ghost Mode)")
print("• 🎣 Normal Auto Reel with customizable settings")
print("• ℹ️ Real-time status monitoring")
print("• 🛡️ Safety features and error handling")
print("")
print("Repository: https://github.com/donitono/simpleaja")
print("Load with: loadstring(game:HttpGet('https://raw.githubusercontent.com/donitono/simpleaja/main/main.lua'))()")