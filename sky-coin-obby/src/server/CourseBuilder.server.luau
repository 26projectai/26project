-- Builds a playable 30-stage obby in 3 zones (Sky Islands, Candy Land, Outer Space)
-- plus the global leaderboard boards next to the start.
-- Skips itself if Workspace already has a "Checkpoints" folder, or if
-- Config.BuildSampleCourse is false.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

if not Config.BuildSampleCourse or workspace:FindFirstChild("Checkpoints") then
	return
end

local STAGES = Config.Stages or 40
local SPACING = 60 -- studs between checkpoints
local BASE_Y = 60 -- course height

local THEMES = {
	{ -- Sky Islands
		Platforms = {
			Color3.fromRGB(80, 170, 255),
			Color3.fromRGB(255, 120, 200),
			Color3.fromRGB(150, 110, 255),
			Color3.fromRGB(255, 200, 70),
			Color3.fromRGB(90, 220, 200),
		},
		Material = Enum.Material.SmoothPlastic,
		Checkpoint = Color3.fromRGB(70, 220, 100),
		Floor = Color3.fromRGB(255, 90, 20),
	},
	{ -- Candy Land
		Platforms = {
			Color3.fromRGB(255, 150, 200),
			Color3.fromRGB(255, 225, 130),
			Color3.fromRGB(160, 240, 200),
			Color3.fromRGB(200, 160, 255),
			Color3.fromRGB(255, 255, 255),
		},
		Material = Enum.Material.SmoothPlastic,
		Checkpoint = Color3.fromRGB(120, 235, 190),
		Floor = Color3.fromRGB(255, 110, 170),
	},
	{ -- Outer Space
		Platforms = {
			Color3.fromRGB(110, 80, 220),
			Color3.fromRGB(60, 190, 255),
			Color3.fromRGB(200, 90, 255),
			Color3.fromRGB(80, 255, 200),
		},
		Material = Enum.Material.Neon,
		Checkpoint = Color3.fromRGB(80, 255, 140),
		Floor = Color3.fromRGB(45, 15, 80),
	},
}

local function zoneIndex(stage)
	local index = 1
	for i, zone in ipairs(Config.Zones) do
		if stage >= zone.FirstStage then
			index = i
		end
	end
	return math.min(index, #THEMES)
end

local function folder(name)
	local f = Instance.new("Folder")
	f.Name = name
	return f
end

local course = folder("SampleCourse")
local checkpoints = folder("Checkpoints")
local coins = folder("Coins")
local killParts = folder("KillParts")
local boards = folder("Leaderboards")

local function part(props, className)
	local p = Instance.new(className or "Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	local parent = props.Parent
	props.Parent = nil
	for key, value in pairs(props) do
		p[key] = value
	end
	p.Parent = parent
	return p
end

local function tag(p, tagName, attributes)
	CollectionService:AddTag(p, tagName)
	for key, value in pairs(attributes or {}) do
		p:SetAttribute(key, value)
	end
	return p
end

local function platform(stage, position, size, cframe)
	local theme = THEMES[zoneIndex(stage)]
	local p = part({
		Name = "Platform",
		Size = size,
		Color = theme.Platforms[(stage + math.floor(position.X / 7)) % #theme.Platforms + 1],
		Material = theme.Material,
		Parent = course,
	})
	p.CFrame = cframe or CFrame.new(position)
	return p
end

local function killBrick(position, size)
	return part({
		Name = "KillBrick",
		Size = size,
		Position = position,
		Color = Color3.fromRGB(255, 40, 40),
		Material = Enum.Material.Neon,
		Parent = killParts,
	})
end

local function coin(position)
	return part({
		Name = "Coin",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.5, 3, 3),
		Position = position,
		Color = Color3.fromRGB(255, 205, 40),
		Material = Enum.Material.Neon,
		CanCollide = false,
		CastShadow = false,
		Parent = coins,
	})
end

local function jumpPad(position, power)
	local p = part({
		Name = "JumpPad",
		Size = Vector3.new(4, 0.6, 4),
		Position = position,
		Color = Color3.fromRGB(60, 255, 120),
		Material = Enum.Material.Neon,
		Parent = course,
	})
	return tag(p, "JumpPad", { Power = power })
end

local function label(parentPart, text, color, height)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(240, height or 50)
	gui.StudsOffset = Vector3.new(0, 5, 0)
	gui.MaxDistance = 120
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextScaled = true
	textLabel.Text = text
	textLabel.TextColor3 = color
	textLabel.TextStrokeTransparency = 0
	textLabel.Parent = gui
	gui.Parent = parentPart
end

---------------------------------------------------------------- Checkpoints
for stage = 1, STAGES do
	local isFinal = stage == STAGES
	local zIndex = zoneIndex(stage)
	local zone = Config.Zones[zIndex]
	local pad = part({
		Name = tostring(stage),
		Size = isFinal and Vector3.new(16, 1, 16) or Vector3.new(12, 1, 12),
		Position = Vector3.new((stage - 1) * SPACING, BASE_Y, 0),
		Color = isFinal and Color3.fromRGB(255, 205, 40) or THEMES[zIndex].Checkpoint,
		Material = isFinal and Enum.Material.Neon or Enum.Material.SmoothPlastic,
	}, stage == 1 and "SpawnLocation" or "Part")
	if stage == 1 then
		pad.Neutral = true
		pad.Duration = 0
	end
	if isFinal then
		label(pad, "FINISH!", Color3.fromRGB(255, 230, 90))
	elseif zone and zone.FirstStage == stage then
		label(pad, zone.Name .. "\nSTAGE " .. stage, Color3.new(1, 1, 1), 90)
	else
		label(pad, "STAGE " .. stage, Color3.new(1, 1, 1))
	end
	pad.Parent = checkpoints
end

---------------------------------------------------------------- Boost Stations (every Config.StationInterval stages)
for stage = Config.StationInterval, STAGES - 1, Config.StationInterval do
	local padPos = Vector3.new((stage - 1) * SPACING, BASE_Y, 0)
	local orb = part({
		Name = "BoostOrb",
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * 3,
		Position = padPos + Vector3.new(-3.5, 3.5, 3.5),
		Color = Color3.fromRGB(255, 210, 40),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = course,
	})
	tag(orb, "BoostOrb", { StationId = "Story" .. stage })
	label(orb, ("x%d COINS - TOUCH ME"):format(Config.StationBoostMultiplier), Color3.fromRGB(255, 230, 120))
	local boardPos = padPos + Vector3.new(0, 6.5, -8)
	local board = part({
		Name = "StationBoard",
		Size = Vector3.new(11, 8, 0.6),
		CFrame = CFrame.lookAt(boardPos, boardPos + Vector3.new(0, 0, 1)),
		Color = Color3.fromRGB(25, 25, 45),
		CanCollide = false,
		Parent = course,
	})
	tag(board, "Board_Live")
end

---------------------------------------------------------------- Portals to the 1000-stage OP Obby
local function opPortal(position, facing)
	local ring = part({
		Name = "OPPortal",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.8, 11, 11),
		CFrame = CFrame.lookAt(position, position + facing) * CFrame.Angles(0, math.rad(90), 0),
		Color = Color3.fromRGB(255, 0, 90),
		Material = Enum.Material.ForceField,
		CanCollide = false,
		Parent = course,
	})
	tag(ring, "OPPortal")
	label(ring, "OP OBBY\n1000 STAGES", Color3.fromRGB(255, 120, 170), 90)
	local frame = part({
		Name = "OPPortalFrame",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.6, 12.5, 12.5),
		CFrame = ring.CFrame * CFrame.new(-0.4, 0, 0),
		Color = Color3.fromRGB(40, 0, 30),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = course,
	})
	frame.CanTouch = false
end
opPortal(Vector3.new(-18, BASE_Y + 6, 13), Vector3.new(0, 0, -1)) -- in the spawn lobby

---------------------------------------------------------------- Obstacle sections
-- Pads span x0-6..x0+6, so each section fills x0+6..x0+54.
-- d = 0..1 difficulty within the zone.
local skySections = {
	-- Jumping platforms that shrink as stages go up
	function(stage, x0, d)
		local size = 5 - 1.5 * d
		for i, cx in ipairs({ 12, 21, 30, 39, 48 }) do
			local y = BASE_Y + (i % 2 == 0 and 2 or 0)
			platform(stage, Vector3.new(x0 + cx, y, 0), Vector3.new(size, 1, size))
			if i % 2 == 0 or i == 3 then
				coin(Vector3.new(x0 + cx, y + 3.5, 0))
			end
		end
	end,
	-- Walkway with kill strips to hop over
	function(stage, x0)
		platform(stage, Vector3.new(x0 + 30, BASE_Y, 0), Vector3.new(48, 1, 6))
		for _, cx in ipairs({ 15, 25, 35, 45 }) do
			killBrick(Vector3.new(x0 + cx, BASE_Y + 1, 0), Vector3.new(1.5, 1, 6))
		end
		for _, cx in ipairs({ 20, 30, 40 }) do
			coin(Vector3.new(x0 + cx, BASE_Y + 3.5, 0))
		end
	end,
	-- Spinning kill bar
	function(stage, x0, d)
		platform(stage, Vector3.new(x0 + 30, BASE_Y, 0), Vector3.new(48, 1, 10))
		local bar = killBrick(Vector3.new(x0 + 30, BASE_Y + 1.25, 0), Vector3.new(1, 1.5, 22))
		bar.Name = "Spinner"
		tag(bar, "Spinner", { SpinSpeed = 90 + 60 * d })
		for _, cx in ipairs({ 14, 30, 46 }) do
			coin(Vector3.new(x0 + cx, BASE_Y + 3.5, 0))
		end
	end,
	-- Narrow zig-zag beams
	function(stage, x0, d)
		local width = 2 - 0.5 * d
		for i, cx in ipairs({ 14, 30, 46 }) do
			local z = ({ 0, 3, -3 })[i]
			platform(stage, Vector3.new(x0 + cx, BASE_Y, z), Vector3.new(12, 1, width))
			coin(Vector3.new(x0 + cx, BASE_Y + 3.5, z))
		end
	end,
}

-- Rotating 90 degrees makes a part's front (look) direction point toward -X.
local FACE_BACK = CFrame.Angles(0, math.rad(90), 0)

-- Trap floor: identical tiles, but some of them drop away (great reaction clips).
local function trapFloor(stage, x0, d)
	local rng = Random.new(stage * 31)
	local tiles = 6
	for i = 1, tiles do
		local cx = 6 + (i - 0.5) * (48 / tiles)
		for row = -1, 1 do
			local tile = platform(stage, Vector3.new(x0 + cx, BASE_Y, row * 3.2), Vector3.new(48 / tiles - 0.2, 1, 3))
			tile.Color = Color3.fromRGB(230, 230, 240)
			-- One safe tile per column; the others are trap doors.
			if row ~= (rng:NextInteger(-1, 1)) then
				tag(tile, "TrapDoor")
			end
		end
	end
	coin(Vector3.new(x0 + 30, BASE_Y + 3.5, 0))
end

local candySections = {
	trapFloor,
	-- Platforms that vanish after you step on them
	function(stage, x0, d)
		for i, cx in ipairs({ 12, 21, 30, 39, 48 }) do
			local p = platform(stage, Vector3.new(x0 + cx, BASE_Y, 0), Vector3.new(6, 1, 6))
			tag(p, "Fade", { FadeTime = 0.8 - 0.4 * d, ReturnTime = 2.5 })
			if i % 2 == 1 then
				coin(Vector3.new(x0 + cx, BASE_Y + 3.5, 0))
			end
		end
	end,
	-- Conveyor pushing you backwards, with sliding blocks
	function(stage, x0, d)
		local belt = platform(stage, Vector3.zero, Vector3.new(8, 1, 48), CFrame.new(x0 + 30, BASE_Y, 0) * FACE_BACK)
		belt.Material = Enum.Material.DiamondPlate
		tag(belt, "Conveyor", { ConveyorSpeed = 6 + 6 * d })
		for i, cx in ipairs({ 18, 30, 42 }) do
			local block = killBrick(Vector3.zero, Vector3.new(2, 2, 2))
			block.CFrame = CFrame.new(x0 + cx, BASE_Y + 1.5, 0) * FACE_BACK
			tag(block, "Slider", { Distance = 3, Speed = 0.3 + 0.2 * d, Phase = i * 0.33 })
			coin(Vector3.new(x0 + cx + 6, BASE_Y + 3.5, 0))
		end
	end,
	-- Jump pad up to a high platform
	function(stage, x0)
		platform(stage, Vector3.new(x0 + 13, BASE_Y, 0), Vector3.new(14, 1, 8))
		jumpPad(Vector3.new(x0 + 18, BASE_Y + 0.8, 0), 80)
		platform(stage, Vector3.new(x0 + 31, BASE_Y + 14, 0), Vector3.new(12, 1, 8))
		platform(stage, Vector3.new(x0 + 45, BASE_Y + 7, 0), Vector3.new(6, 1, 6))
		coin(Vector3.new(x0 + 23, BASE_Y + 13, 0))
		coin(Vector3.new(x0 + 31, BASE_Y + 17.5, 0))
		coin(Vector3.new(x0 + 45, BASE_Y + 10.5, 0))
	end,
	-- Narrow walkway with sliders sweeping across
	function(stage, x0, d)
		platform(stage, Vector3.new(x0 + 30, BASE_Y, 0), Vector3.new(48, 1, 6))
		for i, cx in ipairs({ 16, 26, 36, 46 }) do
			local block = killBrick(Vector3.zero, Vector3.new(2, 3, 2))
			block.CFrame = CFrame.new(x0 + cx, BASE_Y + 2, 0) * FACE_BACK
			tag(block, "Slider", { Distance = 3.5, Speed = 0.35 + 0.25 * d, Phase = i * 0.25 })
		end
		for _, cx in ipairs({ 21, 31, 41 }) do
			coin(Vector3.new(x0 + cx, BASE_Y + 3.5, 0))
		end
	end,
}

-- Space has low gravity (see Config.Zones), so jumps go much further.
local spaceSections = {
	trapFloor,
	-- Asteroid hops
	function(stage, x0, d)
		local size = 6 - 2 * d
		for i, cx in ipairs({ 16, 31, 45 }) do
			local y = BASE_Y + ({ 2, 5, 1 })[i]
			platform(stage, Vector3.new(x0 + cx, y, ({ 2, -2, 1 })[i]), Vector3.new(size, 1, size))
			coin(Vector3.new(x0 + cx, y + 7, 0))
		end
	end,
	-- Double spinners
	function(stage, x0, d)
		platform(stage, Vector3.new(x0 + 30, BASE_Y, 0), Vector3.new(48, 1, 10))
		for i, cx in ipairs({ 19, 41 }) do
			local bar = killBrick(Vector3.new(x0 + cx, BASE_Y + 1.25, 0), Vector3.new(1, 1.5, 14))
			bar.Name = "Spinner"
			tag(bar, "Spinner", { SpinSpeed = (i == 1 and 1 or -1) * (110 + 70 * d) })
			coin(Vector3.new(x0 + cx, BASE_Y + 9, 0))
		end
		coin(Vector3.new(x0 + 30, BASE_Y + 3.5, 0))
	end,
	-- Vanishing moon rocks over the void
	function(stage, x0, d)
		for _, cx in ipairs({ 15, 27, 39, 50 }) do
			local p = platform(stage, Vector3.new(x0 + cx, BASE_Y, 0), Vector3.new(4, 1, 4))
			tag(p, "Fade", { FadeTime = 0.7 - 0.3 * d, ReturnTime = 3 })
			coin(Vector3.new(x0 + cx, BASE_Y + 6, 0))
		end
	end,
	-- Moon launch: a jump pad flings you across a huge gap
	function(stage, x0)
		platform(stage, Vector3.new(x0 + 10, BASE_Y, 0), Vector3.new(8, 1, 8))
		jumpPad(Vector3.new(x0 + 12, BASE_Y + 0.8, 0), 70)
		platform(stage, Vector3.new(x0 + 44, BASE_Y, 0), Vector3.new(20, 1, 10))
		coin(Vector3.new(x0 + 20, BASE_Y + 24, 0))
		coin(Vector3.new(x0 + 26, BASE_Y + 29, 0))
		coin(Vector3.new(x0 + 32, BASE_Y + 24, 0))
	end,
	-- Laser gates: neon bars sliding up and down across a walkway
	function(stage, x0, d)
		platform(stage, Vector3.new(x0 + 30, BASE_Y, 0), Vector3.new(48, 1, 8))
		for i, cx in ipairs({ 16, 27, 38, 49 }) do
			local laser = killBrick(Vector3.zero, Vector3.new(1, 0.6, 9))
			laser.Color = Color3.fromRGB(255, 50, 200)
			-- Rotated so the slider's X axis points up: it moves vertically.
			laser.CFrame = CFrame.new(x0 + cx, BASE_Y + 4, 0) * CFrame.Angles(0, 0, math.rad(90))
			tag(laser, "Slider", { Distance = 3.2, Speed = 0.35 + 0.25 * d, Phase = i * 0.27 })
		end
		for _, cx in ipairs({ 21, 32, 43 }) do
			coin(Vector3.new(x0 + cx, BASE_Y + 3.5, 0))
		end
	end,
	-- Long moon leaps between tiny platforms
	function(stage, x0, d)
		local size = 5 - 1.5 * d
		for i, cx in ipairs({ 20, 37 }) do
			local y = BASE_Y + (i == 1 and 4 or 1)
			platform(stage, Vector3.new(x0 + cx, y, (i == 1 and 3 or -3)), Vector3.new(size, 1, size))
			coin(Vector3.new(x0 + cx, y + 9, 0))
		end
		coin(Vector3.new(x0 + 46, BASE_Y + 12, 0))
	end,
}

local sectionsByZone = { skySections, candySections, spaceSections }

for stage = 1, STAGES - 1 do
	local zIndex = zoneIndex(stage)
	local zoneFirst = Config.Zones[zIndex].FirstStage
	local nextZone = Config.Zones[zIndex + 1]
	local zoneLast = nextZone and nextZone.FirstStage - 1 or STAGES - 1
	local d = (stage - zoneFirst) / math.max(zoneLast - zoneFirst, 1)
	local sections = sectionsByZone[zIndex]
	sections[(stage - zoneFirst) % #sections + 1](stage, (stage - 1) * SPACING, d)
end

---------------------------------------------------------------- Gary jumpscares + a silly yeet pad (clip-worthy moments)
for _, stage in ipairs({ 6, 17, 27, 36 }) do
	if stage < STAGES then
		local trigger = part({
			Name = "GaryScare",
			Size = Vector3.new(4, 8, 14),
			Position = Vector3.new((stage - 1) * SPACING + 30, BASE_Y + 4, 0),
			Transparency = 1,
			CanCollide = false,
			Parent = course,
		})
		tag(trigger, "Jumpscare")
	end
end
do
	-- On the lobby island: a pad that launches you absurdly high (land back in the lobby).
	local yeet = part({
		Name = "YeetPad",
		Size = Vector3.new(5, 0.6, 5),
		Position = Vector3.new(-26, BASE_Y + 0.3, -6),
		Color = Color3.fromRGB(255, 80, 200),
		Material = Enum.Material.Neon,
		Parent = course,
	})
	tag(yeet, "JumpPad", { Power = 260, Yeet = true })
	label(yeet, "DO NOT TOUCH", Color3.fromRGB(255, 120, 220))
end

---------------------------------------------------------------- Kill floors (one per zone, out to the horizon)
local FLOOR_MATERIALS = { Enum.Material.CrackedLava, Enum.Material.SmoothPlastic, Enum.Material.Neon }
local FLOOR_WIDTH = 1400 -- studs across (z); parts max out at 2048
for zIndex, zone in ipairs(Config.Zones) do
	if zIndex > #THEMES then
		break
	end
	local nextZone = Config.Zones[zIndex + 1]
	local xStart = (zone.FirstStage - 1) * SPACING - (zIndex == 1 and 600 or 0)
	local xEnd = nextZone and (nextZone.FirstStage - 1) * SPACING or (STAGES - 1) * SPACING + 600
	local floor = killBrick(Vector3.new((xStart + xEnd) / 2, BASE_Y - 30, 0), Vector3.new(xEnd - xStart, 2, FLOOR_WIDTH))
	floor.Name = "Floor"
	floor.Color = THEMES[zIndex].Floor
	floor.Material = FLOOR_MATERIALS[zIndex] or Enum.Material.SmoothPlastic
	floor.CastShadow = false
	if zIndex == 3 then
		floor.Transparency = 0.45 -- see the asteroid belt below the space void
	end
end

-- The template's grey baseplate would show under the course as empty "dead space".
local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate and baseplate:IsA("BasePart") then
	baseplate:Destroy()
end

---------------------------------------------------------------- Leaderboard boards
-- Boards are found by tag: Board_Wins (global most wins), Board_Time (global fastest run),
-- Board_Live (this server's live race by stage). See Leaderboards.server.
local function board(name, tagName, position, facing, size)
	local p = part({
		Name = name,
		Size = size or Vector3.new(14, 12, 1),
		CFrame = CFrame.lookAt(position, position + facing),
		Color = Color3.fromRGB(25, 25, 45),
		Parent = boards,
	})
	CollectionService:AddTag(p, tagName)
	return p
end
-- Beside the start.
board("WinsBoard", "Board_Wins", Vector3.new(0, BASE_Y + 7, -13), Vector3.new(0, 0, 1))
board("TimeBoard", "Board_Time", Vector3.new(0, BASE_Y + 7, 13), Vector3.new(0, 0, -1))
board("LiveBoard", "Board_Live", Vector3.new(-16, BASE_Y + 7, -13), Vector3.new(0, 0, 1))

---------------------------------------------------------------- Central hub (dashboard + NPCs)
local HUB_STAGE = math.clamp(Config.HubStage or 20, 2, STAGES - 1)
local hubX = (HUB_STAGE - 1) * SPACING
local HUB_CENTER = Vector3.new(hubX, BASE_Y, -62)
local HUB_DIAMETER = 84
do
	local hubTheme = THEMES[zoneIndex(HUB_STAGE)]
	-- Walkable bridge from the hub checkpoint to the island.
	part({
		Name = "HubBridge",
		Size = Vector3.new(7, 1, 30),
		Position = Vector3.new(hubX, BASE_Y - 0.5, -20),
		Color = Color3.fromRGB(150, 105, 70),
		Material = Enum.Material.WoodPlanks,
		Parent = course,
	})
	-- Giant dashboard: three panels facing the course.
	local dashZ = HUB_CENTER.Z - 24
	local facing = Vector3.new(0, 0, 1)
	board("HubWins", "Board_Wins", Vector3.new(hubX - 27, BASE_Y + 10, dashZ), facing, Vector3.new(17, 15, 1))
	board("HubLive", "Board_Live", Vector3.new(hubX - 9, BASE_Y + 11, dashZ), facing, Vector3.new(17, 17, 1))
	board("HubOP", "Board_OP", Vector3.new(hubX + 9, BASE_Y + 11, dashZ), facing, Vector3.new(17, 17, 1))
	board("HubTime", "Board_Time", Vector3.new(hubX + 27, BASE_Y + 10, dashZ), facing, Vector3.new(17, 15, 1))
	local frame = part({
		Name = "DashboardFrame",
		Size = Vector3.new(76, 22, 1),
		CFrame = CFrame.new(hubX, BASE_Y + 11, dashZ - 0.8),
		Color = hubTheme.Checkpoint,
		Material = Enum.Material.Neon,
		Parent = boards,
	})
	frame.CanCollide = false
	local header = part({
		Name = "DashboardHeader",
		Size = Vector3.new(40, 5, 1),
		CFrame = CFrame.lookAt(Vector3.new(hubX, BASE_Y + 24.5, dashZ), Vector3.new(hubX, BASE_Y + 24.5, dashZ) + facing),
		Color = Color3.fromRGB(25, 25, 45),
		Parent = boards,
	})
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.fromScale(1, 1)
	headerText.BackgroundTransparency = 1
	headerText.Font = Enum.Font.FredokaOne
	headerText.TextScaled = true
	headerText.Text = "SKY COIN DASHBOARD"
	headerText.TextColor3 = Color3.fromRGB(255, 215, 60)
	headerText.Parent = gui
	gui.Parent = header
	opPortal(HUB_CENTER + Vector3.new(20, 6, 6), Vector3.new(-1, 0, 0)) -- on the hub island

	-- Teamwork Vault: glass cage with a coin chest; two plates must be held at once to open it.
	local vault = HUB_CENTER + Vector3.new(-24, 0, 10)
	local glass = { Color = Color3.fromRGB(180, 230, 255), Material = Enum.Material.Glass, Transparency = 0.3, Parent = course }
	local function wall(offset, size)
		local props = table.clone(glass)
		props.Size = size
		props.Position = vault + offset
		return part(props)
	end
	wall(Vector3.new(0, 4, -4), Vector3.new(8, 8, 0.5))
	wall(Vector3.new(-4, 4, 0), Vector3.new(0.5, 8, 8))
	wall(Vector3.new(4, 4, 0), Vector3.new(0.5, 8, 8))
	wall(Vector3.new(0, 8.25, 0), Vector3.new(8, 0.5, 8))
	local door = wall(Vector3.new(0, 4, 4), Vector3.new(8, 8, 0.5))
	door.Name = "VaultDoor"
	CollectionService:AddTag(door, "VaultDoor")
	local chest = part({
		Name = "VaultChest",
		Size = Vector3.new(3, 2.5, 2),
		Position = vault + Vector3.new(0, 1.3, 0),
		Color = Color3.fromRGB(255, 200, 40),
		Material = Enum.Material.Neon,
		Parent = course,
	})
	CollectionService:AddTag(chest, "VaultChest")
	label(chest, "TEAMWORK VAULT\nStand on BOTH plates!", Color3.fromRGB(255, 230, 120), 70)
	for _, dx in ipairs({ -7, 7 }) do
		local plate = part({
			Name = "VaultPlate",
			Size = Vector3.new(4, 0.4, 4),
			Position = vault + Vector3.new(dx, 0.2, 10),
			Color = Color3.fromRGB(255, 80, 80),
			Material = Enum.Material.Neon,
			Parent = course,
		})
		CollectionService:AddTag(plate, "VaultPlate")
	end

	-- Jump Power Tower: ledges far too high to reach... until your Jump Power grows.
	local towerBase = HUB_CENTER + Vector3.new(26, 0, -24)
	for i, height in ipairs({ 18, 34, 55 }) do
		local ledge = part({
			Name = "PowerLedge",
			Size = Vector3.new(8, 1, 8),
			Position = towerBase + Vector3.new(0, height, -i * 2),
			Color = Color3.fromRGB(255, 220, 60),
			Material = Enum.Material.Neon,
			Parent = course,
		})
		local reward = ({ 100, 250, 600 })[i]
		local chestTop = part({
			Name = "PowerChest",
			Size = Vector3.new(2.5, 2, 2),
			Position = ledge.Position + Vector3.new(0, 1.5, 0),
			Color = Color3.fromRGB(120, 70, 30),
			Material = Enum.Material.Wood,
			Parent = course,
		})
		tag(chestTop, "RewardChest", { Reward = reward, CooldownMinutes = 60, ChestId = "Power" .. i })
		label(ledge, ("JUMP POWER %d+\n+%d coins"):format(({ 230, 550, 970 })[i], reward), Color3.new(1, 1, 1), 60)
	end
end

---------------------------------------------------------------- Scenery (islands, worlds, gates, trophy)
require(script.Parent:WaitForChild("Scenery")).Build({
	Stages = STAGES,
	Spacing = SPACING,
	BaseY = BASE_Y,
	Zones = Config.Zones,
	ZoneIndex = zoneIndex,
	HubCenter = HUB_CENTER,
	HubDiameter = HUB_DIAMETER,
})

course.Parent = workspace
killParts.Parent = workspace
coins.Parent = workspace
boards.Parent = workspace
checkpoints.Parent = workspace
