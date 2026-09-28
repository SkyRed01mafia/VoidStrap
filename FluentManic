--[[ FLUENT MANIC UI v1.0 | PARTE 1/2 — Base + Componentes ]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- TEMA
-- ============================================
local Theme = {
    Primary       = Color3.fromRGB(120, 90, 240),
    PrimaryDark   = Color3.fromRGB(90, 65, 200),
    Secondary     = Color3.fromRGB(60, 180, 255),
    Accent        = Color3.fromRGB(0, 220, 180),
    Danger        = Color3.fromRGB(255, 80, 100),
    Success       = Color3.fromRGB(80, 220, 120),
    Warning       = Color3.fromRGB(255, 180, 60),

    WindowBg      = Color3.fromRGB(20, 22, 32),
    SidebarBg     = Color3.fromRGB(14, 16, 24),
    PanelBg       = Color3.fromRGB(30, 33, 45),
    PanelHover    = Color3.fromRGB(40, 44, 60),
    PanelLight    = Color3.fromRGB(45, 48, 65),

    Stroke        = Color3.fromRGB(60, 65, 85),
    StrokeLight   = Color3.fromRGB(80, 85, 110),

    Text          = Color3.fromRGB(240, 242, 250),
    TextDim       = Color3.fromRGB(150, 155, 175),
    TextMuted     = Color3.fromRGB(100, 105, 125),

    Font          = Enum.Font.GothamMedium,
    FontBold      = Enum.Font.GothamBold,
    FontSemi      = Enum.Font.Gotham,
}

local Config = {
    BackgroundImage = "rbxassetid://11717400651",
    BackgroundTransparency = 0.4,
    CornerRadius = 14,
    AnimSpeed = 0.15,
}

-- ============================================
-- HELPERS
-- ============================================
local function Create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props) do
        if k ~= "Parent" then obj[k] = v end
    end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

local function Corner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent,
    })
end

local function Stroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function Gradient(parent, c1, c2, rotation)
    return Create("UIGradient", {
        Color = ColorSequence.new(c1, c2),
        Rotation = rotation or 0,
        Parent = parent,
    })
end

local function Tween(obj, time, props)
    TweenService:Create(
        obj,
        TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function Drag(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================
-- NOTIFICAÇÕES
-- ============================================
local NotifyGui = Create("ScreenGui", {
    Name = "ManicNotify",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = CoreGui,
})

local NotifyStack = {}

local function PushNotify(title, content, duration, iconType)
    duration = duration or 3
    iconType = iconType or "info"

    local iconColor = Theme.Primary
    if iconType == "success" then iconColor = Theme.Success
    elseif iconType == "error" then iconColor = Theme.Danger
    elseif iconType == "warning" then iconColor = Theme.Warning end

    local frame = Create("Frame", {
        Size = UDim2.new(0, 320, 0, 0),
        Position = UDim2.new(1, -340, 1, -20),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = NotifyGui,
    })
    Corner(frame, 12)
    Stroke(frame, Theme.Stroke, 1, 0.3)

    Create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = iconColor,
        BorderSizePixel = 0,
        Parent = frame,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 22),
        Position = UDim2.new(0, 16, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 40),
        Position = UDim2.new(0, 16, 0, 32),
        BackgroundTransparency = 1,
        Text = content,
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Theme.FontSemi,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = frame,
    })

    table.insert(NotifyStack, frame)

    Tween(frame, 0.3, { Size = UDim2.new(0, 320, 0, 70) })

    task.delay(duration, function()
        if frame and frame.Parent then
            Tween(frame, 0.25, {
                Size = UDim2.new(0, 320, 0, 0),
                BackgroundTransparency = 1,
            })
            task.wait(0.3)
            frame:Destroy()
            for i, f in ipairs(NotifyStack) do
                if f == frame then
                    table.remove(NotifyStack, i)
                    break
                end
            end
        end
    end)
end

-- ============================================
-- COMPONENTES
-- ============================================
local Components = {}

function Components.Section(parent, title)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = string.upper(title or ""),
        TextColor3 = Theme.TextMuted,
        TextSize = 10,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })

    return container
end

function Components.Toggle(parent, title, desc, default, callback)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, desc and 52 or 42),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Corner(row, 10)
    Stroke(row, Theme.Stroke, 1, 0.6)

    Create("TextLabel", {
        Size = UDim2.new(1, -80, 0, desc and 22 or 42),
        Position = UDim2.new(0, 14, 0, desc and 8 or 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    if desc then
        Create("TextLabel", {
            Size = UDim2.new(1, -80, 0, 16),
            Position = UDim2.new(0, 14, 0, 28),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Theme.TextMuted,
            TextSize = 11,
            Font = Theme.FontSemi,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })
    end

    local state = default or false

    local switch = Create("TextButton", {
        Size = UDim2.new(0, 46, 0, 24),
        Position = UDim2.new(1, -58, 0.5, -12),
        BackgroundColor3 = state and Theme.Primary or Theme.PanelLight,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = row,
    })
    Corner(switch, 999)

    local dot = Create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = switch,
    })
    Corner(dot, 999)

    switch.MouseButton1Click:Connect(function()
        state = not state
        Tween(switch, 0.2, {
            BackgroundColor3 = state and Theme.Primary or Theme.PanelLight,
        })
        Tween(dot, 0.2, {
            Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
        })
        if callback then callback(state) end
    end)

    return row
end

function Components.Slider(parent, title, min, max, default, suffix, callback)
    min = min or 0
    max = max or 100
    default = default or min
    suffix = suffix or ""

    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Corner(row, 10)
    Stroke(row, Theme.Stroke, 1, 0.6)

    Create("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 22),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local valueLbl = Create("TextLabel", {
        Size = UDim2.new(0.3, 0, 0, 22),
        Position = UDim2.new(0.65, 0, 0, 8),
        BackgroundTransparency = 1,
        Text = tostring(default) .. suffix,
        TextColor3 = Theme.Primary,
        TextSize = 13,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })

    local bar = Create("Frame", {
        Size = UDim2.new(1, -28, 0, 6),
        Position = UDim2.new(0, 14, 1, -18),
        BackgroundColor3 = Theme.PanelLight,
        BorderSizePixel = 0,
        Parent = row,
    })
    Corner(bar, 999)

    local fill = Create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Primary,
        BorderSizePixel = 0,
        Parent = bar,
    })
    Corner(fill, 999)
    Gradient(fill, Theme.Primary, Theme.Secondary, 0)

    local handle = Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = bar,
        ZIndex = 3,
    })
    Corner(handle, 999)
    Stroke(handle, Theme.Primary, 2, 0)

    local dragging = false

    local function update(input)
        local pos = math.clamp(
            (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
            0, 1
        )
        local val = math.floor(min + (max - min) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        handle.Position = UDim2.new(pos, 0, 0.5, 0)
        valueLbl.Text = tostring(val) .. suffix
        if callback then callback(val) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    return row
end

function Components.Button(parent, title, desc, callback)
    local row = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, desc and 52 or 38),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.3,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = parent,
    })
    Corner(row, 10)
    Stroke(row, Theme.Stroke, 1, 0.6)

    Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, desc and 22 or 38),
        Position = UDim2.new(0, 14, 0, desc and 8 or 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    if desc then
        Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 16),
            Position = UDim2.new(0, 14, 0, 28),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Theme.TextMuted,
            TextSize = 11,
            Font = Theme.FontSemi,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })
    end

    row.MouseEnter:Connect(function()
        Tween(row, 0.15, { BackgroundColor3 = Theme.PanelHover, BackgroundTransparency = 0.15 })
    end)
    row.MouseLeave:Connect(function()
        Tween(row, 0.15, { BackgroundColor3 = Theme.PanelBg, BackgroundTransparency = 0.3 })
    end)
    row.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return row
end

function Components.Input(parent, title, placeholder, callback)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Corner(row, 10)
    Stroke(row, Theme.Stroke, 1, 0.6)

    local box = Create("TextBox", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = placeholder or "digite aqui...",
        PlaceholderColor3 = Theme.TextMuted,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = row,
    })

    box.FocusLost:Connect(function()
        if callback then callback(box.Text) end
    end)

    return row
end

function Components.Dropdown(parent, title, options, default, callback)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Corner(row, 10)
    Stroke(row, Theme.Stroke, 1, 0.6)

    local current = default or options[1]

    local lbl = Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = title .. "  v  " .. tostring(current),
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = row,
    })

    btn.MouseButton1Click:Connect(function()
        local idx = 1
        for i, v in ipairs(options) do
            if v == current then idx = i break end
        end
        idx = idx + 1
        if idx > #options then idx = 1 end
        current = options[idx]
        lbl.Text = title .. "  v  " .. tostring(current)
        if callback then callback(current) end
    end)

    return row
end

function Components.Colorpicker(parent, title, default, callback)
    local row = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.3,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = parent,
    })
    Corner(row, 10)
    Stroke(row, Theme.Stroke, 1, 0.6)

    Create("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local preview = Create("Frame", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -36, 0.5, -12),
        BackgroundColor3 = default or Theme.Primary,
        BorderSizePixel = 0,
        Parent = row,
    })
    Corner(preview, 6)
    Stroke(preview, Theme.StrokeLight, 1, 0.5)

    row.MouseButton1Click:Connect(function()
        if callback then callback(preview.BackgroundColor3) end
    end)

    return row
end--[[ FLUENT MANIC UI v1.0 | PARTE 2/2 — Library ]]

local Library = {}

function Library:Notify(cfg)
    PushNotify(
        cfg.Title or "Manic",
        cfg.Content or "",
        cfg.Duration or 3,
        cfg.Icon or "info"
    )
end

function Library:CreateWindow(cfg)
    cfg = cfg or {}

    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil

    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "FluentManicUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })
    Window.GUI = ScreenGui

    -- Main Frame
    local Main = Create("Frame", {
        Name = "Window",
        Size = UDim2.new(0, cfg.Width or 620, 0, cfg.Height or 480),
        Position = UDim2.new(0.5, -(cfg.Width or 620) / 2, 0.5, -(cfg.Height or 480) / 2),
        BackgroundColor3 = Theme.WindowBg,
        BorderSizePixel = 0,
        Active = true,
        ClipsDescendants = true,
        Parent = ScreenGui,
    })
    Corner(Main, Config.CornerRadius)
    Stroke(Main, Theme.StrokeLight, 1.5, 0.4)
    Drag(Main)
    Window.Frame = Main

    -- Background Image
    local bgImage = cfg.Background or Config.BackgroundImage
    if bgImage then
        local bg = Create("ImageLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = bgImage,
            ImageTransparency = cfg.BackgroundTransparency or Config.BackgroundTransparency,
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 0,
            Parent = Main,
        })
        Corner(bg, Config.CornerRadius)
    end

    -- Dark overlay
    local overlay = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.WindowBg,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = Main,
    })
    Corner(overlay, Config.CornerRadius)

    -- Topbar
    local TopBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = Theme.WindowBg,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Main,
    })
    Corner(TopBar, Config.CornerRadius)

    -- Logo
    local logoFrame = Create("Frame", {
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 14, 0.5, -18),
        BackgroundColor3 = Theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = TopBar,
    })
    Corner(logoFrame, 10)
    Gradient(logoFrame, Theme.Primary, Theme.Secondary, 45)

    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = cfg.Icon or "UI",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Font = Theme.FontBold,
        ZIndex = 4,
        Parent = logoFrame,
    })

    -- Title
    local titleLbl = Create("TextLabel", {
        Size = UDim2.new(1, -250, 0, 20),
        Position = UDim2.new(0, 60, 0, 8),
        BackgroundTransparency = 1,
        Text = cfg.Title or "Manic Hub",
        TextColor3 = Theme.Text,
        TextSize = 15,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = TopBar,
    })
    Window.TitleLabel = titleLbl

    local subtitleLbl = Create("TextLabel", {
        Size = UDim2.new(1, -250, 0, 14),
        Position = UDim2.new(0, 60, 0, 28),
        BackgroundTransparency = 1,
        Text = cfg.Author or "interface",
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        Font = Theme.FontSemi,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = TopBar,
    })
    Window.SubtitleLabel = subtitleLbl

    -- Top Buttons
    local function makeTopBtn(symbol, xOffset, hoverColor, callback)
        local btn = Create("TextButton", {
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(1, xOffset, 0.5, -16),
            BackgroundColor3 = Theme.PanelBg,
            BackgroundTransparency = 0.4,
            Text = symbol,
            TextColor3 = Theme.Text,
            TextSize = 14,
            Font = Theme.FontBold,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ZIndex = 3,
            Parent = TopBar,
        })
        Corner(btn, 8)

        btn.MouseEnter:Connect(function()
            Tween(btn, 0.15, { BackgroundColor3 = hoverColor, BackgroundTransparency = 0.2 })
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, 0.15, { BackgroundColor3 = Theme.PanelBg, BackgroundTransparency = 0.4 })
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    makeTopBtn("-", -115, Theme.PanelLight, function()
        Tween(Main, 0.2, { Size = UDim2.new(0, cfg.Width or 620, 0, 54) })
    end)
    makeTopBtn("[ ]", -78, Theme.PanelLight, function()
        Tween(Main, 0.2, { Size = UDim2.new(0, cfg.Width or 620, 0, cfg.Height or 480) })
    end)
    makeTopBtn("X", -41, Theme.Danger, function()
        ScreenGui.Enabled = false
    end)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Size = UDim2.new(0, 160, 1, -68),
        Position = UDim2.new(0, 6, 0, 58),
        BackgroundColor3 = Theme.SidebarBg,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Main,
    })
    Corner(Sidebar, 12)

    Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Sidebar,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = Sidebar,
    })

    -- Content
    local Content = Create("Frame", {
        Size = UDim2.new(1, -178, 1, -68),
        Position = UDim2.new(0, 172, 0, 58),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = Main,
    })

    -- ============================================
    -- TAB API
    -- ============================================
    function Window:Tab(tabCfg)
        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.PanelBg,
            BackgroundTransparency = 1,
            Text = "  " .. (tabCfg.Title or "Tab"),
            TextColor3 = Theme.TextDim,
            TextSize = 13,
            Font = Theme.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ZIndex = 3,
            Parent = Sidebar,
        })
        Corner(btn, 8)

        local page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Primary,
            ScrollBarImageTransparency = 0.3,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 3,
            Parent = Content,
        })
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 10),
            Parent = page,
        })
        Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = page,
        })

        table.insert(Window.Tabs, { Button = btn, Page = page })

        btn.MouseEnter:Connect(function()
            if Window.CurrentTab ~= btn then
                Tween(btn, 0.15, { BackgroundTransparency = 0.7 })
            end
        end)
        btn.MouseLeave:Connect(function()
            if Window.CurrentTab ~= btn then
                Tween(btn, 0.15, { BackgroundTransparency = 1 })
            end
        end)

        btn.MouseButton1Click:Connect(function()
            for _, t in ipairs(Window.Tabs) do
                t.Page.Visible = false
                t.Button.BackgroundTransparency = 1
                t.Button.BackgroundColor3 = Theme.PanelBg
                t.Button.TextColor3 = Theme.TextDim
            end
            page.Visible = true
            btn.BackgroundTransparency = 0
            btn.BackgroundColor3 = Theme.PanelHover
            btn.TextColor3 = Theme.Text
            Window.CurrentTab = btn
        end)

        local Tab = {}

        function Tab:Section(title)
            Components.Section(page, title)
            return Tab
        end

        function Tab:Toggle(cfg)
            Components.Toggle(page, cfg.Title, cfg.Desc, cfg.Value, cfg.Callback)
            return Tab
        end

        function Tab:Slider(cfg)
            Components.Slider(page, cfg.Title, cfg.Min, cfg.Max, cfg.Default, cfg.Suffix, cfg.Callback)
            return Tab
        end

        function Tab:Button(cfg)
            Components.Button(page, cfg.Title, cfg.Desc, cfg.Callback)
            return Tab
        end

        function Tab:Input(cfg)
            Components.Input(page, cfg.Title, cfg.Placeholder, cfg.Callback)
            return Tab
        end

        function Tab:Dropdown(cfg)
            Components.Dropdown(page, cfg.Title, cfg.Values, cfg.Value, cfg.Callback)
            return Tab
        end

        function Tab:Colorpicker(cfg)
            Components.Colorpicker(page, cfg.Title, cfg.Default, cfg.Callback)
            return Tab
        end

        if not Window.CurrentTab then
            page.Visible = true
            btn.BackgroundTransparency = 0
            btn.BackgroundColor3 = Theme.PanelHover
            btn.TextColor3 = Theme.Text
            Window.CurrentTab = btn
        end

        return Tab
    end

    -- ============================================
    -- WINDOW API
    -- ============================================
    function Window:Toggle()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end

    function Window:SetTitle(text)
        Window.TitleLabel.Text = text
    end

    function Window:SetAuthor(text)
        Window.SubtitleLabel.Text = text
    end

    function Window:SetBackground(imageId, transparency)
        local bg = Main:FindFirstChildWhichIsA("ImageLabel")
        if bg then
            bg.Image = "rbxassetid://" .. tostring(imageId):gsub("rbxassetid://", "")
            if transparency then bg.ImageTransparency = transparency end
        end
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

-- ============================================
-- RETORNA A LIBRARY
-- ============================================
return Library
