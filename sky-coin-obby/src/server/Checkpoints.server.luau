-- Checkpoints: parts inside Workspace.Checkpoints named "1", "2", "3", ...
-- Touching the next one saves your stage; you respawn on your latest checkpoint.
-- Touching the last one is a WIN: +1 win, coins, speedrun time, then back to stage 1.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Server = ServerScriptService:WaitForChild("Server")
local PlayerData = require(Server:WaitForChild("PlayerData"))
local Course = require(Server:WaitForChild("Course"))
local Badges = require(Server:WaitForChild("Badges"))
local Abilities = require(Server:WaitForChild("Abilities"))

-- Roblox Creator Analytics: the first 10 stages are logged as the onboarding funnel, so the
-- dashboard shows exactly where new players quit. Every stage also logs a custom event.
-- (pcall: analytics must never break gameplay.)
local AnalyticsService = game:GetService("AnalyticsService")
local function logStage(player, stage)
	if stage <= 10 then
		pcall(AnalyticsService.LogOnboardingFunnelStepEvent, AnalyticsService, player, stage, "Stage " .. stage)
	end
	pcall(AnalyticsService.LogCustomEvent, AnalyticsService, player, "StageReached", stage)
end

-- First time reaching a milestone stage unlocks a free reward (Config.Milestones).
local function checkMilestones(player, stage)
	local data = PlayerData.Get(player)
	for _, milestone in ipairs(Config.Milestones or {}) do
		if stage >= milestone.Stage and not data.Unlocks[milestone.Unlock] then
			data.Unlocks[milestone.Unlock] = true
			if milestone.Unlock == "CometTrail" then
				data.Owned.CometTrail = true
			end
			Remotes.Notify:FireClient(player, milestone.Message, "gold")
			Abilities.Grant(player)
			PlayerData.Sync(player)
		end
	end
end

local function win(player)
	local data, session = PlayerData.Get(player), PlayerData.Session(player)
	local elapsed = session.RunStart and (workspace:GetServerTimeNow() - session.RunStart)
	local assisted = session.RunAssisted == true
	session.RunStart = nil
	session.RunAssisted = false

	-- Runs that used game-pass abilities still earn wins + coins, but don't set best times.
	local isNewBest = false
	if elapsed and not assisted and (data.BestTime == 0 or elapsed < data.BestTime) then
		data.BestTime = elapsed
		isNewBest = true
	end
	data.Wins += 1
	pcall(AnalyticsService.LogCustomEvent, AnalyticsService, player, "Win", data.Wins)
	local reward = PlayerData.AddCoins(player, Config.WinReward, true)
	Remotes.Won:FireClient(player, elapsed, isNewBest, reward, data.Wins, assisted)

	Badges.Award(player, "FirstWin")
	if not data.Owned.ChampionHalo then
		data.Owned.ChampionHalo = true
		Remotes.Notify:FireClient(player, "UNLOCKED: Champion Halo - equip it in the Shop! You escaped Gary!", "gold")
	end
	if data.Wins >= 10 then
		Badges.Award(player, "TenWins")
	end

	-- Back to the start for another (faster) run.
	task.delay(Config.SecondsBeforeRestart, function()
		if player.Parent and data.Stage == Course.FinalStage() then
			PlayerData.SetStage(player, 1)
			player:LoadCharacter()
		end
	end)
end

local function onTouched(checkpoint, hit)
	local stage = tonumber(checkpoint.Name)
	local character = hit.Parent
	local player = stage and Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end

	local data = PlayerData.Get(player)
	if not data or data.Mode == "OP" or stage <= data.Stage then
		return
	end
	if not Config.AllowStageSkipping and stage ~= data.Stage + 1 then
		return
	end

	PlayerData.SetStage(player, stage)
	checkMilestones(player, stage)
	logStage(player, stage)
	local zoneBadges = { [2] = "ReachedCandy", [3] = "ReachedSpace" }
	for index, zone in ipairs(Config.Zones) do
		if zone.FirstStage == stage and zoneBadges[index] then
			Badges.Award(player, zoneBadges[index])
		end
	end

	if stage == Course.FinalStage() then
		win(player)
	else
		local reward = Config.CheckpointReward > 0 and PlayerData.AddCoins(player, Config.CheckpointReward, true) or 0
		Remotes.CheckpointReached:FireClient(player, stage, reward)
	end
end

local hooked = {}
local function hook(checkpoint)
	if not checkpoint:IsA("BasePart") or hooked[checkpoint] then
		return
	end
	hooked[checkpoint] = true
	checkpoint.Touched:Connect(function(hit)
		onTouched(checkpoint, hit)
	end)
end

for _, child in ipairs(Course.Checkpoints:GetChildren()) do
	hook(child)
end
Course.Checkpoints.ChildAdded:Connect(hook)

-- Respawn on the player's saved checkpoint.
local function onCharacterAdded(player, character)
	local data = PlayerData.WaitFor(player)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not data or not root or data.Mode == "OP" then
		return -- OP Obby spawning is handled by OPObby.server
	end
	-- CharacterAdded fires before the character is placed in the world;
	-- wait for Roblox's own spawn positioning, or it overrides our teleport.
	if not character:IsDescendantOf(workspace) then
		character.AncestryChanged:Wait()
	end
	task.wait(0.1)
	if not character.Parent then
		return
	end
	-- Left (or died) during the win celebration: start a fresh run.
	if data.Stage >= Course.FinalStage() and Course.FinalStage() > 1 then
		PlayerData.SetStage(player, 1)
	end
	Course.PlaceOnStage(character, data.Stage)

	-- A run is timed from a fresh spawn on stage 1 to the finish.
	local session = PlayerData.Session(player)
	if data.Stage == 1 and session then
		session.RunStart = workspace:GetServerTimeNow()
		session.RunAssisted = false
		PlayerData.Sync(player)
	end
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

-- Stage select: jump back to any stage you've already reached (not counted as a timed run).
Remotes.TeleportStage.OnServerInvoke = function(player, stage)
	local data, session = PlayerData.Get(player), PlayerData.Session(player)
	stage = tonumber(stage)
	if not data or not stage or stage % 1 ~= 0 then
		return false, "Bad stage"
	end
	if stage < 1 or stage > math.min(data.MaxStage or 1, Course.FinalStage() - 1) then
		return false, "Reach that stage first!"
	end
	session.RunStart = nil
	PlayerData.SetStage(player, stage)
	if player.Character then
		Course.PlaceOnStage(player.Character, stage)
	end
	return true, "Teleported to stage " .. stage
end
