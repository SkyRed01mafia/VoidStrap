--====================================================================
-- PARTE 5 — MÓDULO: FIRE TRAIL NA BOLA (The Classic Soccer)
-- Detecta a bola automaticamente, anexa Fire + Trail + Particles + PointLight
-- 100% local (client-only), não replica para o servidor, reversível.
--====================================================================

State.FireTrail = State.FireTrail or { Enabled = false, Preset = "Fogo Clássico" }

--====================================================================
-- MÓDULO
--====================================================================
local FireTrailModule = {}

local CurrentBall     = nil
local ActiveInstances = {}  -- lista de instâncias criadas para cleanup

-- ---------- PRESETS DE COR ----------
local FIRE_PRESETS = {
    ["Fogo Clássico"] = {
        fire      = Color3.fromRGB(255, 120, 30),
        secondary = Color3.fromRGB(255, 60, 0),
        trail     = Color3.fromRGB(255, 180, 60),
        trailMid  = Color3.fromRGB(255, 80, 20),
        light     = Color3.fromRGB(255, 140, 40),
        size      = 6,
    },
    ["Fogo Azul"] = {
        fire      = Color3.fromRGB(80, 180, 255),
        secondary = Color3.fromRGB(30, 90, 220),
        trail     = Color3.fromRGB(150, 210, 255),
        trailMid  = Color3.fromRGB(50, 130, 255),
        light     = Color3.fromRGB(100, 180, 255),
        size      = 6,
    },
    ["Fogo Roxo"] = {
        fire      = Color3.fromRGB(180, 80, 255),
        secondary = Color3.fromRGB(120, 30, 220),
        trail     = Color3.fromRGB(210, 150, 255),
        trailMid  = Color3.fromRGB(140, 60, 255),
        light     = Color3.fromRGB(180, 100, 255),
        size      = 6,
    },
    ["Fogo Verde"] = {
        fire      = Color3.fromRGB(100, 255, 120),
        secondary = Color3.fromRGB(30, 200, 60),
        trail     = Color3.fromRGB(160, 255, 180),
        trailMid  = Color3.fromRGB(50, 220, 100),
        light     = Color3.fromRGB(120, 255, 140),
        size      = 6,
    },
    ["Fogo Branco"] = {
        fire      = Color3.fromRGB(255, 255, 255),
        secondary = Color3.fromRGB(220, 240, 255),
        trail     = Color3.fromRGB(255, 255, 255),
        trailMid  = Color3.fromRGB(200, 220, 255),
        light     = Color3.fromRGB(255, 255, 255),
        size      = 6,
    },
    ["Fogo Sombrio"] = {
        fire      = Color3.fromRGB(80, 20, 100),
        secondary = Color3.fromRGB(30, 5, 40),
        trail     = Color3.fromRGB(150, 50, 200),
        trailMid  = Color3.fromRGB(80, 10, 120),
        light     = Color3.fromRGB(120, 30, 180),
        size      = 6,
    },
    ["Inferno"] = {
        fire      = Color3.fromRGB(255, 80, 0),
        secondary = Color3.fromRGB(255, 220, 60),
        trail     = Color3.fromRGB(255, 160, 30),
        trailMid  = Color3.fromRGB(255, 60, 0),
        light     = Color3.fromRGB(255, 120, 20),
        size      = 8,
    },
}

-- ---------- DETECÇÃO DA BOLA ----------
-- Heurística: nome contém "ball"/"bola" e é BasePart, não é do Character.
local function looksLikeBall(obj)
    if not obj:IsA("BasePart") then return false end
    local n = obj.Name:lower()
    if not (n:find("ball") or n:find("bola") or n == "soccer" or n:find("football")) then
        return false
    end
    -- Descarta se estiver dentro do Character (evita pegar acessórios)
    local char = LP.Character
    if char and obj:IsDescendantOf(char) then return false end
    return true
end

local function findBall()
    -- Primeiro tenta por nome exato (mais rápido)
    local candidates = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if looksLikeBall(obj) then
            table.insert(candidates, obj)
        end
    end
    if #candidates == 0 then return nil end

    -- Prioriza bolas com MeshPart, com esfera, ou maiores
    table.sort(candidates, function(a, b)
        local scoreA, scoreB = 0, 0
        if a:IsA("MeshPart") then scoreA = scoreA + 2 end
        if b:IsA("MeshPart") then scoreB = scoreB + 2 end
        if a.Shape == Enum.PartType.Ball then scoreA = scoreA + 3 end
        if b.Shape == Enum.PartType.Ball then scoreB = scoreB + 3 end
        scoreA = scoreA + a.Size.Magnitude
        scoreB = scoreB + b.Size.Magnitude
        return scoreA > scoreB
    end)

    return candidates[1]
end

-- ---------- CLEANUP ----------
local function destroyEffects()
    for _, inst in ipairs(ActiveInstances) do
        pcall(function()
            if inst and inst.Parent then inst:Destroy() end
        end)
    end
    ActiveInstances = {}
    CurrentBall = nil
end

-- ---------- APLICAR EFEITOS ----------
local function applyEffects(ball, presetName)
    destroyEffects()
    if not ball or not ball.Parent then return end

    local p = FIRE_PRESETS[presetName] or FIRE_PRESETS["Fogo Clássico"]
    CurrentBall = ball

    -- Guarda flag para pular o Character (evita detecção desnecessária)
    -- Como só decoramos a bola, não há risco direto de anti-cheat.

    -- 1) Fire clássico
    local fire = Instance.new("Fire")
    fire.Name = "VST_Fire"
    fire.Color = p.fire
    fire.SecondaryColor = p.secondary
    fire.Size = p.size
    fire.Heat = 15
    fire.Parent = ball
    table.insert(ActiveInstances, fire)

    -- 2) Attachments para o Trail (topo e base da bola)
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

    -- 3) Trail em gradiente (fogo → transparente)
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
    trail.MinLength = 0
    trail.LightEmission = 1
    trail.LightInfluence = 0
    trail.FaceCamera = true
    trail.Parent = ball
    table.insert(ActiveInstances, trail)

    -- 4) Faíscas (ParticleEmitter)
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
    sparks.Rotation = NumberRange.new(0, 360)
    sparks.RotSpeed = NumberRange.new(-180, 180)
    sparks.LightEmission = 1
    sparks.LightInfluence = 0
    sparks.Parent = ball
    table.insert(ActiveInstances, sparks)

    -- 5) Brilho ambiente (PointLight)
    local light = Instance.new("PointLight")
    light.Name = "VST_Light"
    light.Brightness = 3
    light.Range = 14
    light.Color = p.light
    light.Shadows = false   -- menos custo + menos "pesado" para anti-cheat
    light.Parent = ball
    table.insert(ActiveInstances, light)
end

-- ---------- API PÚBLICA ----------
function FireTrailModule.setEnabled(on)
    State.FireTrail.Enabled = on
    if on then
        local ball = findBall()
        if ball then
            applyEffects(ball, State.FireTrail.Preset)
            notify("Fire Trail ativado na bola", "good")
        else
            notify("Bola não encontrada ainda...", "bad")
            -- continua tentando via loop
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
        if not ball or not ball.Parent then
            ball = findBall()
        end
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

--====================================================================
-- LOOP DE RE-DETECÇÃO (leve, 1s)
-- Se a bola sumir (fim de rodada) e reaparecer, reanexa automaticamente.
--====================================================================
task.spawn(function()
    while task.wait(1) do
        if State.FireTrail.Enabled then
            if not CurrentBall or not CurrentBall.Parent then
                local ball = findBall()
                if ball then
                    applyEffects(ball, State.FireTrail.Preset)
                end
            end
        end
    end
end)

--====================================================================
-- NOVA ABA
--====================================================================
createTab("Fire Trail", "🔥")

do
    local page = Tabs["Fire Trail"].page

    local sec = section("Rastro de Fogo na Bola")
    sec.Parent = page

    -- Toggle
    toggleRow(sec, "Ativar Fire Trail", State.FireTrail.Enabled, function(on)
        FireTrailModule.setEnabled(on)
    end, 1)

    -- Dropdown de preset
    dropdownRow(sec, "Estilo",
        { "Fogo Clássico", "Fogo Azul", "Fogo Roxo", "Fogo Verde",
          "Fogo Branco", "Fogo Sombrio", "Inferno" },
        State.FireTrail.Preset,
        function(opt) FireTrailModule.setPreset(opt) end, 2)

    -- Botão de reconectar manualmente
    buttonRow(sec, "🔄 Forçar busca da bola", function()
        FireTrailModule.refresh()
    end, 3)

    -- Info
    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Text = "Anexa fogo, trail, faíscas e luz na bola. 100% local, reversível e detecta respawn da bola automaticamente.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 4,
        Parent = sec,
    })
    themed(info, "TextColor3", "Sub")

    -- Restaurar
    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Remover efeitos da bola", function()
        FireTrailModule.reset()
    end, 1)

    local warnLbl = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "⚠ Efeitos visuais são locais. Se algum jogo bloquear criação de instâncias em partes replicadas, desative.",
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
-- HOOK NO UNLOAD / CLEANUP (encadeia com o que já existe)
--====================================================================
local _prevUnload2 = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevUnload2 then _prevUnload2() end
    pcall(function()
        FireTrailModule.reset()
    end)
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function()
            FireTrailModule.reset()
        end)
    end
end)

--====================================================================
-- FIM DA PARTE 5 — Aba "Fire Trail" adicionada
--====================================================================
print("[VoidStrap] Módulo Fire Trail carregado.")--====================================================================
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
-- PARTE 5C — SKYBOX TIPO CAIXA (6 faces, igual ao Sky original)
--====================================================================

State.SkyTexture = State.SkyTexture or { Enabled = false, Current = nil }

local SkyTextureModule = {}
local SkyBoxModel = nil
local FollowConn = nil

local CUSTOM_SKIES = {
    { name = "Sunset",   id = "1495782126" },
    { name = "Blue Sky", id = "1478440122" },
    { name = "Night",    id = "398409631"  },
    { name = "Galaxy",   id = "4976299654" },
    { name = "Clouds",   id = "4713323714" },
    { name = "Red Sky",  id = "6056205191" },
    { name = "Space",    id = "6066307115" },
}

local SIZE = 3000  -- tamanho da caixa

local function destroySkyBox()
    if FollowConn then
        FollowConn:Disconnect()
        FollowConn = nil
    end
    if SkyBoxModel and SkyBoxModel.Parent then
        SkyBoxModel:Destroy()
    end
    SkyBoxModel = nil
end

-- Cria caixa com 6 faces (uma para cada direção)
local function createSkyBox(id)
    destroySkyBox()

    local model = Instance.new("Model")
    model.Name = "VST_SkyBox"
    model.Parent = Workspace

    local url = "rbxassetid://" .. id

    -- Tabela com as 6 faces: nome, offset da câmera, rotação
    local half = SIZE / 2
    local faces = {
        { name = "Front",  offset = CFrame.new(0, 0, -half) * CFrame.Angles(0, math.rad(180), 0) },
        { name = "Back",   offset = CFrame.new(0, 0,  half) },
        { name = "Left",   offset = CFrame.new(-half, 0, 0) * CFrame.Angles(0, math.rad(90), 0) },
        { name = "Right",  offset = CFrame.new( half, 0, 0) * CFrame.Angles(0, math.rad(-90), 0) },
        { name = "Top",    offset = CFrame.new(0,  half, 0) * CFrame.Angles(math.rad(-90), 0, 0) },
        { name = "Bottom", offset = CFrame.new(0, -half, 0) * CFrame.Angles(math.rad(90), 0, 0) },
    }

    for _, face in ipairs(faces) do
        local part = Instance.new("Part")
        part.Name = "VST_SkyFace_" .. face.name
        part.Size = Vector3.new(SIZE, SIZE, 1)
        part.Anchored = true
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.CastShadow = false
        part.Material = Enum.Material.SmoothPlastic
        part.Color = Color3.fromRGB(255, 255, 255)
        part.Locked = true

        local decal = Instance.new("Decal")
        decal.Face = Enum.NormalId.Back
        decal.Texture = url
        decal.Parent = part

        part.Parent = model
    end

    SkyBoxModel = model

    -- Segue a câmera
    FollowConn = RunService.RenderStepped:Connect(function()
        if not SkyBoxModel or not SkyBoxModel.Parent or not Camera then return end
        local baseCF = CFrame.new(Camera.CFrame.Position)

        for _, face in ipairs(faces) do
            local part = SkyBoxModel:FindFirstChild("VST_SkyFace_" .. face.name)
            if part then
                part.CFrame = baseCF * face.offset
            end
        end
    end)

    return model
end

function SkyTextureModule.apply(name)
    for _, entry in ipairs(CUSTOM_SKIES) do
        if entry.name == name then
            State.SkyTexture.Enabled = true
            State.SkyTexture.Current = name
            createSkyBox(entry.id)
            notify("Sky: " .. name, "good")
            return
        end
    end
end

function SkyTextureModule.restore()
    State.SkyTexture.Enabled = false
    State.SkyTexture.Current = nil
    destroySkyBox()
    notify("Sky restaurado", "good")
end

--====================================================================
-- ABA
--====================================================================
createTab("Skies", "SKY")

do
    local page = Tabs["Skies"].page
    local sec = section("Skies (Caixa 6 Faces)")
    sec.Parent = page

    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundTransparency = 1,
        Text = "Caixa gigante com 6 faces. Mesmo metodo que o Sky do Roblox usa internamente. Segue a camera.",
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = ActiveTheme.Sub, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1, Parent = sec,
    })
    themed(info, "TextColor3", "Sub")

    for i, sky in ipairs(CUSTOM_SKIES) do
        buttonRow(sec, sky.name, function()
            SkyTextureModule.apply(sky.name)
        end, 10 + i)
    end

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Remover Sky", function()
        SkyTextureModule.restore()
    end, 1)
end

local _prevUnload4 = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevUnload4 then _prevUnload4() end
    pcall(function() SkyTextureModule.restore() end)
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function() SkyTextureModule.restore() end)
    end
end)

print("[VoidStrap] Skybox Caixa carregado.")
