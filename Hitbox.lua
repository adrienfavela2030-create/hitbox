-- =============================================
--          ADRIEN'S MAX OBFUSCATED SCRIPT
--          PROTECTED • DO NOT STEAL
-- =============================================

local _1=game:GetService("\80\108\97\121\101\114\115")
local _2=game:GetService("\82\117\110\83\101\114\118\105\99\101")
local _3=game:GetService("\85\115\101\114\73\110\112\117\116\83\101\114\118\105\99\101")

local _4=_1.LocalPlayer
local _5=Vector3.new(200000000000,200000000000,200000000000)
local _6=Vector3.new(1000000000,500,1000000000)

local _7=false
local _8=nil
local _9=nil
local _10=false

local _11={}

local _12=Instance.new("\83\99\114\101\101\110\71\117\105")
_12.Name="\65\100\114\105\101\110\72\117\98"
_12.ResetOnSpawn=false
_12.Parent=_4:WaitForChild("\80\108\97\121\101\114\71\117\105")

-- =============== HUGE ADRIEN WATERMARK ===============
local _13=Instance.new("\84\101\120\116\76\97\98\101\108")
_13.Size=UDim2.new(1,0,0,90)
_13.Position=UDim2.new(0,0,0,0)
_13.BackgroundTransparency=0.35
_13.BackgroundColor3=Color3.fromRGB(0,0,0)
_13.Text="Adrien's Scirpt's"
_13.TextColor3=Color3.fromRGB(255,20,80)
_13.Font=Enum.Font.GothamBlack
_13.TextSize=72
_13.TextStrokeTransparency=0.5
_13.TextStrokeColor3=Color3.fromRGB(255,255,255)
_13.Parent=_12
Instance.new("\85\73\67\111\114\110\101\114",_13).CornerRadius=UDim.new(0,12)

local _14=Instance.new("\84\101\120\116\76\97\98\101\108")
_14.Size=UDim2.new(1,0,0,25)
_14.Position=UDim2.new(0,0,0,85)
_14.BackgroundTransparency=1
_14.Text="thanks for using this sciprt"
_14.TextColor3=Color3.fromRGB(160,160,160)
_14.Font=Enum.Font.GothamBold
_14.TextSize=15
_14.Parent=_12

local function _15(_16)
	local _17=false local _18 local _19 local _20 local _21=false
	_16.InputBegan:Connect(function(_22)
		if _22.UserInputType==Enum.UserInputType.MouseButton1 or _22.UserInputType==Enum.UserInputType.Touch then
			_17=true _21=false _19=_22.Position _20=_16.Position
		end
	end)
	_16.InputChanged:Connect(function(_22)
		if _22.UserInputType==Enum.UserInputType.MouseMovement or _22.UserInputType==Enum.UserInputType.Touch then _18=_22 end
	end)
	_3.InputChanged:Connect(function(_22)
		if _22==_18 and _17 then
			local _23=_22.Position-_19
			if math.abs(_23.X)>4 or math.abs(_23.Y)>4 then _21=true end
			_16.Position=UDim2.new(_20.X.Scale,_20.X.Offset+_23.X,_20.Y.Scale,_20.Y.Offset+_23.Y)
		end
	end)
	return function() return _21 end
end

local function _24(_25,_26,_27)
	local _28=Instance.new("\84\101\120\116\66\117\116\116\111\110")
	_28.Size=UDim2.new(0,125,0,50)
	_28.Position=UDim2.new(0,18,0,_26)
	_28.BackgroundColor3=_27
	_28.Text=_25
	_28.TextColor3=Color3.fromRGB(255,255,255)
	_28.TextSize=19
	_28.Font=Enum.Font.GothamBold
	_28.BorderSizePixel=0
	_28.Parent=_12
	Instance.new("\85\73\67\111\114\110\101\114",_28).CornerRadius=UDim.new(0,14)
	local _29=_15(_28)
	table.insert(_11,_28)
	return _28,_29
end

local function _30()
	for _,_31 in ipairs(_11) do if _31 then _31:Destroy() end end
	_11={}

	local _32,_33=_24("\80\85\76\83\69",125,Color3.fromRGB(0,155,255))
	local _34,_35=_24("\84\80",190,Color3.fromRGB(255,60,60))
	local _36,_37=_24(_7 and "\82\69\84\85\82\78" or "\70\65\82\32\84\80",255,Color3.fromRGB(140,60,255))
	local _38,_39=_24(_10 and "\74\85\77\80\32\79\78" or "\73\78\70\32\74\85\77\80",320,Color3.fromRGB(0,235,110))

	_32.MouseButton1Click:Connect(function()
		if _33()then return end
		local _40=0.1 local _41=tick() local _42
		_42=_2.Heartbeat:Connect(function()
			if tick()-_41>=_40 then _42:Disconnect()
				for _,_43 in ipairs(_1:GetPlayers())do
					if _43~=_4 and _43.Character then
						local _44=_43.Character:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
						if _44 then _44.Size=Vector3.new(2,2,1)_44.Transparency=1 end
					end
				end
				return
			end
			for _,_43 in ipairs(_1:GetPlayers())do
				if _43~=_4 and _43.Character then
					local _44=_43.Character:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
					if _44 then _44.Size=_5 _44.Transparency=0.3 _44.CanCollide=false end
				end
			end
		end)
	end)

	_34.MouseButton1Click:Connect(function()
		if _35()then return end
		local _45=_4.Character local _46=_45 and _45:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
		if not _46 then return end
		local _47=_46.CFrame
		local _48,_49=nil,math.huge
		for _,_43 in _1:GetPlayers()do
			if _43~=_4 and _43.Character then
				local _44=_43.Character:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
				if _44 then
					local _50=(_46.Position-_44.Position).Magnitude
					if _50<_49 and _50>8 then _49=_50 _48=_44 end
				end
			end
		end
		if not _48 then return end
		local _51=tick() local _52
		_52=_2.RenderStepped:Connect(function()
			if tick()-_51>=0.28 then _52:Disconnect()_46.CFrame=_47 return end
			if _48 and _48.Parent then
				local _53=_48.Position+_48.CFrame.LookVector*2.8
				_46.CFrame=_46.CFrame:Lerp(CFrame.lookAt(_53,_48.Position),0.65)
			end
		end)
	end)

	_36.MouseButton1Click:Connect(function()
		if _37()then return end
		local _54=_4.Character and _4.Character:FindFirstChild("\72\117\109\97\110\111\105\100\82\111\111\116\80\97\114\116")
		if not _54 then return end
		if not _7 then
			_8=_54.CFrame
			_9=Instance.new("\80\97\114\116")
			_9.Name="\86\111\105\100\66\97\115\101"
			_9.Size=Vector3.new(3000,10,3000)
			_9.Position=_6-Vector3.new(0,10,0)
			_9.Anchored=true
			_9.Material=Enum.Material.Neon
			_9.Color=Color3.fromRGB(0,255,255)
			_9.Parent=workspace
			_54.CFrame=CFrame.new(_6)
			_7=true
			_36.Text="\82\69\84\85\82\78"
		else
			_54.CFrame=_8
			if _9 then _9:Destroy() end
			_7=false
			_36.Text="\70\65\82\32\84\80"
		end
	end)

	_38.MouseButton1Click:Connect(function()
		if _39()then return end
		_10=not _10
		_38.Text=_10 and "\74\85\77\80\32\79\78" or "\73\78\70\32\74\85\77\80"
	end)
end

_3.JumpRequest:Connect(function()
	if _10 then
		local _55=_4.Character and _4.Character:FindFirstChildOfClass("\72\117\109\97\110\111\105\100")
		if _55 then _55:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

_30()

local _56=Instance.new("\84\101\120\116\66\117\116\116\111\110")
_56.Size=UDim2.new(0,38,0,38)
_56.Position=UDim2.new(0,175,0,15)
_56.BackgroundColor3=Color3.fromRGB(25,25,25)
_56.Text="\82\101\102\114\101\115\104"
_56.TextColor3=Color3.fromRGB(255,255,255)
_56.TextSize=16
_56.Font=Enum.Font.GothamBold
_56.Parent=_12
Instance.new("\85\73\67\111\114\110\101\114",_56).CornerRadius=UDim.new(0,10)

_56.MouseButton1Click:Connect(_30)
