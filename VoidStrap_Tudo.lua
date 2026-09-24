--[[ MANIC HUB v1.0 - Soccer Edition ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- CONFIGURAÇÕES GERAIS E FLAGS
-- ==========================================
getgenv().ManicHub = getgenv().ManicHub or {}
local Flags = getgenv().ManicHub

local ManicAssetId = "rbxassetid://80947706998238"
local DarkFont = Enum.Font.Creepster

-- Notificação de boas-vindas
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "MANIC HUB - Executado!",
        Text = "Olá, " .. LocalPlayer.DisplayName .. "!",
        Duration = 5
    })
end)

-- Limpar GUI antiga
if CoreGui:FindFirstChild("ManicHub") then
    CoreGui.ManicHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.Name = "ManicHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true-- ==========================================
-- FUNÇÕES UTILITÁRIAS
-- ==========================================
local function makeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function(inputState)
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ==========================================
-- CONTADOR DE FPS
-- ==========================================
local FpsContainer = Instance.new("Frame")
FpsContainer.Name = "FPS_Counter"
FpsContainer.Parent = ScreenGui
FpsContainer.Size = UDim2.new(0, 220, 0, 30)
FpsContainer.Position = UDim2.new(0, 10, 0, 10)
FpsContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
FpsContainer.BackgroundTransparency = 0.35
FpsContainer.BorderSizePixel = 0
FpsContainer.ZIndex = 10

local FpsCorner = Instance.new("UICorner")
FpsCorner.CornerRadius = UDim.new(0, 8)
FpsCorner.Parent = FpsContainer

local FpsLabel = Instance.new("TextLabel")
FpsLabel.Parent = FpsContainer
FpsLabel.Size = UDim2.new(1, -10, 1, 0)
FpsLabel.Position = UDim2.new(0, 5, 0, 0)
FpsLabel.BackgroundTransparency = 1
FpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsLabel.TextSize = 16
FpsLabel.Font = Enum.Font.SourceSansBold
FpsLabel.TextXAlignment = Enum.TextXAlignment.Center
FpsLabel.Text = "FPS: 0.0/s   0.0 ms"
FpsLabel.TextStrokeTransparency = 0.6
FpsLabel.ZIndex = 11

makeDraggable(FpsContainer)-- ==========================================
-- BOTÃO FLUTUANTE (AUTO BALL)
-- ==========================================
local AutoBallBtn = Instance.new("TextButton")
AutoBallBtn.Name = "AutoBallBtn"
AutoBallBtn.Parent = ScreenGui
AutoBallBtn.Size = UDim2.new(0, 55, 0, 55)
AutoBallBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
AutoBallBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
AutoBallBtn.Text = "⚽"
AutoBallBtn.TextSize = 28
AutoBallBtn.BorderSizePixel = 0
AutoBallBtn.ZIndex = 15

local AutoBallCorner = Instance.new("UICorner")
AutoBallCorner.CornerRadius = UDim.new(0, 12)
AutoBallCorner.Parent = AutoBallBtn

makeDraggable(AutoBallBtn)

-- ==========================================
-- PAINEL PRINCIPAL
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 500, 0, 380)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 6, 12)
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.BorderSizePixel = 0

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

makeDraggable(MainFrame)

-- Imagem de Fundo
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Parent = MainFrame
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = ManicAssetId
BackgroundImage.ImageTransparency = 0.25
BackgroundImage.ZIndex = 0-- ==========================================
-- SIDEBAR
-- ==========================================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.Size = UDim2.new(0, 135, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(5, 3, 8)
Sidebar.BackgroundTransparency = 0.1
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 14)
SidebarCorner.Parent = Sidebar

local BrandLabel = Instance.new("TextLabel")
BrandLabel.Parent = Sidebar
BrandLabel.Size = UDim2.new(1, -10, 0, 35)
BrandLabel.Position = UDim2.new(0, 10, 0, 10)
BrandLabel.BackgroundTransparency = 1
BrandLabel.Text = "MANIC HUB"
BrandLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
BrandLabel.TextSize = 18
BrandLabel.Font = Enum.Font.GothamBold
BrandLabel.TextXAlignment = Enum.TextXAlignment.Left
BrandLabel.ZIndex = 5

local TabContainer = Instance.new("Frame")
TabContainer.Parent = Sidebar
TabContainer.Size = UDim2.new(1, -16, 0, 200)
TabContainer.Position = UDim2.new(0, 8, 0, 50)
TabContainer.BackgroundTransparency = 1

local TabList = Instance.new("UIListLayout")
TabList.Parent = TabContainer
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 6)

-- Perfil do Jogador
local PlayerFrame = Instance.new("Frame")
PlayerFrame.Name = "PlayerFrame"
PlayerFrame.Parent = Sidebar
PlayerFrame.Size = UDim2.new(1, -12, 0, 44)
PlayerFrame.Position = UDim2.new(0, 6, 1, -52)
PlayerFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
PlayerFrame.BackgroundTransparency = 0.1
PlayerFrame.BorderSizePixel = 0
PlayerFrame.ZIndex = 4

local PlayerCorner = Instance.new("UICorner")
PlayerCorner.CornerRadius = UDim.new(0, 8)
PlayerCorner.Parent = PlayerFrame

local PlayerAvatar = Instance.new("ImageLabel")
PlayerAvatar.Parent = PlayerFrame
PlayerAvatar.Size = UDim2.new(0, 34, 0, 34)
PlayerAvatar.Position = UDim2.new(0, 5, 0.5, -17)
PlayerAvatar.BackgroundTransparency = 1
PlayerAvatar.Image = Players:GetUserThumbnailAsync(
    LocalPlayer.UserId, 
    Enum.ThumbnailType.HeadShot, 
    Enum.ThumbnailSize.Size420x420
)
PlayerAvatar.ZIndex = 5

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = PlayerAvatar

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
PlayerName.ZIndex = 5-- ==========================================
-- CONTEÚDO (ABAS)
-- ==========================================
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -145, 1, 0)
ContentFrame.Position = UDim2.new(0, 145, 0, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 2

local Pages = {}
local TabButtons = {}

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
    btn.BackgroundTransparency = 0.2
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = DarkFont
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.ZIndex = 4
    btn.Parent = TabContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(130, 0, 200)
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
            TabButtons[n].BackgroundColor3 = (n == name) 
                and Color3.fromRGB(45, 20, 65) 
                or Color3.fromRGB(15, 12, 22)
        end
    end)

    return page
end-- ==========================================
-- COMPONENTES DE UI
-- ==========================================
local function createToggle(parent, titleText, defaultState, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.Parent = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = titleText
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 14
    lbl.Font = DarkFont
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local switchBtn = Instance.new("TextButton")
    switchBtn.Parent = row
    switchBtn.Size = UDim2.new(0, 40, 0, 20)
    switchBtn.Position = UDim2.new(1, -48, 0.5, -10)
    switchBtn.BackgroundColor3 = defaultState 
        and Color3.fromRGB(130, 0, 200) 
        or Color3.fromRGB(25, 25, 32)
    switchBtn.Text = ""
    switchBtn.BorderSizePixel = 0

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchBtn

    local dot = Instance.new("Frame")
    dot.Parent = switchBtn
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = defaultState 
        and UDim2.new(1, -17, 0.5, -7) 
        or UDim2.new(0, 3, 0.5, -7)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local state = defaultState
    switchBtn.MouseButton1Click:Connect(function()
        state = not state
        switchBtn.BackgroundColor3 = state 
            and Color3.fromRGB(130, 0, 200) 
            or Color3.fromRGB(25, 25, 32)
        dot.Position = state 
            and UDim2.new(1, -17, 0.5, -7) 
            or UDim2.new(0, 3, 0.5, -7)
        callback(state)
    end)

    return row
end

local function createSlider(parent, titleText, min, max, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.Parent = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.Size = UDim2.new(0.6, 0, 0, 22)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = titleText
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 13
    lbl.Font = DarkFont
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valueLbl = Instance.new("TextLabel")
    valueLbl.Parent = row
    valueLbl.Size = UDim2.new(0.3, 0, 0, 22)
    valueLbl.Position = UDim2.new(0.65, 0, 0, 4)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Text = tostring(default)
    valueLbl.TextColor3 = Color3.fromRGB(130, 0, 200)
    valueLbl.TextSize = 13
    valueLbl.Font = Enum.Font.GothamBold
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("Frame")
    bar.Parent = row
    bar.Size = UDim2.new(1, -20, 0, 6)
    bar.Position = UDim2.new(0, 10, 1, -14)
    bar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    bar.BorderSizePixel = 0

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(130, 0, 200)
    fill.BorderSizePixel = 0

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
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
            local pos = math.clamp(
                (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 
                0, 1
            )
            local val = math.floor(min + (max - min) * pos)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            valueLbl.Text = tostring(val)
            callback(val)
        end
    end)

    return row
    end-- ==========================================
-- ABA: SKYBOX
-- ==========================================
local SkyPage = createTab("Skybox")

local SkyboxIDs = {
    {name = "Cinematic", bk = "162001887", dn = "161998893", ft = "162001897", lf = "162001904", rt = "162001919", up = "162001926"},
    {name = "Sunset",    bk = "600832720", dn = "600832804", ft = "600833083", lf = "600832889", rt = "600833001", up = "600833186"},
    {name = "Night Sky", bk = "13107361022"},
    {name = "Blue Sky",  bk = "570557337"},
    {name = "Galaxy",    bk = "8735253332"},
    {name = "Nebula",    bk = "10256505900"},
    {name = "Tropical",  bk = "566612745"},
    {name = "Aurora",    bk = "87779981190120"},
    {name = "Dark",      bk = "138907351102721"},
    {name = "Fantasy",   bk = "92363876322534"},
    {name = "Desert",    bk = "5952679029"},
}

local function applySkybox(ids)
    pcall(function()
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then v:Destroy() end
        end
        local sky = Instance.new("Sky")
        sky.Name = "Manic_Sky"
        sky.SkyboxBk = "rbxassetid://" .. ids.bk
        sky.SkyboxDn = "rbxassetid://" .. (ids.dn or ids.bk)
        sky.SkyboxFt = "rbxassetid://" .. (ids.ft or ids.bk)
        sky.SkyboxLf = "rbxassetid://" .. (ids.lf or ids.bk)
        sky.SkyboxRt = "rbxassetid://" .. (ids.rt or ids.bk)
        sky.SkyboxUp = "rbxassetid://" .. (ids.up or ids.bk)
        sky.Parent = Lighting
    end)
end

for _, skyData in ipairs(SkyboxIDs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
    btn.BackgroundTransparency = 0.2
    btn.Text = "  " .. skyData.name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = DarkFont
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = SkyPage

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        applySkybox(skyData)
        Flags.Skybox = skyData.name
    end)
        end-- ==========================================
-- ABA: BOLA
-- ==========================================
local BallPage = createTab("Bola")

local function getBall()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n == "ball" or n == "bola" 
            or n:find("football") or n:find("soccer") then
                return obj
            end
        end
    end
    return nil
end

-- Cor da Bola
createToggle(BallPage, "Mudar Cor da Bola", false, function(active)
    Flags.BallColorActive = active
end)

-- Fogo na Bola
createToggle(BallPage, "Fogo na Bola", false, function(active)
    Flags.BallFire = active
end)

-- Trail na Bola
local TrailEnabled = false
local TrailColor = Color3.fromRGB(130, 0, 200)
local TrailWidth = 1

local function updateTrail()
    local ball = getBall()
    if not ball then return end
    local trail = ball:FindFirstChild("Manic_BallTrail")
    if TrailEnabled then
        if not trail then
            trail = Instance.new("Trail")
            trail.Name = "Manic_BallTrail"
            local a0 = Instance.new("Attachment", ball)
            a0.Name = "Manic_TrailA0"
            local a1 = Instance.new("Attachment", ball)
            a1.Name = "Manic_TrailA1"
            a1.Position = Vector3.new(0, 0, 0.1)
            trail.Attachment0 = a0
            trail.Attachment1 = a1
            trail.Parent = ball
        end
        trail.Color = ColorSequence.new(TrailColor)
        trail.WidthScale = NumberSequence.new(TrailWidth)
        trail.Lifetime = 0.5
    else
        if trail then trail:Destroy() end
    end
end

createToggle(BallPage, "Trail na Bola", false, function(active)
    TrailEnabled = active
    updateTrail()
end)

createSlider(BallPage, "Largura do Trail", 1, 10, 1, function(v)
    TrailWidth = v
    updateTrail()
end)

-- ==========================================
-- ABA: MAPA
-- ==========================================
local MapPage = createTab("Mapa")

createToggle(MapPage, "Mudar Cor do Mapa", false, function(active)
    Flags.MapColorActive = active
    if active and Flags.MapColor then
        pcall(function()
            local terrain = Workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain:SetMaterialColor(Enum.Material.Grass, Flags.MapColor)
            end
        end)
    end
end)-- ==========================================
-- ABA: JOGABILIDADE
-- ==========================================
local GamePage = createTab("Jogabilidade")

local Character, Humanoid, RootPart
local function updateCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end
updateCharacter()
LocalPlayer.CharacterAdded:Connect(updateCharacter)

-- ===== AUTO DRIVE =====
local AutoDiveEnabled = false
local AutoDiveCooldown = 0

local function DoAutoDive(ball)
    if not AutoDiveEnabled then return end
    if not ball or not Character or not Humanoid or not RootPart then return end
    if os.clock() < AutoDiveCooldown then return end

    local ballVel = ball.AssemblyLinearVelocity
    if ballVel.Magnitude < 12 then return end

    local toMe = RootPart.Position - ball.Position
    if ballVel.Unit:Dot(toMe.Unit) <= 0.35 then return end

    local distance = (ball.Position - RootPart.Position).Magnitude
    if distance > 30 then return end

    local predicted = ball.Position + ballVel * 0.3
    local diff = predicted - RootPart.Position
    local flat = Vector3.new(diff.X, 0, diff.Z)

    if flat.Magnitude > 0.5 and flat.Magnitude < 15 then
        Humanoid:Move(flat.Unit, false)
        Humanoid.WalkSpeed = 30
        for _, name in ipairs({"LeftFoot", "RightFoot", "Left Leg", "Right Leg"}) do
            local foot = Character:FindFirstChild(name)
            if foot and firetouchinterest then
                firetouchinterest(foot, ball, 0)
                firetouchinterest(foot, ball, 1)
            end
        end
        if ball.Position.Y > RootPart.Position.Y + 3 
        and Humanoid.FloorMaterial ~= Enum.Material.Air then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        AutoDiveCooldown = os.clock() + 0.8
    end
end

createToggle(GamePage, "Auto Drive", false, function(active)
    AutoDiveEnabled = active
end)

-- ===== HAMBOLO =====
local HamboloEnabled = false
local HamboloPower = 50

local function DoHambolo(ball)
    if not HamboloEnabled then return end
    if not ball or not Character or not Humanoid or not RootPart then return end
    if not firetouchinterest then return end

    local head = Character:FindFirstChild("Head")
    local torso = Character:FindFirstChild("UpperTorso") 
                  or Character:FindFirstChild("Torso")
    if not head and not torso then return end

    local headY = RootPart.Position.Y + 3.5
    local ballVel = ball.AssemblyLinearVelocity
    local distance = (ball.Position - RootPart.Position).Magnitude

    if ballVel.Y < 2 and ball.Position.Y < headY and distance <= 6 then
        local toMe = RootPart.Position - ball.Position
        local flat = Vector3.new(toMe.X, 0, toMe.Z)
        if flat.Magnitude > 0.1 then
            ball.AssemblyLinearVelocity = flat.Unit * 3 
                + Vector3.new(0, HamboloPower, 0)
        else
            ball.AssemblyLinearVelocity = Vector3.new(0, HamboloPower, 0)
        end
        ball.AssemblyAngularVelocity = Vector3.new(0, 2, 0)
    end

    if ball.Position.Y >= RootPart.Position.Y + 2 
    and ball.Position.Y <= headY + 1.5 and distance <= 8 then
        for _, part in ipairs({head, torso}) do
            if part then
                firetouchinterest(part, ball, 0)
                firetouchinterest(part, ball, 1)
            end
        end
        if ballVel.Y < HamboloPower * 0.4 then
            ball.AssemblyLinearVelocity = Vector3.new(
                ballVel.X * 0.6, HamboloPower, ballVel.Z * 0.6
            )
        end
        if Humanoid.MoveDirection.Magnitude == 0 then
            Humanoid:Move(RootPart.CFrame.LookVector, false)
        end
    end
end

createToggle(GamePage, "Hambolo", false, function(active)
    HamboloEnabled = active
end)

createSlider(GamePage, "Força do Hambolo", 20, 80, 50, function(v)
    HamboloPower = v
end)

-- ===== AUTO BALL =====
local AutoBallEnabled = false

local function DoAutoBall()
    if not AutoBallEnabled then return end
    local ball = getBall()
    if not ball or not RootPart then return end

    if firetouchinterest then
        local rightFoot = Character:FindFirstChild("RightFoot") 
                       or Character:FindFirstChild("Right Leg")
        if rightFoot then
            firetouchinterest(rightFoot, ball, 0)
            firetouchinterest(rightFoot, ball, 1)
        end
    end

    local goal = Workspace:FindFirstChild("Goal") 
              or Workspace:FindFirstChild("Gol")
    if goal then
        local goalPos = goal.Position
        local shootDir = (goalPos - ball.Position).Unit
        pcall(function()
            ball.AssemblyLinearVelocity = shootDir * 80 + Vector3.new(0, 15, 0)
        end)
    end
end

createToggle(GamePage, "Auto Ball", false, function(active)
    AutoBallEnabled = active
    AutoBallBtn.BackgroundColor3 = active 
        and Color3.fromRGB(130, 0, 200) 
        or Color3.fromRGB(10, 10, 14)
end)

AutoBallBtn.MouseButton1Click:Connect(function()
    AutoBallEnabled = not AutoBallEnabled
    AutoBallBtn.BackgroundColor3 = AutoBallEnabled 
        and Color3.fromRGB(130, 0, 200) 
        or Color3.fromRGB(10, 10, 14)
end)

-- ===== AUTO GOAL =====
local AutoGoalEnabled = false

local function DoAutoGoal()
    if not AutoGoalEnabled then return end
    local ball = getBall()
    if not ball or not RootPart then return end
    local goal = Workspace:FindFirstChild("Goal") 
              or Workspace:FindFirstChild("Gol")
    if not goal then return end
    local shootDir = (goal.Position - ball.Position).Unit
    pcall(function()
        ball.AssemblyLinearVelocity = shootDir * 100 + Vector3.new(0, 20, 0)
    end)
end

createToggle(GamePage, "Auto Goal", false, function(active)
    AutoGoalEnabled = active
end)

-- ===== REACH =====
createToggle(GamePage, "Reach (Hitbox)", false, function(active)
    Flags.Reach = active
    if Character and Character:FindFirstChild("Head") then
        if active then
            Character.Head.Size = Vector3.new(10, 10, 10)
            Character.Head.Transparency = 0.5
        else
            Character.Head.Size = Vector3.new(2, 1, 1)
            Character.Head.Transparency = 0
        end
    end
end)-- ==========================================
-- ABA: VISUAL
-- ==========================================
local VisualPage = createTab("Visual")

-- Tela Esticada
local StretchConnection = nil
local function setStretch(active)
    if active then
        if not StretchConnection then
            local Camera = Workspace.CurrentCamera
            StretchConnection = RunService.RenderStepped:Connect(function()
                Camera.CFrame = Camera.CFrame 
                    * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.67, 0, 0, 0, 1)
            end)
        end
    else
        if StretchConnection then
            StretchConnection:Disconnect()
            StretchConnection = nil
        end
    end
end

createToggle(VisualPage, "Tela Esticada", false, function(active)
    setStretch(active)
end)

-- FPS Boost
createToggle(VisualPage, "Gráficos (FPS Boost)", false, function(active)
    if active then
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

-- ==========================================
-- ABA: CONFIG
-- ==========================================
local ConfigPage = createTab("Config")

createToggle(ConfigPage, "Minimizar Painel", false, function(active)
    if active then
        MainFrame.Size = UDim2.new(0, 500, 0, 40)
        for _, child in ipairs(ContentFrame:GetChildren()) do
            if child:IsA("ScrollingFrame") then child.Visible = false end
        end
    else
        MainFrame.Size = UDim2.new(0, 500, 0, 380)
        for name, page in pairs(Pages) do
            if TabButtons[name].BackgroundColor3 == Color3.fromRGB(45, 20, 65) then
                page.Visible = true
            end
        end
    end
end)

createToggle(ConfigPage, "Anti-Cheat (AC)", false, function(active)
    Flags.AC = active
    if active then
        if not Flags.OriginalWalkSpeed and Humanoid then
            Flags.OriginalWalkSpeed = Humanoid.WalkSpeed
        end
        if Humanoid then
            Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if Flags.AC and Humanoid.WalkSpeed > 30 then
                    Humanoid.WalkSpeed = Flags.OriginalWalkSpeed or 16
                end
            end)
        end
    end
end)

-- ==========================================
-- LOOPS DE EXECUÇÃO
-- ==========================================
RunService.Heartbeat:Connect(function()
    local ball = getBall()
    if ball then
        if AutoDiveEnabled then DoAutoDive(ball) end
        if HamboloEnabled then DoHambolo(ball) end
        if AutoBallEnabled then DoAutoBall() end
        if AutoGoalEnabled then DoAutoGoal() end

        -- Fogo
        if Flags.BallFire then
            if not ball:FindFirstChild("Manic_BallFire") then
                local fire = Instance.new("Fire")
                fire.Name = "Manic_BallFire"
                fire.Size = 5
                fire.Heat = 10
                fire.Color = Color3.fromRGB(255, 100, 0)
                fire.SecondaryColor = Color3.fromRGB(255, 200, 0)
                fire.Parent = ball
            end
        else
            local fire = ball:FindFirstChild("Manic_BallFire")
            if fire then fire:Destroy() end
        end
    end
end)

-- FPS Counter
local fpsCount, lastTime = 0, tick()
RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    local now = tick()
    if now - lastTime >= 1 then
        FpsLabel.Text = string.format("FPS: %.1f/s   %.1f ms", 
            fpsCount, (now - lastTime) * 1000 / fpsCount)
        fpsCount = 0
        lastTime = now
    end
end)

-- ==========================================
-- ABRIR/FECHAR MENU (LeftShift)
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Aba padrão
TabButtons["Skybox"].BackgroundColor3 = Color3.fromRGB(45, 20, 65)
Pages["Skybox"].Visible = true
