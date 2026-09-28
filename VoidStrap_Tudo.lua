--[[ MANIC HUB v2.0 | TCS Edition | WindUI | PARTE 1/8 ]]

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
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

getgenv().ManicHub = getgenv().ManicHub or {}
local Flags = getgenv().ManicHub

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local function UpdateCharacter(c)
    Character = c
    Humanoid = c:WaitForChild("Humanoid")
    RootPart = c:WaitForChild("HumanoidRootPart")
end
LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

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

local State = {
    AutoBall = false, AutoDrive = false, AutoCatch = false, Reach = false,
    ReachDistance = 10, PlayerSpeed = 16, Trail = false,
    StretchH = false, StretchV = false,
    BallColor = nil, BallFire = false, BallTrail = false,
    GrassColor = nil, Skybox = nil, GraphicPreset = nil, BoomBoxSound = nil,
}

local FTI = firetouchinterest or (getgenv and getgenv().firetouchinterest)
print("[MANIC HUB] firetouchinterest:", FTI ~= nil)

-- ============================================
-- WINDUI
-- ============================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Manic Hub",
    Icon = "eye",
    Author = "Manic Hub | TCS",
    Folder = "ManicHub",
    Size = UDim2.fromOffset(620, 480),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true,
    Background = "rbxassetid://11717400651",
    BackgroundImageTransparency = 0.35,
})

Window:Tag({
    Title = "v2.0",
    Icon = "sparkles",
    Color = Color3.fromHex("#7850f0"),
    Radius = 30,
})

WindUI:Notify({
    Title = "Manic Hub",
    Content = "Carregado com sucesso!",
    Duration = 5,
    Icon = "check-circle",
})

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.LeftShift then
        Window:Toggle()
    end
end)--[[ MANIC HUB | PARTE 2/8 — ᴍᴀᴘᴀ ]]

local MapTab = Window:Tab({ Title = "ᴍᴀᴘᴀ", Icon = "map" })

MapTab:Section({ Title = "ᴄᴏʀ ᴅᴏ ɢʀᴀᴍᴀᴅᴏ" })

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

MapTab:Colorpicker({
    Title = "ᴍᴀᴘ ᴄᴏʟᴏʀ",
    Default = Color3.fromRGB(60, 145, 60),
    Callback = function(color) AplicarCorGrama(color) end,
})

MapTab:Button({
    Title = "ʀᴇsᴛᴀᴜʀᴀʀ ɢʀᴀᴍᴀ ᴏʀɪɢɪɴᴀʟ",
    Callback = function()
        RestaurarGrama()
        WindUI:Notify({Title = "ᴍᴀᴘᴀ", Content = "ɢʀᴀᴍᴀ ʀᴇsᴛᴀᴜʀᴀᴅᴀ", Duration = 2})
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
end)

-- ============================================
-- SKYBOX (FIX v3 - RenderStepped loop)
-- ============================================
MapTab:Section({ Title = "sᴋʏʙᴏx" })

local SkyboxIDs = {
    {Name = "sᴋʏ 1", ID = "8202961731"},
    {Name = "sᴋʏ 2", ID = "2758029221"},
    {Name = "ɴɪɢʜᴛ", ID = "13107361022"},
    {Name = "sᴋʏ 4", ID = "7108851308"},
    {Name = "sᴋʏ 5", ID = "339406852"},
    {Name = "sᴋʏ 6", ID = "15502592084"},
    {Name = "sᴋʏ 7", ID = "15359965253"},
    {Name = "sᴋʏ 8", ID = "15470370280"},
    {Name = "ʙʟᴜᴇ sᴋʏ", ID = "8808550143"},
    {Name = "sᴋʏ 10", ID = "10594723714"},
}

local function AplicarSkybox(assetId)
    local url = "rbxassetid://" .. assetId
    pcall(function()
        for _, v in ipairs(Lighting:GetDescendants()) do
            if v:IsA("Sky") then v:Destroy() end
        end
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") then v:Destroy() end
        end
        local sky = Instance.new("Sky")
        sky.Name = "Manic_Sky"
        sky.SkyboxBk = url
        sky.SkyboxDn = url
        sky.SkyboxFt = url
        sky.SkyboxLf = url
        sky.SkyboxRt = url
        sky.SkyboxUp = url
        sky.SunAngularSize = 0
        sky.MoonAngularSize = 0
        sky.StarCount = 0
        sky.CelestialBodiesShowSun = false
        sky.CelestialBodiesShowMoon = false
        sky.CelestialBodiesShowStars = false
        sky.Parent = Lighting
        State.Skybox = assetId
    end)
end

for _, sky in ipairs(SkyboxIDs) do
    MapTab:Button({
        Title = sky.Name,
        Callback = function()
            AplicarSkybox(sky.ID)
            WindUI:Notify({Title = "sᴋʏʙᴏx", Content = sky.Name, Duration = 2})
        end,
    })
end

MapTab:Button({
    Title = "ʀᴇᴍᴏᴠᴇʀ sᴋʏʙᴏx",
    Callback = function()
        pcall(function()
            for _, v in ipairs(Lighting:GetDescendants()) do
                if v:IsA("Sky") then v:Destroy() end
            end
        end)
        State.Skybox = nil
    end,
})

-- LOOP RenderStepped (60x/s) — prevalece sobre o TCS
task.spawn(function()
    while true do
        RunService.RenderStepped:Wait()
        if not State.Skybox then continue end

        local url = "rbxassetid://" .. State.Skybox
        local sky = Lighting:FindFirstChild("Manic_Sky")
        if not sky then
            sky = Instance.new("Sky")
            sky.Name = "Manic_Sky"
            sky.Parent = Lighting
        end

        if sky.SkyboxBk ~= url then sky.SkyboxBk = url end
        if sky.SkyboxDn ~= url then sky.SkyboxDn = url end
        if sky.SkyboxFt ~= url then sky.SkyboxFt = url end
        if sky.SkyboxLf ~= url then sky.SkyboxLf = url end
        if sky.SkyboxRt ~= url then sky.SkyboxRt = url end
        if sky.SkyboxUp ~= url then sky.SkyboxUp = url end

        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") and v ~= sky then v:Destroy() end
            if v:IsA("Atmosphere") then v:Destroy() end
        end

        if Lighting.Brightness < 1 then Lighting.Brightness = 2 end
        if Lighting.FogEnd < 5000 then Lighting.FogEnd = 100000 end
    end
end)

-- ============================================
-- GRÁFICOS
-- ============================================
MapTab:Section({ Title = "ɢʀᴀꜰɪᴄᴏs" })

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

MapTab:Button({
    Title = "ꜰʟᴏʀɪᴅᴏ (ɢʀᴀᴅɪᴇɴᴛᴇ ʀᴏsᴀ)",
    Callback = function()
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
    end,
})

MapTab:Button({
    Title = "ʙᴏɴɪᴛᴏ (ʀᴇᴀʟɪsᴛᴀ)",
    Callback = function()
        ResetarLighting()
        pcall(function()
            Lighting.Ambient = Color3.fromRGB(90, 90, 90)
            Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 150)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
        end)
    end,
})

MapTab:Button({
    Title = "sᴏʟ (ʀᴇᴀʟɪsᴛᴀ ʟᴀʀᴀɴᴊᴀ)",
    Callback = function()
        ResetarLighting()
        pcall(function()
            Lighting.Ambient = Color3.fromRGB(255, 200, 150)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 180, 120)
            Lighting.ColorShift_Top = Color3.fromRGB(255, 150, 60)
            Lighting.ColorShift_Bottom = Color3.fromRGB(255, 120, 40)
            Lighting.Brightness = 3
            Lighting.ClockTime = 17
        end)
    end,
})

MapTab:Button({
    Title = "ʀᴇᴄᴏᴍᴇɴᴅᴀᴅᴏ (ʙʀᴀɴᴄᴏ ᴇ ᴘʀᴇᴛᴏ)",
    Callback = function()
        ResetarLighting()
        pcall(function()
            Lighting.Ambient = Color3.fromRGB(80, 80, 80)
            Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 120)
            Lighting.ColorShift_Top = Color3.fromRGB(200, 200, 200)
            Lighting.ColorShift_Bottom = Color3.fromRGB(50, 50, 50)
            Lighting.Brightness = 2
        end)
    end,
})

MapTab:Button({
    Title = "ʀᴇsᴇᴛᴀʀ ɢʀᴀꜰɪᴄᴏs",
    Callback = function() ResetarLighting() end,
})--[[ MANIC HUB | PARTE 3/8 — ʙᴏᴏᴍ ʙᴏx + Auto Ball ]]

local BoomTab = Window:Tab({ Title = "ʙᴏᴏᴍ ʙᴏx", Icon = "music" })
BoomTab:Section({ Title = "ᴍᴜsɪᴄᴀs" })

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
    {Nome = "ᴍᴇᴀɴᴛ ᴛᴏ ʙᴇ", ID = "84321228471359"},
    {Nome = "sᴏᴍᴇᴛɪᴍᴇs", ID = "128715303988843"},
    {Nome = "ʙʟᴏᴅʟʏɴ ʙʟᴏᴏᴅᴘᴏᴘ", ID = "96414211708215"},
}

for _, m in ipairs(Musicas) do
    BoomTab:Button({
        Title = m.Nome,
        Callback = function()
            TocarMusica(m.ID)
            WindUI:Notify({Title = "ʙᴏᴏᴍ ʙᴏx", Content = m.Nome, Duration = 2})
        end,
    })
end

BoomTab:Section({ Title = "ᴄᴜsᴛᴏᴍ" })

BoomTab:Input({
    Title = "ɪᴅ ᴅᴀ ᴍᴜsɪᴄᴀ",
    Placeholder = "ɪᴅ...",
    Callback = function(text)
        if text and text ~= "" then TocarMusica(text) end
    end,
})

BoomTab:Button({
    Title = "ᴘᴀʀᴀʀ ᴍᴜsɪᴄᴀ",
    Callback = function()
        if State.BoomBoxSound then
            pcall(function() State.BoomBoxSound:Stop(); State.BoomBoxSound:Destroy() end)
            State.BoomBoxSound = nil
        end
    end,
})

-- ============================================
-- BALL: Auto Ball (SEM teleporte)
-- ============================================
local BallTab = Window:Tab({ Title = "ʙᴀʟʟ", Icon = "circle" })
BallTab:Section({ Title = "ᴀᴜᴛᴏ ʙᴀʟʟ" })

local AutoFollowConnection = nil
local CurrentBall = nil
local ScanTimer = 0
local SteerStrength = 2.5
local ChaseSpeed = 40
local PlayerControls = nil

pcall(function()
    local PM = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
    PlayerControls = PM:GetControls()
end)

function GetChar()
    local c = LocalPlayer.Character
    if not c then return nil, nil, nil end
    return c, c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
end

function IsValidBall(part)
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

function FindClosestBall()
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

function StartAutoBall()
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

        if inv or ScanTimer >= 0.15 then
            ScanTimer = 0
            CurrentBall = FindClosestBall()
        end

        local ball = CurrentBall
        if not ball or not ball.Parent then return end

        local toBall = Vector3.new(ball.Position.X - root.Position.X, 0, ball.Position.Z - root.Position.Z)
        local dist = toBall.Magnitude
        local manual = GetManualDir()

        local fl = toBall.Unit
        local fin = fl
        if manual.Magnitude > 0.01 then
            local amt = math.clamp(manual.Magnitude, 0, 1)
            fin = fl * (1 - amt * 0.35) + manual * SteerStrength
            if fin.Magnitude > 0 then fin = fin.Unit end
        end
        hum:Move(fin, false)

        if dist > 2 then
            hum.WalkSpeed = math.max(hum.WalkSpeed, ChaseSpeed)
        elseif hum.WalkSpeed > (State.PlayerSpeed or 16) then
            hum.WalkSpeed = State.PlayerSpeed or 16
        end
    end)
end

function StopAutoBall()
    State.AutoBall = false
    CurrentBall = nil
    if AutoFollowConnection then
        AutoFollowConnection:Disconnect()
        AutoFollowConnection = nil
    end
    if Humanoid then
        Humanoid.WalkSpeed = State.PlayerSpeed or 16
    end
end

BallTab:Toggle({
    Title = "ᴀᴜᴛᴏ ʙᴀʟʟ",
    Value = false,
    Callback = function(v)
        if v then StartAutoBall() else StopAutoBall() end
    end,
})

BallTab:Slider({
    Title = "ꜰᴏʀᴄᴀ ᴅᴏ sᴛᴇᴇʀɪɴɢ",
    Value = {Min = 5, Max = 50, Default = 25},
    Callback = function(v) SteerStrength = v / 10 end,
})

BallTab:Slider({
    Title = "ᴠᴇʟᴏᴄɪᴅᴀᴅᴇ ᴀᴏ ᴘᴇʀsᴇɢᴜɪʀ",
    Value = {Min = 16, Max = 120, Default = 40},
    Callback = function(v) ChaseSpeed = v end,
})--[[ MANIC HUB | PARTE 4/8 — ʙᴀʟʟ Efeitos + Botão Flutuante ]]

BallTab:Section({ Title = "ᴀᴘᴀʀᴇɴᴄɪᴀ ᴅᴀ ʙᴀʟʟ" })

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
    State.BallTrail = false
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if IsValidBall(obj) then
            local f = obj:FindFirstChild("Manic_BallFire")
            if f then f:Destroy() end
            local t = obj:FindFirstChild("Manic_BallTrail")
            if t then t:Destroy() end
            for _, a in ipairs(obj:GetChildren()) do
                if a.Name == "Manic_TrailA0" or a.Name == "Manic_TrailA1" then a:Destroy() end
            end
        end
    end
end

BallTab:Colorpicker({
    Title = "ᴄᴏʀ ᴅᴀ ʙᴀʟʟ",
    Default = Color3.fromRGB(89, 247, 255),
    Callback = function(c) AplicarCorBall(c) end,
})

-- 🔥 FOGO
local FireColor1 = Color3.fromRGB(255, 100, 0)
local FireColor2 = Color3.fromRGB(255, 200, 0)
local FireSize = 15
local FireHeat = 25

BallTab:Toggle({
    Title = "ꜰᴏɢᴏ ɴᴀ ʙᴀʟʟ",
    Value = false,
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

BallTab:Colorpicker({
    Title = "ᴄᴏʀ ᴘʀɪɴᴄɪᴘᴀʟ ᴅᴏ ꜰᴏɢᴏ",
    Default = FireColor1,
    Callback = function(c)
        FireColor1 = c
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if IsValidBall(obj) then
                local f = obj:FindFirstChild("Manic_BallFire")
                if f then pcall(function() f.Color = c end) end
            end
        end
    end,
})

BallTab:Colorpicker({
    Title = "ᴄᴏʀ sᴇᴄᴜɴᴅᴀʀɪᴀ ᴅᴏ ꜰᴏɢᴏ",
    Default = FireColor2,
    Callback = function(c)
        FireColor2 = c
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if IsValidBall(obj) then
                local f = obj:FindFirstChild("Manic_BallFire")
                if f then pcall(function() f.SecondaryColor = c end) end
            end
        end
    end,
})

BallTab:Slider({
    Title = "ᴛᴀᴍᴀɴʜᴏ ᴅᴏ ꜰᴏɢᴏ",
    Value = {Min = 1, Max = 50, Default = 15},
    Callback = function(v) FireSize = v end,
})

BallTab:Slider({
    Title = "ɪɴᴛᴇɴsɪᴅᴀᴅᴇ ᴅᴏ ꜰᴏɢᴏ",
    Value = {Min = 1, Max = 50, Default = 25},
    Callback = function(v) FireHeat = v end,
})

-- ✨ TRAIL
local TrailEnabled = false
local TrailColor = Color3.fromRGB(120, 90, 240)
local TrailWidth = 1
local TrailLifetime = 1

BallTab:Toggle({
    Title = "ᴛʀᴀɪʟ ɴᴀ ʙᴀʟʟ",
    Value = false,
    Callback = function(v)
        TrailEnabled = v
        State.BallTrail = v
        if not v then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if IsValidBall(obj) then
                    local t = obj:FindFirstChild("Manic_BallTrail")
                    if t then t:Destroy() end
                    for _, a in ipairs(obj:GetChildren()) do
                        if a.Name == "Manic_TrailA0" or a.Name == "Manic_TrailA1" then a:Destroy() end
                    end
                end
            end
        end
    end,
})

BallTab:Colorpicker({
    Title = "ᴄᴏʀ ᴅᴏ ᴛʀᴀɪʟ",
    Default = TrailColor,
    Callback = function(c)
        TrailColor = c
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if IsValidBall(obj) then
                local t = obj:FindFirstChild("Manic_BallTrail")
                if t then pcall(function() t.Color = ColorSequence.new(c) end) end
            end
        end
    end,
})

BallTab:Slider({
    Title = "ʟᴀʀɢᴜʀᴀ ᴅᴏ ᴛʀᴀɪʟ",
    Value = {Min = 1, Max = 50, Default = 10},
    Callback = function(v) TrailWidth = v / 10 end,
})

BallTab:Slider({
    Title = "ᴅᴜʀᴀᴄᴀᴏ ᴅᴏ ᴛʀᴀɪʟ",
    Value = {Min = 1, Max = 50, Default = 10},
    Callback = function(v) TrailLifetime = v / 10 end,
})

BallTab:Button({
    Title = "ʀᴇsᴛᴀᴜʀᴀʀ ʙᴀʟʟ ᴏʀɪɢɪɴᴀʟ",
    Callback = function()
        RestaurarBall()
        TrailEnabled = false
        WindUI:Notify({Title = "ʙᴀʟʟ", Content = "ʀᴇsᴛᴀᴜʀᴀᴅᴀ", Duration = 2})
    end,
})

-- Loop Fire + Trail
spawn(function()
    while true do
        task.wait(0.25)
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if IsValidBall(obj) then
                if State.BallColor and obj.Color ~= State.BallColor then
                    pcall(function() obj.Color = State.BallColor end)
                end
                if State.BallFire then
                    local f = obj:FindFirstChild("Manic_BallFire")
                    if not f then
                        f = Instance.new("Fire")
                        f.Name = "Manic_BallFire"
                        f.Size = FireSize
                        f.Heat = FireHeat
                        f.Color = FireColor1
                        f.SecondaryColor = FireColor2
                        f.Parent = obj
                    else
                        if f.Size ~= FireSize then f.Size = FireSize end
                        if f.Heat ~= FireHeat then f.Heat = FireHeat end
                        if f.Color ~= FireColor1 then f.Color = FireColor1 end
                        if f.SecondaryColor ~= FireColor2 then f.SecondaryColor = FireColor2 end
                    end
                else
                    local f = obj:FindFirstChild("Manic_BallFire")
                    if f then f:Destroy() end
                end
                if TrailEnabled then
                    local t = obj:FindFirstChild("Manic_BallTrail")
                    if not t then
                        local a0 = Instance.new("Attachment", obj)
                        a0.Name = "Manic_TrailA0"
                        a0.Position = Vector3.new(-0.5, 0, 0)
                        local a1 = Instance.new("Attachment", obj)
                        a1.Name = "Manic_TrailA1"
                        a1.Position = Vector3.new(0.5, 0, 0)
                        t = Instance.new("Trail")
                        t.Name = "Manic_BallTrail"
                        t.Attachment0 = a0
                        t.Attachment1 = a1
                        t.Color = ColorSequence.new(TrailColor)
                        t.WidthScale = NumberSequence.new(TrailWidth)
                        t.Lifetime = TrailLifetime
                        t.MinLength = 0.1
                        t.Parent = obj
                    else
                        if t.Color ~= ColorSequence.new(TrailColor) then
                            t.Color = ColorSequence.new(TrailColor)
                        end
                        if t.Lifetime ~= TrailLifetime then
                            t.Lifetime = TrailLifetime
                        end
                        if t.WidthScale ~= NumberSequence.new(TrailWidth) then
                            t.WidthScale = NumberSequence.new(TrailWidth)
                        end
                    end
                else
                    local t = obj:FindFirstChild("Manic_BallTrail")
                    if t then t:Destroy() end
                    for _, a in ipairs(obj:GetChildren()) do
                        if a.Name == "Manic_TrailA0" or a.Name == "Manic_TrailA1" then a:Destroy() end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- CURVA BALL (loadstring externo)
-- ============================================
BallTab:Section({ Title = "ᴄᴜʀᴠᴀ ʙᴀʟʟ" })

BallTab:Button({
    Title = "ᴀʙʀɪʀ ᴄᴜʀᴠᴀ ʙᴀʟʟ",
    Desc = "ᴇxᴇᴄᴜᴛᴀ ᴏ sᴄʀɪᴘᴛ ᴅᴇ ᴄᴜʀᴠᴀ ᴇxᴛᴇʀɴᴏ",
    Callback = function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/7ixqsxx7"))()
        end)
        if ok then
            WindUI:Notify({Title = "ᴄᴜʀᴠᴀ ʙᴀʟʟ", Content = "sᴄʀɪᴘᴛ ᴇxᴇᴄᴜᴛᴀᴅᴏ", Duration = 3, Icon = "check-circle"})
        else
            WindUI:Notify({Title = "ᴄᴜʀᴠᴀ ʙᴀʟʟ", Content = "ᴇʀʀᴏ: " .. tostring(err), Duration = 5, Icon = "x-circle"})
        end
    end,
})

BallTab:Button({
    Title = "ʀᴇᴄᴀʀʀᴇɢᴀʀ ᴄᴜʀᴠᴀ",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/7ixqsxx7"))()
        end)
    end,
})

-- ============================================
-- BOTÃO FLUTUANTE (arrastável + lock)
-- ============================================
BallTab:Section({ Title = "ʙᴏᴛᴀᴏ ꜰʟᴜᴛᴀɴᴛᴇ" })

local FloatGui = nil
local FloatBtn = nil
local FloatLocked = false
local FloatVisible = false

local function CriarFloatBtn()
    if FloatGui then FloatGui:Destroy() end

    FloatGui = Instance.new("ScreenGui")
    FloatGui.Name = "ManicFloat"
    FloatGui.ResetOnSpawn = false
    FloatGui.IgnoreGuiInset = true
    FloatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    FloatGui.Parent = CoreGui

    FloatBtn = Instance.new("TextButton")
    FloatBtn.Size = UDim2.new(0, 60, 0, 60)
    FloatBtn.Position = UDim2.new(0.05, 0, 0.5, 0)
    FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    FloatBtn.Text = "⚽"
    FloatBtn.TextSize = 30
    FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FloatBtn.BorderSizePixel = 0
    FloatBtn.AutoButtonColor = false
    FloatBtn.Active = true
    FloatBtn.Parent = FloatGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = FloatBtn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(120, 90, 240)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = FloatBtn

    local dragging, dragInput, dragStart, startPos
    FloatBtn.InputBegan:Connect(function(input)
        if FloatLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = FloatBtn.Position
            input.Changed:Connect(function(s)
                if s.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    FloatBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and not FloatLocked then
            local delta = input.Position - dragStart
            FloatBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    FloatBtn.MouseButton1Click:Connect(function()
        State.AutoBall = not State.AutoBall
        if State.AutoBall then
            StartAutoBall()
            FloatBtn.BackgroundColor3 = Color3.fromRGB(120, 90, 240)
        else
            StopAutoBall()
            FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        end
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "ᴀᴜᴛᴏ ʙᴀʟʟ",
                Text = State.AutoBall and "ᴀᴛɪᴠᴀᴅᴏ" or "ᴅᴇsᴀᴛɪᴠᴀᴅᴏ",
                Duration = 2
            })
        end)
    end)
end

BallTab:Toggle({
    Title = "ᴍᴏsᴛʀᴀʀ ʙᴏᴛᴀᴏ ꜰʟᴜᴛᴜᴀɴᴛᴇ",
    Desc = "ʙᴏᴛᴀᴏ ᴀʀʀᴀsᴛᴀᴠᴇʟ ᴘᴀʀᴀ ᴛᴏɢɢʟᴀʀ ᴀᴜᴛᴏ ʙᴀʟʟ",
    Value = false,
    Callback = function(v)
        FloatVisible = v
        if v then
            if not FloatBtn then CriarFloatBtn() end
            FloatBtn.Visible = true
        elseif FloatBtn then
            FloatBtn.Visible = false
        end
    end,
})

BallTab:Toggle({
    Title = "ᴛʀᴀᴠᴀʀ ʙᴏᴛᴀᴏ (ʟᴏᴄᴋ)",
    Desc = "ɪᴍᴘᴇᴅᴇ ᴅᴇ ᴀʀʀᴀsᴛᴀʀ ᴏ ʙᴏᴛᴀᴏ",
    Value = false,
    Callback = function(v) FloatLocked = v end,
})

BallTab:Button({
    Title = "ʀᴇᴄʀɪᴀʀ ʙᴏᴛᴀᴏ ꜰʟᴜᴛᴀɴᴛᴇ",
    Callback = function()
        if FloatVisible then
            CriarFloatBtn()
            FloatBtn.Visible = true
        end
    end,
})--[[ MANIC HUB | PARTE 5/8 — ᴘʟᴀʏᴇʀ + ᴄʜᴀʀs ]]

local PlayerTab = Window:Tab({ Title = "ᴘʟᴀʏᴇʀ", Icon = "user" })
PlayerTab:Section({ Title = "ᴠᴇʟᴏᴄɪᴅᴀᴅᴇ" })

local TrailObj = nil
local TrailColorP = Color3.fromRGB(120, 90, 240)

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
    TrailObj.Color = ColorSequence.new(TrailColorP)
    TrailObj.Lifetime = 1
    TrailObj.MinLength = 0.1
    TrailObj.WidthScale = NumberSequence.new(0.5)
    TrailObj.Parent = hrp
end

PlayerTab:Slider({
    Title = "ᴠᴇʟᴏᴄɪᴅᴀᴅᴇ ᴅᴏ ᴊᴏɢᴀᴅᴏʀ",
    Value = {Min = 16, Max = 200, Default = 16},
    Callback = function(v)
        State.PlayerSpeed = v
        if Humanoid then pcall(function() Humanoid.WalkSpeed = v end) end
    end,
})

RunService.RenderStepped:Connect(function()
    if not State.PlayerSpeed then return end
    if not Humanoid or Humanoid.Health <= 0 then return end
    if Humanoid.WalkSpeed ~= State.PlayerSpeed then
        pcall(function() Humanoid.WalkSpeed = State.PlayerSpeed end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    if Humanoid and State.PlayerSpeed then
        pcall(function() Humanoid.WalkSpeed = State.PlayerSpeed end)
    end
    if State.Trail then CriarTrail() end
end)

PlayerTab:Section({ Title = "ᴛʀᴀɪʟ" })

PlayerTab:Toggle({
    Title = "ᴛʀᴀɪʟ ɴᴏ ᴊᴏɢᴀᴅᴏʀ",
    Value = false,
    Callback = function(v)
        State.Trail = v
        if v then CriarTrail()
        elseif TrailObj then TrailObj:Destroy(); TrailObj = nil end
    end,
})

PlayerTab:Colorpicker({
    Title = "ᴄᴏʀ ᴅᴏ ᴛʀᴀɪʟ",
    Default = TrailColorP,
    Callback = function(c)
        TrailColorP = c
        if TrailObj then TrailObj.Color = ColorSequence.new(c) end
    end,
})

PlayerTab:Section({ Title = "ᴛᴇʟᴀ ᴇsᴛɪᴄᴀᴅᴀ" })

local StretchHConn = nil
local StretchVConn = nil

PlayerTab:Toggle({
    Title = "ᴇsᴛɪᴄᴀʀ ʜᴏʀɪᴢᴏɴᴛᴀʟ (ʟᴀᴅᴏs)",
    Value = false,
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

PlayerTab:Toggle({
    Title = "ᴇsᴛɪᴄᴀʀ ᴠᴇʀᴛɪᴄᴀʟ (ᴄɪᴍᴀ)",
    Value = false,
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
local CharsTab = Window:Tab({ Title = "ᴄʜᴀʀs", Icon = "users" })
CharsTab:Section({ Title = "ᴄʜᴀʀs ᴅɪsᴘᴏɴɪᴠᴇɪs" })

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
    CharsTab:Button({
        Title = char,
        Callback = function()
            SendChar(char)
            WindUI:Notify({Title = "ᴄʜᴀʀ", Content = char, Duration = 2})
        end,
    })
end--[[ MANIC HUB | PARTE 6/8 — ᴀᴄ + ʀᴇᴀᴄʜ + ᴀᴜᴛᴏ ᴅʀɪᴠᴇ ]]

local ACTab = Window:Tab({ Title = "ᴀᴄ", Icon = "shield" })
ACTab:Section({ Title = "ᴀᴜᴛᴏ ᴄᴀᴛᴄʜ" })

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
            if p then pcall(FTI, p, ball, 0); pcall(FTI, p, ball, 1) end
        end
    end
    AutoCatchLast = os.clock() + AutoCatchDelay
end

ACTab:Toggle({
    Title = "ᴀᴜᴛᴏ ᴄᴀᴛᴄʜ",
    Value = false,
    Callback = function(v) State.AutoCatch = v end,
})

ACTab:Slider({
    Title = "ᴀʟᴄᴀɴᴄᴇ",
    Value = {Min = 3, Max = 30, Default = 8},
    Callback = function(v) AutoCatchRange = v end,
})

ACTab:Slider({
    Title = "ᴄᴏᴏʟᴅᴏᴡɴ (x100ᴍs)",
    Value = {Min = 2, Max = 30, Default = 8},
    Callback = function(v) AutoCatchDelay = v / 10 end,
})

ACTab:Toggle({
    Title = "ᴍᴏsᴛʀᴀʀ ʜɪᴛʙᴏx",
    Value = false,
    Callback = function(v) AC_Hitbox = v end,
})

-- ============================================
-- REACH
-- ============================================
local ReachTab = Window:Tab({ Title = "ʀᴇᴀᴄʜ", Icon = "ruler" })
ReachTab:Section({ Title = "ʀᴇᴀᴄʜ" })

local ReachLast = 0

ReachTab:Toggle({
    Title = "ᴀᴛɪᴠᴀʀ ʀᴇᴀᴄʜ",
    Value = false,
    Callback = function(v) State.Reach = v end,
})

ReachTab:Slider({
    Title = "ᴅɪsᴛᴀɴᴄɪᴀ",
    Value = {Min = 1, Max = 50, Default = 10},
    Callback = function(v) State.ReachDistance = v end,
})

-- ============================================
-- AUTO DRIVE
-- ============================================
local DriveTab = Window:Tab({ Title = "ᴀᴜᴛᴏ ᴅʀɪᴠᴇ", Icon = "car" })
DriveTab:Section({ Title = "ᴀᴜᴛᴏ ᴅʀɪᴠᴇ (ɢᴋ)" })

local GKBotoes = {}
local AutoDiveLast = 0
local AutoDiveRange = 15
local AutoDiveCooldown = 0.8
local AutoDiveConn = nil
local AutoDiveMode = "ᴀᴜᴛᴏ"

local GK_BUTTON_TEXTS = {
    ["ᴇsǫᴜᴇʀᴅᴀ ᴀʟᴛᴏ"] = "High Dive Left",
    ["ᴅɪʀᴇɪᴛᴀ ᴀʟᴛᴏ"] = "High Dive Right",
    ["ᴇsǫᴜᴇʀᴅᴀ ʙᴀɪxᴏ"] = "Dive Left",
    ["ᴅɪʀᴇɪᴛᴀ ʙᴀɪxᴏ"] = "Dive Right",
    ["ᴀɢᴀʀʀᴀʀ ᴀʟᴛᴏ"] = "High Catch",
    ["ᴀɢᴀʀʀᴀʀ ʙᴀɪxᴏ"] = "Low Catch",
    ["ʀᴇꜰʟᴇxᴏ"] = "Reflex",
    ["ꜰʀᴇɴᴛᴇ"] = "Front Dive",
    ["ᴇɴꜰʀᴇɴᴛᴀʀ"] = "Rush",
}

local function EscanearBotoesGK()
    GKBotoes = {}
    pcall(function()
        for _, v in ipairs(PlayerGui:GetDescendants()) do
            if v:IsA("TextButton") or v:IsA("ImageButton") then
                local nome = v.Name
                local texto = ""
                pcall(function() texto = v.Text end)
                if nome:find("GK") or nome:find("C2")
                or texto:find("Dive") or texto:find("Catch")
                or texto:find("High") or texto:find("Low")
                or texto:find("Reflex") or texto:find("Forward")
                or texto:find("Front") or texto:find("Rush") then
                    table.insert(GKBotoes, {Button = v, Nome = nome, Texto = texto})
                end
            end
        end
    end)
    print("[ᴀᴜᴛᴏ ᴅʀɪᴠᴇ] ʙᴏᴛᴏᴇs:", #GKBotoes)
end

EscanearBotoesGK()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    EscanearBotoesGK()
end)

local function EncontrarBotaoPorTexto(texto)
    for _, info in ipairs(GKBotoes) do
        if info.Texto and info.Texto:lower() == texto:lower() then
            return info.Button
        end
    end
    for _, info in ipairs(GKBotoes) do
        if info.Texto and info.Texto:lower():find(texto:lower(), 1, true) then
            return info.Button
        end
    end
    return nil
end

local function ClicarBotao(botao)
    if not botao then return end
    pcall(function() firesignal(botao.Activated) end)
    pcall(function() firesignal(botao.MouseButton1Click) end)
    pcall(function() firesignal(botao.MouseButton1Down) end)
    pcall(function() firesignal(botao.MouseButton1Up) end)
    pcall(function() firesignal(botao.TouchTap) end)
end

local function AnalisarBola()
    local ball = CurrentBall or FindClosestBall()
    if not ball or not RootPart then return nil end
    local vel = ball.AssemblyLinearVelocity
    local dist = (ball.Position - RootPart.Position).Magnitude
    local tempo = 0
    if vel.Magnitude > 3 then
        tempo = dist / vel.Magnitude
        tempo = math.clamp(tempo, 0, 0.6)
    end
    local posFutura = ball.Position + (vel * tempo)
    local camRight = Camera.CFrame.RightVector
    local direitaH = Vector3.new(camRight.X, 0, camRight.Z)
    if direitaH.Magnitude < 0.1 then direitaH = Vector3.new(1, 0, 0) end
    direitaH = direitaH.Unit
    local delta = posFutura - RootPart.Position
    local deltaH = Vector3.new(delta.X, 0, delta.Z)
    local lado = deltaH:Dot(direitaH)
    local altura = posFutura.Y - RootPart.Position.Y
    return {ball = ball, vel = vel, dist = dist, lado = lado, altura = altura}
end

local function ExecutarDive()
    local info = AnalisarBola()
    if not info then return end
    local lado = info.lado
    local altura = info.altura
    local textoAlvo
    if AutoDiveMode ~= "ᴀᴜᴛᴏ" then
        textoAlvo = GK_BUTTON_TEXTS[AutoDiveMode]
    else
        if altura > 3.5 then
            textoAlvo = lado > 0 and "High Dive Right" or "High Dive Left"
        else
            textoAlvo = lado > 0 and "Dive Right" or "Dive Left"
        end
    end
    if not textoAlvo then return end
    local botao = EncontrarBotaoPorTexto(textoAlvo)
    if botao then
        ClicarBotao(botao)
        print(string.format("[ᴀᴜᴛᴏ ᴅʀɪᴠᴇ] %s | ʟᴀᴅᴏ: %.1f | ᴀʟᴛᴜʀᴀ: %.1f", textoAlvo, lado, altura))
    end
end

local function StartAutoDive()
    if AutoDiveConn then return end
    if #GKBotoes == 0 then EscanearBotoesGK() end
    AutoDiveConn = RunService.Heartbeat:Connect(function()
        if not State.AutoDrive then return end
        if not RootPart or not RootPart.Parent then return end
        if tick() - AutoDiveLast < AutoDiveCooldown then return end
        local ball = CurrentBall or FindClosestBall()
        if not ball or not ball.Parent then return end
        local dist = (ball.Position - RootPart.Position).Magnitude
        if dist > AutoDiveRange then return end
        local ballVel = ball.AssemblyLinearVelocity
        if ballVel.Magnitude < 5 then return end
        local dirParaPlayer = (RootPart.Position - ball.Position)
        local dirH = Vector3.new(dirParaPlayer.X, 0, dirParaPlayer.Z)
        if dirH.Magnitude < 0.1 then return end
        local ballVelH = Vector3.new(ballVel.X, 0, ballVel.Z)
        if ballVelH.Magnitude < 0.1 then return end
        local dot = ballVelH.Unit:Dot(dirH.Unit)
        if dot > 0.15 then
            AutoDiveLast = tick()
            task.spawn(ExecutarDive)
        end
    end)
end

local function StopAutoDive()
    if AutoDiveConn then
        AutoDiveConn:Disconnect()
        AutoDiveConn = nil
    end
end

DriveTab:Toggle({
    Title = "ᴀᴛɪᴠᴀʀ ᴀᴜᴛᴏ ᴅʀɪᴠᴇ",
    Value = false,
    Callback = function(v)
        State.AutoDrive = v
        if v then StartAutoDive() else StopAutoDive() end
    end,
})

DriveTab:Dropdown({
    Title = "ᴍᴏᴅᴏ ᴅᴏ ᴅɪᴠᴇ",
    Values = {"ᴀᴜᴛᴏ", "ᴇsǫᴜᴇʀᴅᴀ ᴀʟᴛᴏ", "ᴅɪʀᴇɪᴛᴀ ᴀʟᴛᴏ", "ᴇsǫᴜᴇʀᴅᴀ ʙᴀɪxᴏ", "ᴅɪʀᴇɪᴛᴀ ʙᴀɪxᴏ",
              "ᴀɢᴀʀʀᴀʀ ᴀʟᴛᴏ", "ᴀɢᴀʀʀᴀʀ ʙᴀɪxᴏ", "ʀᴇꜰʟᴇxᴏ", "ꜰʀᴇɴᴛᴇ", "ᴇɴꜰʀᴇɴᴛᴀʀ"},
    Value = "ᴀᴜᴛᴏ",
    Callback = function(v) AutoDiveMode = v end,
})

DriveTab:Slider({
    Title = "ᴀʟᴄᴀɴᴄᴇ ᴅᴏ ᴅɪᴠᴇ",
    Value = {Min = 5, Max = 30, Default = 15},
    Callback = function(v) AutoDiveRange = v end,
})

DriveTab:Slider({
    Title = "ᴄᴏᴏʟᴅᴏᴡɴ ᴅᴏ ᴅɪᴠᴇ",
    Value = {Min = 3, Max = 50, Default = 8},
    Callback = function(v) AutoDiveCooldown = v / 10 end,
})

DriveTab:Button({
    Title = "ʀᴇᴇsᴄᴀɴᴇᴀʀ ʙᴏᴛᴏᴇs ɢᴋ",
    Callback = function()
        EscanearBotoesGK()
        WindUI:Notify({Title = "ᴀᴜᴛᴏ ᴅʀɪᴠᴇ", Content = "ʙᴏᴛᴏᴇs: " .. #GKBotoes, Duration = 3})
    end,
})--[[ MANIC HUB | PARTE 7/8 — Loops + Finalização ]]

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

WindUI:Notify({
    Title = "Manic Hub",
    Content = "Carregado! Use LeftShift para abrir/fechar.",
    Duration = 5,
    Icon = "check-circle",
})

print("[MANIC HUB] Carregado!")
print("[MANIC HUB] FTI:", tostring(FTI ~= nil))
print("[MANIC HUB] CatchRemote:", tostring(CatchRemote ~= nil))
print("[MANIC HUB] Botões GK:", #GKBotoes)--[[ MANIC HUB | PARTE 8/8 — sᴄʀɪᴘᴛ + ᴄʀᴇᴅɪᴛᴏs ]]

local ScriptTab = Window:Tab({ Title = "sᴄʀɪᴘᴛ", Icon = "settings" })

-- ============================================
-- ASSETS (FIX v2 - multi-target)
-- ============================================
ScriptTab:Section({ Title = "ᴘᴇʀsᴏɴᴀʟɪᴢᴀʀ ᴀssᴇᴛs" })

local BackgroundAtual = "11717400651"
local BackgroundTargets = {}

local function EscanearBackgrounds()
    BackgroundTargets = {}
    pcall(function()
        for _, v in ipairs(Window.GUI:GetDescendants()) do
            if v:IsA("ImageLabel") then
                pcall(function()
                    local abs = v.AbsoluteSize
                    if abs.X >= 300 and abs.Y >= 200 then
                        table.insert(BackgroundTargets, v)
                    end
                end)
            end
        end
    end)
    print("[sᴄʀɪᴘᴛ] ɪᴍᴀɢᴇɴs ᴅᴇ ꜰᴜɴᴅᴏ ᴇɴᴄᴏɴᴛʀᴀᴅᴀs:", #BackgroundTargets)
end

EscanearBackgrounds()
task.delay(1, EscanearBackgrounds)
task.delay(3, EscanearBackgrounds)

local function AplicarBackground(assetId)
    EscanearBackgrounds()
    local url = "rbxassetid://" .. assetId:gsub("rbxassetid://", "")
    local count = 0
    for _, bg in ipairs(BackgroundTargets) do
        if bg and bg.Parent then
            pcall(function()
                bg.Image = url
                bg.ImageTransparency = 0.35
                bg.Visible = true
                count = count + 1
            end)
        end
    end
    BackgroundAtual = assetId

    if count > 0 then
        WindUI:Notify({Title = "sᴄʀɪᴘᴛ", Content = "ɪᴍᴀɢᴇᴍ ᴀᴘʟɪᴄᴀᴅᴀ", Duration = 2, Icon = "check-circle"})
    else
        WindUI:Notify({Title = "sᴄʀɪᴘᴛ", Content = "ɴᴀᴏ ᴇɴᴄᴏɴᴛʀᴇɪ ɪᴍᴀɢᴇᴍ", Duration = 3, Icon = "x-circle"})
    end
end

ScriptTab:Input({
    Title = "ɪᴅ ᴍᴀɴᴜᴀʟ",
    Placeholder = "sᴏᴍᴇɴᴛᴇ ᴏ ɪᴅ",
    Callback = function(text)
        if text and text ~= "" then
            BackgroundAtual = text:gsub("rbxassetid://", "")
        end
    end,
})

ScriptTab:Slider({
    Title = "ᴛʀᴀɴsᴘᴀʀᴇɴᴄɪᴀ",
    Value = {Min = 0, Max = 100, Default = 35},
    Callback = function(v)
        local alpha = v / 100
        for _, bg in ipairs(BackgroundTargets) do
            if bg and bg.Parent then
                pcall(function() bg.ImageTransparency = alpha end)
            end
        end
    end,
})

ScriptTab:Button({
    Title = "ᴀᴘʟɪᴄᴀʀ ɪᴅ ᴍᴀɴᴜᴀʟ",
    Callback = function()
        AplicarBackground(BackgroundAtual)
    end,
})

ScriptTab:Button({
    Title = "ʀᴇᴇsᴄᴀɴᴇᴀʀ ɪᴍᴀɢᴇɴs",
    Callback = function()
        EscanearBackgrounds()
        WindUI:Notify({Title = "sᴄʀɪᴘᴛ", Content = #BackgroundTargets .. " ᴇɴᴄᴏɴᴛʀᴀᴅᴀs", Duration = 2})
    end,
})

ScriptTab:Section({ Title = "ᴀssᴇᴛs ᴘʀᴇsᴇᴛ" })

local ASSETS_PRESET = {
    {Nome = "ᴀssᴇᴛ 1", ID = "86503454003964"},
    {Nome = "ᴀssᴇᴛ 2", ID = "17228542848"},
    {Nome = "ᴀssᴇᴛ 3 (ᴘᴀᴅʀᴀᴏ)", ID = "11717400651"},
    {Nome = "ᴀssᴇᴛ 4", ID = "111996173475442"},
    {Nome = "ᴀssᴇᴛ 5", ID = "15423397129"},
}

for _, asset in ipairs(ASSETS_PRESET) do
    ScriptTab:Button({
        Title = asset.Nome,
        Callback = function() AplicarBackground(asset.ID) end,
    })
end

ScriptTab:Button({
    Title = "ʀᴇsᴛᴀᴜʀᴀʀ ᴘᴀᴅʀᴀᴏ",
    Callback = function()
        AplicarBackground("11717400651")
    end,
})

-- ============================================
-- TÍTULO E AUTOR
-- ============================================
ScriptTab:Section({ Title = "ᴘᴇʀsᴏɴᴀʟɪᴢᴀʀ ᴛɪᴛᴜʟᴏ" })

ScriptTab:Input({
    Title = "ɴᴏᴠᴏ ᴛɪᴛᴜʟᴏ",
    Placeholder = "ᴍᴀɴɪᴄ ʜᴜʙ",
    Callback = function(text)
        if text and text ~= "" then
            pcall(function()
                for _, v in ipairs(Window.GUI:GetDescendants()) do
                    if v:IsA("TextLabel") and (v.Text == "Manic Hub" or v.Text == "ᴍᴀɴɪᴄ ʜᴜʙ") then
                        v.Text = text
                        break
                    end
                end
            end)
        end
    end,
})

ScriptTab:Input({
    Title = "ɴᴏᴠᴏ ᴀᴜᴛᴏʀ",
    Placeholder = "ᴛʜᴇᴀɴɢᴇʟʟᴀɴᴅxꜱ",
    Callback = function(text)
        if text and text ~= "" then
            pcall(function()
                for _, v in ipairs(Window.GUI:GetDescendants()) do
                    if v:IsA("TextLabel") and (v.Text == "Manic Hub | TCS" or v.Text:find("TCS")) then
                        v.Text = text
                        break
                    end
                end
            end)
        end
    end,
})

-- ============================================
-- CORES DO TEMA
-- ============================================
ScriptTab:Section({ Title = "ᴄᴏʀᴇs ᴅᴏ ᴛᴇᴍᴀ" })

ScriptTab:Colorpicker({
    Title = "ᴄᴏʀ ᴘʀɪɴᴄɪᴘᴀʟ",
    Default = Color3.fromRGB(120, 90, 240),
    Callback = function(c)
        pcall(function()
            if Window.SetTheme then Window:SetTheme({ Accent = c }) end
        end)
    end,
})

-- ============================================
-- INFO
-- ============================================
ScriptTab:Section({ Title = "ɪɴꜰᴏʀᴍᴀᴄᴏᴇs" })

ScriptTab:Button({
    Title = "ᴠᴇʀsᴀᴏ: ᴠ2.0",
    Desc = "ᴍᴀɴɪᴄ ʜᴜʙ • ᴛᴄs ᴇᴅɪᴛɪᴏɴ",
    Callback = function() end,
})

ScriptTab:Button({
    Title = "ᴀᴛᴀʟʜᴏ: ʟᴇꜰᴛsʜɪꜰᴛ",
    Desc = "ᴀʙʀᴇ/ꜰᴇᴄʜᴀ ᴏ ᴍᴇɴᴜ",
    Callback = function() end,
})

-- ============================================
-- CRÉDITOS
-- ============================================
ScriptTab:Section({ Title = "ᴄʀᴇᴅɪᴛᴏs" })

local CreditsFrame = Instance.new("Frame")
CreditsFrame.Size = UDim2.new(1, -10, 0, 100)
CreditsFrame.BackgroundColor3 = Color3.fromRGB(25, 22, 40)
CreditsFrame.BackgroundTransparency = 0.3
CreditsFrame.BorderSizePixel = 0
CreditsFrame.Parent = ScriptTab.Container or ScriptTab.Page or ScriptTab

local CFCorner = Instance.new("UICorner")
CFCorner.CornerRadius = UDim.new(0, 10)
CFCorner.Parent = CreditsFrame

local CFStroke = Instance.new("UIStroke")
CFStroke.Color = Color3.fromRGB(120, 90, 240)
CFStroke.Thickness = 1.5
CFStroke.Transparency = 0.4
CFStroke.Parent = CreditsFrame

local CFGradient = Instance.new("UIGradient")
CFGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 90, 240)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 180, 255)),
})
CFGradient.Rotation = 45
CFGradient.Parent = CreditsFrame

local CreditsTitle = Instance.new("TextLabel")
CreditsTitle.Size = UDim2.new(1, -20, 0, 30)
CreditsTitle.Position = UDim2.new(0, 10, 0, 5)
CreditsTitle.BackgroundTransparency = 1
CreditsTitle.Text = "ᴄʀɪᴀᴅᴏ ᴘᴏʀ"
CreditsTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
CreditsTitle.TextSize = 12
CreditsTitle.Font = Enum.Font.GothamBold
CreditsTitle.TextXAlignment = Enum.TextXAlignment.Center
CreditsTitle.Parent = CreditsFrame

local CreditsName = Instance.new("TextLabel")
CreditsName.Size = UDim2.new(1, -20, 0, 40)
CreditsName.Position = UDim2.new(0, 10, 0, 35)
CreditsName.BackgroundTransparency = 1
CreditsName.Text = "𝕿𝖍𝖊𝕬𝖓𝖌𝖊𝖑𝕷𝖆𝖓𝖉𝖝𝖘"
CreditsName.TextColor3 = Color3.fromRGB(255, 255, 255)
CreditsName.TextSize = 22
CreditsName.Font = Enum.Font.GothamBlack
CreditsName.TextXAlignment = Enum.TextXAlignment.Center
CreditsName.Parent = CreditsFrame

local CreditsSub = Instance.new("TextLabel")
CreditsSub.Size = UDim2.new(1, -20, 0, 20)
CreditsSub.Position = UDim2.new(0, 10, 0, 75)
CreditsSub.BackgroundTransparency = 1
CreditsSub.Text = "ᴍᴀɴɪᴄ ʜᴜʙ • ᴛʜᴇ ᴄʟᴀssɪᴄ sᴏᴄᴄᴇʀ"
CreditsSub.TextColor3 = Color3.fromRGB(150, 150, 170)
CreditsSub.TextSize = 11
CreditsSub.Font = Enum.Font.Gotham
CreditsSub.TextXAlignment = Enum.TextXAlignment.Center
CreditsSub.Parent = CreditsFrame

ScriptTab:Button({
    Title = "ᴄᴏᴘɪᴀʀ ɴᴏᴍᴇ ᴅᴏ ᴄʀɪᴀᴅᴏʀ",
    Callback = function()
        pcall(function()
            if setclipboard then setclipboard("𝕿𝖍𝖊𝕬𝖓𝖌𝖊𝖑𝕷𝖆𝖓𝖉𝖝𝖘") end
        end)
        WindUI:Notify({Title = "sᴄʀɪᴘᴛ", Content = "ɴᴏᴍᴇ ᴄᴏᴘɪᴀᴅᴏ", Duration = 2, Icon = "copy"})
    end,
})

ScriptTab:Section({ Title = "ᴀɢʀᴀᴅᴇᴄɪᴍᴇɴᴛᴏs" })

local ThanksLabel = Instance.new("TextLabel")
ThanksLabel.Size = UDim2.new(1, -10, 0, 60)
ThanksLabel.BackgroundTransparency = 1
ThanksLabel.Text = "ᴏʙʀɪɢᴀᴅᴏ ᴘᴏʀ ᴜsᴀʀ ᴏ ᴍᴀɴɪᴄ ʜᴜʙ!\nsᴇ ᴄᴜʀᴛɪᴜ, ᴄᴏᴍᴘᴀʀᴛɪʟʜᴀ ᴄᴏᴍ ᴏs ᴀᴍɪɢᴏs."
ThanksLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
ThanksLabel.TextSize = 12
ThanksLabel.Font = Enum.Font.Gotham
ThanksLabel.TextWrapped = true
ThanksLabel.TextXAlignment = Enum.TextXAlignment.Center
ThanksLabel.Parent = ScriptTab.Container or ScriptTab.Page or ScriptTab

print("[MANIC HUB] sᴄʀɪᴘᴛ ᴀᴅɪᴄɪᴏɴᴀᴅᴀ!")
print("[MANIC HUB] ᴄʀɪᴀᴅᴏ ᴘᴏʀ: 𝕿𝖍𝖊𝕬𝖓𝖌𝖊𝖑𝕷𝖆𝖓𝖉𝖝𝖘")
