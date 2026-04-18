local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local ownerID = 4961265032
local huge = Vector3.new(2e11, 2e11, 2e11)
local skyLimit = 100000 

-- State Variables
local farTPEnabled = false
local savedPosition = nil
local infJump = false

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "Adrien_DragFixed_v34"
gui.ResetOnSpawn = false

--================ STABLE DRAG SYSTEM =================
local function makeDraggable(obj, callback)
    local dragging, dragInput, dragStart, startPos
    local dragThreshold = 7 -- Sensitivity for movement
    local hasMoved = false

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            hasMoved = false
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                    -- Action only fires if we didn't drag it
                    if not hasMoved and callback then
                        callback()
                    end
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
            if delta.Magnitude > dragThreshold then
                hasMoved = true
            end
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--================ AUTO DEFENSES =================
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        -- Forcefield (Always Active)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local tHrp = p.Character.HumanoidRootPart
                if (root.Position - tHrp.Position).Magnitude < 15 then
                    tHrp.AssemblyLinearVelocity = (tHrp.Position - root.Position).Unit * 250
                end
            end
        end

        -- Jitter
        root.CFrame = root.CFrame * CFrame.new(math.sin(tick()*60)*0.1, 0, 0)
        
        -- Sky Lock
        if farTPEnabled then
            root.Anchored = true
            root.Velocity = Vector3.new(0,0,0)
        elseif not farTPEnabled and not root.Anchored then
            root.Anchored = false
        end
    end
end)

--================ BUTTON LOGIC =================

local function pulseAction()
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
end

local function phantomAction()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local target = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            target = p.Character.HumanoidRootPart break
        end
    end
    if root and target then
        local oldPos = root.CFrame
        root.CFrame = target.CFrame * CFrame.new(0, 0, -3)
        task.wait(0.08)
        root.CFrame = oldPos
    end
end

local function skyAction()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local btn = gui:FindFirstChild("SKY TP")
    if not root or not btn then return end
    
    if not farTPEnabled then
        savedPosition = root.CFrame
        root.CFrame = CFrame.new(root.Position.X, skyLimit, root.Position.Z)
        farTPEnabled = true
        btn.Text = "RETURN"
        btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    else
        farTPEnabled = false
        root.Anchored = false
        root.CFrame = savedPosition
        btn.Text = "SKY TP"
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    end
end

local function jumpAction()
    infJump = not infJump
    local btn = gui:FindFirstChild("INF JUMP")
    if btn then
        btn.BackgroundColor3 = infJump and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(15, 15, 15)
    end
end

--================ CREATE BUTTONS =================

local function createBtn(name, text, y, color, action)
    local b = Instance.new("TextButton", gui)
    b.Name = name
    b.Size = UDim2.new(0, 155, 0, 60)
    b.Position = UDim2.new(0, 35, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.RobotoMono
    b.TextSize = 17
    b.AutoButtonColor = false 
    Instance.new("UICorner", b)
    local s = Instance.new("UIStroke", b)
    s.Color = color
    s.Thickness = 3
    
    makeDraggable(b, action)
    return b
end

createBtn("PULSE", "PULSE", 100, Color3.fromRGB(0, 160, 255), pulseAction)
createBtn("PHANTOM TP", "PHANTOM TP", 175, Color3.fromRGB(255, 45, 45), phantomAction)
createBtn("SKY TP", "SKY TP", 250, Color3.fromRGB(255, 255, 0), skyAction)
createBtn("INF JUMP", "INF JUMP", 325, Color3.fromRGB(0, 255, 120), jumpAction)

-- Jump Request
UIS.JumpRequest:Connect(function()
    if infJump and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
