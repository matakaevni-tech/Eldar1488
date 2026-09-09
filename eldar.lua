-- ЭЛЬДАР ГЕЙ 1488 | ФИНАЛ (РАБОТАЕТ)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Cam = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local targetPart = "Head"
local fovRadius = 100
local fovActive = false
local menuOpen = false
local mainGui = nil
local fovCircle = nil

local function createButton()
    local sg = Instance.new("ScreenGui")
    sg.Parent = CoreGui
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0, 10, 0.5, -25)
    btn.Image = "rbxassetid://12210970728"
    btn.BackgroundTransparency = 1
    btn.Parent = sg

    btn.MouseButton1Click:Connect(function()
        if not menuOpen then createMenu() end
    end)
    btn.TouchEnded:Connect(function()
        if not menuOpen then createMenu() end
    end)
end

local function createMenu()
    if mainGui then return end
    menuOpen = true
    local sg = Instance.new("ScreenGui")
    sg.Parent = CoreGui
    mainGui = sg

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 280)
    frame.Position = UDim2.new(0.5, -125, 0.5, -140)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.1
    frame.Parent = sg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "ЭЛЬДАР ГЕЙ 1488"
    title.TextColor3 = Color3.fromRGB(0, 255, 200)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = frame

    local btnHead = Instance.new("TextButton")
    btnHead.Size = UDim2.new(0, 100, 0, 35)
    btnHead.Position = UDim2.new(0, 10, 0, 50)
    btnHead.Text = "ГОЛОВА"
    btnHead.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    btnHead.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnHead.Font = Enum.Font.GothamBold
    btnHead.TextSize = 16
    btnHead.Parent = frame
    btnHead.MouseButton1Click:Connect(function()
        targetPart = "Head"
        btnHead.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        btnTorso.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)
    btnHead.TouchEnded:Connect(function()
        targetPart = "Head"
        btnHead.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        btnTorso.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)

    local btnTorso = Instance.new("TextButton")
    btnTorso.Size = UDim2.new(0, 100, 0, 35)
    btnTorso.Position = UDim2.new(0, 140, 0, 50)
    btnTorso.Text = "ТУЛОВИЩЕ"
    btnTorso.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    btnTorso.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnTorso.Font = Enum.Font.GothamBold
    btnTorso.TextSize = 16
    btnTorso.Parent = frame
    btnTorso.MouseButton1Click:Connect(function()
        targetPart = "Torso"
        btnTorso.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        btnHead.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)
    btnTorso.TouchEnded:Connect(function()
        targetPart = "Torso"
        btnTorso.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        btnHead.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)

    local btnAim = Instance.new("TextButton")
    btnAim.Size = UDim2.new(0, 230, 0, 35)
    btnAim.Position = UDim2.new(0, 10, 0, 100)
    btnAim.Text = "🔫 AIMBOT (ВЫКЛ)"
    btnAim.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    btnAim.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnAim.Font = Enum.Font.GothamBold
    btnAim.TextSize = 16
    btnAim.Parent = frame
    btnAim.MouseButton1Click:Connect(function()
        fovActive = not fovActive
        if fovActive then
            btnAim.Text = "🔫 AIMBOT (ВКЛ)"
            btnAim.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            createFOV()
        else
            btnAim.Text = "🔫 AIMBOT (ВЫКЛ)"
            btnAim.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            removeFOV()
        end
    end)
    btnAim.TouchEnded:Connect(function()
        fovActive = not fovActive
        if fovActive then
            btnAim.Text = "🔫 AIMBOT (ВКЛ)"
            btnAim.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            createFOV()
        else
            btnAim.Text = "🔫 AIMBOT (ВЫКЛ)"
            btnAim.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            removeFOV()
        end
    end)

    local fovSlider = Instance.new("Frame")
    fovSlider.Size = UDim2.new(0, 230, 0, 45)
    fovSlider.Position = UDim2.new(0, 10, 0, 150)
    fovSlider.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    fovSlider.BackgroundTransparency = 0.3
    fovSlider.Parent = frame

    local fovLabel = Instance.new("TextLabel")
    fovLabel.Size = UDim2.new(0, 50, 0, 30)
    fovLabel.Position = UDim2.new(0, 0, 0, 7)
    fovLabel.Text = "FOV"
    fovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Font = Enum.Font.GothamBold
    fovLabel.TextSize = 16
    fovLabel.Parent = fovSlider

    local fovValue = Instance.new("TextLabel")
    fovValue.Size = UDim2.new(0, 40, 0, 30)
    fovValue.Position = UDim2.new(0, 180, 0, 7)
    fovValue.Text = tostring(fovRadius)
    fovValue.TextColor3 = Color3.fromRGB(0, 255, 200)
    fovValue.BackgroundTransparency = 1
    fovValue.Font = Enum.Font.GothamBold
    fovValue.TextSize = 16
    fovValue.Parent = fovSlider

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(0, 120, 0, 6)
    sliderTrack.Position = UDim2.new(0, 55, 0, 19)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    sliderTrack.Parent = fovSlider

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((fovRadius - 50) / 150, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    sliderFill.Parent = sliderTrack

    local sliderButton = Instance.new("ImageButton")
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new((fovRadius - 50) / 150, -8, 0, -5)
    sliderButton.Image = "rbxassetid://12210970728"
    sliderButton.BackgroundTransparency = 1
    sliderButton.Parent = sliderTrack

    local dragging = false
    sliderButton.MouseButton1Down:Connect(function() dragging = true end)
    sliderButton.MouseButton1Up:Connect(function() dragging = false end)
    sliderButton.MouseLeave:Connect(function() dragging = false end)
    sliderButton.TouchBegan:Connect(function() dragging = true end)
    sliderButton.TouchEnded:Connect(function() dragging = false end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local trackPos = sliderTrack.AbsolutePosition.X
            local trackSize = sliderTrack.AbsoluteSize.X
            local mouseX = input.Position.X
            local percent = math.clamp((mouseX - trackPos) / trackSize, 0, 1)
            fovRadius = math.floor(50 + percent * 150)
            fovValue.Text = tostring(fovRadius)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderButton.Position = UDim2.new(percent, -8, 0, -5)
            if fovCircle then removeFOV() createFOV() end
        end
    end)

    UIS.TouchMoved:Connect(function(touch)
        if dragging then
            local trackPos = sliderTrack.AbsolutePosition.X
            local trackSize = sliderTrack.AbsoluteSize.X
            local touchX = touch.Position.X
            local percent = math.clamp((touchX - trackPos) / trackSize, 0, 1)
            fovRadius = math.floor(50 + percent * 150)
            fovValue.Text = tostring(fovRadius)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderButton.Position = UDim2.new(percent, -8, 0, -5)
            if fovCircle then removeFOV() createFOV() end
        end
    end)

    local btnClose = Instance.new("TextButton")
    btnClose.Size = UDim2.new(0, 230, 0, 35)
    btnClose.Position = UDim2.new(0, 10, 0, 230)
    btnClose.Text = "✕ ЗАКРЫТЬ"
    btnClose.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    btnClose.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnClose.Font = Enum.Font.GothamBold
    btnClose.TextSize = 16
    btnClose.Parent = frame
    btnClose.MouseButton1Click:Connect(function()
        sg:Destroy()
        mainGui = nil
        menuOpen = false
    end)
    btnClose.TouchEnded:Connect(function()
        sg:Destroy()
        mainGui = nil
        menuOpen = false
    end)
end

local function createFOV()
    if fovCircle then return end
    local sg = Instance.new("ScreenGui")
    sg.Parent = CoreGui
    local circle = Instance.new("ImageLabel")
    circle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    circle.Position = UDim2.new(0.5, -fovRadius, 0.5, -fovRadius)
    circle.Image = "rbxassetid://12210970728"
    circle.ImageTransparency = 0.5
    circle.BackgroundTransparency = 1
    circle.Parent = sg
    fovCircle = sg
end

local function removeFOV()
    if fovCircle then
        fovCircle:Destroy()
        fovCircle = nil
    end
end

local function doAimbot()
    if not fovActive then return end
    local center = Cam.ViewportSize / 2
    local best, bestDist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and plr.Character:FindFirstChild(targetPart) then
            local part = plr.Character[targetPart]
            local pos, vis = Cam:WorldToScreenPoint(part.Position)
            if vis then
                local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if d < bestDist and d < fovRadius then
                    bestDist = d
                    best = plr
                end
            end
        end
    end
    if best then
        local targetPos = best.Character[targetPart].Position
        Cam.CFrame = CFrame.new(Cam.CFrame.Position, targetPos)
    end
end

RS.Heartbeat:Connect(function()
    if fovActive then doAimbot() end
end)

createButton()
print("[ЭЛЬДАР ГЕЙ] Загружено! Нажми на круглую кнопку слева.")
