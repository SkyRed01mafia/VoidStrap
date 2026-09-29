--[[ MANIC HUB v3.0 | TCS | WindUI | PARTE 1/11 ]]

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

-- WINDUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Manic Hub",
    Icon = "eye",
    Author = "The Classic Soccer",
    Folder = "ManicHub",
    Size = UDim2.fromOffset(620, 480),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true,
    Background = "rbxassetid://92048348535477",
    BackgroundImageTransparency = 0.35,
})

Window:Tag({
    Title = "v3.0",
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
end)

-- FPS COUNTER
local FpsGui = Instance.new("ScreenGui")
FpsGui.Name = "ManicFPS"
FpsGui.ResetOnSpawn = false
FpsGui.IgnoreGuiInset = true
FpsGui.Parent = CoreGui

local FpsBox = Instance.new("TextLabel")
FpsBox.Parent = FpsGui
FpsBox.Size = UDim2.new(0, 90, 0, 32)
FpsBox.Position = UDim2.new(0, 12, 0, 110)
FpsBox.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
FpsBox.BackgroundTransparency = 0.3
FpsBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsBox.TextSize = 13
FpsBox.Font = Enum.Font.GothamBold
FpsBox.Text = "FPS 0"
FpsBox.BorderSizePixel = 0
FpsBox.ZIndex = 100

local FpsCorner = Instance.new("UICorner")
FpsCorner.CornerRadius = UDim.new(0, 6)
FpsCorner.Parent = FpsBox

local fpsCount, fpsTime = 0, tick()
RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    local now = tick()
    if now - fpsTime >= 1 then
        FpsBox.Text = "FPS " .. fpsCount
        fpsCount = 0
        fpsTime = now
    end
end)--[[ MANIC HUB | PARTE 2/11 — ᴍᴀᴘᴀ ]]

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

-- SKYBOX
MapTab:Section({ Title = "sᴋʏʙᴏx" })

local function ForceSkyTCS(assetId)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local n = string.lower(obj.Name)
            if string.find(n, "sky") or string.find(n, "dome")
               or string.find(n, "ceu") or string.find(n, "atmosphere") then
                if not string.find(n, "manic") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") or child:IsA("Atmosphere")
        or child:IsA("Clouds") or child:IsA("PostEffect")
        or child:IsA("ColorCorrectionEffect") then
            child:Destroy()
        end
    end
    local loaded = false
    pcall(function()
        local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
        for _, v in ipairs(objects) do
            if v:IsA("Sky") then
                v.Name = "ManicSky"
                v.Parent = Lighting
                loaded = true
            end
        end
    end)
    if not loaded then
        local newSky = Instance.new("Sky")
        newSky.Name = "ManicSky"
        local url = "rbxassetid://" .. tostring(assetId)
        newSky.SkyboxBk = url
        newSky.SkyboxDn = url
        newSky.SkyboxFt = url
        newSky.SkyboxLf = url
        newSky.SkyboxRt = url
        newSky.SkyboxUp = url
        newSky.Parent = Lighting
    end
    State.Skybox = assetId
end

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

for _, sky in ipairs(SkyboxIDs) do
    MapTab:Button({
        Title = sky.Name,
        Callback = function()
            ForceSkyTCS(sky.ID)
            WindUI:Notify({Title = "sᴋʏʙᴏx", Content = sky.Name, Duration = 2})
        end,
    })
end

MapTab:Button({
    Title = "ʀᴇᴍᴏᴠᴇʀ sᴋʏʙᴏx",
    Callback = function()
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") then child:Destroy() end
        end
        State.Skybox = nil
    end,
})

task.spawn(function()
    while true do
        task.wait(1)
        if not State.Skybox then continue end
        local skyExists = false
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") and v.Name == "ManicSky" then
                skyExists = true
                break
            end
        end
        if not skyExists then ForceSkyTCS(State.Skybox) end
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") and v.Name ~= "ManicSky" then v:Destroy() end
        end
    end
end)

-- GRÁFICOS
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
})--[[ MANIC HUB | PARTE 3/11 — ʙᴏᴏᴍ ʙᴏx + Auto Ball ]]

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

-- AUTO BALL
local BallTab = Window:Tab({ Title = "ʙᴀʟʟ", Icon = "circle" })
BallTab:Section({ Title = "ᴀᴜᴛᴏ ʙᴀʟʟ" })

local AutoFollowConnection = nil
local CurrentFollowBall = nil
local FollowScanTimer = 0
local FollowStopDistance = 0.20
local ManualSteerStrength = 1.25
local PlayerControls = nil

pcall(function()
    local PM = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
    PlayerControls = PM:GetControls()
end)

function GetCharacterData()
    local c = LocalPlayer.Character
    if not c then return nil, nil, nil end
    return c, c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
end

function IsCharacterPart(obj)
    local c = obj
    while c and c ~= Workspace do
        if c:IsA("Model") and c:FindFirstChildOfClass("Humanoid") then return true end
        c = c.Parent
    end
    return false
end

function HasBallName(obj)
    if not obj then return false end
    local n = string.lower(obj.Name)
    for _, w in ipairs({"soccerball","football","matchball","gameball","futebol","bola","ball","tps"}) do
        if string.find(n, w, 1, true) then return true end
    end
    return false
end

function IsBall(part)
    if not part or not part:IsA("BasePart") or IsCharacterPart(part) then return false end
    if string.lower(part.Name) == "tps" then return true end
    if HasBallName(part) or HasBallName(part.Parent) then return true end
    local b = math.max(part.Size.X, part.Size.Y, part.Size.Z)
    local s = math.min(part.Size.X, part.Size.Y, part.Size.Z)
    if b < 0.5 or b > 8 then return false end
    if part:IsA("Part") and part.Shape == Enum.PartType.Ball and not part.Anchored then return true end
    if part:IsA("MeshPart") and not part.Anchored and s/b >= 0.80 then return true end
    return false
end

function IsValidTPSBall(part)
    if not part or not part.Parent or not part:IsA("BasePart") then return false end
    if string.lower(part.Name) ~= "tps" then return false end
    if IsCharacterPart(part) or part.Anchored then return false end
    local b = math.max(part.Size.X, part.Size.Y, part.Size.Z)
    local s = math.min(part.Size.X, part.Size.Y, part.Size.Z)
    if b < 0.5 or b > 6 then return false end
    if s/b < 0.60 then return false end
    return true
end

function FindClosestBall()
    local _, _, root = GetCharacterData()
    if not root then return nil end
    local closest, cd = nil, math.huge
    for _, p in ipairs(Workspace:GetDescendants()) do
        if IsValidTPSBall(p) then
            local off = Vector3.new(p.Position.X-root.Position.X, 0, p.Position.Z-root.Position.Z)
            if off.Magnitude < cd then cd = off.Magnitude; closest = p end
        end
    end
    if closest then return closest end
    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("BasePart") and IsBall(p) then
            local off = Vector3.new(p.Position.X-root.Position.X, 0, p.Position.Z-root.Position.Z)
            if off.Magnitude < cd then cd = off.Magnitude; closest = p end
        end
    end
    return closest
end

function GetValidBall()
    return CurrentFollowBall or FindClosestBall()
end

local function GetManualDirection()
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
    if State.AutoBall then return end
    State.AutoBall = true
    CurrentFollowBall = nil
    FollowScanTimer = 1
    if AutoFollowConnection then AutoFollowConnection:Disconnect() end

    AutoFollowConnection = RunService.RenderStepped:Connect(function(dt)
        if not State.AutoBall then return end
        local _, hum, root = GetCharacterData()
        if not hum or not root or hum.Health <= 0 then return end
        hum.AutoRotate = true
        FollowScanTimer += dt

        local inv = not CurrentFollowBall or not CurrentFollowBall.Parent
        if CurrentFollowBall and CurrentFollowBall.Parent
        and string.lower(CurrentFollowBall.Name) == "tps"
        and not IsValidTPSBall(CurrentFollowBall) then
            inv = true
        end

        if inv or FollowScanTimer >= 0.25 then
            FollowScanTimer = 0
            CurrentFollowBall = FindClosestBall()
        end

        local ball = CurrentFollowBall
        if not ball or not ball.Parent then return end

        local toBall = Vector3.new(ball.Position.X-root.Position.X, 0, ball.Position.Z-root.Position.Z)
        local dist = toBall.Magnitude
        local manual = GetManualDirection()

        if dist > FollowStopDistance then
            local fl = toBall.Unit
            local fin = fl
            if manual.Magnitude > 0.01 then
                local amt = math.clamp(manual.Magnitude, 0, 1)
                fin = fl * (1 - amt * 0.45) + manual * ManualSteerStrength
                if fin.Magnitude > 0 then fin = fin.Unit end
            end
            hum:Move(fin, false)
        elseif manual.Magnitude > 0.01 then
            hum:Move(manual, false)
        end
    end)
end

function StopAutoBall()
    State.AutoBall = false
    CurrentFollowBall = nil
    FollowScanTimer = 0
    if AutoFollowConnection then
        AutoFollowConnection:Disconnect()
        AutoFollowConnection = nil
    end
    local _, hum = GetCharacterData()
    if hum then hum.AutoRotate = true end
end

BallTab:Toggle({
    Title = "ᴀᴜᴛᴏ ʙᴀʟʟ",
    Value = false,
    Callback = function(v) if v then StartAutoBall() else StopAutoBall() end end,
})

BallTab:Slider({
    Title = "ᴅɪsᴛᴀɴᴄɪᴀ ᴅᴇ ᴘᴀʀᴀᴅᴀ",
    Value = {Min = 1, Max = 50, Default = 2},
    Callback = function(v) FollowStopDistance = v / 10 end,
})

BallTab:Slider({
    Title = "ꜰᴏʀᴄᴀ ᴅᴏ sᴛᴇᴇʀɪɴɢ",
    Value = {Min = 1, Max = 30, Default = 13},
    Callback = function(v) ManualSteerStrength = v / 10 end,
})--[[ MANIC HUB | PARTE 4/11 — ʙᴀʟʟ Cor + Fogo + Trail ]]

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
        if IsBall(obj) then
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
        if IsBall(obj) then
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

-- FOGO
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
                if IsBall(obj) then
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
            if IsBall(obj) then
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
            if IsBall(obj) then
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

-- TRAIL
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
                if IsBall(obj) then
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
            if IsBall(obj) then
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

spawn(function()
    while true do
        task.wait(0.25)
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if IsBall(obj) then
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
                        if t.Lifetime ~= TrailLifetime then t.Lifetime = TrailLifetime end
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
end)--[[ MANIC HUB | PARTE 5/11 — Curva + Botão Flutuante ]]

BallTab:Section({ Title = "ᴄᴜʀᴠᴀ ʙᴀʟʟ" })

BallTab:Button({
    Title = "ᴀʙʀɪʀ ᴄᴜʀᴠᴀ ʙᴀʟʟ",
    Desc = "ᴇxᴇᴄᴜᴛᴀ ᴏ sᴄʀɪᴘᴛ ᴅᴇ ᴄᴜʀᴠᴀ ᴇxᴛᴇʀɴᴏ",
    Callback = function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/7ixqsxx7"))()
        end)
        if ok then
            WindUI:Notify({Title = "ᴄᴜʀᴠᴀ", Content = "sᴄʀɪᴘᴛ ᴇxᴇᴄᴜᴛᴀᴅᴏ", Duration = 3, Icon = "check-circle"})
        else
            WindUI:Notify({Title = "ᴄᴜʀᴠᴀ", Content = "ᴇʀʀᴏ: " .. tostring(err), Duration = 5, Icon = "x-circle"})
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

-- BOTÃO FLUTUANTE "SEGUIR"
BallTab:Section({ Title = "ʙᴏᴛᴀᴏ ꜰʟᴜᴛᴀɴᴛᴇ" })

local FloatGui = nil
local FloatBtn = nil
local FloatLocked = false
local FloatVisible = false
local DragStart = nil
local StartPos = nil
local Moved = false

local function AtualizarTextoBotao()
    if not FloatBtn then return end
    if State.AutoBall then
        FloatBtn.Text = "SEGUIR:ON"
        FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 60)
    else
        FloatBtn.Text = "SEGUIR:OFF"
        FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 90, 50)
    end
end

local function CriarFloatBtn()
    if FloatGui then FloatGui:Destroy() end

    FloatGui = Instance.new("ScreenGui")
    FloatGui.Name = "ManicFloat"
    FloatGui.ResetOnSpawn = false
    FloatGui.IgnoreGuiInset = true
    FloatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    FloatGui.Parent = CoreGui

    FloatBtn = Instance.new("TextButton")
    FloatBtn.Size = UDim2.new(0, 110, 0, 110)
    FloatBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
    FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 60)
    FloatBtn.Text = "SEGUIR:OFF"
    FloatBtn.TextSize = 16
    FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FloatBtn.Font = Enum.Font.GothamBold
    FloatBtn.BorderSizePixel = 0
    FloatBtn.AutoButtonColor = false
    FloatBtn.Active = true
    FloatBtn.Parent = FloatGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = FloatBtn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Thickness = 4
    stroke.Transparency = 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = FloatBtn

    local strokeText = Instance.new("UIStroke")
    strokeText.Color = Color3.fromRGB(0, 0, 0)
    strokeText.Thickness = 2
    strokeText.Transparency = 0
    strokeText.Parent = FloatBtn

    AtualizarTextoBotao()

    FloatBtn.InputBegan:Connect(function(input)
        if FloatLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            DragStart = input.Position
            StartPos = FloatBtn.Position
            Moved = false
            input.Changed:Connect(function(x)
                if x.UserInputState == Enum.UserInputState.End then
                    DragStart = nil
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if DragStart and not FloatLocked then
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - DragStart
                if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                    Moved = true
                end
                FloatBtn.Position = UDim2.new(
                    StartPos.X.Scale, StartPos.X.Offset + delta.X,
                    StartPos.Y.Scale, StartPos.Y.Offset + delta.Y
                )
            end
        end
    end)

    FloatBtn.MouseButton1Click:Connect(function()
        if Moved then return end
        State.AutoBall = not State.AutoBall
        if State.AutoBall then StartAutoBall() else StopAutoBall() end
        AtualizarTextoBotao()
    end)
end

BallTab:Toggle({
    Title = "ᴍᴏsᴛʀᴀʀ ʙᴏᴛᴀᴏ ꜰʟᴜᴛᴜᴀɴᴛᴇ",
    Value = false,
    Callback = function(v)
        FloatVisible = v
        if v then
            if not FloatBtn then CriarFloatBtn() end
            FloatBtn.Visible = true
            AtualizarTextoBotao()
        elseif FloatBtn then
            FloatBtn.Visible = false
        end
    end,
})

BallTab:Toggle({
    Title = "ᴛʀᴀᴠᴀʀ ʙᴏᴛᴀᴏ (ʟᴏᴄᴋ)",
    Value = false,
    Callback = function(v) FloatLocked = v end,
})

BallTab:Button({
    Title = "ʀᴇᴄʀɪᴀʀ ʙᴏᴛᴀᴏ ꜰʟᴜᴛᴀɴᴛᴇ",
    Callback = function()
        if FloatVisible then
            CriarFloatBtn()
            FloatBtn.Visible = true
            AtualizarTextoBotao()
        end
    end,
})--[[ MANIC HUB | PARTE 6/11 — ᴘʟᴀʏᴇʀ + ᴄʜᴀʀs ]]

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

-- CHARS
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
end--[[ MANIC HUB | PARTE 7/11 — ᴀᴄ + ʀᴇᴀᴄʜ + ᴀᴜᴛᴏ ᴅʀɪᴠᴇ ]]

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
    local _, hum, root = GetCharacterData()
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

ACTab:Toggle({Title = "ᴀᴜᴛᴏ ᴄᴀᴛᴄʜ", Value = false, Callback = function(v) State.AutoCatch = v end})
ACTab:Slider({Title = "ᴀʟᴄᴀɴᴄᴇ", Value = {Min = 3, Max = 30, Default = 8}, Callback = function(v) AutoCatchRange = v end})
ACTab:Slider({Title = "ᴄᴏᴏʟᴅᴏᴡɴ (x100ᴍs)", Value = {Min = 2, Max = 30, Default = 8}, Callback = function(v) AutoCatchDelay = v / 10 end})
ACTab:Toggle({Title = "ᴍᴏsᴛʀᴀʀ ʜɪᴛʙᴏx", Value = false, Callback = function(v) AC_Hitbox = v end})

local ReachTab = Window:Tab({ Title = "ʀᴇᴀᴄʜ", Icon = "ruler" })
ReachTab:Section({ Title = "ʀᴇᴀᴄʜ" })

local ReachLast = 0

ReachTab:Toggle({Title = "ᴀᴛɪᴠᴀʀ ʀᴇᴀᴄʜ", Value = false, Callback = function(v) State.Reach = v end})
ReachTab:Slider({Title = "ᴅɪsᴛᴀɴᴄɪᴀ", Value = {Min = 1, Max = 50, Default = 10}, Callback = function(v) State.ReachDistance = v end})

local DriveTab = Window:Tab({ Title = "ᴀᴜᴛᴏ ᴅʀɪᴠᴇ", Icon = "car" })

local GKBotoes = {}
local AutoDiveLast = 0
local AutoDiveRange = 15
local AutoDiveCooldown = 0.8
local AutoDiveConn = nil
local AutoDiveMode = "ᴀᴜᴛᴏ"
local AutoCatchIntelEnabled = false
local AutoCatchIntelConn = nil
local AutoCatchIntelRange = 16
local AutoCatchIntelCooldown = 0.35
local AutoCatchIntelLast = 0
local AutoCatchIntelHeight = 3.5
local AutoDiveBloquearSeIntelAtivo = true

local GK_BUTTON_TEXTS = {
    ["ᴇsǫᴜᴇʀᴅᴀ ᴀʟᴛᴏ"] = "High Dive Left",
    ["ᴅɪʀᴇɪᴛᴀ ᴀʟᴛᴏ"]  = "High Dive Right",
    ["ᴇsǫᴜᴇʀᴅᴀ ʙᴀɪxᴏ"] = "Dive Left",
    ["ᴅɪʀᴇɪᴛᴀ ʙᴀɪxᴏ"] = "Dive Right",
    ["ᴀɢᴀʀʀᴀʀ ᴀʟᴛᴏ"]  = "High Catch",
    ["ᴀɢᴀʀʀᴀʀ ʙᴀɪxᴏ"] = "Low Catch",
    ["ʀᴇꜰʟᴇxᴏ"]       = "Reflex",
    ["ꜰʀᴇɴᴛᴇ"]        = "Front Dive",
    ["ᴇɴꜰʀᴇɴᴛᴀʀ"]     = "Rush",
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

local function Pular()
    pcall(function() Humanoid.Jump = true end)
    pcall(function() Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
end

local function AnalisarBola()
    local ball = CurrentFollowBall or FindClosestBall()
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

local function ExecutarAutoCatchIntel()
    local info = AnalisarBola()
    if not info then return end
    local lado = info.lado
    local altura = info.altura
    local ladoAbs = math.abs(lado)
    local bolaAlta = altura > AutoCatchIntelHeight
    local bolaLateral = ladoAbs >= 2.5
    if bolaLateral then
        if bolaAlta then
            local textoDive = lado < 0 and "High Dive Left" or "High Dive Right"
            local botao = EncontrarBotaoPorTexto(textoDive)
            if botao then ClicarBotao(botao) end
        else
            local botao = EncontrarBotaoPorTexto("Low Catch")
            if botao then ClicarBotao(botao) end
        end
    else
        if bolaAlta then
            task.spawn(Pular)
            task.wait(0.05)
            local botao = EncontrarBotaoPorTexto("High Catch")
            if botao then ClicarBotao(botao) end
        else
            local botao = EncontrarBotaoPorTexto("Low Catch")
            if botao then ClicarBotao(botao) end
        end
    end
end

local function StartAutoCatchIntel()
    if AutoCatchIntelConn then return end
    if #GKBotoes == 0 then EscanearBotoesGK() end
    AutoCatchIntelConn = RunService.Heartbeat:Connect(function()
        if not AutoCatchIntelEnabled then return end
        if not RootPart or not RootPart.Parent then return end
        if tick() - AutoCatchIntelLast < AutoCatchIntelCooldown then return end
        local info = AnalisarBola()
        if not info then return end
        if info.dist > AutoCatchIntelRange then return end
        if info.vel.Magnitude < 4 then return end
        local dirParaPlayer = RootPart.Position - info.ball.Position
        local dirH = Vector3.new(dirParaPlayer.X, 0, dirParaPlayer.Z)
        if dirH.Magnitude < 0.1 then return end
        local velH = Vector3.new(info.vel.X, 0, info.vel.Z)
        if velH.Magnitude < 0.1 then return end
        if velH.Unit:Dot(dirH.Unit) > 0.15 then
            AutoCatchIntelLast = tick()
            task.spawn(ExecutarAutoCatchIntel)
        end
    end)
end

local function StopAutoCatchIntel()
    if AutoCatchIntelConn then
        AutoCatchIntelConn:Disconnect()
        AutoCatchIntelConn = nil
    end
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
        if altura > AutoCatchIntelHeight then
            textoAlvo = lado > 0 and "High Dive Right" or "High Dive Left"
        else
            textoAlvo = lado > 0 and "Dive Right" or "Dive Left"
        end
    end
    if not textoAlvo then return end
    local botao = EncontrarBotaoPorTexto(textoAlvo)
    if botao then ClicarBotao(botao) end
end

local function StartAutoDive()
    if AutoDiveConn then return end
    if #GKBotoes == 0 then EscanearBotoesGK() end
    AutoDiveConn = RunService.Heartbeat:Connect(function()
        if not State.AutoDrive then return end
        if AutoDiveBloquearSeIntelAtivo and AutoCatchIntelEnabled then return end
        if not RootPart or not RootPart.Parent then return end
        if tick() - AutoDiveLast < AutoDiveCooldown then return end
        local ball = CurrentFollowBall or FindClosestBall()
        if not ball or not ball.Parent then return end
        local dist = (ball.Position - RootPart.Position).Magnitude
        if dist > AutoDiveRange then return end
        local ballVel = ball.AssemblyLinearVelocity
        if ballVel.Magnitude < 5 then return end
        local dirParaPlayer = RootPart.Position - ball.Position
        local dirH = Vector3.new(dirParaPlayer.X, 0, dirParaPlayer.Z)
        if dirH.Magnitude < 0.1 then return end
        local ballVelH = Vector3.new(ballVel.X, 0, ballVel.Z)
        if ballVelH.Magnitude < 0.1 then return end
        if ballVelH.Unit:Dot(dirH.Unit) > 0.15 then
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

DriveTab:Section({ Title = "ᴀᴜᴛᴏ ᴄᴀᴛᴄʜ ɪɴᴛᴇʟɪɢᴇɴᴛᴇ" })
DriveTab:Toggle({Title = "ᴀᴛɪᴠᴀʀ ᴀᴜᴛᴏ ᴄᴀᴛᴄʜ ɪɴᴛᴇʟɪɢᴇɴᴛᴇ", Value = false, Callback = function(Value)
    AutoCatchIntelEnabled = Value
    if Value then StartAutoCatchIntel() else StopAutoCatchIntel() end
end})
DriveTab:Slider({Title = "ᴀʟᴄᴀɴᴄᴇ", Value = {Min = 5, Max = 35, Default = 16}, Callback = function(v) AutoCatchIntelRange = v end})
DriveTab:Slider({Title = "ᴀʟᴛᴜʀᴀ ᴍɪɴɪᴍᴀ", Value = {Min = 1, Max = 10, Default = 3.5, Decimal = 1}, Callback = function(v) AutoCatchIntelHeight = v end})
DriveTab:Slider({Title = "ᴄᴏᴏʟᴅᴏᴡɴ", Value = {Min = 1, Max = 20, Default = 3, Suffix = "x0.1s"}, Callback = function(v) AutoCatchIntelCooldown = v / 10 end})

DriveTab:Section({ Title = "ᴀᴜᴛᴏ ᴅɪᴠᴇ" })
DriveTab:Toggle({Title = "ᴀᴛɪᴠᴀʀ ᴀᴜᴛᴏ ᴅɪᴠᴇ", Value = false, Callback = function(Value)
    State.AutoDrive = Value    if Value then StartAutoDive() else StopAutoDive() end
end})
DriveTab:Dropdown({
    Title = "ᴍᴏᴅᴏ ᴅᴏ ᴅɪᴠᴇ",
    Values = {"ᴀᴜᴛᴏ", "ᴇsǫᴜᴇʀᴅᴀ ᴀʟᴛᴏ", "ᴅɪʀᴇɪᴛᴀ ᴀʟᴛᴏ", "ᴇsǫᴜᴇʀᴅᴀ ʙᴀɪxᴏ", "ᴅɪʀᴇɪᴛᴀ ʙᴀɪxᴏ",
              "ᴀɢᴀʀʀᴀʀ ᴀʟᴛᴏ", "ᴀɢᴀʀʀᴀʀ ʙᴀɪxᴏ", "ʀᴇꜰʟᴇxᴏ", "ꜰʀᴇɴᴛᴇ", "ᴇɴꜰʀᴇɴᴛᴀʀ"},
    Value = "ᴀᴜᴛᴏ",
    Callback = function(v) AutoDiveMode = v end,
})
DriveTab:Slider({Title = "ᴀʟᴄᴀɴᴄᴇ ᴅᴏ ᴅɪᴠᴇ", Value = {Min = 5, Max = 30, Default = 15}, Callback = function(v) AutoDiveRange = v end})
DriveTab:Slider({Title = "ᴄᴏᴏʟᴅᴏᴡɴ ᴅᴏ ᴅɪᴠᴇ", Value = {Min = 3, Max = 50, Default = 8, Suffix = "x0.1s"}, Callback = function(v) AutoDiveCooldown = v / 10 end})
DriveTab:Toggle({Title = "ᴅɪᴠᴇ ᴘᴀᴜsᴀ ǫᴜᴀɴᴅᴏ ɪɴᴛᴇʟ ᴏɴ", Value = true, Callback = function(v) AutoDiveBloquearSeIntelAtivo = v end})
DriveTab:Button({
    Title = "ʀᴇᴇsᴄᴀɴᴇᴀʀ ʙᴏᴛᴏᴇs ɢᴋ",
    Callback = function()
        EscanearBotoesGK()
        WindUI:Notify({Title = "ᴀᴜᴛᴏ ᴅʀɪᴠᴇ", Content = #GKBotoes .. " ʙᴏᴛᴏᴇs", Duration = 3})
    end,
})--[[ MANIC HUB | PARTE 8/11 — ꜰʟᴀɢ ]]

local FlagTab = Window:Tab({ Title = "ꜰʟᴀɢ", Icon = "zap" })
FlagTab:Section({ Title = "ᴏᴛɪᴍɪᴢᴀᴄᴀᴏ" })

local FpsUnlocked = false

FlagTab:Toggle({
    Title = "ᴜɴʟᴏᴄᴋ ꜰᴘs",
    Desc = "ᴀᴜᴍᴇɴᴛᴀ ᴍᴜɪᴛᴏ ᴏ ꜰᴘs ᴅᴏ ᴜsᴜᴀʀɪᴏ",
    Value = false,
    Callback = function(v)
        FpsUnlocked = v
        pcall(function()
            if setfpscap then setfpscap(v and 999 or 60) end
        end)
        WindUI:Notify({Title = "ꜰʟᴀɢ", Content = v and "ꜰᴘs ᴜɴʟᴏᴄᴋᴇᴅ" or "ꜰᴘs ɴᴏʀᴍᴀʟ", Duration = 2})
    end,
})

local AntiLagEnabled = false
local AntiLagBackup = {}

FlagTab:Toggle({
    Title = "ᴀɴᴛɪ ʟᴀɢ",
    Desc = "ᴛɪʀᴀ ᴏ ʟᴀɢ ᴅᴏ ᴜsᴜᴀʀɪᴏ",
    Value = false,
    Callback = function(v)
        AntiLagEnabled = v
        pcall(function()
            if v then
                AntiLagBackup.Brightness = Lighting.Brightness
                AntiLagBackup.GlobalShadows = Lighting.GlobalShadows
                AntiLagBackup.FogEnd = Lighting.FogEnd
                AntiLagBackup.OutdoorAmbient = Lighting.OutdoorAmbient
                AntiLagBackup.QualityLevel = settings().Rendering.QualityLevel

                Lighting.GlobalShadows = false
                Lighting.FogEnd = 100000
                Lighting.Brightness = 1
                Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

                for _, obj in ipairs(Lighting:GetChildren()) do
                    if obj:IsA("PostEffect") then obj.Enabled = false end
                end
                WindUI:Notify({Title = "ꜰʟᴀɢ", Content = "ᴀɴᴛɪ ʟᴀɢ ᴀᴛɪᴠᴀᴅᴏ", Duration = 2})
            else
                if AntiLagBackup.Brightness then Lighting.Brightness = AntiLagBackup.Brightness end
                if AntiLagBackup.GlobalShadows ~= nil then Lighting.GlobalShadows = AntiLagBackup.GlobalShadows end
                if AntiLagBackup.FogEnd then Lighting.FogEnd = AntiLagBackup.FogEnd end
                if AntiLagBackup.OutdoorAmbient then Lighting.OutdoorAmbient = AntiLagBackup.OutdoorAmbient end
                if AntiLagBackup.QualityLevel then settings().Rendering.QualityLevel = AntiLagBackup.QualityLevel end
                for _, obj in ipairs(Lighting:GetChildren()) do
                    if obj:IsA("PostEffect") then obj.Enabled = true end
                end
                WindUI:Notify({Title = "ꜰʟᴀɢ", Content = "ᴀɴᴛɪ ʟᴀɢ ᴅᴇsᴀᴛɪᴠᴀᴅᴏ", Duration = 2})
            end
        end)
    end,
})

local AntiFreezeEnabled = false
local AntiFreezeConn = nil

FlagTab:Toggle({
    Title = "ᴀɴᴛɪ ꜰʀᴇᴇᴢᴇ",
    Desc = "ᴛɪʀᴀ ᴛʀᴀᴠᴀᴅᴀs ᴅᴏ ᴜsᴜᴀʀɪᴏ",
    Value = false,
    Callback = function(v)
        AntiFreezeEnabled = v
        if v then
            if AntiFreezeConn then AntiFreezeConn:Disconnect() end
            AntiFreezeConn = RunService.Heartbeat:Connect(function()
                if not AntiFreezeEnabled then return end
                pcall(function()
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if obj:IsA("BasePart") then obj.CanQuery = true end
                    end
                end)
            end)
            WindUI:Notify({Title = "ꜰʟᴀɢ", Content = "ᴀɴᴛɪ ꜰʀᴇᴇᴢᴇ ᴀᴛɪᴠᴀᴅᴏ", Duration = 2})
        else
            if AntiFreezeConn then
                AntiFreezeConn:Disconnect()
                AntiFreezeConn = nil
            end
            WindUI:Notify({Title = "ꜰʟᴀɢ", Content = "ᴀɴᴛɪ ꜰʀᴇᴇᴢᴇ ᴅᴇsᴀᴛɪᴠᴀᴅᴏ", Duration = 2})
        end
    end,
})

local ContainerEnabled = false
local ContainerBackup = {}
local ContainerConn = nil

FlagTab:Toggle({
    Title = "ᴄᴏɴᴛᴀɪɴᴇʀ",
    Desc = "ᴛɪʀᴀ ᴛᴇxᴛᴜʀᴀs ᴅᴇsɴᴇᴄᴇssᴀʀɪᴀs ᴅᴏ ᴊᴏɢᴏ",
    Value = false,
    Callback = function(v)
        ContainerEnabled = v
        if v then
            if ContainerConn then ContainerConn:Disconnect() end
            ContainerConn = RunService.Heartbeat:Connect(function()
                if not ContainerEnabled then return end
                pcall(function()
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("Texture") or obj:IsA("Decal") then
                            if obj.Parent and obj.Parent:IsA("BasePart") then
                                local dist = (obj.Parent.Position - RootPart.Position).Magnitude
                                if dist > 200 then
                                    if not ContainerBackup[obj] then
                                        ContainerBackup[obj] = obj.Transparency
                                    end
                                    obj.Transparency = 1
                                end
                            end
                        end
                        if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
                        or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                            if obj.Parent and obj.Parent:IsA("BasePart") then
                                local dist = (obj.Parent.Position - RootPart.Position).Magnitude
                                if dist > 150 then
                                    if not ContainerBackup[obj] then
                                        ContainerBackup[obj] = obj.Enabled
                                    end
                                    obj.Enabled = false
                                end
                            end
                        end
                    end
                end)
            end)
            WindUI:Notify({Title = "ꜰʟᴀɢ", Content = "ᴄᴏɴᴛᴀɪɴᴇʀ ᴀᴛɪᴠᴀᴅᴏ", Duration = 2})
        else
            if ContainerConn then
                ContainerConn:Disconnect()
                ContainerConn = nil
            end
            for obj, val in pairs(ContainerBackup) do
                if obj and obj.Parent then
                    pcall(function() obj.Transparency = val end)
                    pcall(function() obj.Enabled = val end)
                end
            end
            ContainerBackup = {}
            WindUI:Notify({Title = "ꜰʟᴀɢ", Content = "ᴄᴏɴᴛᴀɪɴᴇʀ ᴅᴇsᴀᴛɪᴠᴀᴅᴏ", Duration = 2})
        end
    end,
})

FlagTab:Section({ Title = "ᴀᴄᴏᴇs" })
FlagTab:Button({
    Title = "ʀᴇsᴛᴀᴜʀᴀʀ ᴛᴜᴅᴏ",
    Desc = "ᴅᴇsᴀᴛɪᴠᴀ ᴛᴏᴅᴀs ᴀs ꜰʟᴀɢs ᴇ ᴠᴏʟᴛᴀ ᴀᴏ ɴᴏʀᴍᴀʟ",
    Callback = function()
        pcall(function()
            if setfpscap then setfpscap(60) end
            Lighting.Brightness = Backups.Lighting.Brightness
            Lighting.GlobalShadows = true
            Lighting.FogEnd = Backups.Lighting.FogEnd
            Lighting.OutdoorAmbient = Backups.Lighting.OutdoorAmbient
            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("PostEffect") then obj.Enabled = true end
            end
        end)
        WindUI:Notify({Title = "ꜰʟᴀɢ", Content = "ᴛᴜᴅᴏ ʀᴇsᴛᴀᴜʀᴀᴅᴏ", Duration = 2})
    end,
})

print("[MANIC HUB] ᴀʙᴀ ꜰʟᴀɢ ᴄᴀʀʀᴇɢᴀᴅᴀ!")--[[ MANIC HUB | PARTE 10/11 — sᴄʀɪᴘᴛ + Assets ]]

local ScriptTab = Window:Tab({ Title = "sᴄʀɪᴘᴛ", Icon = "settings" })

ScriptTab:Section({ Title = "ᴘᴇʀsᴏɴᴀʟɪᴢᴀʀ ᴀssᴇᴛs" })

local BackgroundAtual = "4155801252"

-- ============================================
-- APLICA IMAGEM DE FUNDO (fix definitivo v5)
-- ============================================
local function AplicarBackground(assetId)
    local url = "rbxassetid://" .. tostring(assetId):gsub("rbxassetid://", "")

    -- ============================================
    -- MÉTODO 1: API nativa do WindUI
    -- ============================================
    local sucesso = false
    pcall(function()
        if Window.SetBackground then
            Window:SetBackground(url, 0.35)
            sucesso = true
        end
    end)
    if sucesso then
        BackgroundAtual = assetId
        WindUI:Notify({Title = "sᴄʀɪᴘᴛ", Content = "Imagem aplicada!", Duration = 2, Icon = "check-circle"})
        return
    end

    -- ============================================
    -- MÉTODO 2: Usar Window.GUI (ScreenGui interna)
    -- ============================================
    local windGui = nil
    pcall(function() windGui = Window.GUI end)
    if not windGui then pcall(function() windGui = Window.ScreenGui end) end
    if not windGui then pcall(function() windGui = Window.Root end) end
    if not windGui then pcall(function() windGui = Window.Frame end) end

    if not windGui then
        WindUI:Notify({Title = "sᴄʀɪᴘᴛ", Content = "Nao consegui acessar Window.GUI", Duration = 3, Icon = "x-circle"})
        return
    end

    -- ============================================
    -- Encontra o Frame principal
    -- ============================================
    local mainFrame = nil
    local maiorArea = 0
    for _, obj in ipairs(windGui:GetDescendants()) do
        if obj:IsA("Frame") then
            local area = obj.AbsoluteSize.X * obj.AbsoluteSize.Y
            if area > maiorArea and area > 50000 then
                maiorArea = area
                mainFrame = obj
            end
        end
    end

    if not mainFrame then
        WindUI:Notify({Title = "sᴄʀɪᴘᴛ", Content = "MainFrame nao encontrado", Duration = 3, Icon = "x-circle"})
        return
    end

    -- Remove fundo antigo
    local oldBg = mainFrame:FindFirstChild("ManicBackground")
    if oldBg then oldBg:Destroy() end

    -- Cria o ImageLabel de fundo
    local bg = Instance.new("ImageLabel")
    bg.Name = "ManicBackground"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Position = UDim2.new(0, 0, 0, 0)
    bg.BackgroundTransparency = 1
    bg.ScaleType = Enum.ScaleType.Crop
    bg.ZIndex = 0
    bg.Image = url
    bg.ImageTransparency = 0.35
    bg.Visible = true
    bg.Parent = mainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = bg

    -- Deixa transparente Frames escuros que cobrem a janela
    for _, obj in ipairs(mainFrame:GetChildren()) do
        if obj:IsA("Frame") and obj ~= bg then
            local sz = obj.AbsoluteSize
            if sz.X > 500 and sz.Y > 300 and obj.BackgroundTransparency < 0.7 then
                obj.BackgroundTransparency = 0.85
            end
        end
    end

    -- Força o bg a ser renderizado primeiro
    bg.Parent = nil
    bg.Parent = mainFrame

    BackgroundAtual = assetId
    WindUI:Notify({Title = "sᴄʀɪᴘᴛ", Content = "Imagem aplicada!", Duration = 2, Icon = "check-circle"})
end

local function AtualizarTransparencia(valor)
    -- Procura o ImageLabel em toda parte
    for _, sg in ipairs(CoreGui:GetChildren()) do
        if sg:IsA("ScreenGui") then
            for _, obj in ipairs(sg:GetDescendants()) do
                if obj.Name == "ManicBackground" then
                    pcall(function() obj.ImageTransparency = valor / 100 end)
                end
            end
        end
    end
    -- Também procura via Window.GUI
    pcall(function()
        if Window.GUI then
            for _, obj in ipairs(Window.GUI:GetDescendants()) do
                if obj.Name == "ManicBackground" then
                    obj.ImageTransparency = valor / 100
                end
            end
        end
    end)
end

-- ============================================
-- CONTROLES
-- ============================================
ScriptTab:Input({
    Title = "ɪᴅ ᴍᴀɴᴜᴀʟ",
    Placeholder = "sᴏᴍᴇɴᴛᴇ ᴏ ɪᴅ",
    Callback = function(text)
        if text and text ~= "" then
            BackgroundAtual = text:gsub("rbxassetid://", "")
        end
    end,
})

ScriptTab:Button({
    Title = "ᴀᴘʟɪᴄᴀʀ ɪᴅ ᴍᴀɴᴜᴀʟ",
    Callback = function() AplicarBackground(BackgroundAtual) end,
})

ScriptTab:Slider({
    Title = "ᴛʀᴀɴsᴘᴀʀᴇɴᴄɪᴀ ᴅᴀ ɪᴍᴀɢᴇᴍ",
    Value = {Min = 0, Max = 100, Default = 35},
    Callback = function(v) AtualizarTransparencia(v) end,
})

ScriptTab:Button({
    Title = "🔍 ᴅᴇʙᴜɢ ᴡɪɴᴅᴜɪ",
    Desc = "Mostra as propriedades internas do WindUI",
    Callback = function()
        print("=== DEBUG WINDUI ===")
        print("Window.GUI:", tostring(Window.GUI))
        print("Window.ScreenGui:", tostring(Window.ScreenGui))
        print("Window.Root:", tostring(Window.Root))
        print("Window.Frame:", tostring(Window.Frame))
        print("Window.SetBackground:", tostring(Window.SetBackground))
        print("--- Propriedades do Window ---")
        for k, v in pairs(Window) do
            print("  Window." .. tostring(k) .. ":", typeof(v))
        end
        print("=== FIM DEBUG ===")
        WindUI:Notify({Title = "sᴄʀɪᴘᴛ", Content = "Veja o console (F9)", Duration = 3})
    end,
})

-- ============================================
-- ASSETS PRESET
-- ============================================
ScriptTab:Section({ Title = "ᴀssᴇᴛs ᴘʀᴇsᴇᴛ" })

local ASSETS_PRESET = {
    {Nome = "ᴀssᴇᴛ 1", ID = "86503454003964"},
    {Nome = "ᴀssᴇᴛ 2", ID = "17228542848"},
    {Nome = "ᴀssᴇᴛ 3 (ᴘᴀᴅʀᴀᴏ)", ID = "92048348535477"},
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
    Title = "ʀᴇᴍᴏᴠᴇʀ ɪᴍᴀɢᴇᴍ ᴅᴇ ꜰᴜɴᴅᴏ",
    Callback = function()
        for _, sg in ipairs(CoreGui:GetChildren()) do
            if sg:IsA("ScreenGui") then
                for _, obj in ipairs(sg:GetDescendants()) do
                    if obj.Name == "ManicBackground" then
                        obj:Destroy()
                    end
                end
            end
        end
        pcall(function()
            if Window.GUI then
                for _, obj in ipairs(Window.GUI:GetDescendants()) do
                    if obj.Name == "ManicBackground" then
                        obj:Destroy()
                    end
                end
            end
        end)
        WindUI:Notify({Title = "sᴄʀɪᴘᴛ", Content = "Imagem removida", Duration = 2})
    end,
})

-- ============================================
-- INFORMAÇÕES
-- ============================================
ScriptTab:Section({ Title = "ɪɴꜰᴏʀᴍᴀᴄᴏᴇs" })

ScriptTab:Button({
    Title = "ᴠᴇʀsᴀᴏ: ᴠ3.0",
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

ScriptTab:Button({
    Title = "ᴄʀɪᴀᴅᴏ ᴘᴏʀ: 𝕿𝖍𝖊𝕬𝖓𝖌𝖊𝖑𝕷𝖆𝖓𝖉𝖝𝖘",
    Desc = "ᴍᴀɴɪᴄ ʜᴜʙ • ᴛʜᴇ ᴄʟᴀꜱꜱɪᴄ ꜱᴏᴄᴄᴇʀ",
    Callback = function()
        pcall(function()
            if setclipboard then setclipboard("𝕿𝖍𝖊𝕬𝖓𝖌𝖊𝖑𝕷𝖆𝖓𝖉𝖝𝖘") end
        end)
        WindUI:Notify({Title = "sᴄʀɪᴘᴛ", Content = "Nome copiado", Duration = 2})
    end,
})

ScriptTab:Button({
    Title = "ᴏʙʀɪɢᴀᴅᴏ ᴘᴏʀ ᴜsᴀʀ!",
    Desc = "ꜱᴇ ᴄᴜʀᴛɪᴜ, ᴄᴏᴍᴘᴀʀᴛɪʟʜᴀ ᴄᴏᴍ ᴏꜱ ᴀᴍɪɢᴏꜱ.",
    Callback = function()
        WindUI:Notify({Title = "ᴍᴀɴɪᴄ ʜᴜʙ", Content = "Valeu pelo apoio!", Duration = 3})
    end,
})

-- ============================================
-- FINAL
-- ============================================
WindUI:Notify({
    Title = "Manic Hub",
    Content = "Carregado! Use LeftShift para abrir/fechar.",
    Duration = 5,
    Icon = "check-circle",
})

print("[MANIC HUB] Carregado com WindUI!")
print("[MANIC HUB] FTI:", tostring(FTI ~= nil))
print("[MANIC HUB] Botões GK:", #GKBotoes)
print("[MANIC HUB] ᴄʀɪᴀᴅᴏ ᴘᴏʀ: 𝕿𝖍𝖊𝕬𝖓𝖌𝖊𝖑𝕷𝖆𝖓𝖉𝖝𝖘")
--[[ MANIC HUB | PARTE 11/11 — ᴛʀᴏʟʟ + ᴀᴜᴛᴏ ꜰᴀʀᴍ ]]

-- ABA ᴛʀᴏʟʟ
local TrollTab = Window:Tab({ Title = "ᴛʀᴏʟʟ", Icon = "zap" })

local FlingBallForce = 300
local PowerShootEnabled = false
local PowerShootForce = 250
local PowerShootRange = 8
local ControlBallEnabled = false
local ControlBallConn = nil
local ControlBallSpeed = 80
local OriginalCameraSubject = nil
local OriginalCameraType = nil
local LoopBallEnabled = false
local LoopBallConn = nil
local LoopBallDistance = 2.5
local LoopBallMinSpeed = 5
local ImaBallEnabled = false
local ImaBallConn = nil
local ImaBallForce = 60
local ImaBallRange = 40

TrollTab:Section({ Title = "ʟᴏᴏᴘ ʙᴀʟʟ" })

local function StartLoopBall()
    if LoopBallConn then return end
    LoopBallConn = RunService.Heartbeat:Connect(function()
        if not LoopBallEnabled then return end
        if not RootPart or not RootPart.Parent then return end
        local ball = GetValidBall()
        if not ball or not ball.Parent then return end
        local vel = ball.AssemblyLinearVelocity
        if vel.Magnitude < LoopBallMinSpeed then return end
        local dir = ball.Position - RootPart.Position
        local dirH = Vector3.new(dir.X, 0, dir.Z)
        if dirH.Magnitude < 0.1 then
            RootPart.CFrame = CFrame.new(ball.Position + Vector3.new(0, 1.5, 0))
        else
            local dirUnit = dirH.Unit
            local posFinal = ball.Position - (dirUnit * LoopBallDistance) + Vector3.new(0, 1.5, 0)
            RootPart.CFrame = CFrame.new(posFinal)
        end
        pcall(function()
            firetouchinterest(RootPart, ball, 0)
            firetouchinterest(RootPart, ball, 1)
        end)
    end)
end

local function StopLoopBall()
    if LoopBallConn then
        LoopBallConn:Disconnect()
        LoopBallConn = nil
    end
end

TrollTab:Toggle({Title = "ᴀᴛɪᴠᴀʀ ʟᴏᴏᴘ ʙᴀʟʟ", Value = false, Callback = function(Value)
    LoopBallEnabled = Value
    if Value then StartLoopBall() else StopLoopBall() end
end})
TrollTab:Slider({Title = "ᴠᴇʟᴏᴄɪᴅᴀᴅᴇ ᴍɪɴɪᴍᴀ ᴅᴀ ʙᴏʟᴀ", Value = {Min = 1, Max = 30, Default = 5}, Callback = function(v) LoopBallMinSpeed = v end})
TrollTab:Slider({Title = "ᴅɪsᴛᴀɴᴄɪᴀ ᴅᴀ ʙᴏʟᴀ", Value = {Min = 1, Max = 8, Default = 2.5, Decimal = 1}, Callback = function(v) LoopBallDistance = v end})

TrollTab:Section({ Title = "ɪᴍᴀ ʙᴀʟʟ" })

local function StartImaBall()
    if ImaBallConn then return end
    ImaBallConn = RunService.Heartbeat:Connect(function(dt)
        if not ImaBallEnabled then return end
        if not RootPart or not RootPart.Parent then return end
        local ball = GetValidBall()
        if not ball or not ball.Parent then return end
        local dir = RootPart.Position - ball.Position
        local dist = dir.Magnitude
        if dist > ImaBallRange or dist < 0.5 then return end
        local dirUnit = dir.Unit
        local forceMultiplier = math.clamp(1 - (dist / ImaBallRange), 0.3, 1)
        local pull = dirUnit * ImaBallForce * forceMultiplier
        local vel = ball.AssemblyLinearVelocity
        ball.AssemblyLinearVelocity = vel:Lerp(pull, dt * 8)
    end)
end

local function StopImaBall()
    if ImaBallConn then
        ImaBallConn:Disconnect()
        ImaBallConn = nil
    end
end

TrollTab:Toggle({Title = "ᴀᴛɪᴠᴀʀ ɪᴍᴀ ʙᴀʟʟ", Value = false, Callback = function(Value)
    ImaBallEnabled = Value
    if Value then StartImaBall() else StopImaBall() end
end})
TrollTab:Slider({Title = "ꜰᴏʀᴄᴀ ᴅᴏ ɪᴍᴀ", Value = {Min = 10, Max = 200, Default = 60}, Callback = function(v) ImaBallForce = v end})
TrollTab:Slider({Title = "ᴀʟᴄᴀɴᴄᴇ ᴅᴏ ɪᴍᴀ", Value = {Min = 5, Max = 100, Default = 40}, Callback = function(v) ImaBallRange = v end})

TrollTab:Section({ Title = "ᴄᴏɴᴛʀᴏʟ ʙᴀʟʟ" })

local function StartControlBall()
    if ControlBallConn then return end
    local ball = GetValidBall()
    if not ball or not ball.Parent then
        WindUI:Notify({Title = "ᴄᴏɴᴛʀᴏʟ ʙᴀʟʟ", Content = "Nenhuma bola encontrada", Duration = 2})
        ControlBallEnabled = false
        return
    end
    OriginalCameraType = Camera.CameraType
    OriginalCameraSubject = Camera.CameraSubject
    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = ball
    ControlBallConn = RunService.Heartbeat:Connect(function(dt)
        if not ControlBallEnabled then return end
        ball = GetValidBall()
        if not ball or not ball.Parent then return end
        if Camera.CameraSubject ~= ball then
            Camera.CameraSubject = ball
            Camera.CameraType = Enum.CameraType.Custom
        end
        local camLook = Camera.CFrame.LookVector
        local targetVel = camLook * ControlBallSpeed
        local currentVel = ball.AssemblyLinearVelocity
        ball.AssemblyLinearVelocity = currentVel:Lerp(targetVel, dt * 10)
        ball.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function StopControlBall()
    if ControlBallConn then
        ControlBallConn:Disconnect()
        ControlBallConn = nil
    end
    pcall(function()
        if OriginalCameraSubject then
            Camera.CameraSubject = OriginalCameraSubject
        elseif Humanoid then
            Camera.CameraSubject = Humanoid
        end
        Camera.CameraType = OriginalCameraType or Enum.CameraType.Custom
    end)
    OriginalCameraType = nil
    OriginalCameraSubject = nil
end

TrollTab:Toggle({Title = "ᴀᴛɪᴠᴀʀ ᴄᴏɴᴛʀᴏʟ ʙᴀʟʟ", Value = false, Callback = function(Value)
    ControlBallEnabled = Value
    if Value then StartControlBall() else StopControlBall() end
end})
TrollTab:Slider({Title = "ᴠᴇʟᴏᴄɪᴅᴀᴅᴇ ᴅᴀ ʙᴏʟᴀ", Value = {Min = 20, Max = 300, Default = 80}, Callback = function(v) ControlBallSpeed = v end})

TrollTab:Section({ Title = "ꜰʟɪɴɢ ʙᴀʟʟ" })

local function FlingBall()
    local ball = GetValidBall()
    if not ball or not ball.Parent then
        WindUI:Notify({Title = "ꜰʟɪɴɢ ʙᴀʟʟ", Content = "Nenhuma bola encontrada", Duration = 2})
        return
    end
    if not RootPart or not RootPart.Parent then return end
    local direcao = (ball.Position - RootPart.Position).Unit
    local posFinal = ball.Position - (direcao * 1.5) + Vector3.new(0, 1, 0)
    RootPart.CFrame = CFrame.new(posFinal)
    task.wait(0.1)
    if ball and ball.Parent then
        local randomDir = Vector3.new(
            math.random(-100, 100) / 100,
            1,
            math.random(-100, 100) / 100
        ).Unit
        ball.AssemblyLinearVelocity = randomDir * FlingBallForce + Vector3.new(0, FlingBallForce * 0.6, 0)
        ball.AssemblyAngularVelocity = Vector3.new(
            math.random(-50, 50),
            math.random(-50, 50),
            math.random(-50, 50)
        )
        pcall(function()
            firetouchinterest(RootPart, ball, 0)
            firetouchinterest(RootPart, ball, 1)
        end)
        WindUI:Notify({Title = "ꜰʟɪɴɢ ʙᴀʟʟ", Content = "Bola flingada!", Duration = 1.5})
    end
end

TrollTab:Button({Title = "ꜰʟɪɴɢ ʙᴀʟʟ", Desc = "Teleporta ate a bola e manda ela voando", Callback = function() FlingBall() end})
TrollTab:Slider({Title = "ꜰᴏʀᴄᴀ ᴅᴏ ꜰʟɪɴɢ", Value = {Min = 100, Max = 800, Default = 300}, Callback = function(v) FlingBallForce = v end})

TrollTab:Section({ Title = "ᴘᴏᴡᴇʀ sʜᴏᴏᴛ" })

local function CheckPowerShoot()
    if not PowerShootEnabled then return end
    if not RootPart or not RootPart.Parent then return end
    local ball = GetValidBall()
    if not ball or not ball.Parent then return end
    local dist = (ball.Position - RootPart.Position).Magnitude
    if dist > PowerShootRange then return end
    local dir = (ball.Position - RootPart.Position).Unit
    local lookDir = RootPart.CFrame.LookVector
    local shootDir = (lookDir + dir).Unit
    ball.AssemblyLinearVelocity = shootDir * PowerShootForce + Vector3.new(0, PowerShootForce * 0.3, 0)
    ball.AssemblyAngularVelocity = Vector3.new(
        math.random(-30, 30),
        math.random(-30, 30),
        math.random(-30, 30)
    )
    pcall(function()
        firetouchinterest(RootPart, ball, 0)
        firetouchinterest(RootPart, ball, 1)
    end)
end

TrollTab:Toggle({Title = "ᴀᴛɪᴠᴀʀ ᴘᴏᴡᴇʀ sʜᴏᴏᴛ", Value = false, Callback = function(Value) PowerShootEnabled = Value end})
TrollTab:Slider({Title = "ꜰᴏʀᴄᴀ ᴅᴏ ᴘᴏᴡᴇʀ sʜᴏᴏᴛ", Value = {Min = 100, Max = 800, Default = 250}, Callback = function(v) PowerShootForce = v end})
TrollTab:Slider({Title = "ᴀʟᴄᴀɴᴄᴇ ᴅᴏ ᴘᴏᴡᴇʀ sʜᴏᴏᴛ", Value = {Min = 3, Max = 20, Default = 8}, Callback = function(v) PowerShootRange = v end})

RunService.PreRender:Connect(function() CheckPowerShoot() end)

print("[MANIC HUB] ᴀʙᴀ ᴛʀᴏʟʟ ᴄᴀʀʀᴇɢᴀᴅᴀ!")

-- ABA ᴀᴜᴛᴏ ꜰᴀʀᴍ
local FarmTab = Window:Tab({ Title = "ᴀᴜᴛᴏ ꜰᴀʀᴍ", Icon = "repeat" })

local AutoGolBlueEnabled = false
local AutoGolGreenEnabled = false
local AutoGolCooldown = 0.4
local AutoGolLast = 0
local AutoGolForce = 180
local AutoGolArcY = 25

local AUTO_GOL_BLUE_CFRAMES = { Vector3.new(-32.18, -28.94, -203.58) }
local AUTO_GOL_GREEN_CFRAMES = {
    Vector3.new(-34.06, -28.94, 383.88),
    Vector3.new(-3.92, -28.94, 388.81),
}

local function EscolherCFrameAleatorio(lista)
    return lista[math.random(1, #lista)]
end

local function CheckAutoGol()
    if not AutoGolBlueEnabled and not AutoGolGreenEnabled then return end
    if not RootPart or not RootPart.Parent then return end
    if tick() - AutoGolLast < AutoGolCooldown then return end
    local ball = GetValidBall()
    if not ball or not ball.Parent then return end
    local dist = (ball.Position - RootPart.Position).Magnitude
    if dist > 6 then return end
    local target
    if AutoGolBlueEnabled and AutoGolGreenEnabled then
        if math.random() < 0.5 then
            target = EscolherCFrameAleatorio(AUTO_GOL_BLUE_CFRAMES)
        else
            target = EscolherCFrameAleatorio(AUTO_GOL_GREEN_CFRAMES)
        end
    elseif AutoGolBlueEnabled then
        target = EscolherCFrameAleatorio(AUTO_GOL_BLUE_CFRAMES)
    elseif AutoGolGreenEnabled then
        target = EscolherCFrameAleatorio(AUTO_GOL_GREEN_CFRAMES)
    end
    if not target then return end
    AutoGolLast = tick()
    local dir = target - ball.Position
    local dirH = Vector3.new(dir.X, 0, dir.Z)
    if dirH.Magnitude < 0.1 then return end
    local dirUnit = dirH.Unit
    local shootVec = (dirUnit * AutoGolForce) + Vector3.new(0, AutoGolArcY, 0)
    local currentVel = ball.AssemblyLinearVelocity
    ball.AssemblyLinearVelocity = currentVel:Lerp(shootVec, 0.85)
    ball.AssemblyAngularVelocity = Vector3.new(
        math.random(-15, 15),
        math.random(-15, 15),
        math.random(-15, 15)
    )
    pcall(function()
        firetouchinterest(RootPart, ball, 0)
        firetouchinterest(RootPart, ball, 1)
    end)
end

FarmTab:Section({ Title = "ᴀᴜᴛᴏ ɢᴏʟ" })
FarmTab:Toggle({Title = "ᴀᴜᴛᴏ ɢᴏʟ ʙʟᴜᴇ", Value = false, Callback = function(Value) AutoGolBlueEnabled = Value end})
FarmTab:Toggle({Title = "ᴀᴜᴛᴏ ɢᴏʟ ɢʀᴇᴇɴ", Value = false, Callback = function(Value) AutoGolGreenEnabled = Value end})
FarmTab:Slider({Title = "ꜰᴏʀᴄᴀ ᴅᴏ ᴀʀʀᴇᴍᴇssᴏ", Value = {Min = 50, Max = 500, Default = 180}, Callback = function(v) AutoGolForce = v end})
FarmTab:Slider({Title = "ᴀʀᴄᴏ (ᴀʟᴛᴜʀᴀ)", Value = {Min = 0, Max = 100, Default = 25}, Callback = function(v) AutoGolArcY = v end})
FarmTab:Slider({Title = "ᴄᴏᴏʟᴅᴏᴡɴ", Value = {Min = 1, Max = 30, Default = 4, Suffix = "x0.1s"}, Callback = function(v) AutoGolCooldown = v / 10 end})

RunService.PreRender:Connect(function() CheckAutoGol() end)

print("[MANIC HUB] ᴀʙᴀ ᴀᴜᴛᴏ ꜰᴀʀᴍ ᴄᴀʀʀᴇɢᴀᴅᴀ!")
print("[MANIC HUB] ᴛᴏᴛᴀʟ ᴅᴇ 11 ᴘᴀʀᴛᴇs ᴄᴀʀʀᴇɢᴀᴅᴀs!")
