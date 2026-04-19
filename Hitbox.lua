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
local flying = false
local flySpeed = 50 
local guiLocked = false

local buttons = {}

--================ GUI ROOT =================
local gui = Instance.new("ScreenGui")
gui.Name = "AdrienHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--================ TITLE FRAME =================
local titleFrame = Instance.new("Frame", gui)
titleFrame.Size = UDim2.new(0, 220, 0, 40)
titleFrame.Position = UDim2.new(0, 10, 0, 10)
titleFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
titleFrame.BackgroundTransparency = 0.35
Instance.new("UICorner", titleFrame)

local titleText = Instance.new("TextLabel", titleFrame)
titleText.Size = UDim2.new(1, -80, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Adrien's Hub"
titleText.TextColor3 = Color3.new(1, 1, 1)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 18
titleText.TextXAlignment = Enum.TextXAlignment.Left

local refreshBtn = Instance.new("TextButton", titleFrame)
refreshBtn.Size = UDim2.new(0, 30, 0, 30)
refreshBtn.Position = UDim2.new(1, -35, 0.5, -15)
refreshBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
refreshBtn.Text = "🔄"
refreshBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", refreshBtn)

local lockBtn = Instance.new("TextButton", titleFrame)
lockBtn.Size = UDim2.new(0, 30, 0, 30)
lockBtn.Position = UDim2.new(1, -70, 0.5, -15)
lockBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
lockBtn.Text = "🔓"
lockBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", lockBtn)

--================ SIMPLE FLY ENGINE =================
local bodyVel
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if flying and root and hum then
        if not bodyVel then
            bodyVel = Instance.new("BodyVelocity", root)
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        end
        
        hum.PlatformStand = true
        local cam = workspace.CurrentCamera.CFrame
        local moveDir = hum.MoveDirection
        
        -- The simplest fly: Camera direction * Joystick input * Speed
        if moveDir.Magnitude > 0 then
            bodyVel.Velocity = cam.LookVector * (-moveDir.Z * flySpeed)
        else
            bodyVel.Velocity = Vector3.zero
        end
        
        -- Noclip logic
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else
        if bodyVel then bodyVel:Destroy() bodyVel = nil end
        if hum then hum.PlatformStand = false end
    end
end)

--================ DRAG & UI HELPERS =================
local function makeDraggable(btn)
	local dragging, dragInput, dragStart, startPos
	btn.InputBegan:Connect(function(input)
        if guiLocked then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPos = btn.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local function createButton(text, posY, color)
	local btn = Instance.new("TextButton", gui)
	btn.Size = UDim2.new(0, 110, 0, 44)
	btn.Position = UDim2.new(0, 10, 0, posY)
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
	makeDraggable(btn)
	table.insert(buttons, btn)
	return btn
end

--================ BUILD UI =================
local function buildUI()
	for _, b in ipairs(buttons) do if b then b:Destroy() end end
	buttons = {}
	
	local pulseBtn = createButton("PULSE", 60, Color3.fromRGB(0, 145, 255))
	local tpBtn    = createButton("TP", 112, Color3.fromRGB(255, 75, 75))
	local farBtn   = createButton(farTPEnabled and "RETURN" or "FAR TP", 164, Color3.fromRGB(130, 70, 255))
    local flyBtn   = createButton(flying and "FLY ON" or "FLY OFF", 216, Color3.fromRGB(255, 140, 0))
    
    local speedBox = Instance.new("TextBox", gui)
    speedBox.Size = UDim2.new(0, 110, 0, 44)
    speedBox.Position = UDim2.new(0, 10, 0, 268)
    speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    speedBox.Text = tostring(flySpeed)
    speedBox.TextColor3 = Color3.new(1, 1, 1)
    speedBox.Font = Enum.Font.GothamBold
    Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 12)
    makeDraggable(speedBox)
    table.insert(buttons, speedBox)

	local jumpBtn = createButton(infJump and "JUMP ON" or "INF JUMP", 320, Color3.fromRGB(0, 220, 120))

    speedBox.FocusLost:Connect(function()
        flySpeed = tonumber(speedBox.Text) or 50
    end)

    flyBtn.MouseButton1Click:Connect(function()
        flying = not flying
        buildUI()
    end)

    lockBtn.MouseButton1Click:Connect(function()
        guiLocked = not guiLocked
        lockBtn.Text = guiLocked and "🔒" or "🔓"
        lockBtn.BackgroundColor3 = guiLocked and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(35, 35, 35)
    end)
    -- Pulse, TP, FarTP, Jump logic remain unchanged for brevity --
end

buildUI()
refreshBtn.MouseButton1Click:Connect(buildUI)
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
local flying = false
local flySpeed = 50 
local guiLocked = false

local buttons = {}

--================ GUI ROOT =================
local gui = Instance.new("ScreenGui")
gui.Name = "AdrienHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--================ TITLE FRAME =================
local titleFrame = Instance.new("Frame", gui)
titleFrame.Size = UDim2.new(0, 220, 0, 40)
titleFrame.Position = UDim2.new(0, 10, 0, 10)
titleFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
titleFrame.BackgroundTransparency = 0.35
Instance.new("UICorner", titleFrame)

local titleText = Instance.new("TextLabel", titleFrame)
titleText.Size = UDim2.new(1, -80, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Adrien's Hub"
titleText.TextColor3 = Color3.new(1, 1, 1)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 18
titleText.TextXAlignment = Enum.TextXAlignment.Left

local refreshBtn = Instance.new("TextButton", titleFrame)
refreshBtn.Size = UDim2.new(0, 30, 0, 30)
refreshBtn.Position = UDim2.new(1, -35, 0.5, -15)
refreshBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
refreshBtn.Text = "🔄"
refreshBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", refreshBtn)

local lockBtn = Instance.new("TextButton", titleFrame)
lockBtn.Size = UDim2.new(0, 30, 0, 30)
lockBtn.Position = UDim2.new(1, -70, 0.5, -15)
lockBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
lockBtn.Text = "🔓"
lockBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", lockBtn)

--================ SIMPLE FLY ENGINE =================
local bodyVel
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if flying and root and hum then
        if not bodyVel then
            bodyVel = Instance.new("BodyVelocity", root)
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        end
        
        hum.PlatformStand = true
        local cam = workspace.CurrentCamera.CFrame
        local moveDir = hum.MoveDirection
        
        -- The simplest fly: Camera direction * Joystick input * Speed
        if moveDir.Magnitude > 0 then
            bodyVel.Velocity = cam.LookVector * (-moveDir.Z * flySpeed)
        else
            bodyVel.Velocity = Vector3.zero
        end
        
        -- Noclip logic
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else
        if bodyVel then bodyVel:Destroy() bodyVel = nil end
        if hum then hum.PlatformStand = false end
    end
end)

--================ DRAG & UI HELPERS =================
local function makeDraggable(btn)
	local dragging, dragInput, dragStart, startPos
	btn.InputBegan:Connect(function(input)
        if guiLocked then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPos = btn.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local function createButton(text, posY, color)
	local btn = Instance.new("TextButton", gui)
	btn.Size = UDim2.new(0, 110, 0, 44)
	btn.Position = UDim2.new(0, 10, 0, posY)
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
	makeDraggable(btn)
	table.insert(buttons, btn)
	return btn
end

--================ BUILD UI =================
local function buildUI()
	for _, b in ipairs(buttons) do if b then b:Destroy() end end
	buttons = {}
	
	local pulseBtn = createButton("PULSE", 60, Color3.fromRGB(0, 145, 255))
	local tpBtn    = createButton("TP", 112, Color3.fromRGB(255, 75, 75))
	local farBtn   = createButton(farTPEnabled and "RETURN" or "FAR TP", 164, Color3.fromRGB(130, 70, 255))
    local flyBtn   = createButton(flying and "FLY ON" or "FLY OFF", 216, Color3.fromRGB(255, 140, 0))
    
    local speedBox = Instance.new("TextBox", gui)
    speedBox.Size = UDim2.new(0, 110, 0, 44)
    speedBox.Position = UDim2.new(0, 10, 0, 268)
    speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    speedBox.Text = tostring(flySpeed)
    speedBox.TextColor3 = Color3.new(1, 1, 1)
    speedBox.Font = Enum.Font.GothamBold
    Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 12)
    makeDraggable(speedBox)
    table.insert(buttons, speedBox)

	local jumpBtn = createButton(infJump and "JUMP ON" or "INF JUMP", 320, Color3.fromRGB(0, 220, 120))

    speedBox.FocusLost:Connect(function()
        flySpeed = tonumber(speedBox.Text) or 50
    end)

    flyBtn.MouseButton1Click:Connect(function()
        flying = not flying
        buildUI()
    end)

    lockBtn.MouseButton1Click:Connect(function()
        guiLocked = not guiLocked
        lockBtn.Text = guiLocked and "🔒" or "🔓"
        lockBtn.BackgroundColor3 = guiLocked and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(35, 35, 35)
    end)
    -- Pulse, TP, FarTP, Jump logic remain unchanged for brevity --
end

buildUI()
refreshBtn.MouseButton1Click:Connect(buildUI)
