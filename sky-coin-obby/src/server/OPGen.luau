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
