--====================================================================
-- FIRE TRAIL (versao corrigida — detecta "tps")
--====================================================================

State.FireTrail = State.FireTrail or { Enabled = false, Preset = "Fogo Classico" }

local FireTrailModule = {}
local CurrentBall = nil
local ActiveInstances = {}

local FIRE_PRESETS = {
    ["Fogo Classico"]={fire=Color3.fromRGB(255,120,30),secondary=Color3.fromRGB(255,60,0),trail=Color3.fromRGB(255,180,60),trailMid=Color3.fromRGB(255,80,20),light=Color3.fromRGB(255,140,40),size=6},
    ["Fogo Azul"]={fire=Color3.fromRGB(80,180,255),secondary=Color3.fromRGB(30,90,220),trail=Color3.fromRGB(150,210,255),trailMid=Color3.fromRGB(50,130,255),light=Color3.fromRGB(100,180,255),size=6},
    ["Fogo Roxo"]={fire=Color3.fromRGB(180,80,255),secondary=Color3.fromRGB(120,30,220),trail=Color3.fromRGB(210,150,255),trailMid=Color3.fromRGB(140,60,255),light=Color3.fromRGB(180,100,255),size=6},
    ["Fogo Verde"]={fire=Color3.fromRGB(100,255,120),secondary=Color3.fromRGB(30,200,60),trail=Color3.fromRGB(160,255,180),trailMid=Color3.fromRGB(50,220,100),light=Color3.fromRGB(120,255,140),size=6},
    ["Fogo Branco"]={fire=Color3.fromRGB(255,255,255),secondary=Color3.fromRGB(220,240,255),trail=Color3.fromRGB(255,255,255),trailMid=Color3.fromRGB(200,220,255),light=Color3.fromRGB(255,255,255),size=6},
    ["Fogo Sombrio"]={fire=Color3.fromRGB(80,20,100),secondary=Color3.fromRGB(30,5,40),trail=Color3.fromRGB(150,50,200),trailMid=Color3.fromRGB(80,10,120),light=Color3.fromRGB(120,30,180),size=6},
    ["Inferno"]={fire=Color3.fromRGB(255,80,0),secondary=Color3.fromRGB(255,220,60),trail=Color3.fromRGB(255,160,30),trailMid=Color3.fromRGB(255,60,0),light=Color3.fromRGB(255,120,20),size=8},
}

-- Deteccao RAPIDA: procura por "TPS" primeiro
local function findBall()
    local char = LP.Character
    local function valid(p)
        if not p or not p:IsA("BasePart") then return false end
        if char and p:IsDescendantOf(char) then return false end
        return true
    end

    -- Nomes conhecidos da bola
    for _, name in ipairs({"TPS", "Bola", "Ball", "SoccerBall", "Soccer"}) do
        local b = Workspace:FindFirstChild(name, true)
        if valid(b) then return b end
    end

    -- Fallback: esferas pequenas
    for _, obj in ipairs(Workspace:GetChildren()) do
        if valid(obj) and obj:IsA("BasePart") then
            if obj.Shape == Enum.PartType.Ball then
                local mx = math.max(obj.Size.X, obj.Size.Y, obj.Size.Z)
                if mx >= 1 and mx <= 6 then return obj end
            end
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

local function destroyEffects()
    for _, inst in ipairs(ActiveInstances) do
        pcall(function() if inst and inst.Parent then inst:Destroy() end end)
    end
    ActiveInstances = {}
    CurrentBall = nil
end

local function applyEffects(ball, presetName)
    destroyEffects()
    if not ball or not ball.Parent then return end
    local p = FIRE_PRESETS[presetName] or FIRE_PRESETS["Fogo Classico"]
    CurrentBall = ball

    local fire = Instance.new("Fire")
    fire.Name = "VST_Fire"
    fire.Color = p.fire
    fire.SecondaryColor = p.secondary
    fire.Size = p.size
    fire.Heat = 15
    fire.Parent = ball
    table.insert(ActiveInstances, fire)

    local size = ball.Size
    local offsetY = math.max(size.Y * 0.5, 1)

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

    local light = Instance.new("PointLight")
    light.Name = "VST_Light"
    light.Brightness = 3
    light.Range = 14
    light.Color = p.light
    light.Shadows = false
    light.Parent = ball
    table.insert(ActiveInstances, light)
end

function FireTrailModule.setEnabled(on)
    State.FireTrail.Enabled = on
    if on then
        local ball = findBall()
        if ball then
            applyEffects(ball, State.FireTrail.Preset)
            notify("Fire Trail ativado", "good")
        else
            notify("Bola nao encontrada", "bad")
        end
    else
        destroyEffects()
        notify("Fire Trail desativado", "bad")
    end
end

function FireTrailModule.setPreset(name)
    State.FireTrail.Preset = name
    if State.FireTrail.Enabled then
        local ball = CurrentBall
        if not ball or not ball.Parent then ball = findBall() end
        if ball then
            applyEffects(ball, name)
            notify("Rastro: " .. name, "good")
        end
    end
end

function FireTrailModule.refresh()
    local ball = findBall()
    if ball then
        applyEffects(ball, State.FireTrail.Preset)
        notify("Bola reconectada", "good")
    else
        notify("Nenhuma bola encontrada", "bad")
    end
end

function FireTrailModule.reset()
    State.FireTrail.Enabled = false
    destroyEffects()
    notify("Fire Trail resetado", "bad")
end

-- Loop de re-deteccao (caso a bola respawne)
task.spawn(function()
    while task.wait(1) do
        if State.FireTrail.Enabled then
            if not CurrentBall or not CurrentBall.Parent then
                local ball = findBall()
                if ball then applyEffects(ball, State.FireTrail.Preset) end
            end
        end
    end
end)

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

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Remover efeitos da bola", function()
        FireTrailModule.reset()
    end, 1)
end

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
-- BALL COLOR — Apenas cor da bola
--====================================================================

State.BallCustom = State.BallCustom or {
    Enabled = false,
    Color = nil,
}

local BallCustomModule = {}
local BallTarget = nil
local BallBackup = nil
local BallConn = nil

-- ---------- CORES ----------
local BALL_COLORS = {
    { name = "Branco",     color = Color3.fromRGB(255, 255, 255) },
    { name = "Preto",      color = Color3.fromRGB(20, 20, 20) },
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
    { name = "Metalico",   color = Color3.fromRGB(180, 180, 190) },
}

-- ---------- DETECCAO ----------
local function findBall()
    local char = LP.Character
    local function valid(p)
        if not p or not p:IsA("BasePart") then return false end
        if char and p:IsDescendantOf(char) then return false end
        return true
    end
    for _, name in ipairs({"TPS", "Bola", "Ball", "SoccerBall", "Soccer"}) do
        local b = Workspace:FindFirstChild(name, true)
        if valid(b) then return b end
    end
    return nil
end

-- ---------- APLICAR ----------
local function applyColor(ball, color)
    if not ball then return end
    if not BallBackup then
        BallBackup = {
            Color = ball.Color,
            Material = ball.Material,
        }
    end
    pcall(function()
        ball.Color = color
    end)
end

local function restoreBall()
    if BallTarget and BallTarget.Parent and BallBackup then
        pcall(function()
            BallTarget.Color = BallBackup.Color
            BallTarget.Material = BallBackup.Material
        end)
    end
    BallBackup = nil
end

-- ---------- MONITOR DE RESPAWN ----------
local function startMonitor()
    if BallConn then BallConn:Disconnect() end
    local lastSearch = 0
    BallConn = RunService.Heartbeat:Connect(function()
        if not State.BallCustom.Enabled then return end
        if not BallTarget or not BallTarget.Parent then
            local now = tick()
            if now - lastSearch < 1.5 then return end
            lastSearch = now
            task.spawn(function()
                local b = findBall()
                if b and State.BallCustom.Enabled then
                    BallTarget = b
                    BallBackup = nil
                    if State.BallCustom.Color then
                        applyColor(b, State.BallCustom.Color)
                    end
                end
            end)
        end
    end)
end

-- ---------- API ----------
function BallCustomModule.setEnabled(on)
    State.BallCustom.Enabled = on
    if on then
        task.spawn(function()
            BallTarget = findBall()
            if BallTarget then
                if State.BallCustom.Color then
                    applyColor(BallTarget, State.BallCustom.Color)
                end
                notify("Ball Color ativado", "good")
            else
                notify("Bola nao encontrada", "bad")
            end
            startMonitor()
        end)
    else
        restoreBall()
        if BallConn then
            BallConn:Disconnect()
            BallConn = nil
        end
        BallTarget = nil
        notify("Ball Color desativado", "bad")
    end
end

function BallCustomModule.setColor(name)
    for _, e in ipairs(BALL_COLORS) do
        if e.name == name then
            State.BallCustom.Color = e.color
            if BallTarget and BallTarget.Parent then
                applyColor(BallTarget, e.color)
            end
            notify("Cor: " .. name, "good")
            return
        end
    end
end

function BallCustomModule.refresh()
    task.spawn(function()
        local b = findBall()
        if b then
            BallTarget = b
            BallBackup = nil
            if State.BallCustom.Color then
                applyColor(b, State.BallCustom.Color)
            end
            notify("Bola reconectada", "good")
        else
            notify("Nenhuma bola encontrada", "bad")
        end
    end)
end

function BallCustomModule.reset()
    State.BallCustom.Enabled = false
    State.BallCustom.Color = nil
    restoreBall()
    if BallConn then
        BallConn:Disconnect()
        BallConn = nil
    end
    BallTarget = nil
    notify("Bola restaurada", "bad")
end

--====================================================================
-- ABA
--====================================================================
createTab("Ball", "BALL")

do
    local page = Tabs["Ball"].page

    local mainSec = section("Cor da Bola")
    mainSec.Parent = page

    toggleRow(mainSec, "Ativar Cor Custom", State.BallCustom.Enabled, function(on)
        BallCustomModule.setEnabled(on)
    end, 1)

    buttonRow(mainSec, "Reconectar a bola", function()
        BallCustomModule.refresh()
    end, 2)

    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "Muda a cor da bola. Apenas local - outros nao veem.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 3,
        Parent = mainSec,
    })
    themed(info, "TextColor3", "Sub")

    local colorSec = section("Cores")
    colorSec.Parent = page
    for i, e in ipairs(BALL_COLORS) do
        local row = buttonRow(colorSec, e.name, function()
            BallCustomModule.setColor(e.name)
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

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Restaurar cor original", function()
        BallCustomModule.reset()
    end, 1)
end

--====================================================================
-- CLEANUP
--====================================================================
local _prevBall = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevBall then _prevBall() end
    pcall(function()
        BallCustomModule.reset()
    end)
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function()
            BallCustomModule.reset()
        end)
    end
end)

print("[VoidStrap] Ball Color carregado.")
