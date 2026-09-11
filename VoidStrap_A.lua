--[[
    VoidStrap v1.2.0 — Parte 1 (Kirtium Style)
    Serviços + Temas + State + Helpers + UI base + Fundo cósmico
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

-- ---------- TEMAS ----------
local Themes = {
    Kirtium = {
        Background = Color3.fromRGB(12, 12, 15),
        Surface    = Color3.fromRGB(22, 22, 26),
        Surface2   = Color3.fromRGB(32, 32, 38),
        Accent     = Color3.fromRGB(80, 220, 130),
        AccentDim  = Color3.fromRGB(40, 130, 70),
        Text       = Color3.fromRGB(245, 245, 250),
        Sub        = Color3.fromRGB(150, 155, 165),
        Stroke     = Color3.fromRGB(48, 48, 55),
        Good       = Color3.fromRGB(80, 220, 130),
        Bad        = Color3.fromRGB(230, 90, 90),
    },
    Void = {
        Background = Color3.fromRGB(15, 15, 18),
        Surface    = Color3.fromRGB(25, 25, 30),
        Surface2   = Color3.fromRGB(35, 35, 42),
        Accent     = Color3.fromRGB(140, 100, 255),
        AccentDim  = Color3.fromRGB(80, 55, 160),
        Text       = Color3.fromRGB(240, 240, 245),
        Sub        = Color3.fromRGB(150, 150, 165),
        Stroke     = Color3.fromRGB(50, 50, 60),
        Good       = Color3.fromRGB(80, 200, 130),
        Bad        = Color3.fromRGB(220, 80, 80),
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
        BackgroundColor3 = Color3.fromRGB(25, 25, 30),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Parent = NotifyHolder,
    })
    corner(8, frame)
    stroke(ActiveTheme.Stroke, 1, 0.3, frame)

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

-- Imagem de fundo cósmica (ID 943463390956)
local MainBgImage = create("ImageLabel", {
    Name = "VST_MainBg",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Image = "rbxassetid://943463390956",
    ImageTransparency = 0.35,
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 0,
    Visible = true,
    Parent = Main,
})
corner(14, MainBgImage)

-- Overlay escuro pra deixar texto legível
local MainOverlay = create("Frame", {
    Name = "VST_MainOverlay",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(8, 8, 12),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 1,
    Parent = Main,
})
corner(14, MainOverlay)

stroke(Color3.fromRGB(60, 60, 70), 1, 0.5, Main)

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

-- Logo
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

-- Badge de versão
local VersionBadge = create("Frame", {
    Size = UDim2.fromOffset(70, 24),
    Position = UDim2.new(0, 175, 0.5, -12),
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

-- Botões da topbar
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

print("[VoidStrap] Parte 1 (com fundo cosmico) OK")--====================================================================
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

print("[VoidStrap] Parte 4 OK")
