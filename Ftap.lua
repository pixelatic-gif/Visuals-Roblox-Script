local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Скорость персонажа (стандартная 16, настраиваемая до 70)
local characterSpeed = 30 -- Начальное значение

local isControlling = false
local currentRocket = nil
local nosePart = nil

local cameraConn = nil
local physicsConn = nil
local inputConn = nil

local yaw = 0
local pitch = 0

-- =================================================================
-- 1. GUI В СТИЛЕ BUILD A BOAT FOR TREASURE (ПЕРЕТАСКИВАЕМОЕ)
-- =================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FTAP_DraggableRocketGUI"
screenGui.ResetOnSpawn = false

local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("FTAP_DraggableRocketGUI")
if oldGui then oldGui:Destroy() end

screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главная перетаскиваемая рамка
local babftFrame = Instance.new("Frame")
babftFrame.Name = "BABFT_Frame"
babftFrame.Size = UDim2.new(0, 240, 0, 150)
babftFrame.Position = UDim2.new(0.5, -120, 0.72, 0)
babftFrame.BackgroundColor3 = Color3.fromRGB(40, 32, 25)
babftFrame.BackgroundTransparency = 0.2
babftFrame.Active = true
babftFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = babftFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(212, 175, 55)
frameStroke.Thickness = 2.5
frameStroke.Parent = babftFrame

-- Заголовок (Плашка для перетаскивания)
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleHeader"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 2)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🚀 РАКЕТА FTAP (✋ ТАЩИ)"
titleLabel.TextColor3 = Color3.fromRGB(255, 225, 150)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.Parent = babftFrame

-- Главная кнопка УПРАВЛЕНИЯ / СБРОСА
local mainButton = Instance.new("TextButton")
mainButton.Name = "MainButton"
mainButton.Size = UDim2.new(0.9, 0, 0, 40)
mainButton.Position = UDim2.new(0.05, 0, 0.24, 0)
mainButton.BackgroundColor3 = Color3.fromRGB(45, 180, 90)
mainButton.Text = "🚀 УПРАВЛЯТЬ (НАЦЕЛЬСЯ)"
mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainButton.Font = Enum.Font.FredokaOne
mainButton.TextSize = 13
mainButton.Parent = babftFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = mainButton

-- --- БЛОК РЕГУЛИРОВКИ СКОРОСТИ (16 - 70) ---
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 20)
speedLabel.Position = UDim2.new(0, 0, 0.55, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Скорость (16-70): " .. tostring(characterSpeed)
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.FredokaOne
speedLabel.TextSize = 12
speedLabel.Parent = babftFrame

-- Кнопка МЕНЬШЕ (-)
local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 35, 0, 30)
minusBtn.Position = UDim2.new(0.08, 0, 0.72, 0)
minusBtn.BackgroundColor3 = Color3.fromRGB(70, 55, 45)
minusBtn.Text = "-"
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.Font = Enum.Font.FredokaOne
minusBtn.TextSize = 18
minusBtn.Parent = babftFrame

local minusCorner = Instance.new("UICorner")
minusCorner.CornerRadius = UDim.new(0, 6)
minusCorner.Parent = minusBtn

-- Кнопка БОЛЬШЕ (+)
local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 35, 0, 30)
plusBtn.Position = UDim2.new(0.77, 0, 0.72, 0)
plusBtn.BackgroundColor3 = Color3.fromRGB(70, 55, 45)
plusBtn.Text = "+"
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.Font = Enum.Font.FredokaOne
plusBtn.TextSize = 18
plusBtn.Parent = babftFrame

local plusCorner = Instance.new("UICorner")
plusCorner.CornerRadius = UDim.new(0, 6)
plusCorner.Parent = plusBtn

-- Индикатор скорости
local speedBarBg = Instance.new("Frame")
speedBarBg.Size = UDim2.new(0.5, 0, 0, 12)
speedBarBg.Position = UDim2.new(0.25, 0, 0.78, 0)
speedBarBg.BackgroundColor3 = Color3.fromRGB(20, 15, 10)
speedBarBg.Parent = babftFrame

local speedBarFill = Instance.new("Frame")
speedBarFill.Size = UDim2.new((characterSpeed - 16) / (70 - 16), 0, 1, 0)
speedBarFill.BackgroundColor3 = Color3.fromRGB(212, 175, 55)
speedBarFill.Parent = speedBarBg

local function updateSpeed(newSpeed)
	characterSpeed = math.clamp(newSpeed, 16, 70)
	speedLabel.Text = "Скорость (16-70): " .. tostring(math.floor(characterSpeed))
	speedBarFill.Size = UDim2.new((characterSpeed - 16) / (70 - 16), 0, 1, 0)
end

minusBtn.MouseButton1Click:Connect(function() updateSpeed(characterSpeed - 5) end)
plusBtn.MouseButton1Click:Connect(function() updateSpeed(characterSpeed + 5) end)

-- =================================================================
-- 2. ЛОГИКА ПЕРЕТАСКИВАНИЯ ОКНА (DRAGGABLE GUI)
-- =================================================================
local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
	local delta = input.Position - dragStart
	babftFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

babftFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = babftFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

babftFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		updateInput(input)
	end
end)

-- =================================================================
-- 3. СБРОС И ВОЗВРАТ КАМЕРЫ НА ГОЛОВУ
-- =================================================================
local function stopControl()
	isControlling = false
	currentRocket = nil
	nosePart = nil

	if cameraConn then cameraConn:Disconnect() cameraConn = nil end
	if physicsConn then physicsConn:Disconnect() physicsConn = nil end
	if inputConn then inputConn:Disconnect() inputConn = nil end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default

	mainButton.Text = "🚀 УПРАВЛЯТЬ (НАЦЕЛЬСЯ)"
	mainButton.BackgroundColor3 = Color3.fromRGB(45, 180, 90)

	-- Моментальный возврат камеры на голову
	camera.CameraType = Enum.CameraType.Custom
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		camera.CameraSubject = player.Character.Humanoid
	end
end

-- =================================================================
-- 4. ПОИСК И УПРАВЛЕНИЕ РАКЕТОЙ
-- =================================================================
local function getTargetObject()
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

	local unitRay = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {char}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 100, raycastParams)

	if result and result.Instance and not result.Instance.Anchored then
		return result.Instance:FindFirstAncestorOfClass("Model") or result.Instance
	end

	local pPos = char.HumanoidRootPart.Position
	local closest = nil
	local minDist = 25

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(char) then
			local dist = (obj.Position - pPos).Magnitude
			if dist < minDist then
				minDist = dist
				closest = obj:FindFirstAncestorOfClass("Model") or obj
			end
		end
	end

	return closest
end

local function startControl(target)
	if not target then return end

	nosePart = target:IsA("Model") and (target:FindFirstChild("NoseCone") or target:FindFirstChild("Tip") or target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")) or target

	if not nosePart then return end

	isControlling = true
	currentRocket = target

	mainButton.Text = "🛑 STOP / СБРОС"
	mainButton.BackgroundColor3 = Color3.fromRGB(200, 45, 45)

	local rx, ry, rz = nosePart.CFrame:ToOrientation()
	yaw = ry
	pitch = rx

	if not UserInputService.TouchEnabled then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end
	camera.CameraType = Enum.CameraType.Scriptable

	inputConn = UserInputService.InputChanged:Connect(function(input)
		if not isControlling then return end

		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Delta
			local sens = UserInputService.TouchEnabled and 0.4 or 0.3
			yaw = yaw - math.rad(delta.X * sens)
			pitch = math.clamp(pitch - math.rad(delta.Y * sens), math.rad(-80), math.rad(80))
		end
	end)

	cameraConn = RunService.RenderStepped:Connect(function()
		if not isControlling or not currentRocket or not currentRocket.Parent or not nosePart.Parent then
			stopControl()
			return
		end

		local rotCFrame = CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
		local nosePos = nosePart.Position + (nosePart.CFrame.LookVector * (nosePart.Size.Z / 2))

		camera.CFrame = CFrame.new(nosePos) * rotCFrame
	end)

	physicsConn = RunService.Heartbeat:Connect(function()
		if not isControlling or not currentRocket or not currentRocket.Parent or not nosePart.Parent then
			stopControl()
			return
		end

		local look = camera.CFrame.LookVector
		-- Пересчитываем скорость персонажа (16..70) в физическую скорость ракеты
		local actualRocketSpeed = characterSpeed * 4.5 
		nosePart.AssemblyLinearVelocity = look * actualRocketSpeed
		nosePart.CFrame = CFrame.lookAt(nosePart.Position, nosePart.Position + look)
	end)
end

mainButton.MouseButton1Click:Connect(function()
	if isControlling then
		stopControl()
	else
		local target = getTargetObject()
		if target then
			startControl(target)
		end
	end
end)
