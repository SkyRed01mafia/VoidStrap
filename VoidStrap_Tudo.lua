--[[ VoidStrap v1.3.0 — Interface Premium ]]

--====================================================================
-- SERVIÇOS
--====================================================================
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local Workspace    = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--====================================================================
-- DETECÇÃO DE EXECUTOR
--====================================================================
local ExecutorInfo = { Name = "Desconhecido", Mobile = false, HasGethui = false }
pcall(function()
    if identifyexecutor then ExecutorInfo.Name = identifyexecutor()
    elseif getexecutorname then ExecutorInfo.Name = getexecutorname() end
end)
ExecutorInfo.Mobile    = UIS.TouchEnabled and not UIS.KeyboardEnabled
ExecutorInfo.HasGethui = (type(gethui) == "function")

print(("[VoidStrap] Executor=%s | Mobile=%s"):format(ExecutorInfo.Name, tostring(ExecutorInfo.Mobile)))

--====================================================================
-- PARENT SEGURO
--====================================================================
local function obterParentSeguro()
    if ExecutorInfo.HasGethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    return LP:WaitForChild("PlayerGui")
end
local GuiParent = obterParentSeguro()

local VERSAO = "v1.3.0"
local TITULO = "VoidStrap"

--====================================================================
-- TEMAS
--====================================================================
local Temas = {
    Kirtium = {
        Background=Color3.fromRGB(11,13,12), Background2=Color3.fromRGB(7,9,8),
        Surface=Color3.fromRGB(21,24,22), Surface2=Color3.fromRGB(31,35,32),
        Surface3=Color3.fromRGB(42,47,43),
        Accent=Color3.fromRGB(80,225,140), Accent2=Color3.fromRGB(50,180,100),
        AccentDim=Color3.fromRGB(30,100,60),
        Text=Color3.fromRGB(245,248,246), Sub=Color3.fromRGB(150,158,152),
        Stroke=Color3.fromRGB(46,52,48), Stroke2=Color3.fromRGB(66,74,68),
        Good=Color3.fromRGB(80,220,140), Bad=Color3.fromRGB(230,90,90),
    },
    Void = {
        Background=Color3.fromRGB(13,13,17), Background2=Color3.fromRGB(8,8,11),
        Surface=Color3.fromRGB(24,24,30), Surface2=Color3.fromRGB(34,34,42),
        Surface3=Color3.fromRGB(44,44,54),
        Accent=Color3.fromRGB(140,100,255), Accent2=Color3.fromRGB(90,60,200),
        AccentDim=Color3.fromRGB(60,40,120),
        Text=Color3.fromRGB(240,240,248), Sub=Color3.fromRGB(150,150,168),
        Stroke=Color3.fromRGB(50,50,62), Stroke2=Color3.fromRGB(70,70,85),
        Good=Color3.fromRGB(80,210,130), Bad=Color3.fromRGB(230,85,85),
    },
    Midnight = {
        Background=Color3.fromRGB(8,12,20), Background2=Color3.fromRGB(5,8,14),
        Surface=Color3.fromRGB(14,20,32), Surface2=Color3.fromRGB(22,30,46),
        Surface3=Color3.fromRGB(30,40,60),
        Accent=Color3.fromRGB(80,160,255), Accent2=Color3.fromRGB(50,120,220),
        AccentDim=Color3.fromRGB(30,70,140),
        Text=Color3.fromRGB(230,240,255), Sub=Color3.fromRGB(130,150,180),
        Stroke=Color3.fromRGB(30,44,66), Stroke2=Color3.fromRGB(45,60,85),
        Good=Color3.fromRGB(80,220,160), Bad=Color3.fromRGB(230,90,100),
    },
    Ruby = {
        Background=Color3.fromRGB(18,10,12), Background2=Color3.fromRGB(12,5,7),
        Surface=Color3.fromRGB(30,16,20), Surface2=Color3.fromRGB(42,22,28),
        Surface3=Color3.fromRGB(56,30,38),
        Accent=Color3.fromRGB(255,90,120), Accent2=Color3.fromRGB(220,60,90),
        AccentDim=Color3.fromRGB(130,30,50),
        Text=Color3.fromRGB(255,235,240), Sub=Color3.fromRGB(190,140,150),
        Stroke=Color3.fromRGB(60,30,40), Stroke2=Color3.fromRGB(80,45,55),
        Good=Color3.fromRGB(120,220,140), Bad=Color3.fromRGB(255,80,80),
    },
}
local TemaAtivo = Temas.Kirtium

--====================================================================
-- ESTADO
--====================================================================
local Estado = {
    Settings = { AnimationsEnabled = true, SoundsEnabled = true, ThemeName = "Kirtium" },
    Skybox = { Enabled = false, Current = "Padrao" },
    Stretch = { Enabled = false, Intensity = 0, BaseFOV = 70 },
    Flags = { Enabled = false, Preset = "Balanced" },
    Lighting = { Enabled = false, Hour = 14 },
}
local Originais = { Instances = {} }

local function rastrear(inst, prop)
    Originais.Instances[inst] = Originais.Instances[inst] or {}
    if Originais.Instances[inst][prop] == nil then
        Originais.Instances[inst][prop] = inst[prop]
    end
end
local function restaurarInstancia(inst)
    local data = Originais.Instances[inst]
    if not data then return end
    for prop, value in pairs(data) do
        pcall(function() inst[prop] = value end)
    end
end
local function restaurarTudo()
    for inst in pairs(Originais.Instances) do restaurarInstancia(inst) end
    Originais.Instances = {}
end

--====================================================================
-- HELPERS
--====================================================================
local function criar(classe, props, filhos)
    local inst = Instance.new(classe)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, f in ipairs(filhos or {}) do f.Parent = inst end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end
local function canto(raio, parent)
    return criar("UICorner", { CornerRadius = UDim.new(0, raio or 8), Parent = parent })
end
local function contorno(cor, espessura, transparencia, parent, zindex)
    return criar("UIStroke", {
        Color = cor or Color3.new(1,1,1),
        Thickness = espessura or 1,
        Transparency = transparencia or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        ZIndex = zindex or 1,
        Parent = parent,
    })
end
local function espacamento(parent, px, top, bottom, left, right)
    return criar("UIPadding", {
        PaddingTop    = UDim.new(0, top or px),
        PaddingBottom = UDim.new(0, bottom or px),
        PaddingLeft   = UDim.new(0, left or px),
        PaddingRight  = UDim.new(0, right or px),
        Parent = parent,
    })
end
local function animar(inst, tempo, props, estilo, dir)
    if not Estado.Settings.AnimationsEnabled then
        for k, v in pairs(props) do inst[k] = v end
        return nil
    end
    local t = TweenService:Create(inst,
        TweenInfo.new(tempo, estilo or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props)
    t:Play()
    return t
end

local SomClique = criar("Sound", {
    SoundId = "rbxasset://sounds/electronicpingshort.wav",
    Volume = 0.35,
    Parent = SoundService,
})
local function tocarClique()
    if not Estado.Settings.SoundsEnabled then return end
    pcall(function() SomClique:Play() end)
end

local ElementosComTema = {}
local function comTema(inst, prop, chave)
    table.insert(ElementosComTema, { inst = inst, prop = prop, key = chave })
    inst[prop] = TemaAtivo[chave]
    return inst
end
local function aplicarTema(nome)
    local tema = Temas[nome] or Temas.Kirtium
    TemaAtivo = tema
    for _, e in ipairs(ElementosComTema) do
        local v = tema[e.key]
        if v then e.inst[e.prop] = v end
    end
end

--====================================================================
-- NOTIFICAÇÕES
--====================================================================
local NotificacoesHolder
local function notificar(texto, tipo)
    tipo = tipo or "info"
    if not NotificacoesHolder then return end
    local cor = TemaAtivo.Accent
    local icone = "."
    if tipo == "good" then cor = TemaAtivo.Good; icone = "+" end
    if tipo == "bad"  then cor = TemaAtivo.Bad;  icone = "x" end

    local frame = criar("Frame", {
        Size = UDim2.fromOffset(300, 48),
        BackgroundColor3 = TemaAtivo.Surface,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = NotificacoesHolder,
    })
    canto(10, frame)
    contorno(TemaAtivo.Stroke, 1, 0.3, frame)

    criar("Frame", {
        Size = UDim2.new(0, 4, 1, -14),
        Position = UDim2.new(0, 7, 0, 7),
        BackgroundColor3 = cor,
        BorderSizePixel = 0,
        Parent = frame,
    })

    local iconeLabel = criar("TextLabel", {
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.new(0, 20, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = cor,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Text = icone,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = cor,
        Parent = frame,
    })
    canto(12, iconeLabel)

    criar("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 52, 0, 0),
        BackgroundTransparency = 1,
        Text = texto,
        TextColor3 = TemaAtivo.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    frame.Position = UDim2.new(1, 30, 0, 0)
    animar(frame, 0.4, { Position = UDim2.new(0, 0, 0, 0) })
    animar(frame, 0.4, { BackgroundTransparency = 0 })

    task.delay(3, function()
        local out1 = animar(frame, 0.3, { Position = UDim2.new(1, 30, 0, 0) })
        animar(frame, 0.3, { BackgroundTransparency = 1 })
        if out1 then out1.Completed:Connect(function() frame:Destroy() end)
        else frame:Destroy() end
    end)
end

--====================================================================
-- SCREEN GUI
--====================================================================
local ScreenGui = criar("ScreenGui", {
    Name = "VoidStrapGui_" .. tostring(math.random(1000, 9999)),
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999999,
    Parent = GuiParent,
})

local ScreenOverlay = criar("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Parent = ScreenGui,
})

NotificacoesHolder = criar("Frame", {
    Size = UDim2.new(0, 320, 1, -100),
    Position = UDim2.new(1, -340, 0, 70),
    BackgroundTransparency = 1,
    Parent = ScreenOverlay,
})
criar("UIListLayout", {
    Padding = UDim.new(0, 8),
    VerticalAlignment = Enum.VerticalAlignment.Top,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = NotificacoesHolder,
})

local Main = criar("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(660, 460),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = TemaAtivo.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = ScreenOverlay,
})
comTema(Main, "BackgroundColor3", "Background")
canto(16, Main)
criar("UIGradient", {
    Color = ColorSequence.new(TemaAtivo.Background, TemaAtivo.Background2),
    Rotation = 45,
    Parent = Main,
})
contorno(TemaAtivo.Stroke, 1, 0.4, Main, 2)
contorno(TemaAtivo.AccentDim, 2, 0.85, Main, 3)

local TopBar = criar("Frame", {
    Size = UDim2.new(1, 0, 0, 56),
    BackgroundColor3 = TemaAtivo.Surface,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 5,
    Parent = Main,
})
canto(16, TopBar)
comTema(TopBar, "BackgroundColor3", "Surface")

criar("Frame", {
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(0, 0, 1, -16),
    BackgroundColor3 = TemaAtivo.Surface,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 5,
    Parent = TopBar,
})

local Logo = criar("Frame", {
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.new(0, 16, 0.5, -17),
    BackgroundColor3 = TemaAtivo.Accent,
    BorderSizePixel = 0,
    ZIndex = 6,
    Parent = TopBar,
})
comTema(Logo, "BackgroundColor3", "Accent")
canto(10, Logo)
criar("UIGradient", {
    Color = ColorSequence.new(TemaAtivo.Accent, TemaAtivo.Accent2),
    Rotation = 45,
    Parent = Logo,
})

local TituloLabel = criar("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 60, 0, 0),
    BackgroundTransparency = 1,
    Text = TITULO,
    Font = Enum.Font.GothamBold,
    TextSize = 19,
    TextColor3 = TemaAtivo.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 6,
    Parent = TopBar,
})
comTema(TituloLabel, "TextColor3", "Text")

local BadgeVersao = criar("Frame", {
    Size = UDim2.fromOffset(72, 26),
    Position = UDim2.new(0, 178, 0.5, -13),
    BackgroundColor3 = TemaAtivo.Surface2,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    ZIndex = 6,
    Parent = TopBar,
})
comTema(BadgeVersao, "BackgroundColor3", "Surface2")
canto(7, BadgeVersao)
contorno(TemaAtivo.Stroke, 1, 0.4, BadgeVersao, 6)
criar("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = VERSAO,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = TemaAtivo.Text,
    ZIndex = 7,
    Parent = BadgeVersao,
})

local Sidebar = criar("ScrollingFrame", {
    Size = UDim2.new(0, 160, 1, -56),
    Position = UDim2.new(0, 0, 0, 56),
    BackgroundColor3 = TemaAtivo.Background,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = TemaAtivo.Accent,
    ScrollBarImageTransparency = 0.5,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ScrollingEnabled = true,
    ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
    ClipsDescendants = true,
    ZIndex = 5,
    Parent = Main,
})
comTema(Sidebar, "BackgroundColor3", "Background")
espacamento(Sidebar, 10, 12, 12, 10, 6)
criar("UIListLayout", {
    Padding = UDim.new(0, 3),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = Sidebar,
})

local Content = criar("Frame", {
    Size = UDim2.new(1, -160, 1, -56),
    Position = UDim2.new(0, 160, 0, 56),
    BackgroundColor3 = TemaAtivo.Background,
    BackgroundTransparency = 0.7,
    BorderSizePixel = 0,
    ZIndex = 5,
    Parent = Main,
})
comTema(Content, "BackgroundColor3", "Background")
espacamento(Content, 16, 14, 14, 16, 16)

local function botaoTopBar(icone, offsetDireita, callback)
    local btn = criar("TextButton", {
        Size = UDim2.fromOffset(34, 34),
        Position = UDim2.new(1, offsetDireita, 0.5, -17),
        BackgroundColor3 = TemaAtivo.Surface2,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = icone,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = TemaAtivo.Sub,
        AutoButtonColor = false,
        ZIndex = 6,
        Parent = TopBar,
    })
    comTema(btn, "BackgroundColor3", "Surface2")
    comTema(btn, "TextColor3", "Sub")
    canto(9, btn)
    btn.MouseEnter:Connect(function()
        animar(btn, 0.15, { BackgroundColor3 = TemaAtivo.Surface3, BackgroundTransparency = 0, TextColor3 = TemaAtivo.Text })
    end)
    btn.MouseLeave:Connect(function()
        animar(btn, 0.15, { BackgroundColor3 = TemaAtivo.Surface2, BackgroundTransparency = 0.3, TextColor3 = TemaAtivo.Sub })
    end)
    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

botaoTopBar("X", -48, function()
    tocarClique()
    if _G.VoidStrapUnload then _G.VoidStrapUnload() end
    ScreenGui:Destroy()
end)

--====================================================================
-- BOTÃO FLUTUANTE "V" (minimizar)
--====================================================================
local BotaoFlutuanteMin = nil
local BFM_Estado = { Posicao = UDim2.new(0.02, 0, 0.5, 0), Travado = false }
local BFM_Arr, BFM_DragIni, BFM_PosIni = false, nil, nil

local function mostrarBotaoFlutuanteMin()
    if BotaoFlutuanteMin and BotaoFlutuanteMin.Parent then
        BotaoFlutuanteMin.Visible = true
        return
    end

    BotaoFlutuanteMin = criar("TextButton", {
        Name = "VST_MinBtn",
        Size = UDim2.fromOffset(50, 50),
        Position = BFM_Estado.Posicao,
        BackgroundColor3 = TemaAtivo.Accent,
        BorderSizePixel = 0,
        Text = "V",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = TemaAtivo.Text,
        AutoButtonColor = false,
        ZIndex = 99999,
        Parent = ScreenOverlay,
    })
    canto(12, BotaoFlutuanteMin)
    contorno(TemaAtivo.AccentDim, 2, 0.2, BotaoFlutuanteMin, 99999)

    BotaoFlutuanteMin.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            BFM_Arr = true
            BFM_DragIni = input.Position
            BFM_PosIni = BotaoFlutuanteMin.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not BFM_Arr or BFM_Estado.Travado then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - BFM_DragIni
            if math.abs(d.X) > 6 or math.abs(d.Y) > 6 then
                BotaoFlutuanteMin.Position = UDim2.new(
                    BFM_PosIni.X.Scale, BFM_PosIni.X.Offset + d.X,
                    BFM_PosIni.Y.Scale, BFM_PosIni.Y.Offset + d.Y)
                BFM_Estado.Posicao = BotaoFlutuanteMin.Position
            end
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            BFM_Arr = false
        end
    end)

    BotaoFlutuanteMin.MouseButton1Click:Connect(function()
        tocarClique()
        BotaoFlutuanteMin.Visible = false
        Main.Visible = true
        animar(Main, 0.3, { Size = UDim2.fromOffset(660, 460) })
    end)
end

botaoTopBar("-", -88, function()
    tocarClique()
    animar(Main, 0.3, { Size = UDim2.fromOffset(660, 56) })
    task.wait(0.32)
    Main.Visible = false
    mostrarBotaoFlutuanteMin()
end)

print("[VoidStrap] Parte 1/8 carregada.")--====================================================================
-- COMPONENTE: SLIDER
--====================================================================
local function sliderRow(parent, rotulo, minV, maxV, inicial, aoMudar, ordem)
    local row = criar("Frame", {
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundColor3 = TemaAtivo.Surface2,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        LayoutOrder = ordem or 0,
        Parent = parent,
    })
    comTema(row, "BackgroundColor3", "Surface2")
    canto(9, row)

    local lbl = criar("TextLabel", {
        Size = UDim2.new(1, -80, 0, 22),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = rotulo,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = TemaAtivo.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    comTema(lbl, "TextColor3", "Text")

    local valueLabel = criar("TextLabel", {
        Size = UDim2.fromOffset(60, 22),
        Position = UDim2.new(1, -72, 0, 8),
        BackgroundTransparency = 1,
        Text = tostring(inicial),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = TemaAtivo.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })
    comTema(valueLabel, "TextColor3", "Accent")

    local track = criar("Frame", {
        Size = UDim2.new(1, -28, 0, 8),
        Position = UDim2.new(0, 14, 0, 44),
        BackgroundColor3 = TemaAtivo.Stroke,
        BorderSizePixel = 0,
        Parent = row,
    })
    comTema(track, "BackgroundColor3", "Stroke")
    canto(4, track)

    local fill = criar("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = TemaAtivo.Accent,
        BorderSizePixel = 0,
        Parent = track,
    })
    comTema(fill, "BackgroundColor3", "Accent")
    canto(4, fill)

    local handle = criar("Frame", {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = track,
    })
    canto(10, handle)
    contorno(TemaAtivo.Accent, 2, 0, handle)

    local valor = inicial
    local arrastando = false

    local function atualizarDeX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        valor = math.floor(minV + (maxV - minV) * rel + 0.5)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        handle.Position = UDim2.new(rel, 0, 0.5, 0)
        valueLabel.Text = tostring(valor)
        if aoMudar then aoMudar(valor) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            arrastando = true
            atualizarDeX(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if arrastando and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            atualizarDeX(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            arrastando = false
        end
    end)

    task.defer(function()
        local rel = (inicial - minV) / (maxV - minV)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        handle.Position = UDim2.new(rel, 0, 0.5, 0)
    end)

    return row
end

--====================================================================
-- COMPONENTE: DROPDOWN
--====================================================================
local function dropdownRow(parent, rotulo, opcoes, inicial, aoMudar, ordem)
    local row = criar("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = TemaAtivo.Surface2,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        LayoutOrder = ordem or 0,
        ZIndex = 100,
        Parent = parent,
    })
    comTema(row, "BackgroundColor3", "Surface2")
    canto(9, row)

    local lbl = criar("TextLabel", {
        Size = UDim2.new(1, -170, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = rotulo,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = TemaAtivo.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101,
        Parent = row,
    })
    comTema(lbl, "TextColor3", "Text")

    local selecionado = criar("TextButton", {
        Size = UDim2.fromOffset(130, 32),
        Position = UDim2.new(1, -144, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = TemaAtivo.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = inicial,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = TemaAtivo.Text,
        AutoButtonColor = false,
        ZIndex = 102,
        Parent = row,
    })
    comTema(selecionado, "BackgroundColor3", "Background")
    comTema(selecionado, "TextColor3", "Text")
    canto(7, selecionado)
    contorno(TemaAtivo.Stroke, 1, 0.5, selecionado, 102)

    local lista = criar("Frame", {
        Size = UDim2.new(0, 130, 0, #opcoes * 30 + 12),
        Position = UDim2.new(1, -144, 1, 6),
        BackgroundColor3 = TemaAtivo.Surface,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 9999,
        Parent = row,
    })
    comTema(lista, "BackgroundColor3", "Surface")
    canto(8, lista)
    contorno(TemaAtivo.Stroke, 1, 0.3, lista, 9999)
    criar("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = lista,
    })
    espacamento(lista, 5)

    for i, opt in ipairs(opcoes) do
        local o = criar("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = TemaAtivo.Surface,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Text = opt,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = TemaAtivo.Text,
            AutoButtonColor = false,
            LayoutOrder = i,
            ZIndex = 10000,
            Parent = lista,
        })
        comTema(o, "BackgroundColor3", "Surface")
        comTema(o, "TextColor3", "Text")
        canto(5, o)
        o.MouseButton1Click:Connect(function()
            tocarClique()
            selecionado.Text = opt
            lista.Visible = false
            if aoMudar then aoMudar(opt) end
        end)
    end

    selecionado.MouseButton1Click:Connect(function()
        tocarClique()
        lista.Visible = not lista.Visible
    end)

    return row
end

--====================================================================
-- SISTEMA DE ABAS
--====================================================================
local Tabs = {}
local AbaAtual = nil

local function selecionarAba(nome)
    for n, tab in pairs(Tabs) do
        local ativo = (n == nome)
        tab.page.Visible = ativo
        tab.indicador.Visible = ativo
        animar(tab.button, 0.25, {
            BackgroundColor3 = ativo and TemaAtivo.Surface or TemaAtivo.Background,
            BackgroundTransparency = ativo and 0.2 or 1,
        })
        animar(tab.txt, 0.25, { TextColor3 = ativo and TemaAtivo.Text or TemaAtivo.Sub })
        animar(tab.icon, 0.25, { TextColor3 = ativo and TemaAtivo.Accent or TemaAtivo.Sub })
        tab.indicador.BackgroundTransparency = ativo and 0 or 1
    end
    AbaAtual = nome
end

local function criarAba(nome, iconText)
    local btn = criar("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = TemaAtivo.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = Sidebar,
    })
    comTema(btn, "BackgroundColor3", "Background")
    canto(10, btn)

    local indicador = criar("Frame", {
        Size = UDim2.new(0, 3, 0.6, 0),
        Position = UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = TemaAtivo.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = btn,
    })
    comTema(indicador, "BackgroundColor3", "Accent")
    canto(2, indicador)

    local icon = criar("TextLabel", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = iconText,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = TemaAtivo.Sub,
        Parent = btn,
    })
    comTema(icon, "TextColor3", "Sub")

    local txt = criar("TextLabel", {
        Size = UDim2.new(1, -44, 1, 0),
        Position = UDim2.new(0, 38, 0, 0),
        BackgroundTransparency = 1,
        Text = nome,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = TemaAtivo.Sub,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
    })
    comTema(txt, "TextColor3", "Sub")

    local page = criar("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = TemaAtivo.Accent,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollingEnabled = true,
        ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 10,
        Parent = Content,
    })
    criar("UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })
    espacamento(page, 2, 4, 60, 2, 2)

    Tabs[nome] = { button = btn, page = page, indicador = indicador, txt = txt, icon = icon }

    btn.MouseButton1Click:Connect(function()
        tocarClique()
        selecionarAba(nome)
    end)
end

--====================================================================
-- SECTION (LIMPA — SEM BARRA LATERAL)
--====================================================================
local function section(titulo)
    local frame = criar("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = TemaAtivo.Surface,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 20,
    })
    comTema(frame, "BackgroundColor3", "Surface")
    canto(12, frame)
    contorno(TemaAtivo.Stroke, 1, 0.5, frame, 20)

    criar("UIPadding", {
        PaddingTop = UDim.new(0, 14),
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 14),
        Parent = frame,
    })
    criar("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = frame,
    })

    local lbl = criar("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = titulo,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = TemaAtivo.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
        ZIndex = 21,
        Parent = frame,
    })
    comTema(lbl, "TextColor3", "Text")

    return frame
end

--====================================================================
-- BUTTON ROW
--====================================================================
local function buttonRow(parent, rotulo, aoClicar, ordem)
    local row = criar("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = TemaAtivo.Surface2,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = ordem or 0,
        ZIndex = 22,
        Parent = parent,
    })
    comTema(row, "BackgroundColor3", "Surface2")
    canto(9, row)
    contorno(TemaAtivo.Stroke, 1, 0.7, row, 22)

    local lbl = criar("TextLabel", {
        Size = UDim2.new(1, -90, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = rotulo,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = TemaAtivo.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 23,
        Parent = row,
    })
    comTema(lbl, "TextColor3", "Text")

    local badge = criar("TextLabel", {
        Size = UDim2.fromOffset(64, 24),
        Position = UDim2.new(1, -74, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = TemaAtivo.Accent,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Text = "Aplicar",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Color3.new(1, 1, 1),
        ZIndex = 23,
        Parent = row,
    })
    comTema(badge, "BackgroundColor3", "Accent")
    canto(7, badge)

    row.MouseEnter:Connect(function()
        animar(row, 0.15, { BackgroundColor3 = TemaAtivo.Surface3, BackgroundTransparency = 0 })
    end)
    row.MouseLeave:Connect(function()
        animar(row, 0.15, { BackgroundColor3 = TemaAtivo.Surface2, BackgroundTransparency = 0.3 })
    end)
    row.MouseButton1Click:Connect(function()
        tocarClique()
        if aoClicar then aoClicar(badge) end
    end)
    return row, badge
end

--====================================================================
-- TOGGLE ROW
--====================================================================
local function toggleRow(parent, rotulo, inicial, aoMudar, ordem)
    local row = criar("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = TemaAtivo.Surface2,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        LayoutOrder = ordem or 0,
        Parent = parent,
    })
    comTema(row, "BackgroundColor3", "Surface2")
    canto(9, row)

    local lbl = criar("TextLabel", {
        Size = UDim2.new(1, -110, 0, 22),
        Position = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1,
        Text = rotulo,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = TemaAtivo.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    comTema(lbl, "TextColor3", "Text")

    local track = criar("Frame", {
        Size = UDim2.fromOffset(48, 28),
        Position = UDim2.new(1, -62, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = TemaAtivo.Stroke,
        BorderSizePixel = 0,
        Parent = row,
    })
    comTema(track, "BackgroundColor3", "Stroke")
    canto(14, track)

    local knob = criar("Frame", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = track,
    })
    canto(11, knob)

    local estado = inicial and true or false
    local function render(anim)
        local alvoX = estado and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        local alvoCor = estado and TemaAtivo.Accent or TemaAtivo.Stroke
        if anim then
            animar(knob, 0.22, { Position = alvoX })
            animar(track, 0.22, { BackgroundColor3 = alvoCor })
        else
            knob.Position = alvoX
            track.BackgroundColor3 = alvoCor
        end
    end
    render(false)

    local btn = criar("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        Parent = row,
    })
    btn.MouseButton1Click:Connect(function()
        tocarClique()
        estado = not estado
        render(true)
        if aoMudar then aoMudar(estado) end
    end)
    return row
end

print("[VoidStrap] Parte 2/8 carregada.")--====================================================================
-- MÓDULO: GRAMA
--====================================================================
local GrassModule = {}
local CorGramaOriginal = nil
local PartesRecoloridas = {}

local function ehParteDeGrama(part)
    if not part:IsA("BasePart") then return false end
    local mat = part.Material
    if mat == Enum.Material.Grass or mat == Enum.Material.LeafyGrass then return true end
    local c = part.Color
    local ehVerde = c.G > 0.45 and c.R < 0.45 and c.B < 0.45
    local ehGrande = part.Size.X >= 30 and part.Size.Z >= 30
    return ehVerde and ehGrande
end

local function devePular(part)
    local char = LP.Character
    if char and part:IsDescendantOf(char) then return true end
    local model = part:FindFirstAncestorOfClass("Model")
    if model then
        local n = model.Name:lower()
        if n:find("ball") or n:find("bola") then return true end
        if model:FindFirstChildOfClass("Humanoid") then return true end
    end
    return false
end

function GrassModule.definirCor(color)
    if not CorGramaOriginal then
        local ok, c = pcall(function() return Workspace.Terrain:GetMaterialColor(Enum.Material.Grass) end)
        CorGramaOriginal = (ok and c) or Color3.fromRGB(91, 154, 76)
    end
    pcall(function()
        Workspace.Terrain:SetMaterialColor(Enum.Material.Grass, color)
        Workspace.Terrain:SetMaterialColor(Enum.Material.LeafyGrass, color)
    end)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if ehParteDeGrama(obj) and not devePular(obj) then
            if PartesRecoloridas[obj] == nil then
                PartesRecoloridas[obj] = obj.Color
            end
            pcall(function() obj.Color = color end)
        end
    end
end

function GrassModule.restaurar()
    if CorGramaOriginal then
        pcall(function()
            Workspace.Terrain:SetMaterialColor(Enum.Material.Grass, CorGramaOriginal)
            Workspace.Terrain:SetMaterialColor(Enum.Material.LeafyGrass, CorGramaOriginal)
        end)
    end
    for part, original in pairs(PartesRecoloridas) do
        pcall(function()
            if part and part.Parent then part.Color = original end
        end)
    end
    PartesRecoloridas = {}
end

local GRASS_PRESETS = {
    ["Verde Padrao"]  = Color3.fromRGB(91, 154, 76),
    ["Verde Escuro"]  = Color3.fromRGB(45, 90, 40),
    ["Verde Neon"]    = Color3.fromRGB(80, 255, 120),
    ["Verde Agua"]    = Color3.fromRGB(120, 220, 180),
    ["Azul"]          = Color3.fromRGB(60, 130, 220),
    ["Roxo"]          = Color3.fromRGB(120, 70, 200),
    ["Vermelho"]      = Color3.fromRGB(200, 60, 60),
    ["Rosa"]          = Color3.fromRGB(240, 130, 200),
    ["Amarelo"]       = Color3.fromRGB(230, 210, 70),
    ["Cinza"]         = Color3.fromRGB(120, 120, 125),
    ["Branco"]        = Color3.fromRGB(240, 240, 245),
    ["Preto"]         = Color3.fromRGB(25, 25, 28),
    ["Gelo"]          = Color3.fromRGB(190, 220, 255),
}

function GrassModule.aplicarPreset(nome)
    local color = GRASS_PRESETS[nome]
    if not color then return end
    GrassModule.definirCor(color)
    notificar("Grama: " .. nome, "good")
end

function GrassModule.resetar()
    GrassModule.restaurar()
    notificar("Grama restaurada", "bad")
end

--====================================================================
-- MÓDULO: FLAGS
--====================================================================
local FlagsModule = {}

local PRESETS_FLAGS = {
    Ultra       = { particles = false, shadows = false, lighting = false },
    Balanced    = { particles = true,  shadows = true,  lighting = false },
    Performance = { particles = true,  shadows = true,  lighting = true  },
    Potato      = { particles = true,  shadows = true,  lighting = true  },
}

function FlagsModule.aplicarPreset(preset)
    if not Estado.Flags.Enabled then return end
    local c = PRESETS_FLAGS[preset] or PRESETS_FLAGS.Balanced
    local char = LP.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if char and obj:IsDescendantOf(char) then continue end
        if c.particles and (
            obj:IsA("ParticleEmitter") or obj:IsA("Trail") or
            obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")
        ) then
            rastrear(obj, "Enabled")
            pcall(function() obj.Enabled = false end)
        end
        if c.shadows and obj:IsA("BasePart") then
            rastrear(obj, "CastShadow")
            pcall(function() obj.CastShadow = false end)
        end
    end
    if c.lighting then
        rastrear(Lighting, "GlobalShadows")
        pcall(function() Lighting.GlobalShadows = false end)
    end
end

function FlagsModule.ativar(ligado)
    Estado.Flags.Enabled = ligado
    if ligado then
        FlagsModule.aplicarPreset(Estado.Flags.Preset)
        notificar("Flags ativadas: " .. Estado.Flags.Preset, "good")
    else
        restaurarTudo()
        notificar("Flags desativadas", "bad")
    end
end

function FlagsModule.definirPreset(preset)
    Estado.Flags.Preset = preset
    if Estado.Flags.Enabled then
        restaurarTudo()
        FlagsModule.aplicarPreset(preset)
        notificar("Preset: " .. preset, "good")
    end
end

--====================================================================
-- MÓDULO: SKYBOX
--====================================================================
local SkyboxModule = {}
local LightingOriginal = nil

local function capturarIluminacao()
    if LightingOriginal then return end
    LightingOriginal = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogColor = Lighting.FogColor,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
    }
end

local SKY_PRESETS = {
    Noite = {
        Ambient = Color3.fromRGB(10, 10, 25),
        OutdoorAmbient = Color3.fromRGB(15, 15, 35),
        Brightness = 0.3, ClockTime = 0,
        FogColor = Color3.fromRGB(5, 5, 15),
        FogStart = 30, FogEnd = 250,
    },
    Espaco = {
        Ambient = Color3.fromRGB(2, 2, 8),
        OutdoorAmbient = Color3.fromRGB(5, 5, 15),
        Brightness = 0.1, ClockTime = 0,
        FogColor = Color3.fromRGB(0, 0, 5),
        FogStart = 5, FogEnd = 100,
    },
    Vermelho = {
        Ambient = Color3.fromRGB(60, 10, 10),
        OutdoorAmbient = Color3.fromRGB(80, 15, 15),
        Brightness = 1.2, ClockTime = 17.5,
        FogColor = Color3.fromRGB(40, 5, 5),
        FogStart = 20, FogEnd = 300,
    },
    Roxo = {
        Ambient = Color3.fromRGB(40, 15, 60),
        OutdoorAmbient = Color3.fromRGB(60, 20, 90),
        Brightness = 1.0, ClockTime = 18.5,
        FogColor = Color3.fromRGB(25, 5, 40),
        FogStart = 20, FogEnd = 280,
    },
    Personalizado = {
        Ambient = Color3.fromRGB(25, 30, 40),
        OutdoorAmbient = Color3.fromRGB(40, 50, 70),
        Brightness = 0.8, ClockTime = 14,
        FogColor = Color3.fromRGB(10, 20, 30),
        FogStart = 40, FogEnd = 350,
    },
}

local ORDEM_SEGURA = {
    "FogColor", "FogStart", "FogEnd",
    "Ambient", "OutdoorAmbient", "Brightness", "ClockTime",
}

local function aplicarSkyboxPreset(nome)
    capturarIluminacao()
    if nome == "Padrao" then SkyboxModule.restaurar(); return end
    local p = SKY_PRESETS[nome]
    if not p then return end
    for _, key in ipairs(ORDEM_SEGURA) do
        if p[key] ~= nil then
            pcall(function() Lighting[key] = p[key] end)
        end
    end
end

function SkyboxModule.aplicar(nome)
    Estado.Skybox.Current = nome
    if Estado.Skybox.Enabled then aplicarSkyboxPreset(nome) end
    notificar("Skybox: " .. nome, "good")
end

function SkyboxModule.restaurar()
    if not LightingOriginal then return end
    for k, v in pairs(LightingOriginal) do
        pcall(function() Lighting[k] = v end)
    end
end

function SkyboxModule.ativar(ligado)
    Estado.Skybox.Enabled = ligado
    if ligado then
        aplicarSkyboxPreset(Estado.Skybox.Current)
        notificar("Skybox ativado", "good")
    else
        SkyboxModule.restaurar()
        notificar("Skybox desativado", "bad")
    end
end

--====================================================================
-- MÓDULO: STRETCH
--====================================================================
local StretchModule = {}

local function aplicarStretch()
    if not Camera then return end
    if not Estado.Stretch.Enabled or Estado.Stretch.Intensity == 0 then
        pcall(function() Camera.FieldOfView = Estado.Stretch.BaseFOV end)
        return
    end
    local extra = (Estado.Stretch.Intensity / 100) * 50
    pcall(function()
        Camera.FieldOfView = Estado.Stretch.BaseFOV + extra + (math.random() - 0.5) * 1.0
    end)
end

function StretchModule.ativar(ligado)
    Estado.Stretch.Enabled = ligado
    aplicarStretch()
    notificar(ligado and "Stretch ativado" or "Stretch desativado",
              ligado and "good" or "bad")
end

function StretchModule.definirIntensidade(v)
    Estado.Stretch.Intensity = v
    aplicarStretch()
end

function StretchModule.resetar()
    Estado.Stretch.Enabled = false
    Estado.Stretch.Intensity = 0
    if Camera then pcall(function() Camera.FieldOfView = Estado.Stretch.BaseFOV end) end
end

--====================================================================
-- MÓDULO: ILUMINAÇÃO
--====================================================================
local LightingModule = {}
local ClockTimeOriginal = nil

function LightingModule.definirHora(h)
    if not ClockTimeOriginal then
        ClockTimeOriginal = Lighting.ClockTime
    end
    pcall(function() Lighting.ClockTime = h end)
end

function LightingModule.restaurar()
    if ClockTimeOriginal then
        pcall(function() Lighting.ClockTime = ClockTimeOriginal end)
    end
end

print("[VoidStrap] Parte 3/8 carregada.")--====================================================================
-- MÓDULO: FIRE TRAIL
--====================================================================
local FireTrailModule = {}
local BolaAtual = nil
local InstanciasAtivas = {}

local FIRE_PRESETS = {
    ["Fogo Classico"] = { fire=Color3.fromRGB(255,120,30), secondary=Color3.fromRGB(255,60,0), trail=Color3.fromRGB(255,180,60), trailMid=Color3.fromRGB(255,80,20), light=Color3.fromRGB(255,140,40), size=6 },
    ["Fogo Azul"]     = { fire=Color3.fromRGB(80,180,255), secondary=Color3.fromRGB(30,90,220), trail=Color3.fromRGB(150,210,255), trailMid=Color3.fromRGB(50,130,255), light=Color3.fromRGB(100,180,255), size=6 },
    ["Fogo Roxo"]     = { fire=Color3.fromRGB(180,80,255), secondary=Color3.fromRGB(120,30,220), trail=Color3.fromRGB(210,150,255), trailMid=Color3.fromRGB(140,60,255), light=Color3.fromRGB(180,100,255), size=6 },
    ["Fogo Verde"]    = { fire=Color3.fromRGB(100,255,120), secondary=Color3.fromRGB(30,200,60), trail=Color3.fromRGB(160,255,180), trailMid=Color3.fromRGB(50,220,100), light=Color3.fromRGB(120,255,140), size=6 },
    ["Fogo Branco"]   = { fire=Color3.fromRGB(255,255,255), secondary=Color3.fromRGB(220,240,255), trail=Color3.fromRGB(255,255,255), trailMid=Color3.fromRGB(200,220,255), light=Color3.fromRGB(255,255,255), size=6 },
    ["Inferno"]       = { fire=Color3.fromRGB(255,80,0), secondary=Color3.fromRGB(255,220,60), trail=Color3.fromRGB(255,160,30), trailMid=Color3.fromRGB(255,60,0), light=Color3.fromRGB(255,120,20), size=8 },
}

local BALL_NAMES_FT = {
    "TPS","ESA","MRS","PRS","MPS","Ball","Football","Soccer Ball","Bola","SoccerBall"
}

local function ehNomeBolaFT(name)
    for _, n in ipairs(BALL_NAMES_FT) do
        if name == n then return true end
    end
    return false
end

local function encontrarBolaFT()
    local char = LP.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and ehNomeBolaFT(obj.Name) then
            if not (char and obj:IsDescendantOf(char)) then return obj end
        end
    end
    return nil
end

local function limparEfeitosFT()
    for _, inst in ipairs(InstanciasAtivas) do
        pcall(function() if inst and inst.Parent then inst:Destroy() end end)
    end
    InstanciasAtivas = {}
    BolaAtual = nil
end

local function aplicarEfeitosFT(ball, presetName)
    limparEfeitosFT()
    if not ball or not ball.Parent then return end
    local p = FIRE_PRESETS[presetName] or FIRE_PRESETS["Fogo Classico"]
    BolaAtual = ball

    local fire = Instance.new("Fire")
    fire.Color = p.fire
    fire.SecondaryColor = p.secondary
    fire.Size = p.size
    fire.Heat = 15
    fire.Parent = ball
    table.insert(InstanciasAtivas, fire)

    local offsetY = math.max(ball.Size.Y * 0.5, 1)
    local a0 = Instance.new("Attachment")
    a0.Position = Vector3.new(0, offsetY, 0)
    a0.Parent = ball
    table.insert(InstanciasAtivas, a0)

    local a1 = Instance.new("Attachment")
    a1.Position = Vector3.new(0, -offsetY, 0)
    a1.Parent = ball
    table.insert(InstanciasAtivas, a1)

    local trail = Instance.new("Trail")
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, p.trail),
        ColorSequenceKeypoint.new(0.5, p.trailMid),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(0,0,0)),
    })
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.15),
        NumberSequenceKeypoint.new(0.6, 0.65),
        NumberSequenceKeypoint.new(1.0, 1.0),
    })
    trail.Lifetime = 0.7
    trail.LightEmission = 1
    trail.LightInfluence = 0
    trail.Parent = ball
    table.insert(InstanciasAtivas, trail)

    local sparks = Instance.new("ParticleEmitter")
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
    table.insert(InstanciasAtivas, sparks)

    local light = Instance.new("PointLight")
    light.Brightness = 3
    light.Range = 14
    light.Color = p.light
    light.Shadows = false
    light.Parent = ball
    table.insert(InstanciasAtivas, light)
end

function FireTrailModule.ativar(ligado)
    Estado.FireTrail = Estado.FireTrail or { Enabled = false, Preset = "Fogo Classico" }
    Estado.FireTrail.Enabled = ligado
    if ligado then
        local ball = encontrarBolaFT()
        if ball then
            aplicarEfeitosFT(ball, Estado.FireTrail.Preset)
            notificar("Fire Trail ativado", "good")
        else
            notificar("Bola nao encontrada", "bad")
        end
    else
        limparEfeitosFT()
        notificar("Fire Trail desativado", "bad")
    end
end

function FireTrailModule.definirPreset(nome)
    Estado.FireTrail = Estado.FireTrail or { Enabled = false, Preset = "Fogo Classico" }
    Estado.FireTrail.Preset = nome
    if Estado.FireTrail.Enabled then
        local ball = BolaAtual
        if not ball or not ball.Parent then ball = encontrarBolaFT() end
        if ball then
            aplicarEfeitosFT(ball, nome)
            notificar("Rastro: " .. nome, "good")
        end
    end
end

function FireTrailModule.reconectar()
    local ball = encontrarBolaFT()
    if ball then
        aplicarEfeitosFT(ball, (Estado.FireTrail and Estado.FireTrail.Preset) or "Fogo Classico")
        notificar("Bola reconectada", "good")
    else
        notificar("Nenhuma bola encontrada", "bad")
    end
end

function FireTrailModule.resetar()
    if Estado.FireTrail then Estado.FireTrail.Enabled = false end
    limparEfeitosFT()
    notificar("Fire Trail resetado", "bad")
end

task.spawn(function()
    while task.wait(1) do
        if Estado.FireTrail and Estado.FireTrail.Enabled then
            if not BolaAtual or not BolaAtual.Parent then
                local ball = encontrarBolaFT()
                if ball then aplicarEfeitosFT(ball, Estado.FireTrail.Preset) end
            end
        end
    end
end)

--====================================================================
-- MÓDULO: CHARS
--====================================================================
local LISTA_CHARS = {
    "MiguelCalebeGamer202","guto785662","beastsxc","89felip3","guto_01games",
    "feliou23","LeozzinnTxz","aerovah","novaes_wc","GHOST_INFINITI07","16alvez",
    "mikaelfacada10","keny_tcs","3qu","hel","phzin123271","portuga_xz3","j12ufdo",
    "shadow_samuel1347k","131felipe6","mnbzzaicsn","careca12492","sunno_mm2",
    "rangeamandio","rosa_skillsz","DAVILUCASPLU2VC","rayagaj3","Felliou","ythek9on1",
    "Bernardow_w","Samblox_Xd","mica1203ely5",
}

local CharsModule = {}

local function enviarChat(msg)
    local ok = false
    pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        local ev = RS:FindFirstChild("DefaultChatSystemChatEvents")
        if ev then
            local say = ev:FindFirstChild("SayMessageRequest")
            if say then say:FireServer(msg, "All"); ok = true end
        end
    end)
    if not ok then
        pcall(function()
            local TCS = game:GetService("TextChatService")
            if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
                local canais = TCS:FindFirstChild("TextChannels")
                if canais then
                    local geral = canais:FindFirstChild("RBXGeneral")
                    if geral then geral:SendAsync(msg); ok = true end
                end
            end
        end)
    end
    return ok
end

function CharsModule.aplicar(nome)
    if not nome or nome == "" then return end
    if enviarChat(":char " .. nome) then
        notificar("Char: " .. nome, "good")
    else
        notificar("Falha ao enviar", "bad")
    end
end

--====================================================================
-- MÓDULO: BOLA CUSTOM
--====================================================================
local BolaCustomModule = {}
local CB_Estado = { Enabled = false, Color = Color3.fromRGB(255,255,255), Material = "SmoothPlastic" }
local CB_Ball = nil
local CB_Conn = nil

local BALL_NAMES_CB = {
    "TPS","ESA","MRS","PRS","MPS","Ball","Football","Soccer Ball","Bola","SoccerBall"
}

local function ehBolaCB(name)
    for _, n in ipairs(BALL_NAMES_CB) do
        if name == n then return true end
    end
    return false
end

local function buscarBolaCB()
    local char = LP.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and ehBolaCB(obj.Name) then
            if not (char and obj:IsDescendantOf(char)) then return obj end
        end
    end
    return nil
end

local function aplicarCB()
    if not CB_Estado.Enabled then return end
    if not CB_Ball or not CB_Ball.Parent then CB_Ball = buscarBolaCB() end
    local b = CB_Ball
    if not b then return end
    pcall(function()
        b.Color = CB_Estado.Color
        b.Material = Enum.Material[CB_Estado.Material]
    end)
    local mesh = b:FindFirstChildOfClass("SpecialMesh") or b:FindFirstChildOfClass("Mesh")
    if mesh then pcall(function() mesh.VertexColor = CB_Estado.Color end) end
end

function BolaCustomModule.ativar(ligado)
    CB_Estado.Enabled = ligado
    if ligado then
        if CB_Conn then CB_Conn:Disconnect() end
        CB_Conn = RunService.Heartbeat:Connect(aplicarCB)
        notificar("Custom Ball ativado", "good")
    else
        if CB_Conn then CB_Conn:Disconnect(); CB_Conn = nil end
        CB_Ball = nil
        notificar("Custom Ball desativado", "bad")
    end
end

function BolaCustomModule.definirCor(cor)
    CB_Estado.Color = cor
    aplicarCB()
end

function BolaCustomModule.definirMaterial(mat)
    CB_Estado.Material = mat
    aplicarCB()
end

function BolaCustomModule.resetar()
    CB_Estado.Enabled = false
    if CB_Conn then CB_Conn:Disconnect(); CB_Conn = nil end
    if CB_Ball and CB_Ball.Parent then
        pcall(function()
            CB_Ball.Color = Color3.fromRGB(255,255,255)
            CB_Ball.Material = Enum.Material.SmoothPlastic
        end)
    end
    CB_Ball = nil
    notificar("Bola restaurada", "good")
end

print("[VoidStrap] Parte 4/8 carregada.")--====================================================================
-- MÓDULO: BOOM BOX
--====================================================================
local BoomBoxModule = {}
local BB_Estado = {
    Enabled = false, Volume = 1.0, Looped = true,
    Target = "Player", CurrentTrack = nil,
}
local BB_Sound = nil
local BB_Conn = nil

local TRACKS_BB = {
    { name = "Nenhuma",          id = nil },
    { name = "BrooklynBloodPop", id = "96414211708215" },
    { name = "Sometimes",        id = "128715303988843" },
    { name = "Meant to Be",      id = "121397051787416" },
    { name = "Ilusionary",       id = "87570666848900" },
    { name = "I'm So Fed Up",    id = "103072508653269" },
    { name = "Super Funk",       id = "107835682687645" },
}

local BALL_NAMES_BB = {
    "TPS","ESA","MRS","PRS","MPS","Ball","Football","Soccer Ball","Bola","SoccerBall"
}

local function ehBolaBB(name)
    for _, n in ipairs(BALL_NAMES_BB) do
        if name == n then return true end
    end
    return false
end

local function buscarBolaBB()
    local char = LP.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and ehBolaBB(obj.Name) then
            if not (char and obj:IsDescendantOf(char)) then return obj end
        end
    end
    return nil
end

local function destruirSom()
    if BB_Sound and BB_Sound.Parent then pcall(function() BB_Sound:Destroy() end) end
    BB_Sound = nil
end

local function criarSomEm(alvo)
    if not alvo then return end
    if BB_Sound and BB_Sound.Parent == alvo then return end
    destruirSom()
    BB_Sound = Instance.new("Sound")
    BB_Sound.Name = "VST_BoomBox"
    BB_Sound.Volume = BB_Estado.Volume
    BB_Sound.Looped = BB_Estado.Looped
    BB_Sound.RollOffMaxDistance = 200
    BB_Sound.RollOffMinDistance = 5
    BB_Sound.RollOffMode = Enum.RollOffMode.InverseTapered
    BB_Sound.Parent = alvo
end

local function aplicarFaixa(id)
    if not BB_Sound then return end
    if id then
        pcall(function()
            BB_Sound.SoundId = "rbxassetid://" .. tostring(id)
            BB_Sound:Play()
        end)
    else
        pcall(function() BB_Sound:Stop() end)
    end
end

local function iniciarBB()
    if BB_Conn then BB_Conn:Disconnect() end
    BB_Conn = RunService.Heartbeat:Connect(function()
        if not BB_Estado.Enabled then return end
        local alvo
        if BB_Estado.Target == "Player" then
            local char = LP.Character
            alvo = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        else
            alvo = buscarBolaBB()
        end
        if not alvo then return end
        if not BB_Sound or BB_Sound.Parent ~= alvo then
            criarSomEm(alvo)
            if BB_Estado.CurrentTrack then aplicarFaixa(BB_Estado.CurrentTrack) end
        end
        if BB_Sound then
            pcall(function()
                BB_Sound.Volume = BB_Estado.Volume
                BB_Sound.Looped = BB_Estado.Looped
            end)
        end
    end)
end

function BoomBoxModule.ativar(ligado)
    BB_Estado.Enabled = ligado
    if ligado then
        iniciarBB()
        notificar("Boom Box ativada", "good")
    else
        if BB_Conn then BB_Conn:Disconnect(); BB_Conn = nil end
        destruirSom()
        notificar("Boom Box desativada", "bad")
    end
end

function BoomBoxModule.definirAlvo(opt)
    BB_Estado.Target = opt
    destruirSom()
    notificar("Alvo: " .. opt, "good")
end

function BoomBoxModule.definirVolume(v)
    BB_Estado.Volume = v
    if BB_Sound then pcall(function() BB_Sound.Volume = v end) end
end

function BoomBoxModule.definirLoop(on)
    BB_Estado.Looped = on
    if BB_Sound then pcall(function() BB_Sound.Looped = on end) end
end

function BoomBoxModule.tocarFaixa(nome, id)
    BB_Estado.CurrentTrack = id
    if id then
        aplicarFaixa(id)
        notificar("Tocando: " .. nome, "good")
    else
        aplicarFaixa(nil)
        notificar("Musica parada", "bad")
    end
end

function BoomBoxModule.tocarPorId(id)
    id = tostring(id or ""):gsub("%s", "")
    id = id:gsub("rbxassetid://", "")
    id = id:match("^%d+") or id
    if id:match("^%d+$") then
        BB_Estado.CurrentTrack = id
        aplicarFaixa(id)
        notificar("Tocando ID: " .. id, "good")
    else
        notificar("ID invalido", "bad")
    end
end

--====================================================================
-- MÓDULO: AUTO FOLLOW (distância + segue X/Z + sem rotação)
--====================================================================
local AutoFollowModule = {}
local AF_Estado = {
    Enabled = false,
    Speed = 22,
    StopDistance = 2.5,
    TargetMode = "Mais Próxima",
    AntiStuck = true,
}
local AF_BodyVel = nil
local AF_AlignOrient = nil
local AF_Conn = nil
local AF_CachedBall = nil
local AF_LastSearch = 0

local BALL_NAMES_AF = {
    "TPS","ESA","MRS","PRS","MPS","Ball","Football","Soccer Ball","Bola","SoccerBall"
}

local function ehBolaAF(name)
    for _, n in ipairs(BALL_NAMES_AF) do
        if name == n then return true end
    end
    return false
end

local function buscarTodasBolasAF()
    local bolas = {}
    local char = LP.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and ehBolaAF(obj.Name) then
            if not (char and obj:IsDescendantOf(char)) then
                table.insert(bolas, obj)
            end
        end
    end
    return bolas
end

local function buscarBolaMaisProximaAF()
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local maisProxima, menorDist = nil, math.huge
    for _, b in ipairs(buscarTodasBolasAF()) do
        local d = (b.Position - root.Position).Magnitude
        if d < menorDist then
            menorDist = d
            maisProxima = b
        end
    end
    return maisProxima
end

local function buscarBolaPorModoAF()
    if AF_Estado.TargetMode == "Mais Próxima" then
        return buscarBolaMaisProximaAF()
    end
    local bolas = buscarTodasBolasAF()
    return bolas[1]
end

local function limparBodyVelAF()
    if AF_BodyVel and AF_BodyVel.Parent then
        pcall(function() AF_BodyVel:Destroy() end)
    end
    AF_BodyVel = nil
    if AF_AlignOrient and AF_AlignOrient.Parent then
        pcall(function() AF_AlignOrient:Destroy() end)
    end
    AF_AlignOrient = nil
end

local function iniciarAF()
    if AF_Conn then AF_Conn:Disconnect() end
    local ultimaPos, framesPreso = nil, 0

    AF_Conn = RunService.Heartbeat:Connect(function()
        if not AF_Estado.Enabled then limparBodyVelAF() return end
        local char = LP.Character
        if not char then limparBodyVelAF() return end

        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then
            limparBodyVelAF()
            return
        end

        local agora = tick()
        if not AF_CachedBall or not AF_CachedBall.Parent or (agora - AF_LastSearch) > 2 then
            AF_LastSearch = agora
            AF_CachedBall = buscarBolaPorModoAF()
        end
        local bola = AF_CachedBall
        if not bola then limparBodyVelAF() return end

        -- Segue só X e Z (mantém altura do jogador)
        local alvo = Vector3.new(bola.Position.X, root.Position.Y, bola.Position.Z)
        local distancia = (root.Position - alvo).Magnitude

        -- Chegou perto → para
        if distancia < AF_Estado.StopDistance then
            if AF_BodyVel then
                pcall(function() AF_BodyVel.Velocity = AF_BodyVel.Velocity * 0.5 end)
                if AF_BodyVel.Velocity.Magnitude < 1 then limparBodyVelAF() end
            end
            framesPreso = 0
            return
        end

        if AF_Estado.AntiStuck then
            if ultimaPos then
                local moveu = (root.Position - ultimaPos).Magnitude
                if moveu < 0.1 then framesPreso = framesPreso + 1 else framesPreso = 0 end
                if framesPreso > 60 then
                    framesPreso = 0
                    local dir = (alvo - root.Position).Unit
                    local perp = Vector3.new(-dir.Z, 0, dir.X)
                    local lado = (math.random() > 0.5) and 1 or -1
                    pcall(function() root.CFrame = root.CFrame + (perp * lado * 3 + dir * 2) end)
                end
            end
            ultimaPos = root.Position
        end

        -- Cria BodyVelocity (movimento sem rotação)
        if not AF_BodyVel or AF_BodyVel.Parent ~= root then
            limparBodyVelAF()
            AF_BodyVel = Instance.new("BodyVelocity")
            AF_BodyVel.Name = "VST_AutoFollow"
            AF_BodyVel.MaxForce = Vector3.new(math.huge, 0, math.huge)
            AF_BodyVel.P = 100000
            AF_BodyVel.Velocity = Vector3.zero
            AF_BodyVel.Parent = root
        end

        -- AlignOrientation para travar rotação do personagem
        if not AF_AlignOrient or AF_AlignOrient.Parent ~= root then
            if AF_AlignOrient and AF_AlignOrient.Parent then
                pcall(function() AF_AlignOrient:Destroy() end)
            end
            local att = root:FindFirstChild("VST_AlignAtt")
            if not att then
                att = Instance.new("Attachment")
                att.Name = "VST_AlignAtt"
                att.Parent = root
            end
            AF_AlignOrient = Instance.new("AlignOrientation")
            AF_AlignOrient.Name = "VST_NoRotation"
            AF_AlignOrient.Mode = Enum.OrientationAlignmentMode.OneAttachment
            AF_AlignOrient.Attachment0 = att
            AF_AlignOrient.MaxTorque = math.huge
            AF_AlignOrient.Responsiveness = 200
            AF_AlignOrient.RigidityEnabled = true
            AF_AlignOrient.CFrame = root.CFrame
            AF_AlignOrient.Parent = root
        end
        if AF_AlignOrient then
            pcall(function()
                AF_AlignOrient.CFrame = root.CFrame
            end)
        end

        local direcao = (alvo - root.Position).Unit
        pcall(function() AF_BodyVel.Velocity = direcao * AF_Estado.Speed end)
    end)
end

function AutoFollowModule.ativar(ligado)
    AF_Estado.Enabled = ligado
    if ligado then
        iniciarAF()
        notificar("Auto Follow ativado", "good")
    else
        limparBodyVelAF()
        if AF_Conn then AF_Conn:Disconnect(); AF_Conn = nil end
        notificar("Auto Follow desativado", "bad")
    end
    if atualizarBtnAF then atualizarBtnAF() end
end

function AutoFollowModule.definirVelocidade(v) AF_Estado.Speed = v end
function AutoFollowModule.definirDistancia(v) AF_Estado.StopDistance = v end
function AutoFollowModule.definirModo(modo)
    AF_Estado.TargetMode = modo
    AF_CachedBall = nil
    AF_LastSearch = 0
    notificar("Alvo: " .. modo, "good")
end
function AutoFollowModule.ativarAntiStuck(on) AF_Estado.AntiStuck = on end

function AutoFollowModule.resetar()
    AF_Estado.Enabled = false
    limparBodyVelAF()
    if AF_Conn then AF_Conn:Disconnect(); AF_Conn = nil end
    AF_CachedBall = nil
    if atualizarBtnAF then atualizarBtnAF() end
    notificar("Auto Follow resetado", "bad")
end

--====================================================================
-- BOTÃO FLUTUANTE DO AUTO FOLLOW
--====================================================================
local AF_Btn = nil
local AF_BtnEstado = { Travado = false, Posicao = UDim2.new(0.85, 0, 0.3, 0) }
local AF_BtnArr = false
local AF_BtnDragIni, AF_BtnPosIni = nil, nil
local AF_BtnTempoP, AF_BtnPosP = 0, nil

function atualizarBtnAF()
    if not AF_Btn or not AF_Btn.Parent then return end
    if AF_Estado.Enabled then
        AF_Btn.BackgroundColor3 = TemaAtivo.Good
        AF_Btn.Text = "AF ON"
    else
        AF_Btn.BackgroundColor3 = TemaAtivo.Surface2
        AF_Btn.Text = "AF OFF"
    end
    local lock = AF_Btn:FindFirstChild("VST_Lock")
    if AF_BtnEstado.Travado then
        if not lock then
            criar("TextLabel", {
                Name = "VST_Lock",
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.new(1, -18, 0, 2),
                BackgroundTransparency = 1,
                Text = "L",
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = Color3.fromRGB(255, 220, 60),
                ZIndex = 100001,
                Parent = AF_Btn,
            })
        end
    else
        if lock then lock:Destroy() end
    end
end

function AutoFollowModule.criarBotaoAF()
    if AF_Btn and AF_Btn.Parent then
        AF_Btn.Visible = true
        atualizarBtnAF()
        return
    end

    AF_Btn = criar("TextButton", {
        Name = "VST_AutoFollowBtn",
        Size = UDim2.fromOffset(64, 64),
        Position = AF_BtnEstado.Posicao,
        BackgroundColor3 = TemaAtivo.Surface2,
        BorderSizePixel = 0,
        Text = "AF OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = TemaAtivo.Text,
        AutoButtonColor = false,
        ZIndex = 99998,
        Parent = ScreenOverlay,
    })
    canto(32, AF_Btn)
    contorno(TemaAtivo.AccentDim, 2, 0.2, AF_Btn, 99998)
    atualizarBtnAF()

    AF_Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            AF_BtnArr = true
            AF_BtnDragIni = input.Position
            AF_BtnPosIni = AF_Btn.Position
            AF_BtnTempoP = tick()
            AF_BtnPosP = input.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not AF_BtnArr or AF_BtnEstado.Travado then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - AF_BtnDragIni
            if math.abs(d.X) > 8 or math.abs(d.Y) > 8 then
                AF_Btn.Position = UDim2.new(
                    AF_BtnPosIni.X.Scale, AF_BtnPosIni.X.Offset + d.X,
                    AF_BtnPosIni.Y.Scale, AF_BtnPosIni.Y.Offset + d.Y)
                AF_BtnEstado.Posicao = AF_Btn.Position
            end
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            AF_BtnArr = false
            if AF_BtnPosP then
                local df = input.Position - AF_BtnPosP
                local mov = math.abs(df.X) + math.abs(df.Y)
                local tmp = tick() - AF_BtnTempoP
                if mov < 12 and tmp < 0.5 then
                    AutoFollowModule.ativar(not AF_Estado.Enabled)
                end
            end
            AF_BtnPosP = nil
        end
    end)
end

function AutoFollowModule.esconderBotaoAF()
    if AF_Btn and AF_Btn.Parent then AF_Btn:Destroy(); AF_Btn = nil end
end

function AutoFollowModule.travarBotaoAF(on)
    AF_BtnEstado.Travado = on
    atualizarBtnAF()
    notificar(on and "Botao AF travado" or "Botao AF liberado",
              on and "good" or "bad")
end

print("[VoidStrap] Parte 5/8 carregada.")--====================================================================
-- MÓDULO: AUTO CATCH + REACH
--====================================================================
local AutoCatchModule = {}
local AC_Estado = { Enabled = false, Distance = 8, Cooldown = 0.4 }
local RC_Estado = { Enabled = false, Distance = 6, Mode = "Toque Simples", Cooldown = 0.05 }
local AC_Conn, RC_Conn = nil, nil
local AC_Ultimo, RC_Ultimo = 0, 0

local BALL_NAMES_AC = {
    "TPS","ESA","MRS","PRS","MPS","Ball","Football","Soccer Ball","Bola","SoccerBall"
}

local function ehBolaAC(name)
    for _, n in ipairs(BALL_NAMES_AC) do
        if name == n then return true end
    end
    return false
end

local function buscarBolaAC()
    local char = LP.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and ehBolaAC(obj.Name) then
            if not (char and obj:IsDescendantOf(char)) then return obj end
        end
    end
    return nil
end

local function obterMao()
    local char = LP.Character
    if not char then return nil end
    return char:FindFirstChild("RightHand")
        or char:FindFirstChild("LeftHand")
        or char:FindFirstChild("Right Arm")
        or char:FindFirstChild("Left Arm")
        or char:FindFirstChild("HumanoidRootPart")
end

local function obterPerna()
    local char = LP.Character
    if not char then return nil end
    return char:FindFirstChild("Right Leg")
        or char:FindFirstChild("Left Leg")
        or char:FindFirstChild("RightFoot")
        or char:FindFirstChild("LeftFoot")
        or char:FindFirstChild("HumanoidRootPart")
end

function AutoCatchModule.ativar(ligado)
    AC_Estado.Enabled = ligado
    if ligado then
        if AC_Conn then AC_Conn:Disconnect() end
        AC_Conn = RunService.Heartbeat:Connect(function()
            if not AC_Estado.Enabled then return end
            local agora = tick()
            if (agora - AC_Ultimo) < AC_Estado.Cooldown then return end
            local char = LP.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end
            local mao = obterMao()
            if not mao then return end
            local bola = buscarBolaAC()
            if not bola then return end
            if (bola.Position - mao.Position).Magnitude <= AC_Estado.Distance then
                if firetouchinterest then
                    pcall(function()
                        firetouchinterest(bola, mao, 0)
                        firetouchinterest(bola, mao, 1)
                    end)
                end
                pcall(function()
                    local d = mao.Position - bola.Position
                    if d.Magnitude > 0 then
                        bola.AssemblyLinearVelocity = d.Unit * math.min(d.Magnitude * 4, 30)
                    end
                end)
                AC_Ultimo = agora
            end
        end)
        notificar("Auto Catch ativado", "good")
    else
        if AC_Conn then AC_Conn:Disconnect(); AC_Conn = nil end
        notificar("Auto Catch desativado", "bad")
    end
end

function AutoCatchModule.definirDistancia(v) AC_Estado.Distance = v end

function AutoCatchModule.ativarReach(ligado)
    RC_Estado.Enabled = ligado
    if ligado then
        if RC_Conn then RC_Conn:Disconnect() end
        RC_Conn = RunService.Heartbeat:Connect(function()
            if not RC_Estado.Enabled then return end
            local agora = tick()
            if (agora - RC_Ultimo) < RC_Estado.Cooldown then return end
            local char = LP.Character
            if not char then return end
            local perna = obterPerna()
            if not perna then return end
            local bola = buscarBolaAC()
            if not bola then return end
            if (bola.Position - perna.Position).Magnitude <= RC_Estado.Distance then
                if firetouchinterest then
                    pcall(function()
                        firetouchinterest(bola, perna, 0)
                        firetouchinterest(bola, perna, 1)
                    end)
                end
                if RC_Estado.Mode == "Empurrao Continuo" then
                    pcall(function()
                        local d = perna.Position - bola.Position
                        if d.Magnitude > 0 then
                            bola.AssemblyLinearVelocity = d.Unit * 25
                        end
                    end)
                end
                RC_Ultimo = agora
            end
        end)
        notificar("Reach ativado", "good")
    else
        if RC_Conn then RC_Conn:Disconnect(); RC_Conn = nil end
        notificar("Reach desativado", "bad")
    end
end

function AutoCatchModule.definirDistanciaReach(v) RC_Estado.Distance = v end
function AutoCatchModule.definirModoReach(m) RC_Estado.Mode = m end

function AutoCatchModule.resetar()
    AC_Estado.Enabled = false
    RC_Estado.Enabled = false
    if AC_Conn then AC_Conn:Disconnect(); AC_Conn = nil end
    if RC_Conn then RC_Conn:Disconnect(); RC_Conn = nil end
    notificar("Auto Catch resetado", "bad")
end

--====================================================================
-- MÓDULO: TRAIL
--====================================================================
local TrailModule = {}
local TR_Estado = {
    Enabled = false, Cor = "Roxo", Textura = "Padrao",
    Lifetime = 1, Espessura = 1
}

local CORES_TR = {
    ["Branco"]   = ColorSequence.new(Color3.fromRGB(255,255,255)),
    ["Preto"]    = ColorSequence.new(Color3.fromRGB(20,20,20)),
    ["Vermelho"] = ColorSequence.new(Color3.fromRGB(255,40,40)),
    ["Azul"]     = ColorSequence.new(Color3.fromRGB(40,130,255)),
    ["Verde"]    = ColorSequence.new(Color3.fromRGB(50,255,100)),
    ["Amarelo"]  = ColorSequence.new(Color3.fromRGB(255,230,40)),
    ["Roxo"]     = ColorSequence.new(Color3.fromRGB(160,60,255)),
    ["Rosa"]     = ColorSequence.new(Color3.fromRGB(255,100,200)),
    ["Ciano"]    = ColorSequence.new(Color3.fromRGB(0,240,255)),
    ["Laranja"]  = ColorSequence.new(Color3.fromRGB(255,140,30)),
}

local TEXTURAS_TR = {
    ["Padrao"]  = nil,
    ["Fogo"]    = "rbxassetid://258128463",
    ["Neon"]    = "rbxassetid://386066482",
    ["Glow"]    = "rbxassetid://257742662",
    ["Sparkle"] = "rbxassetid://303963708",
}

local TrailAtual, TrailConn = nil, nil
local Atts = {}

local function limparTrail()
    if TrailAtual and TrailAtual.Parent then pcall(function() TrailAtual:Destroy() end) end
    TrailAtual = nil
    for _, a in ipairs(Atts) do
        if a and a.Parent then pcall(function() a:Destroy() end) end
    end
    Atts = {}
end

local function criarTrail()
    limparTrail()
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local a0 = Instance.new("Attachment")
    a0.Position = Vector3.new(0.5, 0, 0)
    a0.Parent = root
    table.insert(Atts, a0)

    local a1 = Instance.new("Attachment")
    a1.Position = Vector3.new(-0.5, 0, 0)
    a1.Parent = root
    table.insert(Atts, a1)

    TrailAtual = Instance.new("Trail")
    TrailAtual.Name = "VST_Trail"
    TrailAtual.Attachment0 = a0
    TrailAtual.Attachment1 = a1
    TrailAtual.Lifetime = TR_Estado.Lifetime
    TrailAtual.MinLength = 0.1
    TrailAtual.FaceCamera = true
    TrailAtual.LightEmission = 0.5
    TrailAtual.WidthScale = NumberSequence.new(TR_Estado.Espessura)
    TrailAtual.Color = CORES_TR[TR_Estado.Cor] or CORES_TR["Roxo"]
    local tex = TEXTURAS_TR[TR_Estado.Textura]
    if tex then
        TrailAtual.Texture = tex
        TrailAtual.TextureMode = Enum.TextureMode.Stretch
    end
    TrailAtual.Parent = root
end

function TrailModule.ativar(ligado)
    TR_Estado.Enabled = ligado
    if ligado then
        criarTrail()
        if TrailConn then TrailConn:Disconnect() end
        TrailConn = RunService.Heartbeat:Connect(function()
            if not TR_Estado.Enabled then return end
            local char = LP.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and not root:FindFirstChild("VST_Trail") then criarTrail() end
        end)
        notificar("Trail ativado", "good")
    else
        limparTrail()
        if TrailConn then TrailConn:Disconnect(); TrailConn = nil end
        notificar("Trail desativado", "bad")
    end
end

function TrailModule.definirCor(opt)
    TR_Estado.Cor = opt
    if TR_Estado.Enabled then criarTrail() end
end

function TrailModule.definirTextura(opt)
    TR_Estado.Textura = opt
    if TR_Estado.Enabled then criarTrail() end
end

function TrailModule.definirLifetime(v)
    TR_Estado.Lifetime = v
    if TrailAtual then TrailAtual.Lifetime = v end
end

function TrailModule.definirEspessura(v)
    TR_Estado.Espessura = v
    if TrailAtual then TrailAtual.WidthScale = NumberSequence.new(v) end
end

function TrailModule.resetar()
    TR_Estado.Enabled = false
    limparTrail()
    if TrailConn then TrailConn:Disconnect(); TrailConn = nil end
    notificar("Trail removido", "bad")
end

print("[VoidStrap] Parte 6/8 carregada.")--====================================================================
-- MÓDULO: TOTE (Curva imitando teclas T e D do teclado)
--====================================================================
local ToteModule = {}
local TO_Estado = {
    Enabled = false,
    Forca = 1.0,
    BtnVisivel = true,
    BtnTravado = false,
    BtnTPosicao = UDim2.new(0.75, 0, 0.65, 0),
    BtnDPosicao = UDim2.new(0.90, 0, 0.65, 0),
    Ativando = nil,
}
local TO_BtnT, TO_BtnD = nil, nil

--====================================================================
-- SIMULAÇÃO DE TECLA (T / D)
--====================================================================
local function simularTecla(tecla, pressionar)
    -- Método 1: VirtualInputManager
    local ok = pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(pressionar, tecla, false, game)
    end)
    if ok then return end

    -- Método 2: keypress / keyrelease globais (fallback)
    pcall(function()
        if pressionar and keypress then
            keypress(tecla)
        elseif not pressionar and keyrelease then
            keyrelease(tecla)
        end
    end)
end

--====================================================================
-- DETECÇÃO DA BOLA
--====================================================================
local BALL_NAMES_TO = {
    "TPS","ESA","MRS","PRS","MPS","Ball","Football","Soccer Ball","Bola","SoccerBall"
}

local function ehBolaTO(name)
    for _, n in ipairs(BALL_NAMES_TO) do
        if name == n then return true end
    end
    return false
end

local function buscarBolaTO()
    local char = LP.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and ehBolaTO(obj.Name) then
            if not (char and obj:IsDescendantOf(char)) then return obj end
        end
    end
    return nil
end

-- Mantido para compatibilidade (não usado agora, pois a tecla faz o trabalho)
local function aplicarCurva() end

--====================================================================
-- ATUALIZAÇÃO VISUAL DOS BOTÕES
--====================================================================
local function atualizarBtn(btn, tipo)
    if not btn or not btn.Parent then return end
    if not TO_Estado.Enabled then
        btn.BackgroundColor3 = TemaAtivo.Surface2
        btn.TextColor3 = TemaAtivo.Sub
    elseif TO_Estado.Ativando == tipo then
        btn.BackgroundColor3 = TemaAtivo.Good
        btn.TextColor3 = TemaAtivo.Text
    else
        btn.BackgroundColor3 = TemaAtivo.Accent
        btn.TextColor3 = TemaAtivo.Text
    end
end

local function atualizarTodosBtns()
    atualizarBtn(TO_BtnT, "T")
    atualizarBtn(TO_BtnD, "D")
end

--====================================================================
-- CRIAÇÃO DOS BOTÕES
--====================================================================
local function criarBotao(btnRef, tipo, posicao)
    if btnRef and btnRef.Parent then
        btnRef.Visible = true
        atualizarBtn(btnRef, tipo)
        return btnRef
    end

    local btn = criar("TextButton", {
        Name = "VST_ToteBtn" .. tipo,
        Size = UDim2.fromOffset(60, 60),
        Position = posicao,
        BackgroundColor3 = TemaAtivo.Accent,
        BorderSizePixel = 0,
        Text = tipo,
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = TemaAtivo.Text,
        AutoButtonColor = false,
        ZIndex = 99998,
        Parent = ScreenOverlay,
    })
    canto(30, btn)
    contorno(TemaAtivo.AccentDim, 2, 0.2, btn, 99998)
    atualizarBtn(btn, tipo)

    local arrastando, dragIni, posIni = false, nil, nil
    local tempoP, posP = 0, nil

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            arrastando = true
            dragIni = input.Position
            posIni = btn.Position
            tempoP = tick()
            posP = input.Position

            if TO_Estado.Enabled then
                TO_Estado.Ativando = tipo
                atualizarTodosBtns()
                -- Simula segurar a tecla T ou D
                if tipo == "T" then
                    simularTecla(Enum.KeyCode.T, true)
                else
                    simularTecla(Enum.KeyCode.D, true)
                end
            end
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not arrastando or TO_Estado.BtnTravado then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragIni
            if math.abs(d.X) > 8 or math.abs(d.Y) > 8 then
                btn.Position = UDim2.new(
                    posIni.X.Scale, posIni.X.Offset + d.X,
                    posIni.Y.Scale, posIni.Y.Offset + d.Y)
                if tipo == "T" then TO_Estado.BtnTPosicao = btn.Position
                else TO_Estado.BtnDPosicao = btn.Position end
            end
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            arrastando = false

            -- Solta a tecla correspondente
            if tipo == "T" then
                simularTecla(Enum.KeyCode.T, false)
            else
                simularTecla(Enum.KeyCode.D, false)
            end

            if TO_Estado.Ativando == tipo then
                TO_Estado.Ativando = nil
            end
            atualizarTodosBtns()

            -- Clique rápido alterna o Tote
            if posP then
                local df = input.Position - posP
                local mov = math.abs(df.X) + math.abs(df.Y)
                local tmp = tick() - tempoP
                if mov < 12 and tmp < 0.5 then
                    TO_Estado.Enabled = not TO_Estado.Enabled
                    if TO_Estado.Enabled then
                        notificar("Tote ativado", "good")
                    else
                        notificar("Tote desativado", "bad")
                    end
                    atualizarTodosBtns()
                end
            end
            posP = nil
        end
    end)

    return btn
end

--====================================================================
-- API PÚBLICA
--====================================================================
function ToteModule.criarBotoes()
    TO_BtnT = criarBotao(TO_BtnT, "T", TO_Estado.BtnTPosicao)
    TO_BtnD = criarBotao(TO_BtnD, "D", TO_Estado.BtnDPosicao)
end

function ToteModule.ativar(ligado)
    TO_Estado.Enabled = ligado
    if ligado then
        ToteModule.criarBotoes()
        notificar("Tote ativado", "good")
    else
        -- Solta as teclas caso estejam pressionadas
        if TO_Estado.Ativando == "T" then simularTecla(Enum.KeyCode.T, false) end
        if TO_Estado.Ativando == "D" then simularTecla(Enum.KeyCode.D, false) end
        TO_Estado.Ativando = nil
        notificar("Tote desativado", "bad")
    end
    atualizarTodosBtns()
end

function ToteModule.definirForca(v)
    TO_Estado.Forca = v
end

function ToteModule.esconderBotoes()
    -- Solta teclas por segurança
    if TO_Estado.Ativando == "T" then simularTecla(Enum.KeyCode.T, false) end
    if TO_Estado.Ativando == "D" then simularTecla(Enum.KeyCode.D, false) end
    TO_Estado.Ativando = nil

    if TO_BtnT and TO_BtnT.Parent then TO_BtnT:Destroy(); TO_BtnT = nil end
    if TO_BtnD and TO_BtnD.Parent then TO_BtnD:Destroy(); TO_BtnD = nil end
end

function ToteModule.travarBotoes(on)
    TO_Estado.BtnTravado = on
    notificar(on and "Botoes T/D travados" or "Botoes T/D liberados",
              on and "good" or "bad")
end

function ToteModule.resetar()
    ToteModule.esconderBotoes()
    TO_Estado.Enabled = false
    notificar("Tote resetado", "bad")
end

--====================================================================
-- CRIAÇÃO DAS ABAS
--====================================================================
criarAba("Skybox",      "◈")
criarAba("Stretch",     "▢")
criarAba("Grama",       "❖")
criarAba("Iluminacao",  "☀")
criarAba("Performance", "▶")
criarAba("Fire Trail",  "🔥")
criarAba("Chars",       "CH")
criarAba("Bola Custom", "BC")
criarAba("Boom Box",    "BB")
criarAba("Auto Follow", "AF")
criarAba("Auto Catch",  "AC")
criarAba("Trail",       "TR")
criarAba("Tote",        "TO")
criarAba("Config.",     "⚙")

-- -------------------- SKYBOX --------------------
do
    local page = Tabs["Skybox"].page
    local sec = section("Skybox Local")
    sec.Parent = page

    toggleRow(sec, "Ativar Skybox", Estado.Skybox.Enabled, function(on)
        SkyboxModule.ativar(on)
    end, 1)

    for i, nome in ipairs({"Padrao","Noite","Espaco","Vermelho","Roxo","Personalizado"}) do
        buttonRow(sec, "• " .. nome, function()
            SkyboxModule.aplicar(nome)
        end, 10 + i)
    end

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Restaurar Skybox original", function()
        SkyboxModule.restaurar()
        notificar("Skybox restaurado", "good")
    end, 1)
end

-- -------------------- STRETCH --------------------
do
    local page = Tabs["Stretch"].page
    local sec = section("Stretch Screen (FOV)")
    sec.Parent = page

    toggleRow(sec, "Ativar Stretch", Estado.Stretch.Enabled, function(on)
        StretchModule.ativar(on)
    end, 1)

    sliderRow(sec, "Intensidade", 0, 100, Estado.Stretch.Intensity, function(v)
        StretchModule.definirIntensidade(v)
    end, 2)

    local resetSec = section("Resetar")
    resetSec.Parent = page
    buttonRow(resetSec, "Resetar Stretch", function()
        StretchModule.resetar()
        notificar("Stretch resetado", "good")
    end, 1)
end

-- -------------------- GRAMA --------------------
do
    local page = Tabs["Grama"].page
    local sec = section("Cor da Grama")
    sec.Parent = page

    for i, nome in ipairs({
        "Verde Padrao","Verde Escuro","Verde Neon","Verde Agua","Azul","Roxo",
        "Vermelho","Rosa","Amarelo","Cinza","Branco","Preto","Gelo"
    }) do
        buttonRow(sec, "🌿 " .. nome, function()
            GrassModule.aplicarPreset(nome)
        end, 10 + i)
    end

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Restaurar grama", function()
        GrassModule.resetar()
    end, 1)
end

-- -------------------- ILUMINAÇÃO --------------------
do
    local page = Tabs["Iluminacao"].page
    local sec = section("Iluminacao da Cena")
    sec.Parent = page

    toggleRow(sec, "Ativar Iluminacao", Estado.Lighting.Enabled, function(on)
        Estado.Lighting.Enabled = on
        if on then
            LightingModule.definirHora(Estado.Lighting.Hour)
            notificar("Iluminacao ativada", "good")
        else
            LightingModule.restaurar()
            notificar("Iluminacao desativada", "bad")
        end
    end, 1)

    sliderRow(sec, "Hora (1-30)", 1, 30, Estado.Lighting.Hour, function(v)
        Estado.Lighting.Hour = v
        if Estado.Lighting.Enabled then LightingModule.definirHora(v) end
    end, 2)

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Restaurar iluminacao", function()
        LightingModule.restaurar()
    end, 1)
end

-- -------------------- PERFORMANCE --------------------
do
    local page = Tabs["Performance"].page
    local sec = section("Flags de Performance")
    sec.Parent = page

    toggleRow(sec, "Ativar Flags", Estado.Flags.Enabled, function(on)
        FlagsModule.ativar(on)
    end, 1)

    dropdownRow(sec, "Preset",
        { "Ultra", "Balanced", "Performance", "Potato" },
        Estado.Flags.Preset,
        function(opt) FlagsModule.definirPreset(opt) end, 2)
end

-- -------------------- FIRE TRAIL --------------------
do
    local page = Tabs["Fire Trail"].page
    local sec = section("Rastro de Fogo na Bola")
    sec.Parent = page

    toggleRow(sec, "Ativar Fire Trail", (Estado.FireTrail and Estado.FireTrail.Enabled) or false, function(on)
        FireTrailModule.ativar(on)
    end, 1)

    dropdownRow(sec, "Estilo",
        { "Fogo Classico", "Fogo Azul", "Fogo Roxo", "Fogo Verde", "Fogo Branco", "Inferno" },
        (Estado.FireTrail and Estado.FireTrail.Preset) or "Fogo Classico",
        function(opt) FireTrailModule.definirPreset(opt) end, 2)

    buttonRow(sec, "Forcar busca da bola", function()
        FireTrailModule.reconectar()
    end, 3)

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Remover efeitos da bola", function()
        FireTrailModule.resetar()
    end, 1)
end

-- -------------------- CONFIG. --------------------
do
    local page = Tabs["Config."].page
    local sec = section("Configuracoes")
    sec.Parent = page

    toggleRow(sec, "Animacoes", Estado.Settings.AnimationsEnabled, function(on)
        Estado.Settings.AnimationsEnabled = on
    end, 1)

    toggleRow(sec, "Sons", Estado.Settings.SoundsEnabled, function(on)
        Estado.Settings.SoundsEnabled = on
    end, 2)

    dropdownRow(sec, "Tema",
        { "Kirtium", "Void", "Midnight", "Ruby" },
        Estado.Settings.ThemeName,
        function(opt)
            Estado.Settings.ThemeName = opt
            aplicarTema(opt)
            notificar("Tema: " .. opt, "good")
        end, 3)

    local infoSec = section("Informacoes")
    infoSec.Parent = page
    local infoLabel = criar("TextLabel", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        Text = "VoidStrap " .. VERSAO .. "\nExecutor: " .. ExecutorInfo.Name ..
               "\nMobile: " .. tostring(ExecutorInfo.Mobile),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = TemaAtivo.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = infoSec,
    })
    comTema(infoLabel, "TextColor3", "Sub")

    local resetSec = section("Resetar")
    resetSec.Parent = page
    buttonRow(resetSec, "Descarregar VoidStrap", function()
        if _G.VoidStrapUnload then _G.VoidStrapUnload() end
        ScreenGui:Destroy()
    end, 1)
end

-- Seleciona a primeira aba
if next(Tabs) then selecionarAba(next(Tabs)) end

print("[VoidStrap] Parte 7/8 carregada.")-- -------------------- CHARS --------------------
do
    local page = Tabs["Chars"].page
    local sec = section("Aplicar Char via Chat")
    sec.Parent = page

    local info = criar("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "Clique em um char para enviar :char NOME no chat.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = TemaAtivo.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = sec,
    })
    comTema(info, "TextColor3", "Sub")

    for i, nome in ipairs(LISTA_CHARS) do
        buttonRow(sec, nome, function()
            CharsModule.aplicar(nome)
        end, 10 + i)
    end

    local secId = section("Char por ID")
    secId.Parent = page
    local inputFrame = criar("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = TemaAtivo.Surface2,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Parent = secId,
    })
    comTema(inputFrame, "BackgroundColor3", "Surface2")
    canto(8, inputFrame)

    local caixa = criar("TextBox", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Digite o ID do char...",
        PlaceholderColor3 = TemaAtivo.Sub,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = TemaAtivo.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inputFrame,
    })
    comTema(caixa, "TextColor3", "Text")
    comTema(caixa, "PlaceholderColor3", "Sub")

    local btn = criar("TextButton", {
        Size = UDim2.fromOffset(80, 26),
        Position = UDim2.new(1, -90, 0.5, -13),
        BackgroundColor3 = TemaAtivo.Accent,
        BorderSizePixel = 0,
        Text = "Aplicar",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = TemaAtivo.Text,
        AutoButtonColor = false,
        Parent = inputFrame,
    })
    comTema(btn, "BackgroundColor3", "Accent")
    canto(6, btn)
    btn.MouseButton1Click:Connect(function()
        tocarClique()
        CharsModule.aplicar(caixa.Text)
    end)
end

-- -------------------- BOLA CUSTOM --------------------
do
    local page = Tabs["Bola Custom"].page
    local sec = section("Aparencia da Bola")
    sec.Parent = page

    toggleRow(sec, "Ativar Custom Ball", false, function(on)
        BolaCustomModule.ativar(on)
    end, 1)

    local cores = {
        ["Branco"]=Color3.fromRGB(255,255,255), ["Preto"]=Color3.fromRGB(0,0,0),
        ["Vermelho"]=Color3.fromRGB(255,50,50), ["Azul"]=Color3.fromRGB(50,150,255),
        ["Verde"]=Color3.fromRGB(50,255,100), ["Amarelo"]=Color3.fromRGB(255,255,50),
        ["Roxo"]=Color3.fromRGB(180,50,255), ["Rosa"]=Color3.fromRGB(255,100,200),
        ["Ciano"]=Color3.fromRGB(0,255,255), ["Laranja"]=Color3.fromRGB(255,150,0),
    }
    local nomes = {}
    for n in pairs(cores) do table.insert(nomes, n) end
    table.sort(nomes)

    dropdownRow(sec, "Cor da Bola", nomes, "Branco", function(opt)
        if cores[opt] then BolaCustomModule.definirCor(cores[opt]) end
    end, 2)

    dropdownRow(sec, "Material",
        {"SmoothPlastic","Neon","Metal","Glass","ForceField","Ice"},
        "SmoothPlastic",
        function(opt) BolaCustomModule.definirMaterial(opt) end, 3)

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Restaurar cor original", function()
        BolaCustomModule.resetar()
    end, 1)
end

-- -------------------- BOOM BOX --------------------
do
    local page = Tabs["Boom Box"].page
    local sec = section("Boom Box")
    sec.Parent = page

    toggleRow(sec, "Ativar Boom Box", false, function(on)
        BoomBoxModule.ativar(on)
    end, 1)

    dropdownRow(sec, "Tocar em", {"Player", "Ball"}, "Player", function(opt)
        BoomBoxModule.definirAlvo(opt)
    end, 2)

    sliderRow(sec, "Volume (x100)", 0, 200, 100, function(v)
        BoomBoxModule.definirVolume(v / 100)
    end, 3)

    toggleRow(sec, "Loop", true, function(on)
        BoomBoxModule.definirLoop(on)
    end, 4)

    local secFaixas = section("Musicas")
    secFaixas.Parent = page
    for i, t in ipairs(TRACKS_BB) do
        buttonRow(secFaixas, t.name, function()
            BoomBoxModule.tocarFaixa(t.name, t.id)
        end, i)
    end

    local secId = section("Tocar por ID")
    secId.Parent = page
    local inputFrame = criar("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = TemaAtivo.Surface2,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Parent = secId,
    })
    comTema(inputFrame, "BackgroundColor3", "Surface2")
    canto(8, inputFrame)

    local caixa = criar("TextBox", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Digite o ID da musica...",
        PlaceholderColor3 = TemaAtivo.Sub,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = TemaAtivo.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inputFrame,
    })
    comTema(caixa, "TextColor3", "Text")
    comTema(caixa, "PlaceholderColor3", "Sub")

    local btn = criar("TextButton", {
        Size = UDim2.fromOffset(80, 26),
        Position = UDim2.new(1, -90, 0.5, -13),
        BackgroundColor3 = TemaAtivo.Accent,
        BorderSizePixel = 0,
        Text = "Tocar",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = TemaAtivo.Text,
        AutoButtonColor = false,
        Parent = inputFrame,
    })
    comTema(btn, "BackgroundColor3", "Accent")
    canto(6, btn)
    btn.MouseButton1Click:Connect(function()
        tocarClique()
        BoomBoxModule.tocarPorId(caixa.Text)
    end)
end

-- -------------------- AUTO FOLLOW --------------------
do
    local page = Tabs["Auto Follow"].page
    local sec = section("Seguir Bola")
    sec.Parent = page

    toggleRow(sec, "Ativar Auto Follow", false, function(on)
        AutoFollowModule.ativar(on)
    end, 1)

    dropdownRow(sec, "Alvo", {"Todas", "Mais Próxima"}, "Mais Próxima", function(opt)
        AutoFollowModule.definirModo(opt)
    end, 2)

    sliderRow(sec, "Velocidade", 8, 60, 22, function(v)
        AutoFollowModule.definirVelocidade(v)
    end, 3)

    sliderRow(sec, "Distancia Parada (x10)", 10, 100, 25, function(v)
        AutoFollowModule.definirDistancia(v / 10)
    end, 4)

    toggleRow(sec, "Anti-Stuck", true, function(on)
        AutoFollowModule.ativarAntiStuck(on)
    end, 5)

    local secBtn = section("Botao Flutuante")
    secBtn.Parent = page

    toggleRow(secBtn, "Mostrar Botao AF", false, function(on)
        if on then AutoFollowModule.criarBotaoAF()
        else AutoFollowModule.esconderBotaoAF() end
    end, 1)

    toggleRow(secBtn, "Travar Botao AF", false, function(on)
        AutoFollowModule.travarBotaoAF(on)
    end, 2)

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Desativar tudo", function()
        AutoFollowModule.resetar()
        AutoFollowModule.esconderBotaoAF()
    end, 1)
end

-- -------------------- AUTO CATCH --------------------
do
    local page = Tabs["Auto Catch"].page
    local secAC = section("Auto Catch")
    secAC.Parent = page

    toggleRow(secAC, "Ativar Auto Catch", false, function(on)
        AutoCatchModule.ativar(on)
    end, 1)

    sliderRow(secAC, "Distancia (studs)", 2, 25, 8, function(v)
        AutoCatchModule.definirDistancia(v)
    end, 2)

    local secRC = section("Reach")
    secRC.Parent = page

    toggleRow(secRC, "Ativar Reach", false, function(on)
        AutoCatchModule.ativarReach(on)
    end, 1)

    sliderRow(secRC, "Reach (studs)", 1, 20, 6, function(v)
        AutoCatchModule.definirDistanciaReach(v)
    end, 2)

    dropdownRow(secRC, "Modo", {"Toque Simples", "Empurrao Continuo"}, "Toque Simples", function(opt)
        AutoCatchModule.definirModoReach(opt)
    end, 3)

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Desativar tudo", function()
        AutoCatchModule.resetar()
    end, 1)
end

-- -------------------- TRAIL --------------------
do
    local page = Tabs["Trail"].page
    local sec = section("Trail no Personagem")
    sec.Parent = page

    toggleRow(sec, "Ativar Trail", false, function(on)
        TrailModule.ativar(on)
    end, 1)

    local nomesC = {}
    for n in pairs(CORES_TR) do table.insert(nomesC, n) end
    table.sort(nomesC)

    dropdownRow(sec, "Cor", nomesC, "Roxo", function(opt)
        TrailModule.definirCor(opt)
    end, 2)

    local nomesT = {}
    for n in pairs(TEXTURAS_TR) do table.insert(nomesT, n) end
    table.sort(nomesT)

    dropdownRow(sec, "Textura", nomesT, "Padrao", function(opt)
        TrailModule.definirTextura(opt)
    end, 3)

    sliderRow(sec, "Duracao (x10)", 1, 50, 10, function(v)
        TrailModule.definirLifetime(v / 10)
    end, 4)

    sliderRow(sec, "Espessura (x10)", 1, 30, 10, function(v)
        TrailModule.definirEspessura(v / 10)
    end, 5)

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Remover Trail", function()
        TrailModule.resetar()
    end, 1)
end

-- -------------------- TOTE --------------------
do
    local page = Tabs["Tote"].page
    local sec = section("Tote (Curva)")
    sec.Parent = page

    toggleRow(sec, "Ativar Tote", false, function(on)
        ToteModule.ativar(on)
    end, 1)

    sliderRow(sec, "Forca da Curva (x10)", 1, 30, 10, function(v)
        ToteModule.definirForca(v / 10)
    end, 2)

    local info = criar("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "Segure T (curva esquerda) ou D (curva direita) na tela.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = TemaAtivo.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 3,
        Parent = sec,
    })
    comTema(info, "TextColor3", "Sub")

    local secBtn = section("Botoes Flutuantes (Mobile)")
    secBtn.Parent = page

    toggleRow(secBtn, "Mostrar Botoes T/D", false, function(on)
        if on then ToteModule.criarBotoes() else ToteModule.esconderBotoes() end
    end, 1)

    toggleRow(secBtn, "Travar Botoes no Lugar", false, function(on)
        ToteModule.travarBotoes(on)
    end, 2)

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Desativar Tote e remover botoes", function()
        ToteModule.resetar()
    end, 1)
end

--====================================================================
-- FINALIZAÇÃO / CLEANUP
--====================================================================
local _prevUnload = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevUnload then _prevUnload() end
    pcall(function()
        AutoFollowModule.resetar()
        AutoCatchModule.resetar()
        TrailModule.resetar()
        ToteModule.resetar()
        BoomBoxModule.ativar(false)
        BolaCustomModule.resetar()
        FireTrailModule.resetar()
    end)
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP and _G.VoidStrapUnload then
        pcall(function() _G.VoidStrapUnload() end)
    end
end)

task.wait(0.5)
notificar("VoidStrap " .. VERSAO .. " carregado!", "good")

print("[VoidStrap] Parte 8/8 carregada. Script completo!")
