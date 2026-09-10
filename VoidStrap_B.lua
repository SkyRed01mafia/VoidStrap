--====================================================================
-- PARTE 5 — FIRE TRAIL NA BOLA (versão SIMPLES e direta)
-- Anexa Trail + Fire DIRETO na bola, como os scripts de rastro de player.
--====================================================================

State.FireTrail = State.FireTrail or { Enabled = false, Preset = "Fogo Clássico" }

local FireTrailModule = {}

local CurrentBall   = nil
local ActiveEffects = {}
local DebugLabel    = nil
local DebugLog      = {}

local function dbg(msg)
    table.insert(DebugLog, 1, msg)
    while #DebugLog > 10 do table.remove(DebugLog) end
    if DebugLabel then DebugLabel.Text = table.concat(DebugLog, "\n") end
    print("[FireTrail] " .. msg)
end

-- ---------- PRESETS ----------
local PRESETS = {
    ["Fogo Clássico"] = { c1=Color3.fromRGB(255,120,30), c2=Color3.fromRGB(255,60,0) },
    ["Fogo Azul"]     = { c1=Color3.fromRGB(80,180,255), c2=Color3.fromRGB(30,90,220) },
    ["Fogo Roxo"]     = { c1=Color3.fromRGB(180,80,255), c2=Color3.fromRGB(120,30,220) },
    ["Fogo Verde"]    = { c1=Color3.fromRGB(100,255,120), c2=Color3.fromRGB(30,200,60) },
    ["Fogo Branco"]   = { c1=Color3.fromRGB(255,255,255), c2=Color3.fromRGB(220,240,255) },
    ["Fogo Sombrio"]  = { c1=Color3.fromRGB(80,20,100), c2=Color3.fromRGB(30,5,40) },
    ["Inferno"]       = { c1=Color3.fromRGB(255,80,0), c2=Color3.fromRGB(255,220,60) },
}

-- ---------- BUSCA A BOLA ----------
-- Busca rápida: só "tps" e nomes comuns, sem varrer o Workspace inteiro.
local function findBall()
    local char = LP.Character

    local function isValid(p)
        if not p or not p:IsA("BasePart") then return false end
        if char and p:IsDescendantOf(char) then return false end
        return true
    end

    -- Prioridade 1: "TPS" ou "Bola"
    for _, name in ipairs({"TPS", "Bola", "Ball", "SoccerBall"}) do
        local b = Workspace:FindFirstChild(name, true)
        if isValid(b) then return b end
    end

    -- Prioridade 2: qualquer coisa com "ball"/"bola"
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("ball") then
            if isValid(obj) then return obj end
        end
        if obj:IsA("Model") then
            for _, sub in ipairs(obj:GetChildren()) do
                if sub:IsA("BasePart") then
                    local n = sub.Name:lower()
                    if n:find("ball") or n:find("bola") or n == "tps" then
                        if isValid(sub) then return sub end
                    end
                end
            end
        end
    end

    return nil
end

-- ---------- LIMPA EFEITOS ----------
local function clearEffects()
    for _, obj in ipairs(ActiveEffects) do
        pcall(function()
            if obj and obj.Parent then obj:Destroy() end
        end)
    end
    ActiveEffects = {}
end

-- ---------- APLICA EFEITOS DIRETO NA BOLA ----------
local function applyToBall(ball, presetName)
    if not ball or not ball.Parent then return false end

    clearEffects()

    local p = PRESETS[presetName] or PRESETS["Fogo Clássico"]
    dbg("Anexando em: " .. ball.Name)

    -- 1) Fire DIRETO na bola
    local fire = Instance.new("Fire")
    fire.Name = "VST_Fire"
    fire.Color = p.c1
    fire.SecondaryColor = p.c2
    fire.Size = 10
    fire.Heat = 20
    fire.Parent = ball
    table.insert(ActiveEffects, fire)

    -- 2) Attachments pra o Trail
    local a0 = Instance.new("Attachment")
    a0.Name = "VST_A0"
    a0.Position = Vector3.new(0, 0.5, 0)
    a0.Parent = ball
    table.insert(ActiveEffects, a0)

    local a1 = Instance.new("Attachment")
    a1.Name = "VST_A1"
    a1.Position = Vector3.new(0, -0.5, 0)
    a1.Parent = ball
    table.insert(ActiveEffects, a1)

    -- 3) Trail DIRETO na bola (igual aos scripts de rastro de player)
    local trail = Instance.new("Trail")
    trail.Name = "VST_Trail"
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, p.c1),
        ColorSequenceKeypoint.new(0.5, p.c2),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(0, 0, 0)),
    })
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.1),
        NumberSequenceKeypoint.new(0.6, 0.4),
        NumberSequenceKeypoint.new(1.0, 1.0),
    })
    trail.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 2.0),
        NumberSequenceKeypoint.new(0.5, 1.2),
        NumberSequenceKeypoint.new(1.0, 0.3),
    })
    trail.Lifetime = 1.0
    trail.LightEmission = 1
    trail.LightInfluence = 0
    trail.FaceCamera = true
    trail.Parent = ball
    table.insert(ActiveEffects, trail)

    -- 4) Partículas extras
    local sparks = Instance.new("ParticleEmitter")
    sparks.Name = "VST_Sparks"
    sparks.Color = ColorSequence.new(p.c1, p.c2)
    sparks.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 1.5),
        NumberSequenceKeypoint.new(1.0, 0.0),
    })
    sparks.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.2),
        NumberSequenceKeypoint.new(1.0, 1.0),
    })
    sparks.Lifetime = NumberRange.new(0.5, 1.0)
    sparks.Rate = 60
    sparks.Speed = NumberRange.new(2, 6)
    sparks.SpreadAngle = Vector2.new(180, 180)
    sparks.LightEmission = 1
    sparks.LightInfluence = 0
    sparks.Parent = ball
    table.insert(ActiveEffects, sparks)

    -- 5) Luz
    local light = Instance.new("PointLight")
    light.Name = "VST_Light"
    light.Brightness = 4
    light.Range = 16
    light.Color = p.c1
    light.Shadows = false
    light.Parent = ball
    table.insert(ActiveEffects, light)

    CurrentBall = ball
    dbg("✓ Efeitos aplicados!")
    return true
end

-- ---------- API ----------
function FireTrailModule.setEnabled(on)
    State.FireTrail.Enabled = on
    if on then
        dbg("Ativando...")
        task.spawn(function()
            local ball = findBall()
            if ball then
                applyToBall(ball, State.FireTrail.Preset)
                notify("Fire Trail ativado", "good")
            else
                dbg("❌ Bola não encontrada")
                notify("Bola não encontrada", "bad")
            end
        end)
    else
        clearEffects()
        CurrentBall = nil
        dbg("Desativado")
        notify("Fire Trail desativado", "bad")
    end
end

function FireTrailModule.setPreset(name)
    State.FireTrail.Preset = name
    if State.FireTrail.Enabled and CurrentBall and CurrentBall.Parent then
        applyToBall(CurrentBall, name)
        notify("Estilo: " .. name, "good")
    end
end

function FireTrailModule.refresh()
    task.spawn(function()
        clearEffects()
        local ball = findBall()
        if ball then
            applyToBall(ball, State.FireTrail.Preset)
            notify("Bola reconectada", "good")
        else
            notify("Nenhuma bola encontrada", "bad")
        end
    end)
end

function FireTrailModule.reset()
    State.FireTrail.Enabled = false
    clearEffects()
    CurrentBall = nil
    DebugLog = {}
    if DebugLabel then DebugLabel.Text = "(reset)" end
    notify("Fire Trail resetado", "bad")
end

-- ---------- MONITOR DE RESPAWN (2s) ----------
-- Se a bola sumir e reaparecer, reanexa.
task.spawn(function()
    while task.wait(2) do
        if State.FireTrail.Enabled then
            if not CurrentBall or not CurrentBall.Parent then
                local ball = findBall()
                if ball then
                    applyToBall(ball, State.FireTrail.Preset)
                    dbg("Respawn detectado")
                end
            end
        end
    end
end)

--====================================================================
-- ABA
--====================================================================
createTab("Fire Trail", "🔥")

do
    local page = Tabs["Fire Trail"].page
    local sec = section("Rastro de Fogo na Bola")
    sec.Parent = page

    toggleRow(sec, "Ativar Fire Trail", State.FireTrail.Enabled, function(on)
        FireTrailModule.setEnabled(on)
    end, 1)

    dropdownRow(sec, "Estilo",
        { "Fogo Clássico", "Fogo Azul", "Fogo Roxo", "Fogo Verde",
          "Fogo Branco", "Fogo Sombrio", "Inferno" },
        State.FireTrail.Preset,
        function(opt) FireTrailModule.setPreset(opt) end, 2)

    buttonRow(sec, "🔄 Forçar busca da bola", function()
        FireTrailModule.refresh()
    end, 3)

    local debugFrame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 140),
        BackgroundColor3 = Color3.fromRGB(15, 15, 18),
        BorderSizePixel = 0,
        LayoutOrder = 4,
        Parent = sec,
    })
    corner(8, debugFrame)
    stroke(ActiveTheme.Stroke, 1, 0.4, debugFrame)

    DebugLabel = create("TextLabel", {
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
end

--====================================================================
-- CLEANUP
--====================================================================
local _prevUnload2 = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevUnload2 then _prevUnload2() end
    pcall(function() FireTrailModule.reset() end)
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function() FireTrailModule.reset() end)
    end
end)

print("[VoidStrap] Fire Trail (direct) carregado.")
--====================================================================
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

print("[VoidStrap] Player Trail carregado.")
