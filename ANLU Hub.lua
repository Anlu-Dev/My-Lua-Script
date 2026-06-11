-- =============================================================================
-- ANLU Hub(Rivals) - PRO EDITION (ULTIMATE HEADSHOT + ZERO DROP + UNLOCK ALL + KILL AURA + GOD MODE)
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local angle, antiAimAngle, lastStrafeTime, alternateVoid, lastNormalCFrame = 0, 0, 0, false, nil
local isClicking, isRightMouseDown = false, false
local espCache = {}
local CachedSilentTarget = nil -- ✅ [최적화] 매 프레임 타겟 연산 캐싱용 변수 추가

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 50)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false

-- =============================================================================
-- [ 🌟 UNLOCK ALL DATA & CORE INITIALIZATION ]
-- =============================================================================
_G.UnlockAllActive = false
_G.HooksInitialized = false
_G.AxiomEquipped = {}
_G.AxiomFavorites = {}
_G.LastUsedWeapon = nil
_G.ConstructingWeapon = nil
_G.ViewingProfile = nil

local function InitUnlockAll()
    if _G.HooksInitialized then return end
    _G.HooksInitialized = true

    local controllers = LocalPlayer.PlayerScripts:WaitForChild("Controllers", 10)
    
    _G.EnumLibrary = require(ReplicatedStorage.Modules:WaitForChild("EnumLibrary", 10))
    if _G.EnumLibrary then _G.EnumLibrary:WaitForEnumBuilder() end
    _G.CosmeticLibrary = require(ReplicatedStorage.Modules:WaitForChild("CosmeticLibrary", 10))
    _G.ItemLibrary = require(ReplicatedStorage.Modules:WaitForChild("ItemLibrary", 10))
    _G.DataController = require(controllers:WaitForChild("PlayerDataController", 10))
    pcall(function() _G.FighterController = require(controllers:WaitForChild("FighterController", 10)) end)

    _G.CosmeticLibrary.OwnsCosmeticNormally = function() return true end
    _G.CosmeticLibrary.OwnsCosmeticUniversally = function() return true end
    _G.CosmeticLibrary.OwnsCosmeticForWeapon = function() return true end

    local origOwns = _G.CosmeticLibrary.OwnsCosmetic
    _G.CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
        if not _G.UnlockAllActive then return origOwns(self, inventory, name, weapon) end 
        if type(name) == "string" and name:find("MISSING_") then return origOwns(self, inventory, name, weapon) end
        return true
    end

    local origGet = _G.DataController.Get
    _G.DataController.Get = function(self, key)
        local data = origGet(self, key)
        if not _G.UnlockAllActive then return data end 

        if key == "CosmeticInventory" then
            local proxy = data and table.clone(data) or {}
            return setmetatable(proxy, { __index = function() return true end })
        end
        if key == "FavoritedCosmetics" then
            local result = data and table.clone(data) or {}
            for weapon, favs in pairs(_G.AxiomFavorites) do
                result[weapon] = result[weapon] or {}
                for name, isFav in pairs(favs) do result[weapon][name] = isFav end
            end
            return result
        end
        return data
    end

    local origGetWeaponData = _G.DataController.GetWeaponData
    _G.DataController.GetWeaponData = function(self, weaponName)
        local data = origGetWeaponData(self, weaponName)
        if not _G.UnlockAllActive then return data end 
        
        if not data then return nil end
        if _G.AxiomEquipped[weaponName] then
            local merged = table.clone(data)
            merged.Name = weaponName
            for cType, cData in pairs(_G.AxiomEquipped[weaponName]) do
                merged[cType] = cData
            end
            return merged
        end
        return data
    end

    local ClientItem
    pcall(function() ClientItem = require(LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem) end)

    if ClientItem and ClientItem._CreateViewModel then
        local origCreateViewModel = ClientItem._CreateViewModel
        ClientItem._CreateViewModel = function(self, viewmodelRef)
            if not _G.UnlockAllActive then return origCreateViewModel(self, viewmodelRef) end 
            
            local weaponName = self.Name
            local weaponPlayer = self.ClientFighter and self.ClientFighter.Player
            _G.ConstructingWeapon = (weaponPlayer == LocalPlayer) and weaponName or nil
            
            if weaponPlayer == LocalPlayer and _G.AxiomEquipped[weaponName] and _G.AxiomEquipped[weaponName].Skin and viewmodelRef then
                local dataKey = self:ToEnum("Data")
                local skinKey = self:ToEnum("Skin")
                local nameKey = self:ToEnum("Name")
                if viewmodelRef[dataKey] then
                    viewmodelRef[dataKey][skinKey] = _G.AxiomEquipped[weaponName].Skin
                    viewmodelRef[dataKey][nameKey] = _G.AxiomEquipped[weaponName].Skin.Name
                elseif viewmodelRef.Data then
                    viewmodelRef.Data.Skin = _G.AxiomEquipped[weaponName].Skin
                    viewmodelRef.Data.Name = _G.AxiomEquipped[weaponName].Skin.Name
                end
            end
            local result = origCreateViewModel(self, viewmodelRef)
            _G.ConstructingWeapon = nil
            return result
        end
    end

    local viewModelModule = LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
    if viewModelModule then
        local ClientViewModel = require(viewModelModule)
        if ClientViewModel.GetWrap then
            local origGetWrap = ClientViewModel.GetWrap
            ClientViewModel.GetWrap = function(self)
                if not _G.UnlockAllActive then return origGetWrap(self) end 
                
                local weaponName = self.ClientItem and self.ClientItem.Name
                local weaponPlayer = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
                if weaponName and weaponPlayer == LocalPlayer and _G.AxiomEquipped[weaponName] and _G.AxiomEquipped[weaponName].Wrap then
                    return _G.AxiomEquipped[weaponName].Wrap
                end
                return origGetWrap(self)
            end
        end

        local origNew = ClientViewModel.new
        ClientViewModel.new = function(replicatedData, clientItem)
            if not _G.UnlockAllActive then return origNew(replicatedData, clientItem) end 
            
            local weaponPlayer = clientItem.ClientFighter and clientItem.ClientFighter.Player
            local weaponName = _G.ConstructingWeapon or clientItem.Name
            if weaponPlayer == LocalPlayer and _G.AxiomEquipped[weaponName] then
                local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
                local dataKey = ReplicatedClass:ToEnum("Data")
                replicatedData[dataKey] = replicatedData[dataKey] or {}
                local cosmetics = _G.AxiomEquipped[weaponName]
                if cosmetics.Skin then replicatedData[dataKey][ReplicatedClass:ToEnum("Skin")] = cosmetics.Skin end
                if cosmetics.Wrap then replicatedData[dataKey][ReplicatedClass:ToEnum("Wrap")] = cosmetics.Wrap end
                if cosmetics.Charm then replicatedData[dataKey][ReplicatedClass:ToEnum("Charm")] = cosmetics.Charm end
            end
            local result = origNew(replicatedData, clientItem)
            if weaponPlayer == LocalPlayer and _G.AxiomEquipped[weaponName] and _G.AxiomEquipped[weaponName].Wrap and result._UpdateWrap then
                result:_UpdateWrap()
                task.delay(0.1, function() pcall(function() if not result._destroyed then result:_UpdateWrap() end end) end)
            end
            return result
        end
    end

    local origGetVMImage = _G.ItemLibrary.GetViewModelImageFromWeaponData
    _G.ItemLibrary.GetViewModelImageFromWeaponData = function(self, weaponData, highRes)
        if not _G.UnlockAllActive then return origGetVMImage(self, weaponData, highRes) end 
        
        if not weaponData then return origGetVMImage(self, weaponData, highRes) end
        local weaponName = weaponData.Name
        local hasSkin = _G.AxiomEquipped[weaponName] and _G.AxiomEquipped[weaponName].Skin
        local matchesSkin = weaponData.Skin and hasSkin and weaponData.Skin == _G.AxiomEquipped[weaponName].Skin
        local profileView = _G.ViewingProfile == LocalPlayer and hasSkin
        
        if (matchesSkin or profileView) and hasSkin then
            local skinInfo = self.ViewModels[_G.AxiomEquipped[weaponName].Skin.Name]
            if skinInfo then
                return skinInfo[highRes and "ImageHighResolution" or "Image"] or skinInfo.Image
            end
        end
        return origGetVMImage(self, weaponData, highRes)
    end

    local ClientEntity
    pcall(function() ClientEntity = require(LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity) end)
    if ClientEntity and ClientEntity.ReplicateFromServer then
        local origReplicate = ClientEntity.ReplicateFromServer
        ClientEntity.ReplicateFromServer = function(self, action, ...)
            if not _G.UnlockAllActive then return origReplicate(self, action, ...) end 
            
            if action == "FinisherEffect" then
                local args = {...}
                local killerName = args[3]
                local decodedKiller = killerName
                if type(killerName) == "userdata" and _G.EnumLibrary and _G.EnumLibrary.FromEnum then
                    local ok, decoded = pcall(_G.EnumLibrary.FromEnum, _G.EnumLibrary, killerName)
                    if ok and decoded then decodedKiller = decoded end
                end
                
                local isOurKill = tostring(decodedKiller):lower() == LocalPlayer.Name:lower()
                if isOurKill and _G.LastUsedWeapon and _G.AxiomEquipped[_G.LastUsedWeapon] and _G.AxiomEquipped[_G.LastUsedWeapon].Finisher then
                    local finisherData = _G.AxiomEquipped[_G.LastUsedWeapon].Finisher
                    local finisherEnum = finisherData.Enum
                    if not finisherEnum and _G.EnumLibrary then
                        local ok, result = pcall(_G.EnumLibrary.ToEnum, _G.EnumLibrary, finisherData.Name)
                        if ok and result then finisherEnum = result end
                    end
                    if finisherEnum then
                        args[1] = finisherEnum
                        return origReplicate(self, action, unpack(args))
                    end
                end
            end
            return origReplicate(self, action, ...)
        end
    end
end

-- =============================================================================
-- [ 1. MAIN COMBAT TAB ]
-- =============================================================================
local AimbotTab = Tabs.Main:AddLeftGroupbox('Camera Lock-on Aimbot')
AimbotTab:AddToggle('AimbotEnabled', { Text = 'Enable Camera Aimbot', Default = false })
AimbotTab:AddSlider('Smoothness', { Text = 'Aimbot Smoothing', Default = 8, Min = 1, Max = 100, Rounding = 1 })
AimbotTab:AddDropdown('AimbotPart', { Values = { 'Head', 'HumanoidRootPart' }, Default = 1, Text = 'Target Part' })

local RageMainBox = Tabs.Main:AddLeftGroupbox('Hydra Rage Bot (ULTIMATE)')
RageMainBox:AddToggle('RageBotToggle', { Text = 'Enable Instant Bullet Magnet', Default = false })
RageMainBox:AddSlider('BaseVelocity', { Text = 'Bullet Speed Multiplier', Default = 1000000, Min = 100, Max = 10000000, Rounding = 0 })
RageMainBox:AddSlider('DropCompensation', { Text = 'Headshot Drop Comp (Y-Offset)', Default = 1.5, Min = 0, Max = 10, Rounding = 1 })
RageMainBox:AddToggle('AutoShootToggle', { Text = 'Enable Auto-Shoot (Kill Aura)', Default = false })
RageMainBox:AddToggle('KillAllToggle', { Text = 'Enable AOE (Kill All Players)', Default = false })
RageMainBox:AddToggle('HitboxExpander', { Text = 'Enable Head Hitbox Expander', Default = false })
RageMainBox:AddSlider('HitboxSize', { Text = 'Hitbox Size (Studs)', Default = 20, Min = 5, Max = 100, Rounding = 0 })
RageMainBox:AddToggle('AntiDamage', { Text = 'Delete Enemy Bullets (God Mode)', Default = false })

local SilentTab = Tabs.Main:AddRightGroupbox('Hyper Silent Aim')
SilentTab:AddToggle('SilentEnabled', { Text = 'Enable Silent Aim', Default = true })
SilentTab:AddToggle('WallBang', { Text = 'Wall Bang (Penetration)', Default = true })
SilentTab:AddToggle('PredictiveShot', { Text = 'Prediction Engine', Default = true })
SilentTab:AddToggle('ShowFOV', { Text = 'Show FOV Circle', Default = false })
SilentTab:AddSlider('Radius', { Text = 'FOV Radius Size', Default = 400, Min = 0, Max = 1000, Rounding = 0 })
SilentTab:AddSlider('HitChance', { Text = 'Hit Chance (%)', Default = 100, Min = 0, Max = 100, Rounding = 0 })

local AntiAimGroupBox = Tabs.Main:AddRightGroupbox('Hydra Anti-Aim')
AntiAimGroupBox:AddToggle('AntiAimToggle', { Text = 'Enable Anti-Aim', Default = false })
AntiAimGroupBox:AddDropdown('AntiAimMode', { 
    Values = { 'Hyper Spinbot', 'Backwards', 'Matrix Break', 'Pitch Flip', 'Fake Jitter' }, Default = 1, Text = 'Anti-Aim Style' 
})
AntiAimGroupBox:AddSlider('AntiAimSpeed', { Text = 'Glitch/Rotation Speed', Default = 150, Min = 10, Max = 500, Rounding = 0 })

-- =============================================================================
-- [ 2. PLAYER MOVEMENT & GLITCH TAB ] 
-- =============================================================================
local GlitchGroupBox = Tabs.Player:AddLeftGroupbox('Math Stationary Glitch')
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
UtilsGroupBox:AddToggle('NoclipToggle', { Text = 'Enable Noclip', Default = false }):AddKeyPicker('NoclipKey', { Default = 'N', SyncToggleState = true, Mode = 'Toggle', Text = 'Noclip Toggle' })
UtilsGroupBox:AddToggle('AutoStrafeToggle', { Text = 'Enable Auto Strafe', Default = false })
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
-- [ 3. VISUALS ESP & SKIN CHANGER TAB ]
-- =============================================================================
local EspGroupBox = Tabs.Visuals:AddLeftGroupbox('Player ESP Options')
EspGroupBox:AddToggle('EspBox', { Text = 'Bounding Box', Default = false }):AddColorPicker('BoxColor', { Default = Color3.fromRGB(255, 255, 255) })
EspGroupBox:AddToggle('EspFill', { Text = 'Box Fill Transparency', Default = false }):AddColorPicker('FillColor', { Default = Color3.fromRGB(240, 200, 220) })
EspGroupBox:AddToggle('EspSkeleton', { Text = 'Skeleton Bones', Default = false }):AddColorPicker('SkeletonColor', { Default = Color3.fromRGB(255, 255, 255) })
EspGroupBox:AddToggle('EspName', { Text = 'Display Player Name', Default = false }):AddColorPicker('NameColor', { Default = Color3.fromRGB(255, 255, 255) })
EspGroupBox:AddToggle('EspDistance', { Text = 'Display Distance', Default = false }):AddColorPicker('DistanceColor', { Default = Color3.fromRGB(255, 255, 255) })
EspGroupBox:AddToggle('EspHealthBar', { Text = 'Health Bar Status', Default = false }):AddColorPicker('HealthBarColor', { Default = Color3.fromRGB(0, 255, 100) })

local SkinSpooferBox = Tabs.Visuals:AddRightGroupbox('Unlock All Cosmetics')
SkinSpooferBox:AddToggle('EnableUnlockAll', { Text = 'Enable Unlock All (In-Game)', Default = false }):OnChanged(function()
    _G.UnlockAllActive = Toggles.EnableUnlockAll.Value
    if _G.UnlockAllActive then
        InitUnlockAll()
        Library:Notify('🔓 Unlock All Active! 로비의 인벤토리 창을 사용하세요.', 4)
    else
        Library:Notify('🔒 Unlock All Disabled. 원래 인벤토리 상태로 복구되었습니다.', 3)
    end
end)
SkinSpooferBox:AddLabel('활성화 시 모든 스킨/피니셔 잠금이 해제됩니다.')

local SkinChangerBox = Tabs.Visuals:AddRightGroupbox('Auto-Dump Skin Changer')
local weaponToSkins = {}
local availableWeapons = {"AssaultRifle", "Sniper", "Shotgun", "Pistol", "Knife", "SMG", "RocketLauncher"}

SkinChangerBox:AddDropdown('TargetWeapon', { Values = availableWeapons, Default = 1, Text = '대상 무기 선택' })
SkinChangerBox:AddDropdown('TargetSkin', { Values = {"Select Weapon First..."}, Default = 1, Text = '적용할 스킨 선택' })

Options.TargetWeapon:OnChanged(function(val)
    pcall(function()
        if not Options.TargetSkin then return end
        local skins = weaponToSkins[val]
        if skins and type(skins) == "table" and #skins > 0 then
            Options.TargetSkin:SetValues(skins)
        else
            Options.TargetSkin:SetValues({"No Skins Found"})
        end
    end)
end)

SkinChangerBox:AddButton('🔥 스킨 강제 장착 (Apply)', function()
    if not _G.UnlockAllActive then
        Library:Notify('❌ [오류] 먼저 위쪽의 Unlock All 기능을 활성화해주세요!', 4)
        return
    end

    local weapon = Options.TargetWeapon.Value
    local skin = Options.TargetSkin.Value

    if weapon and skin and skin ~= "Select Weapon First..." and skin ~= "No Skins Found" then
        _G.AxiomEquipped[weapon] = _G.AxiomEquipped[weapon] or {}
        _G.AxiomEquipped[weapon].Skin = {
            Name = skin,
            Type = "Skin",
            Seed = math.random(1, 9999999)
        }
        
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:UnequipTools()
            Library:Notify('✅ ['..weapon..']에 '..skin..' 스킨 변조 완료!\n인벤토리에서 무기를 다시 꺼내면 적용됩니다.', 5)
        end
    else
        Library:Notify('⚠️ 올바른 무기와 스킨을 선택해주세요.', 3)
    end
end)

task.spawn(function()
    local CosmeticLib = nil
    while not CosmeticLib do
        CosmeticLib = _G.CosmeticLibrary
        if type(CosmeticLib) ~= "table" then
            local ok, res = pcall(function() return require(ReplicatedStorage.Modules:WaitForChild("CosmeticLibrary", 3)) end)
            if ok and type(res) == "table" then CosmeticLib = res end
        end
        if type(CosmeticLib) == "table" and CosmeticLib.Cosmetics then break end
        task.wait(1)
    end

    local tempWeapons = {}
    for name, data in pairs(CosmeticLib.Cosmetics) do
        if type(data) == "table" and data.Type == "Skin" then
            local lowerName = name:lower()
            if not lowerName:find("wrap") and not lowerName:find("finisher") and not lowerName:find("charm") then
                local wName = data.Weapon or data.WeaponName or data.Item or "All Weapons"
                weaponToSkins[wName] = weaponToSkins[wName] or {}
                table.insert(weaponToSkins[wName], name)
                if not table.find(tempWeapons, wName) then table.insert(tempWeapons, wName) end
            end
        end
    end
    
    if #tempWeapons > 0 then
        table.sort(tempWeapons)
        availableWeapons = tempWeapons
        for _, skins in pairs(weaponToSkins) do table.sort(skins) end
    end
    
    while not (Options and Options.TargetWeapon) do task.wait(0.1) end
    pcall(function() Options.TargetWeapon:SetValues(availableWeapons) end)
end)

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
WeaponModBox:AddSlider('FireRateMultiplier', { Text = 'Packet Replication Multiplier', Default = 10, Min = 1, Max = 50, Rounding = 0 })

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

local SpooferBox = Tabs.Misc:AddRightGroupbox('System Spoofer (기기 위조)')
SpooferBox:AddDropdown('DeviceMode', { 
    Values = { 'PC', 'Mobile', 'Console', 'VR' }, Default = 1, Text = '위조할 기기 선택' 
}):OnChanged(function()
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local setControlsRemote = remotes:WaitForChild("Replication", 2):WaitForChild("Fighter", 2):WaitForChild("SetControls", 2)
            if setControlsRemote then
                local mode = Options.DeviceMode.Value
                local targetDevice = "MouseKeyboard"
                if mode == "Mobile" then targetDevice = "Touch"
                elseif mode == "Console" then targetDevice = "Gamepad"
                elseif mode == "VR" then targetDevice = "VR"
                end
                setControlsRemote:FireServer("MouseKeyboard")
                task.wait(0.3)
                setControlsRemote:FireServer(targetDevice)
                Library:Notify("📱 서버에 기기 위조 신호 전송 완료: " .. mode, 3)
            end
        end
    end)
end)

-- =============================================================================
-- [ 6. BACKEND CORE ENGINE & HELPER FUNCTIONS ]
-- =============================================================================

local function getClosestPlayerToMous()
    if not Options or not Options.Radius then return nil end
    local target, maxDist = nil, Options.Radius.Value
    local mousePos = UserInputService:GetMouseLocation()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local hrp = p.Character.Head
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
    local target, maxDist = nil, math.huge
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
    d.TopGui.Parent = game:GetService("CoreGui")
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

local autoStrafeSide = 1
local lastAutoStrafe = tick()

local function updateFly()
    if not Toggles or not Options then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if Toggles.FlyToggle and Toggles.FlyToggle.Value and hrp then
        local camCFrame = Camera.CFrame
        local moveDir = Vector3.new(0, 0, 0)

        if keyStates.W then moveDir = moveDir + camCFrame.LookVector end
        if keyStates.S then moveDir = moveDir - camCFrame.LookVector end
        if keyStates.A then moveDir = moveDir - camCFrame.RightVector end
        if keyStates.D then moveDir = moveDir + camCFrame.RightVector end
        if keyStates.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if keyStates.LeftControl then moveDir = moveDir - Vector3.new(0, 1, 0) end

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

-- [ 🌟 UNIFIED METATABLE HOOKING (NAME_CALL - SILENT AIM + DROP COMPENSATION) ]
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and method == "FireServer" then
        local selfName = self.Name
        
        if selfName == "UseItem" then
            if Toggles and Toggles.SilentEnabled and Toggles.SilentEnabled.Value and math.random(1, 100) <= Options.HitChance.Value then
                local targetPlayer = CachedSilentTarget -- ✅ [최적화] 매번 연산하지 않고 캐싱된 타겟 사용
                if targetPlayer and targetPlayer.Character then
                    local targetPart = targetPlayer.Character:FindFirstChild("Head") 
                    
                    if targetPart and args[3] and type(args[3]) == "table" and args[3]["\001"] then
                        local dropComp = (Options.DropCompensation and Options.DropCompensation.Value) or 1.5
                        local hitPos = targetPart.Position + Vector3.new(0, dropComp, 0)
                        
                        -- ✅ [최적화] 예측 계수 0.135 -> 0.05로 줄여 명중률 상승
                        if Toggles.PredictiveShot and Toggles.PredictiveShot.Value and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            hitPos = hitPos + (targetPlayer.Character.HumanoidRootPart.Velocity * 0.05) 
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
            
            if _G.FighterController then
                task.spawn(function()
                    pcall(function()
                        local fighter = _G.FighterController:GetFighter(LocalPlayer)
                        if fighter and fighter.Items then
                            for _, item in pairs(fighter.Items) do
                                if item:Get("ObjectID") == args[1] then
                                    _G.LastUsedWeapon = item.Name
                                    break
                                end
                            end
                        end
                    end)
                end)
            end
        end

        if selfName == "EquipCosmetic" and _G.UnlockAllActive then
            local weaponName, cosmeticType, cosmeticName, options = args[1], args[2], args[3], args[4] or {}
            if cosmeticName and cosmeticName ~= "None" and cosmeticName ~= "" then
                if _G.DataController then
                    local inventory = _G.DataController:Get("CosmeticInventory")
                    if inventory and rawget(inventory, cosmeticName) then
                        return oldNamecall(self, unpack(args))
                    end
                end
            end

            _G.AxiomEquipped[weaponName] = _G.AxiomEquipped[weaponName] or {}
            if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                _G.AxiomEquipped[weaponName][cosmeticType] = nil
                if not next(_G.AxiomEquipped[weaponName]) then _G.AxiomEquipped[weaponName] = nil end
            else
                if _G.CosmeticLibrary and _G.CosmeticLibrary.Cosmetics then
                    local base = _G.CosmeticLibrary.Cosmetics[cosmeticName]
                    if base then
                        local cloned = {}
                        for k, v in pairs(base) do cloned[k] = v end
                        cloned.Name = cosmeticName
                        cloned.Type = cloned.Type or cosmeticType
                        cloned.Seed = cloned.Seed or math.random(1, 1000000)
                        if _G.EnumLibrary then
                            pcall(function() 
                                cloned.Enum = _G.EnumLibrary:ToEnum(cosmeticName) 
                                cloned.ObjectID = cloned.ObjectID or cloned.Enum
                            end)
                        end
                        if options then
                            if options.IsInverted ~= nil then cloned.Inverted = options.IsInverted end
                            if options.OnlyUseFavorites ~= nil then cloned.OnlyUseFavorites = options.OnlyUseFavorites end
                        end
                        _G.AxiomEquipped[weaponName][cosmeticType] = cloned
                    end
                end
            end
            if _G.DataController then
                task.defer(function() pcall(function() _G.DataController.CurrentData:Replicate("WeaponInventory") end) end)
            end
            return
        end

        if selfName == "FavoriteCosmetic" and _G.UnlockAllActive then
            _G.AxiomFavorites[args[1]] = _G.AxiomFavorites[args[1]] or {}
            _G.AxiomFavorites[args[1]][args[2]] = args[3] or nil
            if _G.DataController then
                task.spawn(function() pcall(function() _G.DataController.CurrentData:Replicate("FavoritedCosmetics") end) end)
            end
            return
        end
    end
    
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

UserInputService.InputBegan:Connect(function(i, g) 
    if not g then 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then isClicking = true end 
        if i.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = true end 
        if i.KeyCode == Enum.KeyCode.W then keyStates.W = true end
        if i.KeyCode == Enum.KeyCode.A then keyStates.A = true end
        if i.KeyCode == Enum.KeyCode.S then keyStates.S = true end
        if i.KeyCode == Enum.KeyCode.D then keyStates.D = true end
        if i.KeyCode == Enum.KeyCode.Space then keyStates.Space = true end
        if i.KeyCode == Enum.KeyCode.LeftControl then keyStates.LeftControl = true end
    end 
end)

UserInputService.InputEnded:Connect(function(i, g) 
    if i.UserInputType == Enum.UserInputType.MouseButton1 then isClicking = false end 
    if i.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = false end 
    if i.KeyCode == Enum.KeyCode.W then keyStates.W = false end
    if i.KeyCode == Enum.KeyCode.A then keyStates.A = false end
    if i.KeyCode == Enum.KeyCode.S then keyStates.S = false end
    if i.KeyCode == Enum.KeyCode.D then keyStates.D = false end
    if i.KeyCode == Enum.KeyCode.Space then keyStates.Space = false end
    if i.KeyCode == Enum.KeyCode.LeftControl then keyStates.LeftControl = false end
end)

-- [ ✅ 극한의 헤드샷 고정 오토 슛/패킷 난사 (AOE) 쓰레드 ]
local UseItemRemote = nil
task.spawn(function()
    local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
    if remotes then
        local rep = remotes:WaitForChild("Replication", 5)
        if rep then
            local fighter = rep:WaitForChild("Fighter", 5)
            if fighter then
                UseItemRemote = fighter:WaitForChild("UseItem", 5)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.05) do -- ✅ [최적화] 대기 시간 증가로 타임아웃 튕김 방지
        local isFastFire = Toggles and Toggles.FastFireToggle and Toggles.FastFireToggle.Value and isClicking
        local isAutoShoot = Toggles and Toggles.AutoShootToggle and Toggles.AutoShootToggle.Value
        local isKillAll = Toggles and Toggles.KillAllToggle and Toggles.KillAllToggle.Value

        if (isFastFire or isAutoShoot) then
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function() tool:Activate() end)
            end

            if UseItemRemote then
                local targets = {}
                
                if isKillAll then
                    local count = 0
                    for _, p in ipairs(Players:GetPlayers()) do
                        if count >= 5 then break end -- ✅ [최적화] 다중 타겟 과부하 방지 (최대 5명 제한)
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                            local hum = p.Character:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then 
                                table.insert(targets, p)
                                count = count + 1
                            end
                        end
                    end
                else
                    -- ✅ [최적화] 매번 연산하지 않고 캐싱된 타겟 불러오기
                    if CachedSilentTarget then table.insert(targets, CachedSilentTarget) end
                end

                -- ✅ [최적화] 패킷 과부하를 막기 위해 최대 5배로 제한
                local multiplier = (Options and Options.FireRateMultiplier) and math.floor(Options.FireRateMultiplier.Value) or 1
                multiplier = math.clamp(multiplier, 1, 5)

                for _, targetPlayer in ipairs(targets) do
                    local targetPart = targetPlayer.Character:FindFirstChild("Head")
                    
                    if targetPart then
                        local dropComp = (Options.DropCompensation and Options.DropCompensation.Value) or 1.5
                        local hx, hy, hz = targetPart.Position.X, targetPart.Position.Y + dropComp, targetPart.Position.Z
                        
                        local customArgs = {
                            [1] = "\207\147", [2] = "\026",
                            [3] = { ["\001"] = {
                                ["\001"] = { ["\001"] = hx, ["\000"] = hy, ["\003"] = 0, ["\002"] = hz, ["\005"] = 0, ["\004"] = 0 },
                                ["\000"] = { ["\001"] = hx, ["\000"] = hy, ["\003"] = 0, ["\002"] = hz, ["\005"] = 0, ["\004"] = 0 },
                                ["\003"] = { ["\001"] = 0,  ["\000"] = 0,  ["\003"] = 0, ["\002"] = 10, ["\005"] = 0, ["\004"] = 1.57 },
                                ["\002"] = targetPart
                            }}
                        }
                        
                        for i = 1, multiplier do
                            task.spawn(function() pcall(function() UseItemRemote:FireServer(unpack(customArgs)) end) end)
                            task.wait(0.01) -- ✅ [최적화] 패킷 사이 미세 딜레이
                        end
                    end
                end
            end
        end
    end
end)

-- [ 🌟 즉각 탄환 텔레포트 (무조건 헤드 타격) 및 반중력/갓모드 ]
workspace.DescendantAdded:Connect(function(d) 
    if not Toggles then return end
    if not d:IsA("BasePart") then return end
    
    local name = d.Name:lower()
    if name:find("bullet") or name:find("projectile") then
        task.spawn(function()
            if Toggles.AntiDamage and Toggles.AntiDamage.Value then
                local antiHitConn
                antiHitConn = RunService.RenderStepped:Connect(function()
                    if not d or not d.Parent then antiHitConn:Disconnect() return end
                    local myChar = LocalPlayer.Character
                    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if myHrp then
                        if (d.Position - myHrp.Position).Magnitude < 15 then
                            d:Destroy()
                            antiHitConn:Disconnect()
                        end
                    end
                end)
            end

            if not Toggles.RageBotToggle or not Toggles.RageBotToggle.Value then return end
            
            pcall(function() d.CanCollide = false d.Size = Vector3.new(20, 20, 20) d.Transparency = 0.5 end)
            
            if not d:FindFirstChild("AntiGravity") then
                local bf = Instance.new("BodyForce")
                bf.Name = "AntiGravity"
                bf.Force = Vector3.new(0, workspace.Gravity * d:GetMass(), 0)
                bf.Parent = d
            end
            
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not d or not d.Parent or not Toggles.RageBotToggle.Value then connection:Disconnect() return end
                
                local tp = CachedSilentTarget -- ✅ [최적화] 캐싱된 타겟 사용
                if tp and tp.Character and tp.Character:FindFirstChild("Head") then
                    local head = tp.Character.Head
                    
                    local dropComp = (Options.DropCompensation and Options.DropCompensation.Value) or 1.5
                    local aimTarget = head.Position + Vector3.new(0, dropComp, 0)
                    
                    d.CFrame = CFrame.new(aimTarget)
                    d.Velocity = (aimTarget - d.Position).Unit * Options.BaseVelocity.Value
                end
            end)
        end)
    end 
end)

RunService.Stepped:Connect(function()
    if Toggles and Toggles.NoclipToggle and Toggles.NoclipToggle.Value and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    -- ✅ [최적화] RenderStepped 최상단에서 매 프레임 타겟 갱신 (캐싱)
    if Toggles and Toggles.SilentEnabled and Toggles.SilentEnabled.Value then
        CachedSilentTarget = getClosestPlayerToMous()
    else
        CachedSilentTarget = nil
    end

    if Toggles and Toggles.HitboxExpander and Toggles.HitboxExpander.Value then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                head.Size = Vector3.new(Options.HitboxSize.Value, Options.HitboxSize.Value, Options.HitboxSize.Value)
                head.Transparency = 0.8
                head.BrickColor = BrickColor.new("Bright red")
                head.Material = Enum.Material.Neon
                head.CanCollide = false
            end
        end
    end

    if Toggles.ShowFOV.Value then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Options.Radius.Value
        FOVCircle.Visible = true
    else FOVCircle.Visible = false end
    
    if weatherAnchor and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        weatherAnchor.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 25, 0))
    end
    
    pcall(updateEsp)
    
    -- ✅ [최적화] 뷰모델(카메라) Aimbot 보정 (낙차 오프셋 일치화 및 부드러운 Lerp)
    if Toggles.AimbotEnabled.Value and isRightMouseDown then
        local targetPlayer = CachedSilentTarget
        if targetPlayer and targetPlayer.Character then
            local targetPart = targetPlayer.Character:FindFirstChild(Options.AimbotPart.Value)
            if targetPart then 
                local dropComp = (Options.DropCompensation and Options.DropCompensation.Value) or 1.5
                local targetPos = targetPart.Position + Vector3.new(0, dropComp, 0)
                local smoothFactor = math.clamp(Options.Smoothness.Value / 100, 0.01, 1)
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPos), smoothFactor) 
            end
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    pcall(updateFly)
    pcall(updateMovement, dt)
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
    
    -- ✅ [최적화] 플레이어 나갈 때 캐시된 타겟도 비워주기
    if CachedSilentTarget == player then
        CachedSilentTarget = nil
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

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('ANLUHub')
SaveManager:SetFolder('ANLUHub/Rivals')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
