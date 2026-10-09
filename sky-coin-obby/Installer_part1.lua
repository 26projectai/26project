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
	RocketLauncher = 0, -- rocket tool: blast off where you look
	DoubleJump = 0, -- 1 extra mid-air jump
	TripleJump = 0, -- 2 extra mid-air jumps
	SpeedCoil = 0, -- hold to run 60% faster
	GravityCoil = 0, -- hold to float
}
Assets.Products = {
	SkipStage = 0, -- skip the current stage
}

-- Badges (optional). Create them on the Creator Hub and paste the ids (0 = off).
Assets.Badges = {
	Welcome = 0,
	ReachedCandy = 0,
	ReachedSpace = 0,
	ReachedLair = 0,
	FirstWin = 0,
	TenWins = 0,
	OP100 = 0,
	OP500 = 0,
	OP1000 = 0,
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
	Passes = "rbxassetid://0", -- art/ui-passes.png
	Rewards = "rbxassetid://0", -- art/ui-rewards.png
	DrawCommon = "rbxassetid://0", -- art/draw-common.png
	DrawRare = "rbxassetid://0", -- art/draw-rare.png
	DrawLegendary = "rbxassetid://0", -- art/draw-legendary.png
	Gary = "rbxassetid://0", -- art/gary.png (jumpscare)
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
	Calm = "rbxassetid://0", -- audio/music_calm.mp3
	Phonk = "rbxassetid://0", -- audio/music_phonk.mp3
}

-- Custom skyboxes (skybox/<world>_<face>.png). Upload the 18 images and paste the ids.
Assets.Skyboxes = {
	Sky = { Bk = "rbxassetid://0", Dn = "rbxassetid://0", Ft = "rbxassetid://0", Lf = "rbxassetid://0", Rt = "rbxassetid://0", Up = "rbxassetid://0" },
	Candy = { Bk = "rbxassetid://0", Dn = "rbxassetid://0", Ft = "rbxassetid://0", Lf = "rbxassetid://0", Rt = "rbxassetid://0", Up = "rbxassetid://0" },
	Space = { Bk = "rbxassetid://0", Dn = "rbxassetid://0", Ft = "rbxassetid://0", Lf = "rbxassetid://0", Rt = "rbxassetid://0", Up = "rbxassetid://0" },
	Lair = { Bk = "rbxassetid://0", Dn = "rbxassetid://0", Ft = "rbxassetid://0", Lf = "rbxassetid://0", Rt = "rbxassetid://0", Up = "rbxassetid://0" },
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
	CometTrail = "rbxassetid://0",
	RebirthTrail = "rbxassetid://0",
	ChampionHalo = "rbxassetid://0", -- art/ui-halo.png
	OPHalo = "rbxassetid://0", -- art/ui-halo.png
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

-- Sample course: builds a 40-stage, 3-zone obby automatically if Workspace has no
-- "Checkpoints" folder. Set to false once you've built your own course.
Config.BuildSampleCourse = true
Config.Stages = 100
Config.HubStage = 50 -- the central hub island (dashboard + NPCs) hangs off this checkpoint

-- Zones change the music, sky and (in space) gravity. FirstStage = where the zone starts.
Config.Zones = {
	{ Name = "SKY ISLANDS", FirstStage = 1, Music = "Sky", ClockTime = 14, Gravity = 196.2 },
	{ Name = "CANDY LAND", FirstStage = 26, Music = "Candy", ClockTime = 17.4, Gravity = 196.2 },
	{ Name = "OUTER SPACE", FirstStage = 51, Music = "Space", ClockTime = 0, Gravity = 80 },
	{ Name = "GARY'S LAIR", FirstStage = 76, Music = "Phonk", ClockTime = 18.6, Gravity = 196.2 },
}

-- Daily login rewards: day 1, day 2, ... day 7 (then repeats day 7). Miss a day = back to day 1.
Config.DailyRewards = { 25, 40, 60, 80, 100, 150, 250 }
Config.DailyCooldownHours = 20

-- Both players get this when someone joins through a friend's invite.
Config.InviteReward = 50

-- Free rewards for reaching stages for the first time.
Config.Milestones = {
	{ Stage = 10, Unlock = "SpringBoots", Message = "UNLOCKED: Spring Boots - free Double Jump!" },
	{ Stage = 20, Unlock = "CometTrail", Message = "UNLOCKED: Comet Trail - equip it in the Shop!" },
	{ Stage = 76, Unlock = "LairKey", Message = "You found GARY'S LAIR! The final 25 stages..." },
}
-- OP Obby milestones (by OP stage).
Config.OPMilestones = {
	{ Stage = 100, Unlock = "OPHalo", Message = "UNLOCKED: OP Halo - equip it in the Shop!", Badge = "OP100" },
	{ Stage = 500, Unlock = "OP500", Message = "Halfway up Gary's tower! Respect.", Badge = "OP500" },
	{ Stage = 1000, Unlock = "OP1000", Message = "YOU BEAT THE 1000-STAGE OP OBBY!!!", Badge = "OP1000" },
}

-- Luxury NPCs: touching one gives a coin boost.
Config.NPCBoostMultiplier = 2
Config.NPCBoostSeconds = 60
Config.NPCCooldownSeconds = 180 -- per NPC, per player

-- Daily Draw: one free draw every 24 hours. Chances must add up to 100.
-- Free (no Robux), and the odds are shown in-game.
Config.DrawCooldownHours = 24
Config.DrawRarities = {
	{
		Name = "Common", Chance = 70, Color = Color3.fromRGB(200, 205, 215),
		JumpBoost = 1.5, Aura = "Small", Tag = "Silver",
		Perks = { "Jump Boots x1.5", "Small smoke aura", "Silver name tag" },
	},
	{
		Name = "Rare", Chance = 25, Color = Color3.fromRGB(80, 170, 255),
		JumpBoost = 2.5, Aura = "Medium", Tag = "Gold", Nickname = true,
		Perks = { "Jump Boots x2.5", "Swirling smoke aura", "Gold name tag + custom nickname" },
	},
	{
		Name = "Legendary", Chance = 5, Color = Color3.fromRGB(255, 200, 40),
		JumpBoost = 5, Aura = "Super", Tag = "Legendary", Nickname = true, CoinBoost = 1.5, Trail = true,
		Perks = { "Jump Boots x5", "Super aura + sparkles + glow", "Rainbow name tag + nickname", "+50% coins", "Legendary flame trail" },
	},
}

-- Promo codes (share them on TikTok/YouTube). Codes are case-insensitive; one use per player.
Config.Codes = {
	LAUNCH = 100,
	SKYCOIN = 50,
	MOONJUMP = 75,
}

---------------------------------------------------------------- Story
Config.GameTitle = "ESCAPE GREEDY GARY'S OBBY"
Config.VillainName = "Greedy Gary"
Config.Intro = "Greedy Gary stole ALL the Sky Coins and locked them in his obby!\nEscape his 100-stage story... then conquer his 1000-stage OP tower."
Config.VillainTaunts = {
	"You'll never escape my obby! Hehehe!",
	"Those coins are MINE!",
	"Lava is my favourite colour.",
	"Wait... how are you so good at this?!",
	"My OP tower has 1000 stages. Good luck!",
	"Stop collecting my coins!!",
}

---------------------------------------------------------------- OP Obby (1000-stage difficulty chart tower)
Config.OP = {
	Stages = 1000,
	TierSize = 50, -- stages per tier (20 tiers)
	Spacing = 40, -- studs between checkpoints
	Origin = Vector3.new(0, 80, 3200), -- far away from the story course
	TierHeight = 180, -- each tier sits higher than the last (it's a tower)
	StageRise = 2, -- studs each stage climbs within a tier
	CheckpointReward = 3,
	FinishReward = 5000,
	-- Difficulty chart names + colours, one per tier.
	Tiers = {
		{ "EFFORTLESS", Color3.fromRGB(0, 206, 0) }, { "EASY", Color3.fromRGB(118, 244, 71) },
		{ "MEDIUM", Color3.fromRGB(255, 255, 0) }, { "HARD", Color3.fromRGB(254, 124, 0) },
		{ "DIFFICULT", Color3.fromRGB(255, 12, 4) }, { "CHALLENGING", Color3.fromRGB(193, 0, 0) },
		{ "INTENSE", Color3.fromRGB(25, 40, 50) }, { "REMORSELESS", Color3.fromRGB(201, 1, 201) },
		{ "INSANE", Color3.fromRGB(0, 55, 255) }, { "EXTREME", Color3.fromRGB(3, 137, 255) },
		{ "TERRIFYING", Color3.fromRGB(0, 255, 255) }, { "CATASTROPHIC", Color3.fromRGB(255, 255, 255) },
		{ "HORRIFIC", Color3.fromRGB(150, 145, 255) }, { "UNREAL", Color3.fromRGB(75, 0, 200) },
		{ "NIL", Color3.fromRGB(101, 102, 109) }, { "IMPOSSIBLE", Color3.fromRGB(255, 70, 160) },
		{ "ABSURD", Color3.fromRGB(255, 160, 40) }, { "LEGENDARY", Color3.fromRGB(255, 205, 40) },
		{ "MYTHIC", Color3.fromRGB(170, 255, 200) }, { "OP", Color3.fromRGB(255, 0, 90) },
	},
}

-- Every N stages (story + OP) there's a Boost Station: mini dashboard + x2 coin orb.
Config.StationInterval = 15
Config.StationBoostMultiplier = 2
Config.StationBoostSeconds = 90

-- First-time players get this the moment they spawn (plus the Welcome badge).
Config.WelcomeCoins = 50

-- Invite a friend: when they join through your invite, you BOTH get x3 coins for this long.
Config.InviteBoostMultiplier = 3
Config.InviteBoostMinutes = 30

-- Co-op: tethered teammates earn bonus coins.
Config.TetherMultiplier = 1.5
Config.TetherLength = 16
Config.VaultReward = 75 -- Teamwork Vault coins (needs 2 players on the plates)
Config.VaultCooldownMinutes = 10

-- Fast reset (R key / RESET button) and respawn time.
Config.RespawnTime = 1.5

-- Forgiving failure: after 8 deaths on one stage, players may skip it for coins.
Config.CoinSkipCost = 50

-- Rebirth (prestige): reset coins + wins + story stage for a permanent multiplier.
Config.RebirthWinsNeeded = 1
Config.RebirthCost = 1000 -- multiplied by (rebirths + 1)
Config.RebirthMultiplierStep = 1 -- x2 after 1 rebirth, x3 after 2, ...

-- Idle "+1 Jump Power every second" (toggle in the HUD; makes runs unranked while on).
Config.MaxJumpPower = 1000
Config.JumpPowerHeight = 0.05 -- extra studs of jump height per point

-- Optional Roblox group: members can claim a one-time bonus (0 = off).
Config.GroupId = 0
Config.GroupReward = 200

-- All Roblox ids (images, sounds, music, game passes, products, badges) live in the
-- Assets module, so re-running the installer never wipes them.
local Assets = require(script.Parent:WaitForChild("Assets"))
Config.GamePasses = Assets.GamePasses or {}
Config.Products = Assets.Products or {}
Config.Badges = Assets.Badges or {}
Config.Images = Assets.Images or {}
Config.Sounds = Assets.Sounds or {}
Config.Music = Assets.Music or {}
Config.Skyboxes = Assets.Skyboxes or {}
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
add(f_shared, "ModuleScript", "PassCatalog", [==[
-- Game passes shown in the PASSES window, in display order.
-- Key = the name used in Assets.GamePasses (where you paste each pass id).
-- Assisted = using it makes the run not count for the Fastest Run leaderboard.
return {
	{ Key = "RocketLauncher", Name = "Rocket Launcher", Description = "Click to blast off where you're looking!", Assisted = true },
	{ Key = "TripleJump", Name = "Triple Jump", Description = "Jump twice more in mid-air.", Assisted = true },
	{ Key = "DoubleJump", Name = "Double Jump", Description = "Jump once more in mid-air.", Assisted = true },
	{ Key = "SpeedCoil", Name = "Speed Coil", Description = "Hold it to run 60% faster.", Assisted = true },
	{ Key = "GravityCoil", Name = "Gravity Coil", Description = "Hold it to float in low gravity.", Assisted = true },
	{ Key = "DoubleCoins", Name = "2x Coins", Description = "Double coins forever." },
	{ Key = "VIP", Name = "VIP", Description = "1.5x coins, VIP trail and [VIP] chat tag." },
}
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
	AssistUsed = get("AssistUsed", "RemoteEvent"), -- client -> server: used a game-pass ability this run
	TeleportStage = get("TeleportStage", "RemoteFunction"), -- client -> server: go to an unlocked stage
	DailyDraw = get("DailyDraw", "RemoteFunction"), -- client -> server: free daily draw
	SetNickname = get("SetNickname", "RemoteFunction"), -- client -> server: Rare+ name tag nickname
	RedeemCode = get("RedeemCode", "RemoteFunction"), -- client -> server: promo code
	ClaimGroup = get("ClaimGroup", "RemoteFunction"), -- client -> server: group member bonus
	TeleportOPTier = get("TeleportOPTier", "RemoteFunction"), -- client -> server: go to a reached OP tier
	QuickReset = get("QuickReset", "RemoteEvent"), -- client -> server: respawn at checkpoint now
	Untether = get("Untether", "RemoteEvent"), -- client -> server: leave co-op tether
	Rebirth = get("Rebirth", "RemoteFunction"), -- client -> server: prestige reset
	SkipWithCoins = get("SkipWithCoins", "RemoteFunction"), -- client -> server: coin skip after many fails
	Slap = get("Slap", "RemoteEvent"), -- client -> server: slap hand hit (target player)
	GoLobby = get("GoLobby", "RemoteFunction"), -- client -> server: teleport to the spawn plaza
	BackToStage = get("BackToStage", "RemoteFunction"), -- client -> server: return to your checkpoint
	Fx = get("Fx", "RemoteEvent"), -- server -> client: (effectName, ...) jumpscare / shake / confetti
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
		Id = "CometTrail",
		Name = "Comet Trail",
		Slot = "Trail",
		Price = 0,
		UnlockText = "Reach stage 20", -- free milestone reward (Config.Milestones)
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.3, Color3.fromRGB(120, 220, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 200)),
		}),
	},
	{
		Id = "RebirthTrail",
		Name = "Rebirth Trail",
		Slot = "Trail",
		Price = 0,
		UnlockText = "Rebirth once",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 80, 120)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 40)),
		}),
	},
	{
		Id = "ChampionHalo",
		Name = "Champion Halo",
		Slot = "Halo",
		Kind = "Halo",
		Price = 0,
		UnlockText = "Finish the story",
		Color = Color3.fromRGB(255, 215, 60),
	},
	{
		Id = "OPHalo",
		Name = "OP Halo",
		Slot = "Halo",
		Kind = "Halo",
		Price = 0,
		UnlockText = "Reach OP stage 100",
		Color = Color3.fromRGB(255, 0, 90),
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
add(f_shared, "ModuleScript", "UI", [==[
-- Small shared helpers for building UI in code (used by client scripts).
local UI = {}

UI.FONT = Enum.Font.FredokaOne
UI.COLORS = {
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

function UI.make(className, props, children)
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

function UI.corner(radius)
	return UI.make("UICorner", { CornerRadius = UDim.new(0, radius or 12) })
end

function UI.stroke(thickness)
	return UI.make("UIStroke", {
		Thickness = thickness or 3,
		Color = UI.COLORS.Outline,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function UI.text(props)
	props.BackgroundTransparency = 1
	props.Font = UI.FONT
	props.TextColor3 = props.TextColor3 or UI.COLORS.Text
	props.TextScaled = true
	local label = UI.make("TextLabel", props)
	UI.make("UIStroke", { Thickness = 2, Color = UI.COLORS.Outline, Parent = label })
	return label
end

function UI.button(props)
	props.Font = UI.FONT
	props.TextScaled = true
	props.TextColor3 = props.TextColor3 or UI.COLORS.Text
	props.AutoButtonColor = true
	return UI.make("TextButton", props, {
		UI.corner(10),
		UI.stroke(2),
		UI.make("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) }),
	})
end

-- A centered window with a title and close button. Returns frame, content area.
function UI.window(parent, title, maxSize)
	local frame = UI.make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.9, 0.82),
		BackgroundColor3 = UI.COLORS.Panel,
		Visible = false,
		ZIndex = 5,
		Parent = parent,
	}, { UI.corner(18), UI.stroke(4), UI.make("UISizeConstraint", { MaxSize = maxSize or Vector2.new(560, 560) }) })
	UI.text({
		Position = UDim2.fromOffset(18, 10),
		Size = UDim2.new(1, -90, 0, 44),
		Text = title,
		TextColor3 = UI.COLORS.Gold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 5,
		Parent = frame,
	})
	local close = UI.button({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.fromOffset(40, 40),
		BackgroundColor3 = UI.COLORS.Red,
		Text = "X",
		ZIndex = 6,
		Parent = frame,
	})
	close.Activated:Connect(function()
		frame.Visible = false
	end)
	local content = UI.make("ScrollingFrame", {
		Position = UDim2.fromOffset(14, 62),
		Size = UDim2.new(1, -28, 1, -74),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 5,
		Parent = frame,
	})
	return frame, content
end

function UI.formatDuration(seconds)
	seconds = math.max(0, math.floor(seconds))
	if seconds >= 3600 then
		return ("%dh %dm"):format(seconds // 3600, (seconds % 3600) // 60)
	end
	return ("%d:%02d"):format(seconds // 60, seconds % 60)
end

return UI
]==])
local f_server = folder(game:GetService("ServerScriptService"), "Server")
add(f_server, "ModuleScript", "Abilities", [==[
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
		table.insert(zones, { Center = first.Position + Vector3.new(-44, 0, 0), Radius = 50 })
	end
	local hub = checkpoints and checkpoints:FindFirstChild(tostring(Config.HubStage or 50))
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
]==])
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
add(f_server, "Script", "Boosts", [==[
-- Boost Station orbs (every Config.StationInterval stages): touch for a temporary coin boost.
-- Each orb works once per player every 10 minutes.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

local ORB_COOLDOWN = 600
local used = {} -- [Player] = { [stationId] = os.clock() }

local function onTouched(orb, hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	local session = player and PlayerData.Session(player)
	if not session then
		return
	end
	local id = orb:GetAttribute("StationId") or orb:GetFullName()
	used[player] = used[player] or {}
	local last = used[player][id]
	if last and os.clock() - last < ORB_COOLDOWN then
		return
	end
	used[player][id] = os.clock()
	session.StationBoostUntil = workspace:GetServerTimeNow() + Config.StationBoostSeconds
	PlayerData.Sync(player)
	Remotes.Notify:FireClient(player, ("BOOST STATION: x%d coins for %d seconds!"):format(Config.StationBoostMultiplier, Config.StationBoostSeconds), "gold")
	Remotes.Fx:FireClient(player, "Confetti")
end

local hooked = {}
local function hook(orb)
	if orb:IsA("BasePart") and not hooked[orb] then
		hooked[orb] = true
		orb.Touched:Connect(function(hit)
			onTouched(orb, hit)
		end)
		orb.Destroying:Connect(function()
			hooked[orb] = nil
		end)
	end
end
for _, orb in ipairs(CollectionService:GetTagged("BoostOrb")) do
	hook(orb)
end
CollectionService:GetInstanceAddedSignal("BoostOrb"):Connect(hook)

Players.PlayerRemoving:Connect(function(player)
	used[player] = nil
end)
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
	if elapsed then
		Course.AddRecentRun(player.DisplayName, elapsed, assisted)
	end
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
	local zoneBadges = { [2] = "ReachedCandy", [3] = "ReachedSpace", [4] = "ReachedLair" }
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

-- Latest finishes in this server (newest first), shown on the RECENT FINISHES board.
Course.RecentRuns = {}
function Course.AddRecentRun(name, seconds, assisted)
	table.insert(Course.RecentRuns, 1, { Name = name, Time = seconds, Assisted = assisted, At = os.time() })
	if #Course.RecentRuns > 10 then
		table.remove(Course.RecentRuns)
	end
end

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

local STAGES = Config.Stages or 40
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
	{ -- Gary's Lair (volcano)
		Platforms = {
			Color3.fromRGB(60, 50, 55),
			Color3.fromRGB(90, 70, 70),
			Color3.fromRGB(120, 40, 160),
			Color3.fromRGB(70, 60, 60),
		},
		Material = Enum.Material.Basalt,
		Checkpoint = Color3.fromRGB(255, 160, 40),
		Floor = Color3.fromRGB(255, 70, 20),
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

---------------------------------------------------------------- Boost Stations (every Config.StationInterval stages)
for stage = Config.StationInterval, STAGES - 1, Config.StationInterval do
	local padPos = Vector3.new((stage - 1) * SPACING, BASE_Y, 0)
	local orb = part({
		Name = "BoostOrb",
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * 3,
		Position = padPos + Vector3.new(-3.5, 3.5, 3.5),
		Color = Color3.fromRGB(255, 210, 40),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = course,
	})
	tag(orb, "BoostOrb", { StationId = "Story" .. stage })
	label(orb, ("x%d COINS - TOUCH ME"):format(Config.StationBoostMultiplier), Color3.fromRGB(255, 230, 120))
	local boardPos = padPos + Vector3.new(0, 6.5, -8)
	local board = part({
		Name = "StationBoard",
		Size = Vector3.new(11, 8, 0.6),
		CFrame = CFrame.lookAt(boardPos, boardPos + Vector3.new(0, 0, 1)),
		Color = Color3.fromRGB(25, 25, 45),
		CanCollide = false,
		Parent = course,
	})
	tag(board, "Board_Live")
end

---------------------------------------------------------------- Portals to the 1000-stage OP Obby
local function opPortal(position, facing)
	local ring = part({
		Name = "OPPortal",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.8, 11, 11),
		CFrame = CFrame.lookAt(position, position + facing) * CFrame.Angles(0, math.rad(90), 0),
		Color = Color3.fromRGB(255, 0, 90),
		Material = Enum.Material.ForceField,
		CanCollide = false,
		Parent = course,
	})
	tag(ring, "OPPortal")
	label(ring, "OP OBBY\n1000 STAGES", Color3.fromRGB(255, 120, 170), 90)
	local frame = part({
		Name = "OPPortalFrame",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.6, 12.5, 12.5),
		CFrame = ring.CFrame * CFrame.new(-0.4, 0, 0),
		Color = Color3.fromRGB(40, 0, 30),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = course,
	})
	frame.CanTouch = false
end
opPortal(Vector3.new(-30, BASE_Y + 6, 30), Vector3.new(0, 0, -1)) -- in the spawn plaza

-- World portals: one per world, in a row across the plaza (facing the spawn).
do
	local worldColors = {
		Color3.fromRGB(80, 170, 255),
		Color3.fromRGB(255, 120, 200),
		Color3.fromRGB(150, 90, 255),
		Color3.fromRGB(255, 100, 30),
	}
	local count = #Config.Zones
	for i, zone in ipairs(Config.Zones) do
		local z = (i - (count + 1) / 2) * 13
		local position = Vector3.new(-48, BASE_Y + 4.5, z)
		local ring = part({
			Name = "WorldPortal",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(0.6, 8, 8),
			CFrame = CFrame.new(position),
			Color = worldColors[i] or Color3.new(1, 1, 1),
			Material = Enum.Material.ForceField,
			CanCollide = false,
			Parent = course,
		})
		tag(ring, "WorldPortal", { Stage = zone.FirstStage, World = zone.Name })
		label(ring, ("%s\nStage %d"):format(zone.Name, zone.FirstStage), Color3.new(1, 1, 1), 70)
		local frame = part({
			Name = "WorldPortalFrame",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(0.5, 9.2, 9.2),
			CFrame = CFrame.new(position - Vector3.new(0.3, 0, 0)),
			Color = worldColors[i] or Color3.new(1, 1, 1),
			Material = Enum.Material.Neon,
			CanCollide = false,
			Parent = course,
		})
		frame.CanTouch = false
	end
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

-- Trap floor: identical tiles, but some of them drop away (great reaction clips).
local function trapFloor(stage, x0, d)
	local rng = Random.new(stage * 31)
	local tiles = 6
	for i = 1, tiles do
		local cx = 6 + (i - 0.5) * (48 / tiles)
		for row = -1, 1 do
			local tile = platform(stage, Vector3.new(x0 + cx, BASE_Y, row * 3.2), Vector3.new(48 / tiles - 0.2, 1, 3))
			tile.Color = Color3.fromRGB(230, 230, 240)
			-- One safe tile per column; the others are trap doors.
			if row ~= (rng:NextInteger(-1, 1)) then
				tag(tile, "TrapDoor")
			end
		end
	end
	coin(Vector3.new(x0 + 30, BASE_Y + 3.5, 0))
end

local candySections = {
	trapFloor,
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
	trapFloor,
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
	-- Laser gates: neon bars sliding up and down across a walkway
	function(stage, x0, d)
		platform(stage, Vector3.new(x0 + 30, BASE_Y, 0), Vector3.new(48, 1, 8))
		for i, cx in ipairs({ 16, 27, 38, 49 }) do
			local laser = killBrick(Vector3.zero, Vector3.new(1, 0.6, 9))
			laser.Color = Color3.fromRGB(255, 50, 200)
			-- Rotated so the slider's X axis points up: it moves vertically.
			laser.CFrame = CFrame.new(x0 + cx, BASE_Y + 4, 0) * CFrame.Angles(0, 0, math.rad(90))
			tag(laser, "Slider", { Distance = 3.2, Speed = 0.35 + 0.25 * d, Phase = i * 0.27 })
		end
		for _, cx in ipairs({ 21, 32, 43 }) do
			coin(Vector3.new(x0 + cx, BASE_Y + 3.5, 0))
		end
	end,
	-- Long moon leaps between tiny platforms
	function(stage, x0, d)
		local size = 5 - 1.5 * d
		for i, cx in ipairs({ 20, 37 }) do
			local y = BASE_Y + (i == 1 and 4 or 1)
			platform(stage, Vector3.new(x0 + cx, y, (i == 1 and 3 or -3)), Vector3.new(size, 1, size))
			coin(Vector3.new(x0 + cx, y + 9, 0))
		end
		coin(Vector3.new(x0 + 46, BASE_Y + 12, 0))
	end,
}

-- Gary's Lair (normal gravity): the hardest mix of every hazard.
-- candySections: 1 trap, 2 fade, 3 conveyor, 4 jump pad, 5 sliders
-- spaceSections: 3 double spinners, 6 laser gates (both fine in normal gravity)
local lairSections = {
	trapFloor,
	skySections[3], -- spinning bar
	candySections[5], -- sliders
	spaceSections[6], -- laser gates
	candySections[3], -- conveyor
	spaceSections[3], -- double spinners
	skySections[2], -- kill strips
	candySections[2], -- vanishing platforms
}

local sectionsByZone = { skySections, candySections, spaceSections, lairSections }

for stage = 1, STAGES - 1 do
	local zIndex = zoneIndex(stage)
	local zoneFirst = Config.Zones[zIndex].FirstStage
	local nextZone = Config.Zones[zIndex + 1]
	local zoneLast = nextZone and nextZone.FirstStage - 1 or STAGES - 1
	local d = (stage - zoneFirst) / math.max(zoneLast - zoneFirst, 1)
	local sections = sectionsByZone[zIndex]
	sections[(stage - zoneFirst) % #sections + 1](stage, (stage - 1) * SPACING, d)
end

---------------------------------------------------------------- Gary jumpscares + a silly yeet pad (clip-worthy moments)
for _, stage in ipairs({ 6, 17, 31, 44, 58, 67, 79, 88, 97 }) do
	if stage < STAGES then
		local trigger = part({
			Name = "GaryScare",
			Size = Vector3.new(4, 8, 14),
			Position = Vector3.new((stage - 1) * SPACING + 30, BASE_Y + 4, 0),
			Transparency = 1,
			CanCollide = false,
			Parent = course,
		})
		tag(trigger, "Jumpscare")
	end
end
do
	-- On the lobby island: a pad that launches you absurdly high (land back in the lobby).
	local yeet = part({
		Name = "YeetPad",
		Size = Vector3.new(5, 0.6, 5),
		Position = Vector3.new(-26, BASE_Y + 0.3, -30),
		Color = Color3.fromRGB(255, 80, 200),
		Material = Enum.Material.Neon,
		Parent = course,
	})
	tag(yeet, "JumpPad", { Power = 260, Yeet = true })
	label(yeet, "DO NOT TOUCH", Color3.fromRGB(255, 120, 220))
end

---------------------------------------------------------------- Kill floors (one per zone, out to the horizon)
local FLOOR_MATERIALS = { Enum.Material.CrackedLava, Enum.Material.SmoothPlastic, Enum.Material.Neon, Enum.Material.CrackedLava }
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

---------------------------------------------------------------- Leaderboard boards
-- Boards are found by tag: Board_Wins (global most wins), Board_Time (global fastest run),
-- Board_Live (this server's live race by stage). See Leaderboards.server.
local function board(name, tagName, position, facing, size)
	local p = part({
		Name = name,
		Size = size or Vector3.new(14, 12, 1),
		CFrame = CFrame.lookAt(position, position + facing),
		Color = Color3.fromRGB(25, 25, 45),
		Parent = boards,
	})
	CollectionService:AddTag(p, tagName)
	return p
end
-- Spawn plaza: a big Hall of Fame wall facing the start, plus the speedrun podium.
-- The lobby island (Scenery) is centred at LOBBY_X with room for everything.
local LOBBY_X = -44
local wallX = LOBBY_X - 40
local toCourse = Vector3.new(1, 0, 0)
board("HallTime", "Board_Time", Vector3.new(wallX, BASE_Y + 12, -11), toCourse, Vector3.new(20, 20, 1))
board("HallRecent", "Board_Recent", Vector3.new(wallX, BASE_Y + 12, 11), toCourse, Vector3.new(20, 20, 1))
board("HallWins", "Board_Wins", Vector3.new(wallX + 2, BASE_Y + 10, -33), Vector3.new(1, 0, 0.35).Unit, Vector3.new(18, 16, 1))
board("HallLive", "Board_Live", Vector3.new(wallX + 2, BASE_Y + 10, 33), Vector3.new(1, 0, -0.35).Unit, Vector3.new(18, 16, 1))
do
	local header = part({
		Name = "HallHeader",
		Size = Vector3.new(1, 6, 44),
		Position = Vector3.new(wallX - 0.5, BASE_Y + 25.5, 0),
		Color = Color3.fromRGB(25, 25, 45),
		Parent = boards,
	})
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Right
	gui.LightInfluence = 0
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.Text = "🏆 HALL OF FAME 🏆"
	t.TextColor3 = Color3.fromRGB(255, 215, 60)
	t.Parent = gui
	gui.Parent = header
	-- Backing wall
	local wall = part({
		Name = "HallWall",
		Size = Vector3.new(2, 30, 50),
		Position = Vector3.new(wallX - 2, BASE_Y + 14.5, 0),
		Color = Color3.fromRGB(245, 240, 230),
		Material = Enum.Material.Marble,
		Parent = boards,
	})
	wall.CanCollide = true

	-- Speedrun podium: statues of the 3 fastest players (filled in by Leaderboards.server).
	local podiumX = wallX + 18
	for rank, info in ipairs({ { 0, 6, Color3.fromRGB(255, 205, 40) }, { -8, 4, Color3.fromRGB(210, 215, 230) }, { 8, 2.5, Color3.fromRGB(215, 140, 80) } }) do
		local z, height, color = info[1], info[2], info[3]
		local pedestal = part({
			Name = "Podium" .. rank,
			Size = Vector3.new(7, height, 7),
			Position = Vector3.new(podiumX, BASE_Y + height / 2, z),
			Color = color,
			Material = Enum.Material.Marble,
			Parent = boards,
		})
		tag(pedestal, "Podium", { Rank = rank })
		label(pedestal, "#" .. rank, color, 40)
	end
end

---------------------------------------------------------------- Central hub (dashboard + NPCs)
local HUB_STAGE = math.clamp(Config.HubStage or 20, 2, STAGES - 1)
local hubX = (HUB_STAGE - 1) * SPACING
local HUB_CENTER = Vector3.new(hubX, BASE_Y, -62)
local HUB_DIAMETER = 84
do
	local hubTheme = THEMES[zoneIndex(HUB_STAGE)]
	-- Walkable bridge from the hub checkpoint to the island.
	part({
		Name = "HubBridge",
		Size = Vector3.new(7, 1, 30),
		Position = Vector3.new(hubX, BASE_Y - 0.5, -20),
		Color = Color3.fromRGB(150, 105, 70),
		Material = Enum.Material.WoodPlanks,
		Parent = course,
	})
	-- Giant dashboard: three panels facing the course.
	local dashZ = HUB_CENTER.Z - 24
	local facing = Vector3.new(0, 0, 1)
	board("HubWins", "Board_Wins", Vector3.new(hubX - 27, BASE_Y + 10, dashZ), facing, Vector3.new(17, 15, 1))
	board("HubLive", "Board_Live", Vector3.new(hubX - 9, BASE_Y + 11, dashZ), facing, Vector3.new(17, 17, 1))
	board("HubOP", "Board_OP", Vector3.new(hubX + 9, BASE_Y + 11, dashZ), facing, Vector3.new(17, 17, 1))
	board("HubTime", "Board_Time", Vector3.new(hubX + 27, BASE_Y + 10, dashZ), facing, Vector3.new(17, 15, 1))
	local frame = part({
		Name = "DashboardFrame",
		Size = Vector3.new(76, 22, 1),
		CFrame = CFrame.new(hubX, BASE_Y + 11, dashZ - 0.8),
		Color = hubTheme.Checkpoint,
		Material = Enum.Material.Neon,
		Parent = boards,
	})
	frame.CanCollide = false
	local header = part({
		Name = "DashboardHeader",
		Size = Vector3.new(40, 5, 1),
		CFrame = CFrame.lookAt(Vector3.new(hubX, BASE_Y + 24.5, dashZ), Vector3.new(hubX, BASE_Y + 24.5, dashZ) + facing),
		Color = Color3.fromRGB(25, 25, 45),
		Parent = boards,
	})
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.fromScale(1, 1)
	headerText.BackgroundTransparency = 1
	headerText.Font = Enum.Font.FredokaOne
	headerText.TextScaled = true
	headerText.Text = "SKY COIN DASHBOARD"
	headerText.TextColor3 = Color3.fromRGB(255, 215, 60)
	headerText.Parent = gui
	gui.Parent = header
	opPortal(HUB_CENTER + Vector3.new(20, 6, 6), Vector3.new(-1, 0, 0)) -- on the hub island

	-- Teamwork Vault: glass cage with a coin chest; two plates must be held at once to open it.
	local vault = HUB_CENTER + Vector3.new(-24, 0, 10)
	local glass = { Color = Color3.fromRGB(180, 230, 255), Material = Enum.Material.Glass, Transparency = 0.3, Parent = course }
	local function wall(offset, size)
		local props = table.clone(glass)
		props.Size = size
		props.Position = vault + offset
		return part(props)
	end
	wall(Vector3.new(0, 4, -4), Vector3.new(8, 8, 0.5))
	wall(Vector3.new(-4, 4, 0), Vector3.new(0.5, 8, 8))
	wall(Vector3.new(4, 4, 0), Vector3.new(0.5, 8, 8))
	wall(Vector3.new(0, 8.25, 0), Vector3.new(8, 0.5, 8))
	local door = wall(Vector3.new(0, 4, 4), Vector3.new(8, 8, 0.5))
	door.Name = "VaultDoor"
	CollectionService:AddTag(door, "VaultDoor")
	local chest = part({
		Name = "VaultChest",
		Size = Vector3.new(3, 2.5, 2),
		Position = vault + Vector3.new(0, 1.3, 0),
		Color = Color3.fromRGB(255, 200, 40),
		Material = Enum.Material.Neon,
		Parent = course,
	})
	CollectionService:AddTag(chest, "VaultChest")
	label(chest, "TEAMWORK VAULT\nStand on BOTH plates!", Color3.fromRGB(255, 230, 120), 70)
	for _, dx in ipairs({ -7, 7 }) do
		local plate = part({
			Name = "VaultPlate",
			Size = Vector3.new(4, 0.4, 4),
			Position = vault + Vector3.new(dx, 0.2, 10),
			Color = Color3.fromRGB(255, 80, 80),
			Material = Enum.Material.Neon,
			Parent = course,
		})
		CollectionService:AddTag(plate, "VaultPlate")
	end

	-- Jump Power Tower: ledges far too high to reach... until your Jump Power grows.
	local towerBase = HUB_CENTER + Vector3.new(26, 0, -24)
	for i, height in ipairs({ 18, 34, 55 }) do
		local ledge = part({
			Name = "PowerLedge",
			Size = Vector3.new(8, 1, 8),
			Position = towerBase + Vector3.new(0, height, -i * 2),
			Color = Color3.fromRGB(255, 220, 60),
			Material = Enum.Material.Neon,
			Parent = course,
		})
		local reward = ({ 100, 250, 600 })[i]
		local chestTop = part({
			Name = "PowerChest",
			Size = Vector3.new(2.5, 2, 2),
			Position = ledge.Position + Vector3.new(0, 1.5, 0),
			Color = Color3.fromRGB(120, 70, 30),
			Material = Enum.Material.Wood,
			Parent = course,
		})
		tag(chestTop, "RewardChest", { Reward = reward, CooldownMinutes = 60, ChestId = "Power" .. i })
		label(ledge, ("JUMP POWER %d+\n+%d coins"):format(({ 230, 550, 970 })[i], reward), Color3.new(1, 1, 1), 60)
	end
end

---------------------------------------------------------------- Scenery (islands, worlds, gates, trophy)
require(script.Parent:WaitForChild("Scenery")).Build({
	Stages = STAGES,
	Spacing = SPACING,
	BaseY = BASE_Y,
	Zones = Config.Zones,
	ZoneIndex = zoneIndex,
	HubCenter = HUB_CENTER,
	HubDiameter = HUB_DIAMETER,
})

course.Parent = workspace
killParts.Parent = workspace
coins.Parent = workspace
boards.Parent = workspace
checkpoints.Parent = workspace
]==])
add(f_server, "Script", "DailyDraw", [==[
-- Free Daily Draw (every Config.DrawCooldownHours): Common / Rare / Legendary.
-- The prize lasts until the next draw is available: jump boots, a smoke aura, a name tag
-- (Rare+ can set a filtered nickname) and, for Legendary, +50% coins and a flame trail.
-- No Robux involved, and the odds are shown in-game.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TextService = game:GetService("TextService")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Server = ServerScriptService:WaitForChild("Server")
local PlayerData = require(Server:WaitForChild("PlayerData"))
local Abilities = require(Server:WaitForChild("Abilities"))

local rng = Random.new()

local function roll()
	local total = 0
	for _, rarity in ipairs(Config.DrawRarities) do
		total += rarity.Chance
	end
	local pick = rng:NextNumber(0, total)
	for _, rarity in ipairs(Config.DrawRarities) do
		pick -= rarity.Chance
		if pick <= 0 then
			return rarity
		end
	end
	return Config.DrawRarities[1]
end

---------------------------------------------------------------- Visual effects
local AURAS = {
	Small = { Size = 0.6, Opacity = 0.08, RiseVelocity = 1, Color = Color3.fromRGB(230, 230, 240) },
	Medium = { Size = 1.4, Opacity = 0.14, RiseVelocity = 2, Color = Color3.fromRGB(120, 180, 255) },
	Super = { Size = 2.6, Opacity = 0.2, RiseVelocity = 3, Color = Color3.fromRGB(190, 110, 255) },
}

local TAG_STYLES = {
	Silver = { Color = Color3.fromRGB(215, 220, 230), Prefix = "" },
	Gold = { Color = Color3.fromRGB(255, 205, 50), Prefix = "★ " },
	Legendary = { Color = Color3.new(1, 1, 1), Prefix = "👑 ", Rainbow = true },
}

local function clearEffects(character)
	for _, d in ipairs(character:GetDescendants()) do
		if d:GetAttribute("DrawFx") then
			d:Destroy()
		end
	end
end

local function fx(className, parent)
	local inst = Instance.new(className)
	inst:SetAttribute("DrawFx", true)
	inst.Parent = parent
	return inst
end

local function applyEffects(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local head = character and character:FindFirstChild("Head")
	if not root or not head then
		return
	end
	clearEffects(character)
	local rarity = PlayerData.ActiveDraw(player)
	if not rarity then
		return
	end
	local data = PlayerData.Get(player)

	-- Smoke aura
	local aura = AURAS[rarity.Aura]
	if aura then
		local smoke = fx("Smoke", root)
		smoke.Size = aura.Size
		smoke.Opacity = aura.Opacity
		smoke.RiseVelocity = aura.RiseVelocity
		smoke.Color = aura.Color
	end
	if rarity.Aura == "Super" then
		local sparkles = fx("ParticleEmitter", root)
		sparkles.Color = ColorSequence.new(Color3.fromRGB(255, 220, 80), Color3.fromRGB(255, 120, 255))
		sparkles.LightEmission = 1
		sparkles.Size = NumberSequence.new(0.5, 0)
		sparkles.Rate = 25
		sparkles.Lifetime = NumberRange.new(0.8, 1.5)
		sparkles.Speed = NumberRange.new(2, 5)
		sparkles.SpreadAngle = Vector2.new(180, 180)
		local light = fx("PointLight", root)
		light.Color = Color3.fromRGB(255, 200, 120)
		light.Range = 14
		light.Brightness = 2
	end

	-- Legendary flame trail
	if rarity.Trail then
		local top = fx("Attachment", root)
		top.Position = Vector3.new(0, 1, 0.5)
		local bottom = fx("Attachment", root)
		bottom.Position = Vector3.new(0, -1, 0.5)
		local trail = fx("Trail", root)
		trail.Attachment0 = top
		trail.Attachment1 = bottom
		trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 120)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 80, 200)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 60, 255)),
		})
		trail.LightEmission = 1
		trail.Lifetime = 0.9
		trail.FaceCamera = true
		trail.Transparency = NumberSequence.new(0, 1)
	end

	-- Name tag
	local style = TAG_STYLES[rarity.Tag]
	if style then
		local gui = fx("BillboardGui", head)
		gui.Size = UDim2.fromOffset(200, 40)
		gui.StudsOffset = Vector3.new(0, 2.6, 0)
		gui.MaxDistance = 80
		gui.Adornee = head
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.FredokaOne
		label.TextScaled = true
		label.TextStrokeTransparency = 0
		label.TextColor3 = style.Color
		local nickname = rarity.Nickname and data.Draw.Nickname
		local name = (nickname and nickname ~= "") and nickname or player.DisplayName
		label.Text = style.Prefix .. name
		label.Parent = gui
		if style.Rainbow then
			local gradient = Instance.new("UIGradient")
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
				ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 220, 60)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 255, 140)),
				ColorSequenceKeypoint.new(0.75, Color3.fromRGB(80, 160, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 90, 255)),
			})
			gradient.Parent = label
			CollectionService:AddTag(gradient, "RainbowGradient") -- animated on clients
		end
	end
end

local function refresh(player)
	Abilities.Grant(player) -- updates the JumpBoost attribute
	applyEffects(player)
	PlayerData.Sync(player)
end

---------------------------------------------------------------- Remotes
Remotes.DailyDraw.OnServerInvoke = function(player)
	local data = PlayerData.Get(player)
	if not data then
		return false, "Still loading, try again"
	end
	local waitSeconds = Config.DrawCooldownHours * 3600 - (os.time() - data.LastDraw)
	if waitSeconds > 0 then
		return false, ("Next draw in %dh %dm"):format(waitSeconds // 3600, (waitSeconds % 3600) // 60)
	end
	local rarity = roll()
	local oldNickname = data.Draw and data.Draw.Nickname or ""
	data.LastDraw = os.time()
	data.Draw = {
		Rarity = rarity.Name,
		Expires = os.time() + Config.DrawCooldownHours * 3600,
		Nickname = rarity.Nickname and oldNickname or "",
	}
	refresh(player)
	return true, rarity.Name
end

Remotes.SetNickname.OnServerInvoke = function(player, text)
	local rarity = PlayerData.ActiveDraw(player)
	if not rarity or not rarity.Nickname then
		return false, "Nicknames need a Rare or Legendary draw"
	end
	if type(text) ~= "string" then
		return false, "Bad nickname"
	end
	text = text:gsub("^%s+", ""):gsub("%s+$", "")
	if #text < 1 or utf8.len(text) == nil or utf8.len(text) > 20 then
		return false, "Nicknames must be 1-20 characters"
	end
	-- Roblox text filtering is required for any player-written text shown to others.
	local ok, filtered = pcall(function()
		local result = TextService:FilterStringAsync(text, player.UserId, Enum.TextFilterContext.PublicChat)
		return result:GetNonChatStringForBroadcastAsync()
	end)
	if not ok or not filtered or filtered:find("#") then
		return false, "That nickname isn't allowed - try another"
	end
	PlayerData.Get(player).Draw.Nickname = filtered
	applyEffects(player)
	return true, "Nickname set to " .. filtered
end

---------------------------------------------------------------- Lifecycle
local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Head", 10)
		PlayerData.WaitFor(player)
		applyEffects(player)
	end)
	task.spawn(function()
		PlayerData.WaitFor(player)
		refresh(player)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Expire prizes when their time is up.
while true do
	task.wait(30)
	for _, player in ipairs(Players:GetPlayers()) do
		local data = PlayerData.Get(player)
		if data and data.Draw and os.time() >= (data.Draw.Expires or 0) and player:GetAttribute("JumpBoost") ~= 1 then
			refresh(player)
		end
	end
end
]==])
add(f_server, "Script", "Leaderboards", [==[
-- Leaderboards on in-world boards:
--   Board_Wins  - global Most Wins        (all servers)
--   Board_Time  - global Fastest Full Run (all servers)
--   Board_Live  - live race in this server, by current stage
-- Tag any part with one of these and it becomes that board.
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))
local Course = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Course"))

local REFRESH_SECONDS = 60
local SHOWN = 10

local okStores, winsStore, timeStore, opStore = pcall(function()
	return DataStoreService:GetOrderedDataStore("Wins_" .. Config.LeaderboardVersion),
		DataStoreService:GetOrderedDataStore("BestTime_" .. Config.LeaderboardVersion),
		DataStoreService:GetOrderedDataStore("OPStage_" .. Config.LeaderboardVersion)
end)
if not okStores then
	warn("[Leaderboards] Unavailable:", winsStore)
	winsStore, timeStore, opStore = nil, nil, nil
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

-- Boards are found by tag, so the same board type can appear in several places.
local CollectionService = game:GetService("CollectionService")

local function listsFor(tagName, title, color)
	local lists = {}
	local function add(part)
		if part:IsA("BasePart") then
			table.insert(lists, buildBoard(part, title, color))
		end
	end
	for _, part in ipairs(CollectionService:GetTagged(tagName)) do
		add(part)
	end
	CollectionService:GetInstanceAddedSignal(tagName):Connect(add)
	return lists
end

-- Wait for the course builder (boards are created at startup).
workspace:WaitForChild("Checkpoints", 30)
local winsLists = listsFor("Board_Wins", "MOST WINS", Color3.fromRGB(255, 170, 40))
local timeLists = listsFor("Board_Time", "FASTEST RUN", Color3.fromRGB(70, 160, 255))
local liveLists = listsFor("Board_Live", "LIVE RACE", Color3.fromRGB(80, 220, 120))
local opLists = listsFor("Board_OP", "OP TOWER TOP", Color3.fromRGB(255, 0, 90))
local recentLists = listsFor("Board_Recent", "RECENT FINISHES", Color3.fromRGB(180, 90, 255))

---------------------------------------------------------------- Speedrun podium (top 3 statues)
local statueOwners = {} -- [rank] = userId currently shown
local function updatePodium(entries)
	for _, pedestal in ipairs(CollectionService:GetTagged("Podium")) do
		local rank = pedestal:GetAttribute("Rank")
		local entry = entries[rank]
		local userId = entry and tonumber(entry.key)
		if userId ~= statueOwners[rank] then
			statueOwners[rank] = userId
			local old = pedestal:FindFirstChild("Statue")
			if old then
				old:Destroy()
			end
			if userId then
				task.spawn(function()
					local ok, statue = pcall(Players.CreateHumanoidModelFromUserId, Players, userId)
					if not ok or not statue or statueOwners[rank] ~= userId then
						return
					end
					statue.Name = "Statue"
					for _, d in ipairs(statue:GetDescendants()) do
						if d:IsA("BasePart") then
							d.Anchored = true
							d.CanCollide = false
						elseif d:IsA("Script") or d:IsA("LocalScript") then
							d:Destroy()
						end
					end
					local humanoid = statue:FindFirstChildOfClass("Humanoid")
					if humanoid then
						humanoid.DisplayName = ("#%d %s - %s"):format(rank, nameFor(userId), formatTime(entry.value / 100))
						humanoid.NameDisplayDistance = 120
					end
					statue:ScaleTo(1.6)
					local _, size = statue:GetBoundingBox()
					local top = pedestal.Position + Vector3.new(0, pedestal.Size.Y / 2 + size.Y / 2, 0)
					statue:PivotTo(CFrame.lookAt(top, top + Vector3.new(1, 0, 0)))
					statue.Parent = pedestal
				end)
			end
		end
	end
end

local function fillAll(lists, entries, formatValue)
	-- Boards in streamed OP tiers come and go; drop the ones that were destroyed.
	for i = #lists, 1, -1 do
		if not lists[i]:IsDescendantOf(workspace) then
			table.remove(lists, i)
		end
	end
	for _, list in ipairs(lists) do
		fill(list, entries, formatValue)
	end
end

local function setNotice(lists, text)
	for _, list in ipairs(lists) do
		list.Row1.Text = text
	end
end

local lastOPEntries = {}
local function refreshGlobal()
	if not winsStore then
		setNotice(winsLists, "Works once the game is published")
		setNotice(timeLists, "Works once the game is published")
		setNotice(opLists, "Works once the game is published")
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
			if data.OPStage > 1 then
				pcall(opStore.SetAsync, opStore, key, data.OPStage)
			end
		end
	end

	local okWins, winsPage = pcall(winsStore.GetSortedAsync, winsStore, false, SHOWN)
	if okWins then
		fillAll(winsLists, winsPage:GetCurrentPage(), function(v)
			return v .. " wins"
		end)
	end
	local okOP, opPage = pcall(opStore.GetSortedAsync, opStore, false, SHOWN)
	if okOP then
		lastOPEntries = opPage:GetCurrentPage()
	end
	local okTime, timePage = pcall(timeStore.GetSortedAsync, timeStore, true, SHOWN)
	if okTime then
		local entries = timePage:GetCurrentPage()
		fillAll(timeLists, entries, function(v)
			return formatTime(v / 100)
		end)
		updatePodium(entries)
	end
end

-- Live race: everyone in this server, furthest stage first.
local function refreshLive()
	local entries = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local data = PlayerData.Get(player)
		if data then
			names[player.UserId] = player.DisplayName
			table.insert(entries, { key = tostring(player.UserId), value = data.Stage, wins = data.Wins })
		end
	end
	table.sort(entries, function(a, b)
		if a.value ~= b.value then
			return a.value > b.value
		end
		return a.wins > b.wins
	end)
	fillAll(liveLists, entries, function(v)
		return "Stage " .. v
	end)
	-- Recent finishes in this server (assisted runs are marked).
	for i = #recentLists, 1, -1 do
		if not recentLists[i]:IsDescendantOf(workspace) then
			table.remove(recentLists, i)
		end
	end
	for _, list in ipairs(recentLists) do
		for i = 1, SHOWN do
			local run = Course.RecentRuns[i]
			list["Row" .. i].Text = run and ("%s  %s%s"):format(run.Name, formatTime(run.Time), run.Assisted and " (passes)" or "") or ""
		end
		if not Course.RecentRuns[1] then
			list.Row1.Text = "Finish the course to appear here!"
		end
	end
	-- OP boards refresh often too, so newly streamed station boards fill quickly.
	fillAll(opLists, lastOPEntries, function(v)
		return "OP " .. v
	end)
end

task.spawn(function()
	while true do
		refreshLive()
		task.wait(2)
	end
end)

while true do
	refreshGlobal()
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
local Abilities = require(Server:WaitForChild("Abilities"))
local OPCourse = require(Server:WaitForChild("OPCourse"))

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
	Abilities.Grant(player)
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
		Abilities.Grant(player)
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
	if data.Mode == "OP" then
		if data.OPStage >= Config.OP.Stages - 1 then
			PlayerData.AddCoins(player, Config.WinReward, false)
			Remotes.Notify:FireClient(player, ("The last stage can't be skipped - here's +%d coins!"):format(Config.WinReward), "good")
			return true
		end
		PlayerData.SetOPStage(player, data.OPStage + 1)
		OPCourse.PlaceOnStage(player.Character, data.OPStage)
		Remotes.Notify:FireClient(player, ("Skipped to OP stage %d!"):format(data.OPStage), "good")
		return true
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
add(f_server, "Script", "NPCs", [==[
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
		table.insert(areas, { Center = first.Position + Vector3.new(-30, 0, 0), Radius = 20, Count = 3 })
	end
	local hubStage = checkpoints and checkpoints:FindFirstChild(tostring(Config.HubStage or 50))
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
]==])
add(f_server, "ModuleScript", "OPCourse", [==[
-- Streams the OP Obby: a tier (50 stages) is built when a player needs it and removed
-- once nobody has been there for a while, so 1000 stages never exist all at once.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Server = ServerScriptService:WaitForChild("Server")
local OPGen = require(Server:WaitForChild("OPGen"))
local PlayerData = require(Server:WaitForChild("PlayerData"))

local OPCourse = {}
OPCourse.TierOf = OPGen.TierOf
OPCourse.PadPosition = OPGen.PadPosition

local UNLOAD_AFTER = 45 -- seconds a tier stays after the last player leaves it
local built = {} -- [tier] = { Folders = {...}, LastNeeded = os.clock() }

function OPCourse.Ensure(tier)
	tier = math.clamp(tier, 1, #Config.OP.Tiers)
	local entry = built[tier]
	if not entry then
		entry = { Folders = OPGen.Build(tier) }
		built[tier] = entry
	end
	entry.LastNeeded = os.clock()
end

function OPCourse.PlaceOnStage(character, stage)
	stage = math.clamp(stage, 1, Config.OP.Stages)
	OPCourse.Ensure(OPGen.TierOf(stage))
	if character and character.Parent then
		character:PivotTo(CFrame.new(OPGen.PadPosition(stage) + Vector3.new(0, 3.5, 0)))
	end
end

local function neededTiers()
	local needed = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local data = PlayerData.Get(player)
		if data and data.Mode == "OP" then
			local tier = OPGen.TierOf(data.OPStage)
			needed[tier] = true
			-- Pre-build the next tier when they're close to its portal.
			if data.OPStage % Config.OP.TierSize >= Config.OP.TierSize - 3 then
				needed[tier + 1] = true
			end
		end
	end
	return needed
end

task.spawn(function()
	while true do
		task.wait(3)
		for tier in pairs(neededTiers()) do
			if tier <= #Config.OP.Tiers then
				OPCourse.Ensure(tier)
			end
		end
		for tier, entry in pairs(built) do
			if os.clock() - entry.LastNeeded > UNLOAD_AFTER then
				for _, folder in ipairs(entry.Folders) do
					folder:Destroy()
				end
				built[tier] = nil
			end
		end
	end
end)

return OPCourse
]==])
add(f_server, "ModuleScript", "OPGen", [==[
-- Builds one tier (50 stages) of the 1000-stage OP Obby, procedurally.
-- Every stage is generated from its number, so the same stage always looks the same.
-- Difficulty climbs with the tier: smaller platforms, bigger gaps, faster hazards.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local OP = Config.OP

local OPGen = {}

function OPGen.TierOf(stage)
	return math.floor((stage - 1) / OP.TierSize) + 1
end

function OPGen.PadPosition(stage)
	local tier = OPGen.TierOf(stage)
	local i = stage - (tier - 1) * OP.TierSize
	return OP.Origin + Vector3.new((i - 1) * OP.Spacing, (tier - 1) * OP.TierHeight + (i - 1) * OP.StageRise, 0)
end

local function subfolder(parentName, name)
	local parent = workspace:FindFirstChild(parentName)
	if not parent then
		parent = Instance.new("Folder")
		parent.Name = parentName
		parent.Parent = workspace
	end
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

function OPGen.Build(tier)
	local tierName, tierColor = OP.Tiers[tier][1], OP.Tiers[tier][2]
	local course = Instance.new("Folder")
	course.Name = "OPTier" .. tier
	local coins = subfolder("Coins", "OPTier" .. tier)
	local kills = subfolder("KillParts", "OPTier" .. tier)

	local function part(props, className, parent)
		local p = Instance.new(className or "Part")
		p.Anchored = true
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Material = Enum.Material.SmoothPlastic
		for key, value in pairs(props) do
			p[key] = value
		end
		p.Parent = parent or course
		return p
	end
	local function tag(p, name, attributes)
		CollectionService:AddTag(p, name)
		for key, value in pairs(attributes or {}) do
			p:SetAttribute(key, value)
		end
		return p
	end
	local function label(p, text, color, size, offset)
		local gui = Instance.new("BillboardGui")
		gui.Size = size or UDim2.fromOffset(160, 40)
		gui.StudsOffset = offset or Vector3.new(0, 4, 0)
		gui.MaxDistance = 70
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.Font = Enum.Font.FredokaOne
		t.TextScaled = true
		t.Text = text
		t.TextColor3 = color
		t.TextStrokeTransparency = 0
		t.Parent = gui
		gui.Parent = p
	end

	-- Platform colours: the tier colour mixed with white/black for variety.
	local light = tierColor:Lerp(Color3.new(1, 1, 1), 0.35)
	local dark = tierColor:Lerp(Color3.new(0, 0, 0), 0.25)

	for i = 1, OP.TierSize do
		local stage = (tier - 1) * OP.TierSize + i
		if stage > OP.Stages then
			break
		end
		local pad = OPGen.PadPosition(stage)
		local isStation = stage % Config.StationInterval == 0
		local isFinal = stage == OP.Stages

		-- Checkpoint pad
		local checkpoint = part({
			Name = "OP" .. stage,
			Size = (isStation or isFinal) and Vector3.new(12, 1, 12) or Vector3.new(8, 1, 8),
			Position = pad,
			Color = isFinal and Color3.fromRGB(255, 205, 40) or tierColor,
			Material = Enum.Material.Neon,
		})
		tag(checkpoint, "OPCheckpoint", { Stage = stage })
		label(checkpoint, isFinal and "OP CHAMPION!" or tostring(stage), Color3.new(1, 1, 1))

		-- Boost Station every N stages: x2 coin orb + mini live dashboard.
		if isStation then
			local orb = part({
				Name = "BoostOrb",
				Shape = Enum.PartType.Ball,
				Size = Vector3.one * 3,
				Position = pad + Vector3.new(3, 3.5, 3),
				Color = Color3.fromRGB(255, 210, 40),
				Material = Enum.Material.Neon,
				CanCollide = false,
			})
			tag(orb, "BoostOrb", { StationId = "OP" .. stage })
			label(orb, ("x%d COINS"):format(Config.StationBoostMultiplier), Color3.fromRGB(255, 230, 120), nil, Vector3.new(0, 3, 0))
			local boardPos = pad + Vector3.new(0, 6, -7)
			local board = part({
				Name = "StationBoard",
				Size = Vector3.new(10, 8, 0.6),
				CFrame = CFrame.lookAt(boardPos, boardPos + Vector3.new(0, 0, 1)),
				Color = Color3.fromRGB(25, 25, 45),
				CanCollide = false,
			})
			tag(board, "Board_OP")
		end

		-- Tier start: big sign + portal back to the story course.
		if i == 1 then
			local signPart = part({
				Name = "TierSign",
				Size = Vector3.new(1, 1, 1),
				Position = pad + Vector3.new(0, 12, 0),
				Transparency = 1,
				CanCollide = false,
			})
			label(signPart, ("TIER %d: %s\nStages %d-%d"):format(tier, tierName, stage, math.min(stage + OP.TierSize - 1, OP.Stages)),
				tierColor:Lerp(Color3.new(1, 1, 1), 0.2), UDim2.fromOffset(420, 110), Vector3.zero)
			signPart:FindFirstChildOfClass("BillboardGui").MaxDistance = 200
			local portal = part({
				Name = "StoryPortal",
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(0.6, 8, 8),
				CFrame = CFrame.new(pad + Vector3.new(-8, 4.5, 0)) * CFrame.Angles(0, math.rad(90), 0),
				Color = Color3.fromRGB(120, 200, 255),
				Material = Enum.Material.ForceField,
				CanCollide = false,
			})
			tag(portal, "StoryPortal")
			label(portal, "BACK TO STORY", Color3.fromRGB(150, 220, 255), nil, Vector3.new(0, 5.5, 0))
		end

		-- Obstacle section to the next stage (or the portal to the next tier).
		if isFinal then
			-- Victory trophy
			part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(4, 3, 3), CFrame = CFrame.new(pad + Vector3.new(0, 2.5, -4)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(255, 200, 40), Material = Enum.Material.Metal, CanCollide = false })
			part({ Shape = Enum.PartType.Ball, Size = Vector3.one * 5, Position = pad + Vector3.new(0, 6, -4), Color = Color3.fromRGB(255, 200, 40), Material = Enum.Material.Metal, CanCollide = false })
		elseif i == OP.TierSize then
			local portal = part({
				Name = "NextTierPortal",
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(0.6, 9, 9),
				CFrame = CFrame.new(pad + Vector3.new(9, 4.5, 0)) * CFrame.Angles(0, 0, 0),
				Color = OP.Tiers[math.min(tier + 1, #OP.Tiers)][2],
				Material = Enum.Material.ForceField,
				CanCollide = false,
			})
			tag(portal, "OPNextTier", { Stage = stage + 1 })
			label(portal, "NEXT TIER: " .. OP.Tiers[math.min(tier + 1, #OP.Tiers)][1], Color3.new(1, 1, 1), UDim2.fromOffset(240, 40), Vector3.new(0, 6, 0))
		else
			OPGen.Section(stage, pad, OPGen.PadPosition(stage + 1).Y - pad.Y, {
				part = part,
				tag = tag,
				coins = coins,
				kills = kills,
				light = light,
				dark = dark,
				color = tierColor,
			})
		end
	end

	-- A few themed floating decorations around the tier.
	local rng = Random.new(tier * 7919)
	local base = OPGen.PadPosition((tier - 1) * OP.TierSize + 1)
	for _ = 1, 45 do
		local z = (rng:NextNumber() < 0.5 and -1 or 1) * rng:NextNumber(30, 160)
		local p = part({
			Shape = rng:NextNumber() < 0.5 and Enum.PartType.Ball or Enum.PartType.Block,
			Size = Vector3.one * rng:NextNumber(4, 18),
			Position = base + Vector3.new(rng:NextNumber(-80, OP.TierSize * OP.Spacing + 80), rng:NextNumber(-60, 90), z),
			Orientation = Vector3.new(rng:NextNumber(0, 360), rng:NextNumber(0, 360), 0),
			Color = (rng:NextNumber() < 0.5 and light or dark),
			Material = rng:NextNumber() < 0.3 and Enum.Material.Neon or Enum.Material.SmoothPlastic,
			Transparency = 0.15,
			CanCollide = false,
			CanTouch = false,
			CanQuery = false,
			CastShadow = false,
		})
		p.Name = "Deco"
	end

	course.Parent = workspace:FindFirstChild("OPObby") or (function()
		local f = Instance.new("Folder")
		f.Name = "OPObby"
		f.Parent = workspace
		return f
	end)()
	return { course, coins, kills }
end

---------------------------------------------------------------- Sections
-- Each section fills the 32 studs between two pads (pads are 8 wide).
-- ctx: helpers + folders; rise = height difference to the next pad.
local SECTIONS = {}

local function at(pad, cx, cy, cz)
	return pad + Vector3.new(cx, cy, cz)
end

-- 1. Hops between shrinking platforms
SECTIONS.Hops = function(rng, pad, rise, d, ctx)
	local count = 3 + math.floor(d * 2 + rng:NextNumber())
	local size = math.max(5 - 2.6 * d, 2.4)
	local step = 32 / (count + 1)
	for j = 1, count do
		local cx = 4 + step * j
		local y = rise * cx / 40 + rng:NextNumber(-1.5, 1.5) * d
		local z = rng:NextNumber(-1, 1) * (1 + 2 * d)
		ctx.part({ Name = "Hop", Size = Vector3.new(size, 1, size), Position = at(pad, cx, y, z), Color = j % 2 == 0 and ctx.light or ctx.dark })
		if j == math.ceil(count / 2) then
			ctx.coin(at(pad, cx, y + 3.5, z))
		end
	end
end

-- 2. Walkway with lava strips
SECTIONS.Strips = function(rng, pad, rise, d, ctx)
	local width = math.max(5 - 2 * d, 2.5)
	ctx.part({ Name = "Walk", Size = Vector3.new(32, 1, width), Position = at(pad, 20, rise / 2, 0), Color = ctx.light })
	local strips = 2 + math.floor(4 * d)
	for j = 1, strips do
		local cx = 4 + 32 * j / (strips + 1)
		ctx.kill(at(pad, cx, rise / 2 + 1, 0), Vector3.new(1.2 + 0.8 * d, 1, width))
	end
	ctx.coin(at(pad, 20, rise / 2 + 3.5, 0))
end

-- 3. Spinning lasers
SECTIONS.Spinner = function(rng, pad, rise, d, ctx)
	ctx.part({ Name = "Walk", Size = Vector3.new(32, 1, 9), Position = at(pad, 20, rise / 2, 0), Color = ctx.light })
	local bars = d > 0.5 and 2 or 1
	for j = 1, bars do
		local cx = bars == 1 and 20 or (j == 1 and 13 or 27)
		local bar = ctx.kill(at(pad, cx, rise / 2 + 1.25, 0), Vector3.new(1, 1.5, 12))
		ctx.tag(bar, "Spinner", { SpinSpeed = (j == 1 and 1 or -1) * (80 + 170 * d) })
	end
	ctx.coin(at(pad, 20, rise / 2 + 6, 0))
end

-- 4. Vanishing platforms
SECTIONS.Fade = function(rng, pad, rise, d, ctx)
	local size = math.max(5 - 1.8 * d, 2.8)
	for j = 1, 4 do
		local cx = 4 + 32 * j / 5
		local p = ctx.part({ Name = "Fade", Size = Vector3.new(size, 1, size), Position = at(pad, cx, rise * cx / 40, rng:NextNumber(-1, 1) * d * 2), Color = ctx.dark })
		ctx.tag(p, "Fade", { FadeTime = math.max(0.8 - 0.55 * d, 0.25), ReturnTime = 2.5 })
	end
	ctx.coin(at(pad, 20, rise / 2 + 3.5, 0))
end

-- 5. Backwards conveyor with sliding blocks
SECTIONS.Conveyor = function(rng, pad, rise, d, ctx)
	local belt = ctx.part({ Name = "Belt", Size = Vector3.new(7, 1, 32), CFrame = CFrame.new(at(pad, 20, rise / 2, 0)) * CFrame.Angles(0, math.rad(90), 0), Color = ctx.dark, Material = Enum.Material.DiamondPlate })
	ctx.tag(belt, "Conveyor", { ConveyorSpeed = 6 + 12 * d })
	local blocks = 2 + math.floor(2 * d)
	for j = 1, blocks do
		local cx = 4 + 32 * j / (blocks + 1)
		local block = ctx.kill(Vector3.zero, Vector3.new(2, 2, 2))
		block.CFrame = CFrame.new(at(pad, cx, rise / 2 + 1.5, 0)) * CFrame.Angles(0, math.rad(90), 0)
		ctx.tag(block, "Slider", { Distance = 2.6, Speed = 0.3 + 0.4 * d, Phase = j * 0.3 })
	end
	ctx.coin(at(pad, 20, rise / 2 + 4.5, 0))
end

-- 6. Laser gates sliding up and down
SECTIONS.Lasers = function(rng, pad, rise, d, ctx)
	ctx.part({ Name = "Walk", Size = Vector3.new(32, 1, 7), Position = at(pad, 20, rise / 2, 0), Color = ctx.light })
	local gates = 3 + math.floor(2 * d)
	for j = 1, gates do
		local cx = 4 + 32 * j / (gates + 1)
		local laser = ctx.kill(Vector3.zero, Vector3.new(1, 0.6, 8))
		laser.Color = Color3.fromRGB(255, 50, 200)
		laser.CFrame = CFrame.new(at(pad, cx, rise / 2 + 4, 0)) * CFrame.Angles(0, 0, math.rad(90))
		ctx.tag(laser, "Slider", { Distance = 3.2, Speed = 0.35 + 0.45 * d, Phase = j * 0.27 })
	end
	ctx.coin(at(pad, 20, rise / 2 + 3.5, 0))
end

-- 7. Jump pad to a high ledge
SECTIONS.JumpPad = function(rng, pad, rise, d, ctx)
	ctx.part({ Name = "Ledge", Size = Vector3.new(8, 1, 6), Position = at(pad, 8, 0, 0), Color = ctx.light })
	local jp = ctx.part({ Name = "JumpPad", Size = Vector3.new(3.5, 0.6, 3.5), Position = at(pad, 10, 0.8, 0), Color = Color3.fromRGB(60, 255, 120), Material = Enum.Material.Neon })
	ctx.tag(jp, "JumpPad", { Power = 80 })
	local w = math.max(8 - 4 * d, 4)
	ctx.part({ Name = "High", Size = Vector3.new(w, 1, 6), Position = at(pad, 21, 12, 0), Color = ctx.dark })
	ctx.part({ Name = "Step", Size = Vector3.new(5, 1, 5), Position = at(pad, 31, 6 + rise / 2, 0), Color = ctx.light })
	ctx.coin(at(pad, 21, 15.5, 0))
end

-- 8. Truss climb
SECTIONS.Truss = function(rng, pad, rise, d, ctx)
	local h = 8 + 2 * math.floor(4 * d)
	ctx.part({ Name = "Base", Size = Vector3.new(8, 1, 6), Position = at(pad, 9, 0, 0), Color = ctx.light })
	ctx.part({ Name = "Truss", Size = Vector3.new(2, h, 2), Position = at(pad, 14, h / 2 + 0.5, 0), Color = Color3.fromRGB(200, 200, 210) }, "TrussPart")
	ctx.part({ Name = "Top", Size = Vector3.new(6, 1, 6), Position = at(pad, 18, h + 0.5, 0), Color = ctx.dark })
	ctx.part({ Name = "Step", Size = Vector3.new(5, 1, 5), Position = at(pad, 29, h / 2 + rise / 2, 0), Color = ctx.light })
	ctx.coin(at(pad, 18, h + 4, 0))
end

-- 9. Narrow zig-zag beams
SECTIONS.Beams = function(rng, pad, rise, d, ctx)
	local width = math.max(2 - 1 * d, 1.1)
	for j = 1, 3 do
		local cx = 4 + 32 * j / 4
		local z = ({ 0, 3, -3 })[j]
		ctx.part({ Name = "Beam", Size = Vector3.new(8, 1, width), Position = at(pad, cx, rise * cx / 40, z), Color = j % 2 == 0 and ctx.light or ctx.dark })
	end
	ctx.coin(at(pad, 20, rise / 2 + 3.5, 3))
end

-- 10. Grapple gap: no floor - swing across with the Grappling Hook
SECTIONS.Grapple = function(rng, pad, rise, d, ctx)
	ctx.part({ Name = "Ledge", Size = Vector3.new(4, 1, 6), Position = at(pad, 6, 0, 0), Color = ctx.light })
	for j, cx in ipairs({ 14, 25 }) do
		local point = ctx.part({
			Name = "GrapplePoint",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * 2.5,
			Position = at(pad, cx, 11 + j, 0),
			Color = Color3.fromRGB(80, 255, 255),
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
		ctx.tag(point, "GrapplePoint")
	end
	ctx.part({ Name = "Landing", Size = Vector3.new(6, 1, 6), Position = at(pad, 33, rise, 0), Color = ctx.dark })
	ctx.coin(at(pad, 20, 9, 0))
end

local ORDER = { "Hops", "Strips", "Spinner", "Fade", "Conveyor", "Lasers", "JumpPad", "Truss", "Beams", "Grapple" }
local UNLOCK = { Truss = 10, Grapple = 30, Lasers = 20, Conveyor = 15 } -- earliest stage for each

local function choicesFor(stage)
	local choices = {}
	for _, name in ipairs(ORDER) do
		if stage >= (UNLOCK[name] or 0) then
			table.insert(choices, name)
		end
	end
	return choices
end

-- The section type a stage would get before de-duplication (uses the stage's own RNG).
function OPGen.BasePick(stage, rng)
	local choices = choicesFor(stage)
	rng = rng or Random.new(stage * 104729)
	return choices[rng:NextInteger(1, #choices)]
end

function OPGen.Section(stage, pad, rise, ctx)
	local rng = Random.new(stage * 104729)
	local tier = OPGen.TierOf(stage)
	local within = (stage - (tier - 1) * OP.TierSize - 1) / OP.TierSize
	local d = math.clamp((tier - 1) / (#OP.Tiers - 1) + within * 0.05, 0, 1)

	ctx.coin = function(position)
		local coin = Instance.new("Part")
		coin.Name = "Coin"
		coin.Shape = Enum.PartType.Cylinder
		coin.Size = Vector3.new(0.5, 3, 3)
		coin.Position = position
		coin.Color = Color3.fromRGB(255, 205, 40)
		coin.Material = Enum.Material.Neon
		coin.Anchored = true
		coin.CanCollide = false
		coin.CastShadow = false
		coin.Parent = ctx.coins
		return coin
	end
	ctx.kill = function(position, size)
		return ctx.part({
			Name = "Lava",
			Size = size,
			Position = position,
			Color = Color3.fromRGB(255, 40, 40),
			Material = Enum.Material.Neon,
		}, "Part", ctx.kills)
	end

	local pick = OPGen.BasePick(stage, rng)
	-- Avoid repeating the previous stage's section type.
	if stage > 1 and pick == OPGen.BasePick(stage - 1) then
		local choices = choicesFor(stage)
		pick = choices[(table.find(choices, pick) % #choices) + 1]
	end
	SECTIONS[pick](rng, pad, rise, d, ctx)
end

return OPGen
]==])
add(f_server, "Script", "OPObby", [==[
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
		MaxStage = 1, -- highest stage ever reached (stage select)
		Unlocks = {}, -- [unlockName] = true, from Config.Milestones
		Draw = nil, -- { Rarity = "Rare", Expires = os.time(), Nickname = "" }
		LastDraw = 0,
		RedeemedCodes = {}, -- [CODE] = true
		GroupRewardClaimed = false,
		Rebirths = 0,
		JumpPower = 0, -- grows +1 every second online
		OPStage = 1, -- progress in the 1000-stage OP Obby
		Mode = "Main", -- "Main" (story course) or "OP"
		SeenIntro = false,
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
	leaderstats.OP.Value = profile.Data.OPStage
	player:SetAttribute("Mode", profile.Data.Mode)
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

-- The player's current Daily Draw rarity table (from Config.DrawRarities), or nil.
function PlayerData.ActiveDraw(player)
	local data = PlayerData.Get(player)
	local draw = data and data.Draw
	if not draw or os.time() >= (draw.Expires or 0) then
		return nil
	end
	for _, rarity in ipairs(Config.DrawRarities) do
		if rarity.Name == draw.Rarity then
			return rarity
		end
	end
	return nil
end

function PlayerData.Multiplier(player)
	local data, session = PlayerData.Get(player), PlayerData.Session(player)
	if not data then
		return 1
	end
	local mult = math.min(1 + data.Wins * Config.WinMultiplierStep, Config.MaxWinMultiplier)
	mult *= 1 + (data.Rebirths or 0) * Config.RebirthMultiplierStep
	if session.Passes.DoubleCoins then
		mult *= 2
	end
	if session.Passes.VIP then
		mult *= Config.VIPMultiplier
	end
	local now = workspace:GetServerTimeNow()
	-- Temporary boosts: NPC and Boost Station don't stack with each other (the bigger one wins)...
	local temp = 1
	if (session.BoostUntil or 0) > now then
		temp = math.max(temp, Config.NPCBoostMultiplier)
	end
	if (session.StationBoostUntil or 0) > now then
		temp = math.max(temp, Config.StationBoostMultiplier)
	end
	mult *= temp
	-- ...but the friend-invite boost and co-op tether bonus do.
	if (session.InviteBoostUntil or 0) > now then
		mult *= Config.InviteBoostMultiplier
	end
	if session.TetheredWith then
		mult *= Config.TetherMultiplier
	end
	local rarity = PlayerData.ActiveDraw(player)
	if rarity and rarity.CoinBoost then
		mult *= rarity.CoinBoost
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
		MaxStage = data.MaxStage,
		Unlocks = data.Unlocks,
		Draw = PlayerData.ActiveDraw(player) and data.Draw or nil,
		DrawSecondsLeft = PlayerData.ActiveDraw(player) and (data.Draw.Expires - os.time()) or 0,
		NextDrawIn = math.max(0, Config.DrawCooldownHours * 3600 - (os.time() - data.LastDraw)),
		BoostUntil = session.BoostUntil,
		RedeemedCodes = data.RedeemedCodes,
		GroupRewardClaimed = data.GroupRewardClaimed,
		GroupId = Config.GroupId,
		OPStage = data.OPStage,
		Mode = data.Mode,
		SeenIntro = data.SeenIntro,
		StationBoostUntil = session.StationBoostUntil,
		InviteBoostUntil = session.InviteBoostUntil,
		Tethered = session.TetheredWith ~= nil,
		Rebirths = data.Rebirths,
		RebirthCost = Config.RebirthCost * ((data.Rebirths or 0) + 1),
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
	data.MaxStage = math.max(data.MaxStage or 1, stage)
	PlayerData.Sync(player)
end

function PlayerData.SetOPStage(player, stage)
	local data = PlayerData.Get(player)
	if data then
		data.OPStage = stage
		PlayerData.Sync(player)
	end
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
	for _, name in ipairs({ "Stage", "OP", "Wins", "Coins" }) do
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
add(f_server, "Script", "Progression", [==[
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

---------------------------------------------------------------- Promo codes
Remotes.RedeemCode.OnServerInvoke = function(player, code)
	local data = PlayerData.Get(player)
	if not data or type(code) ~= "string" then
		return false, "Try again"
	end
	code = code:upper():gsub("%s", "")
	local reward = Config.Codes[code]
	if not reward then
		return false, "That code doesn't exist (yet!)"
	end
	if data.RedeemedCodes[code] then
		return false, "You already used this code"
	end
	data.RedeemedCodes[code] = true
	PlayerData.AddCoins(player, reward, false)
	return true, ("Code redeemed: +%d coins!"):format(reward)
end

---------------------------------------------------------------- Group reward
Remotes.ClaimGroup.OnServerInvoke = function(player)
	local data = PlayerData.Get(player)
	if not data or Config.GroupId == 0 then
		return false, "No group set up yet"
	end
	if data.GroupRewardClaimed then
		return false, "Already claimed - thanks for joining!"
	end
	local ok, inGroup = pcall(player.IsInGroup, player, Config.GroupId)
	if not ok or not inGroup then
		return false, "Join our Roblox group first, then rejoin the game!"
	end
	data.GroupRewardClaimed = true
	PlayerData.AddCoins(player, Config.GroupReward, false)
	return true, ("Thanks for joining the group! +%d coins"):format(Config.GroupReward)
end

---------------------------------------------------------------- Friend invites (x3 coins)
-- Detection uses Roblox's referral data: when a friend joins through your invite
-- (the INVITE button / invite menu / referral link), their join data names you as the referrer.
-- Both of you then get x3 coins for Config.InviteBoostMinutes, plus Config.InviteReward coins.
-- If you'd already left, the reward waits for you in a DataStore and is given when you return.
local DataStoreService = game:GetService("DataStoreService")
local okPending, pendingStore = pcall(DataStoreService.GetDataStore, DataStoreService, "PendingReferrals_v1")
if not okPending then
	pendingStore = nil
end

local function giveInviteBoost(player, message)
	local session = PlayerData.Session(player)
	if not session then
		return
	end
	session.InviteBoostUntil = math.max(session.InviteBoostUntil or 0, workspace:GetServerTimeNow()) + Config.InviteBoostMinutes * 60
	PlayerData.AddCoins(player, Config.InviteReward, false)
	Remotes.Notify:FireClient(player, message, "gold")
	Remotes.Fx:FireClient(player, "Confetti")
end

local function rewardReferral(newPlayer)
	local ok, joinData = pcall(newPlayer.GetJoinData, newPlayer)
	local referrerId = ok and joinData and joinData.ReferredByPlayerId
	if not referrerId or referrerId == 0 or referrerId == newPlayer.UserId then
		return
	end
	local newData = PlayerData.WaitFor(newPlayer)
	if not newData then
		return
	end

	-- The friend who joined gets the boost once.
	if not newData.JoinedViaInvite then
		newData.JoinedViaInvite = true
		giveInviteBoost(newPlayer, ("You joined from a friend's invite: x%d COINS for %d minutes!"):format(Config.InviteBoostMultiplier, Config.InviteBoostMinutes))
	end

	-- The inviter: rewarded now if they're here, otherwise saved for later (once per friend).
	local referrer = Players:GetPlayerByUserId(referrerId)
	local referrerData = referrer and PlayerData.WaitFor(referrer)
	local key = tostring(newPlayer.UserId)
	if referrerData then
		if not referrerData.RewardedReferrals[key] then
			referrerData.RewardedReferrals[key] = true
			giveInviteBoost(referrer, ("%s joined from your invite! x%d COINS for %d minutes!"):format(newPlayer.DisplayName, Config.InviteBoostMultiplier, Config.InviteBoostMinutes))
		end
	elseif pendingStore then
		pcall(pendingStore.UpdateAsync, pendingStore, "Ref_" .. referrerId, function(list)
			list = list or {}
			if not table.find(list, key) and #list < 50 then
				table.insert(list, key)
			end
			return list
		end)
	end
end

-- Rewards for invites that joined while you were offline.
local function claimPending(player)
	if not pendingStore then
		return
	end
	local data = PlayerData.WaitFor(player)
	if not data then
		return
	end
	local claimed = {}
	pcall(pendingStore.UpdateAsync, pendingStore, "Ref_" .. player.UserId, function(list)
		for _, key in ipairs(list or {}) do
			if not data.RewardedReferrals[key] then
				data.RewardedReferrals[key] = true
				table.insert(claimed, key)
			end
		end
		return {}
	end)
	if #claimed > 0 then
		giveInviteBoost(player, ("%d friend(s) joined from your invites while you were away! x%d COINS for %d minutes!"):format(#claimed, Config.InviteBoostMultiplier, Config.InviteBoostMinutes))
	end
end

---------------------------------------------------------------- First 60 seconds: instant reward
-- New players get a welcome badge + coins right away (no tutorial, no reading).
local function welcome(player)
	Badges.Award(player, "Welcome")
	local data = PlayerData.WaitFor(player)
	if data and not data.WelcomeGiven then
		data.WelcomeGiven = true
		task.wait(3)
		if player.Parent then
			PlayerData.AddCoins(player, Config.WelcomeCoins or 50, false)
			Remotes.Notify:FireClient(player, ("WELCOME GIFT: +%d coins! Grab more coins ahead!"):format(Config.WelcomeCoins or 50), "gold")
			Remotes.Fx:FireClient(player, "Confetti")
		end
	end
end

local function onPlayerAdded(player)
	task.spawn(welcome, player)
	task.spawn(rewardReferral, player)
	task.spawn(claimPending, player)
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

-- Gary's Lair: volcanoes with glowing craters, lava falls, floating basalt and Gary banners.
local function volcano(base, height, width)
	local rock = Color3.fromRGB(55, 45, 50)
	local layers = 5
	for i = 0, layers - 1 do
		local w = width * (1 - i / (layers + 1))
		pillar(base + Vector3.new(0, (i + 0.5) * height / layers, 0), height / layers, w, rock, Enum.Material.Basalt)
	end
	local top = base + Vector3.new(0, height, 0)
	pillar(top + Vector3.new(0, 0.3, 0), 0.8, width * 0.25, Color3.fromRGB(255, 110, 20), Enum.Material.Neon)
	-- lava fall down one side
	deco({
		Size = Vector3.new(1.2, height * 0.9, width * 0.08),
		Position = top + Vector3.new(width * 0.22, -height * 0.45, 0),
		Color = Color3.fromRGB(255, 90, 20),
		Material = Enum.Material.Neon,
	})
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 120, 40)
	light.Range = 40
	light.Brightness = 3
	light.Parent = deco({ Size = Vector3.one, Position = top + Vector3.new(0, 3, 0), Transparency = 1 })
end

local function buildLair(x0, x1, baseY)
	local density = math.clamp((x1 - x0) / 600, 1, 2)
	for _ = 1, math.floor(10 * density) do
		volcano(Vector3.new(range(x0 - 60, x1 + 60), baseY - 31, side(60, 400)), range(50, 140), range(40, 90))
	end
	for _ = 1, math.floor(30 * density) do
		ball(Vector3.new(range(x0, x1), baseY + range(-25, 30), side(22, 90)), range(3, 10), Color3.fromRGB(range(50, 80), range(40, 55), range(45, 60)), Enum.Material.Basalt)
	end
	-- Ember sparks hanging in the air
	for _ = 1, math.floor(60 * density) do
		ball(Vector3.new(range(x0, x1), baseY + range(-20, 60), side(15, 160)), range(0.4, 1), Color3.fromRGB(255, range(90, 170), 30), Enum.Material.Neon)
	end
	-- Gary's banners
	for _ = 1, math.floor(8 * density) do
		local p = Vector3.new(range(x0, x1), baseY - 4, side(26, 50))
		pillar(p + Vector3.new(0, 12, 0), 24, 0.8, Color3.fromRGB(40, 30, 30), Enum.Material.Metal)
		deco({ Size = Vector3.new(0.3, 9, 6), Position = p + Vector3.new(0, 18, 3.2 * (p.Z > 0 and -1 or 1)), Color = Color3.fromRGB(110, 40, 150), Material = Enum.Material.Fabric })
		ball(p + Vector3.new(0, 19, 3.4 * (p.Z > 0 and -1 or 1)), 3, Color3.fromRGB(255, 200, 40), Enum.Material.Neon)
	end
end

---------------------------------------------------------------- entry point
-- Optional hero landmarks: import 3D models (e.g. the Higgsfield GLBs) into
-- ServerStorage > Landmarks named "Sky", "Candy" and "Space"; they get placed and scaled here.
local function placeLandmark(name, position, targetSize, yaw)
	local storage = game:GetService("ServerStorage"):FindFirstChild("Landmarks")
	local template = storage and storage:FindFirstChild(name)
	if not template then
		return
	end
	local model = template:Clone()
	if model:IsA("BasePart") then
		local wrapper = Instance.new("Model")
		model.Parent = wrapper
		model = wrapper
	end
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
			d.CanTouch = false
			d.CanQuery = false
		end
	end
	local _, size = model:GetBoundingBox()
	local largest = math.max(size.X, size.Y, size.Z)
	if largest > 0 then
		model:ScaleTo(model:GetScale() * targetSize / largest)
	end
	model:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0))
	model.Parent = folder
end

local function buildHub(center, diameter, baseY)
	island(center, baseY - 0.55, diameter, 2, true)
	local padTop = baseY - 0.05
	-- Fountain with glowing water.
	pillar(center + Vector3.new(0, padTop - baseY + 1, 8), 2, 14, Color3.fromRGB(240, 240, 250), Enum.Material.Marble)
	pillar(center + Vector3.new(0, padTop - baseY + 1.6, 8), 1.4, 12, Color3.fromRGB(110, 200, 255), Enum.Material.Neon)
	pillar(center + Vector3.new(0, padTop - baseY + 4, 8), 5, 2, Color3.fromRGB(240, 240, 250), Enum.Material.Marble)
	ball(center + Vector3.new(0, padTop - baseY + 7, 8), 3, Color3.fromRGB(255, 205, 40), Enum.Material.Neon)
	-- Golden lamp posts around the edge.
	for i = 0, 7 do
		local a = math.pi * 2 * i / 8
		local p = center + Vector3.new(math.cos(a) * (diameter / 2 - 4), padTop - baseY, math.sin(a) * (diameter / 2 - 4))
		pillar(p + Vector3.new(0, 4, 0), 8, 0.6, Color3.fromRGB(60, 50, 40), Enum.Material.Metal)
		ball(p + Vector3.new(0, 8.5, 0), 1.6, Color3.fromRGB(255, 230, 150), Enum.Material.Neon)
	end
end

-- Greedy Gary, the villain: a giant goblin with a top hat, monocle and a sack of stolen coins.
-- His speech bubble (tag "GaryTaunt") is updated by Villain.server.
local function gary(position, scale, facing)
	local cf = CFrame.lookAt(position, position + facing)
	local function at(x, y, z)
		return (cf * CFrame.new(x * scale, y * scale, -z * scale)).Position
	end
	local green = Color3.fromRGB(110, 190, 70)
	local suit = Color3.fromRGB(110, 40, 150)
	pillar(at(0, 4, 0), 8 * scale, 7 * scale, suit) -- body
	ball(at(0, 10.5, 0), 8 * scale, green) -- head
	for _, side in ipairs({ -1, 1 }) do
		ball(at(side * 4.6, 11.5, 0), 2.6 * scale, green) -- ears
		ball(at(side * 1.6, 11.6, 3.4), 2 * scale, Color3.new(1, 1, 1)) -- eyes
		ball(at(side * 1.6, 11.6, 4.2), 0.9 * scale, Color3.new(0, 0, 0))
		ball(at(side * 4.2, 3.5, 1.5), 2.4 * scale, green) -- hands
	end
	deco({ -- monocle
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.3 * scale, 2.6 * scale, 2.6 * scale),
		CFrame = CFrame.new(at(1.6, 11.6, 4.5)) * cf.Rotation * CFrame.Angles(0, math.rad(90), 0),
		Color = Color3.fromRGB(255, 200, 40),
		Material = Enum.Material.Metal,
		Transparency = 0.3,
	})
	deco({ Size = Vector3.new(4.2, 0.7, 0.4) * scale, CFrame = CFrame.new(at(0, 9, 3.9)) * cf.Rotation, Color = Color3.fromRGB(40, 10, 10) }) -- grin
	pillar(at(0, 14.6, 0), 0.6 * scale, 8 * scale, Color3.fromRGB(20, 20, 25)) -- hat brim
	pillar(at(0, 17, 0), 4.5 * scale, 5 * scale, Color3.fromRGB(20, 20, 25)) -- hat
	pillar(at(0, 15.6, 0), 0.8 * scale, 5.1 * scale, Color3.fromRGB(200, 30, 60)) -- hat band
	ball(at(5.5, 4, -1), 6 * scale, Color3.fromRGB(150, 110, 60)) -- coin sack
	for i = 1, 5 do
		ball(at(5.5 + math.cos(i) * 1.5, 7 + i * 0.2, -1 + math.sin(i) * 1.5), 1.2 * scale, Color3.fromRGB(255, 205, 40), Enum.Material.Neon)
	end
	local anchor = deco({ Size = Vector3.one, Position = at(0, 21, 0), Transparency = 1 })
	local gui = Instance.new("BillboardGui")
	gui.Name = "GaryTaunt"
	gui.Size = UDim2.fromOffset(360, 90)
	gui.MaxDistance = 400
	gui.LightInfluence = 0
	local bubble = Instance.new("TextLabel")
	bubble.Size = UDim2.fromScale(1, 1)
	bubble.BackgroundColor3 = Color3.new(1, 1, 1)
	bubble.Font = Enum.Font.FredokaOne
	bubble.TextScaled = true
	bubble.TextColor3 = Color3.fromRGB(110, 40, 150)
	bubble.Text = "GREEDY GARY: You'll never escape!"
	bubble.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = bubble
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = bubble
	gui.Parent = anchor
	game:GetService("CollectionService"):AddTag(gui, "GaryTaunt")
end

-- opts: { Stages, Spacing, BaseY, Zones (Config.Zones), ZoneIndex = function(stage), HubCenter, HubDiameter }
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

	-- Spawn plaza: a big island with room for the Hall of Fame wall, podium, portal and NPCs.
	local LOBBY = Vector3.new(-44, 0, 0)
	island(LOBBY, baseY - 0.55, 100, 1, true)
	for _, offset in ipairs({
		Vector3.new(-14, 0, -42), Vector3.new(-14, 0, 42), Vector3.new(-40, 0, -46), Vector3.new(-40, 0, 46),
		Vector3.new(-64, 0, -40), Vector3.new(-64, 0, 40), Vector3.new(-2, 0, -28), Vector3.new(-2, 0, 28),
	}) do
		tree(Vector3.new(offset.X, padTop - 0.6, offset.Z))
	end
	-- Title sign above the Hall of Fame wall.
	sign(Vector3.new(-85.5, baseY + 36, 0), Vector3.new(1, 0, 0), Vector3.new(52, 11, 1), "ESCAPE GREEDY GARY!", opts.Stages .. " STORY STAGES  •  1000-STAGE OP TOWER  •  CO-OP", Color3.fromRGB(255, 215, 60))

	-- Everything built so far (lobby, checkpoint islands) survives the plaza cleanup below.
	for _, p in ipairs(folder:GetChildren()) do
		p:SetAttribute("Keep", true)
	end

	-- World scenery.
	local zones = opts.Zones
	local builders = { buildSky, buildCandy, buildSpace, buildLair }
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
	if zones[4] then
		gate((zones[4].FirstStage - 1) * spacing - 7, baseY - 1, 17, { Color3.fromRGB(255, 90, 20), Color3.fromRGB(40, 30, 30) }, Enum.Material.Neon)
	end

	-- Keep the spawn plaza clear of world decoration.
	for _, p in ipairs(folder:GetChildren()) do
		local offset = p.Position - Vector3.new(LOBBY.X, baseY, 0)
		if Vector2.new(offset.X, offset.Z).Magnitude < 62 and offset.Y > -40 and offset.Y < 60 and not p:GetAttribute("Keep") then
			p:Destroy()
		end
	end

	-- Clear decoration that would poke through the hub island, then build the hub.
	if opts.HubCenter then
		local hub = opts.HubCenter
		local clearRadius = opts.HubDiameter / 2 + 14
		for _, p in ipairs(folder:GetChildren()) do
			local offset = p.Position - hub
			if Vector2.new(offset.X, offset.Z).Magnitude < clearRadius and offset.Y > -40 then
				p:Destroy()
			end
		end
		buildHub(hub, opts.HubDiameter, baseY)
	end

	-- Hero landmarks (only if you've imported them into ServerStorage > Landmarks).
	placeLandmark("Sky", Vector3.new(4 * spacing, baseY + 10, -140), 120, 30)
	if zones[2] then
		placeLandmark("Candy", Vector3.new(((zones[2].FirstStage - 1) + 4) * spacing, baseY, 150), 130, 200)
	end
	if zones[3] then
		placeLandmark("Space", Vector3.new(((zones[3].FirstStage - 1) + 8) * spacing, baseY + 40, -170), 160, 0)
	end

	-- Greedy Gary looms over the lobby, the hub and the finish.
	gary(Vector3.new(-128, baseY - 10, 0), 2.8, Vector3.new(1, 0, 0))
	if opts.HubCenter then
		gary(opts.HubCenter + Vector3.new(0, 30, -36), 1.6, Vector3.new(0, 0, 1))
	end
	gary(Vector3.new((opts.Stages - 1) * spacing + 40, baseY - 4, -10), 1.8, Vector3.new(-1, 0, 0.3).Unit)

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

-- A glowing ring floating above the head.
local function addHalo(character, item)
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end
	local halo = Instance.new("Part")
	halo:SetAttribute("Cosmetic", true)
	halo.Name = "Halo"
	halo.Shape = Enum.PartType.Cylinder
	halo.Size = Vector3.new(0.2, 2.4, 2.4)
	halo.Color = item.Color
	halo.Material = Enum.Material.Neon
	halo.Transparency = 0.15
	halo.CanCollide = false
	halo.CanQuery = false
	halo.CanTouch = false
	halo.Massless = true
	halo.CFrame = head.CFrame * CFrame.new(0, 1.6, 0) * CFrame.Angles(0, 0, math.rad(90))
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = head
	weld.Part1 = halo
	weld.Parent = halo
	local light = Instance.new("PointLight")
	light.Color = item.Color
	light.Range = 8
	light.Parent = halo
	halo.Parent = character
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
			elseif item.Slot == "Halo" then
				addHalo(character, item)
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

	if item.UnlockText and not data.Owned[itemId] then
		return false, item.UnlockText .. " to unlock this!"
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
add(f_server, "Script", "Teamwork", [==[
-- Co-op: tether with a friend (both earn Config.TetherMultiplier coins while tethered),
-- and the Teamwork Vault in the hub, which only opens while two players stand on its plates.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

---------------------------------------------------------------- Tether
local pending = {} -- [requester] = { Target = Player, At = os.clock() }
local ropes = {} -- [Player] = RopeConstraint (stored on both players of a pair)

local function partnerOf(player)
	local session = PlayerData.Session(player)
	return session and session.TetheredWith and Players:GetPlayerByUserId(session.TetheredWith)
end

local function removeRope(player)
	local rope = ropes[player]
	if rope then
		rope:Destroy()
	end
	ropes[player] = nil
end

local function attachRope(a, b)
	removeRope(a)
	removeRope(b)
	local rootA = a.Character and a.Character:FindFirstChild("HumanoidRootPart")
	local rootB = b.Character and b.Character:FindFirstChild("HumanoidRootPart")
	if not rootA or not rootB then
		return
	end
	local att0 = Instance.new("Attachment")
	att0.Name = "TetherAttachment"
	att0.Parent = rootA
	local att1 = Instance.new("Attachment")
	att1.Name = "TetherAttachment"
	att1.Parent = rootB
	local rope = Instance.new("RopeConstraint")
	rope.Name = "Tether"
	rope.Attachment0 = att0
	rope.Attachment1 = att1
	rope.Length = Config.TetherLength
	rope.Visible = true
	rope.Thickness = 0.25
	rope.Color = BrickColor.new("Hot pink")
	rope.Parent = rootA
	rope.Destroying:Connect(function()
		att0:Destroy()
		att1:Destroy()
	end)
	ropes[a], ropes[b] = rope, rope
end

local function untether(player, reason)
	local partner = partnerOf(player)
	for _, p in ipairs({ player, partner }) do
		if p then
			removeRope(p)
			local session = PlayerData.Session(p)
			if session then
				session.TetheredWith = nil
				p:SetAttribute("TetheredWith", nil)
				PlayerData.Sync(p)
				if reason then
					Remotes.Notify:FireClient(p, reason, "bad")
				end
			end
		end
	end
end

local function tether(a, b)
	untether(a)
	untether(b)
	local sa, sb = PlayerData.Session(a), PlayerData.Session(b)
	if not sa or not sb then
		return
	end
	sa.TetheredWith, sb.TetheredWith = b.UserId, a.UserId
	a:SetAttribute("TetheredWith", b.DisplayName)
	b:SetAttribute("TetheredWith", a.DisplayName)
	attachRope(a, b)
	PlayerData.Sync(a)
	PlayerData.Sync(b)
	for _, p in ipairs({ a, b }) do
		Remotes.Notify:FireClient(p, ("TEAMED UP! x%s coins while you stay together."):format(tostring(Config.TetherMultiplier)), "gold")
		Remotes.Fx:FireClient(p, "Confetti")
	end
end

local function addPrompt(player, character)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not root then
		return
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "TeamUpPrompt"
	prompt.ActionText = "Team Up"
	prompt.ObjectText = player.DisplayName
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = root
	prompt.Triggered:Connect(function(requester)
		if requester == player then
			return
		end
		-- The target already asked the requester: that's a yes from both sides.
		local theirs = pending[player]
		if theirs and theirs.Target == requester and os.clock() - theirs.At < 30 then
			pending[player] = nil
			tether(requester, player)
			return
		end
		pending[requester] = { Target = player, At = os.clock() }
		Remotes.Notify:FireClient(requester, ("Request sent to %s!"):format(player.DisplayName), "good")
		Remotes.Notify:FireClient(player, ("%s wants to TEAM UP! Hold E on them to accept."):format(requester.DisplayName), "gold")
	end)
	-- Re-attach the rope after a respawn.
	local partner = partnerOf(player)
	if partner and partner.Character then
		attachRope(player, partner)
	end
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		addPrompt(player, character)
	end)
	if player.Character then
		task.spawn(addPrompt, player, player.Character)
	end
end
Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
Players.PlayerRemoving:Connect(function(player)
	untether(player, "Your teammate left.")
	pending[player] = nil
end)
Remotes.Untether.OnServerEvent:Connect(function(player)
	untether(player, "Tether removed.")
end)

-- Break the tether if teammates end up far apart (different modes, teleports).
task.spawn(function()
	while true do
		task.wait(2)
		for _, player in ipairs(Players:GetPlayers()) do
			local partner = partnerOf(player)
			local a = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local b = partner and partner.Character and partner.Character:FindFirstChild("HumanoidRootPart")
			if partner and a and b and (a.Position - b.Position).Magnitude > 120 then
				untether(player, "Tether snapped - you got too far apart!")
			end
		end
	end
end)

---------------------------------------------------------------- Teamwork Vault
local vaultClaims = {} -- [Player] = os.clock()

local function playersOn(plate)
	local found = {}
	local parts = workspace:GetPartBoundsInBox(plate.CFrame * CFrame.new(0, 3, 0), plate.Size + Vector3.new(0, 6, 0))
	for _, part in ipairs(parts) do
		local player = Players:GetPlayerFromCharacter(part.Parent)
		if player then
			found[player] = true
		end
	end
	return found
end

task.spawn(function()
	while true do
		task.wait(0.3)
		local plates = CollectionService:GetTagged("VaultPlate")
		local door = CollectionService:GetTagged("VaultDoor")[1]
		if #plates >= 2 and door then
			local onA, onB = playersOn(plates[1]), playersOn(plates[2])
			local open = false
			for a in pairs(onA) do
				for b in pairs(onB) do
					if a ~= b then
						open = true
					end
				end
			end
			for _, plate in ipairs(plates) do
				plate.Color = next(playersOn(plate)) and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 80, 80)
			end
			if open and door.CanCollide then
				door.CanCollide = false
				door.Transparency = 0.85
				task.delay(10, function()
					door.CanCollide = true
					door.Transparency = 0.3
				end)
			end
		end
	end
end)

local function hookChest(chest)
	chest.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then
			return
		end
		local last = vaultClaims[player]
		if last and os.clock() - last < Config.VaultCooldownMinutes * 60 then
			return
		end
		vaultClaims[player] = os.clock()
		local amount = PlayerData.AddCoins(player, Config.VaultReward, true)
		Remotes.Notify:FireClient(player, ("TEAMWORK VAULT: +%d coins!"):format(amount), "gold")
		Remotes.Fx:FireClient(player, "Confetti")
	end)
end
for _, chest in ipairs(CollectionService:GetTagged("VaultChest")) do
	hookChest(chest)
end
CollectionService:GetInstanceAddedSignal("VaultChest"):Connect(hookChest)
]==])
add(f_server, "Script", "Villain", [==[
-- Greedy Gary's speech bubbles cycle through taunts, and first-time players get a 3-second
-- story intro (no reading required to start playing).
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

local function onPlayerAdded(player)
	local data = PlayerData.WaitFor(player)
	if data and not data.SeenIntro then
		data.SeenIntro = true
		task.wait(1.5)
		Remotes.Fx:FireClient(player, "Intro", Config.Intro)
	end
end
Players.PlayerAdded:Connect(function(player)
	task.spawn(onPlayerAdded, player)
end)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

local index = 0
while true do
	task.wait(6)
	index = index % #Config.VillainTaunts + 1
	for _, gui in ipairs(CollectionService:GetTagged("GaryTaunt")) do
		local label = gui:FindFirstChildOfClass("TextLabel")
		if label then
			label.Text = Config.VillainName:upper() .. ": " .. Config.VillainTaunts[index]
		end
	end
end
]==])
print("Part 1 of 2 installed - now run part 2!")
