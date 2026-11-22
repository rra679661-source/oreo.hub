local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    ESP = false, ESP_Box = false, ESP_Health = false, ESP_Distance = false,
    Fullbright = false, SpeedHack = false, SpeedValue = 16, InfJump = false,
    Noclip = false, Fly = false, FlySpeed = 50, AntiAFK = false,
    AntiFreeze = false, AntiTeleport = false, AntiFling = false,
    Highlight = false, FPSBoost = false
}

local OldLighting = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OreoHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 80, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0, 150)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.Text = "Menu"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
ToggleButton.Parent = ScreenGui
local ToggleCorner = Instance.new("UICorner", ToggleButton)
ToggleCorner.CornerRadius = UDim.new(0, 6)

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 460, 0, 260)
Frame.Position = UDim2.new(0, 10, 0, 190)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Visible = false
Frame.Parent = ScreenGui
local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 6)

local dragging, dragInput, dragStart, startPos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Header.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "  OreoHub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Info Label (Time, FPS, Ping)
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 200, 1, 0)
infoLabel.Position = UDim2.new(1, -200, 0, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "00:00:00 | 60 FPS | -- ms"
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.Font = Enum.Font.SourceSansBold
infoLabel.TextSize = 12
infoLabel.TextXAlignment = Enum.TextXAlignment.Right
infoLabel.Parent = Header

local fps = 60
local frames = 0
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastTime >= 1 then
        fps = frames
        frames = 0
        lastTime = tick()
    end
    local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
    infoLabel.Text = os.date("%H:%M:%S") .. " | " .. fps .. " FPS | " .. ping .. " ms"
end)

-- Tabs
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 25)
TabContainer.Position = UDim2.new(0, 0, 0, 30)
TabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TabContainer.Parent = Frame

local function createTab(text, posX, width)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0, width, 1, 0)
    tab.Position = UDim2.new(0, posX, 0, 0)
    tab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tab.Text = text
    tab.TextColor3 = Color3.fromRGB(200, 200, 200)
    tab.Font = Enum.Font.SourceSansBold
    tab.TextSize = 13
    tab.Parent = TabContainer
    return tab
end

local espTabBtn = createTab("ESP", 0, 90)
local aimTabBtn = createTab("Aim", 90, 90)
local charTabBtn = createTab("Char", 180, 90)
local secTabBtn = createTab("Def", 270, 90)
local setTabBtn = createTab("Settings", 360, 100)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.new(0, 10, 0, 65)
Content.BackgroundTransparency = 1
Content.Parent = Frame

local Pages = { ESP = Instance.new("Frame"), Aim = Instance.new("Frame"), Char = Instance.new("Frame"), Security = Instance.new("Frame"), Settings = Instance.new("Frame") }
for name, page in pairs(Pages) do
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = Content
end
Pages.ESP.Visible = true

local function switchTab(activePage, activeBtn)
    for _, page in pairs(Pages) do page.Visible = false end
    activePage.Visible = true
    for _, btn in pairs({espTabBtn, aimTabBtn, charTabBtn, secTabBtn, setTabBtn}) do
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    activeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

espTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.ESP, espTabBtn) end)
aimTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Aim, aimTabBtn) end)
charTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Char, charTabBtn) end)
secTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Security, secTabBtn) end)
setTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Settings, setTabBtn) end)

local function createBtn(parent, text, posX, posY, color, sizeX)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, sizeX or 170, 0, 35)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = parent
    return btn
end

-- ESP Tab
local espBtn = createBtn(Pages.ESP, "Master ESP: OFF", 0, 5, Color3.fromRGB(200, 50, 50))
local espBoxBtn = createBtn(Pages.ESP, "Box: OFF", 180, 5, Color3.fromRGB(200, 50, 50))
local espHealthBtn = createBtn(Pages.ESP, "Health: OFF", 0, 50, Color3.fromRGB(200, 50, 50))
local espDistBtn = createBtn(Pages.ESP, "Distance: OFF", 180, 50, Color3.fromRGB(200, 50, 50))
local fullbrightBtn = createBtn(Pages.ESP, "Fullbright: OFF", 0, 95, Color3.fromRGB(200, 50, 50))

-- Aim Tab
local silentAimBtn = createBtn(Pages.Aim, "Silent Aim (Soon)", 0, 5, Color3.fromRGB(50, 50, 50), 350)
silentAimBtn.Active = false

-- Char Tab
local speedBtn = createBtn(Pages.Char, "Speed: OFF", 0, 5, Color3.fromRGB(200, 50, 50), 110)
local noclipBtn = createBtn(Pages.Char, "Noclip: OFF", 0, 50, Color3.fromRGB(200, 50, 50), 110)
local infJumpBtn = createBtn(Pages.Char, "Inf Jump: OFF", 0, 95, Color3.fromRGB(200, 50, 50), 110)
local highlightBtn = createBtn(Pages.Char, "Highlight: OFF", 130, 50, Color3.fromRGB(200, 50, 50), 110)
local flyBtn = createBtn(Pages.Char, "Fly: OFF", 130, 95, Color3.fromRGB(200, 50, 50), 110)

-- Speed Control
local speedCtrl = Instance.new("Frame")
speedCtrl.Size = UDim2.new(0, 170, 0, 35)
speedCtrl.Position = UDim2.new(0, 120, 0, 5)
speedCtrl.BackgroundTransparency = 1
speedCtrl.Parent = Pages.Char

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 35, 1, 0)
minusBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
minusBtn.Text = "-"
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.Font = Enum.Font.SourceSansBold
minusBtn.Parent = speedCtrl

local speedText = Instance.new("TextLabel")
speedText.Size = UDim2.new(0, 100, 1, 0)
speedText.Position = UDim2.new(0, 35, 0, 0)
speedText.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedText.Text = "Speed: 16"
speedText.TextColor3 = Color3.fromRGB(255, 255, 255)
speedText.Font = Enum.Font.SourceSansBold
speedText.TextSize = 14
speedText.Parent = speedCtrl

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 35, 1, 0)
plusBtn.Position = UDim2.new(0, 135, 0, 0)
plusBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
plusBtn.Text = "+"
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.Font = Enum.Font.SourceSansBold
plusBtn.Parent = speedCtrl

-- Security Tab
local antiAfkBtn = createBtn(Pages.Security, "Anti AFK: OFF", 0, 5, Color3.fromRGB(200, 50, 50))
local antiFreezeBtn = createBtn(Pages.Security, "Anti Freeze: OFF", 180, 5, Color3.fromRGB(200, 50, 50))
local antiTpBtn = createBtn(Pages.Security, "Anti TP: OFF", 0, 50, Color3.fromRGB(200, 50, 50))
local antiFlingBtn = createBtn(Pages.Security, "Anti Fling: OFF", 180, 50, Color3.fromRGB(200, 50, 50))

-- Settings Tab
local fpsBoostBtn = createBtn(Pages.Settings, "FPS Boost: OFF", 0, 5, Color3.fromRGB(200, 50, 50))

-- Down Button (Fly)
local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 100, 0, 50)
downBtn.Position = UDim2.new(1, -120, 1, -150)
downBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
downBtn.BackgroundTransparency = 0.3
downBtn.Text = "Down"
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.TextSize = 16
downBtn.Font = Enum.Font.SourceSansBold
downBtn.Visible = false
downBtn.Parent = ScreenGui
local downCorner = Instance.new("UICorner", downBtn)
downCorner.CornerRadius = UDim.new(0, 8)

-- Toggle Logic
ToggleButton.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
    ToggleButton.Text = Frame.Visible and "Close" or "Menu"
end)

local function updateSpeedText()
    speedText.Text = "Speed: " .. Settings.SpeedValue
end
minusBtn.MouseButton1Click:Connect(function()
    Settings.SpeedValue = math.max(1, Settings.SpeedValue - 10)
    updateSpeedText()
end)
plusBtn.MouseButton1Click:Connect(function()
    Settings.SpeedValue = math.min(500, Settings.SpeedValue + 10)
    updateSpeedText()
end)

local function toggle(settingKey, btn, label)
    Settings[settingKey] = not Settings[settingKey]
    btn.Text = label .. ": " .. (Settings[settingKey] and "ON" or "OFF")
    btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end

espBtn.MouseButton1Click:Connect(function() toggle("ESP", espBtn, "Master ESP") end)
espBoxBtn.MouseButton1Click:Connect(function() toggle("ESP_Box", espBoxBtn, "Box") end)
espHealthBtn.MouseButton1Click:Connect(function() toggle("ESP_Health", espHealthBtn, "Health") end)
espDistBtn.MouseButton1Click:Connect(function() toggle("ESP_Distance", espDistBtn, "Distance") end)
fullbrightBtn.MouseButton1Click:Connect(function() toggle("Fullbright", fullbrightBtn, "Fullbright") end)
speedBtn.MouseButton1Click:Connect(function() toggle("SpeedHack", speedBtn, "Speed") end)
infJumpBtn.MouseButton1Click:Connect(function() toggle("InfJump", infJumpBtn, "Inf Jump") end)
antiAfkBtn.MouseButton1Click:Connect(function() toggle("AntiAFK", antiAfkBtn, "Anti AFK") end)
antiFreezeBtn.MouseButton1Click:Connect(function() toggle("AntiFreeze", antiFreezeBtn, "Anti Freeze") end)
antiTpBtn.MouseButton1Click:Connect(function() toggle("AntiTeleport", antiTpBtn, "Anti TP") end)
antiFlingBtn.MouseButton1Click:Connect(function() toggle("AntiFling", antiFlingBtn, "Anti Fling") end)
highlightBtn.MouseButton1Click:Connect(function() toggle("Highlight", highlightBtn, "Highlight") end)
flyBtn.MouseButton1Click:Connect(function()
    toggle("Fly", flyBtn, "Fly")
    downBtn.Visible = Settings.Fly
end)

fpsBoostBtn.MouseButton1Click:Connect(function() 
    toggle("FPSBoost", fpsBoostBtn, "FPS Boost")
    if Settings.FPSBoost then
        Lighting.GlobalShadows = false
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic; obj.Reflectance = 0
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj.Enabled = false end
        end
    else Lighting.GlobalShadows = true end
end)

noclipBtn.MouseButton1Click:Connect(function()
    toggle("Noclip", noclipBtn, "Noclip")
    if not Settings.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end)

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- Anti Freeze
RunService.Heartbeat:Connect(function()
    if Settings.AntiFreeze and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.PlatformStand then hum.PlatformStand = false end
    end
end)

-- Anti TP & Fling
local lastPos = nil
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if Settings.AntiTeleport then
        if not lastPos then lastPos = hrp.Position
        else
            local dist = (hrp.Position - lastPos).Magnitude
            if dist > 30 then hrp.CFrame = CFrame.new(lastPos); hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            else lastPos = hrp.Position end
        end
    else lastPos = nil end

    if Settings.AntiFling and hrp.AssemblyAngularVelocity.Magnitude > 50 then
        hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
    end
end)

-- Fly Logic
local flyVelocity = nil
local isJumping = false
local isDownPressed = false

UserInputService.JumpRequest:Connect(function()
    if Settings.Fly then
        isJumping = true
        task.delay(0.1, function() isJumping = false end)
    end
end)
downBtn.MouseButton1Down:Connect(function() isDownPressed = true end)
downBtn.MouseButton1Up:Connect(function() isDownPressed = false end)
downBtn.MouseLeave:Connect(function() isDownPressed = false end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if Settings.Fly then
        hum.PlatformStand = true
        if not flyVelocity then
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyVelocity.Velocity = Vector3.zero
            flyVelocity.Parent = hrp
        end
        local moveDir = hum.MoveDirection
        local targetVel = moveDir * Settings.FlySpeed
        if isJumping or UserInputService:IsKeyDown(Enum.KeyCode.Space) then targetVel = targetVel + Vector3.new(0, 50, 0)
        elseif isDownPressed or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then targetVel = targetVel - Vector3.new(0, 50, 0) end
        flyVelocity.Velocity = targetVel
    else
        if hum.PlatformStand then hum.PlatformStand = false end
        if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
    end
end)

-- Character Logic (Noclip, Highlight, Speed)
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    if Settings.Noclip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    if Settings.Highlight then
        if not char:FindFirstChild("HighlightSelf") then
            local hl = Instance.new("Highlight"); hl.Name = "HighlightSelf"; hl.FillColor = Color3.fromRGB(0, 255, 0); hl.OutlineColor = Color3.fromRGB(255, 255, 255); hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = char
        end
    else if char:FindFirstChild("HighlightSelf") then char.HighlightSelf:Destroy() end end
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    if Settings.SpeedHack then
        local spd = math.min(Settings.SpeedValue, 80)
        hum.WalkSpeed = spd
        if hum.MoveDirection.Magnitude > 0 then hrp.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * spd, hrp.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * spd) end
    else hum.WalkSpeed = 16 end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Fullbright then
        Lighting.Brightness = 2; Lighting.Ambient = Color3.fromRGB(255, 255, 255); Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = OldLighting.Brightness; Lighting.Ambient = OldLighting.Ambient; Lighting.OutdoorAmbient = OldLighting.OutdoorAmbient
    end
end)

UserInputService.JumpRequest:Connect(function()
    local char = LocalPlayer.Character
    if Settings.InfJump and char and char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ESP Logic
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "MyESP"
ESPFolder.Parent = game:GetService("CoreGui")
local espData = {}

local function IsTeammate(player)
    if LocalPlayer.Team == nil then return false end
    return player.Team == LocalPlayer.Team
end

local function CreateESP(player)
    if player == LocalPlayer or IsTeammate(player) then return end
    if espData[player.Name] then
        if espData[player.Name].gui then espData[player.Name].gui:Destroy() end
        if espData[player.Name].box then espData[player.Name].box:Destroy() end
        if espData[player.Name].renderConn then espData[player.Name].renderConn:Disconnect() end
    end

    local function onChar(char)
        if espData[player.Name] then
            if espData[player.Name].gui then espData[player.Name].gui:Destroy() end
            if espData[player.Name].box then espData[player.Name].box:Destroy() end
            if espData[player.Name].renderConn then espData[player.Name].renderConn:Disconnect() end
        end
        local head = char:WaitForChild("Head", 5)
        if not head then return end

        local bg = Instance.new("BillboardGui")
        bg.Name = player.Name .. "_Text"
        bg.Adornee = head
        bg.Size = UDim2.new(0, 250, 0, 80)
        bg.StudsOffset = Vector3.new(0, 3.5, 0)
        bg.AlwaysOnTop = true
        bg.Enabled = false
        bg.Parent = ESPFolder

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.fromRGB(255, 50, 50)
        text.Font = Enum.Font.SourceSansBold
        text.TextSize = 20
        text.TextStrokeTransparency = 0
        text.RichText = true
        text.Parent = bg

        local box = Instance.new("BoxHandleAdornment")
        box.Name = player.Name .. "_Box"
        box.Size = Vector3.new(4, 6, 4)
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Transparency = 0.5
        box.Color3 = Color3.fromRGB(255, 0, 0)
        box.Adornee = char:FindFirstChild("HumanoidRootPart") or head
        box.Visible = false
        box.Parent = ESPFolder

        local renderConn = RunService.RenderStepped:Connect(function()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not Settings.ESP or not char.Parent or not hrp or not myHrp or not hum then
                bg.Enabled = false
                box.Visible = false
                return
            end
            local dist = math.floor((myHrp.Position - hrp.Position).Magnitude)
            local hp = math.floor(hum.Health)
            local maxHp = math.floor(hum.MaxHealth)
            local displayStr = player.Name
            if Settings.ESP_Health then displayStr = displayStr .. "\n<font color='#32CD32'>HP: " .. hp .. "/" .. maxHp .. "</font>" end
            if Settings.ESP_Distance then displayStr = displayStr .. "\n[" .. dist .. "m]" end
            if Settings.ESP_Health or Settings.ESP_Distance then bg.Enabled = true; text.Text = displayStr
            else bg.Enabled = true; text.Text = player.Name end
            if Settings.ESP_Box then box.Adornee = hrp; box.Visible = true
            else box.Visible = false end
        end)
        espData[player.Name] = { gui = bg, box = box, renderConn = renderConn }
    end
    if player.Character then onChar(player.Character) end
    player.CharacterAdded:Connect(onChar)
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
-- ================= Fly Fix & Override =================
-- これまでのフライ機能の設定をリセット
if flyVelocity then flyVelocity:Destroy() end
if downBtn then downBtn:Destroy() end
if flySpeedCtrl then flySpeedCtrl:Destroy() end
if flyHeightCtrl then flyHeightCtrl:Destroy() end
if flyBtn then flyBtn:Destroy() end

-- 画面の「Char」タブにある古いフライボタンをすべて削除
for _, v in pairs(Pages.Char:GetChildren()) do
    if v:IsA("TextButton") and string.find(v.Text, "Fly") then
        v:Destroy()
    end
end

Settings.Fly = false
Settings.FlySpeed = 50

-- 1. フライON/OFFボタン（1つだけ）
local flyBtn = createBtn(Pages.Char, "Fly: OFF", 130, 95, Color3.fromRGB(200, 50, 50), 110)
flyBtn.MouseButton1Click:Connect(function()
    Settings.Fly = not Settings.Fly
    flyBtn.Text = "Fly: " .. (Settings.Fly and "ON" or "OFF")
    flyBtn.BackgroundColor3 = Settings.Fly and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    if downBtn then downBtn.Visible = Settings.Fly end
end)

-- 2. 下に下がるボタン（画面右下に配置）
local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 100, 0, 50)
downBtn.Position = UDim2.new(1, -120, 1, -150)
downBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
downBtn.BackgroundTransparency = 0.3
downBtn.Text = "Down"
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.TextSize = 20
downBtn.Font = Enum.Font.SourceSansBold
downBtn.Visible = false
downBtn.Parent = ScreenGui
local downCorner = Instance.new("UICorner", downBtn)
downCorner.CornerRadius = UDim.new(0, 8)

-- 3. フライ処理（ジャンプで上昇、Downボタンで下降）
local flyVelocity = nil
local isJumping = false
local isDownPressed = false

UserInputService.JumpRequest:Connect(function()
    if Settings.Fly then
        isJumping = true
        task.delay(0.1, function() isJumping = false end)
    end
end)

downBtn.MouseButton1Down:Connect(function() isDownPressed = true end)
downBtn.MouseButton1Up:Connect(function() isDownPressed = false end)
downBtn.MouseButton1Click:Connect(function() isDownPressed = false end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if Settings.Fly then
        hum.PlatformStand = true
        if not flyVelocity then
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyVelocity.Velocity = Vector3.zero
            flyVelocity.Parent = hrp
        end

        local targetVel = hum.MoveDirection * Settings.FlySpeed
        if isJumping or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            targetVel = targetVel + Vector3.new(0, 50, 0)
        elseif isDownPressed or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            targetVel = targetVel - Vector3.new(0, 50, 0)
        end
        flyVelocity.Velocity = targetVel
    else
        if hum.PlatformStand then hum.PlatformStand = false end
        if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
    end
end)
