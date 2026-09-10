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
