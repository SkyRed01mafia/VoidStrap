--[[ FLUENT-WIND UI v1.0 | PARTE 1/3 ]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- TEMA
-- ============================================
local Theme = {
    Accent        = Color3.fromRGB(120, 90, 240),
    AccentDark    = Color3.fromRGB(85, 60, 200),
    AccentLight   = Color3.fromRGB(160, 130, 255),
    Secondary     = Color3.fromRGB(60, 180, 255),
    Success       = Color3.fromRGB(80, 220, 120),
    Warning       = Color3.fromRGB(255, 180, 60),
    Danger        = Color3.fromRGB(255, 80, 100),

    WindowBg      = Color3.fromRGB(18, 20, 28),
    SidebarBg     = Color3.fromRGB(12, 14, 20),
    TopBarBg      = Color3.fromRGB(25, 28, 38),
    PanelBg       = Color3.fromRGB(28, 31, 42),
    PanelHover    = Color3.fromRGB(38, 42, 58),
    PanelLight    = Color3.fromRGB(48, 52, 70),
    InputBg       = Color3.fromRGB(22, 24, 34),

    Stroke        = Color3.fromRGB(50, 54, 70),
    StrokeLight   = Color3.fromRGB(70, 75, 95),

    Text          = Color3.fromRGB(240, 242, 250),
    TextDim       = Color3.fromRGB(160, 165, 185),
    TextMuted     = Color3.fromRGB(110, 115, 135),

    Font          = Enum.Font.GothamMedium,
    FontBold      = Enum.Font.GothamBold,
    FontSemi      = Enum.Font.Gotham,
}

local Config = {
    BackgroundImage = "rbxassetid://11717400651",
    BackgroundTransparency = 0.4,
    WindowCorner = 12,
    PanelCorner = 8,
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
-- NOTIFICAÇÕES (estilo WindUI)
-- ============================================
local NotifyGui = Create("ScreenGui", {
    Name = "FW_Notify",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = CoreGui,
})

local NotifyStack = {}

local function PushNotify(title, content, duration, iconType)
    duration = duration or 3
    iconType = iconType or "info"

    local iconColor = Theme.Accent
    if iconType == "success" then iconColor = Theme.Success
    elseif iconType == "error" then iconColor = Theme.Danger
    elseif iconType == "warning" then iconColor = Theme.Warning end

    local frame = Create("Frame", {
        Size = UDim2.new(0, 300, 0, 0),
        Position = UDim2.new(1, -320, 0, 20 + (#NotifyStack * 78)),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = NotifyGui,
    })
    Corner(frame, 10)
    Stroke(frame, Theme.Stroke, 1, 0.3)

    local bar = Create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = iconColor,
        BorderSizePixel = 0,
        Parent = frame,
    })
    Corner(bar, 10)

    Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 22),
        Position = UDim2.new(0, 14, 0, 10),
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
        Position = UDim2.new(0, 14, 0, 30),
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
        BackgroundTransparency = 0.4,
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
    Corner(popup, 14)
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
    Corner(sv, 6)

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
    Corner(preview, 6)
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
    Gradient(applyBtn, Theme.Accent, Theme.AccentLight, 0)

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
end--[[ FLUENT-WIND UI v1.0 | PARTE 2/3 — Componentes ]]

local Components = {}

function Components.Section(parent, title)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
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
        Size = UDim2.new(1, 0, 0, desc and 50 or 40),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Corner(row, 8)
    Stroke(row, Theme.Stroke, 1, 0.7)

    Create("TextLabel", {
        Size = UDim2.new(1, -70, 0, desc and 22 or 40),
        Position = UDim2.new(0, 12, 0, desc and 8 or 0),
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
            Size = UDim2.new(1, -70, 0, 14),
            Position = UDim2.new(0, 12, 0, 28),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Theme.TextMuted,
            TextSize = 10,
            Font = Theme.FontSemi,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })
    end

    local state = default or false
    local switch = Create("TextButton", {
        Size = UDim2.new(0, 40, 0, 22),
        Position = UDim2.new(1, -52, 0.5, -11),
        BackgroundColor3 = state and Theme.Accent or Theme.PanelLight,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = row,
    })
    Corner(switch, 999)

    local dot = Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
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
            Position = state and UDim2.new(1, -18, 0.5, -8)
                or UDim2.new(0, 3, 0.5, -8),
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
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Corner(row, 8)
    Stroke(row, Theme.Stroke, 1, 0.7)

    Create("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 20),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local valueLbl = Create("TextLabel", {
        Size = UDim2.new(0.3, 0, 0, 20),
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
        Size = UDim2.new(1, -24, 0, 5),
        Position = UDim2.new(0, 12, 1, -16),
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
    Gradient(fill, Theme.Accent, Theme.Secondary, 0)

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
        Size = UDim2.new(1, 0, 0, desc and 50 or 36),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.3,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = parent,
    })
    Corner(row, 8)
    Stroke(row, Theme.Stroke, 1, 0.7)

    Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, desc and 22 or 36),
        Position = UDim2.new(0, 12, 0, desc and 8 or 0),
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
            Size = UDim2.new(1, -20, 0, 14),
            Position = UDim2.new(0, 12, 0, 28),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Theme.TextMuted,
            TextSize = 10,
            Font = Theme.FontSemi,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })
    end

    row.MouseEnter:Connect(function()
        Tween(row, 0.15, {
            BackgroundColor3 = Theme.PanelHover,
            BackgroundTransparency = 0.15,
        })
    end)
    row.MouseLeave:Connect(function()
        Tween(row, 0.15, {
            BackgroundColor3 = Theme.PanelBg,
            BackgroundTransparency = 0.3,
        })
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
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Corner(row, 8)
    Stroke(row, Theme.Stroke, 1, 0.7)

    local box = Create("TextBox", {
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = placeholder or "digite aqui...",
        PlaceholderColor3 = Theme.TextMuted,
        TextColor3 = Theme.Text,
        TextSize = 12,
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
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Corner(row, 8)
    Stroke(row, Theme.Stroke, 1, 0.7)

    local current = default or options[1]

    local lbl = Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = title .. "  v  " .. tostring(current),
        TextColor3 = Theme.Text,
        TextSize = 12,
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
            if v == current then
                idx = i
                break
            end
        end
        idx = idx + 1
        if idx > #options then idx = 1 end
        current = options[idx]
        lbl.Text = title .. "  v  " .. tostring(current)
        if callback then callback(current) end
    end)

    return row
end

function Components.Colorpicker(parent, screenGui, title, default, callback)
    local row = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.PanelBg,
        BackgroundTransparency = 0.3,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = parent,
    })
    Corner(row, 8)
    Stroke(row, Theme.Stroke, 1, 0.7)

    Create("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local preview = Create("Frame", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(1, -34, 0.5, -11),
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
    end--[[ FLUENT-WIND UI v1.0 | PARTE 3/3 — Library ]]

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
    Window.Minimized = false
    Window.FullHeight = cfg.Height or 480

    local ScreenGui = Create("ScreenGui", {
        Name = "FW_UI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })
    Window.GUI = ScreenGui

    local Main = Create("Frame", {
        Name = "Window",
        Size = UDim2.new(0, cfg.Width or 620, 0, cfg.Height or 480),
        Position = UDim2.new(
            0.5, -(cfg.Width or 620) / 2,
            0.5, -(cfg.Height or 480) / 2
        ),
        BackgroundColor3 = Theme.WindowBg,
        BorderSizePixel = 0,
        Active = true,
        ClipsDescendants = true,
        Parent = ScreenGui,
    })
    Corner(Main, Config.WindowCorner)
    Stroke(Main, Theme.StrokeLight, 1.5, 0.4)
    Drag(Main)
    Window.Frame = Main

    local bgImage = cfg.Background or Config.BackgroundImage
    if bgImage then
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

    local overlay = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.WindowBg,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = Main,
    })
    Corner(overlay, Config.WindowCorner)

    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.TopBarBg,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Main,
    })
    Corner(TopBar, Config.WindowCorner)

    local logoFrame = Create("Frame", {
        Size = UDim2.new(0, 34, 0, 34),
        Position = UDim2.new(0, 12, 0.5, -17),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = TopBar,
    })
    Corner(logoFrame, 8)
    Gradient(logoFrame, Theme.Accent, Theme.Secondary, 45)

    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = cfg.Icon or "UI",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 13,
        Font = Theme.FontBold,
        ZIndex = 4,
        Parent = logoFrame,
    })

    local titleLbl = Create("TextLabel", {
        Size = UDim2.new(1, -240, 0, 20),
        Position = UDim2.new(0, 56, 0, 6),
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
        Size = UDim2.new(1, -240, 0, 14),
        Position = UDim2.new(0, 56, 0, 26),
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

    local function makeTopBtn(symbol, xOffset, hoverColor, callback)
        local btn = Create("TextButton", {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, xOffset, 0.5, -15),
            BackgroundColor3 = Theme.PanelBg,
            BackgroundTransparency = 0.4,
            Text = symbol,
            TextColor3 = Theme.Text,
            TextSize = 13,
            Font = Theme.FontBold,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ZIndex = 3,
            Parent = TopBar,
        })
        Corner(btn, 6)

        btn.MouseEnter:Connect(function()
            Tween(btn, 0.15, {
                BackgroundColor3 = hoverColor,
                BackgroundTransparency = 0.2,
            })
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, 0.15, {
                BackgroundColor3 = Theme.PanelBg,
                BackgroundTransparency = 0.4,
            })
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local minimizeBtn = makeTopBtn("-", -105, Theme.PanelLight, function()
        Window.Minimized = not Window.Minimized
        if Window.Minimized then
            Tween(Main, 0.25, { Size = UDim2.new(0, cfg.Width or 620, 0, 50) })
            Window.Sidebar.Visible = false
            Window.Content.Visible = false
            minimizeBtn.Text = "+"
        else
            Tween(Main, 0.25, {
                Size = UDim2.new(0, cfg.Width or 620, 0, Window.FullHeight),
            })
            Window.Sidebar.Visible = true
            Window.Content.Visible = true
            minimizeBtn.Text = "-"
        end
    end)

    makeTopBtn("[]", -70, Theme.PanelLight, function()
        Tween(Main, 0.2, {
            Size = UDim2.new(0, cfg.Width or 620, 0, cfg.Height or 480),
        })
        Window.Sidebar.Visible = true
        Window.Content.Visible = true
        Window.Minimized = false
        minimizeBtn.Text = "-"
    end)

    makeTopBtn("X", -35, Theme.Danger, function()
        ScreenGui.Enabled = false
    end)

    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 160, 1, -62),
        Position = UDim2.new(0, 6, 0, 56),
        BackgroundColor3 = Theme.SidebarBg,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Main,
    })
    Corner(Sidebar, 10)
    Window.Sidebar = Sidebar

    Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Sidebar,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = Sidebar,
    })

    local Content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -178, 1, -62),
        Position = UDim2.new(0, 172, 0, 56),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = Main,
    })
    Window.Content = Content

    function Window:Tab(tabCfg)
        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
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
            ScrollBarImageColor3 = Theme.Accent,
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
        local bg = Main:FindFirstChild("BackgroundImage")
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

return Library
