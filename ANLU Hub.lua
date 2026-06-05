-- =============================================================================
-- ANLU Hub(Rivals) - PRO OPTIMIZED VERSION (NO TIMEOUT, SAFE LOOPS)
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

local Tabs = {}
Tabs.Main = Window:AddTab('Main')
Tabs.Player = Window:AddTab('Player')
Tabs.Visuals = Window:AddTab('Visuals')
Tabs.World = Window:AddTab('World')
Tabs.Misc = Window:AddTab('Misc')
Tabs['UI Settings'] = Window:AddTab('UI Settings')

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
RageMainBox:AddToggle('VoidSpamToggle', { Text = 'Void Spam (Anti-Hitbox)', Default = false })

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
-- [ 2. PLAYER MOVEMENT & EMOTE TAB ]
-- =============================================================================
local EmoteGroupBox = Tabs.Player:AddLeftGroupbox('Hydra Emote Studio')
local currentEmoteTrack = nil
local selectedEmoteId = 0

local function PlayCustomEmote(animationId)
    local Players = game:GetService("Players")
    local character = Players.LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        if currentEmoteTrack then
            currentEmoteTrack:Stop()
            currentEmoteTrack:Destroy()
            currentEmoteTrack = nil
        end
        if animationId == 0 then return end
        
        local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. tostring(animationId)
        
        local success, track = pcall(function() return animator:LoadAnimation(anim) end)
        if success and track then
            currentEmoteTrack = track
            currentEmoteTrack.Priority = Enum.AnimationPriority.Action4
            currentEmoteTrack:Play()
        end
    end
end

local EmotePresets = {
    ["Stop Emote"] = 0, ["Default Dance"] = 507468474, ["Floss"] = 10214312386, ["Take The L"] = 10214314410,
    ["Hype"] = 10214311896, ["Orange Justice"] = 10214312845, ["T-Pose"] = 10479375172, ["Griddy"] = 11130453311,
    ["Wave"] = 128743149, ["Dance 1"] = 182435877, ["Dance 2"] = 182436842, ["Dance 3"] = 182436935
}

local EmoteNames = {}
for name, _ in pairs(EmotePresets) do table.insert(EmoteNames, name) end
table.sort(EmoteNames)

EmoteGroupBox:AddDropdown('EmoteSelect', { 
    Values = EmoteNames, Default = 1, Text = 'Select Preset Emote',
    Callback = function(Value) selectedEmoteId = EmotePresets[Value] or 0 end
})
EmoteGroupBox:AddInput('CustomEmoteId', {
    Default = '', Numeric = true, Finished = true, Text = 'Custom Animation ID', Placeholder = 'Paste Asset ID...',
    Callback = function(Value) if Value and Value ~= '' then selectedEmoteId = tonumber(Value) or 0 end end
})
EmoteGroupBox:AddButton('Play Animation', function() if selectedEmoteId ~= 0 then PlayCustomEmote(selectedEmoteId) end end)
EmoteGroupBox:AddButton('Stop Animation', function()
    if currentEmoteTrack then currentEmoteTrack:Stop() currentEmoteTrack:Destroy() currentEmoteTrack = nil end
end)

local UtilsGroupBox = Tabs.Player:AddLeftGroupbox('Player Utilities')
UtilsGroupBox:AddToggle('InfJumpToggle', { Text = 'Infinite Jump Enabled', Default = false })

local VoidGroupBox = Tabs.Player:AddLeftGroupbox('Void Teleport Settings')
VoidGroupBox:AddSlider('VoidSpamDepth', { Text = 'Void Depth (Y-Axis)', Default = -1000, Min = -5000, Max = -100, Rounding = 0 })

local PlayerBox = Tabs.Player:AddRightGroupbox('Movement Modification')
PlayerBox:AddToggle('StrafeToggle', { Text = 'Enable Target Strafe', Default = false })
PlayerBox:AddSlider('TeleportHeight', { Text = 'Teleport Height Offset', Default = 3.5, Min = 0, Max = 20, Rounding = 1 })
PlayerBox:AddSlider('StrafeDuration', { Text = 'Teleport Cycle Interval', Default = 0.5, Min = 0.1, Max = 2, Rounding = 1 })
PlayerBox:AddDropdown('MovementTargetMode', { Values = { 'Closest Player', 'Select Specific Player' }, Default = 1, Text = 'Target Priority' })
PlayerBox:AddDropdown('OrbitTargetPlayer', { SpecialType = 'Player', Text = 'Select Target Player' })

local OrbitGroupBox = Tabs.Player:AddRightGroupbox('Orbit Aura Physics')
OrbitGroupBox:AddToggle('OrbitToggle', { Text = 'Enable Orbit Aura', Default = false })
OrbitGroupBox:AddDropdown('OrbitTargetMode', { Values = { 'Map Center (0,0,0)', 'Tracked Target Position' }, Default = 2, Text = 'Anchor' })
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
EspGroupBox:AddToggle('EspHealthBar', { Text = 'Health Bar Status', Default = false }):AddColorPicker('HealthBarColor', { Default = Color3.fromRGB(0, 255, 100) })

-- =============================================================================
-- [ 4. WORLD EFFECTS TAB ]
-- =============================================================================
local WeatherGroupBox = Tabs.World:AddLeftGroupbox('Weather Systems')
local AmbientGroupBox = Tabs.World:AddRightGroupbox('Atmosphere')
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

-- =============================================================================
-- [ 5. MISC TAB ]
-- =============================================================================
local WeaponModBox = Tabs.Misc:AddLeftGroupbox('Network Packet Overclock')
WeaponModBox:AddToggle('FastFireToggle', { Text = 'Enable Multi-Packet Fire', Default = false })
WeaponModBox:AddSlider('FireRateMultiplier', { Text = 'Packet Multiplier', Default = 4, Min = 1, Max = 10, Rounding = 0 })

-- =============================================================================
-- [ 6. BACKEND CORE ENGINE (OPTIMIZED FOR NO-TIMEOUT) ]
-- =============================================================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local angle, antiAimAngle, lastStrafeTime, alternateVoid, lastNormalCFrame = 0, 0, 0, false, nil
local isClicking, isRightMouseDown = false, false
local espCache = {}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false

UserInputService.JumpRequest:Connect(function()
    if Toggles and Toggles.InfJumpToggle and Toggles.InfJumpToggle.Value and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

local function getClosestPlayerToMous()
    if not Options or not Options.Radius then return nil end
    local target, maxDist = nil, Options.Radius.Value
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

-- Timeout 방지를 위해 메타테이블 후킹 논리 최적화
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and method == "FireServer" and self.Name == "UseItem" and Toggles and Toggles.SilentEnabled and Toggles.SilentEnabled.Value then
        local args = {...}
        if math.random(1, 100) <= Options.HitChance.Value then
            local targetPlayer = getClosestPlayerToMous()
            if targetPlayer and targetPlayer.Character then
                local partName = (Toggles.ClosestPart and Toggles.ClosestPart.Value) and "Head" or "HumanoidRootPart"
                local targetPart = targetPlayer.Character:FindFirstChild(partName)
                
                if targetPart and args[3] and args[3]["\001"] then
                    local hitPos = targetPart.Position
                    if Toggles.PredictiveShot and Toggles.PredictiveShot.Value and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        hitPos = hitPos + (targetPlayer.Character.HumanoidRootPart.Velocity * 0.135) 
                    end
                    -- Argument Spoofing
                    if args[3]["\001"]["\001"] then
                        args[3]["\001"]["\001"]["\001"] = hitPos.X
                        args[3]["\001"]["\001"]["\000"] = hitPos.Y
                        args[3]["\001"]["\001"]["\002"] = hitPos.Z
                    end
                    args[3]["\001"]["\002"] = targetPart
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- Fast Fire 루프 최적화 (while true 루프 제거, 이벤트 기반으로 변경)
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
local UseItemRemote = Remotes and Remotes:WaitForChild("Replication", 5):WaitForChild("Fighter", 5):WaitForChild("UseItem", 5)

RunService.Heartbeat:Connect(function(dt)
    -- Fast Fire 로직
    if Toggles and Toggles.FastFireToggle and Toggles.FastFireToggle.Value and isClicking and UseItemRemote then
        local targetPlayer = getClosestPlayerToMous()
        local targetHrp = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        local customArgs = {
            [1] = "\207\147", [2] = "\026",
            [3] = { ["\001"] = {
                ["\001"] = { ["\001"] = 0, ["\000"] = 0, ["\003"] = 0, ["\002"] = 0, ["\005"] = 0, ["\004"] = 0 },
                ["\000"] = { ["\001"] = 0, ["\000"] = 0, ["\003"] = 0, ["\002"] = 0, ["\005"] = 0, ["\004"] = 0 },
                ["\003"] = { ["\001"] = 0, ["\000"] = 0, ["\003"] = 0, ["\002"] = 10, ["\005"] = 0, ["\004"] = 1.57 },
                ["\002"] = targetHrp or workspace
            }}
        }
        for i = 1, math.floor(Options.FireRateMultiplier.Value) do
            task.spawn(function() pcall(function() UseItemRemote:FireServer(unpack(customArgs)) end) end)
        end
    end

    -- Movement 로직 최적화
    if Toggles and Options and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local antiaim = Toggles.AntiAimToggle and Toggles.AntiAimToggle.Value
        
        if antiaim then
            antiAimAngle = antiAimAngle + (Options.AntiAimSpeed.Value * dt)
            local mode, aaRotation = Options.AntiAimMode.Value, CFrame.Identity
            if mode == 'Hyper Spinbot' then aaRotation = CFrame.Angles(0, antiAimAngle, 0)
            elseif mode == 'Backwards' then aaRotation = CFrame.Angles(0, math.rad(180), 0)
            elseif mode == 'Fake Jitter' then aaRotation = CFrame.Angles(0, math.rad(180) + ((tick() * 40) % 2 == 0 and math.rad(180) or 0), math.rad(25))
            end
            hrp.CFrame = CFrame.new(hrp.Position) * hrp.Rotation * aaRotation
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if Toggles and Toggles.ShowFOV and Toggles.ShowFOV.Value then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Options.Radius.Value
        FOVCircle.Color = Color3.fromRGB(255, 0, 50)
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
    
    if weatherAnchor and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        weatherAnchor.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 25, 0))
    end
    
    if Toggles and Toggles.AimbotEnabled and Toggles.AimbotEnabled.Value and isRightMouseDown then
        local targetPlayer = getClosestPlayerToMous()
        if targetPlayer and targetPlayer.Character then
            local targetPart = targetPlayer.Character:FindFirstChild(Options.AimbotPart.Value)
            if targetPart then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPart.Position), math.clamp(dt * (21 - Options.Smoothness.Value), 0, 1))
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, g) 
    if not g then 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then isClicking = true end 
        if i.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = true end
    end 
end)
UserInputService.InputEnded:Connect(function(i) 
    if i.UserInputType == Enum.UserInputType.MouseButton1 then isClicking = false end 
    if i.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = false end
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload Script', function() 
    pcall(function() FOVCircle:Destroy() if weatherAnchor then weatherAnchor:Destroy() end end)
    Library:Unload() 
end)

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
