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
