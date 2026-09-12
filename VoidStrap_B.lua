--====================================================================
-- PARTE 5 — FIRE TRAIL NA BOLA (The Classic Soccer)
-- Detecta a bola automaticamente, anexa Fire + Trail + Particles + PointLight
-- 100% local (client-only), não replica para o servidor, reversível.
--====================================================================

State.FireTrail = State.FireTrail or { Enabled = false, Preset = "Fogo Classico" }

local FireTrailModule = {}
local CurrentBall = nil
local ActiveInstances = {}

-- ---------- PRESETS ----------
local FIRE_PRESETS = {
    ["Fogo Classico"] = { fire=Color3.fromRGB(255,120,30), secondary=Color3.fromRGB(255,60,0),
        trail=Color3.fromRGB(255,180,60), trailMid=Color3.fromRGB(255,80,20),
        light=Color3.fromRGB(255,140,40), size=6 },
    ["Fogo Azul"] = { fire=Color3.fromRGB(80,180,255), secondary=Color3.fromRGB(30,90,220),
        trail=Color3.fromRGB(150,210,255), trailMid=Color3.fromRGB(50,130,255),
        light=Color3.fromRGB(100,180,255), size=6 },
    ["Fogo Roxo"] = { fire=Color3.fromRGB(180,80,255), secondary=Color3.fromRGB(120,30,220),
        trail=Color3.fromRGB(210,150,255), trailMid=Color3.fromRGB(140,60,255),
        light=Color3.fromRGB(180,100,255), size=6 },
    ["Fogo Verde"] = { fire=Color3.fromRGB(100,255,120), secondary=Color3.fromRGB(30,200,60),
        trail=Color3.fromRGB(160,255,180), trailMid=Color3.fromRGB(50,220,100),
        light=Color3.fromRGB(120,255,140), size=6 },
    ["Fogo Branco"] = { fire=Color3.fromRGB(255,255,255), secondary=Color3.fromRGB(220,240,255),
        trail=Color3.fromRGB(255,255,255), trailMid=Color3.fromRGB(200,220,255),
        light=Color3.fromRGB(255,255,255), size=6 },
    ["Fogo Sombrio"] = { fire=Color3.fromRGB(80,20,100), secondary=Color3.fromRGB(30,5,40),
        trail=Color3.fromRGB(150,50,200), trailMid=Color3.fromRGB(80,10,120),
        light=Color3.fromRGB(120,30,180), size=6 },
    ["Inferno"] = { fire=Color3.fromRGB(255,80,0), secondary=Color3.fromRGB(255,220,60),
        trail=Color3.fromRGB(255,160,30), trailMid=Color3.fromRGB(255,60,0),
        light=Color3.fromRGB(255,120,20), size=8 },
}

-- ---------- DETECÇÃO DA BOLA ----------
local BALL_NAMES = {
    "TPS", "ESA", "MRS", "PRS", "MPS",
    "Ball", "Football", "Soccer Ball", "Bola", "SoccerBall"
}

local function ftFindBall()
    local char = LP.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name
            for _, name in ipairs(BALL_NAMES) do
                if n == name then
                    if char and obj:IsDescendantOf(char) then
                        -- ignora acessórios
                    else
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

-- ---------- CLEANUP ----------
local function ftDestroy()
    for _, inst in ipairs(ActiveInstances) do
        pcall(function()
            if inst and inst.Parent then inst:Destroy() end
        end)
    end
    ActiveInstances = {}
    CurrentBall = nil
end

-- ---------- APLICAR EFEITOS ----------
local function ftApply(ball, presetName)
    ftDestroy()
    if not ball or not ball.Parent then return end

    local p = FIRE_PRESETS[presetName] or FIRE_PRESETS["Fogo Classico"]
    CurrentBall = ball

    -- 1) Fire
    local fire = Instance.new("Fire")
    fire.Name = "VST_Fire"
    fire.Color = p.fire
    fire.SecondaryColor = p.secondary
    fire.Size = p.size
    fire.Heat = 15
    fire.Parent = ball
    table.insert(ActiveInstances, fire)

    -- 2) Attachments
    local offsetY = math.max(ball.Size.Y * 0.5, 1)
    local a0 = Instance.new("Attachment")
    a0.Name = "VST_TrailA0"
    a0.Position = Vector3.new(0, offsetY, 0)
    a0.Parent = ball
    table.insert(ActiveInstances, a0)

    local a1 = Instance.new("Attachment")
    a1.Name = "VST_TrailA1"
    a1.Position = Vector3.new(0, -offsetY, 0)
    a1.Parent = ball
    table.insert(ActiveInstances, a1)

    -- 3) Trail
    local trail = Instance.new("Trail")
    trail.Name = "VST_Trail"
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, p.trail),
        ColorSequenceKeypoint.new(0.5, p.trailMid),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(0, 0, 0)),
    })
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.15),
        NumberSequenceKeypoint.new(0.6, 0.65),
        NumberSequenceKeypoint.new(1.0, 1.0),
    })
    trail.Lifetime = 0.7
    trail.LightEmission = 1
    trail.LightInfluence = 0
    trail.FaceCamera = true
    trail.Parent = ball
    table.insert(ActiveInstances, trail)

    -- 4) Faíscas
    local sparks = Instance.new("ParticleEmitter")
    sparks.Name = "VST_Sparks"
    sparks.Color = ColorSequence.new(p.fire, p.secondary)
    sparks.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.6),
        NumberSequenceKeypoint.new(1.0, 0.0),
    })
    sparks.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.1),
        NumberSequenceKeypoint.new(1.0, 1.0),
    })
    sparks.Lifetime = NumberRange.new(0.4, 0.9)
    sparks.Rate = 45
    sparks.Speed = NumberRange.new(3, 7)
    sparks.SpreadAngle = Vector2.new(180, 180)
    sparks.LightEmission = 1
    sparks.LightInfluence = 0
    sparks.Parent = ball
    table.insert(ActiveInstances, sparks)

    -- 5) Luz
    local light = Instance.new("PointLight")
    light.Name = "VST_Light"
    light.Brightness = 3
    light.Range = 14
    light.Color = p.light
    light.Shadows = false
    light.Parent = ball
    table.insert(ActiveInstances, light)
end

-- ---------- API ----------
function FireTrailModule.setEnabled(on)
    State.FireTrail.Enabled = on
    if on then
        local ball = ftFindBall()
        if ball then
            ftApply(ball, State.FireTrail.Preset)
            notify("Fire Trail ativado", "good")
        else
            notify("Bola nao encontrada", "bad")
        end
    else
        ftDestroy()
        notify("Fire Trail desativado", "bad")
    end
end

function FireTrailModule.setPreset(name)
    State.FireTrail.Preset = name
    if State.FireTrail.Enabled then
        local ball = CurrentBall
        if not ball or not ball.Parent then ball = ftFindBall() end
        if ball then
            ftApply(ball, name)
            notify("Rastro: " .. name, "good")
        end
    end
end

function FireTrailModule.refresh()
    local ball = ftFindBall()
    if ball then
        ftApply(ball, State.FireTrail.Preset)
        notify("Bola reconectada", "good")
    else
        notify("Nenhuma bola encontrada", "bad")
    end
end

function FireTrailModule.reset()
    State.FireTrail.Enabled = false
    ftDestroy()
    notify("Fire Trail resetado", "bad")
end

-- ---------- LOOP DE RE-DETECÇÃO ----------
task.spawn(function()
    while task.wait(1) do
        if State.FireTrail.Enabled then
            if not CurrentBall or not CurrentBall.Parent then
                local ball = ftFindBall()
                if ball then ftApply(ball, State.FireTrail.Preset) end
            end
        end
    end
end)

--====================================================================
-- ABA FIRE TRAIL
--====================================================================
createTab("Fire Trail", "FT")

do
    local page = Tabs["Fire Trail"].page
    local sec = section("Rastro de Fogo na Bola")
    sec.Parent = page

    toggleRow(sec, "Ativar Fire Trail", State.FireTrail.Enabled, function(on)
        FireTrailModule.setEnabled(on)
    end, 1)

    dropdownRow(sec, "Estilo",
        { "Fogo Classico", "Fogo Azul", "Fogo Roxo", "Fogo Verde",
          "Fogo Branco", "Fogo Sombrio", "Inferno" },
        State.FireTrail.Preset,
        function(opt) FireTrailModule.setPreset(opt) end, 2)

    buttonRow(sec, "Forcar busca da bola", function()
        FireTrailModule.refresh()
    end, 3)

    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Text = "Anexa fogo, trail, faiscas e luz na bola. 100% local e reversivel.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 4,
        Parent = sec,
    })
    themed(info, "TextColor3", "Sub")

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Remover efeitos da bola", function()
        FireTrailModule.reset()
    end, 1)
end

-- ---------- CLEANUP ----------
local _prevFT = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevFT then _prevFT() end
    pcall(function() FireTrailModule.reset() end)
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function() FireTrailModule.reset() end)
    end
end)

print("[VoidStrap] Fire Trail carregado.")--====================================================================
-- PARTE 6.1 — AUTO FOLLOW (NÚCLEO + BOTÃO FLUTUANTE)
--====================================================================

State.AutoFollow = State.AutoFollow or {
    Enabled = false,
    Speed = 16,
    StopDistance = 2.2,
    ReachEnabled = false,
    ReachDistance = 1,
    PauseOnLock = true,
    TouchToEnable = true,
    TargetMode = "Todas",
}

State.AutoFollowBtn = State.AutoFollowBtn or {
    Visible = false,
    Position = UDim2.new(0, 20, 0.3, 0),
    Locked = false,
}

local AutoFollowModule = {}
local AF_BodyVel = nil
local AF_Conn = nil
local AF_ReachConn = nil
local AF_CachedBall = nil
local AF_LastSearch = 0
local AF_LockedByMe = false
local AF_TouchConn = nil
local AF_TouchDebounce = 0

-- DETECÇÃO DE BOLA
local BALL_NAMES = {
    "TPS", "ESA", "MRS", "PRS", "MPS",
    "Ball", "Football", "Soccer Ball", "Bola", "SoccerBall"
}

local function isBallName(name)
    for _, n in ipairs(BALL_NAMES) do
        if name == n then return true end
    end
    return false
end

local function getBallOwner(ball)
    if not ball then return nil end
    local ownerVal = ball:FindFirstChild("Owner")
    if not ownerVal or not ownerVal.Value then return nil end
    return Players:GetPlayerFromCharacter(ownerVal.Value)
end

local function afFindAllBalls()
    local balls = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and isBallName(obj.Name) then
            local char = LP.Character
            if not (char and obj:IsDescendantOf(char)) then
                table.insert(balls, obj)
            end
        end
    end
    return balls
end

local function afFindMyBall()
    for _, b in ipairs(afFindAllBalls()) do
        if getBallOwner(b) == LP then return b end
    end
    return nil
end

local function afFindClosestBall()
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, minDist = nil, math.huge
    for _, b in ipairs(afFindAllBalls()) do
        local d = (b.Position - root.Position).Magnitude
        if d < minDist then minDist = d; closest = b end
    end
    return closest
end

local function afFindBallDefault()
    local balls = afFindAllBalls()
    return balls[1]
end

local function afFindBallByMode()
    local mode = State.AutoFollow.TargetMode or "Todas"
    if mode == "Minha" then return afFindMyBall() end
    if mode == "MaisProxima" then return afFindClosestBall() end
    return afFindBallDefault()
end

local function isBallLocked(ball)
    if not ball then return false, nil end
    local owner = getBallOwner(ball)
    if not owner then return false, nil end
    local char = owner.Character
    if not char then return false, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false, nil end
    if (root.Position - ball.Position).Magnitude > 8 then return false, nil end
    return true, owner
end

local function afCleanupBodyVel()
    if AF_BodyVel and AF_BodyVel.Parent then
        pcall(function() AF_BodyVel:Destroy() end)
    end
    AF_BodyVel = nil
end

-- BOTÃO FLUTUANTE
local FloatingBtn = nil

local function updateFloatingBtnVisual()
    if not FloatingBtn or not FloatingBtn.Parent then return end
    local active = State.AutoFollow and State.AutoFollow.Enabled
    if AF_LockedByMe then
        FloatingBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 40)
        FloatingBtn.Text = "AF LOCK"
    elseif active then
        FloatingBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
        FloatingBtn.Text = "AF ON"
    else
        FloatingBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        FloatingBtn.Text = "AF OFF"
    end
end

-- LOOP PRINCIPAL
local function afStart()
    if AF_Conn then AF_Conn:Disconnect() end
    AF_Conn = RunService.RenderStepped:Connect(function()
        if not State.AutoFollow.Enabled then afCleanupBodyVel() return end
        local char = LP.Character
        if not char then afCleanupBodyVel() return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then afCleanupBodyVel() return end

        local now = tick()
        if not AF_CachedBall or not AF_CachedBall.Parent or (now - AF_LastSearch) > 1 then
            AF_LastSearch = now
            AF_CachedBall = afFindBallByMode()
        end
        local ball = AF_CachedBall
        if not ball then afCleanupBodyVel() return end

        if State.AutoFollow.PauseOnLock and State.AutoFollow.TargetMode ~= "Minha" then
            local locked, who = isBallLocked(ball)
            local wasLocked = AF_LockedByMe
            AF_LockedByMe = locked and (who == LP)
            if locked then
                afCleanupBodyVel()
                if wasLocked ~= AF_LockedByMe then updateFloatingBtnVisual() end
                return
            end
            if wasLocked ~= AF_LockedByMe then updateFloatingBtnVisual() end
        else
            AF_LockedByMe = false
        end

        local targetPos = Vector3.new(ball.Position.X, root.Position.Y, ball.Position.Z)
        local dist = (root.Position - targetPos).Magnitude
        if dist > State.AutoFollow.StopDistance then
            if not AF_BodyVel or AF_BodyVel.Parent ~= root then
                afCleanupBodyVel()
                AF_BodyVel = Instance.new("BodyVelocity")
                AF_BodyVel.Name = "VST_AutoFollow"
                AF_BodyVel.MaxForce = Vector3.new(100000, 0, 100000)
                AF_BodyVel.Velocity = Vector3.zero
                AF_BodyVel.Parent = root
            end
            local dir = (targetPos - root.Position).Unit
            pcall(function() root.CFrame = CFrame.lookAt(root.Position, targetPos) end)
            local speed = math.max(hum.WalkSpeed, State.AutoFollow.Speed)
            pcall(function() AF_BodyVel.Velocity = dir * speed end)
        else
            afCleanupBodyVel()
        end
    end)
end

-- REACH
local function afStartReach()
    if AF_ReachConn then AF_ReachConn:Disconnect(); AF_ReachConn = nil end
    AF_ReachConn = RunService.Heartbeat:Connect(function()
        if not State.AutoFollow.Enabled then return end
        if not State.AutoFollow.ReachEnabled then return end
        if State.AutoFollow.ReachDistance <= 1 then return end
        local char = LP.Character
        if not char then return end
        local leg = char:FindFirstChild("Right Leg") or char:FindFirstChild("Right Lower Leg") or char:FindFirstChild("HumanoidRootPart")
        if not leg then return end
        local ball = AF_CachedBall or afFindBallByMode()
        if not ball then return end
        local dist = (leg.Position - ball.Position).Magnitude
        local maxReach = State.AutoFollow.ReachDistance * 1.8
        if dist <= maxReach and dist > 1.5 then
            if firetouchinterest then
                pcall(function() firetouchinterest(ball, leg, 0); firetouchinterest(ball, leg, 1) end)
            end
            pcall(function() ball.CFrame = leg.CFrame * CFrame.new(0, -1, -1) end)
        end
    end)
end

-- TRISCAR
local function afStartTouchDetection()
    if AF_TouchConn then AF_TouchConn:Disconnect(); AF_TouchConn = nil end
    AF_TouchConn = RunService.Heartbeat:Connect(function()
        if not State.AutoFollow.TouchToEnable then return end
        if not State.AutoFollow.Enabled then return end
        local now = tick()
        if now - AF_TouchDebounce < 0.5 then return end
        local char = LP.Character
        if not char then return end
        local ball = AF_CachedBall or afFindBallByMode()
        if not ball or not ball.Parent then return end
        local minDist = math.huge
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                local d = (p.Position - ball.Position).Magnitude
                if d < minDist then minDist = d end
            end
        end
        local radius = math.max(ball.Size.X, ball.Size.Y, ball.Size.Z) * 0.5 + 1.5
        if minDist <= radius then
            AF_TouchDebounce = now
            if not AF_LockedByMe then AF_LastSearch = 0 end
        end
    end)
end

-- API
function AutoFollowModule.setEnabled(on)
    State.AutoFollow.Enabled = on
    if on then
        afStart(); afStartReach(); afStartTouchDetection()
        notify("Auto Follow ativado", "good")
    else
        afCleanupBodyVel()
        if AF_Conn then AF_Conn:Disconnect(); AF_Conn = nil end
        if AF_ReachConn then AF_ReachConn:Disconnect(); AF_ReachConn = nil end
        if AF_TouchConn then AF_TouchConn:Disconnect(); AF_TouchConn = nil end
        AF_LockedByMe = false
        notify("Auto Follow desativado", "bad")
    end
    updateFloatingBtnVisual()
end

function AutoFollowModule.setSpeed(v) State.AutoFollow.Speed = v end
function AutoFollowModule.setStopDistance(v) State.AutoFollow.StopDistance = v end
function AutoFollowModule.setPauseOnLock(v) State.AutoFollow.PauseOnLock = v end
function AutoFollowModule.setTouchToEnable(v) State.AutoFollow.TouchToEnable = v end
function AutoFollowModule.setReachEnabled(v) State.AutoFollow.ReachEnabled = v end
function AutoFollowModule.setReachDistance(v) State.AutoFollow.ReachDistance = v end

function AutoFollowModule.setTargetMode(mode)
    State.AutoFollow.TargetMode = mode
    AF_CachedBall = nil
    AF_LastSearch = 0
    notify("Alvo: " .. mode, "good")
end

function AutoFollowModule.reset()
    State.AutoFollow.Enabled = false
    AF_LockedByMe = false
    afCleanupBodyVel()
    if AF_Conn then AF_Conn:Disconnect(); AF_Conn = nil end
    if AF_ReachConn then AF_ReachConn:Disconnect(); AF_ReachConn = nil end
    if AF_TouchConn then AF_TouchConn:Disconnect(); AF_TouchConn = nil end
    AF_CachedBall = nil
    updateFloatingBtnVisual()
    notify("Auto Follow resetado", "bad")
end

-- BOTÃO FLUTUANTE
local AutoFollowBtnModule = {}
local IsDragging = false
local DragStart = nil
local StartPos = nil
local PressStartTime = 0
local PressStartPos = nil

local function updateLockVisual()
    if not FloatingBtn or not FloatingBtn.Parent then return end
    local lockIcon = FloatingBtn:FindFirstChild("VST_LockIcon")
    if State.AutoFollowBtn.Locked then
        if not lockIcon then
            create("TextLabel", {
                Name = "VST_LockIcon",
                Size = UDim2.fromOffset(18, 18),
                Position = UDim2.new(1, -20, 0, 2),
                BackgroundTransparency = 1,
                Text = "L",
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(255, 220, 60),
                ZIndex = 100000,
                Parent = FloatingBtn,
            })
        end
    else
        if lockIcon then lockIcon:Destroy() end
    end
end

local function createFloatingBtn()
    if FloatingBtn and FloatingBtn.Parent then
        FloatingBtn.Visible = true
        updateLockVisual()
        return
    end
    FloatingBtn = create("TextButton", {
        Name = "VST_AutoFollowBtn",
        Size = UDim2.fromOffset(64, 64),
        Position = State.AutoFollowBtn.Position,
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        BorderSizePixel = 0,
        Text = "AF OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = false,
        ZIndex = 99999,
        Parent = ScreenOverlay,
    })
    corner(32, FloatingBtn)
    stroke(ActiveTheme.Accent, 2, 0.3, FloatingBtn)
    updateFloatingBtnVisual()
    updateLockVisual()

    FloatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            IsDragging = true
            DragStart = input.Position
            StartPos = FloatingBtn.Position
            PressStartTime = tick()
            PressStartPos = input.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not IsDragging then return end
        if State.AutoFollowBtn.Locked then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - DragStart
            if math.abs(delta.X) > 8 or math.abs(delta.Y) > 8 then
                FloatingBtn.Position = UDim2.new(
                    StartPos.X.Scale, StartPos.X.Offset + delta.X,
                    StartPos.Y.Scale, StartPos.Y.Offset + delta.Y
                )
                State.AutoFollowBtn.Position = FloatingBtn.Position
            end
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            IsDragging = false
            if PressStartPos then
                local fDelta = input.Position - PressStartPos
                local moved = math.abs(fDelta.X) + math.abs(fDelta.Y)
                local elapsed = tick() - PressStartTime
                if moved < 12 and elapsed < 0.5 then
                    AutoFollowModule.setEnabled(not State.AutoFollow.Enabled)
                end
            end
            PressStartPos = nil
        end
    end)

    FloatingBtn.MouseEnter:Connect(function()
        tween(FloatingBtn, 0.15, { Size = UDim2.fromOffset(72, 72) })
    end)
    FloatingBtn.MouseLeave:Connect(function()
        tween(FloatingBtn, 0.15, { Size = UDim2.fromOffset(64, 64) })
    end)
end

function AutoFollowBtnModule.show()
    createFloatingBtn()
    State.AutoFollowBtn.Visible = true
    notify("Botao flutuante criado", "good")
end

function AutoFollowBtnModule.hide()
    if FloatingBtn and FloatingBtn.Parent then
        FloatingBtn:Destroy()
        FloatingBtn = nil
    end
    State.AutoFollowBtn.Visible = false
    notify("Botao flutuante removido", "bad")
end

function AutoFollowBtnModule.toggle()
    if State.AutoFollowBtn.Visible then
        AutoFollowBtnModule.hide()
    else
        AutoFollowBtnModule.show()
    end
end

function AutoFollowBtnModule.setLocked(locked)
    State.AutoFollowBtn.Locked = locked
    if FloatingBtn and FloatingBtn.Parent then
        State.AutoFollowBtn.Position = FloatingBtn.Position
    end
    updateLockVisual()
    notify(locked and "Botao travado" or "Botao liberado", locked and "good" or "bad")
end

print("[VoidStrap] 6.1 OK")--====================================================================
-- PARTE 6.2 — AUTO FOLLOW (ABAS UI)
--====================================================================

-- ABA BASICO
createTab("AF Basico", "AF")

do
    local page = Tabs["AF Basico"].page

    local sec = section("Seguir Bola")
    sec.Parent = page

    toggleRow(sec, "Ativar Auto Follow", State.AutoFollow.Enabled, function(on)
        AutoFollowModule.setEnabled(on)
    end, 1)

    dropdownRow(sec, "Alvo",
        { "Todas", "Minha", "MaisProxima" },
        State.AutoFollow.TargetMode,
        function(opt) AutoFollowModule.setTargetMode(opt) end, 2)

    sliderRow(sec, "Velocidade", 8, 60, State.AutoFollow.Speed, function(v)
        AutoFollowModule.setSpeed(v)
    end, 3)

    sliderRow(sec, "Distancia Parada", 1, 10, State.AutoFollow.StopDistance, function(v)
        AutoFollowModule.setStopDistance(v)
    end, 4)

    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 1,
        Text = "Todas = qualquer bola. Minha = so quando VOCE tem a posse. MaisProxima = a mais perto de voce.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 5,
        Parent = sec,
    })
    themed(info, "TextColor3", "Sub")

    local floatSec = section("Botao Flutuante")
    floatSec.Parent = page

    buttonRow(floatSec, "Criar / Remover Botao Flutuante", function()
        AutoFollowBtnModule.toggle()
    end, 1)

    local floatInfo = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "Cria um botao na tela. Toque pra ligar/desligar. Arraste pra mover.",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        Parent = floatSec,
    })
    themed(floatInfo, "TextColor3", "Sub")
end

-- ABA AVANCADO
createTab("AF Avancado", "AF+")

do
    local page = Tabs["AF Avancado"].page

    local sec = section("Seguir Bola (Avancado)")
    sec.Parent = page

    toggleRow(sec, "Triscar Ativa", State.AutoFollow.TouchToEnable, function(on)
        AutoFollowModule.setTouchToEnable(on)
    end, 1)

    toggleRow(sec, "Pausar quando Lockado", State.AutoFollow.PauseOnLock, function(on)
        AutoFollowModule.setPauseOnLock(on)
    end, 2)

    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundTransparency = 1,
        Text = "Triscar = encostar na bola reativa o AF. Lock = pausa quando alguem tem a posse.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 3,
        Parent = sec,
    })
    themed(info, "TextColor3", "Sub")

    local reachSec = section("Reach (Alcance)")
    reachSec.Parent = page

    toggleRow(reachSec, "Ativar Reach", State.AutoFollow.ReachEnabled, function(on)
        AutoFollowModule.setReachEnabled(on)
    end, 1)

    sliderRow(reachSec, "Distancia (Studs)", 1, 12, State.AutoFollow.ReachDistance, function(v)
        AutoFollowModule.setReachDistance(v)
    end, 2)

    local reachWarn = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundTransparency = 1,
        Text = "AVISO: Reach empurra a bola via CFrame. Pode ser detectado por anti-cheat.",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = ActiveTheme.Bad,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 3,
        Parent = reachSec,
    })
    themed(reachWarn, "TextColor3", "Bad")

    local floatSec = section("Botao Flutuante (Avancado)")
    floatSec.Parent = page

    toggleRow(floatSec, "Travar Botao no Lugar", State.AutoFollowBtn.Locked, function(on)
        AutoFollowBtnModule.setLocked(on)
    end, 1)

    local lockInfo = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "Quando travado, o botao fica fixo no lugar. Voce ainda pode tocar pra ligar/desligar.",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        Parent = floatSec,
    })
    themed(lockInfo, "TextColor3", "Sub")

    local resetSec = section("Restaurar")
    resetSec.Parent = page

    buttonRow(resetSec, "Desativar tudo", function()
        AutoFollowModule.reset()
        AutoFollowBtnModule.hide()
    end, 1)
end

-- CLEANUP
local _prevAF = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevAF then _prevAF() end
    pcall(function()
        AutoFollowModule.reset()
        AutoFollowBtnModule.hide()
    end)
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function()
            AutoFollowModule.reset()
            AutoFollowBtnModule.hide()
        end)
    end
end)

print("[VoidStrap] 6.2 OK")--====================================================================
-- PARTE 6B — CHARS (Aplica skin via comando de chat)
--====================================================================

State.Chars = State.Chars or { Enabled = true }

local CharsModule = {}

-- ---------- LISTA DE CHARS ----------
local CHAR_LIST = {
    "MiguelCalebeGamer202",
    "guto785662",
    "beastsxc",
    "89felip3",
    "guto_01games",
    "feliou23",
    "LeozzinnTxz",
    "aerovah",
    "novaes_wc",
    "GHOST_INFINITI07",
    "16alvez",
    "mikaelfacada10",
    "keny_tcs",
    "3qu",
    "hel",
    "phzin123271",
    "portuga_xz3",
    "j12ufdo",
    "shadow_samuel1347k",
    "131felipe6",
    "mnbzzaicsn",
    "careca12492",
    "sunno_mm2",
    "rangeamandio",
    "rosa_skillsz",
    "DAVILUCASPLU2VC",
    "rayagaj3",
    "Felliou",
    "ythek9on1",
    "Bernardow_w",
    "Samblox_Xd",
    "mica1203ely5",
}

-- ---------- ENVIAR MENSAGEM NO CHAT ----------
local function sendChat(msg)
    local ok = false

    pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        local events = RS:FindFirstChild("DefaultChatSystemChatEvents")
        if events then
            local say = events:FindFirstChild("SayMessageRequest")
            if say then
                say:FireServer(msg, "All")
                ok = true
            end
        end
    end)

    if not ok then
        pcall(function()
            local TCS = game:GetService("TextChatService")
            if TCS and TCS.ChatVersion == Enum.ChatVersion.TextChatService then
                local channels = TCS:FindFirstChild("TextChannels")
                if channels then
                    local general = channels:FindFirstChild("RBXGeneral")
                    if general then
                        general:SendAsync(msg)
                        ok = true
                    end
                end
            end
        end)
    end

    return ok
end

-- ---------- API ----------
function CharsModule.apply(charName)
    if not charName or charName == "" then return end
    local cmd = ":char " .. charName
    if sendChat(cmd) then
        notify("Char: " .. charName, "good")
    else
        notify("Falha ao enviar chat", "bad")
    end
end

function CharsModule.applyById(id)
    if not id or id == "" then return end
    local cmd = ":char " .. id
    if sendChat(cmd) then
        notify("Char ID: " .. id, "good")
    else
        notify("Falha ao enviar chat", "bad")
    end
end

--====================================================================
-- ABA CHARS
--====================================================================
createTab("Chars", "CH")

do
    local page = Tabs["Chars"].page

    -- Secao de info
    local secInfo = section("Aplicar Char via Chat")
    secInfo.Parent = page

    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundTransparency = 1,
        Text = "Clique num char pra enviar :char NOME no chat automaticamente.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = secInfo,
    })
    themed(info, "TextColor3", "Sub")

    -- Secao de ID custom
    local secId = section("Char por ID")
    secId.Parent = page

    -- Input de texto simples
    local inputFrame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = ActiveTheme.Surface2,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Parent = secId,
    })
    themed(inputFrame, "BackgroundColor3", "Surface2")
    corner(8, inputFrame)

    local textBox = create("TextBox", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Digite o ID do char...",
        PlaceholderColor3 = ActiveTheme.Sub,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = ActiveTheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inputFrame,
    })
    themed(textBox, "TextColor3", "Text")
    themed(textBox, "PlaceholderColor3", "Sub")

    buttonRow(secId, "Aplicar ID do Char", function()
        local id = textBox.Text
        if id and id ~= "" then
            CharsModule.applyById(id)
        else
            notify("Digite um ID primeiro", "bad")
        end
    end, 2)

    -- Secao da lista
    local charSec = section("Lista de Chars")
    charSec.Parent = page

    for i, name in ipairs(CHAR_LIST) do
        buttonRow(charSec, name, function()
            CharsModule.apply(name)
        end, i)
    end
end

--====================================================================
-- CLEANUP
--====================================================================
local _prevChars = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevChars then _prevChars() end
end

print("[VoidStrap] Chars carregado.")--====================================================================
-- PARTE 7 — CUSTOM BALL (Cor + Textura com ajuste UV)
--====================================================================

State.BallColor = State.BallColor or {
    Enabled = false,
    Color = nil,
    TextureId = nil,
    StudsU = 4,
    StudsV = 4,
    OffsetU = 0,
    OffsetV = 0,
    Face = "Front",
}

local BallColorModule = {}
local BallColorTarget = nil
local BallColorBackup = nil
local BallColorConn = nil

local BALL_COLORS = {
    { name = "Branco",     color = Color3.fromRGB(255, 255, 255) },
    { name = "Preto",      color = Color3.fromRGB(40, 40, 40) },
    { name = "Cinza",      color = Color3.fromRGB(140, 140, 145) },
    { name = "Vermelho",   color = Color3.fromRGB(220, 50, 50) },
    { name = "Laranja",    color = Color3.fromRGB(255, 140, 40) },
    { name = "Amarelo",    color = Color3.fromRGB(240, 220, 60) },
    { name = "Verde",      color = Color3.fromRGB(60, 200, 80) },
    { name = "Azul",       color = Color3.fromRGB(60, 130, 220) },
    { name = "Roxo",       color = Color3.fromRGB(150, 80, 220) },
    { name = "Rosa",       color = Color3.fromRGB(240, 130, 200) },
    { name = "Ciano",      color = Color3.fromRGB(80, 220, 240) },
    { name = "Dourado",    color = Color3.fromRGB(230, 190, 50) },
    { name = "Neon Verde", color = Color3.fromRGB(80, 255, 120) },
    { name = "Neon Roxo",  color = Color3.fromRGB(180, 60, 255) },
    { name = "Inferno",    color = Color3.fromRGB(255, 60, 0) },
    { name = "Fantasma",   color = Color3.fromRGB(200, 200, 255) },
}

local BALL_TEXTURES = {
    { name = "Original",      id = nil },
    { name = "Bola Custom 1", id = "5767385379" },
    { name = "Bola Custom 2", id = "126904127959280" },
    { name = "Bola Custom 3", id = "110053224424205" },
}

local FACE_OPTIONS = {
    { name = "Front",  value = Enum.NormalId.Front },
    { name = "Back",   value = Enum.NormalId.Back },
    { name = "Left",   value = Enum.NormalId.Left },
    { name = "Right",  value = Enum.NormalId.Right },
    { name = "Top",    value = Enum.NormalId.Top },
    { name = "Bottom", value = Enum.NormalId.Bottom },
}

local BALL_NAMES_7 = {
    "TPS", "ESA", "MRS", "PRS", "MPS",
    "Ball", "Football", "Soccer Ball", "Bola", "SoccerBall"
}

local function isBallName7(name)
    for _, n in ipairs(BALL_NAMES_7) do
        if name == n then return true end
    end
    return false
end

local function findBall7()
    local char = LP.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and isBallName7(obj.Name) then
            if not (char and obj:IsDescendantOf(char)) then
                return obj
            end
        end
    end
    return nil
end

local function getFaceValue(name)
    for _, f in ipairs(FACE_OPTIONS) do
        if f.name == name then return f.value end
    end
    return Enum.NormalId.Front
end

local function captureBackup(ball)
    if BallColorBackup then return end
    BallColorBackup = {
        Color = ball.Color,
        Material = ball.Material,
        HasTexture = false,
        TextureColor = nil,
        TextureTransparency = nil,
        TextureId = nil,
        TextureFace = nil,
        StudsU = nil,
        StudsV = nil,
        OffsetU = nil,
        OffsetV = nil,
    }
    local tex = ball:FindFirstChildOfClass("Texture")
    if tex then
        BallColorBackup.HasTexture = true
        BallColorBackup.TextureColor = tex.Color3
        BallColorBackup.TextureTransparency = tex.Transparency
        BallColorBackup.TextureId = tex.Texture
        BallColorBackup.TextureFace = tex.Face
        BallColorBackup.StudsU = tex.StudsPerTileU
        BallColorBackup.StudsV = tex.StudsPerTileV
        BallColorBackup.OffsetU = tex.OffsetStudsU
        BallColorBackup.OffsetV = tex.OffsetStudsV
    end
end

local function applyBallColor(ball, color)
    if not ball then return end
    captureBackup(ball)
    pcall(function() ball.Color = color end)
    local tex = ball:FindFirstChildOfClass("Texture")
    if tex then
        pcall(function() tex.Color3 = color end)
    end
    for _, d in ipairs(ball:GetChildren()) do
        if d:IsA("Decal") then
            pcall(function() d.Color3 = color end)
        end
    end
end

local function applyBallTexture(ball, textureId)
    if not ball then return end
    captureBackup(ball)
    local tex = ball:FindFirstChildOfClass("Texture")
    if not tex then
        tex = Instance.new("Texture")
        tex.Name = "VST_BallTexture"
        tex.Face = Enum.NormalId.Front
        tex.Parent = ball
    end

    if textureId == nil then
        if BallColorBackup.TextureId then
            pcall(function() tex.Texture = BallColorBackup.TextureId end)
        end
        if BallColorBackup.TextureFace then
            pcall(function() tex.Face = BallColorBackup.TextureFace end)
        end
        if BallColorBackup.StudsU then
            pcall(function() tex.StudsPerTileU = BallColorBackup.StudsU end)
        end
        if BallColorBackup.StudsV then
            pcall(function() tex.StudsPerTileV = BallColorBackup.StudsV end)
        end
        if BallColorBackup.OffsetU then
            pcall(function() tex.OffsetStudsU = BallColorBackup.OffsetU end)
        end
        if BallColorBackup.OffsetV then
            pcall(function() tex.OffsetStudsV = BallColorBackup.OffsetV end)
        end
    else
        pcall(function() tex.Texture = "rbxassetid://" .. textureId end)
        pcall(function() tex.Face = getFaceValue(State.BallColor.Face) end)
        pcall(function() tex.StudsPerTileU = State.BallColor.StudsU end)
        pcall(function() tex.StudsPerTileV = State.BallColor.StudsV end)
        pcall(function() tex.OffsetStudsU = State.BallColor.OffsetU end)
        pcall(function() tex.OffsetStudsV = State.BallColor.OffsetV end)
    end
end

local function reapplyUV()
    if not BallColorTarget or not BallColorTarget.Parent then return end
    if not State.BallColor.TextureId then return end
    local tex = BallColorTarget:FindFirstChildOfClass("Texture")
    if not tex then return end
    pcall(function() tex.Face = getFaceValue(State.BallColor.Face) end)
    pcall(function() tex.StudsPerTileU = State.BallColor.StudsU end)
    pcall(function() tex.StudsPerTileV = State.BallColor.StudsV end)
    pcall(function() tex.OffsetStudsU = State.BallColor.OffsetU end)
    pcall(function() tex.OffsetStudsV = State.BallColor.OffsetV end)
end

local function restoreBallColor()
    if BallColorTarget and BallColorTarget.Parent and BallColorBackup then
        pcall(function()
            BallColorTarget.Color = BallColorBackup.Color
            BallColorTarget.Material = BallColorBackup.Material
        end)
        if BallColorBackup.HasTexture then
            local tex = BallColorTarget:FindFirstChildOfClass("Texture")
            if tex then
                if BallColorBackup.TextureColor then
                    pcall(function() tex.Color3 = BallColorBackup.TextureColor end)
                end
                if BallColorBackup.TextureTransparency ~= nil then
                    pcall(function() tex.Transparency = BallColorBackup.TextureTransparency end)
                end
                if BallColorBackup.TextureId then
                    pcall(function() tex.Texture = BallColorBackup.TextureId end)
                end
                if BallColorBackup.TextureFace then
                    pcall(function() tex.Face = BallColorBackup.TextureFace end)
                end
                if BallColorBackup.StudsU then
                    pcall(function() tex.StudsPerTileU = BallColorBackup.StudsU end)
                end
                if BallColorBackup.StudsV then
                    pcall(function() tex.StudsPerTileV = BallColorBackup.StudsV end)
                end
                if BallColorBackup.OffsetU then
                    pcall(function() tex.OffsetStudsU = BallColorBackup.OffsetU end)
                end
                if BallColorBackup.OffsetV then
                    pcall(function() tex.OffsetStudsV = BallColorBackup.OffsetV end)
                end
            end
        end
        for _, d in ipairs(BallColorTarget:GetChildren()) do
            if d:IsA("Decal") then
                pcall(function() d.Color3 = Color3.new(1, 1, 1) end)
            end
        end
    end
    BallColorBackup = nil
end

local function startBallColorMonitor()
    if BallColorConn then BallColorConn:Disconnect() end
    local lastSearch = 0
    BallColorConn = RunService.Heartbeat:Connect(function()
        if not State.BallColor.Enabled then return end
        if not BallColorTarget or not BallColorTarget.Parent then
            local now = tick()
            if now - lastSearch < 1.5 then return end
            lastSearch = now
            task.spawn(function()
                local b = findBall7()
                if b and State.BallColor.Enabled then
                    BallColorTarget = b
                    BallColorBackup = nil
                    if State.BallColor.Color then
                        applyBallColor(b, State.BallColor.Color)
                    end
                    if State.BallColor.TextureId then
                        applyBallTexture(b, State.BallColor.TextureId)
                    end
                end
            end)
        end
    end)
end

function BallColorModule.setEnabled(on)
    State.BallColor.Enabled = on
    if on then
        task.spawn(function()
            BallColorTarget = findBall7()
            if BallColorTarget then
                if State.BallColor.Color then
                    applyBallColor(BallColorTarget, State.BallColor.Color)
                end
                if State.BallColor.TextureId then
                    applyBallTexture(BallColorTarget, State.BallColor.TextureId)
                end
                notify("Ball Custom ativado", "good")
            else
                notify("Bola nao encontrada", "bad")
            end
            startBallColorMonitor()
        end)
    else
        restoreBallColor()
        if BallColorConn then BallColorConn:Disconnect(); BallColorConn = nil end
        BallColorTarget = nil
        notify("Ball Custom desativado", "bad")
    end
end

function BallColorModule.setColor(name)
    for _, e in ipairs(BALL_COLORS) do
        if e.name == name then
            State.BallColor.Color = e.color
            if BallColorTarget and BallColorTarget.Parent then
                applyBallColor(BallColorTarget, e.color)
            end
            notify("Cor: " .. name, "good")
            return
        end
    end
end

function BallColorModule.setTexture(name)
    for _, e in ipairs(BALL_TEXTURES) do
        if e.name == name then
            State.BallColor.TextureId = e.id
            if BallColorTarget and BallColorTarget.Parent then
                applyBallTexture(BallColorTarget, e.id)
            end
            notify("Textura: " .. name, "good")
            return
        end
    end
end

function BallColorModule.setStudsU(v)
    State.BallColor.StudsU = v
    reapplyUV()
end

function BallColorModule.setStudsV(v)
    State.BallColor.StudsV = v
    reapplyUV()
end

function BallColorModule.setOffsetU(v)
    State.BallColor.OffsetU = v
    reapplyUV()
end

function BallColorModule.setOffsetV(v)
    State.BallColor.OffsetV = v
    reapplyUV()
end

function BallColorModule.setFace(name)
    State.BallColor.Face = name
    reapplyUV()
    notify("Face: " .. name, "good")
end

function BallColorModule.refresh()
    task.spawn(function()
        local b = findBall7()
        if b then
            BallColorTarget = b
            BallColorBackup = nil
            if State.BallColor.Color then
                applyBallColor(b, State.BallColor.Color)
            end
            if State.BallColor.TextureId then
                applyBallTexture(b, State.BallColor.TextureId)
            end
            notify("Bola reconectada", "good")
        else
            notify("Nenhuma bola encontrada", "bad")
        end
    end)
end

function BallColorModule.reset()
    State.BallColor.Enabled = false
    State.BallColor.Color = nil
    State.BallColor.TextureId = nil
    restoreBallColor()
    if BallColorConn then BallColorConn:Disconnect(); BallColorConn = nil end
    BallColorTarget = nil
    notify("Bola restaurada", "bad")
end

createTab("Ball", "BALL")

do
    local page = Tabs["Ball"].page

    local mainSec = section("Custom Bola")
    mainSec.Parent = page

    toggleRow(mainSec, "Ativar Custom", State.BallColor.Enabled, function(on)
        BallColorModule.setEnabled(on)
    end, 1)

    buttonRow(mainSec, "Reconectar Bola", function()
        BallColorModule.refresh()
    end, 2)

    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "Muda cor e textura da bola. Apenas voce ve.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 3,
        Parent = mainSec,
    })
    themed(info, "TextColor3", "Sub")

    -- TEXTURAS
    local texSec = section("Texturas")
    texSec.Parent = page

    for i, e in ipairs(BALL_TEXTURES) do
        buttonRow(texSec, e.name, function()
            BallColorModule.setTexture(e.name)
        end, i)
    end

    -- AJUSTE DA TEXTURA (UV)
    local uvSec = section("Ajuste da Textura")
    uvSec.Parent = page

    dropdownRow(uvSec, "Face", 
        { "Front", "Back", "Left", "Right", "Top", "Bottom" },
        State.BallColor.Face,
        function(opt) BallColorModule.setFace(opt) end, 1)

    sliderRow(uvSec, "Studs U", 1, 20, State.BallColor.StudsU, function(v)
        BallColorModule.setStudsU(v)
    end, 2)

    sliderRow(uvSec, "Studs V", 1, 20, State.BallColor.StudsV, function(v)
        BallColorModule.setStudsV(v)
    end, 3)

    sliderRow(uvSec, "Offset U", -10, 10, State.BallColor.OffsetU, function(v)
        BallColorModule.setOffsetU(v)
    end, 4)

    sliderRow(uvSec, "Offset V", -10, 10, State.BallColor.OffsetV, function(v)
        BallColorModule.setOffsetV(v)
    end, 5)

    local uvInfo = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 1,
        Text = "Ajuste para melhorar a projecao da textura na bola. Studs U/V mudam o tamanho. Offset U/V movem. Faca testes.",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 6,
        Parent = uvSec,
    })
    themed(uvInfo, "TextColor3", "Sub")

    -- CORES
    local colorSec = section("Cores")
    colorSec.Parent = page

    for i, e in ipairs(BALL_COLORS) do
        local row = buttonRow(colorSec, e.name, function()
            BallColorModule.setColor(e.name)
        end, i)

        local swatch = create("Frame", {
            Size = UDim2.fromOffset(18, 18),
            Position = UDim2.new(0, 8, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = e.color,
            BorderSizePixel = 0,
            Parent = row,
        })
        corner(4, swatch)

        local lbl = row:FindFirstChildOfClass("TextLabel")
        if lbl then
            lbl.Position = UDim2.new(0, 34, 0, 0)
        end
    end

    -- RESET
    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Restaurar bola original", function()
        BallColorModule.reset()
    end, 1)
end

local _prevBall = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevBall then _prevBall() end
    pcall(function() BallColorModule.reset() end)
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function() BallColorModule.reset() end)
    end
end)

print("[VoidStrap] Ball Custom (cor + textura + UV) carregado.")
