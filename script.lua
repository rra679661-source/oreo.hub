local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    ESP = false, ESP_Name = false, ESP_Health = false, ESP_Distance = false,
    SpeedHack = false, SpeedValue = 16, InfJump = false, Noclip = false,
    Fly = false, FlySpeed = 50, FPSBoost = false,
    AntiAFK = false, AntiFling = false, AntiVoid = false
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

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 280)
Frame.Position = UDim2.new(0.5, -160, 0.5, -140)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Visible = false
Frame.Parent = ScreenGui

local stroke = Instance.new("UIStroke")
stroke.Parent = Frame
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
task.spawn(function()
    local hue = 0.5
    while stroke.Parent do
        hue = hue + 0.01
        if hue > 1 then hue = 0 end
        stroke.Color = Color3.fromHSV(hue, 1, 1)
        task.wait(0.05)
    end
end)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Header.Parent = Frame
local TitleLeft = Instance.new("TextLabel")
TitleLeft.Size = UDim2.new(0.5, 0, 1, 0); TitleLeft.Position = UDim2.new(0, 10, 0, 0); TitleLeft.BackgroundTransparency = 1; TitleLeft.Text = "Oreo.hub"; TitleLeft.TextColor3 = Color3.fromRGB(255, 255, 255); TitleLeft.Font = Enum.Font.SourceSansBold; TitleLeft.TextSize = 14; TitleLeft.TextXAlignment = Enum.TextXAlignment.Left; TitleLeft.Parent = Header
local TitleRight = Instance.new("TextLabel")
TitleRight.Size = UDim2.new(0.5, 0, 1, 0); TitleRight.Position = UDim2.new(0.5, -10, 0, 0); TitleRight.BackgroundTransparency = 1; TitleRight.Text = "Loading..."; TitleRight.TextColor3 = Color3.fromRGB(200, 200, 200); TitleRight.Font = Enum.Font.SourceSansBold; TitleRight.TextSize = 11; TitleRight.TextXAlignment = Enum.TextXAlignment.Right; TitleRight.Parent = Header

local frames = 0
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastTime >= 1 then
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        TitleRight.Text = os.date("%m/%d %H:%M:%S") .. " | " .. frames .. " FPS | " .. ping .. "ms"
        frames = 0; lastTime = tick()
    end
end)

local dragging, dragInput, dragStart, startPos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Frame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
Frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

ToggleMenuBtn.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
    if Frame.Visible then Frame.Position = UDim2.new(0.5, -160, 0.5, -140) end
    ToggleMenuBtn.Text = Frame.Visible and "Close" or "Oreo.hub"
end)

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 25); TabContainer.Position = UDim2.new(0, 0, 0, 30); TabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40); TabContainer.Parent = Frame
local function createTab(text, posX, width)
    local tab = Instance.new("TextButton"); tab.Size = UDim2.new(0, width, 1, 0); tab.Position = UDim2.new(0, posX, 0, 0); tab.BackgroundColor3 = Color3.fromRGB(50, 50, 50); tab.Text = text; tab.TextColor3 = Color3.fromRGB(200, 200, 200); tab.Font = Enum.Font.SourceSansBold; tab.TextSize = 12; tab.Parent = TabContainer; return tab
end
local espTabBtn = createTab("ESP", 0, 80)
local charTabBtn = createTab("キャラ", 80, 80)
local setTabBtn = createTab("設定", 160, 80)
local secTabBtn = createTab("守り", 240, 80)

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -10, 1, -65); Content.Position = UDim2.new(0, 5, 0, 60); Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 4; Content.CanvasSize = UDim2.new(0, 0, 0, 300); Content.Parent = Frame

local Pages = { ESP = Instance.new("Frame"), Char = Instance.new("Frame"), Settings = Instance.new("Frame"), Security = Instance.new("Frame") }
for _, page in pairs(Pages) do page.Size = UDim2.new(1, -5, 0, 300); page.BackgroundTransparency = 1; page.Visible = false; page.Parent = Content end
Pages.ESP.Visible = true

local function switchTab(activePage, activeBtn)
    for _, page in pairs(Pages) do page.Visible = false end
    activePage.Visible = true
    for _, btn in pairs({espTabBtn, charTabBtn, setTabBtn, secTabBtn}) do btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); btn.TextColor3 = Color3.fromRGB(200, 200, 200) end
    activeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70); activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end
espTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.ESP, espTabBtn) end)
charTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Char, charTabBtn) end)
setTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Settings, setTabBtn) end)
secTabBtn.MouseButton1Click:Connect(function() switchTab(Pages.Security, secTabBtn) end)

local function createBtn(parent, text, posX, posY, color, sizeX)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, sizeX or 150, 0, 30); btn.Position = UDim2.new(0, posX, 0, posY); btn.BackgroundColor3 = color; btn.Text = text; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 13; btn.Parent = parent; return btn
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

local speedLabel = Instance.new("TextLabel"); speedLabel.Size = UDim2.new(0, 150, 0, 20); speedLabel.Position = UDim2.new(0, 0, 0, 85); speedLabel.BackgroundTransparency = 1; speedLabel.Text = "Speed: 16"; speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255); speedLabel.Font = Enum.Font.SourceSansBold; speedLabel.TextSize = 14; speedLabel.Parent = Pages.Char
local minusBtn = createBtn(Pages.Char, "-", 0, 110, Color3.fromRGB(200, 50, 50), 40)
local speedToggleBtn = createBtn(Pages.Char, "Speed: OFF", 45, 110, Color3.fromRGB(200, 50, 50), 100)
local plusBtn = createBtn(Pages.Char, "+", 150, 110, Color3.fromRGB(50, 200, 50), 40)
speedToggleBtn.MouseButton1Click:Connect(function() toggle("SpeedHack", speedToggleBtn, "Speed") end)
minusBtn.MouseButton1Click:Connect(function() Settings.SpeedValue = math.max(16, Settings.SpeedValue - 10); speedLabel.Text = "Speed: " .. Settings.SpeedValue end)
plusBtn.MouseButton1Click:Connect(function() Settings.SpeedValue = math.min(300, Settings.SpeedValue + 10); speedLabel.Text = "Speed: " .. Settings.SpeedValue end)

local flyLabel = Instance.new("TextLabel"); flyLabel.Size = UDim2.new(0, 150, 0, 20); flyLabel.Position = UDim2.new(0, 0, 0, 150); flyLabel.BackgroundTransparency = 1; flyLabel.Text = "Fly Speed: 50"; flyLabel.TextColor3 = Color3.fromRGB(255, 255, 255); flyLabel.Font = Enum.Font.SourceSansBold; flyLabel.TextSize = 14; flyLabel.Parent = Pages.Char
local flyMinusBtn = createBtn(Pages.Char, "-", 0, 175, Color3.fromRGB(200, 50, 50), 40)
local flyPlusBtn = createBtn(Pages.Char, "+", 150, 175, Color3.fromRGB(50, 200, 50), 40)
flyMinusBtn.MouseButton1Click:Connect(function() Settings.FlySpeed = math.max(10, Settings.FlySpeed - 10); flyLabel.Text = "Fly Speed: " .. Settings.FlySpeed end)
flyPlusBtn.MouseButton1Click:Connect(function() Settings.FlySpeed = math.min(200, Settings.FlySpeed + 10); flyLabel.Text = "Fly Speed: " .. Settings.FlySpeed end)

-- 設定タブ
local fpsBoostBtn = createBtn(Pages.Settings, "FPS Boost: OFF", 0, 5, Color3.fromRGB(200, 50, 50), 305)
fpsBoostBtn.MouseButton1Click:Connect(function() toggle("FPSBoost", fpsBoostBtn, "FPS Boost") end)
local skinBtn = createBtn(Pages.Settings, "Unlock All Skins", 0, 45, Color3.fromRGB(50, 150, 200), 305)
skinBtn.MouseButton1Click:Connect(function()
    skinBtn.Text = "Applying..."
    local success = pcall(function() loadstring(game:HttpGet("https://pastefy.app/G0WRoaUP/raw"))() end)
    if success then skinBtn.Text = "Unlock All Skins (Applied)"; skinBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) else skinBtn.Text = "Error" end
end)

-- 守りタブ (重要なAnti機能のみ)
local antiAfkBtn = createBtn(Pages.Security, "Anti AFK: OFF", 0, 5, Color3.fromRGB(200, 50, 50))
local antiFlingBtn = createBtn(Pages.Security, "Anti Fling: OFF", 155, 5, Color3.fromRGB(200, 50, 50))
local antiVoidBtn = createBtn(Pages.Security, "Anti Void: OFF", 0, 45, Color3.fromRGB(200, 50, 50))

antiAfkBtn.MouseButton1Click:Connect(function() toggle("AntiAFK", antiAfkBtn, "Anti AFK") end)
antiFlingBtn.MouseButton1Click:Connect(function() toggle("AntiFling", antiFlingBtn, "Anti Fling") end)
antiVoidBtn.MouseButton1Click:Connect(function() toggle("AntiVoid", antiVoidBtn, "Anti Void") end)

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
                local bv = Instance.new("BodyVelocity"); bv.Name = "FlyVelocity"; bv.MaxForce = Vector3.new(1e5, 1e5, 1e5); bv.Velocity = Vector3.zero; bv.Parent = hrp
            end
            local bv = hrp:FindFirstChild("FlyVelocity")
            if bv then
                local targetVel = hum.MoveDirection * Settings.FlySpeed
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then targetVel = targetVel + Vector3.new(0, Settings.FlySpeed, 0) 
                elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then targetVel = targetVel - Vector3.new(0, Settings.FlySpeed, 0) end
                bv.Velocity = targetVel
            end
        else
            if hum.PlatformStand then hum.PlatformStand = false end
            if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
        end
        
        if Settings.AntiVoid and hrp.Position.Y < -50 then hrp.CFrame = CFrame.new(0, 50, 0) end
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

LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if Settings.AntiFling and hrp.AssemblyAngularVelocity.Magnitude > 50 then hrp.AssemblyAngularVelocity = Vector3.new(0,0,0) end
end)

-- ESP
local ESPFolder = Instance.new("Folder"); ESPFolder.Name = "OreoESP"; ESPFolder.Parent = game:GetService("CoreGui")

local function IsTeammate(player) if LocalPlayer.Team == nil then return false end; return player.Team == LocalPlayer.Team end

local function CreateESP(player)
    if player == LocalPlayer or IsTeammate(player) then return end
    local function onChar(char)
        local head = char:WaitForChild("Head", 5); if not head then return end
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
