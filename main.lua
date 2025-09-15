-- Fisch Auto Tools - Direct Access
-- Created by: donitono
-- Repository: https://github.com/donitono/simpleaja

local lp = game:GetService("Players").LocalPlayer

-- Initialize global cleanup system
_G.FischAutoToolsCleanup = _G.FischAutoToolsCleanup or {
    connections = {},
    flags = {},
    modules = {}
}

-- Load Kavo UI Library
print("📚 Loading Kavo UI Library...")
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/kavo.lua"))()

-- Load both features directly  
print("🔍 Loading Auto Appraiser...")
loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_appraiser.lua"))()

print("🎣 Loading Auto Reel Instant...")
loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/simpleaja/main/auto_reel_instant.lua"))()

-- Create simple toggle UI
local UI = Kavo.CreateLib("🎣 Fisch Tools", "Synapse")
_G.MainFischGUI = UI

local MainTab = UI:NewTab("Features")
local Section = MainTab:NewSection("Toggle")

-- Auto Appraiser Toggle
Section:NewToggle("Auto Appraiser", "", function(state)
    if _G.flags then
        _G.flags['autoappraise'] = state
        print(state and "🔍 Auto Appraiser: ON" or "🔍 Auto Appraiser: OFF")
    end
end)

-- Auto Reel Toggle  
Section:NewToggle("Silent Instant Reel", "", function(state)
    if _G.flags then
        _G.flags['superinstantsilent'] = state
        print(state and "🎣 Silent Reel: ON" or "🎣 Silent Reel: OFF")
    end
end)

-- Exit button
Section:NewButton("Exit", "", function()
    -- Safe shutdown
    if _G.flags then
        for flag, _ in pairs(_G.flags) do
            _G.flags[flag] = false
        end
    end
    
    if _G.FischAutoToolsCleanup and _G.FischAutoToolsCleanup.connections then
        for _, connection in pairs(_G.FischAutoToolsCleanup.connections) do
            if connection and typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            end
        end
    end
    
    _G.AutoAppraise = nil
    _G.lureMonitorConnection = nil  
    _G.FischAutoToolsCleanup = nil
    
    if _G.MainFischGUI then
        _G.MainFischGUI:Destroy()
        _G.MainFischGUI = nil
    end
    
    print("✅ All scripts disabled safely!")
end)

print("🎯 Fisch Tools ready!")
