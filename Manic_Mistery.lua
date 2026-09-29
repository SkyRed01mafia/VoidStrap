--[[ MANIC HUB - MM Edition | PARTE 1/6 — Base + WindUI ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

getgenv().ManicMM = getgenv().ManicMM or {}
local Flags = getgenv().ManicMM

-- Personagem
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local function UpdateChar(c)
    Character = c
    Humanoid = c:WaitForChild("Humanoid")
    RootPart = c:WaitForChild("HumanoidRootPart")
end
LocalPlayer.CharacterAdded:Connect(UpdateChar)

-- ============================================
-- WINDUI
-- ============================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Manic Hub",
    Icon = "knife",
    Author = "MM Edition",
    Folder = "ManicMM",
    Size = UDim2.fromOffset(620, 480),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true,
    Background = "rbxassetid://11717400651",
    BackgroundImageTransparency = 0.35,
})

Window:Tag({
    Title = "v1.0",
    Icon = "sparkles",
    Color = Color3.fromHex("#b41e1e"),
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

-- ============================================
-- DETECÇÃO DE ROLES
-- ============================================
local RoleCache = {}

function DetectarRole(player)
    if not player or not player.Character then
        return RoleCache[player.Name] or "Innocent"
    end
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character

    local function CheckContainer(container)
        if not container then return nil end
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:find("knife") or n:find("faca") then
                    return "Murderer"
                end
                if n:find("gun") or n:find("pistol") or n:find("revolver") or n:find("sheriff") then
                    return "Sheriff"
                end
            end
        end
        return nil
    end

    local role = CheckContainer(backpack) or CheckContainer(char)
    if role then
        RoleCache[player.Name] = role
        return role
    end

    return RoleCache[player.Name] or "Innocent"
end

-- Atualiza cache
task.spawn(function()
    while true do
        task.wait(0.5)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                DetectarRole(p)
            end
        end
    end
end)--[[ MANIC HUB - MM Edition | PARTE 2/6 — ᴄᴏᴍʙᴀᴛ ]]

local CombatTab = Window:Tab({ Title = "ᴄᴏᴍʙᴀᴛ", Icon = "sword" })
CombatTab:Section({ Title = "ᴀɪᴍʙᴏᴛ ꜰᴀᴄᴀ" })

local AimbotEnabled = false
local AimbotTeamCheck = false
local AimbotRange = 200
local AimbotCooldown = 0.5
local AimbotLast = 0
local AimbotAutoThrow = true

local function GetClosestTarget()
    local closest, closestDist = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
            local tHum = p.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and tHum and tHum.Health > 0 then
                local dist = (tRoot.Position - myRoot.Position).Magnitude
                if dist < closestDist and dist <= AimbotRange then
                    if AimbotTeamCheck then
                        local role = DetectarRole(p)
                        if role == "Sheriff" then
                            -- Pula
                        else
                            closestDist = dist
                            closest = p
                        end
                    else
                        closestDist = dist
                        closest = p
                    end
                end
            end
        end
    end
    return closest
end

local function FindKnife()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character

    local function Search(container)
        if not container then return nil end
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:find("knife") or n:find("faca") then
                    return tool
                end
            end
        end
        return nil
    end

    return Search(char) or Search(backpack)
end

function ExecutarAimbot()
    if not AimbotEnabled then return end
    if tick() - AimbotLast < AimbotCooldown then return end

    local target = GetClosestTarget()
    if not target or not target.Character then return end

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not tRoot then return end

    -- Mira no alvo
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, tRoot.Position)

    -- Usa faca se tiver
    local knife = FindKnife()
    if knife then
        pcall(function() knife:Activate() end)
    elseif AimbotAutoThrow then
        -- Simula clique do mouse no centro da tela
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(
                Camera.ViewportSize.X / 2,
                Camera.ViewportSize.Y / 2,
                0, true, game, 1
            )
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(
                Camera.ViewportSize.X / 2,
                Camera.ViewportSize.Y / 2,
                0, false, game, 1
            )
        end)
    end

    AimbotLast = tick()
end

-- Loop do Aimbot
RunService.Heartbeat:Connect(function()
    if AimbotEnabled then
        task.spawn(ExecutarAimbot)
    end
end)

CombatTab:Toggle({
    Title = "ᴀɪᴍʙᴏᴛ ꜰᴀᴄᴀ",
    Desc = "ᴀᴄᴇʀᴛᴀ ᴀᴜᴛᴏᴍᴀᴛɪᴄᴀᴍᴇɴᴛᴇ ᴏ ᴊᴏɢᴀᴅᴏʀ ᴍᴀɪs ᴘʀᴏxɪᴍᴏ",
    Value = false,
    Callback = function(v) AimbotEnabled = v end,
})

CombatTab:Toggle({
    Title = "ɪɢɴᴏʀᴀʀ sʜᴇʀɪꜰꜰ",
    Desc = "ɴᴀᴏ ᴀᴛɪʀᴀ ɴᴏ sʜᴇʀɪꜰꜰ",
    Value = false,
    Callback = function(v) AimbotTeamCheck = v end,
})

CombatTab:Toggle({
    Title = "ᴀᴜᴛᴏ ᴛʜʀᴏᴡ",
    Desc = "ᴀᴛɪʀᴀ ᴀ ꜰᴀᴄᴀ ᴀᴜᴛᴏᴍᴀᴛɪᴄᴀᴍᴇɴᴛᴇ ᴀᴏ ᴛʀᴀᴠᴀʀ",
    Value = true,
    Callback = function(v) AimbotAutoThrow = v end,
})

CombatTab:Slider({
    Title = "ᴀʟᴄᴀɴᴄᴇ",
    Value = { Min = 10, Max = 500, Default = 200 },
    Callback = function(v) AimbotRange = v end,
})

CombatTab:Slider({
    Title = "ᴄᴏᴏʟᴅᴏᴡɴ (x100ms)",
    Value = { Min = 1, Max = 20, Default = 5 },
    Callback = function(v) AimbotCooldown = v / 10 end,
})--[[ MANIC HUB - MM Edition | PARTE 3/6 — ᴇsᴘ ]]

local EspTab = Window:Tab({ Title = "ᴇsᴘ", Icon = "eye" })
EspTab:Section({ Title = "ᴅᴇsᴄᴏʙʀɪʀ ʀᴏʟᴇs" })

local RoleESPEnabled = false
local RoleESPConn = nil

local function CriarESP(player, role)
    if not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end

    local existing = head:FindFirstChild("ManicRoleESP")
    if existing then existing:Destroy() end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ManicRoleESP"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0
    text.TextStrokeColor3 = Color3.new(0, 0, 0)

    if role == "Murderer" then
        text.Text = "MURDERER"
        text.TextColor3 = Color3.fromRGB(255, 50, 50)
    elseif role == "Sheriff" then
        text.Text = "SHERIFF"
        text.TextColor3 = Color3.fromRGB(50, 150, 255)
    else
        text.Text = "INNOCENT"
        text.TextColor3 = Color3.fromRGB(100, 255, 100)
    end

    text.Parent = billboard
end

local function LimparESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local esp = head:FindFirstChild("ManicRoleESP")
                if esp then esp:Destroy() end
            end
        end
    end
end

local function IniciarRoleESP()
    if RoleESPConn then return end
    RoleESPConn = RunService.Heartbeat:Connect(function()
        if not RoleESPEnabled then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local role = DetectarRole(p)
                CriarESP(p, role)
            end
        end
    end)
end

EspTab:Toggle({
    Title = "ᴇsᴘ ᴅᴇ ʀᴏʟᴇs",
    Desc = "ᴍᴏsᴛʀᴀ ᴏ ɴᴏᴍᴇ ᴅᴀ ʀᴏʟᴇ ᴀᴄɪᴍᴀ ᴅᴀ ᴄᴀʙᴇᴄᴀ",
    Value = false,
    Callback = function(v)
        RoleESPEnabled = v
        if v then IniciarRoleESP() else LimparESP() end
    end,
})

EspTab:Button({
    Title = "ᴀᴛᴜᴀʟɪᴢᴀʀ ᴄᴀᴄʜᴇ ᴅᴇ ʀᴏʟᴇs",
    Desc = "ғᴏʀᴄᴀ ʀᴇ-ᴅᴇᴛᴇᴄᴄᴀᴏ",
    Callback = function()
        RoleCache = {}
        WindUI:Notify({Title = "ᴇsᴘ", Content = "Cache atualizado", Duration = 2})
    end,
})

-- ============================================
-- ALERTAS
-- ============================================
EspTab:Section({ Title = "ᴀʟᴇʀᴛᴀs" })

local AlertMurdererEnabled = false
local AlertSheriffEnabled = false
local NotificadoMurderer = false
local NotificadoSheriff = false
local AlertRange = 100

EspTab:Toggle({
    Title = "ᴀʟᴇʀᴛᴀʀ sᴇ ᴍᴜʀᴅᴇʀᴇʀ ᴇsᴛɪᴠᴇʀ ᴘᴇʀᴛᴏ",
    Desc = "ɴᴏᴛɪғɪᴄᴀᴄᴀᴏ ᴠɪsᴜᴀʟ ǫᴜᴀɴᴅᴏ ᴏ ᴍᴜʀᴅᴇʀᴇʀ ᴀᴘᴀʀᴇᴄᴇ",
    Value = false,
    Callback = function(v)
        AlertMurdererEnabled = v
        NotificadoMurderer = false
    end,
})

EspTab:Toggle({
    Title = "ᴀʟᴇʀᴛᴀʀ sᴇ sʜᴇʀɪꜰꜰ ᴇsᴛɪᴠᴇʀ ᴘᴇʀᴛᴏ",
    Desc = "ɴᴏᴛɪғɪᴄᴀᴄᴀᴏ ᴠɪsᴜᴀʟ ǫᴜᴀɴᴅᴏ ᴏ sʜᴇʀɪꜰꜰ ᴀᴘᴀʀᴇᴄᴇ",
    Value = false,
    Callback = function(v)
        AlertSheriffEnabled = v
        NotificadoSheriff = false
    end,
})

EspTab:Slider({
    Title = "ᴀʟᴄᴀɴᴄᴇ ᴅᴏ ᴀʟᴇʀᴛᴀ",
    Value = { Min = 20, Max = 300, Default = 100 },
    Callback = function(v) AlertRange = v end,
})

task.spawn(function()
    while true do
        task.wait(0.5)
        if AlertMurdererEnabled or AlertSheriffEnabled then
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                        if tRoot then
                            local dist = (tRoot.Position - myRoot.Position).Magnitude
                            if dist < AlertRange then
                                local role = DetectarRole(p)
                                if role == "Murderer" and AlertMurdererEnabled and not NotificadoMurderer then
                                    NotificadoMurderer = true
                                    WindUI:Notify({
                                        Title = "ALERTA",
                                        Content = p.Name .. " E O MURDERER!",
                                        Duration = 4,
                                        Icon = "alert-triangle"
                                    })
                                elseif role == "Sheriff" and AlertSheriffEnabled and not NotificadoSheriff then
                                    NotificadoSheriff = true
                                    WindUI:Notify({
                                        Title = "ALERTA",
                                        Content = p.Name .. " E O SHERIFF!",
                                        Duration = 4,
                                        Icon = "info"
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)--[[ MANIC HUB - MM Edition | PARTE 4/6 — ᴅᴏᴅɢᴇ ]]

local DodgeTab = Window:Tab({ Title = "ᴅᴏᴅɢᴇ", Icon = "shield" })
DodgeTab:Section({ Title = "ᴅᴇsᴠɪᴀʀ ᴅᴇ ᴀᴛᴀǫᴜᴇs" })

local DodgeKnifeEnabled = false
local DodgeGunEnabled = false
local DodgeRange = 15
local DodgeConn = nil
local DodgeCooldown = 0
local DodgeForce = 60

local function IniciarDodge()
    if DodgeConn then return end
    DodgeConn = RunService.Heartbeat:Connect(function()
        if not DodgeKnifeEnabled and not DodgeGunEnabled then return end
        if tick() < DodgeCooldown then return end
        if not RootPart or not Humanoid then return end

        local myPos = RootPart.Position

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    local dist = (tRoot.Position - myPos).Magnitude
                    if dist < DodgeRange then
                        local role = DetectarRole(p)
                        local deveDodge = false
                        if role == "Murderer" and DodgeKnifeEnabled then
                            deveDodge = true
                        elseif role == "Sheriff" and DodgeGunEnabled then
                            deveDodge = true
                        end
                        if deveDodge then
                            local dir = (myPos - tRoot.Position)
                            local flat = Vector3.new(dir.X, 0, dir.Z)
                            if flat.Magnitude > 0.1 then
                                local dodgeDir = flat.Unit
                                RootPart.Velocity = dodgeDir * DodgeForce + Vector3.new(0, 30, 0)
                                DodgeCooldown = tick() + 0.6
                            end
                            break
                        end
                    end
                end
            end
        end
    end)
end

DodgeTab:Toggle({
    Title = "ᴅᴇsᴠɪᴀʀ ᴅᴀ ꜰᴀᴄᴀ",
    Desc = "ᴅᴇsᴠɪᴀ ᴀᴜᴛᴏᴍᴀᴛɪᴄᴀᴍᴇɴᴛᴇ ǫᴜᴀɴᴅᴏ ᴍᴜʀᴅᴇʀᴇʀ ᴀᴘᴀʀᴇᴄᴇ",
    Value = false,
    Callback = function(v)
        DodgeKnifeEnabled = v
        if v then IniciarDodge() end
    end,
})

DodgeTab:Toggle({
    Title = "ᴅᴇsᴠɪᴀʀ ᴅᴏ ᴛɪʀᴏ",
    Desc = "ᴅᴇsᴠɪᴀ ᴀᴜᴛᴏᴍᴀᴛɪᴄᴀᴍᴇɴᴛᴇ ǫᴜᴀɴᴅᴏ sʜᴇʀɪꜰꜰ ᴀᴛɪʀᴀ",
    Value = false,
    Callback = function(v)
        DodgeGunEnabled = v
        if v then IniciarDodge() end
    end,
})

DodgeTab:Slider({
    Title = "ᴀʟᴄᴀɴᴄᴇ ᴅᴇ ᴅᴏᴅɢᴇ",
    Value = { Min = 5, Max = 50, Default = 15 },
    Callback = function(v) DodgeRange = v end,
})

DodgeTab:Slider({
    Title = "ꜰᴏʀᴄᴀ ᴅᴏ ᴅᴏᴅɢᴇ",
    Value = { Min = 20, Max = 150, Default = 60 },
    Callback = function(v) DodgeForce = v end,
})

DodgeTab:Section({ Title = "sᴛᴀᴛᴜs" })

local DodgeStatusLabel = "ᴅᴏᴅɢᴇ ᴅᴇsᴀᴛɪᴠᴀᴅᴏ"

DodgeTab:Button({
    Title = "ᴠᴇʀ sᴛᴀᴛᴜs ᴅᴏ ᴅᴏᴅɢᴇ",
    Callback = function()
        local status = "Desativado"
        if DodgeKnifeEnabled or DodgeGunEnabled then
            status = "Ativado"
            if DodgeKnifeEnabled and DodgeGunEnabled then
                status = "Faca + Tiro"
            elseif DodgeKnifeEnabled then
                status = "Apenas Faca"
            elseif DodgeGunEnabled then
                status = "Apenas Tiro"
            end
        end
        WindUI:Notify({
            Title = "ᴅᴏᴅɢᴇ",
            Content = "Status: " .. status,
            Duration = 2
        })
    end,
})--[[ MANIC HUB - MM Edition | PARTE 5/6 — ᴠɪsᴜᴀʟ ]]

local VisualTab = Window:Tab({ Title = "ᴠɪsᴜᴀʟ", Icon = "user" })
VisualTab:Section({ Title = "ɪɴᴠɪsɪʙɪʟɪᴅᴀᴅᴇ" })

local InvisEnabled = false
local InvisConn = nil
local OriginalTransparency = {}

local function AtivarInvis()
    if InvisConn then InvisConn:Disconnect() end
    InvisConn = RunService.Heartbeat:Connect(function()
        if not InvisEnabled then return end
        if not Character then return end
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                if not OriginalTransparency[part] then
                    OriginalTransparency[part] = part.Transparency
                end
                part.Transparency = 1
                part.CanCollide = false
            elseif part:IsA("Decal") or part:IsA("Texture") then
                if not OriginalTransparency[part] then
                    OriginalTransparency[part] = part.Transparency
                end
                part.Transparency = 1
            end
        end
    end)
end

local function DesativarInvis()
    if InvisConn then
        InvisConn:Disconnect()
        InvisConn = nil
    end
    for part, val in pairs(OriginalTransparency) do
        if part and part.Parent then
            pcall(function() part.Transparency = val end)
        end
    end
    OriginalTransparency = {}
    if Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.Transparency = 0
                    part.CanCollide = true
                end)
            end
        end
    end
end

VisualTab:Toggle({
    Title = "ɪɴᴠɪsɪʙɪʟɪᴅᴀᴅᴇ",
    Desc = "ғɪᴄᴀ ɪɴᴠɪsɪᴠᴇʟ ᴘᴀʀᴀ ᴏs ᴏᴜᴛʀᴏs",
    Value = false,
    Callback = function(v)
        InvisEnabled = v
        if v then AtivarInvis() else DesativarInvis() end
    end,
})

VisualTab:Section({ Title = "ᴍᴏᴠɪᴍᴇɴᴛᴏ" })

local SpeedEnabled = false
local SpeedValue = 22

VisualTab:Toggle({
    Title = "sᴘᴇᴇᴅ",
    Desc = "ᴀᴜᴍᴇɴᴛᴀ ᴀ ᴠᴇʟᴏᴄɪᴅᴀᴅᴇ",
    Value = false,
    Callback = function(v)
        SpeedEnabled = v
        if Humanoid then
            Humanoid.WalkSpeed = v and SpeedValue or 16
        end
    end,
})

VisualTab:Slider({
    Title = "ᴠᴇʟᴏᴄɪᴅᴀᴅᴇ",
    Value = { Min = 16, Max = 100, Default = 22 },
    Callback = function(v)
        SpeedValue = v
        if SpeedEnabled and Humanoid then
            Humanoid.WalkSpeed = v
        end
    end,
})

-- Reaplica speed ao respawnar
LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    if SpeedEnabled and Humanoid then
        Humanoid.WalkSpeed = SpeedValue
    end
    if InvisEnabled then
        AtivarInvis()
    end
end)

VisualTab:Section({ Title = "ᴄâᴍᴇʀᴀ" })

local FOVEnabled = false
local FOVValue = 70

VisualTab:Toggle({
    Title = "ᴄᴜsᴛᴏᴍ ꜰᴏᴠ",
    Desc = "ᴀʟᴛᴇʀᴀ ᴏ ꜰᴏᴠ ᴅᴀ ᴄâᴍᴇʀᴀ",
    Value = false,
    Callback = function(v) FOVEnabled = v end,
})

VisualTab:Slider({
    Title = "ꜰᴏᴠ",
    Value = { Min = 30, Max = 120, Default = 70 },
    Callback = function(v) FOVValue = v end,
})

RunService.RenderStepped:Connect(function()
    if FOVEnabled then
        Camera.FieldOfView = FOVValue
    end
end)--[[ MANIC HUB - MM Edition | PARTE 6/6 — ʙᴏᴏᴍ ʙᴏx + ɪɴꜰᴏ ]]

local BoomTab = Window:Tab({ Title = "ʙᴏᴏᴍ ʙᴏx", Icon = "music" })
BoomTab:Section({ Title = "ᴍᴜsɪᴄᴀs" })

local BoomSound = nil
local BoomVolume = 2

local function TocarMusica(id)
    pcall(function()
        if BoomSound then BoomSound:Destroy() end
        BoomSound = Instance.new("Sound")
        BoomSound.SoundId = "rbxassetid://" .. id
        BoomSound.Volume = BoomVolume
        BoomSound.Looped = false
        BoomSound.Parent = Character:FindFirstChild("HumanoidRootPart") or Workspace
        BoomSound:Play()
    end)
end

BoomTab:Slider({
    Title = "ᴠᴏʟᴜᴍᴇ",
    Value = { Min = 1, Max = 10, Default = 2 },
    Callback = function(v)
        BoomVolume = v
        if BoomSound then BoomSound.Volume = v end
    end,
})

BoomTab:Button({
    Title = "🎵 ᴍᴇᴀɴᴛ ᴛᴏ ʙᴇ",
    Callback = function() TocarMusica("84321228471359") end,
})

BoomTab:Button({
    Title = "🎵 sᴏᴍᴇᴛɪᴍᴇs",
    Callback = function() TocarMusica("128715303988843") end,
})

BoomTab:Button({
    Title = "🎵 ʙʟᴏᴅʟʏɴ ʙʟᴏᴏᴅᴘᴏᴘ",
    Callback = function() TocarMusica("96414211708215") end,
})

BoomTab:Input({
    Title = "ɪᴅ ᴅᴀ ᴍᴜsɪᴄᴀ",
    Placeholder = "ɪᴅ...",
    Callback = function(text)
        if text and text ~= "" then
            TocarMusica(text)
        end
    end,
})

BoomTab:Button({
    Title = "ᴘᴀʀᴀʀ ᴍᴜsɪᴄᴀ",
    Callback = function()
        if BoomSound then
            pcall(function() BoomSound:Stop(); BoomSound:Destroy() end)
            BoomSound = nil
        end
    end,
})

-- ============================================
-- ABA ɪɴꜰᴏ
-- ============================================
local InfoTab = Window:Tab({ Title = "ɪɴꜰᴏ", Icon = "info" })
InfoTab:Section({ Title = "sᴏʙʀᴇ" })

InfoTab:Button({
    Title = "ᴠᴇʀsᴀᴏ: ᴠ1.0",
    Desc = "ᴍᴀɴɪᴄ ʜᴜʙ • ᴍᴍ ᴇᴅɪᴛɪᴏɴ",
    Callback = function() end,
})

InfoTab:Button({
    Title = "ᴀᴛᴀʟʜᴏ: ʟᴇꜰᴛsʜɪꜰᴛ",
    Desc = "ᴀʙʀᴇ/ꜰᴇᴄʜᴀ ᴏ ᴍᴇɴᴜ",
    Callback = function() end,
})

InfoTab:Button({
    Title = "ʀᴇᴄᴀʀʀᴇɢᴀʀ ʀᴏʟᴇs",
    Desc = "ʟɪᴍᴘᴀ ᴏ ᴄᴀᴄʜᴇ ᴅᴇ ʀᴏʟᴇs",
    Callback = function()
        RoleCache = {}
        WindUI:Notify({Title = "ɪɴꜰᴏ", Content = "Cache limpo", Duration = 2})
    end,
})

InfoTab:Section({ Title = "ᴄʀᴇᴅɪᴛᴏs" })

InfoTab:Button({
    Title = "ᴄʀɪᴀᴅᴏ ᴘᴏʀ: 𝕿𝖍𝖊𝕬𝖓𝖌𝖊𝖑𝕃𝖆𝖓𝖉𝖝𝖘",
    Desc = "ᴍᴀɴɪᴄ ʜᴜʙ • ᴍᴍ ᴇᴅɪᴛɪᴏɴ",
    Callback = function()
        pcall(function()
            if setclipboard then setclipboard("𝕿𝖍𝖊𝕬𝖓𝖌𝖊𝖑𝕃𝖆𝖓𝖉𝖝𝖘") end
        end)
        WindUI:Notify({Title = "ɪɴꜰᴏ", Content = "Nome copiado", Duration = 2})
    end,
})

InfoTab:Button({
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

print("[MANIC HUB - MM] Carregado com sucesso!")
print("[MANIC HUB - MM] ᴄʀɪᴀᴅᴏ ᴘᴏʀ: 𝕿𝖍𝖊𝕬𝖓𝖌𝖊𝖑𝕃𝖆𝖓𝖉𝖝𝖘")
