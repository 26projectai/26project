-- Builds a playable sample obby so you can test right away.
-- Skips itself if Workspace already has a "Checkpoints" folder, or if
-- Config.BuildSampleCourse is false. Delete this script once you've built your own course.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

if not Config.BuildSampleCourse or workspace:FindFirstChild("Checkpoints") then
	return
end

local STAGES = Config.SampleCourseStages
local SPACING = 60 -- studs between checkpoints
local BASE_Y = 60 -- course height

local PLATFORM_COLORS = {
	Color3.fromRGB(80, 170, 255),
	Color3.fromRGB(255, 120, 200),
	Color3.fromRGB(150, 110, 255),
	Color3.fromRGB(255, 200, 70),
	Color3.fromRGB(90, 220, 200),
}

local function folder(name)
	local f = Instance.new("Folder")
	f.Name = name
	return f
end

local course = folder("SampleCourse")
local checkpoints = folder("Checkpoints")
local coins = folder("Coins")
local killParts = folder("KillParts")

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

local function platform(stage, position, size)
	return part({
		Name = "Platform",
		Size = size,
		Position = position,
		Color = PLATFORM_COLORS[(stage - 1) % #PLATFORM_COLORS + 1],
		Parent = course,
	})
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

local function label(parentPart, text, color)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(200, 50)
	gui.StudsOffset = Vector3.new(0, 5, 0)
	gui.MaxDistance = 90
	gui.AlwaysOnTop = false
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

-- Checkpoint pads. Stage 1 doubles as the spawn point.
for stage = 1, STAGES do
	local isFinal = stage == STAGES
	local pad = part({
		Name = tostring(stage),
		Size = Vector3.new(12, 1, 12),
		Position = Vector3.new((stage - 1) * SPACING, BASE_Y, 0),
		Color = isFinal and Color3.fromRGB(255, 205, 40) or Color3.fromRGB(70, 220, 100),
		Material = isFinal and Enum.Material.Neon or Enum.Material.SmoothPlastic,
	}, stage == 1 and "SpawnLocation" or "Part")
	if stage == 1 then
		pad.Neutral = true
		pad.Duration = 0
	end
	label(pad, isFinal and "FINISH!" or ("STAGE " .. stage), Color3.new(1, 1, 1))
	pad.Parent = checkpoints
end

-- Obstacle sections between pads. Pads span x0-6..x0+6, so each section fills x0+6..x0+54.
local sections = {
	-- Jumping platforms that shrink as stages go up
	function(stage, x0, difficulty)
		local size = 5 - 1.5 * difficulty
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
	function(stage, x0, difficulty)
		platform(stage, Vector3.new(x0 + 30, BASE_Y, 0), Vector3.new(48, 1, 10))
		local bar = killBrick(Vector3.new(x0 + 30, BASE_Y + 1.25, 0), Vector3.new(1, 1.5, 22))
		bar.Name = "Spinner"
		bar:SetAttribute("SpinSpeed", 90 + 60 * difficulty)
		CollectionService:AddTag(bar, "Spinner")
		for _, cx in ipairs({ 14, 30, 46 }) do
			coin(Vector3.new(x0 + cx, BASE_Y + 3.5, 0))
		end
	end,
	-- Narrow zig-zag beams
	function(stage, x0, difficulty)
		local width = 2 - 0.5 * difficulty
		for i, cx in ipairs({ 14, 30, 46 }) do
			local z = ({ 0, 3, -3 })[i]
			platform(stage, Vector3.new(x0 + cx, BASE_Y, z), Vector3.new(12, 1, width))
			coin(Vector3.new(x0 + cx, BASE_Y + 3.5, z))
		end
	end,
}

for stage = 1, STAGES - 1 do
	local x0 = (stage - 1) * SPACING
	local difficulty = (stage - 1) / math.max(STAGES - 2, 1)
	sections[(stage - 1) % #sections + 1](stage, x0, difficulty)
end

-- Lava floor under the whole course.
killBrick(
	Vector3.new((STAGES - 1) * SPACING / 2, BASE_Y - 30, 0),
	Vector3.new((STAGES - 1) * SPACING + 120, 2, 160)
).Color = Color3.fromRGB(255, 90, 20)

course.Parent = workspace
killParts.Parent = workspace
coins.Parent = workspace
checkpoints.Parent = workspace
