--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | ᴘᴀʀᴛᴇ 1/9 — ꜱᴇᴛᴜᴘ + ʜᴇʟᴘᴇʀꜱ + ᴍᴀᴘᴀ + ʙᴏᴏᴍʙᴏx ]]

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
    Padrao = "rbxassetid://136946915996013",
}

WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

Window = WindUI:CreateWindow({
    Title = "ᴍᴀɴᴀʀᴄ.ɢᴢʏ",
    Icon = "eye",
    Author = "ᴀᴜᴛᴏ ꜰᴀʀᴍ",
    Folder = "ManicHub",
    Size = UDim2.fromOffset(620, 480),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true,
    Background = Backgrounds.Padrao,
    BackgroundImageTransparency = 0.35,
})

pcall(function()
    Window:Tag({ Title = "ᴠ4.0", Icon = "sparkles", Color = Color3.fromHex("#7850f0"), Radius = 30 })
end)

pcall(function()
    WindUI:Notify({ Title = "ᴍᴀɴᴀʀᴄ.ɢᴢʏ", Content = "ᴄᴀʀʀᴇɢᴀᴅᴏ", Duration = 5, Icon = "check-circle" })
end)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.LeftShift then Window:Toggle() end
end)

-- ============================================================
-- ÍCONE CUSTOMIZADO
-- ============================================================
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

-- ============================================================
-- FPS COUNTER
-- ============================================================
FpsGui = Instance.new("ScreenGui")
FpsGui.Name = "ManicFPS"; FpsGui.ResetOnSpawn = false
FpsGui.IgnoreGuiInset = true
pcall(function() FpsGui.Parent = (gethui and gethui()) or CoreGui end)
FpsBox = Instance.new("TextLabel")
FpsBox.Parent = FpsGui
FpsBox.Size = UDim2.new(0, 90, 0, 32); FpsBox.Position = UDim2.new(0, 12, 0, 110)
FpsBox.BackgroundColor3 = Color3.fromRGB(20, 22, 32); FpsBox.BackgroundTransparency = 0.3
FpsBox.TextColor3 = Color3.fromRGB(255, 255, 255); FpsBox.TextSize = 13
FpsBox.Font = Enum.Font.GothamBold; FpsBox.Text = "ꜰᴘꜱ 0"
FpsBox.BorderSizePixel = 0; FpsBox.ZIndex = 100
Instance.new("UICorner", FpsBox).CornerRadius = UDim.new(0, 6)
fpsCount, fpsTime = 0, tick()
RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    local now = tick()
    if now - fpsTime >= 1 then FpsBox.Text = "ꜰᴘꜱ " .. fpsCount; fpsCount = 0; fpsTime = now end
end)

-- ============================================================
-- HELPERS GLOBAIS
-- ============================================================
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

-- ============================================================
-- SCAN DE GOL (para o Aimbot)
-- ============================================================
function ScanGoalPosition(teamName)
    local mapa = Workspace:FindFirstChild("WorkspaceStadiumMap1")
    if mapa then
        local teamNames = {}
        if teamName == "Blue" then
            teamNames = {"Team1", "TeamBlue", "BlueGoal", "Goal1", "GoalBlue"}
        else
            teamNames = {"Team2", "TeamGreen", "GreenGoal", "Goal2", "GoalGreen"}
        end
        for _, tn in ipairs(teamNames) do
            local team = mapa:FindFirstChild(tn, true)
            if team then
                if team:IsA("BasePart") then return team.Position end
                local union = team:FindFirstChild("Union2") or team:FindFirstChild("Union") or team:FindFirstChildWhichIsA("BasePart", true)
                if union and union:IsA("BasePart") then return union.Position end
            end
        end
    end
    local golKeywords
    if teamName == "Blue" then
        golKeywords = {"goalblue", "goal1", "bluegoal", "team1", "teamblue", "goalpost1", "blue_goal"}
    else
        golKeywords = {"goalgreen", "goal2", "greengoal", "team2", "teamgreen", "goalpost2", "green_goal"}
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Anchored then
            local n = obj.Name:lower()
            for _, keyword in ipairs(golKeywords) do
                if n:find(keyword) then return obj.Position end
            end
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local n = obj.Name:lower()
            local isTarget = false
            if teamName == "Blue" and (n:find("team1") or n:find("blue") or n:find("goal1")) then
                isTarget = true
            elseif teamName == "Green" and (n:find("team2") or n:find("green") or n:find("goal2")) then
                isTarget = true
            end
            if isTarget then
                for _, child in ipairs(obj:GetDescendants()) do
                    if child:IsA("BasePart") then return child.Position end
                end
            end
        end
    end
    local minZ, maxZ = math.huge, -math.huge
    local minZPart, maxZPart = nil, nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Anchored and obj.Size.X > 5 then
            local n = obj.Name:lower()
            if n:find("goal") or n:find("post") or n:find("net") or n:find("union") then
                if obj.Position.Z < minZ then minZ = obj.Position.Z; minZPart = obj end
                if obj.Position.Z > maxZ then maxZ = obj.Position.Z; maxZPart = obj end
            end
        end
    end
    if teamName == "Blue" and minZPart then return minZPart.Position
    elseif teamName == "Green" and maxZPart then return maxZPart.Position end
    return nil
end

-- ============================================================
-- ABA MAPA
-- ============================================================
MapTab = Window:Tab({ Title = "ᴍᴀᴘᴀ", Icon = "map" })

-- ===== COR DO GRAMADO =====
MapTab:Section({ Title = "ᴄᴏʀ ᴅᴏ ɢʀᴀᴍᴀᴅᴏ" })

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

MapTab:Colorpicker({ Title = "ᴍᴀᴘ ᴄᴏʟᴏʀ", Default = Color3.fromRGB(60, 145, 60), Callback = function(c) AplicarCorGrama(c) end })
MapTab:Button({ Title = "ʀᴇꜱᴛᴀᴜʀᴀʀ ɢʀᴀᴍᴀ", Callback = function()
    RestaurarGrama(); pcall(function() WindUI:Notify({Title = "ᴍᴀᴘᴀ", Content = "ɢʀᴀᴍᴀ ʀᴇꜱᴛᴀᴜʀᴀᴅᴀ", Duration = 2}) end)
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

-- ===== GRÁFICOS =====
MapTab:Section({ Title = "ɢʀᴀꜰɪᴄᴏꜱ" })

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
MapTab:Button({Title = "ꜰʟᴏʀɪᴅᴏ", Callback = function()
    ResetarLighting()
    pcall(function()
        Lighting.Ambient = Color3.fromRGB(255, 200, 230)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 180, 220)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 150, 200)
        Lighting.Brightness = 2.5
    end)
end })
MapTab:Button({Title = "ʙᴏɴɪᴛᴏ", Callback = function() ResetarLighting() end })
MapTab:Button({Title = "ꜱᴏʟ", Callback = function()
    ResetarLighting(); pcall(function() Lighting.ClockTime = 17 end)
end })
MapTab:Button({Title = "ʀᴇᴄᴏᴍᴇɴᴅᴀᴅᴏ", Callback = function() ResetarLighting() end })

-- ===== IMAGEM DE FUNDO =====
MapTab:Section({ Title = "ɪᴍᴀɢᴇᴍ ᴅᴇ ꜰᴜɴᴅᴏ" })

MapTab:Dropdown({
    Title = "ʙᴀᴄᴋɢʀᴏᴜɴᴅ",
    Values = {"Padrao"},
    Value = "Padrao",
    Callback = function(option)
        local url = Backgrounds[option]
        if not url then return end
        pcall(function() if Window.SetBackground then Window:SetBackground(url, 0.35) end end)
        pcall(function() WindUI:Notify({Title = "ᴛʜᴇᴍᴇ", Content = option, Duration = 2}) end)
    end,
})

-- ============================================================
-- ABA BOOM BOX
-- ============================================================
BoomTab = Window:Tab({ Title = "ʙᴏᴏᴍ ʙᴏx", Icon = "music" })
BoomTab:Section({ Title = "ᴍᴜꜱɪᴄᴀꜱ" })

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
    {Nome = "ᴍᴇᴀɴᴛ ᴛᴏ ʙᴇ", ID = "84321228471359"},
    {Nome = "ꜱᴏᴍᴇᴛɪᴍᴇꜱ", ID = "128715303988843"},
    {Nome = "ʙʟᴏᴅʟʏɴ ʙʟᴏᴏᴅᴘᴏᴘ", ID = "96414211708215"},
}) do
    BoomTab:Button({ Title = m.Nome, Callback = function()
        TocarMusica(m.ID); pcall(function() WindUI:Notify({Title = "ʙᴏᴏᴍ ʙᴏx", Content = m.Nome, Duration = 2}) end)
    end })
end

BoomTab:Section({ Title = "ᴄᴜꜱᴛᴏᴍ" })
BoomTab:Input({ Title = "ɪᴅ", Placeholder = "ɪᴅ...", Callback = function(text)
    if text and text ~= "" then TocarMusica(text) end
end })
BoomTab:Button({ Title = "ᴘᴀʀᴀʀ ᴍᴜꜱɪᴄᴀ", Callback = function()
    if State.BoomBoxSound then
        pcall(function() State.BoomBoxSound:Stop(); State.BoomBoxSound:Destroy() end)
        State.BoomBoxSound = nil
    end
end })--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | ᴘᴀʀᴛᴇ 1.5/9 — ꜱᴋʏʙᴏx ᴄᴜꜱᴛᴏᴍ (ᴀʙᴀ ᴍᴀᴘᴀ) ]]

-- ============================================================
-- FUNÇÕES DE SKYBOX
-- ============================================================
function ForceSkyCustom(assetId)
    -- 1) Destruir sky domes/atmosphere parts do MAPA
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("MeshPart") then
            local n = string.lower(obj.Name)
            if (string.find(n, "sky") or string.find(n, "dome") or string.find(n, "ceu")
            or string.find(n, "atmosphere") or string.find(n, "skybox"))
            and not string.find(n, "manic") then
                pcall(function() obj:Destroy() end)
            end
        end
    end

    -- 2) Destruir Sky/Atmosphere/Clouds/PostEffect do Lighting
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Sky") or child:IsA("Atmosphere") or child:IsA("Clouds")
        or child:IsA("PostEffect") or child:IsA("ColorCorrectionEffect") then
            child:Destroy()
        end
    end

    -- 3) Tentar carregar como objeto Sky
    local loaded = false
    pcall(function()
        local objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
        for _, v in pairs(objects) do
            if v:IsA("Sky") then
                v.Name = "ManicSky"
                v.Parent = Lighting
                loaded = true
            end
        end
    end)

    -- 4) Se não veio como Sky, aplica via URL nas 6 faces
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

    -- 5) Atmosphere neutro
    pcall(function()
        local atm = Instance.new("Atmosphere")
        atm.Name = "ManicAtmosphere"
        atm.Density = 0
        atm.Offset = 0
        atm.Color = Color3.fromRGB(199, 199, 199)
        atm.Decay = Color3.fromRGB(106, 112, 125)
        atm.Glare = 0
        atm.Haze = 0
        atm.Parent = Lighting
    end)

    State.Skybox = assetId
end

function RestaurarSkyOriginal()
    for _, child in pairs(Lighting:GetChildren()) do
        if child.Name == "ManicSky" or child.Name == "ManicAtmosphere" then
            child:Destroy()
        end
    end
    State.Skybox = nil
    pcall(function() WindUI:Notify({Title = "ꜱᴋʏʙᴏx", Content = "ᴄéᴜ ʀᴇꜱᴛᴀᴜʀᴀᴅᴏ", Duration = 2}) end)
end

function ClearSky()
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") then obj:Destroy() end
    end
end

-- Loop de manutenção do skybox
task.spawn(function()
    while task.wait(2) do
        if State.Skybox then
            local found = false
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("Sky") and v.Name == "ManicSky" then found = true; break end
            end
            if not found then ForceSkyCustom(State.Skybox) end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    local n = string.lower(obj.Name)
                    if (string.find(n, "sky") or string.find(n, "dome") or string.find(n, "ceu"))
                    and not string.find(n, "manic") then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- SEÇÕES NA ABA MAPA
-- ============================================================
MapTab:Section({ Title = "ꜱᴋʏʙᴏx ᴄᴜꜱᴛᴏᴍ" })

SkyCustomId = ""
MapTab:Input({
    Title = "ɪᴅ ᴅᴏ ꜱᴋʏʙᴏx",
    Placeholder = "ᴇx: 113859918879279",
    Callback = function(text)
        SkyCustomId = text or ""
    end,
})
MapTab:Button({
    Title = "ᴀᴘʟɪᴄᴀʀ ꜱᴋʏʙᴏx ᴄᴜꜱᴛᴏᴍ",
    Desc = "ᴄᴏʟᴏᴜ ᴏ ɪᴅ ᴀᴄɪᴍᴀ? ᴄʟɪǫᴜᴇ ᴀǫᴜɪ",
    Callback = function()
        if SkyCustomId == "" or not SkyCustomId then
            pcall(function() WindUI:Notify({Title = "ꜱᴋʏʙᴏx", Content = "ᴄᴏʟᴏǫᴜᴇ ᴜᴍ ɪᴅ ᴘʀɪᴍᴇɪʀᴏ", Duration = 3}) end)
            return
        end
        ForceSkyCustom(SkyCustomId)
        pcall(function() WindUI:Notify({Title = "ꜱᴋʏʙᴏx", Content = "ᴀᴘʟɪᴄᴀᴅᴏ: " .. SkyCustomId, Duration = 3}) end)
    end,
})
MapTab:Button({
    Title = "ʀᴇꜱᴛᴀᴜʀᴀʀ ᴄéᴜ ᴏʀɪɢɪɴᴀʟ",
    Callback = function() RestaurarSkyOriginal() end,
})

-- ============================================================
-- PRESETS
-- ============================================================
MapTab:Section({ Title = "ꜱᴋʏʙᴏx ᴘʀᴇꜱᴇᴛꜱ" })

SkyPresets = {
    {Nome = "ɢʀᴇᴇɴ ꜱᴋʏ", ID = "113859918879279"},
    {Nome = "ᴘɪɴᴋ ꜱᴋʏ", ID = "96902346573845"},
    {Nome = "ᴍɪɴᴇᴄʀᴀꜰᴛ ꜱᴋʏ", ID = "96736589365838"},
    {Nome = "ꜱᴋʏ 1", ID = "8202961731"},
    {Nome = "ꜱᴋʏ 2", ID = "2758029221"},
    {Nome = "ɴɪɢʜᴛ", ID = "13107361022"},
    {Nome = "ꜱᴋʏ 4", ID = "7108851308"},
    {Nome = "ꜱᴋʏ 5", ID = "339406852"},
    {Nome = "ꜱᴋʏ 6", ID = "15502592084"},
    {Nome = "ꜱᴋʏ 7", ID = "15359965253"},
    {Nome = "ꜱᴋʏ 8", ID = "15470370280"},
    {Nome = "ʙʟᴜᴇ ꜱᴋʏ", ID = "8808550143"},
    {Nome = "ꜱᴋʏ 10", ID = "10594723714"},
}
for _, sky in ipairs(SkyPresets) do
    MapTab:Button({
        Title = sky.Nome,
        Callback = function()
            ForceSkyCustom(sky.ID)
            pcall(function() WindUI:Notify({Title = "ꜱᴋʏʙᴏx", Content = sky.Nome, Duration = 2}) end)
        end,
    })
end

-- ============================================================
-- SKY EXTRAS
-- ============================================================
MapTab:Section({ Title = "ꜱᴋʏ ᴇxᴛʀᴀꜱ" })

MapTab:Button({ Title = "ꜱᴋʏ ᴅᴇ ꜱᴏʟ", Callback = function()
    ClearSky(); Lighting.ClockTime = 7; Lighting.Brightness = 2
    local sky = Instance.new("Sky")
    sky.SkyboxBk = "rbxassetid://541743453"; sky.SkyboxDn = "rbxassetid://541743443"
    sky.SkyboxFt = "rbxassetid://541743446"; sky.SkyboxLf = "rbxassetid://541743436"
    sky.SkyboxRt = "rbxassetid://541743435"; sky.SkyboxUp = "rbxassetid://541743441"
    sky.Parent = Lighting
    State.Skybox = "sol"
end })
MapTab:Button({ Title = "ꜱᴋʏ ᴅᴇ ʟᴜᴀ", Callback = function()
    ClearSky(); Lighting.ClockTime = 21
    local sky = Instance.new("Sky")
    sky.SkyboxBk = "rbxassetid://4498828382"; sky.SkyboxDn = "rbxassetid://4498828812"
    sky.SkyboxFt = "rbxassetid://4498829917"; sky.SkyboxLf = "rbxassetid://4498830911"
    sky.SkyboxRt = "rbxassetid://4498830417"; sky.SkyboxUp = "rbxassetid://4498831746"
    sky.Parent = Lighting
    State.Skybox = "lua"
end })
MapTab:Button({ Title = "ʀᴇᴍᴏᴠᴇʀ ꜱᴋʏ", Callback = function() ClearSky(); State.Skybox = nil end })--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | ᴘᴀʀᴛᴇ 2/9 — ʙᴀʟʟ ᴀᴜᴛᴏ + ᴇꜰᴇɪᴛᴏꜱ ]]

BallTab = Window:Tab({ Title = "ʙᴀʟʟ", Icon = "circle" })
BallTab:Section({ Title = "ᴀᴜᴛᴏ ʙᴀʟʟ" })

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

BallTab:Toggle({ Title = "ᴀᴜᴛᴏ ʙᴀʟʟ", Value = false, Callback = function(v)
    if v then StartAutoBall() else StopAutoBall() end
end })
BallTab:Slider({ Title = "ᴅɪꜱᴛâɴᴄɪᴀ ᴅᴇ ᴘᴀʀᴀᴅᴀ", Value = {Min = 1, Max = 50, Default = 2}, Callback = function(v) FollowStopDistance = v / 10 end })
BallTab:Slider({ Title = "ꜰᴏʀçᴀ ᴅᴏ ꜱᴛᴇᴇʀɪɴɢ", Value = {Min = 1, Max = 30, Default = 13}, Callback = function(v) ManualSteerStrength = v / 10 end })

BallTab:Section({ Title = "ᴀᴘᴀʀêɴᴄɪᴀ ᴅᴀ ʙᴀʟʟ" })

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

BallTab:Colorpicker({ Title = "ᴄᴏʀ ᴅᴀ ʙᴀʟʟ", Default = Color3.fromRGB(89, 247, 255), Callback = function(c) AplicarCorBall(c) end })

FireColor1 = Color3.fromRGB(255, 100, 0)
FireColor2 = Color3.fromRGB(255, 200, 0)
FireSize = 15
FireHeat = 25

BallTab:Toggle({ Title = "ꜰᴏɢᴏ ɴᴀ ʙᴀʟʟ", Value = false, Callback = function(v)
    State.BallFire = v
    if not v then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if IsBall(obj) then
                local f = obj:FindFirstChild("Manic_BallFire"); if f then f:Destroy() end
            end
        end
    end
end })
BallTab:Colorpicker({ Title = "ᴄᴏʀ ᴘʀɪɴᴄɪᴘᴀʟ ᴅᴏ ꜰᴏɢᴏ", Default = FireColor1, Callback = function(c) FireColor1 = c end })
BallTab:Colorpicker({ Title = "ᴄᴏʀ ꜱᴇᴄᴜɴᴅáʀɪᴀ", Default = FireColor2, Callback = function(c) FireColor2 = c end })
BallTab:Slider({Title = "ᴛᴀᴍᴀɴʜᴏ", Value = {Min = 1, Max = 50, Default = 15}, Callback = function(v) FireSize = v end})
BallTab:Slider({Title = "ɪɴᴛᴇɴꜱɪᴅᴀᴅᴇ", Value = {Min = 1, Max = 50, Default = 25}, Callback = function(v) FireHeat = v end})

TrailEnabled = false
TrailColor = Color3.fromRGB(120, 90, 240)
TrailWidth = 1
TrailLifetime = 1

BallTab:Toggle({ Title = "ᴛʀᴀɪʟ ɴᴀ ʙᴀʟʟ", Value = false, Callback = function(v)
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
BallTab:Colorpicker({Title = "ᴄᴏʀ ᴅᴏ ᴛʀᴀɪʟ", Default = TrailColor, Callback = function(c) TrailColor = c end})
BallTab:Slider({Title = "ʟᴀʀɢᴜʀᴀ", Value = {Min = 1, Max = 50, Default = 10}, Callback = function(v) TrailWidth = v / 10 end})
BallTab:Slider({Title = "ᴅᴜʀᴀçãᴏ", Value = {Min = 1, Max = 50, Default = 10}, Callback = function(v) TrailLifetime = v / 10 end})

BallTab:Button({ Title = "ʀᴇꜱᴛᴀᴜʀᴀʀ ʙᴀʟʟ", Callback = function()
    RestaurarBall(); TrailEnabled = false
    pcall(function() WindUI:Notify({Title = "ʙᴀʟʟ", Content = "ʀᴇꜱᴛᴀᴜʀᴀᴅᴀ", Duration = 2}) end)
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
end)--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | ᴘᴀʀᴛᴇ 3/9 — ʙᴀʟʟ ᴇxᴛʀᴀꜱ + ᴘʀᴇᴅɪçãᴏ ]]

BallTab:Section({ Title = "ᴄʜᴀɴɢᴇʀ ʙᴀʟʟ" })

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
BallTab:Dropdown({ Title = "ꜱᴋɪɴ ᴅᴀ ʙᴀʟʟ", Values = {"Champions Laranja", "Champions Azul", "Champions Branca"}, Value = "Champions Laranja",
    Callback = function(option) AplicarBallSkin(option); pcall(function() WindUI:Notify({Title = "ʙᴀʟʟ ꜱᴋɪɴ", Content = option, Duration = 2}) end) end })

BallTab:Button({ Title = "ᴅᴇꜱᴀᴛɪᴠᴀʀ ꜱᴋɪɴ", Callback = function()
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

BallTab:Section({ Title = "ᴠɪꜱᴜᴀʟ ᴅᴀ ʙᴀʟʟ" })
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

BallTab:Toggle({ Title = "ʙᴀʟʟ ᴇꜱᴘ", Value = false, Callback = function(v)
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
BallTab:Colorpicker({ Title = "ᴄᴏʀ ᴅᴏ ᴇꜱᴘ", Default = Color3.fromRGB(0, 255, 100), Callback = function(c)
    BallESPColor = c
    if BallESPInstance then BallESPInstance.FillColor = c; BallESPInstance.OutlineColor = c end
end })
BallTab:Slider({ Title = "ᴛʀᴀɴꜱᴘᴀʀêɴᴄɪᴀ", Value = {Min = 0, Max = 100, Default = 50}, Callback = function(v)
    BallESPFill = v / 100
    if BallESPInstance then BallESPInstance.FillTransparency = BallESPFill end
end })

BallChamsEnabled = false
BallChamsColor = Color3.fromRGB(255, 50, 50)
BallChamsBackup = {}
BallTab:Toggle({ Title = "ʙᴀʟʟ ᴄʜᴀᴍꜱ", Value = false, Callback = function(v)
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
BallTab:Colorpicker({ Title = "ᴄᴏʀ ᴅᴏ ᴄʜᴀᴍꜱ", Default = Color3.fromRGB(255, 50, 50), Callback = function(c) BallChamsColor = c end })

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

BallTab:Section({ Title = "ᴘʀᴇᴅɪçãᴏ ᴅᴀ ʙᴀʟʟ" })
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

BallTab:Toggle({ Title = "3ᴅ ᴘʀᴇᴅɪçãᴏ ʟɪɴᴇ", Value = false, Callback = function(v)
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
BallTab:Slider({Title = "ᴄᴏᴍᴘʀɪᴍᴇɴᴛᴏ", Value = {Min = 10, Max = 200, Default = 50}, Callback = function(v) PredictionLength = v end})
BallTab:Colorpicker({Title = "ᴄᴏʀ", Default = Color3.fromRGB(0, 200, 255), Callback = function(c)
    PredictionColor = c
    if PredictionBeam then PredictionBeam.Color = ColorSequence.new(c) end
end})

BallTab:Section({ Title = "ᴛᴇʟᴇᴘᴏʀᴛᴀʀ ʙᴀʟʟ" })
TPBallPosEnabled = false
TPBallPosition = Vector3.new(-56, 1194, -281)
BallTab:Toggle({Title = "ᴛᴘ ʙᴀʟʟ ᴛᴏ ᴘᴏꜱɪᴛɪᴏɴ", Value = false, Callback = function(v)
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
BallTab:Input({Title = "x", Placeholder = "-56", Callback = function(t) local n = tonumber(t); if n then TPBallPosition = Vector3.new(n, TPBallPosition.Y, TPBallPosition.Z) end end})
BallTab:Input({Title = "ʏ", Placeholder = "1194", Callback = function(t) local n = tonumber(t); if n then TPBallPosition = Vector3.new(TPBallPosition.X, n, TPBallPosition.Z) end end})
BallTab:Input({Title = "ᴢ", Placeholder = "-281", Callback = function(t) local n = tonumber(t); if n then TPBallPosition = Vector3.new(TPBallPosition.X, TPBallPosition.Y, n) end end})
BallTab:Button({Title = "ᴜꜱᴀʀ ᴍɪɴʜᴀ ᴘᴏꜱɪçãᴏ", Callback = function()
    if RootPart then TPBallPosition = RootPart.Position
        pcall(function() WindUI:Notify({Title = "ʙᴀʟʟ", Content = "ᴘᴏꜱɪçãᴏ ᴅᴇꜰɪɴɪᴅᴀ", Duration = 2}) end) end
end})

TPToBallEnabled = false
BallTab:Toggle({Title = "ᴛᴘ ᴛᴏ ʙᴀʟʟ", Value = false, Callback = function(v)
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

BallTab:Section({ Title = "ᴄᴜʀᴠᴀ ᴅᴀ ʙᴀʟʟ" })
CurvePresets = {
    ["None"] = {side = "None", dip = false, cPower = 0, dPower = 0},
    ["Curve Esquerda"] = {side = "Left", dip = true, cPower = 60, dPower = 20},
    ["Curve Direita"] = {side = "Right", dip = false, cPower = 80, dPower = 0},
}
CurveState = {Side = "None", Dip = false, CPower = 0, DPower = 0, Active = false}
BallTab:Dropdown({Title = "ᴛɪᴘᴏ ᴅᴇ ᴄᴜʀᴠᴀ", Values = {"None", "Curve Esquerda", "Curve Direita"}, Value = "None",
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

-- ============================================================
-- BOTÃO FLUTUANTE ARRASTÁVEL
-- ============================================================
BallTab:Section({ Title = "ʙᴏᴛãᴏ ꜰʟᴜᴛᴜᴀɴᴛᴇ" })
FloatGui, FloatBtn, FloatLocked = nil, nil, false

function AtualizarTextoBotao()
    if not FloatBtn then return end
    if State.AutoBall then
        FloatBtn.Text = "ꜱᴇɢᴜɪʀ:ᴏɴ"; FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 60)
    else
        FloatBtn.Text = "ꜱᴇɢᴜɪʀ:ᴏꜰꜰ"; FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 90, 50)
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
    FloatBtn.Text = "ꜱᴇɢᴜɪʀ:ᴏꜰꜰ"
    FloatBtn.TextSize = 16; FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FloatBtn.Font = Enum.Font.GothamBold; FloatBtn.BorderSizePixel = 0
    FloatBtn.AutoButtonColor = false; FloatBtn.Active = true
    FloatBtn.Parent = FloatGui
    Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 12)
    local s = Instance.new("UIStroke", FloatBtn); s.Color = Color3.fromRGB(0, 0, 0); s.Thickness = 4
    AtualizarTextoBotao()

    local isDragging = false
    local dragStart = nil
    local startPos = nil
    local moveThreshold = 8
    local movedFar = false

    FloatBtn.InputBegan:Connect(function(input)
        if FloatLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = FloatBtn.AbsolutePosition
            movedFar = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not isDragging then return end
        if FloatLocked then isDragging = false; return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > moveThreshold or math.abs(delta.Y) > moveThreshold then
                movedFar = true
            end
            FloatBtn.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if isDragging and not movedFar then
                State.AutoBall = not State.AutoBall
                if State.AutoBall then StartAutoBall() else StopAutoBall() end
                AtualizarTextoBotao()
            end
            isDragging = false
        end
    end)
end

BallTab:Toggle({Title = "ᴍᴏꜱᴛʀᴀʀ ʙᴏᴛãᴏ ꜰʟᴜᴛᴜᴀɴᴛᴇ", Value = false, Callback = function(v)
    if v then
        if not FloatBtn then CriarFloatBtn() end
        FloatBtn.Visible = true
        AtualizarTextoBotao()
    elseif FloatBtn then
        FloatBtn.Visible = false
    end
end})
BallTab:Toggle({Title = "ᴛʀᴀᴠᴀʀ ʙᴏᴛãᴏ", Value = false, Callback = function(v) FloatLocked = v end})
BallTab:Button({Title = "ʀᴇᴄʀɪᴀʀ ʙᴏᴛãᴏ", Callback = function()
    if FloatBtn then CriarFloatBtn(); FloatBtn.Visible = true end
end})

spawn(function() while true do task.wait(0.2); if FloatBtn then AtualizarTextoBotao() end end end)--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | ᴘᴀʀᴛᴇ 4/9 — ᴘʟᴀʏᴇʀ (ꜱᴇᴍ ᴀᴜᴛᴏ ꜰᴏʟʟᴏᴡ) ]]

PlayerTab = Window:Tab({ Title = "ᴘʟᴀʏᴇʀ", Icon = "user" })

PlayerTab:Section({ Title = "ᴠᴇʟᴏᴄɪᴅᴀᴅᴇ (ᴀɴᴛɪ-ʙᴀɴ)" })
SpeedEnabled = false
SpeedValue = 24
SpeedJitter = true

PlayerTab:Toggle({Title = "ᴀᴛɪᴠᴀʀ ᴠᴇʟᴏᴄɪᴅᴀᴅᴇ", Desc = "ᴀɴᴛɪ-ʙᴀɴ", Value = false, Callback = function(v) SpeedEnabled = v end})
PlayerTab:Slider({Title = "ᴠᴇʟᴏᴄɪᴅᴀᴅᴇ", Value = {Min = 16, Max = 60, Default = 24}, Callback = function(v) SpeedValue = v end})
PlayerTab:Toggle({Title = "ᴊɪᴛᴛᴇʀ ɴᴀᴛᴜʀᴀʟ", Value = true, Callback = function(v) SpeedJitter = v end})

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

PlayerTab:Section({ Title = "ᴛʀᴀɪʟ ᴅᴏ ᴊᴏɢᴀᴅᴏʀ" })
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
PlayerTab:Toggle({Title = "ᴛʀᴀɪʟ ɴᴏ ᴊᴏɢᴀᴅᴏʀ", Value = false, Callback = function(v)
    State.Trail = v
    if v then CriarTrail() elseif TrailObj then TrailObj:Destroy(); TrailObj = nil end
end})
PlayerTab:Colorpicker({Title = "ᴄᴏʀ ᴅᴏ ᴛʀᴀɪʟ", Default = TrailColorP, Callback = function(c)
    TrailColorP = c
    if TrailObj then TrailObj.Color = ColorSequence.new(c) end
end})
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); if State.Trail then CriarTrail() end end)

PlayerTab:Section({ Title = "ᴛᴇʟᴀ ᴇꜱᴛɪᴄᴀᴅᴀ" })
StretchHConn, StretchVConn = nil, nil
PlayerTab:Toggle({Title = "ᴇꜱᴛɪᴄᴀʀ ʜᴏʀɪᴢᴏɴᴛᴀʟ", Value = false, Callback = function(v)
    State.StretchH = v
    if v then
        if StretchHConn then StretchHConn:Disconnect() end
        local cam = Workspace.CurrentCamera
        StretchHConn = RunService.RenderStepped:Connect(function()
            cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 0.75, 0, 0, 0, 1, 0, 0, 0, 1)
        end)
    elseif StretchHConn then StretchHConn:Disconnect(); StretchHConn = nil end
end})
PlayerTab:Toggle({Title = "ᴇꜱᴛɪᴄᴀʀ ᴠᴇʀᴛɪᴄᴀʟ", Value = false, Callback = function(v)
    State.StretchV = v
    if v then
        if StretchVConn then StretchVConn:Disconnect() end
        local cam = Workspace.CurrentCamera
        StretchVConn = RunService.RenderStepped:Connect(function()
            cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.67, 0, 0, 0, 1)
        end)
    elseif StretchVConn then StretchVConn:Disconnect(); StretchVConn = nil end
end})

PlayerTab:Section({ Title = "ᴄᴏʀ ᴅᴀ ᴛᴇʟᴀ" })
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
PlayerTab:Toggle({Title = "ᴀᴛɪᴠᴀʀ ᴄᴏʀ ᴅᴀ ᴛᴇʟᴀ", Value = false, Callback = function(v) ScreenColorEnabled = v; AplicarScreenColor() end})
PlayerTab:Colorpicker({Title = "ᴄᴏʀ", Default = Color3.fromRGB(255, 255, 255), Callback = function(c)
    ScreenColorTint = c; if ScreenColorEffect then ScreenColorEffect.TintColor = c end
end})
PlayerTab:Slider({Title = "ꜱᴀᴛᴜʀᴀçãᴏ", Value = {Min = -100, Max = 100, Default = 0}, Callback = function(v)
    ScreenColorSaturation = v / 100; if ScreenColorEffect then ScreenColorEffect.Saturation = ScreenColorSaturation end
end})
PlayerTab:Slider({Title = "ᴄᴏɴᴛʀᴀꜱᴛᴇ", Value = {Min = -100, Max = 100, Default = 0}, Callback = function(v)
    ScreenColorContrast = v / 100; if ScreenColorEffect then ScreenColorEffect.Contrast = ScreenColorContrast end
end})
PlayerTab:Slider({Title = "ʙʀɪʟʜᴏ", Value = {Min = -100, Max = 100, Default = 0}, Callback = function(v)
    ScreenColorBrightness = v / 100; if ScreenColorEffect then ScreenColorEffect.Brightness = ScreenColorBrightness end
end})
PlayerTab:Button({Title = "ʀᴇꜱᴛᴀᴜʀᴀʀ ᴄᴏʀ", Callback = function()
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
PlayerTab:Toggle({Title = "ɪɴᴠᴇʀᴛᴇʀ ᴄᴏʀ ᴅᴀ ᴛᴇʟᴀ", Desc = "ᴍᴏᴅᴏ ᴇꜱᴄᴜʀᴏ", Value = false, Callback = function(v)
    ScreenInvertEnabled = v; AplicarScreenInvert()
end})

PlayerTab:Section({ Title = "ᴀᴜᴛᴏ ꜱᴋɪʟʟ" })
AutoSkillEnabled = false
SkillSpeed = 5
SkillStep = 0
SkillPhase = 0
SkillRange = 3
PlayerTab:Toggle({Title = "ᴀᴜᴛᴏ ꜱᴋɪʟʟ", Value = false, Callback = function(v)
    AutoSkillEnabled = v
    if not v then SkillPhase = 0; SkillStep = 0 end
end})
PlayerTab:Slider({Title = "ᴠᴇʟᴏᴄɪᴅᴀᴅᴇ", Value = {Min = 1, Max = 10, Default = 5}, Callback = function(v) SkillSpeed = v end})
PlayerTab:Slider({Title = "ᴀʟᴄᴀɴᴄᴇ", Value = {Min = 1, Max = 10, Default = 3}, Callback = function(v) SkillRange = v end})
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

PlayerTab:Section({ Title = "ᴄᴏɴᴛʀᴏʟ ʙᴀʟʟ" })
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
PlayerTab:Toggle({Title = "ᴄᴏɴᴛʀᴏʟ ʙᴀʟʟ", Desc = "ᴋᴇʏ: ᴜ", Value = false, Callback = function(v)
    ControlBallEnabled = v
    if not v and ControllingBall then StopControl() end
end})
PlayerTab:Slider({Title = "ᴠᴇʟᴏᴄɪᴅᴀᴅᴇ ᴅᴀ ʙᴀʟʟ", Value = {Min = 10, Max = 200, Default = 70}, Callback = function(v) ControlBallSpeed = v end})
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == ControlKey and ControlBallEnabled then
        if ControllingBall then StopControl() else
            local ball = GetValidBall(); if ball then StartControl(ball) end
        end
    end
end)--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | ᴘᴀʀᴛᴇ 5/9 — ᴄʜᴀʀꜱ + ᴀᴄ + ʀᴇᴀᴄʜ ]]

CharsTab = Window:Tab({ Title = "ᴄʜᴀʀꜱ", Icon = "users" })
CharsTab:Section({ Title = "ᴄʜᴀʀꜱ" })
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
        SendChar(char); pcall(function() WindUI:Notify({Title = "ᴄʜᴀʀ", Content = char, Duration = 2}) end)
    end })
end

ACTab = Window:Tab({ Title = "ᴀᴄ", Icon = "shield" })
ACTab:Section({ Title = "ᴀᴜᴛᴏ ᴄᴀᴛᴄʜ" })
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
ACTab:Toggle({Title = "ᴀᴜᴛᴏ ᴄᴀᴛᴄʜ", Value = false, Callback = function(v) State.AutoCatch = v end})
ACTab:Slider({Title = "ᴀʟᴄᴀɴᴄᴇ", Value = {Min = 3, Max = 30, Default = 8}, Callback = function(v) AutoCatchRange = v end})
ACTab:Slider({Title = "ᴄᴏᴏʟᴅᴏᴡɴ", Value = {Min = 2, Max = 30, Default = 8, Suffix = " x0.1s"}, Callback = function(v) AutoCatchDelay = v / 10 end})
ACTab:Toggle({Title = "ᴍᴏꜱᴛʀᴀʀ ʜɪᴛʙᴏx", Value = false, Callback = function(v) AC_Hitbox = v end})

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

ACTab:Section({ Title = "ʀᴇᴀᴄʜ" })
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
ACTab:Toggle({Title = "ᴀᴛɪᴠᴀʀ ʀᴇᴀᴄʜ", Value = false, Callback = function(v) State.Reach = v end})
ACTab:Slider({Title = "ᴅɪꜱᴛâɴᴄɪᴀ", Value = {Min = 1, Max = 50, Default = 10}, Callback = function(v) State.ReachDistance = v end})
ACTab:Toggle({Title = "ᴠɪꜱᴜᴀʟ ᴅᴏ ʀᴇᴀᴄʜ", Value = false, Callback = function(v)
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
end)--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | ᴘᴀʀᴛᴇ 6/9 — ᴀᴜᴛᴏ ᴅʀɪᴠᴇ ᴘᴜʀᴏ (ɴᴇᴡᴛᴏɴ) ]]

DriveTab = Window:Tab({ Title = "ᴀᴜᴛᴏ ᴅʀɪᴠᴇ", Icon = "car" })

-- ============================================================
-- AUTO CATCH (remote)
-- ============================================================
CatchRemote = nil
pcall(function()
    CatchRemote = ReplicatedStorage:FindFirstChild("CatchBall", true)
end)
AutoCatchEnabled = false
AutoCatchRange = 8
AutoCatchDelay = 1
AutoCatchLast = 0
AC_Hitbox = false
AC_HitboxPart = nil

function TryCatch(ball)
    if not ball or not ball.Parent then return end
    if CatchRemote then
        pcall(function()
            if CatchRemote:IsA("RemoteEvent") then
                CatchRemote:FireServer(ball)
            elseif CatchRemote:IsA("RemoteFunction") then
                CatchRemote:InvokeServer(ball)
            end
        end)
    end
    AutoCatchLast = tick()
end

DriveTab:Section({ Title = "ᴀᴄ ᴀᴜᴛᴏ ᴄᴀᴛᴄʜ (ʀᴇᴍᴏᴛᴇ)" })
DriveTab:Toggle({
    Title = "ᴀᴛɪᴠᴀʀ ᴀᴜᴛᴏ ᴄᴀᴛᴄʜ",
    Desc = "ᴄᴀᴘᴛᴜʀᴀ ᴀ ʙᴏʟᴀ ǫᴜᴀɴᴅᴏ ᴇꜱᴛɪᴠᴇʀ ɴᴏ ᴀʟᴄᴀɴᴄᴇ",
    Value = false,
    Callback = function(v) AutoCatchEnabled = v end,
})
DriveTab:Slider({
    Title = "ᴅɪꜱᴛâɴᴄɪᴀ ᴅᴇ ᴄᴀᴘᴛᴜʀᴀ",
    Value = { Min = 3, Max = 30, Default = 8 },
    Callback = function(v) AutoCatchRange = v end,
})
DriveTab:Slider({
    Title = "ᴄᴏᴏʟᴅᴏᴡɴ",
    Value = { Min = 0.2, Max = 3, Default = 1, Decimal = 1 },
    Callback = function(v) AutoCatchDelay = v end,
})
DriveTab:Toggle({
    Title = "ᴍᴏꜱᴛʀᴀʀ ʜɪᴛʙᴏx",
    Desc = "ᴇxɪʙᴇ ᴇꜱꜰᴇʀᴀ ᴠɪꜱᴜᴀʟ ᴅᴀ áʀᴇᴀ ᴅᴇ ᴄᴀᴘᴛᴜʀᴀ",
    Value = false,
    Callback = function(v) AC_Hitbox = v end,
})

-- ============================================================
-- AUTO CATCH INTELIGENTE
-- ============================================================
AutoCatchIntelEnabled = false
AutoCatchIntelConn = nil
AutoCatchIntelRange = 16
AutoCatchIntelCooldown = 0.35
AutoCatchIntelLast = 0
AutoCatchIntelHeight = 3.5
AutoDiveBloquearSeIntelAtivo = true

function AnalisarBola()
    local ball = GetValidBall()
    if not ball or not RootPart then return nil end
    local vel = ball.AssemblyLinearVelocity
    local dist = (ball.Position - RootPart.Position).Magnitude
    local tempo = 0
    if vel.Magnitude > 3 then
        tempo = dist / vel.Magnitude
        tempo = math.clamp(tempo, 0, 0.6)
    end
    local posFutura = ball.Position + (vel * tempo)
    local camLook = Camera.CFrame.LookVector
    local camRight = Camera.CFrame.RightVector
    local frenteH = Vector3.new(camLook.X, 0, camLook.Z)
    if frenteH.Magnitude < 0.1 then frenteH = Vector3.new(0, 0, -1) end
    frenteH = frenteH.Unit
    local direitaH = Vector3.new(camRight.X, 0, camRight.Z)
    if direitaH.Magnitude < 0.1 then direitaH = Vector3.new(1, 0, 0) end
    direitaH = direitaH.Unit
    local delta = posFutura - RootPart.Position
    local deltaH = Vector3.new(delta.X, 0, delta.Z)
    local ladoX = deltaH:Dot(direitaH)
    local ladoY = posFutura.Y - RootPart.Position.Y
    local frenteDist = deltaH:Dot(frenteH)
    return {
        ball = ball,
        vel = vel,
        dist = dist,
        posFutura = posFutura,
        lado = ladoX,
        altura = ladoY,
        frente = frenteDist,
    }
end

function ExecutarAutoCatchIntel()
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
            local botaoDive = EncontrarBotaoPorTexto(textoDive)
            if botaoDive then ClicarBotao(botaoDive) end
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

function StartAutoCatchIntel()
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
        local dot = velH.Unit:Dot(dirH.Unit)
        if dot > 0.15 then
            AutoCatchIntelLast = tick()
            task.spawn(ExecutarAutoCatchIntel)
        end
    end)
end
function StopAutoCatchIntel()
    if AutoCatchIntelConn then
        AutoCatchIntelConn:Disconnect()
        AutoCatchIntelConn = nil
    end
end

DriveTab:Section({ Title = "ᴀᴜᴛᴏ ᴄᴀᴛᴄʜ ɪɴᴛᴇʟɪɢᴇɴᴛᴇ" })
DriveTab:Toggle({
    Title = "ᴀᴛɪᴠᴀʀ ᴀᴜᴛᴏ ᴄᴀᴛᴄʜ ɪɴᴛᴇʟɪɢᴇɴᴛᴇ",
    Desc = "ʙᴏʟᴀ ᴄᴇɴᴛʀᴀʟ: ᴀɢᴀʀʀᴀ. ʟᴀᴛᴇʀᴀʟ ʙᴀɪxᴀ: ᴀɢᴀʀʀᴀʀ ʙᴀɪxᴏ. ʟᴀᴛᴇʀᴀʟ ᴀʟᴛᴀ: ᴅɪᴠᴇ",
    Value = false,
    Callback = function(v)
        AutoCatchIntelEnabled = v
        if v then StartAutoCatchIntel() else StopAutoCatchIntel() end
    end,
})
DriveTab:Slider({
    Title = "ᴀʟᴄᴀɴᴄᴇ",
    Value = { Min = 5, Max = 35, Default = 16 },
    Callback = function(v) AutoCatchIntelRange = v end,
})
DriveTab:Slider({
    Title = "ᴀʟᴛᴜʀᴀ ᴍíɴɪᴍᴀ (ʙᴏʟᴀ ᴀʟᴛᴀ)",
    Desc = "ᴀᴄɪᴍᴀ ᴅᴇꜱꜱᴀ ᴀʟᴛᴜʀᴀ ᴏ ɢᴏʟᴇɪʀᴏ ᴘᴜʟᴀ/ᴜꜱᴀ ᴀɢᴀʀʀᴀʀ ᴀʟᴛᴏ",
    Value = { Min = 1, Max = 10, Default = 3.5, Decimal = 1 },
    Callback = function(v) AutoCatchIntelHeight = v end,
})
DriveTab:Slider({
    Title = "ᴄᴏᴏʟᴅᴏᴡɴ",
    Value = { Min = 0.1, Max = 2, Default = 0.35, Decimal = 1 },
    Callback = function(v) AutoCatchIntelCooldown = v end,
})

-- ============================================================
-- AUTO DIVE (puro do Newton)
-- ============================================================
AutoDiveEnabled = false
AutoDiveCooldown = 0.8
AutoDiveLastTime = 0
AutoDiveRange = 15
AutoDiveConn = nil
AutoDiveMode = "Auto"

GK_BUTTON_TEXTS = {
    ["Esquerda Alto"] = "High Dive Left",
    ["Direita Alto"]  = "High Dive Right",
    ["Esquerda Baixo"] = "Dive Left",
    ["Direita Baixo"] = "Dive Right",
    ["Agarrar Alto"]  = "High Catch",
    ["Agarrar Baixo"] = "Low Catch",
    ["Reflexo"]       = "Reflex",
    ["Frente"]        = "Front Dive",
    ["Enfrentar"]     = "Rush",
}

function ExecutarDive()
    local ball = GetValidBall()
    if not ball or not RootPart then return end
    local ballVel = ball.AssemblyLinearVelocity
    local distBola = (ball.Position - RootPart.Position).Magnitude
    local tempoChegada = 0
    if ballVel.Magnitude > 5 then
        tempoChegada = math.clamp(distBola / ballVel.Magnitude, 0, 0.7)
    end
    local posFutura = ball.Position + (ballVel * tempoChegada)
    local camRight = Camera.CFrame.RightVector
    local direitaH = Vector3.new(camRight.X, 0, camRight.Z)
    if direitaH.Magnitude < 0.1 then direitaH = Vector3.new(1, 0, 0) end
    direitaH = direitaH.Unit
    local delta = posFutura - RootPart.Position
    local lado = (Vector3.new(delta.X, 0, delta.Z)):Dot(direitaH)
    local altura = delta.Y
    local textoAlvo
    if AutoDiveMode ~= "Auto" then
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

function StartAutoDive()
    if AutoDiveConn then return end
    if #GKBotoes == 0 then EscanearBotoesGK() end
    AutoDiveConn = RunService.Heartbeat:Connect(function()
        if not AutoDiveEnabled then return end
        if AutoDiveBloquearSeIntelAtivo and AutoCatchIntelEnabled then return end
        if not RootPart or not RootPart.Parent then return end
        if tick() - AutoDiveLastTime < AutoDiveCooldown then return end
        local ball = GetValidBall()
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
        local dot = ballVelH.Unit:Dot(dirH.Unit)
        if dot > 0.15 then
            AutoDiveLastTime = tick()
            task.spawn(ExecutarDive)
        end
    end)
end
function StopAutoDive()
    if AutoDiveConn then
        AutoDiveConn:Disconnect()
        AutoDiveConn = nil
    end
end

DriveTab:Section({ Title = "ᴀᴜᴛᴏ ᴅɪᴠᴇ" })
DriveTab:Toggle({
    Title = "ᴀᴛɪᴠᴀʀ ᴀᴜᴛᴏ ᴅɪᴠᴇ",
    Desc = "ᴇxᴇᴄᴜᴛᴀ ᴅɪᴠᴇ ᴀᴜᴛᴏᴍᴀᴛɪᴄᴀᴍᴇɴᴛᴇ ǫᴜᴀɴᴅᴏ ᴀ ʙᴏʟᴀ ᴠᴇᴍ ɴᴀ ꜱᴜᴀ ᴅɪʀᴇçãᴏ",
    Value = false,
    Callback = function(v)
        AutoDiveEnabled = v
        if v then StartAutoDive() else StopAutoDive() end
    end,
})
DriveTab:Dropdown({
    Title = "ᴍᴏᴅᴏ ᴅᴏ ᴅɪᴠᴇ",
    Values = {
        "Auto", "Esquerda Alto", "Direita Alto", "Esquerda Baixo", "Direita Baixo",
        "Agarrar Alto", "Agarrar Baixo", "Reflexo", "Frente", "Enfrentar",
    },
    Value = "Auto",
    Callback = function(v) AutoDiveMode = v end,
})
DriveTab:Slider({
    Title = "ᴀʟᴄᴀɴᴄᴇ ᴅᴏ ᴅɪᴠᴇ",
    Value = { Min = 5, Max = 30, Default = 15 },
    Callback = function(v) AutoDiveRange = v end,
})
DriveTab:Slider({
    Title = "ᴄᴏᴏʟᴅᴏᴡɴ ᴅᴏ ᴅɪᴠᴇ",
    Value = { Min = 0.3, Max = 5, Default = 0.8, Decimal = 1 },
    Callback = function(v) AutoDiveCooldown = v end,
})
DriveTab:Toggle({
    Title = "ᴅɪᴠᴇ ᴘᴀᴜꜱᴀ ǫᴜᴀɴᴅᴏ ɪɴᴛᴇʟ ᴏɴ",
    Desc = "ᴇᴠɪᴛᴀ ᴄᴏɴꜰʟɪᴛᴏ: ꜱᴇ ᴏ ᴀᴜᴛᴏ ᴄᴀᴛᴄʜ ɪɴᴛᴇʟ ᴇꜱᴛɪᴠᴇʀ ʟɪɢᴀᴅᴏ, ᴏ ᴅɪᴠᴇ ɴãᴏ ɪɴᴛᴇʀꜰᴇʀᴇ",
    Value = true,
    Callback = function(v) AutoDiveBloquearSeIntelAtivo = v end,
})
DriveTab:Button({
    Title = "ʀᴇᴇꜱᴄᴀɴᴇᴀʀ ʙᴏᴛõᴇꜱ ɢᴋ",
    Desc = "ᴀᴛᴜᴀʟɪᴢᴀ ᴀ ʟɪꜱᴛᴀ ᴅᴇ ʙᴏᴛõᴇꜱ. ᴜꜱᴇ ꜱᴇ ᴇɴᴛʀᴀʀ ᴄᴏᴍᴏ ɢᴏʟᴇɪʀᴏ ᴅᴇᴘᴏɪꜱ",
    Callback = function()
        EscanearBotoesGK()
        pcall(function() WindUI:Notify({Title = "ᴀᴜᴛᴏ ᴅɪᴠᴇ", Content = #GKBotoes .. " ʙᴏᴛõᴇꜱ ᴇɴᴄᴏɴᴛʀᴀᴅᴏꜱ", Duration = 3}) end)
    end,
})

-- ============================================================
-- AIMBOT (do Newton)
-- ============================================================
AimbotBlueEnabled = false
AimbotGreenEnabled = false

function doAimbot(direcaoGol)
    local ball = GetValidBall()
    if not ball or not ball.Parent then return end
    if not RootPart or not RootPart.Parent then return end
    local vel = ball.AssemblyLinearVelocity
    if vel.Magnitude < 15 then return end
    local golPos = ScanGoalPosition(direcaoGol)
    if not golPos then return end
    local dirGol = (Vector3.new(golPos.X - ball.Position.X, 0, golPos.Z - ball.Position.Z)).Unit
    local velH = Vector3.new(vel.X, 0, vel.Z)
    if velH.Magnitude < 0.1 then return end
    local velAlvo = velH.Unit:Lerp(dirGol, 0.25)
    ball.AssemblyLinearVelocity = Vector3.new(velAlvo.X * velH.Magnitude, vel.Y, velAlvo.Z * velH.Magnitude)
    ball.AssemblyAngularVelocity = Vector3.zero
end

DriveTab:Section({ Title = "ᴀɪᴍʙᴏᴛ ɢᴏʟ" })
DriveTab:Toggle({
    Title = "ᴀɪᴍʙᴏᴛ ʙʟᴜᴇ",
    Desc = "ʀᴇᴅɪʀᴇᴄɪᴏɴᴀ ᴀ ʙᴏʟᴀ ᴘʀᴏ ɢᴏʟ ᴀᴢᴜʟ",
    Value = false,
    Callback = function(v) AimbotBlueEnabled = v end,
})
DriveTab:Toggle({
    Title = "ᴀɪᴍʙᴏᴛ ɢʀᴇᴇɴ",
    Desc = "ʀᴇᴅɪʀᴇᴄɪᴏɴᴀ ᴀ ʙᴏʟᴀ ᴘʀᴏ ɢᴏʟ ᴠᴇʀᴅᴇ",
    Value = false,
    Callback = function(v) AimbotGreenEnabled = v end,
})

-- ============================================================
-- HELPERS GK (botões)
-- ============================================================
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
                or texto:find("Dive") or texto:find("Catch")
                or texto:find("High") or texto:find("Low")
                or texto:find("Reflex") or texto:find("Forward")
                or texto:find("Front") or texto:find("Rush") then
                    table.insert(GKBotoes, {Button = v, Nome = nome, Texto = texto})
                end
            end
        end
    end)
    print("[Auto Dive] Botões GK encontrados:", #GKBotoes)
end
EscanearBotoesGK()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    EscanearBotoesGK()
end)

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
function Pular()
    pcall(function() Humanoid.Jump = true end)
    pcall(function() Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
end

-- ============================================================
-- LOOP PRINCIPAL (AutoCatch / Aimbot)
-- ============================================================
RunService.PreRender:Connect(function()
    if not RootPart or not RootPart.Parent or not Humanoid then return end
    local ball = GetValidBall()

    -- auto catch
    if AutoCatchEnabled and tick() - AutoCatchLast >= AutoCatchDelay then
        local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
        if ball and hrp and (ball.Position - hrp.Position).Magnitude <= AutoCatchRange then
            TryCatch(ball)
        end
    end

    -- hitbox visual
    if AC_Hitbox and RootPart and RootPart.Parent then
        local d = AutoCatchRange * 2
        if not AC_HitboxPart or not AC_HitboxPart.Parent then
            AC_HitboxPart = Instance.new("Part")
            AC_HitboxPart.Name = "Manic_AC_Hitbox"
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

    -- aimbot
    if AimbotBlueEnabled then doAimbot("Blue") end
    if AimbotGreenEnabled then doAimbot("Green") end
end)--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | ᴘᴀʀᴛᴇ 7/9 — ꜰʟᴀɢ ]]

FlagTab = Window:Tab({ Title = "ꜰʟᴀɢ", Icon = "zap" })
FlagTab:Section({ Title = "ᴏᴛɪᴍɪᴢᴀçãᴏ" })

FlagTab:Toggle({Title = "ᴜɴʟᴏᴄᴋ ꜰᴘꜱ", Value = false, Callback = function(v)
    pcall(function() if setfpscap then setfpscap(v and 999 or 60) end end)
end})

AntiLagBackup = {}
FlagTab:Toggle({Title = "ᴀɴᴛɪ ʟᴀɢ", Value = false, Callback = function(v)
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
FlagTab:Toggle({Title = "ᴀɴᴛɪ ꜰʀᴇᴇᴢᴇ", Value = false, Callback = function(v)
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
FlagTab:Toggle({Title = "ᴄᴏɴᴛᴀɪɴᴇʀ", Value = false, Callback = function(v)
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
end})--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | ᴘᴀʀᴛᴇ 8/9 — ᴛʀᴏʟʟ ]]

TrollTab = Window:Tab({ Title = "ᴛʀᴏʟʟ", Icon = "skull" })

LoopBallEnabled = false
LoopBallDistance = 2.5
LoopBallMinSpeed = 5
TrollTab:Section({ Title = "ʟᴏᴏᴘ ʙᴀʟʟ" })
TrollTab:Toggle({Title = "ᴀᴛɪᴠᴀʀ ʟᴏᴏᴘ", Value = false, Callback = function(v)
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
TrollTab:Slider({Title = "ᴠᴇʟᴏᴄɪᴅᴀᴅᴇ ᴍɪɴɪᴍᴀ", Value = {Min = 1, Max = 30, Default = 5}, Callback = function(v) LoopBallMinSpeed = v end})
TrollTab:Slider({Title = "ᴅɪꜱᴛâɴᴄɪᴀ", Value = {Min = 1, Max = 8, Default = 2.5, Decimal = 1}, Callback = function(v) LoopBallDistance = v end})

ImaBallEnabled = false
ImaBallForce = 60
ImaBallRange = 40
TrollTab:Section({ Title = "íᴍᴀ ʙᴀʟʟ" })
TrollTab:Toggle({Title = "ᴀᴛɪᴠᴀʀ íᴍᴀ", Value = false, Callback = function(v)
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
TrollTab:Slider({Title = "ꜰᴏʀçᴀ", Value = {Min = 10, Max = 200, Default = 60}, Callback = function(v) ImaBallForce = v end})
TrollTab:Slider({Title = "ᴀʟᴄᴀɴᴄᴇ", Value = {Min = 5, Max = 100, Default = 40}, Callback = function(v) ImaBallRange = v end})

FlingBallForce = 300
TrollTab:Section({ Title = "ꜰʟɪɴɢ ʙᴀʟʟ" })
TrollTab:Button({Title = "ꜰʟɪɴɢ ʙᴀʟʟ", Callback = function()
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
TrollTab:Slider({Title = "ꜰᴏʀçᴀ", Value = {Min = 100, Max = 800, Default = 300}, Callback = function(v) FlingBallForce = v end})

TrollTab:Section({ Title = "ꜱɪʟᴇɴᴛ ᴀɪᴍ" })
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

TrollTab:Toggle({Title = "ꜱɪʟᴇɴᴛ ᴀɪᴍ", Value = false, Callback = function(v) SilentAimEnabled = v end})
TrollTab:Dropdown({Title = "ᴍᴏᴅᴏ", Values = {"Nearest", "LowestHP"}, Value = "Nearest", Callback = function(v) SilentAimTargetMode = v end})
TrollTab:Slider({Title = "ᴀʟᴄᴀɴᴄᴇ", Value = {Min = 20, Max = 500, Default = 150}, Callback = function(v) SilentAimRange = v end})
TrollTab:Slider({Title = "ᴄᴏᴏʟᴅᴏᴡɴ", Value = {Min = 1, Max = 100, Default = 15, Suffix = " x0.01s"}, Callback = function(v) SilentAimCooldown = v / 100 end})
TrollTab:Toggle({Title = "ᴍᴏꜱᴛʀᴀʀ ᴀʟᴠᴏ", Value = false, Callback = function(v) SilentAimShowTarget = v end})

TrollTab:Section({ Title = "ᴄʜᴜᴛᴇ ꜱɪʟᴇɴᴄɪᴏꜱᴏ" })
SilentKickEnabled = false
SilentKickMode = "Nearest"
SilentKickRange = 50
SilentKickPower = 250
SilentKickCooldown = 1
SilentKickLast = 0

TrollTab:Toggle({Title = "ᴄʜᴜᴛᴇ ꜱɪʟᴇɴᴄɪᴏꜱᴏ", Value = false, Callback = function(v)
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
TrollTab:Dropdown({Title = "ᴍᴏᴅᴏ", Values = {"Nearest", "All"}, Value = "Nearest", Callback = function(v) SilentKickMode = v end})
TrollTab:Slider({Title = "ᴀʟᴄᴀɴᴄᴇ", Value = {Min = 10, Max = 200, Default = 50}, Callback = function(v) SilentKickRange = v end})
TrollTab:Slider({Title = "ꜰᴏʀçᴀ", Value = {Min = 100, Max = 800, Default = 250}, Callback = function(v) SilentKickPower = v end})
TrollTab:Slider({Title = "ᴄᴏᴏʟᴅᴏᴡɴ", Value = {Min = 1, Max = 100, Default = 10, Suffix = " x0.1s"}, Callback = function(v) SilentKickCooldown = v / 10 end})--[[ 𝙼𝙰𝙽𝙰𝚁𝙲.𝙶𝚉𝚈 | ᴘᴀʀᴛᴇ 9/9 — ᴄʀéᴅɪᴛᴏꜱ + ꜰɪɴᴀʟɪᴢᴀçãᴏ ]]

-- ============================================================
-- ABA CRÉDITOS
-- ============================================================
CreditosTab = Window:Tab({ Title = "ᴄʀéᴅɪᴛᴏꜱ", Icon = "heart" })

CreditosTab:Section({ Title = "ᴅᴏɴᴏ ᴅᴏ ꜱᴄʀɪᴘᴛ" })
CreditosTab:Button({
    Title = "𝕿𝖍𝖊𝕬𝖓𝖌𝖊𝖑𝕭𝖆𝖓𝖉𝖝𝖘",
    Desc = "ᴄʀɪᴀᴅᴏʀ ᴇ ᴅᴏɴᴏ ᴅᴏ ꜱᴄʀɪᴘᴛ",
    Callback = function()
        pcall(function()
            if setclipboard then setclipboard("𝕿𝖍𝖊𝕬𝖓𝖌𝖊𝖑𝕭𝖆𝖓𝖉𝖝𝖘") end
        end)
        pcall(function() WindUI:Notify({Title = "ᴄʀéᴅɪᴛᴏꜱ", Content = "ᴄᴏᴘɪᴀᴅᴏ: 𝕿𝖍𝖊𝕬𝖓𝖌𝖊𝖑𝕭𝖆𝖓𝖉𝖝𝖘", Duration = 3}) end)
    end,
})

CreditosTab:Section({ Title = "ᴀʟɪᴀᴅᴏ" })
CreditosTab:Button({
    Title = "xinelo_fps001_20098",
    Desc = "ᴀʟɪᴀᴅᴏ ᴅᴏ ᴘʀᴏᴊᴇᴛᴏ",
    Callback = function()
        pcall(function()
            if setclipboard then setclipboard("xinelo_fps001_20098") end
        end)
        pcall(function() WindUI:Notify({Title = "ᴄʀéᴅɪᴛᴏꜱ", Content = "ᴄᴏᴘɪᴀᴅᴏ: xinelo_fps001_20098", Duration = 3}) end)
    end,
})

CreditosTab:Section({ Title = "ᴅɪꜱᴄᴏʀᴅ" })
CreditosTab:Button({
    Title = "ᴇɴᴛʀᴀʀ ɴᴏ ᴅɪꜱᴄᴏʀᴅ",
    Desc = "discord.gg/UrUwUPhYP",
    Callback = function()
        pcall(function()
            if setclipboard then setclipboard("https://discord.gg/UrUwUPhYP") end
        end)
        pcall(function() WindUI:Notify({Title = "ᴅɪꜱᴄᴏʀᴅ", Content = "ʟɪɴᴋ ᴄᴏᴘɪᴀᴅᴏ! ᴄᴏʟᴇ ɴᴏ ɴᴀᴠᴇɢᴀᴅᴏʀ", Duration = 4}) end)
    end,
})

CreditosTab:Section({ Title = "ᴀɢʀᴀᴅᴇᴄɪᴍᴇɴᴛᴏꜱ" })
CreditosTab:Button({
    Title = "ᴏʙʀɪɢᴀᴅᴏ ᴘᴏʀ ᴜꜱᴀʀ",
    Desc = "ᴄᴏᴍᴘᴀʀᴛɪʟʜᴇ ᴄᴏᴍ ᴏꜱ ᴀᴍɪɢᴏꜱ",
    Callback = function()
        pcall(function() WindUI:Notify({Title = "ᴍᴀɴᴀʀᴄ.ɢᴢʏ", Content = "ᴠᴀʟᴇᴜ ᴘᴇʟᴏ ᴀᴘᴏɪᴏ", Duration = 3}) end)
    end,
})
CreditosTab:Button({
    Title = "ᴠᴇʀꜱãᴏ: ᴠ4.0",
    Desc = "ᴀᴜᴛᴏ ᴅʀɪᴠᴇ ᴘʀᴏ + ᴀɪᴍʙᴏᴛ + ꜱᴋʏʙᴏx ᴄᴜꜱᴛᴏᴍ",
    Callback = function() end,
})

-- ============================================================
-- FINALIZAÇÃO
-- ============================================================
task.spawn(function()
    task.wait(0.6)
    pcall(function() Window:SelectTab(1) end)
    pcall(function() Window:Toggle() end)
    task.wait(0.2)
    pcall(function() Window:Toggle() end)
end)

print("[MANARC.GZY] SCRIPT COMPLETO CARREGADO - PARTES 1/9 A 9/9 OK")
print("[MANARC.GZY] DONO: TheAngelBandxs | ALIADO: xinelo_fps001_20098")
print("[MANARC.GZY] DISCORD: https://discord.gg/UrUwUPhYP")
print("[MANARC.GZY] TOTALMENTE INICIADO - BOA SORTE!")

pcall(function()
    WindUI:Notify({Title = "ᴍᴀɴᴀʀᴄ.ɢᴢʏ", Content = "ꜱᴄʀɪᴘᴛ ᴄᴏᴍᴘʟᴇᴛᴏ", Duration = 6, Icon = "check-circle"})
end)
