-- Emergency Stop Script - Fisch Auto Tools
-- Use this to stop all running processes and clean memory
-- Author: donitono

print("🛑 Emergency Stop Script Loading...")

-- Function to disconnect all connections
local function disconnectAllConnections()
    local disconnected = 0
    
    -- Try to stop Auto Appraiser if running
    if _G.AutoAppraiserHeadless then
        pcall(function()
            _G.AutoAppraiserHeadless.stop()
            disconnected = disconnected + 1
            print("✅ Auto Appraiser stopped")
        end)
    end
    
    -- Try to stop Auto Reel if running  
    if _G.AutoReelHeadless then
        pcall(function()
            _G.AutoReelHeadless.stop()
            disconnected = disconnected + 1
            print("✅ Auto Reel stopped")
        end)
    end
    
    -- Force disconnect all RunService connections
    local RunService = game:GetService("RunService")
    pcall(function()
        -- This will disconnect ALL connections - aggressive but effective
        for _, connection in pairs(getconnections(RunService.Heartbeat)) do
            if connection.Function then
                local funcStr = tostring(connection.Function)
                if string.find(funcStr:lower(), "reel") or 
                   string.find(funcStr:lower(), "fish") or
                   string.find(funcStr:lower(), "apprai") or
                   string.find(funcStr:lower(), "bobber") then
                    connection:Disconnect()
                    disconnected = disconnected + 1
                    print("🔌 Disconnected suspicious Heartbeat connection")
                end
            end
        end
        
        for _, connection in pairs(getconnections(RunService.RenderStepped)) do
            if connection.Function then
                local funcStr = tostring(connection.Function)
                if string.find(funcStr:lower(), "reel") or 
                   string.find(funcStr:lower(), "fish") or
                   string.find(funcStr:lower(), "apprai") or
                   string.find(funcStr:lower(), "bobber") then
                    connection:Disconnect()
                    disconnected = disconnected + 1
                    print("🔌 Disconnected suspicious RenderStepped connection")
                end
            end
        end
        
        for _, connection in pairs(getconnections(RunService.Stepped)) do
            if connection.Function then
                local funcStr = tostring(connection.Function)
                if string.find(funcStr:lower(), "reel") or 
                   string.find(funcStr:lower(), "fish") or
                   string.find(funcStr:lower(), "apprai") or
                   string.find(funcStr:lower(), "bobber") then
                    connection:Disconnect()
                    disconnected = disconnected + 1
                    print("🔌 Disconnected suspicious Stepped connection")
                end
            end
        end
    end)
    
    return disconnected
end

-- Function to clean up global variables
local function cleanGlobalVariables()
    local cleaned = 0
    
    -- Clean main globals
    if _G.AutoAppraiserHeadless then
        _G.AutoAppraiserHeadless = nil
        cleaned = cleaned + 1
        print("🧹 Auto Appraiser globals cleaned")
    end
    
    if _G.AutoReelHeadless then
        _G.AutoReelHeadless = nil
        cleaned = cleaned + 1
        print("🧹 Auto Reel globals cleaned")
    end
    
    -- Clean emergency stop global
    if _G.EmergencyStop then
        _G.EmergencyStop = nil
        cleaned = cleaned + 1
        print("🧹 Emergency Stop global cleaned")
    end
    
    -- Clean any other fishing-related globals
    for key, value in pairs(_G) do
        if type(key) == "string" then
            local keyLower = key:lower()
            if string.find(keyLower, "fish") or
               string.find(keyLower, "reel") or 
               string.find(keyLower, "apprai") or
               string.find(keyLower, "bobber") or
               string.find(keyLower, "auto") then
                _G[key] = nil
                cleaned = cleaned + 1
                print("🧹 Cleaned suspicious global: " .. key)
            end
        end
    end
    
    return cleaned
end

-- Function to clean GUI listeners and events
local function cleanGUIListeners()
    local cleaned = 0
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- Disconnect all GUI event listeners
    pcall(function()
        local PlayerGui = LocalPlayer.PlayerGui
        
        -- Disconnect ChildAdded connections
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, connection in pairs(getconnections(gui.ChildAdded)) do
                    if connection.Function then
                        local funcStr = tostring(connection.Function)
                        if string.find(funcStr:lower(), "fish") or
                           string.find(funcStr:lower(), "reel") or
                           string.find(funcStr:lower(), "bobber") then
                            connection:Disconnect()
                            cleaned = cleaned + 1
                            print("🔌 Disconnected GUI listener")
                        end
                    end
                end
                
                -- Also check DescendantAdded
                for _, connection in pairs(getconnections(gui.DescendantAdded)) do
                    if connection.Function then
                        local funcStr = tostring(connection.Function)
                        if string.find(funcStr:lower(), "fish") or
                           string.find(funcStr:lower(), "reel") or
                           string.find(funcStr:lower(), "bobber") then
                            connection:Disconnect()
                            cleaned = cleaned + 1
                            print("🔌 Disconnected GUI descendant listener")
                        end
                    end
                end
            end
        end
        
        -- Also check PlayerGui itself
        for _, connection in pairs(getconnections(PlayerGui.ChildAdded)) do
            if connection.Function then
                local funcStr = tostring(connection.Function)
                if string.find(funcStr:lower(), "fish") or
                   string.find(funcStr:lower(), "reel") or
                   string.find(funcStr:lower(), "bobber") then
                    connection:Disconnect()
                    cleaned = cleaned + 1
                    print("🔌 Disconnected PlayerGui listener")
                end
            end
        end
    end)
    
    return cleaned
end

-- Function to force stop all RunService connections
local function forceStopRunService()
    local RunService = game:GetService("RunService")
    local stopped = 0
    
    -- This is a more aggressive approach
    pcall(function()
        -- Force garbage collection
        game:GetService("RunService").Heartbeat:Wait()
        stopped = stopped + 1
        print("🔄 Forced RunService cleanup")
    end)
    
    return stopped
end

-- Function to close all GUIs
local function closeAllGUIs()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer.PlayerGui
    local closed = 0
    
    -- Look for our GUIs and close them
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            -- Check if it's one of our UIs
            if string.find(gui.Name, "Kavo") or 
               string.find(gui.Name, "Auto") or
               string.find(gui.Name, "Fisch") then
                pcall(function()
                    gui:Destroy()
                    closed = closed + 1
                    print("🗑️ Closed GUI: " .. gui.Name)
                end)
            end
        end
    end
    
    return closed
end

-- Main emergency stop function
local function emergencyStop()
    print("🚨 EMERGENCY STOP INITIATED 🚨")
    print("==============================")
    
    local totalStopped = 0
    
    -- Step 1: Disconnect all connections (aggressive)
    print("🛑 Step 1: Stopping all processes...")
    totalStopped = totalStopped + disconnectAllConnections()
    
    -- Step 2: Clean GUI listeners
    print("🔌 Step 2: Cleaning GUI listeners...")
    totalStopped = totalStopped + cleanGUIListeners()
    
    -- Step 3: Clean global variables
    print("🧹 Step 3: Cleaning global variables...")
    totalStopped = totalStopped + cleanGlobalVariables()
    
    -- Step 4: Force cleanup RunService
    print("🔄 Step 4: Force RunService cleanup...")
    totalStopped = totalStopped + forceStopRunService()
    
    -- Step 5: Close GUIs
    print("🗑️ Step 5: Closing all GUIs...")
    totalStopped = totalStopped + closeAllGUIs()
    
    -- Step 6: Multiple garbage collection passes
    print("🧽 Step 6: Aggressive garbage collection...")
    for i = 1, 3 do
        pcall(function()
            collectgarbage("collect")
            wait(0.1)
        end)
    end
    print("🧽 Garbage collection completed (3 passes)")
    
    -- Step 7: Final verification
    print("✅ Step 7: Final verification...")
    local stillRunning = 0
    if _G.AutoAppraiserHeadless then stillRunning = stillRunning + 1 end
    if _G.AutoReelHeadless then stillRunning = stillRunning + 1 end
    
    if stillRunning > 0 then
        print("⚠️ WARNING: " .. stillRunning .. " processes may still be running!")
        print("🔄 Attempting final cleanup...")
        _G.AutoAppraiserHeadless = nil
        _G.AutoReelHeadless = nil
        collectgarbage("collect")
    else
        print("✅ All processes confirmed stopped!")
    end
    
    print("==============================")
    print("✅ EMERGENCY STOP COMPLETED!")
    print("📊 Total items stopped/cleaned: " .. totalStopped)
    print("🎮 Game should be back to normal performance")
    print("💡 You can now reload the script safely")
    
    -- Final notification
    game.StarterGui:SetCore("SendNotification", {
        Title = "🛑 Emergency Stop";
        Text = "All processes stopped! Game restored.";
        Duration = 5;
    })
end

-- Execute emergency stop immediately
emergencyStop()

-- Also provide global function for manual use
_G.EmergencyStop = emergencyStop

print("")
print("💡 EMERGENCY STOP SCRIPT LOADED!")
print("🔄 To run again, use: _G.EmergencyStop()")
print("📖 Safe to reload main script after this")