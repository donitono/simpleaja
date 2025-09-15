-- Auto Reel Silent - Headless Version (No UI)
-- Silent instant reel system without UI
-- This version runs in background without creating UI windows

print("🤫 Loading Auto Reel Silent (Headless Mode)...")

-- Services
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local LocalPlayer = Players.LocalPlayer

-- Variables
local isRunning = false
local heartbeatConnection = nil
local settings = {
    silentMode = true,
    instantReel = true,
    autoShake = true,
    zeroAnimation = true
}

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

-- Instant reel function
local function instantReel()
    if not isRunning or not settings.instantReel then return end
    
    -- Look for fishing GUI
    local playerGui = LocalPlayer.PlayerGui
    local fishingGui = playerGui:FindFirstChild("FishingGUI")
    
    if fishingGui then
        local reelButton = fishingGui:FindFirstChild("Reel")
        if reelButton and reelButton.Visible then
            -- Silent mode - fire without visual feedback
            if settings.silentMode then
                firesignal(reelButton.Activated)
            else
                reelButton:TriggerEvent("MouseClick")
            end
        end
        
        -- Auto shake handling
        if settings.autoShake then
            local shakeButton = fishingGui:FindFirstChild("Shake")
            if shakeButton and shakeButton.Visible then
                firesignal(shakeButton.Activated)
            end
        end
    end
end

-- Main auto reel loop
local function startAutoReel()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
    end
    
    isRunning = true
    
    -- Animation blocking loop
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if isRunning then
            blockAnimations()
            instantReel()
        end
    end)
    
    print("✅ Auto Reel Silent started (Headless Mode)")
end

local function stopAutoReel()
    isRunning = false
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    print("⏸️ Auto Reel Silent stopped (Headless Mode)")
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
    
    getSettings = function()
        return settings
    end,
    
    isRunning = function()
        return isRunning
    end
}

print("🤫 Auto Reel Silent (Headless) loaded successfully!")