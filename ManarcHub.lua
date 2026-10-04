--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | PARTE 1/9 — Setup + Helpers + Mapa + BoomBox ]]

Players = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
Workspace = game:GetService("Workspace")
CoreGui = game:GetService("CoreGui")
StarterGui = game:GetService("StarterGui")
Lighting = game:GetService("Lighting")
ReplicatedStorage = game:GetService("ReplicatedStorage")
TextChatService = game:GetService("TextChatService")
TweenService = game:GetService("TweenService")
VirtualInputManager = game:GetService("VirtualInputManager")
LocalPlayer = Players.LocalPlayer
Camera = Workspace.CurrentCamera
PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

getgenv().ManicHub = getgenv().ManicHub or {}
Flags = getgenv().ManicHub

Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
Humanoid = Character:WaitForChild("Humanoid")
RootPart = Character:WaitForChild("HumanoidRootPart")
function UpdateCharacter(c)
    Character = c
    Humanoid = c:WaitForChild("Humanoid")
    RootPart = c:WaitForChild("HumanoidRootPart")
end
LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

Backups = {
    Grass = {},
    Lighting = {
        Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
        ColorShift_Top = Lighting.ColorShift_Top, ColorShift_Bottom = Lighting.ColorShift_Bottom,
        Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd, FogColor = Lighting.FogColor,
    }
}

State = {
    AutoBall = false, AutoDrive = false, AutoCatch = false, Reach = false,
    ReachDistance = 10, PlayerSpeed = 16, Trail = false,
    StretchH = false, StretchV = false,
    BallColor = nil, BallFire = false, BallTrail = false,
    GrassColor = nil, Skybox = nil, BoomBoxSound = nil,
}

FTI = firetouchinterest or (getgenv and getgenv().firetouchinterest)

Backgrounds = {
    BlackCat   = "rbxassetid://73996114712615",
    catsamurai = "rbxassetid://89598194576679",
    BlackHole  = "rbxassetid://129182988208983",
    Classic    = "rbxassetid://137552094969",
}

WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

Window = WindUI:CreateWindow({
    Title = "𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈",
    Icon = "eye",
    Author = "𝙰𝚄𝚃𝙾 𝙵𝙰𝚁𝙼",
    Folder = "ManicHub",
    Size = UDim2.fromOffset(620, 480),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true,
    Background = Backgrounds.BlackHole,
    BackgroundImageTransparency = 0.35,
})

pcall(function()
    Window:Tag({ Title = "𝚅𝟺.𝟶", Icon = "sparkles", Color = Color3.fromHex("#7850f0"), Radius = 30 })
end)

pcall(function()
    WindUI:Notify({ Title = "𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈", Content = "𝙲𝙰𝚁𝚁𝙴𝙶𝙰𝙳𝙾", Duration = 5, Icon = "check-circle" })
end)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.LeftShift then Window:Toggle() end
end)

ICON_IMAGE_ID = "rbxassetid://136946915996013"
task.spawn(function()
    task.wait(1.5)
    local parentGui = (gethui and gethui()) or CoreGui
    local ok, children = pcall(function() return parentGui:GetChildren() end)
    if not ok then return end
    local windGui = nil
    for _, sg in ipairs(children) do
        if sg:IsA("ScreenGui") and sg.Enabled then
            local nome = string.lower(sg.Name)
            if nome ~= "robloxgui" and nome ~= "manicfps" and nome ~= "manicfloat" and nome ~= "manicnotify" then
                windGui = sg; break
            end
        end
    end
    if not windGui then return end
    for _, obj in ipairs(windGui:GetDescendants()) do
        if obj:IsA("TextLabel") then
            local n = string.lower(obj.Name)
            if n == "icon" or n == "titleicon" or n == "logoicon" then
                local p, pos, sz = obj.Parent, obj.Position, obj.Size
                obj.Visible = false
                local img = Instance.new("ImageLabel")
                img.Name = "Manic_CustomIcon"
                img.Size = sz; img.Position = pos
                img.BackgroundTransparency = 1
                img.Image = ICON_IMAGE_ID
                img.ScaleType = Enum.ScaleType.Crop
                img.Parent = p
                Instance.new("UICorner", img).CornerRadius = UDim.new(0, 8)
                break
            end
        end
    end
end)

FpsGui = Instance.new("ScreenGui")
FpsGui.Name = "ManicFPS"; FpsGui.ResetOnSpawn = false
FpsGui.IgnoreGuiInset = true
pcall(function() FpsGui.Parent = (gethui and gethui()) or CoreGui end)
FpsBox = Instance.new("TextLabel")
FpsBox.Parent = FpsGui
FpsBox.Size = UDim2.new(0, 90, 0, 32); FpsBox.Position = UDim2.new(0, 12, 0, 110)
FpsBox.BackgroundColor3 = Color3.fromRGB(20, 22, 32); FpsBox.BackgroundTransparency = 0.3
FpsBox.TextColor3 = Color3.fromRGB(255, 255, 255); FpsBox.TextSize = 13
FpsBox.Font = Enum.Font.GothamBold; FpsBox.Text = "𝙵𝙿𝚂 𝟶"
FpsBox.BorderSizePixel = 0; FpsBox.ZIndex = 100
Instance.new("UICorner", FpsBox).CornerRadius = UDim.new(0, 6)
fpsCount, fpsTime = 0, tick()
RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    local now = tick()
    if now - fpsTime >= 1 then FpsBox.Text = "𝙵𝙿𝚂 " .. fpsCount; fpsCount = 0; fpsTime = now end
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
    return s/b >= 0.60
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
function GetValidBall() return CurrentFollowBall or FindClosestBall() end
function EhGrama(obj)
    if not obj:IsA("BasePart") then return false end
    if obj.Material == Enum.Material.Grass then return true end
    local n = string.lower(obj.Name)
    return (string.find(n, "grass") or string.find(n, "grama") or string.find(n, "gramado")
        or string.find(n, "campo") or string.find(n, "field") or string.find(n, "pitch")
        or string.find(n, "turf")) ~= nil
end

MapTab = Window:Tab({ Title = "𝙼𝙰𝙿𝙰", Icon = "map" })
MapTab:Section({ Title = "𝙲𝙾𝚁 𝙳𝙾 𝙶𝚁𝙰𝙼𝙰𝙳𝙾" })

function SalvarGrama()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and EhGrama(obj) and not Backups.Grass[obj] then
            Backups.Grass[obj] = {Color = obj.Color, Material = obj.Material}
        end
    end
end
function AplicarCorGrama(cor)
    SalvarGrama(); State.GrassColor = cor
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
function RestaurarGrama()
    for obj, data in pairs(Backups.Grass) do
        if obj and obj.Parent then
            pcall(function()
                obj.Color = data.Color; obj.Material = data.Material
                for _, c in ipairs(obj:GetChildren()) do
                    if c:IsA("Texture") or c:IsA("Decal") then c.Transparency = 0 end
                end
            end)
        end
    end
    State.GrassColor = nil
end

MapTab:Colorpicker({ Title = "𝙼𝙰𝙿 𝙲𝙾𝙻𝙾𝚁", Default = Color3.fromRGB(60, 145, 60), Callback = function(c) AplicarCorGrama(c) end })
MapTab:Button({ Title = "𝚁𝙴𝚂𝚃𝙰𝚄𝚁𝙰𝚁 𝙶𝚁𝙰𝙼𝙰", Callback = function()
    RestaurarGrama(); pcall(function() WindUI:Notify({Title = "𝙼𝙰𝙿𝙰", Content = "𝙶𝚁𝙰𝙼𝙰 𝚁𝙴𝚂𝚃𝙰𝚄𝚁𝙰𝙳𝙰", Duration = 2}) end)
end })

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

MapTab:Section({ Title = "𝚂𝙺𝚈𝙱𝙾𝚇" })
function ForceSkyTCS(assetId)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local n = string.lower(obj.Name)
            if (string.find(n, "sky") or string.find(n, "dome") or string.find(n, "ceu") or string.find(n, "atmosphere"))
            and not string.find(n, "manic") then
                pcall(function() obj:Destroy() end)
            end
        end
    end
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") or child:IsA("Atmosphere") or child:IsA("Clouds")
        or child:IsA("PostEffect") or child:IsA("ColorCorrectionEffect") then child:Destroy() end
    end
    local newSky = Instance.new("Sky")
    newSky.Name = "ManicSky"
    local url = "rbxassetid://" .. tostring(assetId)
    newSky.SkyboxBk = url; newSky.SkyboxDn = url; newSky.SkyboxFt = url
    newSky.SkyboxLf = url; newSky.SkyboxRt = url; newSky.SkyboxUp = url
    newSky.Parent = Lighting
    State.Skybox = assetId
end

SkyboxIDs = {
    {Name = "𝚂𝙺𝚈 𝟷", ID = "8202961731"}, {Name = "𝚂𝙺𝚈 𝟸", ID = "2758029221"},
    {Name = "𝙽𝙸𝙶𝙷𝚃", ID = "13107361022"}, {Name = "𝚂𝙺𝚈 𝟺", ID = "7108851308"},
    {Name = "𝚂𝙺𝚈 𝟻", ID = "339406852"}, {Name = "𝚂𝙺𝚈 𝟼", ID = "15502592084"},
    {Name = "𝚂𝙺𝚈 𝟽", ID = "15359965253"}, {Name = "𝚂𝙺𝚈 𝟾", ID = "15470370280"},
    {Name = "𝙱𝙻𝚄𝙴 𝚂𝙺𝚈", ID = "8808550143"}, {Name = "𝚂𝙺𝚈 𝟷𝟶", ID = "10594723714"},
}
for _, sky in ipairs(SkyboxIDs) do
    MapTab:Button({ Title = sky.Name, Callback = function()
        ForceSkyTCS(sky.ID); pcall(function() WindUI:Notify({Title = "𝚂𝙺𝚈𝙱𝙾𝚇", Content = sky.Name, Duration = 2}) end)
    end })
end

MapTab:Section({ Title = "𝚂𝙺𝚈 𝙴𝚇𝚃𝚁𝙰" })
function ClearSky()
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") then obj:Destroy() end
    end
end
MapTab:Button({ Title = "𝚂𝙺𝚈 𝙳𝙴 𝚂𝙾𝙻", Callback = function()
    ClearSky(); Lighting.ClockTime = 7; Lighting.Brightness = 2
    local sky = Instance.new("Sky")
    sky.SkyboxBk = "rbxassetid://541743453"; sky.SkyboxDn = "rbxassetid://541743443"
    sky.SkyboxFt = "rbxassetid://541743446"; sky.SkyboxLf = "rbxassetid://541743436"
    sky.SkyboxRt = "rbxassetid://541743435"; sky.SkyboxUp = "rbxassetid://541743441"
    sky.Parent = Lighting
end })
MapTab:Button({ Title = "𝚂𝙺𝚈 𝙳𝙴 𝙻𝚄𝙰", Callback = function()
    ClearSky(); Lighting.ClockTime = 21
    local sky = Instance.new("Sky")
    sky.SkyboxBk = "rbxassetid://4498828382"; sky.SkyboxDn = "rbxassetid://4498828812"
    sky.SkyboxFt = "rbxassetid://4498829917"; sky.SkyboxLf = "rbxassetid://4498830911"
    sky.SkyboxRt = "rbxassetid://4498830417"; sky.SkyboxUp = "rbxassetid://4498831746"
    sky.Parent = Lighting
end })
MapTab:Button({ Title = "𝚁𝙴𝙼𝙾𝚅𝙴𝚁 𝚂𝙺𝚈", Callback = function() ClearSky(); State.Skybox = nil end })

task.spawn(function()
    while true do
        task.wait(1)
        if State.Skybox then
            local exists = false
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("Sky") and v.Name == "ManicSky" then exists = true; break end
            end
            if not exists then ForceSkyTCS(State.Skybox) end
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("Sky") and v.Name ~= "ManicSky" then v:Destroy() end
            end
        end
    end
end)

MapTab:Section({ Title = "𝙶𝚁𝙰𝙵𝙸𝙲𝙾𝚂" })
function ResetarLighting()
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
MapTab:Button({Title = "𝙵𝙻𝙾𝚁𝙸𝙳𝙾", Callback = function()
    ResetarLighting()
    pcall(function()
        Lighting.Ambient = Color3.fromRGB(255, 200, 230)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 180, 220)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 150, 200)
        Lighting.Brightness = 2.5
    end)
end })
MapTab:Button({Title = "𝙱𝙾𝙽𝙸𝚃𝙾", Callback = function() ResetarLighting() end })
MapTab:Button({Title = "𝚂𝙾𝙻", Callback = function()
    ResetarLighting(); pcall(function() Lighting.ClockTime = 17 end)
end })
MapTab:Button({Title = "𝚁𝙴𝙲𝙾𝙼𝙴𝙽𝙳𝙰𝙳𝙾", Callback = function() ResetarLighting() end })

MapTab:Section({ Title = "𝙸𝙼𝙰𝙶𝙴𝙼 𝙳𝙴 𝙵𝚄𝙽𝙳𝙾" })
MapTab:Dropdown({
    Title = "𝙱𝙰𝙲𝙺𝙶𝚁𝙾𝚄𝙽𝙳",
    Values = {"BlackCat", "catsamurai", "BlackHole", "Classic"},
    Value = "BlackHole",
    Callback = function(option)
        local url = Backgrounds[option]
        if not url then return end
        pcall(function() if Window.SetBackground then Window:SetBackground(url, 0.35) end end)
        pcall(function() WindUI:Notify({Title = "𝚃𝙷𝙴𝙼𝙴", Content = option, Duration = 2}) end)
    end,
})

BoomTab = Window:Tab({ Title = "𝙱𝙾𝙾𝙼 𝙱𝙾𝚇", Icon = "music" })
BoomTab:Section({ Title = "𝙼𝚄𝚂𝙸𝙲𝙰𝚂" })

function TocarMusica(id)
    pcall(function()
        if State.BoomBoxSound then State.BoomBoxSound:Destroy() end
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. id
        sound.Volume = 2
        sound.Parent = Character:FindFirstChild("HumanoidRootPart") or Workspace
        sound:Play()
        State.BoomBoxSound = sound
    end)
end

for _, m in ipairs({
    {Nome = "𝙼𝙴𝙰𝙽𝚃 𝚃𝙾 𝙱𝙴", ID = "84321228471359"},
    {Nome = "𝚂𝙾𝙼𝙴𝚃𝙸𝙼𝙴𝚂", ID = "128715303988843"},
    {Nome = "𝙱𝙻𝙾𝙳𝙻𝚈𝙽 𝙱𝙻𝙾𝙾𝙳𝙿𝙾𝙿", ID = "96414211708215"},
}) do
    BoomTab:Button({ Title = m.Nome, Callback = function()
        TocarMusica(m.ID); pcall(function() WindUI:Notify({Title = "𝙱𝙾𝙾𝙼 𝙱𝙾𝚇", Content = m.Nome, Duration = 2}) end)
    end })
end

BoomTab:Section({ Title = "𝙲𝚄𝚂𝚃𝙾𝙼" })
BoomTab:Input({ Title = "𝙸𝙳", Placeholder = "𝙸𝙳...", Callback = function(text)
    if text and text ~= "" then TocarMusica(text) end
end })
BoomTab:Button({ Title = "𝙿𝙰𝚁𝙰𝚁 𝙼𝚄𝚂𝙸𝙲𝙰", Callback = function()
    if State.BoomBoxSound then
        pcall(function() State.BoomBoxSound:Stop(); State.BoomBoxSound:Destroy() end)
        State.BoomBoxSound = nil
    end
end })--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | PARTE 2/9 — Ball: Auto Ball + Efeitos ]]

BallTab = Window:Tab({ Title = "𝙱𝙰𝙻𝙻", Icon = "circle" })
BallTab:Section({ Title = "𝙰𝚄𝚃𝙾 𝙱𝙰𝙻𝙻" })

AutoFollowConnection = nil
CurrentFollowBall = nil
FollowScanTimer = 0
FollowStopDistance = 0.20
ManualSteerStrength = 1.25
PlayerControls = nil

pcall(function()
    local PM = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
    PlayerControls = PM:GetControls()
end)

function GetManualDirection()
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
        and not IsValidTPSBall(CurrentFollowBall) then inv = true end

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
    State.AutoBall = false; CurrentFollowBall = nil; FollowScanTimer = 0
    if AutoFollowConnection then AutoFollowConnection:Disconnect(); AutoFollowConnection = nil end
    local _, hum = GetCharacterData()
    if hum then hum.AutoRotate = true end
end

BallTab:Toggle({ Title = "𝙰𝚄𝚃𝙾 𝙱𝙰𝙻𝙻", Value = false, Callback = function(v)
    if v then StartAutoBall() else StopAutoBall() end
end })
BallTab:Slider({ Title = "𝙳𝙸𝚂𝚃𝙰𝙽𝙲𝙸𝙰 𝙳𝙴 𝙿𝙰𝚁𝙰𝙳𝙰", Value = {Min = 1, Max = 50, Default = 2}, Callback = function(v) FollowStopDistance = v / 10 end })
BallTab:Slider({ Title = "𝙵𝙾𝚁𝙲𝙰 𝙳𝙾 𝚂𝚃𝙴𝙴𝚁𝙸𝙽𝙶", Value = {Min = 1, Max = 30, Default = 13}, Callback = function(v) ManualSteerStrength = v / 10 end })

BallTab:Section({ Title = "𝙰𝙿𝙰𝚁𝙴𝙽𝙲𝙸𝙰 𝙳𝙰 𝙱𝙰𝙻𝙻" })

BallTextureBackup = {}
function SalvarTexturasBall(ball)
    if BallTextureBackup[ball] then return end
    local data = {Decals = {}, MeshTexId = nil, Mesh = nil, Cor = ball.Color, Material = ball.Material}
    pcall(function() if ball:IsA("MeshPart") then data.TextureID = ball.TextureID end end)
    local mesh = ball:FindFirstChildWhichIsA("SpecialMesh")
    if mesh then data.MeshTexId = mesh.TextureId; data.Mesh = mesh end
    for _, c in ipairs(ball:GetChildren()) do
        if c:IsA("Texture") or c:IsA("Decal") then
            table.insert(data.Decals, {Obj = c, Trans = c.Transparency})
        end
    end
    BallTextureBackup[ball] = data
end
function RemoverTexturasBall(ball)
    pcall(function() if ball:IsA("MeshPart") then ball.TextureID = "" end end)
    local mesh = ball:FindFirstChildWhichIsA("SpecialMesh")
    if mesh then pcall(function() mesh.TextureId = "" end) end
    for _, c in ipairs(ball:GetChildren()) do
        if c:IsA("Texture") or c:IsA("Decal") then c.Transparency = 1 end
    end
end
function AplicarCorBall(cor)
    State.BallColor = cor
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if IsBall(obj) then
            SalvarTexturasBall(obj); RemoverTexturasBall(obj)
            pcall(function() obj.Color = cor; obj.Material = Enum.Material.Neon end)
        end
    end
end
function RestaurarBall()
    for ball, data in pairs(BallTextureBackup) do
        if ball and ball.Parent then
            pcall(function()
                if data.TextureID then ball.TextureID = data.TextureID end
                if data.MeshTexId and data.Mesh then data.Mesh.TextureId = data.MeshTexId end
                for _, d in ipairs(data.Decals) do
                    if d.Obj and d.Obj.Parent then d.Obj.Transparency = d.Trans end
                end
                ball.Color = data.Cor; ball.Material = data.Material
            end)
        end
    end
    State.BallColor = nil; State.BallFire = false; State.BallTrail = false
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if IsBall(obj) then
            local f = obj:FindFirstChild("Manic_BallFire"); if f then f:Destroy() end
            local t = obj:FindFirstChild("Manic_BallTrail"); if t then t:Destroy() end
            for _, a in ipairs(obj:GetChildren()) do
                if a.Name == "Manic_TrailA0" or a.Name == "Manic_TrailA1" then a:Destroy() end
            end
        end
    end
end

BallTab:Colorpicker({ Title = "𝙲𝙾𝚁 𝙳𝙰 𝙱𝙰𝙻𝙻", Default = Color3.fromRGB(89, 247, 255), Callback = function(c) AplicarCorBall(c) end })

FireColor1 = Color3.fromRGB(255, 100, 0)
FireColor2 = Color3.fromRGB(255, 200, 0)
FireSize = 15
FireHeat = 25

BallTab:Toggle({ Title = "𝙵𝙾𝙶𝙾 𝙽𝙰 𝙱𝙰𝙻𝙻", Value = false, Callback = function(v)
    State.BallFire = v
    if not v then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if IsBall(obj) then
                local f = obj:FindFirstChild("Manic_BallFire"); if f then f:Destroy() end
            end
        end
    end
end })
BallTab:Colorpicker({ Title = "𝙲𝙾𝚁 𝙿𝚁𝙸𝙽𝙲𝙸𝙿𝙰𝙻 𝙳𝙾 𝙵𝙾𝙶𝙾", Default = FireColor1, Callback = function(c) FireColor1 = c end })
BallTab:Colorpicker({ Title = "𝙲𝙾𝚁 𝚂𝙴𝙲𝚄𝙽𝙳𝙰𝚁𝙸𝙰", Default = FireColor2, Callback = function(c) FireColor2 = c end })
BallTab:Slider({Title = "𝚃𝙰𝙼𝙰𝙽𝙷𝙾", Value = {Min = 1, Max = 50, Default = 15}, Callback = function(v) FireSize = v end})
BallTab:Slider({Title = "𝙸𝙽𝚃𝙴𝙽𝚂𝙸𝙳𝙰𝙳𝙴", Value = {Min = 1, Max = 50, Default = 25}, Callback = function(v) FireHeat = v end})

TrailEnabled = false
TrailColor = Color3.fromRGB(120, 90, 240)
TrailWidth = 1
TrailLifetime = 1

BallTab:Toggle({ Title = "𝚃𝚁𝙰𝙸𝙻 𝙽𝙰 𝙱𝙰𝙻𝙻", Value = false, Callback = function(v)
    TrailEnabled = v; State.BallTrail = v
    if not v then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if IsBall(obj) then
                local t = obj:FindFirstChild("Manic_BallTrail"); if t then t:Destroy() end
                for _, a in ipairs(obj:GetChildren()) do
                    if a.Name == "Manic_TrailA0" or a.Name == "Manic_TrailA1" then a:Destroy() end
                end
            end
        end
    end
end })
BallTab:Colorpicker({Title = "𝙲𝙾𝚁 𝙳𝙾 𝚃𝚁𝙰𝙸𝙻", Default = TrailColor, Callback = function(c) TrailColor = c end})
BallTab:Slider({Title = "𝙻𝙰𝚁𝙶𝚄𝚁𝙰", Value = {Min = 1, Max = 50, Default = 10}, Callback = function(v) TrailWidth = v / 10 end})
BallTab:Slider({Title = "𝙳𝚄𝚁𝙰𝙲𝙰𝙾", Value = {Min = 1, Max = 50, Default = 10}, Callback = function(v) TrailLifetime = v / 10 end})

BallTab:Button({ Title = "𝚁𝙴𝚂𝚃𝙰𝚄𝚁𝙰𝚁 𝙱𝙰𝙻𝙻", Callback = function()
    RestaurarBall(); TrailEnabled = false
    pcall(function() WindUI:Notify({Title = "𝙱𝙰𝙻𝙻", Content = "𝚁𝙴𝚂𝚃𝙰𝚄𝚁𝙰𝙳𝙰", Duration = 2}) end)
end })

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
                        f.Size = FireSize; f.Heat = FireHeat
                        f.Color = FireColor1; f.SecondaryColor = FireColor2
                        f.Parent = obj
                    else
                        f.Size = FireSize; f.Heat = FireHeat
                        f.Color = FireColor1; f.SecondaryColor = FireColor2
                    end
                else
                    local f = obj:FindFirstChild("Manic_BallFire"); if f then f:Destroy() end
                end
                if TrailEnabled then
                    local t = obj:FindFirstChild("Manic_BallTrail")
                    if not t then
                        local a0 = Instance.new("Attachment", obj); a0.Name = "Manic_TrailA0"; a0.Position = Vector3.new(-0.5, 0, 0)
                        local a1 = Instance.new("Attachment", obj); a1.Name = "Manic_TrailA1"; a1.Position = Vector3.new(0.5, 0, 0)
                        t = Instance.new("Trail")
                        t.Name = "Manic_BallTrail"; t.Attachment0 = a0; t.Attachment1 = a1
                        t.Color = ColorSequence.new(TrailColor)
                        t.WidthScale = NumberSequence.new(TrailWidth)
                        t.Lifetime = TrailLifetime; t.MinLength = 0.1
                        t.Parent = obj
                    else
                        t.Color = ColorSequence.new(TrailColor); t.Lifetime = TrailLifetime
                    end
                else
                    local t = obj:FindFirstChild("Manic_BallTrail"); if t then t:Destroy() end
                    for _, a in ipairs(obj:GetChildren()) do
                        if a.Name == "Manic_TrailA0" or a.Name == "Manic_TrailA1" then a:Destroy() end
                    end
                end
            end
        end
    end
end)--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | PARTE 3/9 — Ball Extras ]]

BallTab:Section({ Title = "𝙲𝙷𝙰𝙽𝙶𝙴𝚁 𝙱𝙰𝙻𝙻" })

BallSkins = {
    ["Champions Laranja"] = {Texture = "rbxassetid://6631296730", Mesh = "rbxassetid://4545270159"},
    ["Champions Azul"]    = {Texture = "rbxassetid://8108082224", Mesh = "rbxassetid://4454597214"},
    ["Champions Branca"]  = {Texture = "rbxassetid://7897839361", Mesh = "rbxassetid://4761031195"},
}
function AplicarBallSkin(nomeSkin)
    local skin = BallSkins[nomeSkin]; if not skin then return end
    for _, ball in ipairs(Workspace:GetDescendants()) do
        if ball:IsA("BasePart") then
            local n = string.lower(ball.Name)
            if n == "tps" or n == "ball" or n == "bola" or n:find("football") or n:find("soccerball") then
                pcall(function()
                    local mesh = ball:FindFirstChildOfClass("SpecialMesh")
                    if ball:IsA("MeshPart") then
                        ball.MeshId = skin.Mesh; ball.TextureID = skin.Texture
                    else
                        if not mesh then mesh = Instance.new("SpecialMesh", ball) end
                        mesh.MeshType = Enum.MeshType.FileMesh
                        mesh.MeshId = skin.Mesh; mesh.TextureId = skin.Texture
                    end
                    for _, c in ipairs(ball:GetChildren()) do
                        if c:IsA("Decal") or c:IsA("Texture") then
                            c.Texture = skin.Texture; c.Transparency = 0
                        end
                    end
                end)
            end
        end
    end
end
BallTab:Dropdown({ Title = "𝚂𝙺𝙸𝙽 𝙳𝙰 𝙱𝙰𝙻𝙻", Values = {"Champions Laranja", "Champions Azul", "Champions Branca"}, Value = "Champions Laranja",
    Callback = function(option) AplicarBallSkin(option); pcall(function() WindUI:Notify({Title = "𝙱𝙰𝙻𝙻 𝚂𝙺𝙸𝙽", Content = option, Duration = 2}) end) end })

BallTab:Button({ Title = "𝙳𝙴𝚂𝙰𝚃𝙸𝚅𝙰𝚁 𝚂𝙺𝙸𝙽", Callback = function()
    for _, ball in ipairs(Workspace:GetDescendants()) do
        if ball:IsA("BasePart") then
            local n = string.lower(ball.Name)
            if n == "tps" or n == "ball" or n == "bola" then
                pcall(function()
                    local mesh = ball:FindFirstChildOfClass("SpecialMesh"); if mesh then mesh:Destroy() end
                    for _, c in ipairs(ball:GetChildren()) do
                        if c:IsA("Decal") or c:IsA("Texture") then c:Destroy() end
                    end
                end)
            end
        end
    end
end })

BallTab:Section({ Title = "𝚅𝙸𝚂𝚄𝙰𝙻 𝙳𝙰 𝙱𝙰𝙻𝙻" })
BallESPEnabled = false
BallESPColor = Color3.fromRGB(0, 255, 100)
BallESPInstance = nil
BallESPFill = 0.5

function CriarBallESP()
    if BallESPInstance and BallESPInstance.Parent then BallESPInstance:Destroy() end
    BallESPInstance = Instance.new("Highlight")
    BallESPInstance.Name = "Manic_BallESP"
    BallESPInstance.FillColor = BallESPColor
    BallESPInstance.FillTransparency = BallESPFill
    BallESPInstance.OutlineColor = BallESPColor
    BallESPInstance.OutlineTransparency = 0
    BallESPInstance.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    BallESPInstance.Parent = Camera
end

BallTab:Toggle({ Title = "𝙱𝙰𝙻𝙻 𝙴𝚂𝙿", Value = false, Callback = function(v)
    BallESPEnabled = v
    if v then
        spawn(function()
            while BallESPEnabled do
                task.wait(0.05)
                local ball = GetValidBall()
                if ball and ball.Parent then
                    if not BallESPInstance or not BallESPInstance.Parent then CriarBallESP() end
                    BallESPInstance.Adornee = ball
                elseif BallESPInstance then BallESPInstance.Adornee = nil end
            end
        end)
    else
        if BallESPInstance and BallESPInstance.Parent then BallESPInstance:Destroy(); BallESPInstance = nil end
    end
end })
BallTab:Colorpicker({ Title = "𝙲𝙾𝚁 𝙳𝙾 𝙴𝚂𝙿", Default = Color3.fromRGB(0, 255, 100), Callback = function(c)
    BallESPColor = c
    if BallESPInstance then BallESPInstance.FillColor = c; BallESPInstance.OutlineColor = c end
end })
BallTab:Slider({ Title = "𝚃𝚁𝙰𝙽𝚂𝙿𝙰𝚁𝙴𝙽𝙲𝙸𝙰", Value = {Min = 0, Max = 100, Default = 50}, Callback = function(v)
    BallESPFill = v / 100
    if BallESPInstance then BallESPInstance.FillTransparency = BallESPFill end
end })

BallChamsEnabled = false
BallChamsColor = Color3.fromRGB(255, 50, 50)
BallChamsBackup = {}
BallTab:Toggle({ Title = "𝙱𝙰𝙻𝙻 𝙲𝙷𝙰𝙼𝚂", Value = false, Callback = function(v)
    BallChamsEnabled = v
    if not v then
        for ball, data in pairs(BallChamsBackup) do
            if ball and ball.Parent then
                pcall(function() ball.Color = data.Color; ball.Material = data.Material; ball.Transparency = data.Transparency end)
            end
        end
        BallChamsBackup = {}
    end
end })
BallTab:Colorpicker({ Title = "𝙲𝙾𝚁 𝙳𝙾 𝙲𝙷𝙰𝙼𝚂", Default = Color3.fromRGB(255, 50, 50), Callback = function(c) BallChamsColor = c end })

spawn(function()
    while true do
        task.wait(0.1)
        if BallChamsEnabled then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if IsBall(obj) then
                    if not BallChamsBackup[obj] then
                        BallChamsBackup[obj] = {Color = obj.Color, Material = obj.Material, Transparency = obj.Transparency}
                    end
                    pcall(function()
                        obj.Color = BallChamsColor
                        obj.Material = Enum.Material.ForceField
                        obj.Transparency = 0
                    end)
                end
            end
        end
    end
end)

BallTab:Section({ Title = "𝙿𝚁𝙴𝙳𝙸𝙲𝙰𝙾 𝙳𝙰 𝙱𝙰𝙻𝙻" })
PredictionEnabled = false
PredictionLength = 50
PredictionColor = Color3.fromRGB(0, 200, 255)
PredictionPart, PredictionAttachA, PredictionAttachB, PredictionBeam = nil, nil, nil, nil

function CriarPrediction()
    if PredictionPart then PredictionPart:Destroy() end
    if PredictionBeam then PredictionBeam:Destroy() end
    PredictionPart = Instance.new("Part")
    PredictionPart.Name = "Manic_Prediction"
    PredictionPart.Size = Vector3.new(1, 1, 1)
    PredictionPart.Transparency = 1
    PredictionPart.CanCollide = false; PredictionPart.CanQuery = false
    PredictionPart.CanTouch = false; PredictionPart.Anchored = true
    PredictionPart.Parent = Workspace
    PredictionAttachA = Instance.new("Attachment", PredictionPart); PredictionAttachA.Name = "Manic_PredA"
    PredictionAttachB = Instance.new("Attachment", PredictionPart); PredictionAttachB.Name = "Manic_PredB"
    PredictionBeam = Instance.new("Beam")
    PredictionBeam.Name = "Manic_PredBeam"
    PredictionBeam.Attachment0 = PredictionAttachA; PredictionBeam.Attachment1 = PredictionAttachB
    PredictionBeam.Color = ColorSequence.new(PredictionColor)
    PredictionBeam.Width0 = 0.4; PredictionBeam.Width1 = 0.4
    PredictionBeam.FaceCamera = true; PredictionBeam.LightEmission = 1
    PredictionBeam.Transparency = NumberSequence.new(0)
    PredictionBeam.Parent = PredictionPart
end

BallTab:Toggle({ Title = "𝟹𝙳 𝙿𝚁𝙴𝙳𝙸𝙲𝙰𝙾 𝙻𝙸𝙽𝙴", Value = false, Callback = function(v)
    PredictionEnabled = v
    if v then
        spawn(function()
            while PredictionEnabled do
                task.wait(0.03)
                local ball = GetValidBall()
                if not ball or not ball.Parent then
                    if PredictionBeam then PredictionBeam.Enabled = false end
                    continue
                end
                if not PredictionBeam or not PredictionBeam.Parent then CriarPrediction() end
                local vel = ball.AssemblyLinearVelocity
                if vel.Magnitude < 1 then PredictionBeam.Enabled = false; continue end
                local posFutura = ball.Position + vel.Unit * PredictionLength
                PredictionPart.CFrame = CFrame.new(ball.Position, posFutura)
                PredictionAttachA.Position = Vector3.new(0, 0, -PredictionLength / 2)
                PredictionAttachB.Position = Vector3.new(0, 0, PredictionLength / 2)
                PredictionBeam.Enabled = true
            end
        end)
    else
        if PredictionBeam then PredictionBeam.Enabled = false end
    end
end })
BallTab:Slider({Title = "𝙲𝙾𝙼𝙿𝚁𝙸𝙼𝙴𝙽𝚃𝙾", Value = {Min = 10, Max = 200, Default = 50}, Callback = function(v) PredictionLength = v end})
BallTab:Colorpicker({Title = "𝙲𝙾𝚁", Default = Color3.fromRGB(0, 200, 255), Callback = function(c)
    PredictionColor = c
    if PredictionBeam then PredictionBeam.Color = ColorSequence.new(c) end
end})

BallTab:Section({ Title = "𝚃𝙴𝙻𝙴𝙿𝙾𝚁𝚃𝙰𝚁 𝙱𝙰𝙻𝙻" })
TPBallPosEnabled = false
TPBallPosition = Vector3.new(-56, 1194, -281)
BallTab:Toggle({Title = "𝚃𝙿 𝙱𝙰𝙻𝙻 𝚃𝙾 𝙿𝙾𝚂𝙸𝚃𝙸𝙾𝙽", Value = false, Callback = function(v)
    TPBallPosEnabled = v
    if v then
        spawn(function()
            while TPBallPosEnabled do
                task.wait(0.05)
                local ball = GetValidBall()
                if ball and RootPart and (RootPart.Position - ball.Position).Magnitude < 5 then
                    pcall(function()
                        ball.CFrame = CFrame.new(TPBallPosition)
                        ball.AssemblyLinearVelocity = Vector3.zero
                        ball.AssemblyAngularVelocity = Vector3.zero
                    end)
                    TPBallPosEnabled = false
                end
            end
        end)
    end
end})
BallTab:Input({Title = "𝚇", Placeholder = "-56", Callback = function(t) local n = tonumber(t); if n then TPBallPosition = Vector3.new(n, TPBallPosition.Y, TPBallPosition.Z) end end})
BallTab:Input({Title = "𝚈", Placeholder = "1194", Callback = function(t) local n = tonumber(t); if n then TPBallPosition = Vector3.new(TPBallPosition.X, n, TPBallPosition.Z) end end})
BallTab:Input({Title = "𝚉", Placeholder = "-281", Callback = function(t) local n = tonumber(t); if n then TPBallPosition = Vector3.new(TPBallPosition.X, TPBallPosition.Y, n) end end})
BallTab:Button({Title = "𝚄𝚂𝙰𝚁 𝙼𝙸𝙽𝙷𝙰 𝙿𝙾𝚂𝙸𝙲𝙰𝙾", Callback = function()
    if RootPart then TPBallPosition = RootPart.Position
        pcall(function() WindUI:Notify({Title = "𝙱𝙰𝙻𝙻", Content = "𝙿𝙾𝚂𝙸𝙲𝙰𝙾 𝙳𝙴𝙵𝙸𝙽𝙸𝙳𝙰", Duration = 2}) end) end
end})

TPToBallEnabled = false
BallTab:Toggle({Title = "𝚃𝙿 𝚃𝙾 𝙱𝙰𝙻𝙻", Value = false, Callback = function(v)
    TPToBallEnabled = v
    if v then
        spawn(function()
            while TPToBallEnabled do
                task.wait(0.05)
                local ball = GetValidBall()
                if ball and Character then
                    pcall(function() Character:PivotTo(CFrame.new(ball.Position + Vector3.new(0, 5, 0))) end)
                end
            end
        end)
    end
end})

BallTab:Section({ Title = "𝙲𝚄𝚁𝚅𝙰 𝙳𝙰 𝙱𝙰𝙻𝙻" })
CurvePresets = {
    ["None"] = {side = "None", dip = false, cPower = 0, dPower = 0},
    ["Curve Esquerda"] = {side = "Left", dip = true, cPower = 60, dPower = 20},
    ["Curve Direita"] = {side = "Right", dip = false, cPower = 80, dPower = 0},
}
CurveState = {Side = "None", Dip = false, CPower = 0, DPower = 0, Active = false}
BallTab:Dropdown({Title = "𝚃𝙸𝙿𝙾 𝙳𝙴 𝙲𝚄𝚁𝚅𝙰", Values = {"None", "Curve Esquerda", "Curve Direita"}, Value = "None",
    Callback = function(o)
        local p = CurvePresets[o]; if not p then return end
        CurveState.Side = p.side; CurveState.Dip = p.dip
        CurveState.CPower = p.cPower; CurveState.DPower = p.dPower
        CurveState.Active = (o ~= "None")
    end})

RunService.Heartbeat:Connect(function()
    if not CurveState.Active then return end
    local ball = GetValidBall()
    if not ball or not ball:IsA("BasePart") then return end
    local vel = ball.AssemblyLinearVelocity
    if vel.Magnitude <= 15 then return end
    local force = Vector3.zero
    local flat = Vector3.new(vel.X, 0, vel.Z)
    if CurveState.Side ~= "None" and flat.Magnitude > 2 then
        local cross = flat:Cross(Vector3.yAxis).Unit
        if CurveState.Side == "Left" then cross = -cross end
        force = force + cross * (CurveState.CPower / 180)
    end
    if CurveState.Dip then force = force + Vector3.new(0, -(CurveState.DPower / 180), 0) end
    pcall(function() ball.AssemblyLinearVelocity = vel + force end)
end)

BallTab:Section({ Title = "𝙱𝙾𝚃𝙰𝙾 𝙵𝙻𝚄𝚃𝚄𝙰𝙽𝚃𝙴" })
FloatGui, FloatBtn, FloatLocked = nil, nil, false
DragStart, StartPos, Moved = nil, nil, false

function AtualizarTextoBotao()
    if not FloatBtn then return end
    if State.AutoBall then
        FloatBtn.Text = "𝚂𝙴𝙶𝚄𝙸𝚁:𝙾𝙽"; FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 60)
    else
        FloatBtn.Text = "𝚂𝙴𝙶𝚄𝙸𝚁:𝙾𝙵𝙵"; FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 90, 50)
    end
end

function CriarFloatBtn()
    if FloatGui then FloatGui:Destroy() end
    FloatGui = Instance.new("ScreenGui")
    FloatGui.Name = "ManicFloat"; FloatGui.ResetOnSpawn = false
    FloatGui.IgnoreGuiInset = true
    pcall(function() FloatGui.Parent = (gethui and gethui()) or CoreGui end)
    FloatBtn = Instance.new("TextButton")
    FloatBtn.Size = UDim2.new(0, 110, 0, 110)
    FloatBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
    FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 60)
    FloatBtn.Text = "𝚂𝙴𝙶𝚄𝙸𝚁:𝙾𝙵𝙵"
    FloatBtn.TextSize = 16; FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FloatBtn.Font = Enum.Font.GothamBold; FloatBtn.BorderSizePixel = 0
    FloatBtn.AutoButtonColor = false; FloatBtn.Active = true
    FloatBtn.Parent = FloatGui
    Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 12)
    local s = Instance.new("UIStroke", FloatBtn); s.Color = Color3.fromRGB(0, 0, 0); s.Thickness = 4
    AtualizarTextoBotao()

    FloatBtn.InputBegan:Connect(function(input)
        if FloatLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            DragStart = input.Position; StartPos = FloatBtn.Position; Moved = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if DragStart and not FloatLocked then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local d = input.Position - DragStart
                if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then Moved = true end
                FloatBtn.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + d.X, StartPos.Y.Scale, StartPos.Y.Offset + d.Y)
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            DragStart = nil
            if not Moved then
                State.AutoBall = not State.AutoBall
                if State.AutoBall then StartAutoBall() else StopAutoBall() end
                AtualizarTextoBotao()
            end
        end
    end)
end

BallTab:Toggle({Title = "𝙼𝙾𝚂𝚃𝚁𝙰𝚁 𝙱𝙾𝚃𝙰𝙾 𝙵𝙻𝚄𝚃𝚄𝙰𝙽𝚃𝙴", Value = false, Callback = function(v)
    if v then if not FloatBtn then CriarFloatBtn() end; FloatBtn.Visible = true; AtualizarTextoBotao()
    elseif FloatBtn then FloatBtn.Visible = false end
end})
BallTab:Toggle({Title = "𝚃𝚁𝙰𝚅𝙰𝚁 𝙱𝙾𝚃𝙰𝙾", Value = false, Callback = function(v) FloatLocked = v end})
BallTab:Button({Title = "𝚁𝙴𝙲𝚁𝙸𝙰𝚁 𝙱𝙾𝚃𝙰𝙾", Callback = function()
    if FloatBtn then CriarFloatBtn(); FloatBtn.Visible = true end
end})

spawn(function() while true do task.wait(0.2); if FloatBtn then AtualizarTextoBotao() end end end)--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | PARTE 4/9 — Player ]]

PlayerTab = Window:Tab({ Title = "𝙿𝙻𝙰𝚈𝙴𝚁", Icon = "user" })

PlayerTab:Section({ Title = "𝚅𝙴𝙻𝙾𝙲𝙸𝙳𝙰𝙳𝙴 (𝙰𝙽𝚃𝙸-𝙱𝙰𝙽)" })
SpeedEnabled = false
SpeedValue = 24
SpeedJitter = true

PlayerTab:Toggle({Title = "𝙰𝚃𝙸𝚅𝙰𝚁 𝚅𝙴𝙻𝙾𝙲𝙸𝙳𝙰𝙳𝙴", Desc = "𝙰𝙽𝚃𝙸-𝙱𝙰𝙽", Value = false, Callback = function(v) SpeedEnabled = v end})
PlayerTab:Slider({Title = "𝚅𝙴𝙻𝙾𝙲𝙸𝙳𝙰𝙳𝙴", Value = {Min = 16, Max = 60, Default = 24}, Callback = function(v) SpeedValue = v end})
PlayerTab:Toggle({Title = "𝙹𝙸𝚃𝚃𝙴𝚁 𝙽𝙰𝚃𝚄𝚁𝙰𝙻", Value = true, Callback = function(v) SpeedJitter = v end})

RunService.Heartbeat:Connect(function(dt)
    if not SpeedEnabled then return end
    if not Humanoid or not RootPart or not RootPart.Parent then return end
    if Humanoid.Health <= 0 or Humanoid.Sit or Humanoid.SeatPart then return end
    local moveDir = Humanoid.MoveDirection
    if moveDir.Magnitude < 0.05 then return end
    local state = Humanoid:GetState()
    if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping
    or state == Enum.HumanoidStateType.Swimming then return end
    local jitter = SpeedJitter and (math.random(-30, 30) / 100) or 0
    local finalSpeed = SpeedValue + jitter
    local currentVel = RootPart.AssemblyLinearVelocity
    local target = moveDir.Unit * finalSpeed
    local newHoriz = Vector3.new(currentVel.X, 0, currentVel.Z):Lerp(target, math.clamp(dt * 15, 0, 1))
    RootPart.AssemblyLinearVelocity = Vector3.new(newHoriz.X, currentVel.Y, newHoriz.Z)
end)

PlayerTab:Section({ Title = "𝚃𝚁𝙰𝙸𝙻 𝙳𝙾 𝙹𝙾𝙶𝙰𝙳𝙾𝚁" })
TrailObj = nil
TrailColorP = Color3.fromRGB(120, 90, 240)
function CriarTrail()
    if TrailObj then TrailObj:Destroy() end
    if not Character then return end
    local hrp = Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local a0 = Instance.new("Attachment", hrp); a0.Name = "ManicTrailA0"; a0.Position = Vector3.new(0, 1, 0)
    local a1 = Instance.new("Attachment", hrp); a1.Name = "ManicTrailA1"; a1.Position = Vector3.new(0, -1, 0)
    TrailObj = Instance.new("Trail")
    TrailObj.Name = "ManicTrail"
    TrailObj.Attachment0 = a0; TrailObj.Attachment1 = a1
    TrailObj.Color = ColorSequence.new(TrailColorP)
    TrailObj.Lifetime = 1; TrailObj.MinLength = 0.1
    TrailObj.WidthScale = NumberSequence.new(0.5)
    TrailObj.Parent = hrp
end
PlayerTab:Toggle({Title = "𝚃𝚁𝙰𝙸𝙻 𝙽𝙾 𝙹𝙾𝙶𝙰𝙳𝙾𝚁", Value = false, Callback = function(v)
    State.Trail = v
    if v then CriarTrail() elseif TrailObj then TrailObj:Destroy(); TrailObj = nil end
end})
PlayerTab:Colorpicker({Title = "𝙲𝙾𝚁 𝙳𝙾 𝚃𝚁𝙰𝙸𝙻", Default = TrailColorP, Callback = function(c)
    TrailColorP = c
    if TrailObj then TrailObj.Color = ColorSequence.new(c) end
end})
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); if State.Trail then CriarTrail() end end)

PlayerTab:Section({ Title = "𝚃𝙴𝙻𝙰 𝙴𝚂𝚃𝙸𝙲𝙰𝙳𝙰" })
StretchHConn, StretchVConn = nil, nil
PlayerTab:Toggle({Title = "𝙴𝚂𝚃𝙸𝙲𝙰𝚁 𝙷𝙾𝚁𝙸𝚉𝙾𝙽𝚃𝙰𝙻", Value = false, Callback = function(v)
    State.StretchH = v
    if v then
        if StretchHConn then StretchHConn:Disconnect() end
        local cam = Workspace.CurrentCamera
        StretchHConn = RunService.RenderStepped:Connect(function()
            cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 0.75, 0, 0, 0, 1, 0, 0, 0, 1)
        end)
    elseif StretchHConn then StretchHConn:Disconnect(); StretchHConn = nil end
end})
PlayerTab:Toggle({Title = "𝙴𝚂𝚃𝙸𝙲𝙰𝚁 𝚅𝙴𝚁𝚃𝙸𝙲𝙰𝙻", Value = false, Callback = function(v)
    State.StretchV = v
    if v then
        if StretchVConn then StretchVConn:Disconnect() end
        local cam = Workspace.CurrentCamera
        StretchVConn = RunService.RenderStepped:Connect(function()
            cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.67, 0, 0, 0, 1)
        end)
    elseif StretchVConn then StretchVConn:Disconnect(); StretchVConn = nil end
end})

PlayerTab:Section({ Title = "𝙲𝙾𝚁 𝙳𝙰 𝚃𝙴𝙻𝙰" })
ScreenColorEnabled = false
ScreenColorTint = Color3.fromRGB(255, 255, 255)
ScreenColorSaturation = 0
ScreenColorContrast = 0
ScreenColorBrightness = 0
ScreenColorEffect = nil
function AplicarScreenColor()
    if ScreenColorEffect then ScreenColorEffect:Destroy(); ScreenColorEffect = nil end
    if not ScreenColorEnabled then return end
    ScreenColorEffect = Instance.new("ColorCorrectionEffect")
    ScreenColorEffect.Name = "Manic_ScreenColor"
    ScreenColorEffect.TintColor = ScreenColorTint
    ScreenColorEffect.Saturation = ScreenColorSaturation
    ScreenColorEffect.Contrast = ScreenColorContrast
    ScreenColorEffect.Brightness = ScreenColorBrightness
    ScreenColorEffect.Parent = Lighting
end
PlayerTab:Toggle({Title = "𝙰𝚃𝙸𝚅𝙰𝚁 𝙲𝙾𝚁 𝙳𝙰 𝚃𝙴𝙻𝙰", Value = false, Callback = function(v) ScreenColorEnabled = v; AplicarScreenColor() end})
PlayerTab:Colorpicker({Title = "𝙲𝙾𝚁", Default = Color3.fromRGB(255, 255, 255), Callback = function(c)
    ScreenColorTint = c; if ScreenColorEffect then ScreenColorEffect.TintColor = c end
end})
PlayerTab:Slider({Title = "𝚂𝙰𝚃𝚄𝚁𝙰𝙲𝙰𝙾", Value = {Min = -100, Max = 100, Default = 0}, Callback = function(v)
    ScreenColorSaturation = v / 100; if ScreenColorEffect then ScreenColorEffect.Saturation = ScreenColorSaturation end
end})
PlayerTab:Slider({Title = "𝙲𝙾𝙽𝚃𝚁𝙰𝚂𝚃𝙴", Value = {Min = -100, Max = 100, Default = 0}, Callback = function(v)
    ScreenColorContrast = v / 100; if ScreenColorEffect then ScreenColorEffect.Contrast = ScreenColorContrast end
end})
PlayerTab:Slider({Title = "𝙱𝚁𝙸𝙻𝙷𝙾", Value = {Min = -100, Max = 100, Default = 0}, Callback = function(v)
    ScreenColorBrightness = v / 100; if ScreenColorEffect then ScreenColorEffect.Brightness = ScreenColorBrightness end
end})
PlayerTab:Button({Title = "𝚁𝙴𝚂𝚃𝙰𝚄𝚁𝙰𝚁 𝙲𝙾𝚁", Callback = function()
    if ScreenColorEffect then ScreenColorEffect:Destroy(); ScreenColorEffect = nil end
    ScreenColorEnabled = false
end})

ScreenInvertEnabled = false
ScreenInvertEffect = nil
function AplicarScreenInvert()
    if ScreenInvertEffect then ScreenInvertEffect:Destroy(); ScreenInvertEffect = nil end
    if not ScreenInvertEnabled then return end
    ScreenInvertEffect = Instance.new("ColorCorrectionEffect")
    ScreenInvertEffect.Name = "Manic_ScreenInvert"
    ScreenInvertEffect.TintColor = Color3.fromRGB(0, 0, 0)
    ScreenInvertEffect.Saturation = -1
    ScreenInvertEffect.Contrast = -1
    ScreenInvertEffect.Brightness = -0.3
    ScreenInvertEffect.Parent = Lighting
end
PlayerTab:Toggle({Title = "𝙸𝙽𝚅𝙴𝚁𝚃𝙴𝚁 𝙲𝙾𝚁 𝙳𝙰 𝚃𝙴𝙻𝙰", Desc = "𝙼𝙾𝙳𝙾 𝙴𝚂𝙲𝚄𝚁𝙾", Value = false, Callback = function(v)
    ScreenInvertEnabled = v; AplicarScreenInvert()
end})

PlayerTab:Section({ Title = "𝙰𝚄𝚃𝙾 𝚂𝙺𝙸𝙻𝙻" })
AutoSkillEnabled = false
SkillSpeed = 5
SkillStep = 0
SkillPhase = 0
SkillRange = 3
PlayerTab:Toggle({Title = "𝙰𝚄𝚃𝙾 𝚂𝙺𝙸𝙻𝙻", Value = false, Callback = function(v)
    AutoSkillEnabled = v
    if not v then SkillPhase = 0; SkillStep = 0 end
end})
PlayerTab:Slider({Title = "𝚅𝙴𝙻𝙾𝙲𝙸𝙳𝙰𝙳𝙴", Value = {Min = 1, Max = 10, Default = 5}, Callback = function(v) SkillSpeed = v end})
PlayerTab:Slider({Title = "𝙰𝙻𝙲𝙰𝙽𝙲𝙴", Value = {Min = 1, Max = 10, Default = 3}, Callback = function(v) SkillRange = v end})
RunService.Heartbeat:Connect(function()
    if not AutoSkillEnabled then return end
    if not Character or not RootPart or not Humanoid then return end
    local ball = GetValidBall()
    if not ball or (ball.Position - RootPart.Position).Magnitude > SkillRange + 2 then return end
    SkillPhase = SkillPhase + 0.016 * SkillSpeed
    if SkillPhase >= 1 then SkillPhase = 0; SkillStep = (SkillStep + 1) % 4 end
    local dir
    if SkillStep == 0 then dir = RootPart.CFrame.LookVector
    elseif SkillStep == 1 then dir = RootPart.CFrame.RightVector
    elseif SkillStep == 2 then dir = -RootPart.CFrame.RightVector
    else dir = -RootPart.CFrame.LookVector end
    local offset = dir * math.sin(SkillPhase * math.pi) * 2
    local targetPos = RootPart.Position + offset + Vector3.new(0, -1.5, 0)
    pcall(function()
        ball.CFrame = CFrame.new(ball.Position:Lerp(targetPos, 0.3), ball.Position)
        ball.AssemblyLinearVelocity = Vector3.zero
        ball.AssemblyAngularVelocity = Vector3.zero
    end)
end)

PlayerTab:Section({ Title = "𝙰𝚄𝚃𝙾 𝙵𝙾𝙻𝙻𝙾𝚆" })
AutoFollowEnabled = false
AutoFollowKey = Enum.KeyCode.K
AutoFollowStopDist = 1.8
KeyMap = {
    Q=Enum.KeyCode.Q,W=Enum.KeyCode.W,E=Enum.KeyCode.E,R=Enum.KeyCode.R,T=Enum.KeyCode.T,
    Y=Enum.KeyCode.Y,U=Enum.KeyCode.U,I=Enum.KeyCode.I,O=Enum.KeyCode.O,P=Enum.KeyCode.P,
    A=Enum.KeyCode.A,S=Enum.KeyCode.S,D=Enum.KeyCode.D,F=Enum.KeyCode.F,G=Enum.KeyCode.G,
    H=Enum.KeyCode.H,J=Enum.KeyCode.J,K=Enum.KeyCode.K,L=Enum.KeyCode.L,Z=Enum.KeyCode.Z,
    X=Enum.KeyCode.X,C=Enum.KeyCode.C,V=Enum.KeyCode.V,B=Enum.KeyCode.B,N=Enum.KeyCode.N,M=Enum.KeyCode.M,
}
function IsMoving()
    return UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.A)
        or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)
end
RunService.RenderStepped:Connect(function()
    if not AutoFollowEnabled then return end
    if not RootPart or not RootPart.Parent or not Humanoid then return end
    if IsMoving() then return end
    local ball = GetValidBall(); if not ball then return end
    local delta = ball.Position - RootPart.Position
    local flat = Vector3.new(delta.X, 0, delta.Z)
    if flat.Magnitude > AutoFollowStopDist and flat.Magnitude < 150 then
        Humanoid:Move(flat.Unit, false)
        RootPart.CFrame = CFrame.new(RootPart.Position, Vector3.new(ball.Position.X, RootPart.Position.Y, ball.Position.Z))
    else Humanoid:Move(Vector3.zero, false) end
end)
PlayerTab:Toggle({Title = "𝙰𝚄𝚃𝙾 𝙵𝙾𝙻𝙻𝙾𝚆", Desc = "𝙺𝙴𝚈: 𝙺", Value = false, Callback = function(v)
    AutoFollowEnabled = v
    if not v and Humanoid then Humanoid:Move(Vector3.zero, false) end
end})
PlayerTab:Input({Title = "𝙺𝙴𝚈𝙱𝙸𝙽𝙳", Placeholder = "𝙺", Callback = function(text)
    local clean = text:gsub("%s+", ""); if clean == "" then return end
    local key = KeyMap[clean] or Enum.KeyCode[clean]
    if key then AutoFollowKey = key; pcall(function() WindUI:Notify({Title = "𝙺𝙴𝚈𝙱𝙸𝙽𝙳", Content = "𝙵𝙾𝙻𝙻𝙾𝚆: " .. clean, Duration = 2}) end) end
end})
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == AutoFollowKey then
        AutoFollowEnabled = not AutoFollowEnabled
        if not AutoFollowEnabled and Humanoid then Humanoid:Move(Vector3.zero, false) end
    end
end)

PlayerTab:Section({ Title = "𝙲𝙾𝙽𝚃𝚁𝙾𝙻 𝙱𝙰𝙻𝙻" })
ControlBallEnabled = false
ControllingBall = false
ControlledBall = nil
ControlRenderConn, ControlInputConn = nil, nil
ControlBallSpeed = 70
ControlCameraDistance = 16
ControlCameraHeight = 6
ControlMouseSens = 0.004
ControlCameraYaw = 0
ControlCameraPitch = 0.2
SavedCameraType, SavedCameraSubject = nil, nil
ControlKey = Enum.KeyCode.U

function StopControl()
    ControllingBall = false
    if ControlRenderConn then ControlRenderConn:Disconnect(); ControlRenderConn = nil end
    if ControlInputConn then ControlInputConn:Disconnect(); ControlInputConn = nil end
    if SavedCameraType and SavedCameraSubject then
        local cam = Workspace.CurrentCamera
        cam.CameraType = SavedCameraType; cam.CameraSubject = SavedCameraSubject
    end
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    ControlledBall = nil
end
function StartControl(ball)
    if ControlRenderConn then ControlRenderConn:Disconnect() end
    if ControlInputConn then ControlInputConn:Disconnect() end
    if ball:IsA("Model") then ball = ball.PrimaryPart or ball:FindFirstChildWhichIsA("BasePart") end
    if not ball or not ball:IsA("BasePart") then StopControl() return end
    ControlledBall = ball; ControllingBall = true
    local cam = Workspace.CurrentCamera
    SavedCameraType = cam.CameraType; SavedCameraSubject = cam.CameraSubject
    local look = cam.CFrame.LookVector
    ControlCameraYaw = math.atan2(-look.X, -look.Z)
    ControlCameraPitch = math.asin(math.clamp(look.Y, -1, 1))
    cam.CameraType = Enum.CameraType.Scriptable
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    ControlInputConn = UserInputService.InputChanged:Connect(function(i)
        if not ControllingBall then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            ControlCameraYaw = ControlCameraYaw - i.Delta.X * ControlMouseSens
            ControlCameraPitch = math.clamp(ControlCameraPitch - i.Delta.Y * ControlMouseSens, -1.2, 1.2)
        elseif i.UserInputType == Enum.UserInputType.Touch then
            ControlCameraYaw = ControlCameraYaw - i.Delta.X * 0.006
            ControlCameraPitch = math.clamp(ControlCameraPitch - i.Delta.Y * 0.006, -1.2, 1.2)
        end
    end)
    ControlRenderConn = RunService.RenderStepped:Connect(function()
        if not ControllingBall or not ControlledBall or not ControlledBall.Parent then StopControl(); return end
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        local dir = CFrame.fromEulerAnglesYXZ(ControlCameraPitch, ControlCameraYaw, 0).LookVector
        pcall(function()
            ControlledBall.AssemblyLinearVelocity = dir * ControlBallSpeed
            ControlledBall.AssemblyAngularVelocity = Vector3.zero
        end)
        local camPos = ControlledBall.Position - dir * ControlCameraDistance + Vector3.new(0, ControlCameraHeight, 0)
        Workspace.CurrentCamera.CFrame = CFrame.lookAt(camPos, ControlledBall.Position + Vector3.new(0, 1.5, 0))
    end)
end
PlayerTab:Toggle({Title = "𝙲𝙾𝙽𝚃𝚁𝙾𝙻 𝙱𝙰𝙻𝙻", Desc = "𝙺𝙴𝚈: 𝚄", Value = false, Callback = function(v)
    ControlBallEnabled = v
    if not v and ControllingBall then StopControl() end
end})
PlayerTab:Slider({Title = "𝚅𝙴𝙻𝙾𝙲𝙸𝙳𝙰𝙳𝙴 𝙳𝙰 𝙱𝙰𝙻𝙻", Value = {Min = 10, Max = 200, Default = 70}, Callback = function(v) ControlBallSpeed = v end})
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == ControlKey and ControlBallEnabled then
        if ControllingBall then StopControl() else
            local ball = GetValidBall(); if ball then StartControl(ball) end
        end
    end
end)--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | PARTE 5/9 — Chars + AC + Reach ]]

CharsTab = Window:Tab({ Title = "𝙲𝙷𝙰𝚁𝚂", Icon = "users" })
CharsTab:Section({ Title = "𝙲𝙷𝙰𝚁𝚂" })
CharsList = {
    "oxentepivetih77","RB9844","FearZakk","pachowillian","DavskCbm9","6unfire","mikaelfacada10","guto785662",
    "orieehrjr","beastsxc","candyxzzz0","polarnyp","kayquealt1106","Skxgoat7","KingOfKitsunezx","slk_eosouzax",
    "defantastico","hyago_mach","mica1203ely5","b_2020f","bernadow_w","ythek9on1","Samblox_Xd","3qu",
    "021_KayqueJr","monalisopitango","a4rloo","Ilulict","m3mbers0nly","19_Nxx","Juninhojwve","ensixraa",
    "keny_tcs","MSS10_ALT1",
}
function SendChar(nome)
    pcall(function()
        local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if ch then ch:SendAsync(":char " .. nome) end
    end)
    pcall(function()
        ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(":char " .. nome, "All")
    end)
end
for _, char in ipairs(CharsList) do
    CharsTab:Button({ Title = char, Callback = function()
        SendChar(char); pcall(function() WindUI:Notify({Title = "𝙲𝙷𝙰𝚁", Content = char, Duration = 2}) end)
    end })
end

ACTab = Window:Tab({ Title = "𝙰𝙲", Icon = "shield" })
ACTab:Section({ Title = "𝙰𝚄𝚃𝙾 𝙲𝙰𝚃𝙲𝙷" })
CatchRemote = nil
pcall(function()
    for _, name in ipairs({"CatchBall", "Catch", "AutoCatch", "Grab"}) do
        local r = ReplicatedStorage:FindFirstChild(name, true)
        if r then CatchRemote = r break end
    end
end)
AutoCatchLast = 0
AutoCatchRange = 8
AutoCatchDelay = 0.8
AC_Hitbox = false
AC_HitboxPart = nil
function DoAutoCatch(ball)
    if not State.AutoCatch then return end
    if os.clock() < AutoCatchLast then return end
    if not ball or not ball.Parent then return end
    local _, hum, root = GetCharacterData(); if not hum or not root then return end
    if (ball.Position - root.Position).Magnitude > AutoCatchRange then return end
    if CatchRemote then
        pcall(function()
            if CatchRemote:IsA("RemoteEvent") then CatchRemote:FireServer(ball)
            elseif CatchRemote:IsA("RemoteFunction") then CatchRemote:InvokeServer(ball) end
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
ACTab:Toggle({Title = "𝙰𝚄𝚃𝙾 𝙲𝙰𝚃𝙲𝙷", Value = false, Callback = function(v) State.AutoCatch = v end})
ACTab:Slider({Title = "𝙰𝙻𝙲𝙰𝙽𝙲𝙴", Value = {Min = 3, Max = 30, Default = 8}, Callback = function(v) AutoCatchRange = v end})
ACTab:Slider({Title = "𝙲𝙾𝙾𝙻𝙳𝙾𝚆𝙽", Value = {Min = 2, Max = 30, Default = 8, Suffix = " 𝚇𝟶.𝟷𝚂"}, Callback = function(v) AutoCatchDelay = v / 10 end})
ACTab:Toggle({Title = "𝙼𝙾𝚂𝚃𝚁𝙰𝚁 𝙷𝙸𝚃𝙱𝙾𝚇", Value = false, Callback = function(v) AC_Hitbox = v end})

RunService.Heartbeat:Connect(function()
    if State.AutoCatch then
        local ball = CurrentFollowBall or FindClosestBall()
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
            AC_HitboxPart.CanCollide = false; AC_HitboxPart.CanQuery = false
            AC_HitboxPart.CanTouch = false; AC_HitboxPart.Anchored = true
            AC_HitboxPart.Parent = Workspace
        end
        AC_HitboxPart.Size = Vector3.new(d, d, d)
        AC_HitboxPart.Position = RootPart.Position
    elseif AC_HitboxPart and AC_HitboxPart.Parent then
        AC_HitboxPart:Destroy(); AC_HitboxPart = nil
    end
end)

ACTab:Section({ Title = "𝚁𝙴𝙰𝙲𝙷" })
ReachLast = 0
ReachVisualEnabled = false
ReachVisualBox, ReachSelectionBox = nil, nil
function CriarReachVisual()
    if ReachVisualBox then ReachVisualBox:Destroy() end
    ReachVisualBox = Instance.new("Part")
    ReachVisualBox.Name = "Manic_ReachVisual"
    ReachVisualBox.Size = Vector3.new(1, 1, 1)
    ReachVisualBox.Transparency = 1
    ReachVisualBox.CanCollide = false; ReachVisualBox.CanQuery = false
    ReachVisualBox.CanTouch = false; ReachVisualBox.Anchored = true
    ReachVisualBox.Parent = Workspace
    ReachSelectionBox = Instance.new("SelectionBox")
    ReachSelectionBox.Adornee = ReachVisualBox
    ReachSelectionBox.Color3 = Color3.fromRGB(0, 255, 0)
    ReachSelectionBox.LineThickness = 0.05
    ReachSelectionBox.Transparency = 0.5
    ReachSelectionBox.SurfaceTransparency = 0.9
    ReachSelectionBox.Visible = false
    ReachSelectionBox.Parent = ReachVisualBox
end
ACTab:Toggle({Title = "𝙰𝚃𝙸𝚅𝙰𝚁 𝚁𝙴𝙰𝙲𝙷", Value = false, Callback = function(v) State.Reach = v end})
ACTab:Slider({Title = "𝙳𝙸𝚂𝚃𝙰𝙽𝙲𝙸𝙰", Value = {Min = 1, Max = 50, Default = 10}, Callback = function(v) State.ReachDistance = v end})
ACTab:Toggle({Title = "𝚅𝙸𝚂𝚄𝙰𝙻 𝙳𝙾 𝚁𝙴𝙰𝙲𝙷", Value = false, Callback = function(v)
    ReachVisualEnabled = v
    if v then if not ReachVisualBox then CriarReachVisual() end
    elseif ReachSelectionBox then ReachSelectionBox.Visible = false end
end})

RunService.Heartbeat:Connect(function()
    if not State.Reach then return end
    if not Character or not RootPart then return end
    if os.clock() < ReachLast then return end
    local ball = CurrentFollowBall or FindClosestBall()
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

task.spawn(function()
    while true do
        task.wait(0.05)
        if ReachVisualEnabled and State.Reach then
            if not ReachVisualBox or not ReachVisualBox.Parent then CriarReachVisual() end
            if Character and RootPart then
                local size = State.ReachDistance * 2
                ReachVisualBox.Size = Vector3.new(size, size, size)
                ReachVisualBox.CFrame = RootPart.CFrame
                if ReachSelectionBox then ReachSelectionBox.Visible = true end
            end
        elseif ReachSelectionBox then ReachSelectionBox.Visible = false end
    end
end)--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | PARTE 6/9 — Auto Drive + Sensor ]]

DriveTab = Window:Tab({ Title = "𝙰𝚄𝚃𝙾 𝙳𝚁𝙸𝚅𝙴", Icon = "car" })

GKBotoes = {}

function EscanearBotoesGK()
    GKBotoes = {}
    pcall(function()
        for _, v in ipairs(PlayerGui:GetDescendants()) do
            if v:IsA("TextButton") or v:IsA("ImageButton") then
                local nome = v.Name
                local texto = ""
                pcall(function() texto = v.Text end)
                if nome:find("GK") or nome:find("C2")
                or texto:find("Dive") or texto:find("Catch") or texto:find("High")
                or texto:find("Low") or texto:find("Reflex") or texto:find("Forward")
                or texto:find("Front") or texto:find("Rush") then
                    table.insert(GKBotoes, {Button = v, Nome = nome, Texto = texto})
                end
            end
        end
    end)
end
EscanearBotoesGK()
LocalPlayer.CharacterAdded:Connect(function() task.wait(2); EscanearBotoesGK() end)

function EncontrarBotaoPorTexto(texto)
    for _, info in ipairs(GKBotoes) do
        if info.Texto and info.Texto:lower() == texto:lower() then return info.Button end
    end
    for _, info in ipairs(GKBotoes) do
        if info.Texto and info.Texto:lower():find(texto:lower(), 1, true) then return info.Button end
    end
    return nil
end
function ClicarBotao(botao)
    if not botao then return end
    pcall(function() firesignal(botao.Activated) end)
    pcall(function() firesignal(botao.MouseButton1Click) end)
    pcall(function() firesignal(botao.MouseButton1Down) end)
    pcall(function() firesignal(botao.MouseButton1Up) end)
    pcall(function() firesignal(botao.TouchTap) end)
end

function PredizerTrajetoria(ball, tempoMax)
    if not ball or not ball.Parent then return nil end
    local posInicial = ball.Position
    local velInicial = ball.AssemblyLinearVelocity
    if velInicial.Magnitude < 2 then
        return {posFinal = posInicial, velFinal = velInicial, tempo = 0, alturaMax = posInicial.Y}
    end
    local gravity = Workspace.Gravity
    local pos, vel = posInicial, velInicial
    local dt, tempo = 0.05, 0
    local alturaMax = pos.Y
    while tempo < tempoMax do
        vel = Vector3.new(vel.X, vel.Y - gravity * dt, vel.Z)
        pos = pos + vel * dt
        tempo = tempo + dt
        if pos.Y > alturaMax then alturaMax = pos.Y end
        if pos.Y < -100 then break end
    end
    return {posFinal = pos, velFinal = vel, tempo = tempo, alturaMax = alturaMax}
end

function AnalisarBola()
    local ball = CurrentFollowBall or FindClosestBall()
    if not ball or not RootPart then return nil end
    local vel = ball.AssemblyLinearVelocity
    local dist = (ball.Position - RootPart.Position).Magnitude
    local traj = PredizerTrajetoria(ball, 1.5)
    if not traj then return nil end
    local camRight = Camera.CFrame.RightVector
    local direitaH = Vector3.new(camRight.X, 0, camRight.Z)
    if direitaH.Magnitude < 0.1 then direitaH = Vector3.new(1, 0, 0) end
    direitaH = direitaH.Unit
    local delta = traj.posFinal - RootPart.Position
    local deltaH = Vector3.new(delta.X, 0, delta.Z)
    local lado = deltaH:Dot(direitaH)
    local altura = traj.posFinal.Y - RootPart.Position.Y
    local alturaMax = traj.alturaMax - RootPart.Position.Y
    local dirParaPlayer = RootPart.Position - ball.Position
    local dirH = Vector3.new(dirParaPlayer.X, 0, dirParaPlayer.Z)
    local velH = Vector3.new(vel.X, 0, vel.Z)
    local vindo = false
    if dirH.Magnitude > 0.1 and velH.Magnitude > 0.1 then
        vindo = velH.Unit:Dot(dirH.Unit) > 0.15
    end
    return {ball = ball, vel = vel, dist = dist, lado = lado, altura = altura, alturaMax = alturaMax, vindoParaPlayer = vindo, trajetoria = traj}
end

function EscolherBotaoDefesa(info)
    local ladoAbs = math.abs(info.lado)
    if ladoAbs >= 2.5 then
        if info.altura > 3.5 or info.alturaMax > 5 then
            return info.lado > 0 and "High Dive Right" or "High Dive Left"
        else
            return info.lado > 0 and "Dive Right" or "Dive Left"
        end
    else
        if info.altura > 3.5 or info.alturaMax > 5 then
            return "High Catch", true
        else
            return "Low Catch"
        end
    end
end

AutoDiveEnabled = false
AutoDiveRange = 25
AutoDiveCooldown = 0.6
AutoDiveLast = 0

function ExecutarDive()
    local info = AnalisarBola()
    if not info or not info.vindoParaPlayer then return end
    local texto, pular = EscolherBotaoDefesa(info)
    if not texto then return end
    if pular then
        task.spawn(function()
            pcall(function() Humanoid.Jump = true end)
            pcall(function() Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
        end)
        task.wait(0.05)
    end
    local botao = EncontrarBotaoPorTexto(texto)
    if botao then ClicarBotao(botao) end
end

DriveTab:Section({ Title = "𝙰𝚄𝚃𝙾 𝙳𝚁𝙸𝚅𝙴" })
DriveTab:Toggle({Title = "𝙰𝚃𝙸𝚅𝙰𝚁 𝙰𝚄𝚃𝙾 𝙳𝚁𝙸𝚅𝙴", Value = false, Callback = function(v) AutoDiveEnabled = v end})
DriveTab:Slider({Title = "𝙰𝙻𝙲𝙰𝙽𝙲𝙴", Value = {Min = 5, Max = 50, Default = 25}, Callback = function(v) AutoDiveRange = v end})
DriveTab:Slider({Title = "𝙲𝙾𝙾𝙻𝙳𝙾𝚆𝙽", Value = {Min = 3, Max = 50, Default = 6, Suffix = " 𝚇𝟶.𝟷𝚂"}, Callback = function(v) AutoDiveCooldown = v / 10 end})
DriveTab:Button({Title = "𝚁𝙴𝙴𝚂𝙲𝙰𝙽𝙴𝙰𝚁 𝙱𝙾𝚃𝙾𝙴𝚂 𝙶𝙺", Callback = function()
    EscanearBotoesGK(); pcall(function() WindUI:Notify({Title = "𝙰𝚄𝚃𝙾 𝙳𝚁𝙸𝚅𝙴", Content = #GKBotoes .. " 𝙱𝙾𝚃𝙾𝙴𝚂", Duration = 3}) end)
end})

SensorEnabled = false
SensorVisualEnabled = false
SensorAutoSaveEnabled = false
SensorRange = 80
SensorLast = 0
SensorTargetButton = "Auto"
SensorMoveToIntercept = true
SensorCooldown = 0.4
SensorBeam, SensorPart, SensorAttachA, SensorAttachB, SensorLandingMarker = nil, nil, nil, nil, nil

function CriarSensorVisual()
    if SensorPart then SensorPart:Destroy() end
    if SensorBeam then SensorBeam:Destroy() end
    SensorPart = Instance.new("Part")
    SensorPart.Name = "Manic_SensorBeam"
    SensorPart.Size = Vector3.new(1, 1, 1)
    SensorPart.Transparency = 1
    SensorPart.CanCollide = false; SensorPart.CanQuery = false
    SensorPart.CanTouch = false; SensorPart.Anchored = true
    SensorPart.Parent = Workspace
    SensorAttachA = Instance.new("Attachment", SensorPart); SensorAttachA.Name = "Manic_SensorA"
    SensorAttachB = Instance.new("Attachment", SensorPart); SensorAttachB.Name = "Manic_SensorB"
    SensorBeam = Instance.new("Beam")
    SensorBeam.Attachment0 = SensorAttachA; SensorBeam.Attachment1 = SensorAttachB
    SensorBeam.Color = ColorSequence.new(Color3.fromRGB(255, 200, 0))
    SensorBeam.Width0 = 0.3; SensorBeam.Width1 = 0.3
    SensorBeam.FaceCamera = true; SensorBeam.LightEmission = 1
    SensorBeam.Transparency = NumberSequence.new(0.3)
    SensorBeam.Parent = SensorPart
    if SensorLandingMarker then SensorLandingMarker:Destroy() end
    SensorLandingMarker = Instance.new("Part")
    SensorLandingMarker.Shape = Enum.PartType.Ball
    SensorLandingMarker.Size = Vector3.new(4, 4, 4)
    SensorLandingMarker.Material = Enum.Material.ForceField
    SensorLandingMarker.Color = Color3.fromRGB(255, 200, 0)
    SensorLandingMarker.Transparency = 0.4
    SensorLandingMarker.CanCollide = false; SensorLandingMarker.CanQuery = false
    SensorLandingMarker.CanTouch = false; SensorLandingMarker.Anchored = true
    SensorLandingMarker.Parent = Workspace
end
function DestruirSensorVisual()
    if SensorPart then SensorPart:Destroy(); SensorPart = nil end
    if SensorBeam then SensorBeam:Destroy(); SensorBeam = nil end
    if SensorLandingMarker then SensorLandingMarker:Destroy(); SensorLandingMarker = nil end
end

function ExecutarDefesaSensor()
    local info = AnalisarBola()
    if not info or not info.vindoParaPlayer then return end
    if info.dist > SensorRange or info.vel.Magnitude < 5 then return end
    if tick() - SensorLast < SensorCooldown then return end
    SensorLast = tick()
    if SensorMoveToIntercept and Humanoid then
        local flat = info.trajetoria.posFinal - RootPart.Position
        local flatH = Vector3.new(flat.X, 0, flat.Z)
        if flatH.Magnitude > 1.5 then Humanoid:Move(flatH.Unit, false) end
    end
    local texto, pular
    if SensorTargetButton ~= "Auto" then texto = SensorTargetButton
    else texto, pular = EscolherBotaoDefesa(info) end
    if not texto then return end
    if pular then
        task.spawn(function()
            pcall(function() Humanoid.Jump = true end)
            pcall(function() Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
        end)
        task.wait(0.05)
    end
    local botao = EncontrarBotaoPorTexto(texto)
    if botao then ClicarBotao(botao) end
end

RunService.Heartbeat:Connect(function()
    if not AutoDiveEnabled and not SensorEnabled then return end
    if not RootPart or not RootPart.Parent then return end
    if AutoDiveEnabled and tick() - AutoDiveLast >= AutoDiveCooldown then
        local ball = CurrentFollowBall or FindClosestBall()
        if ball and ball.Parent and (ball.Position - RootPart.Position).Magnitude <= AutoDiveRange then
            AutoDiveLast = tick(); task.spawn(ExecutarDive)
        end
    end
    if SensorEnabled then
        local info = AnalisarBola()
        if info then
            if SensorVisualEnabled then
                if not SensorBeam or not SensorBeam.Parent then CriarSensorVisual() end
                pcall(function()
                    SensorPart.Position = info.ball.Position
                    local dir = info.trajetoria.posFinal - info.ball.Position
                    if dir.Magnitude > 0.1 then SensorPart.CFrame = CFrame.new(info.ball.Position, info.trajetoria.posFinal) end
                    SensorAttachA.Position = Vector3.new(0, 0, 0)
                    SensorAttachB.Position = Vector3.new(0, 0, -dir.Magnitude)
                    SensorLandingMarker.Position = info.trajetoria.posFinal
                end)
            end
            if SensorAutoSaveEnabled then task.spawn(ExecutarDefesaSensor) end
        elseif SensorVisualEnabled then DestruirSensorVisual() end
    elseif SensorVisualEnabled then DestruirSensorVisual() end
end)

DriveTab:Section({ Title = "𝚂𝙴𝙽𝚂𝙾𝚁 + 𝙰𝚄𝚃𝙾 𝚂𝙰𝚅𝙴" })
DriveTab:Toggle({Title = "𝚂𝙴𝙽𝚂𝙾𝚁 𝙳𝙴 𝙱𝙰𝙻𝙻", Value = false, Callback = function(v) SensorEnabled = v; if not v then DestruirSensorVisual() end end})
DriveTab:Toggle({Title = "𝚅𝙸𝚂𝚄𝙰𝙻 𝙳𝙾 𝚂𝙴𝙽𝚂𝙾𝚁", Value = false, Callback = function(v) SensorVisualEnabled = v; if not v then DestruirSensorVisual() end end})
DriveTab:Toggle({Title = "𝙰𝚄𝚃𝙾 𝚂𝙰𝚅𝙴", Value = false, Callback = function(v) SensorAutoSaveEnabled = v end})
DriveTab:Toggle({Title = "𝙼𝙾𝚅𝙴𝚁 𝙿𝙰𝚁𝙰 𝙸𝙽𝚃𝙴𝚁𝙲𝙴𝙿𝚃𝙰𝚁", Value = true, Callback = function(v) SensorMoveToIntercept = v end})
DriveTab:Dropdown({Title = "𝙱𝙾𝚃𝙰𝙾 𝙵𝙸𝚇𝙾", Values = {"Auto", "High Dive Left", "High Dive Right", "Dive Left", "Dive Right", "High Catch", "Low Catch", "Reflex", "Front Dive", "Rush"}, Value = "Auto", Callback = function(v) SensorTargetButton = v end})
DriveTab:Slider({Title = "𝙰𝙻𝙲𝙰𝙽𝙲𝙴 𝙳𝙾 𝚂𝙴𝙽𝚂𝙾𝚁", Value = {Min = 20, Max = 200, Default = 80}, Callback = function(v) SensorRange = v end})
DriveTab:Slider({Title = "𝙲𝙾𝙾𝙻𝙳𝙾𝚆𝙽", Value = {Min = 1, Max = 20, Default = 4, Suffix = " 𝚇𝟶.𝟷𝚂"}, Callback = function(v) SensorCooldown = v / 10 end})
DriveTab:Button({Title = "𝙵𝙾𝚁𝙲𝙰𝚁 𝙳𝙴𝙵𝙴𝚂𝙰", Callback = function()
    if SensorEnabled then SensorLast = 0; ExecutarDefesaSensor() end
end})--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | PARTE 7/9 — Flag ]]

FlagTab = Window:Tab({ Title = "𝙵𝙻𝙰𝙶", Icon = "zap" })
FlagTab:Section({ Title = "𝙾𝚃𝙸𝙼𝙸𝚉𝙰𝙲𝙰𝙾" })

FlagTab:Toggle({Title = "𝚄𝙽𝙻𝙾𝙲𝙺 𝙵𝙿𝚂", Value = false, Callback = function(v)
    pcall(function() if setfpscap then setfpscap(v and 999 or 60) end end)
end})

AntiLagBackup = {}
FlagTab:Toggle({Title = "𝙰𝙽𝚃𝙸 𝙻𝙰𝙶", Value = false, Callback = function(v)
    pcall(function()
        if v then
            AntiLagBackup.Brightness = Lighting.Brightness
            AntiLagBackup.GlobalShadows = Lighting.GlobalShadows
            AntiLagBackup.FogEnd = Lighting.FogEnd
            AntiLagBackup.OutdoorAmbient = Lighting.OutdoorAmbient
            Lighting.GlobalShadows = false; Lighting.FogEnd = 100000
            Lighting.Brightness = 1; Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("PostEffect") then obj.Enabled = false end
            end
        else
            if AntiLagBackup.Brightness then Lighting.Brightness = AntiLagBackup.Brightness end
            if AntiLagBackup.GlobalShadows ~= nil then Lighting.GlobalShadows = AntiLagBackup.GlobalShadows end
            if AntiLagBackup.FogEnd then Lighting.FogEnd = AntiLagBackup.FogEnd end
            if AntiLagBackup.OutdoorAmbient then Lighting.OutdoorAmbient = AntiLagBackup.OutdoorAmbient end
            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("PostEffect") then obj.Enabled = true end
            end
        end
    end)
end})

AntiFreezeEnabled = false
FlagTab:Toggle({Title = "𝙰𝙽𝚃𝙸 𝙵𝚁𝙴𝙴𝚉𝙴", Value = false, Callback = function(v)
    AntiFreezeEnabled = v
    if v then
        spawn(function()
            while AntiFreezeEnabled do
                task.wait(0.1)
                pcall(function()
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if obj:IsA("BasePart") then obj.CanQuery = true end
                    end
                end)
            end
        end)
    end
end})

ContainerEnabled = false
ContainerBackup = {}
FlagTab:Toggle({Title = "𝙲𝙾𝙽𝚃𝙰𝙸𝙽𝙴𝚁", Value = false, Callback = function(v)
    ContainerEnabled = v
    if v then
        spawn(function()
            while ContainerEnabled do
                task.wait(0.25)
                if RootPart then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if (obj:IsA("Texture") or obj:IsA("Decal")) and obj.Parent and obj.Parent:IsA("BasePart") then
                            if (obj.Parent.Position - RootPart.Position).Magnitude > 200 then
                                if not ContainerBackup[obj] then ContainerBackup[obj] = obj.Transparency end
                                obj.Transparency = 1
                            end
                        end
                    end
                end
            end
        end)
    else
        for obj, val in pairs(ContainerBackup) do
            if obj and obj.Parent then pcall(function() obj.Transparency = val end) end
        end
        ContainerBackup = {}
    end
end})--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | PARTE 8/9 — Troll ]]

TrollTab = Window:Tab({ Title = "𝚃𝚁𝙾𝙻𝙻", Icon = "skull" })

LoopBallEnabled = false
LoopBallDistance = 2.5
LoopBallMinSpeed = 5
TrollTab:Section({ Title = "𝙻𝙾𝙾𝙿 𝙱𝙰𝙻𝙻" })
TrollTab:Toggle({Title = "𝙰𝚃𝙸𝚅𝙰𝚁 𝙻𝙾𝙾𝙿", Value = false, Callback = function(v)
    LoopBallEnabled = v
    if v then
        spawn(function()
            while LoopBallEnabled do
                task.wait(0.05)
                if RootPart and RootPart.Parent then
                    local ball = GetValidBall()
                    if ball and ball.Parent then
                        local vel = ball.AssemblyLinearVelocity
                        if vel.Magnitude >= LoopBallMinSpeed then
                            local dir = ball.Position - RootPart.Position
                            local dirH = Vector3.new(dir.X, 0, dir.Z)
                            if dirH.Magnitude < 0.1 then
                                RootPart.CFrame = CFrame.new(ball.Position + Vector3.new(0, 1.5, 0))
                            else
                                RootPart.CFrame = CFrame.new(ball.Position - (dirH.Unit * LoopBallDistance) + Vector3.new(0, 1.5, 0))
                            end
                            if FTI then
                                pcall(function()
                                    firetouchinterest(RootPart, ball, 0)
                                    firetouchinterest(RootPart, ball, 1)
                                end)
                            end
                        end
                    end
                end
            end
        end)
    end
end})
TrollTab:Slider({Title = "𝚅𝙴𝙻𝙾𝙲𝙸𝙳𝙰𝙳𝙴 𝙼𝙸𝙽𝙸𝙼𝙰", Value = {Min = 1, Max = 30, Default = 5}, Callback = function(v) LoopBallMinSpeed = v end})
TrollTab:Slider({Title = "𝙳𝙸𝚂𝚃𝙰𝙽𝙲𝙸𝙰", Value = {Min = 1, Max = 8, Default = 2.5, Decimal = 1}, Callback = function(v) LoopBallDistance = v end})

ImaBallEnabled = false
ImaBallForce = 60
ImaBallRange = 40
TrollTab:Section({ Title = "𝙸𝙼𝙰 𝙱𝙰𝙻𝙻" })
TrollTab:Toggle({Title = "𝙰𝚃𝙸𝚅𝙰𝚁 𝙸𝙼𝙰", Value = false, Callback = function(v)
    ImaBallEnabled = v
    if v then
        spawn(function()
            while ImaBallEnabled do
                task.wait(0.03)
                if RootPart and RootPart.Parent then
                    local ball = GetValidBall()
                    if ball and ball.Parent then
                        local dir = RootPart.Position - ball.Position
                        local dist = dir.Magnitude
                        if dist <= ImaBallRange and dist >= 0.5 then
                            local mult = math.clamp(1 - (dist / ImaBallRange), 0.3, 1)
                            local pull = dir.Unit * ImaBallForce * mult
                            pcall(function()
                                ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity:Lerp(pull, 0.2)
                            end)
                        end
                    end
                end
            end
        end)
    end
end})
TrollTab:Slider({Title = "𝙵𝙾𝚁𝙲𝙰", Value = {Min = 10, Max = 200, Default = 60}, Callback = function(v) ImaBallForce = v end})
TrollTab:Slider({Title = "𝙰𝙻𝙲𝙰𝙽𝙲𝙴", Value = {Min = 5, Max = 100, Default = 40}, Callback = function(v) ImaBallRange = v end})

FlingBallForce = 300
TrollTab:Section({ Title = "𝙵𝙻𝙸𝙽𝙶 𝙱𝙰𝙻𝙻" })
TrollTab:Button({Title = "𝙵𝙻𝙸𝙽𝙶 𝙱𝙰𝙻𝙻", Callback = function()
    local ball = GetValidBall()
    if not ball or not RootPart then return end
    local dir = (ball.Position - RootPart.Position).Unit
    RootPart.CFrame = CFrame.new(ball.Position - (dir * 1.5) + Vector3.new(0, 1, 0))
    task.wait(0.1)
    if ball and ball.Parent then
        local rd = Vector3.new(math.random(-100,100)/100, 1, math.random(-100,100)/100).Unit
        ball.AssemblyLinearVelocity = rd * FlingBallForce + Vector3.new(0, FlingBallForce * 0.6, 0)
        ball.AssemblyAngularVelocity = Vector3.new(math.random(-50,50), math.random(-50,50), math.random(-50,50))
    end
end})
TrollTab:Slider({Title = "𝙵𝙾𝚁𝙲𝙰", Value = {Min = 100, Max = 800, Default = 300}, Callback = function(v) FlingBallForce = v end})

TrollTab:Section({ Title = "𝚂𝙸𝙻𝙴𝙽𝚃 𝙰𝙸𝙼" })
SilentAimEnabled = false
SilentAimRange = 150
SilentAimCooldown = 0.15
SilentAimLast = 0
SilentAimShowTarget = false
SilentAimTargetMode = "Nearest"
SilentAimHighlight = nil

function GetTargetsInRange(range)
    local list = {}
    if not RootPart then return list end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
            local tHum = p.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and tHum and tHum.Health > 0 then
                local dist = (tRoot.Position - RootPart.Position).Magnitude
                if dist <= range then table.insert(list, {player = p, root = tRoot, hum = tHum, dist = dist}) end
            end
        end
    end
    return list
end
function GetBestTarget()
    local list = GetTargetsInRange(SilentAimRange)
    if #list == 0 then return nil end
    if SilentAimTargetMode == "Nearest" then table.sort(list, function(a,b) return a.dist < b.dist end)
    elseif SilentAimTargetMode == "LowestHP" then table.sort(list, function(a,b) return a.hum.Health < b.hum.Health end) end
    return list[1]
end

RunService.Heartbeat:Connect(function()
    if not SilentAimEnabled or not SilentAimShowTarget then
        if SilentAimHighlight then SilentAimHighlight:Destroy(); SilentAimHighlight = nil end
        return
    end
    local target = GetBestTarget()
    if target then
        if not SilentAimHighlight or not SilentAimHighlight.Parent then
            SilentAimHighlight = Instance.new("Highlight")
            SilentAimHighlight.FillColor = Color3.fromRGB(255, 50, 50)
            SilentAimHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            SilentAimHighlight.FillTransparency = 0.6
            SilentAimHighlight.OutlineTransparency = 0
            SilentAimHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            SilentAimHighlight.Parent = Camera
        end
        SilentAimHighlight.Adornee = target.player.Character
    elseif SilentAimHighlight then SilentAimHighlight:Destroy(); SilentAimHighlight = nil end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not SilentAimEnabled then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if tick() - SilentAimLast < SilentAimCooldown then return end
    local target = GetBestTarget()
    if not target then return end
    pcall(function() Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.root.Position) end)
    task.spawn(function()
        task.wait(0.05)
        local ball = GetValidBall()
        if ball and ball.Parent then
            local dir = (target.root.Position - ball.Position).Unit
            pcall(function()
                ball.AssemblyLinearVelocity = dir * 200 + Vector3.new(0, 25, 0)
                ball.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end)
    SilentAimLast = tick()
end)

TrollTab:Toggle({Title = "𝚂𝙸𝙻𝙴𝙽𝚃 𝙰𝙸𝙼", Value = false, Callback = function(v) SilentAimEnabled = v end})
TrollTab:Dropdown({Title = "𝙼𝙾𝙳𝙾", Values = {"Nearest", "LowestHP"}, Value = "Nearest", Callback = function(v) SilentAimTargetMode = v end})
TrollTab:Slider({Title = "𝙰𝙻𝙲𝙰𝙽𝙲𝙴", Value = {Min = 20, Max = 500, Default = 150}, Callback = function(v) SilentAimRange = v end})
TrollTab:Slider({Title = "𝙲𝙾𝙾𝙻𝙳𝙾𝚆𝙽", Value = {Min = 1, Max = 100, Default = 15, Suffix = " 𝚇𝟶.𝟶𝟷𝚂"}, Callback = function(v) SilentAimCooldown = v / 100 end})
TrollTab:Toggle({Title = "𝙼𝙾𝚂𝚃𝚁𝙰𝚁 𝙰𝙻𝚅𝙾", Value = false, Callback = function(v) SilentAimShowTarget = v end})

TrollTab:Section({ Title = "𝙲𝙷𝚄𝚃𝙴 𝚂𝙸𝙻𝙴𝙽𝙲𝙸𝙾𝚂𝙾" })
SilentKickEnabled = false
SilentKickMode = "Nearest"
SilentKickRange = 50
SilentKickPower = 250
SilentKickCooldown = 1
SilentKickLast = 0

TrollTab:Toggle({Title = "𝙲𝙷𝚄𝚃𝙴 𝚂𝙸𝙻𝙴𝙽𝙲𝙸𝙾𝚂𝙾", Value = false, Callback = function(v)
    SilentKickEnabled = v
    if v then
        spawn(function()
            while SilentKickEnabled do
                task.wait(0.1)
                if tick() - SilentKickLast < SilentKickCooldown then continue end
                local ball = GetValidBall()
                if not ball or not ball.Parent or not RootPart then continue end
                local targets = GetTargetsInRange(SilentKickRange)
                if #targets == 0 then continue end
                SilentKickLast = tick()
                if SilentKickMode == "All" then
                    for _, t in ipairs(targets) do
                        local dir = (t.root.Position - ball.Position).Unit
                        pcall(function() ball.AssemblyLinearVelocity = dir * SilentKickPower + Vector3.new(0, 30, 0) end)
                        task.wait(0.05)
                    end
                else
                    local nearest = targets[1]
                    for _, t in ipairs(targets) do if t.dist < nearest.dist then nearest = t end end
                    local dir = (nearest.root.Position - ball.Position).Unit
                    pcall(function() ball.AssemblyLinearVelocity = dir * SilentKickPower + Vector3.new(0, 30, 0) end)
                end
                if FTI then
                    pcall(function()
                        firetouchinterest(RootPart, ball, 0)
                        firetouchinterest(RootPart, ball, 1)
                    end)
                end
            end
        end)
    end
end})
TrollTab:Dropdown({Title = "𝙼𝙾𝙳𝙾", Values = {"Nearest", "All"}, Value = "Nearest", Callback = function(v) SilentKickMode = v end})
TrollTab:Slider({Title = "𝙰𝙻𝙲𝙰𝙽𝙲𝙴", Value = {Min = 10, Max = 200, Default = 50}, Callback = function(v) SilentKickRange = v end})
TrollTab:Slider({Title = "𝙵𝙾𝚁𝙲𝙰", Value = {Min = 100, Max = 800, Default = 250}, Callback = function(v) SilentKickPower = v end})
TrollTab:Slider({Title = "𝙲𝙾𝙾𝙻𝙳𝙾𝚆𝙽", Value = {Min = 1, Max = 100, Default = 10, Suffix = " 𝚇𝟶.𝟷𝚂"}, Callback = function(v) SilentKickCooldown = v / 10 end})--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | PARTE 9/9 — Auto Farm + Utils + Info + Finalização ]]

FarmTab = Window:Tab({ Title = "𝙰𝚄𝚃𝙾 𝙵𝙰𝚁𝙼", Icon = "repeat" })

GOAL_COORDS = {
    Blue  = Vector3.new(-9, -27, -199),
    Green = Vector3.new(-20, -29, 379),
}
AUTO_GOL_CFRAMES = {
    Blue  = {Vector3.new(-32.18, -28.94, -203.58)},
    Green = {Vector3.new(-34.06, -28.94, 383.88), Vector3.new(-3.92, -28.94, 388.81)},
}

function GetMyTeam()
    local team = LocalPlayer.Team
    if not team then return nil end
    local nome = string.lower(team.Name)
    if nome:find("blue") or nome:find("azul") or nome:find("team1") or nome:find("time1") then return "Blue" end
    if nome:find("green") or nome:find("verde") or nome:find("team2") or nome:find("time2") then return "Green" end
    local tc = LocalPlayer.TeamColor
    if tc then
        local tcName = string.lower(tc.Name)
        if tcName:find("blue") or tcName:find("azul") then return "Blue" end
        if tcName:find("green") or tcName:find("verde") then return "Green" end
    end
    return nil
end

function GetEnemyGoalPosition()
    local myTeam = GetMyTeam()
    if myTeam == "Blue" then return GOAL_COORDS.Green, "Green"
    elseif myTeam == "Green" then return GOAL_COORDS.Blue, "Blue" end
    local _, _, root = GetCharacterData()
    if root then
        local dBlue = (GOAL_COORDS.Blue - root.Position).Magnitude
        local dGreen = (GOAL_COORDS.Green - root.Position).Magnitude
        if dBlue > dGreen then return GOAL_COORDS.Blue, "Blue"
        else return GOAL_COORDS.Green, "Green" end
    end
    return GOAL_COORDS.Green, "Green"
end

FarmTab:Section({ Title = "𝙰𝙸𝙼 𝙶𝙾𝙰𝙻 (𝙰𝙸𝙼𝙱𝙾𝚃)" })
AimGoalEnabled = false
AimGoalForce = 180
AimGoalArcY = 25
AimGoalCooldown = 0.4
AimGoalLast = 0
AimGoalDetectionThreshold = 25
AimGoalVisualEnabled = false
AimGoalMarker, AimGoalBeam, AimGoalBeamPart = nil, nil, nil

function CriarAimVisual()
    if AimGoalMarker then AimGoalMarker:Destroy() end
    if AimGoalBeamPart then AimGoalBeamPart:Destroy() end
    AimGoalMarker = Instance.new("Part")
    AimGoalMarker.Shape = Enum.PartType.Ball
    AimGoalMarker.Size = Vector3.new(8, 8, 8)
    AimGoalMarker.Material = Enum.Material.ForceField
    AimGoalMarker.Color = Color3.fromRGB(255, 50, 50)
    AimGoalMarker.Transparency = 0.5
    AimGoalMarker.CanCollide = false; AimGoalMarker.CanQuery = false
    AimGoalMarker.CanTouch = false; AimGoalMarker.Anchored = true
    AimGoalMarker.Parent = Workspace
    AimGoalBeamPart = Instance.new("Part")
    AimGoalBeamPart.Size = Vector3.new(1, 1, 1)
    AimGoalBeamPart.Transparency = 1
    AimGoalBeamPart.CanCollide = false; AimGoalBeamPart.CanQuery = false
    AimGoalBeamPart.Anchored = true
    AimGoalBeamPart.Parent = Workspace
    local a0 = Instance.new("Attachment", AimGoalBeamPart); a0.Name = "AimA0"
    local a1 = Instance.new("Attachment", AimGoalBeamPart); a1.Name = "AimA1"
    AimGoalBeam = Instance.new("Beam")
    AimGoalBeam.Attachment0 = a0; AimGoalBeam.Attachment1 = a1
    AimGoalBeam.Color = ColorSequence.new(Color3.fromRGB(255, 50, 50))
    AimGoalBeam.Width0 = 0.4; AimGoalBeam.Width1 = 0.4
    AimGoalBeam.FaceCamera = true; AimGoalBeam.LightEmission = 1
    AimGoalBeam.Transparency = NumberSequence.new(0.3)
    AimGoalBeam.Parent = AimGoalBeamPart
end
function DestruirAimVisual()
    if AimGoalMarker then AimGoalMarker:Destroy(); AimGoalMarker = nil end
    if AimGoalBeam then AimGoalBeam:Destroy(); AimGoalBeam = nil end
    if AimGoalBeamPart then AimGoalBeamPart:Destroy(); AimGoalBeamPart = nil end
end

BolaJaRedirecionada = false
RunService.Heartbeat:Connect(function()
    if not AimGoalEnabled then
        if AimGoalVisualEnabled then DestruirAimVisual() end
        return
    end
    if tick() - AimGoalLast < AimGoalCooldown then return end
    local ball = GetValidBall()
    if not ball or not ball.Parent then return end
    local vel = ball.AssemblyLinearVelocity
    local velMag = vel.Magnitude
    if velMag < AimGoalDetectionThreshold then BolaJaRedirecionada = false; return end
    if BolaJaRedirecionada then return end
    local golPos = GetEnemyGoalPosition()
    if not golPos then return end
    if AimGoalVisualEnabled then
        if not AimGoalMarker or not AimGoalMarker.Parent then CriarAimVisual() end
        pcall(function()
            AimGoalMarker.Position = golPos
            local dir = golPos - ball.Position
            AimGoalBeamPart.Position = ball.Position
            if dir.Magnitude > 0.1 then AimGoalBeamPart.CFrame = CFrame.new(ball.Position, golPos) end
            local a0 = AimGoalBeamPart:FindFirstChild("AimA0")
            local a1 = AimGoalBeamPart:FindFirstChild("AimA1")
            if a0 and a1 then
                a0.Position = Vector3.new(0, 0, 0)
                a1.Position = Vector3.new(0, 0, -dir.Magnitude)
            end
        end)
    end
    local dirGol = golPos - ball.Position
    local dirH = Vector3.new(dirGol.X, 0, dirGol.Z)
    if dirH.Magnitude < 0.1 then return end
    local novaVel = dirH.Unit * AimGoalForce + Vector3.new(0, AimGoalArcY, 0)
    pcall(function()
        ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity:Lerp(novaVel, 0.9)
        ball.AssemblyAngularVelocity = Vector3.new(math.random(-15,15), math.random(-15,15), math.random(-15,15))
    end)
    if FTI then
        pcall(function()
            firetouchinterest(RootPart, ball, 0)
            firetouchinterest(RootPart, ball, 1)
        end)
    end
    BolaJaRedirecionada = true
    AimGoalLast = tick()
end)

FarmTab:Toggle({
    Title = "𝙰𝙸𝙼 𝙶𝙾𝙰𝙻",
    Desc = "𝚃𝙾𝙳𝙾 𝙲𝙷𝚄𝚃𝙴 𝚅𝙰𝙸 𝙿𝙰𝚁𝙰 𝙾 𝙶𝙾𝙻 𝙸𝙽𝙸𝙼𝙸𝙶𝙾",
    Value = false,
    Callback = function(v)
        AimGoalEnabled = v
        if v then
            local myTeam = GetMyTeam()
            local _, golTeam = GetEnemyGoalPosition()
            pcall(function() WindUI:Notify({Title = "𝙰𝙸𝙼 𝙶𝙾𝙰𝙻", Content = "𝚃𝙸𝙼𝙴: " .. (myTeam or "?") .. " -> 𝙰𝙻𝚅𝙾: " .. (golTeam or "?"), Duration = 4}) end)
        else DestruirAimVisual() end
    end,
})
FarmTab:Slider({Title = "𝙵𝙾𝚁𝙲𝙰 𝙳𝙾 𝙲𝙷𝚄𝚃𝙴", Value = {Min = 50, Max = 500, Default = 180}, Callback = function(v) AimGoalForce = v end})
FarmTab:Slider({Title = "𝙰𝚁𝙲𝙾", Value = {Min = 0, Max = 100, Default = 25}, Callback = function(v) AimGoalArcY = v end})
FarmTab:Slider({Title = "𝙲𝙾𝙾𝙻𝙳𝙾𝚆𝙽", Value = {Min = 1, Max = 30, Default = 4, Suffix = " 𝚇𝟶.𝟷𝚂"}, Callback = function(v) AimGoalCooldown = v / 10 end})
FarmTab:Slider({Title = "𝙳𝙴𝚃𝙴𝙲𝙲𝙰𝙾 𝙳𝙴 𝙲𝙷𝚄𝚃𝙴", Value = {Min = 10, Max = 80, Default = 25, Suffix = " 𝚂𝚃𝚄𝙳/𝚂"}, Callback = function(v) AimGoalDetectionThreshold = v end})
FarmTab:Toggle({Title = "𝚅𝙸𝚂𝚄𝙰𝙻 𝙳𝙾 𝙰𝙸𝙼 𝙶𝙾𝙰𝙻", Value = false, Callback = function(v) AimGoalVisualEnabled = v; if not v then DestruirAimVisual() end end})
FarmTab:Button({Title = "𝚅𝙴𝚁 𝙼𝙴𝚄 𝚃𝙸𝙼𝙴 𝙴 𝙰𝙻𝚅𝙾", Callback = function()
    print("Meu time:", GetMyTeam() or "?")
    local gp, gt = GetEnemyGoalPosition()
    print("Gol inimigo:", gt, "| Pos:", tostring(gp))
    pcall(function() WindUI:Notify({Title = "𝙰𝙸𝙼 𝙶𝙾𝙰𝙻", Content = "𝚅𝙴𝙹𝙰 𝙾 𝙲𝙾𝙽𝚂𝙾𝙻𝙴 (𝙵𝟿)", Duration = 3}) end)
end})

FarmTab:Section({ Title = "𝙰𝚄𝚃𝙾 𝙶𝙾𝙻" })
AutoGolBlueEnabled = false
AutoGolGreenEnabled = false
AutoGolCooldown = 0.4
AutoGolLast = 0
AutoGolForce = 180
AutoGolArcY = 25

function CheckAutoGol()
    if not AutoGolBlueEnabled and not AutoGolGreenEnabled then return end
    if not RootPart or not RootPart.Parent then return end
    if tick() - AutoGolLast < AutoGolCooldown then return end
    local ball = GetValidBall()
    if not ball or not ball.Parent then return end
    if (ball.Position - RootPart.Position).Magnitude > 6 then return end
    local target
    if AutoGolBlueEnabled and AutoGolGreenEnabled then
        target = math.random() < 0.5 and AUTO_GOL_CFRAMES.Blue[1] or AUTO_GOL_CFRAMES.Green[1]
    elseif AutoGolBlueEnabled then target = AUTO_GOL_CFRAMES.Blue[1]
    elseif AutoGolGreenEnabled then target = AUTO_GOL_CFRAMES.Green[1] end
    if not target then return end
    AutoGolLast = tick()
    local dir = target - ball.Position
    local dirH = Vector3.new(dir.X, 0, dir.Z)
    if dirH.Magnitude < 0.1 then return end
    local shootVec = dirH.Unit * AutoGolForce + Vector3.new(0, AutoGolArcY, 0)
    pcall(function()
        ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity:Lerp(shootVec, 0.85)
        ball.AssemblyAngularVelocity = Vector3.new(math.random(-15,15), math.random(-15,15), math.random(-15,15))
    end)
    if FTI then
        pcall(function()
            firetouchinterest(RootPart, ball, 0)
            firetouchinterest(RootPart, ball, 1)
        end)
    end
end

FarmTab:Toggle({Title = "𝙰𝚄𝚃𝙾 𝙶𝙾𝙻 𝙱𝙻𝚄𝙴", Value = false, Callback = function(v) AutoGolBlueEnabled = v end})
FarmTab:Toggle({Title = "𝙰𝚄𝚃𝙾 𝙶𝙾𝙻 𝙶𝚁𝙴𝙴𝙽", Value = false, Callback = function(v) AutoGolGreenEnabled = v end})
FarmTab:Slider({Title = "𝙵𝙾𝚁𝙲𝙰", Value = {Min = 50, Max = 500, Default = 180}, Callback = function(v) AutoGolForce = v end})
FarmTab:Slider({Title = "𝙰𝚁𝙲𝙾", Value = {Min = 0, Max = 100, Default = 25}, Callback = function(v) AutoGolArcY = v end})
FarmTab:Slider({Title = "𝙲𝙾𝙾𝙻𝙳𝙾𝚆𝙽", Value = {Min = 1, Max = 30, Default = 4, Suffix = " 𝚇𝟶.𝟷𝚂"}, Callback = function(v) AutoGolCooldown = v / 10 end})
RunService.PreRender:Connect(CheckAutoGol)

UtilsTab = Window:Tab({ Title = "𝚄𝚃𝙸𝙻𝚂", Icon = "settings-2" })

UtilsTab:Section({ Title = "𝚃𝙴𝙻𝙴𝙿𝙾𝚁𝚃𝙴𝚂" })
function TeleportTo(pos)
    if not RootPart or not RootPart.Parent then return end
    if typeof(pos) == "Vector3" then
        RootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        RootPart.AssemblyLinearVelocity = Vector3.zero
    end
end
UtilsTab:Button({Title = "𝙸𝚁 𝙿𝙰𝚁𝙰 𝙰 𝙱𝙰𝙻𝙻", Callback = function()
    local ball = GetValidBall()
    if ball then TeleportTo(ball.Position); pcall(function() WindUI:Notify({Title = "𝚃𝙴𝙻𝙴𝙿𝙾𝚁𝚃𝙴", Content = "𝙸𝙽𝙳𝙾 𝙿𝙰𝚁𝙰 𝙰 𝙱𝙰𝙻𝙻", Duration = 2}) end) end
end})
UtilsTab:Button({Title = "𝙸𝚁 𝙿𝙰𝚁𝙰 𝙾 𝙶𝙾𝙻 𝙸𝙽𝙸𝙼𝙸𝙶𝙾", Callback = function()
    local gp = GetEnemyGoalPosition()
    if gp then TeleportTo(gp); pcall(function() WindUI:Notify({Title = "𝚃𝙴𝙻𝙴𝙿𝙾𝚁𝚃𝙴", Content = "𝙸𝙽𝙳𝙾 𝙿𝙰𝚁𝙰 𝙾 𝙶𝙾𝙻", Duration = 2}) end) end
end})
UtilsTab:Button({Title = "𝙸𝚁 𝙿𝙰𝚁𝙰 𝙾 𝙲𝙴𝙽𝚃𝚁𝙾", Callback = function()
    TeleportTo(Vector3.new(0, 5, 0))
    pcall(function() WindUI:Notify({Title = "𝚃𝙴𝙻𝙴𝙿𝙾𝚁𝚃𝙴", Content = "𝙸𝙽𝙳𝙾 𝙿𝙰𝚁𝙰 𝙾 𝙲𝙴𝙽𝚃𝚁𝙾", Duration = 2}) end)
end})
UtilsTab:Button({Title = "𝙻𝙰𝙽𝙲𝙰𝚁 𝙿𝙰𝚁𝙰 𝙻𝙾𝙽𝙶𝙴", Callback = function()
    if RootPart then RootPart.AssemblyLinearVelocity = Vector3.new(0, 500, 0) end
end})

UtilsTab:Section({ Title = "𝙼𝙾𝚅𝙸𝙼𝙴𝙽𝚃𝙾 𝙴𝚇𝚃𝚁𝙰" })
AntiFlingEnabled = false
UtilsTab:Toggle({Title = "𝙰𝙽𝚃𝙸-𝙵𝙻𝙸𝙽𝙶", Desc = "𝚃𝚁𝙰𝚅𝙰 𝚅𝙴𝙻𝙾𝙲𝙸𝙳𝙰𝙳𝙴 𝙳𝙾 𝚁𝙾𝙾𝚃𝙿𝙰𝚁𝚃", Value = false, Callback = function(v)
    AntiFlingEnabled = v
    if v then
        spawn(function()
            while AntiFlingEnabled do
                task.wait(0.1)
                if RootPart and RootPart.Parent then
                    pcall(function()
                        local v3 = RootPart.AssemblyLinearVelocity
                        if v3.Magnitude > 200 then RootPart.AssemblyLinearVelocity = v3.Unit * 200 end
                        RootPart.AssemblyAngularVelocity = Vector3.zero
                    end)
                end
            end
        end)
    end
end})

UtilsTab:Section({ Title = "𝙸𝙽𝙵𝙾 𝙳𝙾 𝙹𝙾𝙶𝙾" })
InfoLabel = nil
pcall(function()
    InfoLabel = UtilsTab:Paragraph({
        Title = "𝙴𝚂𝚃𝙰𝙳𝙾 𝙰𝚃𝚄𝙰𝙻",
        Desc = "𝚃𝙸𝙼𝙴: ? | 𝙱𝙰𝙻𝙻: ? | 𝙳𝙸𝚂𝚃: ?",
    })
end)

spawn(function()
    while task.wait(1) do
        pcall(function()
            local myTeam = GetMyTeam() or "?"
            local ball = GetValidBall()
            local distStr = "?"
            if ball and RootPart then
                distStr = string.format("%.1f", (ball.Position - RootPart.Position).Magnitude)
            end
            local txt = "𝚃𝙸𝙼𝙴: " .. myTeam .. " | 𝙱𝙰𝙻𝙻: " .. (ball and "𝙾𝙺" or "𝙽𝙾") .. " | 𝙳𝙸𝚂𝚃: " .. distStr
            if InfoLabel and InfoLabel.SetDesc then InfoLabel:SetDesc(txt) end
        end)
    end
end)

UtilsTab:Button({Title = "𝙲𝙾𝙿𝙸𝙰𝚁 𝙴𝚂𝚃𝙰𝙳𝙾", Callback = function()
    local myTeam = GetMyTeam() or "?"
    local _, golTeam = GetEnemyGoalPosition()
    local txt = string.format("𝚃𝙸𝙼𝙴: %s | 𝙰𝙻𝚅𝙾: %s | 𝙵𝙾𝚁𝙲𝙰 𝙰𝙸𝙼: %d | 𝙵𝙾𝚁𝙲𝙰 𝙰𝚄𝚃𝙾: %d",
        myTeam, golTeam or "?", AimGoalForce, AutoGolForce)
    if setclipboard then pcall(setclipboard, txt) end
    print(txt)
    pcall(function() WindUI:Notify({Title = "𝙸𝙽𝙵𝙾", Content = "𝙲𝙾𝙿𝙸𝙰𝙳𝙾 𝙿𝙰𝚁𝙰 𝙾 𝙲𝙻𝙸𝙿𝙱𝙾𝙰𝚁𝙳", Duration = 3}) end)
end})

UtilsTab:Section({ Title = "𝙰𝙲𝙾𝙴𝚂 𝙶𝙻𝙾𝙱𝙰𝙸𝚂" })
UtilsTab:Button({Title = "𝙳𝙴𝚂𝙻𝙸𝙶𝙰𝚁 𝚃𝙾𝙳𝙾𝚂 𝙾𝚂 𝚃𝙾𝙶𝙶𝙻𝙴𝚂 𝙳𝙴 𝙵𝙰𝚁𝙼", Callback = function()
    AimGoalEnabled = false
    AutoGolBlueEnabled = false
    AutoGolGreenEnabled = false
    DestruirAimVisual()
    pcall(function() WindUI:Notify({Title = "𝚄𝚃𝙸𝙻𝚂", Content = "𝚃𝙾𝙶𝙶𝙻𝙴𝚂 𝙳𝙴 𝙵𝙰𝚁𝙼 𝙳𝙴𝚂𝙻𝙸𝙶𝙰𝙳𝙾𝚂", Duration = 3}) end)
end})
UtilsTab:Button({Title = "𝚁𝙴𝚂𝙿𝙰𝚆𝙽𝙰𝚁", Callback = function()
    if Character then
        pcall(function()
            local hum = Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end)
    end
end})
UtilsTab:Button({Title = "𝚂𝙰𝙸𝚁 𝙳𝙾 𝙹𝙾𝙶𝙾", Callback = function()
    pcall(function() LocalPlayer:Kick("Manarc.Gzy") end)
end})

InfoTab = Window:Tab({ Title = "𝙸𝙽𝙵𝙾", Icon = "info" })
InfoTab:Section({ Title = "𝙲𝚁𝙴𝙳𝙸𝚃𝙾𝚂" })
InfoTab:Paragraph({
    Title = "𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈",
    Desc = "𝚂𝙲𝚁𝙸𝙿𝚃 𝙵𝚄𝙻𝙻 - 𝙿𝙰𝚁𝚃𝙴𝚂 𝟷/𝟿 𝙰𝚃𝙴 𝟿/𝟿 𝙲𝙰𝚁𝚁𝙴𝙶𝙰𝙳𝙰𝚂 𝙲𝙾𝙼 𝚂𝚄𝙲𝙴𝚂𝚂𝙾.\n𝚃𝙲𝚂 | 𝚆𝙸𝙽𝙳𝚄𝙸 | 𝚅𝟺.𝟶",
})
InfoTab:Paragraph({
    Title = "𝙰𝚃𝙰𝙻𝙷𝙾𝚂",
    Desc = "- 𝙻𝙴𝙵𝚃𝚂𝙷𝙸𝙵𝚃: 𝙰𝙱𝚁𝙸𝚁/𝙵𝙴𝙲𝙷𝙰𝚁 𝙼𝙴𝙽𝚄\n- 𝙺: 𝙰𝚄𝚃𝙾 𝙵𝙾𝙻𝙻𝙾𝚆\n- 𝚄: 𝙲𝙾𝙽𝚃𝚁𝙾𝙻 𝙱𝙰𝙻𝙻",
})
InfoTab:Button({Title = "𝚅𝙴𝚁 𝚃𝙾𝙳𝙰𝚂 𝙰𝚂 𝙵𝚄𝙽𝙲𝙾𝙴𝚂", Callback = function()
    print("=== 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 - 𝚃𝙾𝙳𝙰𝚂 𝙰𝚂 𝙵𝚄𝙽𝙲𝙾𝙴𝚂 ===")
    print("MAPA | BOOMBOX | BALL | PLAYER | CHARS | AC | AUTODRIVE | FLAG | TROLL | AUTOFARM | UTILS | INFO")
    pcall(function() WindUI:Notify({Title = "𝙸𝙽𝙵𝙾", Content = "𝚅𝙴𝙹𝙰 𝙾 𝙲𝙾𝙽𝚂𝙾𝙻𝙴 (𝙵𝟿)", Duration = 3}) end)
end})

task.spawn(function()
    task.wait(0.6)
    pcall(function() Window:SelectTab(1) end)
    pcall(function() Window:Toggle() end)
    task.wait(0.2)
    pcall(function() Window:Toggle() end)
end)

print("[MANARC.GZY] SCRIPT COMPLETO CARREGADO - PARTES 1/9 A 9/9 OK")
print("[MANARC.GZY] TOTALMENTE INICIADO - BOA SORTE!")

pcall(function()
    WindUI:Notify({Title = "𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈", Content = "𝚂𝙲𝚁𝙸𝙿𝚃 𝙲𝙾𝙼𝙿𝙻𝙴𝚃𝙾", Duration = 6, Icon = "check-circle"})
end)
