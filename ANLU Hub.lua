-- =============================================================================
-- ANLU Hub(Rivals) - PRO EDITION (UI SETTINGS & UTILITIES UPGRADED)
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
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local glitchConnection = nil
local keyStates = {W = false, A = false, S = false, D = false}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then keyStates.W = true end
    if input.KeyCode == Enum.KeyCode.A then keyStates.A = true end
    if input.KeyCode == Enum.KeyCode.S then keyStates.S = true end
    if input.KeyCode == Enum.KeyCode.D then keyStates.D = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then keyStates.W = false end
    if input.KeyCode == Enum.KeyCode.A then keyStates.A = false end
    if input.KeyCode == Enum.KeyCode.S then keyStates.S = false end
    if input.KeyCode == Enum.KeyCode.D then keyStates.D = false end
end)

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
        Library:Notify('🕺 Static WASD Glitch Enabled!', 3)
    else
        Library:Notify('Glitch Stopped', 2)
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
local Camera = workspace.CurrentCamera

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
-- [ 5. MISC TAB ] 
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
        else
            Library:Notify('❌ Please equip a tool to duplicate first!', 3)
        end
    else
        Library:Notify('❌ Backpack not found.', 3)
    end
end)

-- =============================================================================
-- [ 6. BACKEND CORE ENGINE ]
-- =============================================================================
local angle, antiAimAngle, lastStrafeTime, alternateVoid, lastNormalCFrame = 0, 0, 0, false, nil
local isClicking, isRightMouseDown = false, false
local espCache = {}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 50)
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

local function getClosestPlayerToChar()
    local target = nil
    local maxDist = math.huge
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (myHrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < maxDist then maxDist = dist target = p end
        end
    end
    return target
end

-- [ ESP ENGINE ]
local function createEspDrawings(player)
    local d = { Box = Drawing.new("Square"), Fill = Drawing.new("Square"), HealthOutline = Drawing.new("Square"), HealthBar = Drawing.new("Square"), Bones = {}, TopGui = Instance.new("BillboardGui"), TopLabel = Instance.new("TextLabel") }
    d.Box.Thickness = 1.5 d.Box.Filled = false d.Box.Visible = false
    d.Fill.Filled = true d.Fill.Transparency = 0.35 d.Fill.Visible = false
    d.HealthOutline.Filled = true d.HealthOutline.Color = Color3.fromRGB(0,0,0) d.HealthOutline.Visible = false
    d.HealthBar.Filled = true d.HealthBar.Visible = false
    for i = 1, 15 do local l = Drawing.new("Line") l.Thickness = 1.5 l.Visible = false table.insert(d.Bones, l) end
    d.TopGui.AlwaysOnTop = true d.TopGui.Size = UDim2.new(0, 200, 0, 50) d.TopGui.Name = "ANLU_Top_"..player.Name
    d.TopLabel.Size = UDim2.new(1,0,1,0) d.TopLabel.BackgroundTransparency = 1 d.TopLabel.Font = Enum.Font.GothamBold d.TopLabel.TextSize = 14 d.TopLabel.TextStrokeTransparency = 0 d.TopLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0) d.TopLabel.Parent = d.TopGui
    d.TopGui.Parent = CoreGui
    return d
end

local function drawBoneLine(line, p1, p2)
    if p1 and p2 then
        local pos1, on1 = Camera:WorldToViewportPoint(p1.Position)
        local pos2, on2 = Camera:WorldToViewportPoint(p2.Position)
        if on1 and on2 then line.From = Vector2.new(pos1.X, pos1.Y) line.To = Vector2.new(pos2.X, pos2.Y) return true end
    end
    return false
end

local function updateEsp()
    if not Toggles or not Options then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local d = espCache[player]
        if not d then d = createEspDrawings(player) espCache[player] = d end

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hrp and head and hum and hum.Health > 0 then
            local _, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local top, topOn = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.8, 0))
                local bot, botOn = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))
                
                if topOn and botOn then
                    local sizeY = math.abs(top.Y - bot.Y)
                    local sizeX = sizeY * 0.65
                    local boxPos = Vector2.new(top.X - (sizeX / 2), top.Y)

                    d.Box.Size = Vector2.new(sizeX, sizeY) d.Box.Position = boxPos d.Box.Color = Options.BoxColor.Value d.Box.Visible = Toggles.EspBox.Value
                    d.Fill.Size = Vector2.new(sizeX, sizeY) d.Fill.Position = boxPos d.Fill.Color = Options.FillColor.Value d.Fill.Visible = Toggles.EspFill.Value
                    
                    if Toggles.EspHealthBar.Value then
                        local pct = hum.Health / hum.MaxHealth
                        d.HealthOutline.Size = Vector2.new(3, sizeY) d.HealthOutline.Position = Vector2.new(boxPos.X - 6, boxPos.Y) d.HealthOutline.Visible = true
                        d.HealthBar.Size = Vector2.new(3, sizeY * pct) d.HealthBar.Position = Vector2.new(boxPos.X - 6, boxPos.Y + (sizeY - (sizeY * pct))) d.HealthBar.Color = Options.HealthBarColor.Value d.HealthBar.Visible = true
                    else d.HealthOutline.Visible = false d.HealthBar.Visible = false end

                    if Toggles.EspSkeleton.Value then
                        local bc = Options.SkeletonColor.Value
                        for _, l in ipairs(d.Bones) do l.Color = bc l.Visible = false end
                        local p = { Head=head, Torso=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"), LeftArm=char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"), RightArm=char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"), LeftForearm=char:FindFirstChild("LeftLowerArm"), RightForearm=char:FindFirstChild("RightLowerArm"), LeftHand=char:FindFirstChild("LeftHand"), RightHand=char:FindFirstChild("RightHand"), LowerTorso=char:FindFirstChild("LowerTorso"), LeftThigh=char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"), RightThigh=char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"), LeftCalf=char:FindFirstChild("LeftLowerLeg"), RightCalf=char:FindFirstChild("RightLowerLeg"), LeftFoot=char:FindFirstChild("LeftFoot"), RightFoot=char:FindFirstChild("RightFoot") }
                        local idx = 1
                        local function conn(p1, p2) if drawBoneLine(d.Bones[idx], p1, p2) then d.Bones[idx].Visible = true idx = idx + 1 end end
                        conn(p.Head, p.Torso) if p.LowerTorso then conn(p.Torso, p.LowerTorso) end
                        conn(p.Torso, p.LeftArm) if p.LeftForearm then conn(p.LeftArm, p.LeftForearm) conn(p.LeftForearm, p.LeftHand) end
                        conn(p.Torso, p.RightArm) if p.RightForearm then conn(p.RightArm, p.RightForearm) conn(p.RightForearm, p.RightHand) end
                        local hip = p.LowerTorso or p.Torso
                        conn(hip, p.LeftThigh) if p.LeftCalf then conn(p.LeftThigh, p.LeftCalf) conn(p.LeftCalf, p.LeftFoot) end
                        conn(hip, p.RightThigh) if p.RightCalf then conn(p.RightThigh, p.RightCalf) conn(p.RightCalf, p.RightFoot) end
                    else for _, l in ipairs(d.Bones) do l.Visible = false end end

                    if Toggles.EspName.Value or Toggles.EspDistance.Value then
                        d.TopGui.Adornee = head
                        local str = ""
                        if Toggles.EspName.Value then str = player.DisplayName d.TopLabel.TextColor3 = Options.NameColor.Value end
                        if Toggles.EspDistance.Value then 
                            local dist = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
                            str = str ~= "" and str.."\n["..dist.."m]" or "["..dist.."m]"
                            if not Toggles.EspName.Value then d.TopLabel.TextColor3 = Options.DistanceColor.Value end
                        end
                        d.TopLabel.Text = str d.TopGui.Enabled = true
                    else d.TopGui.Enabled = false end
                else
                    d.Box.Visible=false d.Fill.Visible=false d.HealthOutline.Visible=false d.HealthBar.Visible=false d.TopGui.Enabled=false
                    for _, l in ipairs(d.Bones) do l.Visible=false end
                end
            else
                d.Box.Visible=false d.Fill.Visible=false d.HealthOutline.Visible=false d.HealthBar.Visible=false d.TopGui.Enabled=false
                for _, l in ipairs(d.Bones) do l.Visible=false end
            end
        else
            d.Box.Visible=false d.Fill.Visible=false d.HealthOutline.Visible=false d.HealthBar.Visible=false d.TopGui.Enabled=false
            for _, l in ipairs(d.Bones) do l.Visible=false end
        end
    end
end

-- [ NOCLIP SYSTEM ]
RunService.Stepped:Connect(function()
    if Toggles and Toggles.NoclipToggle and Toggles.NoclipToggle.Value and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- [ FLY & MOVEMENT SYSTEM ]
local FlyKeys = {W = false, A = false, S = false, D = false, Space = false, LeftControl = false}
local autoStrafeSide = 1
local lastAutoStrafe = tick()

local function updateFly()
    if not Toggles or not Options then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if Toggles.FlyToggle and Toggles.FlyToggle.Value and hrp then
        local camCFrame = Camera.CFrame
        local moveDir = Vector3.new(0, 0, 0)

        if FlyKeys.W then moveDir = moveDir + camCFrame.LookVector end
        if FlyKeys.S then moveDir = moveDir - camCFrame.LookVector end
        if FlyKeys.A then moveDir = moveDir - camCFrame.RightVector end
        if FlyKeys.D then moveDir = moveDir + camCFrame.RightVector end
        if FlyKeys.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if FlyKeys.LeftControl then moveDir = moveDir - Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end

        local bv = hrp:FindFirstChild("ANLU_Fly")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "ANLU_Fly"
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Parent = hrp
        end
        bv.Velocity = moveDir * Options.FlySpeed.Value

        if not Toggles.AntiAimToggle.Value and not Toggles.GlitchDanceToggle.Value then
            local bg = hrp:FindFirstChild("ANLU_FlyGyro")
            if not bg then
                bg = Instance.new("BodyGyro")
                bg.Name = "ANLU_FlyGyro"
                bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                bg.P = 10000
                bg.Parent = hrp
            end
            bg.CFrame = CFrame.new(hrp.Position, hrp.Position + camCFrame.LookVector * 100)
        else
            if hrp:FindFirstChild("ANLU_FlyGyro") then hrp.ANLU_FlyGyro:Destroy() end
        end
    else
        if hrp then
            if hrp:FindFirstChild("ANLU_Fly") then hrp.ANLU_Fly:Destroy() end
            if hrp:FindFirstChild("ANLU_FlyGyro") then hrp.ANLU_FlyGyro:Destroy() end
        end
    end
end

local function updateMovement(dt)
    if not Toggles or not Options then return end
    if Toggles.GlitchDanceToggle and Toggles.GlitchDanceToggle.Value then return end
    if Toggles.FlyToggle and Toggles.FlyToggle.Value then return end 

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local strafe, orbit, void, antiaim = Toggles.StrafeToggle.Value, Toggles.OrbitToggle.Value, Toggles.VoidSpamToggle.Value, Toggles.AntiAimToggle.Value
    if not strafe and not orbit and not void and not antiaim then 
        if Toggles.AutoStrafeToggle and Toggles.AutoStrafeToggle.Value then
            if tick() - lastAutoStrafe > 0.15 then
                autoStrafeSide = autoStrafeSide * -1
                lastAutoStrafe = tick()
            end
            hrp.CFrame = hrp.CFrame + (hrp.CFrame.RightVector * (autoStrafeSide * Options.AutoStrafeSpeed.Value * dt))
        end
        return 
    end

    local targetPlayer = Options.MovementTargetMode.Value == 'Closest Player' and getClosestPlayerToChar() or Players:FindFirstChild(Options.OrbitTargetPlayer.Value or "")
    local targetHrp = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHeadPos = targetHrp and (targetHrp.Position + Vector3.new(0, Options.TeleportHeight.Value, 0)) or nil

    if strafe and targetHeadPos then
        local now, cycle = tick(), Options.StrafeDuration.Value
        if now - lastStrafeTime > (cycle * 2) then lastStrafeTime = now end
        lastNormalCFrame = (now - lastStrafeTime < cycle) and CFrame.lookAt(targetHeadPos, Vector3.new(targetHrp.Position.X, targetHeadPos.Y, targetHrp.Position.Z)) or hrp.CFrame
    elseif orbit then
        local center = Options.OrbitTargetMode.Value == 'Map Center (0,0,0)' and Vector3.new(0,0,0) or (targetHrp and targetHrp.Position or hrp.Position)
        angle = angle + (Options.OrbitSpeed.Value * dt)
        lastNormalCFrame = CFrame.lookAt(Vector3.new(center.X + math.cos(angle)*Options.OrbitRadius.Value, center.Y + Options.OrbitHeight.Value, center.Z + math.sin(angle)*Options.OrbitRadius.Value), center)
    else
        lastNormalCFrame = hrp.CFrame
    end

    if antiaim and lastNormalCFrame then
        antiAimAngle = antiAimAngle + (Options.AntiAimSpeed.Value * dt)
        local m, aa = Options.AntiAimMode.Value, CFrame.Identity
        if m == 'Hyper Spinbot' then aa = CFrame.Angles(0, antiAimAngle, 0)
        elseif m == 'Backwards' then aa = CFrame.Angles(0, math.rad(180), 0)
        elseif m == 'Matrix Break' then aa = CFrame.Angles(math.rad(math.random(-60,60)), math.rad(math.random(-180,180)), math.rad(math.random(-45,45)))
        elseif m == 'Pitch Flip' then aa = CFrame.Angles((tick()*30)%2==0 and math.rad(85) or math.rad(-85), antiAimAngle, 0)
        elseif m == 'Fake Jitter' then aa = CFrame.Angles(0, math.rad(180) + ((tick()*40)%2==0 and math.rad(180) or 0), math.rad(25)) end
        lastNormalCFrame = CFrame.new(lastNormalCFrame.Position) * lastNormalCFrame.Rotation * aa
    end

    if lastNormalCFrame then
        if void then
            alternateVoid = not alternateVoid
            hrp.CFrame = alternateVoid and lastNormalCFrame or CFrame.new(lastNormalCFrame.Position.X, Options.VoidSpamDepth.Value, lastNormalCFrame.Position.Z) * lastNormalCFrame.Rotation
        else hrp.CFrame = lastNormalCFrame end
        hrp.Velocity, hrp.RotVelocity = Vector3.zero, Vector3.zero
    end
end

-- [ Namecall Hooks ]
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

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

RunService.RenderStepped:Connect(function(dt)
    if Toggles.ShowFOV.Value then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Options.Radius.Value
        FOVCircle.Visible = true
    else FOVCircle.Visible = false end
    
    if weatherAnchor and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        weatherAnchor.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 25, 0))
    end
    pcall(updateEsp)
    
    if Toggles.AimbotEnabled.Value and isRightMouseDown then
        local targetPlayer = getClosestPlayerToMous()
        if targetPlayer and targetPlayer.Character then
            local targetPart = targetPlayer.Character:FindFirstChild(Options.AimbotPart.Value)
            if targetPart then Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPart.Position), math.clamp(dt * (21 - Options.Smoothness.Value), 0, 1)) end
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    pcall(updateFly)
    pcall(updateMovement, dt)
end)

local UseItemRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
if UseItemRemote then UseItemRemote = UseItemRemote:WaitForChild("Replication", 5) end
if UseItemRemote then UseItemRemote = UseItemRemote:WaitForChild("Fighter", 5) end
if UseItemRemote then UseItemRemote = UseItemRemote:WaitForChild("UseItem", 5) end

task.spawn(function()
    while task.wait(0.1) do
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
    end
end)

workspace.DescendantAdded:Connect(function(d) 
    if Toggles and Toggles.RageBotToggle and Toggles.RageBotToggle.Value and (d.Name:lower():find("bullet") or d.Name:lower():find("projectile") or d:IsA("BasePart")) then
        if d.Name:lower():find("bullet") or d.Name:lower():find("projectile") then
            task.spawn(function()
                pcall(function() d.CanCollide = false if d:IsA("BasePart") then d.Size = d.Size * 3 end end)
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if not d or not d.Parent or not Toggles.RageBotToggle.Value then connection:Disconnect() return end
                    local tp = getClosestPlayerToMous()
                    if tp and tp.Character and tp.Character:FindFirstChild("Head") then
                        local head = tp.Character.Head
                        local dist = (head.Position - d.Position).Magnitude
                        local spd = Options.BaseVelocity.Value
                        if dist < (spd * 0.016) then d.CFrame = CFrame.new(head.Position) else
                            d.Velocity = (head.Position - d.Position).Unit * spd
                            d.CFrame = CFrame.lookAt(d.Position, head.Position)
                        end
                    end
                end)
            end)
        end
    end 
end)

UserInputService.InputBegan:Connect(function(i, g) 
    if not g then 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then isClicking = true end 
        if i.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = true end 
        if i.KeyCode == Enum.KeyCode.W then FlyKeys.W = true end
        if i.KeyCode == Enum.KeyCode.A then FlyKeys.A = true end
        if i.KeyCode == Enum.KeyCode.S then FlyKeys.S = true end
        if i.KeyCode == Enum.KeyCode.D then FlyKeys.D = true end
        if i.KeyCode == Enum.KeyCode.Space then FlyKeys.Space = true end
        if i.KeyCode == Enum.KeyCode.LeftControl then FlyKeys.LeftControl = true end
    end 
end)

UserInputService.InputEnded:Connect(function(i, g) 
    if i.UserInputType == Enum.UserInputType.MouseButton1 then isClicking = false end 
    if i.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = false end 
    if i.KeyCode == Enum.KeyCode.W then FlyKeys.W = false end
    if i.KeyCode == Enum.KeyCode.A then FlyKeys.A = false end
    if i.KeyCode == Enum.KeyCode.S then FlyKeys.S = false end
    if i.KeyCode == Enum.KeyCode.D then FlyKeys.D = false end
    if i.KeyCode == Enum.KeyCode.Space then FlyKeys.Space = false end
    if i.KeyCode == Enum.KeyCode.LeftControl then FlyKeys.LeftControl = false end
end)

Players.PlayerRemoving:Connect(function(player)
    if espCache[player] then
        pcall(function()
            if espCache[player].Box then espCache[player].Box:Destroy() end
            if espCache[player].Fill then espCache[player].Fill:Destroy() end
            if espCache[player].HealthOutline then espCache[player].HealthOutline:Destroy() end
            if espCache[player].HealthBar then espCache[player].HealthBar:Destroy() end
            if espCache[player].TopGui then espCache[player].TopGui:Destroy() end
            if espCache[player].Bones then for _, l in ipairs(espCache[player].Bones) do l:Destroy() end end
        end)
        espCache[player] = nil
    end
end)

-- =============================================================================
-- [ 7. UI SETTINGS & MANAGERS ] (Here is the Massive Upgrade!)
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
        for _, d in pairs(espCache) do
            if d.Box then d.Box:Destroy() end if d.Fill then d.Fill:Destroy() end
            if d.HealthOutline then d.HealthOutline:Destroy() end if d.HealthBar then d.HealthBar:Destroy() end
            if d.TopGui then d.TopGui:Destroy() end if d.Bones then for _, l in ipairs(d.Bones) do l:Destroy() end end
        end
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

ExtraBox:AddToggle('ShowKeybinds', { Text = 'Show Active Keybinds', Default = false }):OnChanged(function()
    Library.KeybindFrame.Visible = Toggles.ShowKeybinds.Value
end)

-- Properly initializing the Managers so the UI Settings tab fills up completely
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('ANLUHub')
SaveManager:SetFolder('ANLUHub/Rivals')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
