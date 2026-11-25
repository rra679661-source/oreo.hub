local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= 設定 =================
local Settings = {
    ESP = false, ESP_Name = false, ESP_Health = false, ESP_Distance = false,
    SpeedHack = false, SpeedValue = 16, InfJump = false, Noclip = false,
    Fly = false, FlySpeed = 50, FPSBoost = false,
    AntiAFK = false, AntiLag = false, AntiFling = false, AntiTP = false,
    Aimbot = false, AimFOV = 150
}

-- ================= UI ベース =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OreoHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Size = UDim2.new(0, 80, 0, 35)
ToggleMenuBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleMenuBtn.Text = "Oreo.hub"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleMenuBtn.Font = Enum.Font.SourceSansBold
ToggleMenuBtn.TextSize = 14
ToggleMenuBtn.Parent = ScreenGui

-- メインフレーム（高さを少し抑えてスマホでも収まるように）
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 280)
Frame.Position = UDim2.new(0.5, -160, 0.5, -140)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Visible = false
Frame.Parent = ScreenGui

-- ヘッダー
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Header.Parent = Frame

local TitleLeft = Instance.new("TextLabel")
TitleLeft.Size = UDim2.new(0.5, 0, 1, 0)
TitleLeft.Position = UDim2.new(0, 10, 0, 0)
TitleLeft.BackgroundTransparency = 1
TitleLeft.Text = "Oreo.hub"
TitleLeft.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLeft.Font = Enum.Font.SourceSansBold
TitleLeft.TextSize = 14
TitleLeft.TextXAlignment = Enum.TextXAlignment.Left
TitleLeft.Parent = Header

local TitleRight = Instance.new("TextLabel")
TitleRight.Size = UDim2.new(0.5, 0, 1, 0)
TitleRight.Position = UDim2.new(0.5, -10, 0, 0)
TitleRight.BackgroundTransparency = 1
TitleRight.Text = "Loading..."
TitleRight.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleRight.Font = Enum.Font.SourceSansBold
TitleRight.TextSize = 11
TitleRight.TextXAlignment = Enum.TextXAlignment.Right
TitleRight.Parent = Header

local frames = 0
local lastTime = tick()
local fps = 60
RunService.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastTime >= 1 then
        fps = frames
        frames = 0
        lastTime = tick()
    end
    local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
    TitleRight.Text = os.date("%m/%d %H:%M:%S") .. " | " .. fps .. " FPS | " .. ping .. "ms"
end)

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

ToggleMenuBtn.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
    if Frame.Visible then Frame.Position = UDim2.new(0.5, -160, 0.5, -140) end
end)

-- タブ
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
    tab.TextSize = 12
    tab.Parent = TabContainer
    return tab
end

local espTabBtn = createTab("ESP", 0, 64)
local charTabBtn = createTab("キャラ", 64, 64)
local setTabBtn = createTab("設定", 128, 64)
local aimTabBtn = createTab("エイム", 192, 64)
local secTabBtn = createTab("守り", 256, 64)

-- スクロール可能なコンテンツエリア
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -10, 1, -65)
Content.Position = UDim2.new(0, 5, 0, 60)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 4
Content.CanvasSize = UDim2.new(0, 0, 0, 250) -- 縦に長く設定
Content.Parent = Frame

local Pages = { ESP = Instance.new("Frame"), Char = Instance.new("Frame"), Settings = Instance.new("Frame"), Aim = Instance.new("Frame"), Security = Instance.new("Frame") }
for _, page in pairs(Pages) do
    page.Size = UDim2.new(1, -5, 0, 250)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = Content
end
Pages.ESP.Visible = true

local function switchTab(activePage, activeBtn)
    for _, page in pairs(Pages) do page.Visible = false end
    activePage.Visible = true
    for _, btn in pairs({espTabBtn, charTabBtn, setTabBtn, aimTabBtn, secTabBtn}) do
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    activeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

espTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.ESP, espTabBtn) end)
charTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Char, charTabBtn) end)
setTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Settings, setTabBtn) end)
aimTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Aim, aimTabBtn) end)
secTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Security, secTabBtn) end)

local function createBtn(parent, text, posX, posY, color, sizeX)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, sizeX or 150, 0, 30)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = parent
    return btn
end

local function toggle(settingKey, btn, label)
    Settings[settingKey] = not Settings[settingKey]
    btn.Text = label .. ": " .. (Settings[settingKey] and "ON" or "OFF")
    btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end

-- ESPタブ
local espMasterBtn = createBtn(Pages.ESP, "ESP: OFF", 0, 5, Color3.fromRGB(200, 50, 50))
local espNameBtn = createBtn(Pages.ESP, "Name: OFF", 155, 5, Color3.fromRGB(200, 50, 50))
local espHpBtn = createBtn(Pages.ESP, "Health: OFF", 0, 45, Color3.fromRGB(200, 50, 50))
local espDistBtn = createBtn(Pages.ESP, "Distance: OFF", 155, 45, Color3.fromRGB(200, 50, 50))

espMasterBtn.MouseButton1Click:Connect(function() toggle("ESP", espMasterBtn, "ESP") end)
espNameBtn.MouseButton1Click:Connect(function() toggle("ESP_Name", espNameBtn, "Name") end)
espHpBtn.MouseButton1Click:Connect(function() toggle("ESP_Health", espHpBtn, "Health") end)
espDistBtn.MouseButton1Click:Connect(function() toggle("ESP_Distance", espDistBtn, "Distance") end)

-- キャラクタータブ
local infJumpBtn = createBtn(Pages.Char, "Inf Jump: OFF", 0, 5, Color3.fromRGB(200, 50, 50))
local noclipBtn = createBtn(Pages.Char, "Noclip: OFF", 155, 5, Color3.fromRGB(200, 50, 50))
local flyBtn = createBtn(Pages.Char, "Fly: OFF", 0, 45, Color3.fromRGB(200, 50, 50))

infJumpBtn.MouseButton1Click:Connect(function() toggle("InfJump", infJumpBtn, "Inf Jump") end)
noclipBtn.MouseButton1Click:Connect(function() toggle("Noclip", noclipBtn, "Noclip") end)
flyBtn.MouseButton1Click:Connect(function() toggle("Fly", flyBtn, "Fly") end)

-- スピード
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 150, 0, 20)
speedLabel.Position = UDim2.new(0, 0, 0, 85)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 16"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.SourceSansBold
speedLabel.TextSize = 14
speedLabel.Parent = Pages.Char

local minusBtn = createBtn(Pages.Char, "-", 0, 110, Color3.fromRGB(200, 50, 50), 40)
local speedToggleBtn = createBtn(Pages.Char, "Speed: OFF", 45, 110, Color3.fromRGB(200, 50, 50), 100)
local plusBtn = createBtn(Pages.Char, "+", 150, 110, Color3.fromRGB(50, 200, 50), 40)

speedToggleBtn.MouseButton1Click:Connect(function() toggle("SpeedHack", speedToggleBtn, "Speed") end)
minusBtn.MouseButton1Click:Connect(function() Settings.SpeedValue = math.max(16, Settings.SpeedValue - 10); speedLabel.Text = "Speed: " .. Settings.SpeedValue end)
plusBtn.MouseButton1Click:Connect(function() Settings.SpeedValue = math.min(300, Settings.SpeedValue + 10); speedLabel.Text = "Speed: " .. Settings.SpeedValue end)

-- フライ設定
local flyLabel = Instance.new("TextLabel")
flyLabel.Size = UDim2.new(0, 150, 0, 20)
flyLabel.Position = UDim2.new(0, 0, 0, 150)
flyLabel.BackgroundTransparency = 1
flyLabel.Text = "Fly Speed: 50"
flyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
flyLabel.Font = Enum.Font.SourceSansBold
flyLabel.TextSize = 14
flyLabel.Parent = Pages.Char

local flyMinusBtn = createBtn(Pages.Char, "-", 0, 175, Color3.fromRGB(200, 50, 50), 40)
local flyPlusBtn = createBtn(Pages.Char, "+", 150, 175, Color3.fromRGB(50, 200, 50), 40)

flyMinusBtn.MouseButton1Click:Connect(function() Settings.FlySpeed = math.max(10, Settings.FlySpeed - 10); flyLabel.Text = "Fly Speed: " .. Settings.FlySpeed end)
flyPlusBtn.MouseButton1Click:Connect(function() Settings.FlySpeed = math.min(200, Settings.FlySpeed + 10); flyLabel.Text = "Fly Speed: " .. Settings.FlySpeed end)

-- 上昇・下降
local upBtn = createBtn(Pages.Char, "上昇", 45, 175, Color3.fromRGB(50, 150, 200), 45)
local downBtn = createBtn(Pages.Char, "下降", 95, 175, Color3.fromRGB(200, 100, 50), 45)

local isFlyingUp = false
local isFlyingDown = false
upBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isFlyingUp = true end end)
upBtn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isFlyingUp = false end end)
downBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isFlyingDown = true end end)
downBtn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isFlyingDown = false end end)

-- 設定タブ
local fpsBoostBtn = createBtn(Pages.Settings, "FPS Boost: OFF", 0, 5, Color3.fromRGB(200, 50, 50), 305)
fpsBoostBtn.MouseButton1Click:Connect(function() toggle("FPSBoost", fpsBoostBtn, "FPS Boost") end)

-- エイムタブ
local aimbotBtn = createBtn(Pages.Aim, "Aimbot: OFF", 0, 5, Color3.fromRGB(200, 50, 50), 305)
aimbotBtn.MouseButton1Click:Connect(function() toggle("Aimbot", aimbotBtn, "Aimbot") end)

-- 守りタブ
local antiAfkBtn = createBtn(Pages.Security, "Anti AFK: OFF", 0, 5, Color3.fromRGB(200, 50, 50))
local antiLagBtn = createBtn(Pages.Security, "Anti Lag: OFF", 155, 5, Color3.fromRGB(200, 50, 50))
local antiFlingBtn = createBtn(Pages.Security, "Anti Fling: OFF", 0, 45, Color3.fromRGB(200, 50, 50))
local antiTpBtn = createBtn(Pages.Security, "Anti TP: OFF", 155, 45, Color3.fromRGB(200, 50, 50))

antiAfkBtn.MouseButton1Click:Connect(function() toggle("AntiAFK", antiAfkBtn, "Anti AFK") end)
antiLagBtn.MouseButton1Click:Connect(function() toggle("AntiLag", antiLagBtn, "Anti Lag") end)
antiFlingBtn.MouseButton1Click:Connect(function() toggle("AntiFling", antiFlingBtn, "Anti Fling") end)
antiTpBtn.MouseButton1Click:Connect(function() toggle("AntiTP", antiTpBtn, "Anti TP") end)

-- ================= 処理群 =================
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if hum and hrp then
        if Settings.SpeedHack then
            hum.WalkSpeed = Settings.SpeedValue
            if hum.MoveDirection.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * Settings.SpeedValue, hrp.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * Settings.SpeedValue)
            end
        else
            hum.WalkSpeed = 16
        end

        if Settings.Fly then
            hum.PlatformStand = true
            if not hrp:FindFirstChild("FlyVelocity") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "FlyVelocity"
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bv.Velocity = Vector3.zero
                bv.Parent = hrp
            end
            local bv = hrp:FindFirstChild("FlyVelocity")
            if bv then
                local targetVel = hum.MoveDirection * Settings.FlySpeed
                if isFlyingUp or UserInputService:IsKeyDown(Enum.KeyCode.Space) then targetVel = targetVel + Vector3.new(0, Settings.FlySpeed, 0) 
                elseif isFlyingDown or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then targetVel = targetVel - Vector3.new(0, Settings.FlySpeed, 0) end
                bv.Velocity = targetVel
            end
        else
            if hum.PlatformStand then hum.PlatformStand = false end
            if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
        end
    end

    if Settings.Noclip then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local isShooting = false
UserInputService.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isShooting = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isShooting = false end end)

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and isShooting then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local closestHead = nil
        local shortestDist = Settings.AimFOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    if LocalPlayer.Team == nil or p.Team ~= LocalPlayer.Team then
                        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local dist = (center - Vector2.new(pos.X, pos.Y)).Magnitude
                            if dist < shortestDist then shortestDist = dist; closestHead = head end
                        end
                    end
                end
            end
        end
        if closestHead then Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, closestHead.Position), 0.5) end
    end
end)

LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

local lastPos = nil
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if Settings.AntiTP then
        if not lastPos then lastPos = hrp.Position
        else
            local dist = (hrp.Position - lastPos).Magnitude
            if dist > 30 then hrp.CFrame = CFrame.new(lastPos); hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) else lastPos = hrp.Position end
        end
    else lastPos = nil end
    if Settings.AntiFling and hrp.AssemblyAngularVelocity.Magnitude > 50 then hrp.AssemblyAngularVelocity = Vector3.new(0,0,0) end
end)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "OreoESP"
ESPFolder.Parent = game:GetService("CoreGui")

local function IsTeammate(player) if LocalPlayer.Team == nil then return false end; return player.Team == LocalPlayer.Team end

local function CreateESP(player)
    if player == LocalPlayer or IsTeammate(player) then return end
    local function onChar(char)
        local head = char:WaitForChild("Head", 5)
        if not head then return end
        if ESPFolder:FindFirstChild(player.Name) then ESPFolder[player.Name]:Destroy() end
        local bg = Instance.new("BillboardGui"); bg.Name = player.Name; bg.Adornee = head; bg.Size = UDim2.new(0, 200, 0, 50); bg.StudsOffset = Vector3.new(0, 2.5, 0); bg.AlwaysOnTop = true; bg.Parent = ESPFolder
        local text = Instance.new("TextLabel"); text.Size = UDim2.new(1, 0, 1, 0); text.BackgroundTransparency = 1; text.TextColor3 = Color3.fromRGB(255, 255, 255); text.Font = Enum.Font.SourceSansBold; text.TextSize = 14; text.TextStrokeTransparency = 0; text.RichText = true; text.Parent = bg
        task.spawn(function()
            while bg.Parent do
                if Settings.ESP and char.Parent and char:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude)
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local display = ""
                    if Settings.ESP_Name then display = display .. player.Name .. "\n" end
                    if Settings.ESP_Health and hum then display = display .. "<font color='#32CD32'>HP: " .. math.floor(hum.Health) .. "</font>\n" end
                    if Settings.ESP_Distance then display = display .. "<font color='#32CD32'>[" .. dist .. "m]</font>" end
                    text.Text = display; bg.Enabled = true
                else bg.Enabled = false end
                task.wait(0.2)
            end
        end)
    end
    if player.Character then onChar(player.Character) end
    player.CharacterAdded:Connect(onChar)
end
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
-- ================= Rapid Fire (2x) =================
local rapidFireEnabled = false

-- 既存のエイムタブを探す
local aimPage = Pages and Pages.Aim
if aimPage then
    -- 既存のRapid Fireボタンがあれば消す
    for _, v in pairs(aimPage:GetChildren()) do
        if v:IsA("TextButton") and string.find(v.Text, "Rapid Fire") then
            v:Destroy()
        end
    end

    -- ボタン作成
    local rapidBtn = Instance.new("TextButton")
    rapidBtn.Size = UDim2.new(0, 305, 0, 35)
    rapidBtn.Position = UDim2.new(0, 0, 0, 45) -- エイムボットの下
    rapidBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    rapidBtn.Text = "Rapid Fire (2x): OFF"
    rapidBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rapidBtn.Font = Enum.Font.SourceSansBold
    rapidBtn.TextSize = 14
    rapidBtn.Parent = aimPage

    rapidBtn.MouseButton1Click:Connect(function()
        rapidFireEnabled = not rapidFireEnabled
        rapidBtn.Text = "Rapid Fire (2x): " .. (rapidFireEnabled and "ON" or "OFF")
        rapidBtn.BackgroundColor3 = rapidFireEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    end)

    -- 連射処理ループ
    task.spawn(function()
        while task.wait(0.05) do -- 0.05秒ごとにチェック
            if rapidFireEnabled then
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        -- ツールのアクティベートを連打（デバウンス無視を狙う）
                        pcall(function() tool:Activate() end)
                        -- サーバーへ送るリモートを直接叩く試み
                        for _, v in pairs(tool:GetDescendants()) do
                            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                                pcall(function()
                                    if v:IsA("RemoteEvent") then
                                        v:FireServer()
                                    else
                                        v:InvokeServer()
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
end
-- ================= Rapid Fire (Super Fix) =================
rapidFireEnabled = false

-- 古いRapid Fireボタンを消す
if Pages and Pages.Aim then
    for _, v in pairs(Pages.Aim:GetChildren()) do
        if v:IsA("TextButton") and string.find(v.Text, "Rapid Fire") then
            v:Destroy()
        end
    end

    local rapidBtn = Instance.new("TextButton")
    rapidBtn.Size = UDim2.new(0, 305, 0, 35)
    rapidBtn.Position = UDim2.new(0, 0, 0, 45) 
    rapidBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    rapidBtn.Text = "Rapid Fire (2x): OFF"
    rapidBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rapidBtn.Font = Enum.Font.SourceSansBold
    rapidBtn.TextSize = 14
    rapidBtn.Parent = Pages.Aim

    rapidBtn.MouseButton1Click:Connect(function()
        rapidFireEnabled = not rapidFireEnabled
        rapidBtn.Text = "Rapid Fire (2x): " .. (rapidFireEnabled and "ON" or "OFF")
        rapidBtn.BackgroundColor3 = rapidFireEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    end)
end

-- 内部スクリプトの数値を書き換えるループ
task.spawn(function()
    while task.wait(0.5) do -- 0.5秒ごとに装備をチェック
        if rapidFireEnabled then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    -- ツール内のスクリプトを探して、連射速度に関係する数値を強制的に書き換える
                    for _, obj in pairs(tool:GetDescendants()) do
                        -- スクリプト内の特定の数値を上書き
                        if obj:IsA("NumberValue") then
                            if string.find(obj.Name, "Cooldown") or string.find(obj.Name, "FireRate") or string.find(obj.Name, "Delay") or string.find(obj.Name, "Speed") then
                                obj.Value = 0.01 -- 極限まで短くする
                            end
                        end
                        
                        -- 発射用リモートイベントの名前を探して連打する
                        if obj:IsA("RemoteEvent") and (string.find(obj.Name, "Fire") or string.find(obj.Name, "Shoot") or string.find(obj.Name, "Attack")) then
                            pcall(function()
                                obj:FireServer()
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- 超高速連打（0.02秒ごと）
task.spawn(function()
    while task.wait(0.02) do
        if rapidFireEnabled then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function() tool:Activate() end)
                end
            end
        end
    end
end)
-- ================= Fast Knife (高速振り) =================
local fastKnifeEnabled = false

if Pages and Pages.Aim then
    -- 既存のFast Knifeボタンを消去
    for _, v in pairs(Pages.Aim:GetChildren()) do
        if v:IsA("TextButton") and string.find(v.Text, "Fast Knife") then
            v:Destroy()
        end
    end

    -- 新しいボタンの配置
    local knifeBtn = Instance.new("TextButton")
    knifeBtn.Size = UDim2.new(0, 305, 0, 35)
    knifeBtn.Position = UDim2.new(0, 0, 0, 85) -- Rapid Fireの下
    knifeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    knifeBtn.Text = "Fast Knife: OFF"
    knifeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    knifeBtn.Font = Enum.Font.SourceSansBold
    knifeBtn.TextSize = 14
    knifeBtn.Parent = Pages.Aim

    knifeBtn.MouseButton1Click:Connect(function()
        fastKnifeEnabled = not fastKnifeEnabled
        knifeBtn.Text = "Fast Knife: " .. (fastKnifeEnabled and "ON" or "OFF")
        knifeBtn.BackgroundColor3 = fastKnifeEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    end)
end

-- 高速振りループ処理
task.spawn(function()
    while task.wait(0.01) do -- 1秒間に100回の超高速ループ
        if fastKnifeEnabled then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                -- 装備している武器がナイフや近接武器（Melee）かどうかの判定
                if tool and (string.find(tool.Name, "Knife") or string.find(tool.Name, "Sword") or string.find(tool.Name, "Katana") or string.find(tool.Name, "Melee")) then
                    -- ツールの発動（振る動作）
                    pcall(function() tool:Activate() end)
                    
                    -- 内部のリモートイベントを直接叩く（サーバーへの攻撃リクエスト）
                    for _, obj in pairs(tool:GetDescendants()) do
                        if obj:IsA("RemoteEvent") then
                            pcall(function() obj:FireServer() end)
                        end
                    end
                end
            end
        end
    end
end)
-- ================= Fast Knife (Hook方式 & 長押し対応) =================

-- ツール内の関数をフックするための準備
local isHoldingKnifeBtn = false
local hookedTools = {}

-- 長押し判定用ボタンの作成
if Pages and Pages.Aim then
    for _, v in pairs(Pages.Aim:GetChildren()) do
        if v:IsA("TextButton") and string.find(v.Text, "Fast Knife") then
            v:Destroy()
        end
    end

    local knifeBtn = Instance.new("TextButton")
    knifeBtn.Size = UDim2.new(0, 305, 0, 35)
    knifeBtn.Position = UDim2.new(0, 0, 0, 85) 
    knifeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    knifeBtn.Text = "Fast Knife (Hold): OFF"
    knifeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    knifeBtn.Font = Enum.Font.SourceSansBold
    knifeBtn.TextSize = 14
    knifeBtn.Parent = Pages.Aim

    -- 長押し開始
    knifeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isHoldingKnifeBtn = true
            knifeBtn.Text = "Fast Knife (Hold): ON"
            knifeBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        end
    end)

    -- 長押し終了
    knifeBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isHoldingKnifeBtn = false
            knifeBtn.Text = "Fast Knife (Hold): OFF"
            knifeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    end)
end

-- ツールの関数をフックする処理（クールダウン無視）
local function HookTool(tool)
    if hookedTools[tool] then return end
    hookedTools[tool] = true

    -- ツール内のスクリプトやLocalScriptを探す
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("Script") then
            -- スクリプト内の関数をフックするのは複雑なため、
            -- ここではツールの子要素にある「Cooldown」などの数値を0にする処理を常時行う
            -- （これが実質的なフック指名の代わりになります）
        end
    end
end

-- 長押し中の超高速発動ループ
task.spawn(function()
    while task.wait() do
        if isHoldingKnifeBtn then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and (string.find(tool.Name, "Knife") or string.find(tool.Name, "Sword") or string.find(tool.Name, "Katana")) then
                    HookTool(tool)
                    
                    -- ツールのクールダウン数値を書き換え
                    for _, obj in pairs(tool:GetDescendants()) do
                        if obj:IsA("NumberValue") and (string.find(obj.Name, "Cooldown") or string.find(obj.Name, "Delay") or string.find(obj.Name, "Time")) then
                            obj.Value = 0
                        end
                    end

                    -- アクティベートを連打（振る動作）
                    pcall(function() tool:Activate() end)
                    
                    -- リモートイベントを直接叩く
                    for _, obj in pairs(tool:GetDescendants()) do
                        if obj:IsA("RemoteEvent") then
                            pcall(function() obj:FireServer() end)
                        end
                    end
                end
            end
        end
    end
end)
-- ================= スキンチェンジャー（URL読み込み型） =================

if Pages and Pages.Settings then
    -- 既存のスキンチェンジャーボタンがあれば消去
    for _, v in pairs(Pages.Settings:GetChildren()) do
        if v:IsA("TextButton") and string.find(v.Text, "Skin") then
            v:Destroy()
        end
    end

    -- スキンチェンジャー用のボタン
    local skinBtn = Instance.new("TextButton")
    skinBtn.Size = UDim2.new(0, 305, 0, 35)
    skinBtn.Position = UDim2.new(0, 0, 0, 45) -- FPS Boostの下
    skinBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
    skinBtn.Text = "Unlock All Skins (Apply)"
    skinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    skinBtn.Font = Enum.Font.SourceSansBold
    skinBtn.TextSize = 14
    skinBtn.Parent = Pages.Settings

    -- ボタンを押した時の処理
    skinBtn.MouseButton1Click:Connect(function()
        skinBtn.Text = "Applying..."
        
        -- もらってきた構文をURLから読み込んで実行
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://pastefy.app/G0WRoaUP/raw"))()
        end)

        if success then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Skin Changer";
                Text = "スキンのアンロックと適用が完了しました！";
                Duration = 5;
            })
            skinBtn.Text = "Unlock All Skins (Applied)"
            skinBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Skin Changer Error";
                Text = "読み込みに失敗しました。ゲーム内にいるか確認してください。";
                Duration = 5;
            })
            skinBtn.Text = "Unlock All Skins (Error)"
            skinBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    end)
end
-- ================= エイムタブの完全初期化 =================

if Pages and Pages.Aim then
    for _, v in pairs(Pages.Aim:GetChildren()) do
        if v:IsA("TextButton") or v:IsA("TextLabel") then
            v:Destroy()
        end
    end
    
    -- 必要なら「準備中」というテキストだけ置いておく
    local emptyLabel = Instance.new("TextLabel")
    emptyLabel.Size = UDim2.new(1, 0, 1, 0)
    emptyLabel.BackgroundTransparency = 1
    emptyLabel.Text = "準備中..."
    emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    emptyLabel.Font = Enum.Font.SourceSansBold
    emptyLabel.TextSize = 16
    emptyLabel.Parent = Pages.Aim
end
-- ================= 弾道トレーサー (Tracer) =================

local TracerSettings = {
    Enabled = false,
    Color = Color3.fromRGB(0, 255, 255), -- シアン色（キースナイパー風）
    Lifetime = 0.5 -- 線が消えるまでの時間（秒）
}

-- ESPタブにボタンを追加
if Pages and Pages.ESP then
    -- 既存のTracerボタンを探して消す
    for _, v in pairs(Pages.ESP:GetChildren()) do
        if v:IsA("TextButton") and string.find(v.Text, "Tracer") then
            v:Destroy()
        end
    end

    local tracerBtn = Instance.new("TextButton")
    tracerBtn.Size = UDim2.new(0, 305, 0, 35)
    tracerBtn.Position = UDim2.new(0, 0, 0, 90) -- 既存のESPボタンの下
    tracerBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    tracerBtn.Text = "Bullet Tracer: OFF"
    tracerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tracerBtn.Font = Enum.Font.SourceSansBold
    tracerBtn.TextSize = 14
    tracerBtn.Parent = Pages.ESP

    tracerBtn.MouseButton1Click:Connect(function()
        TracerSettings.Enabled = not TracerSettings.Enabled
        tracerBtn.Text = "Bullet Tracer: " .. (TracerSettings.Enabled and "ON" or "OFF")
        tracerBtn.BackgroundColor3 = TracerSettings.Enabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    end)
end

-- 弾の検知と描画処理
local DrawingsFolder = Instance.new("Folder")
DrawingsFolder.Name = "TracerFolder"
DrawingsFolder.Parent = game:GetService("CoreGui")

-- 新しく生成されたパーツ（弾）を監視する
workspace.DescendantAdded:Connect(function(obj)
    if TracerSettings.Enabled and obj:IsA("BasePart") then
        -- 弾っぽいパーツ（小さくて、当たり判定がないもの）を判定
        if obj.Size.Magnitude < 2 and obj.CanCollide == false then
            -- 弾のスタート位置（カメラの位置 = 自分が撃った位置）
            local startPos = Camera.CFrame.Position
            
            -- 弾が消える（当たる）のを待つか、少しの間追跡する
            task.spawn(function()
                local endPos = startPos
                local elapsed = 0
                local hasHit = false

                -- 弾が存在する間、または一定時間が経過するまで追跡
                while obj.Parent and elapsed < 2 do
                    endPos = obj.Position
                    task.wait(0.01)
                    elapsed = elapsed + 0.01
                end

                -- 弾が消えた時点（命中した時点）の位置を取得
                local tracer = Drawing.new("Line")
                tracer.Visible = true
                tracer.Thickness = 2
                tracer.Color = TracerSettings.Color
                tracer.Transparency = 1
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 50) -- 画面下部の自分の手元
                
                -- 着弾点を画面座標に変換
                local screenPos, onScreen = Camera:WorldToViewportPoint(endPos)
                if onScreen then
                    tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    tracer.Parent = DrawingsFolder

                    -- フェードアウトして消す処理
                    task.spawn(function()
                        local fadeTime = TracerSettings.Lifetime
                        while fadeTime > 0 do
                            task.wait(0.05)
                            fadeTime = fadeTime - 0.05
                            tracer.Transparency = fadeTime / TracerSettings.Lifetime
                        end
                        tracer:Remove()
                    end)
                else
                    tracer:Remove()
                end
            end)
        end
    end
end)
