local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local characterSpeed = 30 -- Скорость (16 - 70)

local isControlling = false
local currentRocket = nil
local nosePart = nil

local cameraConn = nil
local physicsConn = nil

local yaw = 0
local pitch = 0

-- =================================================================
-- 1. GUI В СТИЛЕ BUILD A BOAT FOR TREASURE (ПЕРЕТАСКИВАЕМОЕ)
-- =================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FTAP_FixedRocketGUI"
screenGui.ResetOnSpawn = false

local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("FTAP_FixedRocketGUI")
if oldGui then oldGui:Destroy() end

screenGui.Parent = player:WaitForChild("PlayerGui")

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

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleHeader"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 2)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🚀 FTAP (Q: Полёт | X/C: Скорость)"
titleLabel.TextColor3 = Color3.fromRGB(255, 225, 150)
titleLabel.TextSize = 12
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.Parent = babftFrame

local mainButton = Instance.new("TextButton")
mainButton.Name = "MainButton"
mainButton.Size = UDim2.new(0.9, 0, 0, 40)
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
speedLabel.Text = "Скорость (16-70): " .. tostring(characterSpeed)
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.FredokaOne
speedLabel.TextSize = 12
speedLabel.Parent = babftFrame

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 45, 0, 30)
minusBtn.Position = UDim2.new(0.08, 0, 0.72, 0)
minusBtn.BackgroundColor3 = Color3.fromRGB(70, 55, 45)
minusBtn.Text = "- [C]"
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.Font = Enum.Font.FredokaOne
minusBtn.TextSize = 13
minusBtn.Parent = babftFrame

local minusCorner = Instance.new("UICorner")
minusCorner.CornerRadius = UDim.new(0, 6)
minusCorner.Parent = minusBtn

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 45, 0, 30)
plusBtn.Position = UDim2.new(0.73, 0, 0.72, 0)
plusBtn.BackgroundColor3 = Color3.fromRGB(70, 55, 45)
plusBtn.Text = "+ [X]"
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.Font = Enum.Font.FredokaOne
plusBtn.TextSize = 13
plusBtn.Parent = babftFrame

local plusCorner = Instance.new("UICorner")
plusCorner.CornerRadius = UDim.new(0, 6)
plusCorner.Parent = plusBtn

local speedBarBg = Instance.new("Frame")
speedBarBg.Size = UDim2.new(0.42, 0, 0, 12)
speedBarBg.Position = UDim2.new(0.29, 0, 0.78, 0)
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
-- 2. ПЕРЕТАСКИВАНИЕ ОКНА
-- =================================================================
local dragging, dragInput, dragStart, startPos

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
		local delta = input.Position - dragStart
		babftFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- =================================================================
-- 3. СБРОС УПРАВЛЕНИЯ
-- =================================================================
local function stopControl()
	isControlling = false
	currentRocket = nil
	nosePart = nil

	if cameraConn then cameraConn:Disconnect() cameraConn = nil end
	if physicsConn then physicsConn:Disconnect() physicsConn = nil end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default

	mainButton.Text = "🚀 УПРАВЛЯТЬ [Q]"
	mainButton.BackgroundColor3 = Color3.fromRGB(45, 180, 90)

	camera.CameraType = Enum.CameraType.Custom
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		camera.CameraSubject = player.Character.Humanoid
	end
end

-- =================================================================
-- 4. УПРАВЛЕНИЕ ПОЛЁТОМ (ИСПРАВЛЕННЫЙ ПОВОРОТ)
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

	mainButton.Text = "🛑 STOP / СБРОС [Q]"
	mainButton.BackgroundColor3 = Color3.fromRGB(200, 45, 45)

	-- Запоминаем стартовые углы камеры
	local _, camY, _ = camera.CFrame:ToOrientation()
	yaw = camY
	pitch = 0

	if not UserInputService.TouchEnabled then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end

	-- Движение и вращение ракеты строго по взгляду
	physicsConn = RunService.Heartbeat:Connect(function()
		if not isControlling or not currentRocket or not currentRocket.Parent or not nosePart.Parent then
			stopControl()
			return
		end

		local lookVector = camera.CFrame.LookVector
		local actualSpeed = characterSpeed * 4.5

		-- Принудительно сбрасываем вращение физического движка
		nosePart.AssemblyAngularVelocity = Vector3.zero
		nosePart.AssemblyLinearVelocity = lookVector * actualSpeed

		-- Поворачиваем ракету точно по направлению камеры
		nosePart.CFrame = CFrame.lookAt(nosePart.Position, nosePart.Position + lookVector)
	end)

	-- Привязка камеры к конусу
	cameraConn = RunService.RenderStepped:Connect(function()
		if not isControlling or not nosePart or not nosePart.Parent then return end
		
		-- Удерживаем камеру точно на носу ракеты
		local nosePos = nosePart.Position + (nosePart.CFrame.LookVector * (nosePart.Size.Z / 2))
		camera.CFrame = CFrame.new(nosePos, nosePos + nosePart.CFrame.LookVector)
	end)
end

local function toggleControl()
	if isControlling then
		stopControl()
	else
		local target = getTargetObject()
		if target then
			startControl(target)
		end
	end
end

mainButton.MouseButton1Click:Connect(toggleControl)

-- =================================================================
-- 5. КЛАВИШИ Q, X, C
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
