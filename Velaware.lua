--[[ VELAWARE UI v1.0 | PARTE 1/3 ]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- TEMA VELAWARE
-- ============================================
local Theme = {
    -- Cores principais (roxo/rosa Velaware)
    Accent        = Color3.fromRGB(180, 120, 255),
    AccentDark    = Color3.fromRGB(140, 80, 220),
    AccentLight   = Color3.fromRGB(220, 180, 255),
    Pink          = Color3.fromRGB(255, 130, 200),
    Success       = Color3.fromRGB(90, 220, 130),
    Warning       = Color3.fromRGB(255, 190, 80),
    Danger        = Color3.fromRGB(255, 90, 110),
    Red           = Color3.fromRGB(255, 95, 86),
    Yellow        = Color3.fromRGB(255, 189, 46),
    Green         = Color3.fromRGB(39, 201, 63),

    -- Fundos
    WindowBg      = Color3.fromRGB(22, 18, 32),
    TopBarBg      = Color3.fromRGB(28, 22, 40),
    SidebarBg     = Color3.fromRGB(18, 14, 28),
    PanelBg       = Color3.fromRGB(35, 28, 50),
    PanelHover    = Color3.fromRGB(45, 36, 65),
    PanelLight    = Color3.fromRGB(52, 42, 75),
    InputBg       = Color3.fromRGB(28, 22, 42),

    -- Bordas
    Stroke        = Color3.fromRGB(70, 55, 100),
    StrokeLight   = Color3.fromRGB(100, 80, 140),

    -- Texto
    Text          = Color3.fromRGB(248, 245, 255),
    TextDim       = Color3.fromRGB(190, 180, 210),
    TextMuted     = Color3.fromRGB(130, 120, 160),

    Font          = Enum.Font.GothamMedium,
    FontBold      = Enum.Font.GothamBold,
    FontSemi      = Enum.Font.Gotham,
}

local Config = {
    BackgroundImage = "",
    BackgroundTransparency = 0.55,
    WindowCorner = 16,
    PanelCorner = 10,
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
    Name = "VW_Notify",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = CoreGui,
})

local NotifyStack = {}

local function PushNotify(title, content, duration, iconType)
    duration = duration or 3
    iconType = iconType or "info"

    local accent = Theme.Accent
    if iconType == "success" then accent = Theme.Success
    elseif iconType == "error" then accent = Theme.Danger
    elseif iconType == "warning" then accent = Theme.Warning end

    local frame = Create("Frame", {
        Size = UDim2.new(0, 300, 0, 0),
        Position = UDim2.new(1, -320, 0, 20 + (#NotifyStack * 78)),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = NotifyGui,
    })
    Corner(frame, 12)
    Stroke(frame, accent, 1, 0.4)

    local bar = Create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Parent = frame,
    })
    Corner(bar, 12)

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
        Size = UDim2.new(1, -30, 0, 36),
        Position = UDim2.new(0, 16, 0, 30),
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
    Tween(frame, 0.3, { Size = UDim2.new(0, 300, 0, 66) })

    task.delay(duration, function()
        if frame and frame.Parent then
            Tween(frame, 0.25, {
                Size = UDim2.new(0, 300, 0, 0),
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
-- COLOR EDITOR
-- ============================================
local function OpenColorEditor(parentScreen, initialColor, callback)
    local h, s, v = Color3.toHSV(initialColor)
    local currentColor = initialColor

    local overlay = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 300,
        Parent = parentScreen,
    })

    local popup = Create("Frame", {
        Size = UDim2.new(0, 480, 0, 300),
        Position = UDim2.new(0.5, -240, 0.5, -150),
        BackgroundColor3 = Theme.PanelBg,
        BorderSizePixel = 0,
        ZIndex = 301,
        Parent = overlay,
    })
    Corner(popup, 16)
    Stroke(popup, Theme.Accent, 1.5, 0.3)
    Drag(popup)

    Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 26),
        Position = UDim2.new(0, 20, 0, 12),
        BackgroundTransparency = 1,
        Text = "Color Editor",
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 302,
        Parent = popup,
    })

    local sv = Create("ImageLabel", {
        Size = UDim2.new(0, 260, 0, 200),
        Position = UDim2.new(0, 20, 0, 50),
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        Image = "rbxassetid://4155801252",
        BorderSizePixel = 0,
        ZIndex = 302,
        Parent = popup,
    })
    Corner(sv, 8)

    local cursor = Create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(s, -6, 1 - v, -6),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 2,
        BorderColor3 = Color3.new(0, 0, 0),
        ZIndex = 303,
        Parent = sv,
    })
    Corner(cursor, 999)

    local hueBar = Create("ImageLabel", {
        Size = UDim2.new(0, 20, 0, 200),
        Position = UDim2.new(0, 290, 0, 50),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6020205287",
        ZIndex = 302,
        Parent = popup,
    })
    Corner(hueBar, 999)

    local hueCursor = Create("Frame", {
        Size = UDim2.new(1, 6, 0, 6),
        Position = UDim2.new(0, -3, h, -3),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 2,
        BorderColor3 = Color3.new(0, 0, 0),
        ZIndex = 303,
        Parent = hueBar,
    })
    Corner(hueCursor, 999)

    local preview = Create("Frame", {
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 320, 0, 50),
        BackgroundColor3 = initialColor,
        BorderSizePixel = 0,
        ZIndex = 302,
        Parent = popup,
    })
    Corner(preview, 8)
    Stroke(preview, Theme.StrokeLight, 1, 0.4)

    local inputs = {}
    local labels = {"Hex", "Red", "Green", "Blue"}
    local yPos = 50
    for i, lab in ipairs(labels) do
        local box = Create("TextBox", {
            Size = UDim2.new(0, 130, 0, 26),
            Position = UDim2.new(0, 370, 0, yPos),
            BackgroundColor3 = Theme.InputBg,
            TextColor3 = Theme.Text,
            TextSize = 12,
            Font = Theme.FontBold,
            Text = (i == 1) and "#ffffff" or "255",
            BorderSizePixel = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 302,
            Parent = popup,
        })
        Corner(box, 6)
        Stroke(box, Theme.Stroke, 1, 0.5)
        Create("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = box })

        Create("TextLabel", {
            Size = UDim2.new(0, 60, 0, 26),
            Position = UDim2.new(1, -70, 0, yPos),
            BackgroundTransparency = 1,
            Text = lab,
            TextColor3 = Theme.TextMuted,
            TextSize = 11,
            Font = Theme.FontSemi,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 302,
            Parent = popup,
        })

        inputs[lab] = box
        yPos = yPos + 32
    end

    local cancelBtn = Create("TextButton", {
        Size = UDim2.new(0, 100, 0, 34),
        Position = UDim2.new(0, 20, 1, -50),
        BackgroundColor3 = Theme.PanelLight,
        Text = "Cancel",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Theme.FontBold,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 302,
        Parent = popup,
    })
    Corner(cancelBtn, 8)

    local applyBtn = Create("TextButton", {
        Size = UDim2.new(0, 140, 0, 34),
        Position = UDim2.new(0, 340, 1, -50),
        BackgroundColor3 = Theme.Accent,
        Text = "Apply",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 13,
        Font = Theme.FontBold,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 302,
        Parent = popup,
    })
    Corner(applyBtn, 8)
    Gradient(applyBtn, Theme.Accent, Theme.Pink, 0)

    local updating = false
    local function updateAll()
        if updating then return end
        updating = true
        currentColor = Color3.fromHSV(h, s, v)
        sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        cursor.Position = UDim2.new(s, -6, 1 - v, -6)
        hueCursor.Position = UDim2.new(0, -3, h, -3)
        preview.BackgroundColor3 = currentColor
        inputs["Hex"].Text = "#" .. string.format("%02x%02x%02x",
            math.floor(currentColor.R * 255),
            math.floor(currentColor.G * 255),
            math.floor(currentColor.B * 255))
        inputs["Red"].Text = tostring(math.floor(currentColor.R * 255))
        inputs["Green"].Text = tostring(math.floor(currentColor.G * 255))
        inputs["Blue"].Text = tostring(math.floor(currentColor.B * 255))
        updating = false
    end
    updateAll()

    local svDrag = false
    sv.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then svDrag = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then svDrag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if svDrag and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            s = math.clamp((i.Position.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((i.Position.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
            updateAll()
        end
    end)

    local hDrag = false
    hueBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then hDrag = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then hDrag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if hDrag and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            h = math.clamp((i.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
            updateAll()
        end
    end)

    inputs["Hex"].FocusLost:Connect(function()
        local hex = inputs["Hex"].Text:gsub("#", "")
        local r = tonumber(hex:sub(1, 2), 16) or 255
        local g = tonumber(hex:sub(3, 4), 16) or 255
        local b = tonumber(hex:sub(5, 6), 16) or 255
        h, s, v = Color3.toHSV(Color3.fromRGB(r, g, b))
        updateAll()
    end)
    for _, lab in ipairs({"Red", "Green", "Blue"}) do
        inputs[lab].FocusLost:Connect(function()
            local r = tonumber(inputs["Red"].Text) or 255
            local g = tonumber(inputs["Green"].Text) or 255
            local b = tonumber(inputs["Blue"].Text) or 255
            h, s, v = Color3.toHSV(Color3.fromRGB(r, g, b))
            updateAll()
        end)
    end

    cancelBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    applyBtn.MouseButton1Click:Connect(function()
        callback(currentColor)
        overlay:Destroy()
    end)
end--[[ VELAWARE UI v1.0 | PARTE 2/3 — Componentes ]]

local Components = {}

-- Section com ícone (estilo Velaware)
function Components.Section(parent, title, iconText)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    if iconText then
        Create("TextLabel", {
            Size = UDim2.new(0, 24, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Text = iconText,
            TextColor3 = Theme.Accent,
            TextSize = 18,
            Font = Theme.FontBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = container,
        })
    end

    Create("TextLabel", {
        Size = UDim2.new(1, iconText and -40 or -12, 1, 0),
        Position = UDim2.new(0, iconText and 36 or 6, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "",
        TextColor3 = Theme.Text,
        TextSize = 15,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })

    return container
end

-- Toggle estilo Velaware (linha larga, desc abaixo, switch à direita)
function Components.Toggle(parent, title, desc, default, callback)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Corner(row, 10)

    Create("TextLabel", {
        Size = UDim2.new(1, -80, 0, 22),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    if desc then
        Create("TextLabel", {
            Size = UDim2.new(1, -80, 0, 16),
            Position = UDim2.new(0, 14, 0, 30),
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
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -56, 0.5, -12),
        BackgroundColor3 = state and Theme.Accent or Theme.PanelLight,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = row,
    })
    Corner(switch, 999)

    local dot = Create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = switch,
    })
    Corner(dot, 999)

    switch.MouseButton1Click:Connect(function()
        state = not state
        Tween(switch, 0.2, {
            BackgroundColor3 = state and Theme.Accent or Theme.PanelLight,
        })
        Tween(dot, 0.2, {
            Position = state and UDim2.new(1, -20, 0.5, -9)
                or UDim2.new(0, 3, 0.5, -9),
        })
        if callback then callback(state) end
    end)

    return row
end

-- Slider estilo Velaware
function Components.Slider(parent, title, min, max, default, suffix, callback)
    min = min or 0
    max = max or 100
    default = default or min
    suffix = suffix or ""

    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Corner(row, 10)

    Create("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 22),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local valueLbl = Create("TextLabel", {
        Size = UDim2.new(0.3, 0, 0, 22),
        Position = UDim2.new(0.65, 0, 0, 8),
        BackgroundTransparency = 1,
        Text = tostring(default) .. suffix,
        TextColor3 = Theme.Accent,
        TextSize = 13,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })

    local bar = Create("Frame", {
        Size = UDim2.new(1, -28, 0, 5),
        Position = UDim2.new(0, 14, 1, -18),
        BackgroundColor3 = Theme.PanelLight,
        BorderSizePixel = 0,
        Parent = row,
    })
    Corner(bar, 999)

    local fill = Create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = bar,
    })
    Corner(fill, 999)
    Gradient(fill, Theme.Accent, Theme.Pink, 0)

    local dragging = false
    local function update(input)
        local pos = math.clamp(
            (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
            0, 1
        )
        local val = math.floor(min + (max - min) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
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
        Size = UDim2.new(1, 0, 0, desc and 54 or 40),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.55,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = parent,
    })
    Corner(row, 10)

    Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, desc and 22 or 40),
        Position = UDim2.new(0, 14, 0, desc and 8 or 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    if desc then
        Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 16),
            Position = UDim2.new(0, 14, 0, 30),
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
        Tween(row, 0.15, { BackgroundColor3 = Theme.PanelHover, BackgroundTransparency = 0.4 })
    end)
    row.MouseLeave:Connect(function()
        Tween(row, 0.15, { BackgroundColor3 = Theme.PanelBg, BackgroundTransparency = 0.55 })
    end)
    row.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return row
end

function Components.Input(parent, title, placeholder, callback)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Corner(row, 10)

    local box = Create("TextBox", {
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = placeholder or "digite aqui...",
        PlaceholderColor3 = Theme.TextMuted,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Theme.FontSemi,
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
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Corner(row, 10)

    local current = default or options[1]

    local lbl = Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = title .. "  ▾  " .. tostring(current),
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Theme.FontSemi,
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
        lbl.Text = title .. "  ▾  " .. tostring(current)
        if callback then callback(current) end
    end)

    return row
end

function Components.Colorpicker(parent, screenGui, title, default, callback)
    local row = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.55,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = parent,
    })
    Corner(row, 10)

    Create("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Theme.FontSemi,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local preview = Create("Frame", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -36, 0.5, -12),
        BackgroundColor3 = default or Theme.Accent,
        BorderSizePixel = 0,
        Parent = row,
    })
    Corner(preview, 6)
    Stroke(preview, Theme.StrokeLight, 1, 0.5)

    row.MouseButton1Click:Connect(function()
        OpenColorEditor(screenGui, preview.BackgroundColor3, function(c)
            preview.BackgroundColor3 = c
            if callback then callback(c) end
        end)
    end)

    return row
    end--[[ VELAWARE UI v1.0 | PARTE 3/3 — Library ]]

local Library = {}

function Library:Notify(cfg)
    PushNotify(
        cfg.Title or "Velaware",
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
    Window.Minimized = false
    Window.FullWidth = cfg.Width or 620
    Window.FullHeight = cfg.Height or 420

    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "VelawareUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })
    Window.GUI = ScreenGui

    -- Main Frame
    local Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, Window.FullWidth, 0, Window.FullHeight),
        Position = UDim2.new(
            0.5, -Window.FullWidth / 2,
            0.5, -Window.FullHeight / 2
        ),
        BackgroundColor3 = Theme.WindowBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Active = true,
        ClipsDescendants = true,
        Parent = ScreenGui,
    })
    Corner(Main, Config.WindowCorner)
    Stroke(Main, Theme.Accent, 1.5, 0.5)
    Drag(Main)
    Window.Frame = Main

    -- Background Image
    local bgImage = cfg.Background or Config.BackgroundImage
    if bgImage and bgImage ~= "" then
        local bg = Create("ImageLabel", {
            Name = "BackgroundImage",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = bgImage,
            ImageTransparency = cfg.BackgroundTransparency or Config.BackgroundTransparency,
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 0,
            Parent = Main,
        })
        Corner(bg, Config.WindowCorner)
    end

    -- Overlay escuro (dá o look Velaware)
    local overlay = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.WindowBg,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = Main,
    })
    Corner(overlay, Config.WindowCorner)

    -- ============================================
    -- TOPBAR (com botões mac-style)
    -- ============================================
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Theme.TopBarBg,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Main,
    })
    Corner(TopBar, Config.WindowCorner)

    -- Botões mac-style (red, yellow, green)
    local function makeMacBtn(color, xOffset, callback, hoverFunc)
        local btn = Create("TextButton", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0, xOffset, 0.5, -6),
            BackgroundColor3 = color,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ZIndex = 3,
            Parent = TopBar,
        })
        Corner(btn, 999)

        local hover = hoverFunc or function() end
        btn.MouseEnter:Connect(function()
            hover(true)
        end)
        btn.MouseLeave:Connect(function()
            hover(false)
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Botão vermelho (X - fechar)
    makeMacBtn(Theme.Red, 14, function()
        ScreenGui.Enabled = false
    end)

    -- Botão amarelo (minimizar → vira botão flutuante)
    makeMacBtn(Theme.Yellow, 32, function()
        Window:Minimize()
    end)

    -- Botão verde (maximizar)
    makeMacBtn(Theme.Green, 50, function()
        Window:Maximize()
    end)

    -- Título
    local titleLbl = Create("TextLabel", {
        Size = UDim2.new(1, -220, 0, 22),
        Position = UDim2.new(0, 80, 0, 6),
        BackgroundTransparency = 1,
        Text = cfg.Title or "Velaware",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = TopBar,
    })
    Window.TitleLabel = titleLbl

    local subtitleLbl = Create("TextLabel", {
        Size = UDim2.new(1, -220, 0, 14),
        Position = UDim2.new(0, 80, 0, 26),
        BackgroundTransparency = 1,
        Text = cfg.Author or "interface",
        TextColor3 = Theme.TextMuted,
        TextSize = 10,
        Font = Theme.FontSemi,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = TopBar,
    })
    Window.SubtitleLabel = subtitleLbl

    -- ============================================
    -- SIDEBAR (estilo Velaware)
    -- ============================================
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 170, 1, -60),
        Position = UDim2.new(0, 8, 0, 52),
        BackgroundColor3 = Theme.SidebarBg,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Main,
    })
    Corner(Sidebar, 12)
    Stroke(Sidebar, Theme.Stroke, 1, 0.7)
    Window.Sidebar = Sidebar

    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Sidebar,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = Sidebar,
    })

    -- ============================================
    -- CONTENT
    -- ============================================
    local Content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -194, 1, -60),
        Position = UDim2.new(0, 186, 0, 52),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = Main,
    })
    Window.Content = Content

    -- ============================================
    -- BOTÃO FLUTUANTE (aparece quando minimizado)
    -- ============================================
    local FloatGui = Create("ScreenGui", {
        Name = "VW_Float",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
        Enabled = false,
    })

    local FloatBtn = Create("TextButton", {
        Size = UDim2.new(0, 52, 0, 52),
        Position = UDim2.new(0.03, 0, 0.4, 0),
        BackgroundColor3 = Theme.WindowBg,
        BackgroundTransparency = 0.05,
        Text = cfg.Icon or "V",
        TextColor3 = Theme.Accent,
        TextSize = 22,
        Font = Theme.FontBold,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = FloatGui,
    })
    Corner(FloatBtn, 999)
    Stroke(FloatBtn, Theme.Accent, 1.5, 0.3)
    Drag(FloatBtn)

    FloatBtn.MouseButton1Click:Connect(function()
        Window:Maximize()
    end)

    -- ============================================
    -- MINIMIZE / MAXIMIZE
    -- ============================================
    function Window:Minimize()
        Window.Minimized = true
        Main.Visible = false
        FloatGui.Enabled = true
    end

    function Window:Maximize()
        Window.Minimized = false
        Main.Visible = true
        Main.Size = UDim2.new(0, Window.FullWidth, 0, Window.FullHeight)
        FloatGui.Enabled = false
    end

    -- ============================================
    -- TAB API
    -- ============================================
    function Window:Tab(tabCfg)
        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Theme.PanelBg,
            BackgroundTransparency = 1,
            Text = "  " .. (tabCfg.Icon or "") .. "   " .. (tabCfg.Title or "Tab"),
            TextColor3 = Theme.TextDim,
            TextSize = 14,
            Font = Theme.FontSemi,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ZIndex = 3,
            Parent = Sidebar,
        })
        Corner(btn, 10)

        local page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            ScrollBarImageTransparency = 0.4,
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
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = page,
        })

        table.insert(Window.Tabs, { Button = btn, Page = page })

        btn.MouseEnter:Connect(function()
            if Window.CurrentTab ~= btn then
                Tween(btn, 0.15, { BackgroundTransparency = 0.6 })
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

        function Tab:Section(title, iconText)
            Components.Section(page, title, iconText)
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
            Components.Colorpicker(page, ScreenGui, cfg.Title, cfg.Default, cfg.Callback)
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
        if Window.Minimized then
            Window:Maximize()
        else
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end

    function Window:SetTitle(text)
        Window.TitleLabel.Text = text
    end

    function Window:SetAuthor(text)
        Window.SubtitleLabel.Text = text
    end

    function Window:SetBackground(imageId, transparency)
        local bg = Main:FindFirstChild("BackgroundImage")
        if not bg then
            bg = Create("ImageLabel", {
                Name = "BackgroundImage",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ImageTransparency = transparency or Config.BackgroundTransparency,
                ScaleType = Enum.ScaleType.Crop,
                ZIndex = 0,
                Parent = Main,
            })
            Corner(bg, Config.WindowCorner)
        end
        bg.Image = "rbxassetid://" .. tostring(imageId):gsub("rbxassetid://", "")
        if transparency then bg.ImageTransparency = transparency end
    end

    function Window:Destroy()
        ScreenGui:Destroy()
        FloatGui:Destroy()
    end

    return Window
end

return Library
