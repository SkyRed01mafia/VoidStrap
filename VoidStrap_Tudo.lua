--[[
    ██╗   ██╗ ██████╗ ██╗██████╗ ███████╗████████╗██████╗  █████╗ ██████╗
    ██║   ██║██╔═══██╗██║██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗
    ██║   ██║██║   ██║██║██║  ██║███████╗   ██║   ██████╔╝███████║██████╔╝
    ╚██╗ ██╔╝██║   ██║██║██║  ██║╚════██║   ██║   ██╔══██╗██╔══██║██╔═══╝
     ╚████╔╝ ╚██████╔╝██║██████╔╝███████║   ██║   ██║  ██║██║  ██║██║
      ╚═══╝   ╚═════╝ ╚═╝╚═════╝ ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝

    VoidStrap v1.3.0 — Interface Premium em Português
]]

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
local ExecutorInfo = { Name = "Desconhecido", Mobile = false, HasGethui = false, InStudio = false }
pcall(function()
    if identifyexecutor then ExecutorInfo.Name = identifyexecutor()
    elseif getexecutorname then ExecutorInfo.Name = getexecutorname() end
end)
ExecutorInfo.Mobile    = UIS.TouchEnabled and not UIS.KeyboardEnabled
ExecutorInfo.HasGethui = (type(gethui) == "function")
ExecutorInfo.InStudio  = RunService:IsStudio()

print(("[VoidStrap] Executor=%s | Mobile=%s | gethui=%s | Studio=%s")
    :format(ExecutorInfo.Name, tostring(ExecutorInfo.Mobile),
            tostring(ExecutorInfo.HasGethui), tostring(ExecutorInfo.InStudio)))

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

--====================================================================
-- CONSTANTES
--====================================================================
local VERSAO = "v1.3.0"
local TITULO = "VoidStrap"

--====================================================================
-- TEMAS (com mais variações)
--====================================================================
local Temas = {
    Void = {
        Background   = Color3.fromRGB(13, 13, 17),
        Background2  = Color3.fromRGB(8, 8, 11),
        Surface      = Color3.fromRGB(24, 24, 30),
        Surface2     = Color3.fromRGB(34, 34, 42),
        Surface3     = Color3.fromRGB(44, 44, 54),
        Accent       = Color3.fromRGB(140, 100, 255),
        Accent2      = Color3.fromRGB(90, 60, 200),
        AccentDim    = Color3.fromRGB(60, 40, 120),
        Text         = Color3.fromRGB(240, 240, 248),
        Sub          = Color3.fromRGB(150, 150, 168),
        Stroke       = Color3.fromRGB(50, 50, 62),
        Stroke2      = Color3.fromRGB(70, 70, 85),
        Good         = Color3.fromRGB(80, 210, 130),
        Bad          = Color3.fromRGB(230, 85, 85),
    },
    Kirtium = {
        Background   = Color3.fromRGB(11, 13, 12),
        Background2  = Color3.fromRGB(7, 9, 8),
        Surface      = Color3.fromRGB(21, 24, 22),
        Surface2     = Color3.fromRGB(31, 35, 32),
        Surface3     = Color3.fromRGB(42, 47, 43),
        Accent       = Color3.fromRGB(80, 225, 140),
        Accent2      = Color3.fromRGB(50, 180, 100),
        AccentDim    = Color3.fromRGB(30, 100, 60),
        Text         = Color3.fromRGB(245, 248, 246),
        Sub          = Color3.fromRGB(150, 158, 152),
        Stroke       = Color3.fromRGB(46, 52, 48),
        Stroke2      = Color3.fromRGB(66, 74, 68),
        Good         = Color3.fromRGB(80, 220, 140),
        Bad          = Color3.fromRGB(230, 90, 90),
    },
    Midnight = {
        Background   = Color3.fromRGB(8, 12, 20),
        Background2  = Color3.fromRGB(5, 8, 14),
        Surface      = Color3.fromRGB(14, 20, 32),
        Surface2     = Color3.fromRGB(22, 30, 46),
        Surface3     = Color3.fromRGB(30, 40, 60),
        Accent       = Color3.fromRGB(80, 160, 255),
        Accent2      = Color3.fromRGB(50, 120, 220),
        AccentDim    = Color3.fromRGB(30, 70, 140),
        Text         = Color3.fromRGB(230, 240, 255),
        Sub          = Color3.fromRGB(130, 150, 180),
        Stroke       = Color3.fromRGB(30, 44, 66),
        Stroke2      = Color3.fromRGB(45, 60, 85),
        Good         = Color3.fromRGB(80, 220, 160),
        Bad          = Color3.fromRGB(230, 90, 100),
    },
    Ruby = {
        Background   = Color3.fromRGB(18, 10, 12),
        Background2  = Color3.fromRGB(12, 5, 7),
        Surface      = Color3.fromRGB(30, 16, 20),
        Surface2     = Color3.fromRGB(42, 22, 28),
        Surface3     = Color3.fromRGB(56, 30, 38),
        Accent       = Color3.fromRGB(255, 90, 120),
        Accent2      = Color3.fromRGB(220, 60, 90),
        AccentDim    = Color3.fromRGB(130, 30, 50),
        Text         = Color3.fromRGB(255, 235, 240),
        Sub          = Color3.fromRGB(190, 140, 150),
        Stroke       = Color3.fromRGB(60, 30, 40),
        Stroke2      = Color3.fromRGB(80, 45, 55),
        Good         = Color3.fromRGB(120, 220, 140),
        Bad          = Color3.fromRGB(255, 80, 80),
    },
}
local TemaAtivo = Temas.Kirtium

--====================================================================
-- ESTADO PERSISTENTE
--====================================================================
local Estado = {
    Settings = { AnimationsEnabled = true, SoundsEnabled = true, ThemeName = "Kirtium" },
    Window = { Minimized = false },
    Skybox = { Enabled = false, Current = "Default" },
    Stretch = { Enabled = false, Intensity = 0, BaseFOV = 70 },
    Flags = { Enabled = false, Preset = "Balanced" },
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
    for inst in pairs(Originais.Instances) do
        restaurarInstancia(inst)
    end
    Originais.Instances = {}
end

--====================================================================
-- HELPERS DE UI
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
        Color = cor or Color3.new(1, 1, 1),
        Thickness = espessura or 1,
        Transparency = transparencia or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        ZIndex = zindex or 1,
        Parent = parent,
    })
end

local function espacamento(px, parent, top, bottom, left, right)
    return criar("UIPadding", {
        PaddingTop    = UDim.new(0, top or px),
        PaddingBottom = UDim.new(0, bottom or px),
        PaddingLeft   = UDim.new(0, left or px),
        PaddingRight  = UDim.new(0, right or px),
        Parent = parent,
    })
end

local function gradiente(c1, c2, rot, parent, transparencia)
    local g = criar("UIGradient", {
        Color = ColorSequence.new(c1, c2),
        Rotation = rot or 90,
        Parent = parent,
    })
    return g
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

--====================================================================
-- SISTEMA DE TEMA DINÂMICO
--====================================================================
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
-- NOTIFICAÇÕES (premium com fade + ícone)
--====================================================================
local NotificacoesHolder

local function notificar(texto, tipo)
    tipo = tipo or "info"
    if not NotificacoesHolder then return end

    local cor = TemaAtivo.Accent
    local icone = "•"
    if tipo == "good" then cor = TemaAtivo.Good; icone = "✓" end
    if tipo == "bad"  then cor = TemaAtivo.Bad;  icone = "✕" end

    local frame = criar("Frame", {
        Size = UDim2.fromOffset(300, 48),
        BackgroundColor3 = TemaAtivo.Surface,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = NotificacoesHolder,
    })
    canto(10, frame)
    contorno(TemaAtivo.Stroke, 1, 0.3, frame)

    local faixa = criar("Frame", {
        Size = UDim2.new(0, 4, 1, -14),
        Position = UDim2.new(0, 7, 0, 7),
        BackgroundColor3 = cor,
        BorderSizePixel = 0,
        Parent = frame,
    })
    canto(2, faixa)

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
        if out1 then
            out1.Completed:Connect(function() frame:Destroy() end)
        else
            frame:Destroy()
        end
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

-- ---------- JANELA PRINCIPAL ----------
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

-- Gradiente sutil de fundo
local GradienteMain = criar("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, TemaAtivo.Background),
        ColorSequenceKeypoint.new(1, TemaAtivo.Background2),
    }),
    Rotation = 45,
    Parent = Main,
})

-- Stroke duplo (glow)
contorno(TemaAtivo.Stroke, 1, 0.4, Main, 2)
contorno(TemaAtivo.AccentDim, 2, 0.85, Main, 3)

-- ---------- TOPBAR ----------
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

-- Cobre cantos inferiores da topbar
criar("Frame", {
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(0, 0, 1, -16),
    BackgroundColor3 = TemaAtivo.Surface,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 5,
    Parent = TopBar,
})
comTema(TopBar:FindFirstChildOfClass("Frame"), "BackgroundColor3", "Surface")

-- Logo premium
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

local GradienteLogo = criar("UIGradient", {
    Color = ColorSequence.new(TemaAtivo.Accent, TemaAtivo.Accent2),
    Rotation = 45,
    Parent = Logo,
})

local ImagemLogo = criar("ImageLabel", {
    Size = UDim2.fromScale(0.7, 0.7),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Image = "rbxassetid://99887975337982",
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 7,
    Parent = Logo,
})

-- Título
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

-- Badge de versão
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

local VersaoLabel = criar("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = VERSAO,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = TemaAtivo.Text,
    ZIndex = 7,
    Parent = BadgeVersao,
})
comTema(VersaoLabel, "TextColor3", "Text")

-- Botões da topbar
local function botaoTopBar(icone, offsetDireita)
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
    return btn
end

local BotaoFechar    = botaoTopBar("✕", -48)
local BotaoMinimizar = botaoTopBar("−", -88)

-- ---------- SIDEBAR ----------
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
espacamento(10, Sidebar, 12, 12, 10, 6)
criar("UIListLayout", {
    Padding = UDim.new(0, 3),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = Sidebar,
})

-- ---------- CONTENT ----------
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
espacamento(16, Content, 14, 14, 16, 16)

print("[VoidStrap] Bloco 1/8 carregado.")--====================================================================
-- SISTEMA DE ABAS (premium)
--====================================================================
local Tabs = {}
local AbaAtual = nil

function selecionarAba(nome)
    for n, tab in pairs(Tabs) do
        local ativo = (n == nome)
        tab.page.Visible = ativo
        tab.indicador.Visible = ativo

        animar(tab.button, 0.25, {
            BackgroundColor3 = ativo and TemaAtivo.Surface or TemaAtivo.Background,
            BackgroundTransparency = ativo and 0.2 or 1,
        })
        animar(tab.txt, 0.25, {
            TextColor3 = ativo and TemaAtivo.Text or TemaAtivo.Sub,
        })
        animar(tab.icon, 0.25, {
            TextColor3 = ativo and TemaAtivo.Accent or TemaAtivo.Sub,
        })
        if ativo then
            animar(tab.indicador, 0.25, {
                BackgroundTransparency = 0,
                Size = UDim2.new(0, 3, 0.6, 0),
            })
        else
            animar(tab.indicador, 0.2, {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 3, 0.3, 0),
            })
        end
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
        TextXAlignment = Enum.TextXAlignment.Center,
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
    btn.MouseEnter:Connect(function()
        if AbaAtual ~= nome then
            animar(btn, 0.15, { BackgroundColor3 = TemaAtivo.Surface, BackgroundTransparency = 0.6 })
        end
    end)
    btn.MouseLeave:Connect(function()
        if AbaAtual ~= nome then
            animar(btn, 0.15, { BackgroundColor3 = TemaAtivo.Background, BackgroundTransparency = 1 })
        end
    end)
end

--====================================================================
-- COMPONENTE: SECTION (com barra lateral colorida)
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

    local barraLateral = criar("Frame", {
        Size = UDim2.new(0, 3, 1, -20),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = TemaAtivo.Accent,
        BorderSizePixel = 0,
        ZIndex = 21,
        Parent = frame,
    })
    comTema(barraLateral, "BackgroundColor3", "Accent")
    canto(2, barraLateral)

    espacamento(frame, 0, 14, 14, 16, 14)
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
-- COMPONENTE: BUTTON ROW (com badge + hover)
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
-- COMPONENTE: TOGGLE ROW (premium)
--====================================================================
local function toggleRow(parent, rotulo, inicial, aoMudar, ordem)
    local row = criar("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = TemaAtivo.Surface2,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        LayoutOrder = ordem or 0,
        ZIndex = 22,
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
        ZIndex = 23,
        Parent = row,
    })
    comTema(lbl, "TextColor3", "Text")

    local sub = criar("TextLabel", {
        Size = UDim2.new(1, -110, 0, 14),
        Position = UDim2.new(0, 14, 0, 28),
        BackgroundTransparency = 1,
        Text = "Ativa / desativa essa função",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = TemaAtivo.Sub,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 23,
        Parent = row,
    })
    comTema(sub, "TextColor3", "Sub")

    local track = criar("Frame", {
        Size = UDim2.fromOffset(48, 28),
        Position = UDim2.new(1, -62, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = TemaAtivo.Stroke,
        BorderSizePixel = 0,
        ZIndex = 23,
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
        ZIndex = 24,
        Parent = track,
    })
    canto(11, knob)
    contorno(Color3.new(0, 0, 0), 1, 0.7, knob, 24)

    local estado = inicial and true or false
    local function render(animado)
        local alvoX = estado and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        local alvoCor = estado and TemaAtivo.Accent or TemaAtivo.Stroke
        if animado then
            animar(knob, 0.22, { Position = alvoX })
            animar(track, 0.22, { BackgroundColor3 = alvoCor })
        else
            knob.Position = alvoX
            track.BackgroundColor3 = alvoCor
        end
    end
    render(false)

    local function setar(novoEstado)
        estado = novoEstado and true or false
        render(true)
        if aoMudar then aoMudar(estado) end
    end

    local btn = criar("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 25,
        Parent = row,
    })
    btn.MouseButton1Click:Connect(function()
        tocarClique()
        setar(not estado)
    end)

    return row, setar, function() return estado end
end

print("[VoidStrap] Bloco 2A/8 carregado.")--====================================================================
-- COMPONENTE: SLIDER ROW (premium com gradiente)
--====================================================================
local function sliderRow(parent, rotulo, minV, maxV, inicial, aoMudar, ordem)
    local row = criar("Frame", {
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundColor3 = TemaAtivo.Surface2,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        LayoutOrder = ordem or 0,
        ZIndex = 22,
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
        ZIndex = 23,
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
        ZIndex = 23,
        Parent = row,
    })
    comTema(valueLabel, "TextColor3", "Accent")

    local track = criar("Frame", {
        Size = UDim2.new(1, -28, 0, 8),
        Position = UDim2.new(0, 14, 0, 44),
        BackgroundColor3 = TemaAtivo.Stroke,
        BorderSizePixel = 0,
        ZIndex = 23,
        Parent = row,
    })
    comTema(track, "BackgroundColor3", "Stroke")
    canto(4, track)

    local fill = criar("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = TemaAtivo.Accent,
        BorderSizePixel = 0,
        ZIndex = 24,
        Parent = track,
    })
    comTema(fill, "BackgroundColor3", "Accent")
    canto(4, fill)

    criar("UIGradient", {
        Color = ColorSequence.new(TemaAtivo.Accent, TemaAtivo.Accent2),
        Rotation = 0,
        Parent = fill,
    })

    local handle = criar("Frame", {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 25,
        Parent = track,
    })
    canto(10, handle)
    contorno(TemaAtivo.Accent, 2, 0, handle, 25)

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

    return row, function() return valor end
end

--====================================================================
-- COMPONENTE: DROPDOWN ROW (premium com slide + seta rotativa)
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
        ClipsDescendants = false,
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

    local seta = criar("TextLabel", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(1, -22, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = "▾",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = TemaAtivo.Sub,
        ZIndex = 103,
        Parent = selecionado,
    })
    comTema(seta, "TextColor3", "Sub")

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

        o.MouseEnter:Connect(function()
            animar(o, 0.12, { BackgroundColor3 = TemaAtivo.Surface3, BackgroundTransparency = 0 })
        end)
        o.MouseLeave:Connect(function()
            animar(o, 0.12, { BackgroundColor3 = TemaAtivo.Surface, BackgroundTransparency = 0.3 })
        end)
        o.MouseButton1Click:Connect(function()
            tocarClique()
            selecionado.Text = opt
            lista.Visible = false
            animar(lista, 0.2, { BackgroundTransparency = 1 })
            animar(seta, 0.2, { Rotation = 0 })
            if aoMudar then aoMudar(opt) end
        end)
    end

    selecionado.MouseButton1Click:Connect(function()
        tocarClique()
        local visivel = not lista.Visible
        lista.Visible = visivel
        if visivel then
            animar(lista, 0.2, { BackgroundTransparency = 0 })
            animar(seta, 0.2, { Rotation = 180 })
        else
            animar(lista, 0.15, { BackgroundTransparency = 1 })
            animar(seta, 0.2, { Rotation = 0 })
        end
    end)

    return row
end

--====================================================================
-- FPS METER
--====================================================================
local FPSLabel
do
    local frames, lastT = 0, tick()
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = tick()
        if now - lastT >= 0.5 then
            local fps = math.floor(frames / (now - lastT) + 0.5)
            frames = 0
            lastT = now
            if FPSLabel then FPSLabel.Text = fps .. " FPS" end
        end
    end)
end

print("[VoidStrap] Bloco 2B/8 carregado.")--====================================================================
-- MÓDULO: SKYBOX (presets de iluminação)
--====================================================================
local SkyboxModule = {}
local LightingOriginal = nil

local function capturarIluminacao()
    if LightingOriginal then return end
    LightingOriginal = {
        Ambient          = Lighting.Ambient,
        OutdoorAmbient   = Lighting.OutdoorAmbient,
        Brightness       = Lighting.Brightness,
        ClockTime        = Lighting.ClockTime,
        FogColor         = Lighting.FogColor,
        FogStart         = Lighting.FogStart,
        FogEnd           = Lighting.FogEnd,
        ColorShift_Top   = Lighting.ColorShift_Top,
        ColorShift_Bottom= Lighting.ColorShift_Bottom,
        GlobalShadows    = Lighting.GlobalShadows,
        EnvironmentDiffuseScale  = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    }
end

local SKY_PRESETS = {
    Noite = {
        Ambient          = Color3.fromRGB(10, 10, 25),
        OutdoorAmbient   = Color3.fromRGB(15, 15, 35),
        Brightness       = 0.3,
        ClockTime        = 0,
        FogColor         = Color3.fromRGB(5, 5, 15),
        FogStart         = 30,
        FogEnd           = 250,
        ColorShift_Top   = Color3.fromRGB(30, 30, 70),
        ColorShift_Bottom= Color3.fromRGB(0, 0, 0),
    },
    Espaço = {
        Ambient          = Color3.fromRGB(2, 2, 8),
        OutdoorAmbient   = Color3.fromRGB(5, 5, 15),
        Brightness       = 0.1,
        ClockTime        = 0,
        FogColor         = Color3.fromRGB(0, 0, 5),
        FogStart         = 5,
        FogEnd           = 100,
        ColorShift_Top   = Color3.fromRGB(10, 10, 30),
        ColorShift_Bottom= Color3.fromRGB(0, 0, 0),
    },
    Vermelho = {
        Ambient          = Color3.fromRGB(60, 10, 10),
        OutdoorAmbient   = Color3.fromRGB(80, 15, 15),
        Brightness       = 1.2,
        ClockTime        = 17.5,
        FogColor         = Color3.fromRGB(40, 5, 5),
        FogStart         = 20,
        FogEnd           = 300,
        ColorShift_Top   = Color3.fromRGB(120, 20, 20),
        ColorShift_Bottom= Color3.fromRGB(30, 0, 0),
    },
    Roxo = {
        Ambient          = Color3.fromRGB(40, 15, 60),
        OutdoorAmbient   = Color3.fromRGB(60, 20, 90),
        Brightness       = 1.0,
        ClockTime        = 18.5,
        FogColor         = Color3.fromRGB(25, 5, 40),
        FogStart         = 20,
        FogEnd           = 280,
        ColorShift_Top   = Color3.fromRGB(90, 40, 140),
        ColorShift_Bottom= Color3.fromRGB(20, 0, 40),
    },
    Personalizado = {
        Ambient          = Color3.fromRGB(25, 30, 40),
        OutdoorAmbient   = Color3.fromRGB(40, 50, 70),
        Brightness       = 0.8,
        ClockTime        = 14,
        FogColor         = Color3.fromRGB(10, 20, 30),
        FogStart         = 40,
        FogEnd           = 350,
        ColorShift_Top   = Color3.fromRGB(60, 90, 130),
        ColorShift_Bottom= Color3.fromRGB(10, 15, 25),
    },
}

local ORDEM_SEGURA = {
    "FogColor", "FogStart", "FogEnd",
    "ColorShift_Top", "ColorShift_Bottom",
    "Ambient", "OutdoorAmbient",
    "Brightness", "ClockTime",
}

local function aplicarSkyboxPreset(nome)
    capturarIluminacao()
    if nome == "Padrão" then
        SkyboxModule.restaurar()
        return
    end
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
    if Estado.Skybox.Enabled then
        aplicarSkyboxPreset(nome)
    end
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
-- MÓDULO: STRETCH SCREEN (FOV)
--====================================================================
local StretchModule = {}
local FOV_JITTER = 0
local StretchConn = nil

local function aplicarStretch()
    if not Camera then return end
    if not Estado.Stretch.Enabled or Estado.Stretch.Intensity == 0 then
        pcall(function() Camera.FieldOfView = Estado.Stretch.BaseFOV end)
        return
    end
    local extra = (Estado.Stretch.Intensity / 100) * 50
    FOV_JITTER = (math.random() - 0.5) * 1.0
    pcall(function()
        Camera.FieldOfView = Estado.Stretch.BaseFOV + extra + FOV_JITTER
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
    if Camera then
        pcall(function() Camera.FieldOfView = Estado.Stretch.BaseFOV end)
    end
end

print("[VoidStrap] Bloco 3A/8 carregado.")--====================================================================
-- MÓDULO: GRASS COLOR (cor da grama)
--====================================================================
local GrassModule = {}
local CorGramaOriginal = nil
local PartesRecoloridas = {}

local function ehParteDeGrama(part)
    if not part:IsA("BasePart") then return false end
    local mat = part.Material
    if mat == Enum.Material.Grass or mat == Enum.Material.LeafyGrass then
        return true
    end
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

local function capturarGrama()
    if CorGramaOriginal then return end
    local ok, color = pcall(function()
        return Workspace.Terrain:GetMaterialColor(Enum.Material.Grass)
    end)
    CorGramaOriginal = (ok and color) or Color3.fromRGB(91, 154, 76)
end

function GrassModule.definirCor(color)
    capturarGrama()

    pcall(function()
        Workspace.Terrain:SetMaterialColor(Enum.Material.Grass, color)
        Workspace.Terrain:SetMaterialColor(Enum.Material.LeafyGrass, color)
    end)

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if ehParteDeGrama(obj) and not devePular(obj) then
            if PartesRecoloridas[obj] == nil then
                PartesRecoloridas[obj] = obj.Color
            end
            pcall(function()
                obj.Color = color
                if obj.Material == Enum.Material.SmoothPlastic then
                    obj.Material = Enum.Material.Grass
                end
            end)
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
    ["Verde Padrão"]  = Color3.fromRGB(91, 154, 76),
    ["Verde Escuro"]  = Color3.fromRGB(45, 90, 40),
    ["Verde Neon"]    = Color3.fromRGB(80, 255, 120),
    ["Verde Água"]    = Color3.fromRGB(120, 220, 180),
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
-- MÓDULO: FLAGS / PERFORMANCE
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
        rastrear(Lighting, "EnvironmentDiffuseScale")
        rastrear(Lighting, "EnvironmentSpecularScale")
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
        end)
    end

    if preset == "Potato" then
        rastrear(Lighting, "Brightness")
        pcall(function()
            Lighting.Brightness = math.min(Lighting.Brightness, 0.5)
        end)
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

print("[VoidStrap] Bloco 3B/8 carregado.")--====================================================================
-- MÓDULO: ILUMINAÇÃO (ClockTime 1–30)
--====================================================================
local LightingModule = {}
local ClockTimeOriginal = nil

local function capturarClock()
    if ClockTimeOriginal then return end
    ClockTimeOriginal = Lighting.ClockTime
end

function LightingModule.definirHora(h)
    capturarClock()
    pcall(function() Lighting.ClockTime = h end)
end

function LightingModule.restaurar()
    if ClockTimeOriginal then
        pcall(function() Lighting.ClockTime = ClockTimeOriginal end)
    end
end

--====================================================================
-- CRIAÇÃO DAS ABAS
--====================================================================
criarAba("Skybox",      "◈")
criarAba("Stretch",     "▣")
criarAba("Grama",       "❖")
criarAba("Iluminação",  "☀")
criarAba("Performance", "▶")
criarAba("Config.",     "⚙")

-- -------------------- ABA SKYBOX --------------------
do
    local page = Tabs["Skybox"].page

    local mainSec = section("Skybox Local")
    mainSec.Parent = page

    toggleRow(mainSec, "Ativar Skybox", Estado.Skybox.Enabled, function(on)
        SkyboxModule.ativar(on)
    end, 1)

    local nomes = { "Padrão", "Noite", "Espaço", "Vermelho", "Roxo", "Personalizado" }
    for i, nome in ipairs(nomes) do
        buttonRow(mainSec, "• " .. nome, function()
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

-- -------------------- ABA STRETCH --------------------
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

    local info = criar("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "Altera apenas o FieldOfView da câmera local. Reversível e seguro.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = TemaAtivo.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 3,
        Parent = sec,
    })
    comTema(info, "TextColor3", "Sub")

    local resetSec = section("Resetar")
    resetSec.Parent = page
    buttonRow(resetSec, "Resetar Stretch", function()
        StretchModule.resetar()
        notificar("Stretch resetado", "good")
    end, 1)
end

-- -------------------- ABA GRAMA --------------------
do
    local page = Tabs["Grama"].page

    local mainSec = section("Cor da Grama")
    mainSec.Parent = page

    local info = criar("TextLabel", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = "Funciona em campos de Terrain e em partes com material Grass. Local e reversível.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = TemaAtivo.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = mainSec,
    })
    comTema(info, "TextColor3", "Sub")

    local presets = {
        "Verde Padrão", "Verde Escuro", "Verde Neon", "Verde Água",
        "Azul", "Roxo", "Vermelho", "Rosa",
        "Amarelo", "Cinza", "Branco", "Preto", "Gelo",
    }
    for i, nome in ipairs(presets) do
        buttonRow(mainSec, "🌿 " .. nome, function()
            GrassModule.aplicarPreset(nome)
        end, 10 + i)
    end

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Restaurar cor original da grama", function()
        GrassModule.resetar()
    end, 1)
end

-- -------------------- ABA ILUMINAÇÃO --------------------
do
    local page = Tabs["Iluminação"].page

    local sec = section("Iluminação da Cena")
    sec.Parent = page

    toggleRow(sec, "Ativar Iluminação", Estado.Lighting.Enabled, function(on)
        Estado.Lighting.Enabled = on
        if on then
            LightingModule.definirHora(Estado.Lighting.Hour)
            notificar("Iluminação ativada", "good")
        else
            LightingModule.restaurar()
            notificar("Iluminação desativada", "bad")
        end
    end, 1)

    sliderRow(sec, "Hora (1–30)", 1, 30, Estado.Lighting.Hour, function(v)
        Estado.Lighting.Hour = v
        if Estado.Lighting.Enabled then
            LightingModule.definirHora(v)
        end
    end, 2)

    local info = criar("TextLabel", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Text = "Controla o horário (ClockTime). Valores acima de 24 reiniciam o ciclo automaticamente.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = TemaAtivo.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 3,
        Parent = sec,
    })
    comTema(info, "TextColor3", "Sub")

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Restaurar iluminação original", function()
        LightingModule.restaurar()
        notificar("Iluminação restaurada", "good")
    end, 1)
end

-- -------------------- ABA PERFORMANCE --------------------
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

    local fpsSec = section("Monitor")
    fpsSec.Parent = page

    local fpsRow = criar("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = TemaAtivo.Surface2,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Parent = fpsSec,
    })
    comTema(fpsRow, "BackgroundColor3", "Surface2")
    canto(9, fpsRow)

    local fpsLbl = criar("TextLabel", {
        Size = UDim2.new(1, -110, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = "FPS atual",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = TemaAtivo.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = fpsRow,
    })
    comTema(fpsLbl, "TextColor3", "Text")

    FPSLabel = criar("TextLabel", {
        Size = UDim2.fromOffset(80, 24),
        Position = UDim2.new(1, -94, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = TemaAtivo.Accent,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Text = "— FPS",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.new(1, 1, 1),
        Parent = fpsRow,
    })
    comTema(FPSLabel, "BackgroundColor3", "Accent")
    canto(7, FPSLabel)
end

-- -------------------- ABA CONFIGURAÇÕES --------------------
do
    local page = Tabs["Config."].page

    local sec = section("Interface")
    sec.Parent = page

    toggleRow(sec, "Animações da UI", Estado.Settings.AnimationsEnabled, function(on)
        Estado.Settings.AnimationsEnabled = on
        notificar(on and "Animações ativadas" or "Animações desativadas",
                  on and "good" or "bad")
    end, 1)

    toggleRow(sec, "Sons da UI", Estado.Settings.SoundsEnabled, function(on)
        Estado.Settings.SoundsEnabled = on
        notificar(on and "Sons ativados" or "Sons desativados",
                  on and "good" or "bad")
    end, 2)

    local themeSec = section("Tema")
    themeSec.Parent = page

    dropdownRow(themeSec, "Tema",
        { "Void", "Kirtium", "Midnight", "Ruby" },
        Estado.Settings.ThemeName,
        function(opt)
            Estado.Settings.ThemeName = opt
            aplicarTema(opt)
            notificar("Tema: " .. opt, "good")
        end, 1)

    local resetSec = section("Resetar")
    resetSec.Parent = page

    buttonRow(resetSec, "Resetar configurações", function()
        SkyboxModule.restaurar()
        Estado.Skybox.Enabled = false
        Estado.Skybox.Current = "Padrão"

        StretchModule.resetar()
        GrassModule.restaurar()
        LightingModule.restaurar()
        restaurarTudo()
        Estado.Flags.Enabled = false
        Estado.Flags.Preset = "Balanced"

        Estado.Settings.AnimationsEnabled = true
        Estado.Settings.SoundsEnabled = true
        Estado.Settings.ThemeName = "Kirtium"
        aplicarTema("Kirtium")

        notificar("Configurações resetadas", "good")
    end, 1)
end

--====================================================================
-- MINIMIZAR / FECHAR / BOTÃO FLUTUANTE
--====================================================================
local MiniBotao

local function definirMinimizado(minimizado)
    Estado.Window.Minimized = minimizado
    if minimizado then
        animar(Main, 0.25, { Size = UDim2.fromOffset(0, 0) })
        task.delay(0.25, function()
            Main.Visible = false
            if MiniBotao then MiniBotao.Visible = true end
        end)
    else
        Main.Visible = true
        if MiniBotao then MiniBotao.Visible = false end
        local vp = Camera.ViewportSize
        local w = math.min(660, vp.X - 40)
        local h = math.min(460, vp.Y - 80)
        animar(Main, 0.25, { Size = UDim2.fromOffset(w, h) })
    end
end

BotaoMinimizar.MouseButton1Click:Connect(function()
    tocarClique()
    definirMinimizado(true)
end)

BotaoFechar.MouseButton1Click:Connect(function()
    tocarClique()
    definirMinimizado(true)
end)

-- Botão flutuante "V"
do
    MiniBotao = criar("TextButton", {
        Size = UDim2.fromOffset(52, 52),
        Position = UDim2.new(0, 20, 0.5, -26),
        BackgroundColor3 = TemaAtivo.Accent,
        BorderSizePixel = 0,
        Text = "V",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 99999,
        Parent = ScreenOverlay,
    })
    comTema(MiniBotao, "BackgroundColor3", "Accent")
    canto(26, MiniBotao)
    contorno(TemaAtivo.Stroke, 1, 0.4, MiniBotao, 99999)
    criar("UIGradient", {
        Color = ColorSequence.new(TemaAtivo.Accent, TemaAtivo.AccentDim),
        Rotation = 45,
        Parent = MiniBotao,
    })

    MiniBotao.MouseButton1Click:Connect(function()
        tocarClique()
        definirMinimizado(false)
    end)

    local arrastando, inicioArrasto, posInicial
    MiniBotao.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            arrastando = true
            inicioArrasto = input.Position
            posInicial = MiniBotao.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if arrastando and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - inicioArrasto
            MiniBotao.Position = UDim2.new(
                posInicial.X.Scale, posInicial.X.Offset + delta.X,
                posInicial.Y.Scale, posInicial.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            arrastando = false
        end
    end)
end

--====================================================================
-- ARRASTAR JANELA PELA TOPBAR
--====================================================================
do
    local arrastando, inicioArrasto, posInicial
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            arrastando = true
            inicioArrasto = input.Position
            posInicial = Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if arrastando and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - inicioArrasto
            Main.Position = UDim2.new(
                posInicial.X.Scale, posInicial.X.Offset + delta.X,
                posInicial.Y.Scale, posInicial.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            arrastando = false
        end
    end)
end

--====================================================================
-- HOLDER DE NOTIFICAÇÕES
--====================================================================
NotificacoesHolder = criar("Frame", {
    Size = UDim2.fromOffset(320, 260),
    Position = UDim2.new(1, -340, 1, -280),
    BackgroundTransparency = 1,
    Parent = ScreenOverlay,
})
criar("UIListLayout", {
    Padding = UDim.new(0, 8),
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = NotificacoesHolder,
})

--====================================================================
-- RESPONSIVIDADE
--====================================================================
local function aplicarResponsivo()
    if Estado.Window.Minimized then return end
    local vp = Camera.ViewportSize
    local w = math.min(660, vp.X - 40)
    local h = math.min(460, vp.Y - 80)
    Main.Size = UDim2.fromOffset(w, h)
end

aplicarResponsivo()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(aplicarResponsivo)

--====================================================================
-- ANIMAÇÃO DE ABERTURA
--====================================================================
do
    local vp = Camera.ViewportSize
    local w = math.min(660, vp.X - 40)
    local h = math.min(460, vp.Y - 80)
    Main.Size = UDim2.fromOffset(0, 0)
    task.spawn(function()
        task.wait(0.15)
        animar(Main, 0.35, { Size = UDim2.fromOffset(w, h) },
            Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
end

selecionarAba("Skybox")
aplicarTema(Estado.Settings.ThemeName)
notificar(TITULO .. " " .. VERSAO .. " carregado", "good")

--====================================================================
-- CLEANUP
--====================================================================
Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function()
            SkyboxModule.restaurar()
            StretchModule.resetar()
            GrassModule.restaurar()
            LightingModule.restaurar()
            restaurarTudo()
        end)
    end
end)

_G.VoidStrapUnload = function()
    pcall(function()
        SkyboxModule.restaurar()
        StretchModule.resetar()
        GrassModule.restaurar()
        LightingModule.restaurar()
        restaurarTudo()
    end)
    if ScreenGui then ScreenGui:Destroy() end
    if SomClique then SomClique:Destroy() end
    ElementosComTema = {}
    Originais.Instances = {}
    PartesRecoloridas = {}
    print("[VoidStrap] Descarregado.")
end

print("[VoidStrap] Bloco 4/8 carregado.")
print(("[VoidStrap] %s inicializado com sucesso."):format(VERSAO))--====================================================================
-- MÓDULO: FIRE TRAIL NA BOLA (efeito de fogo + trail + luz)
-- 100% local (client-side), não replica para o servidor.
--====================================================================

Estado.FireTrail = Estado.FireTrail or { Enabled = false, Preset = "Fogo Clássico" }

local FireTrailModule = {}
local BolaAtual = nil
local InstanciasAtivas = {}

-- ---------- PRESETS DE COR ----------
local FIRE_PRESETS = {
    ["Fogo Clássico"] = {
        fire = Color3.fromRGB(255, 120, 30),
        secondary = Color3.fromRGB(255, 60, 0),
        trail = Color3.fromRGB(255, 180, 60),
        trailMid = Color3.fromRGB(255, 80, 20),
        light = Color3.fromRGB(255, 140, 40),
        size = 6,
    },
    ["Fogo Azul"] = {
        fire = Color3.fromRGB(80, 180, 255),
        secondary = Color3.fromRGB(30, 90, 220),
        trail = Color3.fromRGB(150, 210, 255),
        trailMid = Color3.fromRGB(50, 130, 255),
        light = Color3.fromRGB(100, 180, 255),
        size = 6,
    },
    ["Fogo Roxo"] = {
        fire = Color3.fromRGB(180, 80, 255),
        secondary = Color3.fromRGB(120, 30, 220),
        trail = Color3.fromRGB(210, 150, 255),
        trailMid = Color3.fromRGB(140, 60, 255),
        light = Color3.fromRGB(180, 100, 255),
        size = 6,
    },
    ["Fogo Verde"] = {
        fire = Color3.fromRGB(100, 255, 120),
        secondary = Color3.fromRGB(30, 200, 60),
        trail = Color3.fromRGB(160, 255, 180),
        trailMid = Color3.fromRGB(50, 220, 100),
        light = Color3.fromRGB(120, 255, 140),
        size = 6,
    },
    ["Fogo Branco"] = {
        fire = Color3.fromRGB(255, 255, 255),
        secondary = Color3.fromRGB(220, 240, 255),
        trail = Color3.fromRGB(255, 255, 255),
        trailMid = Color3.fromRGB(200, 220, 255),
        light = Color3.fromRGB(255, 255, 255),
        size = 6,
    },
    ["Fogo Sombrio"] = {
        fire = Color3.fromRGB(80, 20, 100),
        secondary = Color3.fromRGB(30, 5, 40),
        trail = Color3.fromRGB(150, 50, 200),
        trailMid = Color3.fromRGB(80, 10, 120),
        light = Color3.fromRGB(120, 30, 180),
        size = 6,
    },
    ["Inferno"] = {
        fire = Color3.fromRGB(255, 80, 0),
        secondary = Color3.fromRGB(255, 220, 60),
        trail = Color3.fromRGB(255, 160, 30),
        trailMid = Color3.fromRGB(255, 60, 0),
        light = Color3.fromRGB(255, 120, 20),
        size = 8,
    },
}

-- ---------- DETECÇÃO DA BOLA ----------
local BALL_NAMES_FT = {
    "TPS", "ESA", "MRS", "PRS", "MPS",
    "Ball", "Football", "Soccer Ball", "Bola", "SoccerBall"
}

local function ehNomeBola(name)
    for _, n in ipairs(BALL_NAMES_FT) do
        if name == n then return true end
    end
    return false
end

local function encontrarBola()
    local char = LP.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and ehNomeBola(obj.Name) then
            if not (char and obj:IsDescendantOf(char)) then
                return obj
            end
        end
    end
    return nil
end

-- ---------- LIMPEZA ----------
local function limparEfeitos()
    for _, inst in ipairs(InstanciasAtivas) do
        pcall(function()
            if inst and inst.Parent then inst:Destroy() end
        end)
    end
    InstanciasAtivas = {}
    BolaAtual = nil
end

-- ---------- APLICAR EFEITOS ----------
local function aplicarEfeitos(ball, presetName)
    limparEfeitos()
    if not ball or not ball.Parent then return end

    local p = FIRE_PRESETS[presetName] or FIRE_PRESETS["Fogo Clássico"]
    BolaAtual = ball

    -- 1) Fire
    local fire = Instance.new("Fire")
    fire.Name = "VST_Fire"
    fire.Color = p.fire
    fire.SecondaryColor = p.secondary
    fire.Size = p.size
    fire.Heat = 15
    fire.Parent = ball
    table.insert(InstanciasAtivas, fire)

    -- 2) Attachments pro Trail
    local offsetY = math.max(ball.Size.Y * 0.5, 1)

    local a0 = Instance.new("Attachment")
    a0.Name = "VST_TrailA0"
    a0.Position = Vector3.new(0, offsetY, 0)
    a0.Parent = ball
    table.insert(InstanciasAtivas, a0)

    local a1 = Instance.new("Attachment")
    a1.Name = "VST_TrailA1"
    a1.Position = Vector3.new(0, -offsetY, 0)
    a1.Parent = ball
    table.insert(InstanciasAtivas, a1)

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
    table.insert(InstanciasAtivas, trail)

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
    table.insert(InstanciasAtivas, sparks)

    -- 5) Luz
    local light = Instance.new("PointLight")
    light.Name = "VST_Light"
    light.Brightness = 3
    light.Range = 14
    light.Color = p.light
    light.Shadows = false
    light.Parent = ball
    table.insert(InstanciasAtivas, light)
end

-- ---------- API PÚBLICA ----------
function FireTrailModule.ativar(ligado)
    Estado.FireTrail.Enabled = ligado
    if ligado then
        local ball = encontrarBola()
        if ball then
            aplicarEfeitos(ball, Estado.FireTrail.Preset)
            notificar("Fire Trail ativado", "good")
        else
            notificar("Bola não encontrada", "bad")
        end
    else
        limparEfeitos()
        notificar("Fire Trail desativado", "bad")
    end
end

function FireTrailModule.definirPreset(nome)
    Estado.FireTrail.Preset = nome
    if Estado.FireTrail.Enabled then
        local ball = BolaAtual
        if not ball or not ball.Parent then ball = encontrarBola() end
        if ball then
            aplicarEfeitos(ball, nome)
            notificar("Rastro: " .. nome, "good")
        end
    end
end

function FireTrailModule.reconectar()
    local ball = encontrarBola()
    if ball then
        aplicarEfeitos(ball, Estado.FireTrail.Preset)
        notificar("Bola reconectada", "good")
    else
        notificar("Nenhuma bola encontrada", "bad")
    end
end

function FireTrailModule.resetar()
    Estado.FireTrail.Enabled = false
    limparEfeitos()
    notificar("Fire Trail resetado", "bad")
end

-- ---------- LOOP DE RE-DETECÇÃO (leve, 1x/s) ----------
task.spawn(function()
    while task.wait(1) do
        if Estado.FireTrail.Enabled then
            if not BolaAtual or not BolaAtual.Parent then
                local ball = encontrarBola()
                if ball then
                    aplicarEfeitos(ball, Estado.FireTrail.Preset)
                end
            end
        end
    end
end)

--====================================================================
-- ABA FIRE TRAIL
--====================================================================
criarAba("Fire Trail", "🔥")

do
    local page = Tabs["Fire Trail"].page

    local sec = section("Rastro de Fogo na Bola")
    sec.Parent = page

    toggleRow(sec, "Ativar Fire Trail", Estado.FireTrail.Enabled, function(on)
        FireTrailModule.ativar(on)
    end, 1)

    dropdownRow(sec, "Estilo",
        { "Fogo Clássico", "Fogo Azul", "Fogo Roxo", "Fogo Verde",
          "Fogo Branco", "Fogo Sombrio", "Inferno" },
        Estado.FireTrail.Preset,
        function(opt) FireTrailModule.definirPreset(opt) end, 2)

    buttonRow(sec, "Forçar busca da bola", function()
        FireTrailModule.reconectar()
    end, 3)

    local info = criar("TextLabel", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Text = "Anexa fogo, trail, faíscas e luz na bola. 100% local e reversível.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = TemaAtivo.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 4,
        Parent = sec,
    })
    comTema(info, "TextColor3", "Sub")

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Remover efeitos da bola", function()
        FireTrailModule.resetar()
    end, 1)
end

-- Cleanup
local _prevUnload_ft = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevUnload_ft then _prevUnload_ft() end
    pcall(function() FireTrailModule.resetar() end)
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function() FireTrailModule.resetar() end)
    end
end)

print("[VoidStrap] Bloco 5/8 carregado.")--====================================================================
-- MÓDULO: AUTO FOLLOW (núcleo com BodyVelocity)
--====================================================================

Estado.AutoFollow = Estado.AutoFollow or {
    Enabled = false,
    Speed = 22,
    StopDistance = 2.5,
    ReachEnabled = false,
    ReachDistance = 1,
    TargetMode = "Todas",
    AntiStuck = true,
}

Estado.AutoFollowBtn = Estado.AutoFollowBtn or {
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

local BALL_NAMES_AF = {
    "TPS", "ESA", "MRS", "PRS", "MPS",
    "Ball", "Football", "Soccer Ball", "Bola", "SoccerBall"
}

local function ehNomeBolaAF(name)
    for _, n in ipairs(BALL_NAMES_AF) do
        if name == n then return true end
    end
    return false
end

local function buscarTodasBolas()
    local bolas = {}
    local char = LP.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and ehNomeBolaAF(obj.Name) then
            if not (char and obj:IsDescendantOf(char)) then
                table.insert(bolas, obj)
            end
        end
    end
    return bolas
end

local function buscarBolaMaisProxima()
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local maisProxima, menorDist = nil, math.huge
    for _, b in ipairs(buscarTodasBolas()) do
        local d = (b.Position - root.Position).Magnitude
        if d < menorDist then
            menorDist = d
            maisProxima = b
        end
    end
    return maisProxima
end

local function buscarBolaPadrao()
    local bolas = buscarTodasBolas()
    return bolas[1]
end

local function buscarBolaPorModo()
    local modo = Estado.AutoFollow.TargetMode or "Todas"
    if modo == "Mais Próxima" then return buscarBolaMaisProxima() end
    return buscarBolaPadrao()
end

local function limparBodyVel()
    if AF_BodyVel and AF_BodyVel.Parent then
        pcall(function() AF_BodyVel:Destroy() end)
    end
    AF_BodyVel = nil
end

local BotaoFlutuanteAF = nil

local function atualizarVisualBotao()
    if not BotaoFlutuanteAF or not BotaoFlutuanteAF.Parent then return end
    local ativo = Estado.AutoFollow and Estado.AutoFollow.Enabled
    if ativo then
        BotaoFlutuanteAF.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
        BotaoFlutuanteAF.Text = "AF ON"
    else
        BotaoFlutuanteAF.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        BotaoFlutuanteAF.Text = "AF OFF"
    end
end

-- ---------- LOOP PRINCIPAL ----------
local function iniciarAF()
    if AF_Conn then AF_Conn:Disconnect() end

    local ultimaPos = nil
    local framesPreso = 0

    AF_Conn = RunService.Heartbeat:Connect(function(dt)
        if not Estado.AutoFollow.Enabled then
            limparBodyVel()
            return
        end

        local char = LP.Character
        if not char then limparBodyVel() return end

        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then
            limparBodyVel()
            return
        end

        -- Cache da bola a cada 2s
        local agora = tick()
        if not AF_CachedBall or not AF_CachedBall.Parent or (agora - AF_LastSearch) > 2 then
            AF_LastSearch = agora
            AF_CachedBall = buscarBolaPorModo()
        end
        local bola = AF_CachedBall
        if not bola then
            limparBodyVel()
            return
        end

        local alvo = Vector3.new(bola.Position.X, root.Position.Y, bola.Position.Z)
        local distancia = (root.Position - alvo).Magnitude

        -- Chegou perto → desacelera suave
        if distancia < Estado.AutoFollow.StopDistance then
            if AF_BodyVel then
                pcall(function()
                    AF_BodyVel.Velocity = AF_BodyVel.Velocity * 0.5
                end)
                if AF_BodyVel.Velocity.Magnitude < 1 then
                    limparBodyVel()
                end
            end
            framesPreso = 0
            return
        end

        -- Anti-Stuck suave
        if Estado.AutoFollow.AntiStuck then
            if ultimaPos then
                local moveu = (root.Position - ultimaPos).Magnitude
                if moveu < 0.1 then
                    framesPreso = framesPreso + 1
                else
                    framesPreso = 0
                end

                -- ~1s parado → empurra lateral + frontal
                if framesPreso > 60 then
                    framesPreso = 0
                    local dir = (alvo - root.Position).Unit
                    local perp = Vector3.new(-dir.Z, 0, dir.X)
                    local lado = (math.random() > 0.5) and 1 or -1
                    pcall(function()
                        root.CFrame = root.CFrame + (perp * lado * 3 + dir * 2)
                    end)
                end
            end
            ultimaPos = root.Position
        end

        -- BodyVelocity com força HUMANA (não teleporta)
        if not AF_BodyVel or AF_BodyVel.Parent ~= root then
            limparBodyVel()
            AF_BodyVel = Instance.new("BodyVelocity")
            AF_BodyVel.Name = "VST_AutoFollow"
            AF_BodyVel.MaxForce = Vector3.new(4000, 0, 4000)
            AF_BodyVel.P = 800
            AF_BodyVel.Velocity = Vector3.zero
            AF_BodyVel.Parent = root
        end

        local direcao = (alvo - root.Position).Unit
        local velocidade = Estado.AutoFollow.Speed

        pcall(function()
            AF_BodyVel.Velocity = direcao * velocidade
        end)
    end)
end

local function iniciarReach()
    if AF_ReachConn then AF_ReachConn:Disconnect(); AF_ReachConn = nil end
    AF_ReachConn = RunService.Heartbeat:Connect(function()
        if not Estado.AutoFollow.Enabled then return end
        if not Estado.AutoFollow.ReachEnabled then return end
        if Estado.AutoFollow.ReachDistance <= 1 then return end

        local char = LP.Character
        if not char then return end

        local perna = char:FindFirstChild("Right Leg")
            or char:FindFirstChild("Right Lower Leg")
            or char:FindFirstChild("HumanoidRootPart")
        if not perna then return end

        local bola = AF_CachedBall or buscarBolaPorModo()
        if not bola then return end

        local dist = (perna.Position - bola.Position).Magnitude
        local alcanceMax = Estado.AutoFollow.ReachDistance * 1.8

        if dist <= alcanceMax and dist > 1.5 then
            if firetouchinterest then
                pcall(function()
                    firetouchinterest(bola, perna, 0)
                    firetouchinterest(bola, perna, 1)
                end)
            end
        end
    end)
end

-- ---------- API ----------
function AutoFollowModule.ativar(ligado)
    Estado.AutoFollow.Enabled = ligado
    if ligado then
        iniciarAF()
        iniciarReach()
        notificar("Auto Follow ativado", "good")
    else
        limparBodyVel()
        if AF_Conn then AF_Conn:Disconnect(); AF_Conn = nil end
        if AF_ReachConn then AF_ReachConn:Disconnect(); AF_ReachConn = nil end
        notificar("Auto Follow desativado", "bad")
    end
    atualizarVisualBotao()
end

function AutoFollowModule.definirVelocidade(v) Estado.AutoFollow.Speed = v end
function AutoFollowModule.definirDistancia(v) Estado.AutoFollow.StopDistance = v end
function AutoFollowModule.ativarReach(v) Estado.AutoFollow.ReachEnabled = v end
function AutoFollowModule.definirDistanciaReach(v) Estado.AutoFollow.ReachDistance = v end
function AutoFollowModule.ativarAntiStuck(v) Estado.AutoFollow.AntiStuck = v end

function AutoFollowModule.definirModo(modo)
    Estado.AutoFollow.TargetMode = modo
    AF_CachedBall = nil
    AF_LastSearch = 0
    notificar("Alvo: " .. modo, "good")
end

function AutoFollowModule.resetar()
    Estado.AutoFollow.Enabled = false
    limparBodyVel()
    if AF_Conn then AF_Conn:Disconnect(); AF_Conn = nil end
    if AF_ReachConn then AF_ReachConn:Disconnect(); AF_ReachConn = nil end
    AF_CachedBall = nil
    atualizarVisualBotao()
    notificar("Auto Follow resetado", "bad")
end

-- ---------- BOTÃO FLUTUANTE ----------
local AutoFollowBtnModule = {}
local AF_Arrastando = false
local AF_DragStart = nil
local AF_PosInicial = nil
local AF_PressTempo = 0
local AF_PressPos = nil

local function atualizarVisualLock()
    if not BotaoFlutuanteAF or not BotaoFlutuanteAF.Parent then return end
    local iconeLock = BotaoFlutuanteAF:FindFirstChild("VST_LockIcon")
    if Estado.AutoFollowBtn.Locked then
        if not iconeLock then
            criar("TextLabel", {
                Name = "VST_LockIcon",
                Size = UDim2.fromOffset(18, 18),
                Position = UDim2.new(1, -20, 0, 2),
                BackgroundTransparency = 1,
                Text = "L",
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(255, 220, 60),
                ZIndex = 100000,
                Parent = BotaoFlutuanteAF,
            })
        end
    else
        if iconeLock then iconeLock:Destroy() end
    end
end

local function criarBotaoFlutuante()
    if BotaoFlutuanteAF and BotaoFlutuanteAF.Parent then
        BotaoFlutuanteAF.Visible = true
        atualizarVisualLock()
        return
    end

    BotaoFlutuanteAF = criar("TextButton", {
        Name = "VST_AutoFollowBtn",
        Size = UDim2.fromOffset(64, 64),
        Position = Estado.AutoFollowBtn.Position,
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
    canto(32, BotaoFlutuanteAF)
    contorno(TemaAtivo.Accent, 2, 0.3, BotaoFlutuanteAF, 99999)
    atualizarVisualBotao()
    atualizarVisualLock()

    BotaoFlutuanteAF.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            AF_Arrastando = true
            AF_DragStart = input.Position
            AF_PosInicial = BotaoFlutuanteAF.Position
            AF_PressTempo = tick()
            AF_PressPos = input.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not AF_Arrastando then return end
        if Estado.AutoFollowBtn.Locked then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - AF_DragStart
            if math.abs(delta.X) > 8 or math.abs(delta.Y) > 8 then
                BotaoFlutuanteAF.Position = UDim2.new(
                    AF_PosInicial.X.Scale, AF_PosInicial.X.Offset + delta.X,
                    AF_PosInicial.Y.Scale, AF_PosInicial.Y.Offset + delta.Y
                )
                Estado.AutoFollowBtn.Position = BotaoFlutuanteAF.Position
            end
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            AF_Arrastando = false
            if AF_PressPos then
                local deltaFinal = input.Position - AF_PressPos
                local moveu = math.abs(deltaFinal.X) + math.abs(deltaFinal.Y)
                local tempo = tick() - AF_PressTempo
                if moveu < 12 and tempo < 0.5 then
                    AutoFollowModule.ativar(not Estado.AutoFollow.Enabled)
                end
            end
            AF_PressPos = nil
        end
    end)

    BotaoFlutuanteAF.MouseEnter:Connect(function()
        animar(BotaoFlutuanteAF, 0.15, { Size = UDim2.fromOffset(72, 72) })
    end)
    BotaoFlutuanteAF.MouseLeave:Connect(function()
        animar(BotaoFlutuanteAF, 0.15, { Size = UDim2.fromOffset(64, 64) })
    end)
end

function AutoFollowBtnModule.mostrar()
    criarBotaoFlutuante()
    Estado.AutoFollowBtn.Visible = true
    notificar("Botão flutuante criado", "good")
end

function AutoFollowBtnModule.esconder()
    if BotaoFlutuanteAF and BotaoFlutuanteAF.Parent then
        BotaoFlutuanteAF:Destroy()
        BotaoFlutuanteAF = nil
    end
    Estado.AutoFollowBtn.Visible = false
    notificar("Botão flutuante removido", "bad")
end

function AutoFollowBtnModule.alternar()
    if Estado.AutoFollowBtn.Visible then
        AutoFollowBtnModule.esconder()
    else
        AutoFollowBtnModule.mostrar()
    end
end

function AutoFollowBtnModule.travar(locked)
    Estado.AutoFollowBtn.Locked = locked
    if BotaoFlutuanteAF and BotaoFlutuanteAF.Parent then
        Estado.AutoFollowBtn.Position = BotaoFlutuanteAF.Position
    end
    atualizarVisualLock()
    notificar(locked and "Botão travado" or "Botão liberado",
              locked and "good" or "bad")
end

--====================================================================
-- ABA AF AVANÇADO
--====================================================================
criarAba("AF Avançado", "AF+")

do
    local page = Tabs["AF Avançado"].page

    -- ============ SEGUIR BOLA ============
    local sec = section("Seguir Bola")
    sec.Parent = page

    toggleRow(sec, "Ativar Auto Follow", Estado.AutoFollow.Enabled, function(on)
        AutoFollowModule.ativar(on)
    end, 1)

    dropdownRow(sec, "Alvo",
        { "Todas", "Mais Próxima" },
        Estado.AutoFollow.TargetMode,
        function(opt) AutoFollowModule.definirModo(opt) end, 2)

    sliderRow(sec, "Velocidade", 8, 60, Estado.AutoFollow.Speed, function(v)
        AutoFollowModule.definirVelocidade(v)
    end, 3)

    sliderRow(sec, "Distância Parada", 1, 10, Estado.AutoFollow.StopDistance, function(v)
        AutoFollowModule.definirDistancia(v)
    end, 4)

    toggleRow(sec, "Anti-Stuck", Estado.AutoFollow.AntiStuck, function(on)
        AutoFollowModule.ativarAntiStuck(on)
    end, 5)

    -- ============ REACH ============
    local reachSec = section("Reach (Alcance)")
    reachSec.Parent = page

    toggleRow(reachSec, "Ativar Reach", Estado.AutoFollow.ReachEnabled, function(on)
        AutoFollowModule.ativarReach(on)
    end, 1)

    sliderRow(reachSec, "Distância (Studs)", 1, 12, Estado.AutoFollow.ReachDistance, function(v)
        AutoFollowModule.definirDistanciaReach(v)
    end, 2)

    -- ============ BOTÃO FLUTUANTE ============
    local floatSec = section("Botão Flutuante")
    floatSec.Parent = page

    buttonRow(floatSec, "Criar / Remover Botão Flutuante", function()
        AutoFollowBtnModule.alternar()
    end, 1)

    toggleRow(floatSec, "Travar Botão no Lugar", Estado.AutoFollowBtn.Locked, function(on)
        AutoFollowBtnModule.travar(on)
    end, 2)

    -- ============ RESET ============
    local resetSec = section("Restaurar")
    resetSec.Parent = page

    buttonRow(resetSec, "Desativar tudo", function()
        AutoFollowModule.resetar()
        AutoFollowBtnModule.esconder()
    end, 1)
end

-- Cleanup
local _prevUnload_af = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevUnload_af then _prevUnload_af() end
    pcall(function()
        AutoFollowModule.resetar()
        AutoFollowBtnModule.esconder()
    end)
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function()
            AutoFollowModule.resetar()
            AutoFollowBtnModule.esconder()
        end)
    end
end)

print("[VoidStrap] Bloco 6/8 carregado.")
