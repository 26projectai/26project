-- Everything sold in the cosmetic shop.
-- Slot: "Trail", "Aura", "Halo", "Hat", "Back" or "Pet" (a player can equip one of each).
-- Stage / OPStage: you must have reached that story / OP stage before you can buy it.
-- CoinBoost (pets): extra coins while equipped, e.g. 0.1 = +10%.
-- RequiresVIP: only VIP game pass owners can get it.
-- Icons come from Assets.ItemIcons; without one the card shows the Emoji.
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

local function cs(...)
	local colors = { ... }
	local points = {}
	for i, color in ipairs(colors) do
		table.insert(points, ColorSequenceKeypoint.new((i - 1) / math.max(#colors - 1, 1), color))
	end
	if #points == 1 then
		table.insert(points, ColorSequenceKeypoint.new(1, colors[1]))
	end
	return ColorSequence.new(points)
end
local rgb = Color3.fromRGB

-- More items, unlocked as you climb. Prices rise with the stage they unlock at.
local MORE = {
	-- Trails
	{ Id = "CandyTrail", Name = "Candy Cane Trail", Slot = "Trail", Price = 400, Stage = 26, Emoji = "🍭", Color = cs(rgb(255, 255, 255), rgb(255, 60, 90), rgb(255, 255, 255), rgb(255, 60, 90)) },
	{ Id = "StarlightTrail", Name = "Starlight Trail", Slot = "Trail", Price = 800, Stage = 51, Emoji = "🌠", Color = cs(rgb(255, 255, 200), rgb(140, 120, 255), rgb(20, 10, 60)) },
	{ Id = "MagmaTrail", Name = "Magma Trail", Slot = "Trail", Price = 1200, Stage = 76, Emoji = "🌋", Color = cs(rgb(255, 230, 80), rgb(255, 80, 0), rgb(40, 10, 10)) },
	{ Id = "GoldRushTrail", Name = "Gold Rush Trail", Slot = "Trail", Price = 2500, OPStage = 50, Emoji = "💰", Color = cs(rgb(255, 255, 220), rgb(255, 200, 40), rgb(200, 120, 0)) },
	{ Id = "VoidTrail", Name = "Void Trail", Slot = "Trail", Price = 6000, OPStage = 300, Emoji = "🕳️", Color = cs(rgb(200, 0, 255), rgb(10, 0, 20), rgb(0, 255, 200)) },
	{ Id = "PrismTrail", Name = "Prismatic Trail", Slot = "Trail", Price = 15000, OPStage = 700, Emoji = "💎", Color = cs(rgb(255, 0, 120), rgb(255, 200, 0), rgb(0, 255, 120), rgb(0, 160, 255), rgb(200, 0, 255)) },

	-- Auras (Kind "Particles" = coloured particles; Smoke = dark smoke)
	{ Id = "SnowAura", Name = "Snow Aura", Slot = "Aura", Kind = "Particles", Price = 350, Stage = 15, Emoji = "❄️", Color = cs(rgb(255, 255, 255), rgb(170, 220, 255)), Rate = 14, Size = 0.4, Accel = Vector3.new(0, -4, 0) },
	{ Id = "HeartAura", Name = "Heart Aura", Slot = "Aura", Kind = "Particles", Price = 600, Stage = 35, Emoji = "💖", Color = cs(rgb(255, 120, 180), rgb(255, 40, 120)), Rate = 10, Size = 0.6, Accel = Vector3.new(0, 3, 0) },
	{ Id = "GalaxyAura", Name = "Galaxy Aura", Slot = "Aura", Kind = "Particles", Price = 1000, Stage = 55, Emoji = "🌌", Color = cs(rgb(120, 230, 255), rgb(170, 80, 255), rgb(255, 255, 255)), Rate = 24, Size = 0.35, Accel = Vector3.zero },
	{ Id = "ShadowAura", Name = "Shadow Aura", Slot = "Aura", Kind = "Smoke", Price = 1800, Stage = 85, Emoji = "🌑", Color = rgb(30, 10, 40) },
	{ Id = "CoinRainAura", Name = "Coin Rain Aura", Slot = "Aura", Kind = "Particles", Price = 4000, OPStage = 150, Emoji = "🪙", Color = cs(rgb(255, 230, 90), rgb(255, 180, 20)), Rate = 12, Size = 0.7, Accel = Vector3.new(0, -12, 0), Above = true },

	-- Hats
	{ Id = "PartyHat", Name = "Party Hat", Slot = "Hat", Kind = "PartyHat", Price = 150, Stage = 5, Emoji = "🥳", Color = rgb(255, 80, 200) },
	{ Id = "CatEars", Name = "Cat Ears", Slot = "Hat", Kind = "CatEars", Price = 300, Stage = 12, Emoji = "🐱", Color = rgb(255, 170, 200) },
	{ Id = "TopHat", Name = "Greedy Top Hat", Slot = "Hat", Kind = "TopHat", Price = 700, Stage = 30, Emoji = "🎩", Color = rgb(30, 25, 35) },
	{ Id = "DevilHorns", Name = "Devil Horns", Slot = "Hat", Kind = "Horns", Price = 1200, Stage = 60, Emoji = "😈", Color = rgb(220, 20, 40) },
	{ Id = "GoldCrown", Name = "Golden Crown", Slot = "Hat", Kind = "Crown", Price = 3000, Stage = 100, Emoji = "👑", Color = rgb(255, 200, 40) },
	{ Id = "DiamondCrown", Name = "Diamond Crown", Slot = "Hat", Kind = "Crown", Price = 8000, OPStage = 400, Emoji = "💠", Color = rgb(170, 235, 255) },

	-- Wings (Back)
	{ Id = "FairyWings", Name = "Fairy Wings", Slot = "Back", Kind = "Wings", Price = 500, Stage = 18, Emoji = "🧚", Color = rgb(170, 255, 230), Neon = true, Transparency = 0.35 },
	{ Id = "BatWings", Name = "Bat Wings", Slot = "Back", Kind = "Wings", Price = 900, Stage = 40, Emoji = "🦇", Color = rgb(40, 30, 50) },
	{ Id = "AngelWings", Name = "Angel Wings", Slot = "Back", Kind = "Wings", Price = 2000, Stage = 70, Emoji = "👼", Color = rgb(255, 255, 255), Neon = true, Transparency = 0.1 },
	{ Id = "Jetpack", Name = "Rocket Jetpack", Slot = "Back", Kind = "Jetpack", Price = 3500, Stage = 90, Emoji = "🚀", Color = rgb(200, 205, 215) },
	{ Id = "DragonWings", Name = "Dragon Wings", Slot = "Back", Kind = "Wings", Price = 10000, OPStage = 600, Emoji = "🐉", Color = rgb(200, 30, 30), Neon = true },

	-- Pets: follow you around AND give bonus coins
	{ Id = "CoinBuddy", Name = "Coin Buddy", Slot = "Pet", Kind = "Coin", Price = 250, Stage = 8, Emoji = "🪙", Color = rgb(255, 200, 40), CoinBoost = 0.05 },
	{ Id = "SlimePet", Name = "Bouncy Slime", Slot = "Pet", Kind = "Blob", Price = 750, Stage = 22, Emoji = "🟢", Color = rgb(90, 230, 120), CoinBoost = 0.1 },
	{ Id = "GhostPet", Name = "Ghosty", Slot = "Pet", Kind = "Ghost", Price = 1500, Stage = 45, Emoji = "👻", Color = rgb(240, 240, 255), CoinBoost = 0.15 },
	{ Id = "MiniGary", Name = "Mini Gary", Slot = "Pet", Kind = "Gary", Price = 4000, Stage = 80, Emoji = "😈", Color = rgb(120, 200, 60), CoinBoost = 0.25 },
	{ Id = "StarPup", Name = "Star Pup", Slot = "Pet", Kind = "Star", Price = 9000, OPStage = 200, Emoji = "⭐", Color = rgb(255, 230, 90), CoinBoost = 0.35 },
	{ Id = "GoldDragon", Name = "Golden Dragon", Slot = "Pet", Kind = "Dragon", Price = 25000, OPStage = 800, Emoji = "🐲", Color = rgb(255, 190, 30), CoinBoost = 0.5 },
}
for _, item in ipairs(MORE) do
	table.insert(ShopCatalog.Items, item)
end

-- Emojis for the original items (shown when no icon image is set).
local EMOJI = {
	RainbowTrail = "🌈", FireTrail = "🔥", GalaxyTrail = "🌌", SparkleAura = "✨", FireAura = "🔥",
	GoldenGlow = "🌟", BubbleAura = "🫧", LightningTrail = "⚡", CometTrail = "☄️", RebirthTrail = "🔁",
	ChampionHalo = "😇", OPHalo = "💥", VIPTrail = "💎",
}
for _, item in ipairs(ShopCatalog.Items) do
	item.Emoji = item.Emoji or EMOJI[item.Id]
end

-- Shop tabs, in order.
ShopCatalog.Tabs = {
	{ Name = "ALL" },
	{ Name = "TRAILS", Slots = { Trail = true } },
	{ Name = "AURAS", Slots = { Aura = true, Halo = true } },
	{ Name = "HATS", Slots = { Hat = true } },
	{ Name = "WINGS", Slots = { Back = true } },
	{ Name = "PETS", Slots = { Pet = true } },
}

-- "Reach stage 26" style lock text, or nil if this player has unlocked it.
function ShopCatalog.LockText(item, maxStage, maxOP)
	if item.Stage and (maxStage or 1) < item.Stage then
		return "Stage " .. item.Stage
	end
	if item.OPStage and (maxOP or 1) < item.OPStage then
		return "OP " .. item.OPStage
	end
	return nil
end

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
