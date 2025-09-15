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
        Text = "🚀 All modules loaded successfully!";
        Duration = 2;
    })
end)

-- Create clean interface tabs
local AppraiserTab = Window:NewTab("🎯 Auto Appraiser")
local ReelTab = Window:NewTab("🤫 Auto Reel")
local StatusTab = Window:NewTab("📊 Status")

-- Auto Appraiser Tab Content
local AppraiserSection = AppraiserTab:NewSection("Auto Appraiser Controls")

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

local ReelInfoSection = ReelTab:NewSection("Features Information")
ReelInfoSection:NewLabel("🎮 Available features:")
ReelInfoSection:NewLabel("• Silent instant fishing")
ReelInfoSection:NewLabel("• No movement required")
ReelInfoSection:NewLabel("• Aggressive animation blocking")
ReelInfoSection:NewLabel("• Automatic reel detection")

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

-- Load Auto Reel Silent Module  
LoaderSection:NewButton("🤫 Load Auto Reel Silent", "Load silent instant reel and normal auto reel system", function()
    if not moduleStatus.autoReel then
        print("📦 Loading Auto Reel Silent module...")
        
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_reel_instant.lua"))()
            moduleStatus.autoReel = true
            
            game.StarterGui:SetCore("SendNotification", {
                Title = "Module Loader";
                Text = "🤫 Auto Reel Silent loaded successfully!";
                Duration = 3;
            })
            
            print("✅ Auto Reel Silent module loaded successfully!")
        end)
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Module Loader";
            Text = "⚠️ Auto Reel Silent already loaded!";
            Duration = 2;
        })
    end
end)

-- Load All Modules at Once
LoaderSection:NewButton("🚀 Load All Modules", "Load both Auto Appraiser and Auto Reel Silent", function()
    print("🚀 Loading all modules...")
    
    -- Load Auto Appraiser if not loaded
    if not moduleStatus.appraiser then
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_appraiser.lua"))()
            moduleStatus.appraiser = true
            print("✅ Auto Appraiser module loaded!")
        end)
    end
    
    -- Load Auto Reel Silent if not loaded
    if not moduleStatus.autoReel then
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_reel_instant.lua"))()
            moduleStatus.autoReel = true
            print("✅ Auto Reel Silent module loaded!")
        end)
    end
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Module Loader";
        Text = "🚀 All modules loaded successfully!";
        Duration = 3;
    })
end)

-- Reload/Update Modules
LoaderSection:NewButton("🔄 Reload All Modules", "Force reload all modules (for updates)", function()
    print("🔄 Force reloading all modules...")
    
    -- Reset status and force reload
    moduleStatus.appraiser = false
    moduleStatus.autoReel = false
    
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_appraiser.lua"))()
        moduleStatus.appraiser = true
        print("🔄 Auto Appraiser module reloaded!")
    end)
    
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_reel_instant.lua"))()
        moduleStatus.autoReel = true
        print("🔄 Auto Reel Silent module reloaded!")
    end)
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Module Loader";
        Text = "🔄 All modules reloaded successfully!";
        Duration = 3;
    })
end)

-- Status Display
local appraiserStatusLabel = StatusSection:NewLabel("🎯 Auto Appraiser: Not Loaded")
local reelStatusLabel = StatusSection:NewLabel("🤫 Auto Reel Silent: Not Loaded")

-- Status Update Loop
task.spawn(function()
    while true do
        task.wait(2)
        
        local appraiserText = moduleStatus.appraiser and "Loaded ✅" or "Not Loaded ❌"
        local reelText = moduleStatus.autoReel and "Loaded ✅" or "Not Loaded ❌"
        
        appraiserStatusLabel:UpdateLabel("🎯 Auto Appraiser: " .. appraiserText)
        reelStatusLabel:UpdateLabel("🤫 Auto Reel Silent: " .. reelText)
    end
end)

-- Information Tab
local InfoTab = Window:NewTab("ℹ️ Information")
local AboutSection = InfoTab:NewSection("About")
local ModulesSection = InfoTab:NewSection("Available Modules")
local UpdatesSection = InfoTab:NewSection("Updates & Links")

-- About Information
AboutSection:NewLabel("🎣 Fisch Auto Tools Hub")
AboutSection:NewLabel("Modular script loader for Fisch game automation")
AboutSection:NewLabel("Each module loads independently with its own UI")
AboutSection:NewLabel("Easy to update and maintain separately")

-- Module Information
ModulesSection:NewLabel("🎯 AUTO APPRAISER MODULE:")
ModulesSection:NewLabel("• Automatic fish/rod appraisal")
ModulesSection:NewLabel("• Mutation filtering (Albino, Midas, etc.)")
ModulesSection:NewLabel("• Auto teleport to appraiser NPCs")
ModulesSection:NewLabel("• Smart conversation handling")

ModulesSection:NewLabel("")
ModulesSection:NewLabel("🤫 AUTO REEL SILENT MODULE:")
ModulesSection:NewLabel("• Silent instant reel (Ghost Mode)")
ModulesSection:NewLabel("• Normal auto reel with animations")
ModulesSection:NewLabel("• Zero movement fishing")
ModulesSection:NewLabel("• Zero movement fishing")
ModulesSection:NewLabel("• Auto shake bypass")

-- Update Information
UpdatesSection:NewLabel("📦 MODULE URLS:")
UpdatesSection:NewLabel("Auto Appraiser:")
UpdatesSection:NewLabel("github.com/donitono/simpleaja/auto_appraiser.lua")
UpdatesSection:NewLabel("")
UpdatesSection:NewLabel("Auto Reel Silent:")
UpdatesSection:NewLabel("github.com/donitono/simpleaja/auto_reel_instant.lua")
UpdatesSection:NewLabel("")
UpdatesSection:NewLabel("🔄 Use 'Reload All' to get latest updates!")

-- Quick Load Tab for Easy Access
local QuickTab = Window:NewTab("⚡ Quick Load")
local QuickSection = QuickTab:NewSection("One-Click Loading")

QuickSection:NewButton("⚡ Load Everything Now", "Quick load all modules instantly", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_appraiser.lua"))()
        moduleStatus.appraiser = true
    end)
    
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_reel_instant.lua"))()
        moduleStatus.autoReel = true
    end)
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Quick Load";
        Text = "⚡ Everything loaded instantly!";
        Duration = 3;
    })
    
    print("⚡ Quick Load Complete - All modules ready!")
end)

QuickSection:NewLabel("⚡ This will load both modules immediately")
QuickSection:NewLabel("Each module will open its own UI window")
QuickSection:NewLabel("Use this for fastest setup experience")

-- Welcome Messages
game.StarterGui:SetCore("SendNotification", {
    Title = "Fisch Auto Tools Hub";
    Text = "🏠 Main loader ready! Load modules as needed.";
    Duration = 3;
})

print("🏠 Fisch Auto Tools Hub loaded successfully!")
print("🎯 Available Modules:")
print("  • Auto Appraiser (mutation filtering)")
print("  • Auto Reel Silent (ghost mode fishing)")
print("")
print("💡 Each module loads independently with separate UI")
print("🔄 Easy to update individual modules via reload")
print("⚡ Use Quick Load for instant setup!")
print("")
print("📦 Repository: https://github.com/donitono/simpleaja")
print("🚀 Main Loader: loadstring(game:HttpGet('https://raw.githubusercontent.com/donitono/simpleaja/main/main.lua'))()")