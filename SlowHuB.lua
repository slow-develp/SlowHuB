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

local KEY = "SlowHubVIP"
local DISCORD_LINK = "https://discord.com/users/tav.x"
local SCRIPT_URL = "https://raw.githubusercontent.com/slow-develp/slowhub/main/slowhub.lua"

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
    if d.Box then d.Box.Visible = false end
    if d.Line then d.Line.Visible = false end
    if d.Name then d.Name.Visible = false end
    if d.Dist then d.Dist.Visible = false end
    if d.HpBg then d.HpBg.Visible = false end
    if d.Stick then
        if d.Stick.Body then d.Stick.Body.Visible = false end
        if d.Stick.ArmL then d.Stick.ArmL.Visible = false end
        if d.Stick.ArmR then d.Stick.ArmR.Visible = false end
        if d.Stick.LegL then d.Stick.LegL.Visible = false end
        if d.Stick.LegR then d.Stick.LegR.Visible = false end
    end
end

function updateESP()
    if not Config.ESP.Enabled then
        for _, d in pairs(espData) do hideESP(d) end
        return
    end

    local localChar = LocalPlayer.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local vp = Camera.ViewportSize

    -- Cria ESP pra todos os players
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and not espData[plr] then
            createESP(plr)
        end
    end

    -- Remove players que saíram
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
                            else
                                d.Name.Visible = false
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
                            else
                                d.Dist.Visible = false
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
                            else
                                d.HpBg.Visible = false
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
                            elseif d.Line then
                                d.Line.Visible = false
                            end

                            if Config.ESP.ShowHighlight and d.Stick then
                                if d.Stick.Body then d.Stick.Body.Visible = false end
                                if d.Stick.ArmL then d.Stick.ArmL.Visible = false end
                                if d.Stick.ArmR then d.Stick.ArmR.Visible = false end
                                if d.Stick.LegL then d.Stick.LegL.Visible = false end
                                if d.Stick.LegR then d.Stick.LegR.Visible = false end

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

                                local function desenhaLinha(frame, p1, p2, espessura)
                                    if not p1 or not p2 then
                                        frame.Visible = false
                                        return
                                    end
                                    local dx2 = p2.X - p1.X
                                    local dy2 = p2.Y - p1.Y
                                    local dist2 = math.sqrt(dx2 * dx2 + dy2 * dy2)
                                    local mx = (p1.X + p2.X) / 2
                                    local my = (p1.Y + p2.Y) / 2
                                    local ang = math.deg(math.atan2(-dx2, dy2))
                                    frame.Visible = true
                                    frame.Position = UDim2.new(0, mx, 0, my)
                                    frame.Size = UDim2.new(0, espessura or 2, 0, dist2)
                                    frame.Rotation = ang
                                    frame.BackgroundColor3 = cor
                                end

                                desenhaLinha(d.Stick.Body, pPescoco, pQuadril, 2)
                                desenhaLinha(d.Stick.ArmL, pOmbroE, pMaoE, 2)
                                desenhaLinha(d.Stick.ArmR, pOmbroD, pMaoD, 2)
                                desenhaLinha(d.Stick.LegL, pQuadril, pPeE, 2)
                                desenhaLinha(d.Stick.LegR, pQuadril, pPeD, 2)
                            end
                        else
                            hideESP(d)
                        end
                    else
                        hideESP(d)
                    end
                else
                    hideESP(d)
                end
            else
                hideESP(d)
            end
        else
            hideESP(d)
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
    local closest, closestDist = nil, math.huge
    local vp = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr, Config.Aimbot.TeamCheck) then
            local char, hum, hrp = safeChar(plr)
            if char and hrp and char.Parent and plr.Parent then
                local passWallCheck = true
                if Config.Aimbot.WallCheck then
                    passWallCheck = hasLineOfSight(char)
                end
                if passWallCheck then
                    local part = (Config.Aimbot.Target == "Head") and char:FindFirstChild("Head") or hrp
                    if part and part.Parent then
                        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                                    if onScreen and pos.Z > 0 then
                            local screenPos = Vector2.new(pos.X, pos.Y)
                            local dist = (screenPos - center).Magnitude
                            if dist <= Config.Aimbot.FOVSize and dist < closestDist then
                                closest, closestDist = part, dist
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- ═══════════ AUTOSHOT INTELIGENTE ═══════════
aimbotActive = false
_ultimoTiro = 0
_rajadaRestante = 0
_ultimoAlvo = nil

COOLDOWN_HEAD = 0.07
COOLDOWN_RAJADA = 0.06
COOLDOWN_NORMAL = 0.03
TAMANHO_RAJADA = 6

atirarMetodoDetectado = nil
atirarBotaoCache = nil
atirarTentativas = 0

-- 🔍 Lista de palavras comuns (o script procura em qualquer botão)
local PALAVRAS_TIRO = {
    "fire", "shoot", "atirar", "tiro", "gun", "arma", "weapon",
    "attack", "atacar", "ataque", "hit", "punch", "soco", "bater",
    "skill", "poder", "habilidade", "ability", "cast", "usar", "use",
    "action", "acao", "combat", "combate", "strike", "golpe",
    "shot", "blast", "explosao", "bomb", "bomba", "throw", "lancar",
    "swing", "slash", "corte", "cut", "spell", "magia", "magic",
}

-- 🔍 Verifica se o nome do botão bate com alguma palavra
local function nomeBateTiro(nome)
    local n = string.lower(nome or "")
    for _, palavra in ipairs(PALAVRAS_TIRO) do
        if n:find(palavra) then
            return true
        end
    end
    return false
end

-- 🔍 Verifica se o botão tá na área do "polegar" (canto inferior direito)
local function botaoNaAreaAtaque(btn)
    local vp = Camera.ViewportSize
    local pos = btn.AbsolutePosition
    local size = btn.AbsoluteSize
    if size.X <= 0 or size.Y <= 0 then return false end

    local cx = pos.X + size.X / 2
    local cy = pos.Y + size.Y / 2

    -- Considera "área de ataque" o quadrante inferior direito (60% da tela)
    local limiteX = vp.X * 0.4
    local limiteY = vp.Y * 0.4

    return cx > limiteX and cy > limiteY
end

-- 🔍 Verifica se o botão tem conexão clicável
local function botaoClicavel(btn)
    if type(getconnections) ~= "function" then
        return true  -- assume que sim (vai tentar VirtualInputManager)
    end
    local tipos = {"Activated", "MouseButton1Down", "MouseButton1Up", "MouseButton1Click", "InputBegan", "TouchTap"}
    for _, tipo in ipairs(tipos) do
        local ok, conns = pcall(getconnections, btn[tipo])
        if ok and conns and #conns > 0 then
            return true
        end
    end
    return false
end

-- 🔍 FUNÇÃO INTELIGENTE: procura botão de atirar
function detectarMetodoTiro()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return "tool" end

    -- ═══════════ MÉTODO 1: Fluxo PvP (prioridade máxima) ═══════════
    local hud = pg:FindFirstChild("ButtonsHUD")
    if hud then
        local botoes = hud:FindFirstChild("BotoesArma")
        if botoes then
            local fb = botoes:FindFirstChild("FireButton")
            if fb then
                local ok, conns = pcall(getconnections, fb.InputBegan)
                if ok and conns and #conns > 0 then
                    atirarBotaoCache = fb
                    return "fluxo"
                end
            end
        end
    end

    -- ═══════════ MÉTODO 2: Procura botão por NOME ═══════════
    local botaoPorNome = nil
    local botaoNaArea = nil

    for _, obj in ipairs(pg:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            if obj.Visible and obj.AbsoluteSize.X > 0 then
                -- Prioridade 1: nome bate com palavra de tiro
                if nomeBateTiro(obj.Name) then
                    if botaoClicavel(obj) then
                        botaoPorNome = obj
                        break
                    end
                end
                -- Prioridade 2: botão na área de ataque (canto inferior direito)
                if not botaoNaArea and botaoNaAreaAtaque(obj) and botaoClicavel(obj) then
                    -- Ignora botões muito pequenos (geralmente são de UI)
                    if obj.AbsoluteSize.X > 30 and obj.AbsoluteSize.Y > 30 then
                        botaoNaArea = obj
                    end
                end
            end
        end
    end

    if botaoPorNome then
        atirarBotaoCache = botaoPorNome
        return "toque"
    end

    if botaoNaArea then
        atirarBotaoCache = botaoNaArea
        return "toque"
    end

    -- ═══════════ MÉTODO 3: Tool ativa (fallback) ═══════════
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then return "tool" end
    end

    return "toque"
end

-- 🎯 FUNÇÃO DE ATIRAR (inteligente, tenta várias abordagens)
function atirarFluxo()
    local metodo = atirarMetodoDetectado or detectarMetodoTiro()
    atirarMetodoDetectado = metodo

    -- ═══════════ MÉTODO FLUXO PVP ═══════════
    if metodo == "fluxo" and atirarBotaoCache and atirarBotaoCache.Parent then
        if type(getconnections) ~= "function" then
            metodo = "toque"
        else
            local fb = atirarBotaoCache

            local ok, conns = pcall(getconnections, fb.InputBegan)
            if ok and conns and #conns > 0 then
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

            local ok3, conns3 = pcall(getconnections, fb.MouseButton1Click)
            if ok3 and conns3 and #conns3 > 0 then
                for _, c in ipairs(conns3) do
                    pcall(function()
                        if c.Function then c.Function() end
                    end)
                end
                return true
            end

            metodo = "toque"
        end
    end

    -- ═══════════ MÉTODO TOQUE (inteligente) ═══════════
    if metodo == "toque" and atirarBotaoCache and atirarBotaoCache.Parent then
        local btn = atirarBotaoCache

        -- Tenta getconnections em TODOS os tipos de conexão
        if type(getconnections) == "function" then
            local tipos = {
                "Activated",
                "MouseButton1Down",
                "MouseButton1Up",
                "MouseButton1Click",
                "InputBegan",
                "TouchTap",
                "TouchLongPress",
            }
            for _, tipo in ipairs(tipos) do
                local ok, conns = pcall(getconnections, btn[tipo])
                if ok and conns and #conns > 0 then
                    for _, c in ipairs(conns) do
                        pcall(function()
                            if c.Function then
                                if tipo == "InputBegan" then
                                    c.Function({
                                        UserInputType = Enum.UserInputType.MouseButton1,
                                        UserInputState = Enum.UserInputState.Begin,
                                        Position = Vector3.zero,
                                        Delta = Vector3.zero,
                                        KeyCode = Enum.KeyCode.Unknown
                                    })
                                elseif tipo == "InputEnded" then
                                    c.Function({
                                        UserInputType = Enum.UserInputType.MouseButton1,
                                        UserInputState = Enum.UserInputState.End,
                                        Position = Vector3.zero,
                                        Delta = Vector3.zero,
                                        KeyCode = Enum.KeyCode.Unknown
                                    })
                                else
                                    c.Function()
                                end
                            end
                        end)
                    end
                end
            end
        end

        -- Fallback: VirtualInputManager (clica na posição do botão)
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            local pos = btn.AbsolutePosition
            local size = btn.AbsoluteSize
            local x = pos.X + size.X / 2
            local y = pos.Y + size.Y / 2
            vim:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.02)
            vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end)

        return true
    end

    -- ═══════════ MÉTODO TOOL (fallback final) ═══════════
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and type(tool.Activate) == "function" then
            pcall(function() tool:Activate() end)
            return true
        end
    end

    return false
end

-- 🔄 Re-detecção inteligente (a cada 5s, ou se o botão sumiu)
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            if Config and Config.Aimbot and Config.Aimbot.Enabled then
                -- Se o botão sumiu da tela
                if atirarBotaoCache and (not atirarBotaoCache.Parent or not atirarBotaoCache.Visible) then
                    atirarMetodoDetectado = nil
                    atirarBotaoCache = nil
                    atirarTentativas = 0
                end

                -- Se ainda não detectou nada
                if not atirarMetodoDetectado then
                    detectarMetodoTiro()
                end

                -- Se tentou várias vezes e não achou, reseta
                atirarTentativas = atirarTentativas + 1
                if atirarTentativas > 12 and not atirarBotaoCache then
                    atirarMetodoDetectado = nil
                    atirarTentativas = 0
                end
            end
        end)
    end
end)            

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
                pcall(function() aplicarHitboxEmPlayer(plr) end)
            end
        end
    end)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            plr.CharacterAdded:Connect(function()
                if Config.Hitbox.Enabled then
                    task.wait(0.5)
                    hitboxExtraPartes[plr] = {}
                    pcall(function() aplicarHitboxEmPlayer(plr) end)
                end
            end)
        end
    end

    Players.PlayerAdded:Connect(function(plr)
        if Config.Hitbox.Enabled and plr ~= LocalPlayer then
            plr.CharacterAdded:Connect(function()
                if Config.Hitbox.Enabled then
                    task.wait(0.5)
                    hitboxExtraPartes[plr] = {}
                    pcall(function() aplicarHitboxEmPlayer(plr) end)
                end
            end)
        end
    end)
end

Players.PlayerRemoving:Connect(function(plr)
    if hitboxExtraPartes[plr] then
        for _, part in ipairs(hitboxExtraPartes[plr]) do
            if part and part.Parent then
                pcall(function() part:Destroy() end)
            end
        end
        hitboxExtraPartes[plr] = nil
    end
end)

function trackPlayer(plr)
    if plr == LocalPlayer then return end
    createESP(plr)
end
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

-- SPEED
speedConn = nil
function setSpeed(state)
    if speedConn then speedConn:Disconnect() speedConn = nil end
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

-- FLY
flyConn = nil
flyBodyVel = nil
flyBodyGyro = nil

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
    flyBodyVel.P = 8000
    flyBodyVel.Velocity = Vector3.zero
    flyBodyVel.Parent = hrp

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.Name = "SlowHub_FlyGyro"
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.P = 15000
    flyBodyGyro.D = 200
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
            flyBodyVel.P = 8000
            flyBodyVel.Velocity = Vector3.zero
            flyBodyVel.Parent = hrp
        end
        if not flyBodyGyro or not flyBodyGyro.Parent then
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.Name = "SlowHub_FlyGyro"
            flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBodyGyro.P = 15000
            flyBodyGyro.D = 200
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
        flyBodyVel.Velocity = currentVel:Lerp(move, 0.3)
        flyBodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.LookVector)
    end)
end

function setFly(state)
    if state then
        startFly()
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

keyGui = Instance.new("ScreenGui")
keyGui.Name = "SlowHubKey"
keyGui.ResetOnSpawn = false
keyGui.IgnoreGuiInset = true
keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
keyGui.DisplayOrder = 10000
keyGui.Parent = parentGui

keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 400, 0, 300)
keyFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
keyFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
keyFrame.BackgroundTransparency = 0.1
keyFrame.BorderSizePixel = 0
keyFrame.Active = true
keyFrame.Parent = keyGui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 24)

keyStroke = Instance.new("UIStroke", keyFrame)
keyStroke.Color = PURPLE_BORDER
keyStroke.Thickness = 1.5
keyStroke.Transparency = 0.2

keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, -32, 0, 30)
keyTitle.Position = UDim2.new(0, 16, 0, 22)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "Slow Hub"
keyTitle.TextColor3 = TEXT
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 20
keyTitle.TextXAlignment = Enum.TextXAlignment.Left
keyTitle.Parent = keyFrame

keySub = Instance.new("TextLabel")
keySub.Size = UDim2.new(1, -32, 0, 20)
keySub.Position = UDim2.new(0, 16, 0, 54)
keySub.BackgroundTransparency = 1
keySub.Text = "Key Authentication System"
keySub.TextColor3 = TEXTDIM
keySub.Font = Enum.Font.Gotham
keySub.TextSize = 12
keySub.TextXAlignment = Enum.TextXAlignment.Left
keySub.Parent = keyFrame

keyLine = Instance.new("Frame")
keyLine.Size = UDim2.new(1, -32, 0, 1)
keyLine.Position = UDim2.new(0, 16, 0, 84)
keyLine.BackgroundColor3 = STROKE
keyLine.BorderSizePixel = 0
keyLine.Parent = keyFrame

keyInfo = Instance.new("TextLabel")
keyInfo.Size = UDim2.new(1, -32, 0, 40)
keyInfo.Position = UDim2.new(0, 16, 0, 96)
keyInfo.BackgroundTransparency = 1
keyInfo.Text = "Insira sua key para continuar."
keyInfo.TextColor3 = TEXTDIM
keyInfo.Font = Enum.Font.Gotham
keyInfo.TextSize = 12
keyInfo.TextXAlignment = Enum.TextXAlignment.Left
keyInfo.TextYAlignment = Enum.TextYAlignment.Top
keyInfo.TextWrapped = true
keyInfo.Parent = keyFrame

keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(1, -32, 0, 40)
keyInput.Position = UDim2.new(0, 16, 0, 138)
keyInput.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
keyInput.BorderSizePixel = 0
keyInput.Text = ""
keyInput.PlaceholderText = "Digite sua key..."
keyInput.PlaceholderColor3 = TEXTDIM
keyInput.TextColor3 = TEXT
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 13
keyInput.ClearTextOnFocus = false
keyInput.Parent = keyFrame
Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 8)

discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(1, -32, 0, 36)
discordBtn.Position = UDim2.new(0, 16, 0, 188)
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.Text = "Adquirir a Key"
discordBtn.TextColor3 = Color3.new(1, 1, 1)
discordBtn.Font = Enum.Font.GothamBold
discordBtn.TextSize = 12
discordBtn.AutoButtonColor = false
discordBtn.Parent = keyFrame
Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 8)

submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(1, -32, 0, 38)
submitBtn.Position = UDim2.new(0, 16, 1, -56)
submitBtn.BackgroundColor3 = ACCENT
submitBtn.Text = "VALIDAR KEY"
submitBtn.TextColor3 = Color3.new(1, 1, 1)
submitBtn.Font = Enum.Font.GothamBold
submitBtn.TextSize = 13
submitBtn.AutoButtonColor = false
submitBtn.Parent = keyFrame
Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 8)

keyStatus = Instance.new("TextLabel")
keyStatus.Size = UDim2.new(1, -32, 0, 16)
keyStatus.Position = UDim2.new(0, 16, 1, -74)
keyStatus.BackgroundTransparency = 1
keyStatus.Text = ""
keyStatus.TextColor3 = DANGER
keyStatus.Font = Enum.Font.Gotham
keyStatus.TextSize = 11
keyStatus.TextXAlignment = Enum.TextXAlignment.Left
keyStatus.Parent = keyFrame

discordBtn.MouseButton1Click:Connect(function()
    pcall(function() openDiscord() end)
end)

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
    previewStroke.Color = Color3.fromRGB(255, 255, 255)
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
            strokeSel.Color = Color3.fromRGB(255, 255, 255)
            strokeSel.Thickness = 2.5
            selecionado = strokeSel
        end

        swatch.MouseButton1Click:Connect(function()
            if selecionado and selecionado.Parent then
                selecionado:Destroy()
            end
            local novoSel = Instance.new("UIStroke", swatch)
            novoSel.Color = Color3.fromRGB(255, 255, 255)
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

profBadge = Instance.new("TextLabel")
profBadge.Size = UDim2.new(0, 90, 0, 20)
profBadge.Position = UDim2.new(1, -102, 0, 18)
profBadge.BackgroundColor3 = TOGGLE_ON_COLOR
profBadge.BackgroundTransparency = 0.15
profBadge.Text = "⭐  VIP"
profBadge.TextColor3 = Color3.new(1, 1, 1)
profBadge.Font = Enum.Font.GothamBold
profBadge.TextSize = 10
profBadge.ZIndex = 130
profBadge.Parent = profileCard
Instance.new("UICorner", profBadge).CornerRadius = UDim.new(1, 0)

profStatus = Instance.new("TextLabel")
profStatus.Size = UDim2.new(0, 90, 0, 16)
profStatus.Position = UDim2.new(1, -102, 0, 44)
profStatus.BackgroundTransparency = 1
profStatus.Text = "🟢  Key ativa"
profStatus.TextColor3 = SUCCESS
profStatus.Font = Enum.Font.GothamMedium
profStatus.TextSize = 9
profStatus.TextXAlignment = Enum.TextXAlignment.Right
profStatus.ZIndex = 130
profStatus.Parent = profileCard

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

-- ═══════════ PÁGINA JOGADORES ═══════════
playersPage = createPage("Jogadores")
addPageTitle(playersPage, "Jogadores", "Lista de jogadores no servidor")

searchBar = Instance.new("Frame")
searchBar.Size = UDim2.new(1, -24, 0, 30)
searchBar.Position = UDim2.new(0, 12, 0, 50)
searchBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
searchBar.BackgroundTransparency = 0.4
searchBar.BorderSizePixel = 0
searchBar.ZIndex = 120
searchBar.Parent = playersPage
Instance.new("UICorner", searchBar).CornerRadius = UDim.new(0, 8)

searchIcon = Instance.new("ImageLabel")
searchIcon.Size = UDim2.new(0, 14, 0, 14)
searchIcon.Position = UDim2.new(0, 8, 0.5, -7)
searchIcon.BackgroundTransparency = 1
searchIcon.Image = ICONS.Person
searchIcon.ImageColor3 = TEXTDIM
searchIcon.ZIndex = 130
searchIcon.Parent = searchBar

searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -30, 1, 0)
searchBox.Position = UDim2.new(0, 28, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""
searchBox.PlaceholderText = "Buscar jogador..."
searchBox.PlaceholderColor3 = TEXTDIM
searchBox.TextColor3 = TEXT
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 11
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.ZIndex = 130
searchBox.Parent = searchBar

playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, -24, 1, -90)
playerScroll.Position = UDim2.new(0, 12, 0, 86)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 3
playerScroll.ScrollBarImageColor3 = ACCENT
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerScroll.ZIndex = 120
playerScroll.Parent = playersPage

playerLayout = Instance.new("UIListLayout", playerScroll)
playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerLayout.Padding = UDim.new(0, 4)

playerPad = Instance.new("UIPadding", playerScroll)
playerPad.PaddingTop = UDim.new(0, 2)
playerPad.PaddingBottom = UDim.new(0, 6)
playerPad.PaddingLeft = UDim.new(0, 2)
playerPad.PaddingRight = UDim.new(0, 2)

playerCards = {}

function createPlayerCard(plr, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -4, 0, 40)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    card.BackgroundTransparency = 0.3
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.ZIndex = 130
    card.Parent = playerScroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 28, 0, 28)
    avatar.Position = UDim2.new(0, 8, 0.5, -14)
    avatar.BackgroundColor3 = CARD
    avatar.BorderSizePixel = 0
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=100&h=100"
    avatar.ZIndex = 140
    avatar.Parent = card
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -140, 0, 14)
    nameLbl.Position = UDim2.new(0, 44, 0, 5)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = plr.DisplayName or plr.Name
    nameLbl.TextColor3 = TEXT
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 140
    nameLbl.Parent = card

    local userLbl = Instance.new("TextLabel")
    userLbl.Size = UDim2.new(1, -140, 0, 12)
    userLbl.Position = UDim2.new(0, 44, 0, 20)
    userLbl.BackgroundTransparency = 1
    userLbl.Text = "@" .. plr.Name
    userLbl.TextColor3 = TEXTDIM
    userLbl.Font = Enum.Font.Gotham
    userLbl.TextSize = 9
    userLbl.TextXAlignment = Enum.TextXAlignment.Left
    userLbl.ZIndex = 140
    userLbl.Parent = card

    local gotoBtn = Instance.new("TextButton")
    gotoBtn.Size = UDim2.new(0, 60, 0, 24)
    gotoBtn.Position = UDim2.new(1, -68, 0.5, -12)
    gotoBtn.BackgroundColor3 = TOGGLE_ON_COLOR
    gotoBtn.Text = "Goto"
    gotoBtn.TextColor3 = Color3.new(1, 1, 1)
    gotoBtn.Font = Enum.Font.GothamBold
    gotoBtn.TextSize = 10
    gotoBtn.AutoButtonColor = false
    gotoBtn.ZIndex = 140
    gotoBtn.Parent = card
    Instance.new("UICorner", gotoBtn).CornerRadius = UDim.new(0, 6)

    gotoBtn.MouseButton1Click:Connect(function()
        local ok = gotoPlayer(plr)
        if ok then
            addNotif("Goto", "Teleportado para " .. plr.Name)
        else
            addNotif("Erro", "Não foi possível teleportar.")
        end
    end)

    playerCards[plr.UserId] = {
        frame = card,
        name = string.lower(plr.DisplayName or plr.Name),
        username = string.lower(plr.Name)
    }
end

function refreshPlayers()
    for _, data in pairs(playerCards) do
        if data.frame then data.frame:Destroy() end
    end
    playerCards = {}
    local order = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            order += 1
            createPlayerCard(plr, order)
        end
    end
end

refreshPlayers()

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(searchBox.Text or "")
    for _, data in pairs(playerCards) do
        if data.frame and data.frame.Parent then
            local match = q == ""
                or string.find(data.name, q, 1, true)
                or string.find(data.username, q, 1, true)
            data.frame.Visible = match
        end
    end
end)

Players.PlayerAdded:Connect(function()
    task.wait(1)
    refreshPlayers()
end)

Players.PlayerRemoving:Connect(function(plr)
    local data = playerCards[plr.UserId]
    if data and data.frame then data.frame:Destroy() end
    playerCards[plr.UserId] = nil
end)

-- ═══════════ PÁGINA MOVIMENTO ═══════════
movementPage = createPage("Movimento")
addPageTitle(movementPage, "Movimento", "Noclip, Speed, Fly, Inf Jump")

noclipCard = makeCard(movementPage, 56, 32)
makeLabel(noclipCard, "Noclip", 10, 200)
makeToggle(noclipCard, Config.Noclip.Enabled, function(s)
    Config.Noclip.Enabled = s
    setNoclip(s)
end)

speedCard = makeCard(movementPage, 94, 32)
makeLabel(speedCard, "Speed", 10, 150)
speedInput = makeInput(speedCard, 6, tostring(Config.Speed.Value), 50, function(txt)
    local n = tonumber(txt)
    if n then Config.Speed.Value = math.clamp(n, 16, 200) end
end)
speedInput.Position = UDim2.new(1, -110, 0.5, -12)
makeToggle(speedCard, Config.Speed.Enabled, function(s)
    Config.Speed.Enabled = s
    setSpeed(s)
end)

flyCard = makeCard(movementPage, 132, 32)
makeLabel(flyCard, "Fly", 10, 100)
flySpeedInput = makeInput(flyCard, 6, tostring(Config.Fly.Speed), 50, function(txt)
    local n = tonumber(txt)
    if n then Config.Fly.Speed = math.clamp(n, 10, 500) end
end)
flySpeedInput.Position = UDim2.new(1, -110, 0.5, -12)
makeToggle(flyCard, Config.Fly.Enabled, function(s)
    Config.Fly.Enabled = s
    setFly(s)
end)

jumpCard = makeCard(movementPage, 170, 32)
makeLabel(jumpCard, "Infinite Jump", 10, 200)
makeToggle(jumpCard, Config.InfiniteJump.Enabled, function(s)
    Config.InfiniteJump.Enabled = s
    setInfJump(s)
end)

-- ═══════════ PÁGINA FLING ═══════════
flingPage = createPage("Fling")
addPageTitle(flingPage, "Fling", "Selecione os jogadores pra arremessar")

flingSearchBar = Instance.new("Frame")
flingSearchBar.Size = UDim2.new(1, -24, 0, 32)
flingSearchBar.Position = UDim2.new(0, 12, 0, 50)
flingSearchBar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
flingSearchBar.BackgroundTransparency = 0.2
flingSearchBar.BorderSizePixel = 0
flingSearchBar.ZIndex = 120
flingSearchBar.Parent = flingPage
Instance.new("UICorner", flingSearchBar).CornerRadius = UDim.new(0, 10)
local sbStroke = Instance.new("UIStroke", flingSearchBar)
sbStroke.Color = PURPLE_BORDER
sbStroke.Thickness = 1
sbStroke.Transparency = 0.6

flingSearchIcon = Instance.new("ImageLabel")
flingSearchIcon.Size = UDim2.new(0, 14, 0, 14)
flingSearchIcon.Position = UDim2.new(0, 10, 0.5, -7)
flingSearchIcon.BackgroundTransparency = 1
flingSearchIcon.Image = ICONS.Person
flingSearchIcon.ImageColor3 = PURPLE_BORDER
flingSearchIcon.ZIndex = 130
flingSearchIcon.Parent = flingSearchBar

flingSearchBox = Instance.new("TextBox")
flingSearchBox.Size = UDim2.new(1, -32, 1, 0)
flingSearchBox.Position = UDim2.new(0, 30, 0, 0)
flingSearchBox.BackgroundTransparency = 1
flingSearchBox.Text = ""
flingSearchBox.PlaceholderText = "Buscar jogador..."
flingSearchBox.PlaceholderColor3 = TEXTDIM
flingSearchBox.TextColor3 = TEXT
flingSearchBox.Font = Enum.Font.Gotham
flingSearchBox.TextSize = 11
flingSearchBox.TextXAlignment = Enum.TextXAlignment.Left
flingSearchBox.ClearTextOnFocus = false
flingSearchBox.ZIndex = 130
flingSearchBox.Parent = flingSearchBar

flingList = Instance.new("ScrollingFrame")
flingList.Size = UDim2.new(1, -24, 1, -220)
flingList.Position = UDim2.new(0, 12, 0, 88)
flingList.BackgroundTransparency = 1
flingList.BorderSizePixel = 0
flingList.ScrollBarThickness = 3
flingList.ScrollBarImageColor3 = ACCENT
flingList.CanvasSize = UDim2.new(0, 0, 0, 0)
flingList.AutomaticCanvasSize = Enum.AutomaticSize.Y
flingList.ZIndex = 120
flingList.Parent = flingPage

flingListLayout = Instance.new("UIListLayout", flingList)
flingListLayout.SortOrder = Enum.SortOrder.LayoutOrder
flingListLayout.Padding = UDim.new(0, 6)

flingListPad = Instance.new("UIPadding", flingList)
flingListPad.PaddingTop = UDim.new(0, 4)
flingListPad.PaddingBottom = UDim.new(0, 6)
flingListPad.PaddingLeft = UDim.new(0, 4)
flingListPad.PaddingRight = UDim.new(0, 4)

flingSelectedTargets = {}
flingCards = {}

function updateFlingStatus()
    local count = 0
    for _ in pairs(flingSelectedTargets) do count = count + 1 end
    if flingActiveStatus and flingActiveStatus.Parent then
        if flingActive then
            flingActiveStatus.Text = "🟢  Flingando " .. count .. " jogador(es)"
            flingActiveStatus.TextColor3 = Color3.fromRGB(80, 220, 120)
        else
            flingActiveStatus.Text = "⚪  " .. count .. " jogador(es) selecionado(s)"
            flingActiveStatus.TextColor3 = TEXTDIM
        end
    end
end

function createFlingCard(plr, order)
    if plr == LocalPlayer then return end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -8, 0, 46)
    card.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.ZIndex = 130
    card.Parent = flingList
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = PURPLE_BORDER
    cardStroke.Thickness = 1
    cardStroke.Transparency = 0.7

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 32, 0, 32)
    avatar.Position = UDim2.new(0, 8, 0.5, -16)
    avatar.BackgroundColor3 = CARD
    avatar.BorderSizePixel = 0
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=100&h=100"
    avatar.ZIndex = 140
    avatar.Parent = card
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
    local avStroke = Instance.new("UIStroke", avatar)
    avStroke.Color = PURPLE_BORDER
    avStroke.Thickness = 1.5
    avStroke.Transparency = 0.3

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -100, 0, 15)
    nameLbl.Position = UDim2.new(0, 48, 0, 6)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = plr.DisplayName or plr.Name
    nameLbl.TextColor3 = TEXT
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 140
    nameLbl.Parent = card

    local userLbl = Instance.new("TextLabel")
    userLbl.Size = UDim2.new(1, -100, 0, 12)
    userLbl.Position = UDim2.new(0, 48, 0, 22)
    userLbl.BackgroundTransparency = 1
    userLbl.Text = "@" .. plr.Name
    userLbl.TextColor3 = TEXTDIM
    userLbl.Font = Enum.Font.Gotham
    userLbl.TextSize = 9
    userLbl.TextXAlignment = Enum.TextXAlignment.Left
    userLbl.ZIndex = 140
    userLbl.Parent = card

    local checkBtn = Instance.new("TextButton")
    checkBtn.Size = UDim2.new(0, 80, 0, 28)
    checkBtn.Position = UDim2.new(1, -88, 0.5, -14)
    checkBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    checkBtn.Text = "Selecionar"
    checkBtn.TextColor3 = TEXTDIM
    checkBtn.Font = Enum.Font.GothamBold
    checkBtn.TextSize = 10
    checkBtn.AutoButtonColor = false
    checkBtn.ZIndex = 140
    checkBtn.Parent = card
    Instance.new("UICorner", checkBtn).CornerRadius = UDim.new(0, 7)
    local btnStroke = Instance.new("UIStroke", checkBtn)
    btnStroke.Color = PURPLE_BORDER
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.5

    checkBtn.MouseButton1Click:Connect(function()
        if flingSelectedTargets[plr.UserId] then
            flingSelectedTargets[plr.UserId] = nil
            checkBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
            checkBtn.TextColor3 = TEXTDIM
            checkBtn.Text = "Selecionar"
            card.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
            cardStroke.Color = PURPLE_BORDER
        else
            flingSelectedTargets[plr.UserId] = plr
            checkBtn.BackgroundColor3 = DANGER
            checkBtn.TextColor3 = Color3.new(1, 1, 1)
            checkBtn.Text = "✓ Selecionado"
            card.BackgroundColor3 = Color3.fromRGB(45, 20, 25)
            cardStroke.Color = DANGER
        end
        updateFlingStatus()
    end)

    flingCards[plr.UserId] = {
        frame = card,
        checkBtn = checkBtn,
        cardStroke = cardStroke,
        name = string.lower(plr.DisplayName or plr.Name),
        username = string.lower(plr.Name)
    }
end

function refreshFlingList()
    for _, data in pairs(flingCards) do
        if data.frame then data.frame:Destroy() end
    end
    flingCards = {}
    flingSelectedTargets = {}
    local order = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            order += 1
            createFlingCard(plr, order)
        end
    end
    updateFlingStatus()
end

flingSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(flingSearchBox.Text or "")
    for _, data in pairs(flingCards) do
        if data.frame and data.frame.Parent then
            local match = q == ""
                or string.find(data.name, q, 1, true)
                or string.find(data.username, q, 1, true)
            data.frame.Visible = match
        end
    end
end)

flingActiveStatus = Instance.new("TextLabel")
flingActiveStatus.Size = UDim2.new(1, -24, 0, 20)
flingActiveStatus.Position = UDim2.new(0, 12, 1, -125)
flingActiveStatus.BackgroundTransparency = 1
flingActiveStatus.Text = "⚪  0 jogador(es) selecionado(s)"
flingActiveStatus.TextColor3 = TEXTDIM
flingActiveStatus.Font = Enum.Font.GothamBold
flingActiveStatus.TextSize = 11
flingActiveStatus.TextXAlignment = Enum.TextXAlignment.Left
flingActiveStatus.ZIndex = 130
flingActiveStatus.Parent = flingPage

flingStartBtn = Instance.new("TextButton")
flingStartBtn.Size = UDim2.new(1, -24, 0, 34)
flingStartBtn.Position = UDim2.new(0, 12, 1, -97)
flingStartBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
flingStartBtn.Text = "▶  INICIAR FLING"
flingStartBtn.TextColor3 = Color3.new(1, 1, 1)
flingStartBtn.Font = Enum.Font.GothamBold
flingStartBtn.TextSize = 12
flingStartBtn.AutoButtonColor = false
flingStartBtn.ZIndex = 130
flingStartBtn.Parent = flingPage
Instance.new("UICorner", flingStartBtn).CornerRadius = UDim.new(0, 8)
local startStroke = Instance.new("UIStroke", flingStartBtn)
startStroke.Color = Color3.fromRGB(0, 255, 100)
startStroke.Thickness = 1.5
startStroke.Transparency = 0.5

flingStartBtn.MouseEnter:Connect(function()
    TweenService:Create(flingStartBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 220, 0)}):Play()
end)
flingStartBtn.MouseLeave:Connect(function()
    TweenService:Create(flingStartBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 170, 0)}):Play()
end)

flingStartBtn.MouseButton1Click:Connect(function()
    if flingActive then return end
    local count = 0
    for _ in pairs(flingSelectedTargets) do count = count + 1 end
    if count == 0 then
        addNotif("Fling", "Nenhum jogador selecionado.", 3)
        return
    end

    Config.AntiFling.Enabled = false
    setAntiFling(false)
    if antiFlingToggle then
        antiFlingToggle:SetAttribute("ToggleState", false)
        antiFlingToggle.BackgroundColor3 = CARD
        antiFlingToggle.Text = "OFF"
    end

    flingActive = true
    updateFlingStatus()
    addNotif("Fling", "Iniciado em " .. count .. " jogador(es).", 3)

    task.spawn(function()
        while flingActive do
            for userId, plr in pairs(flingSelectedTargets) do
                if plr and plr.Parent then
                    pcall(function() SkidFling(plr) end)

                    flingSelectedTargets[userId] = nil
                    local data = flingCards[userId]
                    if data and data.checkBtn then
                        data.checkBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
                        data.checkBtn.TextColor3 = TEXTDIM
                        data.checkBtn.Text = "Selecionar"
                        if data.frame then
                            data.frame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
                        end
                        if data.cardStroke then
                            data.cardStroke.Color = PURPLE_BORDER
                        end
                    end
                    updateFlingStatus()

                    task.wait(0.05)
                end
            end

            local restantes = 0
            for _ in pairs(flingSelectedTargets) do restantes = restantes + 1 end
            if restantes == 0 then
                flingActive = false
                Config.AntiFling.Enabled = true
                setAntiFling(true)
                if antiFlingToggle then
                    antiFlingToggle:SetAttribute("ToggleState", true)
                    antiFlingToggle.BackgroundColor3 = TOGGLE_ON_COLOR
                    antiFlingToggle.Text = "ON"
                end
                updateFlingStatus()
                addNotif("Fling", "Todos flingados. Anti-Fling reativado.", 3)
                break
            end

            task.wait(0.3)
        end
    end)
end)

flingStopBtn = Instance.new("TextButton")
flingStopBtn.Size = UDim2.new(1, -24, 0, 34)
flingStopBtn.Position = UDim2.new(0, 12, 1, -58)
flingStopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
flingStopBtn.Text = "■  PARAR FLING"
flingStopBtn.TextColor3 = Color3.new(1, 1, 1)
flingStopBtn.Font = Enum.Font.GothamBold
flingStopBtn.TextSize = 12
flingStopBtn.AutoButtonColor = false
flingStopBtn.ZIndex = 130
flingStopBtn.Parent = flingPage
Instance.new("UICorner", flingStopBtn).CornerRadius = UDim.new(0, 8)
local stopStroke = Instance.new("UIStroke", flingStopBtn)
stopStroke.Color = Color3.fromRGB(255, 80, 80)
stopStroke.Thickness = 1.5
stopStroke.Transparency = 0.5

flingStopBtn.MouseEnter:Connect(function()
    TweenService:Create(flingStopBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 0, 0)}):Play()
end)
flingStopBtn.MouseLeave:Connect(function()
    TweenService:Create(flingStopBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(170, 0, 0)}):Play()
end)

flingStopBtn.MouseButton1Click:Connect(function()
    if not flingActive then return end
    flingActive = false

    Config.AntiFling.Enabled = true
    setAntiFling(true)
    if antiFlingToggle then
        antiFlingToggle:SetAttribute("ToggleState", true)
        antiFlingToggle.BackgroundColor3 = TOGGLE_ON_COLOR
        antiFlingToggle.Text = "ON"
    end

    updateFlingStatus()
    addNotif("Fling", "Parado. Anti-Fling reativado.", 3)
end)

refreshFlingList()

Players.PlayerAdded:Connect(function()
    task.wait(1)
    refreshFlingList()
end)

Players.PlayerRemoving:Connect(function(plr)
    local data = flingCards[plr.UserId]
    if data and data.frame then data.frame:Destroy() end
    flingCards[plr.UserId] = nil
    flingSelectedTargets[plr.UserId] = nil
    updateFlingStatus()
end)

-- ═══════════ PÁGINA TELEPORTE ═══════════
tpPage = createPage("Teleporte")
addPageTitle(tpPage, "Teleporte", "Salvar / Ir / Resetar / Remover")

savedList = Instance.new("ScrollingFrame")
savedList.Size = UDim2.new(1, -24, 1, -170)
savedList.Position = UDim2.new(0, 12, 0, 50)
savedList.BackgroundTransparency = 1
savedList.BorderSizePixel = 0
savedList.ScrollBarThickness = 3
savedList.ScrollBarImageColor3 = ACCENT
savedList.CanvasSize = UDim2.new(0, 0, 0, 0)
savedList.AutomaticCanvasSize = Enum.AutomaticSize.Y
savedList.ZIndex = 120
savedList.Parent = tpPage

savedLayout = Instance.new("UIListLayout", savedList)
savedLayout.SortOrder = Enum.SortOrder.LayoutOrder
savedLayout.Padding = UDim.new(0, 4)

savedSlots = {}

function refreshSavedSlots()
    for _, obj in ipairs(savedList:GetChildren()) do
        if obj:IsA("Frame") then obj:Destroy() end
    end
    local order = 0
    for i, cf in pairs(savedSlots) do
        order += 1
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -4, 0, 32)
        card.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        card.BackgroundTransparency = 0.3
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        card.ZIndex = 130
        card.Parent = savedList
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -130, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "Slot " .. i
        lbl.TextColor3 = TEXT
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 140
        lbl.Parent = card

        local goBtn = Instance.new("TextButton")
        goBtn.Size = UDim2.new(0, 44, 0, 22)
        goBtn.Position = UDim2.new(1, -100, 0.5, -11)
        goBtn.BackgroundColor3 = ACCENT
        goBtn.Text = "Ir"
        goBtn.TextColor3 = Color3.new(1, 1, 1)
        goBtn.Font = Enum.Font.GothamBold
        goBtn.TextSize = 9
        goBtn.AutoButtonColor = false
        goBtn.ZIndex = 140
        goBtn.Parent = card
        Instance.new("UICorner", goBtn).CornerRadius = UDim.new(0, 6)
        goBtn.MouseButton1Click:Connect(function()
            if gotoPosition(i) then
                addNotif("Teleporte", "Foi para o slot " .. i)
            end
        end)

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 44, 0, 22)
        delBtn.Position = UDim2.new(1, -52, 0.5, -11)
        delBtn.BackgroundColor3 = DANGER
        delBtn.Text = "X"
        delBtn.TextColor3 = Color3.new(1, 1, 1)
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 9
        delBtn.AutoButtonColor = false
        delBtn.ZIndex = 140
        delBtn.Parent = card
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 6)
        delBtn.MouseButton1Click:Connect(function()
            savedSlots[i] = nil
            savedPositions[i] = nil
            refreshSavedSlots()
            addNotif("Teleporte", "Slot " .. i .. " removido.")
        end)
    end
end

saveBtn = makeButton(tpPage, "Salvar Posição", 0, 155, 26, Color3.fromRGB(35, 35, 42), function()
    local nextSlot = 1
    while savedSlots[nextSlot] do nextSlot += 1 end
    if savePosition(nextSlot) then
        savedSlots[nextSlot] = true
        refreshSavedSlots()
        addNotif("Teleporte", "Posição salva no slot " .. nextSlot)
    end
end)
saveBtn.Position = UDim2.new(0, 12, 1, -108)

resetBtn = makeButton(tpPage, "Resetar Todos", 0, 155, 26, Color3.fromRGB(35, 35, 42), function()
    savedSlots = {}
    savedPositions = {}
    refreshSavedSlots()
    addNotif("Teleporte", "Todos os slots foram resetados.")
end)
resetBtn.Position = UDim2.new(0, 12, 1, -76)

removeHint = makeButton(tpPage, "Remover Slot (X)", 0, 155, 26, Color3.fromRGB(60, 25, 30), function()
    addNotif("Remover Slot", "Clique no X vermelho ao lado do slot.")
end)
removeHint.Position = UDim2.new(0, 12, 1, -44)

-- ═══════════ PÁGINA VISUAL ═══════════
visualPage = createPage("Visual")
addPageTitle(visualPage, "Visual", "ESP, Fullbright, Paletas")

espCard = makeCard(visualPage, 56, 32)
makeLabel(espCard, "ESP", 10, 200)
makeToggle(espCard, Config.ESP.Enabled, function(s) Config.ESP.Enabled = s end)

espNameCard = makeCard(visualPage, 94, 32)
makeLabel(espNameCard, "ESP • Mostrar Nome", 10, 200)
makeToggle(espNameCard, Config.ESP.ShowName, function(s) Config.ESP.ShowName = s end)

espDistCard = makeCard(visualPage, 132, 32)
makeLabel(espDistCard, "ESP • Mostrar Distância", 10, 200)
makeToggle(espDistCard, Config.ESP.ShowDistance, function(s) Config.ESP.ShowDistance = s end)

espHealthCard = makeCard(visualPage, 170, 32)
makeLabel(espHealthCard, "ESP • Mostrar Vida", 10, 200)
makeToggle(espHealthCard, Config.ESP.ShowHealth, function(s) Config.ESP.ShowHealth = s end)

espHLCard = makeCard(visualPage, 208, 32)
makeLabel(espHLCard, "ESP • Boneco Palito", 10, 240)
makeToggle(espHLCard, Config.ESP.ShowHighlight, function(s) Config.ESP.ShowHighlight = s end)

espTMCard = makeCard(visualPage, 246, 32)
makeLabel(espTMCard, "ESP • TeamCheck", 10, 200)
makeToggle(espTMCard, Config.ESP.TeamCheck, function(s) Config.ESP.TeamCheck = s end)

espLinesCard = makeCard(visualPage, 284, 32)
makeLabel(espLinesCard, "ESP • Linhas (tracer)", 10, 200)
makeToggle(espLinesCard, Config.ESP.ShowLines, function(s) Config.ESP.ShowLines = s end)

fbCard = makeCard(visualPage, 322, 32)
makeLabel(fbCard, "Fullbright", 10, 200)
makeToggle(fbCard, Config.Fullbright.Enabled, function(s)
    Config.Fullbright.Enabled = s
    setFullbright(s)
end)

makeColorPalette(visualPage, 372, "🎨 Cor do ESP (Box/Linha)", Config.ESP.Color, function(cor)
    Config.ESP.Color = cor
end)

makeColorPalette(visualPage, 480, "🎯 Cor do FOV", Config.Aimbot.FOVColor, function(cor)
    Config.Aimbot.FOVColor = cor
end)

-- ═══════════ PÁGINA HITBOX (até 500) ═══════════
hitboxPage = createPage("Hitbox")
addPageTitle(hitboxPage, "Hitbox", "Quadrado invisível no HRP")

hbCard = makeCard(hitboxPage, 56, 32)
makeLabel(hbCard, "Hitbox Expander", 10, 200)
makeToggle(hbCard, Config.Hitbox.Enabled, function(s)
    Config.Hitbox.Enabled = s
    setHitbox(s)
end)

hbSizeCard = makeCard(hitboxPage, 94, 32)
makeLabel(hbSizeCard, "Tamanho (1 - 500)", 10, 150)
hbSizeInput = makeInput(hbSizeCard, 6, tostring(Config.Hitbox.Size), 60, function(txt)
    local n = tonumber(txt)
    if n then Config.Hitbox.Size = math.clamp(n, 1, 500) end
end)
hbSizeInput.Position = UDim2.new(1, -80, 0.5, -12)

-- ═══════════ PÁGINA MIRA ═══════════
miraPage = createPage("Mira")
addPageTitle(miraPage, "Mira", "Aimbot, FOV, WallCheck")

aimCard = makeCard(miraPage, 56, 32)
makeLabel(aimCard, "Aimbot", 10, 200)
makeToggle(aimCard, Config.Aimbot.Enabled, function(s)
    Config.Aimbot.Enabled = s
    if s then startAimbot() end
end)

aimShotCard = makeCard(miraPage, 94, 32)
makeLabel(aimShotCard, "Aimbot • Auto Shot", 10, 200)
makeToggle(aimShotCard, Config.Aimbot.AutoShot, function(s) Config.Aimbot.AutoShot = s end)

aimReloadCard = makeCard(miraPage, 132, 32)
makeLabel(aimReloadCard, "Aimbot • Auto Reload", 10, 200)
makeToggle(aimReloadCard, Config.Aimbot.AutoReload, function(s) Config.Aimbot.AutoReload = s end)

aimTMCard = makeCard(miraPage, 170, 32)
makeLabel(aimTMCard, "Aimbot • TeamCheck", 10, 200)
makeToggle(aimTMCard, Config.Aimbot.TeamCheck, function(s) Config.Aimbot.TeamCheck = s end)

aimWCCard = makeCard(miraPage, 208, 32)
makeLabel(aimWCCard, "Aimbot • WallCheck", 10, 240)
makeToggle(aimWCCard, Config.Aimbot.WallCheck, function(s) Config.Aimbot.WallCheck = s end)

aimTargetCard = makeCard(miraPage, 246, 32)
aimTargetCard.ClipsDescendants = false
makeLabel(aimTargetCard, "Alvo", 10, 150)

targetBtn = Instance.new("TextButton")
targetBtn.Size = UDim2.new(0, 100, 0, 24)
targetBtn.Position = UDim2.new(1, -110, 0.5, -12)
targetBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
targetBtn.Text = "🎯  " .. Config.Aimbot.Target .. "  ▼"
targetBtn.TextColor3 = Color3.new(1, 1, 1)
targetBtn.Font = Enum.Font.GothamBold
targetBtn.TextSize = 11
targetBtn.AutoButtonColor = false
targetBtn.ZIndex = 200
targetBtn.Parent = aimTargetCard
Instance.new("UICorner", targetBtn).CornerRadius = UDim.new(0, 6)

targetDropdown = Instance.new("Frame")
targetDropdown.Size = UDim2.new(0, 100, 0, 60)
targetDropdown.Position = UDim2.new(0, 0, 0, 0)
targetDropdown.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
targetDropdown.BorderSizePixel = 0
targetDropdown.Visible = false
targetDropdown.ZIndex = 9999
targetDropdown.Parent = gui
Instance.new("UICorner", targetDropdown).CornerRadius = UDim.new(0, 6)

local dropStroke = Instance.new("UIStroke", targetDropdown)
dropStroke.Color = PURPLE_BORDER
dropStroke.Thickness = 1
dropStroke.Transparency = 0.3

targetOptHead = Instance.new("TextButton")
targetOptHead.Size = UDim2.new(1, 0, 0, 30)
targetOptHead.Position = UDim2.new(0, 0, 0, 0)
targetOptHead.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
targetOptHead.Text = "🎯  Head"
targetOptHead.TextColor3 = TEXT
targetOptHead.Font = Enum.Font.GothamMedium
targetOptHead.TextSize = 11
targetOptHead.AutoButtonColor = false
targetOptHead.ZIndex = 9999
targetOptHead.Parent = targetDropdown
Instance.new("UICorner", targetOptHead).CornerRadius = UDim.new(0, 6)

targetOptTorso = Instance.new("TextButton")
targetOptTorso.Size = UDim2.new(1, 0, 0, 30)
targetOptTorso.Position = UDim2.new(0, 0, 0, 30)
targetOptTorso.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
targetOptTorso.Text = "🎯  Torso"
targetOptTorso.TextColor3 = TEXT
targetOptTorso.Font = Enum.Font.GothamMedium
targetOptTorso.TextSize = 11
targetOptTorso.AutoButtonColor = false
targetOptTorso.ZIndex = 9999
targetOptTorso.Parent = targetDropdown
Instance.new("UICorner", targetOptTorso).CornerRadius = UDim.new(0, 6)

function atualizarDropdown()
    targetBtn.Text = "🎯  " .. Config.Aimbot.Target .. "  ▼"
    if Config.Aimbot.Target == "Head" then
        targetOptHead.BackgroundColor3 = ACCENT
        targetOptTorso.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    else
        targetOptHead.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
        targetOptTorso.BackgroundColor3 = Color3.fromRGB(30, 130, 200)
    end
end

atualizarDropdown()

dropdownAbertoEm = 0

targetBtn.MouseButton1Click:Connect(function()
    targetDropdown.Visible = not targetDropdown.Visible
    if targetDropdown.Visible then
        dropdownAbertoEm = tick()
        local btnPos = targetBtn.AbsolutePosition
        local btnSize = targetBtn.AbsoluteSize
        targetDropdown.Position = UDim2.new(0, btnPos.X, 0, btnPos.Y + btnSize.Y + 4)
        targetDropdown.Size = UDim2.new(0, btnSize.X, 0, 60)
    end
end)

targetOptHead.MouseButton1Click:Connect(function()
    Config.Aimbot.Target = "Head"
    atualizarDropdown()
    targetDropdown.Visible = false
    pcall(function() saveConfig() end)
end)

targetOptTorso.MouseButton1Click:Connect(function()
    Config.Aimbot.Target = "Torso"
    atualizarDropdown()
    targetDropdown.Visible = false
    pcall(function() saveConfig() end)
end)

UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        if targetDropdown.Visible and tick() - dropdownAbertoEm > 0.3 then
            local pos = input.Position
            local dp = targetDropdown.AbsolutePosition
            local ds = targetDropdown.AbsoluteSize
            local bp = targetBtn.AbsolutePosition
            local bs = targetBtn.AbsoluteSize
            
            local dentroDrop = pos.X >= dp.X and pos.X <= dp.X + ds.X 
                          and pos.Y >= dp.Y and pos.Y <= dp.Y + ds.Y
            local dentroBtn = pos.X >= bp.X and pos.X <= bp.X + bs.X 
                          and pos.Y >= bp.Y and pos.Y <= bp.Y + bs.Y
            
            if not dentroDrop and not dentroBtn then
                targetDropdown.Visible = false
            end
        end
    end
end)

aimSmoothCard = makeCard(miraPage, 284, 32)
makeLabel(aimSmoothCard, "Suavidade (0.05 - 1)", 10, 150)
smoothInput = makeInput(aimSmoothCard, 6, tostring(Config.Aimbot.Smoothness), 60, function(txt)
    local n = tonumber(txt)
    if n then Config.Aimbot.Smoothness = math.clamp(n, 0.05, 1) end
end)
smoothInput.Position = UDim2.new(1, -80, 0.5, -12)

fovCard = makeCard(miraPage, 322, 32)
makeLabel(fovCard, "FOV Circle", 10, 200)
makeToggle(fovCard, Config.Aimbot.FOVEnabled, function(s) Config.Aimbot.FOVEnabled = s end)

fovSizeCard = makeCard(miraPage, 360, 32)
makeLabel(fovSizeCard, "Tamanho FOV", 10, 150)
fovSizeInput = makeInput(fovSizeCard, 6, tostring(Config.Aimbot.FOVSize), 50, function(txt)
    local n = tonumber(txt)
    if n then Config.Aimbot.FOVSize = math.clamp(n, 20, 500) end
end)
fovSizeInput.Position = UDim2.new(1, -70, 0.5, -12)

fovChangeCard = makeCard(miraPage, 398, 32)
makeLabel(fovChangeCard, "FOV Changer", 10, 200)
makeToggle(fovChangeCard, Config.FOVChanger.Enabled, function(s)
    Config.FOVChanger.Enabled = s
    setFOVChanger(s)
end)

-- ═══════════ PÁGINA ANTI ═══════════
antiPage = createPage("Anti")
addPageTitle(antiPage, "Anti", "Anti-Fling, Anti-AFK, Anti-Void")

antiFlingToggle = nil

afCard = makeCard(antiPage, 56, 32)
makeLabel(afCard, "Anti-Fling", 10, 200)
antiFlingToggle = makeToggle(afCard, Config.AntiFling.Enabled, function(s)
    Config.AntiFling.Enabled = s
    setAntiFling(s)
end)

afkCard = makeCard(antiPage, 94, 32)
makeLabel(afkCard, "Anti-AFK", 10, 200)
makeToggle(afkCard, Config.AntiAFK.Enabled, function(s)
    Config.AntiAFK.Enabled = s
    setAntiAFK(s)
end)

antiVoidCard = makeCard(antiPage, 132, 32)
makeLabel(antiVoidCard, "Anti-Void (não cai no void)", 10, 240)
makeToggle(antiVoidCard, Config.AntiVoid.Enabled, function(s)
    Config.AntiVoid.Enabled = s
    setAntiVoid(s)
end)

-- ═══════════ PÁGINA SERVIDOR ═══════════
serverPage = createPage("Servidor")
addPageTitle(serverPage, "Servidor", "Server Hop, Rejoin")

rejoinCard = makeCard(serverPage, 56, 40)
makeLabel(rejoinCard, "Rejoin (entrar de novo)", 10, 200)
rejoinBtn = makeButton(rejoinCard, "Rejoin", 7, 80, 26, TOGGLE_ON_COLOR, function()
    addNotif("Servidor", "Rejoinando... Script vai reabrir!")
    rejoin()
end)
rejoinBtn.Position = UDim2.new(1, -90, 0.5, -13)

hopCard = makeCard(serverPage, 102, 40)
makeLabel(hopCard, "Server Hop", 10, 200)
hopBtn = makeButton(hopCard, "Hop", 7, 80, 26, TOGGLE_ON_COLOR, function()
    addNotif("Servidor", "Procurando servidor... Script vai reabrir!")
    serverHop()
end)
hopBtn.Position = UDim2.new(1, -90, 0.5, -13)

-- ═══════════ PÁGINA SOBRE ═══════════
aboutPage = createPage("Sobre")
addPageTitle(aboutPage, "Sobre", "Informações do script")

aboutCard = Instance.new("Frame")
aboutCard.Size = UDim2.new(1, -24, 0, 100)
aboutCard.Position = UDim2.new(0, 12, 0, 56)
aboutCard.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
aboutCard.BackgroundTransparency = 0.15
aboutCard.BorderSizePixel = 0
aboutCard.ZIndex = 120
aboutCard.Parent = aboutPage
Instance.new("UICorner", aboutCard).CornerRadius = UDim.new(0, 14)

local aGrad = Instance.new("UIGradient", aboutCard)
aGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 20, 35)),
})
aGrad.Rotation = 45

local aStroke = Instance.new("UIStroke", aboutCard)
aStroke.Color = PURPLE_BORDER
aStroke.Thickness = 1
aStroke.Transparency = 0.4

local aLogo = Instance.new("ImageLabel")
aLogo.Size = UDim2.new(0, 60, 0, 60)
aLogo.Position = UDim2.new(0, 14, 0, 20)
aLogo.BackgroundTransparency = 1
aLogo.Image = ICONS.Star
aLogo.ImageColor3 = PURPLE_BORDER
aLogo.ZIndex = 130
aLogo.Parent = aboutCard

local aTitle = Instance.new("TextLabel")
aTitle.Size = UDim2.new(1, -90, 0, 22)
aTitle.Position = UDim2.new(0, 86, 0, 22)
aTitle.BackgroundTransparency = 1
aTitle.Text = "Slow Hub - Universal"
aTitle.TextColor3 = Color3.new(1, 1, 1)
aTitle.Font = Enum.Font.GothamBlack
aTitle.TextSize = 18
aTitle.TextXAlignment = Enum.TextXAlignment.Left
aTitle.ZIndex = 130
aTitle.Parent = aboutCard

local aTitleGrad = Instance.new("UIGradient", aTitle)
aTitleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 100, 220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 230, 255)),
})
aTitleGrad.Rotation = 0

local aVersion = Instance.new("TextLabel")
aVersion.Size = UDim2.new(1, -90, 0, 14)
aVersion.Position = UDim2.new(0, 86, 0, 44)
aVersion.BackgroundTransparency = 1
aVersion.Text = "by Slow develop  •  Discord: tav.x"
aVersion.TextColor3 = TEXTDIM
aVersion.Font = Enum.Font.Gotham
aVersion.TextSize = 10
aVersion.TextXAlignment = Enum.TextXAlignment.Left
aVersion.ZIndex = 130
aVersion.Parent = aboutCard

local aDesc = Instance.new("TextLabel")
aDesc.Size = UDim2.new(1, -20, 0, 24)
aDesc.Position = UDim2.new(0, 10, 0, 72)
aDesc.BackgroundTransparency = 1
aDesc.Text = "Script mobile com aimbot, ESP, fly, fling e muito mais."
aDesc.TextColor3 = TEXTDIM
aDesc.Font = Enum.Font.Gotham
aDesc.TextSize = 9
aDesc.TextXAlignment = Enum.TextXAlignment.Left
aDesc.ZIndex = 130
aDesc.Parent = aboutCard

infoAboutCard = Instance.new("Frame")
infoAboutCard.Size = UDim2.new(1, -24, 0, 80)
infoAboutCard.Position = UDim2.new(0, 12, 0, 164)
infoAboutCard.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
infoAboutCard.BackgroundTransparency = 0.2
infoAboutCard.BorderSizePixel = 0
infoAboutCard.ZIndex = 120
infoAboutCard.Parent = aboutPage
Instance.new("UICorner", infoAboutCard).CornerRadius = UDim.new(0, 10)
local iStroke = Instance.new("UIStroke", infoAboutCard)
iStroke.Color = PURPLE_BORDER
iStroke.Thickness = 1
iStroke.Transparency = 0.6

local function makeInfoRow(parent, y, label, valor)
    local row = Instance.new("TextLabel")
    row.Size = UDim2.new(0, 100, 0, 16)
    row.Position = UDim2.new(0, 10, 0, y)
    row.BackgroundTransparency = 1
    row.Text = label
    row.TextColor3 = TEXTDIM
    row.Font = Enum.Font.Gotham
    row.TextSize = 10
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.ZIndex = 130
    row.Parent = parent

    local rowVal = Instance.new("TextLabel")
    rowVal.Size = UDim2.new(1, -120, 0, 16)
    rowVal.Position = UDim2.new(0, 110, 0, y)
    rowVal.BackgroundTransparency = 1
    rowVal.Text = valor
    rowVal.TextColor3 = TEXT
    rowVal.Font = Enum.Font.GothamBold
    rowVal.TextSize = 10
    rowVal.TextXAlignment = Enum.TextXAlignment.Right
    rowVal.ZIndex = 130
    rowVal.Parent = parent
end

makeInfoRow(infoAboutCard, 8, "Criador", "Spzinx")
makeInfoRow(infoAboutCard, 26, "Discord", "tav.x")
makeInfoRow(infoAboutCard, 44, "Key", "SlowHubVIP")
makeInfoRow(infoAboutCard, 62, "GitHub", "slow-develp/slowhub")

configCard = Instance.new("Frame")
configCard.Size = UDim2.new(1, -24, 0, 90)
configCard.Position = UDim2.new(0, 12, 0, 252)
configCard.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
configCard.BackgroundTransparency = 0.2
configCard.BorderSizePixel = 0
configCard.ZIndex = 120
configCard.Parent = aboutPage
Instance.new("UICorner", configCard).CornerRadius = UDim.new(0, 10)
local cStroke = Instance.new("UIStroke", configCard)
cStroke.Color = PURPLE_BORDER
cStroke.Thickness = 1
cStroke.Transparency = 0.6

local cTitle = Instance.new("TextLabel")
cTitle.Size = UDim2.new(1, -20, 0, 14)
cTitle.Position = UDim2.new(0, 10, 0, 8)
cTitle.BackgroundTransparency = 1
cTitle.Text = "Configurações"
cTitle.TextColor3 = TEXT
cTitle.Font = Enum.Font.GothamBold
cTitle.TextSize = 11
cTitle.TextXAlignment = Enum.TextXAlignment.Left
cTitle.ZIndex = 130
cTitle.Parent = configCard

saveConfigBtn = makeIconButton(configCard, 11768914234, "Salvar Configurações", 30, 200, 24, Color3.fromRGB(0, 150, 80), function()
    local g = parentGui:FindFirstChild("SlowHub")
    if g then
        for _, obj in ipairs(g:GetDescendants()) do
            if obj:IsA("TextBox") and obj:IsFocused() then
                obj:ReleaseFocus()
                task.wait(0.05)
            end
        end
    end
    task.wait(0.1)
    if saveConfig() then
        addNotif("Config", "Configurações salvas com sucesso!", 3)
    else
        addNotif("Config", "Erro ao salvar (executor sem writefile)", 3)
    end
end)

resetConfigBtn = makeIconButton(configCard, 84090157888894, "Resetar Configurações", 58, 200, 24, Color3.fromRGB(180, 40, 40), function()
    resetConfig()
    addNotif("Config", "Configurações resetadas! Reabra o script.", 4)
end)

-- BOTÕES LATERAIS
createTabButton("Home", ICONS.Home)
createTabButton("Jogadores", ICONS.Person)
createTabButton("Movimento", ICONS.Lightning)
createTabButton("Fling", ICONS.Fling)
createTabButton("Teleporte", ICONS.Door)
createTabButton("Visual", ICONS.Eye)
createTabButton("Hitbox", ICONS.Box)
createTabButton("Mira", ICONS.Aimbot)
createTabButton("Anti", ICONS.Info)
createTabButton("Servidor", ICONS.Star)
createTabButton("Sobre", ICONS.Config)

setPage("Home")

-- BOTÕES DO HEADER
minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    mainBorder.Visible = false
    capsule.Visible = true
    capsuleBorder.Visible = true
end)

isMaximized = false
maxBtn.MouseButton1Click:Connect(function()
    isMaximized = not isMaximized
    if isMaximized then
        main.Size = MAXIMIZED_SIZE
        main.Position = UDim2.new(0.5, -maxW/2, 0.5, -maxH/2)
    else
        main.Size = NORMAL_SIZE
        main.Position = UDim2.new(0.5, -250, 0.5, -170)
    end
end)

capsuleText.MouseButton1Click:Connect(function()
    if capsule.Visible then
        capsule.Visible = false
        capsuleBorder.Visible = false
        main.Visible = true
        mainBorder.Visible = true
    end
end)

-- DRAG DA CÁPSULA
capsuleDragging = false
capsuleDragStart = nil
capsuleStartPos = nil

dragZone.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        capsuleDragging = true
        capsuleDragStart = UIS:GetMouseLocation()
        capsuleStartPos = capsule.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if not capsuleDragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
    and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local pos = UIS:GetMouseLocation()
    local dx = pos.X - capsuleDragStart.X
    local dy = pos.Y - capsuleDragStart.Y
    capsule.Position = UDim2.new(
        capsuleStartPos.X.Scale, capsuleStartPos.X.Offset + dx,
        capsuleStartPos.Y.Scale, capsuleStartPos.Y.Offset + dy
    )
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        capsuleDragging = false
    end
end)

-- BORDA DA CÁPSULA segue posição/tamanho
RunService.RenderStepped:Connect(function(dt)
    if not capsuleBorder then return end
    capsuleBorder.Visible = capsule.Visible
    capsuleBorder.Size = UDim2.new(
        capsule.Size.X.Scale, capsule.Size.X.Offset + 4,
        capsule.Size.Y.Scale, capsule.Size.Y.Offset + 4
    )
    capsuleBorder.Position = UDim2.new(
        capsule.Position.X.Scale, capsule.Position.X.Offset - 2,
        capsule.Position.Y.Scale, capsule.Position.Y.Offset - 2
    )
end)

-- BORDA DO PAINEL segue posição/tamanho
RunService.RenderStepped:Connect(function(dt)
    if not mainBorder then return end
    mainBorder.Visible = main.Visible
    mainBorder.Size = UDim2.new(
        main.Size.X.Scale, main.Size.X.Offset + 4,
        main.Size.Y.Scale, main.Size.Y.Offset + 4
    )
    mainBorder.Position = UDim2.new(
        main.Position.X.Scale, main.Position.X.Offset - 2,
        main.Position.Y.Scale, main.Position.Y.Offset - 2
    )
end)

-- DRAG DO PAINEL
mainDragging = false
mainDragStart = nil
mainStartPos = nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        mainDragging = true
        mainDragStart = UIS:GetMouseLocation()
        mainStartPos = main.Position
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        mainDragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if mainDragging and mainDragStart then
        local delta = UIS:GetMouseLocation() - mainDragStart
        main.Position = UDim2.new(
            mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X,
            mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y
        )
    end
end)

-- MODAL DE FECHAR
closeModal = Instance.new("Frame")
closeModal.Name = "CloseModal"
closeModal.Size = UDim2.new(1, 0, 1, 0)
closeModal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
closeModal.BackgroundTransparency = 0.5
closeModal.BorderSizePixel = 0
closeModal.Visible = false
closeModal.ZIndex = 300
closeModal.Parent = gui

modalBox = Instance.new("Frame")
modalBox.Size = UDim2.new(0, 320, 0, 160)
modalBox.Position = UDim2.new(0.5, -160, 0.5, -80)
modalBox.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
modalBox.BorderSizePixel = 0
modalBox.ZIndex = 301
modalBox.Parent = closeModal
Instance.new("UICorner", modalBox).CornerRadius = UDim.new(0, 16)

modalStroke = Instance.new("UIStroke", modalBox)
modalStroke.Color = PURPLE_BORDER
modalStroke.Thickness = 1.5
modalStroke.Transparency = 0.2

modalTitle = Instance.new("TextLabel")
modalTitle.Size = UDim2.new(1, -32, 0, 24)
modalTitle.Position = UDim2.new(0, 16, 0, 20)
modalTitle.BackgroundTransparency = 1
modalTitle.Text = "Are you sure?"
modalTitle.TextColor3 = TEXT
modalTitle.Font = Enum.Font.GothamBold
modalTitle.TextSize = 16
modalTitle.TextXAlignment = Enum.TextXAlignment.Left
modalTitle.ZIndex = 302
modalTitle.Parent = modalBox

modalDesc = Instance.new("TextLabel")
modalDesc.Size = UDim2.new(1, -32, 0, 40)
modalDesc.Position = UDim2.new(0, 16, 0, 48)
modalDesc.BackgroundTransparency = 1
modalDesc.Text = "This will close the script and disable all features."
modalDesc.TextColor3 = TEXTDIM
modalDesc.Font = Enum.Font.Gotham
modalDesc.TextSize = 12
modalDesc.TextXAlignment = Enum.TextXAlignment.Left
modalDesc.TextWrapped = true
modalDesc.ZIndex = 302
modalDesc.Parent = modalBox

cancelBtn = Instance.new("TextButton")
cancelBtn.Size = UDim2.new(0, 130, 0, 32)
cancelBtn.Position = UDim2.new(0, 16, 1, -48)
cancelBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
cancelBtn.Text = "Cancel"
cancelBtn.TextColor3 = TEXT
cancelBtn.Font = Enum.Font.GothamBold
cancelBtn.TextSize = 12
cancelBtn.AutoButtonColor = false
cancelBtn.ZIndex = 302
cancelBtn.Parent = modalBox
Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 8)

confirmCloseBtn = Instance.new("TextButton")
confirmCloseBtn.Size = UDim2.new(0, 130, 0, 32)
confirmCloseBtn.Position = UDim2.new(1, -146, 1, -48)
confirmCloseBtn.BackgroundColor3 = ACCENT
confirmCloseBtn.Text = "Close Window"
confirmCloseBtn.TextColor3 = Color3.new(1, 1, 1)
confirmCloseBtn.Font = Enum.Font.GothamBold
confirmCloseBtn.TextSize = 12
confirmCloseBtn.AutoButtonColor = false
confirmCloseBtn.ZIndex = 302
confirmCloseBtn.Parent = modalBox
Instance.new("UICorner", confirmCloseBtn).CornerRadius = UDim.new(0, 8)

cancelBtn.MouseEnter:Connect(function()
    TweenService:Create(cancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
end)
cancelBtn.MouseLeave:Connect(function()
    TweenService:Create(cancelBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
end)
confirmCloseBtn.MouseEnter:Connect(function()
    TweenService:Create(confirmCloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(120, 200, 255)}):Play()
end)
confirmCloseBtn.MouseLeave:Connect(function()
    TweenService:Create(confirmCloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = ACCENT}):Play()
end)

function openCloseModal()
    closeModal.Visible = true
    closeModal.BackgroundTransparency = 1
    modalBox.Size = UDim2.new(0, 260, 0, 130)
    modalBox.Position = UDim2.new(0.5, -130, 0.5, -65)
    TweenService:Create(closeModal, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
    TweenService:Create(modalBox, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 320, 0, 160),
        Position = UDim2.new(0.5, -160, 0.5, -80)
    }):Play()
end

function closeCloseModal()
    TweenService:Create(closeModal, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    TweenService:Create(modalBox, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 260, 0, 130),
        Position = UDim2.new(0.5, -130, 0.5, -65)
    }):Play()
    task.wait(0.22)
    closeModal.Visible = false
end

cancelBtn.MouseButton1Click:Connect(closeCloseModal)

function resetEverything()
    for section, data in pairs(Config) do
        if type(data) == "table" and data.Enabled ~= nil then
            data.Enabled = false
        end
    end
    if espData then
        for _, d in pairs(espData) do
            if d.Box then d.Box.Visible = false end
            if d.Line then d.Line.Visible = false end
            if d.Name then d.Name.Visible = false end
            if d.Dist then d.Dist.Visible = false end
            if d.HpBg then d.HpBg.Visible = false end
            if d.Stick then
                if d.Stick.Body then d.Stick.Body.Visible = false end
                if d.Stick.ArmL then d.Stick.ArmL.Visible = false end
                if d.Stick.ArmR then d.Stick.ArmR.Visible = false end
                if d.Stick.LegL then d.Stick.LegL.Visible = false end
                if d.Stick.LegR then d.Stick.LegR.Visible = false end
            end
        end
    end
    if hitboxConn then pcall(function() hitboxConn:Disconnect() end) hitboxConn = nil end
    restaurarHitboxes()

    if noclipConn then pcall(function() noclipConn:Disconnect() end) noclipConn = nil end
    if speedConn then pcall(function() speedConn:Disconnect() end) speedConn = nil end
    if flingConn then pcall(function() flingConn:Disconnect() end) flingConn = nil end
    if flyConn then pcall(function() flyConn:Disconnect() end) flyConn = nil end
    if flyBodyVel and flyBodyVel.Parent then flyBodyVel:Destroy() end
    if flyBodyGyro and flyBodyGyro.Parent then flyBodyGyro:Destroy() end
    flyBodyVel, flyBodyGyro = nil, nil

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 16
        hum.PlatformStand = false
        hum.AutoRotate = true
    end

    if infJumpConn then pcall(function() infJumpConn:Disconnect() end) infJumpConn = nil end

    if originalLighting and originalLighting.Ambient then
        pcall(function()
            Lighting.Ambient = originalLighting.Ambient
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
            Lighting.Brightness = originalLighting.Brightness
            Lighting.ClockTime = originalLighting.ClockTime
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.GlobalShadows = originalLighting.GlobalShadows
        end)
    end
    pcall(function()
        if Camera then Camera.FieldOfView = 70 end
    end)
    if antiFlingConn then pcall(function() antiFlingConn:Disconnect() end) antiFlingConn = nil end
    if antiVoidConn then pcall(function() antiVoidConn:Disconnect() end) antiVoidConn = nil end
    if antiAfkConn then pcall(function() antiAfkConn:Disconnect() end) antiAfkConn = nil end
    if fovFrame then fovFrame.Visible = false end
    aimbotActive = false
end

confirmCloseBtn.MouseButton1Click:Connect(function()
    addNotif("Slow Hub", "Todas as funções foram desativadas.", 3)
    resetEverything()
    closeCloseModal()
    capsule.Visible = false
    capsuleBorder.Visible = false
    main.Visible = false
    mainBorder.Visible = false
    task.wait(0.8)
    pcall(function()
        if gui then gui:Destroy() end
        if keyGui then keyGui:Destroy() end
    end)
    pcall(function()
        if espFolder and espFolder.Parent then espFolder:Destroy() end
        if fovFrame and fovFrame.Parent then fovFrame:Destroy() end
        if mainBorder and mainBorder.Parent then mainBorder:Destroy() end
        if capsuleBorder and capsuleBorder.Parent then capsuleBorder:Destroy() end
    end)
    pcall(function()
        if noclipConn then noclipConn:Disconnect() end
        if speedConn then speedConn:Disconnect() end
        if flingConn then flingConn:Disconnect() end
        if flyConn then flyConn:Disconnect() end
        if infJumpConn then infJumpConn:Disconnect() end
        if antiFlingConn then antiFlingConn:Disconnect() end
        if antiVoidConn then antiVoidConn:Disconnect() end
        if antiAfkConn then antiAfkConn:Disconnect() end
    end)
end)

closeBtn.MouseButton1Click:Connect(function()
    openCloseModal()
end)

-- VALIDAÇÃO DA KEY
function tryValidateKey()
    local typed = keyInput.Text or ""
    if typed == KEY then
        keyStatus.TextColor3 = SUCCESS
        keyStatus.Text = "Key validada com sucesso!"
        task.wait(0.6)
        keyFrame.Visible = false
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
        keyStatus.Text = "Key inválida. Tente novamente."
    end
end

submitBtn.MouseButton1Click:Connect(tryValidateKey)
keyInput.FocusLost:Connect(function(enter)
    if enter then tryValidateKey() end
end)

-- DRAG DA KEY
keyDragging = false
keyDragStart = nil
keyStartPos = nil

keyFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        keyDragging = true
        keyDragStart = UIS:GetMouseLocation()
        keyStartPos = keyFrame.Position
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        keyDragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if keyDragging and keyDragStart then
        local delta = UIS:GetMouseLocation() - keyDragStart
        keyFrame.Position = UDim2.new(
            keyStartPos.X.Scale, keyStartPos.X.Offset + delta.X,
            keyStartPos.Y.Scale, keyStartPos.Y.Offset + delta.Y
        )
    end
end)

-- BOOT FINAL
gui.Enabled = false
keyGui.Enabled = true
keyFrame.Visible = true
capsule.Visible = false
capsuleBorder.Visible = false
main.Visible = false
mainBorder.Visible = false

-- AUMENTAR ÍCONES DAS ABAS (Fling e Mira)
task.spawn(function()
    task.wait(0.3)
    if buttons and buttons["Fling"] then
        local img = buttons["Fling"]:FindFirstChildOfClass("ImageLabel")
        if img then
            img.Size = UDim2.new(0, 22, 0, 22)
            img.Position = UDim2.new(0, 6, 0.5, -11)
        end
        local lbl = buttons["Fling"]:FindFirstChild("TabLabel")
        if lbl then
            lbl.Position = UDim2.new(0, 30, 0, 0)
        end
    end
    if buttons and buttons["Mira"] then
        local img = buttons["Mira"]:FindFirstChildOfClass("ImageLabel")
        if img then
            img.Size = UDim2.new(0, 22, 0, 22)
            img.Position = UDim2.new(0, 6, 0.5, -11)
        end
        local lbl = buttons["Mira"]:FindFirstChild("TabLabel")
        if lbl then
            lbl.Position = UDim2.new(0, 30, 0, 0)
        end
    end
end)

-- AUTO-START DAS FUNÇÕES SALVAS
task.spawn(function()
    task.wait(3)
    print("[SlowHub] Verificando funcoes salvas...")
    if Config.Aimbot.Enabled then
        print("[SlowHub] Aimbot salvo como ON, ativando...")
        startAimbot()
    end
    if Config.AntiFling.Enabled then pcall(setAntiFling, true) end
    if Config.AntiVoid.Enabled then pcall(setAntiVoid, true) end
    if Config.AntiAFK.Enabled then pcall(setAntiAFK, true) end
    if Config.Fullbright.Enabled then pcall(setFullbright, true) end
    if Config.FOVChanger.Enabled then pcall(setFOVChanger, true) end
    if Config.Noclip.Enabled then pcall(setNoclip, true) end
    if Config.Speed.Enabled then pcall(setSpeed, true) end
    if Config.Fly.Enabled then pcall(setFly, true) end
    if Config.InfiniteJump.Enabled then pcall(setInfJump, true) end
    if Config.Hitbox.Enabled then pcall(setHitbox, true) end
    print("[SlowHub] Funcoes salvas ativadas!")
end)
