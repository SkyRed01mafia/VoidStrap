--====================================================================
-- PARTE 4 — MÓDULO: ILUMINAÇÃO (ClockTime, slider 1–30)
-- Adiciona aba "Lighting" sem alterar as demais.
--====================================================================

-- Estado do módulo (aproveita a tabela State da Parte 1)
State.Lighting = State.Lighting or { Enabled = true, Hour = 12 }

--====================================================================
-- MÓDULO
--====================================================================
local LightingModule = {}
local OriginalClockTime = nil

local function captureClock()
    if OriginalClockTime then return end
    OriginalClockTime = Lighting.ClockTime
end

-- Slider 1..30 → ClockTime. Roblox aceita 0..24 com wrap suave
-- (valores >24 reiniciam o ciclo dia/noite automaticamente).
function LightingModule.setHour(h)
    captureClock()
    pcall(function()
        Lighting.ClockTime = h
    end)
end

function LightingModule.restore()
    if OriginalClockTime then
        pcall(function()
            Lighting.ClockTime = OriginalClockTime
        end)
    end
end

--====================================================================
-- NOVA ABA
--====================================================================
createTab("Lighting", "☀")

do
    local page = Tabs["Lighting"].page

    local sec = section("Iluminação")
    sec.Parent = page

    -- Toggle de ativação
    toggleRow(sec, "Ativar Iluminação", State.Lighting.Enabled, function(on)
        State.Lighting.Enabled = on
        if on then
            LightingModule.setHour(State.Lighting.Hour)
            notify("Iluminação ativada", "good")
        else
            LightingModule.restore()
            notify("Iluminação desativada", "bad")
        end
    end, 1)

    -- Slider 1–30
    sliderRow(sec, "Hora (1–30)", 1, 30, State.Lighting.Hour, function(v)
        State.Lighting.Hour = v
        if State.Lighting.Enabled then
            LightingModule.setHour(v)
        end
    end, 2)

    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "Controla o horário do dia (ClockTime). Valores acima de 24 reiniciam o ciclo automaticamente.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 3,
        Parent = sec,
    })
    themed(info, "TextColor3", "Sub")

    -- Restaurar
    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Restaurar iluminação original", function()
        LightingModule.restore()
        notify("Iluminação restaurada", "good")
    end, 1)
end

--====================================================================
-- HOOK NO UNLOAD / CLEANUP (encadeia com o que já existe)
--====================================================================
local _prevUnload = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevUnload then _prevUnload() end
    pcall(function()
        LightingModule.restore()
    end)
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function()
            LightingModule.restore()
        end)
    end
end)

--====================================================================
-- FIM DA PARTE 4 — Aba "Lighting" adicionada
--====================================================================
print("[VoidStrap] Módulo de Iluminação carregado.")--====================================================================
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
-- Prioriza nome exato "tps" (bola do The Classic Soccer).
-- Fallback: nome com ball/bola/soccer/football, ou esfera pequena (1-6 studs).
local function looksLikeBall(obj)
    if not obj:IsA("BasePart") then return false end
    local char = LP.Character
    if char and obj:IsDescendantOf(char) then return false end

    local n = obj.Name:lower()

    -- Nome exato da bola do TPS
    if n == "tps" then return true end

    -- Outros nomes comuns
    if n:find("ball") or n:find("bola") or n:find("soccer") or
       n:find("football") or n:find("sphere") or n:find("pelota") then
        return true
    end

    -- Fallback: esferas pequenas (1 a 6 studs)
    if obj.Shape == Enum.PartType.Ball then
        local s = obj.Size
        local maxSize = math.max(s.X, s.Y, s.Z)
        if maxSize >= 1 and maxSize <= 6 then
            return true
        end
    end

    return false
end

local function findBall()
    local candidates = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if looksLikeBall(obj) then
            table.insert(candidates, obj)
        end
    end
    if #candidates == 0 then return nil end

    -- Prioriza: nome "tps" > MeshPart > Shape Ball > tamanho
    table.sort(candidates, function(a, b)
        local function score(x)
            local s = 0
            if x.Name:lower() == "tps" then s = s + 10 end
            if x:IsA("MeshPart") then s = s + 2 end
            if x.Shape == Enum.PartType.Ball then s = s + 3 end
            s = s + math.min(x.Size.Magnitude, 10)
            return s
        end
        return score(a) > score(b)
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
    light.Shadows = false
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
-- HOOK NO UNLOAD / CLEANUP
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
-- FIM DA PARTE 5
--====================================================================
print("[VoidStrap] Módulo Fire Trail carregado.")
