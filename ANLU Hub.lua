-- =============================================================================
-- ANLU Hub(Rivals) - PRO EDITION (KOREAN TRANSLATION & STATIC GLITCH)
-- =============================================================================
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'ANLU Hub(Rivals) - 프로 에디션',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.1
})

-- 탭 이름 한글화
local Tabs = {
    Main = Window:AddTab('메인(전투)'),
    Player = Window:AddTab('플레이어(무빙)'),
    Visuals = Window:AddTab('시각효과(ESP)'),
    Misc = Window:AddTab('기타'),
    ['UI Settings'] = Window:AddTab('메뉴 설정')
}

-- =============================================================================
-- [ 1. MAIN COMBAT TAB ]
-- =============================================================================
local AimbotTab = Tabs.Main:AddLeftGroupbox('카메라 자동 조준 (에임봇)')
AimbotTab:AddToggle('AimbotEnabled', { Text = '에임봇 켜기 (우클릭)', Default = false })
AimbotTab:AddSlider('Smoothness', { Text = '에임 부드러움 조절', Default = 8, Min = 1, Max = 20, Rounding = 1 })
AimbotTab:AddDropdown('AimbotPart', { Values = { 'Head', 'HumanoidRootPart' }, Default = 1, Text = '조준 부위 설정' })

local SilentTab = Tabs.Main:AddRightGroupbox('하이퍼 사일런트 에임')
SilentTab:AddToggle('SilentEnabled', { Text = '사일런트 에임 켜기', Default = true })
SilentTab:AddToggle('WallBang', { Text = '월뱅 (벽 뚫고 쏘기)', Default = true })
SilentTab:AddToggle('ShowFOV', { Text = '인식 범위(FOV) 원 표시', Default = false })
SilentTab:AddSlider('Radius', { Text = '인식 범위(FOV) 크기', Default = 400, Min = 0, Max = 1000, Rounding = 0 })

-- =============================================================================
-- [ 2. PLAYER & WASD GLITCH EMOTE TAB ] 
-- =============================================================================
local GlitchGroupBox = Tabs.Player:AddLeftGroupbox('시점 고정 WASD 글리치 댄스')

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local glitchConnection = nil

-- WASD 키 입력 상태 확인용 변수
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
    if glitchConnection then
        glitchConnection:Disconnect()
        glitchConnection = nil
    end

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
            
            -- 시점(피격 판정) 고정
            char.HumanoidRootPart.Velocity = Vector3.zero
            char.HumanoidRootPart.RotVelocity = Vector3.zero
            
            -- W/S 입력: 앞뒤로 꺾기
            if keyStates.W or keyStates.S then
                local sMod = keyStates.W and 1 or -1
                if rootJoint then rootJoint.Transform = CFrame.Angles(math.sin(t) * 0.8 * sMod, 0, 0) end
                if neck then neck.Transform = CFrame.Angles(math.sin(t * 1.5) * 0.7 * sMod, 0, math.rad(90) * sMod) end
            end
            
            -- A/D 입력: 양팔 휘젓기
            if keyStates.A or keyStates.D then
                local sMod = keyStates.A and 1 or -1
                if rShoulder then rShoulder.Transform = CFrame.new(math.sin(t) * 2 * sMod, 0, 0) * CFrame.Angles(math.pi, math.sin(t) * sMod, 0) end
                if lShoulder then lShoulder.Transform = CFrame.new(math.sin(t) * -2 * sMod, 0, 0) * CFrame.Angles(math.pi, math.sin(t) * sMod, 0) end
            end
            
            -- 입력 없을 때: 기괴하게 대기
            if not keyStates.W and not keyStates.A and not keyStates.S and not keyStates.D then
                if rootJoint then rootJoint.Transform = CFrame.Angles(0, math.sin(t * 0.2) * 0.5, math.rad( tick() * 200 ) % 360) end
                if neck then neck.Transform = CFrame.Angles(math.sin(t) * 0.9, 0, 0) end
                if rShoulder then rShoulder.Transform = CFrame.Angles(math.rad(tick() * 100), math.rad(80), 0) end
            end
        end)
        Library:Notify('🕺 고정형 WASD 글리치 가동! (적들이 나를 못 맞춤)', 3)
    else
        Library:Notify('글리치 댄스 중지', 2)
    end
end

GlitchGroupBox:AddToggle('GlitchDanceToggle', { Text = 'WASD 글리치 모드 켜기', Default = false }):OnChanged(function()
    ToggleStationaryGlitch(Toggles.GlitchDanceToggle.Value)
end)

local UtilsGroupBox = Tabs.Player:AddLeftGroupbox('플레이어 유틸리티')
UtilsGroupBox:AddToggle('InfJumpToggle', { Text = '무한 점프 켜기', Default = false })

-- =============================================================================
-- [ 3. VISUALS ESP TAB ]
-- =============================================================================
local VisualsMainBox = Tabs.Visuals:AddLeftGroupbox('핵심 시각 효과')
VisualsMainBox:AddToggle('EspEnabled', { Text = '플레이어 위치 표시 (ESP)', Default = false })

-- =============================================================================
-- [ 4. MISC TAB ]
-- =============================================================================
local WeaponModBox = Tabs.Misc:AddLeftGroupbox('무기 설정 (오버클럭)')
WeaponModBox:AddToggle('FastFireToggle', { Text = '초고속 연사 켜기', Default = false })
WeaponModBox:AddSlider('FireRateMultiplier', { Text = '연사 배속 조절', Default = 4, Min = 1, Max = 10, Rounding = 0 })

-- =============================================================================
-- [ 5. BACKEND CORE ENGINE ]
-- =============================================================================
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local isRightMouseDown = false

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

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and typeof(self) == "Instance" and self.Name == "UseItem" and method == "FireServer" then
        if Toggles and Toggles.SilentEnabled and Toggles.SilentEnabled.Value then
            local targetPlayer = getClosestPlayerToMous()
            if targetPlayer and targetPlayer.Character then
                local targetPart = targetPlayer.Character:FindFirstChild("Head") or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if targetPart and args[3] and type(args[3]) == "table" and args[3]["\001"] then
                    local hitPos = targetPart.Position
                    if args[3]["\001"]["\001"] then args[3]["\001"]["\001"]["\001"] = hitPos.X args[3]["\001"]["\001"]["\000"] = hitPos.Y args[3]["\001"]["\001"]["\002"] = hitPos.Z end
                    args[3]["\001"]["\002"] = targetPart
                end
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

RunService.RenderStepped:Connect(function(dt)
    if Toggles.AimbotEnabled.Value and isRightMouseDown then
        local targetPlayer = getClosestPlayerToMous()
        if targetPlayer and targetPlayer.Character then
            local targetPart = targetPlayer.Character:FindFirstChild(Options.AimbotPart.Value)
            if targetPart then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPart.Position), math.clamp(dt * (21 - Options.Smoothness.Value), 0, 1))
            end
        end
    end
end)

local UseItemRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
if UseItemRemote then UseItemRemote = UseItemRemote:WaitForChild("Replication", 5) end
if UseItemRemote then UseItemRemote = UseItemRemote:WaitForChild("Fighter", 5) end
if UseItemRemote then UseItemRemote = UseItemRemote:WaitForChild("UseItem", 5) end

task.spawn(function()
    while task.wait(0.1) do
        if Toggles and Toggles.FastFireToggle and Toggles.FastFireToggle.Value and UseItemRemote then
            if isRightMouseDown then 
                local targetPlayer = getClosestPlayerToMous()
                local targetHrp = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                local customArgs = {
                    [1] = "\207\147", [2] = "\026",
                    [3] = { ["\001"] = {
                        ["\002"] = targetHrp or workspace
                    }}
                }
                for i = 1, math.floor(Options.FireRateMultiplier.Value) do
                    task.spawn(function() pcall(function() UseItemRemote:FireServer(unpack(customArgs)) end) end)
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, g) if not g and i.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = false end end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('설정 메뉴')
MenuGroup:AddButton('스크립트 끄기 (Unload)', function() 
    pcall(function()
        if glitchConnection then glitchConnection:Disconnect() end
    end)
    Library:Unload() 
end)

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
