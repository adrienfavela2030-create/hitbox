local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local huge = Vector3.new(1e16,1e16,1e16)

local farTPEnabled = false
local savedPosition = nil
local platform = nil
local infJump = false

--================ GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "AdrienHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--================ TITLE =================
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0,170,0,30)
title.Position = UDim2.new(0,10,0,10)
title.BackgroundTransparency = 0.35
title.BackgroundColor3 = Color3.fromRGB(0,0,0)
title.Text = "Adrien's Scirpt's"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = gui

local tc = Instance.new("UICorner",title)
tc.CornerRadius = UDim.new(0,10)

--================ DRAG BUTTONS =================
local function makeDraggable(btn)
	local dragging = false
	local dragStart
	local startPos
	local moved = false

	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			dragStart = input.Position
			startPos = btn.Position
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then
			local delta = input.Position - dragStart
			if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
				moved = true
			end

			btn.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	return function()
		return moved
	end
end

local function createButton(text,posY,color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,110,0,44)
	btn.Position = UDim2.new(0,10,0,posY)
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.TextSize = 17
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = true
	btn.Parent = gui

	local c = Instance.new("UICorner",btn)
	c.CornerRadius = UDim.new(0,12)

	local s = Instance.new("UIStroke",btn)
	s.Thickness = 1.5
	s.Color = Color3.fromRGB(255,255,255)

	return btn, makeDraggable(btn)
end

local pulseBtn,pulseDrag = createButton("PULSE",50,Color3.fromRGB(0,145,255))
local tpBtn,tpDrag       = createButton("TP",102,Color3.fromRGB(255,75,75))
local farBtn,farDrag     = createButton("FAR TP",154,Color3.fromRGB(130,70,255))
local jumpBtn,jumpDrag   = createButton("INF JUMP",206,Color3.fromRGB(0,220,120))

--================ PULSE =================
pulseBtn.MouseButton1Click:Connect(function()
	if pulseDrag() then return end

	for _,plr in Players:GetPlayers() do
		if plr ~= player and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Size = huge
				hrp.Transparency = 0.35
				hrp.CanCollide = false
			end
		end
	end

	task.wait(0.18)

	for _,plr in Players:GetPlayers() do
		if plr ~= player and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Size = Vector3.new(2,2,1)
				hrp.Transparency = 1
			end
		end
	end
end)

--================ TP =================
tpBtn.MouseButton1Click:Connect(function()
	if tpDrag() then return end

	local char = player.Character
	if not char then return end
	local myRoot = char:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	local oldPos = myRoot.CFrame
	local closest = nil
	local dist = math.huge

	for _,plr in Players:GetPlayers() do
		if plr ~= player and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local d = (myRoot.Position - hrp.Position).Magnitude
				if d < dist and d > 8 then
					dist = d
					closest = hrp
				end
			end
		end
	end

	if not closest then return end

	local start = tick()
	local con
	con = RunService.RenderStepped:Connect(function()
		if tick() - start >= 0.28 then
			con:Disconnect()
			myRoot.CFrame = oldPos
			return
		end

		if closest and closest.Parent then
			local targetPos = closest.Position
			local frontPos = targetPos + closest.CFrame.LookVector * 2.8
			myRoot.CFrame = myRoot.CFrame:Lerp(CFrame.lookAt(frontPos,targetPos),0.65)
		end
	end)
end)

--================ FAR TP =================
farBtn.MouseButton1Click:Connect(function()
	if farDrag() then return end

	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if not farTPEnabled then
		savedPosition = root.CFrame

		root.CFrame = CFrame.new(
			root.Position.X + 10000000,
			root.Position.Y + 200,
			root.Position.Z + 10000000
		)

		platform = Instance.new("Part")
		platform.Size = Vector3.new(200,10,200)
		platform.Position = root.Position - Vector3.new(0,8,0)
		platform.Anchored = true
		platform.CanCollide = true
		platform.Transparency = 0.25
		platform.Material = Enum.Material.Neon
		platform.Color = Color3.fromRGB(0,170,255)
		platform.Parent = workspace

		farTPEnabled = true
		farBtn.Text = "RETURN"
	else
		root.CFrame = savedPosition
		if platform then platform:Destroy() end
		farTPEnabled = false
		farBtn.Text = "FAR TP"
	end
end)

--================ INF JUMP =================
jumpBtn.MouseButton1Click:Connect(function()
	if jumpDrag() then return end

	infJump = not infJump

	if infJump then
		jumpBtn.Text = "JUMP ON"
		jumpBtn.BackgroundColor3 = Color3.fromRGB(0,255,130)
	else
		jumpBtn.Text = "INF JUMP"
		jumpBtn.BackgroundColor3 = Color3.fromRGB(0,220,120)
	end
end)

UIS.JumpRequest:Connect(function()
	if infJump then
		local char = player.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end)
