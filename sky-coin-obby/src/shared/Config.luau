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
Config.Stages = 40
Config.HubStage = 20 -- the central hub island (dashboard + NPCs) hangs off this checkpoint

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

-- Free rewards for reaching stages for the first time.
Config.Milestones = {
	{ Stage = 10, Unlock = "SpringBoots", Message = "UNLOCKED: Spring Boots - free Double Jump!" },
	{ Stage = 20, Unlock = "CometTrail", Message = "UNLOCKED: Comet Trail - equip it in the Shop!" },
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
