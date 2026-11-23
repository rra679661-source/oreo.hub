local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 設定
local Settings = { ESP = false, SpeedHack = false, SpeedValue = 16, InfJump = false, Noclip = false }

-- ================= UI作成 =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OreoHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- メニュー開閉ボタン
local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Size = UDim2.new(0, 80, 0, 35)
ToggleMenuBtn.Position = UDim2.new(0, 20, 0, 100)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleMenuBtn.Text = "Menu"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleMenuBtn.Font = Enum.Font.SourceSansBold
ToggleMenuBtn.Parent = ScreenGui

-- メインフレーム（完全に中央配置）
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 300) -- サイズを調整
-- 画面のド真ん中に表示するための計算式（0.5で中央、サイズの半分を引く）
Frame.Position = UDim2.new(0.5, -125, 0.5, -150) 
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Visible = false
Frame.Parent = ScreenGui

-- ドラッグ移動処理
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

-- ヘッダー
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Header.Parent = Frame
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "おれおはぶ"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = Header

-- ボタン生成関数
local function createBtn(text, posY, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = Frame
    return btn
end

-- ボタンの配置
local espBtn = createBtn("ESP: OFF", 45, Color3.fromRGB(200, 50, 50))
local speedBtn = createBtn("Speed: OFF", 95, Color3.fromRGB(200, 50, 50))
local jumpBtn = createBtn("Inf Jump: OFF", 145, Color3.fromRGB(200, 50, 50))
local noclipBtn = createBtn("Noclip: OFF", 195, Color3.fromRGB(200, 50, 50))

-- スピード調整スライダー
local speedBar = Instance.new("TextButton")
speedBar.Size = UDim2.new(0.9, 0, 0, 15)
speedBar.Position = UDim2.new(0.05, 0, 0, 245)
speedBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
speedBar.Text = ""
speedBar.Parent = Frame

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
fill.Parent = speedBar

local speedText = Instance.new("TextLabel")
speedText.Size = UDim2.new(1, 0, 0, 15)
speedText.Position = UDim2.new(0, 0, 0, -15)
speedText.BackgroundTransparency = 1
speedText.Text = "Speed: 16"
speedText.TextColor3 = Color3.fromRGB(255, 255, 255)
speedText.TextSize = 12
speedText.Parent = speedBar

-- メニュー開閉処理
ToggleMenuBtn.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
    -- メニューを開いた時に位置がズレていたら強制的に中央に戻す
    if Frame.Visible then
        Frame.Position = UDim2.new(0.5, -125, 0.5, -150)
    end
    ToggleMenuBtn.Text = Frame.Visible and "Close" or "Menu"
end)

-- ================= 各ボタンの処理 =================
espBtn.MouseButton1Click:Connect(function()
    Settings.ESP = not Settings.ESP
    espBtn.Text = "ESP: " .. (Settings.ESP and "ON" or "OFF")
    espBtn.BackgroundColor3 = Settings.ESP and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

speedBtn.MouseButton1Click:Connect(function()
    Settings.SpeedHack = not Settings.SpeedHack
    speedBtn.Text = "Speed: " .. (Settings.SpeedHack and "ON" or "OFF")
    speedBtn.BackgroundColor3 = Settings.SpeedHack and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

jumpBtn.MouseButton1Click:Connect(function()
    Settings.InfJump = not Settings.InfJump
    jumpBtn.Text = "Inf Jump: " .. (Settings.InfJump and "ON" or "OFF")
    jumpBtn.BackgroundColor3 = Settings.InfJump and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

noclipBtn.MouseButton1Click:Connect(function()
    Settings.Noclip = not Settings.Noclip
    noclipBtn.Text = "Noclip: " .. (Settings.Noclip and "ON" or "OFF")
    noclipBtn.BackgroundColor3 = Settings.Noclip and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

-- スライダー操作
speedBar.MouseButton1Click:Connect(function()
    local mouseX = UserInputService:GetMouseLocation().X
    local relativeX = math.clamp((mouseX - speedBar.AbsolutePosition.X) / speedBar.AbsoluteSize.X, 0, 1)
    Settings.SpeedValue = math.floor(16 + (relativeX * 284))
    fill.Size = UDim2.new(relativeX, 0, 1, 0)
    speedText.Text = "Speed: " .. Settings.SpeedValue
end)

-- ================= キャラクター処理 =================
local function IsTeammate(player)
    if LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team then return true end
    return false
end

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

-- ================= ESP =================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "MyESP"
ESPFolder.Parent = game:GetService("CoreGui")

local function CreateESP(player)
    if player == LocalPlayer or IsTeammate(player) then return end
    local function onChar(char)
        local head = char:WaitForChild("Head", 5)
        if not head then return end
        if ESPFolder:FindFirstChild(player.Name) then ESPFolder[player.Name]:Destroy() end

        local bg = Instance.new("BillboardGui")
        bg.Name = player.Name
        bg.Adornee = head
        bg.Size = UDim2.new(0, 200, 0, 50)
        bg.StudsOffset = Vector3.new(0, 2.5, 0)
        bg.AlwaysOnTop = true
        bg.Parent = ESPFolder

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.fromRGB(255, 50, 50)
        text.Font = Enum.Font.SourceSansBold
        text.TextSize = 16
        text.TextStrokeTransparency = 0
        text.Parent = bg

        task.spawn(function()
            while bg.Parent do
                if Settings.ESP and char.Parent and char:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    bg.Enabled = true
                    local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude)
                    local weapon = "None"
                    for _, v in pairs(char:GetChildren()) do
                        if v:IsA("Tool") then weapon = v.Name break end
                    end
                    text.Text = player.Name .. "\n[" .. weapon .. "]\n[" .. distance .. "m]"
                else
                    bg.Enabled = false
                end
                task.wait(0.2)
            end
        end)
    end
    if player.Character then onChar(player.Character) end
    player.CharacterAdded:Connect(onChar)
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
