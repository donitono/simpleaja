-- Auto Reel Silent - Headless Version (No UI)
-- Silent instant reel system without UI
-- This version runs in background without creating UI windows

print("🤫 Loading Auto Reel Silent (Headless Mode)...")

-- Services
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local LocalPlayer = Players.LocalPlayer

-- GUI Change Detection for instant response
local function setupGUIListener()
    local playerGui = LocalPlayer.PlayerGui
    
    -- Listen for fishing GUI changes
    playerGui.ChildAdded:Connect(function(child)
        if child.Name == "FishingGUI" and isRunning then
            -- Immediate check when fishing GUI appears
            task.wait(0.01) -- Tiny delay to ensure GUI is ready
            instantReel()
        end
    end)
    
    -- Monitor existing fishing GUI
    local fishingGui = playerGui:FindFirstChild("FishingGUI")
    if fishingGui then
        fishingGui.ChildAdded:Connect(function(child)
            if isRunning and (child.Name == "Reel" or child.Name == "Shake") then
                task.wait(0.01) -- Tiny delay to ensure button is ready  
                instantReel()
            end
        end)
        
        -- Also listen for property changes
        fishingGui.DescendantAdded:Connect(function(descendant)
            if isRunning and descendant:IsA("GuiButton") and (descendant.Name == "Reel" or descendant.Name == "Shake") then
                task.wait(0.01)
                instantReel()
            end
        end)
    end
end

-- Variables
local isRunning = false
local heartbeatConnection = nil
local steppedConnection = nil
local renderSteppedConnection = nil
local settings = {
    silentMode = true,
    instantReel = true,
    autoShake = true,
    zeroAnimation = true,
    instantCast = true,   -- Speed up rod casting 5x
    fastBobber = true,    -- Eliminate arc trajectory - straight fall
    instantBobber = true, -- Skip arc completely with teleport
    maxBobberDistance = 25 -- Jarak maksimum bobber dari player
}

-- Fungsi global untuk diakses UI
_G.AutoReelHeadless = _G.AutoReelHeadless or {}
function _G.AutoReelHeadless.setMaxBobberDistance(val)
    if type(val) == "number" and val > 0 then
        settings.maxBobberDistance = val
        print("[AutoReel] Max bobber distance set to:", val)
    end
end

end

-- Instant Cast System - Speed up rod casting
local function instantCast()
    if not isRunning or not settings.instantCast then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    -- Look for fishing rod tool
    local tool = character:FindFirstChildOfClass("Tool")
    if tool and string.find(tool.Name:lower(), "rod") then
        
        -- Speed up casting animation
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                if track.Animation and track.Animation.AnimationId then
                    local animId = track.Animation.AnimationId:lower()
                    if string.find(animId, "cast") or string.find(animId, "throw") or string.find(animId, "fish") then
                        -- Speed up the casting animation
                        track.Speed = 5 -- Make casting 5x faster
                    end
                end
            end
        end
    end
end

-- Fast Bobber System - Eliminate arc trajectory and make straight fall
local function fastBobber()
    if not isRunning or not settings.fastBobber then return end
    
    -- Method 1: Use handlebobber RemoteEvent for instant control
    pcall(function()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local handlebobberEvent = replicatedStorage:FindFirstChild("shared")
        if handlebobberEvent then
            handlebobberEvent = handlebobberEvent:FindFirstChild("modules")
            if handlebobberEvent then
                handlebobberEvent = handlebobberEvent:FindFirstChild("fishing")
                if handlebobberEvent then
                    handlebobberEvent = handlebobberEvent:FindFirstChild("rodresources")
                    if handlebobberEvent then
                        handlebobberEvent = handlebobberEvent:FindFirstChild("events")
                        if handlebobberEvent then
                            handlebobberEvent = handlebobberEvent:FindFirstChild("handlebobber")
                            if handlebobberEvent then
                                -- Fire instant bobber landing
                                handlebobberEvent:FireServer("instant_land")
                                handlebobberEvent:FireServer("ready")
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- Method 2: Eliminate arc trajectory - make bobber fall straight down
    local workspace = game.Workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Bobber" or obj.Name == "FishingBobber" or string.find(obj.Name:lower(), "bobber") then
            if obj:IsA("BasePart") then
                
                -- ELIMINATE ARC: Force straight down movement
                if obj.AssemblyLinearVelocity then
                    local velocity = obj.AssemblyLinearVelocity
                    -- Remove horizontal movement, keep only straight down
                    obj.AssemblyLinearVelocity = Vector3.new(0, math.min(velocity.Y, -80), 0)
                end
                
                -- FORCE STRAIGHT TRAJECTORY: Override physics
                if obj:FindFirstChild("BodyVelocity") then
                    obj.BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                    obj.BodyVelocity.Velocity = Vector3.new(0, -120, 0) -- Pure vertical fall
                elseif not obj:FindFirstChild("BodyVelocity") then
                    -- Create BodyVelocity to force straight movement
                    local bodyVel = Instance.new("BodyVelocity")
                    bodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
                    bodyVel.Velocity = Vector3.new(0, -120, 0)
                    bodyVel.Parent = obj
                    
                    -- Auto cleanup after 2 seconds
                    game:GetService("Debris"):AddItem(bodyVel, 2)
                end
                
                -- DISABLE ARC PHYSICS: Remove position constraints
                if obj:FindFirstChild("BodyPosition") then
                    obj.BodyPosition.MaxForce = Vector3.new(0, 0, 0)
                end
                
                -- INSTANT TELEPORT: Skip arc completely if bobber is above water
                if settings.instantBobber and obj.Position.Y > 10 then
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local lookVec = character.HumanoidRootPart.CFrame.LookVector
                        local maxDist = settings.maxBobberDistance or 25
                        local targetPos = character.HumanoidRootPart.Position + lookVec * maxDist
                        obj.CFrame = CFrame.new(targetPos.X, 5, targetPos.Z) -- Teleport ke jarak maksimum
                        -- Force immediate water landing velocity
                        obj.AssemblyLinearVelocity = Vector3.new(0, -10, 0)
                    end
                end
            end
        end
    end
end

-- Block fishing animations aggressively
local function blockAnimations()
    if not settings.zeroAnimation then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Stop all animations
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.Animation.AnimationId then
            local animId = track.Animation.AnimationId
            if string.find(animId, "fish") or string.find(animId, "reel") or string.find(animId, "cast") then
                track:Stop()
            end
        end
    end
end

-- Instant reel function - High Priority
local function instantReel()
    if not isRunning or not settings.instantReel then return end
    
    -- Look for fishing GUI with multiple attempts
    local playerGui = LocalPlayer.PlayerGui
    local fishingGui = playerGui:FindFirstChild("FishingGUI")
    
    if fishingGui then
        -- Priority 1: Reel button (most important)
        local reelButton = fishingGui:FindFirstChild("Reel")
        if reelButton and reelButton.Visible and reelButton.AbsoluteSize.X > 0 then
            -- Multiple fire methods for maximum reliability
            if settings.silentMode then
                pcall(function()
                    firesignal(reelButton.Activated)
                    firesignal(reelButton.MouseButton1Click)
                end)
            else
                pcall(function()
                    reelButton:TriggerEvent("MouseClick")
                    firesignal(reelButton.Activated)
                end)
            end
            return -- Exit early after successful reel
        end
        
        -- Priority 2: Auto shake handling
        if settings.autoShake then
            local shakeButton = fishingGui:FindFirstChild("Shake")
            if shakeButton and shakeButton.Visible and shakeButton.AbsoluteSize.X > 0 then
                pcall(function()
                    firesignal(shakeButton.Activated)
                    firesignal(shakeButton.MouseButton1Click)
                end)
            end
        end
    end
    
    -- Also check for any fishing-related RemoteEvents
    pcall(function()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        
        -- Method 1: Standard shared events
        local events = replicatedStorage:FindFirstChild("shared")
        if events then
            events = events:FindFirstChild("modules")
            if events then
                events = events:FindFirstChild("fishing")
                if events then
                    events = events:FindFirstChild("rodresources")
                    if events then
                        events = events:FindFirstChild("events")
                        if events then
                            -- Use handlebobber for instant reel
                            local handlebobberEvent = events:FindFirstChild("handlebobber")
                            if handlebobberEvent then
                                handlebobberEvent:FireServer("reel")
                            end
                            
                            -- Also try direct reel events
                            local reelEvent = events:FindFirstChild("reel")
                            if reelEvent then
                                reelEvent:FireServer()
                            end
                        end
                    end
                end
            end
        end
        
        -- Method 2: Player-specific rod events (from dump analysis)
        local character = LocalPlayer.Character
        if character then
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") and string.find(tool.Name:lower(), "rod") then
                    local rodEvents = tool:FindFirstChild("events")
                    if rodEvents then
                        local handlebobber = rodEvents:FindFirstChild("handlebobber")
                        if handlebobber then
                            handlebobber:FireServer("instant_reel")
                        end
                        
                        local catchfinish = rodEvents:FindFirstChild("catchfinish")
                        if catchfinish then
                            catchfinish:FireServer()
                        end
                    end
                end
            end
        end
        
        -- Method 3: Backpack rod events
        local backpack = LocalPlayer.Backpack
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and string.find(tool.Name:lower(), "rod") then
                    local rodEvents = tool:FindFirstChild("events")
                    if rodEvents then
                        local handlebobber = rodEvents:FindFirstChild("handlebobber")
                        if handlebobber then
                            handlebobber:FireServer("instant_reel")
                        end
                    end
                end
            end
        end
    end)
end

-- Main auto reel loop with maximum responsiveness
local function startAutoReel()
    if heartbeatConnection then heartbeatConnection:Disconnect() end
    if steppedConnection then steppedConnection:Disconnect() end  
    if renderSteppedConnection then renderSteppedConnection:Disconnect() end
    
    isRunning = true
    
    -- Setup GUI listeners for instant response
    setupGUIListener()
    
    -- Multiple connections for maximum responsiveness
    -- 1. RenderStepped - Highest priority (60+ FPS)
    renderSteppedConnection = RunService.RenderStepped:Connect(function()
        if isRunning then
            instantReel() -- Check for reel with highest priority
        end
    end)
    
    -- 2. Heartbeat - Medium priority (~30 FPS)
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if isRunning then
            blockAnimations() -- Block animations
            instantReel() -- Double check for reel
            instantCast() -- Speed up casting
            fastBobber() -- Accelerate bobber
        end
    end)
    
    -- 3. Stepped - Physics step (~60 FPS)
    steppedConnection = RunService.Stepped:Connect(function()
        if isRunning then
            instantReel() -- Triple check for reel
            fastBobber() -- Keep accelerating bobber
        end
    end)
    
    print("✅ Auto Reel Silent started (Ultra Fast Mode)")
end

local function stopAutoReel()
    print("🛑 Stopping Auto Reel Silent...")
    
    -- Set running flag to false first
    isRunning = false
    
    -- Disconnect all known connections
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
        print("🔌 Heartbeat connection disconnected")
    end
    if steppedConnection then
        steppedConnection:Disconnect()
        steppedConnection = nil
        print("🔌 Stepped connection disconnected")
    end
    if renderSteppedConnection then
        renderSteppedConnection:Disconnect()
        renderSteppedConnection = nil
        print("🔌 RenderStepped connection disconnected")
    end
    
    -- Force disconnect any suspicious connections (aggressive cleanup)
    pcall(function()
        local RunService = game:GetService("RunService")
        
        -- Check all Heartbeat connections
        for _, connection in pairs(getconnections(RunService.Heartbeat)) do
            if connection.Function then
                local funcStr = tostring(connection.Function)
                if string.find(funcStr:lower(), "instantreel") or 
                   string.find(funcStr:lower(), "fastbobber") or
                   string.find(funcStr:lower(), "blockanimations") then
                    connection:Disconnect()
                    print("🔌 Force disconnected suspicious Heartbeat")
                end
            end
        end
        
        -- Check all RenderStepped connections
        for _, connection in pairs(getconnections(RunService.RenderStepped)) do
            if connection.Function then
                local funcStr = tostring(connection.Function)
                if string.find(funcStr:lower(), "instantreel") or 
                   string.find(funcStr:lower(), "fastbobber") then
                    connection:Disconnect()
                    print("🔌 Force disconnected suspicious RenderStepped")
                end
            end
        end
        
        -- Check all Stepped connections
        for _, connection in pairs(getconnections(RunService.Stepped)) do
            if connection.Function then
                local funcStr = tostring(connection.Function)
                if string.find(funcStr:lower(), "instantreel") or 
                   string.find(funcStr:lower(), "fastbobber") then
                    connection:Disconnect()
                    print("🔌 Force disconnected suspicious Stepped")
                end
            end
        end
    end)
    
    -- Also disconnect GUI listeners
    pcall(function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local PlayerGui = LocalPlayer.PlayerGui
        
        for _, connection in pairs(getconnections(PlayerGui.ChildAdded)) do
            if connection.Function then
                local funcStr = tostring(connection.Function)
                if string.find(funcStr:lower(), "fishinggui") or
                   string.find(funcStr:lower(), "instantreel") then
                    connection:Disconnect()
                    print("🔌 Force disconnected GUI listener")
                end
            end
        end
    end)
    
    print("⏸️ Auto Reel Silent stopped completely!")
end

-- DON'T start immediately - wait for user control

-- Global functions for external control
_G.AutoReelHeadless = {
    start = function()
        startAutoReel()
    end,
    
    stop = function()
        stopAutoReel()
    end,
    
    toggle = function()
        if isRunning then
            stopAutoReel()
        else
            startAutoReel()
        end
    end,
    
    setSilentMode = function(enabled)
        settings.silentMode = enabled
        print("👻 Silent mode " .. (enabled and "enabled" or "disabled"))
    end,
    
    setInstantReel = function(enabled)
        settings.instantReel = enabled
        print("⚡ Instant reel " .. (enabled and "enabled" or "disabled"))
    end,
    
    setAutoShake = function(enabled)
        settings.autoShake = enabled
        print("🎣 Auto shake " .. (enabled and "enabled" or "disabled"))
    end,
    
    setZeroAnimation = function(enabled)
        settings.zeroAnimation = enabled
        print("🚫 Zero animation " .. (enabled and "enabled" or "disabled"))
    end,
    
    setInstantCast = function(enabled)
        settings.instantCast = enabled
        print("🚀 Instant cast " .. (enabled and "enabled" or "disabled"))
    end,
    
    setFastBobber = function(enabled)
        settings.fastBobber = enabled
        print("💨 Fast bobber " .. (enabled and "enabled" or "disabled"))
    end,
    
    getSettings = function()
        return settings
    end,
    
    isRunning = function()
        return isRunning
    end
}

print("🤫 Auto Reel Silent (Headless) loaded successfully!")