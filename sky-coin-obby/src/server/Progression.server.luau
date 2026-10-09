-- Retention systems:
--   Fast reset (R key / RESET button) + short respawn time
--   Forgiving failure: after repeated deaths on one stage you get a small speed/jump assist,
--     and after more you're offered a coin skip ("rubber banding")
--   Rebirth / prestige: reset for a permanent coin multiplier, exclusive trail and chat title
--   Idle "+1 Jump Power every second" stat (toggle in the HUD) + reward chests that need it
--   Trap doors and Gary jumpscares (clip-worthy moments)
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Server = ServerScriptService:WaitForChild("Server")
local PlayerData = require(Server:WaitForChild("PlayerData"))
local Course = require(Server:WaitForChild("Course"))
local OPCourse = require(Server:WaitForChild("OPCourse"))

Players.RespawnTime = Config.RespawnTime

---------------------------------------------------------------- Fast reset
local lastReset = {}
Remotes.QuickReset.OnServerEvent:Connect(function(player)
	if lastReset[player] and os.clock() - lastReset[player] < 1 then
		return
	end
	lastReset[player] = os.clock()
	player:LoadCharacter()
end)

---------------------------------------------------------------- Forgiving failure
local deaths = {} -- [Player] = { Key = "Main:12", Count = 3 }

local function stageKey(data)
	return data.Mode == "OP" and ("OP:" .. data.OPStage) or ("Main:" .. data.Stage)
end

local function onDied(player)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	local key = stageKey(data)
	local entry = deaths[player]
	if not entry or entry.Key ~= key then
		entry = { Key = key, Count = 0 }
		deaths[player] = entry
	end
	entry.Count += 1
	if entry.Count == 3 then
		player:SetAttribute("Assist", 1)
		Remotes.Notify:FireClient(player, "Gary feels a bit sorry for you... +10% speed & jump on this stage!", "gold")
	elseif entry.Count == 6 then
		player:SetAttribute("Assist", 2)
		Remotes.Notify:FireClient(player, "Still stuck? +20% speed & jump on this stage!", "gold")
	elseif entry.Count >= 8 and entry.Count % 4 == 0 then
		Remotes.Fx:FireClient(player, "OfferSkip", Config.CoinSkipCost)
	end
end

-- Moving to a new stage clears the assist.
local function watchStage(player)
	local stats = player:WaitForChild("leaderstats", 30)
	if not stats then
		return
	end
	for _, name in ipairs({ "Stage", "OP" }) do
		stats:WaitForChild(name).Changed:Connect(function()
			deaths[player] = nil
			player:SetAttribute("Assist", nil)
		end)
	end
end

Remotes.SkipWithCoins.OnServerInvoke = function(player)
	local data = PlayerData.Get(player)
	local entry = deaths[player]
	if not data or not entry or entry.Count < 8 then
		return false, "Not available"
	end
	if not PlayerData.SpendCoins(player, Config.CoinSkipCost) then
		return false, ("You need %d coins"):format(Config.CoinSkipCost)
	end
	PlayerData.Session(player).RunStart = nil
	if data.Mode == "OP" then
		if data.OPStage < Config.OP.Stages - 1 then
			PlayerData.SetOPStage(player, data.OPStage + 1)
			OPCourse.PlaceOnStage(player.Character, data.OPStage)
		end
	elseif data.Stage < Course.FinalStage() - 1 then
		PlayerData.SetStage(player, data.Stage + 1)
		if player.Character then
			Course.PlaceOnStage(player.Character, data.Stage)
		end
	end
	return true, "Skipped! You've got this."
end

---------------------------------------------------------------- Rebirth
local function rebirthCost(data)
	return Config.RebirthCost * ((data.Rebirths or 0) + 1)
end

Remotes.Rebirth.OnServerInvoke = function(player)
	local data = PlayerData.Get(player)
	if not data then
		return false, "Still loading"
	end
	if data.Wins < Config.RebirthWinsNeeded then
		return false, ("Finish the story %d time(s) first!"):format(Config.RebirthWinsNeeded)
	end
	local cost = rebirthCost(data)
	if data.Coins < cost then
		return false, ("Rebirth costs %d coins"):format(cost)
	end
	data.Rebirths = (data.Rebirths or 0) + 1
	data.Coins = 0
	data.Wins = 0
	data.Stage = 1
	data.Owned.RebirthTrail = true
	player:SetAttribute("Rebirths", data.Rebirths)
	PlayerData.Session(player).RunStart = nil
	PlayerData.Sync(player)
	player:LoadCharacter()
	Remotes.Fx:FireClient(player, "Confetti")
	return true, ("REBIRTH %d! Permanent x%s coins + Rebirth Trail!"):format(data.Rebirths, tostring(1 + data.Rebirths * Config.RebirthMultiplierStep))
end

---------------------------------------------------------------- Idle Jump Power (+1 every second)
task.spawn(function()
	while true do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			local data = PlayerData.Get(player)
			if data and (data.JumpPower or 0) < Config.MaxJumpPower then
				data.JumpPower = (data.JumpPower or 0) + 1
				player:SetAttribute("JumpPower", data.JumpPower)
			end
		end
	end
end)

---------------------------------------------------------------- Reward chests (Jump Power Tower)
local chestClaims = {} -- [Player] = { [ChestId] = os.clock() }
local function hookChest(chest)
	if not chest:IsA("BasePart") then
		return
	end
	chest.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then
			return
		end
		local id = chest:GetAttribute("ChestId") or chest:GetFullName()
		chestClaims[player] = chestClaims[player] or {}
		local last = chestClaims[player][id]
		if last and os.clock() - last < (chest:GetAttribute("CooldownMinutes") or 60) * 60 then
			return
		end
		chestClaims[player][id] = os.clock()
		local amount = PlayerData.AddCoins(player, chest:GetAttribute("Reward") or 50, false)
		Remotes.Notify:FireClient(player, ("CHEST: +%d coins!"):format(amount), "gold")
		Remotes.Fx:FireClient(player, "Confetti")
	end)
end
for _, chest in ipairs(CollectionService:GetTagged("RewardChest")) do
	hookChest(chest)
end
CollectionService:GetInstanceAddedSignal("RewardChest"):Connect(hookChest)

---------------------------------------------------------------- Trap doors + jumpscares
local function hookTrap(tile)
	if not tile:IsA("BasePart") then
		return
	end
	local busy = false
	tile.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if busy or not player then
			return
		end
		busy = true
		Remotes.Fx:FireClient(player, "Trap")
		task.wait(0.2)
		tile.CanCollide = false
		tile.Transparency = 0.8
		task.wait(3)
		tile.CanCollide = true
		tile.Transparency = 0
		busy = false
	end)
end
for _, tile in ipairs(CollectionService:GetTagged("TrapDoor")) do
	hookTrap(tile)
end
CollectionService:GetInstanceAddedSignal("TrapDoor"):Connect(hookTrap)

local scared = {} -- [Player] = os.clock()
local function hookScare(trigger)
	trigger.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player and (not scared[player] or os.clock() - scared[player] > 120) then
			scared[player] = os.clock()
			Remotes.Fx:FireClient(player, "Jumpscare", Config.VillainTaunts[math.random(#Config.VillainTaunts)])
		end
	end)
end
for _, trigger in ipairs(CollectionService:GetTagged("Jumpscare")) do
	hookScare(trigger)
end
CollectionService:GetInstanceAddedSignal("Jumpscare"):Connect(hookScare)

---------------------------------------------------------------- Lobby teleport + world portals
local function lobbyCFrame()
	local first = Course.GetCheckpoint(1)
	local spot = (first and first.Position or Vector3.new(0, 60, 0)) + Vector3.new(-26, 4, math.random(-6, 6))
	return CFrame.lookAt(spot, spot + Vector3.new(1, 0, 0))
end

Remotes.GoLobby.OnServerInvoke = function(player)
	local data = PlayerData.Get(player)
	local character = player.Character
	if not data or not character then
		return false, "Try again"
	end
	-- The lobby is in the story area, so leave the OP tower (OP progress is saved).
	if data.Mode == "OP" then
		data.Mode = "Main"
	end
	PlayerData.Session(player).RunStart = nil -- leaving the course ends a timed run
	PlayerData.Sync(player)
	character:PivotTo(lobbyCFrame())
	player:SetAttribute("InLobby", true)
	return true, "Welcome back to the lobby!"
end

Remotes.BackToStage.OnServerInvoke = function(player)
	local data = PlayerData.Get(player)
	if not data or not player.Character then
		return false, "Try again"
	end
	Course.PlaceOnStage(player.Character, data.Stage)
	player:SetAttribute("InLobby", nil)
	return true, ("Back to stage %d!"):format(data.Stage)
end

-- World portals in the plaza: jump to the start of any world you've reached.
local portalCooldown = {}
local function hookWorldPortal(portal)
	if not portal:IsA("BasePart") then
		return
	end
	portal.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		local data = player and PlayerData.Get(player)
		if not data or (portalCooldown[player] and os.clock() - portalCooldown[player] < 2) then
			return
		end
		portalCooldown[player] = os.clock()
		local stage = portal:GetAttribute("Stage") or 1
		if (data.MaxStage or 1) < stage then
			Remotes.Notify:FireClient(player, ("Reach stage %d first to unlock this world!"):format(stage), "bad")
			return
		end
		data.Mode = "Main"
		PlayerData.Session(player).RunStart = nil
		PlayerData.SetStage(player, stage)
		Course.PlaceOnStage(player.Character, stage)
		player:SetAttribute("InLobby", nil)
		Remotes.Notify:FireClient(player, ("Teleported to %s!"):format(portal:GetAttribute("World") or "the world"), "good")
	end)
end
for _, portal in ipairs(CollectionService:GetTagged("WorldPortal")) do
	hookWorldPortal(portal)
end
CollectionService:GetInstanceAddedSignal("WorldPortal"):Connect(hookWorldPortal)

---------------------------------------------------------------- Player lifecycle
local function onPlayerAdded(player)
	task.spawn(watchStage, player)
	task.spawn(function()
		local data = PlayerData.WaitFor(player)
		if data then
			player:SetAttribute("JumpPower", data.JumpPower or 0)
			player:SetAttribute("Rebirths", data.Rebirths or 0)
		end
	end)
	player.CharacterAdded:Connect(function(character)
		player:SetAttribute("InLobby", nil) -- respawns happen at your checkpoint
		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid then
			humanoid.Died:Connect(function()
				onDied(player)
			end)
		end
	end)
end
Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
Players.PlayerRemoving:Connect(function(player)
	lastReset[player], deaths[player], chestClaims[player], scared[player], portalCooldown[player] = nil, nil, nil, nil, nil
end)
