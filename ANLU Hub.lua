--기존 updateMovement 함수를 찾아서 아래 구조로 통째로 대체하거나 참고하시기 바랍니다.

local function updateMovement(dt)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- UI의 실시간 활성화 상태를 매 프레임 독립적인 로컬 변수로 강제 바인딩
    local isStrafeEnabled = Toggles.StrafeToggle.Value
    local isOrbitEnabled = Toggles.OrbitToggle.Value
    local isVoidEnabled = Toggles.VoidSpamToggle.Value

    -- 타겟 플레이어의 실시간 상태 갱신
    local targetPlayer = Players:FindFirstChild(Options.OrbitTargetPlayer.Value or "")
    local targetHrp = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    -- 1. [완전 독점 분기] 타겟 머리 위 텔포 (Strafe)가 켜져 있을 때
    if isStrafeEnabled then
        if targetHrp then
            local targetHeadPos = targetHrp.Position + Vector3.new(0, Options.TeleportHeight.Value, 0)
            local now = tick()
            local cycle = Options.StrafeDuration.Value
            
            -- 지정된 작동 시간에만 타겟 위로 좌표 고정, 그 외에는 상태 대기
            if (now - lastStrafeTime) < cycle then
                local lookAtPos = Vector3.new(targetHrp.Position.X, targetHeadPos.Y, targetHrp.Position.Z)
                lastNormalCFrame = CFrame.lookAt(targetHeadPos, lookAtPos)
            else
                if (now - lastStrafeTime) > (cycle * 2) then
                    lastStrafeTime = now
                end
                lastNormalCFrame = hrp.CFrame
            end
        else
            lastNormalCFrame = nil
        end

    -- 2. [완전 독점 분기] 머리 위 텔포가 꺼져 있고, 오빗 아우라만 켜져 있을 때
    elseif isOrbitEnabled then
        -- 기준 중심점 설정 (맵 중심 또는 대상 플레이어 위치)
        local center = Vector3.new(0,0,0)
        if Options.OrbitTargetMode.Value ~= '맵 중심 (0,0,0)' then
            center = targetHrp and targetHrp.Position or hrp.Position
        end
        
        -- 속도 및 각도 누적 계산
        angle = angle + (Options.OrbitSpeed.Value * dt)
        local radius = Options.OrbitRadius.Value
        local height = Options.OrbitHeight.Value
        
        local x = center.X + math.cos(angle) * radius
        local z = center.Z + math.sin(angle) * radius
        local y = center.Y + height
        
        lastNormalCFrame = CFrame.lookAt(Vector3.new(x, y, z), center)

    -- 3. 아무것도 켜져 있지 않을 때 (모든 제어 플래그 즉시 강제 초기화)
    else
        lastNormalCFrame = nil
    end

    -- 물리 CFrame 변조 적용 파트
    if lastNormalCFrame then
        if isVoidEnabled then
            -- 보이드 스팸 연산 적용 시 가상 비트 보정
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
        
        -- 이동 변조 중 서버 물리 충돌 및 관성 누적으로 인한 튕김 현상 방지
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
    end
end
