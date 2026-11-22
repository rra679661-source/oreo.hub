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
-- ================= New Combat Tab & Random TP =================

-- 1. 新しい「戦闘」タブのボタンを作成（タブコンテナに追加）
local combatTabBtn = createTab("Combat", 0, 0) -- 仮でサイズ0にして後で調整
-- 既存のタブの幅を少し詰めて、右端に「Combat」を追加する
espTabBtn.Size = UDim2.new(0, 75, 1, 0)
aimTabBtn.Size = UDim2.new(0, 75, 1, 0)
aimTabBtn.Position = UDim2.new(0, 75, 0, 0)
charTabBtn.Size = UDim2.new(0, 75, 1, 0)
charTabBtn.Position = UDim2.new(0, 150, 0, 0)
secTabBtn.Size = UDim2.new(0, 75, 1, 0)
secTabBtn.Position = UDim2.new(0, 225, 0, 0)
setTabBtn.Size = UDim2.new(0, 75, 1, 0)
setTabBtn.Position = UDim2.new(0, 300, 0, 0)

combatTabBtn.Size = UDim2.new(0, 85, 1, 0)
combatTabBtn.Position = UDim2.new(0, 375, 0, 0)
combatTabBtn.Text = "Combat"

-- 2. 新しいページ（画面）を作成
local CombatPage = Instance.new("Frame")
CombatPage.Size = UDim2.new(1, 0, 1, 0)
CombatPage.BackgroundTransparency = 1
CombatPage.Visible = false
CombatPage.Parent = Content
Pages.Combat = CombatPage -- 既存のPagesテーブルに追加

-- 3. タブ切り替え処理の更新
local oldSwitchTab = switchTab
switchTab = function(activePage, activeBtn)
    for _, page in pairs(Pages) do page.Visible = false end
    activePage.Visible = true
    for _, btn in pairs({espTabBtn, aimTabBtn, charTabBtn, secTabBtn, setTabBtn, combatTabBtn}) do
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    activeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- 新しいタブクリック時の処理を再設定
espTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.ESP, espTabBtn) end)
aimTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Aim, aimTabBtn) end)
charTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Char, charTabBtn) end)
secTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Security, secTabBtn) end)
setTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Settings, setTabBtn) end)
combatTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Combat, combatTabBtn) end)

-- 4. 戦闘タブに「TP to Enemy」ボタンを配置
local tpEnemyBtn = createBtn(Pages.Combat, "TP to Enemy", 0, 5, Color3.fromRGB(50, 150, 50), 350)

tpEnemyBtn.MouseButton1Click:Connect(function()
    local enemies = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                if LocalPlayer.Team == nil or player.Team ~= LocalPlayer.Team then
                    table.insert(enemies, hrp)
                end
            end
        end
    end
    
    if #enemies > 0 then
        local targetHrp = enemies[math.random(1, #enemies)]
        local myChar = LocalPlayer.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            myChar.HumanoidRootPart.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)
-- ================= Combat Tab & Random TP Fix =================

-- 既存のタブの幅と位置を均等に再設定
espTabBtn.Size = UDim2.new(0, 75, 1, 0)
espTabBtn.Position = UDim2.new(0, 0, 0, 0)

aimTabBtn.Size = UDim2.new(0, 75, 1, 0)
aimTabBtn.Position = UDim2.new(0, 75, 0, 0)

charTabBtn.Size = UDim2.new(0, 75, 1, 0)
charTabBtn.Position = UDim2.new(0, 150, 0, 0)

secTabBtn.Size = UDim2.new(0, 75, 1, 0)
secTabBtn.Position = UDim2.new(0, 225, 0, 0)

setTabBtn.Size = UDim2.new(0, 75, 1, 0)
setTabBtn.Position = UDim2.new(0, 300, 0, 0)

-- 新しい「Combat」タブのボタンを作成
local combatTabBtn = createTab("Combat", 375, 85)

-- 新しいページ（画面）を作成
local CombatPage = Instance.new("Frame")
CombatPage.Size = UDim2.new(1, 0, 1, 0)
CombatPage.BackgroundTransparency = 1
CombatPage.Visible = false
CombatPage.Parent = Content
Pages.Combat = CombatPage

-- タブ切り替え処理の更新
local oldSwitchTab = switchTab
switchTab = function(activePage, activeBtn)
    for _, page in pairs(Pages) do page.Visible = false end
    activePage.Visible = true
    for _, btn in pairs({espTabBtn, aimTabBtn, charTabBtn, secTabBtn, setTabBtn, combatTabBtn}) do
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    activeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- タブクリックイベントの再登録
espTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.ESP, espTabBtn) end)
aimTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Aim, aimTabBtn) end)
charTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Char, charTabBtn) end)
secTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Security, secTabBtn) end)
setTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Settings, setTabBtn) end)
combatTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Combat, combatTabBtn) end)

-- 戦闘タブに「TP to Enemy」ボタンを配置
local tpEnemyBtn = createBtn(Pages.Combat, "TP to Enemy", 0, 5, Color3.fromRGB(50, 150, 50), 350)

tpEnemyBtn.MouseButton1Click:Connect(function()
    local enemies = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                if LocalPlayer.Team == nil or player.Team ~= LocalPlayer.Team then
                    table.insert(enemies, hrp)
                end
            end
        end
    end
    
    if #enemies > 0 then
        local targetHrp = enemies[math.random(1, #enemies)]
        local myChar = LocalPlayer.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            myChar.HumanoidRootPart.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)-- ================= Combat Tab Force Fix =================

-- 既存の5つのタブを少し左に寄せて幅を狭める
if espTabBtn then espTabBtn.Size = UDim2.new(0, 75, 1, 0); espTabBtn.Position = UDim2.new(0, 0, 0, 0) end
if aimTabBtn then aimTabBtn.Size = UDim2.new(0, 75, 1, 0); aimTabBtn.Position = UDim2.new(0, 75, 0, 0) end
if charTabBtn then charTabBtn.Size = UDim2.new(0, 75, 1, 0); charTabBtn.Position = UDim2.new(0, 150, 0, 0) end
if secTabBtn then secTabBtn.Size = UDim2.new(0, 75, 1, 0); secTabBtn.Position = UDim2.new(0, 225, 0, 0) end
if setTabBtn then setTabBtn.Size = UDim2.new(0, 75, 1, 0); setTabBtn.Position = UDim2.new(0, 300, 0, 0) end

-- 新しい「Combat」タブのボタンを一番上に強制表示
local combatTabBtn = Instance.new("TextButton")
combatTabBtn.Size = UDim2.new(0, 85, 1, 0)
combatTabBtn.Position = UDim2.new(0, 375, 0, 0)
combatTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
combatTabBtn.Text = "Combat"
combatTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
combatTabBtn.Font = Enum.Font.SourceSansBold
combatTabBtn.TextSize = 13
combatTabBtn.ZIndex = 10
combatTabBtn.Parent = TabContainer

-- 新しいページ（画面）を作成
local CombatPage = Instance.new("Frame")
CombatPage.Size = UDim2.new(1, 0, 1, 0)
CombatPage.BackgroundTransparency = 1
CombatPage.Visible = false
CombatPage.Parent = Content
Pages.Combat = CombatPage

-- タブ切り替え処理
combatTabBtn.MouseButton1Click:Connect(function()
    for _, page in pairs(Pages) do page.Visible = false end
    CombatPage.Visible = true
    for _, btn in pairs({espTabBtn, aimTabBtn, charTabBtn, secTabBtn, setTabBtn, combatTabBtn}) do
        if btn then
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    combatTabBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    combatTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

-- 他のタブが押されたらCombatタブの色を戻す処理
local function resetCombatTab()
    if combatTabBtn then
        combatTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        combatTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end
if espTabBtn then espTabBtn.MouseButton1Click:Connect(resetCombatTab) end
if aimTabBtn then aimTabBtn.MouseButton1Click:Connect(resetCombatTab) end
if charTabBtn then charTabBtn.MouseButton1Click:Connect(resetCombatTab) end
if secTabBtn then secTabBtn.MouseButton1Click:Connect(resetCombatTab) end
if setTabBtn then setTabBtn.MouseButton1Click:Connect(resetCombatTab) end

-- 戦闘タブに「TP to Enemy」ボタンを配置
local tpEnemyBtn = createBtn(CombatPage, "TP to Enemy", 0, 5, Color3.fromRGB(50, 150, 50), 350)

tpEnemyBtn.MouseButton1Click:Connect(function()
    local enemies = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                if LocalPlayer.Team == nil or player.Team ~= LocalPlayer.Team then
                    table.insert(enemies, hrp)
                end
            end
        end
    end
    
    if #enemies > 0 then
        local targetHrp = enemies[math.random(1, #enemies)]
        local myChar = LocalPlayer.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            myChar.HumanoidRootPart.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)
-- ================= Aim Tab: Triggerbot =================

-- エイムタブにトリガーボットのボタンを追加
local aimTriggerbotBtn = createBtn(Pages.Aim, "Triggerbot: OFF", 0, 50, Color3.fromRGB(200, 50, 50), 350)

Settings.Triggerbot = false
Settings.TriggerbotFOV = 150

aimTriggerbotBtn.MouseButton1Click:Connect(function()
    Settings.Triggerbot = not Settings.Triggerbot
    aimTriggerbotBtn.Text = "Triggerbot: " .. (Settings.Triggerbot and "ON" or "OFF")
    aimTriggerbotBtn.BackgroundColor3 = Settings.Triggerbot and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

-- 画面中央に敵がいるか確認する関数
local function IsEnemyInCrosshair()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            
            if hum and hum.Health > 0 and (head or hrp) then
                if LocalPlayer.Team == nil or player.Team ~= LocalPlayer.Team then
                    local targetPart = head or hrp
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if dist < Settings.TriggerbotFOV then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- トリガーボットの実行ループ
local isFiring = false
task.spawn(function()
    while task.wait(0.01) do
        if Settings.Triggerbot then
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                if IsEnemyInCrosshair() then
                    if not isFiring then
                        isFiring = true
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            pcall(function() tool:Activate() end)
                        end
                        pcall(function() VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
                    end
                else
                    if isFiring then
                        isFiring = false
                        pcall(function() VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
                    end
                end
            end
        else
            if isFiring then
                isFiring = false
                pcall(function() VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
            end
        end
    end
end)-- ================= Triggerbot Absolute Fix =================

Settings.Triggerbot = false
Settings.TriggerbotFOV = 150

-- エイムタブ（Pages.Aim）の真ん中あたりに直接ボタンを生成
local aimTriggerbotBtn = Instance.new("TextButton")
aimTriggerbotBtn.Size = UDim2.new(0, 250, 0, 40)
aimTriggerbotBtn.Position = UDim2.new(0, 10, 0, 50)
aimTriggerbotBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
aimTriggerbotBtn.Text = "Triggerbot: OFF"
aimTriggerbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aimTriggerbotBtn.Font = Enum.Font.SourceSansBold
aimTriggerbotBtn.TextSize = 16
aimTriggerbotBtn.ZIndex = 10
aimTriggerbotBtn.Parent = Pages.Aim

-- ボタンが押された時の処理
aimTriggerbotBtn.MouseButton1Click:Connect(function()
    Settings.Triggerbot = not Settings.Triggerbot
    aimTriggerbotBtn.Text = "Triggerbot: " .. (Settings.Triggerbot and "ON" or "OFF")
    aimTriggerbotBtn.BackgroundColor3 = Settings.Triggerbot and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

-- 画面中央に敵がいるか確認する関数
local function IsEnemyInCrosshair()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            
            if hum and hum.Health > 0 and (head or hrp) then
                if LocalPlayer.Team == nil or player.Team ~= LocalPlayer.Team then
                    local targetPart = head or hrp
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if dist < Settings.TriggerbotFOV then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- トリガーボットの実行ループ
local isFiring = false
task.spawn(function()
    while task.wait(0.01) do
        if Settings.Triggerbot then
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                if IsEnemyInCrosshair() then
                    if not isFiring then
                        isFiring = true
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            pcall(function() tool:Activate() end)
                        end
                        pcall(function() VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
                    end
                else
                    if isFiring then
                        isFiring = false
                        pcall(function() VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
                    end
                end
            end
        else
            if isFiring then
                isFiring = false
                pcall(function() VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
            end
        end
    end
end)
-- ================= Aim Triggerbot Force Fix =================

Settings.Triggerbot = false
Settings.TriggerbotFOV = 150

-- 画面の一番手前にボタンを強制表示
local aimTriggerbotBtn = Instance.new("TextButton")
aimTriggerbotBtn.Size = UDim2.new(0, 150, 0, 40)
aimTriggerbotBtn.Position = UDim2.new(0, 10, 0, 300) -- 画面左側の下の方
aimTriggerbotBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
aimTriggerbotBtn.Text = "Triggerbot: OFF"
aimTriggerbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aimTriggerbotBtn.Font = Enum.Font.SourceSansBold
aimTriggerbotBtn.TextSize = 16
aimTriggerbotBtn.ZIndex = 9999
aimTriggerbotBtn.Parent = ScreenGui -- メニューの中ではなく、画面全体に直接配置

aimTriggerbotBtn.MouseButton1Click:Connect(function()
    Settings.Triggerbot = not Settings.Triggerbot
    aimTriggerbotBtn.Text = "Triggerbot: " .. (Settings.Triggerbot and "ON" or "OFF")
    aimTriggerbotBtn.BackgroundColor3 = Settings.Triggerbot and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

local function IsEnemyInCrosshair()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and (head or hrp) then
                if LocalPlayer.Team == nil or player.Team ~= LocalPlayer.Team then
                    local targetPart = head or hrp
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if dist < Settings.TriggerbotFOV then return true end
                    end
                end
            end
        end
    end
    return false
end

local isFiring = false
task.spawn(function()
    while task.wait(0.01) do
        if Settings.Triggerbot then
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                if IsEnemyInCrosshair() then
                    if not isFiring then
                        isFiring = true
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then pcall(function() tool:Activate() end) end
                        pcall(function() VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
                    end
                else
                    if isFiring then
                        isFiring = false
                        pcall(function() VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
                    end
                end
            end
        else
            if isFiring then
                isFiring = false
                pcall(function() VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
            end
        end
    end
end)
-- ================= Triggerbot Position Fix =================
if aimTriggerbotBtn then aimTriggerbotBtn:Destroy() end

local aimTriggerbotBtn = Instance.new("TextButton")
aimTriggerbotBtn.Size = UDim2.new(0, 150, 0, 40)
aimTriggerbotBtn.Position = UDim2.new(0.5, -75, 0.5, -20) -- 画面のド真ん中
aimTriggerbotBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
aimTriggerbotBtn.Text = "Triggerbot: OFF"
aimTriggerbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aimTriggerbotBtn.Font = Enum.Font.SourceSansBold
aimTriggerbotBtn.TextSize = 16
aimTriggerbotBtn.ZIndex = 9999
aimTriggerbotBtn.Parent = ScreenGui

-- 今の状態（ONかOFFか）を引き継ぐ
aimTriggerbotBtn.Text = "Triggerbot: " .. (Settings.Triggerbot and "ON" or "OFF")
aimTriggerbotBtn.BackgroundColor3 = Settings.Triggerbot and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)

aimTriggerbotBtn.MouseButton1Click:Connect(function()
    Settings.Triggerbot = not Settings.Triggerbot
    aimTriggerbotBtn.Text = "Triggerbot: " .. (Settings.Triggerbot and "ON" or "OFF")
    aimTriggerbotBtn.BackgroundColor3 = Settings.Triggerbot and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)
-- ================= Triggerbot UI Fix =================

-- 画面外や重複しているボタンをすべて消去
if aimTriggerbotBtn then aimTriggerbotBtn:Destroy() end
for _, v in pairs(ScreenGui:GetChildren()) do
    if v:IsA("TextButton") and string.find(v.Text, "Triggerbot") then
        v:Destroy()
    end
end
for _, v in pairs(Pages.Aim:GetChildren()) do
    if v:IsA("TextButton") and string.find(v.Text, "Triggerbot") then
        v:Destroy()
    end
end

-- エイムタブの正しい位置（Silent Aimの下）に1つだけ生成
local finalTriggerbotBtn = createBtn(Pages.Aim, "Triggerbot: OFF", 0, 50, Color3.fromRGB(200, 50, 50), 350)

-- 今の設定状態（ON/OFF）を引き継ぐ
if Settings.Triggerbot then
    finalTriggerbotBtn.Text = "Triggerbot: ON"
    finalTriggerbotBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
else
    finalTriggerbotBtn.Text = "Triggerbot: OFF"
    finalTriggerbotBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end

-- ボタンが押された時の処理
finalTriggerbotBtn.MouseButton1Click:Connect(function()
    Settings.Triggerbot = not Settings.Triggerbot
    finalTriggerbotBtn.Text = "Triggerbot: " .. (Settings.Triggerbot and "ON" or "OFF")
    finalTriggerbotBtn.BackgroundColor3 = Settings.Triggerbot and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)
-- ================= 最終修正: Triggerbotの完全な整理 =================

-- 1. 画面下の邪魔な赤いボタンを消す
for _, v in pairs(ScreenGui:GetChildren()) do
    if v:IsA("TextButton") and string.find(v.Text, "Triggerbot") then
        v:Destroy()
    end
end

-- 2. エイムタブの中にある古いボタンを消す
for _, v in pairs(Pages.Aim:GetChildren()) do
    if v:IsA("TextButton") and string.find(v.Text, "Triggerbot") then
        v:Destroy()
    end
end

-- 3. エイムタブの「Silent Aim (Soon)」のすぐ下に新しいボタンを1つだけ作る
local finalTriggerbotBtn = createBtn(Pages.Aim, "Triggerbot: OFF", 0, 50, Color3.fromRGB(200, 50, 50), 350)

-- 設定状態を引き継ぐ
if Settings.Triggerbot then
    finalTriggerbotBtn.Text = "Triggerbot: ON"
    finalTriggerbotBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
else
    finalTriggerbotBtn.Text = "Triggerbot: OFF"
    finalTriggerbotBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end

-- ボタンを押した時の処理
finalTriggerbotBtn.MouseButton1Click:Connect(function()
    Settings.Triggerbot = not Settings.Triggerbot
    finalTriggerbotBtn.Text = "Triggerbot: " .. (Settings.Triggerbot and "ON" or "OFF")
    finalTriggerbotBtn.BackgroundColor3 = Settings.Triggerbot and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)-- ================= Absolute Final Fix =================

-- 1. 画面に散らばっているすべてのTriggerbotボタン（枠外の赤いボタン含む）を完全に削除
for _, v in pairs(ScreenGui:GetDescendants()) do
    if v:IsA("TextButton") and string.find(v.Text, "Triggerbot") then
        v:Destroy()
    end
end
for _, v in pairs(Pages.Aim:GetDescendants()) do
    if v:IsA("TextButton") and string.find(v.Text, "Triggerbot") then
        v:Destroy()
    end
end
for _, v in pairs(Pages.Combat:GetDescendants()) do
    if v:IsA("TextButton") and string.find(v.Text, "Triggerbot") then
        v:Destroy()
    end
end

-- 2. エイムタブの正しい位置（Silent Aimの下）に、新しいボタンを1つだけ綺麗に配置
local finalTB = createBtn(Pages.Aim, "Triggerbot: OFF", 0, 50, Color3.fromRGB(200, 50, 50), 350)
Settings.Triggerbot = false

-- 3. ボタンのON/OFF切り替え処理
finalTB.MouseButton1Click:Connect(function()
    Settings.Triggerbot = not Settings.Triggerbot
    finalTB.Text = "Triggerbot: " .. (Settings.Triggerbot and "ON" or "OFF")
    finalTB.BackgroundColor3 = Settings.Triggerbot and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

-- 4. 画面中央に敵がいるか確認する関数（トリガーの判定）
local function IsEnemyInCrosshair()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and (head or hrp) then
                if LocalPlayer.Team == nil or player.Team ~= LocalPlayer.Team then
                    local targetPart = head or hrp
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if dist < 150 then return true end
                    end
                end
            end
        end
    end
    return false
end

-- 5. 自動射撃の実行ループ（一番強力な擬似クリック処理）
local firing = false
task.spawn(function()
    while task.wait(0.01) do
        if Settings.Triggerbot then
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                if IsEnemyInCrosshair() then
                    if not firing then
                        firing = true
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then pcall(function() tool:Activate() end) end
                        pcall(function() VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
                    end
                else
                    if firing then
                        firing = false
                        pcall(function() VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
                    end
                end
            end
        else
            if firing then
                firing = false
                pcall(function() VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
            end
        end
    end
end)

-- 6. これまでの「TP to Enemy」ボタンもCombatタブの綺麗な位置に再配置
for _, v in pairs(Pages.Combat:GetDescendants()) do
    if v:IsA("TextButton") and string.find(v.Text, "TP") then v:Destroy() end
end
local finalTP = createBtn(Pages.Combat, "TP to Enemy", 0, 5, Color3.fromRGB(50, 150, 50), 350)
finalTP.MouseButton1Click:Connect(function()
    local enemies = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                if LocalPlayer.Team == nil or player.Team ~= LocalPlayer.Team then
                    table.insert(enemies, hrp)
                end
            end
        end
    end
    if #enemies > 0 then
        local targetHrp = enemies[math.random(1, #enemies)]
        local myChar = LocalPlayer.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            myChar.HumanoidRootPart.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)-- ================= トリガーボット超強化版（付け足し用） =================
-- 既存のトリガーボット処理を無効化（上書き）します
if isFiring ~= nil then isFiring = nil end
Settings.Triggerbot = false
Settings.TriggerbotFOV = 150

-- UIのトリガーボットボタンのテキストを初期化
if triggerBtn then
    triggerBtn.Text = "Triggerbot: OFF"
    triggerBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end

-- 画面中央の敵を検知する関数（FOV 150px以内）
local function IsEnemyInCrosshair()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeammate(player) and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and (head or hrp) then
                local targetPart = head or hrp
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist < Settings.TriggerbotFOV then 
                        return true 
                    end
                end
            end
        end
    end
    return false
end

-- 強化された自動射撃ループ
local firing = false
task.spawn(function()
    while task.wait(0.01) do -- 0.01秒ごとに高速判定
        if Settings.Triggerbot then
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                if IsEnemyInCrosshair() then
                    if not firing then
                        firing = true
                        
                        -- 1. 持っている武器（Tool）を直接発動させる
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then 
                            pcall(function() tool:Activate() end) 
                        end
                        
                        -- 2. マウスクリック（射撃入力）をエミュレートする
                        pcall(function() VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
                    end
                else
                    if firing then
                        firing = false
                        -- マウスクリックを離す
                        pcall(function() VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
                    end
                end
            end
        else
            if firing then
                firing = false
                pcall(function() VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
            end
        end
    end
end)

-- ボタンのクリックイベントを再設定
if triggerBtn then
    triggerBtn.MouseButton1Click:Connect(function()
        Settings.Triggerbot = not Settings.Triggerbot
        triggerBtn.Text = "Triggerbot: " .. (Settings.Triggerbot and "ON" or "OFF")
        triggerBtn.BackgroundColor3 = Settings.Triggerbot and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    end)
end
-- ================= Rivals専用 Triggerbot (最終手段) =================
Settings.Triggerbot = false
Settings.TriggerbotFOV = 150

-- トリガーボット用のUIボタン（一番手前に強制表示）
local FinalTriggerBtn = Instance.new("TextButton")
FinalTriggerBtn.Size = UDim2.new(0, 150, 0, 40)
FinalTriggerBtn.Position = UDim2.new(0, 20, 0, 350)
FinalTriggerBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
FinalTriggerBtn.Text = "Trigger (Final): OFF"
FinalTriggerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FinalTriggerBtn.Font = Enum.Font.SourceSansBold
FinalTriggerBtn.TextSize = 14
FinalTriggerBtn.ZIndex = 999
FinalTriggerBtn.Parent = ScreenGui

FinalTriggerBtn.MouseButton1Click:Connect(function()
    Settings.Triggerbot = not Settings.Triggerbot
    FinalTriggerBtn.Text = "Trigger (Final): " .. (Settings.Triggerbot and "ON" or "OFF")
    FinalTriggerBtn.BackgroundColor3 = Settings.Triggerbot and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

-- 中央に敵がいるか判定
local function CheckEnemy()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            if hum and hum.Health > 0 and head then
                if LocalPlayer.Team == nil or player.Team ~= LocalPlayer.Team then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist < Settings.TriggerbotFOV then return true end
                    end
                end
            end
        end
    end
    return false
end

-- 発砲処理
local isShooting = false
local toolDebounce = false

task.spawn(function()
    while task.wait(0.01) do
        if Settings.Triggerbot and CheckEnemy() then
            if not isShooting then
                isShooting = true
                local char = LocalPlayer.Character
                if char then
                    -- 1. ツールの直接発動（連射用にデバウンスを入れる）
                    if not toolDebounce then
                        toolDebounce = true
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then 
                            -- Rivalsの銃はActivateではなく、内部のリモートを叩く必要がある場合がありますが、
                            -- まずはActivateを連打します
                            pcall(function() tool:Activate() end)
                        end
                        task.delay(0.1, function() toolDebounce = false end)
                    end
                    
                    -- 2. マウスクリックのエミュレート（Deltaの機能をフル活用）
                    pcall(function() VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
                end
            end
        else
            if isShooting then
                isShooting = false
                pcall(function() VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
            end
        end
    end
end)
