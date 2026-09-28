--[[ MANIC HUB v2.0 | TCS Edition | PARTE 1/7 — Base + Rayfield ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

getgenv().ManicHub = getgenv().ManicHub or {}
local Flags = getgenv().ManicHub

-- Personagem
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(c)
    Character = c
    Humanoid = c:WaitForChild("Humanoid")
    RootPart = c:WaitForChild("HumanoidRootPart")
end)

-- Backups
local Backups = {
    Grass = {},
    Lighting = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ColorShift_Top = Lighting.ColorShift_Top,
        ColorShift_Bottom = Lighting.ColorShift_Bottom,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        FogColor = Lighting.FogColor,
    }
}

-- Estado global
local State = {
    AutoBall = false, AutoDrive = false, AutoCatch = false, Reach = false,
    ReachDistance = 10, PlayerSpeed = 16, Trail = false,
    StretchH = false, StretchV = false,
    BallColor = nil, BallFire = false,
    GrassColor = nil, Skybox = nil, GraphicPreset = nil, BoomBoxSound = nil,
}

-- FTI
local FTI = firetouchinterest or (getgenv and getgenv().firetouchinterest)
print("[MANIC HUB] firetouchinterest:", FTI ~= nil)

-- Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Manic Hub",
    Icon = 0,
    LoadingTitle = "Manic Hub",
    LoadingSubtitle = "TCS Edition",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ManicHub",
        FileName = "ManicConfig"
    },
    Discord = { Enabled = false },
    KeySystem = false,
})

Rayfield:Notify({
    Title = "Manic Hub",
    Content = "Carregado com sucesso!",
    Duration = 5,
    Image = 4483362458,
})

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.LeftShift then
        Rayfield:ToggleWindow()
    end
end)--[[ MANIC HUB | PARTE 2/7 — MAPA ]]

local MapTab = Window:CreateTab("ᴍᴀᴘᴀ", 4483362458)
MapTab:CreateSection("🎨 Cor do Gramado")

local function EhGrama(obj)
    if not obj:IsA("BasePart") then return false end
    if obj.Material == Enum.Material.Grass then return true end
    local n = string.lower(obj.Name)
    return (string.find(n, "grass") or string.find(n, "grama")
        or string.find(n, "gramado") or string.find(n, "campo")
        or string.find(n, "field") or string.find(n, "pitch")
        or string.find(n, "turf")) ~= nil
end

local function SalvarGrama()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and EhGrama(obj) then
            if not Backups.Grass[obj] then
                Backups.Grass[obj] = {Color = obj.Color, Material = obj.Material}
            end
        end
    end
end

local function AplicarCorGrama(cor)
    SalvarGrama()
    State.GrassColor = cor
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and EhGrama(obj) then
            pcall(function()
                obj.Color = cor
                if obj:IsA("MeshPart") then obj.TextureID = "" end
                for _, c in ipairs(obj:GetChildren()) do
                    if c:IsA("Texture") or c:IsA("Decal") then c.Transparency = 1 end
                end
            end)
        end
    end
end

local function RestaurarGrama()
    for obj, data in pairs(Backups.Grass) do
        if obj and obj.Parent then
            pcall(function()
                obj.Color = data.Color
                obj.Material = data.Material
                for _, c in ipairs(obj:GetChildren()) do
                    if c:IsA("Texture") or c:IsA("Decal") then c.Transparency = 0 end
                end
            end)
        end
    end
    State.GrassColor = nil
end

MapTab:CreateColorPicker({
    Name = "Map Color",
    Color = Color3.fromRGB(60, 145, 60),
    Flag = "GrassColor",
    Callback = function(color) AplicarCorGrama(color) end,
})

MapTab:CreateButton({
    Name = "↩ Restaurar Grama Original",
    Callback = function()
        RestaurarGrama()
        Rayfield:Notify({Title = "Mapa", Content = "Grama restaurada!", Duration = 2})
    end,
})

spawn(function()
    while true do
        task.wait(1)
        if State.GrassColor then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and EhGrama(obj) and obj.Color ~= State.GrassColor then
                    pcall(function() obj.Color = State.GrassColor end)
                end
            end
        end
    end
end)-- ============================================
-- SKYBOX (CORRIGIDO - anti-reset)
-- ============================================
MapTab:CreateSection("☁ Skybox")

local SkyboxIDs = {
    {Name = "Sky 1", ID = "8202961731"},
    {Name = "Sky 2", ID = "2758029221"},
    {Name = "Night", ID = "13107361022"},
    {Name = "Sky 4", ID = "7108851308"},
    {Name = "Sky 5", ID = "339406852"},
    {Name = "Sky 6", ID = "15502592084"},
    {Name = "Sky 7", ID = "15359965253"},
    {Name = "Sky 8", ID = "15470370280"},
    {Name = "Blue Sky", ID = "8808550143"},
    {Name = "Sky 10", ID = "10594723714"},
}

local function AplicarSkybox(assetId)
    pcall(function()
        -- 1. Destrói TODAS as Sky (inclusive dentro de pastas)
        for _, v in ipairs(Lighting:GetDescendants()) do
            if v:IsA("Sky") then v:Destroy() end
        end
        -- 2. Destrói Atmosphere (pode escurecer a sky)
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") then v:Destroy() end
        end
        -- 3. Cria a nova Sky
        local sky = Instance.new("Sky")
        sky.Name = "Manic_Sky"
        sky.SkyboxBk = "rbxassetid://" .. assetId
        sky.SkyboxDn = "rbxassetid://" .. assetId
        sky.SkyboxFt = "rbxassetid://" .. assetId
        sky.SkyboxLf = "rbxassetid://" .. assetId
        sky.SkyboxRt = "rbxassetid://" .. assetId
        sky.SkyboxUp = "rbxassetid://" .. assetId
        sky.SunAngularSize = 0
        sky.MoonAngularSize = 0
        sky.StarCount = 0
        sky.Parent = Lighting
        State.Skybox = assetId
    end)
end

local function RemoverSkybox()
    pcall(function()
        for _, v in ipairs(Lighting:GetDescendants()) do
            if v:IsA("Sky") then v:Destroy() end
        end
    end)
    State.Skybox = nil
end

-- Botões das skyboxes
for _, sky in ipairs(SkyboxIDs) do
    MapTab:CreateButton({
        Name = "☁ " .. sky.Name,
        Callback = function()
            AplicarSkybox(sky.ID)
            Rayfield:Notify({
                Title = "Skybox",
                Content = sky.Name .. " aplicada!",
                Duration = 2
            })
        end,
    })
end

MapTab:CreateButton({
    Name = "↩ Remover Skybox Customizada",
    Callback = function()
        RemoverSkybox()
        Rayfield:Notify({Title = "Skybox", Content = "Removida!", Duration = 2})
    end,
})

-- 🔥 LOOP ANTI-RESET: re-aplica se o TCS sobrescrever
RunService.RenderStepped:Connect(function()
    if not State.Skybox then return end

    -- Se a nossa sky sumiu, recria
    if not Lighting:FindFirstChild("Manic_Sky") then
        AplicarSkybox(State.Skybox)
        return
    end

    -- Remove qualquer Sky que NÃO seja a nossa
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") and v.Name ~= "Manic_Sky" then
            v:Destroy()
        end
    end

    -- Remove Atmosphere se aparecer
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Atmosphere") then
            v:Destroy()
        end
    end
end)-- ============================================
-- GRÁFICOS
-- ============================================
MapTab:CreateSection("🌅 Gráficos")

local function ResetarLighting()
    pcall(function()
        Lighting.Ambient = Backups.Lighting.Ambient
        Lighting.OutdoorAmbient = Backups.Lighting.OutdoorAmbient
        Lighting.ColorShift_Top = Backups.Lighting.ColorShift_Top
        Lighting.ColorShift_Bottom = Backups.Lighting.ColorShift_Bottom
        Lighting.Brightness = Backups.Lighting.Brightness
        Lighting.ClockTime = Backups.Lighting.ClockTime
        Lighting.FogEnd = Backups.Lighting.FogEnd
        Lighting.FogColor = Backups.Lighting.FogColor
        Lighting.GlobalShadows = true
    end)
end

local function AplicarFlorido()
    ResetarLighting()
    pcall(function()
        Lighting.Ambient = Color3.fromRGB(255, 200, 230)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 180, 220)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 150, 200)
        Lighting.ColorShift_Bottom = Color3.fromRGB(255, 100, 180)
        Lighting.Brightness = 2.5
        Lighting.ClockTime = 14
        Lighting.FogColor = Color3.fromRGB(255, 200, 230)
    end)
end

local function AplicarBonito()
    ResetarLighting()
    pcall(function()
        Lighting.Ambient = Color3.fromRGB(90, 90, 90)
        Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 150)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = true
    end)
end

local function AplicarSol()
    ResetarLighting()
    pcall(function()
        Lighting.Ambient = Color3.fromRGB(255, 200, 150)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 180, 120)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 150, 60)
        Lighting.ColorShift_Bottom = Color3.fromRGB(255, 120, 40)
        Lighting.Brightness = 3
        Lighting.ClockTime = 17
        Lighting.FogColor = Color3.fromRGB(255, 200, 150)
    end)
end

local function AplicarRecomendado()
    ResetarLighting()
    pcall(function()
        Lighting.Ambient = Color3.fromRGB(80, 80, 80)
        Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 120)
        Lighting.ColorShift_Top = Color3.fromRGB(200, 200, 200)
        Lighting.ColorShift_Bottom = Color3.fromRGB(50, 50, 50)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = true
    end)
end

MapTab:CreateButton({Name = "🌸 Florido (Gradiente Rosa)",
    Callback = function() AplicarFlorido(); State.GraphicPreset = "Florido" end})
MapTab:CreateButton({Name = "🎬 Bonito (Realista)",
    Callback = function() AplicarBonito(); State.GraphicPreset = "Bonito" end})
MapTab:CreateButton({Name = "🌞 Sol (Realista Laranja)",
    Callback = function() AplicarSol(); State.GraphicPreset = "Sol" end})
MapTab:CreateButton({Name = "⭐ Recomendado (Branco e Preto)",
    Callback = function() AplicarRecomendado(); State.GraphicPreset = "Recomendado" end})
MapTab:CreateButton({Name = "↩ Resetar Gráficos",
    Callback = function() ResetarLighting(); State.GraphicPreset = nil end})--[[ MANIC HUB | PARTE 3/7 — Boom Box + Auto Follow ]]

local BoomTab = Window:CreateTab("ʙᴏᴏᴍ ʙᴏx", 4483362458)
BoomTab:CreateSection("🎵 Músicas")

local function TocarMusica(id)
    pcall(function()
        if State.BoomBoxSound then State.BoomBoxSound:Destroy() end
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. id
        sound.Volume = 2
        sound.Looped = false
        sound.Parent = Character:FindFirstChild("HumanoidRootPart") or Workspace
        sound:Play()
        State.BoomBoxSound = sound
    end)
end

local Musicas = {
    {Nome = "🎵 Meant To Be", ID = "84321228471359"},
    {Nome = "🎵 Misery", ID = "128715303988843"},
    {Nome = "🎵 Blodlyn Bloodpop", ID = "96414211708215"},
}

for _, m in ipairs(Musicas) do
    BoomTab:CreateButton({
        Name = m.Nome,
        Callback = function()
            TocarMusica(m.ID)
            Rayfield:Notify({Title = "Boom Box", Content = "Tocando: " .. m.Nome, Duration = 2})
        end,
    })
end

BoomTab:CreateSection("🎵 Custom")
BoomTab:CreateInput({
    Name = "ID da Música",
    PlaceholderText = "Digite o ID...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        if text and text ~= "" then TocarMusica(text) end
    end,
})

BoomTab:CreateButton({
    Name = "⏹ Parar Música",
    Callback = function()
        if State.BoomBoxSound then
            pcall(function() State.BoomBoxSound:Stop(); State.BoomBoxSound:Destroy() end)
            State.BoomBoxSound = nil
        end
    end,
})

-- ============================================
-- BALL: Auto Follow
-- ============================================
local BallTab = Window:CreateTab("ʙᴀʟʟ", 4483362458)
BallTab:CreateSection("⚽ Auto Follow")

local AutoFollowConnection = nil
local CurrentBall = nil
local ScanTimer = 0
local StopDistance = 0.2
local SteerStrength = 1.25
local PlayerControls = nil

pcall(function()
    local PM = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
    PlayerControls = PM:GetControls()
end)

local function GetChar()
    local c = LocalPlayer.Character
    if not c then return nil, nil, nil end
    return c, c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
end

local function IsValidBall(part)
    if not part or not part.Parent or not part:IsA("BasePart") then return false end
    if part:IsDescendantOf(LocalPlayer.Character) then return false end
    if part.Anchored then return false end
    local n = string.lower(part.Name)
    if n ~= "tps" and n ~= "ball" and n ~= "bola" then return false end
    local b = math.max(part.Size.X, part.Size.Y, part.Size.Z)
    local s = math.min(part.Size.X, part.Size.Y, part.Size.Z)
    if b < 0.5 or b > 8 then return false end
    if s / b < 0.55 then return false end
    return true
end

local function FindClosestBall()
    local _, _, root = GetChar()
    if not root then return nil end
    local closest, cd = nil, math.huge
    for _, p in ipairs(Workspace:GetDescendants()) do
        if IsValidBall(p) then
            local off = Vector3.new(p.Position.X - root.Position.X, 0, p.Position.Z - root.Position.Z)
            if off.Magnitude < cd then cd = off.Magnitude; closest = p end
        end
    end
    return closest
end

local function GetManualDir()
    local cam = Workspace.CurrentCamera
    if not cam then return Vector3.zero end
    local fwd = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
    local rgt = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
    if fwd.Magnitude > 0 then fwd = fwd.Unit end
    if rgt.Magnitude > 0 then rgt = rgt.Unit end
    if PlayerControls then
        local ok, mv = pcall(function() return PlayerControls:GetMoveVector() end)
        if ok and mv then
            local d = rgt * mv.X + fwd * -mv.Z
            if d.Magnitude > 1 then d = d.Unit end
            if d.Magnitude > 0.01 then return d end
        end
    end
    local d = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then d += fwd end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then d -= fwd end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then d += rgt end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then d -= rgt end
    if d.Magnitude > 1 then d = d.Unit end
    return d
end

local function StartAutoBall()
    if AutoFollowConnection then AutoFollowConnection:Disconnect() end
    State.AutoBall = true
    CurrentBall = nil
    ScanTimer = 1

    AutoFollowConnection = RunService.RenderStepped:Connect(function(dt)
        if not State.AutoBall then return end
        local _, hum, root = GetChar()
        if not hum or not root or hum.Health <= 0 then return end
        hum.AutoRotate = true
        ScanTimer += dt

        local inv = not CurrentBall or not CurrentBall.Parent
        if CurrentBall and CurrentBall.Parent and not IsValidBall(CurrentBall) then inv = true end

        if inv or ScanTimer >= 0.25 then
            ScanTimer = 0
            CurrentBall = FindClosestBall()
        end

        local ball = CurrentBall
        if not ball or not ball.Parent then return end

        local toBall = Vector3.new(ball.Position.X - root.Position.X, 0, ball.Position.Z - root.Position.Z)
        local dist = toBall.Magnitude
        local manual = GetManualDir()

        if dist > StopDistance then
            local fl = toBall.Unit
            local fin = fl
            if manual.Magnitude > 0.01 then
                local amt = math.clamp(manual.Magnitude, 0, 1)
                fin = fl * (1 - amt * 0.45) + manual * SteerStrength
                if fin.Magnitude > 0 then fin = fin.Unit end
            end
            hum:Move(fin, false)
        elseif manual.Magnitude > 0.01 then
            hum:Move(manual, false)
        end
    end)
end

local function StopAutoBall()
    State.AutoBall = false
    CurrentBall = nil
    if AutoFollowConnection then
        AutoFollowConnection:Disconnect()
        AutoFollowConnection = nil
    end
end

BallTab:CreateToggle({
    Name = "Auto Follow (Seguir Bola)",
    CurrentValue = false,
    Flag = "AutoFollow",
    Callback = function(v)
        if v then StartAutoBall() else StopAutoBall() end
    end,
})

BallTab:CreateSlider({
    Name = "Distância de Parada",
    Range = {1, 50}, Increment = 1, Suffix = "x10",
    CurrentValue = 2, Flag = "StopDistance",
    Callback = function(v) StopDistance = v / 10 end,
})

BallTab:CreateSlider({
    Name = "Força do Steering",
    Range = {1, 30}, Increment = 1, Suffix = "x10",
    CurrentValue = 13, Flag = "SteerStrength",
    Callback = function(v) SteerStrength = v / 10 end,
})--[[ MANIC HUB | PARTE 4/7 — Ball: Cor + Fogo + Curva ]]

BallTab:CreateSection("🎨 Aparência da Ball")

local BallTextureBackup = {}

local function SalvarTexturasBall(ball)
    if BallTextureBackup[ball] then return end
    local data = {Decals = {}, MeshTexId = nil, Mesh = nil, Cor = ball.Color, Material = ball.Material}
    pcall(function()
        if ball:IsA("MeshPart") then data.TextureID = ball.TextureID end
    end)
    local mesh = ball:FindFirstChildWhichIsA("SpecialMesh")
    if mesh then
        data.MeshTexId = mesh.TextureId
        data.Mesh = mesh
    end
    for _, c in ipairs(ball:GetChildren()) do
        if c:IsA("Texture") or c:IsA("Decal") then
            table.insert(data.Decals, {Obj = c, Trans = c.Transparency})
        end
    end
    BallTextureBackup[ball] = data
end

local function RemoverTexturasBall(ball)
    pcall(function()
        if ball:IsA("MeshPart") then ball.TextureID = "" end
    end)
    local mesh = ball:FindFirstChildWhichIsA("SpecialMesh")
    if mesh then pcall(function() mesh.TextureId = "" end) end
    for _, c in ipairs(ball:GetChildren()) do
        if c:IsA("Texture") or c:IsA("Decal") then c.Transparency = 1 end
    end
end

local function AplicarCorBall(cor)
    State.BallColor = cor
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if IsValidBall(obj) then
            SalvarTexturasBall(obj)
            RemoverTexturasBall(obj)
            pcall(function()
                obj.Color = cor
                obj.Material = Enum.Material.Neon
            end)
        end
    end
end

local function RestaurarBall()
    for ball, data in pairs(BallTextureBackup) do
        if ball and ball.Parent then
            pcall(function()
                if data.TextureID then ball.TextureID = data.TextureID end
                if data.MeshTexId and data.Mesh then data.Mesh.TextureId = data.MeshTexId end
                for _, d in ipairs(data.Decals) do
                    if d.Obj and d.Obj.Parent then d.Obj.Transparency = d.Trans end
                end
                ball.Color = data.Cor
                ball.Material = data.Material
            end)
        end
    end
    State.BallColor = nil
    State.BallFire = false
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if IsValidBall(obj) then
            local f = obj:FindFirstChild("Manic_BallFire")
            if f then f:Destroy() end
        end
    end
end

BallTab:CreateColorPicker({
    Name = "Cor da Ball",
    Color = Color3.fromRGB(89, 247, 255),
    Flag = "BallColor",
    Callback = function(c) AplicarCorBall(c) end,
})

BallTab:CreateToggle({
    Name = "🔥 Fogo na Ball",
    CurrentValue = false,
    Flag = "BallFire",
    Callback = function(v)
        State.BallFire = v
        if not v then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if IsValidBall(obj) then
                    local f = obj:FindFirstChild("Manic_BallFire")
                    if f then f:Destroy() end
                end
            end
        end
    end,
})

BallTab:CreateButton({
    Name = "↩ Restaurar Ball Original",
    Callback = function()
        RestaurarBall()
        Rayfield:Notify({Title = "Ball", Content = "Restaurada!", Duration = 2})
    end,
})

spawn(function()
    while true do
        task.wait(0.5)
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if IsValidBall(obj) then
                if State.BallColor and obj.Color ~= State.BallColor then
                    pcall(function() obj.Color = State.BallColor end)
                end
                if State.BallFire and not obj:FindFirstChild("Manic_BallFire") then
                    local f = Instance.new("Fire")
                    f.Name = "Manic_BallFire"
                    f.Size = 15; f.Heat = 25
                    f.Color = Color3.fromRGB(255, 100, 0)
                    f.SecondaryColor = Color3.fromRGB(255, 200, 0)
                    f.Parent = obj
                end
            end
        end
    end
end)

-- ============================================
-- CURVA UI
-- ============================================
BallTab:CreateSection("🌀 Curva / Skills")

local CurvaGui = nil

local function SendChat(msg)
    pcall(function()
        local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if ch then ch:SendAsync(msg) end
    end)
    pcall(function()
        ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents")
            :WaitForChild("SayMessageRequest"):FireServer(msg, "All")
    end)
end

local function CriarCurvaUI()
    if CurvaGui then CurvaGui:Destroy() end
    CurvaGui = Instance.new("ScreenGui")
    CurvaGui.Name = "ManicCurvaUI"
    CurvaGui.ResetOnSpawn = false
    CurvaGui.IgnoreGuiInset = true
    CurvaGui.Parent = CoreGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 500, 0, 500)
    main.Position = UDim2.new(0.5, -250, 0.5, -250)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    main.BorderSizePixel = 0
    main.Active = true
    main.Parent = CurvaGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(120, 90, 240)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = main

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 20, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 12, 20)),
    })
    gradient.Rotation = 135
    gradient.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = "🌀 MANIC CURVA"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = main

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -40, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 100)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = main
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function() CurvaGui:Destroy(); CurvaGui = nil end)

    local dragging, dragInput, dragStart, startPos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local grid = Instance.new("Frame")
    grid.Size = UDim2.new(1, -30, 1, -60)
    grid.Position = UDim2.new(0, 15, 0, 55)
    grid.BackgroundTransparency = 1
    grid.Parent = main

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0.5, -8, 0, 42)
    gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = grid

    local Skills = {
        {Nome="Dominar", C=":dominar"}, {Nome="Esquerda", C=":esquerda"},
        {Nome="Direita", C=":direita"}, {Nome="Alto", C=":alto"},
        {Nome="Chute Baixo", C=":chutebaixo"}, {Nome="Lambreta", C=":lambreta"},
        {Nome="Chapéu", C=":chapeu"}, {Nome="Calcanhar", C=":calcanhar"},
        {Nome="Voleio", C=":voleio"}, {Nome="Direita Atrás", C=":direitaatras"},
        {Nome="Esquerda Atrás", C=":esquerdaatras"}, {Nome="Conduzir", C=":conduzir"},
        {Nome="Chute Falso", C=":chutefalso"}, {Nome="Arraste Para Trás", C=":arraste"},
        {Nome="Cabeceio", C=":cabeceio"}, {Nome="Bicicleta", C=":bicicleta"},
    }

    for _, skill in ipairs(Skills) do
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
        btn.Text = skill.Nome
        btn.TextColor3 = Color3.fromRGB(230, 230, 240)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = grid
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        local s = Instance.new("UIStroke")
        s.Color = Color3.fromRGB(80, 70, 140)
        s.Thickness = 1.5; s.Transparency = 0.5
        s.Parent = btn

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(120, 90, 240)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28, 32, 48)}):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            SendChat(skill.C)
            pcall(function()
                StarterGui:SetCore("SendNotification", {Title="Curva", Text=skill.Nome, Duration=1})
            end)
        end)
    end
end

BallTab:CreateButton({
    Name = "🌀 Abrir Curva UI",
    Callback = function() CriarCurvaUI() end,
})--[[ MANIC HUB | PARTE 5/7 — Player + Chars ]]

local PlayerTab = Window:CreateTab("ᴘʟᴀʏᴇʀ", 4483362458)
PlayerTab:CreateSection("🏃 Velocidade")

local TrailObj = nil
local TrailColor = Color3.fromRGB(120, 90, 240)

local function CriarTrail()
    if TrailObj then TrailObj:Destroy() end
    if not Character then return end
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local a0 = Instance.new("Attachment", hrp); a0.Name = "ManicTrailA0"; a0.Position = Vector3.new(0, 1, 0)
    local a1 = Instance.new("Attachment", hrp); a1.Name = "ManicTrailA1"; a1.Position = Vector3.new(0, -1, 0)
    TrailObj = Instance.new("Trail")
    TrailObj.Name = "ManicTrail"
    TrailObj.Attachment0 = a0
    TrailObj.Attachment1 = a1
    TrailObj.Color = ColorSequence.new(TrailColor)
    TrailObj.Lifetime = 1
    TrailObj.MinLength = 0.1
    TrailObj.WidthScale = NumberSequence.new(0.5)
    TrailObj.Parent = hrp
end

PlayerTab:CreateSlider({
    Name = "Velocidade do Jogador",
    Range = {16, 200}, Increment = 1, Suffix = "studs/s",
    CurrentValue = 16, Flag = "PlayerSpeed",
    Callback = function(v)
        State.PlayerSpeed = v
        if Humanoid then Humanoid.WalkSpeed = v end
    end,
})

PlayerTab:CreateSection("✨ Trail")
PlayerTab:CreateToggle({
    Name = "Trail no Jogador",
    CurrentValue = false, Flag = "TrailEnabled",
    Callback = function(v)
        State.Trail = v
        if v then CriarTrail()
        elseif TrailObj then TrailObj:Destroy(); TrailObj = nil end
    end,
})

PlayerTab:CreateColorPicker({
    Name = "Cor do Trail",
    Color = TrailColor, Flag = "TrailColor",
    Callback = function(c)
        TrailColor = c
        if TrailObj then TrailObj.Color = ColorSequence.new(c) end
    end,
})

LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(1)
    if State.Trail then CriarTrail() end
    if Humanoid then Humanoid.WalkSpeed = State.PlayerSpeed end
end)

-- ============================================
-- TELA ESTICADA
-- ============================================
PlayerTab:CreateSection("📺 Tela Esticada")

local StretchHConn = nil
local StretchVConn = nil

PlayerTab:CreateToggle({
    Name = "Esticar Horizontal (Lados)",
    CurrentValue = false, Flag = "StretchH",
    Callback = function(v)
        State.StretchH = v
        if v then
            if StretchHConn then StretchHConn:Disconnect() end
            local cam = Workspace.CurrentCamera
            StretchHConn = RunService.RenderStepped:Connect(function()
                cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 0.75, 0, 0, 0, 1, 0, 0, 0, 1)
            end)
        elseif StretchHConn then
            StretchHConn:Disconnect(); StretchHConn = nil
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Esticar Vertical (Cima)",
    CurrentValue = false, Flag = "StretchV",
    Callback = function(v)
        State.StretchV = v
        if v then
            if StretchVConn then StretchVConn:Disconnect() end
            local cam = Workspace.CurrentCamera
            StretchVConn = RunService.RenderStepped:Connect(function()
                cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.67, 0, 0, 0, 1)
            end)
        elseif StretchVConn then
            StretchVConn:Disconnect(); StretchVConn = nil
        end
    end,
})

-- ============================================
-- CHARS
-- ============================================
local CharsTab = Window:CreateTab("ᴄʜᴀʀs", 4483362458)
CharsTab:CreateSection("🎭 Chars Disponíveis")

local CharsList = {
    "oxentepivetih77","RB9844","FearZakk","pachowillian","DavskCbm9",
    "6unfire","mikaelfacada10","guto785662","orieehrjr","beastsxc",
    "candyxzzz0","polarnyp","kayquealt1106","Skxgoat7","KingOfKitsunezx",
    "slk_eosouzax","defantastico","hyago_mach","mica1203ely5","b_2020f",
    "bernadow_w","ythek9on1","Samblox_Xd","3qu","021_KayqueJr",
    "monalisopitango","a4rloo","Ilulict","m3mbers0nly","19_Nxx",
    "Juninhojwve","ensixraa","keny_tcs","MSS10_ALT1",
}

local function SendChar(nome)
    pcall(function()
        local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if ch then ch:SendAsync(":char " .. nome) end
    end)
    pcall(function()
        ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents")
            :WaitForChild("SayMessageRequest"):FireServer(":char " .. nome, "All")
    end)
end

for _, char in ipairs(CharsList) do
    CharsTab:CreateButton({
        Name = "🎭 " .. char,
        Callback = function()
            SendChar(char)
            Rayfield:Notify({Title = "Char", Content = "Aplicando: " .. char, Duration = 2})
        end,
    })
end--[[ MANIC HUB | PARTE 6/7 — AC + Reach + Auto Drive ]]

local ACTab = Window:CreateTab("ᴀᴄ", 4483362458)
ACTab:CreateSection("🧤 Auto Catch")

local CatchRemote = nil
pcall(function()
    for _, name in ipairs({"CatchBall", "Catch", "AutoCatch", "Grab"}) do
        local r = ReplicatedStorage:FindFirstChild(name, true)
        if r then CatchRemote = r break end
    end
end)

local AutoCatchLast = 0
local AutoCatchRange = 8
local AutoCatchDelay = 0.8
local AC_Hitbox = false
local AC_HitboxPart = nil

local function DoAutoCatch(ball)
    if not State.AutoCatch then return end
    if os.clock() < AutoCatchLast then return end
    if not ball or not ball.Parent then return end
    local _, hum, root = GetChar()
    if not hum or not root then return end
    if (ball.Position - root.Position).Magnitude > AutoCatchRange then return end

    if CatchRemote then
        pcall(function()
            if CatchRemote:IsA("RemoteEvent") then
                CatchRemote:FireServer(ball)
            elseif CatchRemote:IsA("RemoteFunction") then
                CatchRemote:InvokeServer(ball)
            end
        end)
    end

    if FTI then
        for _, n in ipairs({"LeftFoot", "RightFoot", "Left Leg", "Right Leg"}) do
            local p = Character:FindFirstChild(n)
            if p then
                pcall(FTI, p, ball, 0); pcall(FTI, p, ball, 1)
            end
        end
    end
    AutoCatchLast = os.clock() + AutoCatchDelay
end

ACTab:CreateToggle({
    Name = "Auto Catch",
    CurrentValue = false, Flag = "AutoCatch",
    Callback = function(v) State.AutoCatch = v end,
})

ACTab:CreateSlider({
    Name = "Alcance", Range = {3, 30}, Increment = 1, Suffix = "studs",
    CurrentValue = 8, Flag = "ACCatchRange",
    Callback = function(v) AutoCatchRange = v end,
})

ACTab:CreateSlider({
    Name = "Cooldown", Range = {2, 30}, Increment = 1, Suffix = "x100ms",
    CurrentValue = 8, Flag = "ACCatchDelay",
    Callback = function(v) AutoCatchDelay = v / 10 end,
})

ACTab:CreateToggle({
    Name = "Mostrar Hitbox",
    CurrentValue = false, Flag = "AC_Hitbox",
    Callback = function(v) AC_Hitbox = v end,
})

-- ============================================
-- REACH
-- ============================================
local ReachTab = Window:CreateTab("ʀᴇᴀᴄʜ", 4483362458)
ReachTab:CreateSection("📏 Reach")

local ReachLast = 0

ReachTab:CreateToggle({
    Name = "Ativar Reach",
    CurrentValue = false, Flag = "ReachEnabled",
    Callback = function(v) State.Reach = v end,
})

ReachTab:CreateSlider({
    Name = "Distância", Range = {1, 50}, Increment = 1, Suffix = "studs",
    CurrentValue = 10, Flag = "ReachDistance",
    Callback = function(v) State.ReachDistance = v end,
})

-- ============================================
-- AUTO DRIVE
-- ============================================
local DriveTab = Window:CreateTab("ᴀᴜᴛᴏ ᴅʀɪᴠᴇ", 4483362458)
DriveTab:CreateSection("🚀 Auto Drive")

local AutoDriveLast = 0
local AutoDriveRange = 35
local AutoDriveCooldown = 0.7
local AutoDriveSpeed = 32

local function DoAutoDrive(ball)
    if not State.AutoDrive then return end
    if os.clock() < AutoDriveLast then return end
    if not ball or not ball.Parent then return end
    if not FTI then return end

    local _, hum, root = GetChar()
    if not hum or not root then return end

    local ballVel = ball.AssemblyLinearVelocity
    if ballVel.Magnitude < 10 then return end

    local toMe = root.Position - ball.Position
    if ballVel.Unit:Dot(toMe.Unit) <= 0.3 then return end
    if (ball.Position - root.Position).Magnitude > AutoDriveRange then return end

    local predicted = ball.Position + ballVel * 0.35
    local diff = predicted - root.Position
    local flat = Vector3.new(diff.X, 0, diff.Z)

    if flat.Magnitude > 0.5 and flat.Magnitude < 18 then
        local orig = hum.WalkSpeed
        hum:Move(flat.Unit, false)
        hum.WalkSpeed = AutoDriveSpeed
        for _, n in ipairs({"LeftFoot", "RightFoot", "Left Leg", "Right Leg"}) do
            local p = Character:FindFirstChild(n)
            if p then pcall(FTI, p, ball, 0); pcall(FTI, p, ball, 1) end
        end
        if ball.Position.Y > root.Position.Y + 3 and hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        AutoDriveLast = os.clock() + AutoDriveCooldown
        task.delay(0.5, function()
            if hum and State.AutoDrive then hum.WalkSpeed = State.PlayerSpeed or orig end
        end)
    end
end

DriveTab:CreateToggle({
    Name = "Ativar Auto Drive",
    CurrentValue = false, Flag = "AutoDrive",
    Callback = function(v) State.AutoDrive = v end,
})

DriveTab:CreateSlider({
    Name = "Alcance", Range = {10, 50}, Increment = 1, Suffix = "studs",
    CurrentValue = 35, Flag = "ADRange",
    Callback = function(v) AutoDriveRange = v end,
})

DriveTab:CreateSlider({
    Name = "Velocidade ao Perseguir",
    Range = {16, 60}, Increment = 1, Suffix = "studs",
    CurrentValue = 32, Flag = "ADSpeed",
    Callback = function(v) AutoDriveSpeed = v end,
})

DriveTab:CreateSlider({
    Name = "Cooldown", Range = {2, 20}, Increment = 1, Suffix = "x100ms",
    CurrentValue = 7, Flag = "ADCooldown",
    Callback = function(v) AutoDriveCooldown = v / 10 end,
})--[[ MANIC HUB | PARTE 7/7 — Loops + Finalização ]]

-- Loop Auto Catch + Hitbox
RunService.Heartbeat:Connect(function()
    if State.AutoCatch then
        local ball = CurrentBall or FindClosestBall()
        if ball then DoAutoCatch(ball) end
    end
    if AC_Hitbox and RootPart then
        local d = AutoCatchRange * 2
        if not AC_HitboxPart or not AC_HitboxPart.Parent then
            AC_HitboxPart = Instance.new("Part")
            AC_HitboxPart.Name = "ManicAC_Hitbox"
            AC_HitboxPart.Shape = Enum.PartType.Ball
            AC_HitboxPart.Material = Enum.Material.ForceField
            AC_HitboxPart.Color = Color3.fromRGB(0, 200, 255)
            AC_HitboxPart.Transparency = 0.65
            AC_HitboxPart.CanCollide = false
            AC_HitboxPart.CanQuery = false
            AC_HitboxPart.CanTouch = false
            AC_HitboxPart.Anchored = true
            AC_HitboxPart.Parent = Workspace
        end
        AC_HitboxPart.Size = Vector3.new(d, d, d)
        AC_HitboxPart.Position = RootPart.Position
    elseif AC_HitboxPart and AC_HitboxPart.Parent then
        AC_HitboxPart:Destroy()
        AC_HitboxPart = nil
    end
end)

-- Loop Reach
RunService.Heartbeat:Connect(function()
    if not State.Reach then return end
    if not Character or not RootPart then return end
    if os.clock() < ReachLast then return end
    local ball = CurrentBall or FindClosestBall()
    if not ball or not ball.Parent then return end
    if (ball.Position - RootPart.Position).Magnitude > State.ReachDistance then return end
    if FTI then
        pcall(FTI, RootPart, ball, 0); pcall(FTI, RootPart, ball, 1)
        for _, n in ipairs({"LeftFoot", "RightFoot", "Left Leg", "Right Leg"}) do
            local p = Character:FindFirstChild(n)
            if p then pcall(FTI, p, ball, 0); pcall(FTI, p, ball, 1) end
        end
    end
    ReachLast = os.clock() + 0.05
end)

-- Loop Auto Drive
RunService.Heartbeat:Connect(function()
    if State.AutoDrive then
        local ball = CurrentBall or FindClosestBall()
        if ball then DoAutoDrive(ball) end
    end
end)

-- Notificação final
Rayfield:Notify({
    Title = "Manic Hub",
    Content = "✅ Carregado! Use LeftShift para abrir/fechar.",
    Duration = 5,
})

print("[MANIC HUB] ✅ Carregado!")
print("[MANIC HUB] FTI:", tostring(FTI ~= nil))
print("[MANIC HUB] CatchRemote:", tostring(CatchRemote ~= nil))
