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

-- Odd and even tiers sit side by side (z), so each tier's sea and scenery never hang
-- over the tier below it.
local TIER_SIDE_OFFSET = 700

function OPGen.PadPosition(stage)
	local tier = OPGen.TierOf(stage)
	local i = stage - (tier - 1) * OP.TierSize
	local z = ((tier - 1) % 2) * TIER_SIDE_OFFSET
	return OP.Origin + Vector3.new((i - 1) * OP.Spacing, (tier - 1) * OP.TierHeight + (i - 1) * OP.StageRise, z)
end

function OPGen.BiomeOf(tier)
	return math.min(math.floor((tier - 1) / OP.TiersPerBiome) + 1, #OP.Biomes)
end

---------------------------------------------------------------- Biome looks
-- Material for platforms, a sea far below (flowing texture from Assets.Floors), and scenery.
local GOLD = Color3.fromRGB(255, 200, 60)
local BIOME_STYLE = {
	{ -- Rainbow Meadows
		Material = Enum.Material.SmoothPlastic,
		SeaColor = Color3.fromRGB(255, 140, 30),
		SeaMaterial = Enum.Material.CrackedLava,
		Spark = Color3.fromRGB(255, 220, 90),
	},
	{ -- Inferno Forge
		Material = Enum.Material.Basalt,
		SeaColor = Color3.fromRGB(255, 70, 20),
		SeaMaterial = Enum.Material.CrackedLava,
		Spark = Color3.fromRGB(255, 120, 30),
	},
	{ -- Frozen Peaks
		Material = Enum.Material.Glass,
		SeaColor = Color3.fromRGB(120, 200, 255),
		SeaMaterial = Enum.Material.Glacier,
		Spark = Color3.fromRGB(230, 245, 255),
		SeaTint = Color3.fromRGB(170, 230, 255),
	},
	{ -- Neon City
		Material = Enum.Material.Neon,
		SeaColor = Color3.fromRGB(40, 10, 80),
		SeaMaterial = Enum.Material.Neon,
		Spark = Color3.fromRGB(120, 255, 255),
	},
	{ -- Gary's Golden Vault
		Material = Enum.Material.Marble,
		SeaColor = Color3.fromRGB(255, 190, 40),
		SeaMaterial = Enum.Material.Foil,
		Spark = Color3.fromRGB(255, 230, 120),
	},
}

-- Scenery builders: deco(props) makes a non-collidable part. rng is per-tier.
local SCENERY = {}

SCENERY[1] = function(rng, deco, spot, light, dark)
	for _ = 1, 14 do -- floating grass islands with trees
		local c = spot(rng)
		local d = rng:NextNumber(14, 34)
		deco({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(3, d, d), CFrame = CFrame.new(c) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(90, 200, 80), Material = Enum.Material.Grass })
		deco({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(6, d * 0.7, d * 0.7), CFrame = CFrame.new(c - Vector3.new(0, 4.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(120, 90, 60), Material = Enum.Material.Rock })
		for _ = 1, math.floor(d / 10) do
			local t = c + Vector3.new(rng:NextNumber(-d / 3, d / 3), 1.5, rng:NextNumber(-d / 3, d / 3))
			deco({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(6, 1.4, 1.4), CFrame = CFrame.new(t + Vector3.new(0, 3, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(110, 75, 45), Material = Enum.Material.Wood })
			deco({ Shape = Enum.PartType.Ball, Size = Vector3.one * rng:NextNumber(5, 8), Position = t + Vector3.new(0, 7.5, 0), Color = Color3.fromRGB(80, rng:NextInteger(170, 215), 80), Material = Enum.Material.Grass })
		end
	end
	for _ = 1, 22 do -- clouds
		local c = spot(rng)
		for _ = 1, 4 do
			deco({ Shape = Enum.PartType.Ball, Size = Vector3.one * rng:NextNumber(8, 16), Position = c + Vector3.new(rng:NextNumber(-9, 9), rng:NextNumber(-2, 3), rng:NextNumber(-5, 5)), Color = Color3.new(1, 1, 1) })
		end
	end
end

SCENERY[2] = function(rng, deco, spot)
	for _ = 1, 26 do -- basalt spires with glowing lava tops
		local c = spot(rng) - Vector3.new(0, 30, 0)
		local h = rng:NextNumber(30, 80)
		local w = rng:NextNumber(6, 14)
		deco({ Size = Vector3.new(w, h, w), CFrame = CFrame.new(c) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0), Color = Color3.fromRGB(45, 35, 35), Material = Enum.Material.Basalt })
		local top = deco({ Size = Vector3.new(w * 0.8, 1.2, w * 0.8), Position = c + Vector3.new(0, h / 2, 0), Color = Color3.fromRGB(255, 90, 20), Material = Enum.Material.Neon })
		if rng:NextNumber() < 0.4 then
			local fire = Instance.new("Fire")
			fire.Size = 12
			fire.Heat = 15
			fire.Parent = top
		end
	end
	for _ = 1, 12 do -- hanging chains of glowing rock
		local c = spot(rng)
		for k = 0, 5 do
			deco({ Size = Vector3.new(1.4, 3, 1.4), Position = c + Vector3.new(0, -k * 3.2, 0), Color = k % 2 == 0 and Color3.fromRGB(70, 60, 60) or Color3.fromRGB(255, 110, 30), Material = k % 2 == 0 and Enum.Material.Metal or Enum.Material.Neon })
		end
	end
end

SCENERY[3] = function(rng, deco, spot)
	local ice = { Color3.fromRGB(170, 230, 255), Color3.fromRGB(120, 200, 255), Color3.fromRGB(230, 245, 255) }
	for _ = 1, 30 do -- crystal clusters
		local c = spot(rng)
		for _ = 1, 3 do
			local h = rng:NextNumber(10, 28)
			deco({
				Size = Vector3.new(rng:NextNumber(2, 4), h, rng:NextNumber(2, 4)),
				CFrame = CFrame.new(c) * CFrame.Angles(rng:NextNumber(-0.5, 0.5), rng:NextNumber(0, 6.28), rng:NextNumber(-0.5, 0.5)) * CFrame.new(0, h / 2, 0),
				Color = ice[rng:NextInteger(1, #ice)],
				Material = Enum.Material.Glass,
				Transparency = 0.25,
			})
		end
		deco({ Shape = Enum.PartType.Ball, Size = Vector3.one * 2, Position = c, Color = Color3.fromRGB(200, 240, 255), Material = Enum.Material.Neon })
	end
	for _ = 1, 10 do -- snowy floating icebergs
		local c = spot(rng)
		local d = rng:NextNumber(16, 30)
		deco({ Size = Vector3.new(d, 6, d * 0.8), CFrame = CFrame.new(c) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0), Color = Color3.fromRGB(240, 248, 255), Material = Enum.Material.Snow })
		deco({ Shape = Enum.PartType.Ball, Size = Vector3.new(d * 0.7, d * 0.7, d * 0.7), Position = c - Vector3.new(0, d * 0.3, 0), Color = Color3.fromRGB(150, 210, 255), Material = Enum.Material.Ice })
	end
end

SCENERY[4] = function(rng, deco, spot, light, dark, tierColor)
	local neon = { Color3.fromRGB(255, 0, 200), Color3.fromRGB(0, 255, 255), Color3.fromRGB(140, 80, 255), tierColor }
	for _ = 1, 18 do -- skyscrapers with glowing window stripes
		local c = spot(rng) - Vector3.new(0, 60, 0)
		local h = rng:NextNumber(60, 140)
		local w = rng:NextNumber(10, 18)
		deco({ Size = Vector3.new(w, h, w), Position = c, Color = Color3.fromRGB(20, 18, 35), Material = Enum.Material.Glass })
		local stripe = neon[rng:NextInteger(1, #neon)]
		for k = 1, math.floor(h / 14) do
			deco({ Size = Vector3.new(w + 0.3, 0.6, w + 0.3), Position = c + Vector3.new(0, -h / 2 + k * 14, 0), Color = stripe, Material = Enum.Material.Neon })
		end
	end
	for _ = 1, 14 do -- floating neon rings
		local c = spot(rng)
		local r = rng:NextNumber(5, 10)
		local color = neon[rng:NextInteger(1, #neon)]
		local tilt = CFrame.Angles(rng:NextNumber(0, 3.14), rng:NextNumber(0, 3.14), 0)
		for k = 0, 15 do
			local a = math.pi * 2 * k / 16
			deco({ Size = Vector3.new(0.8, 0.8, 2 * math.pi * r / 16 + 0.2), CFrame = CFrame.new(c) * tilt * CFrame.lookAt(Vector3.new(0, math.sin(a) * r, math.cos(a) * r), Vector3.new(0, math.sin(a) * r + math.cos(a), math.cos(a) * r - math.sin(a))), Color = color, Material = Enum.Material.Neon })
		end
	end
end

SCENERY[5] = function(rng, deco, spot)
	for _ = 1, 22 do -- giant spinning-looking gold coins
		local c = spot(rng)
		local d = rng:NextNumber(8, 20)
		deco({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(d * 0.15, d, d), CFrame = CFrame.new(c) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0), Color = GOLD, Material = Enum.Material.Foil })
	end
	for _ = 1, 12 do -- marble pillars with gold caps
		local c = spot(rng) - Vector3.new(0, 40, 0)
		local h = rng:NextNumber(50, 100)
		deco({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(h, 6, 6), CFrame = CFrame.new(c) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(245, 242, 235), Material = Enum.Material.Marble })
		deco({ Size = Vector3.new(8, 2, 8), Position = c + Vector3.new(0, h / 2 + 1, 0), Color = GOLD, Material = Enum.Material.Metal })
	end
	for _ = 1, 10 do -- treasure piles
		local c = spot(rng)
		for _ = 1, 8 do
			deco({ Shape = Enum.PartType.Ball, Size = Vector3.one * rng:NextNumber(3, 7), Position = c + Vector3.new(rng:NextNumber(-5, 5), rng:NextNumber(-2, 2), rng:NextNumber(-5, 5)), Color = GOLD, Material = Enum.Material.Metal })
		end
		local gem = deco({ Size = Vector3.new(2, 3, 2), CFrame = CFrame.new(c + Vector3.new(0, 4, 0)) * CFrame.Angles(0.6, 0.6, 0), Color = Color3.fromRGB(255, 60, 150), Material = Enum.Material.Neon })
		gem.Name = "Gem"
	end
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
	local biomeIndex = OPGen.BiomeOf(tier)
	local biome, style = OP.Biomes[biomeIndex], BIOME_STYLE[biomeIndex]
	local course = Instance.new("Folder")
	course.Name = "OPTier" .. tier
	local coins = subfolder("Coins", "OPTier" .. tier)
	local kills = subfolder("KillParts", "OPTier" .. tier)

	local function part(props, className, parent)
		local p = Instance.new(className or "Part")
		p.Anchored = true
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Material = style.Material
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

		-- Tier start: a grand gate with the tier name + portal back to the story course.
		if i == 1 then
			OPGen.TierGate(pad, tier, tierName, tierColor, biome, stage, part)
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

		-- Checkpoint trim: a darker rim around every pad.
		part({
			Name = "PadRim",
			Size = checkpoint.Size + Vector3.new(1.2, -0.2, 1.2),
			Position = pad - Vector3.new(0, 0.2, 0),
			Color = dark,
			Material = Enum.Material.Metal,
			CanCollide = false,
			CanTouch = false,
		})

		-- Obstacle section to the next stage (or the portal to the next tier).
		if isFinal then
			-- Victory trophy
			part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(4, 3, 3), CFrame = CFrame.new(pad + Vector3.new(0, 2.5, -4)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(255, 200, 40), Material = Enum.Material.Metal, CanCollide = false })
			part({ Shape = Enum.PartType.Ball, Size = Vector3.one * 5, Position = pad + Vector3.new(0, 6, -4), Color = Color3.fromRGB(255, 200, 40), Material = Enum.Material.Metal, CanCollide = false })
		elseif i == OP.TierSize then
			local nextInfo = OP.Tiers[math.min(tier + 1, #OP.Tiers)]
			local portalPos = pad + Vector3.new(10, 5.5, 0)
			local portal = part({
				Name = "NextTierPortal",
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(0.6, 9, 9),
				CFrame = CFrame.new(portalPos),
				Color = nextInfo[2],
				Material = Enum.Material.ForceField,
				CanCollide = false,
			})
			tag(portal, "OPNextTier", { Stage = stage + 1 })
			OPGen.Ring(portalPos, 5, nextInfo[2], part)
			label(portal, "NEXT TIER: " .. nextInfo[1], Color3.new(1, 1, 1), UDim2.fromOffset(260, 44), Vector3.new(0, 7.5, 0))
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

	-- Biome scenery around the tier (kept clear of the jump path).
	local rng = Random.new(tier * 7919)
	local base = OPGen.PadPosition((tier - 1) * OP.TierSize + 1)
	local length = OP.TierSize * OP.Spacing
	local function deco(props)
		props.CanCollide = false
		props.CanTouch = false
		props.CanQuery = false
		props.CastShadow = false
		local p = part(props)
		p.Name = p.Name == "Part" and "Deco" or p.Name
		return p
	end
	local function spot(r)
		local x = r:NextNumber(-60, length + 60)
		local z = (r:NextNumber() < 0.5 and -1 or 1) * r:NextNumber(35, 170)
		return base + Vector3.new(x, x / OP.Spacing * OP.StageRise + r:NextNumber(-50, 70), z)
	end
	SCENERY[biomeIndex](rng, deco, spot, light, dark, tierColor)

	-- The sea far below (visual: falling 45 studs below your stage already resets you).
	local seaY = base.Y - 70
	local seaImage = Config.Floors and Config.Floors[biome.Sea]
	local hasImage = seaImage and seaImage ~= "" and seaImage ~= "rbxassetid://0"
	for piece = 0, 1 do
		local sea = deco({
			Name = "Sea",
			Size = Vector3.new(length / 2 + 200, 2, 560),
			Position = Vector3.new(base.X - 100 + (piece + 0.5) * (length / 2 + 200), seaY, base.Z),
			Color = style.SeaColor,
			Material = style.SeaMaterial,
		})
		if hasImage then
			for layer = 1, 2 do
				local texture = Instance.new("Texture")
				texture.Face = Enum.NormalId.Top
				texture.Texture = seaImage
				texture.Color3 = style.SeaTint or Color3.new(1, 1, 1)
				texture.StudsPerTileU = layer == 1 and 80 or 136
				texture.StudsPerTileV = texture.StudsPerTileU
				texture.Transparency = layer == 1 and 0 or 0.6
				texture:SetAttribute("FlowU", layer == 1 and 3 or -2)
				texture:SetAttribute("FlowV", layer == 1 and 1.5 or -1)
				texture.Parent = sea
				CollectionService:AddTag(texture, "FlowTexture")
			end
		end
		local sparks = Instance.new("ParticleEmitter")
		sparks.EmissionDirection = Enum.NormalId.Top
		sparks.Color = ColorSequence.new(style.Spark)
		sparks.LightEmission = 1
		sparks.Rate = 60
		sparks.Lifetime = NumberRange.new(3, 5)
		sparks.Speed = NumberRange.new(10, 18)
		sparks.Size = NumberSequence.new(2.5, 0)
		sparks.Parent = sea
	end

	course.Parent = workspace:FindFirstChild("OPObby") or (function()
		local f = Instance.new("Folder")
		f.Name = "OPObby"
		f.Parent = workspace
		return f
	end)()
	return { course, coins, kills }
end

---------------------------------------------------------------- Tier gate + portal ring
function OPGen.Ring(center, radius, color, part)
	local segments = 24
	for k = 0, segments - 1 do
		local a0, a1 = math.pi * 2 * k / segments, math.pi * 2 * (k + 1) / segments
		local p0 = center + Vector3.new(0, math.sin(a0) * radius, math.cos(a0) * radius)
		local p1 = center + Vector3.new(0, math.sin(a1) * radius, math.cos(a1) * radius)
		for layer, info in ipairs({ { radius, 0.7, color, Enum.Material.Neon }, { radius + 0.8, 1, GOLD, Enum.Material.Metal } }) do
			local scale = info[1] / radius
			local q0, q1 = center + (p0 - center) * scale, center + (p1 - center) * scale
			part({
				Name = "PortalRing" .. layer,
				Size = Vector3.new(1, info[2], (q1 - q0).Magnitude + 0.15),
				CFrame = CFrame.lookAt((q0 + q1) / 2, q1),
				Color = info[3],
				Material = info[4],
				CanCollide = false,
				CanTouch = false,
				CanQuery = false,
			})
		end
	end
end

function OPGen.TierGate(pad, tier, tierName, tierColor, biome, stage, part)
	local lastStage = math.min(stage + OP.TierSize - 1, OP.Stages)
	-- Two tall columns in the tier colour + a glowing beam across the top.
	for _, dz in ipairs({ -8, 8 }) do
		part({ Name = "GateColumn", Size = Vector3.new(2.5, 22, 2.5), Position = pad + Vector3.new(0, 11, dz), Color = tierColor, Material = Enum.Material.Neon, CanCollide = false, CanTouch = false })
		part({ Name = "GateCap", Shape = Enum.PartType.Ball, Size = Vector3.one * 3.4, Position = pad + Vector3.new(0, 23.5, dz), Color = GOLD, Material = Enum.Material.Metal, CanCollide = false, CanTouch = false })
	end
	local signPos = pad + Vector3.new(0, 25, 0)
	local sign = part({
		Name = "TierSign",
		Size = Vector3.new(19, 7, 0.8),
		CFrame = CFrame.lookAt(signPos, signPos + Vector3.new(-1, 0, 0)),
		Color = Color3.fromRGB(20, 18, 35),
		CanCollide = false,
		CanTouch = false,
	})
	part({ Name = "TierSignTrim", Size = Vector3.new(20, 8, 0.5), CFrame = sign.CFrame * CFrame.new(0, 0, 0.4), Color = GOLD, Material = Enum.Material.Metal, CanCollide = false, CanTouch = false })
	for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
		local gui = Instance.new("SurfaceGui")
		gui.Face = face
		gui.LightInfluence = 0
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 30
		local function line(text, y, h, color)
			local t = Instance.new("TextLabel")
			t.BackgroundTransparency = 1
			t.Position = UDim2.fromScale(0.04, y)
			t.Size = UDim2.fromScale(0.92, h)
			t.Font = Enum.Font.FredokaOne
			t.TextScaled = true
			t.Text = text
			t.TextColor3 = color
			local stroke = Instance.new("UIStroke")
			stroke.Thickness = 3
			stroke.Parent = t
			t.Parent = gui
		end
		line(("TIER %d: %s"):format(tier, tierName), 0.05, 0.42, tierColor:Lerp(Color3.new(1, 1, 1), 0.15))
		line(biome.Name, 0.5, 0.24, GOLD)
		line(("STAGES %d - %d"):format(stage, lastStage), 0.76, 0.2, Color3.new(1, 1, 1))
		gui.Parent = sign
	end
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

-- 11. Pillars: step up and down a row of round pillars
SECTIONS.Pillars = function(rng, pad, rise, d, ctx)
	local count = 4 + math.floor(d * 1.5)
	local top = math.max(4.2 - 2 * d, 2.2)
	local heights = { 1, 3, 4.2, 3, 1.5, 2.5 }
	for j = 1, count do
		local cx = 4 + 32 * j / (count + 1)
		local y = rise * cx / 40 + heights[j]
		ctx.part({
			Name = "Pillar",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(24, top, top),
			CFrame = CFrame.new(at(pad, cx, y - 11.5, rng:NextNumber(-1, 1) * d * 2)) * CFrame.Angles(0, 0, math.rad(90)),
			Color = j % 2 == 0 and ctx.light or ctx.dark,
		})
		if j == 3 then
			ctx.coin(at(pad, cx, y + 3.5, 0))
		end
	end
end

-- 12. Trap tiles: two lanes, one tile in every row drops away (same every time - learn it!)
SECTIONS.TrapTiles = function(rng, pad, rise, d, ctx)
	local rows = 5
	for j = 1, rows do
		local cx = 4 + 32 * (j - 0.5) / rows
		local trapLane = rng:NextInteger(1, 2)
		for lane = 1, 2 do
			local tile = ctx.part({
				Name = "Tile",
				Size = Vector3.new(32 / rows - 0.4, 1, 3.6),
				Position = at(pad, cx, rise * cx / 40, lane == 1 and -2 or 2),
				Color = (j + lane) % 2 == 0 and ctx.light or ctx.dark,
			})
			if lane == trapLane and j > 1 then
				ctx.tag(tile, "TrapDoor")
			end
		end
	end
	ctx.coin(at(pad, 20, rise / 2 + 3.5, 0))
end

-- 13. Rings: hop across platforms through glowing hoops
SECTIONS.Rings = function(rng, pad, rise, d, ctx)
	local size = math.max(4.5 - 2 * d, 2.6)
	for j = 1, 3 do
		local cx = 4 + 32 * j / 4
		local y = rise * cx / 40 + (j == 2 and 1.5 or 0)
		ctx.part({ Name = "Hop", Size = Vector3.new(size, 1, size), Position = at(pad, cx, y, 0), Color = j % 2 == 0 and ctx.light or ctx.dark })
		-- hoop over the gap before this platform
		local hoop = at(pad, cx - 4, y + 4, 0)
		for k = 0, 11 do
			local a = math.pi * 2 * k / 12
			ctx.part({
				Name = "Hoop",
				Size = Vector3.new(0.5, 0.5, 2.1),
				CFrame = CFrame.lookAt(hoop + Vector3.new(0, math.sin(a) * 3.2, math.cos(a) * 3.2), hoop + Vector3.new(0, math.sin(a) * 3.2 + math.cos(a), math.cos(a) * 3.2 - math.sin(a))),
				Color = ctx.color,
				Material = Enum.Material.Neon,
				CanCollide = false,
				CanTouch = false,
				CanQuery = false,
			})
		end
		ctx.coin(hoop)
	end
end

-- 14. Bounce: a chain of jump pads
SECTIONS.Bounce = function(rng, pad, rise, d, ctx)
	local size = math.max(4.5 - 1.5 * d, 3)
	for j, info in ipairs({ { 9, 0 }, { 21, 3 }, { 31, 1.5 } }) do
		local cx, y = info[1], info[2] + rise * info[1] / 40
		ctx.part({ Name = "BouncePlatform", Size = Vector3.new(size, 1, size), Position = at(pad, cx, y, 0), Color = ctx.dark })
		if j < 3 then
			local jp = ctx.part({ Name = "JumpPad", Size = Vector3.new(size - 1, 0.4, size - 1), Position = at(pad, cx, y + 0.7, 0), Color = Color3.fromRGB(60, 255, 120), Material = Enum.Material.Neon })
			ctx.tag(jp, "JumpPad", { Power = 70 })
		end
	end
	ctx.coin(at(pad, 15, 12, 0))
end

-- 15. Sweeper: a round platform with a spinning bar at your feet - jump over it!
SECTIONS.Sweeper = function(rng, pad, rise, d, ctx)
	local center = at(pad, 20, rise / 2, 0)
	ctx.part({ Name = "Arena", Shape = Enum.PartType.Cylinder, Size = Vector3.new(1, 21, 21), CFrame = CFrame.new(center) * CFrame.Angles(0, 0, math.rad(90)), Color = ctx.light })
	ctx.part({ Name = "Hub", Shape = Enum.PartType.Cylinder, Size = Vector3.new(3, 2, 2), CFrame = CFrame.new(center + Vector3.new(0, 1.5, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = ctx.dark, Material = Enum.Material.Metal })
	local bar = ctx.kill(center + Vector3.new(0, 1.2, 0), Vector3.new(0.8, 0.9, 20))
	ctx.tag(bar, "Spinner", { SpinSpeed = 60 + 110 * d })
	if d > 0.55 then
		local high = ctx.kill(center + Vector3.new(0, 5, 0), Vector3.new(0.8, 0.8, 20))
		ctx.tag(high, "Spinner", { SpinSpeed = -(50 + 80 * d) })
	end
	ctx.coin(center + Vector3.new(0, 4, 6))
end

-- 16. Stairs: climb a staircase where some steps are lava
SECTIONS.Stairs = function(rng, pad, rise, d, ctx)
	local lava = {}
	if d > 0.25 then
		lava[2] = true
	end
	if d > 0.5 then
		lava[5] = true
	end
	for j = 1, 6 do
		local cx = 1.5 + 5 * j
		local y = j * 1.2
		if lava[j] then
			ctx.kill(at(pad, cx, y, 0), Vector3.new(4, 1, 6))
		else
			ctx.part({ Name = "Step", Size = Vector3.new(4, 1, 6), Position = at(pad, cx, y, 0), Color = j % 2 == 0 and ctx.light or ctx.dark })
		end
	end
	ctx.coin(at(pad, 21.5, 7.5, 0))
end

local ORDER = {
	"Hops", "Strips", "Spinner", "Fade", "Conveyor", "Lasers", "JumpPad", "Truss", "Beams", "Grapple",
	"Pillars", "TrapTiles", "Rings", "Bounce", "Sweeper", "Stairs",
}
-- earliest stage for each section type
local UNLOCK = { Truss = 10, Grapple = 30, Lasers = 20, Conveyor = 15, Pillars = 5, Bounce = 25, Sweeper = 35, Stairs = 45, TrapTiles = 60 }

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
