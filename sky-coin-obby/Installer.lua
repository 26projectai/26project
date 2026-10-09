-- Sky Coin Obby installer: paste into the Studio command bar and press Enter/Run.
-- Creates every folder and script. Safe to run again (it replaces the old copies).
local function folder(parent, name)
	local old = parent:FindFirstChild(name)
	if old then old:Destroy() end
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end
local function add(parent, className, name, source)
	local s = Instance.new(className)
	s.Name = name
	s.Source = source
	s.Parent = parent
end
local spawn = workspace:FindFirstChild("SpawnLocation")
if spawn then spawn:Destroy() end
local f_shared = folder(game:GetService("ReplicatedStorage"), "Shared")
add(f_shared, "ModuleScript", "Config", [==[
-- Game-wide settings. Tweak these freely.
local Config = {}

-- Change the version suffix to wipe everyone's saved progress.
Config.DataStoreName = "SkyCoinObby_v1"

-- Economy
Config.StartingCoins = 0
Config.CoinValue = 1 -- default value per coin (override per coin with a "Value" attribute)
Config.CoinRespawnSeconds = 60 -- how long before a player can grab the same coin again
Config.CheckpointReward = 5 -- bonus coins the first time a player reaches a new stage

-- Checkpoints
Config.AllowStageSkipping = false -- false = players must touch checkpoints in order

-- Visuals
Config.CoinSpinSpeed = 2 -- radians per second

-- Sample course: builds a 10-stage obby automatically if Workspace has no
-- "Checkpoints" folder. Set to false once you've built your own course.
Config.BuildSampleCourse = true
Config.SampleCourseStages = 10

-- Upload the PNGs in /art to Roblox and paste the asset ids here
-- (format: "rbxassetid://1234567890"). "rbxassetid://0" = use the built-in fallback look.
Config.Images = {
	Coin = "rbxassetid://0",
	ShopButton = "rbxassetid://0",
}

-- Optional sound ids from the Creator Store. "rbxassetid://0" = silent.
Config.Sounds = {
	Coin = "rbxassetid://0",
	Checkpoint = "rbxassetid://0",
	Purchase = "rbxassetid://0",
}

return Config
]==])
add(f_shared, "ModuleScript", "Remotes", [==[
-- Creates the RemoteEvents/RemoteFunctions on the server and finds them on the client.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

local folder
if isServer then
	folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end
else
	folder = ReplicatedStorage:WaitForChild("Remotes")
end

local function get(name, className)
	if not isServer then
		return folder:WaitForChild(name)
	end
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new(className)
		remote.Name = name
		remote.Parent = folder
	end
	return remote
end

return {
	DataUpdated = get("DataUpdated", "RemoteEvent"), -- server -> client: coins/stage/owned/equipped
	RequestData = get("RequestData", "RemoteFunction"), -- client -> server: initial snapshot
	CoinCollected = get("CoinCollected", "RemoteEvent"), -- server -> client: hide a coin locally
	CheckpointReached = get("CheckpointReached", "RemoteEvent"), -- server -> client: celebration
	ShopAction = get("ShopAction", "RemoteFunction"), -- client -> server: Buy / Equip / Unequip
}
]==])
add(f_shared, "ModuleScript", "ShopCatalog", [==[
-- Everything sold in the cosmetic shop.
-- Slot: "Trail" or "Aura" (a player can equip one of each).
-- Icon: paste the uploaded asset id for the matching PNG in /art.
local ShopCatalog = {}

ShopCatalog.Items = {
	{
		Id = "RainbowTrail",
		Name = "Rainbow Trail",
		Slot = "Trail",
		Price = 25,
		Icon = "rbxassetid://0", -- art/item-rainbow-trail.png
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 160, 40)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 235, 60)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(60, 220, 90)),
			ColorSequenceKeypoint.new(0.8, Color3.fromRGB(60, 140, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 80, 255)),
		}),
	},
	{
		Id = "FireTrail",
		Name = "Fire Trail",
		Slot = "Trail",
		Price = 75,
		Icon = "rbxassetid://0", -- art/item-fire-trail.png
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 120)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 120, 20)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 20, 20)),
		}),
	},
	{
		Id = "GalaxyTrail",
		Name = "Galaxy Trail",
		Slot = "Trail",
		Price = 150,
		Icon = "rbxassetid://0", -- art/item-galaxy-trail.png
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 230, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140, 60, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 10, 90)),
		}),
	},
	{
		Id = "SparkleAura",
		Name = "Sparkle Aura",
		Slot = "Aura",
		Kind = "Sparkles",
		Price = 100,
		Icon = "rbxassetid://0", -- art/item-sparkle-aura.png
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 210, 60)),
	},
	{
		Id = "FireAura",
		Name = "Fire Aura",
		Slot = "Aura",
		Kind = "Fire",
		Price = 200,
		Icon = "rbxassetid://0", -- art/item-fire-aura.png
		Color = Color3.fromRGB(255, 140, 30),
		SecondaryColor = Color3.fromRGB(60, 120, 255),
	},
	{
		Id = "GoldenGlow",
		Name = "Golden Glow",
		Slot = "Aura",
		Kind = "Glow",
		Price = 400,
		Icon = "rbxassetid://0", -- art/item-golden-glow.png
		Color = Color3.fromRGB(255, 200, 40),
	},
}

local byId = {}
for _, item in ipairs(ShopCatalog.Items) do
	byId[item.Id] = item
end

function ShopCatalog.Get(id)
	return byId[id]
end

return ShopCatalog
]==])
local f_server = folder(game:GetService("ServerScriptService"), "Server")
add(f_server, "Script", "Checkpoints", [==[
-- Checkpoints: parts inside Workspace.Checkpoints named "1", "2", "3", ...
-- Touching the next one saves your stage; you respawn on your latest checkpoint.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

local checkpoints = workspace:WaitForChild("Checkpoints")

local function finalStage()
	local highest = 0
	for _, child in ipairs(checkpoints:GetChildren()) do
		local n = tonumber(child.Name)
		if n and n > highest then
			highest = n
		end
	end
	return highest
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
	if not data or stage <= data.Stage then
		return
	end
	if not Config.AllowStageSkipping and stage ~= data.Stage + 1 then
		return
	end

	PlayerData.SetStage(player, stage)
	if Config.CheckpointReward > 0 then
		PlayerData.AddCoins(player, Config.CheckpointReward)
	end
	Remotes.CheckpointReached:FireClient(player, stage, stage == finalStage())
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

for _, child in ipairs(checkpoints:GetChildren()) do
	hook(child)
end
checkpoints.ChildAdded:Connect(hook)

-- Respawn on the player's saved checkpoint.
local function onCharacterAdded(player, character)
	local data = PlayerData.WaitFor(player)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not data or not root then
		return
	end
	local checkpoint = checkpoints:FindFirstChild(tostring(math.min(data.Stage, finalStage())))
	if checkpoint and checkpoint:IsA("BasePart") then
		task.wait() -- let Roblox finish its own spawn positioning first
		character:PivotTo(CFrame.new(checkpoint.Position + Vector3.new(0, checkpoint.Size.Y / 2 + 3, 0)))
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
]==])
add(f_server, "Script", "Coins", [==[
-- Coins: any BasePart inside Workspace.Coins. Each player can grab each coin once,
-- then it reappears for them after Config.CoinRespawnSeconds.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

local coinsFolder = workspace:WaitForChild("Coins")
local collected = {} -- [Player] = { [coin] = true }

local function onTouched(coin, hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root then
		return
	end

	local mine = collected[player]
	if not mine or mine[coin] then
		return
	end
	-- Basic sanity check against exploiters firing touches from far away.
	if (root.Position - coin.Position).Magnitude > coin.Size.Magnitude + 12 then
		return
	end

	mine[coin] = true
	PlayerData.AddCoins(player, coin:GetAttribute("Value") or Config.CoinValue)
	Remotes.CoinCollected:FireClient(player, coin, Config.CoinRespawnSeconds)

	task.delay(Config.CoinRespawnSeconds, function()
		if collected[player] then
			collected[player][coin] = nil
		end
	end)
end

local hooked = {}
local function hook(part)
	if not part:IsA("BasePart") or hooked[part] then
		return
	end
	hooked[part] = true
	part.CanCollide = false
	part.Touched:Connect(function(hit)
		onTouched(part, hit)
	end)
end

for _, d in ipairs(coinsFolder:GetDescendants()) do
	hook(d)
end
coinsFolder.DescendantAdded:Connect(hook)

Players.PlayerAdded:Connect(function(player)
	collected[player] = {}
end)
for _, player in ipairs(Players:GetPlayers()) do
	collected[player] = {}
end
Players.PlayerRemoving:Connect(function(player)
	collected[player] = nil
end)
]==])
add(f_server, "Script", "CourseBuilder", [==[
-- Builds a playable sample obby so you can test right away.
-- Skips itself if Workspace already has a "Checkpoints" folder, or if
-- Config.BuildSampleCourse is false. Delete this script once you've built your own course.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

if not Config.BuildSampleCourse or workspace:FindFirstChild("Checkpoints") then
	return
end

local STAGES = Config.SampleCourseStages
local SPACING = 60 -- studs between checkpoints
local BASE_Y = 60 -- course height

local PLATFORM_COLORS = {
	Color3.fromRGB(80, 170, 255),
	Color3.fromRGB(255, 120, 200),
	Color3.fromRGB(150, 110, 255),
	Color3.fromRGB(255, 200, 70),
	Color3.fromRGB(90, 220, 200),
}

local function folder(name)
	local f = Instance.new("Folder")
	f.Name = name
	return f
end

local course = folder("SampleCourse")
local checkpoints = folder("Checkpoints")
local coins = folder("Coins")
local killParts = folder("KillParts")

local function part(props, className)
	local p = Instance.new(className or "Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	local parent = props.Parent
	props.Parent = nil
	for key, value in pairs(props) do
		p[key] = value
	end
	p.Parent = parent
	return p
end

local function platform(stage, position, size)
	return part({
		Name = "Platform",
		Size = size,
		Position = position,
		Color = PLATFORM_COLORS[(stage - 1) % #PLATFORM_COLORS + 1],
		Parent = course,
	})
end

local function killBrick(position, size)
	return part({
		Name = "KillBrick",
		Size = size,
		Position = position,
		Color = Color3.fromRGB(255, 40, 40),
		Material = Enum.Material.Neon,
		Parent = killParts,
	})
end

local function coin(position)
	return part({
		Name = "Coin",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.5, 3, 3),
		Position = position,
		Color = Color3.fromRGB(255, 205, 40),
		Material = Enum.Material.Neon,
		CanCollide = false,
		CastShadow = false,
		Parent = coins,
	})
end

local function label(parentPart, text, color)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(200, 50)
	gui.StudsOffset = Vector3.new(0, 5, 0)
	gui.MaxDistance = 90
	gui.AlwaysOnTop = false
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextScaled = true
	textLabel.Text = text
	textLabel.TextColor3 = color
	textLabel.TextStrokeTransparency = 0
	textLabel.Parent = gui
	gui.Parent = parentPart
end

-- Checkpoint pads. Stage 1 doubles as the spawn point.
for stage = 1, STAGES do
	local isFinal = stage == STAGES
	local pad = part({
		Name = tostring(stage),
		Size = Vector3.new(12, 1, 12),
		Position = Vector3.new((stage - 1) * SPACING, BASE_Y, 0),
		Color = isFinal and Color3.fromRGB(255, 205, 40) or Color3.fromRGB(70, 220, 100),
		Material = isFinal and Enum.Material.Neon or Enum.Material.SmoothPlastic,
	}, stage == 1 and "SpawnLocation" or "Part")
	if stage == 1 then
		pad.Neutral = true
		pad.Duration = 0
	end
	label(pad, isFinal and "FINISH!" or ("STAGE " .. stage), Color3.new(1, 1, 1))
	pad.Parent = checkpoints
end

-- Obstacle sections between pads. Pads span x0-6..x0+6, so each section fills x0+6..x0+54.
local sections = {
	-- Jumping platforms that shrink as stages go up
	function(stage, x0, difficulty)
		local size = 5 - 1.5 * difficulty
		for i, cx in ipairs({ 12, 21, 30, 39, 48 }) do
			local y = BASE_Y + (i % 2 == 0 and 2 or 0)
			platform(stage, Vector3.new(x0 + cx, y, 0), Vector3.new(size, 1, size))
			if i % 2 == 0 or i == 3 then
				coin(Vector3.new(x0 + cx, y + 3.5, 0))
			end
		end
	end,
	-- Walkway with kill strips to hop over
	function(stage, x0)
		platform(stage, Vector3.new(x0 + 30, BASE_Y, 0), Vector3.new(48, 1, 6))
		for _, cx in ipairs({ 15, 25, 35, 45 }) do
			killBrick(Vector3.new(x0 + cx, BASE_Y + 1, 0), Vector3.new(1.5, 1, 6))
		end
		for _, cx in ipairs({ 20, 30, 40 }) do
			coin(Vector3.new(x0 + cx, BASE_Y + 3.5, 0))
		end
	end,
	-- Spinning kill bar
	function(stage, x0, difficulty)
		platform(stage, Vector3.new(x0 + 30, BASE_Y, 0), Vector3.new(48, 1, 10))
		local bar = killBrick(Vector3.new(x0 + 30, BASE_Y + 1.25, 0), Vector3.new(1, 1.5, 22))
		bar.Name = "Spinner"
		bar:SetAttribute("SpinSpeed", 90 + 60 * difficulty)
		CollectionService:AddTag(bar, "Spinner")
		for _, cx in ipairs({ 14, 30, 46 }) do
			coin(Vector3.new(x0 + cx, BASE_Y + 3.5, 0))
		end
	end,
	-- Narrow zig-zag beams
	function(stage, x0, difficulty)
		local width = 2 - 0.5 * difficulty
		for i, cx in ipairs({ 14, 30, 46 }) do
			local z = ({ 0, 3, -3 })[i]
			platform(stage, Vector3.new(x0 + cx, BASE_Y, z), Vector3.new(12, 1, width))
			coin(Vector3.new(x0 + cx, BASE_Y + 3.5, z))
		end
	end,
}

for stage = 1, STAGES - 1 do
	local x0 = (stage - 1) * SPACING
	local difficulty = (stage - 1) / math.max(STAGES - 2, 1)
	sections[(stage - 1) % #sections + 1](stage, x0, difficulty)
end

-- Lava floor under the whole course.
killBrick(
	Vector3.new((STAGES - 1) * SPACING / 2, BASE_Y - 30, 0),
	Vector3.new((STAGES - 1) * SPACING + 120, 2, 160)
).Color = Color3.fromRGB(255, 90, 20)

course.Parent = workspace
killParts.Parent = workspace
coins.Parent = workspace
checkpoints.Parent = workspace
]==])
add(f_server, "Script", "Obstacles", [==[
-- Kill bricks and spinners.
--   Kill brick: any BasePart inside Workspace.KillParts, or tagged "KillPart".
--   Spinner:    any BasePart tagged "Spinner" (optional number attribute "SpinSpeed", degrees/second).
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local hooked = {}
local function makeDeadly(part)
	if not part:IsA("BasePart") or hooked[part] then
		return
	end
	hooked[part] = true
	part.Touched:Connect(function(hit)
		local humanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			humanoid.Health = 0
		end
	end)
end

for _, part in ipairs(CollectionService:GetTagged("KillPart")) do
	makeDeadly(part)
end
CollectionService:GetInstanceAddedSignal("KillPart"):Connect(makeDeadly)

local function watchKillFolder(folder)
	for _, d in ipairs(folder:GetDescendants()) do
		makeDeadly(d)
	end
	folder.DescendantAdded:Connect(makeDeadly)
end

local killFolder = workspace:FindFirstChild("KillParts")
if killFolder then
	watchKillFolder(killFolder)
else
	-- The sample course builder may create it a moment later.
	local conn
	conn = workspace.ChildAdded:Connect(function(child)
		if child.Name == "KillParts" then
			conn:Disconnect()
			watchKillFolder(child)
		end
	end)
end

RunService.Heartbeat:Connect(function(dt)
	for _, part in ipairs(CollectionService:GetTagged("Spinner")) do
		if part:IsA("BasePart") and part:IsDescendantOf(workspace) then
			local speed = part:GetAttribute("SpinSpeed") or 90
			part.CFrame *= CFrame.Angles(0, math.rad(speed) * dt, 0)
		end
	end
end)
]==])
add(f_server, "ModuleScript", "PlayerData", [==[
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
]==])
add(f_server, "Script", "Shop", [==[
-- Cosmetic shop: handles Buy / Equip / Unequip and puts trails + auras on characters.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Catalog = require(Shared:WaitForChild("ShopCatalog"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

local function cosmetic(className, parent)
	local inst = Instance.new(className)
	inst:SetAttribute("Cosmetic", true)
	inst.Parent = parent
	return inst
end

local function clearCosmetics(character)
	for _, d in ipairs(character:GetDescendants()) do
		if d:GetAttribute("Cosmetic") then
			d:Destroy()
		end
	end
end

local function addTrail(root, item)
	local top = cosmetic("Attachment", root)
	top.Position = Vector3.new(0, 0.9, 0.4)
	local bottom = cosmetic("Attachment", root)
	bottom.Position = Vector3.new(0, -0.9, 0.4)

	local trail = Instance.new("Trail")
	trail:SetAttribute("Cosmetic", true)
	trail.Attachment0 = top
	trail.Attachment1 = bottom
	trail.Color = item.Color
	trail.Lifetime = 0.7
	trail.LightEmission = 0.6
	trail.FaceCamera = true
	trail.Transparency = NumberSequence.new(0.1, 1)
	trail.WidthScale = NumberSequence.new(1, 0.3)
	trail.Parent = root
end

local function addAura(character, root, item)
	if item.Kind == "Sparkles" then
		local emitter = Instance.new("ParticleEmitter")
		emitter:SetAttribute("Cosmetic", true)
		emitter.Color = item.Color
		emitter.LightEmission = 1
		emitter.Rate = 18
		emitter.Lifetime = NumberRange.new(0.8, 1.4)
		emitter.Speed = NumberRange.new(1, 3)
		emitter.SpreadAngle = Vector2.new(180, 180)
		emitter.Size = NumberSequence.new(0.45, 0)
		emitter.Parent = root
	elseif item.Kind == "Fire" then
		local fire = Instance.new("Fire")
		fire:SetAttribute("Cosmetic", true)
		fire.Color = item.Color
		fire.SecondaryColor = item.SecondaryColor
		fire.Size = 6
		fire.Heat = 4
		fire.Parent = root
	elseif item.Kind == "Glow" then
		local highlight = Instance.new("Highlight")
		highlight:SetAttribute("Cosmetic", true)
		highlight.FillColor = item.Color
		highlight.FillTransparency = 0.55
		highlight.OutlineColor = Color3.fromRGB(255, 245, 200)
		highlight.Parent = character
		local light = Instance.new("PointLight")
		light:SetAttribute("Cosmetic", true)
		light.Color = item.Color
		light.Range = 12
		light.Brightness = 2
		light.Parent = root
	end
end

local function applyCosmetics(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local data = PlayerData.Get(player)
	if not root or not data then
		return
	end
	clearCosmetics(character)
	for _, itemId in pairs(data.Equipped) do
		local item = Catalog.Get(itemId)
		if item and data.Owned[itemId] then
			if item.Slot == "Trail" then
				addTrail(root, item)
			elseif item.Slot == "Aura" then
				addAura(character, root, item)
			end
		end
	end
end

local lastRequest = {}
Remotes.ShopAction.OnServerInvoke = function(player, action, itemId)
	-- Light rate limit so spam-clicking can't hammer the server.
	local now = os.clock()
	if lastRequest[player] and now - lastRequest[player] < 0.25 then
		return false, "Slow down!"
	end
	lastRequest[player] = now

	if type(action) ~= "string" or type(itemId) ~= "string" then
		return false, "Bad request"
	end
	local item = Catalog.Get(itemId)
	local data = PlayerData.Get(player)
	if not item then
		return false, "Unknown item"
	end
	if not data then
		return false, "Still loading, try again"
	end

	local message
	if action == "Buy" then
		if data.Owned[itemId] then
			return false, "You already own this"
		end
		if not PlayerData.SpendCoins(player, item.Price) then
			return false, ("You need %d more coins"):format(item.Price - data.Coins)
		end
		data.Owned[itemId] = true
		data.Equipped[item.Slot] = itemId
		message = "Bought " .. item.Name .. "!"
	elseif action == "Equip" then
		if not data.Owned[itemId] then
			return false, "You don't own this yet"
		end
		data.Equipped[item.Slot] = itemId
		message = "Equipped " .. item.Name
	elseif action == "Unequip" then
		if data.Equipped[item.Slot] == itemId then
			data.Equipped[item.Slot] = nil
		end
		message = "Unequipped " .. item.Name
	else
		return false, "Bad request"
	end

	applyCosmetics(player)
	PlayerData.Sync(player)
	return true, message
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart", 10)
		PlayerData.WaitFor(player)
		applyCosmetics(player)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
	if player.Character then
		task.spawn(applyCosmetics, player)
	end
end
Players.PlayerRemoving:Connect(function(player)
	lastRequest[player] = nil
end)
]==])
local f_client = folder(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "Client")
add(f_client, "LocalScript", "Coins", [==[
-- Spins + bobs coins locally, and hides coins you've collected until they respawn for you.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local coinsFolder = workspace:WaitForChild("Coins")
local baseCFrames = {} -- [coin] = original CFrame

local function track(part)
	if part:IsA("BasePart") then
		baseCFrames[part] = part.CFrame
	end
end

for _, d in ipairs(coinsFolder:GetDescendants()) do
	track(d)
end
coinsFolder.DescendantAdded:Connect(track)
coinsFolder.DescendantRemoving:Connect(function(d)
	baseCFrames[d] = nil
end)

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	for coin, base in pairs(baseCFrames) do
		local bob = math.sin(t * 2 + base.Position.X * 0.1) * 0.3
		coin.CFrame = CFrame.new(base.Position + Vector3.new(0, bob, 0))
			* CFrame.Angles(0, t * Config.CoinSpinSpeed, 0)
			* base.Rotation
	end
end)

local function setVisible(coin, visible)
	local value = visible and 0 or 1
	coin.LocalTransparencyModifier = value
	for _, d in ipairs(coin:GetDescendants()) do
		if d:IsA("Decal") or d:IsA("BasePart") then
			d.LocalTransparencyModifier = value
		elseif d:IsA("ParticleEmitter") or d:IsA("Light") or d:IsA("BillboardGui") then
			d.Enabled = visible
		end
	end
end

local function burst(position)
	local holder = Instance.new("Part")
	holder.Anchored = true
	holder.CanCollide = false
	holder.CanQuery = false
	holder.CanTouch = false
	holder.Transparency = 1
	holder.Size = Vector3.one
	holder.Position = position
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 220, 60))
	emitter.LightEmission = 1
	emitter.Lifetime = NumberRange.new(0.3, 0.6)
	emitter.Speed = NumberRange.new(8, 14)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Size = NumberSequence.new(0.5, 0)
	emitter.Rate = 0
	emitter.Parent = holder
	holder.Parent = workspace
	emitter:Emit(20)
	task.delay(1, function()
		holder:Destroy()
	end)
end

local function playSound(id)
	if id and not id:match("://0$") then
		local sound = Instance.new("Sound")
		sound.SoundId = id
		sound.Parent = workspace.CurrentCamera
		sound.PlayOnRemove = true
		sound:Destroy()
	end
end

Remotes.CoinCollected.OnClientEvent:Connect(function(coin, respawnSeconds)
	if not coin or not coin.Parent then
		return
	end
	burst(coin.Position)
	playSound(Config.Sounds.Coin)
	setVisible(coin, false)
	task.delay(respawnSeconds, function()
		if coin.Parent then
			setVisible(coin, true)
		end
	end)
end)
]==])
add(f_client, "LocalScript", "Interface", [==[
-- HUD (coins + stage), shop window, and pop-up messages. All UI is built in code,
-- so there's nothing to set up in StarterGui.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Catalog = require(Shared:WaitForChild("ShopCatalog"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local player = Players.LocalPlayer

local COLORS = {
	Panel = Color3.fromRGB(30, 30, 50),
	Card = Color3.fromRGB(48, 48, 78),
	Outline = Color3.fromRGB(15, 15, 25),
	Gold = Color3.fromRGB(255, 205, 40),
	Green = Color3.fromRGB(70, 210, 100),
	Blue = Color3.fromRGB(70, 150, 255),
	Pink = Color3.fromRGB(255, 90, 170),
	Red = Color3.fromRGB(235, 70, 70),
	Text = Color3.new(1, 1, 1),
}
local FONT = Enum.Font.FredokaOne

local state = { Coins = 0, Stage = 1, Owned = {}, Equipped = {} }

local function hasImage(id)
	return type(id) == "string" and id ~= "" and not id:match("://0$")
end

local function make(className, props, children)
	local inst = Instance.new(className)
	local parent = props.Parent
	props.Parent = nil
	for key, value in pairs(props) do
		inst[key] = value
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	inst.Parent = parent
	return inst
end

local function corner(radius)
	return make("UICorner", { CornerRadius = UDim.new(0, radius or 12) })
end

local function stroke(thickness)
	return make("UIStroke", {
		Thickness = thickness or 3,
		Color = COLORS.Outline,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function text(props)
	props.BackgroundTransparency = 1
	props.Font = FONT
	props.TextColor3 = props.TextColor3 or COLORS.Text
	props.TextScaled = true
	local label = make("TextLabel", props)
	make("UIStroke", { Thickness = 2, Color = COLORS.Outline, Parent = label })
	return label
end

-- Image if an asset id is set in Config/Catalog, otherwise a simple drawn fallback.
local function icon(imageId, fallbackColor, fallbackText, props)
	if hasImage(imageId) then
		props.Image = imageId
		props.BackgroundTransparency = 1
		props.ScaleType = Enum.ScaleType.Fit
		return make("ImageLabel", props)
	end
	props.BackgroundColor3 = fallbackColor
	local frame = make("Frame", props, { corner(999), stroke(2) })
	text({
		Size = UDim2.fromScale(0.7, 0.7),
		Position = UDim2.fromScale(0.15, 0.15),
		Text = fallbackText,
		Parent = frame,
	})
	return frame
end

local function playSound(id)
	if hasImage(id) then
		local sound = Instance.new("Sound")
		sound.SoundId = id
		sound.Parent = workspace.CurrentCamera
		sound.PlayOnRemove = true
		sound:Destroy()
	end
end

local gui = make("ScreenGui", {
	Name = "ObbyUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = player:WaitForChild("PlayerGui"),
})

---------------------------------------------------------------- HUD
local coinPanel = make("Frame", {
	Position = UDim2.fromOffset(12, 12),
	Size = UDim2.fromOffset(170, 52),
	BackgroundColor3 = COLORS.Panel,
	Parent = gui,
}, { corner(14), stroke(3) })
local coinScale = make("UIScale", { Parent = coinPanel })
icon(Config.Images.Coin, COLORS.Gold, "$", {
	Position = UDim2.fromOffset(6, 6),
	Size = UDim2.fromOffset(40, 40),
	Parent = coinPanel,
})
local coinLabel = text({
	Position = UDim2.fromOffset(54, 8),
	Size = UDim2.new(1, -62, 0, 36),
	Text = "0",
	TextColor3 = COLORS.Gold,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = coinPanel,
})

local stagePanel = make("Frame", {
	Position = UDim2.fromOffset(12, 72),
	Size = UDim2.fromOffset(170, 40),
	BackgroundColor3 = COLORS.Panel,
	Parent = gui,
}, { corner(12), stroke(3) })
local stageLabel = text({
	Position = UDim2.fromOffset(10, 6),
	Size = UDim2.new(1, -20, 1, -12),
	Text = "Stage 1",
	Parent = stagePanel,
})

local shopButton = make("TextButton", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 12, 0.5, 0),
	Size = UDim2.fromOffset(84, 96),
	BackgroundColor3 = COLORS.Pink,
	Text = "",
	AutoButtonColor = true,
	Parent = gui,
}, { corner(16), stroke(3) })
icon(Config.Images.ShopButton, COLORS.Gold, "🛒", {
	Position = UDim2.fromOffset(10, 4),
	Size = UDim2.fromOffset(64, 64),
	Parent = shopButton,
})
text({
	Position = UDim2.new(0, 4, 1, -28),
	Size = UDim2.new(1, -8, 0, 24),
	Text = "SHOP",
	Parent = shopButton,
})

---------------------------------------------------------------- Toasts
local toastLabel = text({
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, -80),
	Size = UDim2.new(0.6, 0, 0, 48),
	Text = "",
	ZIndex = 10,
	Parent = gui,
})
local toastToken = 0
local function toast(message, color)
	toastToken += 1
	local token = toastToken
	toastLabel.Text = message
	toastLabel.TextColor3 = color or COLORS.Text
	TweenService:Create(toastLabel, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, 0, 0, 24),
	}):Play()
	task.delay(2.2, function()
		if token == toastToken then
			TweenService:Create(toastLabel, TweenInfo.new(0.25), {
				Position = UDim2.new(0.5, 0, 0, -80),
			}):Play()
		end
	end)
end

---------------------------------------------------------------- Shop window
local shopWindow = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.9, 0.8),
	BackgroundColor3 = COLORS.Panel,
	Visible = false,
	ZIndex = 5,
	Parent = gui,
}, {
	corner(18),
	stroke(4),
	make("UISizeConstraint", { MaxSize = Vector2.new(640, 460) }),
})
text({
	Position = UDim2.fromOffset(18, 10),
	Size = UDim2.new(1, -90, 0, 44),
	Text = "COSMETIC SHOP",
	TextColor3 = COLORS.Gold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 5,
	Parent = shopWindow,
})
local closeButton = make("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -12, 0, 12),
	Size = UDim2.fromOffset(40, 40),
	BackgroundColor3 = COLORS.Red,
	Font = FONT,
	Text = "X",
	TextScaled = true,
	TextColor3 = COLORS.Text,
	ZIndex = 5,
	Parent = shopWindow,
}, { corner(10), stroke(2) })

local grid = make("ScrollingFrame", {
	Position = UDim2.fromOffset(14, 64),
	Size = UDim2.new(1, -28, 1, -78),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 6,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ZIndex = 5,
	Parent = shopWindow,
}, {
	make("UIGridLayout", {
		CellSize = UDim2.fromOffset(140, 190),
		CellPadding = UDim2.fromOffset(12, 12),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
	make("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }),
})

local cards = {} -- [itemId] = { Button = TextButton }

local function setOpen(open)
	shopWindow.Visible = open
end

shopButton.Activated:Connect(function()
	setOpen(not shopWindow.Visible)
end)
closeButton.Activated:Connect(function()
	setOpen(false)
end)

local busy = false
local function onCardClicked(item)
	if busy then
		return
	end
	local action
	if state.Equipped[item.Slot] == item.Id then
		action = "Unequip"
	elseif state.Owned[item.Id] then
		action = "Equip"
	else
		action = "Buy"
	end
	busy = true
	local ok, message = Remotes.ShopAction:InvokeServer(action, item.Id)
	busy = false
	toast(message or "", ok and COLORS.Green or COLORS.Red)
	if ok and action == "Buy" then
		playSound(Config.Sounds.Purchase)
	end
end

for index, item in ipairs(Catalog.Items) do
	local card = make("Frame", {
		LayoutOrder = index,
		BackgroundColor3 = COLORS.Card,
		ZIndex = 5,
		Parent = grid,
	}, { corner(14), stroke(3) })
	local fallbackColor = item.Slot == "Trail" and COLORS.Blue or COLORS.Pink
	local art = icon(item.Icon, fallbackColor, item.Name:sub(1, 1), {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 8),
		Size = UDim2.fromOffset(88, 88),
		ZIndex = 5,
		Parent = card,
	})
	for _, d in ipairs(art:GetDescendants()) do
		if d:IsA("GuiObject") then
			d.ZIndex = 6
		end
	end
	text({
		Position = UDim2.new(0, 6, 0, 100),
		Size = UDim2.new(1, -12, 0, 22),
		Text = item.Name,
		ZIndex = 5,
		Parent = card,
	})
	text({
		Position = UDim2.new(0, 6, 0, 122),
		Size = UDim2.new(1, -12, 0, 16),
		Text = item.Slot,
		TextColor3 = Color3.fromRGB(190, 190, 220),
		ZIndex = 5,
		Parent = card,
	})
	local button = make("TextButton", {
		Position = UDim2.new(0, 10, 1, -44),
		Size = UDim2.new(1, -20, 0, 34),
		Font = FONT,
		TextScaled = true,
		TextColor3 = COLORS.Text,
		ZIndex = 5,
		Parent = card,
	}, { corner(10), stroke(2), make("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
	}) })
	button.Activated:Connect(function()
		onCardClicked(item)
	end)
	cards[item.Id] = { Button = button, Item = item }
end

---------------------------------------------------------------- Refresh
local function totalStages()
	local folder = workspace:FindFirstChild("Checkpoints")
	local highest = 0
	for _, child in ipairs(folder and folder:GetChildren() or {}) do
		highest = math.max(highest, tonumber(child.Name) or 0)
	end
	return highest
end

local lastCoins
local function refresh()
	coinLabel.Text = tostring(state.Coins)
	if lastCoins and state.Coins > lastCoins then
		coinScale.Scale = 1.2
		TweenService:Create(coinScale, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	end
	lastCoins = state.Coins

	local total = totalStages()
	stageLabel.Text = total > 0 and ("Stage %d / %d"):format(state.Stage, total) or ("Stage " .. state.Stage)

	for id, card in pairs(cards) do
		local button = card.Button
		if state.Equipped[card.Item.Slot] == id then
			button.Text = "Equipped ✓"
			button.BackgroundColor3 = COLORS.Green
		elseif state.Owned[id] then
			button.Text = "Equip"
			button.BackgroundColor3 = COLORS.Blue
		else
			button.Text = "$ " .. card.Item.Price
			button.BackgroundColor3 = state.Coins >= card.Item.Price and COLORS.Gold or Color3.fromRGB(110, 110, 130)
		end
	end
end

Remotes.DataUpdated.OnClientEvent:Connect(function(data)
	state = data
	refresh()
end)

Remotes.CheckpointReached.OnClientEvent:Connect(function(stage, isFinal)
	playSound(Config.Sounds.Checkpoint)
	if isFinal then
		toast("🎉 YOU BEAT THE OBBY! 🎉", COLORS.Gold)
	else
		toast(("Checkpoint! Stage %d  (+%d coins)"):format(stage, Config.CheckpointReward), COLORS.Green)
	end
end)

local initial = Remotes.RequestData:InvokeServer()
if initial then
	state = initial
end
refresh()
]==])
print("Sky Coin Obby installed! Press Play to test.")
