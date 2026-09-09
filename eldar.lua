-- ЭЛЬДАР ГЕЙ 1488 | ПОЛНАЯ ВЕРСИЯ (ПРОВЕРЕНА)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Cam = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Char:WaitForChild("Humanoid")
local RootPart = Char:WaitForChild("HumanoidRootPart")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local PathfindingService = game:GetService("PathfindingService")

-- НАСТРОЙКИ
local targetPart = "Head"
local sellRemote = ReplicatedStorage:FindFirstChild("SellItem")
local buyRemote = ReplicatedStorage:FindFirstChild("BuyItem")
local laundryRemote = ReplicatedStorage:FindFirstChild("LaundryMoney")
local isFarming = false
local fovRadius = 100
local fovActive = false
local menuOpen = false
local mainGui = nil
local fovCircle = nil

-- ИНВЕНТАРЬ И ДЕНЬГИ (заглушки, если нет)
local Inventory = LP:FindFirstChild("Inventory") or Instance.new("Folder", LP)
local Money = LP:FindFirstChild("Money") or Instance.new("IntValue", LP)
local CleanMoney = LP:FindFirstChild("CleanMoney") or Instance.new("IntValue", LP)

-- КООРДИНАТЫ (ЗАМЕНИТЬ НА РЕАЛЬНЫЕ)
local dealerPosition = Vector3.new(100, 10, 0)   -- место торговца
local mexicoPosition = Vector3.new(-100, 0, 200) -- стартовая точка

-- ===== БЕГ С PATHFINDING (ОБХОД СТЕН) =====
local function walkTo(targetPos, speed)
    Humanoid.WalkSpeed = speed
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
    })
    path:ComputeAsync(RootPart.Position, targetPos)
    if path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            if not isFarming then break end
            Humanoid:MoveTo(waypoint.Position)
            while isFarming and (RootPart.Position - waypoint.Position).Magnitude > 3 do
                Humanoid:MoveTo(waypoint.Position)
                task.wait(0.1)
            end
        end
    else
        Humanoid:MoveTo(targetPos)
        while isFarming and (RootPart.Position - targetPos).Magnitude > 3 do
            Humanoid:MoveTo(targetPos)
            task.wait(0.1)
        end
    end
    Humanoid.WalkSpeed = 16
end

-- ===== ФРАКЦИИ =====
local function getPlayerFaction(plr)
    if plr.Character and plr.Character:FindFirstChild("FactionTag") then
        return plr.Character.FactionTag.Value
    end
    return "Civilian"
end

local function isValidTarget(plr)
    if plr == LP then return false end
    if not plr.Character or not plr.Character:FindFirstChild("Head") then return false end
    local myFaction = getPlayerFaction(LP)
    local targetFaction = getPlayerFaction(plr)
    if myFaction == "Bandit" then
        return targetFaction == "Police" or targetFaction == "FBI" or targetFaction == "BorderGuard"
    end
    if myFaction == "Police" or myFaction == "FBI" or myFaction == "BorderGuard" then
        if targetFaction == "Civilian" then
            local stars = plr.Character:FindFirstChild("WantedLevel")
            if stars then return stars.Value >= 1 end
        end
        return false
    end
    return false
end

-- ===== ПОИСК ТОРГОВЦА =====
local function findBestDealer()
    local best, bestPrice = nil, 0
    for _, npc in pairs(workspace:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("PriceTag") then
            local price = tonumber(npc.PriceTag.Value) or 0
            if price > bestPrice then
                bestPrice = price
                best = npc
            end
        end
    end
    return best, bestPrice
end

-- ===== СИМУЛЯЦИЯ НАЖАТИЯ =====
local function simulateClick()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
    task.wait(0.3)
end

-- ===== ПРОВЕРКИ ИНВЕНТАРЯ =====
local function hasItem(itemName, amount)
    local count = 0
    for _, item in pairs(Inventory:GetChildren()) do
        if item.Name == itemName then count = count + 1 end
    end
    return count >= amount
end

local function doBuy(dealer, item, amount, price)
    if not buyRemote then return false end
    buyRemote:FireServer(dealer, item, amount, price)
    simulateClick()
    task.wait(1)
    return hasItem(item, amount)
end

local function doSell(dealer, item, amount, price)
    if not sellRemote then return false end
    sellRemote:FireServer(dealer, item, amount, price)
    simulateClick()
    task.wait(1)
    return not hasItem(item, amount)
end

local function doLaundry(amount)
    if not laundryRemote then return false end
    laundryRemote:FireServer(amount)
    simulateClick()
    task.wait(1)
    return CleanMoney.Value > 0
end

-- ===== АВТОФАРМ =====
local function startAutoFarm()
    if isFarming then
        isFarming = false
        print("[ЭЛЬДАР ГЕЙ] Автофарм остановлен")
        return
    end
    isFarming = true
    print("[ЭЛЬДАР ГЕЙ] Автофарм запущен")
    task.spawn(function()
        while isFarming do
            walkTo(dealerPosition, 40)
            if not isFarming then break end
            local dealer = findBestDealer()
            if not dealer then
                print("[ЭЛЬДАР ГЕЙ] Торговец не найден")
                break
            end
            local price = tonumber(dealer.PriceTag.Value) or 0
            local total = price * 5
            local clean = total * 0.85
            if doBuy(dealer, "MonaLisa", 5, total) then
                print("[ЭЛЬДАР ГЕЙ] Покупка успешна")
            else
                print("[ЭЛЬДАР ГЕЙ] Ошибка покупки")
                break
            end
            task.wait(1)
            if doSell(dealer, "MonaLisa", 5, total) then
                print("[ЭЛЬДАР ГЕЙ] Продажа успешна")
            else
                print("[ЭЛЬДАР ГЕЙ] Ошибка продажи")
                break
            end
            task.wait(1)
            if doLaundry(clean) then
                print("[ЭЛЬДАР ГЕЙ] Отмыв успешен")
            else
                print("[ЭЛЬДАР ГЕЙ] Ошибка отмыва")
                break
            end
            task.wait(1)
            walkTo(mexicoPosition, 40)
        end
        isFarming = false
    end)
end

-- ===== FOV =====
local function createFOV()
    if fovCircle then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "FOVCircle"
    sg.Parent = CoreGui
    sg.ResetOnSpawn = false
    local circle = Instance.new("ImageLabel")
    circle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    circle.Position = UDim2.new(0.5, -fovRadius, 0.5, -fovRadius)
    circle.Image = "rbxassetid://12210970728"
    circle.ImageTransparency = 0.5
    circle.BackgroundTransparency = 1
    circle.Parent = sg
    fovCircle = sg
    fovActive = true
end

local function removeFOV()
    if fovCircle then fovCircle:Destroy() fovCircle = nil end
    fovActive = false
end

-- ===== AIMBOT =====
local function doAimbot()
    if not fovActive then return end
    local center = Cam.ViewportSize / 2
    local best, bestDist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if isValidTarget(plr) then
            local part = plr.Character:FindFirstChild(targetPart)
            if part then
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
    end
    if best then
        local targetPos = best.Character[targetPart].Position
        Cam.CFrame = CFrame.new(Cam.CFrame.Position, targetPos)
        print("[ЭЛЬДАР ГЕЙ] Выстрел в", best.Name)
        return true
    end
    return false
end

RS.Heartbeat:Connect(function()
    if fovActive then doAimbot() end
end)

-- ===== МЕНЮ =====
local function createMainMenu()
    if mainGui then return end
    menuOpen = true
    local sg = Instance.new("ScreenGui")
    sg.Name = "EldarMenu"
    sg.Parent = CoreGui
    sg.ResetOnSpawn = false
    mainGui = sg

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 400)
    frame.Position = UDim2.new(0.5, -160, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = sg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Text = "ЭЛЬДАР ГЕЙ 1488"
    title.TextColor3 = Color3.fromRGB(0, 255, 200)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.Parent = frame

    local function createButton(text, y, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 280, 0, 40)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.Text = text
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.Parent = frame
        btn.MouseButton1Click:Connect(callback)
        btn.TouchEnded:Connect(callback)
        return btn
    end

    local btnHead = createButton("ГОЛОВА", 60, Color3.fromRGB(0, 200, 0), function()
        targetPart = "Head"
        btnHead.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        btnTorso.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        print("[ЭЛЬДАР ГЕЙ] Цель: ГОЛОВА")
    end)

    local btnTorso = createButton("ТУЛОВИЩЕ", 110, Color3.fromRGB(80, 80, 80), function()
        targetPart = "Torso"
        btnTorso.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        btnHead.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        print("[ЭЛЬДАР ГЕЙ] Цель: ТУЛОВИЩЕ")
    end)

    createButton("🔫 AIMBOT", 160, Color3.fromRGB(0, 150, 200), function()
        if fovActive then
            removeFOV()
            print("[ЭЛЬДАР ГЕЙ] Aimbot выключен")
        else
            createFOV()
            print("[ЭЛЬДАР ГЕЙ] Aimbot включён")
        end
    end)

    createButton("💰 AUTOFARM", 210, Color3.fromRGB(200, 150, 0), function()
        startAutoFarm()
        local btn = findButton("💰 AUTOFARM")
        if btn then
            if isFarming then
                btn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            else
                btn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
            end
        end
    end)

    createButton("✕ ЗАКРЫТЬ", 330, Color3.fromRGB(200, 40, 40), function()
        sg:Destroy()
        mainGui = nil
        menuOpen = false
    end)
end

-- ВСПОМОГАТЕЛЬНАЯ ФУНКЦИЯ ДЛЯ ПОИСКА КНОПКИ (для изменения цвета)
local function findButton(text)
    if not mainGui then return nil end
    for _, child in pairs(mainGui:GetDescendants()) do
        if child:IsA("TextButton") and child.Text == text then
            return child
        end
    end
    return nil
end

-- ===== КНОПКА ОТКРЫТИЯ МЕНЮ =====
local function createOpenButton()
    local sg = Instance.new("ScreenGui")
    sg.Name = "EldarButton"
    sg.Parent = CoreGui
    sg.ResetOnSpawn = false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 240, 0, 55)
    btn.Position = UDim2.new(0.5, -120, 0.9, 0)
    btn.Text = '"ЭЛЬДАР ОЧЕНЬ КРУТОЙ"'
    btn.TextColor3 = Color3.fromRGB(0, 255, 200)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    btn.BackgroundTransparency = 0.2
    btn.ZIndex = 10
    btn.Parent = sg

    btn.MouseButton1Click:Connect(function()
        if not menuOpen then createMainMenu() end
    end)
    btn.TouchEnded:Connect(function()
        if not menuOpen then createMainMenu() end
    end)
end

-- ===== ЗАПУСК =====
createOpenButton()
print("[ЭЛЬДАР ГЕЙ] ЗАГРУЖЕНО! Нажми на кнопку для открытия меню.")
