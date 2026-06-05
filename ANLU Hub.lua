-- =============================================================================
-- ANLU Hub(Rivals) - PRO EDITION (STABLE & DEVICE SPOOFER INTEGRATED)
-- =============================================================================
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'ANLU Hub(Rivals) - PRO EDITION',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.1
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Player = Window:AddTab('Player'),
    Visuals = Window:AddTab('Visuals'),
    World = Window:AddTab('World'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings')
}

-- [ Services & Variables ]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =============================================================================
-- [ 1. MAIN COMBAT TAB ]
-- =============================================================================
local AimbotTab = Tabs.Main:AddLeftGroupbox('Camera Lock-on Aimbot')
AimbotTab:AddToggle('AimbotEnabled', { Text = 'Enable Camera Aimbot', Default = false })
AimbotTab:AddSlider('Smoothness', { Text = 'Aimbot Smoothing', Default = 8, Min = 1, Max = 20, Rounding = 1 })
AimbotTab:AddDropdown('AimbotPart', { Values = { 'Head', 'HumanoidRootPart' }, Default = 1, Text = 'Target Part' })

local RageMainBox = Tabs.Main:AddLeftGroupbox('Hydra Rage Bot')
RageMainBox:AddToggle('RageBotToggle', { Text = 'Enable Projectile Redirect', Default = false })
RageMainBox:AddSlider('BaseVelocity', { Text = 'Minimum Bullet Velocity', Default = 500, Min = 100, Max = 10000, Rounding = 0 })

local SilentTab = Tabs.Main:AddRightGroupbox('Hyper Silent Aim')
SilentTab:AddToggle('SilentEnabled', { Text = 'Enable Silent Aim', Default = true })
SilentTab:AddToggle('WallBang', { Text = 'Wall Bang (Penetration)', Default = true })
SilentTab:AddToggle('PredictiveShot', { Text = 'Prediction Engine', Default = true })
SilentTab:AddToggle('ClosestPart', { Text = 'Auto Target Closest Part', Default = true })
SilentTab:AddToggle('ShowFOV', { Text = 'Show FOV Circle', Default = false })
SilentTab:AddSlider('Radius', { Text = 'FOV Radius Size', Default = 400, Min = 0, Max = 1000, Rounding = 0 })
SilentTab:AddSlider('HitChance', { Text = 'Hit Chance (%)', Default = 100, Min = 0, Max = 100, Rounding = 0 })

local AntiAimGroupBox = Tabs.Main:AddRightGroupbox('Hydra Anti-Aim')
AntiAimGroupBox:AddToggle('AntiAimToggle', { Text = 'Enable Anti-Aim', Default = false })
AntiAimGroupBox:AddDropdown('AntiAimMode', { 
    Values = { 'Hyper Spinbot', 'Backwards', 'Matrix Break', 'Pitch Flip', 'Fake Jitter' }, 
    Default = 1, 
    Text = 'Anti-Aim Style' 
})
AntiAimGroupBox:AddSlider('AntiAimSpeed', { Text = 'Glitch/Rotation Speed', Default = 150, Min = 10, Max = 500, Rounding = 0 })

-- =============================================================================
-- [ 2. PLAYER MOVEMENT & GLITCH EMOTE TAB ] 
-- =============================================================================
local GlitchGroupBox = Tabs.Player:AddLeftGroupbox('Math Stationary Glitch Emote')
local glitchConnection = nil
local keyStates = {W = false, A = false, S = false, D = false}

local function ToggleStationaryGlitch(state)
    if glitchConnection then glitchConnection:Disconnect() glitchConnection = nil end
    if state then
        glitchConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local torso = char and (char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
            if not torso or not char:FindFirstChild("Head") or not char:FindFirstChild("HumanoidRootPart") then return end
            local rootJoint = char.HumanoidRootPart:FindFirstChild("RootJoint") 
            local neck = torso:FindFirstChild("Neck") 
            local rShoulder = torso:FindFirstChild("Right Shoulder") or torso:FindFirstChild("RightShoulder")
            local lShoulder = torso:FindFirstChild("Left Shoulder") or torso:FindFirstChild("LeftShoulder")
            local t = tick() * 10
            
            char.HumanoidRootPart.Velocity = Vector3.zero
            char.HumanoidRootPart.RotVelocity = Vector3.zero
            
            if keyStates.W or keyStates.S then
                local sMod = keyStates.W and 1 or -1
                if rootJoint then rootJoint.Transform = CFrame.Angles(math.sin(t) * 0.8 * sMod, 0, 0) end
                if neck then neck.Transform = CFrame.Angles(math.sin(t * 1.5) * 0.7 * sMod, 0, math.rad(90) * sMod) end
            end
            if keyStates.A or keyStates.D then
                local sMod = keyStates.A and 1 or -1
                if rShoulder then rShoulder.Transform = CFrame.new(math.sin(t) * 2 * sMod, 0, 0) * CFrame.Angles(math.pi, math.sin(t) * sMod, 0) end
                if lShoulder then lShoulder.Transform = CFrame.new(math.sin(t) * -2 * sMod, 0, 0) * CFrame.Angles(math.pi, math.sin(t) * sMod, 0) end
            end
            if not keyStates.W and not keyStates.A and not keyStates.S and not keyStates.D then
                if rootJoint then rootJoint.Transform = CFrame.Angles(0, math.sin(t * 0.2) * 0.5, math.rad( tick() * 200 ) % 360) end
                if neck then neck.Transform = CFrame.Angles(math.sin(t) * 0.9, 0, 0) end
                if rShoulder then rShoulder.Transform = CFrame.Angles(math.rad(tick() * 100), math.rad(80), 0) end
            end
        end)
    end
end

GlitchGroupBox:AddToggle('GlitchDanceToggle', { Text = 'Enable Static WASD Glitch', Default = false }):OnChanged(function() ToggleStationaryGlitch(Toggles.GlitchDanceToggle.Value) end)

local UtilsGroupBox = Tabs.Player:AddLeftGroupbox('Player Utilities')
UtilsGroupBox:AddToggle('InfJumpToggle', { Text = 'Infinite Jump Enabled', Default = false })
UtilsGroupBox:AddToggle('FlyToggle', { Text = 'Enable Fly (Flight)', Default = false }):AddKeyPicker('FlyKey', { Default = 'F', SyncToggleState = true, Mode = 'Toggle', Text = 'Fly Toggle' })
UtilsGroupBox:AddSlider('FlySpeed', { Text = 'Fly Speed', Default = 50, Min = 16, Max = 100000, Rounding = 0 })
UtilsGroupBox:AddToggle('NoclipToggle', { Text = 'Enable Noclip (Walk through walls)', Default = false }):AddKeyPicker('NoclipKey', { Default = 'N', SyncToggleState = true, Mode = 'Toggle', Text = 'Noclip Toggle' })
UtilsGroupBox:AddToggle('AutoStrafeToggle', { Text = 'Enable Auto Strafe (Evasion)', Default = false })
UtilsGroupBox:AddSlider('AutoStrafeSpeed', { Text = 'Auto Strafe Power', Default = 30, Min = 10, Max = 200, Rounding = 0 })

local VoidGroupBox = Tabs.Player:AddLeftGroupbox('Void Teleport Settings')
VoidGroupBox:AddSlider('VoidSpamDepth', { Text = 'Void Depth (Y-Axis)', Default = -1000, Min = -5000, Max = -100, Rounding = 0 })
VoidGroupBox:AddToggle('VoidSpamToggle', { Text = 'Void Spam (Anti-Hitbox)', Default = false })

local PlayerBox = Tabs.Player:AddRightGroupbox('Movement Modification')
PlayerBox:AddToggle('StrafeToggle', { Text = 'Enable Target Strafe', Default = false })
PlayerBox:AddSlider('TeleportHeight', { Text = 'Teleport Height Offset', Default = 3.5, Min = 0, Max = 20, Rounding = 1 })
PlayerBox:AddSlider('StrafeDuration', { Text = 'Teleport Cycle Interval', Default = 0.5, Min = 0.1, Max = 2, Rounding = 1 })
PlayerBox:AddDropdown('MovementTargetMode', { Values = { 'Closest Player', 'Select Specific Player' }, Default = 1, Text = 'Target Tracking Priority' })
PlayerBox:AddDropdown('OrbitTargetPlayer', { SpecialType = 'Player', Text = 'Select Target Player' })

local OrbitGroupBox = Tabs.Player:AddRightGroupbox('Orbit Aura Physics')
OrbitGroupBox:AddToggle('OrbitToggle', { Text = 'Enable Orbit Aura', Default = false })
OrbitGroupBox:AddDropdown('OrbitTargetMode', { Values = { 'Map Center (0,0,0)', 'Tracked Target Position' }, Default = 2, Text = 'Rotation Anchor' })
OrbitGroupBox:AddSlider('OrbitRadius', { Text = 'Orbit Radius', Default = 8, Min = 2, Max = 100, Rounding = 0 })
OrbitGroupBox:AddSlider('OrbitSpeed', { Text = 'Orbit Speed', Default = 150, Min = 1, Max = 500, Rounding = 0 })
OrbitGroupBox:AddSlider('OrbitHeight', { Text = 'Orbit Height Offset', Default = 3, Min = -50, Max = 50, Rounding = 0 })

-- =============================================================================
-- [ 3. VISUALS ESP TAB ]
-- =============================================================================
local EspGroupBox = Tabs.Visuals:AddLeftGroupbox('Player ESP Options')
EspGroupBox:AddToggle('EspBox', { Text = 'Bounding Box', Default = false }):AddColorPicker('BoxColor', { Default = Color3.fromRGB(255, 255, 255) })
EspGroupBox:AddToggle('EspFill', { Text = 'Box Fill Transparency', Default = false }):AddColorPicker('FillColor', { Default = Color3.fromRGB(240, 200, 220) })
EspGroupBox:AddToggle('EspSkeleton', { Text = 'Skeleton Bones', Default = false }):AddColorPicker('SkeletonColor', { Default = Color3.fromRGB(255, 255, 255) })
EspGroupBox:AddToggle('EspName', { Text = 'Display Player Name', Default = false }):AddColorPicker('NameColor', { Default = Color3.fromRGB(255, 255, 255) })
EspGroupBox:AddToggle('EspDistance', { Text = 'Display Distance', Default = false }):AddColorPicker('DistanceColor', { Default = Color3.fromRGB(255, 255, 255) })
EspGroupBox:AddToggle('EspHealthBar', { Text = 'Health Bar Status', Default = false }):AddColorPicker('HealthBarColor', { Default = Color3.fromRGB(0, 255, 100) })

-- =============================================================================
-- [ 4. WORLD EFFECTS TAB ] 
-- =============================================================================
local WeatherGroupBox = Tabs.World:AddLeftGroupbox('Weather Systems')
local AmbientGroupBox = Tabs.World:AddRightGroupbox('Atmosphere & Environment')

local weatherAnchor = workspace:FindFirstChild("ANLU_WeatherZone")
if not weatherAnchor then
    weatherAnchor = Instance.new("Part")
    weatherAnchor.Name = "ANLU_WeatherZone"
    weatherAnchor.Size = Vector3.new(100, 1, 100)
    weatherAnchor.Transparency = 1
    weatherAnchor.Anchored = true
    weatherAnchor.CanCollide = false
    weatherAnchor.Parent = workspace
end

local snowPE, rainPE = nil, nil

WeatherGroupBox:AddToggle('SnowEffect', { Text = 'Enable Snow Effect', Default = false }):OnChanged(function()
    if Toggles.SnowEffect.Value then
        if not snowPE then
            snowPE = Instance.new("ParticleEmitter", weatherAnchor)
            snowPE.Name = "ANLU_Snow"
            snowPE.Texture = "rbxassetid://1084991211" 
            snowPE.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.3)})
            snowPE.Lifetime = NumberRange.new(2, 4)
            snowPE.Rate = 200
            snowPE.Speed = NumberRange.new(20, 35)
            snowPE.SpreadAngle = Vector2.new(30, 30)
            snowPE.LockedToPart = true
            snowPE.Acceleration = Vector3.new(0, -10, 0)
        end
    else
        if snowPE then snowPE:Destroy() snowPE = nil end
    end
end)

WeatherGroupBox:AddToggle('RainEffect', { Text = 'Enable Rain Effect', Default = false }):OnChanged(function()
    if Toggles.RainEffect.Value then
        if not rainPE then
            rainPE = Instance.new("ParticleEmitter", weatherAnchor)
            rainPE.Name = "ANLU_Rain"
            rainPE.Texture = "rbxassetid://363276166" 
            rainPE.Size = NumberSequence.new(0.2)
            rainPE.Lifetime = NumberRange.new(1, 1.5)
            rainPE.Rate = 500
            rainPE.Speed = NumberRange.new(90, 130)
            rainPE.SpreadAngle = Vector2.new(10, 10)
            rainPE.LockedToPart = true
            rainPE.Acceleration = Vector3.new(-15, -50, 0)
        end
    else
        if rainPE then rainPE:Destroy() rainPE = nil end
    end
end)

AmbientGroupBox:AddSlider('AtmosphereDensity', { Text = 'Atmosphere Density', Default = 0, Min = 0, Max = 100, Rounding = 0 }):OnChanged(function()
    local lighting = game:GetService("Lighting")
    local atmos = lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", lighting)
    atmos.Density = Options.AtmosphereDensity.Value / 100
end)

-- =============================================================================
-- [ 5. MISC TAB (DEVICE SPOOFER & UTILS) ] 
-- =============================================================================
local WeaponModBox = Tabs.Misc:AddLeftGroupbox('Network Packet Overclock')
WeaponModBox:AddToggle('FastFireToggle', { Text = 'Enable Multi-Packet Fire', Default = false })
WeaponModBox:AddSlider('FireRateMultiplier', { Text = 'Packet Replication Multiplier', Default = 4, Min = 1, Max = 10, Rounding = 0 })

local InventoryBox = Tabs.Misc:AddLeftGroupbox('Inventory Modification')
InventoryBox:AddButton('Duplicate Current Weapon x4', function()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    
    if char and backpack then
        local currentTool = char:FindFirstChildOfClass("Tool")
        if currentTool then
            for i = 1, 3 do
                local clonedTool = currentTool:Clone()
                clonedTool.Parent = backpack
            end
            Library:Notify('🔥 Duplicated currently held tool 4 times!', 3)
        end
    end
end)

-- [ 📱 SYSTEM DEVICE SPOOFER ]
local SpooferBox = Tabs.Misc:AddRightGroupbox('System Spoofer (기기 위조)')
SpooferBox:AddToggle('DeviceSpooferToggle', { Text = 'Device Spoofer (기기 속이기)', Default = false })
SpooferBox:AddDropdown('DeviceMode', { 
    Values = { 'PC', 'Mobile', 'Console' }, 
    Default = 2, 
    Text = '위조할 기기 선택' 
})

-- =============================================================================
-- [ 6. BACKEND CORE ENGINE (HOOKS & LOOPS) ]
-- =============================================================================
local angle, antiAimAngle, lastStrafeTime, alternateVoid, lastNormalCFrame = 0, 0, 0, false, nil
local isClicking, isRightMouseDown = false, false
local espCache = {}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 50)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false

-- [ 🌟 METATABLE HOOKING (NAME_CALL & INDEX) ]
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
setreadonly(mt, false)

-- __index 후킹: Device Spoofer
mt.__index = newcclosure(function(self, key)
    if not checkcaller() and Toggles and Toggles.DeviceSpooferToggle and Toggles.DeviceSpooferToggle.Value then
        local mode = Options.DeviceMode.Value
        
        if self == UserInputService then
            if mode == "Mobile" then
                if key == "TouchEnabled" then return true end
                if key == "KeyboardEnabled" then return false end
            elseif mode == "Console" then
                if key == "GamepadEnabled" then return true end
                if key == "KeyboardEnabled" then return false end
            elseif mode == "PC" then
                if key == "KeyboardEnabled" then return true end
                if key == "TouchEnabled" then return false end
                if key == "GamepadEnabled" then return false end
            end
        elseif self == GuiService then
            if mode == "Console" and key == "IsTenFootInterface" then
                return true 
            end
        end
    end
    return oldIndex(self, key)
end)

-- __namecall 후킹: Silent Aim
local function getClosestPlayerToMous()
    if not Options or not Options.Radius then return nil end
    local target = nil
    local maxDist = Options.Radius.Value
    local mousePos = UserInputService:GetMouseLocation()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen or (Toggles.WallBang and Toggles.WallBang.Value) then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < maxDist then maxDist = dist target = p end
            end
        end
    end
    return target
end

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and typeof(self) == "Instance" and self.Name == "UseItem" and method == "FireServer" then
        if Toggles and Toggles.SilentEnabled and Toggles.SilentEnabled.Value and math.random(1, 100) <= Options.HitChance.Value then
            local targetPlayer = getClosestPlayerToMous()
            if targetPlayer and targetPlayer.Character then
                local partName = (Toggles.ClosestPart and Toggles.ClosestPart.Value) and "Head" or "HumanoidRootPart"
                local targetPart = targetPlayer.Character:FindFirstChild(partName)
                
                if targetPart and args[3] and type(args[3]) == "table" and args[3]["\001"] then
                    local hitPos = targetPart.Position
                    if Toggles.PredictiveShot and Toggles.PredictiveShot.Value and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        hitPos = hitPos + (targetPlayer.Character.HumanoidRootPart.Velocity * 0.135) 
                    end
                    if args[3]["\001"]["\001"] then args[3]["\001"]["\001"]["\001"] = hitPos.X args[3]["\001"]["\001"]["\000"] = hitPos.Y args[3]["\001"]["\001"]["\002"] = hitPos.Z end
                    if args[3]["\001"]["\000"] then args[3]["\001"]["\000"]["\001"] = hitPos.X args[3]["\001"]["\000"]["\000"] = hitPos.Y args[3]["\001"]["\000"]["\002"] = hitPos.Z end
                    args[3]["\001"]["\002"] = targetPart
                end
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

-- [ Inputs & Binds ]
UserInputService.JumpRequest:Connect(function()
    if Toggles and Toggles.InfJumpToggle and Toggles.InfJumpToggle.Value and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

local FlyKeys = {W = false, A = false, S = false, D = false, Space = false, LeftControl = false}
UserInputService.InputBegan:Connect(function(i, g) 
    if not g then 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then isClicking = true end 
        if i.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = true end 
        if i.KeyCode == Enum.KeyCode.W then FlyKeys.W = true keyStates.W = true end
        if i.KeyCode == Enum.KeyCode.A then FlyKeys.A = true keyStates.A = true end
        if i.KeyCode == Enum.KeyCode.S then FlyKeys.S = true keyStates.S = true end
        if i.KeyCode == Enum.KeyCode.D then FlyKeys.D = true keyStates.D = true end
        if i.KeyCode == Enum.KeyCode.Space then FlyKeys.Space = true end
        if i.KeyCode == Enum.KeyCode.LeftControl then FlyKeys.LeftControl = true end
    end 
end)

UserInputService.InputEnded:Connect(function(i, g) 
    if i.UserInputType == Enum.UserInputType.MouseButton1 then isClicking = false end 
    if i.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = false end 
    if i.KeyCode == Enum.KeyCode.W then FlyKeys.W = false keyStates.W = false end
    if i.KeyCode == Enum.KeyCode.A then FlyKeys.A = false keyStates.A = false end
    if i.KeyCode == Enum.KeyCode.S then FlyKeys.S = false keyStates.S = false end
    if i.KeyCode == Enum.KeyCode.D then FlyKeys.D = false keyStates.D = false end
    if i.KeyCode == Enum.KeyCode.Space then FlyKeys.Space = false end
    if i.KeyCode == Enum.KeyCode.LeftControl then FlyKeys.LeftControl = false end
end)

-- [ CORE LOOPS ]
RunService.RenderStepped:Connect(function(dt)
    if Toggles.ShowFOV.Value then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Options.Radius.Value
        FOVCircle.Visible = true
    else FOVCircle.Visible = false end
    
    if weatherAnchor and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        weatherAnchor.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 25, 0))
    end
    
    if Toggles.AimbotEnabled.Value and isRightMouseDown then
        local targetPlayer = getClosestPlayerToMous()
        if targetPlayer and targetPlayer.Character then
            local targetPart = targetPlayer.Character:FindFirstChild(Options.AimbotPart.Value)
            if targetPart then Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPart.Position), math.clamp(dt * (21 - Options.Smoothness.Value), 0, 1)) end
        end
    end
end)

-- =============================================================================
-- [ 7. UI SETTINGS & MANAGERS ]
-- =============================================================================
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu Options')
MenuGroup:AddButton('Unload Script', function() 
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then 
            if hrp:FindFirstChild("ANLU_Fly") then hrp.ANLU_Fly:Destroy() end
            if hrp:FindFirstChild("ANLU_FlyGyro") then hrp.ANLU_FlyGyro:Destroy() end
        end
        if glitchConnection then glitchConnection:Disconnect() end
        FOVCircle:Destroy() if weatherAnchor then weatherAnchor:Destroy() end
    end)
    Library:Unload() 
end)

MenuGroup:AddLabel('Menu Bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind

local ExtraBox = Tabs['UI Settings']:AddRightGroupbox('Extra Utilities')
ExtraBox:AddToggle('ShowWatermark', { Text = 'Show Watermark', Default = true }):OnChanged(function()
    Library:SetWatermarkVisibility(Toggles.ShowWatermark.Value)
end)
Library:SetWatermark('ANLU Hub(Rivals) - PRO EDITION')

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('ANLUHub')
SaveManager:SetFolder('ANLUHub/Rivals')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
