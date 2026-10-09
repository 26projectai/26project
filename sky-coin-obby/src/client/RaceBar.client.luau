-- Live race bar: every player's avatar on a track from stage 1 to the finish, so you can see
-- who's ahead. Also shows the active coin-boost timer (luxury NPC boost).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local UI = require(Shared:WaitForChild("UI"))

local player = Players.LocalPlayer
local COLORS = UI.COLORS
local make = UI.make

local gui = make("ScreenGui", {
	Name = "RaceBarUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = player:WaitForChild("PlayerGui"),
})

local track = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 96),
	Size = UDim2.fromOffset(420, 10),
	BackgroundColor3 = COLORS.Panel,
	BackgroundTransparency = 0.2,
	Parent = gui,
}, { UI.corner(999), UI.stroke(2) })
local scale = make("UIScale", { Parent = track })

-- Zone colour bands along the track.
local function totalStages()
	local checkpoints = workspace:FindFirstChild("Checkpoints")
	local total = 0
	for _, child in ipairs(checkpoints and checkpoints:GetChildren() or {}) do
		total = math.max(total, tonumber(child.Name) or 0)
	end
	return math.max(total, 2)
end

local ZONE_COLORS = { Color3.fromRGB(80, 170, 255), Color3.fromRGB(255, 120, 200), Color3.fromRGB(150, 90, 255) }
-- Two sets of colour bands: story worlds, and the OP tower's 20 difficulty tiers.
local storyBands = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = track })
local opBands = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = track })
task.defer(function()
	local total = totalStages()
	for i, zone in ipairs(Config.Zones) do
		local nextZone = Config.Zones[i + 1]
		local from = (zone.FirstStage - 1) / (total - 1)
		local to = nextZone and (nextZone.FirstStage - 1) / (total - 1) or 1
		make("Frame", {
			Position = UDim2.fromScale(from, 0),
			Size = UDim2.fromScale(to - from, 1),
			BackgroundColor3 = ZONE_COLORS[i] or COLORS.Blue,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			Parent = storyBands,
		})
	end
	local tiers = #Config.OP.Tiers
	for i, tier in ipairs(Config.OP.Tiers) do
		make("Frame", {
			Position = UDim2.fromScale((i - 1) / tiers, 0),
			Size = UDim2.fromScale(1 / tiers, 1),
			BackgroundColor3 = tier[2],
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Parent = opBands,
		})
	end
end)

local markers = {} -- [Player] = ImageLabel

local function markerFor(other)
	if markers[other] then
		return markers[other]
	end
	local isMe = other == player
	local marker = make("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(isMe and 30 or 24, isMe and 30 or 24),
		BackgroundColor3 = isMe and COLORS.Gold or COLORS.Card,
		ZIndex = isMe and 4 or 3,
		Parent = track,
	}, { UI.corner(999), make("UIStroke", { Thickness = 2, Color = isMe and COLORS.Gold or COLORS.Outline }) })
	task.spawn(function()
		local ok, image = pcall(Players.GetUserThumbnailAsync, Players, other.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		if ok then
			marker.Image = image
		end
	end)
	markers[other] = marker
	return marker
end

Players.PlayerRemoving:Connect(function(other)
	if markers[other] then
		markers[other]:Destroy()
		markers[other] = nil
	end
end)

---------------------------------------------------------------- Boost badge
local boostLabel = UI.text({
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 114),
	Size = UDim2.fromOffset(260, 26),
	Text = "",
	TextColor3 = COLORS.Gold,
	Parent = gui,
})
local boosts = {}
Remotes.DataUpdated.OnClientEvent:Connect(function(data)
	boosts = data
end)

---------------------------------------------------------------- Update loop
local accumulator = 0
RunService.RenderStepped:Connect(function(dt)
	local viewport = workspace.CurrentCamera.ViewportSize
	scale.Scale = math.clamp(viewport.X / 560, 0.6, 1)

	local now = workspace:GetServerTimeNow()
	local parts = {}
	local function addBoost(untilTime, label)
		local left = (untilTime or 0) - now
		if left > 0 then
			table.insert(parts, ("%s %s"):format(label, UI.formatDuration(left)))
		end
	end
	addBoost(boosts.InviteBoostUntil, ("FRIEND x%d"):format(Config.InviteBoostMultiplier))
	addBoost(boosts.BoostUntil, ("NPC x%d"):format(Config.NPCBoostMultiplier))
	addBoost(boosts.StationBoostUntil, ("STATION x%d"):format(Config.StationBoostMultiplier))
	if boosts.Tethered then
		table.insert(parts, ("TEAM x%s"):format(tostring(Config.TetherMultiplier)))
	end
	boostLabel.Text = table.concat(parts, "  |  ")
	boostLabel.Size = UDim2.fromOffset(#parts > 1 and 520 or 260, 26)

	accumulator += dt
	if accumulator < 0.25 then
		return
	end
	accumulator = 0
	-- Show the race for whichever mode you're in (story course or OP tower).
	local myMode = player:GetAttribute("Mode") or "Main"
	local inOP = myMode == "OP"
	storyBands.Visible, opBands.Visible = not inOP, inOP
	local total = inOP and Config.OP.Stages or totalStages()
	for _, other in ipairs(Players:GetPlayers()) do
		local stats = other:FindFirstChild("leaderstats")
		local stage = stats and stats:FindFirstChild(inOP and "OP" or "Stage")
		if stage then
			local marker = markerFor(other)
			marker.Visible = (other:GetAttribute("Mode") or "Main") == myMode
			local target = UDim2.fromScale(math.clamp((stage.Value - 1) / (total - 1), 0, 1), 0.5)
			marker.Position = marker.Position:Lerp(target, 0.5)
		end
	end
end)
