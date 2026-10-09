-- Game-pass abilities on the player's own device:
--   Double/Triple Jump (MaxJumps attribute, toggle with the player's "MultiJumpOff" attribute),
--   Rocket Launcher (click to launch), Speed Coil and Gravity Coil (hold to use).
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
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
RunService.RenderStepped:Connect(function()
	local rotation = (os.clock() * 120) % 360
	for _, gradient in ipairs(CollectionService:GetTagged("RainbowGradient")) do
		gradient.Rotation = rotation
		gradient.Offset = Vector2.new(math.sin(os.clock() * 2) * 0.3, 0)
	end
end)

---------------------------------------------------------------- Tools
local GRAPPLE_RANGE = 110
local GRAPPLE_SPEED = 75
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
	elseif tool.Name == "Grappling Hook" then
		local mouse = player:GetMouse()
		local grappling = false
		tool.Activated:Connect(function()
			local _, humanoid, root = parts()
			if grappling or not root or not humanoid or humanoid.Health <= 0 then
				return
			end
			-- Only glowing grapple points work, so the obby can't be skipped with the hook.
			local target = mouse.Target
			if not (target and CollectionService:HasTag(target, "GrapplePoint")) then
				pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
					Title = "Grappling Hook",
					Text = "Aim at a glowing cyan grapple point!",
					Duration = 2,
				})
				return
			end
			local point = target.Position
			if (point - root.Position).Magnitude > GRAPPLE_RANGE then
				return
			end
			grappling = true
			Sfx.Play("JumpPad", 1.6)
			-- Rope visual
			local handle = tool:FindFirstChild("Handle")
			local a0 = Instance.new("Attachment")
			a0.Parent = handle or root
			local a1 = Instance.new("Attachment")
			a1.WorldPosition = point
			a1.Parent = workspace.Terrain
			local beam = Instance.new("Beam")
			beam.Attachment0, beam.Attachment1 = a0, a1
			beam.Width0, beam.Width1 = 0.25, 0.25
			beam.Color = ColorSequence.new(Color3.fromRGB(80, 255, 255))
			beam.LightEmission = 1
			beam.FaceCamera = true
			beam.Parent = a1
			humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
			local started = os.clock()
			while os.clock() - started < 1.1 do
				local offset = point - root.Position
				if offset.Magnitude < 5 then
					break
				end
				root.AssemblyLinearVelocity = offset.Unit * GRAPPLE_SPEED + Vector3.new(0, 6, 0)
				RunService.Heartbeat:Wait()
			end
			a0:Destroy()
			a1:Destroy()
			grappling = false
			Remotes.AssistUsed:FireServer()
		end)
	elseif tool.Name == "Slap Hand" then
		tool.Activated:Connect(function()
			local _, _, root = parts()
			if not root then
				return
			end
			local nearest, best = nil, 9
			for _, other in ipairs(Players:GetPlayers()) do
				local otherRoot = other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart")
				if otherRoot then
					local distance = (otherRoot.Position - root.Position).Magnitude
					if distance < best then
						nearest, best = other, distance
					end
				end
			end
			Sfx.Play("Click", 0.7)
			if nearest then
				Remotes.Slap:FireServer(nearest)
			end
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
