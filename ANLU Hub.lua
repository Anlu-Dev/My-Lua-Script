-- =============================================================================
-- ANLU Hub(Rivals) - INTEGRATED FINAL VERSION (BUG FIX & SAFETY IMPLEMENTED)
-- =============================================================================
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'ANLU Hub(Rivals) - MULTI MULTI',
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
        
        local success, track = pcall(function()
            return animator:LoadAnimation(anim)
        end)
        
        if success and track then
            currentEmoteTrack = track
            currentEmoteTrack.Priority = Enum.AnimationPriority.Action4
            currentEmoteTrack:Play()
        end
    end
end

local EmotePresets = {
    ["Stop Emote"] = 0,
    ["Default Dance"] = 507468474,
    ["Floss"] = 10214312386,
    ["Take The L"] = 10214314410,
    ["Hype"] = 10214311896,
    ["Orange Justice"] = 10214312845,
    ["T-Pose"] = 10479375172,
    ["Griddy"] = 11130453311,
    ["Wave"] = 128743149,
    ["Dance 1"] = 182435877,
    ["Dance 2"] = 182436842,
    ["Dance 3"] = 182436935
}

local EmoteNames = {}
for name, _ in pairs(EmotePresets) do table.insert(EmoteNames, name) end
table.sort(EmoteNames)

EmoteGroupBox:AddDropdown('EmoteSelect', { 
    Values = EmoteNames, 
    Default = 1, 
    Text = 'Select Preset Emote',
    Callback = function(Value)
        selectedEmoteId = EmotePresets[Value] or 0
    end
})

EmoteGroupBox:AddInput('CustomEmoteId', {
    Default = '',
    Numeric = true,
    Finished = true,
    Text = 'Custom Animation ID',
    Placeholder = 'Paste Asset ID here...',
    Callback = function(Value)
        if Value and Value ~= '' then
            selectedEmoteId = tonumber(Value) or 0
        end
    end
})

EmoteGroupBox:AddButton('Play Animation', function()
    if selectedEmoteId and selectedEmoteId ~= 0 then
        PlayCustomEmote(selectedEmoteId)
    end
end)

EmoteGroupBox:AddButton('Stop Animation', function()
    if currentEmoteTrack then
        currentEmoteTrack:Stop()
        currentEmoteTrack:Destroy()
        currentEmoteTrack = nil
    end
end)

local UtilsGroupBox = Tabs.Player:AddLeftGroupbox('Player Utilities')
UtilsGroupBox:AddToggle('InfJumpToggle', { Text = 'Infinite Jump Enabled', Default = false })

local VoidGroupBox = Tabs.Player:AddLeftGroupbox('Void Teleport Settings')
VoidGroupBox:AddSlider('VoidSpamDepth', { Text = 'Void Depth (Y-Axis)', Default = -1000, Min = -5000, Max = -100, Rounding = 0 })

local PlayerBox = Tabs.Player:AddRightGroupbox('Movement Modification')
PlayerBox:AddToggle('StrafeToggle', { Text = 'Enable Target Strafe (Above Head)', Default = false })
PlayerBox:AddSlider('TeleportHeight', { Text = 'Teleport Height Offset', Default = 3.5, Min = 0, Max = 20, Rounding = 1 })
PlayerBox:AddSlider('StrafeDuration', { Text = 'Teleport Cycle Interval', Default = 0.5, Min = 0.1, Max = 2, Rounding = 1 })
PlayerBox:AddDropdown('MovementTargetMode', { Values = { 'Closest Player', 'Select Specific Player' }, Default = 1, Text = 'Target Tracking Priority' })
PlayerBox:AddDropdown('OrbitTargetPlayer', { SpecialType = 'Player', Text = 'Select Target Player' })

local OrbitGroupBox = Tabs.Player:AddRightGroupbox('Orbit Aura Physics')
OrbitGroupBox:AddToggle('OrbitToggle', { Text = 'Enable Orbit Aura', Default = false })
OrbitGroupBox:AddDropdown('OrbitTargetMode', { Values = { 'Map Center (0,0,0)', 'Tracked Target Position' }, Default = 2, Text = 'Rotation Center Anchor' })
OrbitGroupBox:AddSlider('OrbitRadius', { Text = 'Orbit Radius Distance', Default = 8, Min = 2, Max = 100, Rounding = 0 })
OrbitGroupBox:AddSlider('OrbitSpeed', { Text = 'Orbit Rotation Speed', Default = 150, Min = 1, Max = 500, Rounding = 0 })
OrbitGroupBox:AddSlider('OrbitHeight', { Text = 'Orbit Height Offset (Y-Axis)', Default = 3, Min = -50, Max = 50, Rounding = 0 })

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
    weatherAnchor.CanTouch = false
    weatherAnchor.CanQuery = false
    weatherAnchor.Parent = workspace
end

local snowPE, rainPE = nil, nil

WeatherGroupBox:AddToggle('SnowEffect', { Text = 'Enable Snow Effect', Default = false }):OnChanged(function()
    local enabled = Toggles.SnowEffect.Value
    if enabled then
        if not snowPE then
            snowPE = Instance.new("ParticleEmitter")
            snowPE.Name = "ANLU_Snow"
            snowPE.Texture = "rbxassetid://1084991211" 
            snowPE.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.3)})
            snowPE.Lifetime = NumberRange.new(2, 4)
            snowPE.Rate = 200
            snowPE.Speed = NumberRange.new(20, 35)
            snowPE.SpreadAngle = Vector2.new(30, 30)
            snowPE.LockedToPart = true
            snowPE.Acceleration = Vector3.new(0, -10, 0)
            snowPE.Parent = weatherAnchor
        end
    else
        if snowPE then snowPE:Destroy() snowPE = nil end
    end
end)

WeatherGroupBox:AddToggle('RainEffect', { Text = 'Enable Rain Effect', Default = false }):OnChanged(function()
    local enabled = Toggles.RainEffect.Value
    if enabled then
        if not rainPE then
            rainPE = Instance.new("ParticleEmitter")
            rainPE.Name = "ANLU_Rain"
            rainPE.Texture = "rbxassetid://363276166" 
            rainPE.Size = NumberSequence.new(0.2)
            rainPE.Lifetime = NumberRange.new(1, 1.5)
            rainPE.Rate = 500
            rainPE.Speed = NumberRange.new(90, 130)
            rainPE.SpreadAngle = Vector2.new(10, 10)
            rainPE.LockedToPart = true
            rainPE.Acceleration = Vector3.new(-15, -50, 0)
            rainPE.Parent = weatherAnchor
        end
    else
        if rainPE then rainPE:Destroy() rainPE = nil end
    end
end)

AmbientGroupBox:AddSlider('AtmosphereDensity', { Text = 'Atmosphere Density', Default = 0, Min = 0, Max = 100, Rounding = 0 }):OnChanged(function()
    local value = Options.AtmosphereDensity.Value / 100
    local lighting = game:GetService("Lighting")
    local atmos = lighting:FindFirstChildOfClass("Atmosphere")
    
    if not atmos then
        atmos = Instance.new("Atmosphere")
        atmos.Parent = lighting
    end
    atmos.Density = value
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
local isClicking = false
local isRightMouseDown = false
local espCache = {}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 50)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false

UserInputService.JumpRequest:Connect(function()
    if Toggles and Toggles.InfJumpToggle and Toggles.InfJumpToggle.Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
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
                if dist < maxDist then
                    maxDist = dist
                    target = p
                end
            end
        end
    end
    return target
end

local function getClosestPlayerToChar()
    local target = nil
    local maxDist = math.huge
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local tHrp = p.Character.HumanoidRootPart
            local dist = (myHrp.Position - tHrp.Position).Magnitude
            if dist < maxDist then
                maxDist = dist
                target = p
            end
        end
    end
    return target
end

local function createEspDrawings(player)
    local drawings = {
        Box = Drawing.new("Square"),
        Fill = Drawing.new("Square"),
        HealthOutline = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Bones = {},
        TopGui = Instance.new("BillboardGui"),
        TopLabel = Instance.new("TextLabel"),
    }
    
    drawings.Box.Thickness = 1.5
    drawings.Box.Filled = false
    drawings.Box.Visible = false

    drawings.Fill.Filled = true
    drawings.Fill.Transparency = 0.35
    drawings.Fill.Visible = false

    drawings.HealthOutline.Filled = true
    drawings.HealthOutline.Color = Color3.fromRGB(0, 0, 0)
    drawings.HealthOutline.Visible = false
    
    drawings.HealthBar.Filled = true
    drawings.HealthBar.Visible = false

    for i = 1, 15 do
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Visible = false
        table.insert(drawings.Bones, line)
    end

    drawings.TopGui.AlwaysOnTop = true
    drawings.TopGui.Size = UDim2.new(0, 200, 0, 50)
    drawings.TopGui.Name = "ANLU_Top_" .. player.Name
    
    drawings.TopLabel.Size = UDim2.new(1, 0, 1, 0)
    drawings.TopLabel.BackgroundTransparency = 1
    drawings.TopLabel.Font = Enum.Font.GothamBold
    drawings.TopLabel.TextSize = 14
    drawings.TopLabel.TextStrokeTransparency = 0
    drawings.TopLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    drawings.TopLabel.Parent = drawings.TopLabel.Parent or drawings.TopGui
    drawings.TopGui.Parent = CoreGui

    return drawings
end

local function drawBoneLine(line, part1, part2)
    if part1 and part2 then
        local p1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
        local p2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)
        if onScreen1 and onScreen2 then
            line.From = Vector2.new(p1.X, p1.Y)
            line.To = Vector2.new(p2.X, p2.Y)
            return true
        end
    end
    return false
end

local function updateEsp()
    if not Toggles or not Options then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local drawings = espCache[player]
        if not drawings then
            drawings = createEspDrawings(player)
            espCache[player] = drawings
        end

        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if hrp and head and humanoid and humanoid.Health > 0 then
            local _, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                local headCFrame = head.CFrame
                local rootCFrame = hrp.CFrame
                
                local topWorld = headCFrame.Position + Vector3.new(0, 1.8, 0)
                local bottomWorld = rootCFrame.Position - Vector3.new(0, 3.2, 0)
                
                local topScreen, topOn = Camera:WorldToViewportPoint(topWorld)
                local bottomScreen, bottomOn = Camera:WorldToViewportPoint(bottomWorld)
                
                if topOn and bottomOn then
                    local sizeY = math.abs(topScreen.Y - bottomScreen.Y)
                    local sizeX = sizeY * 0.65
                    local boxPos = Vector2.new(topScreen.X - (sizeX / 2), topScreen.Y)

                    if Toggles.EspBox and Toggles.EspBox.Value then
                        drawings.Box.Size = Vector2.new(sizeX, sizeY)
                        drawings.Box.Position = boxPos
                        drawings.Box.Color = Options.BoxColor.Value
                        drawings.Box.Visible = true
                    else
                        drawings.Box.Visible = false
                    end

                    if Toggles.EspFill and Toggles.EspFill.Value then
                        drawings.Fill.Size = Vector2.new(sizeX, sizeY)
                        drawings.Fill.Position = boxPos
                        drawings.Fill.Color = Options.FillColor.Value
                        drawings.Fill.Visible = true
                    else
                        drawings.Fill.Visible = false
                    end

                    if Toggles.EspHealthBar and Toggles.EspHealthBar.Value then
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        local barHeight = sizeY * healthPercent
                        local barPos = Vector2.new(boxPos.X - 6, boxPos.Y)
                        
                        drawings.HealthOutline.Size = Vector2.new(3, sizeY)
                        drawings.HealthOutline.Position = barPos
                        drawings.HealthOutline.Visible = true
                        
                        drawings.HealthBar.Size = Vector2.new(3, barHeight)
                        drawings.HealthBar.Position = Vector2.new(barPos.X, boxPos.Y + (sizeY - barHeight))
                        drawings.HealthBar.Color = Options.HealthBarColor.Value
                        drawings.HealthBar.Visible = true
                    else
                        drawings.HealthOutline.Visible = false
                        drawings.HealthBar.Visible = false
                    end

                    if Toggles.EspSkeleton and Toggles.EspSkeleton.Value then
                        local boneColor = Options.SkeletonColor.Value
                        for _, line in ipairs(drawings.Bones) do line.Color = boneColor line.Visible = false end
                        
                        local p = {
                            Head = head, Torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"),
                            LeftArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm"),
                            RightArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm"),
                            LeftForearm = character:FindFirstChild("LeftLowerArm"), RightForearm = character:FindFirstChild("RightLowerArm"),
                            LeftHand = character:FindFirstChild("LeftHand"), RightHand = character:FindFirstChild("RightHand"),
                            LowerTorso = character:FindFirstChild("LowerTorso"),
                            LeftThigh = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg"),
                            RightThigh = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg"),
                            LeftCalf = character:FindFirstChild("LeftLowerLeg"), RightCalf = character:FindFirstChild("RightLowerLeg"),
                            LeftFoot = character:FindFirstChild("LeftFoot"), RightFoot = character:FindFirstChild("RightFoot")
                        }

                        local lineIdx = 1
                        local function connect(p1, p2)
                            if drawBoneLine(drawings.Bones[lineIdx], p1, p2) then
                                drawings.Bones[lineIdx].Visible = true
                                lineIdx = lineIdx + 1
                            end
                        end

                        connect(p.Head, p.Torso)
                        if p.LowerTorso then connect(p.Torso, p.LowerTorso) end
                        
                        local baseTorso = p.Torso
                        connect(baseTorso, p.LeftArm)
                        if p.LeftForearm then connect(p.LeftArm, p.LeftForearm) connect(p.LeftForearm, p.LeftHand) end
                        
                        connect(baseTorso, p.RightArm)
                        if p.RightForearm then connect(p.RightArm, p.RightForearm) connect(p.RightForearm, p.RightHand) end
                        
                        local hipBase = p.LowerTorso or p.Torso
                        connect(hipBase, p.LeftThigh)
                        if p.LeftCalf then connect(p.LeftThigh, p.LeftCalf) connect(p.LeftCalf, p.LeftFoot) end
                        
                        connect(hipBase, p.RightThigh)
                        if p.RightCalf then connect(p.RightThigh, p.RightCalf) connect(p.RightCalf, p.RightFoot) end
                    else
                        for _, line in ipairs(drawings.Bones) do line.Visible = false end
                    end

                    if (Toggles.EspName and Toggles.EspName.Value) or (Toggles.EspDistance and Toggles.EspDistance.Value) then
                        drawings.TopGui.Adornee = head
                        drawings.TopGui.StudsOffset = Vector3.new(0, 4.0, 0)
                        local finalString = ""
                        
                        if Toggles.EspName.Value then
                            finalString = player.DisplayName or player.Name
                            drawings.TopLabel.TextColor3 = Options.NameColor.Value
                        end
                        
                        if Toggles.EspDistance.Value then
                            local dist = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
                            if finalString ~= "" then
                                finalString = finalString .. " \n[" .. tostring(dist) .. "m]"
                            else
                                finalString = "[" .. tostring(dist) .. "m]"
                                drawings.TopLabel.TextColor3 = Options.DistanceColor.Value
                            end
                        end
                        
                        drawings.TopLabel.Text = finalString
                        drawings.TopGui.Enabled = true
                    else
                        drawings.TopGui.Enabled = false
                    end
                else
                    drawings.Box.Visible = false
                    drawings.Fill.Visible = false
                    drawings.HealthOutline.Visible = false
                    drawings.HealthBar.Visible = false
                    drawings.TopGui.Enabled = false
                    for _, line in ipairs(drawings.Bones) do line.Visible = false end
                end
            else
                drawings.Box.Visible = false
                drawings.Fill.Visible = false
                drawings.HealthOutline.Visible = false
                drawings.HealthBar.Visible = false
                drawings.TopGui.Enabled = false
                for _, line in ipairs(drawings.Bones) do line.Visible = false end
            end
        else
            drawings.Box.Visible = false
            drawings.Fill.Visible = false
            drawings.HealthOutline.Visible = false
            drawings.HealthBar.Visible = false
            drawings.TopGui.Enabled = false
            for _, line in ipairs(drawings.Bones) do line.Visible = false end
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    if espCache[player] then
        pcall(function()
            if espCache[player].Box then espCache[player].Box:Destroy() end
            if espCache[player].Fill then espCache[player].Fill:Destroy() end
            if espCache[player].HealthOutline then espCache[player].HealthOutline:Destroy() end
            if espCache[player].HealthBar then espCache[player].HealthBar:Destroy() end
            if espCache[player].TopGui then espCache[player].TopGui:Destroy() end
            if espCache[player].Bones then
                for _, line in ipairs(espCache[player].Bones) do line:Destroy() end
            end
        end)
        espCache[player] = nil
    end
end)

local function updateAimbot(dt)
    if not Toggles or not Toggles.AimbotEnabled then return end
    if Toggles.AimbotEnabled.Value and isRightMouseDown then
        local targetPlayer = getClosestPlayerToMous()
        if targetPlayer and targetPlayer.Character then
            local targetPart = targetPlayer.Character:FindFirstChild(Options.AimbotPart.Value)
            if targetPart then
                local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
                local smoothing = Options.Smoothness.Value
                local alpha = math.clamp(dt * (21 - smoothing), 0, 1)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
            end
        end
    end
end

local function updateMovement(dt)
    if not Toggles or not Options then return end
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local strafe = Toggles.StrafeToggle and Toggles.StrafeToggle.Value
    local orbit = Toggles.OrbitToggle and Toggles.OrbitToggle.Value
    local void = Toggles.VoidSpamToggle and Toggles.VoidSpamToggle.Value
    local antiaim = Toggles.AntiAimToggle and Toggles.AntiAimToggle.Value

    if not strafe and not orbit and not void and not antiaim then
        return 
    end

    local targetPlayer = nil
    if Options.MovementTargetMode.Value == 'Closest Player' then
        targetPlayer = getClosestPlayerToChar()
    else
        targetPlayer = Players:FindFirstChild(Options.OrbitTargetPlayer.Value or "")
    end

    local targetHrp = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHeadPos = targetHrp and (targetHrp.Position + Vector3.new(0, Options.TeleportHeight.Value, 0)) or nil
    local isStrafeActive = false

    if strafe and targetHeadPos then
        local now = tick()
        local cycle = Options.StrafeDuration.Value
        if now - lastStrafeTime < cycle then
            isStrafeActive = true
        elseif now - lastStrafeTime > (cycle * 2) then
            lastStrafeTime = now
        end
        
        if isStrafeActive then
            local lookAtPos = Vector3.new(targetHrp.Position.X, targetHeadPos.Y, targetHrp.Position.Z)
            lastNormalCFrame = CFrame.lookAt(targetHeadPos, lookAtPos)
        else
            lastNormalCFrame = hrp.CFrame
        end

    elseif orbit then
        local center = (Options.OrbitTargetMode.Value == 'Map Center (0,0,0)') and Vector3.new(0,0,0) or (targetHrp and targetHrp.Position or hrp.Position)
        angle = angle + (Options.OrbitSpeed.Value * dt)
        
        local radius = Options.OrbitRadius.Value
        local height = Options.OrbitHeight.Value
        
        local x = center.X + math.cos(angle) * radius
        local z = center.Z + math.sin(angle) * radius
        local y = center.Y + height
        
        lastNormalCFrame = CFrame.lookAt(Vector3.new(x, y, z), center)
        
    else
        lastNormalCFrame = hrp.CFrame
    end

    if antiaim and lastNormalCFrame then
        antiAimAngle = antiAimAngle + (Options.AntiAimSpeed.Value * dt)
        local mode = Options.AntiAimMode.Value
        local aaRotation = CFrame.Identity

        if mode == 'Hyper Spinbot' then
            aaRotation = CFrame.Angles(0, antiAimAngle, 0)
        elseif mode == 'Backwards' then
            aaRotation = CFrame.Angles(0, math.rad(180), 0)
        elseif mode == 'Matrix Break' then
            local randomX = math.rad(math.random(-60, 60))
            local randomY = math.rad(math.random(-180, 180))
            local randomZ = math.rad(math.random(-45, 45))
            aaRotation = CFrame.Angles(randomX, randomY, randomZ)
        elseif mode == 'Pitch Flip' then
            local flipY = (tick() * 30) % 2 == 0 and math.rad(85) or math.rad(-85)
            aaRotation = CFrame.Angles(flipY, antiAimAngle, 0)
        elseif mode == 'Fake Jitter' then
            local jitter = (tick() * 40) % 2 == 0 and math.rad(180) or math.rad(0)
            aaRotation = CFrame.Angles(0, math.rad(180) + jitter, math.rad(25))
        end
        lastNormalCFrame = CFrame.new(lastNormalCFrame.Position) * lastNormalCFrame.Rotation * aaRotation
    end

    if lastNormalCFrame then
        if void then
            if alternateVoid then
                hrp.CFrame = CFrame.new(lastNormalCFrame.Position.X, Options.VoidSpamDepth.Value, lastNormalCFrame.Position.Z) * lastNormalCFrame.Rotation
                alternateVoid = false
            else
                hrp.CFrame = lastNormalCFrame
                alternateVoid = true
            end
        else
            hrp.CFrame = lastNormalCFrame
        end
        
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
    end
end

-- =============================================================================
-- [ 7. METATABLE HOOK ]
-- =============================================================================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Toggles and Toggles.SilentEnabled and Toggles.SilentEnabled.Value and self.Name == "UseItem" and method == "FireServer" then
        if math.random(1, 100) <= Options.HitChance.Value then
            local targetPlayer = getClosestPlayerToMous()
            if targetPlayer and targetPlayer.Character then
                local partName = (Toggles.ClosestPart and Toggles.ClosestPart.Value) and "Head" or "HumanoidRootPart"
                local targetPart = targetPlayer.Character:FindFirstChild(partName)
                
                if targetPart and args[3] and args[3]["\001"] then
                    local hitPos = targetPart.Position
                    
                    if Toggles.PredictiveShot and Toggles.PredictiveShot.Value and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local velocity = targetPlayer.Character.HumanoidRootPart.Velocity
                        hitPos = hitPos + (velocity * 0.135) 
                    end
                    
                    if args[3]["\001"]["\001"] then
                        args[3]["\001"]["\001"]["\001"] = hitPos.X
                        args[3]["\001"]["\001"]["\000"] = hitPos.Y
                        args[3]["\001"]["\001"]["\002"] = hitPos.Z
                    end
                    if args[3]["\001"]["\000"] then
                        args[3]["\001"]["\000"]["\001"] = hitPos.X
                        args[3]["\001"]["\000"]["\000"] = hitPos.Y
                        args[3]["\001"]["\000"]["\002"] = hitPos.Z
                    end
                    args[3]["\001"]["\002"] = targetPart
                end
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

RunService.RenderStepped:Connect(function(dt)
    if Toggles and Toggles.ShowFOV and Toggles.ShowFOV.Value then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Options.Radius.Value
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
    
    if weatherAnchor and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myHrp = LocalPlayer.Character.HumanoidRootPart
        weatherAnchor.CFrame = CFrame.new(myHrp.Position + Vector3.new(0, 25, 0))
    end
    
    pcall(updateEsp)
    pcall(updateAimbot, dt)
end)

workspace.DescendantAdded:Connect(function(d) 
    if Toggles and Toggles.RageBotToggle and Toggles.RageBotToggle.Value and (d.Name:lower():find("bullet") or d.Name:lower():find("projectile") or d:IsA("BasePart")) then
        if d.Name:lower():find("bullet") or d.Name:lower():find("projectile") then
            task.spawn(function()
                pcall(function() 
                    d.CanCollide = false 
                    if d:IsA("BasePart") then d.Size = d.Size * 3 end 
                end)
                
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if not d or not d.Parent or not Toggles or not Toggles.RageBotToggle or not Toggles.RageBotToggle.Value then
                        if connection then connection:Disconnect() end
                        return
                    end
                    
                    local targetPlayer = getClosestPlayerToMous()
                    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
                        local targetHead = targetPlayer.Character.Head
                        local distance = (targetHead.Position - d.Position).Magnitude
                        local direction = (targetHead.Position - d.Position).Unit
                        
                        local finalSpeed = Options.BaseVelocity.Value
                        
                        if distance < (finalSpeed * 0.016) then
                            d.CFrame = CFrame.new(targetHead.Position)
                        else
                            d.Velocity = direction * finalSpeed
                            d.CFrame = CFrame.lookAt(d.Position, targetHead.Position)
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
    end 
end)
UserInputService.InputEnded:Connect(function(i) 
    if i.UserInputType == Enum.UserInputType.MouseButton1 then isClicking = false end 
    if i.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = false end
end)

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
local Replication = Remotes and Remotes:WaitForChild("Replication", 5)
local Fighter = Replication and Replication:WaitForChild("Fighter", 5)
local UseItemRemote = Fighter and Fighter:WaitForChild("UseItem", 5)

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if Toggles and Toggles.FastFireToggle and Toggles.FastFireToggle.Value and isClicking and UseItemRemote then
            local targetPlayer = getClosestPlayerToMous()
            local targetHrp = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            local customArgs = {
                [1] = "\207\147",
                [2] = "\026",
                [3] = {
                    ["\001"] = {
                        ["\001"] = { ["\001"] = 0, ["\000"] = 0, ["\003"] = 0, ["\002"] = 0, ["\005"] = 0, ["\004"] = 0 },
                        ["\000"] = { ["\001"] = 0, ["\000"] = 0, ["\003"] = 0, ["\002"] = 0, ["\005"] = 0, ["\004"] = 0 },
                        ["\003"] = { ["\001"] = 0, ["\000"] = 0, ["\003"] = 0, ["\002"] = 10, ["\005"] = 0, ["\004"] = 1.57 },
                        ["\002"] = targetHrp or workspace
                    }
                }
            }

            for i = 1, math.floor(Options.FireRateMultiplier.Value) do
                task.spawn(function()
                    pcall(function()
                        UseItemRemote:FireServer(unpack(customArgs))
                    end)
                end)
            end
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    pcall(updateMovement, dt)
end)

-- =============================================================================
-- [ 8. UI SETTINGS ]
-- =============================================================================
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload Script', function() 
    pcall(function()
        FOVCircle:Destroy() 
        if weatherAnchor then weatherAnchor:Destroy() end
        if currentEmoteTrack then currentEmoteTrack:Stop() currentEmoteTrack:Destroy() end
        for _, drawing in pairs(espCache) do
            if drawing.Box then drawing.Box:Destroy() end
            if drawing.Fill then drawing.Fill:Destroy() end
            if drawing.HealthOutline then drawing.HealthOutline:Destroy() end
            if drawing.HealthBar then drawing.HealthBar:Destroy() end
            if drawing.TopGui then drawing.TopGui:Destroy() end
            if drawing.Bones then
                for _, line in ipairs(drawing.Bones) do line:Destroy() end
            end
        end
    end)
    Library:Unload() 
end)

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
