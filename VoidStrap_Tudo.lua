--[[
    VoidStrap v1.2.0 — Interface redesenhada (estilo Kirtium)
]]

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local Workspace    = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local CoreGui      = game:GetService("CoreGui")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ExecutorInfo = { Name = "Unknown", Mobile = false, HasGethui = false, InStudio = false }
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

local function getSafeGuiParent()
    if ExecutorInfo.HasGethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    return LP:WaitForChild("PlayerGui")
end
local GuiParent = getSafeGuiParent()

local VERSION = "v1.2.0"
local TITLE   = "VoidStrap"

-- ---------- TEMA ----------
local Themes = {
    Void = {
        Background = Color3.fromRGB(15, 15, 18),
        Surface    = Color3.fromRGB(25, 25, 30),
        Surface2   = Color3.fromRGB(35, 35, 42),
        Accent     = Color3.fromRGB(140, 100, 255),
        AccentDim  = Color3.fromRGB(80, 55, 160),
        Text       = Color3.fromRGB(240, 240, 245),
        Sub        = Color3.fromRGB(150, 150, 165),
        Stroke     = Color3.fromRGB(50, 50, 60),
        Good       = Color3.fromRGB(80, 200, 130),  -- verde do toggle
        Bad        = Color3.fromRGB(220, 80, 80),
    },
    Kirtium = {
        Background = Color3.fromRGB(12, 12, 15),
        Surface    = Color3.fromRGB(22, 22, 26),
        Surface2   = Color3.fromRGB(32, 32, 38),
        Accent     = Color3.fromRGB(80, 220, 130),  -- verde
        AccentDim  = Color3.fromRGB(40, 130, 70),
        Text       = Color3.fromRGB(245, 245, 250),
        Sub        = Color3.fromRGB(150, 155, 165),
        Stroke     = Color3.fromRGB(48, 48, 55),
        Good       = Color3.fromRGB(80, 220, 130),
        Bad        = Color3.fromRGB(230, 90, 90),
    },
    Midnight = {
        Background = Color3.fromRGB(8, 12, 20),
        Surface    = Color3.fromRGB(14, 20, 32),
        Surface2   = Color3.fromRGB(22, 30, 46),
        Accent     = Color3.fromRGB(80, 160, 255),
        AccentDim  = Color3.fromRGB(40, 90, 160),
        Text       = Color3.fromRGB(230, 240, 255),
        Sub        = Color3.fromRGB(130, 150, 180),
        Stroke     = Color3.fromRGB(30, 44, 66),
        Good       = Color3.fromRGB(80, 220, 160),
        Bad        = Color3.fromRGB(230, 90, 100),
    },
}
local ActiveTheme = Themes.Kirtium

local State = {
    Settings = { AnimationsEnabled = true, SoundsEnabled = true, ThemeName = "Kirtium" },
    Window = { Minimized = false },
    Skybox = { Enabled = false, Current = "Default" },
    Stretch = { Enabled = false, Intensity = 0, BaseFOV = 70 },
    Flags = { Enabled = false, Preset = "Balanced" },
}

local Originals = { Instances = {} }

local function track(inst, prop)
    Originals.Instances[inst] = Originals.Instances[inst] or {}
    if Originals.Instances[inst][prop] == nil then
        Originals.Instances[inst][prop] = inst[prop]
    end
end

local function restoreInstance(inst)
    local data = Originals.Instances[inst]
    if not data then return end
    for prop, value in pairs(data) do
        pcall(function() inst[prop] = value end)
    end
end

local function restoreAll()
    for inst in pairs(Originals.Instances) do
        restoreInstance(inst)
    end
    Originals.Instances = {}
end

local function create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function corner(radius, parent)
    return create("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

local function stroke(color, thickness, transparency, parent)
    return create("UIStroke", {
        Color = color or Color3.new(1, 1, 1),
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function padding(px, parent)
    return create("UIPadding", {
        PaddingTop    = UDim.new(0, px),
        PaddingBottom = UDim.new(0, px),
        PaddingLeft   = UDim.new(0, px),
        PaddingRight  = UDim.new(0, px),
        Parent = parent,
    })
end

local function gradient(c1, c2, rot, parent)
    return create("UIGradient", {
        Color = ColorSequence.new(c1, c2),
        Rotation = rot or 90,
        Parent = parent,
    })
end

local function tween(inst, time, props, style, dir)
    if not State.Settings.AnimationsEnabled then
        for k, v in pairs(props) do inst[k] = v end
        return nil
    end
    local t = TweenService:Create(inst,
        TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props)
    t:Play()
    return t
end

local ClickSound = create("Sound", {
    SoundId = "rbxasset://sounds/electronicpingshort.wav",
    Volume = 0.35,
    Parent = SoundService,
})

local function playClick()
    if not State.Settings.SoundsEnabled then return end
    pcall(function() ClickSound:Play() end)
end

local ThemedElements = {}

local function themed(inst, prop, themeKey)
    table.insert(ThemedElements, { inst = inst, prop = prop, key = themeKey })
    inst[prop] = ActiveTheme[themeKey]
    return inst
end

local function applyTheme(themeName)
    local theme = Themes[themeName] or Themes.Kirtium
    ActiveTheme = theme
    for _, e in ipairs(ThemedElements) do
        local v = theme[e.key]
        if v then e.inst[e.prop] = v end
    end
end

local NotifyHolder

local function notify(text, kind)
    kind = kind or "info"
    if not NotifyHolder then return end

    local color = ActiveTheme.Accent
    if kind == "good" then color = ActiveTheme.Good end
    if kind == "bad"  then color = ActiveTheme.Bad  end

    local frame = create("Frame", {
        Size = UDim2.fromOffset(280, 44),
        BackgroundColor3 = ActiveTheme.Surface,
        BorderSizePixel = 0,
        Parent = NotifyHolder,
    })
    corner(8, frame)
    stroke(ActiveTheme.Stroke, 1, 0.2, frame)

    create("Frame", {
        Size = UDim2.new(0, 3, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = frame,
    })

    create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = ActiveTheme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    frame.Position = UDim2.new(1, 0, 0, 0)
    tween(frame, 0.35, { Position = UDim2.new(0, 0, 0, 0) })

    task.delay(3, function()
        local out = tween(frame, 0.25, { Position = UDim2.new(1, 0, 0, 0) })
        if out then
            out.Completed:Connect(function() frame:Destroy() end)
        else
            frame:Destroy()
        end
    end)
end

-- ---------- SCREEN GUI ----------
local ScreenGui = create("ScreenGui", {
    Name = "VoidStrapGui_" .. tostring(math.random(1000, 9999)),
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999999,
    Parent = GuiParent,
})

local ScreenOverlay = create("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Parent = ScreenGui,
})

-- JANELA PRINCIPAL
local Main = create("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(640, 440),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(8, 8, 10),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = ScreenOverlay,
})
corner(14, Main)

-- Fundo com imagem (opcional, com blur-like)
local MainBgImage = create("ImageLabel", {
    Name = "VST_MainBg",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Image = "",
    ImageTransparency = 0.4,
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 0,
    Visible = false,
    Parent = Main,
})
corner(14, MainBgImage)

-- Overlay escuro por cima da imagem pra deixar legível
local MainOverlay = create("Frame", {
    Name = "VST_MainOverlay",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(8, 8, 12),
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
    ZIndex = 1,
    Parent = Main,
})
corner(14, MainOverlay)

stroke(ActiveTheme.Stroke, 1, 0.4, Main)

-- TOPBAR
local TopBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 52),
    BackgroundColor3 = Color3.fromRGB(12, 12, 15),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    ZIndex = 5,
    Parent = Main,
})
corner(14, TopBar)

-- Logo pequena
local Logo = create("Frame", {
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.new(0, 16, 0, 12),
    BackgroundColor3 = ActiveTheme.Accent,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 6,
    Parent = TopBar,
})
corner(8, Logo)

local LogoImage = create("ImageLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Image = "rbxassetid://99887975337982",
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 6,
    Parent = Logo,
})
corner(8, LogoImage)

-- Título
local TitleLabel = create("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 54, 0, 0),
    BackgroundTransparency = 1,
    Text = TITLE,
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = ActiveTheme.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 6,
    Parent = TopBar,
})
themed(TitleLabel, "TextColor3", "Text")

-- Badge de versão (estilo Kirtium)
local VersionBadge = create("Frame", {
    Size = UDim2.fromOffset(70, 24),
    Position = UDim2.new(0, 170, 0.5, -12),
    BackgroundColor3 = Color3.fromRGB(25, 25, 30),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    ZIndex = 6,
    Parent = TopBar,
})
corner(6, VersionBadge)
stroke(ActiveTheme.Stroke, 1, 0.3, VersionBadge)

local VersionLabel = create("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = VERSION,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = ActiveTheme.Text,
    ZIndex = 7,
    Parent = VersionBadge,
})
themed(VersionLabel, "TextColor3", "Text")

-- Botões da topbar (minimizar, fechar)
local function topbarButton(iconText, offsetRight)
    local btn = create("TextButton", {
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.new(1, offsetRight, 0, 10),
        BackgroundColor3 = Color3.fromRGB(30, 30, 36),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = iconText,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = ActiveTheme.Sub,
        AutoButtonColor = false,
        ZIndex = 6,
        Parent = TopBar,
    })
    themed(btn, "TextColor3", "Sub")
    corner(8, btn)
    btn.MouseEnter:Connect(function()
        tween(btn, 0.15, { BackgroundColor3 = Color3.fromRGB(45, 45, 55), BackgroundTransparency = 0 })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.15, { BackgroundColor3 = Color3.fromRGB(30, 30, 36), BackgroundTransparency = 0.3 })
    end)
    return btn
end

local CloseBtn    = topbarButton("X", -44)
local MinimizeBtn = topbarButton("_", -82)

-- SIDEBAR
local Sidebar = create("ScrollingFrame", {
    Size = UDim2.new(0, 150, 1, -52),
    Position = UDim2.new(0, 0, 0, 52),
    BackgroundColor3 = Color3.fromRGB(12, 12, 15),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = ActiveTheme.Accent,
    ScrollBarImageTransparency = 0.4,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ScrollingEnabled = true,
    ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
    ClipsDescendants = true,
    ZIndex = 5,
    Parent = Main,
})
padding(10, Sidebar)
create("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = Sidebar,
})

-- CONTENT
local Content = create("Frame", {
    Size = UDim2.new(1, -150, 1, -52),
    Position = UDim2.new(0, 150, 0, 52),
    BackgroundColor3 = Color3.fromRGB(10, 10, 14),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 5,
    Parent = Main,
})
padding(14, Content)

print("[VoidStrap] Parte 1 (Kirtium style) OK")--====================================================================
-- PARTE 2 — ABAS + COMPONENTES (estilo Kirtium)
--====================================================================

local Tabs = {}
local CurrentTab = nil

function selectTab(name)
    for n, tab in pairs(Tabs) do
        local isActive = (n == name)
        tab.page.Visible = isActive
        tween(tab.button, 0.2, {
            BackgroundColor3 = isActive and Color3.fromRGB(35, 35, 42) or Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = isActive and 0.3 or 1,
        })
        tween(tab.txt, 0.2, {
            TextColor3 = isActive and ActiveTheme.Text or ActiveTheme.Sub,
        })
        tab.accentBar.Visible = isActive
    end
    CurrentTab = name
end

local function createTab(name, iconText)
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = Sidebar,
    })
    corner(8, btn)

    -- ícone (texto pequeno à esquerda)
    local icon = create("TextLabel", {
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = iconText,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = ActiveTheme.Sub,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = btn,
    })
    themed(icon, "TextColor3", "Sub")

    local txt = create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 38, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = ActiveTheme.Sub,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
    })
    themed(txt, "TextColor3", "Sub")

    local accentBar = create("Frame", {
        Size = UDim2.new(0, 3, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = ActiveTheme.Accent,
        BorderSizePixel = 0,
        Visible = false,
        Parent = btn,
    })
    corner(2, accentBar)

    local page = create("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = ActiveTheme.Accent,
        ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollingEnabled = true,
        ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
        ClipsDescendants = true,
        Visible = false,
        Parent = Content,
    })
    create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })
    create("UIPadding", {
        PaddingTop    = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft   = UDim.new(0, 2),
        PaddingRight  = UDim.new(0, 2),
        Parent = page,
    })

    Tabs[name] = { button = btn, page = page, accentBar = accentBar, txt = txt, icon = icon }

    btn.MouseButton1Click:Connect(function()
        playClick()
        selectTab(name)
    end)
    btn.MouseEnter:Connect(function()
        if CurrentTab ~= name then
            tween(btn, 0.15, { BackgroundColor3 = Color3.fromRGB(25, 25, 30), BackgroundTransparency = 0.5 })
        end
    end)
    btn.MouseLeave:Connect(function()
        if CurrentTab ~= name then
            tween(btn, 0.15, { BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1 })
        end
    end)
end

-- SECTION
local function section(title)
    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
    })
    corner(12, frame)
    stroke(ActiveTheme.Stroke, 1, 0.6, frame)
    padding(14, frame)
    create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = frame,
    })
    local lbl = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = ActiveTheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0,
        Parent = frame,
    })
    themed(lbl, "TextColor3", "Text")
    return frame
end

-- BUTTON ROW
local function buttonRow(parent, label, onClick, order)
    local row = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order or 0,
        Parent = parent,
    })
    corner(8, row)

    local lbl = create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = ActiveTheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    themed(lbl, "TextColor3", "Text")

    local badge = create("TextLabel", {
        Size = UDim2.fromOffset(56, 22),
        Position = UDim2.new(1, -64, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = ActiveTheme.Accent,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Text = "Aplicar",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Color3.new(1, 1, 1),
        Parent = row,
    })
    corner(6, badge)

    row.MouseEnter:Connect(function()
        tween(row, 0.15, { BackgroundColor3 = Color3.fromRGB(38, 38, 46), BackgroundTransparency = 0.3 })
    end)
    row.MouseLeave:Connect(function()
        tween(row, 0.15, { BackgroundColor3 = Color3.fromRGB(28, 28, 34), BackgroundTransparency = 0.4 })
    end)
    row.MouseButton1Click:Connect(function()
        playClick()
        if onClick then onClick(badge) end
    end)
    return row, badge
end

-- TOGGLE ROW (verde estilo Kirtium)
local function toggleRow(parent, label, initial, onChange, order)
    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        LayoutOrder = order or 0,
        Parent = parent,
    })
    corner(8, row)

    local lbl = create("TextLabel", {
        Size = UDim2.new(1, -100, 0, 22),
        Position = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = ActiveTheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    themed(lbl, "TextColor3", "Text")

    -- subtítulo do Kirtium (opcional)
    local sub = create("TextLabel", {
        Size = UDim2.new(1, -100, 0, 14),
        Position = UDim2.new(0, 14, 0, 26),
        BackgroundTransparency = 1,
        Text = "Ativa/desativa essa função",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = ActiveTheme.Sub,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    themed(sub, "TextColor3", "Sub")

    -- Toggle track (verde quando ativo)
    local track = create("Frame", {
        Size = UDim2.fromOffset(46, 26),
        Position = UDim2.new(1, -60, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(60, 60, 70),
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(13, track)

    local knob = create("Frame", {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(10, knob)

    local state = initial and true or false
    local function render(animated)
        local targetX = state and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        local targetColor = state and Color3.fromRGB(80, 220, 130) or Color3.fromRGB(60, 60, 70)
        if animated then
            tween(knob, 0.2, { Position = targetX })
            tween(track, 0.2, { BackgroundColor3 = targetColor })
        else
            knob.Position = targetX
            track.BackgroundColor3 = targetColor
        end
    end
    render(false)

    local function set(newState)
        state = newState and true or false
        render(true)
        if onChange then onChange(state) end
    end

    local btn = create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        Parent = row,
    })
    btn.MouseButton1Click:Connect(function()
        playClick()
        set(not state)
    end)

    return row, set, function() return state end
end

-- SLIDER ROW
local function sliderRow(parent, label, minV, maxV, initial, onChange, order)
    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        LayoutOrder = order or 0,
        Parent = parent,
    })
    corner(8, row)

    local lbl = create("TextLabel", {
        Size = UDim2.new(1, -80, 0, 22),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = ActiveTheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    themed(lbl, "TextColor3", "Text")

    local valueLabel = create("TextLabel", {
        Size = UDim2.fromOffset(60, 22),
        Position = UDim2.new(1, -72, 0, 8),
        BackgroundTransparency = 1,
        Text = tostring(initial),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = ActiveTheme.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })
    themed(valueLabel, "TextColor3", "Accent")

    local track = create("Frame", {
        Size = UDim2.new(1, -28, 0, 6),
        Position = UDim2.new(0, 14, 0, 42),
        BackgroundColor3 = Color3.fromRGB(60, 60, 70),
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(3, track)

    local fill = create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = ActiveTheme.Accent,
        BorderSizePixel = 0,
        Parent = track,
    })
    themed(fill, "BackgroundColor3", "Accent")
    corner(3, fill)

    local handle = create("Frame", {
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(9, handle)

    local value = initial
    local dragging = false

    local function updateFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.floor(minV + (maxV - minV) * rel + 0.5)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        handle.Position = UDim2.new(rel, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        if onChange then onChange(value) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    task.defer(function()
        local rel = (initial - minV) / (maxV - minV)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        handle.Position = UDim2.new(rel, 0, 0.5, 0)
    end)

    return row, function() return value end
end

-- DROPDOWN ROW
local function dropdownRow(parent, label, options, initial, onChange, order)
    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        LayoutOrder = order or 0,
        Parent = parent,
        ClipsDescendants = false,
    })
    corner(8, row)

    local lbl = create("TextLabel", {
        Size = UDim2.new(1, -160, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = ActiveTheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    themed(lbl, "TextColor3", "Text")

    local selected = create("TextButton", {
        Size = UDim2.fromOffset(120, 30),
        Position = UDim2.new(1, -134, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = initial,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = ActiveTheme.Text,
        AutoButtonColor = false,
        Parent = row,
    })
    themed(selected, "TextColor3", "Text")
    corner(6, selected)

    local list = create("Frame", {
        Size = UDim2.new(0, 120, 0, #options * 28 + 10),
        Position = UDim2.new(1, -134, 1, 4),
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 5,
        Parent = row,
    })
    corner(6, list)
    stroke(ActiveTheme.Stroke, 1, 0.3, list)
    create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = list,
    })
    padding(4, list)

    for i, opt in ipairs(options) do
        local o = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = Color3.fromRGB(28, 28, 34),
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Text = opt,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = ActiveTheme.Text,
            AutoButtonColor = false,
            LayoutOrder = i,
            Parent = list,
        })
        corner(4, o)
        o.MouseEnter:Connect(function()
            tween(o, 0.12, { BackgroundColor3 = Color3.fromRGB(45, 45, 55), BackgroundTransparency = 0 })
        end)
        o.MouseLeave:Connect(function()
            tween(o, 0.12, { BackgroundColor3 = Color3.fromRGB(28, 28, 34), BackgroundTransparency = 0.3 })
        end)
        o.MouseButton1Click:Connect(function()
            playClick()
            selected.Text = opt
            list.Visible = false
            if onChange then onChange(opt) end
        end)
    end

    selected.MouseButton1Click:Connect(function()
        playClick()
        list.Visible = not list.Visible
    end)

    return row
end

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

print("[VoidStrap] Parte 2 (Kirtium style) OK")--====================================================================
-- PARTE 3A — MÓDULOS (Skybox / Stretch / Grass / Flags)
--====================================================================

local SkyboxModule = {}
local OriginalLighting = nil

local function captureLighting()
    if OriginalLighting then return end
    OriginalLighting = {
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
    Night = {
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
    Space = {
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
    Red = {
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
    Purple = {
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
    Custom = {
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

local SAFE_ORDER = {
    "FogColor", "FogStart", "FogEnd",
    "ColorShift_Top", "ColorShift_Bottom",
    "Ambient", "OutdoorAmbient",
    "Brightness", "ClockTime",
}

local function applySkyboxPreset(name)
    captureLighting()
    if name == "Default" then
        SkyboxModule.restore()
        return
    end
    local p = SKY_PRESETS[name]
    if not p then return end
    for _, key in ipairs(SAFE_ORDER) do
        if p[key] ~= nil then
            pcall(function() Lighting[key] = p[key] end)
        end
    end
end

function SkyboxModule.apply(name)
    State.Skybox.Current = name
    if State.Skybox.Enabled then
        applySkyboxPreset(name)
    end
    notify("Skybox: " .. name, "good")
end

function SkyboxModule.restore()
    if not OriginalLighting then return end
    for k, v in pairs(OriginalLighting) do
        pcall(function() Lighting[k] = v end)
    end
end

function SkyboxModule.setEnabled(on)
    State.Skybox.Enabled = on
    if on then
        applySkyboxPreset(State.Skybox.Current)
        notify("Skybox ativado", "good")
    else
        SkyboxModule.restore()
        notify("Skybox desativado", "bad")
    end
end

local StretchModule = {}
local FOV_JITTER = 0

function StretchModule.apply()
    if not Camera then return end
    if not State.Stretch.Enabled or State.Stretch.Intensity == 0 then
        pcall(function() Camera.FieldOfView = State.Stretch.BaseFOV end)
        return
    end
    local extra = (State.Stretch.Intensity / 100) * 50
    FOV_JITTER = (math.random() - 0.5) * 1.0
    pcall(function()
        Camera.FieldOfView = State.Stretch.BaseFOV + extra + FOV_JITTER
    end)
end

function StretchModule.setEnabled(on)
    State.Stretch.Enabled = on
    StretchModule.apply()
    notify(on and "Stretch ativado" or "Stretch desativado", on and "good" or "bad")
end

function StretchModule.setIntensity(v)
    State.Stretch.Intensity = v
    StretchModule.apply()
end

function StretchModule.reset()
    State.Stretch.Enabled = false
    State.Stretch.Intensity = 0
    if Camera then
        pcall(function() Camera.FieldOfView = State.Stretch.BaseFOV end)
    end
end

local GrassModule = {}
local OriginalGrassColor = nil
local RecoloredParts = {}

local function isGrassPart(part)
    if not part:IsA("BasePart") then return false end
    local mat = part.Material
    if mat == Enum.Material.Grass or mat == Enum.Material.LeafyGrass then return true end
    local c = part.Color
    local isGreen = c.G > 0.45 and c.R < 0.45 and c.B < 0.45
    local isBig = part.Size.X >= 30 and part.Size.Z >= 30
    return isGreen and isBig
end

local function shouldSkip(part)
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

local function captureGrass()
    if OriginalGrassColor then return end
    local ok, color = pcall(function()
        return Workspace.Terrain:GetMaterialColor(Enum.Material.Grass)
    end)
    OriginalGrassColor = (ok and color) or Color3.fromRGB(91, 154, 76)
end

function GrassModule.setColor(color)
    captureGrass()
    pcall(function()
        Workspace.Terrain:SetMaterialColor(Enum.Material.Grass, color)
        Workspace.Terrain:SetMaterialColor(Enum.Material.LeafyGrass, color)
    end)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isGrassPart(obj) and not shouldSkip(obj) then
            if RecoloredParts[obj] == nil then
                RecoloredParts[obj] = obj.Color
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

function GrassModule.restore()
    if OriginalGrassColor then
        pcall(function()
            Workspace.Terrain:SetMaterialColor(Enum.Material.Grass, OriginalGrassColor)
            Workspace.Terrain:SetMaterialColor(Enum.Material.LeafyGrass, OriginalGrassColor)
        end)
    end
    for part, original in pairs(RecoloredParts) do
        pcall(function()
            if part and part.Parent then part.Color = original end
        end)
    end
    RecoloredParts = {}
end

local GRASS_PRESETS = {
    ["Verde Padrao"]=Color3.fromRGB(91,154,76), ["Verde Escuro"]=Color3.fromRGB(45,90,40),
    ["Verde Neon"]=Color3.fromRGB(80,255,120), ["Verde Agua"]=Color3.fromRGB(120,220,180),
    ["Azul"]=Color3.fromRGB(60,130,220), ["Roxo"]=Color3.fromRGB(120,70,200),
    ["Vermelho"]=Color3.fromRGB(200,60,60), ["Rosa"]=Color3.fromRGB(240,130,200),
    ["Amarelo"]=Color3.fromRGB(230,210,70), ["Cinza"]=Color3.fromRGB(120,120,125),
    ["Branco"]=Color3.fromRGB(240,240,245), ["Preto"]=Color3.fromRGB(25,25,28),
    ["Gelo"]=Color3.fromRGB(190,220,255),
}

function GrassModule.applyPreset(name)
    local color = GRASS_PRESETS[name]
    if not color then return end
    GrassModule.setColor(color)
    notify("Grama: " .. name, "good")
end

function GrassModule.reset()
    GrassModule.restore()
    notify("Grama restaurada", "bad")
end

local FlagsModule = {}

local PRESETS = {
    Ultra       = { particles = false, shadows = false, lighting = false },
    Balanced    = { particles = true,  shadows = true,  lighting = false },
    Performance = { particles = true,  shadows = true,  lighting = true  },
    Potato      = { particles = true,  shadows = true,  lighting = true  },
}

function FlagsModule.applyPreset(preset)
    if not State.Flags.Enabled then return end
    local c = PRESETS[preset] or PRESETS.Balanced
    local char = LP.Character

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if char and obj:IsDescendantOf(char) then continue end
        if c.particles and (
            obj:IsA("ParticleEmitter") or obj:IsA("Trail") or
            obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")
        ) then
            track(obj, "Enabled")
            pcall(function() obj.Enabled = false end)
        end
        if c.shadows and obj:IsA("BasePart") then
            track(obj, "CastShadow")
            pcall(function() obj.CastShadow = false end)
        end
    end

    if c.lighting then
        track(Lighting, "GlobalShadows")
        track(Lighting, "EnvironmentDiffuseScale")
        track(Lighting, "EnvironmentSpecularScale")
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
        end)
    end

    if preset == "Potato" then
        track(Lighting, "Brightness")
        pcall(function()
            Lighting.Brightness = math.min(Lighting.Brightness, 0.5)
        end)
    end
end

function FlagsModule.setEnabled(on)
    State.Flags.Enabled = on
    if on then
        FlagsModule.applyPreset(State.Flags.Preset)
        notify("Flags ativadas: " .. State.Flags.Preset, "good")
    else
        restoreAll()
        notify("Flags desativadas", "bad")
    end
end

function FlagsModule.setPreset(preset)
    State.Flags.Preset = preset
    if State.Flags.Enabled then
        restoreAll()
        FlagsModule.applyPreset(preset)
        notify("Preset: " .. preset, "good")
    end
end

print("[VoidStrap] Parte 3A OK")--====================================================================
-- PARTE 3B — MONTAGEM DAS ABAS + BOOT + CLEANUP
--====================================================================

createTab("Skybox",      "SKY")
createTab("Stretch",     "STR")
createTab("Grass",       "GRS")
createTab("Performance", "PRF")
createTab("Settings",    "CFG")

-- ABA SKYBOX
do
    local page = Tabs["Skybox"].page
    local mainSec = section("Skybox Local")
    mainSec.Parent = page
    toggleRow(mainSec, "Ativar Skybox", State.Skybox.Enabled, function(on)
        SkyboxModule.setEnabled(on)
    end, 1)
    for i, name in ipairs({ "Default", "Night", "Space", "Red", "Purple", "Custom" }) do
        buttonRow(mainSec, "• " .. name, function()
            SkyboxModule.apply(name)
        end, 10 + i)
    end
    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Restaurar Skybox original", function()
        SkyboxModule.restore()
        notify("Skybox restaurado", "good")
    end, 1)
end

-- ABA STRETCH
do
    local page = Tabs["Stretch"].page
    local sec = section("Stretch Screen (FOV)")
    sec.Parent = page
    toggleRow(sec, "Ativar Stretch", State.Stretch.Enabled, function(on)
        StretchModule.setEnabled(on)
    end, 1)
    sliderRow(sec, "Intensidade", 0, 100, State.Stretch.Intensity, function(v)
        StretchModule.setIntensity(v)
    end, 2)
    local resetSec = section("Reset")
    resetSec.Parent = page
    buttonRow(resetSec, "Resetar Stretch", function()
        StretchModule.reset()
        notify("Stretch resetado", "good")
    end, 1)
end

-- ABA GRASS
do
    local page = Tabs["Grass"].page
    local mainSec = section("Cor da Grama")
    mainSec.Parent = page
    local presets = {
        "Verde Padrao", "Verde Escuro", "Verde Neon", "Verde Agua",
        "Azul", "Roxo", "Vermelho", "Rosa",
        "Amarelo", "Cinza", "Branco", "Preto", "Gelo",
    }
    for i, name in ipairs(presets) do
        buttonRow(mainSec, name, function()
            GrassModule.applyPreset(name)
        end, 10 + i)
    end
    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Restaurar cor original", function()
        GrassModule.reset()
    end, 1)
end

-- ABA PERFORMANCE
do
    local page = Tabs["Performance"].page
    local sec = section("Flags de Performance")
    sec.Parent = page
    toggleRow(sec, "Ativar Flags", State.Flags.Enabled, function(on)
        FlagsModule.setEnabled(on)
    end, 1)
    dropdownRow(sec, "Preset",
        { "Ultra", "Balanced", "Performance", "Potato" },
        State.Flags.Preset,
        function(opt) FlagsModule.setPreset(opt) end, 2)
    local fpsSec = section("Monitor")
    fpsSec.Parent = page
    local fpsRow = create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = ActiveTheme.Surface2,
        BorderSizePixel = 0, LayoutOrder = 1, Parent = fpsSec,
    })
    themed(fpsRow, "BackgroundColor3", "Surface2")
    corner(8, fpsRow)
    local fpsLbl = create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = "FPS atual",
        Font = Enum.Font.GothamMedium, TextSize = 13,
        TextColor3 = ActiveTheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = fpsRow,
    })
    themed(fpsLbl, "TextColor3", "Text")
    FPSLabel = create("TextLabel", {
        Size = UDim2.fromOffset(80, 22), Position = UDim2.new(1, -92, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = ActiveTheme.Accent, BorderSizePixel = 0,
        Text = "— FPS", Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = Color3.new(1, 1, 1), Parent = fpsRow,
    })
    themed(FPSLabel, "BackgroundColor3", "Accent")
    corner(6, FPSLabel)
end

-- ABA SETTINGS
do
    local page = Tabs["Settings"].page
    local sec = section("Interface")
    sec.Parent = page
    toggleRow(sec, "Animacoes da UI", State.Settings.AnimationsEnabled, function(on)
        State.Settings.AnimationsEnabled = on
        notify(on and "Animacoes ativadas" or "Animacoes desativadas", on and "good" or "bad")
    end, 1)
    toggleRow(sec, "Sons da UI", State.Settings.SoundsEnabled, function(on)
        State.Settings.SoundsEnabled = on
        notify(on and "Sons ativados" or "Sons desativados", on and "good" or "bad")
    end, 2)
    local themeSec = section("Tema")
    themeSec.Parent = page
    dropdownRow(themeSec, "Tema",
        { "Void", "Midnight", "Ember" },
        State.Settings.ThemeName,
        function(opt)
            State.Settings.ThemeName = opt
            applyTheme(opt)
            notify("Tema: " .. opt, "good")
        end, 1)
    local resetSec = section("Reset")
    resetSec.Parent = page
    buttonRow(resetSec, "Resetar configuracoes", function()
        SkyboxModule.restore()
        State.Skybox.Enabled = false
        State.Skybox.Current = "Default"
        StretchModule.reset()
        GrassModule.restore()
        restoreAll()
        State.Flags.Enabled = false
        State.Flags.Preset = "Balanced"
        State.Settings.AnimationsEnabled = true
        State.Settings.SoundsEnabled = true
        State.Settings.ThemeName = "Void"
        applyTheme("Void")
        notify("Configuracoes resetadas", "good")
    end, 1)
end

-- MINIMIZE / CLOSE / MINI BUTTON
local MiniButton

local function setMinimized(minimized)
    State.Window.Minimized = minimized
    if minimized then
        tween(Main, 0.25, { Size = UDim2.fromOffset(0, 0) })
        task.delay(0.25, function()
            Main.Visible = false
            if MiniButton then MiniButton.Visible = true end
        end)
    else
        Main.Visible = true
        if MiniButton then MiniButton.Visible = false end
        local vp = Camera.ViewportSize
        local w = math.min(620, vp.X - 40)
        local h = math.min(420, vp.Y - 80)
        tween(Main, 0.25, { Size = UDim2.fromOffset(w, h) })
    end
end

MinimizeBtn.MouseButton1Click:Connect(function()
    playClick()
    setMinimized(true)
end)

CloseBtn.MouseButton1Click:Connect(function()
    playClick()
    setMinimized(true)
end)

do
    MiniButton = create("TextButton", {
        Size = UDim2.fromOffset(52, 52),
        Position = UDim2.new(0, 20, 0.5, -26),
        BackgroundColor3 = ActiveTheme.Accent,
        BorderSizePixel = 0, Text = "V",
        Font = Enum.Font.GothamBold, TextSize = 20,
        TextColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = false, Visible = false,
        Parent = ScreenOverlay,
    })
    themed(MiniButton, "BackgroundColor3", "Accent")
    corner(26, MiniButton)
    stroke(ActiveTheme.Stroke, 1, 0.4, MiniButton)
    gradient(ActiveTheme.Accent, ActiveTheme.AccentDim, 45, MiniButton)

    MiniButton.MouseButton1Click:Connect(function()
        playClick()
        setMinimized(false)
    end)

    local dragging, dragStart, startPos
    MiniButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MiniButton.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MiniButton.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ARRASTAR JANELA
do
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

NotifyHolder = create("Frame", {
    Size = UDim2.fromOffset(300, 240),
    Position = UDim2.new(1, -320, 1, -260),
    BackgroundTransparency = 1,
    Parent = ScreenOverlay,
})
create("UIListLayout", {
    Padding = UDim.new(0, 8),
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = NotifyHolder,
})

local function applyResponsive()
    if State.Window.Minimized then return end
    local vp = Camera.ViewportSize
    local w = math.min(620, vp.X - 40)
    local h = math.min(420, vp.Y - 80)
    Main.Size = UDim2.fromOffset(w, h)
end

applyResponsive()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsive)

do
    local vp = Camera.ViewportSize
    local w = math.min(620, vp.X - 40)
    local h = math.min(420, vp.Y - 80)
    Main.Size = UDim2.fromOffset(0, 0)
    task.spawn(function()
        task.wait(0.15)
        tween(Main, 0.35, { Size = UDim2.fromOffset(w, h) },
            Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
end

selectTab("Skybox")
applyTheme(State.Settings.ThemeName)
notify(TITLE .. " " .. VERSION .. " carregado", "good")

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function()
            SkyboxModule.restore()
            StretchModule.reset()
            GrassModule.restore()
            restoreAll()
        end)
    end
end)

_G.VoidStrapUnload = function()
    pcall(function()
        SkyboxModule.restore()
        StretchModule.reset()
        GrassModule.restore()
        restoreAll()
    end)
    if ScreenGui then ScreenGui:Destroy() end
    if ClickSound then ClickSound:Destroy() end
    ThemedElements = {}
    Originals.Instances = {}
    RecoloredParts = {}
    print("[VoidStrap] Unloaded.")
end

print("[VoidStrap] Parte 3B OK")
print(("[VoidStrap] %s inicializado com sucesso."):format(VERSION))--====================================================================
-- PARTE 4 — ILUMINAÇÃO (ClockTime 1-30)
--====================================================================

State.Lighting = State.Lighting or { Enabled = true, Hour = 12 }

local LightingModule = {}
local OriginalClockTime = nil

local function captureClock()
    if OriginalClockTime then return end
    OriginalClockTime = Lighting.ClockTime
end

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

createTab("Lighting", "LGT")

do
    local page = Tabs["Lighting"].page
    local sec = section("Iluminacao")
    sec.Parent = page

    toggleRow(sec, "Ativar Iluminacao", State.Lighting.Enabled, function(on)
        State.Lighting.Enabled = on
        if on then
            LightingModule.setHour(State.Lighting.Hour)
            notify("Iluminacao ativada", "good")
        else
            LightingModule.restore()
            notify("Iluminacao desativada", "bad")
        end
    end, 1)

    sliderRow(sec, "Hora (1-30)", 1, 30, State.Lighting.Hour, function(v)
        State.Lighting.Hour = v
        if State.Lighting.Enabled then
            LightingModule.setHour(v)
        end
    end, 2)

    local resetSec = section("Restaurar")
    resetSec.Parent = page
    buttonRow(resetSec, "Restaurar iluminacao original", function()
        LightingModule.restore()
        notify("Iluminacao restaurada", "good")
    end, 1)
end

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

print("[VoidStrap] Parte 4 OK")--====================================================================
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
-- PARTE 6.1 — AUTO FOLLOW (NÚCLEO)
--====================================================================

State.AutoFollow = State.AutoFollow or {
    Enabled = false,
    Speed = 16,
    StopDistance = 2.2,
    ReachEnabled = false,
    ReachDistance = 1,
    PauseOnLock = true,
    TouchToEnable = true,
    TargetMode = "Todas",
}

State.AutoFollowBtn = State.AutoFollowBtn or {
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
local AF_LockedByMe = false
local AF_TouchConn = nil
local AF_TouchDebounce = 0

local BALL_NAMES = {
    "TPS", "ESA", "MRS", "PRS", "MPS",
    "Ball", "Football", "Soccer Ball", "Bola", "SoccerBall"
}

local function isBallName(name)
    for _, n in ipairs(BALL_NAMES) do
        if name == n then return true end
    end
    return false
end

local function getBallOwner(ball)
    if not ball then return nil end
    local ownerVal = ball:FindFirstChild("Owner")
    if not ownerVal or not ownerVal.Value then return nil end
    return Players:GetPlayerFromCharacter(ownerVal.Value)
end

local function afFindAllBalls()
    local balls = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and isBallName(obj.Name) then
            local char = LP.Character
            if not (char and obj:IsDescendantOf(char)) then
                table.insert(balls, obj)
            end
        end
    end
    return balls
end

local function afFindMyBall()
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, bestDist = nil, math.huge
    for _, b in ipairs(afFindAllBalls()) do
        if getBallOwner(b) == LP then return b end
        local owner = getBallOwner(b)
        if owner == nil or owner == LP then
            local d = (b.Position - root.Position).Magnitude
            if d < 6 and d < bestDist then
                bestDist = d
                best = b
            end
        end
    end
    return best
end

local function afFindClosestBall()
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, minDist = nil, math.huge
    for _, b in ipairs(afFindAllBalls()) do
        local d = (b.Position - root.Position).Magnitude
        if d < minDist then minDist = d; closest = b end
    end
    return closest
end

local function afFindBallDefault()
    local balls = afFindAllBalls()
    return balls[1]
end

local function afFindBallByMode()
    local mode = State.AutoFollow.TargetMode or "Todas"
    if mode == "Minha" then return afFindMyBall() end
    if mode == "MaisProxima" then return afFindClosestBall() end
    return afFindBallDefault()
end

local function isBallLocked(ball)
    if not ball then return false, nil end
    local owner = getBallOwner(ball)
    if not owner then return false, nil end
    local char = owner.Character
    if not char then return false, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false, nil end
    if (root.Position - ball.Position).Magnitude > 8 then return false, nil end
    return true, owner
end

local function afCleanupBodyVel()
    if AF_BodyVel and AF_BodyVel.Parent then
        pcall(function() AF_BodyVel:Destroy() end)
    end
    AF_BodyVel = nil
end

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

local function afStart()
    if AF_Conn then AF_Conn:Disconnect() end
    AF_Conn = RunService.RenderStepped:Connect(function()
        if not State.AutoFollow.Enabled then afCleanupBodyVel() return end
        local char = LP.Character
        if not char then afCleanupBodyVel() return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then afCleanupBodyVel() return end

        local now = tick()
        if not AF_CachedBall or not AF_CachedBall.Parent or (now - AF_LastSearch) > 1 then
            AF_LastSearch = now
            AF_CachedBall = afFindBallByMode()
        end
        local ball = AF_CachedBall
        if not ball then afCleanupBodyVel() return end

        if State.AutoFollow.PauseOnLock and State.AutoFollow.TargetMode ~= "Minha" then
            local locked, who = isBallLocked(ball)
            local wasLocked = AF_LockedByMe
            AF_LockedByMe = locked and (who == LP)
            if locked then
                afCleanupBodyVel()
                if wasLocked ~= AF_LockedByMe then updateFloatingBtnVisual() end
                return
            end
            if wasLocked ~= AF_LockedByMe then updateFloatingBtnVisual() end
        else
            AF_LockedByMe = false
        end

        local targetPos = Vector3.new(ball.Position.X, root.Position.Y, ball.Position.Z)
        local dist = (root.Position - targetPos).Magnitude
        if dist > State.AutoFollow.StopDistance then
            if not AF_BodyVel or AF_BodyVel.Parent ~= root then
                afCleanupBodyVel()
                AF_BodyVel = Instance.new("BodyVelocity")
                AF_BodyVel.Name = "VST_AutoFollow"
                AF_BodyVel.MaxForce = Vector3.new(100000, 0, 100000)
                AF_BodyVel.Velocity = Vector3.zero
                AF_BodyVel.Parent = root
            end
            local dir = (targetPos - root.Position).Unit
            pcall(function() root.CFrame = CFrame.lookAt(root.Position, targetPos) end)
            local speed = math.max(hum.WalkSpeed, State.AutoFollow.Speed)
            pcall(function() AF_BodyVel.Velocity = dir * speed end)
        else
            afCleanupBodyVel()
        end
    end)
end

local function afStartReach()
    if AF_ReachConn then AF_ReachConn:Disconnect(); AF_ReachConn = nil end
    AF_ReachConn = RunService.Heartbeat:Connect(function()
        if not State.AutoFollow.Enabled then return end
        if not State.AutoFollow.ReachEnabled then return end
        if State.AutoFollow.ReachDistance <= 1 then return end
        local char = LP.Character
        if not char then return end
        local leg = char:FindFirstChild("Right Leg") or char:FindFirstChild("Right Lower Leg") or char:FindFirstChild("HumanoidRootPart")
        if not leg then return end
        local ball = AF_CachedBall or afFindBallByMode()
        if not ball then return end
        local dist = (leg.Position - ball.Position).Magnitude
        local maxReach = State.AutoFollow.ReachDistance * 1.8
        if dist <= maxReach and dist > 1.5 then
            if firetouchinterest then
                pcall(function() firetouchinterest(ball, leg, 0); firetouchinterest(ball, leg, 1) end)
            end
            pcall(function() ball.CFrame = leg.CFrame * CFrame.new(0, -1, -1) end)
        end
    end)
end

local function afStartTouchDetection()
    if AF_TouchConn then AF_TouchConn:Disconnect(); AF_TouchConn = nil end
    AF_TouchConn = RunService.Heartbeat:Connect(function()
        if not State.AutoFollow.TouchToEnable then return end
        if not State.AutoFollow.Enabled then return end
        local now = tick()
        if now - AF_TouchDebounce < 0.5 then return end
        local char = LP.Character
        if not char then return end
        local ball = AF_CachedBall or afFindBallByMode()
        if not ball or not ball.Parent then return end
        local minDist = math.huge
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                local d = (p.Position - ball.Position).Magnitude
                if d < minDist then minDist = d end
            end
        end
        local radius = math.max(ball.Size.X, ball.Size.Y, ball.Size.Z) * 0.5 + 1.5
        if minDist <= radius then
            AF_TouchDebounce = now
            if not AF_LockedByMe then AF_LastSearch = 0 end
        end
    end)
end

function AutoFollowModule.setEnabled(on)
    State.AutoFollow.Enabled = on
    if on then
        afStart(); afStartReach(); afStartTouchDetection()
        notify("Auto Follow ativado", "good")
    else
        afCleanupBodyVel()
        if AF_Conn then AF_Conn:Disconnect(); AF_Conn = nil end
        if AF_ReachConn then AF_ReachConn:Disconnect(); AF_ReachConn = nil end
        if AF_TouchConn then AF_TouchConn:Disconnect(); AF_TouchConn = nil end
        AF_LockedByMe = false
        notify("Auto Follow desativado", "bad")
    end
    updateFloatingBtnVisual()
end

function AutoFollowModule.setSpeed(v) State.AutoFollow.Speed = v end
function AutoFollowModule.setStopDistance(v) State.AutoFollow.StopDistance = v end
function AutoFollowModule.setPauseOnLock(v) State.AutoFollow.PauseOnLock = v end
function AutoFollowModule.setTouchToEnable(v) State.AutoFollow.TouchToEnable = v end
function AutoFollowModule.setReachEnabled(v) State.AutoFollow.ReachEnabled = v end
function AutoFollowModule.setReachDistance(v) State.AutoFollow.ReachDistance = v end

function AutoFollowModule.setTargetMode(mode)
    State.AutoFollow.TargetMode = mode
    AF_CachedBall = nil
    AF_LastSearch = 0
    notify("Alvo: " .. mode, "good")
end

function AutoFollowModule.reset()
    State.AutoFollow.Enabled = false
    AF_LockedByMe = false
    afCleanupBodyVel()
    if AF_Conn then AF_Conn:Disconnect(); AF_Conn = nil end
    if AF_ReachConn then AF_ReachConn:Disconnect(); AF_ReachConn = nil end
    if AF_TouchConn then AF_TouchConn:Disconnect(); AF_TouchConn = nil end
    AF_CachedBall = nil
    updateFloatingBtnVisual()
    notify("Auto Follow resetado", "bad")
end

local AutoFollowBtnModule = {}
local IsDragging = false
local DragStart = nil
local StartPos = nil
local PressStartTime = 0
local PressStartPos = nil

local function updateLockVisual()
    if not FloatingBtn or not FloatingBtn.Parent then return end
    local lockIcon = FloatingBtn:FindFirstChild("VST_LockIcon")
    if State.AutoFollowBtn.Locked then
        if not lockIcon then
            create("TextLabel", {
                Name = "VST_LockIcon",
                Size = UDim2.fromOffset(18, 18),
                Position = UDim2.new(1, -20, 0, 2),
                BackgroundTransparency = 1,
                Text = "L",
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(255, 220, 60),
                ZIndex = 100000,
                Parent = FloatingBtn,
            })
        end
    else
        if lockIcon then lockIcon:Destroy() end
    end
end

local function createFloatingBtn()
    if FloatingBtn and FloatingBtn.Parent then
        FloatingBtn.Visible = true
        updateLockVisual()
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
    updateLockVisual()

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
        if State.AutoFollowBtn.Locked then return end
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
                local fDelta = input.Position - PressStartPos
                local moved = math.abs(fDelta.X) + math.abs(fDelta.Y)
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

function AutoFollowBtnModule.setLocked(locked)
    State.AutoFollowBtn.Locked = locked
    if FloatingBtn and FloatingBtn.Parent then
        State.AutoFollowBtn.Position = FloatingBtn.Position
    end
    updateLockVisual()
    notify(locked and "Botao travado" or "Botao liberado", locked and "good" or "bad")
end

print("[VoidStrap] 6.1 OK")--====================================================================
-- PARTE 6.2 — AUTO FOLLOW (ABAS UI)
--====================================================================

-- ABA BÁSICO
createTab("AF Basico", "AF")

do
    local page = Tabs["AF Basico"].page

    local sec = section("Seguir Bola")
    sec.Parent = page

    toggleRow(sec, "Ativar Auto Follow", State.AutoFollow.Enabled, function(on)
        AutoFollowModule.setEnabled(on)
    end, 1)

    dropdownRow(sec, "Alvo",
        { "Todas", "Minha", "MaisProxima" },
        State.AutoFollow.TargetMode,
        function(opt) AutoFollowModule.setTargetMode(opt) end, 2)

    sliderRow(sec, "Velocidade", 8, 60, State.AutoFollow.Speed, function(v)
        AutoFollowModule.setSpeed(v)
    end, 3)

    sliderRow(sec, "Distancia Parada", 1, 10, State.AutoFollow.StopDistance, function(v)
        AutoFollowModule.setStopDistance(v)
    end, 4)

    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 1,
        Text = "Todas = qualquer bola. Minha = so quando VOCE tem a posse. MaisProxima = a mais perto de voce.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 5,
        Parent = sec,
    })
    themed(info, "TextColor3", "Sub")

    local floatSec = section("Botao Flutuante")
    floatSec.Parent = page

    buttonRow(floatSec, "Criar / Remover Botao Flutuante", function()
        AutoFollowBtnModule.toggle()
    end, 1)

    local floatInfo = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "Cria um botao na tela. Toque pra ligar/desligar. Arraste pra mover.",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        Parent = floatSec,
    })
    themed(floatInfo, "TextColor3", "Sub")
end

-- ABA AVANÇADO
createTab("AF Avancado", "AF+")

do
    local page = Tabs["AF Avancado"].page

    local sec = section("Seguir Bola (Avancado)")
    sec.Parent = page

    toggleRow(sec, "Triscar Ativa", State.AutoFollow.TouchToEnable, function(on)
        AutoFollowModule.setTouchToEnable(on)
    end, 1)

    toggleRow(sec, "Pausar quando Lockado", State.AutoFollow.PauseOnLock, function(on)
        AutoFollowModule.setPauseOnLock(on)
    end, 2)

    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundTransparency = 1,
        Text = "Triscar = encostar na bola reativa o AF. Lock = pausa quando alguem tem a posse.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 3,
        Parent = sec,
    })
    themed(info, "TextColor3", "Sub")

    local reachSec = section("Reach (Alcance)")
    reachSec.Parent = page

    toggleRow(reachSec, "Ativar Reach", State.AutoFollow.ReachEnabled, function(on)
        AutoFollowModule.setReachEnabled(on)
    end, 1)

    sliderRow(reachSec, "Distancia (Studs)", 1, 12, State.AutoFollow.ReachDistance, function(v)
        AutoFollowModule.setReachDistance(v)
    end, 2)

    local reachWarn = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundTransparency = 1,
        Text = "AVISO: Reach empurra a bola via CFrame. Pode ser detectado por anti-cheat.",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = ActiveTheme.Bad,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 3,
        Parent = reachSec,
    })
    themed(reachWarn, "TextColor3", "Bad")

    local floatSec = section("Botao Flutuante (Avancado)")
    floatSec.Parent = page

    toggleRow(floatSec, "Travar Botao no Lugar", State.AutoFollowBtn.Locked, function(on)
        AutoFollowBtnModule.setLocked(on)
    end, 1)

    local lockInfo = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "Quando travado, o botao fica fixo no lugar. Voce ainda pode tocar pra ligar/desligar.",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        Parent = floatSec,
    })
    themed(lockInfo, "TextColor3", "Sub")

    local resetSec = section("Restaurar")
    resetSec.Parent = page

    buttonRow(resetSec, "Desativar tudo", function()
        AutoFollowModule.reset()
        AutoFollowBtnModule.hide()
    end, 1)
end

-- CLEANUP
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

print("[VoidStrap] 6.2 OK")--====================================================================
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

print("[VoidStrap] Chars carregado.")--====================================================================
-- PARTE 7 — CUSTOM BALL (Cor)
--====================================================================

State.BallColor = State.BallColor or {
    Enabled = false,
    Color = nil,
}

local BallColorModule = {}
local BallColorTarget = nil
local BallColorBackup = nil
local BallColorConn = nil

-- ---------- PALETA ----------
local BALL_COLORS = {
    { name = "Branco",     color = Color3.fromRGB(255, 255, 255) },
    { name = "Preto",      color = Color3.fromRGB(20, 20, 20) },
    { name = "Cinza",      color = Color3.fromRGB(140, 140, 145) },
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
}

-- ---------- DETECÇÃO DA BOLA ----------
local BALL_NAMES_7 = {
    "TPS", "ESA", "MRS", "PRS", "MPS",
    "Ball", "Football", "Soccer Ball", "Bola", "SoccerBall"
}

local function isBallName7(name)
    for _, n in ipairs(BALL_NAMES_7) do
        if name == n then return true end
    end
    return false
end

local function findBall7()
    local char = LP.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and isBallName7(obj.Name) then
            if not (char and obj:IsDescendantOf(char)) then
                return obj
            end
        end
    end
    return nil
end

-- ---------- APLICAR / RESTAURAR ----------
local function applyBallColor(ball, color)
    if not ball then return end
    if not BallColorBackup then
        BallColorBackup = {
            Color = ball.Color,
            Material = ball.Material,
        }
    end
    pcall(function()
        ball.Color = color
    end)
end

local function restoreBallColor()
    if BallColorTarget and BallColorTarget.Parent and BallColorBackup then
        pcall(function()
            BallColorTarget.Color = BallColorBackup.Color
            BallColorTarget.Material = BallColorBackup.Material
        end)
    end
    BallColorBackup = nil
end

-- ---------- MONITOR DE RESPAWN ----------
local function startBallColorMonitor()
    if BallColorConn then BallColorConn:Disconnect() end
    local lastSearch = 0

    BallColorConn = RunService.Heartbeat:Connect(function()
        if not State.BallColor.Enabled then return end
        if not BallColorTarget or not BallColorTarget.Parent then
            local now = tick()
            if now - lastSearch < 1.5 then return end
            lastSearch = now
            task.spawn(function()
                local b = findBall7()
                if b and State.BallColor.Enabled then
                    BallColorTarget = b
                    BallColorBackup = nil
                    if State.BallColor.Color then
                        applyBallColor(b, State.BallColor.Color)
                    end
                end
            end)
        end
    end)
end

-- ---------- API ----------
function BallColorModule.setEnabled(on)
    State.BallColor.Enabled = on
    if on then
        task.spawn(function()
            BallColorTarget = findBall7()
            if BallColorTarget then
                if State.BallColor.Color then
                    applyBallColor(BallColorTarget, State.BallColor.Color)
                end
                notify("Ball Color ativado", "good")
            else
                notify("Bola nao encontrada", "bad")
            end
            startBallColorMonitor()
        end)
    else
        restoreBallColor()
        if BallColorConn then BallColorConn:Disconnect(); BallColorConn = nil end
        BallColorTarget = nil
        notify("Ball Color desativado", "bad")
    end
end

function BallColorModule.setColor(name)
    for _, e in ipairs(BALL_COLORS) do
        if e.name == name then
            State.BallColor.Color = e.color
            if BallColorTarget and BallColorTarget.Parent then
                applyBallColor(BallColorTarget, e.color)
            end
            notify("Cor: " .. name, "good")
            return
        end
    end
end

function BallColorModule.refresh()
    task.spawn(function()
        local b = findBall7()
        if b then
            BallColorTarget = b
            BallColorBackup = nil
            if State.BallColor.Color then
                applyBallColor(b, State.BallColor.Color)
            end
            notify("Bola reconectada", "good")
        else
            notify("Nenhuma bola encontrada", "bad")
        end
    end)
end

function BallColorModule.reset()
    State.BallColor.Enabled = false
    State.BallColor.Color = nil
    restoreBallColor()
    if BallColorConn then BallColorConn:Disconnect(); BallColorConn = nil end
    BallColorTarget = nil
    notify("Bola restaurada", "bad")
end

-- ---------- ABA ----------
createTab("Ball", "BALL")

do
    local page = Tabs["Ball"].page

    local mainSec = section("Cor da Bola")
    mainSec.Parent = page

    toggleRow(mainSec, "Ativar Cor Custom", State.BallColor.Enabled, function(on)
        BallColorModule.setEnabled(on)
    end, 1)

    buttonRow(mainSec, "Reconectar Bola", function()
        BallColorModule.refresh()
    end, 2)

    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "Muda a cor da bola localmente. Apenas voce ve.",
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
            BallColorModule.setColor(e.name)
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
        BallColorModule.reset()
    end, 1)
end

-- ---------- CLEANUP ----------
local _prevBall = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevBall then _prevBall() end
    pcall(function() BallColorModule.reset() end)
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function() BallColorModule.reset() end)
    end
end)

print("[VoidStrap] Ball Color carregado.")--====================================================================
-- PARTE 9 — BALL NA CABEÇA + BOTÃO FLUTUANTE
--====================================================================

State.BallOnHead = State.BallOnHead or {
    Enabled = false,
    HeightOffset = 4,
    Smooth = true,
    Smoothness = 0.3,
}

State.BallOnHeadBtn = State.BallOnHeadBtn or {
    Visible = false,
    Position = UDim2.new(0, 20, 0.55, 0),
    Locked = false,
}

local BallOnHeadModule = {}
local BOH_Conn = nil
local BOH_CachedBall = nil
local BOH_LastSearch = 0
local BOH_FloatingBtn = nil

-- ---------- DETECÇÃO ----------
local BALL_NAMES_9 = {
    "TPS", "ESA", "MRS", "PRS", "MPS",
    "Ball", "Football", "Soccer Ball", "Bola", "SoccerBall"
}

local function isBallName9(name)
    for _, n in ipairs(BALL_NAMES_9) do
        if name == n then return true end
    end
    return false
end

local function findBall9()
    local char = LP.Character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and isBallName9(obj.Name) then
            if not (char and obj:IsDescendantOf(char)) then
                return obj
            end
        end
    end
    return nil
end

-- ---------- LOOP ----------
local function bohStart()
    if BOH_Conn then BOH_Conn:Disconnect() end
    BOH_Conn = RunService.RenderStepped:Connect(function()
        if not State.BallOnHead.Enabled then return end
        local char = LP.Character
        if not char then return end
        local head = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
        if not head then return end

        local now = tick()
        if not BOH_CachedBall or not BOH_CachedBall.Parent or (now - BOH_LastSearch) > 1 then
            BOH_LastSearch = now
            BOH_CachedBall = findBall9()
        end
        local ball = BOH_CachedBall
        if not ball then return end

        local headSize = head.Size
        local offsetY = (headSize.Y / 2) + (ball.Size.Y / 2) + State.BallOnHead.HeightOffset
        local targetPos = head.Position + Vector3.new(0, offsetY, 0)
        local targetCF = CFrame.new(targetPos)

        pcall(function()
            if State.BallOnHead.Smooth then
                local k = math.clamp(State.BallOnHead.Smoothness, 0.05, 1)
                ball.CFrame = ball.CFrame:Lerp(targetCF, k)
            else
                ball.CFrame = targetCF
            end
        end)

        pcall(function()
            ball.AssemblyLinearVelocity = Vector3.zero
            ball.AssemblyAngularVelocity = Vector3.zero
        end)
    end)
end

local function bohUpdateBtnVisual()
    if not BOH_FloatingBtn or not BOH_FloatingBtn.Parent then return end
    if State.BallOnHead.Enabled then
        BOH_FloatingBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 40)
        BOH_FloatingBtn.Text = "HEAD ON"
    else
        BOH_FloatingBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        BOH_FloatingBtn.Text = "HEAD OFF"
    end
end

local function bohUpdateLockVisual()
    if not BOH_FloatingBtn or not BOH_FloatingBtn.Parent then return end
    local lockIcon = BOH_FloatingBtn:FindFirstChild("VST_BOHLock")
    if State.BallOnHeadBtn.Locked then
        if not lockIcon then
            create("TextLabel", {
                Name = "VST_BOHLock",
                Size = UDim2.fromOffset(18, 18),
                Position = UDim2.new(1, -20, 0, 2),
                BackgroundTransparency = 1,
                Text = "L",
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(255, 220, 60),
                ZIndex = 100000,
                Parent = BOH_FloatingBtn,
            })
        end
    else
        if lockIcon then lockIcon:Destroy() end
    end
end

-- ---------- API ----------
function BallOnHeadModule.setEnabled(on)
    State.BallOnHead.Enabled = on
    if on then
        bohStart()
        notify("Ball on Head ativado", "good")
    else
        if BOH_Conn then BOH_Conn:Disconnect(); BOH_Conn = nil end
        notify("Ball on Head desativado", "bad")
    end
    bohUpdateBtnVisual()
end

function BallOnHeadModule.setHeight(v) State.BallOnHead.HeightOffset = v end
function BallOnHeadModule.setSmooth(on) State.BallOnHead.Smooth = on end
function BallOnHeadModule.setSmoothness(v) State.BallOnHead.Smoothness = v end

function BallOnHeadModule.reset()
    State.BallOnHead.Enabled = false
    if BOH_Conn then BOH_Conn:Disconnect(); BOH_Conn = nil end
    BOH_CachedBall = nil
    bohUpdateBtnVisual()
    notify("Ball on Head resetado", "bad")
end

-- ---------- BOTÃO FLUTUANTE ----------
local BallOnHeadBtnModule = {}
local BOH_Dragging = false
local BOH_DragStart = nil
local BOH_StartPos = nil
local BOH_PressTime = 0
local BOH_PressPos = nil

local function bohCreateFloatingBtn()
    if BOH_FloatingBtn and BOH_FloatingBtn.Parent then
        BOH_FloatingBtn.Visible = true
        bohUpdateLockVisual()
        return
    end

    BOH_FloatingBtn = create("TextButton", {
        Name = "VST_BallOnHeadBtn",
        Size = UDim2.fromOffset(64, 64),
        Position = State.BallOnHeadBtn.Position,
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        BorderSizePixel = 0,
        Text = "HEAD OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = false,
        ZIndex = 99999,
        Parent = ScreenOverlay,
    })
    corner(32, BOH_FloatingBtn)
    stroke(ActiveTheme.Accent, 2, 0.3, BOH_FloatingBtn)
    bohUpdateBtnVisual()
    bohUpdateLockVisual()

    BOH_FloatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            BOH_Dragging = true
            BOH_DragStart = input.Position
            BOH_StartPos = BOH_FloatingBtn.Position
            BOH_PressTime = tick()
            BOH_PressPos = input.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not BOH_Dragging then return end
        if State.BallOnHeadBtn.Locked then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - BOH_DragStart
            if math.abs(delta.X) > 8 or math.abs(delta.Y) > 8 then
                BOH_FloatingBtn.Position = UDim2.new(
                    BOH_StartPos.X.Scale, BOH_StartPos.X.Offset + delta.X,
                    BOH_StartPos.Y.Scale, BOH_StartPos.Y.Offset + delta.Y
                )
                State.BallOnHeadBtn.Position = BOH_FloatingBtn.Position
            end
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            BOH_Dragging = false
            if BOH_PressPos then
                local fDelta = input.Position - BOH_PressPos
                local moved = math.abs(fDelta.X) + math.abs(fDelta.Y)
                local elapsed = tick() - BOH_PressTime
                if moved < 12 and elapsed < 0.5 then
                    BallOnHeadModule.setEnabled(not State.BallOnHead.Enabled)
                end
            end
            BOH_PressPos = nil
        end
    end)
end

function BallOnHeadBtnModule.show()
    bohCreateFloatingBtn()
    State.BallOnHeadBtn.Visible = true
    notify("Botao Head criado", "good")
end

function BallOnHeadBtnModule.hide()
    if BOH_FloatingBtn and BOH_FloatingBtn.Parent then
        BOH_FloatingBtn:Destroy()
        BOH_FloatingBtn = nil
    end
    State.BallOnHeadBtn.Visible = false
    notify("Botao Head removido", "bad")
end

function BallOnHeadBtnModule.toggle()
    if State.BallOnHeadBtn.Visible then
        BallOnHeadBtnModule.hide()
    else
        BallOnHeadBtnModule.show()
    end
end

function BallOnHeadBtnModule.setLocked(locked)
    State.BallOnHeadBtn.Locked = locked
    if BOH_FloatingBtn and BOH_FloatingBtn.Parent then
        State.BallOnHeadBtn.Position = BOH_FloatingBtn.Position
    end
    bohUpdateLockVisual()
    notify(locked and "Botao travado" or "Botao liberado", locked and "good" or "bad")
end

--====================================================================
-- ABA CABEÇA
--====================================================================
createTab("Cabeça", "BOH")

do
    local page = Tabs["Cabeça"].page

    local sec = section("Ball na Cabeca")
    sec.Parent = page

    toggleRow(sec, "Ativar Ball on Head", State.BallOnHead.Enabled, function(on)
        BallOnHeadModule.setEnabled(on)
    end, 1)

    sliderRow(sec, "Altura (studs)", 0, 15, State.BallOnHead.HeightOffset, function(v)
        BallOnHeadModule.setHeight(v)
    end, 2)

    toggleRow(sec, "Movimento Suave", State.BallOnHead.Smooth, function(on)
        BallOnHeadModule.setSmooth(on)
    end, 3)

    sliderRow(sec, "Suavidade (x100)", 5, 100, math.floor(State.BallOnHead.Smoothness * 100), function(v)
        BallOnHeadModule.setSmoothness(v / 100)
    end, 4)

    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundTransparency = 1,
        Text = "Bola fica em cima da cabeca. Apenas voce ve — outros continuam vendo no lugar real.",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 5,
        Parent = sec,
    })
    themed(info, "TextColor3", "Sub")

    -- BOTÃO FLUTUANTE
    local floatSec = section("Botao Flutuante")
    floatSec.Parent = page

    buttonRow(floatSec, "Criar / Remover Botao", function()
        BallOnHeadBtnModule.toggle()
    end, 1)

    toggleRow(floatSec, "Travar Botao no Lugar", State.BallOnHeadBtn.Locked, function(on)
        BallOnHeadBtnModule.setLocked(on)
    end, 2)

    local lockInfo = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "Toque pra ligar/desligar. Arraste pra mover. Trave pra fixar.",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = ActiveTheme.Sub,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 3,
        Parent = floatSec,
    })
    themed(lockInfo, "TextColor3", "Sub")

    -- Aviso
    local warnSec = section("Aviso")
    warnSec.Parent = page

    local warnLbl = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 1,
        Text = "AVISO: mexer no CFrame da bola e detectavel por anti-cheat. Use apenas em alt.",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = ActiveTheme.Bad,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = warnSec,
    })
    themed(warnLbl, "TextColor3", "Bad")

    buttonRow(warnSec, "Desativar", function()
        BallOnHeadModule.reset()
        BallOnHeadBtnModule.hide()
    end, 2)
end

local _prevBOH = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevBOH then _prevBOH() end
    pcall(function()
        BallOnHeadModule.reset()
        BallOnHeadBtnModule.hide()
    end)
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function()
            BallOnHeadModule.reset()
            BallOnHeadBtnModule.hide()
        end)
    end
end)

print("[VoidStrap] Ball on Head + Botao carregado.")--====================================================================
-- PARTE 10 — STRETCH SCREEN (FOV)
--====================================================================

State.Stretch = State.Stretch or {
    Enabled = false,
    Preset = "Baixa",
    Intensity = 1.0,
}

local StretchModule = {}
local ST_OriginalFOV = nil
local ST_BaseFOV = 70
local ST_Conn = nil

local STRETCH_PRESETS = {
    { name = "Baixa",  fov = 85,  desc = "85 FOV" },
    { name = "Media",  fov = 100, desc = "100 FOV" },
    { name = "Alta",   fov = 115, desc = "115 FOV" },
    { name = "Ultra",  fov = 130, desc = "130 FOV" },
}

local function stGetPreset(name)
    for _, p in ipairs(STRETCH_PRESETS) do
        if p.name == name then return p end
    end
    return STRETCH_PRESETS[1]
end

local function stApply()
    if not Camera then return end
    if not ST_OriginalFOV then
        ST_OriginalFOV = Camera.FieldOfView
        ST_BaseFOV = Camera.FieldOfView
    end
    if not State.Stretch.Enabled then
        pcall(function() Camera.FieldOfView = ST_OriginalFOV end)
        return
    end
    local p = stGetPreset(State.Stretch.Preset)
    local targetFOV = ST_BaseFOV + (p.fov - ST_BaseFOV) * State.Stretch.Intensity
    pcall(function() Camera.FieldOfView = targetFOV end)
end

local function stStart()
    if ST_Conn then ST_Conn:Disconnect() end
    ST_Conn = RunService.RenderStepped:Connect(function()
        if not State.Stretch.Enabled then return end
        if not Camera then return end
        local p = stGetPreset(State.Stretch.Preset)
        local target = ST_BaseFOV + (p.fov - ST_BaseFOV) * State.Stretch.Intensity
        if math.abs(Camera.FieldOfView - target) > 0.5 then
            pcall(function() Camera.FieldOfView = target end)
        end
    end)
end

function StretchModule.setEnabled(on)
    State.Stretch.Enabled = on
    if on then
        if not ST_OriginalFOV and Camera then
            ST_OriginalFOV = Camera.FieldOfView
            ST_BaseFOV = Camera.FieldOfView
        end
        stStart()
        stApply()
        notify("Stretch: " .. State.Stretch.Preset, "good")
    else
        if ST_Conn then ST_Conn:Disconnect(); ST_Conn = nil end
        stApply()
        notify("Stretch desativado", "bad")
    end
end

function StretchModule.setPreset(name)
    State.Stretch.Preset = name
    if State.Stretch.Enabled then
        stApply()
        notify("Stretch: " .. name, "good")
    end
end

function StretchModule.setIntensity(v)
    State.Stretch.Intensity = v
    if State.Stretch.Enabled then stApply() end
end

function StretchModule.reset()
    State.Stretch.Enabled = false
    State.Stretch.Preset = "Baixa"
    State.Stretch.Intensity = 1.0
    if ST_Conn then ST_Conn:Disconnect(); ST_Conn = nil end
    if Camera and ST_OriginalFOV then
        pcall(function() Camera.FieldOfView = ST_OriginalFOV end)
    end
    notify("Stretch resetado", "bad")
end

createTab("Stretch", "STR")

do
    local page = Tabs["Stretch"].page

    local sec = section("Esticar Tela (FOV)")
    sec.Parent = page

    toggleRow(sec, "Ativar Stretch", State.Stretch.Enabled, function(on)
        StretchModule.setEnabled(on)
    end, 1)

    dropdownRow(sec, "Proporcao",
        { "Baixa", "Media", "Alta", "Ultra" },
        State.Stretch.Preset,
        function(opt) StretchModule.setPreset(opt) end, 2)

    sliderRow(sec, "Intensidade (x100)", 50, 200, math.floor(State.Stretch.Intensity * 100), function(v)
        StretchModule.setIntensity(v / 100)
    end, 3)

    local info = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundTransparency = 1,
        Text = "Baixa=85 | Media=100 | Alta=115 | Ultra=130 FOV.\n\nIntensidade: 0.5x a 2x do efeito.",
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
    buttonRow(resetSec, "Resetar Stretch", function()
        StretchModule.reset()
    end, 1)
end

local _prevStr = _G.VoidStrapUnload
_G.VoidStrapUnload = function()
    if _prevStr then _prevStr() end
    pcall(function() StretchModule.reset() end)
end

Players.PlayerRemoving:Connect(function(plr)
    if plr == LP then
        pcall(function() StretchModule.reset() end)
    end
end)

print("[VoidStrap] Stretch (FOV) carregado.")
