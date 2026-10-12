local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

local parentGui = CoreGui
pcall(function()
    if type(gethui) == "function" then
        local ok, res = pcall(gethui)
        if ok and res then parentGui = res end
    end
end)
if not parentGui or typeof(parentGui) ~= "Instance" then parentGui = CoreGui end
local testOK = pcall(function()
    local t = Instance.new("Folder")
    t.Parent = parentGui
    t:Destroy()
end)
if not testOK then parentGui = CoreGui end

pcall(function()
    if parentGui and parentGui.FindFirstChild then
        local old = parentGui:FindFirstChild("SlowHub")
        if old then old:Destroy() end
        local old2 = parentGui:FindFirstChild("SlowHubKey")
        if old2 then old2:Destroy() end
    end
end)

local BG = Color3.fromRGB(16, 16, 20)
local PANEL = Color3.fromRGB(28, 28, 34)
local CARD = Color3.fromRGB(38, 38, 46)
local ACCENT = Color3.fromRGB(80, 180, 255)
local TEXT = Color3.fromRGB(240, 240, 250)
local TEXTDIM = Color3.fromRGB(150, 150, 165)
local SUCCESS = Color3.fromRGB(70, 200, 120)
local DANGER = Color3.fromRGB(230, 80, 90)
local STROKE = Color3.fromRGB(90, 90, 100)
local PURPLE_BORDER = Color3.fromRGB(40, 100, 220)

TOGGLE_ON_COLOR = Color3.fromRGB(50, 200, 100)
GOLD_COLOR = Color3.fromRGB(255, 215, 0)

-- ═══════════════════════════════════════════════════════════
-- 🔑 SLOWHUB — CONFIGURAÇÃO DO KEY SYSTEM (RedstoneGuard)
-- ═══════════════════════════════════════════════════════════
KEY_CONFIG = {
    Logo = "rbxassetid://71605643769617",
    Title = "Slow Hub",
    Subtitle = "Authentication System",
    DiscordInvite = "https://discord.gg/DFaVxbxMmG",
    DiscordLogo = "rbxassetid://125310003685274",
    RedstoneURL = "https://redstoneguard.xyz/key-system/a71c40c4-c64d-42dd-89e9-57db3bac8caa",
    SDKUrl = "https://redstoneguard.xyz/redstoneguard-sdk.lua",
    KeyFile = "slowhub_key.txt",
    PermFile = "slowhub_perm.txt",
    Providers = {
        {
            Name = "LootLabs",
            Logo = "rbxassetid://100564232544318",
            Color = Color3.fromRGB(255, 197, 0),
            Hover = Color3.fromRGB(255, 220, 100),
        },
        {
            Name = "Linkvertise",
            Logo = "rbxassetid://133637250102434",
            Color = Color3.fromRGB(67, 229, 94),
            Hover = Color3.fromRGB(120, 245, 140),
        },
        {
            Name = "Work.ink",
            Logo = "rbxassetid://132330349768681",
            Color = Color3.fromRGB(4, 107, 210),
            Hover = Color3.fromRGB(60, 150, 240),
        },
    },
}

-- Compatibilidade com o código antigo
KEY = "SlowHubVIP"
DISCORD_LINK = KEY_CONFIG.DiscordInvite
SCRIPT_URL = "https://raw.githubusercontent.com/slow-develp/slowhub/main/slowhub.lua"

ICONS = {
    Home = "rbxassetid://111637692403997",
    Person = "rbxassetid://118410078119588",
    Eye = "rbxassetid://7546367582",
    Box = "rbxassetid://87246322401825",
    Door = "rbxassetid://138668025068101",
    Lightning = "rbxassetid://4177217854",
    Info = "rbxassetid://11780939099",
    Star = "rbxassetid://89172331085803",
    Config = "rbxassetid://103052477976081",
    Aimbot = "rbxassetid://87867532553953",
    Fling = "rbxassetid://88738549621060",
}

local ICON_MINIMIZE = "rbxassetid://128208355010366"
local ICON_MAXIMIZE = "rbxassetid://120100397680644"
local ICON_CLOSE    = "rbxassetid://88418589248976"
local ICON_PINCEL   = "rbxassetid://130521044774541"

originalLighting = {}
welcomeShown = false
getgenv().SlowHubStartTime = tick()

Config = {
    ESP = {Enabled=false, Color=Color3.fromRGB(80,200,255), HighlightColor=Color3.fromRGB(60,220,255), ShowName=false, ShowDistance=false, ShowHealth=false, ShowHighlight=false, TeamCheck=false, ShowLines=false},
    Aimbot = {Enabled=false, FOVEnabled=false, FOVColor=Color3.fromRGB(80,180,255), FOVSize=250, Target="Head", TeamCheck=false, Smoothness=0.35, AutoShot=false, WallCheck=false, AutoReload=false},
    Hitbox = {Enabled=false, Size=5, Color=Color3.fromRGB(80,180,255), ShowBox=false},
    Noclip = {Enabled=false},
    Speed = {Enabled=false, Value=32},
    InfiniteJump = {Enabled=false},
    Fly = {Enabled=false, Speed=80, MinSpeed=10, MaxSpeed=500},
    Fullbright = {Enabled=false},
    FOVChanger = {Enabled=false, Value=70},
    AntiFling = {Enabled=true},
    AntiAFK = {Enabled=false},
    AntiVoid = {Enabled=false},
    Fling = {Enabled=false}
}

local CONFIG_FILE = "slowhub_config.json"

function saveConfig()
    if type(writefile) ~= "function" then return false end
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(Config)
    end)
    if success then
        pcall(function() writefile(CONFIG_FILE, encoded) end)
        return true
    end
    return false
end

function loadConfig()
    if type(isfile) ~= "function" or type(readfile) ~= "function" then return false end
    local exists = pcall(function() return isfile(CONFIG_FILE) end)
    if not exists or not isfile(CONFIG_FILE) then return false end
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(CONFIG_FILE))
    end)
    if not success or type(data) ~= "table" then return false end
    for section, values in pairs(data) do
        if type(values) == "table" and Config[section] then
            for key, value in pairs(values) do
                if Config[section][key] ~= nil then
                    if typeof(value) == "Color3" then
                        Config[section][key] = Color3.new(value.r, value.g, value.b)
                    else
                        Config[section][key] = value
                    end
                end
            end
        end
    end
    return true
end

function resetConfig()
    if type(delfile) == "function" then
        pcall(function() delfile(CONFIG_FILE) end)
    end
end

-- 🔑 FUNÇÕES DO SISTEMA DE KEY (permanente vs temporária)
function isPermanent()
    if type(isfile) == "function" and isfile(KEY_CONFIG.PermFile) then
        return true
    end
    return false
end

function setPermanent()
    if type(writefile) == "function" then
        pcall(function() writefile(KEY_CONFIG.PermFile, "true") end)
    end
end

function saveKeyLocal(key)
    if type(writefile) == "function" then
        pcall(function() writefile(KEY_CONFIG.KeyFile, key) end)
    end
end

function getSavedKey()
    if type(isfile) == "function" and type(readfile) == "function" then
        local ok = pcall(function() return isfile(KEY_CONFIG.KeyFile) end)
        if ok and isfile(KEY_CONFIG.KeyFile) then
            return readfile(KEY_CONFIG.KeyFile)
        end
    end
    return nil
end

function safeChar(plr)
    if not plr or not plr.Parent then return nil, nil, nil end
    local char = plr.Character
    if not char then return nil, nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return char, hum, hrp
end

function sameTeam(plr)
    if not plr or not LocalPlayer then return false end
    if plr == LocalPlayer then return true end

    local ok1, result1 = pcall(function()
        if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
            return true
        end
        return false
    end)
    if ok1 and result1 then return true end

    local ok2, result2 = pcall(function()
        if plr.TeamColor and LocalPlayer.TeamColor and plr.TeamColor == LocalPlayer.TeamColor then
            return true
        end
        return false
    end)
    if ok2 and result2 then return true end

    local attrNames = {"Team", "team", "TeamName", "Gang", "Faction", "Squad"}
    for _, attr in ipairs(attrNames) do
        local ok, mine, theirs = pcall(function()
            return LocalPlayer:GetAttribute(attr), plr:GetAttribute(attr)
        end)
        if ok and mine ~= nil and theirs ~= nil and mine == theirs then
            return true
        end
    end

    local myChar = LocalPlayer.Character
    local theirChar = plr.Character
    if myChar and theirChar then
        for _, attr in ipairs(attrNames) do
            local ok, mine, theirs = pcall(function()
                return myChar:GetAttribute(attr), theirChar:GetAttribute(attr)
            end)
            if ok and mine ~= nil and theirs ~= nil and mine == theirs then
                return true
            end
        end
    end

    return false
end

function isValidTarget(plr, teamcheck)
    if not plr then return false end
    if plr == LocalPlayer then return false end
    if not plr.Parent then return false end

    local char = plr.Character
    if not char or not char.Parent then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    if char:FindFirstChildOfClass("ForceField") then return false end

    if teamcheck then
        local ok, resultado = pcall(sameTeam, plr)
        if ok and resultado == true then
            return false
        end
    end

    return true
end

function getPing()
    local ping = 0
    pcall(function()
        ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    return ping
end

function getPlayersCount()
    return #Players:GetPlayers(), Players.MaxPlayers
end

function getUptime()
    return math.floor(tick() - (getgenv().SlowHubStartTime or tick()))
end

function openDiscord()
    pcall(function()
        if setclipboard then
            setclipboard(DISCORD_LINK)
        elseif toclipboard then
            toclipboard(DISCORD_LINK)
        end
    end)
end

loadConfig()
                                     
espFolder = Instance.new("Folder")
espFolder.Name = "SlowHub_ESP"
espFolder.Parent = parentGui

espData = {}

function destroyESP(plr)
    local d = espData[plr]
    if not d then return end
    for _, obj in pairs(d) do
        if typeof(obj) == "Instance" and obj.Parent then obj:Destroy() end
    end
    espData[plr] = nil
end
function createESP(plr)
    if espData[plr] then return end
    local d = {}
    local box = Instance.new("Frame")
    box.Name = "Box"
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = false
    box.ZIndex = 5
    box.Parent = espFolder
    local stroke = Instance.new("UIStroke", box)
    stroke.Color = Config.ESP.Color
    stroke.Thickness = 1.2
    stroke.Transparency = 0.15

    local nameLbl = Instance.new("TextLabel")
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = plr.Name
    nameLbl.TextColor3 = Config.ESP.Color
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 12
    nameLbl.TextStrokeTransparency = 0.3
    nameLbl.Visible = false
    nameLbl.ZIndex = 6
    nameLbl.Parent = espFolder

    local distLbl = Instance.new("TextLabel")
    distLbl.BackgroundTransparency = 1
    distLbl.Text = "0m"
    distLbl.TextColor3 = Config.ESP.Color
    distLbl.Font = Enum.Font.Gotham
    distLbl.TextSize = 10
    distLbl.TextStrokeTransparency = 0.3
    distLbl.Visible = false
    distLbl.ZIndex = 6
    distLbl.Parent = espFolder

    local hpBg = Instance.new("Frame")
    hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    hpBg.BorderSizePixel = 0
    hpBg.Visible = false
    hpBg.ZIndex = 6
    hpBg.Parent = espFolder
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 2)

    local hpBar = Instance.new("Frame")
    hpBar.BackgroundColor3 = SUCCESS
    hpBar.BorderSizePixel = 0
    hpBar.Size = UDim2.new(1, 0, 1, 0)
    hpBar.ZIndex = 7
    hpBar.Parent = hpBg
    Instance.new("UICorner", hpBar).CornerRadius = UDim.new(0, 2)

    local line = Instance.new("Frame")
    line.Name = "Line"
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BorderSizePixel = 0
    line.BackgroundColor3 = Config.ESP.Color
    line.BackgroundTransparency = 0
    line.Visible = false
    line.ZIndex = 4
    line.Parent = espFolder

    local stick = Instance.new("Folder")
    stick.Name = "Stick"
    stick.Parent = espFolder

    local function makeStickLine(nome)
        local f = Instance.new("Frame")
        f.Name = nome
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.BorderSizePixel = 0
        f.BackgroundColor3 = Config.ESP.Color
        f.Visible = false
        f.ZIndex = 6
        f.Parent = stick
        local corner = Instance.new("UICorner", f)
        corner.CornerRadius = UDim.new(1, 0)
        return f
    end

    local stickBody = makeStickLine("Body")
    local stickArmL = makeStickLine("ArmL")
    local stickArmR = makeStickLine("ArmR")
    local stickLegL = makeStickLine("LegL")
    local stickLegR = makeStickLine("LegR")

    d.Stick = {
        Body = stickBody,
        ArmL = stickArmL,
        ArmR = stickArmR,
        LegL = stickLegL,
        LegR = stickLegR,
    }

    d.Box = box
    d.Stroke = stroke
    d.Name = nameLbl
    d.Dist = distLbl
    d.HpBg = hpBg
    d.HpBar = hpBar
    d.Line = line
    espData[plr] = d
end

function hideESP(d)
    if not d then return end
    if d.Box and d.Box.Parent then d.Box.Visible = false end
    if d.Line and d.Line.Parent then d.Line.Visible = false end
    if d.Name and d.Name.Parent then d.Name.Visible = false end
    if d.Dist and d.Dist.Parent then d.Dist.Visible = false end
    if d.HpBg and d.HpBg.Parent then d.HpBg.Visible = false end
    if d.Stick then
        if d.Stick.Body and d.Stick.Body.Parent then d.Stick.Body.Visible = false end
        if d.Stick.ArmL and d.Stick.ArmL.Parent then d.Stick.ArmL.Visible = false end
        if d.Stick.ArmR and d.Stick.ArmR.Parent then d.Stick.ArmR.Visible = false end
        if d.Stick.LegL and d.Stick.LegL.Parent then d.Stick.LegL.Visible = false end
        if d.Stick.LegR and d.Stick.LegR.Parent then d.Stick.LegR.Visible = false end
    end
end

function updateESP()
    for _, d in pairs(espData) do
        hideESP(d)
    end

    for plr, d in pairs(espData) do
        if not plr or not plr.Parent then
            destroyESP(plr)
        end
    end

    for _, obj in ipairs(espFolder:GetChildren()) do
        if obj.Name == "Stick" then
            local pai = nil
            for plr, d in pairs(espData) do
                if d.Stick == obj then pai = plr break end
            end
            if not pai then
                obj:Destroy()
            end
        end
    end

    if not Config.ESP.Enabled then
        return
    end

    local localChar = LocalPlayer.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local vp = Camera.ViewportSize

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and not espData[plr] then
            createESP(plr)
        end
    end

    for plr, d in pairs(espData) do
        if not plr.Parent then
            destroyESP(plr)
        end
    end

    for plr, d in pairs(espData) do
        if isValidTarget(plr, Config.ESP.TeamCheck) then
            local char, hum, hrp = safeChar(plr)
            if (char and hum and hrp) and char.Parent and plr.Parent then
                local head = char:FindFirstChild("Head")
                if head then
                    local headPos, headOn = Camera:WorldToViewportPoint(head.Position)
                    local footPos, footOn = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

                    if headOn and footOn and headPos.Z > 0 and footPos.Z > 0 then
                        local dentroTela = headPos.X > 0 and headPos.X < vp.X 
                                       and headPos.Y > 0 and headPos.Y < vp.Y
                        if dentroTela then
                            local h = math.abs(footPos.Y - headPos.Y)
                            local w = h * 0.6
                            local x = headPos.X - w / 2
                            local y = headPos.Y

                            if h > 3 then
                                d.Box.Visible = true
                                d.Box.Position = UDim2.new(0, x, 0, y)
                                d.Box.Size = UDim2.new(0, w, 0, h)
                                d.Stroke.Color = Config.ESP.Color

                                if Config.ESP.ShowName then
                                    d.Name.Visible = true
                                    d.Name.Position = UDim2.new(0, x, 0, y - 16)
                                    d.Name.Size = UDim2.new(0, w + 60, 0, 14)
                                    d.Name.TextColor3 = Config.ESP.Color
                                    if Config.ESP.ShowHealth and hum and hum.MaxHealth > 0 then
                                        local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                        d.Name.Text = plr.Name .. "  " .. math.floor(pct * 100) .. "%"
                                    else
                                        d.Name.Text = plr.Name
                                    end
                                end

                                if Config.ESP.ShowDistance then
                                    d.Dist.Visible = true
                                    local dist = localHrp and (localHrp.Position - hrp.Position).Magnitude or 0
                                    d.Dist.Text = string.format("%dm", math.floor(dist))
                                    d.Dist.Position = UDim2.new(0, x, 0, y + h + 2)
                                    d.Dist.Size = UDim2.new(0, w, 0, 12)
                                    if dist < 30 then
                                        d.Dist.TextColor3 = Color3.fromRGB(100, 255, 100)
                                    elseif dist < 80 then
                                        d.Dist.TextColor3 = Color3.fromRGB(255, 220, 100)
                                    else
                                        d.Dist.TextColor3 = Color3.fromRGB(255, 100, 100)
                                    end
                                end

                                if Config.ESP.ShowHealth then
                                    d.HpBg.Visible = true
                                    d.HpBg.Position = UDim2.new(0, x - 7, 0, y)
                                    d.HpBg.Size = UDim2.new(0, 4, 0, h)

                                    local vida, vidaMax = nil, nil
                                    pcall(function()
                                        if hum and hum.MaxHealth and hum.MaxHealth > 0 then
                                            vida = hum.Health
                                            vidaMax = hum.MaxHealth
                                        end
                                        if not vida or not vidaMax or vidaMax <= 0 then
                                            local hAttr = char:GetAttribute("Health") or char:GetAttribute("health") or char:GetAttribute("HP")
                                            local mAttr = char:GetAttribute("MaxHealth") or char:GetAttribute("maxHealth") or char:GetAttribute("MaxHP")
                                            if hAttr and mAttr and mAttr > 0 then
                                                vida = hAttr
                                                vidaMax = mAttr
                                            end
                                        end
                                        if not vida or not vidaMax or vidaMax <= 0 then
                                            for _, obj in ipairs(char:GetDescendants()) do
                                                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                                                    local n = string.lower(obj.Name)
                                                    if n == "health" or n == "hp" or n == "vida" then
                                                        vida = obj.Value
                                                        local mObj = char:FindFirstChild("MaxHealth") or char:FindFirstChild("MaxHP") or char:FindFirstChild("maxHealth")
                                                        if mObj and mObj.Value and mObj.Value > 0 then
                                                            vidaMax = mObj.Value
                                                        else
                                                            vidaMax = 100
                                                        end
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                        if not vida or not vidaMax or vidaMax <= 0 then
                                            local ls = plr:FindFirstChild("leaderstats")
                                            if ls then
                                                local hpStat = ls:FindFirstChild("Health") or ls:FindFirstChild("HP") or ls:FindFirstChild("Vida")
                                                local maxStat = ls:FindFirstChild("MaxHealth") or ls:FindFirstChild("MaxHP")
                                                if hpStat then
                                                    vida = hpStat.Value
                                                    if maxStat then vidaMax = maxStat.Value else vidaMax = 100 end
                                                end
                                            end
                                        end
                                    end)

                                    if vida and vidaMax and vidaMax > 0 then
                                        local pct = math.clamp(vida / vidaMax, 0, 1)
                                        d.HpBar.Size = UDim2.new(1, 0, pct, 0)
                                        d.HpBar.Position = UDim2.new(0, 0, 1 - pct, 0)
                                        local cor
                                        if pct > 0.6 then
                                            cor = Color3.fromRGB(80, 220, 100)
                                        elseif pct > 0.3 then
                                            cor = Color3.fromRGB(255, 200, 60)
                                        else
                                            cor = Color3.fromRGB(230, 60, 60)
                                        end
                                        d.HpBar.BackgroundColor3 = cor
                                    else
                                        d.HpBg.Visible = false
                                    end
                                end

                                if Config.ESP.ShowLines and d.Line then
                                    local startX = vp.X / 2
                                    local startY = 0
                                    local endX = x + w / 2
                                    local endY = y

                                    local dx = endX - startX
                                    local dy = endY - startY
                                    local dist = math.sqrt(dx * dx + dy * dy)
                                    local midX = (startX + endX) / 2
                                    local midY = (startY + endY) / 2
                                    local angulo = math.deg(math.atan2(-dx, dy))

                                    d.Line.Visible = true
                                    d.Line.AnchorPoint = Vector2.new(0.5, 0.5)
                                    d.Line.Position = UDim2.new(0, midX, 0, midY)
                                    d.Line.Size = UDim2.new(0, 2, 0, dist)
                                    d.Line.Rotation = angulo
                                    d.Line.BackgroundColor3 = Config.ESP.Color
                                end

                                if Config.ESP.ShowHighlight and d.Stick then
                                    local function w2s(pos)
                                        local sp, on = Camera:WorldToViewportPoint(pos)
                                        if on and sp.Z > 0 then return Vector2.new(sp.X, sp.Y) end
                                        return nil
                                    end

                                    local torsoSup = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                                    local torsoInf = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
                                    local bracoESup = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
                                    local bracoDSup = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
                                    local maoE = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
                                    local maoD = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
                                    local peE = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg")
                                    local peD = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")

                                    local pPescoco = torsoSup and w2s(torsoSup.Position)
                                    local pQuadril = torsoInf and w2s(torsoInf.Position)
                                    local pOmbroE = bracoESup and w2s(bracoESup.Position)
                                    local pOmbroD = bracoDSup and w2s(bracoDSup.Position)
                                    local pMaoE = maoE and w2s(maoE.Position)
                                    local pMaoD = maoD and w2s(maoD.Position)
                                    local pPeE = peE and w2s(peE.Position)
                                    local pPeD = peD and w2s(peD.Position)

                                    local cor = Config.ESP.Color
                                    local ESPESSURA_PALITO = 1

                                    local function desenhaLinha(frame, p1, p2)
                                        if not p1 or not p2 then
                                            frame.Visible = false
                                            return
                                        end
                                        local dx2 = p2.X - p1.X
                                        local dy2 = p2.Y - p1.Y
                                        local dist2 = math.sqrt(dx2 * dx2 + dy2 * dy2)
                                        if dist2 < 2 then
                                            frame.Visible = false
                                            return
                                        end
                                        local mx = (p1.X + p2.X) / 2
                                        local my = (p1.Y + p2.Y) / 2
                                        local ang = math.deg(math.atan2(-dx2, dy2))
                                        frame.Visible = true
                                        frame.Position = UDim2.new(0, mx, 0, my)
                                        frame.Size = UDim2.new(0, ESPESSURA_PALITO, 0, dist2)
                                        frame.Rotation = ang
                                        frame.BackgroundColor3 = cor
                                    end

                                    desenhaLinha(d.Stick.Body, pPescoco, pQuadril)
                                    desenhaLinha(d.Stick.ArmL, pOmbroE, pMaoE)
                                    desenhaLinha(d.Stick.ArmR, pOmbroD, pMaoD)
                                    desenhaLinha(d.Stick.LegL, pQuadril, pPeE)
                                    desenhaLinha(d.Stick.LegR, pQuadril, pPeD)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

fovFrame = Instance.new("Frame")
fovFrame.Name = "Aimbot_FOV"
fovFrame.BackgroundTransparency = 1
fovFrame.BorderSizePixel = 0
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Visible = false
fovFrame.ZIndex = 500
fovFrame.Parent = parentGui
fovStroke = Instance.new("UIStroke", fovFrame)
fovStroke.Color = Config.Aimbot.FOVColor
fovStroke.Thickness = 2.5
fovStroke.Transparency = 0
Instance.new("UICorner", fovFrame).CornerRadius = UDim.new(1, 0)

function updateFOV()
    if not (Config.Aimbot.Enabled and Config.Aimbot.FOVEnabled) then
        fovFrame.Visible = false
        return
    end
    fovFrame.Visible = true
    fovFrame.Size = UDim2.new(0, Config.Aimbot.FOVSize * 2, 0, Config.Aimbot.FOVSize * 2)
    local vp = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    fovFrame.Position = UDim2.new(0, vp.X / 2, 0, vp.Y / 2)
    fovStroke.Color = Config.Aimbot.FOVColor
end

function hasLineOfSight(char)
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local origin = Camera.CFrame.Position
    local target = hrp.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, char}
    params.IgnoreWater = true
    local result = workspace:Raycast(origin, target - origin, params)
    return result == nil
end

function getClosest()
    local closestPart = nil
    local closestDist = math.huge
    local vp = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    local center = Vector2.new(vp.X / 2, vp.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr, Config.Aimbot.TeamCheck) then
            local char, hum, hrp = safeChar(plr)
            if char and hrp and char.Parent and plr.Parent then
                local part = nil
                if Config.Aimbot.Target == "Head" then
                    part = char:FindFirstChild("Head")
                end
                           if not part then part = hrp end

                if part and part.Parent then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen and pos.Z > 0 then
                        local screenPos = Vector2.new(pos.X, pos.Y)
                        local dist = (screenPos - center).Magnitude
                        if dist <= Config.Aimbot.FOVSize then
                            if not Config.Aimbot.WallCheck or hasLineOfSight(char) then
                                if dist < closestDist then
                                    closestPart = part
                                    closestDist = dist
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPart
end
-- ═══════════ AUTOSHOT SIMPLES (Fluxo PvP) ═══════════
aimbotActive = false
_ultimoTiro = 0
_rajadaRestante = 0
_ultimoAlvo = nil

COOLDOWN_HEAD = 0.07
COOLDOWN_RAJADA = 0.06
COOLDOWN_NORMAL = 0.03
TAMANHO_RAJADA = 6

function atirarFluxo()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end
    local hud = pg:FindFirstChild("ButtonsHUD")
    if not hud then return false end
    local botoes = hud:FindFirstChild("BotoesArma")
    if not botoes then return false end
    local fb = botoes:FindFirstChild("FireButton")
    if not fb then return false end

    if type(getconnections) ~= "function" then return false end

    local ok, conns = pcall(getconnections, fb.InputBegan)
    if not ok or not conns or #conns == 0 then return false end

    local input = {
        UserInputType = Enum.UserInputType.MouseButton1,
        UserInputState = Enum.UserInputState.Begin,
        Position = Vector3.zero,
        Delta = Vector3.zero,
        KeyCode = Enum.KeyCode.Unknown
    }

    for _, c in ipairs(conns) do
        pcall(function()
            if c.Function then c.Function(input) end
        end)
    end

    local ok2, conns2 = pcall(getconnections, fb.InputEnded)
    if ok2 and conns2 and #conns2 > 0 then
        local inputEnd = {
            UserInputType = Enum.UserInputType.MouseButton1,
            UserInputState = Enum.UserInputState.End,
            Position = Vector3.zero,
            Delta = Vector3.zero,
            KeyCode = Enum.KeyCode.Unknown
        }
        for _, c in ipairs(conns2) do
            pcall(function()
                if c.Function then c.Function(inputEnd) end
            end)
        end
    end
    return true
end               

-- ═══════════ MUNIÇÃO / AUTO RELOAD ═══════════
function getMunicao()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil, nil end
    local zexis = pg:FindFirstChild("ZexisGUI")
    if not zexis then return nil, nil end
    local ammoFrame = zexis:FindFirstChild("AmmoFrame")
    if not ammoFrame then return nil, nil end
    local valueLbl = ammoFrame:FindFirstChild("Value")
    if not valueLbl or not valueLbl:IsA("TextLabel") then return nil, nil end
    local texto = valueLbl.Text or ""
    local atual, max = texto:match("(%d+)/(%d+)")
    if atual and max then
        return tonumber(atual), tonumber(max)
    end
    return nil, nil
end

function recarregarArma()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end
    local hud = pg:FindFirstChild("ButtonsHUD")
    if not hud then return false end
    local botoes = hud:FindFirstChild("BotoesArma")
    if not botoes then return false end
    local rb = botoes:FindFirstChild("ReloadButton")
    if not rb then return false end
    if type(getconnections) ~= "function" then return false end

    local ok, conns = pcall(getconnections, rb.InputBegan)
    if not ok or not conns or #conns == 0 then return false end

    local input = {
        UserInputType = Enum.UserInputType.MouseButton1,
        UserInputState = Enum.UserInputState.Begin,
        Position = Vector3.zero,
        Delta = Vector3.zero,
        KeyCode = Enum.KeyCode.Unknown
    }

    for _, c in ipairs(conns) do
        pcall(function()
            if c.Function then c.Function(input) end
        end)
    end
    return true
end

_ultimoReloadAuto = 0
task.spawn(function()
    while task.wait(0.25) do
        if Config.Aimbot and Config.Aimbot.AutoReload then
            local atual, max = getMunicao()
            if atual and max and max > 0 then
                if atual <= 2 then
                    if tick() - _ultimoReloadAuto > 1.5 then
                        _ultimoReloadAuto = tick()
                        recarregarArma()
                    end
                end
            end
        end
    end
end)

-- ═══════════ AIMBOT ═══════════
function startAimbot()
    if aimbotActive then return end
    aimbotActive = true
    task.spawn(function()
        while Config.Aimbot.Enabled do
            local target = getClosest()
            if target and target.Parent then
                local camPos = Camera.CFrame.Position
                local aimPos = target.Position

                if (aimPos - camPos).Magnitude > 0.1 then
                    local lookAt = CFrame.new(camPos, aimPos)
                    local smooth = math.clamp(Config.Aimbot.Smoothness or 0.25, 0.05, 1)
                    Camera.CFrame = Camera.CFrame:Lerp(lookAt, math.max(smooth, 0.5))
                end

                RunService.RenderStepped:Wait()

                if target and target.Parent then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                end

                if Config.Aimbot.AutoShot then
                    local isHead = (target.Name == "Head")
                    if isHead then
                        if tick() - _ultimoTiro > COOLDOWN_HEAD then
                            _ultimoTiro = tick()
                            atirarFluxo()
                        end
                        _rajadaRestante = 0
                    else
                        if _rajadaRestante > 0 then
                            if tick() - _ultimoTiro > COOLDOWN_RAJADA then
                                _ultimoTiro = tick()
                                atirarFluxo()
                                _rajadaRestante = _rajadaRestante - 1
                            end
                        else
                            if tick() - _ultimoTiro > COOLDOWN_NORMAL then
                                _ultimoTiro = tick()
                                atirarFluxo()
                                _rajadaRestante = TAMANHO_RAJADA - 1
                            end
                        end
                    end
                end
            end
            RunService.RenderStepped:Wait()
        end
        aimbotActive = false
    end)
end


-- ═══════════ HITBOX UNIVERSAL ═══════════
hitboxConn = nil
hitboxExtraPartes = {}

function restaurarHitboxes()
    for plr, partes in pairs(hitboxExtraPartes) do
        for _, part in ipairs(partes) do
            if part and part.Parent then
                pcall(function() part:Destroy() end)
            end
        end
    end
    hitboxExtraPartes = {}
end

function aplicarHitboxEmPlayer(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not hitboxExtraPartes[plr] then
        hitboxExtraPartes[plr] = {}
    end

    local size = math.max(Config.Hitbox.Size, 2)

    if #hitboxExtraPartes[plr] == 0 then
        pcall(function()
            local extraPart = Instance.new("Part")
            extraPart.Name = "SlowHubHitbox"
            extraPart.Size = Vector3.new(size, size, size)
            extraPart.Transparency = 0.7
            extraPart.Color = Color3.fromRGB(80, 180, 255)
            extraPart.Material = Enum.Material.Neon
            extraPart.CanCollide = false
            extraPart.CanTouch = true
            extraPart.CanQuery = true
            extraPart.Massless = true
            extraPart.Anchored = false
            extraPart.TopSurface = Enum.SurfaceType.Smooth
            extraPart.BottomSurface = Enum.SurfaceType.Smooth
            extraPart.CFrame = hrp.CFrame
            extraPart.Parent = char

            local weld = Instance.new("Weld")
            weld.Part0 = hrp
            weld.Part1 = extraPart
            weld.C0 = CFrame.new(0, 0, 0)
            weld.C1 = CFrame.new(0, 0, 0)
            weld.Parent = extraPart

            table.insert(hitboxExtraPartes[plr], extraPart)
        end)
    else
        for _, part in ipairs(hitboxExtraPartes[plr]) do
            if part and part.Parent then
                pcall(function()
                    part.Size = Vector3.new(size, size, size)
                end)
            end
        end
    end
end

function setHitbox(state)
    if hitboxConn then
        hitboxConn:Disconnect()
        hitboxConn = nil
    end

    if not state then
        restaurarHitboxes()
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            pcall(function() aplicarHitboxEmPlayer(plr) end)
        end
    end

    hitboxConn = RunService.Heartbeat:Connect(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = plr.Character
                if char then
                    local partes = hitboxExtraPartes[plr]
                    if partes and #partes > 0 then
                        local orfa = false
                        for _, part in ipairs(partes) do
                            if not part or not part.Parent then
                                orfa = true
                                break
                            end
                        end
                        if orfa then
                            hitboxExtraPartes[plr] = {}
                        end
                    end
                end

                pcall(function() aplicarHitboxEmPlayer(plr) end)
            end
        end
    end)

    local function conectarRespawn(plr)
        if plr == LocalPlayer then return end
        plr.CharacterAdded:Connect(function()
            if Config.Hitbox.Enabled then
                task.wait(0.3)
                hitboxExtraPartes[plr] = {}
                pcall(function() aplicarHitboxEmPlayer(plr) end)
            end
        end)
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        conectarRespawn(plr)
    end

    Players.PlayerAdded:Connect(function(plr)
        if Config.Hitbox.Enabled then
            conectarRespawn(plr)
        end
    end)
end

-- ═══════════ TRACK PLAYERS ═══════════
function trackPlayer(plr)
    if plr == LocalPlayer then return end
    createESP(plr)
end

for _, plr in ipairs(Players:GetPlayers()) do
    trackPlayer(plr)
end

Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(function(plr)
    destroyESP(plr)
end)                                                               

-- NOCLIP
noclipConn = nil
function setNoclip(state)
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if not state then return end
    noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

-- SPEED (com respawn)
speedConn = nil
speedCharConn = nil

function setSpeed(state)
    if speedConn then speedConn:Disconnect() speedConn = nil end
    if speedCharConn then speedCharConn:Disconnect() speedCharConn = nil end

    local function aplicaSpeed()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if state then
            hum.WalkSpeed = Config.Speed.Value
            speedConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if Config.Speed.Enabled and hum.WalkSpeed ~= Config.Speed.Value then
                    hum.WalkSpeed = Config.Speed.Value
                end
            end)
        else
            hum.WalkSpeed = 16
        end
    end

    aplicaSpeed()

    if state then
        speedCharConn = LocalPlayer.CharacterAdded:Connect(function()
            if not Config.Speed.Enabled then return end
            task.wait(0.5)
            if speedConn then speedConn:Disconnect() end
            aplicaSpeed()
        end)
    end
end

-- FLY (rápido, controlável, com respawn)
flyConn = nil
flyBodyVel = nil
flyBodyGyro = nil
flyCharConn = nil

function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBodyVel and flyBodyVel.Parent then flyBodyVel:Destroy() end
    if flyBodyGyro and flyBodyGyro.Parent then flyBodyGyro:Destroy() end
    flyBodyVel, flyBodyGyro = nil, nil
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 16
        hum.AutoRotate = true
        hum.PlatformStand = false
    end
end

function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end

    hum.PlatformStand = false
    hum.AutoRotate = false
    hum.WalkSpeed = 1

    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.Name = "SlowHub_FlyVel"
    flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVel.P = 30000
    flyBodyVel.Velocity = Vector3.zero
    flyBodyVel.Parent = hrp

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.Name = "SlowHub_FlyGyro"
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.P = 50000
    flyBodyGyro.D = 500
    flyBodyGyro.CFrame = Camera.CFrame
    flyBodyGyro.Parent = hrp

    flyConn = RunService.RenderStepped:Connect(function()
        if not Config.Fly.Enabled then return end
        if not (hrp and hrp.Parent) then return end

        if hum and hum.WalkSpeed ~= 1 then
            hum.WalkSpeed = 1
        end

        if not flyBodyVel or not flyBodyVel.Parent then
            flyBodyVel = Instance.new("BodyVelocity")
            flyBodyVel.Name = "SlowHub_FlyVel"
            flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBodyVel.P = 30000
            flyBodyVel.Velocity = Vector3.zero
            flyBodyVel.Parent = hrp
        end
        if not flyBodyGyro or not flyBodyGyro.Parent then
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.Name = "SlowHub_FlyGyro"
            flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBodyGyro.P = 50000
            flyBodyGyro.D = 500
            flyBodyGyro.Parent = hrp
        end

        local md = hum.MoveDirection
        local cam = Camera.CFrame
        local move = Vector3.zero

        if md.Magnitude > 0.1 then
            local mdCam = cam:VectorToObjectSpace(md)
            move = (cam.LookVector * -mdCam.Z) + (cam.RightVector * mdCam.X)
            if move.Magnitude > 0 then
                move = move.Unit * Config.Fly.Speed
            end
        end

        local currentVel = flyBodyVel.Velocity
        flyBodyVel.Velocity = currentVel:Lerp(move, 0.5)
        flyBodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.LookVector)
    end)
end

function setFly(state)
    if flyCharConn then flyCharConn:Disconnect() flyCharConn = nil end

    if state then
        startFly()
        flyCharConn = LocalPlayer.CharacterAdded:Connect(function()
            if not Config.Fly.Enabled then return end
            task.wait(0.5)
            stopFly()
            task.wait(0.1)
            if Config.Fly.Enabled then
                startFly()
            end
        end)
        addNotif("Fly", "Ativado. Use o analógico.", 3)
    else
        stopFly()
        addNotif("Fly", "Desativado.", 3)
    end
end

-- INFINITE JUMP
infJumpConn = nil
function setInfJump(state)
    if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
    if not state then return end
    infJumpConn = UIS.JumpRequest:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

-- FLING
flingActive = false
flingActiveStatus = nil

function SkidFling(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end

    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")

    if not (Character and Humanoid and RootPart) then return end
    if not THumanoid or not TRootPart then return end

    local OldPos = RootPart.CFrame
    local OldFPDH = workspace.FallenPartsDestroyHeight
    workspace.FallenPartsDestroyHeight = 0/0

    local alvoNoAr = TRootPart.AssemblyLinearVelocity.Y > 15

    local FPos = function(BasePart, Pos, Ang)
        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
        Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
        local forca = alvoNoAr and 5e7 or 9e7
        RootPart.Velocity = Vector3.new(forca, forca * 10, forca)
        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local SFBasePart = function(BasePart)
        local TimeToWait = alvoNoAr and 2.5 or 1.5
        local Time = tick()
        local Angle = 0
        repeat
            if RootPart and THumanoid then
                if BasePart.Velocity.Magnitude < 50 then
                    Angle = Angle + 100
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                else
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                end
            end
        until Time + TimeToWait < tick() or not flingActive

        if RootPart and Character and Humanoid then
            for _ = 1, 30 do
                RootPart.CFrame = OldPos
                Character:SetPrimaryPartCFrame(OldPos)
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                RootPart.Velocity = Vector3.zero
                RootPart.RotVelocity = Vector3.zero
                task.wait()
                if (RootPart.Position - OldPos.Position).Magnitude < 3 then
                    break
                end
            end
        end
    end

    local BV = Instance.new("BodyVelocity")
    BV.Parent = RootPart
    BV.Velocity = Vector3.new(0, 0, 0)
    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    if TRootPart then
        SFBasePart(TRootPart)
    elseif THead then
        SFBasePart(THead)
    end

    BV:Destroy()
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.FallenPartsDestroyHeight = OldFPDH
end

-- ANTI-FLING
antiFlingConn = nil
function setAntiFling(state)
    if antiFlingConn then antiFlingConn:Disconnect() antiFlingConn = nil end
        if not state then return end
    antiFlingConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local vel = hrp.AssemblyLinearVelocity
        if vel.Magnitude > 150 then
            hrp.AssemblyLinearVelocity = vel.Unit * 30
            hrp.RotVelocity = Vector3.zero
        end
    end)
end

-- ANTI-VOID
antiVoidConn = nil
antiVoidPos = nil

function setAntiVoid(state)
    if antiVoidConn then antiVoidConn:Disconnect() antiVoidConn = nil end
    if not state then
        antiVoidPos = nil
        return
    end

    local spawnFallback = Vector3.new(0, 100, 0)
    pcall(function()
        local sp = workspace:FindFirstChildOfClass("SpawnLocation")
        if sp then spawnFallback = sp.Position + Vector3.new(0, 5, 0) end
    end)

    antiVoidPos = spawnFallback

    task.spawn(function()
        task.wait(0.5)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y > 5 then
            antiVoidPos = hrp.Position
        end
    end)

    antiVoidConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if hrp.Position.Y < -50 then
            local destino = antiVoidPos or spawnFallback
            pcall(function()
                hrp.CFrame = CFrame.new(destino + Vector3.new(0, 5, 0))
                hrp.Velocity = Vector3.zero
                hrp.AssemblyLinearVelocity = Vector3.zero
            end)
        end

        if hrp.Position.Y > 5 then
            antiVoidPos = hrp.Position
        end

        if hrp.Velocity.Y < -300 then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, -50, hrp.Velocity.Z)
        end
    end)
end

-- ANTI-AFK
antiAfkConn = nil
function setAntiAFK(state)
    if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
    if not state then return end
    if LocalPlayer and LocalPlayer.Idled then
        antiAfkConn = LocalPlayer.Idled:Connect(function()
            pcall(function()
                local vu = game:GetService("VirtualUser")
                if vu then
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new())
                end
            end)
        end)
    end
end

-- FULLBRIGHT
function setFullbright(state)
    if state then
        if not originalLighting.Ambient then
            originalLighting.Ambient = Lighting.Ambient
            originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
            originalLighting.Brightness = Lighting.Brightness
            originalLighting.ClockTime = Lighting.ClockTime
            originalLighting.FogEnd = Lighting.FogEnd
            originalLighting.GlobalShadows = Lighting.GlobalShadows
        end
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false
    else
        if originalLighting.Ambient then
            Lighting.Ambient = originalLighting.Ambient
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
            Lighting.Brightness = originalLighting.Brightness
            Lighting.ClockTime = originalLighting.ClockTime
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.GlobalShadows = originalLighting.GlobalShadows
        end
    end
end

-- FOV CHANGER
function setFOVChanger(state)
    if state then
        Camera.FieldOfView = Config.FOVChanger.Value
    else
        Camera.FieldOfView = 70
    end
end

-- TP SAVE/GOTO
savedPositions = {}

function savePosition(slot)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    savedPositions[slot] = hrp.CFrame
    return true
end

function gotoPosition(slot)
    local cf = savedPositions[slot]
    if not cf then return false end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    hrp.CFrame = cf
    return true
end

function gotoPlayer(plr)
    if not plr then return false end
    local _, _, targetHrp = safeChar(plr)
    if not targetHrp then return false end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    hrp.CFrame = targetHrp.CFrame + Vector3.new(0, 0, 3)
    return true
end

-- REJOIN / SERVER HOP
function queueScriptOnTeleport()
    local code = 'loadstring(game:HttpGet("' .. SCRIPT_URL .. '"))()'
    local queued = false
    pcall(function()
        if queue_on_teleport then
            queue_on_teleport(code)
            queued = true
        elseif queueonteleport then
            queueonteleport(code)
            queued = true
        end
    end)
    return queued
end

function rejoin()
    queueScriptOnTeleport()
    task.wait(0.3)
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

function serverHop()
    queueScriptOnTeleport()
    task.spawn(function()
        task.wait(0.3)
        local ok, servers = pcall(function()
            if not game.HttpGet then return nil end
            local raw = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            if not raw then return nil end
            return HttpService:JSONDecode(raw)
        end)
        if not ok or not servers or not servers.data then return end
        local currentJob = game.JobId
        for _, s in ipairs(servers.data) do
            if s.id ~= currentJob and s.playing < s.maxPlayers then
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                end)
                return
            end
        end
    end)
end

-- LOOP PRINCIPAL
RunService.RenderStepped:Connect(function()
    if type(updateESP) == "function" then pcall(updateESP) end
    if type(updateFOV) == "function" then pcall(updateFOV) end
    if Config and Config.FOVChanger and Config.FOVChanger.Enabled then
        Camera.FieldOfView = Config.FOVChanger.Value
    end
end)
-- ═══════════════════════════════════════════════════════════
-- GUI PRINCIPAL (SlowHub)
-- ═══════════════════════════════════════════════════════════
gui = Instance.new("ScreenGui")
gui.Name = "SlowHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 9999
gui.Parent = parentGui

pcall(function()
    if espFolder then espFolder.Parent = gui end
    if fovFrame then fovFrame.Parent = gui end
end)

local vpSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
local maxW = math.min(900, vpSize.X * 0.85)
local maxH = math.min(600, vpSize.Y * 0.80)
NORMAL_SIZE = UDim2.new(0, 500, 0, 340)
MAXIMIZED_SIZE = UDim2.new(0, maxW, 0, maxH)

-- ═══════════ CÁPSULA ═══════════
capsuleBorder = Instance.new("Frame")
capsuleBorder.Name = "CapsuleBorder"
capsuleBorder.Size = UDim2.new(0, 224, 0, 50)
capsuleBorder.Position = UDim2.new(0.5, -112, 0, 10)
capsuleBorder.BackgroundColor3 = Color3.new(1, 1, 1)
capsuleBorder.BorderSizePixel = 0
capsuleBorder.ZIndex = 4
capsuleBorder.Visible = false
capsuleBorder.Parent = gui
Instance.new("UICorner", capsuleBorder).CornerRadius = UDim.new(0, 15)

local capsuleBorderGrad = Instance.new("UIGradient", capsuleBorder)
capsuleBorderGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 100, 220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 230, 255)),
})
capsuleBorderGrad.Rotation = 0

capsule = Instance.new("Frame")
capsule.Name = "Capsule"
capsule.Size = UDim2.new(0, 220, 0, 46)
capsule.Position = UDim2.new(0.5, -110, 0, 12)
capsule.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
capsule.BorderSizePixel = 0
capsule.Active = true
capsule.Visible = false
capsule.ZIndex = 5
capsule.Parent = gui
Instance.new("UICorner", capsule).CornerRadius = UDim.new(0, 14)

local capsuleGradient = Instance.new("UIGradient", capsule)
capsuleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 20, 32)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 14, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 20, 32)),
})

dragZone = Instance.new("TextButton")
dragZone.Name = "DragZone"
dragZone.Size = UDim2.new(0, 46, 1, 0)
dragZone.Position = UDim2.new(0, 0, 0, 0)
dragZone.BackgroundTransparency = 1
dragZone.Text = ""
dragZone.AutoButtonColor = false
dragZone.Active = true
dragZone.ZIndex = 8
dragZone.Parent = capsule
Instance.new("UICorner", dragZone).CornerRadius = UDim.new(1, 0)

dragIcon = Instance.new("ImageLabel")
dragIcon.AnchorPoint = Vector2.new(0.5, 0.5)
dragIcon.Size = UDim2.new(0, 26, 0, 26)
dragIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
dragIcon.BackgroundTransparency = 1
dragIcon.Image = "rbxassetid://79111374854903"
dragIcon.ImageColor3 = Color3.fromRGB(210, 210, 220)
dragIcon.ZIndex = 9
dragIcon.Parent = dragZone

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 1, 0, 24)
divider.Position = UDim2.new(0, 46, 0.5, -12)
divider.BackgroundColor3 = Color3.fromRGB(70, 80, 100)
divider.BackgroundTransparency = 0.2
divider.BorderSizePixel = 0
divider.ZIndex = 6
divider.Parent = capsule

capsuleText = Instance.new("TextButton")
capsuleText.Size = UDim2.new(1, -54, 1, 0)
capsuleText.Position = UDim2.new(0, 46, 0, 0)
capsuleText.BackgroundTransparency = 1
capsuleText.Text = "Slow Hub"
capsuleText.TextColor3 = Color3.new(1, 1, 1)
capsuleText.Font = Enum.Font.GothamBlack
capsuleText.TextSize = 15
capsuleText.TextXAlignment = Enum.TextXAlignment.Center
capsuleText.AutoButtonColor = false
capsuleText.ZIndex = 6
capsuleText.Parent = capsule

local capsuleTextGradient = Instance.new("UIGradient", capsuleText)
capsuleTextGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 100, 220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 230, 255)),
})
capsuleTextGradient.Rotation = 0

-- ═══════════════════════════════════════════════════════════
-- 🔑 KEY GUI (Estilo Axon Hub + RedstoneGuard + Auto-Validação)
-- ═══════════════════════════════════════════════════════════
keyGui = Instance.new("ScreenGui")
keyGui.Name = "SlowHubKey"
keyGui.ResetOnSpawn = false
keyGui.IgnoreGuiInset = true
keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
keyGui.DisplayOrder = 10000
keyGui.Parent = parentGui

keyBackdrop = Instance.new("Frame")
keyBackdrop.Size = UDim2.new(1, 0, 1, 0)
keyBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
keyBackdrop.BackgroundTransparency = 0.5
keyBackdrop.BorderSizePixel = 0
keyBackdrop.ZIndex = 9998
keyBackdrop.Parent = keyGui

keyBorder = Instance.new("Frame")
keyBorder.Size = UDim2.new(0, 444, 0, 464)
keyBorder.Position = UDim2.new(0.5, -222, 0.5, -232)
keyBorder.BackgroundColor3 = Color3.new(1, 1, 1)
keyBorder.BorderSizePixel = 0
keyBorder.ZIndex = 9999
keyBorder.Parent = keyGui
Instance.new("UICorner", keyBorder).CornerRadius = UDim.new(0, 16)

local keyBorderGrad = Instance.new("UIGradient", keyBorder)
keyBorderGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 100, 220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 230, 255)),
})
keyBorderGrad.Rotation = 45

keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(1, -4, 1, -4)
keyFrame.Position = UDim2.new(0, 2, 0, 2)
keyFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 22)
keyFrame.BorderSizePixel = 0
keyFrame.Active = true
keyFrame.ZIndex = 10000
keyFrame.Parent = keyBorder
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 15)

-- HEADER
keyHeader = Instance.new("Frame")
keyHeader.Size = UDim2.new(1, 0, 0, 90)
keyHeader.BackgroundTransparency = 1
keyHeader.ZIndex = 10001
keyHeader.Parent = keyFrame

keyLogoBox = Instance.new("Frame")
keyLogoBox.Size = UDim2.new(0, 64, 0, 64)
keyLogoBox.Position = UDim2.new(0, 20, 0, 14)
keyLogoBox.BackgroundColor3 = Color3.fromRGB(15, 12, 30)
keyLogoBox.BorderSizePixel = 0
keyLogoBox.ZIndex = 10002
keyLogoBox.Parent = keyHeader
Instance.new("UICorner", keyLogoBox).CornerRadius = UDim.new(0, 14)
local keyLogoStroke = Instance.new("UIStroke", keyLogoBox)
keyLogoStroke.Color = ACCENT
keyLogoStroke.Thickness = 1
keyLogoStroke.Transparency = 0.6

keyLogoImg = Instance.new("ImageLabel")
keyLogoImg.Size = UDim2.new(1, -8, 1, -8)
keyLogoImg.Position = UDim2.new(0, 4, 0, 4)
keyLogoImg.BackgroundTransparency = 1
keyLogoImg.Image = KEY_CONFIG.Logo
keyLogoImg.ScaleType = Enum.ScaleType.Fit
keyLogoImg.ZIndex = 10003
keyLogoImg.Parent = keyLogoBox

keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, -230, 0, 32)
keyTitle.Position = UDim2.new(0, 96, 0, 20)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = KEY_CONFIG.Title
keyTitle.TextColor3 = TEXT
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 26
keyTitle.TextXAlignment = Enum.TextXAlignment.Left
keyTitle.ZIndex = 10002
keyTitle.Parent = keyHeader

keySub = Instance.new("TextLabel")
keySub.Size = UDim2.new(1, -230, 0, 22)
keySub.Position = UDim2.new(0, 96, 0, 52)
keySub.BackgroundTransparency = 1
keySub.Text = KEY_CONFIG.Subtitle
keySub.TextColor3 = TEXTDIM
keySub.Font = Enum.Font.Gotham
keySub.TextSize = 14
keySub.TextXAlignment = Enum.TextXAlignment.Left
keySub.ZIndex = 10002
keySub.Parent = keyHeader

keyCloseBtn = Instance.new("TextButton")
keyCloseBtn.Name = "SlowHubKeyClose"
keyCloseBtn.Size = UDim2.new(0, 32, 0, 32)
keyCloseBtn.Position = UDim2.new(1, -46, 0, 16)
keyCloseBtn.BackgroundColor3 = Color3.fromRGB(30, 22, 40)
keyCloseBtn.BorderSizePixel = 0
keyCloseBtn.Text = "✕"
keyCloseBtn.TextColor3 = Color3.fromRGB(220, 200, 220)
keyCloseBtn.TextSize = 16
keyCloseBtn.Font = Enum.Font.GothamBold
keyCloseBtn.AutoButtonColor = false
keyCloseBtn.ZIndex = 10002
keyCloseBtn.Parent = keyHeader
Instance.new("UICorner", keyCloseBtn).CornerRadius = UDim.new(0, 10)
local keyCloseStroke = Instance.new("UIStroke", keyCloseBtn)
keyCloseStroke.Color = Color3.fromRGB(180, 80, 120)
keyCloseStroke.Thickness = 1
keyCloseStroke.Transparency = 0.5

keyCloseBtn.MouseEnter:Connect(function()
    keyCloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 80)
    keyCloseBtn.TextColor3 = Color3.new(1, 1, 1)
end)
keyCloseBtn.MouseLeave:Connect(function()
    keyCloseBtn.BackgroundColor3 = Color3.fromRGB(30, 22, 40)
    keyCloseBtn.TextColor3 = Color3.fromRGB(220, 200, 220)
end)
keyCloseBtn.MouseButton1Click:Connect(function()
    keyGui:Destroy()
    pcall(function() gui:Destroy() end)
end)

keyDivider = Instance.new("Frame")
keyDivider.Size = UDim2.new(1, -32, 0, 1)
keyDivider.Position = UDim2.new(0, 16, 0, 90)
keyDivider.BackgroundColor3 = PURPLE_BORDER
keyDivider.BackgroundTransparency = 0.5
keyDivider.BorderSizePixel = 0
keyDivider.ZIndex = 10002
keyDivider.Parent = keyFrame

keyBody = Instance.new("Frame")
keyBody.Size = UDim2.new(1, -40, 1, -110)
keyBody.Position = UDim2.new(0, 20, 0, 100)
keyBody.BackgroundTransparency = 1
keyBody.ZIndex = 10001
keyBody.Parent = keyFrame

keyLayout = Instance.new("UIListLayout", keyBody)
keyLayout.Padding = UDim.new(0, 10)
keyLayout.SortOrder = Enum.SortOrder.LayoutOrder
keyLayout.Parent = keyBody

keyInputFrame = Instance.new("Frame")
keyInputFrame.Size = UDim2.new(1, 0, 0, 42)
keyInputFrame.LayoutOrder = 1
keyInputFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 30)
keyInputFrame.BorderSizePixel = 0
keyInputFrame.ZIndex = 10002
keyInputFrame.Parent = keyBody
Instance.new("UICorner", keyInputFrame).CornerRadius = UDim.new(0, 10)
local keyInputStroke = Instance.new("UIStroke", keyInputFrame)
keyInputStroke.Color = PURPLE_BORDER
keyInputStroke.Thickness = 1.2
keyInputStroke.Transparency = 0.4

keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(1, -20, 1, 0)
keyInput.Position = UDim2.new(0, 10, 0, 0)
keyInput.BackgroundTransparency = 1
keyInput.Text = ""
keyInput.PlaceholderText = "Digite sua Key aqui..."
keyInput.PlaceholderColor3 = TEXTDIM
keyInput.TextColor3 = TEXT
keyInput.TextSize = 15
keyInput.Font = Enum.Font.Gotham
keyInput.TextXAlignment = Enum.TextXAlignment.Left
keyInput.ClearTextOnFocus = false
keyInput.ZIndex = 10003
keyInput.Parent = keyInputFrame

keyValidateBtn = Instance.new("TextButton")
keyValidateBtn.Size = UDim2.new(1, 0, 0, 42)
keyValidateBtn.LayoutOrder = 2
keyValidateBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
keyValidateBtn.BorderSizePixel = 0
keyValidateBtn.Text = "✅  Validar Key"
keyValidateBtn.TextColor3 = Color3.new(1, 1, 1)
keyValidateBtn.TextSize = 15
keyValidateBtn.Font = Enum.Font.GothamBold
keyValidateBtn.AutoButtonColor = false
keyValidateBtn.ZIndex = 10002
keyValidateBtn.Parent = keyBody
Instance.new("UICorner", keyValidateBtn).CornerRadius = UDim.new(0, 10)

keyValidateBtn.MouseEnter:Connect(function()
    keyValidateBtn.BackgroundColor3 = Color3.fromRGB(70, 220, 120)
end)
keyValidateBtn.MouseLeave:Connect(function()
    keyValidateBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
end)

keyOrLbl = Instance.new("TextLabel")
keyOrLbl.Size = UDim2.new(1, 0, 0, 22)
keyOrLbl.LayoutOrder = 3
keyOrLbl.BackgroundTransparency = 1
keyOrLbl.Text = "──────────  ou  ──────────"
keyOrLbl.TextColor3 = TEXTDIM
keyOrLbl.TextSize = 12
keyOrLbl.Font = Enum.Font.Gotham
keyOrLbl.ZIndex = 10002
keyOrLbl.Parent = keyBody

keyDiscordBtn = Instance.new("TextButton")
keyDiscordBtn.Size = UDim2.new(1, 0, 0, 42)
keyDiscordBtn.LayoutOrder = 4
keyDiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
keyDiscordBtn.BorderSizePixel = 0
keyDiscordBtn.Text = ""
keyDiscordBtn.AutoButtonColor = false
keyDiscordBtn.ZIndex = 10002
keyDiscordBtn.Parent = keyBody
Instance.new("UICorner", keyDiscordBtn).CornerRadius = UDim.new(0, 10)

keyDiscordLogo = Instance.new("ImageLabel")
keyDiscordLogo.Size = UDim2.new(0, 22, 0, 22)
keyDiscordLogo.Position = UDim2.new(0, 12, 0.5, -11)
keyDiscordLogo.BackgroundTransparency = 1
keyDiscordLogo.Image = KEY_CONFIG.DiscordLogo
keyDiscordLogo.ScaleType = Enum.ScaleType.Fit
keyDiscordLogo.ZIndex = 10003
keyDiscordLogo.Parent = keyDiscordBtn

keyDiscordText = Instance.new("TextLabel")
keyDiscordText.Size = UDim2.new(1, -50, 1, 0)
keyDiscordText.Position = UDim2.new(0, 42, 0, 0)
keyDiscordText.BackgroundTransparency = 1
keyDiscordText.Text = "Entrar no Discord — Key Permanente"
keyDiscordText.TextColor3 = Color3.new(1, 1, 1)
keyDiscordText.TextSize = 14
keyDiscordText.Font = Enum.Font.GothamBold
keyDiscordText.TextXAlignment = Enum.TextXAlignment.Left
keyDiscordText.ZIndex = 10003
keyDiscordText.Parent = keyDiscordBtn

keyDiscordBtn.MouseEnter:Connect(function()
    keyDiscordBtn.BackgroundColor3 = Color3.fromRGB(110, 120, 250)
end)
keyDiscordBtn.MouseLeave:Connect(function()
    keyDiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
end)
keyDiscordBtn.MouseButton1Click:Connect(function()
    if setclipboard then pcall(function() setclipboard(KEY_CONFIG.DiscordInvite) end) end
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow(KEY_CONFIG.DiscordInvite)
    end)
    setPermanent()
    addNotif("Discord", "Abra um ticket para receber a Key Permanente.", 4)
end)

keyTempLbl = Instance.new("TextLabel")
keyTempLbl.Size = UDim2.new(1, 0, 0, 22)
keyTempLbl.LayoutOrder = 5
keyTempLbl.BackgroundTransparency = 1
keyTempLbl.Text = "📥  Pegar Key Temporária:"
keyTempLbl.TextColor3 = TEXT
keyTempLbl.TextSize = 14
keyTempLbl.Font = Enum.Font.GothamMedium
keyTempLbl.TextXAlignment = Enum.TextXAlignment.Left
keyTempLbl.ZIndex = 10002
keyTempLbl.Parent = keyBody

for i, provider in ipairs(KEY_CONFIG.Providers) do
    local btn = Instance.new("TextButton")
    btn.Name = "Provider_" .. provider.Name
    btn.Size = UDim2.new(1, 0, 0, 46)
    btn.LayoutOrder = 5 + i
    btn.BackgroundColor3 = provider.Color
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 10002
    btn.Parent = keyBody
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = provider.Hover
    btnStroke.Thickness = 1.2
    btnStroke.Transparency = 0.5

    local logoBox = Instance.new("Frame")
    logoBox.Size = UDim2.new(0, 32, 0, 32)
    logoBox.Position = UDim2.new(0, 8, 0.5, -16)
    logoBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    logoBox.BackgroundTransparency = 0.15
    logoBox.BorderSizePixel = 0
    logoBox.ZIndex = 10003
    logoBox.Parent = btn
    Instance.new("UICorner", logoBox).CornerRadius = UDim.new(0, 8)

    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(1, -6, 1, -6)
    logo.Position = UDim2.new(0, 3, 0, 3)
    logo.BackgroundTransparency = 1
    logo.Image = provider.Logo
    logo.ScaleType = Enum.ScaleType.Fit
    logo.ZIndex = 10004
    logo.Parent = logoBox

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 50, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "Pegar Key via " .. provider.Name
    label.TextColor3 = Color3.fromRGB(20, 20, 30)
    label.TextSize = 15
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 10003
    label.Parent = btn

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 30, 1, 0)
    arrow.Position = UDim2.new(1, -36, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "→"
    arrow.TextColor3 = Color3.fromRGB(20, 20, 30)
    arrow.TextSize = 22
    arrow.Font = Enum.Font.GothamBold
    arrow.ZIndex = 10003
    arrow.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = provider.Hover
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = provider.Color
    end)
    btn.MouseButton1Click:Connect(function()
        if setclipboard then pcall(function() setclipboard(KEY_CONFIG.RedstoneURL) end) end
        pcall(function()
            game:GetService("GuiService"):OpenBrowserWindow(KEY_CONFIG.RedstoneURL)
        end)
        addNotif(provider.Name, "Complete a verificação para receber sua Key.", 4)
    end)
end

keyStatus = Instance.new("TextLabel")
keyStatus.Size = UDim2.new(1, 0, 0, 16)
keyStatus.LayoutOrder = 20
keyStatus.BackgroundTransparency = 1
keyStatus.Text = ""
keyStatus.TextColor3 = DANGER
keyStatus.Font = Enum.Font.Gotham
keyStatus.TextSize = 11
keyStatus.TextXAlignment = Enum.TextXAlignment.Left
keyStatus.ZIndex = 10002
keyStatus.Parent = keyBody

-- ═══════════════════════════════════════════════════════════
-- VERIFICAÇÃO DE KEY (RedstoneGuard)
-- ═══════════════════════════════════════════════════════════
function verifyKeyWithRedstone(key)
    if not key or key == "" then return false, "Digite uma Key" end

    local ok, response = pcall(function()
        return game:HttpGet(
            "https://redstoneguard.xyz/api/keys/verify?key=" .. tostring(key)
        )
    end)
    if ok and response then
        local success, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        if success and type(data) == "table" then
            if data.valid == true or data.success == true then
                return true, "Key válida"
            end
            if data.message then
                return false, tostring(data.message)
            end
        end
    end

    if key == KEY then
        return true, "Key válida"
    end

    return false, "Key inválida ou expirada"
end

function tryValidateKey()
    local typed = keyInput.Text or ""
    if typed == "" then
        keyStatus.TextColor3 = DANGER
        keyStatus.Text = "Digite uma Key."
        return
    end

    keyStatus.TextColor3 = ACCENT
    keyStatus.Text = "Verificando..."
    keyValidateBtn.Text = "⏳  Verificando..."

    task.spawn(function()
        local ok, msg = verifyKeyWithRedstone(typed)
        if ok then
            keyStatus.TextColor3 = SUCCESS
            keyStatus.Text = "Key validada com sucesso!"
            keyValidateBtn.Text = "✅  Validada"

            saveKeyLocal(typed)

            task.wait(0.6)
            keyGui.Enabled = false
            gui.Enabled = true
            capsule.Visible = true
            capsuleBorder.Visible = true
            main.Visible = false
            mainBorder.Visible = false

            if not welcomeShown then
                welcomeShown = true
                task.wait(0.4)
                addNotif("Welcome", "Bem-vindo ao Slow Hub, " .. (LocalPlayer.DisplayName or LocalPlayer.Name) .. "!", 6)
            end
        else
            keyStatus.TextColor3 = DANGER
            keyStatus.Text = tostring(msg or "Key inválida.")
            keyValidateBtn.Text = "✅  Validar Key"
        end
    end)
end

keyValidateBtn.MouseButton1Click:Connect(tryValidateKey)
keyInput.FocusLost:Connect(function(enter)
    if enter then tryValidateKey() end
end)

-- Pré-preenche a key salva no input
task.spawn(function()
    local saved = getSavedKey()
    if saved and saved ~= "" then
        keyInput.Text = saved
    end
end)

-- Drag do Key GUI
keyDragging = false
keyDragStart = nil
keyStartPos = nil

keyHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        keyDragging = true
        keyDragStart = UIS:GetMouseLocation()
        keyStartPos = keyBorder.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if not keyDragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
    and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local pos = UIS:GetMouseLocation()
    local dx = pos.X - keyDragStart.X
    local dy = pos.Y - keyDragStart.Y
    keyBorder.Position = UDim2.new(
        keyStartPos.X.Scale, keyStartPos.X.Offset + dx,
        keyStartPos.Y.Scale, keyStartPos.Y.Offset + dy
    )
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        keyDragging = false
    end
end)

════════════════════════════════════════════════
-- FUNÇÕES AUXILIARES
-- ═══════════════════════════════════════════════════════════
function makeCard(parent, y, h)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -24, 0, h or 32)
    card.Position = UDim2.new(0, 12, 0, y)
    card.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    card.BackgroundTransparency = 0.7
    card.BorderSizePixel = 0
    card.ZIndex = 120
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    return card
end

function makeLabel(card, text, x, width)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, width or 200, 1, 0)
    lbl.Position = UDim2.new(0, x or 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = TEXT
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 130
    lbl.Parent = card
    return lbl
end

function makeToggle(card, defaultState, callback)
    local state = defaultState or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -50, 0.5, -10)
    btn.BackgroundColor3 = state and TOGGLE_ON_COLOR or CARD
    btn.Text = state and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.AutoButtonColor = false
    btn.ZIndex = 130
    btn.Parent = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    btn:SetAttribute("ToggleState", state)
    btn.MouseButton1Click:Connect(function()
        local newState = not btn:GetAttribute("ToggleState")
        btn:SetAttribute("ToggleState", newState)
        btn.BackgroundColor3 = newState and TOGGLE_ON_COLOR or CARD
        btn.Text = newState and "ON" or "OFF"
        if callback then callback(newState) end
        pcall(function() saveConfig() end)
    end)
    return btn
end

function makeButton(parent, text, y, w, h, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, w or 120, 0, h or 26)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 42)
    btn.Text = text
    btn.TextColor3 = TEXT
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.ZIndex = 130
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color or Color3.fromRGB(35, 35, 42)}):Play()
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

function makeIconButton(parent, iconId, text, y, w, h, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, w or 180, 0, h or 32)
    btn.Position = UDim2.new(0, 12, 0, y)
    btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 42)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 130
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local btnIcon = Instance.new("ImageLabel")
    btnIcon.Name = "Icon"
    btnIcon.Size = UDim2.new(0, 20, 0, 20)
    btnIcon.Position = UDim2.new(0, 10, 0.5, -10)
    btnIcon.BackgroundTransparency = 1
    btnIcon.Image = "rbxassetid://" .. tostring(iconId)
    btnIcon.ImageColor3 = Color3.new(1, 1, 1)
    btnIcon.ZIndex = 131
    btnIcon.Parent = btn

    local btnTxt = Instance.new("TextLabel")
    btnTxt.Name = "Label"
    btnTxt.Size = UDim2.new(1, -42, 1, 0)
    btnTxt.Position = UDim2.new(0, 38, 0, 0)
    btnTxt.BackgroundTransparency = 1
    btnTxt.Text = text
    btnTxt.TextColor3 = TEXT
    btnTxt.Font = Enum.Font.GothamBold
    btnTxt.TextSize = 11
    btnTxt.TextXAlignment = Enum.TextXAlignment.Left
    btnTxt.ZIndex = 131
    btnTxt.Parent = btn

    local corOriginal = color or Color3.fromRGB(35, 35, 42)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(
            math.min(255, corOriginal.R * 255 + 30),
            math.min(255, corOriginal.G * 255 + 30),
            math.min(255, corOriginal.B * 255 + 30)
        )}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = corOriginal}):Play()
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

function makeInput(parent, y, placeholder, w, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, w or 100, 0, 24)
    box.Position = UDim2.new(0, 10, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    box.BorderSizePixel = 0
    box.Text = tostring(placeholder)
    box.PlaceholderText = tostring(placeholder)
    box.PlaceholderColor3 = TEXTDIM
    box.TextColor3 = TEXT
    box.Font = Enum.Font.Gotham
    box.TextSize = 10
    box.ClearTextOnFocus = false
    box.ZIndex = 130
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    if callback then
        box:GetPropertyChangedSignal("Text"):Connect(function()
            callback(box.Text)
        end)
        box.FocusLost:Connect(function()
            callback(box.Text)
            pcall(function() saveConfig() end)
        end)
    end
    return box
end

local PALETA_CORES = {
    Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 100, 50), Color3.fromRGB(255, 150, 50),
    Color3.fromRGB(255, 200, 50), Color3.fromRGB(255, 240, 80), Color3.fromRGB(230, 255, 100),
    Color3.fromRGB(100, 255, 100), Color3.fromRGB(50, 220, 120), Color3.fromRGB(50, 200, 180),
    Color3.fromRGB(80, 200, 255), Color3.fromRGB(50, 150, 255), Color3.fromRGB(80, 100, 255),
    Color3.fromRGB(150, 90, 240), Color3.fromRGB(180, 80, 220), Color3.fromRGB(220, 80, 180),
    Color3.fromRGB(255, 100, 180), Color3.fromRGB(255, 200, 220), Color3.fromRGB(255, 255, 255),
}

function makeColorPalette(parent, y, titulo, corInicial, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -24, 0, 88)
    card.Position = UDim2.new(0, 12, 0, y)
    card.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    card.BackgroundTransparency = 0.7
    card.BorderSizePixel = 0
    card.ZIndex = 120
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 0, 14)
    lbl.Position = UDim2.new(0, 12, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text = titulo
    lbl.TextColor3 = TEXT
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 130
    lbl.Parent = card

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 30, 0, 22)
    preview.Position = UDim2.new(1, -42, 0, 8)
    preview.BackgroundColor3 = corInicial
    preview.BorderSizePixel = 0
    preview.ZIndex = 130
    preview.Parent = card
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 6)

    local previewStroke = Instance.new("UIStroke", preview)
    previewStroke.Color = Color3.new(1, 1, 1)
    previewStroke.Thickness = 1
    previewStroke.Transparency = 0.7

    local grid = Instance.new("Frame")
    grid.Size = UDim2.new(1, -20, 0, 50)
    grid.Position = UDim2.new(0, 10, 0, 32)
    grid.BackgroundTransparency = 1
    grid.ZIndex = 130
    grid.Parent = card

    local gridLayout = Instance.new("UIGridLayout", grid)
    gridLayout.CellSize = UDim2.new(0, 26, 0, 26)
    gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local selecionado = nil

    for i, cor in ipairs(PALETA_CORES) do
        local swatch = Instance.new("TextButton")
        swatch.Size = UDim2.new(0, 26, 0, 26)
        swatch.BackgroundColor3 = cor
        swatch.Text = ""
        swatch.AutoButtonColor = false
        swatch.LayoutOrder = i
        swatch.ZIndex = 131
        swatch.Parent = grid
        Instance.new("UICorner", swatch).CornerRadius = UDim.new(1, 0)

        if math.abs(cor.R - corInicial.R) < 0.05 
           and math.abs(cor.G - corInicial.G) < 0.05 
           and math.abs(cor.B - corInicial.B) < 0.05 then
            local strokeSel = Instance.new("UIStroke", swatch)
            strokeSel.Color = Color3.new(1, 1, 1)
            strokeSel.Thickness = 2.5
            selecionado = strokeSel
        end

        swatch.MouseButton1Click:Connect(function()
            if selecionado and selecionado.Parent then
                selecionado:Destroy()
            end
            local novoSel = Instance.new("UIStroke", swatch)
            novoSel.Color = Color3.new(1, 1, 1)
            novoSel.Thickness = 2.5
            selecionado = novoSel

            preview.BackgroundColor3 = cor
            if callback then callback(cor) end
            pcall(function() saveConfig() end)
        end)
    end
end

function addNotif(title, desc, duration)
    duration = duration or 4
    if not gui or not gui.Parent then return end
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 60)
    notif.Position = UDim2.new(1, 20, 1, -70)
    notif.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    notif.BackgroundTransparency = 0.05
    notif.BorderSizePixel = 0
    notif.ZIndex = 200
    notif.Parent = gui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = PURPLE_BORDER
    stroke.Thickness = 1.2
    stroke.Transparency = 0.3

    local nIcon = Instance.new("ImageLabel")
    nIcon.Size = UDim2.new(0, 28, 0, 28)
    nIcon.Position = UDim2.new(0, 8, 0, 16)
    nIcon.BackgroundTransparency = 1
    nIcon.Image = ICONS.Star
    nIcon.ImageColor3 = PURPLE_BORDER
    nIcon.ZIndex = 202
    nIcon.Parent = notif

    local nTitle = Instance.new("TextLabel")
    nTitle.Size = UDim2.new(1, -60, 0, 18)
    nTitle.Position = UDim2.new(0, 44, 0, 8)
    nTitle.BackgroundTransparency = 1
    nTitle.Text = title or "Slow Hub"
    nTitle.TextColor3 = TEXT
    nTitle.Font = Enum.Font.GothamBold
    nTitle.TextSize = 12
    nTitle.TextXAlignment = Enum.TextXAlignment.Left
    nTitle.ZIndex = 202
    nTitle.Parent = notif

    local nDesc = Instance.new("TextLabel")
    nDesc.Size = UDim2.new(1, -60, 0, 24)
    nDesc.Position = UDim2.new(0, 44, 0, 26)
    nDesc.BackgroundTransparency = 1
    nDesc.Text = desc or ""
    nDesc.TextColor3 = TEXTDIM
    nDesc.Font = Enum.Font.Gotham
    nDesc.TextSize = 10
    nDesc.TextXAlignment = Enum.TextXAlignment.Left
    nDesc.TextWrapped = true
    nDesc.ZIndex = 202
    nDesc.Parent = notif

    local closeNotif = Instance.new("TextButton")
    closeNotif.Size = UDim2.new(0, 20, 0, 20)
    closeNotif.Position = UDim2.new(1, -26, 0, 6)
    closeNotif.BackgroundTransparency = 1
    closeNotif.Text = ""
    closeNotif.ZIndex = 203
    closeNotif.Parent = notif

    local closeNotifIcon = Instance.new("ImageLabel")
    closeNotifIcon.Size = UDim2.new(0, 12, 0, 12)
    closeNotifIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
    closeNotifIcon.BackgroundTransparency = 1
    closeNotifIcon.Image = "rbxassetid://14219436180"
    closeNotifIcon.ImageColor3 = TEXTDIM
    closeNotifIcon.ZIndex = 204
    closeNotifIcon.Parent = closeNotif

    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        if notif and notif.Parent then
            TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Position = UDim2.new(1, 20, notif.Position.Y.Scale, notif.Position.Y.Offset)
            }):Play()
            task.wait(0.3)
            if notif then notif:Destroy() end
        end
    end

    closeNotif.MouseButton1Click:Connect(dismiss)

    TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -320, 1, -70)
    }):Play()

    task.delay(duration, dismiss)
end

-- ═══════════════════════════════════════════════════════════
-- PAINEL PRINCIPAL
-- ═══════════════════════════════════════════════════════════
main = Instance.new("Frame")
main.Name = "Main"
main.Size = NORMAL_SIZE
main.Position = UDim2.new(0.5, -250, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Visible = false
main.ZIndex = 1
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 24)

mainBorder = Instance.new("Frame")
mainBorder.Name = "MainBorder"
mainBorder.Size = UDim2.new(0, 504, 0, 344)
mainBorder.Position = UDim2.new(0.5, -252, 0.5, -172)
mainBorder.BackgroundColor3 = Color3.new(1, 1, 1)
mainBorder.BorderSizePixel = 0
mainBorder.ZIndex = 0
mainBorder.Visible = false
mainBorder.Parent = gui
Instance.new("UICorner", mainBorder).CornerRadius = UDim.new(0, 25)

local mainBorderGrad = Instance.new("UIGradient", mainBorder)
mainBorderGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 100, 220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 230, 255)),
})
mainBorderGrad.Rotation = 0

mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = PURPLE_BORDER
mainStroke.Thickness = 1.5
mainStroke.Transparency = 1

starContainer = Instance.new("Frame")
starContainer.Size = UDim2.new(1, 0, 1, 0)
starContainer.BackgroundColor3 = Color3.fromRGB(6, 4, 15)
starContainer.BackgroundTransparency = 0.15
starContainer.BorderSizePixel = 0
starContainer.ClipsDescendants = true
starContainer.ZIndex = 1
starContainer.Parent = main
Instance.new("UICorner", starContainer).CornerRadius = UDim.new(0, 24)

stars = {}
for i = 1, 60 do
    local size = math.random(1, 3)
    local star = Instance.new("Frame")
    star.Size = UDim2.new(0, size, 0, size)
    star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    star.BackgroundTransparency = math.random(10, 70) / 100
    star.BorderSizePixel = 0
    star.ZIndex = 2
    star.Parent = starContainer
    Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
    stars[i] = {frame = star, speed = math.random(30, 90) / 100000}
end

starOverlay = Instance.new("Frame")
starOverlay.Size = UDim2.new(1, 0, 1, 0)
starOverlay.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
starOverlay.BackgroundTransparency = 0.6
starOverlay.BorderSizePixel = 0
starOverlay.ZIndex = 3
starOverlay.Parent = starContainer
Instance.new("UICorner", starOverlay).CornerRadius = UDim.new(0, 24)

RunService.RenderStepped:Connect(function(dt)
    if not stars then return end
    for i, s in ipairs(stars) do
        if s and s.frame and s.frame.Parent then
            local pos = s.frame.Position
            local newY = pos.Y.Scale + s.speed * dt * 100
            if newY > 1 then
                newY = -0.05
                s.frame.Position = UDim2.new(math.random(), 0, newY, 0)
            else
                s.frame.Position = UDim2.new(pos.X.Scale, 0, newY, 0)
            end
        end
    end
end)
-- ═══════════════════════════════════════════════════════════
-- HEADER DO PAINEL PRINCIPAL
-- ═══════════════════════════════════════════════════════════
HEADER_H = 52
SIDEBAR_W = 140
FOOTER_H = 42

header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, HEADER_H)
header.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
header.Active = true
header.ZIndex = 10
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 24)

local headerGradient = Instance.new("UIGradient", header)
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 20, 32)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 14, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 20, 32)),
})
headerGradient.Rotation = 90

headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 20)
headerFix.Position = UDim2.new(0, 0, 1, -20)
headerFix.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
headerFix.BackgroundTransparency = 0.1
headerFix.BorderSizePixel = 0
headerFix.ZIndex = 10
headerFix.Parent = header

headerStroke = Instance.new("UIStroke", header)
headerStroke.Color = PURPLE_BORDER
headerStroke.Thickness = 1
headerStroke.Transparency = 1

local headerIcon = Instance.new("ImageLabel")
headerIcon.Size = UDim2.new(0, 26, 0, 26)
headerIcon.Position = UDim2.new(0, 14, 0.5, -13)
headerIcon.BackgroundTransparency = 1
headerIcon.BorderSizePixel = 0
headerIcon.Image = ICON_PINCEL
headerIcon.ImageColor3 = Color3.fromRGB(220, 220, 230)
headerIcon.ZIndex = 11
headerIcon.Parent = header

titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 220, 0, 20)
titleLbl.Position = UDim2.new(0, 48, 0, 8)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "Slow Hub - Universal"
titleLbl.TextColor3 = TEXT
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 15
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 11
titleLbl.Parent = header

local titleGradient = Instance.new("UIGradient", titleLbl)
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 100, 220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 230, 255)),
})
titleGradient.Rotation = 0

local titleSub = Instance.new("TextLabel")
titleSub.Size = UDim2.new(0, 220, 0, 12)
titleSub.Position = UDim2.new(0, 48, 0, 28)
titleSub.BackgroundTransparency = 1
titleSub.Text = "by Slow develop"
titleSub.TextColor3 = Color3.fromRGB(130, 140, 160)
titleSub.Font = Enum.Font.GothamMedium
titleSub.TextSize = 10
titleSub.TextXAlignment = Enum.TextXAlignment.Left
titleSub.ZIndex = 11
titleSub.Parent = header

local COR_ICONE = Color3.fromRGB(255, 255, 255)

minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -106, 0.5, -14)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
minBtn.BackgroundTransparency = 1
minBtn.Text = ""
minBtn.AutoButtonColor = false
minBtn.ZIndex = 11
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 7)

minIcon = Instance.new("ImageLabel")
minIcon.Size = UDim2.new(0, 16, 0, 16)
minIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
minIcon.BackgroundTransparency = 1
minIcon.Image = ICON_MINIMIZE
minIcon.ImageColor3 = COR_ICONE
minIcon.ImageTransparency = 0.15
minIcon.ResampleMode = Enum.ResamplerMode.Default
minIcon.ScaleType = Enum.ScaleType.Fit
minIcon.ZIndex = 12
minIcon.Parent = minBtn

maxBtn = Instance.new("TextButton")
maxBtn.Size = UDim2.new(0, 28, 0, 28)
maxBtn.Position = UDim2.new(1, -76, 0.5, -14)
maxBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
maxBtn.BackgroundTransparency = 1
maxBtn.Text = ""
maxBtn.AutoButtonColor = false
maxBtn.ZIndex = 11
maxBtn.Parent = header
Instance.new("UICorner", maxBtn).CornerRadius = UDim.new(0, 7)

maxIcon = Instance.new("ImageLabel")
maxIcon.Size = UDim2.new(0, 16, 0, 16)
maxIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
maxIcon.BackgroundTransparency = 1
maxIcon.Image = ICON_MAXIMIZE
maxIcon.ImageColor3 = COR_ICONE
maxIcon.ImageTransparency = 0.15
maxIcon.ResampleMode = Enum.ResamplerMode.Default
maxIcon.ScaleType = Enum.ScaleType.Fit
maxIcon.ZIndex = 12
maxIcon.Parent = maxBtn

closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -46, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = ""
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 11
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 7)

closeIcon = Instance.new("ImageLabel")
closeIcon.Size = UDim2.new(0, 16, 0, 16)
closeIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
closeIcon.BackgroundTransparency = 1
closeIcon.Image = ICON_CLOSE
closeIcon.ImageColor3 = COR_ICONE
closeIcon.ImageTransparency = 0.15
closeIcon.ResampleMode = Enum.ResamplerMode.Default
closeIcon.ScaleType = Enum.ScaleType.Fit
closeIcon.ZIndex = 12
closeIcon.Parent = closeBtn

minBtn.MouseEnter:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.85, BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
end)
minBtn.MouseLeave:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
end)

maxBtn.MouseEnter:Connect(function()
    TweenService:Create(maxBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.85, BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
end)
maxBtn.MouseLeave:Connect(function()
    TweenService:Create(maxBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
end)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.85, BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
end)

-- ═══════════════════════════════════════════════════════════
-- FOOTER
-- ═══════════════════════════════════════════════════════════
footer = Instance.new("Frame")
footer.Size = UDim2.new(1, 0, 0, FOOTER_H)
footer.Position = UDim2.new(0, 0, 1, -FOOTER_H)
footer.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
footer.BackgroundTransparency = 0.15
footer.BorderSizePixel = 0
footer.ZIndex = 50
footer.Parent = main
Instance.new("UICorner", footer).CornerRadius = UDim.new(0, 24)

footerFix = Instance.new("Frame")
footerFix.Size = UDim2.new(1, 0, 0, 20)
footerFix.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
footerFix.BackgroundTransparency = 0.15
footerFix.BorderSizePixel = 0
footerFix.ZIndex = 51
footerFix.Parent = footer

footerAvatar = Instance.new("ImageLabel")
footerAvatar.Size = UDim2.new(0, 26, 0, 26)
footerAvatar.Position = UDim2.new(0, 10, 0.5, -13)
footerAvatar.BackgroundColor3 = CARD
footerAvatar.BorderSizePixel = 0
footerAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=100&h=100"
footerAvatar.ZIndex = 51
footerAvatar.Parent = footer
Instance.new("UICorner", footerAvatar).CornerRadius = UDim.new(1, 0)

footerName = Instance.new("TextLabel")
footerName.Size = UDim2.new(1, -60, 0, 14)
footerName.Position = UDim2.new(0, 44, 0, 6)
footerName.BackgroundTransparency = 1
footerName.Text = LocalPlayer.DisplayName or LocalPlayer.Name
footerName.TextColor3 = TEXT
footerName.Font = Enum.Font.GothamBold
footerName.TextSize = 10
footerName.TextXAlignment = Enum.TextXAlignment.Left
footerName.ZIndex = 51
footerName.Parent = footer

footerUser = Instance.new("TextLabel")
footerUser.Size = UDim2.new(1, -60, 0, 12)
footerUser.Position = UDim2.new(0, 44, 0, 21)
footerUser.BackgroundTransparency = 1
footerUser.Text = "@" .. LocalPlayer.Name
footerUser.TextColor3 = TEXTDIM
footerUser.Font = Enum.Font.Gotham
footerUser.TextSize = 9
footerUser.TextXAlignment = Enum.TextXAlignment.Left
footerUser.ZIndex = 51
footerUser.Parent = footer

-- ═══════════════════════════════════════════════════════════
-- SIDEBAR + CONTENT
-- ═══════════════════════════════════════════════════════════
sidebarHolder = Instance.new("Frame")
sidebarHolder.Size = UDim2.new(0, SIDEBAR_W, 1, -(HEADER_H + FOOTER_H + 24))
sidebarHolder.Position = UDim2.new(0, 0, 0, HEADER_H)
sidebarHolder.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
sidebarHolder.BackgroundTransparency = 0.5
sidebarHolder.BorderSizePixel = 0
sidebarHolder.ZIndex = 10
sidebarHolder.Parent = main

sidebarScroll = Instance.new("ScrollingFrame")
sidebarScroll.Size = UDim2.new(1, 0, 1, 0)
sidebarScroll.BackgroundTransparency = 1
sidebarScroll.BorderSizePixel = 0
sidebarScroll.ScrollBarThickness = 3
sidebarScroll.ScrollBarImageColor3 = ACCENT
sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebarScroll.ZIndex = 10
sidebarScroll.Parent = sidebarHolder

sidebarLayout = Instance.new("UIListLayout", sidebarScroll)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 2)

sidebarPad = Instance.new("UIPadding", sidebarScroll)
sidebarPad.PaddingTop = UDim.new(0, 6)
sidebarPad.PaddingBottom = UDim.new(0, 6)
sidebarPad.PaddingLeft = UDim.new(0, 6)
sidebarPad.PaddingRight = UDim.new(0, 6)

content = Instance.new("Frame")
content.Size = UDim2.new(1, -SIDEBAR_W, 1, -(HEADER_H + FOOTER_H))
content.Position = UDim2.new(0, SIDEBAR_W, 0, HEADER_H)
content.BackgroundTransparency = 1
content.ZIndex = 100
content.Parent = main

pages = {}
buttons = {}

function setPage(name)
    for n, page in pairs(pages) do
        page.Visible = (n == name)
    end
    for n, btn in pairs(buttons) do
        if n == name then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 70, 130)}):Play()
            local img = btn:FindFirstChildOfClass("ImageLabel")
            if img then img.ImageColor3 = Color3.new(1, 1, 1) end
            local lbl = btn:FindFirstChild("TabLabel")
            if lbl then lbl.TextColor3 = Color3.new(1, 1, 1) end
        else
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
            local img = btn:FindFirstChildOfClass("ImageLabel")
            if img then img.ImageColor3 = TEXTDIM end
            local lbl = btn:FindFirstChild("TabLabel")
            if lbl then lbl.TextColor3 = TEXTDIM end
        end
    end
end

function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = ACCENT
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 110
    page.Parent = content
    pages[name] = page
    return page
end

function createTabButton(name, iconId)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    btn.BackgroundTransparency = 0.35
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 11
    btn.Parent = sidebarScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 14, 0, 14)
    img.Position = UDim2.new(0, 8, 0.5, -7)
    img.BackgroundTransparency = 1
    img.Image = iconId
    img.ImageColor3 = TEXTDIM
    img.ZIndex = 12
    img.Parent = btn
    local lbl = Instance.new("TextLabel")
    lbl.Name = "TabLabel"
    lbl.Size = UDim2.new(1, -30, 1, 0)
    lbl.Position = UDim2.new(0, 26, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = TEXTDIM
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 12
    lbl.Parent = btn
    btn.MouseButton1Click:Connect(function()
        setPage(name)
    end)
    buttons[name] = btn
end

function addPageTitle(page, text, subtext)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -24, 0, 22)
    title.Position = UDim2.new(0, 12, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = TEXT
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 130
    title.Parent = page
    if subtext then
        local sub = Instance.new("TextLabel")
        sub.Size = UDim2.new(1, -24, 0, 14)
        sub.Position = UDim2.new(0, 12, 0, 30)
        sub.BackgroundTransparency = 1
        sub.Text = subtext
        sub.TextColor3 = TEXTDIM
        sub.Font = Enum.Font.Gotham
        sub.TextSize = 10
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.ZIndex = 130
        sub.Parent = page
    end
end
-- ═══════════ PÁGINA HOME ═══════════
homePage = createPage("Home")
addPageTitle(homePage, "Home", "Bem-vindo ao Slow Hub")

profileCard = Instance.new("Frame")
profileCard.Size = UDim2.new(1, -24, 0, 90)
profileCard.Position = UDim2.new(0, 12, 0, 56)
profileCard.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
profileCard.BackgroundTransparency = 0.15
profileCard.BorderSizePixel = 0
profileCard.ZIndex = 120
profileCard.Parent = homePage
Instance.new("UICorner", profileCard).CornerRadius = UDim.new(0, 14)

local profGrad = Instance.new("UIGradient", profileCard)
profGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 20, 35)),
})
profGrad.Rotation = 45

local profStroke = Instance.new("UIStroke", profileCard)
profStroke.Color = PURPLE_BORDER
profStroke.Thickness = 1
profStroke.Transparency = 0.4

profAvatar = Instance.new("ImageLabel")
profAvatar.Size = UDim2.new(0, 60, 0, 60)
profAvatar.Position = UDim2.new(0, 14, 0, 15)
profAvatar.BackgroundColor3 = CARD
profAvatar.BorderSizePixel = 0
profAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
profAvatar.ZIndex = 130
profAvatar.Parent = profileCard
Instance.new("UICorner", profAvatar).CornerRadius = UDim.new(1, 0)
local profAvatarStroke = Instance.new("UIStroke", profAvatar)
profAvatarStroke.Color = PURPLE_BORDER
profAvatarStroke.Thickness = 2

profName = Instance.new("TextLabel")
profName.Size = UDim2.new(1, -100, 0, 20)
profName.Position = UDim2.new(0, 86, 0, 18)
profName.BackgroundTransparency = 1
profName.Text = LocalPlayer.DisplayName or LocalPlayer.Name
profName.TextColor3 = TEXT
profName.Font = Enum.Font.GothamBold
profName.TextSize = 15
profName.TextXAlignment = Enum.TextXAlignment.Left
profName.ZIndex = 130
profName.Parent = profileCard

profUser = Instance.new("TextLabel")
profUser.Size = UDim2.new(1, -100, 0, 14)
profUser.Position = UDim2.new(0, 86, 0, 40)
profUser.BackgroundTransparency = 1
profUser.Text = "@" .. LocalPlayer.Name
profUser.TextColor3 = TEXTDIM
profUser.Font = Enum.Font.Gotham
profUser.TextSize = 10
profUser.TextXAlignment = Enum.TextXAlignment.Left
profUser.ZIndex = 130
profUser.Parent = profileCard

-- 🔑 BADGE (Permanente ou Free User)
profBadge = Instance.new("TextLabel")
profBadge.Size = UDim2.new(0, 110, 0, 20)
profBadge.Position = UDim2.new(1, -122, 0, 18)
profBadge.BackgroundColor3 = TOGGLE_ON_COLOR
profBadge.BackgroundTransparency = 0.15
profBadge.Text = "FREE USER"
profBadge.TextColor3 = Color3.new(1, 1, 1)
profBadge.Font = Enum.Font.GothamBold
profBadge.TextSize = 10
profBadge.ZIndex = 130
profBadge.Parent = profileCard
Instance.new("UICorner", profBadge).CornerRadius = UDim.new(1, 0)

profStatus = Instance.new("TextLabel")
profStatus.Size = UDim2.new(0, 110, 0, 16)
profStatus.Position = UDim2.new(1, -122, 0, 44)
profStatus.BackgroundTransparency = 1
profStatus.Text = "🟢  Key ativa"
profStatus.TextColor3 = SUCCESS
profStatus.Font = Enum.Font.GothamMedium
profStatus.TextSize = 9
profStatus.TextXAlignment = Enum.TextXAlignment.Right
profStatus.ZIndex = 130
profStatus.Parent = profileCard

-- 🔑 Atualiza o badge conforme o tipo de key
task.spawn(function()
    task.wait(0.3)
    if profBadge and profBadge.Parent then
        if isPermanent() then
            profBadge.Text = "👑 PERMANENTE"
            profBadge.BackgroundColor3 = GOLD_COLOR
            profBadge.TextColor3 = Color3.fromRGB(30, 20, 0)
        else
            profBadge.Text = "FREE USER"
            profBadge.BackgroundColor3 = ACCENT
            profBadge.TextColor3 = Color3.new(1, 1, 1)
        end
    end
end)

function createInfoBox(x, y, w, h, icon, label, valorInicial, corIcon)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, w, 0, h)
    box.Position = UDim2.new(0, x, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    box.BackgroundTransparency = 0.2
    box.BorderSizePixel = 0
    box.ZIndex = 120
    box.Parent = homePage
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
    local bStroke = Instance.new("UIStroke", box)
    bStroke.Color = corIcon or PURPLE_BORDER
    bStroke.Thickness = 1
    bStroke.Transparency = 0.6

    local bIcon = Instance.new("ImageLabel")
    bIcon.Size = UDim2.new(0, 16, 0, 16)
    bIcon.Position = UDim2.new(0, 8, 0, 6)
    bIcon.BackgroundTransparency = 1
    bIcon.Image = icon or ICONS.Star
    bIcon.ImageColor3 = corIcon or PURPLE_BORDER
    bIcon.ZIndex = 130
    bIcon.Parent = box

    local bLabel = Instance.new("TextLabel")
    bLabel.Size = UDim2.new(1, -10, 0, 10)
    bLabel.Position = UDim2.new(0, 8, 0, 26)
    bLabel.BackgroundTransparency = 1
    bLabel.Text = label
    bLabel.TextColor3 = TEXTDIM
    bLabel.Font = Enum.Font.Gotham
    bLabel.TextSize = 8
    bLabel.TextXAlignment = Enum.TextXAlignment.Left
    bLabel.ZIndex = 130
    bLabel.Parent = box

    local bValor = Instance.new("TextLabel")
    bValor.Size = UDim2.new(1, -10, 0, 14)
    bValor.Position = UDim2.new(0, 8, 0, 38)
    bValor.BackgroundTransparency = 1
    bValor.Text = valorInicial
    bValor.TextColor3 = TEXT
    bValor.Font = Enum.Font.GothamBold
    bValor.TextSize = 11
    bValor.TextXAlignment = Enum.TextXAlignment.Left
    bValor.ZIndex = 130
    bValor.Parent = box

    return box, bValor
end

local infoY = 154
local infoW = 82
local infoGap = 4

local boxFPS, valorFPS = createInfoBox(12, infoY, infoW, 58, ICONS.Lightning, "FPS", "...", Color3.fromRGB(100, 200, 255))
local boxPing, valorPing = createInfoBox(12 + infoW + infoGap, infoY, infoW, 58, ICONS.Info, "PING", "...", Color3.fromRGB(255, 200, 100))
local boxPlayers, valorPlayers = createInfoBox(12 + (infoW + infoGap) * 2, infoY, infoW, 58, ICONS.Person, "PLAYERS", "...", Color3.fromRGB(150, 255, 150))
local boxUptime, valorUptime = createInfoBox(12 + (infoW + infoGap) * 3, infoY, infoW, 58, ICONS.Star, "UPTIME", "0s", Color3.fromRGB(255, 150, 220))

tipCard = Instance.new("Frame")
tipCard.Size = UDim2.new(1, -24, 0, 50)
tipCard.Position = UDim2.new(0, 12, 0, 222)
tipCard.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
tipCard.BackgroundTransparency = 0.2
tipCard.BorderSizePixel = 0
tipCard.ZIndex = 120
tipCard.Parent = homePage
Instance.new("UICorner", tipCard).CornerRadius = UDim.new(0, 10)
local tipStroke = Instance.new("UIStroke", tipCard)
tipStroke.Color = PURPLE_BORDER
tipStroke.Thickness = 1
tipStroke.Transparency = 0.6

local tipIcon = Instance.new("ImageLabel")
tipIcon.Size = UDim2.new(0, 18, 0, 18)
tipIcon.Position = UDim2.new(0, 10, 0, 16)
tipIcon.BackgroundTransparency = 1
tipIcon.Image = ICONS.Info
tipIcon.ImageColor3 = PURPLE_BORDER
tipIcon.ZIndex = 130
tipIcon.Parent = tipCard

local tipTitle = Instance.new("TextLabel")
tipTitle.Size = UDim2.new(1, -40, 0, 14)
tipTitle.Position = UDim2.new(0, 34, 0, 8)
tipTitle.BackgroundTransparency = 1
tipTitle.Text = "Dica rápida"
tipTitle.TextColor3 = TEXT
tipTitle.Font = Enum.Font.GothamBold
tipTitle.TextSize = 10
tipTitle.TextXAlignment = Enum.TextXAlignment.Left
tipTitle.ZIndex = 130
tipTitle.Parent = tipCard

local tipDesc = Instance.new("TextLabel")
tipDesc.Size = UDim2.new(1, -40, 0, 24)
tipDesc.Position = UDim2.new(0, 34, 0, 22)
tipDesc.BackgroundTransparency = 1
tipDesc.Text = "Use o menu lateral para acessar todas as funções. Suas configs são salvas automaticamente."
tipDesc.TextColor3 = TEXTDIM
tipDesc.Font = Enum.Font.Gotham
tipDesc.TextSize = 9
tipDesc.TextXAlignment = Enum.TextXAlignment.Left
tipDesc.TextWrapped = true
tipDesc.ZIndex = 130
tipDesc.Parent = tipCard

task.spawn(function()
    local frameCount = 0
    local ultimoTempo = tick()
    local fpsAtual = 60

    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local agora = tick()
        if agora - ultimoTempo >= 0.5 then
            fpsAtual = math.floor(frameCount / (agora - ultimoTempo))
            frameCount = 0
            ultimoTempo = agora
        end
    end)

    while task.wait(1) do
        if valorFPS and valorFPS.Parent then
            valorFPS.Text = tostring(fpsAtual)
        end
        if valorPing and valorPing.Parent then
            local p = getPing()
            valorPing.Text = p .. "ms"
            if p < 80 then
                valorPing.TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif p < 150 then
                valorPing.TextColor3 = Color3.fromRGB(255, 220, 100)
            else
                valorPing.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end
        if valorPlayers and valorPlayers.Parent then
            local atual, max = getPlayersCount()
            valorPlayers.Text = atual .. "/" .. max
        end
        if valorUptime and valorUptime.Parent then
            local s = getUptime()
            if s < 60 then
                valorUptime.Text = s .. "s"
            elseif s < 3600 then
                valorUptime.Text = math.floor(s / 60) .. "m"
            else
                valorUptime.Text = math.floor(s / 3600) .. "h"
            end
        end
    end
end)
