local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
-- Pulse size updated to 2e11
local huge = Vector3.new(2e11, 2e11, 2e11)
-- Set to 1 Billion Studs (1e9)
local farLocation = Vector3.new(1000000000, 500, 1000000000)

local farTPEnabled = false
local savedPosition = nil
local farPlatform = nil
local infJump = false

local buttons = {}

--================ GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "AdrienHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--================ TITLE =================
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 190, 0, 30)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 0.35
title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
title.Text = "Adrien's Scripts"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = gui

Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

--================ REFRESH BUTTON =================
local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 30, 0, 30)
refreshBtn.Position = UDim2.new(0, 175, 0, 10)
refreshBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
refreshBtn.Text = "🔄"
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 18
refreshBtn.Parent = gui

Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 8)

--================ IMPROVED DRAG SYSTEM (NO SNAPPING) =================
local function makeDraggable(btn)
	local dragging = false
	local dragInput
	local dragStart
	local startPos
	local hasMoved = false

	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			hasMoved = false
			dragStart = input.Position
			startPos = btn.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	btn.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
				hasMoved = true
			end
			btn.Position = UDim2.new(
				startPos.X.Scale, 
				startPos.X.Offset + delta.X, 
				startPos.Y.Scale, 
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	return function() return hasMoved end
end

--================ BUTTON CREATOR =================
local function createButton(text, posY, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 110, 0, 44)
	btn.Position = UDim2.new(0, 10, 0, posY)
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 17
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = true
	btn.Parent = gui
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
	
	local dragCheck = makeDraggable(btn)
	table.insert(buttons, btn)
	return btn, dragCheck
end

--================ BUILD UI =================
local function buildUI()
	for _, b in ipairs(buttons) do if b then b:Destroy() end end
	buttons = {}
	
	local pulseBtn, pulseDrag = createButton("PULSE", 50, Color3.fromRGB(0, 145, 255))
	local tpBtn, tpDrag       = createButton("TP", 102, Color3.fromRGB(255, 75, 75))
	local farBtn, farDrag     = createButton(farTPEnabled and "RETURN" or "FAR TP", 154, Color3.fromRGB(130, 70, 255))
	local jumpBtn, jumpDrag   = createButton(infJump and "JUMP ON" or "INF JUMP", 206, Color3.fromRGB(0, 220, 120))

	--================ PULSE (0.10 SECOND BURST) =================
	pulseBtn.MouseButton1Click:Connect(function()
		if pulseDrag() then return end
		
		local duration = 0.10
		local startTime = tick()
		local connection
		
		connection = RunService.Heartbeat:Connect(function()
			if tick() - startTime >= duration then
				connection:Disconnect()
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= player and plr.Character then
						local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
						if hrp then
							hrp.Size = Vector3.new(2, 2, 1)
							hrp.Transparency = 1
						end
					end
				end
				return
			end
			
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character then
					local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						hrp.Size = huge
						hrp.Transparency = 0.35
						hrp.CanCollide = false
					end
				end
			end
		end)
	end)

	--================ TP =================
	tpBtn.MouseButton1Click:Connect(function()
		if tpDrag() then return end
		local char = player.Character
		local myRoot = char and char:FindFirstChild("HumanoidRootPart")
		if not myRoot then return end
		
		local oldPos = myRoot.CFrame
		local closest, dist = nil, math.huge
		for _, plr in Players:GetPlayers() do
			if plr ~= player and plr.Character then
				local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local d = (myRoot.Position - hrp.Position).Magnitude
					if d < dist and d > 8 then dist = d closest = hrp end
				end
			end
		end
		
		if not closest then return end
		local start = tick()
		local con
		con = RunService.RenderStepped:Connect(function()
			if tick() - start >= 0.28 then con:Disconnect() myRoot.CFrame = oldPos return end
			if closest and closest.Parent then
				local front = closest.Position + closest.CFrame.LookVector * 2.8
				myRoot.CFrame = myRoot.CFrame:Lerp(CFrame.lookAt(front, closest.Position), 0.65)
			end
		end)
	end)

	--================ FAR TP (1B STUDS) + NEON PLATFORM =================
	farBtn.MouseButton1Click:Connect(function()
		if farDrag() then return end
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		
		if not farTPEnabled then
			savedPosition = root.CFrame
			
			-- Create base so you don't fall into the null zone
			farPlatform = Instance.new("Part")
			farPlatform.Name = "VoidBase"
			farPlatform.Size = Vector3.new(3000, 10, 3000)
			farPlatform.Position = farLocation - Vector3.new(0, 10, 0)
			farPlatform.Anchored = true
			farPlatform.Material = Enum.Material.Neon
			farPlatform.Color = Color3.fromRGB(0, 255, 255)
			farPlatform.Parent = workspace
			
			root.CFrame = CFrame.new(farLocation)
			farTPEnabled = true
			farBtn.Text = "RETURN"
		else
			root.CFrame = savedPosition
			if farPlatform then farPlatform:Destroy() end
			farTPEnabled = false
			farBtn.Text = "FAR TP"
		end
	end)

	--================ INF JUMP =================
	jumpBtn.MouseButton1Click:Connect(function()
		if jumpDrag() then return end
		infJump = not infJump
		jumpBtn.Text = infJump and "JUMP ON" or "INF JUMP"
	end)
end

--================ EVENTS =================
UIS.JumpRequest:Connect(function()
	if infJump then
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

buildUI()
refreshBtn.MouseButton1Click:Connect(buildUI)
