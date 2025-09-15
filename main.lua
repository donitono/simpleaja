-- Fisch Auto Tools - Clean Interface
-- Auto-loading both Auto Appraiser and Auto Reel Silent
-- Author: donitono
-- Repository: https://github.com/donitono/simpleaja

-- Load Kavo UI Library
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/kavo.lua"))()
local Window = Kavo.CreateLib("🎣 Fisch Auto Tools", "Ocean")

-- Auto-load both modules immediately
task.spawn(function()
    -- Load Auto Appraiser
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_appraiser.lua"))()
    end)
    
    -- Load Auto Reel Silent
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_reel_instant.lua"))()
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
local AppraiserSection = AppraiserTab:NewSection("Auto Appraiser Settings")
AppraiserSection:NewLabel("✅ Auto Appraiser Module Loaded")
AppraiserSection:NewLabel("🎯 Mutation filtering active")
AppraiserSection:NewLabel("🚀 Auto teleport to NPCs enabled")
AppraiserSection:NewLabel("💬 Smart dialog handling active")
AppraiserSection:NewLabel("")
AppraiserSection:NewLabel("📝 Available mutations:")
AppraiserSection:NewLabel("Albino, Midas, Shiny, Golden, Diamond,")
AppraiserSection:NewLabel("Prismarine, Frozen, Electric, Ghastly,")
AppraiserSection:NewLabel("Mosaic, Glossy, Translucent, Negative,")
AppraiserSection:NewLabel("Lunar, Solar, Hexed, Atlantean,")
AppraiserSection:NewLabel("Abyssal, Mythical")

-- Auto Reel Tab Content  
local ReelSection = ReelTab:NewSection("Auto Reel Settings")
ReelSection:NewLabel("✅ Auto Reel Silent Module Loaded")
ReelSection:NewLabel("👻 Ghost Mode (Silent) active")
ReelSection:NewLabel("⚡ Instant reel enabled")
ReelSection:NewLabel("🚫 Zero animations mode")
ReelSection:NewLabel("🎣 Auto shake bypass active")
ReelSection:NewLabel("")
ReelSection:NewLabel("🎮 Features:")
ReelSection:NewLabel("• Silent instant fishing")
ReelSection:NewLabel("• No movement required")
ReelSection:NewLabel("• Aggressive animation blocking")
ReelSection:NewLabel("• Automatic reel detection")

-- Status Tab Content
local SystemSection = StatusTab:NewSection("System Status")
SystemSection:NewLabel("🟢 All modules: Active")
SystemSection:NewLabel("🎯 Auto Appraiser: Running")
SystemSection:NewLabel("🤫 Auto Reel Silent: Running")
SystemSection:NewLabel("")

local InfoSection = StatusTab:NewSection("Information")
InfoSection:NewLabel("📦 Repository: github.com/donitono/simpleaja")
InfoSection:NewLabel("🔄 Auto-updates from GitHub")
InfoSection:NewLabel("⚡ Clean interface mode")
InfoSection:NewLabel("🚀 No manual loading required")

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