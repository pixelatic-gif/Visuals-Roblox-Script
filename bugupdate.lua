local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local characterSpeed = 30 -- Скорость (от 16 до 70)

local isControlling = false
local currentRocket = nil
local nosePart = nil

local renderConn = nil
local physicsConn = nil

-- =================================================================
-- 1. GUI (ПЕРЕТАСКИВАЕМОЕ)
-- =================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FTAP_SuperRocketGUI"
screenGui.ResetOnSpawn = false

local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("FTAP_SuperRocketGUI")
if oldGui then oldGui:Destroy() end

screenGui.Parent = player:WaitForChild("PlayerGui")

local babftFrame = Instance.new("Frame")
babftFrame.Name = "BABFT_Frame"
babftFrame.Size = UDim2.new(0, 240, 0, 150)
babftFrame.Position = UDim2.new(0.5, -120, 0.72, 0)
babftFrame.BackgroundColor3 = Color3.fromRGB(40, 32, 25)
babftFrame.BackgroundTransparency = 0.15
babftFrame.Active = true
babftFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = babftFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(212, 175, 55)
frameStroke.Thickness = 2.5
frameStroke.Parent = babftFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🚀 FTAP (Q: Полёт | X/C: Скорость)"
titleLabel.TextColor3 = Color3.fromRGB(255, 225, 150)
titleLabel.TextSize = 12
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.Parent = babftFrame

local mainButton = Instance.new("TextButton")
mainButton.Name = "MainButton"
mainButton.Size = UDim2.new(0.9, 0, 0, 38)
mainButton.Position = UDim2.new(0.05, 0, 0.24, 0)
mainButton.BackgroundColor3 = Color3.fromRGB(45, 180, 90)
mainButton.Text = "🚀 УПРАВЛЯТЬ [Q]"
mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainButton.Font = Enum.Font.FredokaOne
mainButton.TextSize = 13
mainButton.Parent = babftFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = mainButton

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 20)
speedLabel.Position = UDim2.new(0, 0, 0.55, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Скорость: " .. tostring(characterSpeed)
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.FredokaOne
speedLabel.TextSize = 12
speedLabel.Parent = babftFrame

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 45, 0, 28)
minusBtn.Position = UDim2.new(0.08, 0, 0.72, 0)
minusBtn.BackgroundColor3 = Color3.fromRGB(70, 55, 45)
minusBtn.Text = "- [C]"
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.Font = Enum.Font.FredokaOne
minusBtn.TextSize = 12
minusBtn.Parent = babftFrame

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 45, 0, 28)
plusBtn.Position = UDim2.new(0.73, 0, 0.72, 0)
plusBtn.BackgroundColor3 = Color3.fromRGB(70, 55, 45)
plusBtn.Text = "+ [X]"
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.Font = Enum.Font.FredokaOne
plusBtn.TextSize = 12
plusBtn.Parent = babftFrame

Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 6)

local function updateSpeed(newSpeed)
	characterSpeed = math.clamp(newSpeed, 16, 70)
	speedLabel.Text = "Скорость: " .. tostring(math.floor(characterSpeed))
end

minusBtn.MouseButton1Click:Connect(function() updateSpeed(characterSpeed - 5) end)
plusBtn.MouseButton1Click:Connect(function() updateSpeed(characterSpeed + 5) end)

-- =================================================================
-- 2. ПЕРЕТАСКИВАНИЕ ОКНА GUI
-- =================================================================
local dragging, dragStart, startPos
babftFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = babftFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		babftFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- =================================================================
-- 3. ПОИСК ЦЕЛИ И СБРОС
-- =================================================================
local function stopControl()
	isControlling = false
	currentRocket = nil
	nosePart = nil

	if renderConn then renderConn:Disconnect() renderConn = nil end
	if physicsConn then physicsConn:Disconnect() physicsConn = nil end

	mainButton.Text = "🚀 УПРАВЛЯТЬ [Q]"
	mainButton.BackgroundColor3 = Color3.fromRGB(45, 180, 90)

	camera.CameraType = Enum.CameraType.Custom
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		camera.CameraSubject = player.Character.Humanoid
	end
end

local function getTargetObject()
	local char = player.Character
	if not char then return nil end

	-- Проверка по лучу в центр экрана
	local unitRay = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {char}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 150, raycastParams)
	if result and result.Instance and not result.Instance.Anchored then
		return result.Instance:FindFirstAncestorOfClass("Model") or result.Instance
	end

	-- Ближайший предмет рядом
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	local closest, minDist = nil, 30
	for _, part in ipairs(Workspace:GetDescendants()) do
		if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(char) then
			local d = (part.Position - root.Position).Magnitude
			if d < minDist then
				minDist = d
				closest = part:FindFirstAncestorOfClass("Model") or part
			end
		end
	end

	return closest
end

-- =================================================================
-- 4. СТАРТ УПРАВЛЕНИЯ И ПОЛЁТА
-- =================================================================
local function startControl()
	local target = getTargetObject()
	if not target then
		mainButton.Text = "❌ НЕ ВИЖУ РАКЕТУ!"
		task.delay(1.5, function()
			if not isControlling then mainButton.Text = "🚀 УПРАВЛЯТЬ [Q]" end
		end)
		return
	end

	if target:IsA("Model") then
		nosePart = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
	else
		nosePart = target
	end

	if not nosePart then return end

	isControlling = true
	currentRocket = target

	mainButton.Text = "🛑 STOP / СБРОС [Q]"
	mainButton.BackgroundColor3 = Color3.fromRGB(200, 45, 45)

	-- Оставляем камеру в обычном режиме, но привязываем к ракету
	camera.CameraType = Enum.CameraType.Scriptable

	physicsConn = RunService.Heartbeat:Connect(function()
		if not isControlling or not nosePart or not nosePart.Parent then
			stopControl()
			return
		end

		local look = camera.CFrame.LookVector
		local speed = characterSpeed * 5

		-- Снимаем жесткие физические блокировки
		nosePart.AssemblyAngularVelocity = Vector3.zero
		nosePart.AssemblyLinearVelocity = look * speed

		-- Разворачиваем деталь строго в направлении взгляда камеры
		nosePart.CFrame = CFrame.lookAt(nosePart.Position, nosePart.Position + look)
	end)

	renderConn = RunService.RenderStepped:Connect(function()
		if not isControlling or not nosePart or not nosePart.Parent then return end

		-- Помещаем камеру чуть позади/на носу детали
		local nosePos = nosePart.Position + (nosePart.CFrame.LookVector * 2)
		camera.CFrame = CFrame.new(nosePos, nosePos + nosePart.CFrame.LookVector)
	end)
end

local function toggleControl()
	if isControlling then
		stopControl()
	else
		startControl()
	end
end

mainButton.MouseButton1Click:Connect(toggleControl)

-- =================================================================
-- 5. ГОРЯЧИЕ КЛАВИШИ (Q, X, C)
-- =================================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.Q then
		toggleControl()
	elseif input.KeyCode == Enum.KeyCode.X then
		updateSpeed(characterSpeed + 5)
	elseif input.KeyCode == Enum.KeyCode.C then
		updateSpeed(characterSpeed - 5)
	end
end)
