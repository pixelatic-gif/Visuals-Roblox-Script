local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Rainbow Power",
	LoadingTitle = "Rainbow System",
	LoadingSubtitle = "Visual Effects",
	ConfigurationSaving = {
		Enabled = false
	}
})

local Tab = Window:CreateTab("Effects", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ВСЕ НАСТРОЙКИ ВЫКЛЮЧЕНЫ ПО УМОЛЧАНИЮ (false)
local Settings = {
	ChinaHat = false,
	Wings = false,
	Halo = false,
	Aura = false,
	Jump = false,
	Walk = false,
	Trail = false,
	AirTrails = false,
	TrailLifetime = 1.2,
	TrailTransparency = 0.15,
	
	-- НАСТРОЙКИ ДЛЯ НОЖА
	KnifeTrail = false,
	KnifeRainbow = false,
	KnifeColor = Color3.fromRGB(255, 0, 100),

	-- НАСТРОЙКИ ДЛЯ GHOST CLONES
	GhostClones = false,
	GhostRainbow = false,
	GhostColor = Color3.fromRGB(0, 255, 255),
	GhostLifetime = 0.6,
	GhostDelay = 0.08,

	-- НАСТРОЙКИ FOV
	DynamicFOV = false,
	BaseFOV = 70,
	MaxFOV = 95,

	-- НАСТРОЙКИ HIGHLIGHT (ESP)
	HighlightEnabled = false,
	HighlightRainbow = false,
	HighlightFillColor = Color3.fromRGB(255, 0, 0),
	HighlightOutlineColor = Color3.fromRGB(255, 255, 255),
	HighlightFillTransparency = 0.5,
	HighlightOutlineTransparency = 0
}

-- ЭЛЕМЕНТЫ МЕНЮ
Tab:CreateToggle({
	Name = "Rainbow Wings",
	CurrentValue = Settings.Wings,
	Callback = function(v) Settings.Wings = v end
})

Tab:CreateToggle({
	Name = "China Hat (Perfect Smooth)",
	CurrentValue = Settings.ChinaHat,
	Callback = function(v) Settings.ChinaHat = v end
})

Tab:CreateToggle({
	Name = "Halo",
	CurrentValue = Settings.Halo,
	Callback = function(v) Settings.Halo = v end
})

Tab:CreateToggle({
	Name = "Aura",
	CurrentValue = Settings.Aura,
	Callback = function(v) Settings.Aura = v end
})

Tab:CreateToggle({
	Name = "Jump Effect",
	CurrentValue = Settings.Jump,
	Callback = function(v) Settings.Jump = v end
})

Tab:CreateToggle({
	Name = "Walk Bubbles",
	CurrentValue = Settings.Walk,
	Callback = function(v) Settings.Walk = v end
})

Tab:CreateToggle({
	Name = "Rainbow Trail (Player)",
	CurrentValue = Settings.Trail,
	Callback = function(v) Settings.Trail = v end
})

Tab:CreateToggle({
	Name = "Air Trails (In Air)",
	CurrentValue = Settings.AirTrails,
	Callback = function(v) Settings.AirTrails = v end
})

Tab:CreateSection("ESP / Player Highlight Settings")

Tab:CreateToggle({
	Name = "Highlight Enabled",
	CurrentValue = Settings.HighlightEnabled,
	Callback = function(v) Settings.HighlightEnabled = v end
})

Tab:CreateToggle({
	Name = "Rainbow Highlight Mode",
	CurrentValue = Settings.HighlightRainbow,
	Callback = function(v) Settings.HighlightRainbow = v end
})

Tab:CreateColorPicker({
    Name = "Fill Color (Тело)",
    Color = Settings.HighlightFillColor,
    Callback = function(Value)
        Settings.HighlightFillColor = Value
    end
})

Tab:CreateColorPicker({
    Name = "Outline Color (Контур)",
    Color = Settings.HighlightOutlineColor,
    Callback = function(Value)
        Settings.HighlightOutlineColor = Value
    end
})

Tab:CreateSlider({
	Name = "Fill Transparency",
	Range = {0, 1},
	Increment = 0.05,
	CurrentValue = Settings.HighlightFillTransparency,
	Callback = function(Value)
		Settings.HighlightFillTransparency = Value
	end,
})

Tab:CreateSlider({
	Name = "Outline Transparency",
	Range = {0, 1},
	Increment = 0.05,
	CurrentValue = Settings.HighlightOutlineTransparency,
	Callback = function(Value)
		Settings.HighlightOutlineTransparency = Value
	end,
})

Tab:CreateSection("Camera & FOV Settings")

Tab:CreateToggle({
	Name = "Dynamic Speed FOV",
	CurrentValue = Settings.DynamicFOV,
	Callback = function(v) 
		Settings.DynamicFOV = v 
		if not v and camera then
			camera.FieldOfView = Settings.BaseFOV
		end
	end
})

Tab:CreateSlider({
	Name = "Base FOV",
	Range = {60, 110},
	Increment = 1,
	CurrentValue = Settings.BaseFOV,
	Callback = function(Value)
		Settings.BaseFOV = Value
		if not Settings.DynamicFOV and camera then
			camera.FieldOfView = Value
		end
	end,
})

Tab:CreateSlider({
	Name = "Max Speed FOV",
	Range = {70, 130},
	Increment = 1,
	CurrentValue = Settings.MaxFOV,
	Callback = function(Value)
		Settings.MaxFOV = Value
	end,
})

Tab:CreateSection("Knife Trail Settings")

Tab:CreateToggle({
	Name = "Knife Trail Enabled",
	CurrentValue = Settings.KnifeTrail,
	Callback = function(v) Settings.KnifeTrail = v end
})

Tab:CreateToggle({
	Name = "Knife Rainbow Mode",
	CurrentValue = Settings.KnifeRainbow,
	Callback = function(v) Settings.KnifeRainbow = v end
})

Tab:CreateColorPicker({
    Name = "Knife Custom Color",
    Color = Settings.KnifeColor,
    Callback = function(Value)
        Settings.KnifeColor = Value
    end
})

Tab:CreateSection("Ghost Clones (Phantom Trail)")

Tab:CreateToggle({
	Name = "Ghost Clones Enabled",
	CurrentValue = Settings.GhostClones,
	Callback = function(v) Settings.GhostClones = v end
})

Tab:CreateToggle({
	Name = "Ghost Rainbow Mode",
	CurrentValue = Settings.GhostRainbow,
	Callback = function(v) Settings.GhostRainbow = v end
})

Tab:CreateColorPicker({
    Name = "Ghost Custom Color",
    Color = Settings.GhostColor,
    Callback = function(Value)
        Settings.GhostColor = Value
    end
})

Tab:CreateSlider({
	Name = "Ghost Lifetime",
	Range = {0.2, 2.0},
	Increment = 0.1,
	Suffix = "s",
	CurrentValue = Settings.GhostLifetime,
	Callback = function(Value)
		Settings.GhostLifetime = Value
	end,
})

Tab:CreateSlider({
	Name = "Ghost Spawn Delay",
	Range = {0.02, 0.3},
	Increment = 0.01,
	Suffix = "s",
	CurrentValue = Settings.GhostDelay,
	Callback = function(Value)
		Settings.GhostDelay = Value
	end,
})

Tab:CreateSection("Trail Parameters")

Tab:CreateSlider({
	Name = "Trail Lifetime (Seconds)",
	Range = {0.3, 3.0},
	Increment = 0.1,
	Suffix = "s",
	CurrentValue = Settings.TrailLifetime,
	Flag = "TrailLifetimeSlider",
	Callback = function(Value)
		Settings.TrailLifetime = Value
	end,
})

Tab:CreateSlider({
	Name = "Trail Transparency",
	Range = {0, 0.9},
	Increment = 0.05,
	Suffix = "",
	CurrentValue = Settings.TrailTransparency,
	Flag = "TrailTransparencySlider",
	Callback = function(Value)
		Settings.TrailTransparency = Value
	end,
})

-- ЛОГИКА ЭФФЕКТОВ
local character, head, torso, rootPart, humanoid
local folder
local mainCone, innerCone
local wingsParts = {Left = {}, Right = {}}
local halo = {}
local aura = {}
local lastWalkBubbleTime = 0
local lastAirTrailTime = 0
local lastGhostSpawnTime = 0
local lastRootPos = nil
local isJumping = false

-- Переменные ножа
local currentKnife = nil
local knifeTrailObj = nil
local knifeAtt0, knifeAtt1 = nil, nil

local FEATHERS_PER_WING = 12

local function CleanUpKnifeTrail()
	if knifeTrailObj then pcall(function() knifeTrailObj:Destroy() end) knifeTrailObj = nil end
	if knifeAtt0 then pcall(function() knifeAtt0:Destroy() end) knifeAtt0 = nil end
	if knifeAtt1 then pcall(function() knifeAtt1:Destroy() end) knifeAtt1 = nil end
	currentKnife = nil
end

local function CleanUp()
	CleanUpKnifeTrail()
	if folder then pcall(function() folder:Destroy() end) folder = nil end
	if mainCone then pcall(function() mainCone:Destroy() end) mainCone = nil end
	if innerCone then pcall(function() innerCone:Destroy() end) innerCone = nil end
	wingsParts = {Left = {}, Right = {}}
	halo = {}
	aura = {}
end

local function CreateKnifeTrail(knifeTool)
	CleanUpKnifeTrail()
	if not knifeTool then return end

	local handle = knifeTool:FindFirstChild("Handle") or knifeTool:FindFirstChildOfClass("Part") or knifeTool:FindFirstChildOfClass("MeshPart")
	if not handle then return end

	currentKnife = knifeTool

	knifeAtt0 = Instance.new("Attachment")
	knifeAtt0.Position = Vector3.new(0, -handle.Size.Y / 2, 0)
	knifeAtt0.Parent = handle

	knifeAtt1 = Instance.new("Attachment")
	knifeAtt1.Position = Vector3.new(0, handle.Size.Y / 2, 0)
	knifeAtt1.Parent = handle

	knifeTrailObj = Instance.new("Trail")
	knifeTrailObj.Attachment0 = knifeAtt0
	knifeTrailObj.Attachment1 = knifeAtt1
	knifeTrailObj.FaceCamera = true
	knifeTrailObj.LightEmission = 0.8
	knifeTrailObj.Parent = handle
end

local function CreateEffects()
	CleanUp()

	folder = Instance.new("Folder")
	folder.Name = "RainbowPower"
	folder.Parent = workspace

	-- China Hat
	mainCone = Instance.new("ConeHandleAdornment")
	mainCone.Name = "ChinaHatMain"
	mainCone.Height = 1.2
	mainCone.Radius = 2.4
	mainCone.Transparency = 0.45
	mainCone.CFrame = CFrame.Angles(math.rad(90), 0, 0)

	innerCone = Instance.new("ConeHandleAdornment")
	innerCone.Name = "ChinaHatInner"
	innerCone.Height = 1.15
	innerCone.Radius = 2.35
	innerCone.Transparency = 0.7
	innerCone.CFrame = CFrame.Angles(math.rad(90), 0, 0)

	-- СОЗДАНИЕ КРЫЛЬЕВ
	for i = 1, FEATHERS_PER_WING do
		local pL = Instance.new("Part")
		pL.Size = Vector3.new(0.1, 0.35 + (i * 0.12), 0.8 + (i * 0.15))
		pL.Material = Enum.Material.Neon
		pL.Anchored = true
		pL.CanCollide = false
		pL.Parent = folder
		table.insert(wingsParts.Left, pL)

		local pR = Instance.new("Part")
		pR.Size = Vector3.new(0.1, 0.35 + (i * 0.12), 0.8 + (i * 0.15))
		pR.Material = Enum.Material.Neon
		pR.Anchored = true
		pR.CanCollide = false
		pR.Parent = folder
		table.insert(wingsParts.Right, pR)
	end

	-- Halo
	for i = 1, 48 do
		local p = Instance.new("Part")
		p.Shape = Enum.PartType.Cylinder
		p.Size = Vector3.new(.12, .25, .25)
		p.Anchored = true
		p.CanCollide = false
		p.Material = Enum.Material.Neon
		p.Parent = folder
		table.insert(halo, p)
	end

	-- Aura
	for i = 1, 40 do
		local p = Instance.new("Part")
		p.Size = Vector3.new(.25, .25, .25)
		p.Anchored = true
		p.CanCollide = false
		p.Material = Enum.Material.Neon
		p.Parent = folder
		table.insert(aura, p)
	end
end

-- ФУНКЦИЯ СПАВНА ГОСТ-КЛОНА (GHOST CLONES)
local function SpawnGhostClone()
	if not character or not folder then return end

	local ghostModel = Instance.new("Model")
	ghostModel.Name = "GhostClone"

	local cloneColor = Settings.GhostRainbow and Color3.fromHSV(tick() % 1, 1, 1) or Settings.GhostColor

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
			local clonePart = Instance.new("Part")
			clonePart.Size = child.Size
			clonePart.CFrame = child.CFrame
			clonePart.Material = Enum.Material.Neon
			clonePart.Color = cloneColor
			clonePart.Transparency = 0.4
			clonePart.Anchored = true
			clonePart.CanCollide = false
			clonePart.Parent = ghostModel
		end
	end

	ghostModel.Parent = folder

	task.spawn(function()
		local startTime = tick()
		while tick() - startTime < Settings.GhostLifetime do
			local progress = (tick() - startTime) / Settings.GhostLifetime
			for _, p in ipairs(ghostModel:GetChildren()) do
				if p:IsA("BasePart") then
					p.Transparency = 0.4 + (progress * 0.6)
				end
			end
			task.wait()
		end
		ghostModel:Destroy()
	end)
end

local function createCylinderBubble(startDiameter, height)
	if not rootPart or not folder then return end
	local b = Instance.new("Part")
	b.Shape = Enum.PartType.Cylinder
	b.Material = Enum.Material.Neon
	b.Anchored = true
	b.CanCollide = false
	b.Transparency = 0.2
	
	local basePos = rootPart.Position - Vector3.new(0, 2.8, 0)
	b.Size = Vector3.new(height, startDiameter, startDiameter)
	b.CFrame = CFrame.new(basePos) * CFrame.Angles(0, 0, math.rad(90))
	b.Color = Color3.fromHSV(tick() % 1, 1, 1)
	b.Parent = folder

	return b
end

local function SpawnCustomTrailSegment(p1, p2)
	if not Settings.Trail or not folder then return end

	local distance = (p1 - p2).Magnitude
	if distance < 0.05 then return end

	local segment = Instance.new("Part")
	segment.Material = Enum.Material.Neon
	segment.Shape = Enum.PartType.Block
	segment.Anchored = true
	segment.CanCollide = false
	segment.Size = Vector3.new(0.3, 2.8, distance)
	segment.CFrame = CFrame.lookAt((p1 + p2) / 2, p2)
	segment.Color = Color3.fromHSV(tick() % 1, 1, 1)
	segment.Transparency = Settings.TrailTransparency
	segment.Parent = folder

	local tweenInfo = TweenInfo.new(Settings.TrailLifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goals = {
		Size = Vector3.new(0.01, 0.05, distance),
		Transparency = 1
	}

	local tween = TweenService:Create(segment, tweenInfo, goals)
	tween:Play()
	tween.Completed:Connect(function()
		segment:Destroy()
	end)
end

local function SpawnAirTrail()
	if not Settings.AirTrails or not folder or not rootPart then return end

	local p = Instance.new("Part")
	p.Material = Enum.Material.Neon
	p.Shape = Enum.PartType.Cylinder
	p.Anchored = true
	p.CanCollide = false
	p.Transparency = 0.2
	p.Color = Color3.fromHSV(tick() % 1, 1, 1)

	local angle = math.rad(math.random(0, 360))
	local radius = math.random(15, 30) / 10
	local offset = Vector3.new(math.cos(angle) * radius, math.random(-10, 10) / 10, math.sin(angle) * radius)
	
	p.Size = Vector3.new(math.random(20, 40) / 10, 0.1, 0.1)
	p.CFrame = CFrame.new(rootPart.Position + offset) * CFrame.Angles(0, 0, math.rad(90))
	p.Parent = folder

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goals = {
		Position = p.Position + Vector3.new(0, 2, 0),
		Size = Vector3.new(0.1, 0.02, 0.02),
		Transparency = 1
	}

	local tween = TweenService:Create(p, tweenInfo, goals)
	tween:Play()
	tween.Completed:Connect(function()
		p:Destroy()
	end)
end

local function WalkBubble()
	if not Settings.Walk or not rootPart then return end

	local b = createCylinderBubble(1.6, 0.15)
	if not b then return end
	local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goals = {
		Size = Vector3.new(0.02, 3.2, 3.2),
		Transparency = 1
	}

	local tween = TweenService:Create(b, tweenInfo, goals)
	tween:Play()
	tween.Completed:Connect(function() b:Destroy() end)
end

local function JumpEffect()
	if not Settings.Jump or not rootPart then return end

	local b = createCylinderBubble(2.2, 0.2)
	if not b then return end
	local tweenInfo = TweenInfo.new(0.65, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local goals = {
		Size = Vector3.new(0.02, 7.5, 7.5),
		Transparency = 1
	}

	local tween = TweenService:Create(b, tweenInfo, goals)
	tween:Play()
	tween.Completed:Connect(function() b:Destroy() end)
end

-- ВЕЧНЫЙ МОНИТОР ДЛЯ MM2 И НОЖА
task.spawn(function()
	while true do
		task.wait(0.3)
		local char = player.Character
		if char then
			local h = char:FindFirstChild("Head")
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChildOfClass("Humanoid")
			local t = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")

			if h and hrp and hum and t then
				if character ~= char or not folder or not folder.Parent or not mainCone or mainCone.Adornee ~= h then
					character = char
					head = h
					rootPart = hrp
					humanoid = hum
					torso = t
					lastRootPos = rootPart.Position

					CreateEffects()

					if mainCone and innerCone then
						mainCone.Adornee = head
						mainCone.Parent = head
						innerCone.Adornee = head
						innerCone.Parent = head
					end
				end

				-- ДЕТЕКТИРОВАНИЕ НОЖА В РУКЕ
				local heldTool = char:FindFirstChildOfClass("Tool")
				if heldTool and (heldTool.Name:lower():find("knife") or heldTool:FindFirstChild("KnifeServer") or heldTool:FindFirstChild("Stab")) then
					if currentKnife ~= heldTool or not knifeTrailObj or not knifeTrailObj.Parent then
						CreateKnifeTrail(heldTool)
					end
				else
					if currentKnife then
						CleanUpKnifeTrail()
					end
				end
			end
		end
	end
end)

-- УПРАВЛЕНИЕ HIGHLIGHT ДЛЯ ВСЕХ ИГРОКОВ
local function UpdatePlayerHighlights()
	local rainbowColor = Color3.fromHSV(tick() % 1, 1, 1)

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local char = p.Character
			local hl = char:FindFirstChild("ESP_Highlight")

			if Settings.HighlightEnabled then
				if not hl then
					hl = Instance.new("Highlight")
					hl.Name = "ESP_Highlight"
					hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					hl.Parent = char
				end

				hl.Enabled = true
				hl.FillTransparency = Settings.HighlightFillTransparency
				hl.OutlineTransparency = Settings.HighlightOutlineTransparency

				if Settings.HighlightRainbow then
					hl.FillColor = rainbowColor
					hl.OutlineColor = rainbowColor
				else
					hl.FillColor = Settings.HighlightFillColor
					hl.OutlineColor = Settings.HighlightOutlineColor
				end
			else
				if hl then
					hl.Enabled = false
				end
			end
		end
	end
end

-- ОСНОВНОЙ ЦИКЛ ОТРЕСОВКИ
RunService.RenderStepped:Connect(function(deltaTime)
	-- ОБНОВЛЕНИЕ HIGHLIGHT
	UpdatePlayerHighlights()

	if not character or not head or not head.Parent or not torso or not torso.Parent or not rootPart or not rootPart.Parent or not humanoid then 
		return 
	end

	local t = tick()
	local currentPos = rootPart.Position

	-- 0. ДИНАМИЧЕСКИЙ DYNAMIC SPEED FOV
	if Settings.DynamicFOV and camera then
		local moveSpeed = rootPart.AssemblyLinearVelocity.Magnitude
		local targetFOV = Settings.BaseFOV

		if moveSpeed > 2 then
			local speedRatio = math.clamp((moveSpeed - 2) / 20, 0, 1)
			targetFOV = Settings.BaseFOV + ((Settings.MaxFOV - Settings.BaseFOV) * speedRatio)
		end

		camera.FieldOfView = camera.FieldOfView + (targetFOV - camera.FieldOfView) * math.clamp(deltaTime * 8, 0, 1)
	end

	-- 1. СПАВН GHOST CLONES ПРИ ДВИЖЕНИИ
	if Settings.GhostClones and rootPart.AssemblyLinearVelocity.Magnitude > 2 then
		if t - lastGhostSpawnTime >= Settings.GhostDelay then
			lastGhostSpawnTime = t
			SpawnGhostClone()
		end
	end

	-- 2. РЕНДЕР И ОБНОВЛЕНИЕ ТРАЙЛА НОЖА
	if knifeTrailObj and knifeTrailObj.Parent then
		knifeTrailObj.Enabled = Settings.KnifeTrail
		knifeTrailObj.Lifetime = Settings.TrailLifetime
		
		local trans = Settings.TrailTransparency
		knifeTrailObj.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, trans),
			NumberSequenceKeypoint.new(1, 1)
		})

		if Settings.KnifeRainbow then
			local activeColor = Color3.fromHSV((t * 0.6) % 1, 1, 1)
			knifeTrailObj.Color = ColorSequence.new(activeColor)
		else
			knifeTrailObj.Color = ColorSequence.new(Settings.KnifeColor)
		end
	end

	-- 3. РЕНДЕР И АНИМАЦИЯ КРЫЛЬЕВ
	local flapAngle = math.sin(t * 4) * 0.35
	if humanoid.FloorMaterial == Enum.Material.Air then
		flapAngle = math.sin(t * 8) * 0.55
	end

	if wingsParts.Left then
		for i, part in ipairs(wingsParts.Left) do
			part.Transparency = Settings.Wings and 0.25 or 1
			if Settings.Wings then
				local spread = (i / FEATHERS_PER_WING)
				local angleY = math.rad(15 + spread * 45) + flapAngle
				local angleZ = math.rad(-10 - spread * 25)

				part.CFrame = torso.CFrame * CFrame.new(-0.6 - (spread * 1.6), 0.2 + (spread * 0.8), 0.6)
					* CFrame.Angles(0, angleY, angleZ)
				part.Color = Color3.fromHSV((t * 0.4 + spread * 0.5) % 1, 1, 1)
			end
		end
	end

	if wingsParts.Right then
		for i, part in ipairs(wingsParts.Right) do
			part.Transparency = Settings.Wings and 0.25 or 1
			if Settings.Wings then
				local spread = (i / FEATHERS_PER_WING)
				local angleY = math.rad(-15 - spread * 45) - flapAngle
				local angleZ = math.rad(10 + spread * 25)

				part.CFrame = torso.CFrame * CFrame.new(0.6 + (spread * 1.6), 0.2 + (spread * 0.8), 0.6)
					* CFrame.Angles(0, angleY, angleZ)
				part.Color = Color3.fromHSV((t * 0.4 + spread * 0.5) % 1, 1, 1)
			end
		end
	end

	-- 4. CHINA HAT
	if mainCone and innerCone and mainCone.Parent then
		local isVisible = Settings.ChinaHat
		mainCone.Visible = isVisible
		innerCone.Visible = isVisible

		if isVisible then
			local rainbowColor = Color3.fromHSV((t * 0.5) % 1, 1, 1)
			mainCone.Color3 = rainbowColor
			innerCone.Color3 = rainbowColor

			mainCone.Height = 1.1
			mainCone.Radius = 2.3
			mainCone.CFrame = CFrame.new(0, 0.8, 0) * CFrame.Angles(math.rad(90), 0, 0)
			
			innerCone.Height = 1.05
			innerCone.Radius = 2.25
			innerCone.CFrame = CFrame.new(0, 0.8, 0) * CFrame.Angles(math.rad(90), 0, 0)
		end
	end

	-- 5. Спавн шлейфа игрока
	if Settings.Trail and lastRootPos then
		if (currentPos - lastRootPos).Magnitude > 0.1 then
			SpawnCustomTrailSegment(lastRootPos, currentPos)
			lastRootPos = currentPos
		end
	else
		lastRootPos = currentPos
	end

	-- 6. ПРЫЖОК И AIR TRAILS
	local velocityY = rootPart.AssemblyLinearVelocity.Y
	if humanoid.FloorMaterial == Enum.Material.Air then
		if t - lastAirTrailTime > 0.05 then
			lastAirTrailTime = t
			SpawnAirTrail()
		end

		if velocityY > 10 and not isJumping then
			isJumping = true
			JumpEffect()
		end
	else
		isJumping = false
	end

	-- 7. ХОДЬБА
	if humanoid.MoveDirection.Magnitude > 0 and humanoid.FloorMaterial ~= Enum.Material.Air then
		if t - lastWalkBubbleTime > 0.22 then
			lastWalkBubbleTime = t
			WalkBubble()
		end
	end

	-- 8. HALO
	for i, p in ipairs(halo) do
		p.Transparency = Settings.Halo and 0 or 1
		if Settings.Halo then
			local a = i / 48 * math.pi * 2
			p.CFrame = CFrame.new(
				head.Position + Vector3.new(math.cos(a) * 1.3, 1.1, math.sin(a) * 1.3)
			) * CFrame.Angles(0, a, math.rad(90))
			p.Color = Color3.fromHSV((t + i / 48) % 1, 1, 1)
		end
	end

	-- 9. MOVING AURA
	for i, p in ipairs(aura) do
		p.Transparency = Settings.Aura and 0 or 1
		if Settings.Aura then
			local a = i / 40 * math.pi * 2 + t * 1.5
			p.Position = torso.Position + Vector3.new(
				math.cos(a) * 2,
				math.sin(t * 3 + i) * .5,
				math.sin(a) * 2
			)
			p.Color = Color3.fromHSV((t + i / 40) % 1, 1, 1)
		end
	end
end)
