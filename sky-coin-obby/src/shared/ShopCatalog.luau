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
