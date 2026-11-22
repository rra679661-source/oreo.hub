local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    ESP = false,
    ESP_Box = false,
    ESP_Health = false,
    ESP_Distance = false,
    Fullbright = false,
    SpeedHack = false,
    SpeedValue = 16,
    InfJump = false,
    Noclip = false,
    AntiAFK = false,
    AntiFreeze = false,
    AntiTeleport = false,
    AntiFling = false,
    Highlight = false,
    FPSBoost = false
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

-- メニュー開閉ボタン
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 80, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0, 150)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.Text = "メニュー"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
ToggleButton.Parent = ScreenGui
local ToggleCorner = Instance.new("UICorner", ToggleButton)
ToggleCorner.CornerRadius = UDim.new(0, 6)

-- メインUI
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
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Header.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "  OreoHub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

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
local aimTabBtn = createTab("エイム", 90, 90)
local charTabBtn = createTab("キャラ", 180, 90)
local secTabBtn = createTab("防御", 270, 90)
local setTabBtn = createTab("設定", 360, 100)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.new(0, 10, 0, 65)
Content.BackgroundTransparency = 1
Content.Parent = Frame

local Pages = {
    ESP = Instance.new("Frame"),
    Aim = Instance.new("Frame"),
    Char = Instance.new("Frame"),
    Security = Instance.new("Frame"),
    Settings = Instance.new("Frame")
}

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

-- ================= ESP タブ =================
local espBtn = createBtn(Pages.ESP, "マスターESP: OFF", 0, 5, Color3.fromRGB(200, 50, 50))
local espBoxBtn = createBtn(Pages.ESP, "ボックス: OFF", 180, 5, Color3.fromRGB(200, 50, 50))
local espHealthBtn = createBtn(Pages.ESP, "体力表示: OFF", 0, 50, Color3.fromRGB(200, 50, 50))
local espDistBtn = createBtn(Pages.ESP, "距離表示: OFF", 180, 50, Color3.fromRGB(200, 50, 50))
local fullbrightBtn = createBtn(Pages.ESP, "フルブライト: OFF", 0, 95, Color3.fromRGB(200, 50, 50))

-- ================= エイム タブ =================
local silentAimBtn = createBtn(Pages.Aim, "サイレントエイム (後日配信)", 0, 5, Color3.fromRGB(50, 50, 50), 350)
silentAimBtn.Active = false

-- ================= キャラ タブ =================
local speedBtn = createBtn(Pages.Char, "速度変更: OFF", 0, 5, Color3.fromRGB(200, 50, 50), 110)
local noclipBtn = createBtn(Pages.Char, "壁抜け: OFF", 0, 50, Color3.fromRGB(200, 50, 50), 110)
local infJumpBtn = createBtn(Pages.Char, "無限ジャンプ: OFF", 0, 95, Color3.fromRGB(200, 50, 50), 110)

local highlightBtn = createBtn(Pages.Char, "ハイライト: OFF", 130, 50, Color3.fromRGB(200, 50, 50), 110)

-- 速度調整
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
speedText.Text = "速さ: 16"
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

-- ================= セキュリティ タブ =================
local antiAfkBtn = createBtn(Pages.Security, "アンチAFK: OFF", 0, 5, Color3.fromRGB(200, 50, 50))
local antiFreezeBtn = createBtn(Pages.Security, "アンチフリーズ: OFF", 180, 5, Color3.fromRGB(200, 50, 50))
local antiTpBtn = createBtn(Pages.Security, "アンチテレポート: OFF", 0, 50, Color3.fromRGB(200, 50, 50))
local antiFlingBtn = createBtn(Pages.Security, "アンチフリンチ: OFF", 180, 50, Color3.fromRGB(200, 50, 50))

-- ================= 設定 タブ =================
local fpsBoostBtn = createBtn(Pages.Settings, "FPSブースト: OFF", 0, 5, Color3.fromRGB(200, 50, 50))

-- 開閉処理
ToggleButton.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
    ToggleButton.Text = Frame.Visible and "閉じる" or "メニュー"
    ToggleButton.BackgroundColor3 = Frame.Visible and Color3.fromRGB(180, 60, 60) or Color3.fromRGB(40, 40, 40)
end)

-- 処理
local function updateSpeedText()
    speedText.Text = "速さ: " .. Settings.SpeedValue
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

espBtn.MouseButton1Click:Connect(function() toggle("ESP", espBtn, "マスターESP") end)
espBoxBtn.MouseButton1Click:Connect(function() toggle("ESP_Box", espBoxBtn, "ボックス") end)
espHealthBtn.MouseButton1Click:Connect(function() toggle("ESP_Health", espHealthBtn, "体力表示") end)
espDistBtn.MouseButton1Click:Connect(function() toggle("ESP_Distance", espDistBtn, "距離表示") end)
fullbrightBtn.MouseButton1Click:Connect(function() toggle("Fullbright", fullbrightBtn, "フルブライト") end)
speedBtn.MouseButton1Click:Connect(function() toggle("SpeedHack", speedBtn, "速度変更") end)
infJumpBtn.MouseButton1Click:Connect(function() toggle("InfJump", infJumpBtn, "無限ジャンプ") end)
antiAfkBtn.MouseButton1Click:Connect(function() toggle("AntiAFK", antiAfkBtn, "アンチAFK") end)
antiFreezeBtn.MouseButton1Click:Connect(function() toggle("AntiFreeze", antiFreezeBtn, "アンチフリーズ") end)
antiTpBtn.MouseButton1Click:Connect(function() toggle("AntiTeleport", antiTpBtn, "アンチテレポート") end)
antiFlingBtn.MouseButton1Click:Connect(function() toggle("AntiFling", antiFlingBtn, "アンチフリンチ") end)
highlightBtn.MouseButton1Click:Connect(function() toggle("Highlight", highlightBtn, "ハイライト") end)
fpsBoostBtn.MouseButton1Click:Connect(function() 
    toggle("FPSBoost", fpsBoostBtn, "FPSブースト")
    if Settings.FPSBoost then
        Lighting.GlobalShadows = false
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end
    else
        Lighting.GlobalShadows = true
    end
end)

noclipBtn.MouseButton1Click:Connect(function()
    toggle("Noclip", noclipBtn, "壁抜け")
    if not Settings.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end)

-- アンチAFK
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- アンチフリーズ
RunService.Heartbeat:Connect(function()
    if Settings.AntiFreeze and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.PlatformStand then
            hum.PlatformStand = false
        end
    end
end)

-- アンチテレポート
local lastPos = nil
RunService.Heartbeat:Connect(function()
    if Settings.AntiTeleport and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not lastPos then
                lastPos = hrp.Position
            else
                local dist = (hrp.Position - lastPos).Magnitude
                if dist > 30 then
                    hrp.CFrame = CFrame.new(lastPos)
                    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                else
                    lastPos = hrp.Position
                end
            end
        end
    else
        lastPos = nil
    end
end)

-- アンチフリンチ
RunService.Heartbeat:Connect(function()
    if Settings.AntiFling and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp.AssemblyAngularVelocity.Magnitude > 50 then
                hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
            end
        end
    end
end)

-- キャラクター処理 (壁抜け・ハイライト)
RunService.Stepped:Connect(function(time, deltaTime)
    local char = LocalPlayer.Character
    if not char then return end

    if Settings.Noclip then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    if Settings.Highlight then
        if not char:FindFirstChild("HighlightSelf") then
            local hl = Instance.new("Highlight")
            hl.Name = "HighlightSelf"
            hl.FillColor = Color3.fromRGB(0, 255, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = char
        end
    else
        if char:FindFirstChild("HighlightSelf") then
            char.HighlightSelf:Destroy()
        end
    end
end)

-- 速度変更
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if Settings.SpeedHack then
        local spd = math.min(Settings.SpeedValue, 80)
        hum.WalkSpeed = spd
        if hum.MoveDirection.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * spd, hrp.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * spd)
        end
    else
        hum.WalkSpeed = 16
    end
end)

-- 明るさ処理
RunService.RenderStepped:Connect(function()
    if Settings.Fullbright then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = OldLighting.Brightness
        Lighting.Ambient = OldLighting.Ambient
        Lighting.OutdoorAmbient = OldLighting.OutdoorAmbient
    end
end)

-- 無限ジャンプ
UserInputService.JumpRequest:Connect(function()
    local char = LocalPlayer.Character
    if Settings.InfJump and char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ESP処理
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
            if Settings.ESP_Health then
                displayStr = displayStr .. "\n<font color='#32CD32'>HP: " .. hp .. "/" .. maxHp .. "</font>"
            end
            if Settings.ESP_Distance then
                displayStr = displayStr .. "\n[" .. dist .. "m]"
            end

            if Settings.ESP_Health or Settings.ESP_Distance then
                bg.Enabled = true
                text.Text = displayStr
            else
                bg.Enabled = true
                text.Text = player.Name
            end

            if Settings.ESP_Box then
                box.Adornee = hrp
                box.Visible = true
            else
                box.Visible = false
            end
        end)
        
        espData[player.Name] = { gui = bg, box = box, renderConn = renderConn }
    end

    if player.Character then onChar(player.Character) end
    player.CharacterAdded:Connect(onChar)
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
-- ================= Fly Feature =================

Settings.Fly = false

-- UI Addition (Char Tab)
local flyBtn = createBtn(Pages.Char, "Fly: OFF", 130, 95, Color3.fromRGB(200, 50, 50), 110)

-- Down button for mobile
local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 50, 0, 50)
downBtn.Position = UDim2.new(1, -70, 1, -120)
downBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
downBtn.BackgroundTransparency = 0.5
downBtn.Text = "v"
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.TextSize = 30
downBtn.Font = Enum.Font.SourceSansBold
downBtn.Visible = false
downBtn.Parent = ScreenGui
local downCorner = Instance.new("UICorner", downBtn)
downCorner.CornerRadius = UDim.new(1, 0)

flyBtn.MouseButton1Click:Connect(function()
    Settings.Fly = not Settings.Fly
    flyBtn.Text = "Fly: " .. (Settings.Fly and "ON" or "OFF")
    flyBtn.BackgroundColor3 = Settings.Fly and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    downBtn.Visible = Settings.Fly
end)

-- Fly Logic
local flyVelocity = nil
local isJumping = false
local isDownPressed = false

-- Jump button detection
UserInputService.JumpRequest:Connect(function()
    if Settings.Fly then
        isJumping = true
        task.delay(0.1, function() isJumping = false end)
    end
end)

-- Down button detection
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

        -- Movement calculation
        local moveDir = hum.MoveDirection
        local targetVel = moveDir * 50

        -- Up/Down
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
-- ================= Fly Feature =================

Settings.Fly = false

-- UI Addition (Char Tab)
local flyBtn = createBtn(Pages.Char, "Fly: OFF", 130, 95, Color3.fromRGB(200, 50, 50), 110)

-- Down button for mobile (位置を画面右側の真ん中に固定)
local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 50, 0, 50)
downBtn.Position = UDim2.new(1, -70, 0.5, -25) -- ★画面右端から70px、上下中央
downBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
downBtn.BackgroundTransparency = 0.5
downBtn.Text = "v"
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.TextSize = 30
downBtn.Font = Enum.Font.SourceSansBold
downBtn.Visible = false
downBtn.Parent = ScreenGui
local downCorner = Instance.new("UICorner", downBtn)
downCorner.CornerRadius = UDim.new(1, 0)

flyBtn.MouseButton1Click:Connect(function()
    Settings.Fly = not Settings.Fly
    flyBtn.Text = "Fly: " .. (Settings.Fly and "ON" or "OFF")
    flyBtn.BackgroundColor3 = Settings.Fly and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    downBtn.Visible = Settings.Fly
end)

-- Fly Logic
local flyVelocity = nil
local isJumping = false
local isDownPressed = false

-- Jump button detection
UserInputService.JumpRequest:Connect(function()
    if Settings.Fly then
        isJumping = true
        task.delay(0.1, function() isJumping = false end)
    end
end)

-- Down button detection
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

        -- Movement calculation
        local moveDir = hum.MoveDirection
        local targetVel = moveDir * 50

        -- Up/Down
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
-- ================= Fly Feature (追加用) =================
Settings.Fly = false
local isJumping = false
local isDownPressed = false

-- 画面の右側に「下降ボタン」を追加（ゲームUIと被らない位置）
local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 50, 0, 50)
downBtn.Position = UDim2.new(1, -80, 0.5, -25)
downBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
downBtn.BackgroundTransparency = 0.5
downBtn.Text = "v"
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.TextSize = 30
downBtn.Font = Enum.Font.SourceSansBold
downBtn.Visible = false
downBtn.Parent = ScreenGui
local downCorner = Instance.new("UICorner", downBtn)
downCorner.CornerRadius = UDim.new(1, 0)

-- キャラタブにフライボタンを追加
local flyBtn = createBtn(Pages.Char, "Fly: OFF", 260, 95, Color3.fromRGB(200, 50, 50), 110)
flyBtn.MouseButton1Click:Connect(function()
    Settings.Fly = not Settings.Fly
    flyBtn.Text = "Fly: " .. (Settings.Fly and "ON" or "OFF")
    flyBtn.BackgroundColor3 = Settings.Fly and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    downBtn.Visible = Settings.Fly
end)

-- 入力検知
UserInputService.JumpRequest:Connect(function()
    if Settings.Fly then
        isJumping = true
        task.delay(0.1, function() isJumping = false end)
    end
end)
downBtn.MouseButton1Down:Connect(function() isDownPressed = true end)
downBtn.MouseButton1Up:Connect(function() isDownPressed = false end)
downBtn.MouseLeave:Connect(function() isDownPressed = false end)

-- フライ処理（毎フレーム実行）
local flyVelocity = nil
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
        local targetVel = moveDir * 50

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
-- ================= Fly Feature 最終修正 =================
if flyVelocity then flyVelocity:Destroy() end
if downBtn then downBtn:Destroy() end

local oldFlySpeed = Settings.FlySpeed or 50
local oldFlyHeightSpeed = Settings.FlyHeightSpeed or 50

Settings.Fly = false
Settings.FlySpeed = oldFlySpeed
Settings.FlyHeightSpeed = oldFlyHeightSpeed

-- 下降ボタン
local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 50, 0, 50)
downBtn.Position = UDim2.new(1, -80, 0.5, -25)
downBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
downBtn.BackgroundTransparency = 0.5
downBtn.Text = "v"
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.TextSize = 30
downBtn.Font = Enum.Font.SourceSansBold
downBtn.Visible = false
downBtn.Parent = ScreenGui
local downCorner = Instance.new("UICorner", downBtn)
downCorner.CornerRadius = UDim.new(1, 0)

-- フライON/OFFボタン
local flyBtn = createBtn(Pages.Char, "Fly: OFF", 260, 95, Color3.fromRGB(200, 50, 50), 110)
flyBtn.MouseButton1Click:Connect(function()
    Settings.Fly = not Settings.Fly
    flyBtn.Text = "Fly: " .. (Settings.Fly and "ON" or "OFF")
    flyBtn.BackgroundColor3 = Settings.Fly and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    downBtn.Visible = Settings.Fly
end)

-- フライ速度（横移動）調整
local flyCtrl = Instance.new("Frame")
flyCtrl.Size = UDim2.new(0, 170, 0, 35)
flyCtrl.Position = UDim2.new(0, 120, 0, 50)
flyCtrl.BackgroundTransparency = 1
flyCtrl.Parent = Pages.Char

local flyMinusBtn = Instance.new("TextButton")
flyMinusBtn.Size = UDim2.new(0, 35, 1, 0)
flyMinusBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
flyMinusBtn.Text = "-"
flyMinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyMinusBtn.Font = Enum.Font.SourceSansBold
flyMinusBtn.Parent = flyCtrl

local flyText = Instance.new("TextLabel")
flyText.Size = UDim2.new(0, 100, 1, 0)
flyText.Position = UDim2.new(0, 35, 0, 0)
flyText.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
flyText.Text = "Fly Speed: " .. Settings.FlySpeed
flyText.TextColor3 = Color3.fromRGB(255, 255, 255)
flyText.Font = Enum.Font.SourceSansBold
flyText.TextSize = 14
flyText.Parent = flyCtrl

local flyPlusBtn = Instance.new("TextButton")
flyPlusBtn.Size = UDim2.new(0, 35, 1, 0)
flyPlusBtn.Position = UDim2.new(0, 135, 0, 0)
flyPlusBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
flyPlusBtn.Text = "+"
flyPlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyPlusBtn.Font = Enum.Font.SourceSansBold
flyPlusBtn.Parent = flyCtrl

flyMinusBtn.MouseButton1Click:Connect(function()
    Settings.FlySpeed = math.max(10, Settings.FlySpeed - 10)
    flyText.Text = "Fly Speed: " .. Settings.FlySpeed
end)
flyPlusBtn.MouseButton1Click:Connect(function()
    Settings.FlySpeed = math.min(500, Settings.FlySpeed + 10)
    flyText.Text = "Fly Speed: " .. Settings.FlySpeed
end)

-- フライ高さ（上下移動）調整
local flyHeightCtrl = Instance.new("Frame")
flyHeightCtrl.Size = UDim2.new(0, 170, 0, 35)
flyHeightCtrl.Position = UDim2.new(0, 120, 0, 95)
flyHeightCtrl.BackgroundTransparency = 1
flyHeightCtrl.Parent = Pages.Char

local flyHeightMinusBtn = Instance.new("TextButton")
flyHeightMinusBtn.Size = UDim2.new(0, 35, 1, 0)
flyHeightMinusBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
flyHeightMinusBtn.Text = "-"
flyHeightMinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyHeightMinusBtn.Font = Enum.Font.SourceSansBold
flyHeightMinusBtn.Parent = flyHeightCtrl

local flyHeightText = Instance.new("TextLabel")
flyHeightText.Size = UDim2.new(0, 100, 1, 0)
flyHeightText.Position = UDim2.new(0, 35, 0, 0)
flyHeightText.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
flyHeightText.Text = "Fly Height: " .. Settings.FlyHeightSpeed
flyHeightText.TextColor3 = Color3.fromRGB(255, 255, 255)
flyHeightText.Font = Enum.Font.SourceSansBold
flyHeightText.TextSize = 14
flyHeightText.Parent = flyHeightCtrl

local flyHeightPlusBtn = Instance.new("TextButton")
flyHeightPlusBtn.Size = UDim2.new(0, 35, 1, 0)
flyHeightPlusBtn.Position = UDim2.new(0, 135, 0, 0)
flyHeightPlusBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
flyHeightPlusBtn.Text = "+"
flyHeightPlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyHeightPlusBtn.Font = Enum.Font.SourceSansBold
flyHeightPlusBtn.Parent = flyHeightCtrl

flyHeightMinusBtn.MouseButton1Click:Connect(function()
    Settings.FlyHeightSpeed = math.max(10, Settings.FlyHeightSpeed - 10)
    flyHeightText.Text = "Fly Height: " .. Settings.FlyHeightSpeed
end)
flyHeightPlusBtn.MouseButton1Click:Connect(function()
    Settings.FlyHeightSpeed = math.min(500, Settings.FlyHeightSpeed + 10)
    flyHeightText.Text = "Fly Height: " .. Settings.FlyHeightSpeed
end)

-- 入力検知
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

-- フライ処理
local flyVelocity = nil
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
        
        if isJumping or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            targetVel = targetVel + Vector3.new(0, Settings.FlyHeightSpeed, 0)
        elseif isDownPressed or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            targetVel = targetVel - Vector3.new(0, Settings.FlyHeightSpeed, 0)
        end

        flyVelocity.Velocity = targetVel
    else
        if hum.PlatformStand then hum.PlatformStand = false end
        if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
    end
end)
-- ================= 最終修正：フライ機能とヘッダー情報 =================
if flyVelocity then flyVelocity:Destroy() end
if downBtn then downBtn:Destroy() end
if flyCtrl then flyCtrl:Destroy() end
if flyHeightCtrl then flyHeightCtrl:Destroy() end
if flyBtn then flyBtn:Destroy() end

Settings.Fly = false
Settings.FlySpeed = 50
Settings.FlyHeight = 50

-- フライON/OFFボタン
local flyBtn = createBtn(Pages.Char, "Fly: OFF", 130, 95, Color3.fromRGB(200, 50, 50), 110)
flyBtn.MouseButton1Click:Connect(function()
    Settings.Fly = not Settings.Fly
    flyBtn.Text = "Fly: " .. (Settings.Fly and "ON" or "OFF")
    flyBtn.BackgroundColor3 = Settings.Fly and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

-- フライ速度（横移動）調整
local flySpeedCtrl = Instance.new("Frame")
flySpeedCtrl.Size = UDim2.new(0, 170, 0, 35)
flySpeedCtrl.Position = UDim2.new(0, 130, 0, 50)
flySpeedCtrl.BackgroundTransparency = 1
flySpeedCtrl.Parent = Pages.Char

local flySpeedMinus = Instance.new("TextButton")
flySpeedMinus.Size = UDim2.new(0, 35, 1, 0)
flySpeedMinus.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
flySpeedMinus.Text = "-"
flySpeedMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedMinus.Font = Enum.Font.SourceSansBold
flySpeedMinus.Parent = flySpeedCtrl

local flySpeedText = Instance.new("TextLabel")
flySpeedText.Size = UDim2.new(0, 100, 1, 0)
flySpeedText.Position = UDim2.new(0, 35, 0, 0)
flySpeedText.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
flySpeedText.Text = "Fly Speed: 50"
flySpeedText.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedText.Font = Enum.Font.SourceSansBold
flySpeedText.TextSize = 14
flySpeedText.Parent = flySpeedCtrl

local flySpeedPlus = Instance.new("TextButton")
flySpeedPlus.Size = UDim2.new(0, 35, 1, 0)
flySpeedPlus.Position = UDim2.new(0, 135, 0, 0)
flySpeedPlus.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
flySpeedPlus.Text = "+"
flySpeedPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedPlus.Font = Enum.Font.SourceSansBold
flySpeedPlus.Parent = flySpeedCtrl

flySpeedMinus.MouseButton1Click:Connect(function()
    Settings.FlySpeed = math.max(10, Settings.FlySpeed - 10)
    flySpeedText.Text = "Fly Speed: " .. Settings.FlySpeed
end)
flySpeedPlus.MouseButton1Click:Connect(function()
    Settings.FlySpeed = math.min(500, Settings.FlySpeed + 10)
    flySpeedText.Text = "Fly Speed: " .. Settings.FlySpeed
end)

-- フライ高さ（上昇・下降）調整
local flyHeightCtrl = Instance.new("Frame")
flyHeightCtrl.Size = UDim2.new(0, 170, 0, 35)
flyHeightCtrl.Position = UDim2.new(0, 130, 0, 95)
flyHeightCtrl.BackgroundTransparency = 1
flyHeightCtrl.Parent = Pages.Char

local flyHeightMinus = Instance.new("TextButton")
flyHeightMinus.Size = UDim2.new(0, 35, 1, 0)
flyHeightMinus.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
flyHeightMinus.Text = "-"
flyHeightMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
flyHeightMinus.Font = Enum.Font.SourceSansBold
flyHeightMinus.Parent = flyHeightCtrl

local flyHeightText = Instance.new("TextLabel")
flyHeightText.Size = UDim2.new(0, 100, 1, 0)
flyHeightText.Position = UDim2.new(0, 35, 0, 0)
flyHeightText.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
flyHeightText.Text = "Fly Height: 50"
flyHeightText.TextColor3 = Color3.fromRGB(255, 255, 255)
flyHeightText.Font = Enum.Font.SourceSansBold
flyHeightText.TextSize = 14
flyHeightText.Parent = flyHeightCtrl

local flyHeightPlus = Instance.new("TextButton")
flyHeightPlus.Size = UDim2.new(0, 35, 1, 0)
flyHeightPlus.Position = UDim2.new(0, 135, 0, 0)
flyHeightPlus.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
flyHeightPlus.Text = "+"
flyHeightPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
flyHeightPlus.Font = Enum.Font.SourceSansBold
flyHeightPlus.Parent = flyHeightCtrl

flyHeightMinus.MouseButton1Click:Connect(function()
    Settings.FlyHeight = math.max(10, Settings.FlyHeight - 10)
    flyHeightText.Text = "Fly Height: " .. Settings.FlyHeight
end)
flyHeightPlus.MouseButton1Click:Connect(function()
    Settings.FlyHeight = math.min(500, Settings.FlyHeight + 10)
    flyHeightText.Text = "Fly Height: " .. Settings.FlyHeight
end)

-- フライ処理（PC: スペース/Shift、スマホ: 画面右側をタッチ/ジャンプボタン）
local flyVelocity = nil
local isJumping = false
local isScreenTouched = false

UserInputService.JumpRequest:Connect(function()
    if Settings.Fly then
        isJumping = true
        task.delay(0.1, function() isJumping = false end)
    end
end)

-- 画面右側をタッチで上昇、画面左側をタッチで下降する処理（スマホ用）
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if Settings.Fly and input.UserInputType == Enum.UserInputType.Touch then
        isScreenTouched = true
    end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Touch then
        isScreenTouched = false
    end
end)

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
        
        -- 上昇判定
        if isJumping or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            targetVel = targetVel + Vector3.new(0, Settings.FlyHeight, 0)
        -- 下降判定
        elseif isScreenTouched or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            targetVel = targetVel - Vector3.new(0, Settings.FlyHeight, 0)
        end

        flyVelocity.Velocity = targetVel
    else
        if hum.PlatformStand then hum.PlatformStand = false end
        if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
    end
end)

-- ================= ヘッダー情報（時刻・FPS・Ping） =================
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 200, 0, 30)
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
    
    local osTime = os.date("%H:%M:%S")
    local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
    infoLabel.Text = osTime .. " | " .. fps .. " FPS | " .. ping .. " ms"
end)
-- ================= Fly Feature & Header Info =================
if flyVelocity then flyVelocity:Destroy() end
if downBtn then downBtn:Destroy() end
if flySpeedCtrl then flySpeedCtrl:Destroy() end
if flyHeightCtrl then flyHeightCtrl:Destroy() end
if flyBtn then flyBtn:Destroy() end

Settings.Fly = false
Settings.FlySpeed = 50
Settings.FlyHeight = 50

-- Fly Toggle Button
local flyBtn = createBtn(Pages.Char, "Fly: OFF", 130, 95, Color3.fromRGB(200, 50, 50), 110)
flyBtn.MouseButton1Click:Connect(function()
    Settings.Fly = not Settings.Fly
    flyBtn.Text = "Fly: " .. (Settings.Fly and "ON" or "OFF")
    flyBtn.BackgroundColor3 = Settings.Fly and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

-- Fly Speed Control
local flySpeedCtrl = Instance.new("Frame")
flySpeedCtrl.Size = UDim2.new(0, 170, 0, 35)
flySpeedCtrl.Position = UDim2.new(0, 130, 0, 50)
flySpeedCtrl.BackgroundTransparency = 1
flySpeedCtrl.Parent = Pages.Char

local flySpeedMinus = Instance.new("TextButton")
flySpeedMinus.Size = UDim2.new(0, 35, 1, 0)
flySpeedMinus.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
flySpeedMinus.Text = "-"
flySpeedMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedMinus.Font = Enum.Font.SourceSansBold
flySpeedMinus.Parent = flySpeedCtrl

local flySpeedText = Instance.new("TextLabel")
flySpeedText.Size = UDim2.new(0, 100, 1, 0)
flySpeedText.Position = UDim2.new(0, 35, 0, 0)
flySpeedText.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
flySpeedText.Text = "Fly Speed: 50"
flySpeedText.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedText.Font = Enum.Font.SourceSansBold
flySpeedText.TextSize = 14
flySpeedText.Parent = flySpeedCtrl

local flySpeedPlus = Instance.new("TextButton")
flySpeedPlus.Size = UDim2.new(0, 35, 1, 0)
flySpeedPlus.Position = UDim2.new(0, 135, 0, 0)
flySpeedPlus.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
flySpeedPlus.Text = "+"
flySpeedPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedPlus.Font = Enum.Font.SourceSansBold
flySpeedPlus.Parent = flySpeedCtrl

flySpeedMinus.MouseButton1Click:Connect(function()
    Settings.FlySpeed = math.max(10, Settings.FlySpeed - 10)
    flySpeedText.Text = "Fly Speed: " .. Settings.FlySpeed
end)
flySpeedPlus.MouseButton1Click:Connect(function()
    Settings.FlySpeed = math.min(500, Settings.FlySpeed + 10)
    flySpeedText.Text = "Fly Speed: " .. Settings.FlySpeed
end)

-- Fly Height Control
local flyHeightCtrl = Instance.new("Frame")
flyHeightCtrl.Size = UDim2.new(0, 170, 0, 35)
flyHeightCtrl.Position = UDim2.new(0, 130, 0, 95)
flyHeightCtrl.BackgroundTransparency = 1
flyHeightCtrl.Parent = Pages.Char

local flyHeightMinus = Instance.new("TextButton")
flyHeightMinus.Size = UDim2.new(0, 35, 1, 0)
flyHeightMinus.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
flyHeightMinus.Text = "-"
flyHeightMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
flyHeightMinus.Font = Enum.Font.SourceSansBold
flyHeightMinus.Parent = flyHeightCtrl

local flyHeightText = Instance.new("TextLabel")
flyHeightText.Size = UDim2.new(0, 100, 1, 0)
flyHeightText.Position = UDim2.new(0, 35, 0, 0)
flyHeightText.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
flyHeightText.Text = "Height: 50"
flyHeightText.TextColor3 = Color3.fromRGB(255, 255, 255)
flyHeightText.Font = Enum.Font.SourceSansBold
flyHeightText.TextSize = 14
flyHeightText.Parent = flyHeightCtrl

local flyHeightPlus = Instance.new("TextButton")
flyHeightPlus.Size = UDim2.new(0, 35, 1, 0)
flyHeightPlus.Position = UDim2.new(0, 135, 0, 0)
flyHeightPlus.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
flyHeightPlus.Text = "+"
flyHeightPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
flyHeightPlus.Font = Enum.Font.SourceSansBold
flyHeightPlus.Parent = flyHeightCtrl

flyHeightMinus.MouseButton1Click:Connect(function()
    Settings.FlyHeight = math.max(10, Settings.FlyHeight - 10)
    flyHeightText.Text = "Height: " .. Settings.FlyHeight
end)
flyHeightPlus.MouseButton1Click:Connect(function()
    Settings.FlyHeight = math.min(500, Settings.FlyHeight + 10)
    flyHeightText.Text = "Height: " .. Settings.FlyHeight
end)

-- Fly Logic
local flyVelocity = nil
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
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            targetVel = targetVel + Vector3.new(0, Settings.FlyHeight, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            targetVel = targetVel - Vector3.new(0, Settings.FlyHeight, 0)
        end

        flyVelocity.Velocity = targetVel
    else
        if hum.PlatformStand then hum.PlatformStand = false end
        if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
    end
end)

-- ================= Header Info (Time, FPS, Ping) =================
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 200, 0, 30)
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
    
    local osTime = os.date("%H:%M:%S")
    local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
    infoLabel.Text = osTime .. " | " .. fps .. " FPS | " .. ping .. " ms"
end)
-- ================= Fly Feature (Fixed & Mobile Support) =================
if flyVelocity then flyVelocity:Destroy() end
if downBtn then downBtn:Destroy() end
if flySpeedCtrl then flySpeedCtrl:Destroy() end
if flyHeightCtrl then flyHeightCtrl:Destroy() end
if flyBtn then flyBtn:Destroy() end

Settings.Fly = false
Settings.FlySpeed = 50
Settings.FlyHeight = 50

-- Fly Toggle Button
local flyBtn = createBtn(Pages.Char, "Fly: OFF", 130, 95, Color3.fromRGB(200, 50, 50), 110)
flyBtn.MouseButton1Click:Connect(function()
    Settings.Fly = not Settings.Fly
    flyBtn.Text = "Fly: " .. (Settings.Fly and "ON" or "OFF")
    flyBtn.BackgroundColor3 = Settings.Fly and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

-- Fly Speed Control (Horizontal)
local flySpeedCtrl = Instance.new("Frame")
flySpeedCtrl.Size = UDim2.new(0, 170, 0, 35)
flySpeedCtrl.Position = UDim2.new(0, 130, 0, 50)
flySpeedCtrl.BackgroundTransparency = 1
flySpeedCtrl.Parent = Pages.Char

local flySpeedMinus = Instance.new("TextButton")
flySpeedMinus.Size = UDim2.new(0, 35, 1, 0)
flySpeedMinus.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
flySpeedMinus.Text = "-"
flySpeedMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedMinus.Font = Enum.Font.SourceSansBold
flySpeedMinus.Parent = flySpeedCtrl

local flySpeedText = Instance.new("TextLabel")
flySpeedText.Size = UDim2.new(0, 100, 1, 0)
flySpeedText.Position = UDim2.new(0, 35, 0, 0)
flySpeedText.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
flySpeedText.Text = "Speed: 50"
flySpeedText.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedText.Font = Enum.Font.SourceSansBold
flySpeedText.TextSize = 14
flySpeedText.Parent = flySpeedCtrl

local flySpeedPlus = Instance.new("TextButton")
flySpeedPlus.Size = UDim2.new(0, 35, 1, 0)
flySpeedPlus.Position = UDim2.new(0, 135, 0, 0)
flySpeedPlus.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
flySpeedPlus.Text = "+"
flySpeedPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedPlus.Font = Enum.Font.SourceSansBold
flySpeedPlus.Parent = flySpeedCtrl

flySpeedMinus.MouseButton1Click:Connect(function()
    Settings.FlySpeed = math.max(10, Settings.FlySpeed - 10)
    flySpeedText.Text = "Speed: " .. Settings.FlySpeed
end)
flySpeedPlus.MouseButton1Click:Connect(function()
    Settings.FlySpeed = math.min(500, Settings.FlySpeed + 10)
    flySpeedText.Text = "Speed: " .. Settings.FlySpeed
end)

-- Fly Height Control (Vertical)
local flyHeightCtrl = Instance.new("Frame")
flyHeightCtrl.Size = UDim2.new(0, 170, 0, 35)
flyHeightCtrl.Position = UDim2.new(0, 130, 0, 95)
flyHeightCtrl.BackgroundTransparency = 1
flyHeightCtrl.Parent = Pages.Char

local flyHeightMinus = Instance.new("TextButton")
flyHeightMinus.Size = UDim2.new(0, 35, 1, 0)
flyHeightMinus.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
flyHeightMinus.Text = "-"
flyHeightMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
flyHeightMinus.Font = Enum.Font.SourceSansBold
flyHeightMinus.Parent = flyHeightCtrl

local flyHeightText = Instance.new("TextLabel")
flyHeightText.Size = UDim2.new(0, 100, 1, 0)
flyHeightText.Position = UDim2.new(0, 35, 0, 0)
flyHeightText.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
flyHeightText.Text = "Height: 50"
flyHeightText.TextColor3 = Color3.fromRGB(255, 255, 255)
flyHeightText.Font = Enum.Font.SourceSansBold
flyHeightText.TextSize = 14
flyHeightText.Parent = flyHeightCtrl

local flyHeightPlus = Instance.new("TextButton")
flyHeightPlus.Size = UDim2.new(0, 35, 1, 0)
flyHeightPlus.Position = UDim2.new(0, 135, 0, 0)
flyHeightPlus.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
flyHeightPlus.Text = "+"
flyHeightPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
flyHeightPlus.Font = Enum.Font.SourceSansBold
flyHeightPlus.Parent = flyHeightCtrl

flyHeightMinus.MouseButton1Click:Connect(function()
    Settings.FlyHeight = math.max(10, Settings.FlyHeight - 10)
    flyHeightText.Text = "Height: " .. Settings.FlyHeight
end)
flyHeightPlus.MouseButton1Click:Connect(function()
    Settings.FlyHeight = math.min(500, Settings.FlyHeight + 10)
    flyHeightText.Text = "Height: " .. Settings.FlyHeight
end)

-- Fly Logic & Inputs
local flyVelocity = nil
local isJumping = false
local isCrouching = false

UserInputService.JumpRequest:Connect(function()
    if Settings.Fly then
        isJumping = true
        task.delay(0.1, function() isJumping = false end)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL2 then
        isCrouching = true
    end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL2 then
        isCrouching = false
    end
end)

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
        
        if isJumping or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            targetVel = targetVel + Vector3.new(0, Settings.FlyHeight, 0)
        elseif isCrouching or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            targetVel = targetVel - Vector3.new(0, Settings.FlyHeight, 0)
        end

        flyVelocity.Velocity = targetVel
    else
        if hum.PlatformStand then hum.PlatformStand = false end
        if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
    end
end)

-- Header Info
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 200, 0, 30)
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
    
    local osTime = os.date("%H:%M:%S")
    local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
    infoLabel.Text = osTime .. " | " .. fps .. " FPS | " .. ping .. " ms"
end)
