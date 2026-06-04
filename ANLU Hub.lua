-- =============================================================================
-- ANLU Hub(Rivals) - ULTIMATE INTEGRATED EDITION (Perfect Switch Fix)
-- =============================================================================
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'ANLU Hub(Rivals) - FIXED LOGIC',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.1
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Player = Window:AddTab('Player'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- =============================================================================
-- [ 1. MAIN COMBAT TAB ]
-- =============================================================================
local AimbotTab = Tabs.Main:AddLeftGroupbox('카메라 락온 에임봇')
AimbotTab:AddToggle('AimbotEnabled', { Text = '카메라 에임봇 활성화', Default = false })
AimbotTab:AddSlider('Smoothness', { Text = '에임 부드러움 (Smoothing)', Default = 8, Min = 1, Max = 20, Rounding = 1 })
AimbotTab:AddDropdown('AimbotPart', { Values = { 'Head', 'HumanoidRootPart' }, Default = 1, Text = '조준 부위 설정' })

local SilentTab = Tabs.Main:AddRightGroupbox('하이퍼 사일런트 에임')
SilentTab:AddToggle('SilentEnabled', { Text = '사일런트 에임 활성화', Default = true })
SilentTab:AddToggle('WallBang', { Text = '벽 관통 판정 (Wall Bang)', Default = true })
SilentTab:AddToggle('PredictiveShot', { Text = '예측 샷 엔진 (Prediction)', Default = true })
SilentTab:AddToggle('ClosestPart', { Text = '가장 가까운 부위 자동 조준', Default = true })
SilentTab:AddToggle('ShowFOV', { Text = 'FOV 범위 표시', Default = false })
SilentTab:AddSlider('Radius', { Text = 'FOV 반지름 크기', Default = 400, Min = 0, Max = 1000, Rounding = 0 })
SilentTab:AddSlider('HitChance', { Text = '명중 확률 (Hit Chance)', Default = 100, Min = 0, Max = 100, Rounding = 0 })

local RageMainBox = Tabs.Main:AddRightGroupbox('하이드라 레이지 봇 (Rage)')
RageMainBox:AddToggle('RageBotToggle', { Text = '초고속 탄속 유도 활성화', Default = false })
RageMainBox:AddSlider('BaseVelocity', { Text = '최저 탄속 보장 범위', Default = 500, Min = 100, Max = 10000, Rounding = 0 })
RageMainBox:AddToggle('VoidSpamToggle', { Text = '보이드 스팸 (초고속 탈착)', Default = false })

-- =============================================================================
-- [ 2. PLAYER MOVEMENT TAB ]
-- =============================================================================
local PlayerBox = Tabs.Player:AddLeftGroupbox('이동 변조 (타겟 머리 위 텔포)')
PlayerBox:AddToggle('StrafeToggle', { Text = '타겟 머리 위 텔포 활성화', Default = false })
PlayerBox:AddSlider('TeleportHeight', { Text = '텔레포트 높이', Default = 3.5, Min = 0, Max = 20, Rounding = 1 })
PlayerBox:AddSlider('StrafeDuration', { Text = '텔포 작동 시간 주기', Default = 0.5, Min = 0.1, Max = 2, Rounding = 1 })
PlayerBox:AddDropdown('OrbitTargetPlayer', { SpecialType = 'Player', Text = '타겟 플레이어 선택' })

local OrbitGroupBox = Tabs.Player:AddLeftGroupbox('진짜 물리 오빗 설정 (Orbit Aura)')
OrbitGroupBox:AddToggle('OrbitToggle', { Text = '오빗 아우라 활성화', Default = false })
OrbitGroupBox:AddDropdown('OrbitTargetMode', { Values = { '맵 중심 (0,0,0)', '지정한 플레이어' }, Default = 2, Text = '회전 중심 기준' })
OrbitGroupBox:AddSlider('OrbitRadius', { Text = '회전 거리 (반지름)', Default = 8, Min = 2, Max = 100, Rounding = 0 })
OrbitGroupBox:AddSlider('OrbitSpeed', { Text = '회전 속도', Default = 150, Min = 1, Max = 500, Rounding = 0 })
OrbitGroupBox:AddSlider('OrbitHeight', { Text = '높이 오프셋 (Y축)', Default = 3, Min = -50, Max = 50, Rounding = 0 })

local UtilsGroupBox = Tabs.Player:AddRightGroupbox('플레이어 편의 기능 (Utils)')
UtilsGroupBox:AddToggle('InfJumpToggle', { Text = '무한 점프 활성화', Default = false })

local VoidGroupBox = Tabs.Player:AddLeftGroupbox('보이드 상세 설정')
VoidGroupBox:AddSlider('VoidSpamDepth', { Text = '보이드 깊이 (Y축)', Default = -1000, Min = -5000, Max = -100, Rounding = 0 })

-- =============================================================================
-- [ 3. VISUALS ESP TAB ]
-- =============================================================================
local EspGroupBox = Tabs.Visuals:AddLeftGroupbox('player options')
EspGroupBox:AddToggle('EspBox', { Text = 'box', Default = false }):AddColorPicker('BoxColor', { Default = Color3.fromRGB(255, 255, 255) })
EspGroupBox:AddToggle('EspFill', { Text = 'fill', Default = false }):AddColorPicker('FillColor', { Default = Color3.fromRGB(240, 200, 220) })
EspGroupBox:AddToggle('EspSkeleton', { Text = 'skeleton', Default = false }):AddColorPicker('SkeletonColor', { Default = Color3.fromRGB(255, 255, 255) })
EspGroupBox:AddToggle('EspName', { Text = 'name', Default = false }):AddColorPicker('NameColor', { Default = Color3.fromRGB(255, 255, 255) })
EspGroupBox:AddToggle('EspDistance', { Text = 'distance', Default = false }):AddColorPicker('DistanceColor', { Default = Color3.fromRGB(255, 255, 255) })
EspGroupBox:AddToggle('EspHealthBar', { Text = 'healthbar', Default = false }):AddColorPicker('HealthBarColor', { Default = Color3.fromRGB(0, 255, 100) })

-- =============================================================================
-- [ 4. MISC TAB ]
-- =============================================================================
local WeaponModBox = Tabs.Misc:AddLeftGroupbox('네트워크 패킷 하이퍼 연사')
WeaponModBox:AddToggle('FastFireToggle', { Text = '패킷 오버클럭 연사 활성화', Default = false })
WeaponModBox:AddSlider('FireRateMultiplier', { Text = '패킷 동시 복제 배율', Default = 4, Min = 1, Max = 10, Rounding = 0 })

-- =============================================================================
-- [ 5. BACKEND CORE ENGINE ]
-- =============================================================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local angle, lastStrafeTime, alternateVoid, lastNormalCFrame = 0, 0, false, nil
local isClicking = false
local isRightMouseDown = false
local espCache = {}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 50)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false

UserInputService.JumpRequest:Connect(function()
    if Toggles.InfJumpToggle.Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

local function getClosestPlayerToMous()
    local target = nil
    local maxDist = Options.Radius.Value
    local mousePos = UserInputService:GetMouseLocation()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen or Toggles.WallBang.Value then
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
    drawings.TopLabel.Parent = drawings.TopGui
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

                    if Toggles.EspBox.Value then
                        drawings.Box.Size = Vector2.new(sizeX, sizeY)
                        drawings.Box.Position = boxPos
                        drawings.Box.Color = Options.BoxColor.Value
                        drawings.Box.Visible = true
                    else
                        drawings.Box.Visible = false
                    end

                    if Toggles.EspFill.Value then
                        drawings.Fill.Size = Vector2.new(sizeX, sizeY)
                        drawings.Fill.Position = boxPos
                        drawings.Fill.Color = Options.FillColor.Value
                        drawings.Fill.Visible = true
                    else
                        drawings.Fill.Visible = false
                    end

                    if Toggles.EspHealthBar.Value then
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

                    if Toggles.EspSkeleton.Value then
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

                    if Toggles.EspName.Value or Toggles.EspDistance.Value then
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
        espCache[player].Box:Destroy()
        espCache[player].Fill:Destroy()
        espCache[player].HealthOutline:Destroy()
        espCache[player].HealthBar:Destroy()
        if espCache[player].TopGui then espCache[player].TopGui:Destroy() end
        for _, line in ipairs(espCache[player].Bones) do line:Destroy() end
        espCache[player] = nil
    end
end)

local function updateAimbot(dt)
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

-- 🌟 [정밀 변수 매칭 및 충돌 완전 해결 이동 연산]
local function updateMovement(dt)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetPlayer = Players:FindFirstChild(Options.OrbitTargetPlayer.Value or "")
    local targetHrp = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    -- UI 고유 스위치 바인딩 확인
    local strafe = Toggles.StrafeToggle.Value
    local orbit = Toggles.OrbitToggle.Value
    local void = Toggles.VoidSpamToggle.Value

    local targetHeadPos = targetHrp and (targetHrp.Position + Vector3.new(0, Options.TeleportHeight.Value, 0)) or nil
    local isStrafeActive = false

    -- 1. 타겟 머리 위 텔포 (Strafe) 로직 분기 (우선순위 1)
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

    -- 2. 오빗 아우라 (Orbit) 로직 분기 (우선순위 2 - 스트레이프가 꺼져있을 때만 작동)
    elseif orbit then
        local center = (Options.OrbitTargetMode.Value == '맵 중심 (0,0,0)') and Vector3.new(0,0,0) or (targetHrp and targetHrp.Position or hrp.Position)
        angle = angle + (Options.OrbitSpeed.Value * dt)
        
        local radius = Options.OrbitRadius.Value
        local height = Options.OrbitHeight.Value
        
        local x = center.X + math.cos(angle) * radius
        local z = center.Z + math.sin(angle) * radius
        local y = center.Y + height
        
        lastNormalCFrame = CFrame.lookAt(Vector3.new(x, y, z), center)
        
    else
        -- 아무 이동 기능도 활성화되어 있지 않으면 고정 해제
        lastNormalCFrame = nil
    end

    -- 최종 하드웨어 CFrame 밀어넣기 및 보이드 연산
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
-- [ 6. METATABLE HOOK ]
-- =============================================================================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Toggles.SilentEnabled.Value and self.Name == "UseItem" and method == "FireServer" then
        if math.random(1, 100) <= Options.HitChance.Value then
            local targetPlayer = getClosestPlayerToMous()
            if targetPlayer and targetPlayer.Character then
                local partName = Toggles.ClosestPart.Value and "Head" or "HumanoidRootPart"
                local targetPart = targetPlayer.Character:FindFirstChild(partName)
                
                if targetPart and args[3] and args[3]["\001"] then
                    local hitPos = targetPart.Position
                    
                    if Toggles.PredictiveShot.Value and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
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
    if Toggles.ShowFOV.Value then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Options.Radius.Value
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
    
    updateEsp()
    updateAimbot(dt)
end)

workspace.DescendantAdded:Connect(function(d) 
    if Toggles.RageBotToggle.Value and (d.Name:lower():find("bullet") or d.Name:lower():find("projectile") or d:IsA("BasePart")) then
        if d.Name:lower():find("bullet") or d.Name:lower():find("projectile") then
            task.spawn(function()
                pcall(function() 
                    d.CanCollide = false 
                    if d:IsA("BasePart") then d.Size = d.Size * 3 end 
                end)
                
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if not d or not d.Parent or not Toggles.RageBotToggle.Value then
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

local UseItemRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Replication"):WaitForChild("Fighter"):WaitForChild("UseItem")

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if Toggles.FastFireToggle.Value and isClicking then
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

RunService.Heartbeat:Connect(updateMovement)

-- =============================================================================
-- [ 7. UI SETTINGS ]
-- =============================================================================
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() 
    FOVCircle:Destroy() 
    for _, drawing in pairs(espCache) do
        drawing.Box:Destroy()
        drawing.Fill:Destroy()
        drawing.HealthOutline:Destroy()
        drawing.HealthBar:Destroy()
        if drawing.TopGui then drawing.TopGui:Destroy() end
        for _, line in ipairs(drawing.Bones) do line:Destroy() end
    end
    Library:Unload() 
end)

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
