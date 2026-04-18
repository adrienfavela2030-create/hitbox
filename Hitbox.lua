local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local ownerID = 4961265032
local huge = Vector3.new(2e11, 2e11, 2e11)
local farDistance = 100000000 

-- State Variables
local farTPEnabled, infJump, scriptFreeze, rainbowUI = false, false, false, false
local savedPosition, farPlatform = nil, nil

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "Adrien_Elite_v22"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999 -- Keeps UI above everything

--================ UI EFFECTS & TOOLS =================
local function makeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function applyButtonEffects(btn, color)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = color
    stroke.Thickness = 2
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color, BackgroundTransparency = 0.7}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Thickness = 4}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20,20,20), BackgroundTransparency = 0}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Thickness = 2}):Play()
    end)

    btn.MouseButton1Down:Connect(function()
        btn:TweenSize(UDim2.new(0, 145, 0, 55), "Out", "Quad", 0.1, true)
    end)
    
    btn.MouseButton1Up:Connect(function()
        btn:TweenSize(UDim2.new(0, 155, 0, 60), "Out", "Quad", 0.1, true)
    end)
end

--================ ADMIN PANEL =================
local admin = Instance.new("Frame", gui)
admin.Size = UDim2.new(0, 300, 0, 400)
admin.Position = UDim2.new(0.5, -150, 0.3, 0)
admin.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
admin.Visible = false
Instance.new("UICorner", admin).CornerRadius = UDim.new(0, 10)
makeDraggable(admin)

local aStroke = Instance.new("UIStroke", admin)
aStroke.Color = Color3.fromRGB(255, 0, 0)
aStroke.Thickness = 3

local function createAdminCmd(text, y, callback)
    local b = Instance.new("TextButton", admin)
    b.Size = UDim2.new(0, 260, 0, 45)
    b.Position = UDim2.new(0.5, -130, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
    return b
end

createAdminCmd("FREEZE SELF (TOGGLE)", 60, function() 
    scriptFreeze = not scriptFreeze 
end)

createAdminCmd("VOID OTHERS", 115, function()
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then p.Character:MoveTo(Vector3.new(0, -1000, 0)) end
    end
end)

createAdminCmd("BRING OTHERS", 170, function()
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then p.Character:MoveTo(player.Character.HumanoidRootPart.Position) end
    end
end)

createAdminCmd("RAINBOW MODE", 225, function() rainbowUI = not rainbowUI end)
createAdminCmd("CLOSE PANEL", 330, function() admin.Visible = false end)

--================ MAIN BUTTONS =================
local function createMainBtn(text, y, color)
    local b = Instance.new("TextButton", gui)
    b.Size = UDim2.new(0, 155, 0, 60)
    b.Position = UDim2.new(0, 40, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.RobotoMono
    b.TextSize = 18
    b.ZIndex = 10
    Instance.new("UICorner", b)
    applyButtonEffects(b, color)
    makeDraggable(b)
    return b
end

local pulseBtn = createMainBtn("PULSE", 100, Color3.fromRGB(0, 170, 255))
local tpBtn    = createMainBtn("SNAP TP", 180, Color3.fromRGB(255, 50, 80))
local farBtn   = createMainBtn("FAR TP", 260, Color3.fromRGB(180, 50, 255))
local jumpBtn  = createMainBtn("INF JUMP", 340, Color3.fromRGB(50, 255, 150))

--================ LOGIC CORE =================

-- Pulse (Hitbox)
pulseBtn.MouseButton1Click:Connect(function()   
    for _,v in pairs(Players:GetPlayers()) do   
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then   
            local hrp = v.Character.HumanoidRootPart   
            hrp.Size, hrp.Transparency, hrp.CanCollide = huge, 0.6, false   
        end   
    end   
    task.wait(0.12)   
    for _,v in pairs(Players:GetPlayers()) do   
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then   
            local hrp = v.Character.HumanoidRootPart   
            hrp.Size, hrp.Transparency = Vector3.new(2,2,1), 1   
        end   
    end   
end)

-- Snap TP
tpBtn.MouseButton1Click:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local target = nil
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            target = p.Character.HumanoidRootPart break
        end
    end
    if target then
        local oldPos = root.CFrame
        root.Anchored = true
        root.CFrame = target.CFrame * CFrame.new(0, 0, 3)
        task.wait(0.15)
        root.CFrame = oldPos
        task.wait(0.05)
        root.Anchored = false
    end
end)

-- Far TP (100M)
farBtn.MouseButton1Click:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if not farTPEnabled then
        savedPosition = root.CFrame
        local targetPos = Vector3.new(farDistance, 5000, farDistance)
        farPlatform = Instance.new("Part", workspace)
        farPlatform.Size = Vector3.new(30000, 300, 30000)
        farPlatform.Position = targetPos - Vector3.new(0, 155, 0)
        farPlatform.Anchored, farPlatform.Material, farPlatform.Color = true, Enum.Material.Neon, Color3.fromRGB(0, 255, 150)
        root.CFrame = CFrame.new(targetPos)
        farTPEnabled, farBtn.Text = true, "RETURN"
    else
        root.CFrame = savedPosition
        if farPlatform then farPlatform:Destroy() end
        farTPEnabled, farBtn.Text = false, "FAR TP"
    end
end)

-- Jump Request
UIS.JumpRequest:Connect(function()
    if infJump and player.Character then
        local h = player.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

jumpBtn.MouseButton1Click:Connect(function()
    infJump = not infJump
    jumpBtn.BackgroundColor3 = infJump and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(20, 20, 20)
end)

-- Global Loops
RunService.Heartbeat:Connect(function()
    if scriptFreeze and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = true end
    elseif not scriptFreeze and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and not globalFreeze then hrp.Anchored = false end
    end
    
    if rainbowUI then
        local c = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        aStroke.Color = c
    end
end)

player.Chatted:Connect(function(m)
    if player.UserId == ownerID and m:lower() == "/panel" then admin.Visible = not admin.Visible end
end)
