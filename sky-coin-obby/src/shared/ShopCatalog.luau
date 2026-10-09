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
