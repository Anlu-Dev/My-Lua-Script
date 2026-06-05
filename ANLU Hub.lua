-- =============================================================================
-- ANLU Hub(Rivals) - PRO EDITION (EMOTE ENGINE OVERRIDE FIXED)
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
-- [ 2. PLAYER MOVEMENT & EMOTE TAB ] (여기 핵심 수정됨)
-- =============================================================================
local EmoteGroupBox = Tabs.Player:AddLeftGroupbox('Hydra Emote Studio')
local currentEmoteTrack = nil

local function PlayCustomEmote(animationId)
    local Players = game:GetService("Players")
    local character = Players.LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        if currentEmoteTrack then currentEmoteTrack:Stop() currentEmoteTrack:Destroy() currentEmoteTrack = nil end
        if animationId == 0 then return end
        
        local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
        
        -- [해결] FPS 총기 모션 등 진행 중인 애니메이션 강제 정지!
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            track:Stop()
        end
        
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. tostring(animationId)
        
        local success, track = pcall(function() return animator:LoadAnimation(anim) end)
        if success and track then
            currentEmoteTrack = track
            currentEmoteTrack.Priority = Enum.AnimationPriority.Action4 -- 최우선 순위
            currentEmoteTrack:Play()
            Library:Notify('🕺 이모트 재생 성공!', 3)
        else
            Library:Notify('❌ 로블록스에서 차단된 ID거나 권한이 없습니다.', 3)
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

EmoteGroupBox:AddDropdown('EmoteSelect', { Values = EmoteNames, Default = 1, Text = 'Select Preset Emote' })
EmoteGroupBox:AddInput('CustomEmoteId', { Default = '', Numeric = true, Finished = true, Text = 'Custom Animation ID', Placeholder = 'Paste Asset ID...' })

-- [해결] 버튼을 누를 때마다 UI 창의 현재 값을 실시간으로 읽어와서 동기화 오류 방지
EmoteGroupBox:AddButton('Play Animation', function() 
    local customId = tonumber(Options.CustomEmoteId.Value)
    if customId and customId > 0 then
        PlayCustomEmote(customId)
    else
        local presetId = EmotePresets[Options.EmoteSelect.Value]
        if presetId and presetId ~= 0 then PlayCustomEmote(presetId) end
    end
end)

EmoteGroupBox:AddButton('Stop Animation', function() 
    if currentEmoteTrack then currentEmoteTrack:Stop() currentEmoteTrack:Destroy() currentEmoteTrack = nil end 
    Library:Notify('멈춤 완료', 2)
end)

local UtilsGroupBox = Tabs.Player:AddLeftGroupbox('Player Utilities')
UtilsGroupBox:AddToggle('InfJumpToggle', { Text = 'Infinite Jump Enabled', Default = false })

local VoidGroupBox = Tabs.Player:AddLeftGroupbox('Void Teleport Settings')
VoidGroupBox:AddSlider('VoidSpamDepth', { Text = 'Void Depth (Y-Axis)', Default = -1000, Min = -5000, Max = -100, Rounding = 0 })

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
-- [ 5. MISC TAB ]
-- =============================================================================
local WeaponModBox = Tabs.Misc:AddLeftGroupbox('Network Packet Overclock')
WeaponModBox:AddToggle('FastFireToggle', { Text = 'Enable Multi-Packet Fire', Default = false })
WeaponModBox:AddSlider('FireRateMultiplier', { Text = 'Packet Replication Multiplier', Default = 4, Min = 1, Max = 10, Rounding = 0 })

-- =============================================================================
-- [ 6. BACKEND CORE ENGINE ]
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

local function updateMovement(dt)
    if not Toggles or not Options then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local strafe, orbit, void, antiaim = Toggles.StrafeToggle.Value, Toggles.OrbitToggle.Value, Toggles.VoidSpamToggle.Value, Toggles.AntiAimToggle.Value
    if not strafe and not orbit and not void and not antiaim then return end

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

UserInputService.InputBegan:Connect(function(i, g) if not g then if i.UserInputType == Enum.UserInputType.MouseButton1 then isClicking = true end if i.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = true end end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isClicking = false end if i.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = false end end)

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

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload Script', function() 
    pcall(function()
        FOVCircle:Destroy() if weatherAnchor then weatherAnchor:Destroy() end
        if currentEmoteTrack then currentEmoteTrack:Stop() currentEmoteTrack:Destroy() end
        for _, d in pairs(espCache) do
            if d.Box then d.Box:Destroy() end if d.Fill then d.Fill:Destroy() end
            if d.HealthOutline then d.HealthOutline:Destroy() end if d.HealthBar then d.HealthBar:Destroy() end
            if d.TopGui then d.TopGui:Destroy() end if d.Bones then for _, l in ipairs(d.Bones) do l:Destroy() end end
        end
    end)
    Library:Unload() 
end)

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
