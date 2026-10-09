-- Game-pass abilities on the player's own device:
--   Double/Triple Jump (MaxJumps attribute, toggle with the player's "MultiJumpOff" attribute),
--   Rocket Launcher (click to launch), Speed Coil and Gravity Coil (hold to use).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))
local Sfx = require(Shared:WaitForChild("Sfx"))

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function parts()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return character, humanoid, root
end

local function puff(root, color, count)
	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0, -2.5, 0)
	attachment.Parent = root
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(color)
	emitter.LightEmission = 0.6
	emitter.Size = NumberSequence.new(0.9, 0)
	emitter.Lifetime = NumberRange.new(0.3, 0.6)
	emitter.Speed = NumberRange.new(6, 12)
	emitter.SpreadAngle = Vector2.new(180, 20)
	emitter.Rate = 0
	emitter.Parent = attachment
	emitter:Emit(count or 16)
	task.delay(1, function()
		attachment:Destroy()
	end)
end

---------------------------------------------------------------- Double / triple jump
local extraJumpsUsed = 0
local airborneSince = 0

RunService.Heartbeat:Connect(function()
	local _, humanoid = parts()
	if not humanoid then
		return
	end
	if humanoid.FloorMaterial ~= Enum.Material.Air then
		extraJumpsUsed = 0
		airborneSince = os.clock()
	end
end)

UserInputService.JumpRequest:Connect(function()
	local maxJumps = player:GetAttribute("MaxJumps") or 1
	if maxJumps <= 1 or player:GetAttribute("MultiJumpOff") then
		return
	end
	local _, humanoid, root = parts()
	if not humanoid or not root or humanoid.Health <= 0 then
		return
	end
	-- Only in mid-air, and not in the instant right after the normal jump (held jump key).
	if humanoid.FloorMaterial ~= Enum.Material.Air or os.clock() - airborneSince < 0.2 then
		return
	end
	if extraJumpsUsed >= maxJumps - 1 then
		return
	end
	extraJumpsUsed += 1
	airborneSince = os.clock()
	local jumpVelocity = humanoid.UseJumpPower and humanoid.JumpPower or math.sqrt(2 * workspace.Gravity * humanoid.JumpHeight)
	local v = root.AssemblyLinearVelocity
	root.AssemblyLinearVelocity = Vector3.new(v.X, jumpVelocity, v.Z)
	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	puff(root, Color3.fromRGB(120, 230, 255))
	Sfx.Play("JumpPad", 1.4)
	Remotes.AssistUsed:FireServer()
end)

---------------------------------------------------------------- Boosted jumps count as assisted
local function watchJumps(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Jumping and not player:GetAttribute("BootsOff") and (player:GetAttribute("JumpBoost") or 1) > 1 then
			Remotes.AssistUsed:FireServer()
		end
	end)
end
player.CharacterAdded:Connect(watchJumps)
if player.Character then
	task.spawn(watchJumps, player.Character)
end

---------------------------------------------------------------- Rainbow name tags (Legendary draw)
local CollectionService = game:GetService("CollectionService")
RunService.RenderStepped:Connect(function()
	local rotation = (os.clock() * 120) % 360
	for _, gradient in ipairs(CollectionService:GetTagged("RainbowGradient")) do
		gradient.Rotation = rotation
		gradient.Offset = Vector2.new(math.sin(os.clock() * 2) * 0.3, 0)
	end
end)

---------------------------------------------------------------- Tools
local ROCKET_SPEED = 115
local ROCKET_COOLDOWN = 1.2
local SPEED_COIL_WALKSPEED = 26
local GRAVITY_COIL_LIFT = 0.6 -- cancels this fraction of gravity

local lastRocket = 0
local hooked = {}

local function hookTool(tool)
	if not tool:IsA("Tool") or hooked[tool] then
		return
	end
	hooked[tool] = true

	if tool.Name == "Rocket Launcher" then
		tool.Activated:Connect(function()
			local _, humanoid, root = parts()
			if not root or not humanoid or humanoid.Health <= 0 or os.clock() - lastRocket < ROCKET_COOLDOWN then
				return
			end
			lastRocket = os.clock()
			local direction = camera.CFrame.LookVector
			root.AssemblyLinearVelocity = direction * ROCKET_SPEED + Vector3.new(0, 25, 0)
			humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
			puff(root, Color3.fromRGB(255, 150, 40), 30)
			Sfx.Play("JumpPad", 0.6)
			Remotes.AssistUsed:FireServer()
		end)
	elseif tool.Name == "Speed Coil" then
		local normalSpeed
		tool.Equipped:Connect(function()
			local _, humanoid = parts()
			if humanoid then
				normalSpeed = humanoid.WalkSpeed
				humanoid.WalkSpeed = SPEED_COIL_WALKSPEED
				Remotes.AssistUsed:FireServer()
			end
		end)
		tool.Unequipped:Connect(function()
			local _, humanoid = parts()
			if humanoid and normalSpeed then
				humanoid.WalkSpeed = normalSpeed
			end
		end)
	elseif tool.Name == "Gravity Coil" then
		local force, conn
		tool.Equipped:Connect(function()
			local _, _, root = parts()
			if not root then
				return
			end
			force = Instance.new("VectorForce")
			local attachment = root:FindFirstChild("RootAttachment")
			if not attachment then
				attachment = Instance.new("Attachment")
				attachment.Parent = root
			end
			force.Attachment0 = attachment
			force.RelativeTo = Enum.ActuatorRelativeTo.World
			force.ApplyAtCenterOfMass = true
			force.Parent = root
			conn = RunService.Heartbeat:Connect(function()
				force.Force = Vector3.new(0, root.AssemblyMass * workspace.Gravity * GRAVITY_COIL_LIFT, 0)
			end)
			Remotes.AssistUsed:FireServer()
		end)
		tool.Unequipped:Connect(function()
			if conn then
				conn:Disconnect()
			end
			if force then
				force:Destroy()
			end
		end)
	end
end

local function watch(container)
	for _, child in ipairs(container:GetChildren()) do
		hookTool(child)
	end
	container.ChildAdded:Connect(hookTool)
end

player.CharacterAdded:Connect(function(character)
	watch(character)
	watch(player:WaitForChild("Backpack"))
end)
if player.Character then
	watch(player.Character)
end
watch(player:WaitForChild("Backpack"))
