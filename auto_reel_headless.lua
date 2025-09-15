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
    isRunning = true
    
    -- Animation blocking loop
    RunService.Heartbeat:Connect(function()
        if isRunning then
            blockAnimations()
            instantReel()
        end
    end)
    
    print("✅ Auto Reel Silent started (Headless Mode)")
end

-- Start immediately
startAutoReel()

-- Global functions for external control
_G.AutoReelHeadless = {
    start = function()
        isRunning = true
        print("🤫 Auto Reel Silent resumed")
    end,
    
    stop = function()
        isRunning = false
        print("⏸️ Auto Reel Silent paused")
    end,
    
    toggle = function()
        isRunning = not isRunning
        print("🔄 Auto Reel Silent " .. (isRunning and "started" or "stopped"))
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