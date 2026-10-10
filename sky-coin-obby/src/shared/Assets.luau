-- YOUR ROBLOX IDS GO HERE. The installer keeps this file when you update the game,
-- so anything you paste here is safe.
--   Images / sounds / music:  "rbxassetid://1234567890"  ("rbxassetid://0" = not set yet)
--   Passes / products / badges: plain numbers (0 = not set yet)
local Assets = {}

-- Robux items. Create them on the Creator Hub, then paste the ids here (0 = hidden).
Assets.GamePasses = {
	DoubleCoins = 2025200302, -- 2x coins forever
	VIP = 2027162312, -- 1.5x coins, VIP trail, [VIP] chat tag
	RocketLauncher = 2026628307, -- rocket tool: blast off where you look
	DoubleJump = 2026136310, -- 1 extra mid-air jump
	TripleJump = 2025812309, -- 2 extra mid-air jumps
	SpeedCoil = 2025584314, -- hold to run 60% faster
	GravityCoil = 2026400306, -- hold to float
}
Assets.Products = {
	SkipStage = 3717552827, -- skip the current stage
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
