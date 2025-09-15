-- Main Loader for Fisch Auto Tools
-- Loads Auto Appraiser and Auto Reel Silent as separate modules
-- Author: donitono
-- Repository: https://github.com/donitono/simpleaja

-- Loading notification
game.StarterGui:SetCore("SendNotification", {
    Title = "Fisch Auto Tools";
    Text = "Loading modules... Please wait";
    Duration = 3;
})

print("🎣 Loading Fisch Auto Tools...")

-- Load Kavo UI Library first
print("📚 Loading Kavo UI Library...")
local success1, kavo = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/kavo.lua"))()
end)

if not success1 then
    warn("❌ Failed to load Kavo UI Library:", kavo)
    return
end

-- Create main window
local Window = kavo.CreateLib("🎣 Fisch Auto Tools", "Ocean")

-- Create tabs for each module
local LoaderTab = Window:NewTab("📦 Module Loader")
local LoaderSection = LoaderTab:NewSection("Available Modules")
local StatusSection = LoaderTab:NewSection("Module Status")
local ExitSection = LoaderTab:NewSection("🚨 Safety Exit")

-- Module status tracking
local moduleStatus = {
    autoAppraiser = false,
    autoReelSilent = false,
    isExiting = false  -- NEW: Exit status flag
}

-- Global cleanup functions storage
_G.FischAutoToolsCleanup = _G.FischAutoToolsCleanup or {
    connections = {},
    flags = {},
    modules = {}
}

-- Load Auto Appraiser Module
LoaderSection:NewButton("🎯 Load Auto Appraiser", "Load mutation filtering and auto appraisal module", function()
    if moduleStatus.autoAppraiser then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Module Loader";
            Text = "⚠️ Auto Appraiser already loaded!";
            Duration = 2;
        })
        return
    end
    
    print("🎯 Loading Auto Appraiser module...")
    game.StarterGui:SetCore("SendNotification", {
        Title = "Module Loader";
        Text = "Loading Auto Appraiser...";
        Duration = 2;
    })
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_appraiser.lua"))()
    end)
    
    if success then
        moduleStatus.autoAppraiser = true
        -- Register module for cleanup
        _G.FischAutoToolsCleanup.modules.autoAppraiser = true
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Appraiser";
            Text = "✅ Module loaded successfully!";
            Duration = 3;
        })
        print("✅ Auto Appraiser module loaded!")
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Module Loader";
            Text = "❌ Failed to load Auto Appraiser";
            Duration = 3;
        })
        warn("❌ Failed to load Auto Appraiser:", result)
    end
end)

-- Load Auto Reel Silent Module
LoaderSection:NewButton("🤫 Load Auto Reel Silent", "Load silent instant reel and normal auto reel module", function()
    if moduleStatus.autoReelSilent then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Module Loader";
            Text = "⚠️ Auto Reel Silent already loaded!";
            Duration = 2;
        })
        return
    end
    
    print("🤫 Loading Auto Reel Silent module...")
    game.StarterGui:SetCore("SendNotification", {
        Title = "Module Loader";
        Text = "Loading Auto Reel Silent...";
        Duration = 2;
    })
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_reel_instant.lua"))()
    end)
    
    if success then
        moduleStatus.autoReelSilent = true
        -- Register module for cleanup
        _G.FischAutoToolsCleanup.modules.autoReelSilent = true
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Reel Silent";
            Text = "✅ Module loaded successfully!";
            Duration = 3;
        })
        print("✅ Auto Reel Silent module loaded!")
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Module Loader";
            Text = "❌ Failed to load Auto Reel Silent";
            Duration = 3;
        })
        warn("❌ Failed to load Auto Reel Silent:", result)
    end
end)

-- Load All Modules at Once
LoaderSection:NewButton("🚀 Load All Modules", "Load both Auto Appraiser and Auto Reel Silent", function()
    print("🚀 Loading all modules...")
    game.StarterGui:SetCore("SendNotification", {
        Title = "Module Loader";
        Text = "Loading all modules...";
        Duration = 2;
    })
    
    -- Load Auto Appraiser if not loaded
    if not moduleStatus.autoAppraiser then
        local success1, result1 = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_appraiser.lua"))()
        end)
        
        if success1 then
            moduleStatus.autoAppraiser = true
            _G.FischAutoToolsCleanup.modules.autoAppraiser = true
            print("✅ Auto Appraiser loaded!")
        else
            warn("❌ Failed to load Auto Appraiser:", result1)
        end
    end
    
    -- Load Auto Reel Silent if not loaded
    if not moduleStatus.autoReelSilent then
        wait(0.5) -- Small delay between loads
        local success2, result2 = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_reel_instant.lua"))()
        end)
        
        if success2 then
            moduleStatus.autoReelSilent = true
            _G.FischAutoToolsCleanup.modules.autoReelSilent = true
            print("✅ Auto Reel Silent loaded!")
        else
            warn("❌ Failed to load Auto Reel Silent:", result2)
        end
    end
    
    -- Final status
    local loadedCount = 0
    if moduleStatus.autoAppraiser then loadedCount = loadedCount + 1 end
    if moduleStatus.autoReelSilent then loadedCount = loadedCount + 1 end
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Module Loader";
        Text = string.format("✅ %d/2 modules loaded successfully!", loadedCount);
        Duration = 3;
    })
end)

-- ======================================================================================
-- SAFE EXIT SYSTEM
-- ======================================================================================

-- Global cleanup function to disable all modules safely
local function performSafeExit()
    if moduleStatus.isExiting then
        return -- Prevent multiple exit calls
    end
    
    moduleStatus.isExiting = true
    
    print("🚨 [SAFE EXIT] Initiating safe shutdown...")
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Safe Exit";
        Text = "🚨 Shutting down all modules safely...";
        Duration = 3;
    })
    
    -- Step 1: Disable all module flags via global variables
    pcall(function()
        if _G.AutoAppraise then
            _G.AutoAppraise.Enabled = false
        end
        
        if _G.flags then
            _G.flags['autoreel'] = false
            _G.flags['superinstantsilent'] = false
            _G.flags['instantbobber'] = false
        end
        
        -- Disable any flags that might exist
        if flags then
            flags['autoreel'] = false
            flags['superinstantsilent'] = false
            flags['instantbobber'] = false
        end
        
        print("✅ [SAFE EXIT] All module flags disabled")
    end)
    
    -- Step 2: Disconnect all connections
    pcall(function()
        if _G.FischAutoToolsCleanup and _G.FischAutoToolsCleanup.connections then
            for name, connection in pairs(_G.FischAutoToolsCleanup.connections) do
                if connection and typeof(connection) == "RBXScriptConnection" then
                    connection:Disconnect()
                    print("🔌 [SAFE EXIT] Disconnected:", name)
                end
            end
            _G.FischAutoToolsCleanup.connections = {}
        end
        
        print("✅ [SAFE EXIT] All connections disconnected")
    end)
    
    -- Step 3: Stop all running loops/threads
    pcall(function()
        -- Force disable any running auto appraiser loops
        if _G.AutoAppraise then
            _G.AutoAppraise.Enabled = false
            _G.AutoAppraise.CurrentAttempts = 999999 -- Force stop
        end
        
        -- Force stop any running reel monitoring
        if _G.lureMonitorConnection then
            _G.lureMonitorConnection:Disconnect()
            _G.lureMonitorConnection = nil
        end
        
        if _G.superInstantReelActive then
            _G.superInstantReelActive = false
        end
        
        print("✅ [SAFE EXIT] All loops and threads stopped")
    end)
    
    -- Step 4: Clear any GUI elements that might be active
    pcall(function()
        local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            -- Remove any reel GUIs that might be stuck
            local reelGui = playerGui:FindFirstChild("reel")
            if reelGui then
                reelGui:Destroy()
            end
            
            -- Remove any shake GUIs
            local shakeGui = playerGui:FindFirstChild("shakeui")
            if shakeGui then
                shakeGui:Destroy()
            end
        end
        
        print("✅ [SAFE EXIT] GUI elements cleared")
    end)
    
    -- Step 5: Reset character animations
    pcall(function()
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            
            -- Stop all playing animations
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:Stop()
            end
            
            -- Reset humanoid state
            humanoid.PlatformStand = false
            humanoid.Sit = false
        end
        
        print("✅ [SAFE EXIT] Character animations reset")
    end)
    
    -- Step 6: Update module status
    moduleStatus.autoAppraiser = false
    moduleStatus.autoReelSilent = false
    
    -- Step 7: Clear global cleanup registry
    pcall(function()
        _G.FischAutoToolsCleanup = {
            connections = {},
            flags = {},
            modules = {}
        }
    end)
    
    -- Final notification
    game.StarterGui:SetCore("SendNotification", {
        Title = "Safe Exit";
        Text = "✅ All modules safely disabled! You can close the GUI now.";
        Duration = 5;
    })
    
    print("✅ [SAFE EXIT] Complete! All systems safely shut down.")
    print("🔒 Safe to close executor or leave game.")
    
    -- Wait a bit then reset exit flag
    wait(2)
    moduleStatus.isExiting = false
end

-- Emergency exit function (more aggressive)
local function performEmergencyExit()
    print("🚨 [EMERGENCY EXIT] Performing emergency shutdown...")
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Emergency Exit";
        Text = "🚨 EMERGENCY SHUTDOWN in progress...";
        Duration = 4;
    })
    
    -- Aggressively disable everything
    pcall(function()
        -- Disable all global variables
        for key, value in pairs(_G) do
            if type(key) == "string" then
                if key:lower():find("auto") or key:lower():find("reel") or key:lower():find("apprai") then
                    if type(value) == "table" then
                        for subkey, subvalue in pairs(value) do
                            if type(subkey) == "string" and subkey:lower():find("enable") then
                                value[subkey] = false
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- Disconnect ALL connections in the game
    pcall(function()
        for _, connection in pairs(getconnections(game.Players.LocalPlayer.PlayerGui.ChildAdded)) do
            connection:Disconnect()
        end
        
        for _, connection in pairs(getconnections(game:GetService("RunService").Heartbeat)) do
            if connection.Function and tostring(connection.Function):find("auto") then
                connection:Disconnect()
            end
        end
    end)
    
    -- Reset character completely
    pcall(function()
        local character = game.Players.LocalPlayer.Character
        if character then
            character:FindFirstChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Physics)
            wait(0.1)
            character:FindFirstChild("Humanoid"):ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
    end)
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Emergency Exit";
        Text = "🔒 EMERGENCY SHUTDOWN COMPLETE!";
        Duration = 5;
    })
    
    print("🔒 [EMERGENCY EXIT] Complete! All systems forcefully shut down.")
end

-- Module Information Section
local InfoSection = LoaderTab:NewSection("Module Information")

InfoSection:NewLabel("🎯 Auto Appraiser:")
InfoSection:NewLabel("• Mutation filtering (Albino, Midas, etc.)")
InfoSection:NewLabel("• Auto teleport to appraiser NPC")
InfoSection:NewLabel("• Automatic interaction & confirmation")
InfoSection:NewLabel("• Stop when target mutation found")

InfoSection:NewLabel("")
InfoSection:NewLabel("🤫 Auto Reel Silent:")
InfoSection:NewLabel("• Normal auto reel with animations")
InfoSection:NewLabel("• Silent instant reel (ghost mode)")
InfoSection:NewLabel("• Zero movement fishing")
InfoSection:NewLabel("• Instant catch without delays")

InfoSection:NewLabel("")
InfoSection:NewLabel("📦 Benefits of separate modules:")
InfoSection:NewLabel("• Load only what you need")
InfoSection:NewLabel("• Easy updates without re-downloading")
InfoSection:NewLabel("• Better performance & memory usage")
InfoSection:NewLabel("• Independent module management")

-- Status Labels (Updated real-time)
local appraiserStatusLabel = StatusSection:NewLabel("Auto Appraiser: Not Loaded")
local reelStatusLabel = StatusSection:NewLabel("Auto Reel Silent: Not Loaded")

-- URLs for manual loading
local UrlSection = LoaderTab:NewSection("Manual URLs")
UrlSection:NewLabel("🔗 Manual Loading URLs:")
UrlSection:NewLabel("Auto Appraiser:")
UrlSection:NewLabel("loadstring(game:HttpGet(")
UrlSection:NewLabel("'https://raw.githubusercontent.com/donitono/")
UrlSection:NewLabel("simpleaja/main/auto_appraiser.lua'))()")
UrlSection:NewLabel("")
UrlSection:NewLabel("Auto Reel Silent:")
UrlSection:NewLabel("loadstring(game:HttpGet(")
UrlSection:NewLabel("'https://raw.githubusercontent.com/donitono/")
UrlSection:NewLabel("simpleaja/main/auto_reel_instant.lua'))()")

-- ======================================================================================
-- SAFE EXIT BUTTONS
-- ======================================================================================

-- Safe Exit Button
ExitSection:NewButton("🔒 Safe Exit", "Safely disable all modules and scripts", function()
    -- Confirmation dialog simulation
    game.StarterGui:SetCore("SendNotification", {
        Title = "Safe Exit";
        Text = "⚠️ This will disable ALL modules. Click again to confirm.";
        Duration = 3;
    })
    
    -- Wait for confirmation (second click within 5 seconds)
    local confirmTime = tick()
    local confirmed = false
    
    -- Create temporary confirmation button
    local confirmButton = ExitSection:NewButton("✅ CONFIRM Safe Exit", "Click to confirm safe exit", function()
        if tick() - confirmTime <= 5 then -- 5 second window
            confirmed = true
            performSafeExit()
        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "Safe Exit";
                Text = "❌ Confirmation timeout. Try again.";
                Duration = 2;
            })
        end
    end)
    
    -- Remove confirmation button after 5 seconds
    wait(5)
    if not confirmed then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Safe Exit";
            Text = "❌ Safe exit cancelled (timeout)";
            Duration = 2;
        })
    end
end)

-- Emergency Exit Button
ExitSection:NewButton("🚨 Emergency Exit", "FORCE shutdown all scripts (use if safe exit fails)", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Emergency Exit";
        Text = "⚠️ EMERGENCY MODE! Click EMERGENCY CONFIRM to proceed.";
        Duration = 4;
    })
    
    -- Emergency confirmation
    local emergencyConfirmButton = ExitSection:NewButton("💀 EMERGENCY CONFIRM", "FORCE shutdown everything NOW", function()
        performEmergencyExit()
    end)
    
    wait(3)
    -- Auto-remove emergency button after 3 seconds to prevent accidents
end)

-- Exit Status Display
local exitStatusLabel = ExitSection:NewLabel("Exit Status: Ready")

-- Module Status Display
ExitSection:NewLabel("⚠️ BEFORE EXITING:")
ExitSection:NewLabel("• Safe Exit: Gracefully stops all modules")
ExitSection:NewLabel("• Emergency Exit: Force stops everything")
ExitSection:NewLabel("• Always use Safe Exit first")
ExitSection:NewLabel("• Emergency only if Safe Exit fails")

-- Status update loop
task.spawn(function()
    while true do
        wait(2)
        
        local appraiserStatus = moduleStatus.autoAppraiser and "✅ Loaded" or "❌ Not Loaded"
        local reelStatus = moduleStatus.autoReelSilent and "✅ Loaded" or "❌ Not Loaded"
        
        appraiserStatusLabel:UpdateLabel("Auto Appraiser: " .. appraiserStatus)
        reelStatusLabel:UpdateLabel("Auto Reel Silent: " .. reelStatus)
        
        -- Update exit status
        local exitStatus = "Ready"
        if moduleStatus.isExiting then
            exitStatus = "🚨 Exiting..."
        elseif moduleStatus.autoAppraiser or moduleStatus.autoReelSilent then
            exitStatus = "⚠️ Modules Active"
        end
        exitStatusLabel:UpdateLabel("Exit Status: " .. exitStatus)
    end
end)

-- Success notification
game.StarterGui:SetCore("SendNotification", {
    Title = "Fisch Auto Tools";
    Text = "✅ Main loader ready! Load modules as needed";
    Duration = 3;
})

print("✅ Fisch Auto Tools Main Loader ready!")
print("")
print("📦 Available Modules:")
print("• 🎯 Auto Appraiser - Mutation filtering & auto appraisal")
print("• 🤫 Auto Reel Silent - Ghost mode fishing & normal auto reel")
print("")
print("🚀 Quick Load Command:")
print("loadstring(game:HttpGet('https://raw.githubusercontent.com/donitono/simpleaja/main/main.lua'))()")
print("")
print("🔧 Individual Module Updates:")
print("Each module can be updated independently without affecting others")
print("Repository: https://github.com/donitono/simpleaja")