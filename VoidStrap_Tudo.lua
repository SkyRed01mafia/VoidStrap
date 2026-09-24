--[[ MANIC HUB v2.0 | PARTE 1/8 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

getgenv().ManicHub = getgenv().ManicHub or {}
local Flags = getgenv().ManicHub
local DarkFont = Enum.Font.GothamBold
local ManicAssetId = "rbxassetid://80947706998238"

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "MANIC HUB v2.0",
        Text = "Olá, " .. LocalPlayer.DisplayName .. "!",
        Duration = 5
    })
end)

if CoreGui:FindFirstChild("ManicHub") then CoreGui.ManicHub:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.Name = "ManicHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- Draggable
local function makeDraggable(g)
    local dragging, dragInput, dragStart, startPos
    g.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = g.Position
            input.Changed:Connect(function(s) if s.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    g.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            g.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- FPS Counter
local FpsBox = Instance.new("TextLabel")
FpsBox.Parent = ScreenGui
FpsBox.Size = UDim2.new(0, 90, 0, 34)
FpsBox.Position = UDim2.new(0, 12, 0, 110)
FpsBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
FpsBox.BackgroundTransparency = 0.3
FpsBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsBox.TextSize = 13
FpsBox.Font = Enum.Font.GothamBold
FpsBox.Text = "FPS 0"
FpsBox.BorderSizePixel = 0
FpsBox.ZIndex = 10
local FpsC = Instance.new("UICorner"); FpsC.CornerRadius = UDim.new(0, 6); FpsC.Parent = FpsBox

local fpsCount, fpsTime = 0, tick()--[[ MANIC HUB | PARTE 2/8 ]]

-- Botão flutuante do Auto Ball
local AutoBallBtn = Instance.new("TextButton")
AutoBallBtn.Parent = ScreenGui
AutoBallBtn.Size = UDim2.new(0, 55, 0, 55)
AutoBallBtn.Position = UDim2.new(0.02, 0, 0.3, 0)
AutoBallBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
AutoBallBtn.Text = "⚽"
AutoBallBtn.TextSize = 28
AutoBallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBallBtn.BorderSizePixel = 0
AutoBallBtn.ZIndex = 20
local ABc = Instance.new("UICorner"); ABc.CornerRadius = UDim.new(1, 0); ABc.Parent = AutoBallBtn
makeDraggable(AutoBallBtn)

-- Toggle Button (abre menu)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleBtn.Text = "☰"
ToggleBtn.TextSize = 26
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.ZIndex = 20
local TBc = Instance.new("UICorner"); TBc.CornerRadius = UDim.new(1, 0); TBc.Parent = ToggleBtn
makeDraggable(ToggleBtn)

-- MainFrame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 620, 0, 380)
MainFrame.Position = UDim2.new(0.2, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.BorderSizePixel = 0
local Mfc = Instance.new("UICorner"); Mfc.CornerRadius = UDim.new(0, 10); Mfc.Parent = MainFrame
makeDraggable(MainFrame)

-- TopBar
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
TopBar.BorderSizePixel = 0
local TBc2 = Instance.new("UICorner"); TBc2.CornerRadius = UDim.new(0, 10); TBc2.Parent = TopBar

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Parent = TopBar
TitleLbl.Size = UDim2.new(1, -140, 1, 0)
TitleLbl.Position = UDim2.new(0, 12, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "Manic - The Classic"
TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLbl.TextSize = 15
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = TopBar
SubTitle.Size = UDim2.new(0, 200, 0, 14)
SubTitle.Position = UDim2.new(0, 12, 0, 20)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "manichub.qyz"
SubTitle.TextColor3 = Color3.fromRGB(130, 130, 140)
SubTitle.TextSize = 11
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

local function createTopBtn(text, xPos, color, callback)
    local b = Instance.new("TextButton")
    b.Parent = TopBar
    b.Size = UDim2.new(0, 26, 0, 26)
    b.Position = UDim2.new(1, xPos, 0.5, -13)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 5); c.Parent = b
    b.MouseButton1Click:Connect(callback)
    return b
end

local MinBtn = createTopBtn("—", -70, Color3.fromRGB(35, 40, 55), function()
    MainFrame.Size = UDim2.new(0, 620, 0, 38)
end)
local MaxBtn = createTopBtn("□", -40, Color3.fromRGB(35, 40, 55), function()
    MainFrame.Size = UDim2.new(0, 620, 0, 380)
end)
local CloseBtn = createTopBtn("X", -10, Color3.fromRGB(35, 40, 55), function()
    MainFrame.Visible = false
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Size = UDim2.new(0, 155, 1, -38)
Sidebar.Position = UDim2.new(0, 0, 0, 38)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
Sidebar.BorderSizePixel = 0
local Sbc = Instance.new("UICorner"); Sbc.CornerRadius = UDim.new(0, 10); Sbc.Parent = Sidebar

local TabList = Instance.new("UIListLayout")
TabList.Parent = Sidebar
TabList.Padding = UDim.new(0, 4)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TabPad = Instance.new("UIPadding")
TabPad.Parent = Sidebar
TabPad.PaddingTop = UDim.new(0, 10)--[[ MANIC HUB | PARTE 3/8 ]]

local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -165, 1, -48)
ContentFrame.Position = UDim2.new(0, 160, 0, 42)
ContentFrame.BackgroundTransparency = 1

local Pages = {}
local TabButtons = {}

local function createTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
    btn.BackgroundTransparency = 1
    btn.Text = "   " .. (icon or "●") .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(180, 180, 190)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = Sidebar
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 200)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = ContentFrame
    local layout = Instance.new("UIListLayout")
    layout.Parent = page
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)

    Pages[name] = page
    TabButtons[name] = btn

    btn.MouseButton1Click:Connect(function()
        for n, p in pairs(Pages) do
            p.Visible = (n == name)
            TabButtons[n].BackgroundTransparency = (n == name) and 0 or 1
            TabButtons[n].BackgroundColor3 = (n == name) and Color3.fromRGB(35, 40, 55) or Color3.fromRGB(25, 28, 38)
            TabButtons[n].TextColor3 = (n == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
        end
    end)
    return page
end

local function createSection(parent, titleText)
    local s = Instance.new("TextLabel")
    s.Size = UDim2.new(1, 0, 0, 22)
    s.BackgroundTransparency = 1
    s.Text = titleText
    s.TextColor3 = Color3.fromRGB(140, 140, 160)
    s.TextSize = 11
    s.Font = Enum.Font.GothamBold
    s.TextXAlignment = Enum.TextXAlignment.Left
    s.Parent = parent
    return s
end

local function createToggle(parent, title, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sw = Instance.new("TextButton")
    sw.Parent = row
    sw.Size = UDim2.new(0, 42, 0, 22)
    sw.Position = UDim2.new(1, -52, 0.5, -11)
    sw.BackgroundColor3 = default and Color3.fromRGB(90, 60, 200) or Color3.fromRGB(50, 50, 65)
    sw.Text = ""
    sw.BorderSizePixel = 0
    local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(1, 0); sc.Parent = sw

    local dot = Instance.new("Frame")
    dot.Parent = sw
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1, 0); dc.Parent = dot

    local state = default
    sw.MouseButton1Click:Connect(function()
        state = not state
        sw.BackgroundColor3 = state and Color3.fromRGB(90, 60, 200) or Color3.fromRGB(50, 50, 65)
        dot.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        callback(state)
    end)
    return row
end

local function createSlider(parent, title, min, max, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.Size = UDim2.new(0.6, 0, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local vLbl = Instance.new("TextLabel")
    vLbl.Parent = row
    vLbl.Size = UDim2.new(0.3, 0, 0, 20)
    vLbl.Position = UDim2.new(0.65, 0, 0, 4)
    vLbl.BackgroundTransparency = 1
    vLbl.Text = tostring(default)
    vLbl.TextColor3 = Color3.fromRGB(150, 120, 255)
    vLbl.TextSize = 12
    vLbl.Font = Enum.Font.GothamBold
    vLbl.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("Frame")
    bar.Parent = row
    bar.Size = UDim2.new(1, -24, 0, 6)
    bar.Position = UDim2.new(0, 12, 1, -16)
    bar.BackgroundColor3 = Color3.fromRGB(45, 48, 60)
    bar.BorderSizePixel = 0
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1, 0); bc.Parent = bar

    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(120, 90, 220)
    fill.BorderSizePixel = 0
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1, 0); fc.Parent = fill

    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    bar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            vLbl.Text = tostring(val)
            callback(val)
        end
    end)
    return row
end--[[ MANIC HUB | PARTE 4/8 - Color Picker ]]

local function createColorPicker(parent, title, defaultColor, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
    btn.BackgroundTransparency = 0.3
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Parent = btn
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local prev = Instance.new("Frame")
    prev.Parent = btn
    prev.Size = UDim2.new(0, 24, 0, 24)
    prev.Position = UDim2.new(1, -34, 0.5, -12)
    prev.BackgroundColor3 = defaultColor
    prev.BorderSizePixel = 0
    local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(0, 5); pc.Parent = prev

    btn.MouseButton1Click:Connect(function()
        -- ===== POPUP =====
        local pop = Instance.new("Frame")
        pop.Size = UDim2.new(0, 500, 0, 280)
        pop.Position = UDim2.new(0.5, -250, 0.5, -140)
        pop.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
        pop.BorderSizePixel = 0
        pop.ZIndex = 200
        pop.Parent = ScreenGui
        local ppc = Instance.new("UICorner"); ppc.CornerRadius = UDim.new(0, 12); ppc.Parent = pop
        makeDraggable(pop)

        local title2 = Instance.new("TextLabel")
        title2.Parent = pop
        title2.Size = UDim2.new(1, -20, 0, 26)
        title2.Position = UDim2.new(0, 15, 0, 10)
        title2.BackgroundTransparency = 1
        title2.Text = "Map Color"
        title2.TextColor3 = Color3.fromRGB(255, 255, 255)
        title2.TextSize = 15
        title2.Font = Enum.Font.GothamBold
        title2.TextXAlignment = Enum.TextXAlignment.Left

        -- HSV square
        local sv = Instance.new("ImageLabel")
        sv.Parent = pop
        sv.Size = UDim2.new(0, 260, 0, 180)
        sv.Position = UDim2.new(0, 15, 0, 45)
        sv.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        sv.Image = "rbxassetid://4155801252"
        sv.BorderSizePixel = 0
        sv.ZIndex = 201
        local svc = Instance.new("UICorner"); svc.CornerRadius = UDim.new(0, 4); svc.Parent = sv

        local cursor = Instance.new("Frame")
        cursor.Parent = sv
        cursor.Size = UDim2.new(0, 10, 0, 10)
        cursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        cursor.BorderSizePixel = 2
        cursor.BorderColor3 = Color3.fromRGB(0, 0, 0)
        cursor.ZIndex = 202
        local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(1, 0); cc.Parent = cursor

        -- Hue bar
        local hueBar = Instance.new("ImageLabel")
        hueBar.Parent = pop
        hueBar.Size = UDim2.new(0, 18, 0, 180)
        hueBar.Position = UDim2.new(0, 285, 0, 45)
        hueBar.BackgroundTransparency = 1
        hueBar.Image = "rbxassetid://6020205287"
        hueBar.ZIndex = 201

        local hCursor = Instance.new("Frame")
        hCursor.Parent = hueBar
        hCursor.Size = UDim2.new(1, 4, 0, 4)
        hCursor.Position = UDim2.new(0, -2, 0, -2)
        hCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hCursor.BorderSizePixel = 2
        hCursor.BorderColor3 = Color3.fromRGB(0, 0, 0)
        hCursor.ZIndex = 202

        -- Preview box
        local previewBox = Instance.new("Frame")
        previewBox.Parent = pop
        previewBox.Size = UDim2.new(0, 40, 0, 40)
        previewBox.Position = UDim2.new(0, 430, 0, 230)
        previewBox.BackgroundColor3 = defaultColor
        previewBox.BorderSizePixel = 0
        previewBox.ZIndex = 201
        local pbc = Instance.new("UICorner"); pbc.CornerRadius = UDim.new(0, 6); pbc.Parent = previewBox

        -- Inputs (Hex, R, G, B)
        local inputs = {}
        local labels = {"Hex", "Red", "Green", "Blue"}
        local yPos = 45
        for i, lab in ipairs(labels) do
            local box = Instance.new("TextBox")
            box.Parent = pop
            box.Size = UDim2.new(0, 130, 0, 28)
            box.Position = UDim2.new(0, 315, 0, yPos)
            box.BackgroundColor3 = Color3.fromRGB(30, 33, 42)
            box.TextColor3 = Color3.fromRGB(255, 255, 255)
            box.TextSize = 13
            box.Font = Enum.Font.GothamBold
            box.Text = (i == 1) and "#ffffff" or "255"
            box.BorderSizePixel = 0
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.ZIndex = 201
            local boxc = Instance.new("UICorner"); boxc.CornerRadius = UDim.new(0, 5); boxc.Parent = box
            local pad = Instance.new("UIPadding"); pad.Parent = box; pad.PaddingLeft = UDim.new(0, 10)

            local labL = Instance.new("TextLabel")
            labL.Parent = pop
            labL.Size = UDim2.new(0, 80, 0, 28)
            labL.Position = UDim2.new(0, 455, 0, yPos)
            labL.BackgroundTransparency = 1
            labL.Text = lab
            labL.TextColor3 = Color3.fromRGB(140, 140, 160)
            labL.TextSize = 12
            labL.Font = Enum.Font.Gotham
            labL.TextXAlignment = Enum.TextXAlignment.Left
            labL.ZIndex = 201

            inputs[lab] = box
            yPos = yPos + 34
        end

        -- Cancel / Apply
        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Parent = pop
        cancelBtn.Size = UDim2.new(0, 200, 0, 36)
        cancelBtn.Position = UDim2.new(0, 15, 1, -50)
        cancelBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
        cancelBtn.Text = "Cancel"
        cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        cancelBtn.TextSize = 13
        cancelBtn.Font = Enum.Font.GothamBold
        cancelBtn.BorderSizePixel = 0
        cancelBtn.ZIndex = 201
        local cbc = Instance.new("UICorner"); cbc.CornerRadius = UDim.new(0, 6); cbc.Parent = cancelBtn

        local applyBtn = Instance.new("TextButton")
        applyBtn.Parent = pop
        applyBtn.Size = UDim2.new(0, 260, 0, 36)
        applyBtn.Position = UDim2.new(1, -275, 1, -50)
        applyBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 160)
        applyBtn.Text = "Apply"
        applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        applyBtn.TextSize = 13
        applyBtn.Font = Enum.Font.GothamBold
        applyBtn.BorderSizePixel = 0
        applyBtn.ZIndex = 201
        local abc = Instance.new("UICorner"); abc.CornerRadius = UDim.new(0, 6); abc.Parent = applyBtn

        -- State
        local h, s, v = 0, 1, 1
        local currentColor = defaultColor
        if defaultColor.R > 0 or defaultColor.G > 0 or defaultColor.B > 0 then
            h, s, v = Color3.toHSV(defaultColor)
        end

        local function updateFromHSV()
            currentColor = Color3.fromHSV(h, s, v)
            sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            previewBox.BackgroundColor3 = currentColor
            inputs["Hex"].Text = "#" .. string.format("%02x%02x%02x", math.floor(currentColor.R*255), math.floor(currentColor.G*255), math.floor(currentColor.B*255))
            inputs["Red"].Text = tostring(math.floor(currentColor.R*255))
            inputs["Green"].Text = tostring(math.floor(currentColor.G*255))
            inputs["Blue"].Text = tostring(math.floor(currentColor.B*255))
            cursor.Position = UDim2.new(s, -5, 1 - v, -5)
            hCursor.Position = UDim2.new(0, -2, h, -2)
        end
        updateFromHSV()

        -- Drag no square
        local svDrag = false
        sv.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then svDrag = true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then svDrag = false end end)
        UserInputService.InputChanged:Connect(function(i)
            if svDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                s = math.clamp((i.Position.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((i.Position.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
                updateFromHSV()
            end
        end)

        -- Drag na hue bar
        local hDrag = false
        hueBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then hDrag = true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then hDrag = false end end)
        UserInputService.InputChanged:Connect(function(i)
            if hDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                h = math.clamp((i.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
                updateFromHSV()
            end
        end)

        -- Input handlers
        inputs["Hex"].FocusLost:Connect(function()
            local hex = inputs["Hex"].Text:gsub("#", "")
            local r = tonumber(hex:sub(1,2), 16) or 255
            local g = tonumber(hex:sub(3,4), 16) or 255
            local b = tonumber(hex:sub(5,6), 16) or 255
            currentColor = Color3.fromRGB(r, g, b)
            h, s, v = Color3.toHSV(currentColor)
            updateFromHSV()
        end)
        for _, lab in ipairs({"Red", "Green", "Blue"}) do
            inputs[lab].FocusLost:Connect(function()
                local r = tonumber(inputs["Red"].Text) or 255
                local g = tonumber(inputs["Green"].Text) or 255
                local b = tonumber(inputs["Blue"].Text) or 255
                currentColor = Color3.fromRGB(r, g, b)
                h, s, v = Color3.toHSV(currentColor)
                updateFromHSV()
            end)
        end

        cancelBtn.MouseButton1Click:Connect(function() pop:Destroy() end)
        applyBtn.MouseButton1Click:Connect(function()
            prev.BackgroundColor3 = currentColor
            callback(currentColor)
            pop:Destroy()
        end)
    end)
    return btn
    end--[[ MANIC HUB | PARTE 5/8 - Skybox ]]

local SkyPage = createTab("Skybox", "☁")
createSection(SkyPage, "SKYBOXES DISPONÍVEIS")

local SkyIDs = {
    {name = "Cinematic", id = "8808550143"},
    {name = "Night",     id = "13107361022"},
    {name = "Blue Sky",  id = "570557337"},
    {name = "Sky 4",     id = "570559352"},
    {name = "Galaxy",    id = "8735253332"},
    {name = "Nebula",    id = "10256505900"},
    {name = "Tropical",  id = "566612745"},
    {name = "Aurora",    id = "87779981190120"},
    {name = "Dark",      id = "138907351102721"},
    {name = "Fantasy",   id = "92363876322534"},
    {name = "Desert",    id = "5952679029"},
}

local function applySkybox(assetId)
    pcall(function()
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then v:Destroy() end
        end
        local sky = Instance.new("Sky")
        sky.Name = "Manic_Sky"
        sky.SkyboxBk = "rbxassetid://" .. assetId
        sky.SkyboxDn = "rbxassetid://" .. assetId
        sky.SkyboxFt = "rbxassetid://" .. assetId
        sky.SkyboxLf = "rbxassetid://" .. assetId
        sky.SkyboxRt = "rbxassetid://" .. assetId
        sky.SkyboxUp = "rbxassetid://" .. assetId
        sky.Parent = Lighting
    end)
end

for _, s in ipairs(SkyIDs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
    btn.BackgroundTransparency = 0.2
    btn.Text = "  " .. s.name
    btn.TextColor3 = Color3.fromRGB(230, 230, 240)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = SkyPage
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        applySkybox(s.id)
        Flags.Skybox = s.name
    end)
end

createSection(SkyPage, "REMOVER SKYBOX")
local removeBtn = Instance.new("TextButton")
removeBtn.Size = UDim2.new(1, 0, 0, 32)
removeBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
removeBtn.Text = "  ❌ Remover Skybox"
removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
removeBtn.TextSize = 13
removeBtn.Font = Enum.Font.GothamBold
removeBtn.TextXAlignment = Enum.TextXAlignment.Left
removeBtn.BorderSizePixel = 0
removeBtn.Parent = SkyPage
local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 6); rc.Parent = removeBtn
removeBtn.MouseButton1Click:Connect(function()
    pcall(function()
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then v:Destroy() end
        end
    end)
end)--[[ MANIC HUB | PARTE 6/8 - Bola e Mapa ]]

local function getBall()
    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("BasePart") then
            local n = o.Name:lower()
            if n == "ball" or n == "bola" or n:find("football") or n:find("soccer") then return o end
        end
    end
end

-- ===== ABA BOLA =====
local BallPage = createTab("Ball", "●")
createSection(BallPage, "APARÊNCIA DA BOLA")

local BallColor = Color3.fromRGB(255, 255, 255)
createToggle(BallPage, "Mudar Cor da Bola", false, function(a) Flags.BallColorActive = a end)
createColorPicker(BallPage, "Cor da Bola", BallColor, function(c)
    BallColor = c
    Flags.BallColor = c
end)
createToggle(BallPage, "Fogo na Bola", false, function(a) Flags.BallFire = a end)

createSection(BallPage, "TRAIL DA BOLA")
local TrailEnabled, TrailColor, TrailWidth = false, Color3.fromRGB(120, 90, 220), 2
local function updateTrail()
    local ball = getBall(); if not ball then return end
    local t = ball:FindFirstChild("Manic_BallTrail")
    if TrailEnabled then
        if not t then
            t = Instance.new("Trail")
            t.Name = "Manic_BallTrail"
            local a0 = Instance.new("Attachment", ball); a0.Name = "Manic_A0"
            local a1 = Instance.new("Attachment", ball); a1.Name = "Manic_A1"
            a1.Position = Vector3.new(0, 0, 0.1)
            t.Attachment0 = a0; t.Attachment1 = a1
            t.Lifetime = 0.5
            t.Parent = ball
        end
        t.Color = ColorSequence.new(TrailColor)
        t.WidthScale = NumberSequence.new(TrailWidth / 10)
    elseif t then
        t:Destroy()
    end
end
createToggle(BallPage, "Trail na Bola", false, function(a) TrailEnabled = a; updateTrail() end)
createColorPicker(BallPage, "Cor do Trail", TrailColor, function(c) TrailColor = c; updateTrail() end)
createSlider(BallPage, "Largura do Trail", 1, 10, 2, function(v) TrailWidth = v; updateTrail() end)

-- ===== ABA MAPA =====
local MapPage = createTab("Map Color", "🎨")
createSection(MapPage, "COR DO MAPA (Terreno)")

local MapColor = Color3.fromRGB(80, 180, 80)
local function applyMapColor(c)
    MapColor = c
    pcall(function()
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain:SetMaterialColor(Enum.Material.Grass, c)
        end
    end)
end
createColorPicker(MapPage, "Map Color (Grama)", MapColor, applyMapColor)

createSection(MapPage, "APLICAR AUTOMATICAMENTE")
createToggle(MapPage, "Aplicar em todos terrenos", false, function(a)
    Flags.MapAllTerrain = a
end)--[[ MANIC HUB | PARTE 7/8 - Jogabilidade ]]

local GamePage = createTab("GK / Jogabilidade", "🛡")
createSection(GamePage, "AUTO DRIVE / GOLEIRO")

local Character, Humanoid, RootPart
local function updateChar()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end
updateChar()
LocalPlayer.CharacterAdded:Connect(updateChar)

-- AUTO DRIVE
local AutoDiveEnabled = false
local AutoDiveCooldown = 0
local function DoAutoDive(ball)
    if not AutoDiveEnabled or not ball or not Character or not Humanoid or not RootPart then return end
    if os.clock() < AutoDiveCooldown then return end
    local v = ball.AssemblyLinearVelocity
    if v.Magnitude < 12 then return end
    local toMe = RootPart.Position - ball.Position
    if v.Unit:Dot(toMe.Unit) <= 0.35 then return end
    if (ball.Position - RootPart.Position).Magnitude > 30 then return end
    local pred = ball.Position + v * 0.3
    local diff = pred - RootPart.Position
    local flat = Vector3.new(diff.X, 0, diff.Z)
    if flat.Magnitude > 0.5 and flat.Magnitude < 15 then
        Humanoid:Move(flat.Unit, false)
        Humanoid.WalkSpeed = 30
        for _, name in ipairs({"LeftFoot", "RightFoot", "Left Leg", "Right Leg"}) do
            local f = Character:FindFirstChild(name)
            if f and firetouchinterest then firetouchinterest(f, ball, 0); firetouchinterest(f, ball, 1) end
        end
        if ball.Position.Y > RootPart.Position.Y + 3 and Humanoid.FloorMaterial ~= Enum.Material.Air then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        AutoDiveCooldown = os.clock() + 0.8
    end
end
createToggle(GamePage, "Auto Drive (Goleiro)", false, function(a) AutoDiveEnabled = a end)

createSection(GamePage, "HAMBOLO")
local HamboloEnabled = false
local HamboloPower = 50
local function DoHambolo(ball)
    if not HamboloEnabled or not ball or not Character or not Humanoid or not RootPart then return end
    if not firetouchinterest then return end
    local head = Character:FindFirstChild("Head")
    local torso = Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")
    if not head and not torso then return end
    local headY = RootPart.Position.Y + 3.5
    local v = ball.AssemblyLinearVelocity
    local dist = (ball.Position - RootPart.Position).Magnitude
    if v.Y < 2 and ball.Position.Y < headY and dist <= 6 then
        local toMe = RootPart.Position - ball.Position
        local flat = Vector3.new(toMe.X, 0, toMe.Z)
        ball.AssemblyLinearVelocity = (flat.Magnitude > 0.1) and (flat.Unit * 3 + Vector3.new(0, HamboloPower, 0)) or Vector3.new(0, HamboloPower, 0)
        ball.AssemblyAngularVelocity = Vector3.new(0, 2, 0)
    end
    if ball.Position.Y >= RootPart.Position.Y + 2 and ball.Position.Y <= headY + 1.5 and dist <= 8 then
        for _, p in ipairs({head, torso}) do
            if p then firetouchinterest(p, ball, 0); firetouchinterest(p, ball, 1) end
        end
        if v.Y < HamboloPower * 0.4 then
            ball.AssemblyLinearVelocity = Vector3.new(v.X * 0.6, HamboloPower, v.Z * 0.6)
        end
        if Humanoid.MoveDirection.Magnitude == 0 then
            Humanoid:Move(RootPart.CFrame.LookVector, false)
        end
    end
end
createToggle(GamePage, "Hambolo (Peito)", false, function(a) HamboloEnabled = a end)
createSlider(GamePage, "Força do Hambolo", 20, 80, 50, function(v) HamboloPower = v end)

createSection(GamePage, "AUTO BALL / AUTO GOAL")
local AutoBallEnabled = false
local function DoAutoBall()
    if not AutoBallEnabled then return end
    local ball = getBall(); if not ball or not RootPart then return end
    if firetouchinterest then
        local rf = Character:FindFirstChild("RightFoot") or Character:FindFirstChild("Right Leg")
        if rf then firetouchinterest(rf, ball, 0); firetouchinterest(rf, ball, 1) end
    end
    local goal = Workspace:FindFirstChild("Goal") or Workspace:FindFirstChild("Gol")
    if goal then
        local dir = (goal.Position - ball.Position).Unit
        pcall(function() ball.AssemblyLinearVelocity = dir * 80 + Vector3.new(0, 15, 0) end)
    end
end
createToggle(GamePage, "Auto Ball", false, function(a)
    AutoBallEnabled = a
    AutoBallBtn.BackgroundColor3 = a and Color3.fromRGB(90, 60, 200) or Color3.fromRGB(20, 20, 25)
end)

local AutoGoalEnabled = false
local function DoAutoGoal()
    if not AutoGoalEnabled then return end
    local ball = getBall(); if not ball then return end
    local goal = Workspace:FindFirstChild("Goal") or Workspace:FindFirstChild("Gol")
    if not goal then return end
    local dir = (goal.Position - ball.Position).Unit
    pcall(function() ball.AssemblyLinearVelocity = dir * 100 + Vector3.new(0, 20, 0) end)
end
createToggle(GamePage, "Auto Goal", false, function(a) AutoGoalEnabled = a end)

createSection(GamePage, "REACH / HITBOX")
createToggle(GamePage, "Reach (Hitbox)", false, function(a)
    if not Character then return end
    local h = Character:FindFirstChild("Head")
    if h then
        if a then h.Size = Vector3.new(10, 10, 10); h.Transparency = 0.5
        else h.Size = Vector3.new(2, 1, 1); h.Transparency = 0 end
    end
end)

createSection(GamePage, "ANTI-CHEAT (AC)")
createToggle(GamePage, "Anti-Cheat (AC)", false, function(a)
    Flags.AC = a
    if a and Humanoid then
        Flags.OriginalWalkSpeed = Flags.OriginalWalkSpeed or Humanoid.WalkSpeed
        Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if Flags.AC and Humanoid.WalkSpeed > 30 then Humanoid.WalkSpeed = Flags.OriginalWalkSpeed end
        end)
    end
end)--[[ MANIC HUB | PARTE 8/8 - Visual, Config e Loops ]]

-- ===== ABA VISUAL =====
local VisualPage = createTab("Visual", "👁")
createSection(VisualPage, "TELA / CÂMERA")

local StretchConn = nil
createToggle(VisualPage, "Tela Esticada", false, function(a)
    if a and not StretchConn then
        local cam = Workspace.CurrentCamera
        StretchConn = RunService.RenderStepped:Connect(function()
            cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.67, 0, 0, 0, 1)
        end)
    elseif not a and StretchConn then
        StretchConn:Disconnect(); StretchConn = nil
    end
end)

createSection(VisualPage, "GRÁFICOS")
createToggle(VisualPage, "Gráficos (FPS Boost)", false, function(a)
    if a then
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
            Lighting.Brightness = 1
            if setfpscap then setfpscap(999) end
        end)
    else
        pcall(function()
            Lighting.GlobalShadows = true
            Lighting.Brightness = 2
            if setfpscap then setfpscap(60) end
        end)
    end
end)

-- ===== ABA CONFIG =====
local ConfigPage = createTab("Settings", "⚙")
createSection(ConfigPage, "PAINEL")

local isMinimized = false
createToggle(ConfigPage, "Minimizar Painel", false, function(a)
    isMinimized = a
    if a then
        Sidebar.Visible = false
        ContentFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 620, 0, 38)
    else
        Sidebar.Visible = true
        ContentFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 620, 0, 380)
    end
end)

createSection(ConfigPage, "KEYBIND")
local keyLbl = Instance.new("TextLabel")
keyLbl.Size = UDim2.new(1, 0, 0, 34)
keyLbl.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
keyLbl.BackgroundTransparency = 0.3
keyLbl.Text = "UI Toggle Keybind:  LeftShift"
keyLbl.TextColor3 = Color3.fromRGB(200, 200, 220)
keyLbl.TextSize = 12
keyLbl.Font = Enum.Font.GothamBold
keyLbl.BorderSizePixel = 0
keyLbl.Parent = ConfigPage
local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(0, 6); kc.Parent = keyLbl

-- ===== LOOP PRINCIPAL =====
RunService.Heartbeat:Connect(function()
    local ball = getBall()
    if ball then
        if AutoDiveEnabled then DoAutoDive(ball) end
        if HamboloEnabled then DoHambolo(ball) end
        if AutoBallEnabled then DoAutoBall() end
        if AutoGoalEnabled then DoAutoGoal() end

        if Flags.BallColorActive and Flags.BallColor then
            pcall(function() ball.Color = Flags.BallColor end)
        end

        if Flags.BallFire then
            if not ball:FindFirstChild("Manic_BallFire") then
                local f = Instance.new("Fire")
                f.Name = "Manic_BallFire"
                f.Size = 5; f.Heat = 10
                f.Color = Color3.fromRGB(255, 100, 0)
                f.SecondaryColor = Color3.fromRGB(255, 200, 0)
                f.Parent = ball
            end
        else
            local f = ball:FindFirstChild("Manic_BallFire")
            if f then f:Destroy() end
        end

        -- Atualiza trail se estiver ativo
        if TrailEnabled and not ball:FindFirstChild("Manic_BallTrail") then
            updateTrail()
        end
    end
end)

-- ===== FPS LOOP =====
RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    local now = tick()
    if now - fpsTime >= 1 then
        FpsBox.Text = "FPS " .. fpsCount
        fpsCount = 0
        fpsTime = now
    end
end)

-- ===== TOGGLE MENU (LeftShift) =====
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.LeftShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ===== BOTÕES DE ABRIR/FECHAR =====
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Botão flutuante Auto Ball
AutoBallBtn.MouseButton1Click:Connect(function()
    AutoBallEnabled = not AutoBallEnabled
    AutoBallBtn.BackgroundColor3 = AutoBallEnabled and Color3.fromRGB(90, 60, 200) or Color3.fromRGB(20, 20, 25)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Auto Ball",
            Text = AutoBallEnabled and "Ativado!" or "Desativado!",
            Duration = 2
        })
    end)
end)

-- ===== ABA PADRÃO =====
TabButtons["Skybox"].BackgroundTransparency = 0
TabButtons["Skybox"].BackgroundColor3 = Color3.fromRGB(35, 40, 55)
TabButtons["Skybox"].TextColor3 = Color3.fromRGB(255, 255, 255)
Pages["Skybox"].Visible = true

print("[MANIC HUB] Carregado com sucesso!")
