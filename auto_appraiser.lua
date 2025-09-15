-- Auto Appraiser Script for Fisch Game
-- Features: Filter selection, Auto appraiser toggle
-- Uses Kavo UI Library
-- Based on Fischipedia.org/wiki/Appraiser

-- HOW THE SCRIPT WORKS:
-- 1. FINDING APPRAISER: Script searches for NPC Appraiser in workspace within 50 studs
-- 2. TELEPORTATION: Automatically teleports player to nearest Appraiser NPC
-- 3. NPC INTERACTION: Initiates conversation with Appraiser using multiple methods:
--    - RemoteEvent/RemoteFunction calls
--    - ProximityPrompt interaction
--    - ClickDetector firing
--    - Virtual key presses (E, F, R, T)
-- 4. DIALOG HANDLING: Navigates through NPC conversation menu:
--    - Detects dialog GUI appearance
--    - Finds and clicks "Appraise" option
--    - Handles item selection (uses held/first item)
--    - Clicks confirmation buttons
-- 5. RESULT DETECTION: Monitors for appraisal results:
--    - Checks GUI elements for mutation names
--    - Monitors chat messages for results
--    - Compares result with target mutation filter
-- 6. AUTO LOOP: Continues until target mutation found or max attempts reached

-- APPRAISAL PROCESS IN GAME FISCH:
-- Player approaches Appraiser NPC → Initiates conversation → Selects "Appraise" option
-- → Chooses item to appraise → Pays cost → Receives result (mutation or normal)
-- Script automates this entire process!

-- Appraiser System Info:
-- Appraisers can give fish mutations/variants with different rarity chances
-- Mutation chances (Normal % / Mutation Surge %):
-- Common: Albino, Darkened, Negative (0.95% / 2.73%)
-- Uncommon: Glossy (0.79% / 2.27%), Translucent, Lunar (0.63% / 1.82%)
-- Rare: Electric, Silver, Hexed (0.47% / 1.36%), Frozen, Mosaic (0.32% / 0.91%)
-- Epic: Scorched (0.28%), Amber (0.25%), Abyssal (0.16%)
-- Legendary: Fossilized (0.13%), Midas (0.09%)
-- Mythical: Greedy, Spirit (0.05%), Mythical (0.03%)

local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/kavo.lua"))()
local Window = Kavo.CreateLib("Auto Appraiser", "Ocean")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Auto Appraiser Settings
local AutoAppraise = {
    Enabled = false,
    SelectedAppraiser = "Any", -- Default filter
    AppraiseDelay = 1, -- Delay between appraisals in seconds
    StopWhenFound = true, -- Stop when target appraiser is found
    MaxAttempts = 100, -- Maximum attempts before stopping
    CurrentAttempts = 0
}

-- Register in global cleanup system
_G.AutoAppraise = AutoAppraise
_G.FischAutoToolsCleanup = _G.FischAutoToolsCleanup or {connections = {}, flags = {}, modules = {}}

-- Appraisal Mutation Types (based on Fischipedia wiki - Appraisal Chances table)
local Appraisers = {
    "Any",
    "Albino",
    "Darkened", 
    "Negative",
    "Glossy",
    "Translucent",
    "Lunar",
    "Electric",
    "Silver",
    "Hexed",
    "Frozen",
    "Mosaic",
    "Scorched",
    "Amber",
    "Abyssal",
    "Fossilized",
    "Midas",
    "Greedy",
    "Spirit",
    "Mythical"
}

-- GUI Components
local MainTab = Window:NewTab("Auto Appraiser")
local SettingsSection = MainTab:NewSection("Settings")
local StatusSection = MainTab:NewSection("Status")

-- Functions
local function findNearestAppraiser()
    local nearestAppraiser = nil
    local shortestDistance = math.huge
    
    -- Look for Appraiser NPCs in workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("appraiser") and obj:FindFirstChild("HumanoidRootPart") then
            local distance = (HumanoidRootPart.Position - obj.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance and distance <= 50 then -- Within 50 studs
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
    -- Method 1: Try to find and fire the remote for appraiser interaction
    local remotes = ReplicatedStorage:GetDescendants()
    for _, remote in pairs(remotes) do
        -- Look for appraiser-related remotes
        if remote:IsA("RemoteEvent") then
            local remoteName = remote.Name:lower()
            if remoteName:find("apprai") or remoteName:find("npc") or remoteName:find("dialog") then
                pcall(function()
                    -- Fire remote to start conversation
                    remote:FireServer("StartConversation", appraiser)
                    wait(0.2)
                    -- Fire remote to select appraisal option
                    remote:FireServer("SelectOption", "Appraise")
                    wait(0.2)
                    -- Fire remote to confirm appraisal (usually costs money)
                    remote:FireServer("ConfirmAppraisal")
                end)
                break
            end
        elseif remote:IsA("RemoteFunction") then
            local remoteName = remote.Name:lower()
            if remoteName:find("apprai") or remoteName:find("npc") then
                pcall(function()
                    remote:InvokeServer("StartAppraisal", appraiser)
                end)
                break
            end
        end
    end
    
    -- Method 2: Try proximity prompt if exists (newer interaction system)
    local proximityPrompt = appraiser:FindFirstChildOfClass("ProximityPrompt", true)
    if proximityPrompt then
        -- Simulate proximity prompt interaction
        fireproximityprompt(proximityPrompt)
        wait(0.5)
        
        -- After proximity prompt, look for dialog GUI and interact
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            local dialogGui = playerGui:FindFirstChild("DialogGUI") or 
                             playerGui:FindFirstChild("NPCDialog") or
                             playerGui:FindFirstChild("ConversationGUI")
            
            if dialogGui then
                -- Look for appraisal option button
                local buttons = dialogGui:GetDescendants()
                for _, button in pairs(buttons) do
                    if button:IsA("TextButton") then
                        local buttonText = button.Text:lower()
                        if buttonText:find("appraise") or buttonText:find("evaluate") then
                            -- Click appraisal option
                            button.MouseButton1Click:Fire()
                            wait(0.5)
                            break
                        end
                    end
                end
                
                -- Look for confirm button after selecting appraisal
                wait(0.5)
                local confirmButtons = dialogGui:GetDescendants()
                for _, confirmBtn in pairs(confirmButtons) do
                    if confirmBtn:IsA("TextButton") then
                        local confirmText = confirmBtn.Text:lower()
                        if confirmText:find("confirm") or confirmText:find("yes") or confirmText:find("proceed") then
                            confirmBtn.MouseButton1Click:Fire()
                            break
                        end
                    end
                end
            end
        end
    end
    
    -- Method 3: Try ClickDetector (older interaction system)
    local clickDetector = appraiser:FindFirstChildOfClass("ClickDetector", true)
    if clickDetector then
        fireclickdetector(clickDetector)
    end
    
    -- Method 4: Simulate key press (if NPC uses key interaction like E, F, etc.)
    local humanoidRootPart = appraiser:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local distance = (HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
        if distance <= 10 then -- Within interaction range
            -- Try common interaction keys
            for _, key in pairs({"E", "F", "R", "T"}) do
                game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
                wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
                wait(0.2)
                
                -- Check if dialog opened
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    local dialogGui = playerGui:FindFirstChild("DialogGUI") or 
                                     playerGui:FindFirstChild("NPCDialog")
                    if dialogGui and dialogGui.Visible then
                        break -- Dialog opened successfully
                    end
                end
            end
        end
    end
end

local function handleNPCDialog()
    -- Handle NPC dialog interaction after initiating conversation
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    
    -- Wait for dialog to appear
    wait(1)
    
    -- Look for various dialog GUI names
    local dialogGUI = playerGui:FindFirstChild("DialogGUI") or 
                     playerGui:FindFirstChild("NPCDialog") or
                     playerGui:FindFirstChild("ConversationGUI") or
                     playerGui:FindFirstChild("ChatGUI") or
                     playerGui:FindFirstChild("InteractionGUI")
    
    if dialogGUI and dialogGUI.Visible then
        print("Dialog GUI found:", dialogGUI.Name)
        
        -- Look for appraisal-related options
        local buttons = dialogGUI:GetDescendants()
        for _, element in pairs(buttons) do
            if element:IsA("TextButton") or element:IsA("TextLabel") then
                local text = element.Text:lower()
                
                -- Look for appraisal options
                if text:find("appraise") or text:find("evaluate") or text:find("enhance") then
                    print("Found appraisal option:", element.Text)
                    
                    if element:IsA("TextButton") then
                        -- Click the appraisal option
                        element.MouseButton1Click:Fire()
                        wait(0.5)
                        
                        -- Look for item selection or confirmation
                        return handleAppraisalSelection()
                    end
                end
            end
        end
    end
    
    return false
end

local function handleAppraisalSelection()
    -- Handle item selection and confirmation for appraisal
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    
    wait(0.5)
    
    -- Look for item selection GUI or confirmation dialog
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Visible then
            local buttons = gui:GetDescendants()
            
            for _, button in pairs(buttons) do
                if button:IsA("TextButton") then
                    local buttonText = button.Text:lower()
                    
                    -- Look for confirmation buttons
                    if buttonText:find("confirm") or buttonText:find("yes") or 
                       buttonText:find("proceed") or buttonText:find("appraise") then
                        print("Clicking confirmation button:", button.Text)
                        button.MouseButton1Click:Fire()
                        return true
                    end
                    
                    -- Look for item selection (first item in inventory/held item)
                    if buttonText:find("select") or buttonText:find("choose") then
                        print("Selecting item:", button.Text)
                        button.MouseButton1Click:Fire()
                        wait(0.5)
                        
                        -- After selecting item, look for confirm button
                        local confirmButtons = gui:GetDescendants()
                        for _, confirmBtn in pairs(confirmButtons) do
                            if confirmBtn:IsA("TextButton") then
                                local confirmText = confirmBtn.Text:lower()
                                if confirmText:find("confirm") or confirmText:find("appraise") then
                                    confirmBtn.MouseButton1Click:Fire()
                                    return true
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return false
end
    -- Check if we got the desired appraiser type
    -- Look for appraisal result in PlayerGui
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        -- Look for GUI elements that show appraiser type
        local resultGui = playerGui:FindFirstChild("AppraisalGUI") or 
                         playerGui:FindFirstChild("ItemAppraisalGUI") or
                         playerGui:FindFirstChild("AppraisalResult") or
                         playerGui:FindFirstChild("ResultScreen")
        
        if resultGui then
            -- Extract appraiser type from GUI text
            local textLabels = resultGui:GetDescendants()
            for _, label in pairs(textLabels) do
                if label:IsA("TextLabel") or label:IsA("TextButton") then
                    local text = label.Text
                    if AutoAppraise.SelectedAppraiser ~= "Any" then
                        -- Check for exact match of mutation names
                        local mutations = {
                            "Albino", "Darkened", "Negative", "Glossy", "Translucent",
                            "Lunar", "Electric", "Silver", "Hexed", "Frozen", 
                            "Mosaic", "Scorched", "Amber", "Abyssal", "Fossilized",
                            "Midas", "Greedy", "Spirit", "Mythical"
                        }
                        
                        for _, mutationType in pairs(mutations) do
                            if text:find(mutationType) and mutationType == AutoAppraise.SelectedAppraiser then
                                return true -- Found target mutation
                            end
                        end
                    else
                        -- If "Any" is selected, any mutation counts as success
                        for _, mutationType in pairs({"Albino", "Darkened", "Negative", "Glossy", "Translucent", "Lunar", "Electric", "Silver", "Hexed", "Frozen", "Mosaic", "Scorched", "Amber", "Abyssal", "Fossilized", "Midas", "Greedy", "Spirit", "Mythical"}) do
                            if text:find(mutationType) then
                                return true
                            end
                        end
                    end
                end
            end
        end
        
        -- Alternative: Check for chat messages or other notification systems
        local chatGui = playerGui:FindFirstChild("Chat")
        if chatGui then
            -- Check recent chat messages for appraisal results
            local chatFrame = chatGui:FindFirstChild("Frame")
            if chatFrame then
                local chatChannelParentFrame = chatFrame:FindFirstChild("ChatChannelParentFrame")
                if chatChannelParentFrame then
                    local frame = chatChannelParentFrame:FindFirstChild("Frame_MessageLogDisplay")
                    if frame then
                        local scrollingFrame = frame:FindFirstChild("Scroller")
                        if scrollingFrame then
                            -- Check last few messages
                            local messages = scrollingFrame:GetChildren()
                            for i = #messages, math.max(1, #messages - 3), -1 do
                                local message = messages[i]
                                if message:IsA("Frame") then
                                    local textLabel = message:FindFirstChild("TextLabel")
                                    if textLabel then
                                        local text = textLabel.Text
                                        if AutoAppraise.SelectedAppraiser ~= "Any" then
                                            if text:find(AutoAppraise.SelectedAppraiser) then
                                                return true
                                            end
                                        else
                                            -- Check for any appraisal message
                                            if text:find("appraised") or text:find("Appraiser:") then
                                                return true
                                            end
                                        end
                                    end
                                end
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
    
    print(string.format("Auto Appraiser - Attempt %d/%d", AutoAppraise.CurrentAttempts, AutoAppraise.MaxAttempts))
    
    -- Check if we've reached max attempts
    if AutoAppraise.CurrentAttempts >= AutoAppraise.MaxAttempts then
        AutoAppraise.Enabled = false
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Appraiser";
            Text = "Max attempts reached!";
            Duration = 3;
        })
        return
    end
    
    -- Find nearest appraiser
    local appraiser = findNearestAppraiser()
    if not appraiser then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Appraiser";
            Text = "No appraiser found nearby!";
            Duration = 3;
        })
        wait(2) -- Wait before retrying
        return
    end
    
    print("Found appraiser:", appraiser.Name)
    
    -- Teleport to appraiser
    teleportToAppraiser(appraiser)
    wait(1) -- Wait for teleport to complete
    
    -- Interact with appraiser
    print("Interacting with appraiser...")
    interactWithAppraiser(appraiser)
    
    -- Handle NPC dialog
    print("Handling NPC dialog...")
    local dialogSuccess = handleNPCDialog()
    
    if not dialogSuccess then
        print("Dialog interaction failed, retrying...")
        wait(1)
        return
    end
    
    -- Wait for appraisal to process
    print("Waiting for appraisal result...")
    wait(3)
    
    -- Check if we got the desired result
    if AutoAppraise.StopWhenFound and checkAppraisalResult() then
        AutoAppraise.Enabled = false
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Appraiser";
            Text = "Target mutation found!";
            Duration = 5;
        })
        print("SUCCESS: Target mutation found!")
        return
    end
    
    print("No target mutation found, continuing...")
    
    -- Close any remaining dialog windows
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name:lower():find("dialog") then
                gui.Enabled = false
            end
        end
    end
    
    -- Wait before next attempt
    wait(AutoAppraise.AppraiseDelay)
end

-- GUI Setup
SettingsSection:NewDropdown("Mutation Filter", "Select which mutation/variant to target", Appraisers, function(selected)
    AutoAppraise.SelectedAppraiser = selected
    game.StarterGui:SetCore("SendNotification", {
        Title = "Auto Appraiser";
        Text = "Target mutation set to: " .. selected;
        Duration = 2;
    })
end)

SettingsSection:NewToggle("Auto Appraiser", "Toggle automatic appraising", function(state)
    AutoAppraise.Enabled = state
    AutoAppraise.CurrentAttempts = 0 -- Reset attempts counter
    
    if state then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Appraiser";
            Text = "Auto Appraiser Enabled!";
            Duration = 2;
        })
        
        -- Start auto appraising loop
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

SettingsSection:NewSlider("Appraise Delay", "Delay between appraisals (seconds)", 10, 0.1, function(value)
    AutoAppraise.AppraiseDelay = value
end)

SettingsSection:NewSlider("Max Attempts", "Maximum attempts before stopping", 1000, 10, function(value)
    AutoAppraise.MaxAttempts = value
end)

SettingsSection:NewToggle("Stop When Found", "Stop when target appraiser is found", function(state)
    AutoAppraise.StopWhenFound = state
end)

-- Status Section
StatusSection:NewButton("Find Nearest Appraiser", "Teleport to the nearest appraiser", function()
    local appraiser = findNearestAppraiser()
    if appraiser then
        teleportToAppraiser(appraiser)
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Appraiser";
            Text = "Teleported to nearest appraiser!";
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

StatusSection:NewButton("Reset Attempts", "Reset the attempts counter", function()
    AutoAppraise.CurrentAttempts = 0
    game.StarterGui:SetCore("SendNotification", {
        Title = "Auto Appraiser";
        Text = "Attempts counter reset!";
        Duration = 2;
    })
end)

-- Status Labels (these would need to be updated periodically)
local statusLabel = StatusSection:NewLabel("Status: Ready")
local attemptsLabel = StatusSection:NewLabel("Attempts: 0/" .. AutoAppraise.MaxAttempts)
local filterLabel = StatusSection:NewLabel("Filter: " .. AutoAppraise.SelectedAppraiser)

-- Update status labels periodically
spawn(function()
    while true do
        wait(1)
        local status = AutoAppraise.Enabled and "Running" or "Stopped"
        statusLabel:UpdateLabel("Status: " .. status)
        attemptsLabel:UpdateLabel("Attempts: " .. AutoAppraise.CurrentAttempts .. "/" .. AutoAppraise.MaxAttempts)
        filterLabel:UpdateLabel("Filter: " .. AutoAppraise.SelectedAppraiser)
    end
end)

-- Character respawn handling
local characterConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end)

-- Register connection for cleanup
_G.FischAutoToolsCleanup.connections.characterAppraiser = characterConnection

game.StarterGui:SetCore("SendNotification", {
    Title = "Auto Appraiser";
    Text = "Script loaded successfully!";
    Duration = 3;
})

print("Auto Appraiser Script Loaded!")
print("Features:")
print("- Mutation filter selection for specific fish variants")
print("- Auto appraiser toggle with On/Off functionality")
print("- Customizable delay and attempt limits")
print("- Automatic teleportation to nearest appraiser")
print("- Stop when target mutation is found")
print("- Supported mutations: Albino, Darkened, Negative, Glossy, Translucent,")
print("  Lunar, Electric, Silver, Hexed, Frozen, Mosaic, Scorched, Amber,")
print("  Abyssal, Fossilized, Midas, Greedy, Spirit, Mythical")