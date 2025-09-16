-- Fisch Auto Tools - Clean Interface
-- Auto-loading both Auto Appraiser and Auto Reel Silent
-- Author: donitono
-- Repository: https://github.com/donitono/simpleaja

-- Load Kavo UI Library
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/kavo.lua"))()
local Window = Kavo.CreateLib("🎣 Fisch Auto Tools", "Ocean")

-- Auto-load both modules immediately (Headless versions)
task.spawn(function()
    -- Load Auto Appraiser (Headless - No UI)
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_appraiser_headless.lua"))()
    end)
    
    -- Load Auto Reel Silent (Headless - No UI)
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_reel_headless.lua"))()
    end)
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Fisch Auto Tools";
        Text = "� Modules loaded! Use toggles to start.";
        Duration = 3;
    })
end)

-- Create clean interface tabs
local AppraiserTab = Window:NewTab("🎯 Auto Appraiser")
local ReelTab = Window:NewTab("🤫 Auto Reel")
local StatusTab = Window:NewTab("📊 Status")
local SettingsTab = Window:NewTab("⚙️ Settings")

-- Auto Appraiser Tab Content
local AppraiserSection = AppraiserTab:NewSection("Auto Appraiser Controls")

AppraiserSection:NewLabel("⚠️ Module loaded but NOT running")
AppraiserSection:NewLabel("👆 Use toggle below to start")
AppraiserSection:NewLabel("")

AppraiserSection:NewToggle("🎯 Enable Auto Appraiser", "Toggle automatic fish/rod appraisal", function(state)
    if _G.AutoAppraiserHeadless then
        if state then
            _G.AutoAppraiserHeadless.start()
        else
            _G.AutoAppraiserHeadless.stop()
        end
    end
end)

AppraiserSection:NewToggle("🔍 Filter Mutations Only", "Only appraise items with mutations", function(state)
    if _G.AutoAppraiserHeadless then
        _G.AutoAppraiserHeadless.setFilterMutations(state)
    end
end)

AppraiserSection:NewToggle("🚀 Auto Teleport to NPC", "Automatically teleport to appraiser", function(state)
    if _G.AutoAppraiserHeadless then
        _G.AutoAppraiserHeadless.setAutoTeleport(state)
    end
end)

AppraiserSection:NewToggle("💬 Smart Dialog Handling", "Automatically handle NPC dialogs", function(state)
    if _G.AutoAppraiserHeadless then
        _G.AutoAppraiserHeadless.setSmartDialog(state)
    end
end)

local AppraiserInfoSection = AppraiserTab:NewSection("Mutation Information")
AppraiserInfoSection:NewLabel("📝 Supported mutations:")
AppraiserInfoSection:NewLabel("Albino, Midas, Shiny, Golden, Diamond,")
AppraiserInfoSection:NewLabel("Prismarine, Frozen, Electric, Ghastly,")
AppraiserInfoSection:NewLabel("Mosaic, Glossy, Translucent, Negative,")
AppraiserInfoSection:NewLabel("Lunar, Solar, Hexed, Atlantean,")
AppraiserInfoSection:NewLabel("Abyssal, Mythical")

-- Auto Reel Tab Content  
local ReelSection = ReelTab:NewSection("Auto Reel Controls")

ReelSection:NewLabel("⚠️ Module loaded but NOT running")
ReelSection:NewLabel("👆 Use toggle below to start")
ReelSection:NewLabel("")

ReelSection:NewToggle("🤫 Enable Auto Reel Silent", "Toggle silent instant fishing", function(state)
    if _G.AutoReelHeadless then
        if state then
            _G.AutoReelHeadless.start()
        else
            _G.AutoReelHeadless.stop()
        end
    end
end)

ReelSection:NewToggle("👻 Silent Mode", "Enable ghost mode (no visual feedback)", function(state)
    if _G.AutoReelHeadless then
        _G.AutoReelHeadless.setSilentMode(state)
    end
end)

ReelSection:NewToggle("⚡ Instant Reel", "Enable instant fishing", function(state)
    if _G.AutoReelHeadless then
        _G.AutoReelHeadless.setInstantReel(state)
    end
end)

ReelSection:NewToggle("🎣 Auto Shake", "Automatically handle shake events", function(state)
    if _G.AutoReelHeadless then
        _G.AutoReelHeadless.setAutoShake(state)
    end
end)

ReelSection:NewToggle("🚫 Zero Animations", "Block all fishing animations", function(state)
    if _G.AutoReelHeadless then
        _G.AutoReelHeadless.setZeroAnimation(state)
    end
end)

ReelSection:NewToggle("🚀 Instant Cast", "Speed up rod casting 5x faster", function(state)
    if _G.AutoReelHeadless then
        _G.AutoReelHeadless.setInstantCast(state)
    end
end)

ReelSection:NewToggle("💨 Fast Bobber", "Accelerate bobber to water instantly", function(state)
    if _G.AutoReelHeadless then
        _G.AutoReelHeadless.setFastBobber(state)
    end
end)

local ReelInfoSection = ReelTab:NewSection("Features Information")
ReelInfoSection:NewLabel("🎮 Available features:")
ReelInfoSection:NewLabel("• Silent instant fishing")
ReelInfoSection:NewLabel("• Ultra-fast reel detection")
ReelInfoSection:NewLabel("• Instant rod casting (5x speed)")
ReelInfoSection:NewLabel("• Fast bobber landing")
ReelInfoSection:NewLabel("• Zero animations & movement")

-- Status Tab Content
local SystemSection = StatusTab:NewSection("System Status")
local appraiserStatusLabel = SystemSection:NewLabel("🎯 Auto Appraiser: Loading...")
local reelStatusLabel = SystemSection:NewLabel("🤫 Auto Reel Silent: Loading...")

-- Status update loop
task.spawn(function()
    while true do
        task.wait(2)
        
        local appraiserStatus = "❌ Not Running"
        local reelStatus = "❌ Not Running"
        
        if _G.AutoAppraiserHeadless and _G.AutoAppraiserHeadless.isRunning() then
            appraiserStatus = "✅ Running"
        end
        
        if _G.AutoReelHeadless and _G.AutoReelHeadless.isRunning() then
            reelStatus = "✅ Running"
        end
        
        appraiserStatusLabel:UpdateLabel("🎯 Auto Appraiser: " .. appraiserStatus)
        reelStatusLabel:UpdateLabel("🤫 Auto Reel Silent: " .. reelStatus)
    end
end)

local ControlSection = StatusTab:NewSection("Quick Controls")
ControlSection:NewButton("🚀 Start All", "Enable both modules", function()
    if _G.AutoAppraiserHeadless then _G.AutoAppraiserHeadless.start() end
    if _G.AutoReelHeadless then _G.AutoReelHeadless.start() end
end)

ControlSection:NewButton("⏸️ Stop All", "Disable both modules", function()
    if _G.AutoAppraiserHeadless then _G.AutoAppraiserHeadless.stop() end
    if _G.AutoReelHeadless then _G.AutoReelHeadless.stop() end
end)

local InfoSection = StatusTab:NewSection("Information")
InfoSection:NewLabel("📦 Repository: github.com/donitono/simpleaja")
InfoSection:NewLabel("🔄 Auto-updates from GitHub")
InfoSection:NewLabel("⚡ Clean single UI interface")
InfoSection:NewLabel("🚀 Headless background modules")

-- Settings Tab Content
local EmergencySection = SettingsTab:NewSection("🚨 Emergency Controls")

EmergencySection:NewButton("🛑 Emergency Stop", "Stop ALL processes and clean memory immediately", function()
    print("🚨 EMERGENCY STOP INITIATED FROM UI 🚨")
    
    -- Load and execute the working emergency_stop.lua file
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/emergency_stop.lua"))()
    end)
end)

EmergencySection:NewLabel("⚠️ Use when game is lagging badly")
EmergencySection:NewLabel("🧹 Cleans all memory and stops processes")

local RecoverySection = SettingsTab:NewSection("🔄 Recovery Controls")

RecoverySection:NewButton("🔄 Smart Recovery", "Detect and fix script issues automatically", function()
    print("🔄 SMART RECOVERY INITIATED 🔄")
    
    local function smartRecovery()
        local fixed = 0
        
        -- Check and fix Auto Appraiser
        if not _G.AutoAppraiserHeadless then
            print("🎯 Reloading Auto Appraiser...")
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_appraiser_headless.lua"))()
                fixed = fixed + 1
                print("✅ Auto Appraiser recovered")
            end)
        else
            print("🎯 Auto Appraiser is healthy")
        end
        
        -- Check and fix Auto Reel
        if not _G.AutoReelHeadless then
            print("🤫 Reloading Auto Reel...")
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_reel_headless.lua"))()
                fixed = fixed + 1
                print("✅ Auto Reel recovered")
            end)
        else
            print("🤫 Auto Reel is healthy")
        end
        
        -- Force cleanup
        collectgarbage("collect")
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "🔄 Smart Recovery";
            Text = "Recovery completed! Fixed: " .. fixed .. " modules";
            Duration = 4;
        })
        
        print("✅ Smart recovery completed! Fixed: " .. fixed .. " modules")
    end
    
    smartRecovery()
end)

RecoverySection:NewButton("🔄 Full Reload", "Reload all modules from GitHub", function()
    print("🔄 FULL RELOAD INITIATED 🔄")
    
    local function fullReload()
        -- Stop existing processes
        if _G.AutoAppraiserHeadless then _G.AutoAppraiserHeadless.stop() end
        if _G.AutoReelHeadless then _G.AutoReelHeadless.stop() end
        
        -- Clean globals
        _G.AutoAppraiserHeadless = nil
        _G.AutoReelHeadless = nil
        
        -- Reload both modules
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_appraiser_headless.lua"))()
            print("✅ Auto Appraiser reloaded")
        end)
        
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_reel_headless.lua"))()
            print("✅ Auto Reel reloaded")
        end)
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "🔄 Full Reload";
            Text = "All modules reloaded from GitHub!";
            Duration = 4;
        })
        
        print("✅ Full reload completed!")
    end
    
    fullReload()
end)

RecoverySection:NewLabel("🔧 Auto-detect and fix script problems")
RecoverySection:NewLabel("📥 Get latest updates from GitHub")

local MaintenanceSection = SettingsTab:NewSection("🛠️ Maintenance")

MaintenanceSection:NewButton("📊 Health Check", "Check all modules status", function()
    print("📊 HEALTH CHECK 📊")
    
    local appraiserStatus = _G.AutoAppraiserHeadless and "✅ Loaded" or "❌ Missing"
    local reelStatus = _G.AutoReelHeadless and "✅ Loaded" or "❌ Missing"
    local appraiserRunning = "🔴 Stopped"
    local reelRunning = "🔴 Stopped"
    
    if _G.AutoAppraiserHeadless and _G.AutoAppraiserHeadless.isRunning then
        appraiserRunning = _G.AutoAppraiserHeadless.isRunning() and "🟢 Running" or "🔴 Stopped"
    end
    
    if _G.AutoReelHeadless and _G.AutoReelHeadless.isRunning then
        reelRunning = _G.AutoReelHeadless.isRunning() and "🟢 Running" or "🔴 Stopped"
    end
    
    print("🎯 Auto Appraiser: " .. appraiserStatus .. " | " .. appraiserRunning)
    print("🤫 Auto Reel: " .. reelStatus .. " | " .. reelRunning)
    
    local statusSummary = "Appraiser: " .. (appraiserRunning == "🟢 Running" and "ON" or "OFF") .. 
                         " | Reel: " .. (reelRunning == "🟢 Running" and "ON" or "OFF")
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "📊 Health Check";
        Text = statusSummary;
        Duration = 3;
    })
end)

MaintenanceSection:NewLabel("🔍 Monitor script health and performance")

-- Welcome message
game.StarterGui:SetCore("SendNotification", {
    Title = "🎣 Fisch Auto Tools";
    Text = "� Modules loaded! Use toggles to start.";
    Duration = 3;
})

print("🎣 Fisch Auto Tools loaded successfully!")
print("✅ Available Features:")
print("  🎯 Auto Appraiser (mutation filtering)")
print("  🤫 Auto Reel Silent (ghost mode)")
print("  📊 Real-time status monitoring")
print("  ⚙️ Emergency stop & recovery")
print("")
print("� Use toggle switches to enable features")
print("🛑 Emergency stop available in Settings tab")
print("🔄 Recovery tools for script issues")
print("")
print("📦 Repository: https://github.com/donitono/simpleaja")
print("🚀 Load: loadstring(game:HttpGet('https://raw.githubusercontent.com/donitono/simpleaja/main/main.lua'))()")