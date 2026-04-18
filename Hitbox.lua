local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local huge = Vector3.new(1e16, 1e16, 1e16)

local farTPEnabled = false
local savedPosition = nil
local platform = nil

--================ GUI ================
local gui = Instance.new("ScreenGui")
gui.Name = "AdrienScript"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--================ DRAG SYSTEM ================
local function makeDraggable(obj)
	local dragging = false
	local dragInput
	local dragStart
	local startPos

	obj.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = obj.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	obj.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			obj.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

--================ BUTTON CREATOR ================
local function createButton(text, y, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,150,0,150)
	btn.Position = UDim2.new(0.5,-75,0,y)
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.Parent = gui
	btn.BorderSizePixel = 0

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,12)
	corner.Parent = btn

	makeDraggable(btn)
	return btn
end

local pulseBtn = createButton("Pulse",80,Color3.fromRGB(0,140,255))
local tpBtn = createButton("TP",250,Color3.fromRGB(255,60,60))
local farBtn = createButton("Far TP OFF",420,Color3.fromRGB(100,50,255))

print("✅ Script Loaded")

--================ PULSE HITBOX ================
pulseBtn.MouseButton1Click:Connect(function()
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

--================ NEW TP SYSTEM ====================
tpBtn.MouseButton1Click:Connect(function()
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
		if tick() - start >= 0.15 then
			con:Disconnect()
			myRoot.CFrame = oldPos
			print("Returned to original position")
			return
		end

		if closest and closest.Parent then
			local targetPos = closest.Position
			local frontPos = targetPos + closest.CFrame.LookVector * 2.8
			myRoot.CFrame = myRoot.CFrame:Lerp(
				CFrame.lookAt(frontPos, targetPos),
				0.65
			)
		end
	end)
end)

--================ FAR TP ====================
farBtn.MouseButton1Click:Connect(function()
	local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	if not farTPEnabled then
		savedPosition = myRoot.CFrame

		local farX = myRoot.Position.X + 10000000
		local farZ = myRoot.Position.Z + 10000000
		local farY = myRoot.Position.Y + 200

		myRoot.CFrame = CFrame.new(farX, farY, farZ)

		platform = Instance.new("Part")
		platform.Size = Vector3.new(200,10,200)
		platform.Position = myRoot.Position - Vector3.new(0,8,0)
		platform.Anchored = true
		platform.CanCollide = true
		platform.Transparency = 0.3
		platform.BrickColor = BrickColor.new("Bright blue")
		platform.Parent = workspace

		farTPEnabled = true
		farBtn.Text = "Far TP ON"
		farBtn.BackgroundColor3 = Color3.fromRGB(0,255,100)
	else
		if savedPosition then
			myRoot.CFrame = savedPosition
		end

		if platform then
			platform:Destroy()
			platform = nil
		end

		farTPEnabled = false
		farBtn.Text = "Far TP OFF"
		farBtn.BackgroundColor3 = Color3.fromRGB(100,50,255)
	end
end)
