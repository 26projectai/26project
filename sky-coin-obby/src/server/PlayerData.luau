-- Loads, saves and hands out each player's data (coins, stage, wins, cosmetics, daily streak).
-- Other server scripts require this module instead of touching the DataStore directly.
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local AUTOSAVE_SECONDS = 120

-- GetDataStore errors in Studio when the place isn't published / API access is off.
local storeOk, store = pcall(function()
	return DataStoreService:GetDataStore(Config.DataStoreName)
end)
if not storeOk then
	warn("[PlayerData] DataStores unavailable, progress will not save:", store)
	store = nil
end

local PlayerData = {}
local profiles = {} -- [Player] = { Data = {...}, Session = {...}, CanSave = bool }

local function defaultData()
	return {
		Coins = Config.StartingCoins,
		Stage = 1,
		Wins = 0,
		BestTime = 0, -- seconds, 0 = no full run yet
		Owned = {}, -- [itemId] = true
		Equipped = {}, -- [slot] = itemId
		LastDaily = 0, -- os.time() of last daily claim
		DailyStreak = 0,
		RewardedReferrals = {}, -- [tostring(userId)] = true, friends who joined via your invite
		JoinedViaInvite = false,
	}
end

local function reconcile(saved)
	local data = defaultData()
	if type(saved) ~= "table" then
		return data
	end
	for key, value in pairs(saved) do
		data[key] = value
	end
	return data
end

local function keyFor(player)
	return "Player_" .. player.UserId
end

local function load(player)
	if not store then
		return defaultData(), false
	end
	for attempt = 1, 3 do
		local ok, result = pcall(function()
			return store:GetAsync(keyFor(player))
		end)
		if ok then
			return reconcile(result), true
		end
		warn(("[PlayerData] Load attempt %d failed for %s: %s"):format(attempt, player.Name, tostring(result)))
		task.wait(attempt * 2)
	end
	-- Never save over data we failed to read, or we'd wipe the player's progress.
	return defaultData(), false
end

local function save(player)
	local profile = profiles[player]
	if not profile or not profile.CanSave or not store then
		return
	end
	local ok, err = pcall(function()
		store:SetAsync(keyFor(player), profile.Data)
	end)
	if not ok then
		warn("[PlayerData] Save failed for", player.Name, err)
	end
end

local function updateLeaderstats(player)
	local profile = profiles[player]
	local leaderstats = player:FindFirstChild("leaderstats")
	if not profile or not leaderstats then
		return
	end
	leaderstats.Stage.Value = profile.Data.Stage
	leaderstats.Wins.Value = profile.Data.Wins
	leaderstats.Coins.Value = profile.Data.Coins
end

function PlayerData.Get(player)
	local profile = profiles[player]
	return profile and profile.Data
end

-- Per-server, not saved: run timer, owned game passes, etc.
function PlayerData.Session(player)
	local profile = profiles[player]
	return profile and profile.Session
end

-- Yields until the player's data is loaded. Returns nil if they leave first.
function PlayerData.WaitFor(player)
	while not profiles[player] and player.Parent do
		task.wait(0.1)
	end
	return PlayerData.Get(player)
end

function PlayerData.DailyReady(data)
	return os.time() - data.LastDaily >= Config.DailyCooldownHours * 3600
end

function PlayerData.Multiplier(player)
	local data, session = PlayerData.Get(player), PlayerData.Session(player)
	if not data then
		return 1
	end
	local mult = math.min(1 + data.Wins * Config.WinMultiplierStep, Config.MaxWinMultiplier)
	if session.Passes.DoubleCoins then
		mult *= 2
	end
	if session.Passes.VIP then
		mult *= Config.VIPMultiplier
	end
	return mult
end

local function snapshot(player)
	local data, session = PlayerData.Get(player), PlayerData.Session(player)
	local streak = data.DailyStreak
	if os.time() - data.LastDaily > 48 * 3600 then
		streak = 0 -- missed a day; next claim restarts at day 1
	end
	local nextDay = (streak % #Config.DailyRewards) + 1
	return {
		Coins = data.Coins,
		Stage = data.Stage,
		Wins = data.Wins,
		BestTime = data.BestTime,
		Owned = data.Owned,
		Equipped = data.Equipped,
		Multiplier = PlayerData.Multiplier(player),
		RunStart = session.RunStart, -- workspace:GetServerTimeNow() when the current run began
		RunAssisted = session.RunAssisted, -- used a game-pass ability: time won't hit the leaderboard
		DailyReady = PlayerData.DailyReady(data),
		NextDailyDay = nextDay,
		NextDailyReward = Config.DailyRewards[nextDay],
		Passes = session.Passes,
	}
end

function PlayerData.Sync(player)
	if PlayerData.Get(player) then
		updateLeaderstats(player)
		Remotes.DataUpdated:FireClient(player, snapshot(player))
	end
end

-- Adds coins. With applyMultiplier, wins / game pass bonuses are included.
-- Returns the amount actually added.
function PlayerData.AddCoins(player, amount, applyMultiplier)
	local data = PlayerData.Get(player)
	if not data then
		return 0
	end
	if applyMultiplier then
		amount = math.floor(amount * PlayerData.Multiplier(player) + 0.5)
	end
	data.Coins += amount
	PlayerData.Sync(player)
	return amount
end

-- Returns true and deducts if the player can afford it.
function PlayerData.SpendCoins(player, amount)
	local data = PlayerData.Get(player)
	if not data or data.Coins < amount then
		return false
	end
	data.Coins -= amount
	PlayerData.Sync(player)
	return true
end

function PlayerData.SetStage(player, stage)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	data.Stage = stage
	PlayerData.Sync(player)
end

function PlayerData.SetPass(player, passName, owned)
	local session = PlayerData.Session(player)
	if session then
		session.Passes[passName] = owned
		PlayerData.Sync(player)
	end
end

local function onPlayerAdded(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	for _, name in ipairs({ "Stage", "Wins", "Coins" }) do
		local value = Instance.new("IntValue")
		value.Name = name
		value.Parent = leaderstats
	end
	leaderstats.Stage.Value = 1
	leaderstats.Parent = player

	local data, canSave = load(player)
	if not player.Parent then
		return -- left while loading
	end
	profiles[player] = {
		Data = data,
		CanSave = canSave,
		Session = { Passes = {}, RunStart = nil },
	}
	PlayerData.Sync(player)
end

local function onPlayerRemoving(player)
	save(player)
	profiles[player] = nil
end

Remotes.RequestData.OnServerInvoke = function(player)
	return PlayerData.WaitFor(player) and snapshot(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

game:BindToClose(function()
	local pending = 0
	for player in pairs(profiles) do
		pending += 1
		task.spawn(function()
			save(player)
			pending -= 1
		end)
	end
	local deadline = os.clock() + 25
	while pending > 0 and os.clock() < deadline do
		task.wait(0.1)
	end
end)

task.spawn(function()
	while true do
		task.wait(AUTOSAVE_SECONDS)
		for player in pairs(profiles) do
			task.spawn(save, player)
		end
	end
end)

return PlayerData
