-- Luxury NPCs that stroll around the spawn lobby and the central hub.
-- Touching one gives a coin boost (Config.NPCBoostMultiplier for Config.NPCBoostSeconds).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

local GOLD = Color3.fromRGB(255, 200, 40)
local NPC_TYPES = {
	{ Name = "Sir Goldsworth", Suit = Color3.fromRGB(30, 30, 35), Accent = GOLD },
	{ Name = "Lady Diamond", Suit = Color3.fromRGB(240, 240, 255), Accent = Color3.fromRGB(120, 210, 255) },
	{ Name = "Baron Bling", Suit = Color3.fromRGB(120, 30, 160), Accent = GOLD },
	{ Name = "Countess Coin", Suit = Color3.fromRGB(200, 30, 60), Accent = GOLD },
}

-- Walking areas: { center, radius } on the lobby and hub islands (built by the course builder).
local function walkAreas()
	local areas = {}
	local checkpoints = workspace:FindFirstChild("Checkpoints")
	local first = checkpoints and checkpoints:FindFirstChild("1")
	if first then
		table.insert(areas, { Center = first.Position + Vector3.new(-16, 0, 0), Radius = 12, Count = 2 })
	end
	local hubStage = checkpoints and checkpoints:FindFirstChild(tostring(Config.HubStage or 20))
	if hubStage then
		table.insert(areas, { Center = hubStage.Position + Vector3.new(0, 0, -62), Radius = 18, Count = 2 })
	end
	return areas
end

local function weldTo(part, target, offset)
	part.Anchored = false
	part.CanCollide = false
	part.Massless = true
	part.CFrame = target.CFrame * offset
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = target
	weld.Part1 = part
	weld.Parent = part
end

local function decorate(model, npcType)
	local head = model:FindFirstChild("Head")
	if not head then
		return
	end
	-- Crown
	local crown = Instance.new("Part")
	crown.Name = "Crown"
	crown.Shape = Enum.PartType.Cylinder
	crown.Size = Vector3.new(0.7, 1.4, 1.4)
	crown.Color = GOLD
	crown.Material = Enum.Material.Neon
	weldTo(crown, head, CFrame.new(0, 0.9, 0) * CFrame.Angles(0, 0, math.rad(90)))
	crown.Parent = model
	-- Sunglasses
	local glasses = Instance.new("Part")
	glasses.Name = "Sunglasses"
	glasses.Size = Vector3.new(1.1, 0.25, 0.1)
	glasses.Color = Color3.new(0, 0, 0)
	glasses.Material = Enum.Material.Glass
	weldTo(glasses, head, CFrame.new(0, 0.15, -0.6))
	glasses.Parent = model
	-- Sparkles + gold glow
	local root = model:FindFirstChild("HumanoidRootPart")
	if root then
		local sparkles = Instance.new("ParticleEmitter")
		sparkles.Color = ColorSequence.new(npcType.Accent)
		sparkles.LightEmission = 1
		sparkles.Size = NumberSequence.new(0.3, 0)
		sparkles.Rate = 10
		sparkles.Lifetime = NumberRange.new(0.8, 1.4)
		sparkles.Speed = NumberRange.new(1, 3)
		sparkles.SpreadAngle = Vector2.new(180, 180)
		sparkles.Parent = root
		local light = Instance.new("PointLight")
		light.Color = npcType.Accent
		light.Range = 10
		light.Brightness = 1.5
		light.Parent = root
	end
	-- Name sign
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(220, 60)
	gui.StudsOffset = Vector3.new(0, 3.2, 0)
	gui.MaxDistance = 70
	gui.AlwaysOnTop = true
	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(1, 0.55)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.FredokaOne
	title.TextScaled = true
	title.Text = "💎 " .. npcType.Name
	title.TextColor3 = GOLD
	title.TextStrokeTransparency = 0
	title.Parent = gui
	local hint = title:Clone()
	hint.Position = UDim2.fromScale(0, 0.55)
	hint.Size = UDim2.fromScale(1, 0.45)
	hint.Text = ("Touch me for %dx COINS!"):format(Config.NPCBoostMultiplier)
	hint.TextColor3 = Color3.new(1, 1, 1)
	hint.Parent = gui
	gui.Adornee = head
	gui.Parent = head
end

local function spawnNPC(npcType, area)
	local description = Instance.new("HumanoidDescription")
	description.HeadColor = Color3.fromRGB(255, 220, 180)
	description.LeftArmColor = npcType.Suit
	description.RightArmColor = npcType.Suit
	description.TorsoColor = npcType.Suit
	description.LeftLegColor = Color3.fromRGB(20, 20, 25)
	description.RightLegColor = Color3.fromRGB(20, 20, 25)
	local ok, model = pcall(Players.CreateHumanoidModelFromDescription, Players, description, Enum.HumanoidRigType.R15)
	if not ok or not model then
		warn("[NPCs] Could not create NPC:", model)
		return
	end
	model.Name = npcType.Name
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.WalkSpeed = 7
	decorate(model, npcType)
	model:PivotTo(CFrame.new(area.Center + Vector3.new(math.random(-6, 6), 4, math.random(-6, 6))))
	model.Parent = workspace
	root:SetNetworkOwner(nil) -- the server drives NPC movement

	-- Touch = coin boost, with a cooldown per player.
	local lastBoost = {}
	local function onTouched(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		local session = player and PlayerData.Session(player)
		if not session then
			return
		end
		local now = os.clock()
		if lastBoost[player] and now - lastBoost[player] < Config.NPCCooldownSeconds then
			return
		end
		lastBoost[player] = now
		session.BoostUntil = workspace:GetServerTimeNow() + Config.NPCBoostSeconds
		PlayerData.Sync(player)
		Remotes.Notify:FireClient(
			player,
			("%s gave you %dx COINS for %d seconds!"):format(npcType.Name, Config.NPCBoostMultiplier, Config.NPCBoostSeconds),
			"gold"
		)
	end
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Touched:Connect(onTouched)
		end
	end

	-- Stroll between random points, pausing now and then.
	task.spawn(function()
		while model.Parent and humanoid.Health > 0 do
			local angle = math.random() * math.pi * 2
			local distance = math.random() * area.Radius
			local target = area.Center + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
			humanoid:MoveTo(target)
			local reached = false
			local conn = humanoid.MoveToFinished:Connect(function()
				reached = true
			end)
			local deadline = os.clock() + 8
			while not reached and os.clock() < deadline do
				task.wait(0.2)
			end
			conn:Disconnect()
			task.wait(math.random(1, 4))
			-- Safety: if it ever wanders off the island, put it back.
			if root.Position.Y < area.Center.Y - 20 then
				model:PivotTo(CFrame.new(area.Center + Vector3.new(0, 4, 0)))
			end
		end
	end)
end

workspace:WaitForChild("Checkpoints", 30)
task.wait(2) -- let the islands finish building
local index = 0
for _, area in ipairs(walkAreas()) do
	for _ = 1, area.Count do
		index += 1
		task.spawn(spawnNPC, NPC_TYPES[(index - 1) % #NPC_TYPES + 1], area)
	end
end
