-- Gives game-pass abilities: Rocket Launcher / Speed Coil / Gravity Coil tools, and
-- Double/Triple Jump (via the "MaxJumps" attribute). The actual movement runs on the client
-- (Abilities.client), because players' characters are simulated on their own device.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

local Abilities = {}

local function makeTool(name, tip, handleProps, extraParts)
	local tool = Instance.new("Tool")
	tool.Name = name
	tool.ToolTip = tip
	tool.CanBeDropped = false
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.CanCollide = false
	handle.Massless = true
	for key, value in pairs(handleProps) do
		handle[key] = value
	end
	handle.Parent = tool
	for _, props in ipairs(extraParts or {}) do
		local part = Instance.new("Part")
		part.CanCollide = false
		part.Massless = true
		local offset = props.Offset
		props.Offset = nil
		for key, value in pairs(props) do
			part[key] = value
		end
		part.CFrame = handle.CFrame * offset
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = handle
		weld.Part1 = part
		weld.Parent = part
		part.Parent = tool
	end
	return tool
end

local TOOLS = {
	RocketLauncher = makeTool("Rocket Launcher", "Click to blast off!", {
		Size = Vector3.new(1, 1, 4),
		Color = Color3.fromRGB(220, 40, 40),
		Material = Enum.Material.Metal,
	}, {
		{ Size = Vector3.new(1.2, 1.2, 0.6), Offset = CFrame.new(0, 0, -2.2), Color = Color3.fromRGB(255, 170, 40), Material = Enum.Material.Neon },
		{ Size = Vector3.new(0.4, 1, 0.4), Offset = CFrame.new(0, -0.9, 0.6), Color = Color3.fromRGB(40, 40, 40) },
	}),
	SpeedCoil = makeTool("Speed Coil", "Hold to run faster", {
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(2, 1, 1),
		Color = Color3.fromRGB(255, 60, 60),
		Material = Enum.Material.Neon,
	}),
	GravityCoil = makeTool("Gravity Coil", "Hold to float", {
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(2, 1, 1),
		Color = Color3.fromRGB(160, 80, 255),
		Material = Enum.Material.Neon,
	}),
	-- Free for everyone:
	GrappleHook = makeTool("Grappling Hook", "Click a glowing grapple point to swing!", {
		Size = Vector3.new(0.6, 0.6, 2.4),
		Color = Color3.fromRGB(70, 70, 80),
		Material = Enum.Material.Metal,
	}, {
		{ Size = Vector3.new(0.9, 0.9, 0.5), Offset = CFrame.new(0, 0, -1.3), Color = Color3.fromRGB(80, 255, 255), Material = Enum.Material.Neon },
	}),
	SlapHand = makeTool("Slap Hand", "Slap your friends in the lobby and hub!", {
		Size = Vector3.new(1.6, 0.4, 2),
		Color = Color3.fromRGB(255, 200, 160),
		Material = Enum.Material.SmoothPlastic,
	}),
}
local FREE_TOOLS = { "GrappleHook", "SlapHand" }

local function giveTool(player, key)
	local template = TOOLS[key]
	local starterGear = player:FindFirstChild("StarterGear")
	if not template or not starterGear or starterGear:FindFirstChild(template.Name) then
		return
	end
	template:Clone().Parent = starterGear -- kept after respawns
	local backpack = player:FindFirstChildOfClass("Backpack")
	local character = player.Character
	if backpack and not backpack:FindFirstChild(template.Name) and not (character and character:FindFirstChild(template.Name)) then
		template:Clone().Parent = backpack
	end
end

-- Call after the player's passes are known or change.
function Abilities.Grant(player)
	local session = PlayerData.Session(player)
	if not session then
		return
	end
	local passes = session.Passes
	local data = PlayerData.Get(player)
	local unlocks = data and data.Unlocks or {}
	for key in pairs(TOOLS) do
		if passes[key] then
			giveTool(player, key)
		end
	end
	for _, key in ipairs(FREE_TOOLS) do
		giveTool(player, key)
	end
	-- Spring Boots (stage 10 milestone) give a free double jump.
	player:SetAttribute("MaxJumps", passes.TripleJump and 3 or (passes.DoubleJump or unlocks.SpringBoots) and 2 or 1)
	-- Daily Draw jump boots.
	local rarity = PlayerData.ActiveDraw(player)
	player:SetAttribute("JumpBoost", rarity and rarity.JumpBoost or 1)
end

-- The client reports when it uses an ability, so that run's time skips the leaderboard.
Remotes.AssistUsed.OnServerEvent:Connect(function(player)
	local session = PlayerData.Session(player)
	if session and session.RunStart and not session.RunAssisted then
		session.RunAssisted = true
		PlayerData.Sync(player)
	end
end)

---------------------------------------------------------------- Slap Hand (lobby + hub only, so nobody gets slapped off the course)
local Players = game:GetService("Players")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local function safeZones()
	local zones = {}
	local checkpoints = workspace:FindFirstChild("Checkpoints")
	local first = checkpoints and checkpoints:FindFirstChild("1")
	if first then
		table.insert(zones, { Center = first.Position + Vector3.new(-14, 0, 0), Radius = 24 })
	end
	local hub = checkpoints and checkpoints:FindFirstChild(tostring(Config.HubStage or 20))
	if hub then
		table.insert(zones, { Center = hub.Position + Vector3.new(0, 0, -62), Radius = 44 })
	end
	return zones
end

local function inSafeZone(position)
	for _, zone in ipairs(safeZones()) do
		local offset = position - zone.Center
		if Vector2.new(offset.X, offset.Z).Magnitude < zone.Radius and math.abs(offset.Y) < 30 then
			return true
		end
	end
	return false
end

local lastSlap = {}
Remotes.Slap.OnServerEvent:Connect(function(player, target)
	if typeof(target) ~= "Instance" or not target:IsA("Player") or target == player then
		return
	end
	if lastSlap[player] and os.clock() - lastSlap[player] < 0.8 then
		return
	end
	local a = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local b = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	local tool = player.Character and player.Character:FindFirstChild("Slap Hand")
	if not a or not b or not tool or (a.Position - b.Position).Magnitude > 9 then
		return
	end
	if not inSafeZone(a.Position) or not inSafeZone(b.Position) then
		Remotes.Notify:FireClient(player, "Slapping only works in the lobby and hub!", "bad")
		return
	end
	lastSlap[player] = os.clock()
	local direction = (b.Position - a.Position) * Vector3.new(1, 0, 1)
	direction = direction.Magnitude > 0 and direction.Unit or Vector3.new(0, 0, 1)
	-- The target's own device moves their character, so it applies the knockback.
	Remotes.Fx:FireClient(target, "Slapped", direction)
	Remotes.Fx:FireClient(player, "SlapHit")
end)
Players.PlayerRemoving:Connect(function(player)
	lastSlap[player] = nil
end)

return Abilities
