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
	-- Every 4 tiers the tower changes biome (look, sky, sea and scenery).
	TiersPerBiome = 4,
	Biomes = {
		{ Name = "RAINBOW MEADOWS", Look = "SKY ISLANDS", ClockTime = 14, Sea = "Sky" },
		{ Name = "INFERNO FORGE", Look = "GARY'S LAIR", ClockTime = 18.6, Sea = "Lair" },
		{ Name = "FROZEN PEAKS", Look = "FROZEN PEAKS", ClockTime = 8, Sea = "Space" },
		{ Name = "NEON CITY", Look = "OUTER SPACE", ClockTime = 0, Sea = "Space" },
		{ Name = "GARY'S GOLDEN VAULT", Look = "GOLDEN VAULT", ClockTime = 17, Sea = "Sky" },
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
Config.Floors = Assets.Floors or {}
Config.Portals = Assets.Portals or {}
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
