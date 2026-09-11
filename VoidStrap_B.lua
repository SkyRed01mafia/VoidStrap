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
local function ftFindBall()
    local char = LP.Character
    local function valid(p)
        if not p or not p:IsA("BasePart") then return false end
        if char and p:IsDescendantOf(char) then return false end
        return true
    end

    -- Busca rápida por nomes conhecidos
    for _, name in ipairs({"TPS", "ESA", "MRS", "PRS", "MPS", "Bola", "Ball", "SoccerBall", "Football"}) do
        local b = Workspace:FindFirstChild(name, true)
        if valid(b) then return b end
    end

    -- Fallback: esferas pequenas
    for _, obj in ipairs(Workspace:GetChildren()) do
        if valid(obj) and obj:IsA("BasePart") and obj.Shape == Enum.PartType.Ball then
            local mx = math.max(obj.Size.X, obj.Size.Y, obj.Size.Z)
            if mx >= 1 and mx <= 6 then return obj end
        end
        if obj:IsA("Model") then
            for _, sub in ipairs(obj:GetChildren()) do
                if valid(sub) and sub:IsA("BasePart") then
                    if sub.Shape == Enum.PartType.Ball then
                        local mx = math.max(sub.Size.X, sub.Size.Y, sub.Size.Z)
                        if mx >= 1 and mx <= 6 then return sub end
                    end
                    if sub.Name:lower() == "tps" then return sub end
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
-- ABA
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

    local warnLbl = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "AVISO: efeitos visuais sao locais. Se algum jogo bloquear, desative.",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = ActiveTheme.Bad,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        Parent = resetSec,
    })
    themed(warnLbl, "TextColor3", "Bad")
end

--====================================================================
-- CLEANUP
--====================================================================
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
-- PARTE 5B — PLAYER TRAIL / BEAM
-- Rastro (Trail) ou feixe (Beam) no personagem. Local, reversível.
--====================================================================

State.PlayerTrail = State.PlayerTrail or {
    Enabled = false,
    Mode = "Trail",        -- "Trail" ou "Beam"
    Preset = "Arco-Íris",
    Width = 2,
    Lifetime = 1.0,
}

local PlayerTrailModule = {}

local ActiveEffects   = {}
local CharacterConn   = nil
local CurrentChar     = nil
local DebugLabel2     = nil
local DebugLog2       = {}

local function dbg2(msg)
    table.insert(DebugLog2, 1, msg)
    while #DebugLog2 > 8 do table.remove(DebugLog2) end
    if DebugLabel2 then DebugLabel2.Text = table.concat(DebugLog2, "\n") end
    print("[PlayerTrail] " .. msg)
end

-- ---------- PRESETS DE COR ----------
local PT_PRESETS = {
    ["Arco-Íris"] = {
        colors = {
            Color3.fromRGB(255, 60, 60),
            Color3.fromRGB(255, 200, 60),
            Color3.fromRGB(80, 255, 80),
            Color3.fromRGB(60, 200, 255),
            Color3.fromRGB(180, 80, 255),
        },
        rainbow = true,
    },
    ["Fogo"] = {
        colors = {
            Color3.fromRGB(255, 220, 80),
            Color3.fromRGB(255, 140, 40),
            Color3.fromRGB(255, 60, 0),
        },
    },
    ["Gelo"] = {
        colors = {
            Color3.fromRGB(220, 240, 255),
            Color3.fromRGB(120, 200, 255),
            Color3.fromRGB(60, 140, 220),
        },
    },
    ["Neon Verde"] = {
        colors = {
            Color3.fromRGB(200, 255, 200),
            Color3.fromRGB(80, 255, 120),
            Color3.fromRGB(30, 180, 60),
        },
    },
    ["Roxo Cósmico"] = {
        colors = {
            Color3.fromRGB(230, 180, 255),
            Color3.fromRGB(180, 80, 255),
            Color3.fromRGB(90, 40, 180),
        },
    },
    ["Dourado"] = {
        colors = {
            Color3.fromRGB(255, 240, 180),
            Color3.fromRGB(255, 200, 60),
            Color3.fromRGB(200, 140, 30),
        },
    },
    ["Sangue"] = {
        colors = {
            Color3.fromRGB(255, 80, 80),
            Color3.fromRGB(180, 20, 20),
            Color3.fromRGB(90, 0, 0),
        },
    },
    ["Sombra"] = {
        colors = {
            Color3.fromRGB(90, 60, 130),
            Color3.fromRGB(50, 20, 80),
            Color3.fromRGB(15, 5, 30),
        },
    },
    ["Branco Puro"] = {
        colors = {
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(220, 220, 255),
            Color3.fromRGB(150, 150, 200),
        },
    },
    ["Preto Fade"] = {
        colors = {
            Color3.fromRGB(60, 60, 60),
            Color3.fromRGB(25, 25, 25),
            Color3.fromRGB(0, 0, 0),
        },
    },
}

-- ---------- UTIL ----------
local function buildColorSequence(preset)
    if not preset or not preset.colors then return ColorSequence.new(Color3.new(1,1,1)) end
    if #preset.colors == 1 then
        return ColorSequence.new(preset.colors[1])
    end
    local kps = {}
    for i, c in ipairs(preset.colors) do
        table.insert(kps, ColorSequenceKeypoint.new((i-1)/(#preset.colors-1), c))
    end
    return ColorSequence.new(kps)
end

local function clearEffects()
    for _, obj in ipairs(ActiveEffects) do
        pcall(function()
            if obj and obj.Parent then obj:Destroy() end
        end)
    end
    ActiveEffects = {}
end

-- ---------- APLICAR NO PERSONAGEM ----------
local function applyToCharacter()
    local char = LP.Character
    if not char then
        dbg2("Sem character")
        return false
    end

    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not hrp then
        dbg2("Sem HumanoidRootPart")
        return false
    end

    clearEffects()
    CurrentChar = char

    local preset = PT_PRESETS[State.PlayerTrail.Preset] or PT_PRESETS["Arco-Íris"]
    local colorSeq = buildColorSequence(preset)
    local width = State.PlayerTrail.Width or 2
    local lifetime = State.PlayerTrail.Lifetime or 1.0

    -- Attachment 0 (base, na raiz)
    local a0 = Instance.new("Attachment")
    a0.Name = "VST_PT_A0"
    a0.Position = Vector3.new(0, 0, 0)
    a0.Parent = hrp
    table.insert(ActiveEffects, a0)

    -- Attachment 1 (topo, um pouco acima)
    local a1 = Instance.new("Attachment")
    a1.Name = "VST_PT_A1"
    a1.Position = Vector3.new(0, width, 0)
    a1.Parent = hrp
    table.insert(ActiveEffects, a1)

    if State.PlayerTrail.Mode == "Beam" then
        -- Beam (feixe reto)
        local beam = Instance.new("Beam")
        beam.Name = "VST_PT_Beam"
        beam.Attachment0 = a0
        beam.Attachment1 = a1
        beam.Color = colorSeq
        beam.Width0 = width
        beam.Width1 = width * 0.6
        beam.LightEmission = 1
        beam.LightInfluence = 0
        beam.FaceCamera = true
        beam.Segments = 10
        beam.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0.0, 0.15),
            NumberSequenceKeypoint.new(0.5, 0.4),
            NumberSequenceKeypoint.new(1.0, 1.0),
        })
        beam.Parent = hrp
        table.insert(ActiveEffects, beam)
        dbg2("Beam anexado")
    else
        -- Trail (rastro clássico)
        local trail = Instance.new("Trail")
        trail.Name = "VST_PT_Trail"
        trail.Attachment0 = a0
        trail.Attachment1 = a1
        trail.Color = colorSeq
        trail.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0.0, 0.1),
            NumberSequenceKeypoint.new(0.6, 0.5),
            NumberSequenceKeypoint.new(1.0, 1.0),
        })
        trail.WidthScale = NumberSequence.new({
            NumberSequenceKeypoint.new(0.0, 1.5),
            NumberSequenceKeypoint.new(0.5, 1.0),
            NumberSequenceKeypoint.new(1.0, 0.2),
        })
        trail.Lifetime = lifetime
        trail.LightEmission = 1
        trail.LightInfluence = 0
        trail.FaceCamera = true
        trail.Parent = hrp
        table.insert(ActiveEffects, trail)
        dbg2("Trail anexado")
    end

    -- Partículas extras (opcional, dá mais "aura")
    local sparks = Instance.new("ParticleEmitter")
    sparks.Name = "VST_PT_Sparks"
    sparks.Color = colorSeq
    sparks.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.8),
        NumberSequenceKeypoint.new(1.0, 0.0),
    })
    sparks.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.3),
        NumberSequenceKeypoint.new(1.0, 1.0),
    })
    sparks.Lifetime = NumberRange.new(0.3, 0.7)
    sparks.Rate = 25
    sparks.Speed = NumberRange.new(1, 4)
    sparks.SpreadAngle = Vector2.new(180, 180)
    sparks.LightEmission = 1
    sparks.LightInfluence = 0
    sparks.Parent = hrp
    table.insert(ActiveEffects, sparks)

    dbg2("✓ Efeitos no character")
    return true
end

-- ---------- LOOP DE RAINBOW (se preset tiver rainbow = true) ----------
local RainbowConn = nil
local function startRainbowLoop()
    if RainbowConn then RainbowConn:Disconnect() end
    if not State.PlayerTrail.Enabled then return end
    local preset = PT_PRESETS[State.PlayerTrail.Preset]
    if not preset or not preset.rainbow then return end

    local hue = 0
    RainbowConn = RunService.Heartbeat:Connect(function(dt)
        if not State.PlayerTrail.Enabled then return end
        hue = (hue + dt * 0.3) % 1
        local c1 = Color3.fromHSV(hue, 1, 1)
        local c2 = Color3.fromHSV((hue + 0.2) % 1, 1, 1)
        local c3 = Color3.fromHSV((hue + 0.4) % 1, 1, 1)
        local seq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(0.5, c2),
            ColorSequenceKeypoint.new(1, c3),
        })
        for _, obj in ipairs(ActiveEffects) do
            if obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("ParticleEmitter") then
                pcall(function() obj.Color = seq end)
            end
        end
    end)
end

-- ---------- MONITOR DE RESPAWN ----------
local function hookCharacter()
    if CharacterConn then CharacterConn:Disconnect() end
    CharacterConn = LP.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if State.PlayerTrail.Enabled then
            applyToCharacter()
            startRainbowLoop()
        end
    end)
end

-- ---------- API ----------
function PlayerTrailModule.setEnabled(on)
    State.PlayerTrail.Enabled = on
    if on then
        dbg2("Ativando...")
        task.spawn(function()
            if applyToCharacter() then
                startRainbowLoop()
                notify("Player Trail ativado", "good")
            else
                notify("Character não pronto", "bad")
            end
        end)
    else
        clearEffects()
        if RainbowConn then RainbowConn:Disconnect(); RainbowConn = nil end
        dbg2("Desativado")
        notify("Player Trail desativado", "bad")
    end
end

function PlayerTrailModule.setMode(mode)
    State.PlayerTrail.Mode = mode
    if State.PlayerTrail.Enabled then
        applyToCharacter()
        startRainbowLoop()
        notify("Modo: " .. mode, "good")
    end
end

function PlayerTrailModule.setPreset(name)
    State.PlayerTrail.Preset = name
    if State.PlayerTrail.Enabled then
        applyToCharacter()
        startRainbowLoop()
        notify("Estilo: " .. name, "good")
    end
end

function PlayerTrailModule.setWidth(w)
    State.PlayerTrail.Width = w
    if State.PlayerTrail.Enabled then
        applyToCharacter()
    end
end

function PlayerTrailModule.setLifetime(l)
    State.PlayerTrail.Lifetime = l
    if State.PlayerTrail.Enabled then
        applyToCharacter()
    end
end

function PlayerTrailModule.reset()
    State.PlayerTrail.Enabled = false
    clearEffects()
    if RainbowConn then RainbowConn:Disconnect(); RainbowConn = nil end
    DebugLog2 = {}
    if DebugLabel2 then DebugLabel2.Text = "(reset)" end
    notify("Player Trail resetado", "bad")
end

-- ---------- ABA ----------
createTab("Player Trail", "✨")

do
    local page = Tabs["Player Trail"].page
    local sec = section("Rastro no Personagem")
    sec.Parent = page

    toggleRow(sec, "Ativar Player Trail", State.PlayerTrail.Enabled, function(on)
        PlayerTrailModule.setEnabled(on)
    end, 1)

    dropdownRow(sec, "Modo",
        { "Trail", "Beam" },
        State.PlayerTrail.Mode,
        function(opt) PlayerTrailModule.setMode(opt) end, 2)

    dropdownRow(sec, "Estilo",
        { "Arco-Íris", "Fogo", "Gelo", "Neon Verde", "Roxo Cósmico",
          "Dourado", "Sangue", "Sombra", "Branco Puro", "Preto Fade" },
        State.PlayerTrail.Preset,
        function(opt) PlayerTrailModule.setPreset(opt) end, 3)

    sliderRow(sec, "Largura", 1, 10, State.PlayerTrail.Width, function(v)
        PlayerTrailModule.setWidth(v)
    end, 4)

    sliderRow(sec, "Duração", 1, 5, math.floor(State.PlayerTrail.Lifetime * 10), function(v)
        PlayerTrailModule.setLifetime(v / 10)
    end, 5)

    local debugFrame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 110),
        BackgroundColor3 = Color3.fromRGB(15, 15, 18),
        BorderSizePixel = 0,
        LayoutOrder = 6,
        Parent = sec,
    })
    corner(8, debugFrame)
    stroke(ActiveTheme.Stroke, 1, 0.4, debugFrame)

    DebugLabel2 = create("TextLabel", {
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        Text = "(aguardando...)",
        Font = Enum.Font.Code,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(120, 255, 160),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = debugFrame,
    })

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Remover rastro do personagem", function()
        PlayerTrailModule.reset()
    end, 1)
end

-- Hooks
hookCharacter()

local _prevUnload3 = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevUnload3 then _prevUnload3() end
    pcall(function() PlayerTrailModule.reset() end)
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function() PlayerTrailModule.reset() end)
    end
end)

print("[VoidStrap] Player Trail carregado.")--====================================================================
-- PARTE 6 — AUTO FOLLOW + BOTÃO FLUTUANTE
-- Aplica BodyVelocity no seu HumanoidRootPart pra seguir a bola.
-- Botão flutuante arrastável pra ativar/desativar.
--====================================================================

State.AutoFollow = State.AutoFollow or {
    Enabled = false,
    Speed = 16,
    StopDistance = 2.5,
}

State.AutoFollowBtn = State.AutoFollowBtn or {
    Visible = false,
    Position = UDim2.new(0, 20, 0.3, 0),
}

local AutoFollowModule = {}
local AF_BodyVel = nil
local AF_Conn = nil

-- ---------- DETECÇÃO DA BOLA ----------
local BALL_NAMES = {
    "TPS", "ESA", "MRS", "PRS", "MPS",
    "Ball", "Football", "Soccer Ball", "Bola", "SoccerBall"
}

local function afFindBall()
    local char = LP.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name
            for _, name in ipairs(BALL_NAMES) do
                if n == name then
                    if char and obj:IsDescendantOf(char) then
                        -- ignora acessórios do character
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
local function afCleanup()
    if AF_BodyVel and AF_BodyVel.Parent then
        pcall(function() AF_BodyVel:Destroy() end)
    end
    AF_BodyVel = nil
end

-- ---------- ATUALIZAR VISUAL DO BOTÃO FLUTUANTE ----------
local FloatingBtn = nil

local function updateFloatingBtnVisual()
    if not FloatingBtn or not FloatingBtn.Parent then return end
    local active = State.AutoFollow and State.AutoFollow.Enabled
    if active then
        FloatingBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
        FloatingBtn.Text = "AF ON"
    else
        FloatingBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        FloatingBtn.Text = "AF OFF"
    end
end

-- ---------- LOOP PRINCIPAL DO AUTO FOLLOW ----------
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

        local ball = afFindBall()
        if not ball then afCleanup() return end

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

            pcall(function()
                root.CFrame = CFrame.lookAt(root.Position, targetPos)
            end)
            pcall(function()
                AF_BodyVel.Velocity = direction * speed
            end)
        else
            afCleanup()
        end
    end)
end

-- ---------- API ----------
function AutoFollowModule.setEnabled(on)
    State.AutoFollow.Enabled = on
    if on then
        afStart()
        notify("Auto Follow ativado", "good")
    else
        afCleanup()
        if AF_Conn then AF_Conn:Disconnect(); AF_Conn = nil end
        notify("Auto Follow desativado", "bad")
    end
    updateFloatingBtnVisual()
end

function AutoFollowModule.setSpeed(v)
    State.AutoFollow.Speed = v
end

function AutoFollowModule.setStopDistance(v)
    State.AutoFollow.StopDistance = v
end

function AutoFollowModule.reset()
    State.AutoFollow.Enabled = false
    afCleanup()
    if AF_Conn then AF_Conn:Disconnect(); AF_Conn = nil end
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
                    -- Clique: alterna
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

-- ---------- ABA AUTO FOLLOW ----------
createTab("Auto Follow", "AF")

do
    local page = Tabs["Auto Follow"].page

    local sec = section("Seguir Bola")
    sec.Parent = page

    toggleRow(sec, "Ativar Auto Follow", State.AutoFollow.Enabled, function(on)
        AutoFollowModule.setEnabled(on)
    end, 1)

    sliderRow(sec, "Velocidade", 8, 60, State.AutoFollow.Speed, function(v)
        AutoFollowModule.setSpeed(v)
    end, 2)

    sliderRow(sec, "Distancia Parada", 1, 10, State.AutoFollow.StopDistance, function(v)
        AutoFollowModule.setStopDistance(v)
    end, 3)

    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundTransparency = 1,
        Text = "Aplica BodyVelocity no seu personagem pra te mover ate a bola. Local, reversivel.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 4,
        Parent = sec,
    })
    themed(info, "TextColor3", "Sub")

    -- Seção do botão flutuante
    local floatSec = section("Botao Flutuante")
    floatSec.Parent = page

    local infoBtn = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundTransparency = 1,
        Text = "Cria um botao flutuante na tela. Arraste pra mover, toque pra ativar/desativar o Auto Follow.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = floatSec,
    })
    themed(infoBtn, "TextColor3", "Sub")

    buttonRow(floatSec, "Criar / Remover Botao Flutuante", function()
        AutoFollowBtnModule.toggle()
    end, 2)

    -- Aviso
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

print("[VoidStrap] Auto Follow + Botao Flutuante carregado.")--====================================================================
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
