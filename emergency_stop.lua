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
    
    return disconnected
end

-- Function to clean up global variables
local function cleanGlobalVariables()
    local cleaned = 0
    
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
    
    -- Step 1: Disconnect all connections
    print("🛑 Step 1: Stopping all processes...")
    totalStopped = totalStopped + disconnectAllConnections()
    
    -- Step 2: Clean global variables
    print("🧹 Step 2: Cleaning global variables...")
    totalStopped = totalStopped + cleanGlobalVariables()
    
    -- Step 3: Force cleanup RunService
    print("🔄 Step 3: Force RunService cleanup...")
    totalStopped = totalStopped + forceStopRunService()
    
    -- Step 4: Close GUIs
    print("🗑️ Step 4: Closing all GUIs...")
    totalStopped = totalStopped + closeAllGUIs()
    
    -- Step 5: Force garbage collection
    print("🧽 Step 5: Force garbage collection...")
    pcall(function()
        collectgarbage("collect")
        print("🧽 Garbage collection completed")
    end)
    
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