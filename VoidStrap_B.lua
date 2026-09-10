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
-- PARTE 5 — FIRE TRAIL (Mobile-Optimized)
--====================================================================

State.FireTrail = State.FireTrail or { Enabled = false, Preset = "Fogo Clássico" }

local FireTrailModule = {}

local CurrentBall     = nil
local GhostPart       = nil
local HeartbeatConn   = nil
local ActiveInstances = {}
local DebugLabel      = nil
local DebugLog        = {}

local function dbg(msg)
    table.insert(DebugLog, 1, msg)
    while #DebugLog > 8 do table.remove(DebugLog) end
    if DebugLabel then
        DebugLabel.Text = table.concat(DebugLog, "\n")
    end
    print("[FireTrail] " .. msg)
end

-- ---------- PRESETS ----------
local FIRE_PRESETS = {
    ["Fogo Clássico"] = { fire=Color3.fromRGB(255,120,30), secondary=Color3.fromRGB(255,60,0),
        trail=Color3.fromRGB(255,180,60), trailMid=Color3.fromRGB(255,80,20),
        light=Color3.fromRGB(255,140,40), size=8 },
    ["Fogo Azul"] = { fire=Color3.fromRGB(80,180,255), secondary=Color3.fromRGB(30,90,220),
        trail=Color3.fromRGB(150,210,255), trailMid=Color3.fromRGB(50,130,255),
        light=Color3.fromRGB(100,180,255), size=8 },
    ["Fogo Roxo"] = { fire=Color3.fromRGB(180,80,255), secondary=Color3.fromRGB(120,30,220),
        trail=Color3.fromRGB(210,150,255), trailMid=Color3.fromRGB(140,60,255),
        light=Color3.fromRGB(180,100,255), size=8 },
    ["Fogo Verde"] = { fire=Color3.fromRGB(100,255,120), secondary=Color3.fromRGB(30,200,60),
        trail=Color3.fromRGB(160,255,180), trailMid=Color3.fromRGB(50,220,100),
        light=Color3.fromRGB(120,255,140), size=8 },
    ["Fogo Branco"] = { fire=Color3.fromRGB(255,255,255), secondary=Color3.fromRGB(220,240,255),
        trail=Color3.fromRGB(255,255,255), trailMid=Color3.fromRGB(200,220,255),
        light=Color3.fromRGB(255,255,255), size=8 },
    ["Fogo Sombrio"] = { fire=Color3.fromRGB(80,20,100), secondary=Color3.fromRGB(30,5,40),
        trail=Color3.fromRGB(150,50,200), trailMid=Color3.fromRGB(80,10,120),
        light=Color3.fromRGB(120,30,180), size=8 },
    ["Inferno"] = { fire=Color3.fromRGB(255,80,0), secondary=Color3.fromRGB(255,220,60),
        trail=Color3.fromRGB(255,160,30), trailMid=Color3.fromRGB(255,60,0),
        light=Color3.fromRGB(255,120,20), size=10 },
}

-- ---------- BUSCA OTIMIZADA ----------
-- Tenta por nome exato primeiro (rápido: FindFirstChild com recurse).
-- Só faz varredura completa se não achar por nome.
local function findBall()
    -- 1) Busca rápida por nome "TPS"
    local ball = Workspace:FindFirstChild("TPS", true)
    if ball and ball:IsA("BasePart") then
        local char = LP.Character
        if not (char and ball:IsDescendantOf(char)) then
            return ball
        end
    end

    -- 2) Busca por nome "Ball"/"Bola"
    for _, name in ipairs({"Ball", "Bola", "SoccerBall", "Football", "Pelota"}) do
        local b = Workspace:FindFirstChild(name, true)
        if b and b:IsA("BasePart") then
            local char = LP.Character
            if not (char and b:IsDescendantOf(char)) then
                return b
            end
        end
    end

    -- 3) Fallback: procura em Models comuns de bola
    for _, container in ipairs({"Balls", "Ball", "Soccer", "Field", "Game"}) do
        local c = Workspace:FindFirstChild(container)
        if c then
            for _, obj in ipairs(c:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Shape == Enum.PartType.Ball or obj.Name:lower():find("ball") or obj.Name:lower() == "tps") then
                    return obj
                end
            end
        end
    end

    return nil
end

-- ---------- GHOST ----------
local function createGhost()
    if GhostPart and GhostPart.Parent then return end
    GhostPart = Instance.new("Part")
    GhostPart.Name = "VST_Ghost"
    GhostPart.Size = Vector3.new(3, 3, 3)
    GhostPart.Transparency = 0.98
    GhostPart.Material = Enum.Material.SmoothPlastic
    GhostPart.Color = Color3.new(0, 0, 0)
    GhostPart.CanCollide = false
    GhostPart.CanQuery = false
    GhostPart.CanTouch = false
    GhostPart.Anchored = true
    GhostPart.CastShadow = false
    GhostPart.Massless = true
    GhostPart.Parent = Workspace
    table.insert(ActiveInstances, GhostPart)
end

-- ---------- EFEITOS ----------
local function attachEffects(presetName)
    local p = FIRE_PRESETS[presetName] or FIRE_PRESETS["Fogo Clássico"]
    if not GhostPart or not GhostPart.Parent then return end

    local fire = Instance.new("Fire")
    fire.Name = "VST_Fire"
    fire.Color = p.fire
    fire.SecondaryColor = p.secondary
    fire.Size = p.size
    fire.Heat = 20
    fire.Parent = GhostPart
    table.insert(ActiveInstances, fire)

    local a0 = Instance.new("Attachment")
    a0.Name = "VST_A0"
    a0.Position = Vector3.new(0, 1, 0)
    a0.Parent = GhostPart
    table.insert(ActiveInstances, a0)

    local a1 = Instance.new("Attachment")
    a1.Name = "VST_A1"
    a1.Position = Vector3.new(0, -1, 0)
    a1.Parent = GhostPart
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
        NumberSequenceKeypoint.new(0.0, 0.1),
        NumberSequenceKeypoint.new(0.6, 0.5),
        NumberSequenceKeypoint.new(1.0, 1.0),
    })
    trail.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 2.5),
        NumberSequenceKeypoint.new(0.5, 1.5),
        NumberSequenceKeypoint.new(1.0, 0.2),
    })
    trail.Lifetime = 0.8
    trail.LightEmission = 1
    trail.LightInfluence = 0
    trail.FaceCamera = true
    trail.Parent = GhostPart
    table.insert(ActiveInstances, trail)

    local sparks = Instance.new("ParticleEmitter")
    sparks.Name = "VST_Sparks"
    sparks.Color = ColorSequence.new(p.fire, p.secondary)
    sparks.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 2.0),
        NumberSequenceKeypoint.new(1.0, 0.0),
    })
    sparks.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.15),
        NumberSequenceKeypoint.new(1.0, 1.0),
    })
    sparks.Lifetime = NumberRange.new(0.7, 1.3)
    sparks.Rate = 100
    sparks.Speed = NumberRange.new(3, 9)
    sparks.SpreadAngle = Vector2.new(180, 180)
    sparks.Rotation = NumberRange.new(0, 360)
    sparks.RotSpeed = NumberRange.new(-180, 180)
    sparks.LightEmission = 1
    sparks.LightInfluence = 0
    sparks.Parent = GhostPart
    table.insert(ActiveInstances, sparks)

    local light = Instance.new("PointLight")
    light.Name = "VST_Light"
    light.Brightness = 5
    light.Range = 20
    light.Color = p.light
    light.Shadows = false
    light.Parent = GhostPart
    table.insert(ActiveInstances, light)
end

local function destroyEffects()
    if HeartbeatConn then
        HeartbeatConn:Disconnect()
        HeartbeatConn = nil
    end
    for _, inst in ipairs(ActiveInstances) do
        pcall(function()
            if inst and inst.Parent then inst:Destroy() end
        end)
    end
    ActiveInstances = {}
    CurrentBall = nil
    GhostPart = nil
end

-- ---------- LOOP DE FOLLOW ----------
local function startFollowLoop()
    if HeartbeatConn then HeartbeatConn:Disconnect() end
    local lastSearch = 0
    HeartbeatConn = RunService.Heartbeat:Connect(function()
        if not State.FireTrail.Enabled then return end

        -- Bola existe?
        if not CurrentBall or not CurrentBall.Parent then
            local now = tick()
            if now - lastSearch < 1 then return end
            lastSearch = now

            -- Não roda no Heartbeat direto — spawn pra não travar
            task.spawn(function()
                local b = findBall()
                if b and State.FireTrail.Enabled then
                    CurrentBall = b
                    dbg("Bola: " .. b.Name)
                    if not GhostPart or not GhostPart.Parent then
                        createGhost()
                        attachEffects(State.FireTrail.Preset)
                    end
                end
            end)
            return
        end

        if not GhostPart or not GhostPart.Parent then
            createGhost()
            attachEffects(State.FireTrail.Preset)
            return
        end

        pcall(function()
            GhostPart.CFrame = CurrentBall.CFrame
        end)
    end)
end

-- ---------- API ----------
function FireTrailModule.setEnabled(on)
    State.FireTrail.Enabled = on
    if on then
        dbg("Ativando...")
        task.spawn(function()
            destroyEffects()
            dbg("Criando ghost...")
            createGhost()
            dbg("Procurando bola...")

            local b = findBall()
            if b and State.FireTrail.Enabled then
                CurrentBall = b
                dbg("Bola: " .. b.Name)
                attachEffects(State.FireTrail.Preset)
                dbg("Efeitos OK")
                startFollowLoop()
                notify("Fire Trail ativado", "good")
            else
                dbg("Bola não achada — loop procura")
                startFollowLoop()
                notify("Aguardando bola...", "bad")
            end
        end)
    else
        destroyEffects()
        dbg("Desativado")
        notify("Fire Trail desativado", "bad")
    end
end

function FireTrailModule.setPreset(name)
    State.FireTrail.Preset = name
    if State.FireTrail.Enabled and GhostPart then
        for _, inst in ipairs(ActiveInstances) do
            if inst ~= GhostPart then
                pcall(function() if inst.Parent then inst:Destroy() end end)
            end
        end
        ActiveInstances = { GhostPart }
        attachEffects(name)
        notify("Rastro: " .. name, "good")
    end
end

function FireTrailModule.refresh()
    task.spawn(function()
        destroyEffects()
        if State.FireTrail.Enabled then
            dbg("Re-procurando...")
            local b = findBall()
            if b then
                CurrentBall = b
                createGhost()
                attachEffects(State.FireTrail.Preset)
                startFollowLoop()
                dbg("Bola: " .. b.Name)
                notify("Bola reconectada", "good")
            else
                notify("Nenhuma bola encontrada", "bad")
            end
        end
    end)
end

function FireTrailModule.reset()
    State.FireTrail.Enabled = false
    destroyEffects()
    DebugLog = {}
    if DebugLabel then DebugLabel.Text = "(reset)" end
    notify("Fire Trail resetado", "bad")
end

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
        Size = UDim2.new(1, 0, 0, 130),
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

print("[VoidStrap] Fire Trail (mobile optimized) carregado.")
