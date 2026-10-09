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

local STAGES = 30
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

local candySections = {
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

---------------------------------------------------------------- Kill floors (one per zone)
for zIndex, zone in ipairs(Config.Zones) do
	if zIndex > #THEMES then
		break
	end
	local nextZone = Config.Zones[zIndex + 1]
	local xStart = (zone.FirstStage - 1) * SPACING - (zIndex == 1 and 60 or 0)
	local xEnd = nextZone and (nextZone.FirstStage - 1) * SPACING or (STAGES - 1) * SPACING + 60
	local floor = killBrick(Vector3.new((xStart + xEnd) / 2, BASE_Y - 30, 0), Vector3.new(xEnd - xStart, 2, 160))
	floor.Name = "Floor"
	floor.Color = THEMES[zIndex].Floor
end

---------------------------------------------------------------- Leaderboard boards beside the start
local function board(name, z, facing)
	local position = Vector3.new(0, BASE_Y + 7, z)
	part({
		Name = name,
		Size = Vector3.new(14, 12, 1),
		CFrame = CFrame.lookAt(position, position + facing),
		Color = Color3.fromRGB(25, 25, 45),
		Parent = boards,
	})
end
board("WinsBoard", -13, Vector3.new(0, 0, 1))
board("TimeBoard", 13, Vector3.new(0, 0, -1))

course.Parent = workspace
killParts.Parent = workspace
coins.Parent = workspace
boards.Parent = workspace
checkpoints.Parent = workspace
