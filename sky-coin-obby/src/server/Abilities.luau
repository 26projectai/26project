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
}

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

return Abilities
