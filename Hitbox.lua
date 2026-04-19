local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local admins = {4961265032, 2758862803} -- Added the requested UserID
local huge = Vector3.new(2e11, 2e11, 2e11)
local skyLimit = 100000 

-- State Variables
local farTPEnabled = false
local savedPosition = nil
local infJump = false

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "Adrien_Admin_v35"
gui.ResetOnSpawn = false

--================ STABLE DRAG SYSTEM =================
local function makeDraggable(obj, callback)
    local dragging, dragInput, dragStart, startPos
    local dragThreshold = 7
    local hasMoved = false

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = obj.Position; hasMoved = false
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false; connection:Disconnect()
                    if not hasMoved and callback then callback() end
                end
            end)
        end
    end)

    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > dragThreshold then hasMoved = true end
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--================ ADMIN PANEL SETUP =================
local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0, 250, 0, 300)
panel.Position = UDim2.new(0.5, -125, 0.4, 0)
panel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
panel.Visible = false
Instance.new("UICorner", panel)
local pStroke = Instance.new("UIStroke", panel)
pStroke.Color = Color3.new(1, 1, 1)
pStroke.Thickness = 2
makeDraggable(panel)

local function createAdminCmd(text, y, callback)
    local b = Instance.new("TextButton", panel)
    b.Size = UDim2.new(0, 210, 0, 40)
    b.Position = UDim2.new(0.5, -105, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
end

createAdminCmd("VOID ALL", 50, function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then p.Character:MoveTo(Vector3.new(0, -5000, 0)) end
    end
end)
createAdminCmd("BRING ALL", 110, function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then p.Character:MoveTo(root.Position) end
    end
end)
createAdminCmd("CLOSE PANEL", 240, function() panel.Visible = false end)

--================ CROWN TOGGLE (BOTTOM RIGHT) =================
local crown = Instance.new("TextButton", gui)
crown.Size = UDim2.new(0, 60, 0, 60)
crown.Position = UDim2.new(1, -80, 1, -80)
crown.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
crown.Text = "👑"
crown.TextSize = 35
Instance.new("UICorner", crown)
local cStroke = Instance.new("UIStroke", crown)
cStroke.Color = Color3.fromRGB(255, 215, 0)
cStroke.Thickness = 2

crown.MouseButton1Click:Connect(function()
    if table.find(admins, player.UserId) then
        panel.Visible = not panel.Visible
    end
end)

player.Chatted:Connect(function(msg)
    if msg:lower() == "/panel" and table.find(admins, player.UserId) then
        panel.Visible = not panel.Visible
    end
end)

--================ CORE ACTIONS =================
local function skyAction()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local btn = gui:FindFirstChild("SKY TP")
    if not root or not btn then return end
    if not farTPEnabled then
        savedPosition = root.CFrame
        root.CFrame = CFrame.new(root.Position.X, skyLimit, root.Position.Z)
        farTPEnabled = true
        btn.Text = "RETURN"; btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    else
        farTPEnabled = false; root.Anchored = false; root.CFrame = savedPosition
        btn.Text = "SKY TP"; btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    end
end

--================ MAIN BUTTONS =================
local function createBtn(name, text, y, color, action)
    local b = Instance.new("TextButton", gui)
    b.Name = name; b.Size = UDim2.new(0, 155, 0, 60); b.Position = UDim2.new(0, 35, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(15, 15, 15); b.Text = text; b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.RobotoMono; b.TextSize = 17; b.AutoButtonColor = false 
    Instance.new("UICorner", b); local s = Instance.new("UIStroke", b); s.Color = color; s.Thickness = 3
    makeDraggable(b, action); return b
end

createBtn("PULSE", "PULSE", 100, Color3.fromRGB(0, 160, 255), function()
    for _,v in pairs(Players:GetPlayers()) do   
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then   
            local hrp = v.Character.HumanoidRootPart   
            hrp.Size, hrp.Transparency, hrp.CanCollide = huge, 0.6, false   
        end   
    end   
    task.wait(0.08)
    for _,v in pairs(Players:GetPlayers()) do   
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then   
            local hrp = v.Character.HumanoidRootPart   
            hrp.Size, hrp.Transparency = Vector3.new(2,2,1), 1   
        end   
    end   
end)

createBtn("PHANTOM TP", "PHANTOM TP", 175, Color3.fromRGB(255, 45, 45), function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local target = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            target = p.Character.HumanoidRootPart break
        end
    end
    if root and target then
        local oldPos = root.CFrame; root.CFrame = target.CFrame * CFrame.new(0, 0, -3)
        task.wait(0.08); root.CFrame = oldPos
    end
end)

createBtn("SKY TP", "SKY TP", 250, Color3.fromRGB(255, 255, 0), skyAction)

createBtn("INF JUMP", "INF JUMP", 325, Color3.fromRGB(0, 255, 120), function()
    infJump = not infJump
    gui:FindFirstChild("INF JUMP").BackgroundColor3 = infJump and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(15, 15, 15)
end)

--================ LOOPS =================
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local tHrp = p.Character.HumanoidRootPart
                if (root.Position - tHrp.Position).Magnitude < 15 then
                    tHrp.AssemblyLinearVelocity = (tHrp.Position - root.Position).Unit * 250
                end
            end
        end
        root.CFrame = root.CFrame * CFrame.new(math.sin(tick()*60)*0.1, 0, 0)
        if farTPEnabled then root.Anchored = true; root.Velocity = Vector3.new(0,0,0)
        elseif not farTPEnabled and not root.Anchored then root.Anchored = false end
    end
end)

UIS.JumpRequest:Connect(function()
    if infJump and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
