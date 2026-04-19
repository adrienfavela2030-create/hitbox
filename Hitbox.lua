local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local huge = Vector3.new(2e11, 2e11, 2e11)
local farLocation = Vector3.new(1000000000, 500, 1000000000)

local farTPEnabled = false
local savedPosition = nil
local farPlatform = nil
local infJump = false
local buttons = {}

-- Identification tag (Handshake) so script users can find each other
if not player:FindFirstChild("AdrienHub_Active") then
    local tag = Instance.new("BoolValue")
    tag.Name = "AdrienHub_Active"
    tag.Value = true
    tag.Parent = player
end

--================ GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "AdrienHub_v38"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--================ TITLE & CREDITS =================
local titleFrame = Instance.new("Frame")
titleFrame.Size = UDim2.new(0, 210, 0, 50)
titleFrame.Position = UDim2.new(0, 10, 0, 10)
titleFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
titleFrame.BackgroundTransparency = 0.3
titleFrame.Parent = gui
Instance.new("UICorner", titleFrame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 25)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Adrien's Scripts"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleFrame

local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, -10, 0, 15)
credits.Position = UDim2.new(0, 10, 0, 28)
credits.BackgroundTransparency = 1
credits.Text = "Credits: Adrien & Gemini"
credits.TextColor3 = Color3.fromRGB(200, 200, 200)
credits.Font = Enum.Font.GothamItalic
credits.TextSize = 12
credits.TextXAlignment = Enum.TextXAlignment.Left
credits.Parent = titleFrame

--================ ADMIN PANEL =================
local adminPanel = Instance.new("Frame")
adminPanel.Size = UDim2.new(0, 220, 0, 180)
adminPanel.Position = UDim2.new(0.5, -110, 0.4, 0)
adminPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
adminPanel.Visible = false
adminPanel.Parent = gui
Instance.new("UICorner", adminPanel)
Instance.new("UIStroke", adminPanel).Color = Color3.new(1, 1, 1)

local function createAdminBtn(text, y, callback)
    local b = Instance.new("TextButton", adminPanel)
    b.Size = UDim2.new(0, 190, 0, 40)
    b.Position = UDim2.new(0.5, -95, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
end

-- FIXED BRING SYSTEM
createAdminBtn("BRING SCRIPT USERS", 40, function()
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local foundUsers = 0
    for _, p in pairs(Players:GetPlayers()) do
        -- Searches for the tag created at the top of the script
        if p ~= player and p:FindFirstChild("AdrienHub_Active") and p.Character then
            local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                targetRoot.CFrame = myRoot.CFrame * CFrame.new(math.random(-3, 3), 0, math.random(-3, 3))
                foundUsers = foundUsers + 1
            end
        end
    end
end)

createAdminBtn("CLOSE PANEL", 110, function() adminPanel.Visible = false end)

-- Crown Toggle
local crown = Instance.new("TextButton", gui)
crown.Size = UDim2.new(0, 50, 0, 50)
crown.Position = UDim2.new(1, -70, 1, -70)
crown.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
crown.Text = "👑"
crown.TextSize = 25
crown.Parent = gui
Instance.new("UICorner", crown)

crown.MouseButton1Click:Connect(function() adminPanel.Visible = not adminPanel.Visible end)

--================ DRAG SYSTEM =================
local function makeDraggable(btn, callback)
	local dragging, dragInput, dragStart, startPos
	local hasMoved = false

	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; hasMoved = false
			dragStart = input.Position; startPos = btn.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			if delta.Magnitude > 5 then hasMoved = true end
			btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
    return function() return hasMoved end
end

makeDraggable(adminPanel)

--================ BUTTON CREATOR =================
local function createButton(text, posY, color, action)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 110, 0, 44); btn.Position = UDim2.new(0, 10, 0, posY)
	btn.BackgroundColor3 = color; btn.Text = text; btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextSize = 17; btn.Font = Enum.Font.GothamBold; btn.Parent = gui
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
	local dragCheck = makeDraggable(btn)
    
    btn.MouseButton1Click:Connect(function()
        if not dragCheck() then action() end
    end)
	table.insert(buttons, btn)
	return btn
end

--================ BUILD UI =================
local function buildUI()
	for _, b in ipairs(buttons) do if b then b:Destroy() end end
	buttons = {}
	
	createButton("PULSE", 70, Color3.fromRGB(0, 145, 255), function()
		local startTime = tick()
		local connection
		connection = RunService.Heartbeat:Connect(function()
			if tick() - startTime >= 0.10 then
				connection:Disconnect()
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= player and plr.Character then
						local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
						if hrp then hrp.Size = Vector3.new(2, 2, 1) hrp.Transparency = 1 end
					end
				end
				return
			end
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character then
					local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
					if hrp then hrp.Size = huge hrp.Transparency = 0.35 hrp.CanCollide = false end
				end
			end
		end)
	end)

	createButton("TP", 122, Color3.fromRGB(255, 75, 75), function()
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
			local front = closest.Position + closest.CFrame.LookVector * 2.8
			myRoot.CFrame = myRoot.CFrame:Lerp(CFrame.lookAt(front, closest.Position), 0.65)
		end)
	end)

	createButton(farTPEnabled and "RETURN" or "FAR TP", 174, Color3.fromRGB(130, 70, 255), function()
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		if not farTPEnabled then
			savedPosition = root.CFrame
			farPlatform = Instance.new("Part", workspace)
			farPlatform.Size = Vector3.new(3000, 10, 3000); farPlatform.Position = farLocation - Vector3.new(0, 10, 0)
			farPlatform.Anchored = true; farPlatform.Material = Enum.Material.Neon; farPlatform.Color = Color3.fromRGB(0, 255, 255)
			root.CFrame = CFrame.new(farLocation); farTPEnabled = true; buildUI()
		else
			root.CFrame = savedPosition; if farPlatform then farPlatform:Destroy() end
			farTPEnabled = false; buildUI()
		end
	end)

	createButton(infJump and "JUMP ON" or "INF JUMP", 226, Color3.fromRGB(0, 220, 120), function()
		infJump = not infJump; buildUI()
	end)
end

UIS.JumpRequest:Connect(function()
	if infJump then
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

buildUI()
