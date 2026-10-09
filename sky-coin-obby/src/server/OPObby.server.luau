-- The 1000-stage OP Obby: entering/leaving through portals, OP checkpoints, tier portals,
-- respawning on your OP stage, falling into the void, milestones and the finish.
local AnalyticsService = game:GetService("AnalyticsService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Server = ServerScriptService:WaitForChild("Server")
local PlayerData = require(Server:WaitForChild("PlayerData"))
local OPCourse = require(Server:WaitForChild("OPCourse"))
local Badges = require(Server:WaitForChild("Badges"))
local Abilities = require(Server:WaitForChild("Abilities"))

local OP = Config.OP

local function playerFromHit(hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if player and humanoid and humanoid.Health > 0 then
		return player
	end
	return nil
end

local function onTag(tagName, callback)
	local hooked = {}
	local function hook(part)
		if part:IsA("BasePart") and not hooked[part] then
			hooked[part] = true
			part.Touched:Connect(function(hit)
				local player = playerFromHit(hit)
				if player then
					callback(player, part)
				end
			end)
			part.AncestryChanged:Connect(function()
				if not part:IsDescendantOf(game) then
					hooked[part] = nil
				end
			end)
		end
	end
	for _, part in ipairs(CollectionService:GetTagged(tagName)) do
		hook(part)
	end
	CollectionService:GetInstanceAddedSignal(tagName):Connect(hook)
end

---------------------------------------------------------------- Progress
local function checkMilestones(player, stage)
	local data = PlayerData.Get(player)
	for _, milestone in ipairs(Config.OPMilestones or {}) do
		if stage >= milestone.Stage and not data.Unlocks[milestone.Unlock] then
			data.Unlocks[milestone.Unlock] = true
			if milestone.Unlock == "OPHalo" then
				data.Owned.OPHalo = true
			end
			if milestone.Badge then
				Badges.Award(player, milestone.Badge)
			end
			Remotes.Notify:FireClient(player, milestone.Message, "gold")
		end
	end
end

local function reachStage(player, stage)
	local data = PlayerData.Get(player)
	PlayerData.SetOPStage(player, stage)
	checkMilestones(player, stage)
	pcall(AnalyticsService.LogCustomEvent, AnalyticsService, player, "OPStageReached", stage)
	if stage >= OP.Stages then
		local reward = PlayerData.AddCoins(player, OP.FinishReward, true)
		Remotes.Won:FireClient(player, nil, false, reward, data.Wins, true)
		Remotes.Notify:FireClient(player, "YOU CONQUERED GREEDY GARY'S 1000-STAGE TOWER!", "gold")
	else
		local reward = PlayerData.AddCoins(player, OP.CheckpointReward, true)
		Remotes.CheckpointReached:FireClient(player, stage, reward, "OP")
	end
	PlayerData.Sync(player)
end

onTag("OPCheckpoint", function(player, part)
	local data = PlayerData.Get(player)
	local stage = part:GetAttribute("Stage")
	if data and data.Mode == "OP" and stage == data.OPStage + 1 then
		reachStage(player, stage)
	end
end)

-- Portal at the end of each tier: jump up to the next tier.
onTag("OPNextTier", function(player, part)
	local data = PlayerData.Get(player)
	local stage = part:GetAttribute("Stage")
	if not data or data.Mode ~= "OP" or not stage then
		return
	end
	if data.OPStage == stage - 1 then
		reachStage(player, stage)
	end
	if data.OPStage >= stage then
		OPCourse.PlaceOnStage(player.Character, stage)
	end
end)

---------------------------------------------------------------- Switching modes
local switching = {}
local function setMode(player, mode)
	local data = PlayerData.Get(player)
	if not data or data.Mode == mode or switching[player] then
		return
	end
	switching[player] = true
	data.Mode = mode
	PlayerData.Session(player).RunStart = nil
	PlayerData.Sync(player)
	Remotes.Notify:FireClient(player, mode == "OP"
		and ("Welcome to Gary's OP TOWER - stage %d of %d!"):format(data.OPStage, OP.Stages)
		or "Back to the story course!", "gold")
	player:LoadCharacter()
	task.delay(2, function()
		switching[player] = nil
	end)
end

onTag("OPPortal", function(player)
	setMode(player, "OP")
end)
onTag("StoryPortal", function(player)
	setMode(player, "Main")
end)

---------------------------------------------------------------- Spawning + void
local function onCharacterAdded(player, character)
	local data = PlayerData.WaitFor(player)
	if not data or data.Mode ~= "OP" then
		return
	end
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not root then
		return
	end
	if not character:IsDescendantOf(workspace) then
		character.AncestryChanged:Wait()
	end
	task.wait(0.1)
	OPCourse.PlaceOnStage(character, data.OPStage)
	Abilities.Grant(player)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	if player.Character then
		task.spawn(onCharacterAdded, player, player.Character)
	end
end
Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- There's no floor in the tower: falling well below your stage resets you.
task.spawn(function()
	while true do
		task.wait(0.5)
		for _, player in ipairs(Players:GetPlayers()) do
			local data = PlayerData.Get(player)
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if data and data.Mode == "OP" and root and humanoid and humanoid.Health > 0 then
				if root.Position.Y < OPCourse.PadPosition(data.OPStage).Y - 45 then
					humanoid.Health = 0
				end
			end
		end
	end
end)

-- Tier select (any tier you've reached), used by the STAGE SELECT window.
Remotes.TeleportOPTier.OnServerInvoke = function(player, tier)
	local data = PlayerData.Get(player)
	tier = tonumber(tier)
	if not data or not tier or tier % 1 ~= 0 or tier < 1 then
		return false, "Bad tier"
	end
	local stage = (tier - 1) * OP.TierSize + 1
	if stage > data.OPStage then
		return false, "Reach that tier first!"
	end
	data.OPStage = stage
	if data.Mode ~= "OP" then
		setMode(player, "OP")
	else
		PlayerData.Sync(player)
		OPCourse.PlaceOnStage(player.Character, stage)
	end
	return true, ("Teleported to tier %d"):format(tier)
end
