-- Loads, saves and hands out each player's data (coins, stage, owned + equipped cosmetics).
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
local profiles = {} -- [Player] = { Data = {...}, CanSave = bool }

local function defaultData()
	return {
		Coins = Config.StartingCoins,
		Stage = 1,
		Owned = {}, -- [itemId] = true
		Equipped = {}, -- [slot] = itemId
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
	leaderstats.Coins.Value = profile.Data.Coins
end

local function snapshot(data)
	return {
		Coins = data.Coins,
		Stage = data.Stage,
		Owned = data.Owned,
		Equipped = data.Equipped,
	}
end

function PlayerData.Get(player)
	local profile = profiles[player]
	return profile and profile.Data
end

-- Yields until the player's data is loaded. Returns nil if they leave first.
function PlayerData.WaitFor(player)
	while not profiles[player] and player.Parent do
		task.wait(0.1)
	end
	return PlayerData.Get(player)
end

function PlayerData.Sync(player)
	local data = PlayerData.Get(player)
	if data then
		updateLeaderstats(player)
		Remotes.DataUpdated:FireClient(player, snapshot(data))
	end
end

function PlayerData.AddCoins(player, amount)
	local data = PlayerData.Get(player)
	if not data then
		return
	end
	data.Coins += amount
	PlayerData.Sync(player)
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

local function onPlayerAdded(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	local stage = Instance.new("IntValue")
	stage.Name = "Stage"
	stage.Value = 1
	stage.Parent = leaderstats
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = leaderstats
	leaderstats.Parent = player

	local data, canSave = load(player)
	if not player.Parent then
		return -- left while loading
	end
	profiles[player] = { Data = data, CanSave = canSave }
	PlayerData.Sync(player)
end

local function onPlayerRemoving(player)
	save(player)
	profiles[player] = nil
end

Remotes.RequestData.OnServerInvoke = function(player)
	local data = PlayerData.WaitFor(player)
	return data and snapshot(data)
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
