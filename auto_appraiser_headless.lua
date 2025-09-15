-- Auto Appraiser - Headless Version (No UI)
-- Automatic fish/rod appraisal with mutation filtering
-- This version runs in background without creating UI windows

print("🎯 Loading Auto Appraiser (Headless Mode)...")

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Variables
local isRunning = false
local heartbeatConnection = nil
local settings = {
    filterMutations = true,
    autoTeleport = true,
    smartDialog = true
}

-- Mutation list based on Fischipedia wiki
local mutations = {
    "Albino", "Midas", "Shiny", "Golden", "Diamond",
    "Prismarine", "Frozen", "Electric", "Ghastly", 
    "Mosaic", "Glossy", "Translucent", "Negative",
    "Lunar", "Solar", "Hexed", "Atlantean", 
    "Abyssal", "Mythical"
}

-- Create mutation lookup table for faster checking
local mutationSet = {}
for _, mutation in ipairs(mutations) do
    mutationSet[mutation] = true
end

-- Helper function to check if item has desired mutation
local function hasMutation(itemName)
    if not settings.filterMutations then return true end
    
    for mutation in pairs(mutationSet) do
        if string.find(itemName, mutation) then
            return true
        end
    end
    return false
end

-- Helper function to find appraiser NPC
local function findAppraiserNPC()
    local npcs = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Advanced Appraiser" then
            table.insert(npcs, obj)
        end
    end
    
    return #npcs > 0 and npcs[1] or nil
end

-- Helper function to teleport to NPC
local function teleportToNPC(npc)
    if not settings.autoTeleport then return false end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local npcPrimaryPart = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
    if not npcPrimaryPart then return false end
    
    character.HumanoidRootPart.CFrame = npcPrimaryPart.CFrame * CFrame.new(0, 0, -5)
    return true
end

-- Helper function to handle dialog
local function handleDialog()
    if not settings.smartDialog then return end
    
    local gui = LocalPlayer.PlayerGui:FindFirstChild("DialogChoiceUI")
    if gui then
        local button = gui:FindFirstChild("Middle"):FindFirstChild("TextButton")
        if button then
            button.Text = "Appraise"
            firesignal(button.Activated)
            return true
        end
    end
    return false
end

-- Main appraisal function
local function performAppraisal()
    if not isRunning then return end
    
    local backpack = LocalPlayer.Backpack
    local character = LocalPlayer.Character
    
    -- Check backpack for items to appraise
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and hasMutation(tool.Name) then
            local npc = findAppraiserNPC()
            if npc then
                teleportToNPC(npc)
                
                -- Equip tool
                tool.Parent = character
                wait(0.5)
                
                -- Fire appraisal event
                local appraiseEvent = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("Appraiser")
                if appraiseEvent then
                    appraiseEvent:FireServer()
                end
                
                -- Handle any dialog
                wait(1)
                handleDialog()
                
                -- Unequip tool
                tool.Parent = backpack
                wait(1)
            end
        end
    end
end

-- Auto appraiser loop
local function startAutoAppraiser()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
    end
    
    isRunning = true
    
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if isRunning then
            performAppraisal()
        end
    end)
    
    print("✅ Auto Appraiser started (Headless Mode)")
end

local function stopAutoAppraiser()
    isRunning = false
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    print("⏸️ Auto Appraiser stopped (Headless Mode)")
end

-- DON'T start immediately - wait for user control

-- Global functions for external control
_G.AutoAppraiserHeadless = {
    start = function()
        startAutoAppraiser()
    end,
    
    stop = function()
        stopAutoAppraiser()
    end,
    
    toggle = function()
        if isRunning then
            stopAutoAppraiser()
        else
            startAutoAppraiser()
        end
    end,
    
    setFilterMutations = function(enabled)
        settings.filterMutations = enabled
        print("🎯 Mutation filtering " .. (enabled and "enabled" or "disabled"))
    end,
    
    setAutoTeleport = function(enabled)
        settings.autoTeleport = enabled
        print("🚀 Auto teleport " .. (enabled and "enabled" or "disabled"))
    end,
    
    setSmartDialog = function(enabled)
        settings.smartDialog = enabled
        print("💬 Smart dialog " .. (enabled and "enabled" or "disabled"))
    end,
    
    getSettings = function()
        return settings
    end,
    
    isRunning = function()
        return isRunning
    end
}

print("🎯 Auto Appraiser (Headless) loaded successfully!")