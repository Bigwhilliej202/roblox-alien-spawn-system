--[[
	ROBLOX ALIEN SPAWNING SYSTEM
	Spawns players as aliens with randomized three-color system:
	- Main Color: Skin tone + Outer bio armor
	- Secondary Color: Inner bio armor
	- Tertiary Color: Energy (hidden for now, can be used for effects later)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Color palette for randomization
local COLOR_PALETTES = {
	Color3.fromRGB(100, 200, 255), -- Light cyan
	Color3.fromRGB(150, 100, 255), -- Purple
	Color3.fromRGB(100, 255, 150), -- Mint green
	Color3.fromRGB(255, 150, 100), -- Coral
	Color3.fromRGB(200, 100, 255), -- Magenta
	Color3.fromRGB(100, 255, 200), -- Turquoise
	Color3.fromRGB(255, 200, 100), -- Peach
	Color3.fromRGB(150, 255, 100), -- Lime
	Color3.fromRGB(100, 150, 255), -- Periwinkle
	Color3.fromRGB(255, 100, 200), -- Pink
}

-- Function to get three random unique colors
local function GetRandomAlienColors()
	local colors = {}
	local usedIndices = {}
	
	for i = 1, 3 do
		local randomIndex
		repeat
			randomIndex = math.random(1, #COLOR_PALETTES)
		until not usedIndices[randomIndex]
		
		usedIndices[randomIndex] = true
		table.insert(colors, COLOR_PALETTES[randomIndex])
	end
	
	return {
		mainColor = colors[1],      -- Skin tone + Outer bio armor
		secondaryColor = colors[2], -- Inner bio armor
		energyColor = colors[3]     -- Energy (hidden for now)
	}
end

-- Function to create alien character
local function CreateAlienCharacter(humanoidRootPart, colors)
	-- Remove default humanoid parts
	for _, part in pairs(humanoidRootPart.Parent:GetChildren()) do
		if part:IsA("BasePart") and part ~= humanoidRootPart then
			part:Destroy()
		end
	end
	
	local character = humanoidRootPart.Parent
	local scale = 2.5 -- Alien body scale
	
	-- Create alien head
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(scale * 0.8, scale * 0.9, scale * 0.8)
	head.Color = colors.mainColor
	head.Material = Enum.Material.Neon
	head.TopSurface = Enum.SurfaceType.Smooth
	head.BottomSurface = Enum.SurfaceType.Smooth
	head.CanCollide = false
	head.CFrame = humanoidRootPart.CFrame + Vector3.new(0, scale * 0.5, 0)
	head.Parent = character
	
	-- Create eyes (inner bio armor color)
	local function CreateEye(offset)
		local eye = Instance.new("Part")
		eye.Name = "Eye"
		eye.Shape = Enum.PartType.Ball
		eye.Size = Vector3.new(scale * 0.3, scale * 0.4, scale * 0.2)
		eye.Color = colors.secondaryColor
		eye.Material = Enum.Material.Neon
		eye.CanCollide = false
		eye.CFrame = head.CFrame + head.CFrame.LookVector * scale * 0.4 + offset
		eye.Parent = character
		
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = head
		weld.Part1 = eye
		weld.Parent = eye
		
		return eye
	end
	
	CreateEye(Vector3.new(scale * 0.2, scale * 0.1, 0))
	CreateEye(Vector3.new(-scale * 0.2, scale * 0.1, 0))
	
	-- Create torso
	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Shape = Enum.PartType.Block
	torso.Size = Vector3.new(scale * 0.7, scale * 1.2, scale * 0.5)
	torso.Color = colors.mainColor
	torso.Material = Enum.Material.Neon
	torso.TopSurface = Enum.SurfaceType.Smooth
	torso.BottomSurface = Enum.SurfaceType.Smooth
	torso.CanCollide = false
	torso.CFrame = humanoidRootPart.CFrame
	torso.Parent = character
	
	-- Create inner torso plating (secondary color)
	local innerTorso = Instance.new("Part")
	innerTorso.Name = "InnerTorso"
	innerTorso.Shape = Enum.PartType.Block
	innerTorso.Size = Vector3.new(scale * 0.5, scale * 0.9, scale * 0.4)
	innerTorso.Color = colors.secondaryColor
	innerTorso.Material = Enum.Material.Neon
	innerTorso.CanCollide = false
	innerTorso.CFrame = torso.CFrame
	innerTorso.Parent = character
	
	local innerTorsoWeld = Instance.new("WeldConstraint")
	innerTorsoWeld.Part0 = torso
	innerTorsoWeld.Part1 = innerTorso
	innerTorsoWeld.Parent = innerTorso
	
	-- Connect head to torso
	local headWeld = Instance.new("WeldConstraint")
	headWeld.Part0 = torso
	headWeld.Part1 = head
	headWeld.Parent = head
	
	-- Create left arm
	local function CreateArm(side)
		local arm = Instance.new("Part")
		arm.Name = side .. "Arm"
		arm.Shape = Enum.PartType.Block
		arm.Size = Vector3.new(scale * 0.35, scale * 1, scale * 0.35)
		arm.Color = colors.mainColor
		arm.Material = Enum.Material.Neon
		arm.CanCollide = false
		
		local offset = side == "Left" and -scale * 0.5 or scale * 0.5
		arm.CFrame = torso.CFrame + torso.CFrame.RightVector * offset - torso.CFrame.UpVector * scale * 0.3
		arm.Parent = character
		
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = torso
		weld.Part1 = arm
		weld.Parent = arm
		
		-- Add claws/fingers
		for i = 1, 2 do
			local claw = Instance.new("Part")
			claw.Name = "Claw"
			claw.Shape = Enum.PartType.Block
			claw.Size = Vector3.new(scale * 0.1, scale * 0.3, scale * 0.1)
			claw.Color = colors.secondaryColor
			claw.Material = Enum.Material.Neon
			claw.CanCollide = false
			
			local clawOffset = side == "Left" and -scale * 0.2 or scale * 0.2
			claw.CFrame = arm.CFrame - arm.CFrame.UpVector * scale * 0.6 + arm.CFrame.RightVector * clawOffset * (i - 1.5)
			claw.Parent = character
			
			local clawWeld = Instance.new("WeldConstraint")
			clawWeld.Part0 = arm
			clawWeld.Part1 = claw
			clawWeld.Parent = claw
		end
		
		return arm
	end
	
	CreateArm("Left")
	CreateArm("Right")
	
	-- Create legs
	local function CreateLeg(side)
		local leg = Instance.new("Part")
		leg.Name = side .. "Leg"
		leg.Shape = Enum.PartType.Block
		leg.Size = Vector3.new(scale * 0.3, scale * 1.1, scale * 0.3)
		leg.Color = colors.mainColor
		leg.Material = Enum.Material.Neon
		leg.CanCollide = false
		
		local offset = side == "Left" and -scale * 0.25 or scale * 0.25
		leg.CFrame = torso.CFrame + torso.CFrame.RightVector * offset - torso.CFrame.UpVector * scale * 0.9
		leg.Parent = character
		
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = torso
		weld.Part1 = leg
		weld.Parent = leg
		
		-- Create foot
		local foot = Instance.new("Part")
		foot.Name = "Foot"
		foot.Shape = Enum.PartType.Block
		foot.Size = Vector3.new(scale * 0.35, scale * 0.3, scale * 0.5)
		foot.Color = colors.secondaryColor
		foot.Material = Enum.Material.Neon
		foot.CanCollide = false
		foot.CFrame = leg.CFrame - leg.CFrame.UpVector * scale * 0.7
		foot.Parent = character
		
		local footWeld = Instance.new("WeldConstraint")
		footWeld.Part0 = leg
		footWeld.Part1 = foot
		footWeld.Parent = foot
		
		return leg
	end
	
	CreateLeg("Left")
	CreateLeg("Right")
	
	-- Weld humanoid root part to torso
	local rootWeld = Instance.new("WeldConstraint")
	rootWeld.Part0 = humanoidRootPart
	rootWeld.Part1 = torso
	rootWeld.Parent = torso
	
	-- Store color info for future reference
	character:SetAttribute("MainColor", colors.mainColor)
	character:SetAttribute("SecondaryColor", colors.secondaryColor)
	character:SetAttribute("EnergyColor", colors.energyColor)
	
	print("Alien spawned with colors: Main=" .. tostring(colors.mainColor) .. " | Secondary=" .. tostring(colors.secondaryColor) .. " | Energy=" .. tostring(colors.energyColor))
end

-- Function to handle player spawn
local function OnPlayerSpawned(character)
	local humanoid = character:WaitForChild("Humanoid")
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	
	-- Wait for initial setup
	task.wait(0.1)
	
	-- Get random colors
	local colors = GetRandomAlienColors()
	
	-- Create alien character
	CreateAlienCharacter(humanoidRootPart, colors)
end

-- Connect to player added event
local function OnPlayerAdded(player)
	player.CharacterAdded:Connect(OnPlayerSpawned)
	
	-- Handle if player already has character
	if player.Character then
		OnPlayerSpawned(player.Character)
	end
end

Players.PlayerAdded:Connect(OnPlayerAdded)

-- Handle existing players
for _, player in pairs(Players:GetPlayers()) do
	OnPlayerAdded(player)
end

print("Alien Spawning System loaded successfully!")
