-- Sky Coin Obby installer: paste into the Studio command bar and press Run.
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
-- Keep the Assets module (your Roblox ids) from a previous install.
local oldShared = game:GetService("ReplicatedStorage"):FindFirstChild("Shared")
local oldAssets = oldShared and oldShared:FindFirstChild("Assets")
local keptAssets = oldAssets and oldAssets.Source
local spawn = workspace:FindFirstChild("SpawnLocation")
if spawn then spawn:Destroy() end
local f_shared = folder(game:GetService("ReplicatedStorage"), "Shared")
add(f_shared, "ModuleScript", "Assets", keptAssets or [==[
-- YOUR ROBLOX IDS GO HERE. The installer keeps this file when you update the game,
-- so anything you paste here is safe.
--   Images / sounds / music:  "rbxassetid://1234567890"  ("rbxassetid://0" = not set yet)
--   Passes / products / badges: plain numbers (0 = not set yet)
local Assets = {}

-- Robux items. Create them on the Creator Hub, then paste the ids here (0 = hidden).
Assets.GamePasses = {
	DoubleCoins = 0, -- 2x coins forever
	VIP = 0, -- 1.5x coins, VIP trail, [VIP] chat tag
}
Assets.Products = {
	SkipStage = 0, -- skip the current stage
}

-- Badges (optional). Create them on the Creator Hub and paste the ids (0 = off).
Assets.Badges = {
	Welcome = 0,
	ReachedCandy = 0,
	ReachedSpace = 0,
	FirstWin = 0,
	TenWins = 0,
}

-- Upload the PNGs in /art to Roblox and paste the asset ids here
-- (format: "rbxassetid://1234567890"). "rbxassetid://0" = use the built-in fallback look.
Assets.Images = {
	Coin = "rbxassetid://0", -- art/ui-coin.png
	ShopButton = "rbxassetid://0", -- art/ui-shop-button.png
	Daily = "rbxassetid://0", -- art/ui-daily.png
	Invite = "rbxassetid://0", -- art/ui-invite.png
	Skip = "rbxassetid://0", -- art/ui-skip.png
	Trophy = "rbxassetid://0", -- art/ui-trophy.png
	Music = "rbxassetid://0", -- art/ui-music.png
}

-- Upload the .mp3 files in /audio and paste the ids. "rbxassetid://0" = silent.
Assets.Sounds = {
	Coin = "rbxassetid://0", -- audio/sfx_coin.mp3
	Checkpoint = "rbxassetid://0", -- audio/sfx_checkpoint.mp3
	Purchase = "rbxassetid://0", -- audio/sfx_purchase.mp3
	Death = "rbxassetid://0", -- audio/sfx_death.mp3
	Win = "rbxassetid://0", -- audio/sfx_win.mp3
	JumpPad = "rbxassetid://0", -- audio/sfx_jumppad.mp3
	Click = "rbxassetid://0", -- audio/sfx_click.mp3
	Daily = "rbxassetid://0", -- audio/sfx_daily.mp3
}
Assets.Music = {
	Sky = "rbxassetid://0", -- audio/music_sky.mp3
	Candy = "rbxassetid://0", -- audio/music_candy.mp3
	Space = "rbxassetid://0", -- audio/music_space.mp3
}

-- Shop item icons (art/item-*.png), by item Id from ShopCatalog.
Assets.ItemIcons = {
	RainbowTrail = "rbxassetid://0", -- art/item-rainbow-trail.png
	FireTrail = "rbxassetid://0", -- art/item-fire-trail.png
	GalaxyTrail = "rbxassetid://0", -- art/item-galaxy-trail.png
	SparkleAura = "rbxassetid://0", -- art/item-sparkle-aura.png
	FireAura = "rbxassetid://0", -- art/item-fire-aura.png
	GoldenGlow = "rbxassetid://0", -- art/item-golden-glow.png
	BubbleAura = "rbxassetid://0", -- art/item-bubble-aura.png
	LightningTrail = "rbxassetid://0", -- art/item-lightning-trail.png
	VIPTrail = "rbxassetid://0", -- art/item-vip-trail.png
}

return Assets
]==])
add(f_shared, "ModuleScript", "Config", [==[
-- Game-wide settings. Tweak these freely.
local Config = {}

-- Change the version suffix to wipe everyone's saved progress.
Config.DataStoreName = "SkyCoinObby_v1"
Config.LeaderboardVersion = "v1" -- change to reset the global leaderboards

-- Economy
Config.StartingCoins = 0
Config.CoinValue = 1 -- default value per coin (override per coin with a "Value" attribute)
Config.CoinRespawnSeconds = 45 -- how long before a player can grab the same coin again
Config.CheckpointReward = 5 -- bonus coins the first time a player reaches a new stage
Config.WinReward = 100 -- coins for finishing the whole obby
Config.WinMultiplierStep = 0.25 -- every win permanently adds +25% to coins earned...
Config.MaxWinMultiplier = 5 -- ...up to this cap
Config.SecondsBeforeRestart = 5 -- after winning, players restart at stage 1 for another win

-- Checkpoints
Config.AllowStageSkipping = false -- false = players must touch checkpoints in order

-- Visuals
Config.CoinSpinSpeed = 2 -- radians per second

-- Sample course: builds a 30-stage, 3-zone obby automatically if Workspace has no
-- "Checkpoints" folder. Set to false once you've built your own course.
Config.BuildSampleCourse = true

-- Zones change the music, sky and (in space) gravity. FirstStage = where the zone starts.
Config.Zones = {
	{ Name = "SKY ISLANDS", FirstStage = 1, Music = "Sky", ClockTime = 14, Gravity = 196.2 },
	{ Name = "CANDY LAND", FirstStage = 11, Music = "Candy", ClockTime = 17.4, Gravity = 196.2 },
	{ Name = "OUTER SPACE", FirstStage = 21, Music = "Space", ClockTime = 0, Gravity = 80 },
}

-- Daily login rewards: day 1, day 2, ... day 7 (then repeats day 7). Miss a day = back to day 1.
Config.DailyRewards = { 25, 40, 60, 80, 100, 150, 250 }
Config.DailyCooldownHours = 20

-- Both players get this when someone joins through a friend's invite.
Config.InviteReward = 50

-- All Roblox ids (images, sounds, music, game passes, products, badges) live in the
-- Assets module, so re-running the installer never wipes them.
local Assets = require(script.Parent:WaitForChild("Assets"))
Config.GamePasses = Assets.GamePasses or {}
Config.Products = Assets.Products or {}
Config.Badges = Assets.Badges or {}
Config.Images = Assets.Images or {}
Config.Sounds = Assets.Sounds or {}
Config.Music = Assets.Music or {}
Config.VIPMultiplier = 1.5

Config.MusicVolume = 0.35
Config.SfxVolume = 0.6

function Config.ZoneForStage(stage)
	local found = Config.Zones[1]
	for _, zone in ipairs(Config.Zones) do
		if stage >= zone.FirstStage then
			found = zone
		end
	end
	return found
end

function Config.HasAsset(id)
	return type(id) == "string" and id ~= "" and not id:match("://0$")
end

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
	DataUpdated = get("DataUpdated", "RemoteEvent"), -- server -> client: full data snapshot
	RequestData = get("RequestData", "RemoteFunction"), -- client -> server: initial snapshot
	CoinCollected = get("CoinCollected", "RemoteEvent"), -- server -> client: (coin, respawnSeconds, amount)
	CheckpointReached = get("CheckpointReached", "RemoteEvent"), -- server -> client: (stage, reward)
	Won = get("Won", "RemoteEvent"), -- server -> client: (time or nil, isNewBest, reward, wins)
	Notify = get("Notify", "RemoteEvent"), -- server -> client: (message, kind)
	ShopAction = get("ShopAction", "RemoteFunction"), -- client -> server: Buy / Equip / Unequip
	ClaimDaily = get("ClaimDaily", "RemoteFunction"), -- client -> server: claim daily reward
}
]==])
add(f_shared, "ModuleScript", "Sfx", [==[
-- Client helper: Sfx.Play("Coin") plays Config.Sounds.Coin (if an id is set).
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local Sfx = {}

local group = SoundService:FindFirstChild("SFX")
if not group then
	group = Instance.new("SoundGroup")
	group.Name = "SFX"
	group.Volume = Config.SfxVolume
	group.Parent = SoundService
end

local cache = {}

function Sfx.Play(name, pitch)
	local id = Config.Sounds[name]
	if not Config.HasAsset(id) then
		return
	end
	local template = cache[name]
	if not template then
		template = Instance.new("Sound")
		template.SoundId = id
		template.SoundGroup = group
		cache[name] = template
	end
	local sound = template:Clone()
	sound.PlaybackSpeed = pitch or 1
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
end

return Sfx
]==])
add(f_shared, "ModuleScript", "ShopCatalog", [==[
-- Everything sold in the cosmetic shop.
-- Slot: "Trail" or "Aura" (a player can equip one of each).
-- RequiresVIP: only VIP game pass owners can get it.
-- Icons come from Assets.ItemIcons.
local ShopCatalog = {}

ShopCatalog.Items = {
	{
		Id = "RainbowTrail",
		Name = "Rainbow Trail",
		Slot = "Trail",
		Price = 25,
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
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 210, 60)),
	},
	{
		Id = "FireAura",
		Name = "Fire Aura",
		Slot = "Aura",
		Kind = "Fire",
		Price = 200,
		Color = Color3.fromRGB(255, 140, 30),
		SecondaryColor = Color3.fromRGB(60, 120, 255),
	},
	{
		Id = "GoldenGlow",
		Name = "Golden Glow",
		Slot = "Aura",
		Kind = "Glow",
		Price = 400,
		Color = Color3.fromRGB(255, 200, 40),
	},
	{
		Id = "BubbleAura",
		Name = "Bubble Aura",
		Slot = "Aura",
		Kind = "Bubbles",
		Price = 250,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 220, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 170, 230)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 255, 210)),
		}),
	},
	{
		Id = "LightningTrail",
		Name = "Lightning Trail",
		Slot = "Trail",
		Price = 300,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 240, 90)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 220, 255)),
		}),
	},
	{
		Id = "VIPTrail",
		Name = "VIP Diamond Trail",
		Slot = "Trail",
		Price = 0,
		RequiresVIP = true, -- free for VIP game pass owners
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(170, 230, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 90)),
		}),
	},
}

local Assets = require(script.Parent:WaitForChild("Assets"))

local byId = {}
for _, item in ipairs(ShopCatalog.Items) do
	item.Icon = (Assets.ItemIcons or {})[item.Id] or "rbxassetid://0"
	byId[item.Id] = item
end

function ShopCatalog.Get(id)
	return byId[id]
end

return ShopCatalog
]==])
local f_server = folder(game:GetService("ServerScriptService"), "Server")
add(f_server, "ModuleScript", "Badges", [==[
-- Awards badges listed in Config.Badges (ids of 0 are skipped).
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local Badges = {}

function Badges.Award(player, name)
	local id = Config.Badges[name]
	if not id or id == 0 then
		return
	end
	task.spawn(function()
		local ok, has = pcall(BadgeService.UserHasBadgeAsync, BadgeService, player.UserId, id)
		if ok and not has then
			pcall(BadgeService.AwardBadge, BadgeService, player.UserId, id)
		end
	end)
end

return Badges
]==])
add(f_server, "Script", "Checkpoints", [==[
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

local function win(player)
	local data, session = PlayerData.Get(player), PlayerData.Session(player)
	local elapsed = session.RunStart and (workspace:GetServerTimeNow() - session.RunStart)
	session.RunStart = nil

	local isNewBest = false
	if elapsed and (data.BestTime == 0 or elapsed < data.BestTime) then
		data.BestTime = elapsed
		isNewBest = true
	end
	data.Wins += 1
	local reward = PlayerData.AddCoins(player, Config.WinReward, true)
	Remotes.Won:FireClient(player, elapsed, isNewBest, reward, data.Wins)

	Badges.Award(player, "FirstWin")
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
	if not data or stage <= data.Stage then
		return
	end
	if not Config.AllowStageSkipping and stage ~= data.Stage + 1 then
		return
	end

	PlayerData.SetStage(player, stage)
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
	if not data or not root then
		return
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
	local amount = PlayerData.AddCoins(player, coin:GetAttribute("Value") or Config.CoinValue, true)
	Remotes.CoinCollected:FireClient(player, coin, Config.CoinRespawnSeconds, amount)

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
add(f_server, "ModuleScript", "Course", [==[
-- Helpers for finding checkpoints and moving players between stages.
local Course = {}

local checkpoints = workspace:WaitForChild("Checkpoints")
Course.Checkpoints = checkpoints

function Course.FinalStage()
	local highest = 0
	for _, child in ipairs(checkpoints:GetChildren()) do
		local n = tonumber(child.Name)
		if n and n > highest then
			highest = n
		end
	end
	return highest
end

function Course.GetCheckpoint(stage)
	local checkpoint = checkpoints:FindFirstChild(tostring(math.clamp(stage, 1, math.max(Course.FinalStage(), 1))))
	if checkpoint and checkpoint:IsA("BasePart") then
		return checkpoint
	end
	return nil
end

-- Puts a character on top of a stage's checkpoint.
function Course.PlaceOnStage(character, stage)
	local checkpoint = Course.GetCheckpoint(stage)
	if checkpoint and character.Parent then
		character:PivotTo(CFrame.new(checkpoint.Position + Vector3.new(0, checkpoint.Size.Y / 2 + 3, 0)))
	end
end

return Course
]==])
add(f_server, "Script", "CourseBuilder", [==[
-- Builds a playable 30-stage obby in 3 zones (Sky Islands, Candy Land, Outer Space)
-- plus the global leaderboard boards next to the start.
-- Skips itself if Workspace already has a "Checkpoints" folder, or if
-- Config.BuildSampleCourse is false.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

if not Config.BuildSampleCourse or workspace:FindFirstChild("Checkpoints") then
	return
end

local STAGES = 30
local SPACING = 60 -- studs between checkpoints
local BASE_Y = 60 -- course height

local THEMES = {
	{ -- Sky Islands
		Platforms = {
			Color3.fromRGB(80, 170, 255),
			Color3.fromRGB(255, 120, 200),
			Color3.fromRGB(150, 110, 255),
			Color3.fromRGB(255, 200, 70),
			Color3.fromRGB(90, 220, 200),
		},
		Material = Enum.Material.SmoothPlastic,
		Checkpoint = Color3.fromRGB(70, 220, 100),
		Floor = Color3.fromRGB(255, 90, 20),
	},
	{ -- Candy Land
		Platforms = {
			Color3.fromRGB(255, 150, 200),
			Color3.fromRGB(255, 225, 130),
			Color3.fromRGB(160, 240, 200),
			Color3.fromRGB(200, 160, 255),
			Color3.fromRGB(255, 255, 255),
		},
		Material = Enum.Material.SmoothPlastic,
		Checkpoint = Color3.fromRGB(120, 235, 190),
		Floor = Color3.fromRGB(255, 110, 170),
	},
	{ -- Outer Space
		Platforms = {
			Color3.fromRGB(110, 80, 220),
			Color3.fromRGB(60, 190, 255),
			Color3.fromRGB(200, 90, 255),
			Color3.fromRGB(80, 255, 200),
		},
		Material = Enum.Material.Neon,
		Checkpoint = Color3.fromRGB(80, 255, 140),
		Floor = Color3.fromRGB(45, 15, 80),
	},
}

local function zoneIndex(stage)
	local index = 1
	for i, zone in ipairs(Config.Zones) do
		if stage >= zone.FirstStage then
			index = i
		end
	end
	return math.min(index, #THEMES)
end

local function folder(name)
	local f = Instance.new("Folder")
	f.Name = name
	return f
end

local course = folder("SampleCourse")
local checkpoints = folder("Checkpoints")
local coins = folder("Coins")
local killParts = folder("KillParts")
local boards = folder("Leaderboards")

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

local function tag(p, tagName, attributes)
	CollectionService:AddTag(p, tagName)
	for key, value in pairs(attributes or {}) do
		p:SetAttribute(key, value)
	end
	return p
end

local function platform(stage, position, size, cframe)
	local theme = THEMES[zoneIndex(stage)]
	local p = part({
		Name = "Platform",
		Size = size,
		Color = theme.Platforms[(stage + math.floor(position.X / 7)) % #theme.Platforms + 1],
		Material = theme.Material,
		Parent = course,
	})
	p.CFrame = cframe or CFrame.new(position)
	return p
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

local function jumpPad(position, power)
	local p = part({
		Name = "JumpPad",
		Size = Vector3.new(4, 0.6, 4),
		Position = position,
		Color = Color3.fromRGB(60, 255, 120),
		Material = Enum.Material.Neon,
		Parent = course,
	})
	return tag(p, "JumpPad", { Power = power })
end

local function label(parentPart, text, color, height)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(240, height or 50)
	gui.StudsOffset = Vector3.new(0, 5, 0)
	gui.MaxDistance = 120
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

---------------------------------------------------------------- Checkpoints
for stage = 1, STAGES do
	local isFinal = stage == STAGES
	local zIndex = zoneIndex(stage)
	local zone = Config.Zones[zIndex]
	local pad = part({
		Name = tostring(stage),
		Size = isFinal and Vector3.new(16, 1, 16) or Vector3.new(12, 1, 12),
		Position = Vector3.new((stage - 1) * SPACING, BASE_Y, 0),
		Color = isFinal and Color3.fromRGB(255, 205, 40) or THEMES[zIndex].Checkpoint,
		Material = isFinal and Enum.Material.Neon or Enum.Material.SmoothPlastic,
	}, stage == 1 and "SpawnLocation" or "Part")
	if stage == 1 then
		pad.Neutral = true
		pad.Duration = 0
	end
	if isFinal then
		label(pad, "FINISH!", Color3.fromRGB(255, 230, 90))
	elseif zone and zone.FirstStage == stage then
		label(pad, zone.Name .. "\nSTAGE " .. stage, Color3.new(1, 1, 1), 90)
	else
		label(pad, "STAGE " .. stage, Color3.new(1, 1, 1))
	end
	pad.Parent = checkpoints
end

---------------------------------------------------------------- Obstacle sections
-- Pads span x0-6..x0+6, so each section fills x0+6..x0+54.
-- d = 0..1 difficulty within the zone.
local skySections = {
	-- Jumping platforms that shrink as stages go up
	function(stage, x0, d)
		local size = 5 - 1.5 * d
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
	function(stage, x0, d)
		platform(stage, Vector3.new(x0 + 30, BASE_Y, 0), Vector3.new(48, 1, 10))
		local bar = killBrick(Vector3.new(x0 + 30, BASE_Y + 1.25, 0), Vector3.new(1, 1.5, 22))
		bar.Name = "Spinner"
		tag(bar, "Spinner", { SpinSpeed = 90 + 60 * d })
		for _, cx in ipairs({ 14, 30, 46 }) do
			coin(Vector3.new(x0 + cx, BASE_Y + 3.5, 0))
		end
	end,
	-- Narrow zig-zag beams
	function(stage, x0, d)
		local width = 2 - 0.5 * d
		for i, cx in ipairs({ 14, 30, 46 }) do
			local z = ({ 0, 3, -3 })[i]
			platform(stage, Vector3.new(x0 + cx, BASE_Y, z), Vector3.new(12, 1, width))
			coin(Vector3.new(x0 + cx, BASE_Y + 3.5, z))
		end
	end,
}

-- Rotating 90 degrees makes a part's front (look) direction point toward -X.
local FACE_BACK = CFrame.Angles(0, math.rad(90), 0)

local candySections = {
	-- Platforms that vanish after you step on them
	function(stage, x0, d)
		for i, cx in ipairs({ 12, 21, 30, 39, 48 }) do
			local p = platform(stage, Vector3.new(x0 + cx, BASE_Y, 0), Vector3.new(6, 1, 6))
			tag(p, "Fade", { FadeTime = 0.8 - 0.4 * d, ReturnTime = 2.5 })
			if i % 2 == 1 then
				coin(Vector3.new(x0 + cx, BASE_Y + 3.5, 0))
			end
		end
	end,
	-- Conveyor pushing you backwards, with sliding blocks
	function(stage, x0, d)
		local belt = platform(stage, Vector3.zero, Vector3.new(8, 1, 48), CFrame.new(x0 + 30, BASE_Y, 0) * FACE_BACK)
		belt.Material = Enum.Material.DiamondPlate
		tag(belt, "Conveyor", { ConveyorSpeed = 6 + 6 * d })
		for i, cx in ipairs({ 18, 30, 42 }) do
			local block = killBrick(Vector3.zero, Vector3.new(2, 2, 2))
			block.CFrame = CFrame.new(x0 + cx, BASE_Y + 1.5, 0) * FACE_BACK
			tag(block, "Slider", { Distance = 3, Speed = 0.3 + 0.2 * d, Phase = i * 0.33 })
			coin(Vector3.new(x0 + cx + 6, BASE_Y + 3.5, 0))
		end
	end,
	-- Jump pad up to a high platform
	function(stage, x0)
		platform(stage, Vector3.new(x0 + 13, BASE_Y, 0), Vector3.new(14, 1, 8))
		jumpPad(Vector3.new(x0 + 18, BASE_Y + 0.8, 0), 80)
		platform(stage, Vector3.new(x0 + 31, BASE_Y + 14, 0), Vector3.new(12, 1, 8))
		platform(stage, Vector3.new(x0 + 45, BASE_Y + 7, 0), Vector3.new(6, 1, 6))
		coin(Vector3.new(x0 + 23, BASE_Y + 13, 0))
		coin(Vector3.new(x0 + 31, BASE_Y + 17.5, 0))
		coin(Vector3.new(x0 + 45, BASE_Y + 10.5, 0))
	end,
	-- Narrow walkway with sliders sweeping across
	function(stage, x0, d)
		platform(stage, Vector3.new(x0 + 30, BASE_Y, 0), Vector3.new(48, 1, 6))
		for i, cx in ipairs({ 16, 26, 36, 46 }) do
			local block = killBrick(Vector3.zero, Vector3.new(2, 3, 2))
			block.CFrame = CFrame.new(x0 + cx, BASE_Y + 2, 0) * FACE_BACK
			tag(block, "Slider", { Distance = 3.5, Speed = 0.35 + 0.25 * d, Phase = i * 0.25 })
		end
		for _, cx in ipairs({ 21, 31, 41 }) do
			coin(Vector3.new(x0 + cx, BASE_Y + 3.5, 0))
		end
	end,
}

-- Space has low gravity (see Config.Zones), so jumps go much further.
local spaceSections = {
	-- Asteroid hops
	function(stage, x0, d)
		local size = 6 - 2 * d
		for i, cx in ipairs({ 16, 31, 45 }) do
			local y = BASE_Y + ({ 2, 5, 1 })[i]
			platform(stage, Vector3.new(x0 + cx, y, ({ 2, -2, 1 })[i]), Vector3.new(size, 1, size))
			coin(Vector3.new(x0 + cx, y + 7, 0))
		end
	end,
	-- Double spinners
	function(stage, x0, d)
		platform(stage, Vector3.new(x0 + 30, BASE_Y, 0), Vector3.new(48, 1, 10))
		for i, cx in ipairs({ 19, 41 }) do
			local bar = killBrick(Vector3.new(x0 + cx, BASE_Y + 1.25, 0), Vector3.new(1, 1.5, 14))
			bar.Name = "Spinner"
			tag(bar, "Spinner", { SpinSpeed = (i == 1 and 1 or -1) * (110 + 70 * d) })
			coin(Vector3.new(x0 + cx, BASE_Y + 9, 0))
		end
		coin(Vector3.new(x0 + 30, BASE_Y + 3.5, 0))
	end,
	-- Vanishing moon rocks over the void
	function(stage, x0, d)
		for _, cx in ipairs({ 15, 27, 39, 50 }) do
			local p = platform(stage, Vector3.new(x0 + cx, BASE_Y, 0), Vector3.new(4, 1, 4))
			tag(p, "Fade", { FadeTime = 0.7 - 0.3 * d, ReturnTime = 3 })
			coin(Vector3.new(x0 + cx, BASE_Y + 6, 0))
		end
	end,
	-- Moon launch: a jump pad flings you across a huge gap
	function(stage, x0)
		platform(stage, Vector3.new(x0 + 10, BASE_Y, 0), Vector3.new(8, 1, 8))
		jumpPad(Vector3.new(x0 + 12, BASE_Y + 0.8, 0), 70)
		platform(stage, Vector3.new(x0 + 44, BASE_Y, 0), Vector3.new(20, 1, 10))
		coin(Vector3.new(x0 + 20, BASE_Y + 24, 0))
		coin(Vector3.new(x0 + 26, BASE_Y + 29, 0))
		coin(Vector3.new(x0 + 32, BASE_Y + 24, 0))
	end,
}

local sectionsByZone = { skySections, candySections, spaceSections }

for stage = 1, STAGES - 1 do
	local zIndex = zoneIndex(stage)
	local zoneFirst = Config.Zones[zIndex].FirstStage
	local nextZone = Config.Zones[zIndex + 1]
	local zoneLast = nextZone and nextZone.FirstStage - 1 or STAGES - 1
	local d = (stage - zoneFirst) / math.max(zoneLast - zoneFirst, 1)
	local sections = sectionsByZone[zIndex]
	sections[(stage - zoneFirst) % #sections + 1](stage, (stage - 1) * SPACING, d)
end

---------------------------------------------------------------- Kill floors (one per zone, out to the horizon)
local FLOOR_MATERIALS = { Enum.Material.CrackedLava, Enum.Material.SmoothPlastic, Enum.Material.Neon }
local FLOOR_WIDTH = 1400 -- studs across (z); parts max out at 2048
for zIndex, zone in ipairs(Config.Zones) do
	if zIndex > #THEMES then
		break
	end
	local nextZone = Config.Zones[zIndex + 1]
	local xStart = (zone.FirstStage - 1) * SPACING - (zIndex == 1 and 600 or 0)
	local xEnd = nextZone and (nextZone.FirstStage - 1) * SPACING or (STAGES - 1) * SPACING + 600
	local floor = killBrick(Vector3.new((xStart + xEnd) / 2, BASE_Y - 30, 0), Vector3.new(xEnd - xStart, 2, FLOOR_WIDTH))
	floor.Name = "Floor"
	floor.Color = THEMES[zIndex].Floor
	floor.Material = FLOOR_MATERIALS[zIndex] or Enum.Material.SmoothPlastic
	floor.CastShadow = false
	if zIndex == 3 then
		floor.Transparency = 0.45 -- see the asteroid belt below the space void
	end
end

-- The template's grey baseplate would show under the course as empty "dead space".
local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate and baseplate:IsA("BasePart") then
	baseplate:Destroy()
end

---------------------------------------------------------------- Leaderboard boards beside the start
local function board(name, z, facing)
	local position = Vector3.new(0, BASE_Y + 7, z)
	part({
		Name = name,
		Size = Vector3.new(14, 12, 1),
		CFrame = CFrame.lookAt(position, position + facing),
		Color = Color3.fromRGB(25, 25, 45),
		Parent = boards,
	})
end
board("WinsBoard", -13, Vector3.new(0, 0, 1))
board("TimeBoard", 13, Vector3.new(0, 0, -1))

---------------------------------------------------------------- Scenery (islands, worlds, gates, trophy)
require(script.Parent:WaitForChild("Scenery")).Build({
	Stages = STAGES,
	Spacing = SPACING,
	BaseY = BASE_Y,
	Zones = Config.Zones,
	ZoneIndex = zoneIndex,
})

course.Parent = workspace
killParts.Parent = workspace
coins.Parent = workspace
boards.Parent = workspace
checkpoints.Parent = workspace
]==])
add(f_server, "Script", "Leaderboards", [==[
-- Global leaderboards (all servers): Most Wins and Fastest Full Run.
-- Shown on parts named "WinsBoard" and "TimeBoard" inside Workspace.Leaderboards
-- (the sample course builds them next to the start).
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

local REFRESH_SECONDS = 60
local SHOWN = 10

local okStores, winsStore, timeStore = pcall(function()
	return DataStoreService:GetOrderedDataStore("Wins_" .. Config.LeaderboardVersion),
		DataStoreService:GetOrderedDataStore("BestTime_" .. Config.LeaderboardVersion)
end)
if not okStores then
	warn("[Leaderboards] Unavailable:", winsStore)
	winsStore, timeStore = nil, nil
end

local names = {}
local function nameFor(userId)
	if names[userId] then
		return names[userId]
	end
	local ok, name = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	names[userId] = ok and name or "Player"
	return names[userId]
end

local function formatTime(seconds)
	return ("%d:%05.2f"):format(seconds // 60, seconds % 60)
end

local function buildBoard(part, title, color)
	local gui = part:FindFirstChild("BoardGui") or Instance.new("SurfaceGui")
	gui.Name = "BoardGui"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui:ClearAllChildren()

	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
	bg.Parent = gui

	local header = Instance.new("TextLabel")
	header.Size = UDim2.fromScale(1, 0.14)
	header.BackgroundColor3 = color
	header.Font = Enum.Font.FredokaOne
	header.TextScaled = true
	header.TextColor3 = Color3.new(1, 1, 1)
	header.Text = title
	header.Parent = bg

	local list = Instance.new("Frame")
	list.Name = "List"
	list.Position = UDim2.fromScale(0.04, 0.16)
	list.Size = UDim2.fromScale(0.92, 0.82)
	list.BackgroundTransparency = 1
	list.Parent = bg
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	for i = 1, SHOWN do
		local row = Instance.new("TextLabel")
		row.Name = "Row" .. i
		row.LayoutOrder = i
		row.Size = UDim2.fromScale(1, 1 / SHOWN)
		row.BackgroundTransparency = 1
		row.Font = Enum.Font.FredokaOne
		row.TextScaled = true
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.TextColor3 = i == 1 and Color3.fromRGB(255, 215, 60)
			or i == 2 and Color3.fromRGB(220, 220, 235)
			or i == 3 and Color3.fromRGB(230, 150, 90)
			or Color3.new(1, 1, 1)
		row.Text = ""
		row.Parent = list
	end
	gui.Parent = part
	return list
end

local function fill(list, entries, formatValue)
	for i = 1, SHOWN do
		local row = list:FindFirstChild("Row" .. i)
		local entry = entries[i]
		row.Text = entry and ("#%d  %s  -  %s"):format(i, nameFor(tonumber(entry.key)), formatValue(entry.value)) or ""
	end
end

local boards = workspace:WaitForChild("Leaderboards", 30)
if not boards then
	return -- no boards in this place
end
local winsList = buildBoard(boards:WaitForChild("WinsBoard"), "MOST WINS", Color3.fromRGB(255, 170, 40))
local timeList = buildBoard(boards:WaitForChild("TimeBoard"), "FASTEST RUN", Color3.fromRGB(70, 160, 255))

local function refresh()
	if not winsStore then
		winsList.Row1.Text = "Leaderboards work in published games"
		timeList.Row1.Text = "Leaderboards work in published games"
		return
	end
	-- Upload everyone in this server first.
	for _, player in ipairs(Players:GetPlayers()) do
		local data = PlayerData.Get(player)
		if data then
			local key = tostring(player.UserId)
			if data.Wins > 0 then
				pcall(winsStore.SetAsync, winsStore, key, data.Wins)
			end
			if data.BestTime > 0 then
				pcall(timeStore.SetAsync, timeStore, key, math.floor(data.BestTime * 100)) -- hundredths
			end
		end
	end

	local okWins, winsPage = pcall(winsStore.GetSortedAsync, winsStore, false, SHOWN)
	if okWins then
		fill(winsList, winsPage:GetCurrentPage(), function(v)
			return v .. " wins"
		end)
	end
	local okTime, timePage = pcall(timeStore.GetSortedAsync, timeStore, true, SHOWN)
	if okTime then
		fill(timeList, timePage:GetCurrentPage(), function(v)
			return formatTime(v / 100)
		end)
	end
end

while true do
	refresh()
	task.wait(REFRESH_SECONDS)
end
]==])
add(f_server, "Script", "Monetization", [==[
-- Game passes (2x Coins, VIP) and the Skip Stage developer product.
-- Ids live in Config.GamePasses / Config.Products; anything set to 0 is ignored.
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Server = ServerScriptService:WaitForChild("Server")
local PlayerData = require(Server:WaitForChild("PlayerData"))
local Course = require(Server:WaitForChild("Course"))

local passNameById = {}
for name, id in pairs(Config.GamePasses) do
	if id ~= 0 then
		passNameById[id] = name
	end
end

local function checkPasses(player)
	PlayerData.WaitFor(player)
	for name, id in pairs(Config.GamePasses) do
		if id ~= 0 then
			local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, id)
			if ok and owns then
				PlayerData.SetPass(player, name, true)
			end
		end
	end
	if PlayerData.Session(player) and PlayerData.Session(player).Passes.VIP then
		player:SetAttribute("VIP", true) -- used for the [VIP] chat tag
	end
end

Players.PlayerAdded:Connect(checkPasses)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(checkPasses, player)
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
	local name = passNameById[passId]
	if purchased and name then
		PlayerData.SetPass(player, name, true)
		if name == "VIP" then
			player:SetAttribute("VIP", true)
		end
		Remotes.Notify:FireClient(player, "Thanks for your support! Pass activated.", "good")
	end
end)

---------------------------------------------------------------- Developer products
local handled = {} -- receipts already granted in this server

local productHandlers = {}
productHandlers[Config.Products.SkipStage] = function(player)
	local data = PlayerData.Get(player)
	if not data then
		return false
	end
	local final = Course.FinalStage()
	if data.Stage >= final - 1 then
		-- Skipping can't hand out a win (the Skip button hides here); compensate with coins instead.
		PlayerData.AddCoins(player, Config.WinReward, false)
		Remotes.Notify:FireClient(player, ("Last stage can't be skipped - here's +%d coins instead!"):format(Config.WinReward), "good")
		return true
	end
	PlayerData.Session(player).RunStart = nil -- skipped runs don't count for speedrun times
	PlayerData.SetStage(player, data.Stage + 1)
	if player.Character then
		Course.PlaceOnStage(player.Character, data.Stage)
	end
	Remotes.Notify:FireClient(player, ("Skipped to stage %d!"):format(data.Stage), "good")
	return true
end

MarketplaceService.ProcessReceipt = function(receipt)
	if handled[receipt.PurchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	local handler = productHandlers[receipt.ProductId]
	if not player or not handler then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local ok, granted = pcall(handler, player)
	if ok and granted then
		handled[receipt.PurchaseId] = true
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end
]==])
add(f_server, "Script", "Obstacles", [==[
-- Obstacle behaviours, driven by CollectionService tags (Properties -> Tags in Studio):
--   KillPart  - kills on touch (anything inside Workspace.KillParts counts too)
--   Spinner   - spins around its Y axis. Attribute SpinSpeed (degrees/second, default 90)
--   Slider    - slides back and forth along its X axis. Attributes Distance (studs, default 10)
--               and Speed (cycles/second, default 0.3)
--   Fade      - vanishes shortly after being stepped on, then comes back.
--               Attributes FadeTime (default 0.6) and ReturnTime (default 2.5)
--   Conveyor  - pushes players along its front (look) direction. Attribute ConveyorSpeed (default 12)
--   JumpPad   - launches players upward; handled on the client in Movement (attribute Power)
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local function onTagged(tag, callback)
	for _, inst in ipairs(CollectionService:GetTagged(tag)) do
		task.spawn(callback, inst)
	end
	CollectionService:GetInstanceAddedSignal(tag):Connect(callback)
end

---------------------------------------------------------------- Kill parts
local deadly = {}
local function makeDeadly(part)
	if not part:IsA("BasePart") or deadly[part] then
		return
	end
	deadly[part] = true
	part.Touched:Connect(function(hit)
		local humanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			humanoid.Health = 0
		end
	end)
end

onTagged("KillPart", makeDeadly)

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

---------------------------------------------------------------- Fading platforms
onTagged("Fade", function(part)
	if not part:IsA("BasePart") then
		return
	end
	local busy = false
	local baseTransparency = part.Transparency
	part.Touched:Connect(function(hit)
		if busy or not Players:GetPlayerFromCharacter(hit.Parent) then
			return
		end
		busy = true
		local fadeTime = part:GetAttribute("FadeTime") or 0.6
		local tween = TweenService:Create(part, TweenInfo.new(fadeTime), { Transparency = 1 })
		tween:Play()
		tween.Completed:Wait()
		part.CanCollide = false
		task.wait(part:GetAttribute("ReturnTime") or 2.5)
		part.CanCollide = true
		part.Transparency = baseTransparency
		busy = false
	end)
end)

---------------------------------------------------------------- Conveyors
onTagged("Conveyor", function(part)
	if part:IsA("BasePart") then
		part.AssemblyLinearVelocity = part.CFrame.LookVector * (part:GetAttribute("ConveyorSpeed") or 12)
	end
end)

---------------------------------------------------------------- Spinners + sliders
local sliderOrigins = {}

RunService.Heartbeat:Connect(function(dt)
	for _, part in ipairs(CollectionService:GetTagged("Spinner")) do
		if part:IsA("BasePart") and part:IsDescendantOf(workspace) then
			local speed = part:GetAttribute("SpinSpeed") or 90
			part.CFrame *= CFrame.Angles(0, math.rad(speed) * dt, 0)
		end
	end

	local now = workspace:GetServerTimeNow()
	for _, part in ipairs(CollectionService:GetTagged("Slider")) do
		if part:IsA("BasePart") and part:IsDescendantOf(workspace) then
			local origin = sliderOrigins[part]
			if not origin then
				origin = part.CFrame
				sliderOrigins[part] = origin
			end
			local distance = part:GetAttribute("Distance") or 10
			local speed = part:GetAttribute("Speed") or 0.3
			local phase = part:GetAttribute("Phase") or 0
			local offset = math.sin((now * speed + phase) * math.pi * 2) * distance
			part.CFrame = origin * CFrame.new(offset, 0, 0)
		end
	end
end)
]==])
add(f_server, "ModuleScript", "PlayerData", [==[
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
]==])
add(f_server, "Script", "Rewards", [==[
-- Daily login rewards, friend-invite bonuses and the welcome badge.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Server = ServerScriptService:WaitForChild("Server")
local PlayerData = require(Server:WaitForChild("PlayerData"))
local Badges = require(Server:WaitForChild("Badges"))

---------------------------------------------------------------- Daily reward
Remotes.ClaimDaily.OnServerInvoke = function(player)
	local data = PlayerData.Get(player)
	if not data then
		return false, "Still loading, try again"
	end
	if not PlayerData.DailyReady(data) then
		local hoursLeft = math.ceil((Config.DailyCooldownHours * 3600 - (os.time() - data.LastDaily)) / 3600)
		return false, ("Come back in %d hour%s!"):format(hoursLeft, hoursLeft == 1 and "" or "s")
	end

	local continued = os.time() - data.LastDaily <= 48 * 3600
	data.DailyStreak = continued and data.DailyStreak + 1 or 1
	data.LastDaily = os.time()
	local day = (data.DailyStreak - 1) % #Config.DailyRewards + 1
	local reward = Config.DailyRewards[day]
	PlayerData.AddCoins(player, reward, false)
	return true, ("Day %d reward: +%d coins! Come back tomorrow for more."):format(day, reward)
end

---------------------------------------------------------------- Friend invites
-- When someone joins through a friend's invite link, and that friend is in this server,
-- both get Config.InviteReward coins (once per friend pair).
local function rewardReferral(newPlayer)
	local ok, joinData = pcall(newPlayer.GetJoinData, newPlayer)
	local referrerId = ok and joinData and joinData.ReferredByPlayerId
	if not referrerId or referrerId == 0 or referrerId == newPlayer.UserId then
		return
	end
	local referrer = Players:GetPlayerByUserId(referrerId)
	local newData = PlayerData.WaitFor(newPlayer)
	local referrerData = referrer and PlayerData.WaitFor(referrer)
	if not newData or not referrerData then
		return
	end
	local key = tostring(newPlayer.UserId)
	if referrerData.RewardedReferrals[key] then
		return
	end
	referrerData.RewardedReferrals[key] = true
	PlayerData.AddCoins(referrer, Config.InviteReward, false)
	Remotes.Notify:FireClient(referrer, ("%s joined from your invite! +%d coins"):format(newPlayer.DisplayName, Config.InviteReward), "good")
	if not newData.JoinedViaInvite then
		newData.JoinedViaInvite = true
		PlayerData.AddCoins(newPlayer, Config.InviteReward, false)
		Remotes.Notify:FireClient(newPlayer, ("Thanks for joining %s! +%d coins"):format(referrer.DisplayName, Config.InviteReward), "good")
	end
end

local function onPlayerAdded(player)
	Badges.Award(player, "Welcome")
	task.spawn(rewardReferral, player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
]==])
add(f_server, "ModuleScript", "Scenery", [==[
-- Decorates the sample course: floating islands under checkpoints, flags, a spawn lobby,
-- and per-world scenery (Sky: clouds, tree islands, rainbow; Candy: lollipops, candy canes,
-- cupcakes, gumdrops; Space: planets, stars, asteroids), plus world gates and a finish trophy.
-- Decoration is non-collidable and kept away from the jump paths, so it never affects gameplay.
local Scenery = {}

local rng = Random.new(2026)
local folder

local function deco(props, className)
	local p = Instance.new(className or "Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for key, value in pairs(props) do
		p[key] = value
	end
	p.Parent = folder
	return p
end

local function ball(position, diameter, color, material, transparency)
	return deco({
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * diameter,
		Position = position,
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
		Transparency = transparency or 0,
	})
end

-- Roblox cylinders run along their X axis; this stands one upright.
local UPRIGHT = CFrame.Angles(0, 0, math.rad(90))

local function pillar(position, height, diameter, color, material)
	return deco({
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(height, diameter, diameter),
		CFrame = CFrame.new(position) * UPRIGHT,
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
	})
end

local function range(a, b)
	return rng:NextNumber(a, b)
end

local function side(minZ, maxZ)
	return (rng:NextNumber() < 0.5 and -1 or 1) * range(minZ, maxZ)
end

local function pick(list)
	return list[rng:NextInteger(1, #list)]
end

---------------------------------------------------------------- shared pieces
local ISLANDS = {
	{ Top = Color3.fromRGB(100, 200, 90), TopMaterial = Enum.Material.Grass, Rock = Color3.fromRGB(125, 95, 70) },
	{ Top = Color3.fromRGB(255, 180, 215), TopMaterial = Enum.Material.SmoothPlastic, Rock = Color3.fromRGB(110, 65, 45) },
	{ Top = Color3.fromRGB(120, 115, 150), TopMaterial = Enum.Material.Slate, Rock = Color3.fromRGB(70, 65, 95) },
}
local FLAG_COLORS = { Color3.fromRGB(255, 90, 90), Color3.fromRGB(255, 120, 200), Color3.fromRGB(80, 255, 200) }

-- A floating island whose (walkable) top sits just under `topY`.
local function island(center, topY, diameter, zIndex, walkable)
	local look = ISLANDS[zIndex] or ISLANDS[1]
	local top = pillar(Vector3.new(center.X, topY - 1.05, center.Z), 2, diameter, look.Top, look.TopMaterial)
	top.CanCollide = walkable == true
	top.CastShadow = true
	local y = topY - 2
	for i, scale in ipairs({ 0.85, 0.6, 0.3 }) do
		local h = 3 + i
		pillar(Vector3.new(center.X, y - h / 2, center.Z), h, diameter * scale, look.Rock, Enum.Material.Rock)
		y -= h
	end
end

local function tree(base)
	pillar(base + Vector3.new(0, 3, 0), 6, 1.2, Color3.fromRGB(110, 75, 45), Enum.Material.Wood)
	for _ = 1, 3 do
		ball(base + Vector3.new(range(-1.5, 1.5), range(6, 8), range(-1.5, 1.5)), range(4.5, 6.5), Color3.fromRGB(80, range(170, 210), 80), Enum.Material.Grass)
	end
end

local function cloud(center, colors)
	for _ = 1, rng:NextInteger(3, 5) do
		ball(center + Vector3.new(range(-9, 9), range(-2, 3), range(-5, 5)), range(8, 16), pick(colors), Enum.Material.SmoothPlastic, 0.05)
	end
end

local function flag(position, color, neon)
	pillar(position + Vector3.new(0, 4, 0), 8, 0.4, Color3.fromRGB(240, 240, 240))
	deco({
		Size = Vector3.new(3, 2, 0.2),
		Position = position + Vector3.new(1.6, 7, 0),
		Color = color,
		Material = neon and Enum.Material.Neon or Enum.Material.Fabric,
	})
end

-- Half-ring arch over the path at x, in the Y/Z plane.
local function gate(x, baseY, radius, colors, material)
	local segments = 22
	for i = 0, segments - 1 do
		local a0 = math.pi * i / segments
		local a1 = math.pi * (i + 1) / segments
		local p0 = Vector3.new(x, baseY + math.sin(a0) * radius, math.cos(a0) * radius)
		local p1 = Vector3.new(x, baseY + math.sin(a1) * radius, math.cos(a1) * radius)
		deco({
			Size = Vector3.new(2.2, 2.2, (p1 - p0).Magnitude + 0.3),
			CFrame = CFrame.lookAt((p0 + p1) / 2, p1),
			Color = colors[i % #colors + 1],
			Material = material,
		})
	end
end

local function sign(position, facing, size, title, subtitle, color)
	local board = deco({
		Size = size,
		CFrame = CFrame.lookAt(position, position + facing),
		Color = Color3.fromRGB(30, 30, 55),
	})
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 30
	gui.LightInfluence = 0
	local function line(text, y, h, textColor)
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Position = UDim2.fromScale(0.04, y)
		label.Size = UDim2.fromScale(0.92, h)
		label.Font = Enum.Font.FredokaOne
		label.TextScaled = true
		label.Text = text
		label.TextColor3 = textColor
		label.Parent = gui
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 4
		stroke.Parent = label
	end
	line(title, 0.08, 0.55, color)
	line(subtitle, 0.66, 0.26, Color3.new(1, 1, 1))
	gui.Parent = board
end

---------------------------------------------------------------- per-world scenery
local function buildSky(x0, x1, baseY)
	for _ = 1, 45 do
		cloud(Vector3.new(range(x0 - 80, x1), range(baseY - 25, baseY + 35), side(28, 140)), { Color3.new(1, 1, 1), Color3.fromRGB(235, 245, 255) })
	end
	for _ = 1, 12 do
		local center = Vector3.new(range(x0, x1), baseY + range(-15, 8), side(24, 70))
		island(center, center.Y, range(12, 18), 1, false)
		tree(center + Vector3.new(range(-3, 3), 0, range(-3, 3)))
	end
	-- Big islands out toward the horizon.
	for _ = 1, 14 do
		local center = Vector3.new(range(x0 - 400, x1 + 100), baseY + range(-22, 18), side(110, 380))
		local diameter = range(40, 85)
		island(center, center.Y, diameter, 1, false)
		for _ = 1, math.floor(diameter / 12) do
			local r, a = range(0, diameter * 0.35), range(0, math.pi * 2)
			tree(center + Vector3.new(math.cos(a) * r, -0.1, math.sin(a) * r))
		end
	end
	-- Rocks poking out of the lava sea.
	for _ = 1, 40 do
		ball(Vector3.new(range(x0 - 500, x1), baseY - 30, side(60, 600)), range(10, 40), Color3.fromRGB(range(70, 100), range(55, 75), range(45, 60)), Enum.Material.Basalt)
	end
	-- Giant rainbow in the background.
	local colors = {
		Color3.fromRGB(255, 70, 70), Color3.fromRGB(255, 160, 50), Color3.fromRGB(255, 235, 70),
		Color3.fromRGB(80, 220, 100), Color3.fromRGB(70, 160, 255), Color3.fromRGB(110, 90, 255),
		Color3.fromRGB(190, 90, 255),
	}
	local center = Vector3.new((x0 + x1) / 2, baseY - 30, -90)
	for band, color in ipairs(colors) do
		local radius = 90 - band * 3
		local segments = 26
		for i = 0, segments - 1 do
			local a = math.pi * (i + 0.5) / segments
			local length = math.pi * radius / segments + 0.4
			deco({
				Size = Vector3.new(length, 3, 1),
				CFrame = CFrame.new(center + Vector3.new(math.cos(a) * radius, math.sin(a) * radius, 0)) * CFrame.Angles(0, 0, a + math.pi / 2),
				Color = color,
				Material = Enum.Material.Neon,
				Transparency = 0.25,
			})
		end
	end
end

local CANDY = {
	Color3.fromRGB(255, 110, 180), Color3.fromRGB(170, 120, 255), Color3.fromRGB(255, 220, 90),
	Color3.fromRGB(110, 230, 190), Color3.fromRGB(255, 150, 90), Color3.fromRGB(110, 190, 255),
}

local function lollipop(base, height)
	pillar(base + Vector3.new(0, height / 2, 0), height, 0.8, Color3.new(1, 1, 1))
	local top = base + Vector3.new(0, height + 4, 0)
	local face = CFrame.Angles(0, math.rad(90), 0) -- disc faces the path
	local diameter = range(8, 12)
	deco({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.2, diameter, diameter), CFrame = CFrame.new(top) * face, Color = pick(CANDY) })
	local toward = Vector3.new(0, 0, base.Z > 0 and -0.4 or 0.4)
	deco({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.2, diameter * 0.62, diameter * 0.62), CFrame = CFrame.new(top + toward) * face, Color = pick(CANDY) })
	ball(top + toward * 2, diameter * 0.25, Color3.new(1, 1, 1))
end

local function candyCane(base)
	local red, white = Color3.fromRGB(235, 40, 50), Color3.new(1, 1, 1)
	for i = 0, 7 do
		pillar(base + Vector3.new(0, i * 2 + 1, 0), 2, 1.6, i % 2 == 0 and red or white)
	end
	local hookCenter = base + Vector3.new(2.4, 16, 0)
	for i = 0, 5 do
		local a = math.pi * i / 5
		ball(hookCenter + Vector3.new(-math.cos(a) * 2.4, math.sin(a) * 2.4, 0), 1.8, i % 2 == 0 and red or white)
	end
end

local function cupcake(base)
	pillar(base + Vector3.new(0, 2.5, 0), 5, 8, pick(CANDY))
	ball(base + Vector3.new(0, 6, 0), 9, Color3.fromRGB(255, 225, 240))
	ball(base + Vector3.new(0, 10.6, 0), 2.2, Color3.fromRGB(220, 30, 50))
end

local function buildCandy(x0, x1, baseY)
	for _ = 1, 25 do
		cloud(Vector3.new(range(x0, x1), range(baseY - 25, baseY + 35), side(30, 140)), {
			Color3.fromRGB(255, 190, 225), Color3.fromRGB(190, 220, 255), Color3.fromRGB(255, 235, 245),
		})
	end
	for _ = 1, 14 do
		lollipop(Vector3.new(range(x0, x1), baseY - range(18, 26), side(22, 55)), range(14, 22))
	end
	for _ = 1, 10 do
		local center = Vector3.new(range(x0, x1), baseY + range(-14, 4), side(26, 60))
		island(center, center.Y, 12, 2, false)
		if rng:NextNumber() < 0.5 then
			candyCane(center)
		else
			cupcake(center)
		end
	end
	for _ = 1, 22 do
		ball(Vector3.new(range(x0, x1), baseY + range(-20, 25), side(20, 80)), range(3, 7), pick(CANDY), Enum.Material.SmoothPlastic, 0.15)
	end
	-- Gumdrop hills rising out of the strawberry-milk sea.
	for _ = 1, 30 do
		ball(Vector3.new(range(x0 - 40, x1 + 40), baseY - 30, side(70, 600)), range(25, 80), pick(CANDY), Enum.Material.SmoothPlastic, 0.1)
	end
	-- Giant lollipop forest in the distance.
	for _ = 1, 16 do
		lollipop(Vector3.new(range(x0, x1), baseY - 30, side(90, 320)), range(40, 70))
	end
end

local function buildSpace(x0, x1, baseY)
	for _ = 1, 220 do
		local star = ball(
			Vector3.new(range(x0 - 120, x1 + 160), range(baseY - 60, baseY + 160), side(30, 260)),
			range(0.5, 1.6),
			pick({ Color3.new(1, 1, 1), Color3.fromRGB(255, 240, 180), Color3.fromRGB(180, 220, 255) }),
			Enum.Material.Neon
		)
		star.Shape = Enum.PartType.Ball
	end
	local planets = {
		{ Color = Color3.fromRGB(255, 120, 80), Size = 90, Ring = false },
		{ Color = Color3.fromRGB(120, 200, 255), Size = 60, Ring = true },
		{ Color = Color3.fromRGB(200, 120, 255), Size = 130, Ring = false },
		{ Color = Color3.fromRGB(120, 255, 170), Size = 45, Ring = true },
		{ Color = Color3.fromRGB(255, 220, 120), Size = 70, Ring = false },
	}
	for i, planet in ipairs(planets) do
		local position = Vector3.new(x0 + (x1 - x0) * (i - 0.5) / #planets + range(-40, 40), baseY + range(-10, 90), (i % 2 == 0 and 1 or -1) * range(170, 280))
		ball(position, planet.Size, planet.Color)
		if planet.Ring then
			deco({
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(0.6, planet.Size * 2.1, planet.Size * 2.1),
				CFrame = CFrame.new(position) * CFrame.Angles(math.rad(range(-25, 25)), 0, math.rad(70)),
				Color = Color3.fromRGB(240, 230, 255),
				Material = Enum.Material.Neon,
				Transparency = 0.55,
			})
		end
	end
	for _ = 1, 35 do
		ball(Vector3.new(range(x0, x1), baseY + range(-25, 30), side(20, 90)), range(3, 11), Color3.fromRGB(range(80, 130), range(75, 120), range(95, 140)), Enum.Material.Slate)
	end
	-- Far-off planets and a big asteroid belt below the course.
	for _ = 1, 6 do
		ball(Vector3.new(range(x0 - 300, x1 + 400), baseY + range(-150, 200), side(350, 700)), range(60, 200),
			pick({ Color3.fromRGB(255, 150, 120), Color3.fromRGB(140, 180, 255), Color3.fromRGB(220, 160, 255), Color3.fromRGB(150, 255, 210) }))
	end
	for _ = 1, 60 do
		ball(Vector3.new(range(x0 - 100, x1 + 300), baseY - range(40, 120), side(0, 300)), range(6, 22), Color3.fromRGB(range(70, 110), range(65, 100), range(90, 130)), Enum.Material.Slate)
	end
end

---------------------------------------------------------------- entry point
-- opts: { Stages, Spacing, BaseY, Zones (Config.Zones), ZoneIndex = function(stage) }
function Scenery.Build(opts)
	folder = Instance.new("Folder")
	folder.Name = "Scenery"

	local spacing, baseY = opts.Spacing, opts.BaseY
	local padTop = baseY + 0.5

	-- Islands + flags under every checkpoint.
	for stage = 1, opts.Stages do
		local x = (stage - 1) * spacing
		local zIndex = opts.ZoneIndex(stage)
		local isFinal = stage == opts.Stages
		if stage ~= 1 then
			island(Vector3.new(x, 0, 0), baseY - 0.55, isFinal and 20 or 15, zIndex, true)
		end
		if not isFinal then
			flag(Vector3.new(x + 4.5, padTop, 4.5), FLAG_COLORS[zIndex] or FLAG_COLORS[1], zIndex == 3)
		end
	end

	-- Spawn lobby: big island, trees and a title sign.
	island(Vector3.new(-14, 0, 0), baseY - 0.55, 42, 1, true)
	for _, offset in ipairs({ Vector3.new(-12, 0, -17), Vector3.new(-12, 0, 17), Vector3.new(-22, 0, -14), Vector3.new(-22, 0, 14) }) do
		tree(Vector3.new(offset.X, padTop - 0.6, offset.Z))
	end
	sign(Vector3.new(-31, baseY + 10, 0), Vector3.new(1, 0, 0), Vector3.new(30, 13, 1), "SKY COIN OBBY", "30 STAGES  •  3 WORLDS  •  GLOBAL LEADERBOARDS", Color3.fromRGB(255, 215, 60))

	-- World scenery.
	local zones = opts.Zones
	local builders = { buildSky, buildCandy, buildSpace }
	for i, zone in ipairs(zones) do
		local builder = builders[i]
		if builder then
			local x0 = (zone.FirstStage - 1) * spacing
			local x1 = zones[i + 1] and (zones[i + 1].FirstStage - 1) * spacing or (opts.Stages - 1) * spacing
			builder(x0, x1, baseY)
		end
	end

	-- Gates at the start of each new world.
	if zones[2] then
		gate((zones[2].FirstStage - 1) * spacing - 7, baseY - 1, 16, { Color3.fromRGB(255, 110, 180), Color3.new(1, 1, 1) }, Enum.Material.SmoothPlastic)
	end
	if zones[3] then
		gate((zones[3].FirstStage - 1) * spacing - 7, baseY - 1, 16, { Color3.fromRGB(80, 230, 255), Color3.fromRGB(190, 90, 255) }, Enum.Material.Neon)
	end

	-- Finish: golden arch and a giant trophy.
	local finishX = (opts.Stages - 1) * spacing
	gate(finishX - 9, baseY - 1, 18, { Color3.fromRGB(255, 205, 40), Color3.fromRGB(255, 240, 150) }, Enum.Material.Neon)
	local gold = Color3.fromRGB(255, 200, 40)
	local trophyBase = Vector3.new(finishX + 16, padTop, 0)
	pillar(trophyBase + Vector3.new(0, 1.5, 0), 3, 9, Color3.fromRGB(60, 45, 30), Enum.Material.Wood)
	pillar(trophyBase + Vector3.new(0, 6, 0), 6, 2, gold, Enum.Material.Metal)
	ball(trophyBase + Vector3.new(0, 13, 0), 11, gold, Enum.Material.Metal)
	for _, z in ipairs({ -6.5, 6.5 }) do
		ball(trophyBase + Vector3.new(0, 14, z), 3.5, gold, Enum.Material.Metal)
	end
	ball(trophyBase + Vector3.new(0, 20, 0), 3, Color3.new(1, 1, 1), Enum.Material.Neon)

	folder.Parent = workspace
end

return Scenery
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
	elseif item.Kind == "Bubbles" then
		local emitter = Instance.new("ParticleEmitter")
		emitter:SetAttribute("Cosmetic", true)
		emitter.Color = item.Color
		emitter.LightEmission = 0.3
		emitter.Transparency = NumberSequence.new(0.3, 1)
		emitter.Rate = 8
		emitter.Lifetime = NumberRange.new(1.5, 2.5)
		emitter.Speed = NumberRange.new(1, 2)
		emitter.Acceleration = Vector3.new(0, 3, 0)
		emitter.SpreadAngle = Vector2.new(180, 180)
		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.3, 0.8),
			NumberSequenceKeypoint.new(1, 1),
		})
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
	local data, session = PlayerData.Get(player), PlayerData.Session(player)
	if not root or not data then
		return
	end
	clearCosmetics(character)
	for _, itemId in pairs(data.Equipped) do
		local item = Catalog.Get(itemId)
		if item and (data.Owned[itemId] or (item.RequiresVIP and session.Passes.VIP)) then
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
	local isVIP = PlayerData.Session(player).Passes.VIP
	if item.RequiresVIP and not isVIP then
		return false, "This item is for VIP pass owners"
	end
	if item.RequiresVIP and action ~= "Unequip" then
		data.Owned[itemId] = true -- VIP items are free
	end

	if action == "Buy" then
		if data.Owned[itemId] and not item.RequiresVIP then
			return false, "You already own this"
		end
		if item.Price > 0 and not PlayerData.SpendCoins(player, item.Price) then
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
add(f_client, "LocalScript", "Audio", [==[
-- Background music (changes per zone, mute with the music button) and event sound effects.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Sfx = require(Shared:WaitForChild("Sfx"))

local player = Players.LocalPlayer
local stageValue = player:WaitForChild("leaderstats"):WaitForChild("Stage")

---------------------------------------------------------------- Music
local musicGroup = Instance.new("SoundGroup")
musicGroup.Name = "Music"
musicGroup.Volume = Config.MusicVolume
musicGroup.Parent = SoundService

local tracks = {}
local current

local function trackFor(name)
	local id = Config.Music[name]
	if not Config.HasAsset(id) then
		return nil
	end
	if not tracks[name] then
		local sound = Instance.new("Sound")
		sound.Name = name
		sound.SoundId = id
		sound.Looped = true
		sound.Volume = 0
		sound.SoundGroup = musicGroup
		sound.Parent = SoundService
		tracks[name] = sound
	end
	return tracks[name]
end

local function updateMusic()
	local muted = player:GetAttribute("MusicMuted")
	local wanted = not muted and trackFor(Config.ZoneForStage(stageValue.Value).Music) or nil
	if wanted == current then
		return
	end
	local old = current
	current = wanted
	if old then
		local fade = TweenService:Create(old, TweenInfo.new(1), { Volume = 0 })
		fade:Play()
		fade.Completed:Once(function()
			if current ~= old then
				old:Pause()
			end
		end)
	end
	if wanted then
		if not wanted.IsPlaying then
			wanted:Resume()
			if not wanted.IsPlaying then
				wanted:Play()
			end
		end
		TweenService:Create(wanted, TweenInfo.new(1.5), { Volume = 1 }):Play()
	end
end

stageValue.Changed:Connect(updateMusic)
player:GetAttributeChangedSignal("MusicMuted"):Connect(updateMusic)
updateMusic()

---------------------------------------------------------------- Sound effects
Remotes.CheckpointReached.OnClientEvent:Connect(function()
	Sfx.Play("Checkpoint")
end)

Remotes.Won.OnClientEvent:Connect(function()
	Sfx.Play("Win")
end)

local function onCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		Sfx.Play("Death")
	end)
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then
	task.spawn(onCharacter, player.Character)
end
]==])
add(f_client, "LocalScript", "Coins", [==[
-- Spins + bobs coins locally, and hides coins you've collected until they respawn for you.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Sfx = require(Shared:WaitForChild("Sfx"))

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

-- Grabbing coins quickly in a row raises the pitch, like a combo.
local combo, lastCoin = 0, 0

Remotes.CoinCollected.OnClientEvent:Connect(function(coin, respawnSeconds)
	if not coin or not coin.Parent then
		return
	end
	burst(coin.Position)
	combo = os.clock() - lastCoin < 1.5 and math.min(combo + 1, 8) or 0
	lastCoin = os.clock()
	Sfx.Play("Coin", 1 + combo * 0.06)
	setVisible(coin, false)
	task.delay(respawnSeconds, function()
		if coin.Parent then
			setVisible(coin, true)
		end
	end)
end)
]==])
add(f_client, "LocalScript", "Interface", [==[
-- All on-screen UI, built in code (nothing to set up in StarterGui):
-- HUD (coins, stage, wins, speedrun timer), side buttons (shop, daily, invite, skip, music),
-- shop window with game passes, pop-ups, zone banners and the win screen.
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Catalog = require(Shared:WaitForChild("ShopCatalog"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Sfx = require(Shared:WaitForChild("Sfx"))

local player = Players.LocalPlayer

local COLORS = {
	Panel = Color3.fromRGB(30, 30, 50),
	Card = Color3.fromRGB(48, 48, 78),
	Outline = Color3.fromRGB(15, 15, 25),
	Gold = Color3.fromRGB(255, 205, 40),
	Green = Color3.fromRGB(70, 210, 100),
	Blue = Color3.fromRGB(70, 150, 255),
	Pink = Color3.fromRGB(255, 90, 170),
	Purple = Color3.fromRGB(150, 90, 255),
	Orange = Color3.fromRGB(255, 140, 40),
	Red = Color3.fromRGB(235, 70, 70),
	Grey = Color3.fromRGB(110, 110, 130),
	Text = Color3.new(1, 1, 1),
}
local FONT = Enum.Font.FredokaOne

local state = { Coins = 0, Stage = 1, Wins = 0, BestTime = 0, Owned = {}, Equipped = {}, Multiplier = 1, Passes = {} }

---------------------------------------------------------------- UI helpers
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
	if Config.HasAsset(imageId) then
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
		ZIndex = (props.ZIndex or 1) + 1,
		Parent = frame,
	})
	return frame
end

local function formatTime(seconds)
	return ("%d:%05.2f"):format(seconds // 60, seconds % 60)
end

local function pop(guiObject)
	local scale = guiObject:FindFirstChildOfClass("UIScale") or make("UIScale", { Parent = guiObject })
	scale.Scale = 1.2
	TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
end

local gui = make("ScreenGui", {
	Name = "ObbyUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = player:WaitForChild("PlayerGui"),
})

---------------------------------------------------------------- HUD (top centre, clear of chat + leaderboard)
local hud = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 8),
	Size = UDim2.fromOffset(470, 52),
	BackgroundTransparency = 1,
	Parent = gui,
}, {
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})

local function hudPanel(order, width, iconId, iconColor, iconText, textColor)
	local panel = make("Frame", {
		LayoutOrder = order,
		Size = UDim2.fromOffset(width, 52),
		BackgroundColor3 = COLORS.Panel,
		Parent = hud,
	}, { corner(14), stroke(3) })
	local x = 10
	if iconText then
		icon(iconId, iconColor, iconText, {
			Position = UDim2.fromOffset(6, 6),
			Size = UDim2.fromOffset(40, 40),
			Parent = panel,
		})
		x = 52
	end
	local label = text({
		Position = UDim2.fromOffset(x, 9),
		Size = UDim2.new(1, -x - 8, 0, 34),
		Text = "",
		TextColor3 = textColor or COLORS.Text,
		TextXAlignment = iconText and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
		Parent = panel,
	})
	return panel, label
end

local coinPanel, coinLabel = hudPanel(1, 150, Config.Images.Coin, COLORS.Gold, "$", COLORS.Gold)
local _, stageLabel = hudPanel(2, 150)
local _, winsLabel = hudPanel(3, 150, Config.Images.Trophy, COLORS.Orange, "W", COLORS.Gold)

local timerLabel = text({
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 64),
	Size = UDim2.fromOffset(260, 26),
	Text = "",
	Parent = gui,
})

---------------------------------------------------------------- Toasts
local toastLabel = text({
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, -120),
	Size = UDim2.new(0.6, 0, 0, 36),
	Text = "",
	ZIndex = 10,
	Parent = gui,
})
local toastToken = 0
local TOAST_COLORS = { good = COLORS.Green, bad = COLORS.Red, gold = COLORS.Gold }
local function toast(message, color)
	toastToken += 1
	local token = toastToken
	toastLabel.Text = message
	toastLabel.TextColor3 = TOAST_COLORS[color] or color or COLORS.Text
	TweenService:Create(toastLabel, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, 0, 0, 96),
	}):Play()
	task.delay(2.6, function()
		if token == toastToken then
			TweenService:Create(toastLabel, TweenInfo.new(0.25), {
				Position = UDim2.new(0.5, 0, 0, -120),
			}):Play()
		end
	end)
end

-- Floating "+3" next to the coin counter.
local function coinPopup(amount)
	local label = text({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 1, 10),
		Size = UDim2.fromOffset(90, 28),
		Text = "+" .. amount,
		TextColor3 = COLORS.Gold,
		ZIndex = 5,
		Parent = coinPanel,
	})
	TweenService:Create(label, TweenInfo.new(0.8), { Position = UDim2.new(0.5, 0, 1, 40), TextTransparency = 1 }):Play()
	task.delay(0.8, function()
		label:Destroy()
	end)
end

---------------------------------------------------------------- Side buttons (left)
local sideBar = make("Frame", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 12, 0.6, 0),
	Size = UDim2.fromOffset(84, 460),
	BackgroundTransparency = 1,
	Parent = gui,
}, {
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}),
})

local function sideButton(order, title, color, iconId, fallbackText, height)
	local button = make("TextButton", {
		LayoutOrder = order,
		Size = UDim2.fromOffset(84, height or 84),
		BackgroundColor3 = color,
		Text = "",
		AutoButtonColor = true,
		Parent = sideBar,
	}, { corner(16), stroke(3) })
	local iconSize = (height or 84) - 30
	icon(iconId, COLORS.Panel, fallbackText, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 4),
		Size = UDim2.fromOffset(iconSize, iconSize),
		Parent = button,
	})
	text({
		Position = UDim2.new(0, 4, 1, -24),
		Size = UDim2.new(1, -8, 0, 20),
		Text = title,
		Parent = button,
	})
	button.Activated:Connect(function()
		Sfx.Play("Click")
	end)
	return button
end

local shopButton = sideButton(1, "SHOP", COLORS.Pink, Config.Images.ShopButton, "$")
local dailyButton = sideButton(2, "DAILY", COLORS.Purple, Config.Images.Daily, "!")
local inviteButton = sideButton(3, "INVITE", COLORS.Green, Config.Images.Invite, "+")
local skipButton = sideButton(4, "SKIP", COLORS.Orange, Config.Images.Skip, ">>")
local musicButton = sideButton(5, "MUSIC", COLORS.Blue, Config.Images.Music, "♪", 64)
skipButton.Visible = Config.Products.SkipStage ~= 0

local dailyDot = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(1, -6, 0, 6),
	Size = UDim2.fromOffset(22, 22),
	BackgroundColor3 = COLORS.Red,
	Visible = false,
	ZIndex = 3,
	Parent = dailyButton,
}, { corner(999), stroke(2) })

-- Gently pulse the daily button while a reward is waiting.
task.spawn(function()
	while true do
		task.wait(1)
		if dailyDot.Visible then
			pop(dailyButton)
		end
	end
end)

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
	make("UISizeConstraint", { MaxSize = Vector2.new(660, 500) }),
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

-- Game pass buttons (only shown for passes that have an id in Config).
local passBar = make("Frame", {
	Position = UDim2.fromOffset(14, 62),
	Size = UDim2.new(1, -28, 0, 44),
	BackgroundTransparency = 1,
	ZIndex = 5,
	Parent = shopWindow,
}, {
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 10),
	}),
})
local passButtons = {}
local PASS_LABELS = { DoubleCoins = "2X COINS", VIP = "VIP" }
for name, id in pairs(Config.GamePasses) do
	if id ~= 0 then
		local button = make("TextButton", {
			Size = UDim2.fromOffset(200, 44),
			BackgroundColor3 = name == "VIP" and COLORS.Gold or COLORS.Purple,
			Font = FONT,
			TextScaled = true,
			TextColor3 = COLORS.Text,
			Text = "Get " .. (PASS_LABELS[name] or name),
			ZIndex = 5,
			Parent = passBar,
		}, { corner(10), stroke(2), make("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }) })
		button.Activated:Connect(function()
			MarketplaceService:PromptGamePassPurchase(player, id)
		end)
		passButtons[name] = button
	end
end
local hasPassBar = next(passButtons) ~= nil
passBar.Visible = hasPassBar

local grid = make("ScrollingFrame", {
	Position = UDim2.fromOffset(14, hasPassBar and 114 or 64),
	Size = UDim2.new(1, -28, 1, hasPassBar and -128 or -78),
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

local cards = {} -- [itemId] = { Button, Item }

shopButton.Activated:Connect(function()
	shopWindow.Visible = not shopWindow.Visible
end)
closeButton.Activated:Connect(function()
	shopWindow.Visible = false
end)

local busy = false
local function onCardClicked(item)
	if busy then
		return
	end
	if item.RequiresVIP and not state.Passes.VIP then
		if Config.GamePasses.VIP ~= 0 then
			MarketplaceService:PromptGamePassPurchase(player, Config.GamePasses.VIP)
		else
			toast("VIP isn't on sale yet", "bad")
		end
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
	toast(message or "", ok and "good" or "bad")
	Sfx.Play(ok and action == "Buy" and "Purchase" or "Click")
end

local sorted = table.clone(Catalog.Items)
table.sort(sorted, function(a, b)
	if (a.RequiresVIP or false) ~= (b.RequiresVIP or false) then
		return b.RequiresVIP == true
	end
	return a.Price < b.Price
end)

for index, item in ipairs(sorted) do
	local card = make("Frame", {
		LayoutOrder = index,
		BackgroundColor3 = item.RequiresVIP and Color3.fromRGB(90, 70, 20) or COLORS.Card,
		ZIndex = 5,
		Parent = grid,
	}, { corner(14), stroke(3) })
	local fallbackColor = item.Slot == "Trail" and COLORS.Blue or COLORS.Pink
	local art = icon(item.Icon, fallbackColor, item.Name:sub(1, 1), {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 8),
		Size = UDim2.fromOffset(88, 88),
		ZIndex = 6,
		Parent = card,
	})
	for _, d in ipairs(art:GetDescendants()) do
		if d:IsA("GuiObject") then
			d.ZIndex = 7
		end
	end
	text({
		Position = UDim2.new(0, 6, 0, 100),
		Size = UDim2.new(1, -12, 0, 22),
		Text = item.Name,
		ZIndex = 6,
		Parent = card,
	})
	text({
		Position = UDim2.new(0, 6, 0, 122),
		Size = UDim2.new(1, -12, 0, 16),
		Text = item.RequiresVIP and "VIP only" or item.Slot,
		TextColor3 = item.RequiresVIP and COLORS.Gold or Color3.fromRGB(190, 190, 220),
		ZIndex = 6,
		Parent = card,
	})
	local button = make("TextButton", {
		Position = UDim2.new(0, 10, 1, -44),
		Size = UDim2.new(1, -20, 0, 34),
		Font = FONT,
		TextScaled = true,
		TextColor3 = COLORS.Text,
		ZIndex = 6,
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

---------------------------------------------------------------- Daily / invite / skip / music
dailyButton.Activated:Connect(function()
	local ok, message = Remotes.ClaimDaily:InvokeServer()
	toast(message or "", ok and "gold" or "bad")
	if ok then
		Sfx.Play("Daily")
	end
end)

local function promptInvite()
	local ok, canInvite = pcall(SocialService.CanSendGameInviteAsync, SocialService, player)
	if ok and canInvite then
		pcall(SocialService.PromptGameInvite, SocialService, player)
	else
		toast("Invites aren't available right now", "bad")
	end
end
inviteButton.Activated:Connect(promptInvite)

skipButton.Activated:Connect(function()
	MarketplaceService:PromptProductPurchase(player, Config.Products.SkipStage)
end)

musicButton.Activated:Connect(function()
	local muted = not player:GetAttribute("MusicMuted")
	player:SetAttribute("MusicMuted", muted)
	musicButton.BackgroundColor3 = muted and COLORS.Grey or COLORS.Blue
end)

---------------------------------------------------------------- Zone banner
local banner = text({
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.32),
	Size = UDim2.new(0.8, 0, 0, 80),
	Text = "",
	TextTransparency = 1,
	ZIndex = 8,
	Parent = gui,
})
local bannerStroke = banner:FindFirstChildOfClass("UIStroke")
local ZONE_SUBTITLES = {
	["CANDY LAND"] = "Watch out - platforms vanish!",
	["OUTER SPACE"] = "Low gravity - MOON JUMPS!",
}
local function showBanner(zone)
	local subtitle = ZONE_SUBTITLES[zone.Name]
	banner.Text = zone.Name .. (subtitle and ("\n" .. subtitle) or "")
	banner.TextTransparency = 0
	bannerStroke.Transparency = 0
	pop(banner)
	task.delay(3, function()
		TweenService:Create(banner, TweenInfo.new(1), { TextTransparency = 1 }):Play()
		TweenService:Create(bannerStroke, TweenInfo.new(1), { Transparency = 1 }):Play()
	end)
end

---------------------------------------------------------------- Win screen
local winScreen = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.45),
	Size = UDim2.fromOffset(420, 300),
	BackgroundColor3 = COLORS.Panel,
	Visible = false,
	ZIndex = 20,
	Parent = gui,
}, { corner(20), stroke(4), make("UIScale", {}) })
text({
	Position = UDim2.fromOffset(16, 14),
	Size = UDim2.new(1, -32, 0, 64),
	Text = "YOU WIN!",
	TextColor3 = COLORS.Gold,
	ZIndex = 21,
	Parent = winScreen,
})
local winDetails = text({
	Position = UDim2.fromOffset(24, 84),
	Size = UDim2.new(1, -48, 0, 120),
	Text = "",
	ZIndex = 21,
	Parent = winScreen,
})
local raceButton = make("TextButton", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -16),
	Size = UDim2.new(1, -48, 0, 50),
	BackgroundColor3 = COLORS.Green,
	Font = FONT,
	TextScaled = true,
	TextColor3 = COLORS.Text,
	Text = "Invite friends to race you!",
	ZIndex = 21,
	Parent = winScreen,
}, { corner(12), stroke(2), make("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }) })
raceButton.Activated:Connect(promptInvite)

local function confetti()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0, 3, 0)
	attachment.Parent = root
	for _, color in ipairs({ COLORS.Gold, COLORS.Pink, COLORS.Blue, COLORS.Green, COLORS.Purple }) do
		local emitter = Instance.new("ParticleEmitter")
		emitter.Color = ColorSequence.new(color)
		emitter.LightEmission = 0.5
		emitter.Size = NumberSequence.new(0.35)
		emitter.Lifetime = NumberRange.new(2, 3)
		emitter.Speed = NumberRange.new(18, 30)
		emitter.SpreadAngle = Vector2.new(60, 60)
		emitter.Acceleration = Vector3.new(0, -25, 0)
		emitter.Rotation = NumberRange.new(0, 360)
		emitter.RotSpeed = NumberRange.new(-200, 200)
		emitter.EmissionDirection = Enum.NormalId.Top
		emitter.Rate = 0
		emitter.Parent = attachment
		emitter:Emit(40)
	end
	task.delay(4, function()
		attachment:Destroy()
	end)
end

Remotes.Won.OnClientEvent:Connect(function(elapsed, isNewBest, reward, wins)
	local lines = {}
	if elapsed then
		table.insert(lines, "Time: " .. formatTime(elapsed) .. (isNewBest and "  NEW BEST!" or ""))
	else
		table.insert(lines, "Start from stage 1 for a timed run!")
	end
	table.insert(lines, ("+%d coins   |   Wins: %d"):format(reward, wins))
	table.insert(lines, ("Coin bonus is now x%.2f"):format(math.min(1 + wins * Config.WinMultiplierStep, Config.MaxWinMultiplier)))
	winDetails.Text = table.concat(lines, "\n")
	winScreen.Visible = true
	pop(winScreen)
	confetti()
	task.delay(Config.SecondsBeforeRestart + 1, function()
		winScreen.Visible = false
	end)
end)

---------------------------------------------------------------- Refresh + events
local totalStages = 0
local function countStages()
	local folder = workspace:FindFirstChild("Checkpoints")
	local highest = 0
	for _, child in ipairs(folder and folder:GetChildren() or {}) do
		highest = math.max(highest, tonumber(child.Name) or 0)
	end
	totalStages = highest
end

local lastCoins, lastZone
local function refresh()
	countStages()
	coinLabel.Text = tostring(state.Coins)
	if lastCoins and state.Coins > lastCoins then
		pop(coinPanel)
		coinPopup(state.Coins - lastCoins)
	end
	lastCoins = state.Coins

	stageLabel.Text = totalStages > 0 and ("Stage %d/%d"):format(state.Stage, totalStages) or ("Stage " .. state.Stage)
	winsLabel.Text = ("%d  x%s"):format(state.Wins, tostring(math.floor(state.Multiplier * 100 + 0.5) / 100))
	dailyDot.Visible = state.DailyReady == true
	skipButton.Visible = Config.Products.SkipStage ~= 0 and state.Stage < totalStages - 1

	local zone = Config.ZoneForStage(state.Stage)
	if lastZone and zone ~= lastZone then
		showBanner(zone)
	end
	lastZone = zone

	for name, button in pairs(passButtons) do
		button.Visible = not state.Passes[name]
	end

	for id, card in pairs(cards) do
		local button, item = card.Button, card.Item
		if state.Equipped[item.Slot] == id then
			button.Text = "Equipped ✓"
			button.BackgroundColor3 = COLORS.Green
		elseif state.Owned[id] or (item.RequiresVIP and state.Passes.VIP) then
			button.Text = "Equip"
			button.BackgroundColor3 = COLORS.Blue
		elseif item.RequiresVIP then
			button.Text = "Get VIP"
			button.BackgroundColor3 = COLORS.Gold
		else
			button.Text = "$ " .. item.Price
			button.BackgroundColor3 = state.Coins >= item.Price and COLORS.Gold or COLORS.Grey
		end
	end
end

RunService.RenderStepped:Connect(function()
	if state.RunStart then
		local best = state.BestTime > 0 and ("   Best " .. formatTime(state.BestTime)) or ""
		timerLabel.Text = formatTime(workspace:GetServerTimeNow() - state.RunStart) .. best
	elseif state.BestTime > 0 then
		timerLabel.Text = "Best " .. formatTime(state.BestTime)
	else
		timerLabel.Text = ""
	end
end)

Remotes.DataUpdated.OnClientEvent:Connect(function(data)
	state = data
	refresh()
end)

Remotes.CheckpointReached.OnClientEvent:Connect(function(stage, reward)
	if reward and reward > 0 then
		toast(("Checkpoint! Stage %d  (+%d coins)"):format(stage, reward), "good")
	else
		toast(("Checkpoint! Stage %d"):format(stage), "good")
	end
end)

Remotes.Notify.OnClientEvent:Connect(function(message, kind)
	toast(message, kind)
end)

---------------------------------------------------------------- [VIP] chat tag
TextChatService.OnIncomingMessage = function(message)
	local properties = Instance.new("TextChatMessageProperties")
	local source = message.TextSource
	local sender = source and Players:GetPlayerByUserId(source.UserId)
	if sender and sender:GetAttribute("VIP") then
		properties.PrefixText = '<font color="#FFD23F">[VIP]</font> ' .. message.PrefixText
	end
	return properties
end

---------------------------------------------------------------- Fit small screens (phones)
local hudScale = make("UIScale", { Parent = hud })
local sideScale = make("UIScale", { Parent = sideBar })
local timerScale = make("UIScale", { Parent = timerLabel })
local function fitScreen()
	local viewport = workspace.CurrentCamera.ViewportSize
	hudScale.Scale = math.clamp(viewport.X / 560, 0.6, 1)
	timerScale.Scale = hudScale.Scale
	sideScale.Scale = math.clamp(viewport.Y / 640, 0.55, 1)
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScreen)
fitScreen()

---------------------------------------------------------------- Start
local initial = Remotes.RequestData:InvokeServer()
if initial then
	state = initial
end
refresh()
if state.DailyReady then
	task.delay(2, function()
		toast("Your daily reward is ready! Tap DAILY", "gold")
	end)
end
]==])
add(f_client, "LocalScript", "Movement", [==[
-- Jump pads, plus each zone's sky colours and gravity (space = moon jumps).
-- Runs on the client because players' characters are simulated on their own device.
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Sfx = require(Shared:WaitForChild("Sfx"))

local player = Players.LocalPlayer
local stageValue = player:WaitForChild("leaderstats"):WaitForChild("Stage")

---------------------------------------------------------------- Zone look + gravity
-- Atmosphere haze softens the horizon so the world fades out instead of ending abruptly.
local LOOKS = {
	["SKY ISLANDS"] = {
		Tint = Color3.new(1, 1, 1), Saturation = 0.1, Brightness = 2,
		Density = 0.32, Haze = 1.6, Glare = 0.3, Color = Color3.fromRGB(200, 225, 255), Decay = Color3.fromRGB(110, 160, 215),
	},
	["CANDY LAND"] = {
		Tint = Color3.fromRGB(255, 232, 245), Saturation = 0.25, Brightness = 2,
		Density = 0.36, Haze = 2.2, Glare = 0.4, Color = Color3.fromRGB(255, 215, 238), Decay = Color3.fromRGB(255, 160, 210),
	},
	["OUTER SPACE"] = {
		Tint = Color3.fromRGB(215, 205, 255), Saturation = 0.2, Brightness = 1,
		Density = 0.12, Haze = 0, Glare = 0, Color = Color3.fromRGB(60, 40, 110), Decay = Color3.fromRGB(20, 10, 50),
	},
}

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Offset = 0.2
atmosphere.Parent = Lighting

local correction = Lighting:FindFirstChild("ZoneCorrection") or Instance.new("ColorCorrectionEffect")
correction.Name = "ZoneCorrection"
correction.Parent = Lighting

local defaultJump = {}
local currentZone

local function applyMovement(zone)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	workspace.Gravity = zone.Gravity
	if not humanoid then
		return
	end
	if not defaultJump[humanoid] then
		defaultJump[humanoid] = { UseJumpPower = humanoid.UseJumpPower, JumpPower = humanoid.JumpPower }
	end
	if zone.Gravity < 150 then
		-- Fixed jump power + low gravity = big floaty moon jumps.
		humanoid.UseJumpPower = true
		humanoid.JumpPower = 50
	else
		humanoid.UseJumpPower = defaultJump[humanoid].UseJumpPower
		humanoid.JumpPower = defaultJump[humanoid].JumpPower
	end
end

local function applyZone()
	local zone = Config.ZoneForStage(stageValue.Value)
	applyMovement(zone)
	if zone == currentZone then
		return
	end
	currentZone = zone
	local look = LOOKS[zone.Name] or LOOKS["SKY ISLANDS"]
	local info = TweenInfo.new(2, Enum.EasingStyle.Sine)
	TweenService:Create(Lighting, info, { ClockTime = zone.ClockTime, Brightness = look.Brightness }):Play()
	TweenService:Create(correction, info, { TintColor = look.Tint, Saturation = look.Saturation }):Play()
	TweenService:Create(atmosphere, info, {
		Density = look.Density,
		Haze = look.Haze,
		Glare = look.Glare,
		Color = look.Color,
		Decay = look.Decay,
	}):Play()
end

stageValue.Changed:Connect(applyZone)
player.CharacterAdded:Connect(function(character)
	character:WaitForChild("Humanoid")
	applyZone()
end)
applyZone()

---------------------------------------------------------------- Jump pads
local cooldown = 0
local function hookPad(pad)
	if not pad:IsA("BasePart") then
		return
	end
	pad.Touched:Connect(function(hit)
		local character = player.Character
		if not character or hit.Parent ~= character or os.clock() < cooldown then
			return
		end
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end
		cooldown = os.clock() + 0.4
		local v = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(v.X, pad:GetAttribute("Power") or 80, v.Z)
		Sfx.Play("JumpPad")
	end)
end

for _, pad in ipairs(CollectionService:GetTagged("JumpPad")) do
	hookPad(pad)
end
CollectionService:GetInstanceAddedSignal("JumpPad"):Connect(hookPad)
]==])
print(keptAssets and "Sky Coin Obby updated! (your Assets ids were kept) Press Play to test." or "Sky Coin Obby installed! Press Play to test.")
