local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local huge = Vector3.new(1e16,1e16,1e16)

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
	local targetPos = obj.Position

	obj.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			
			dragging = true
			dragStart = input.Position
			startPos = obj.Position
			targetPos = obj.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	obj.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			targetPos = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	RunService.RenderStepped:Connect(function()
		if dragging then
			obj.Position = obj.Position:Lerp(targetPos,0.55) -- faster follow
		end
	end)
end

--================ BUTTON CREATOR ================
local function createButton(text,y,color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,150,0,150) -- square
	btn.Position = UDim2.new(0,40,0,y)
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

--================ BUTTONS ================
local pulseBtn = createButton("Pulse",100,Color3.fromRGB(0,140,255))
local tpBtn = createButton("TP",270,Color3.fromRGB(255,60,60))

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

--================ TP CLOSEST ================
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
		if tick() - start >= 0.39 then
			con:Disconnect()
			myRoot.CFrame = oldPos
			return
		end

		if closest and closest.Parent then
			local pos = closest.Position + closest.CFrame.LookVector * 2.8
			myRoot.CFrame = CFrame.lookAt(pos,closest.Position)
		end
	end)
end)
