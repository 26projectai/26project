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
