--[[ MANIC HUB v1.0 - Soccer Edition | PARTE 1/3 ]]
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
local ManicAssetId = "rbxassetid://80947706998238"
local DarkFont = Enum.Font.Creepster

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "MANIC HUB - Executado!",
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

-- ============================================
-- DRAG
-- ============================================
local function makeDraggable(g)
    local dragging, dragInput, dragStart, startPos
    g.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = g.Position
            input.Changed:Connect(function(s)
                if s.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
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

-- ============================================
-- FPS COUNTER
-- ============================================
local FpsContainer = Instance.new("Frame")
FpsContainer.Parent = ScreenGui
FpsContainer.Size = UDim2.new(0, 220, 0, 30)
FpsContainer.Position = UDim2.new(0, 10, 0, 10)
FpsContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
FpsContainer.BackgroundTransparency = 0.35
FpsContainer.BorderSizePixel = 0
FpsContainer.ZIndex = 10
local FpsCorner = Instance.new("UICorner"); FpsCorner.CornerRadius = UDim.new(0, 8); FpsCorner.Parent = FpsContainer

local FpsLabel = Instance.new("TextLabel")
FpsLabel.Parent = FpsContainer
FpsLabel.Size = UDim2.new(1, -10, 1, 0)
FpsLabel.Position = UDim2.new(0, 5, 0, 0)
FpsLabel.BackgroundTransparency = 1
FpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsLabel.TextSize = 16
FpsLabel.Font = Enum.Font.SourceSansBold
FpsLabel.Text = "FPS: 0.0/s   0.0 ms"
FpsLabel.TextStrokeTransparency = 0.6
FpsLabel.ZIndex = 11
makeDraggable(FpsContainer)

-- ============================================
-- BOTÃO FLUTUANTE AUTO BALL
-- ============================================
local AutoBallBtn = Instance.new("TextButton")
AutoBallBtn.Parent = ScreenGui
AutoBallBtn.Size = UDim2.new(0, 55, 0, 55)
AutoBallBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
AutoBallBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
AutoBallBtn.Text = "⚽"
AutoBallBtn.TextSize = 28
AutoBallBtn.BorderSizePixel = 0
AutoBallBtn.ZIndex = 15
local ABCorner = Instance.new("UICorner"); ABCorner.CornerRadius = UDim.new(0, 12); ABCorner.Parent = AutoBallBtn
makeDraggable(AutoBallBtn)

-- ============================================
-- PAINEL PRINCIPAL
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 500, 0, 380)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 6, 12)
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.BorderSizePixel = 0
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 14); MainCorner.Parent = MainFrame
makeDraggable(MainFrame)

local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Parent = MainFrame
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = ManicAssetId
BackgroundImage.ImageTransparency = 0.25
BackgroundImage.ZIndex = 0

-- Topbar
local TopBar = Instance.new("TextLabel")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
TopBar.BackgroundTransparency = 0.3
TopBar.Text = "  MANIC HUB  •  Soccer Edition"
TopBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TopBar.TextSize = 14
TopBar.Font = Enum.Font.GothamBold
TopBar.TextXAlignment = Enum.TextXAlignment.Left
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 5

local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TopBar
MinBtn.Size = UDim2.new(0, 30, 0, 25)
MinBtn.Position = UDim2.new(1, -65, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 6
local MinC = Instance.new("UICorner"); MinC.CornerRadius = UDim.new(0, 5); MinC.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.Size = UDim2.new(0, 30, 0, 25)
CloseBtn.Position = UDim2.new(1, -32, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 6
local ClC = Instance.new("UICorner"); ClC.CornerRadius = UDim.new(0, 5); ClC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Size = UDim2.new(0, 135, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(5, 3, 8)
Sidebar.BackgroundTransparency = 0.1
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
local SbC = Instance.new("UICorner"); SbC.CornerRadius = UDim.new(0, 14); SbC.Parent = Sidebar

local TabContainer = Instance.new("Frame")
TabContainer.Parent = Sidebar
TabContainer.Size = UDim2.new(1, -16, 1, -70)
TabContainer.Position = UDim2.new(0, 8, 0, 8)
TabContainer.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout")
TabList.Parent = TabContainer
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 5)

-- Perfil
local PlayerFrame = Instance.new("Frame")
PlayerFrame.Parent = Sidebar
PlayerFrame.Size = UDim2.new(1, -12, 0, 44)
PlayerFrame.Position = UDim2.new(0, 6, 1, -52)
PlayerFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
PlayerFrame.BorderSizePixel = 0
PlayerFrame.ZIndex = 4
local PlC = Instance.new("UICorner"); PlC.CornerRadius = UDim.new(0, 8); PlC.Parent = PlayerFrame

local PlayerAvatar = Instance.new("ImageLabel")
PlayerAvatar.Parent = PlayerFrame
PlayerAvatar.Size = UDim2.new(0, 34, 0, 34)
PlayerAvatar.Position = UDim2.new(0, 5, 0.5, -17)
PlayerAvatar.BackgroundTransparency = 1
pcall(function() PlayerAvatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)
PlayerAvatar.ZIndex = 5
local AvC = Instance.new("UICorner"); AvC.CornerRadius = UDim.new(1, 0); AvC.Parent = PlayerAvatar

local PlayerName = Instance.new("TextLabel")
PlayerName.Parent = PlayerFrame
PlayerName.Size = UDim2.new(1, -48, 1, 0)
PlayerName.Position = UDim2.new(0, 44, 0, 0)
PlayerName.BackgroundTransparency = 1
PlayerName.Text = LocalPlayer.Name
PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerName.TextSize = 11
PlayerName.Font = Enum.Font.GothamBold
PlayerName.TextXAlignment = Enum.TextXAlignment.Left
PlayerName.TextTruncate = Enum.TextTruncate.AtEnd
PlayerName.ZIndex = 5

-- Content
local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -145, 1, -45)
ContentFrame.Position = UDim2.new(0, 145, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 2

local Pages = {}
local TabButtons = {}

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
    btn.BackgroundTransparency = 0.2
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = DarkFont
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.ZIndex = 4
    btn.Parent = TabContainer
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(130, 0, 200)
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
            TabButtons[n].BackgroundColor3 = (n == name) and Color3.fromRGB(45, 20, 65) or Color3.fromRGB(15, 12, 22)
        end
    end)
    return page
end

-- ============================================
-- COMPONENTES DE UI
-- ============================================
local function createToggle(parent, title, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 13
    lbl.Font = DarkFont
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sw = Instance.new("TextButton")
    sw.Parent = row
    sw.Size = UDim2.new(0, 40, 0, 20)
    sw.Position = UDim2.new(1, -48, 0.5, -10)
    sw.BackgroundColor3 = default and Color3.fromRGB(130, 0, 200) or Color3.fromRGB(25, 25, 32)
    sw.Text = ""
    sw.BorderSizePixel = 0
    local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(1, 0); sc.Parent = sw

    local dot = Instance.new("Frame")
    dot.Parent = sw
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1, 0); dc.Parent = dot

    local state = default
    sw.MouseButton1Click:Connect(function()
        state = not state
        sw.BackgroundColor3 = state and Color3.fromRGB(130, 0, 200) or Color3.fromRGB(25, 25, 32)
        dot.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        callback(state)
    end)
    return row
end

local function createSlider(parent, title, min, max, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.Size = UDim2.new(0.6, 0, 0, 22)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 13
    lbl.Font = DarkFont
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local vLbl = Instance.new("TextLabel")
    vLbl.Parent = row
    vLbl.Size = UDim2.new(0.3, 0, 0, 22)
    vLbl.Position = UDim2.new(0.65, 0, 0, 4)
    vLbl.BackgroundTransparency = 1
    vLbl.Text = tostring(default)
    vLbl.TextColor3 = Color3.fromRGB(130, 0, 200)
    vLbl.TextSize = 13
    vLbl.Font = Enum.Font.GothamBold
    vLbl.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("Frame")
    bar.Parent = row
    bar.Size = UDim2.new(1, -20, 0, 6)
    bar.Position = UDim2.new(0, 10, 1, -14)
    bar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    bar.BorderSizePixel = 0
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1, 0); bc.Parent = bar

    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(130, 0, 200)
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
end

local function createColorButton(parent, title, defaultColor, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
    btn.BackgroundTransparency = 0.3
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Parent = btn
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 13
    lbl.Font = DarkFont
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local prev = Instance.new("Frame")
    prev.Parent = btn
    prev.Size = UDim2.new(0, 20, 0, 20)
    prev.Position = UDim2.new(1, -30, 0.5, -10)
    prev.BackgroundColor3 = defaultColor
    prev.BorderSizePixel = 0
    local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(0, 4); pc.Parent = prev

    local r, g, b = math.floor(defaultColor.R*255), math.floor(defaultColor.G*255), math.floor(defaultColor.B*255)

    btn.MouseButton1Click:Connect(function()
        local popup = Instance.new("Frame")
        popup.Size = UDim2.new(0, 240, 0, 200)
        popup.Position = UDim2.new(0.5, -120, 0.5, -100)
        popup.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        popup.BorderSizePixel = 0
        popup.ZIndex = 100
        popup.Parent = ScreenGui
        local ppc = Instance.new("UICorner"); ppc.CornerRadius = UDim.new(0, 10); ppc.Parent = popup

        local t2 = Instance.new("TextLabel")
        t2.Parent = popup
        t2.Size = UDim2.new(1, -20, 0, 25)
        t2.Position = UDim2.new(0, 10, 0, 5)
        t2.BackgroundTransparency = 1
        t2.Text = "Escolher Cor"
        t2.TextColor3 = Color3.fromRGB(255,255,255)
        t2.Font = Enum.Font.GothamBold
        t2.TextSize = 14

        createSlider(popup, "R", 0, 255, r, function(v) r = v end).Position = UDim2.new(0, 5, 0, 35)
        createSlider(popup, "G", 0, 255, g, function(v) g = v end).Position = UDim2.new(0, 5, 0, 90)
        createSlider(popup, "B", 0, 255, b, function(v) b = v end).Position = UDim2.new(0, 5, 0, 145)

        local apply = Instance.new("TextButton")
        apply.Size = UDim2.new(1, -10, 0, 25)
        apply.Position = UDim2.new(0, 5, 1, -30)
        apply.BackgroundColor3 = Color3.fromRGB(130, 0, 200)
        apply.Text = "Aplicar"
        apply.TextColor3 = Color3.fromRGB(255,255,255)
        apply.Font = Enum.Font.GothamBold
        apply.TextSize = 12
        apply.BorderSizePixel = 0
        apply.Parent = popup
        local ac = Instance.new("UICorner"); ac.CornerRadius = UDim.new(0, 6); ac.Parent = apply

        apply.MouseButton1Click:Connect(function()
            local col = Color3.fromRGB(r, g, b)
            prev.BackgroundColor3 = col
            callback(col)
            popup:Destroy()
        end)
    end)
    return btn
end--[[ MANIC HUB | PARTE 2/3 ]]

-- ============================================
-- ABA SKYBOX
-- ============================================
local SkyPage = createTab("Skybox")
local Skyboxes = {
    {name="Cinematic", bk="162001887", dn="161998893", ft="162001897", lf="162001904", rt="162001919", up="162001926"},
    {name="Sunset", bk="600832720", dn="600832804", ft="600833083", lf="600832889", rt="600833001", up="600833186"},
    {name="Night Sky", bk="13107361022"},
    {name="Blue Sky", bk="570557337"},
    {name="Galaxy", bk="8735253332"},
    {name="Nebula", bk="10256505900"},
    {name="Tropical", bk="566612745"},
    {name="Aurora", bk="87779981190120"},
    {name="Dark", bk="138907351102721"},
    {name="Fantasy", bk="92363876322534"},
    {name="Desert", bk="5952679029"},
}
for _, s in ipairs(Skyboxes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
    btn.BackgroundTransparency = 0.2
    btn.Text = "  " .. s.name
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 12
    btn.Font = DarkFont
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = SkyPage
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 5); c.Parent = btn
    btn.MouseButton1Click:Connect(function()
        pcall(function()
            for _, v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
            local sky = Instance.new("Sky")
            sky.SkyboxBk = "rbxassetid://" .. s.bk
            sky.SkyboxDn = "rbxassetid://" .. (s.dn or s.bk)
            sky.SkyboxFt = "rbxassetid://" .. (s.ft or s.bk)
            sky.SkyboxLf = "rbxassetid://" .. (s.lf or s.bk)
            sky.SkyboxRt = "rbxassetid://" .. (s.rt or s.bk)
            sky.SkyboxUp = "rbxassetid://" .. (s.up or s.bk)
            sky.Parent = Lighting
        end)
    end)
end

-- ============================================
-- UTILS DE BOLA
-- ============================================
local function getBall()
    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("BasePart") then
            local n = o.Name:lower()
            if n == "ball" or n == "bola" or n:find("football") or n:find("soccer") then return o end
        end
    end
end

-- ============================================
-- ABA BOLA
-- ============================================
local BallPage = createTab("Bola")
local BallColor = Color3.fromRGB(255,255,255)
createToggle(BallPage, "Mudar Cor da Bola", false, function(a) Flags.BallColorActive = a end)
createColorButton(BallPage, "Cor da Bola", BallColor, function(c) BallColor = c; Flags.BallColor = c end)
createToggle(BallPage, "Fogo na Bola", false, function(a) Flags.BallFire = a end)

local TrailEnabled, TrailColor, TrailWidth = false, Color3.fromRGB(130,0,200), 1
local function updateTrail()
    local ball = getBall(); if not ball then return end
    local t = ball:FindFirstChild("Manic_BallTrail")
    if TrailEnabled then
        if not t then
            t = Instance.new("Trail")
            t.Name = "Manic_BallTrail"
            local a0 = Instance.new("Attachment", ball); a0.Name = "Manic_A0"
            local a1 = Instance.new("Attachment", ball); a1.Name = "Manic_A1"; a1.Position = Vector3.new(0,0,0.1)
            t.Attachment0 = a0; t.Attachment1 = a1
            t.Parent = ball
        end
        t.Color = ColorSequence.new(TrailColor)
        t.WidthScale = NumberSequence.new(TrailWidth)
        t.Lifetime = 0.5
    elseif t then t:Destroy() end
end
createToggle(BallPage, "Trail na Bola", false, function(a) TrailEnabled = a; updateTrail() end)
createColorButton(BallPage, "Cor do Trail", TrailColor, function(c) TrailColor = c; updateTrail() end)
createSlider(BallPage, "Largura do Trail", 1, 10, 1, function(v) TrailWidth = v; updateTrail() end)

-- ============================================
-- ABA MAPA
-- ============================================
local MapPage = createTab("Mapa")
local MapColor = Color3.fromRGB(50,180,80)
createColorButton(MapPage, "Cor do Mapa (Grama)", MapColor, function(c)
    MapColor = c
    pcall(function()
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then terrain:SetMaterialColor(Enum.Material.Grass, c) end
    end)
end)

-- ============================================
-- ABA JOGABILIDADE
-- ============================================
local GamePage = createTab("Jogabilidade")

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
        for _, name in ipairs({"LeftFoot","RightFoot","Left Leg","Right Leg"}) do
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

-- HAMBOLO
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
        if v.Y < HamboloPower * 0.4 then ball.AssemblyLinearVelocity = Vector3.new(v.X*0.6, HamboloPower, v.Z*0.6) end
        if Humanoid.MoveDirection.Magnitude == 0 then Humanoid:Move(RootPart.CFrame.LookVector, false) end
    end
end
createToggle(GamePage, "Hambolo", false, function(a) HamboloEnabled = a end)
createSlider(GamePage, "Força do Hambolo", 20, 80, 50, function(v) HamboloPower = v end)

-- AUTO BALL
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
    AutoBallBtn.BackgroundColor3 = a and Color3.fromRGB(130,0,200) or Color3.fromRGB(10,10,14)
end)
AutoBallBtn.MouseButton1Click:Connect(function()
    AutoBallEnabled = not AutoBallEnabled
    AutoBallBtn.BackgroundColor3 = AutoBallEnabled and Color3.fromRGB(130,0,200) or Color3.fromRGB(10,10,14)
end)

-- AUTO GOAL
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

-- REACH
createToggle(GamePage, "Reach (Hitbox)", false, function(a)
    if not Character then return end
    local h = Character:FindFirstChild("Head")
    if h then
        if a then h.Size = Vector3.new(10,10,10); h.Transparency = 0.5
        else h.Size = Vector3.new(2,1,1); h.Transparency = 0 end
    end
end)--[[ MANIC HUB | PARTE 3/3 ]]

-- ============================================
-- ABA VISUAL
-- ============================================
local VisualPage = createTab("Visual")
local StretchConn = nil
createToggle(VisualPage, "Tela Esticada", false, function(a)
    if a and not StretchConn then
        local cam = Workspace.CurrentCamera
        StretchConn = RunService.RenderStepped:Connect(function()
            cam.CFrame = cam.CFrame * CFrame.new(0,0,0, 1,0,0, 0,0.67,0, 0,0,1)
        end)
    elseif not a and StretchConn then StretchConn:Disconnect(); StretchConn = nil end
end)

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

-- ============================================
-- ABA CONFIG
-- ============================================
local ConfigPage = createTab("Config")
createToggle(ConfigPage, "Minimizar Painel", false, function(a)
    if a then
        ContentFrame.Visible = false
        Sidebar.Visible = false
        MainFrame.Size = UDim2.new(0, 500, 0, 35)
    else
        ContentFrame.Visible = true
        Sidebar.Visible = true
        MainFrame.Size = UDim2.new(0, 500, 0, 380)
    end
end)

createToggle(ConfigPage, "Anti-Cheat (AC)", false, function(a)
    Flags.AC = a
    if a and Humanoid then
        Flags.OriginalWalkSpeed = Flags.OriginalWalkSpeed or Humanoid.WalkSpeed
        Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if Flags.AC and Humanoid.WalkSpeed > 30 then Humanoid.WalkSpeed = Flags.OriginalWalkSpeed end
        end)
    end
end)

-- ============================================
-- LOOP PRINCIPAL
-- ============================================
RunService.Heartbeat:Connect(function()
    local ball = getBall()
    if ball then
        if AutoDiveEnabled then DoAutoDive(ball) end
        if HamboloEnabled then DoHambolo(ball) end
        if AutoBallEnabled then DoAutoBall() end
        if AutoGoalEnabled then DoAutoGoal() end

        -- Cor da bola
        if Flags.BallColorActive and Flags.BallColor then
            pcall(function() ball.Color = Flags.BallColor end)
        end

        -- Fogo
        if Flags.BallFire then
            if not ball:FindFirstChild("Manic_BallFire") then
                local f = Instance.new("Fire")
                f.Name = "Manic_BallFire"; f.Size = 5; f.Heat = 10
                f.Color = Color3.fromRGB(255,100,0)
                f.SecondaryColor = Color3.fromRGB(255,200,0)
                f.Parent = ball
            end
        else
            local f = ball:FindFirstChild("Manic_BallFire")
            if f then f:Destroy() end
        end
    end
end)

-- ============================================
-- FPS COUNTER LOOP
-- ============================================
local fpsCount, lastTime = 0, tick()
RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    local now = tick()
    if now - lastTime >= 1 then
        FpsLabel.Text = string.format("FPS: %.1f/s   %.1f ms", fpsCount, (now - lastTime) * 1000 / fpsCount)
        fpsCount = 0
        lastTime = now
    end
end)

-- ============================================
-- TOGGLE MENU (LeftShift)
-- ============================================
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.LeftShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Aba padrão aberta
TabButtons["Skybox"].BackgroundColor3 = Color3.fromRGB(45, 20, 65)
Pages["Skybox"].Visible = true
