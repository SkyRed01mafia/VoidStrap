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
-- PARTE 6 — AUTO FOLLOW + LOCK DO TPS + BOTÃO FLUTUANTE
-- Detecta lock via ObjectValue "Owner" (método do TPS).
-- Pausa automaticamente quando VOCÊ ou OUTRO jogador pega a bola.
--====================================================================

State.AutoFollow = State.AutoFollow or {
    Enabled = false,
    Speed = 16,
    StopDistance = 2.5,
    PauseOnLock = true,
    TouchToEnable = true,
}

State.AutoFollowBtn = State.AutoFollowBtn or {
    Visible = false,
    Position = UDim2.new(0, 20, 0.3, 0),
}

local AutoFollowModule = {}
local AF_BodyVel = nil
local AF_Conn = nil
local AF_CachedBall = nil
local AF_LastSearch = 0
local AF_LockedByMe = false
local AF_TouchConn = nil
local AF_TouchDebounce = 0

-- ---------- DETECÇÃO DA BOLA ----------
local BALL_NAMES = {
    "TPS", "ESA", "MRS", "PRS", "MPS",
    "Ball", "Football", "Soccer Ball", "Bola", "SoccerBall"
}

local function afFindBall()
    local char = LP.Character
    for _, name in ipairs(BALL_NAMES) do
        local b = Workspace:FindFirstChild(name, true)
        if b and b:IsA("BasePart") then
            if not (char and b:IsDescendantOf(char)) then
                return b
            end
        end
    end
    return nil
end

-- ---------- DETECÇÃO DE LOCK (MÉTODO DO TPS) ----------
-- O TPS usa um ObjectValue chamado "Owner" dentro da bola.
--   Owner.Value = Character de quem tem a posse
--   Owner.Value = nil = bola livre
local function isBallLocked(ball)
    if not ball then return false, nil end

    local ownerVal = ball:FindFirstChild("Owner")
    if ownerVal and ownerVal:IsA("ObjectValue") and ownerVal.Value then
        local ownerPlayer = Players:GetPlayerFromCharacter(ownerVal.Value)
        return true, ownerPlayer or ownerVal.Value
    end

    return false, nil
end

-- ---------- CLEANUP ----------
local function afCleanup()
    if AF_BodyVel and AF_BodyVel.Parent then
        pcall(function() AF_BodyVel:Destroy() end)
    end
    AF_BodyVel = nil
end

-- ---------- BOTÃO FLUTUANTE ----------
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

-- ---------- LOOP PRINCIPAL ----------
local function afStart()
    if AF_Conn then AF_Conn:Disconnect() end

    AF_Conn = RunService.RenderStepped:Connect(function()
        if not State.AutoFollow.Enabled then return end

        local char = LP.Character
        if not char then afCleanup() return end

        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then
            afCleanup()
            return
        end

        local now = tick()
        if not AF_CachedBall or not AF_CachedBall.Parent or (now - AF_LastSearch) > 2 then
            AF_LastSearch = now
            AF_CachedBall = afFindBall()
        end

        local ball = AF_CachedBall
        if not ball then afCleanup() return end

        -- ---------- CHECAGEM DE LOCK (via Owner do TPS) ----------
        if State.AutoFollow.PauseOnLock then
            local locked, who = isBallLocked(ball)
            local wasLocked = AF_LockedByMe

            -- AF_LockedByMe = true se quem lockou foi você
            AF_LockedByMe = locked and (who == LP)

            if locked then
                -- Bola lockada (por você OU outro) → pausa
                afCleanup()
                if wasLocked ~= AF_LockedByMe then
                    updateFloatingBtnVisual()
                end
                return
            end

            if wasLocked ~= AF_LockedByMe then
                updateFloatingBtnVisual()
            end
        else
            AF_LockedByMe = false
        end

        -- ---------- MOVIMENTO ----------
        local targetPos = Vector3.new(ball.Position.X, root.Position.Y, ball.Position.Z)
        local distance = (root.Position - targetPos).Magnitude

        if distance > State.AutoFollow.StopDistance then
            if not AF_BodyVel or AF_BodyVel.Parent ~= root then
                afCleanup()
                AF_BodyVel = Instance.new("BodyVelocity")
                AF_BodyVel.Name = "VST_AutoFollow"
                AF_BodyVel.MaxForce = Vector3.new(1e5, 0, 1e5)
                AF_BodyVel.Velocity = Vector3.zero
                AF_BodyVel.Parent = root
            end
            local direction = (targetPos - root.Position).Unit
            local speed = math.max(humanoid.WalkSpeed, State.AutoFollow.Speed)
            pcall(function() root.CFrame = CFrame.lookAt(root.Position, targetPos) end)
            pcall(function() AF_BodyVel.Velocity = direction * speed end)
        else
            afCleanup()
        end
    end)
end

-- ---------- DETECÇÃO DE TRISCAR ----------
local function afStartTouchDetection()
    if AF_TouchConn then AF_TouchConn:Disconnect(); AF_TouchConn = nil end

    AF_TouchConn = RunService.Heartbeat:Connect(function()
        if not State.AutoFollow.TouchToEnable then return end
        if not State.AutoFollow.Enabled then return end

        local now = tick()
        if now - AF_TouchDebounce < 0.5 then return end

        local char = LP.Character
        if not char then return end

        local ball = AF_CachedBall or afFindBall()
        if not ball or not ball.Parent then return end

        local minDist = math.huge
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local d = (part.Position - ball.Position).Magnitude
                if d < minDist then minDist = d end
            end
        end

        local ballRadius = math.max(ball.Size.X, ball.Size.Y, ball.Size.Z) * 0.5
        local touchRadius = ballRadius + 1.5

        if minDist <= touchRadius then
            AF_TouchDebounce = now
            if AF_BodyVel == nil and not AF_LockedByMe then
                AF_LastSearch = 0
            end
        end
    end)
end

-- ---------- API ----------
function AutoFollowModule.setEnabled(on)
    State.AutoFollow.Enabled = on
    if on then
        afStart()
        afStartTouchDetection()
        notify("Auto Follow ativado", "good")
    else
        afCleanup()
        if AF_Conn then AF_Conn:Disconnect(); AF_Conn = nil end
        if AF_TouchConn then AF_TouchConn:Disconnect(); AF_TouchConn = nil end
        AF_LockedByMe = false
        notify("Auto Follow desativado", "bad")
    end
    updateFloatingBtnVisual()
end

function AutoFollowModule.setSpeed(v) State.AutoFollow.Speed = v end
function AutoFollowModule.setStopDistance(v) State.AutoFollow.StopDistance = v end
function AutoFollowModule.setPauseOnLock(enabled) State.AutoFollow.PauseOnLock = enabled end
function AutoFollowModule.setTouchToEnable(enabled) State.AutoFollow.TouchToEnable = enabled end

function AutoFollowModule.reset()
    State.AutoFollow.Enabled = false
    AF_LockedByMe = false
    afCleanup()
    if AF_Conn then AF_Conn:Disconnect(); AF_Conn = nil end
    if AF_TouchConn then AF_TouchConn:Disconnect(); AF_TouchConn = nil end
    AF_CachedBall = nil
    updateFloatingBtnVisual()
    notify("Auto Follow resetado", "bad")
end

-- ---------- BOTÃO FLUTUANTE ----------
local AutoFollowBtnModule = {}
local IsDragging = false
local DragStart = nil
local StartPos = nil
local PressStartTime = 0
local PressStartPos = nil

local function createFloatingBtn()
    if FloatingBtn and FloatingBtn.Parent then
        FloatingBtn.Visible = true
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
                local finalDelta = input.Position - PressStartPos
                local moved = math.abs(finalDelta.X) + math.abs(finalDelta.Y)
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

-- ---------- ABA ----------
createTab("Auto Follow", "AF")

do
    local page = Tabs["Auto Follow"].page

    local sec = section("Seguir Bola")
    sec.Parent = page

    toggleRow(sec, "Ativar Auto Follow", State.AutoFollow.Enabled, function(on)
        AutoFollowModule.setEnabled(on)
    end, 1)

    toggleRow(sec, "Triscar Ativa", State.AutoFollow.TouchToEnable, function(on)
        AutoFollowModule.setTouchToEnable(on)
    end, 2)

    toggleRow(sec, "Pausar quando Lockado", State.AutoFollow.PauseOnLock, function(on)
        AutoFollowModule.setPauseOnLock(on)
    end, 3)

    sliderRow(sec, "Velocidade", 8, 60, State.AutoFollow.Speed, function(v)
        AutoFollowModule.setSpeed(v)
    end, 4)

    sliderRow(sec, "Distancia Parada", 1, 10, State.AutoFollow.StopDistance, function(v)
        AutoFollowModule.setStopDistance(v)
    end, 5)

    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 1,
        Text = "Segue a bola. Detecta lock via Owner da bola. Pausa automaticamente quando alguem tem a posse.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 6,
        Parent = sec,
    })
    themed(info, "TextColor3", "Sub")

    local floatSec = section("Botao Flutuante")
    floatSec.Parent = page

    buttonRow(floatSec, "Criar / Remover Botao Flutuante", function()
        AutoFollowBtnModule.toggle()
    end, 1)

    local warnSec = section("Aviso")
    warnSec.Parent = page

    local warnLbl = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundTransparency = 1,
        Text = "AVISO: Auto Follow da vantagem competitiva. Use por sua conta e risco.",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = ActiveTheme.Bad,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = warnSec,
    })
    themed(warnLbl, "TextColor3", "Bad")

    buttonRow(warnSec, "Desativar e Remover Botao", function()
        AutoFollowModule.reset()
        AutoFollowBtnModule.hide()
    end, 2)
end

-- ---------- CLEANUP ----------
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

print("[VoidStrap] Auto Follow (com lock TPS) carregado.")--====================================================================
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

print("[VoidStrap] Chars carregado.")
