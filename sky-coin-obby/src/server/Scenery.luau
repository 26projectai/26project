-- Decorates the sample course: floating islands under checkpoints, flags, a spawn lobby,
-- and per-world scenery (Sky: clouds, tree islands, rainbow; Candy: lollipops, candy canes,
-- cupcakes, gumdrops; Space: planets, stars, asteroids), plus world gates and a finish trophy.
-- Decoration is non-collidable and kept away from the jump paths, so it never affects gameplay.
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local Scenery = {}

local rng = Random.new(2026)
local folder

local function deco(props, className)
	local p = Instance.new(className or "Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for key, value in pairs(props) do
		p[key] = value
	end
	p.Parent = folder
	return p
end

local function ball(position, diameter, color, material, transparency)
	return deco({
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * diameter,
		Position = position,
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
		Transparency = transparency or 0,
	})
end

-- Roblox cylinders run along their X axis; this stands one upright.
local UPRIGHT = CFrame.Angles(0, 0, math.rad(90))

local function pillar(position, height, diameter, color, material)
	return deco({
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(height, diameter, diameter),
		CFrame = CFrame.new(position) * UPRIGHT,
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
	})
end

local function range(a, b)
	return rng:NextNumber(a, b)
end

local function side(minZ, maxZ)
	return (rng:NextNumber() < 0.5 and -1 or 1) * range(minZ, maxZ)
end

local function pick(list)
	return list[rng:NextInteger(1, #list)]
end

---------------------------------------------------------------- shared pieces
local ISLANDS = {
	{ Top = Color3.fromRGB(100, 200, 90), TopMaterial = Enum.Material.Grass, Rock = Color3.fromRGB(125, 95, 70) },
	{ Top = Color3.fromRGB(255, 180, 215), TopMaterial = Enum.Material.SmoothPlastic, Rock = Color3.fromRGB(110, 65, 45) },
	{ Top = Color3.fromRGB(120, 115, 150), TopMaterial = Enum.Material.Slate, Rock = Color3.fromRGB(70, 65, 95) },
}
local FLAG_COLORS = { Color3.fromRGB(255, 90, 90), Color3.fromRGB(255, 120, 200), Color3.fromRGB(80, 255, 200) }

-- A floating island whose (walkable) top sits just under `topY`.
local function island(center, topY, diameter, zIndex, walkable)
	local look = ISLANDS[zIndex] or ISLANDS[1]
	local top = pillar(Vector3.new(center.X, topY - 1.05, center.Z), 2, diameter, look.Top, look.TopMaterial)
	top.CanCollide = walkable == true
	top.CastShadow = true
	local y = topY - 2
	for i, scale in ipairs({ 0.85, 0.6, 0.3 }) do
		local h = 3 + i
		pillar(Vector3.new(center.X, y - h / 2, center.Z), h, diameter * scale, look.Rock, Enum.Material.Rock)
		y -= h
	end
end

local function tree(base)
	pillar(base + Vector3.new(0, 3, 0), 6, 1.2, Color3.fromRGB(110, 75, 45), Enum.Material.Wood)
	for _ = 1, 3 do
		ball(base + Vector3.new(range(-1.5, 1.5), range(6, 8), range(-1.5, 1.5)), range(4.5, 6.5), Color3.fromRGB(80, range(170, 210), 80), Enum.Material.Grass)
	end
end

local function cloud(center, colors)
	for _ = 1, rng:NextInteger(3, 5) do
		ball(center + Vector3.new(range(-9, 9), range(-2, 3), range(-5, 5)), range(8, 16), pick(colors), Enum.Material.SmoothPlastic, 0.05)
	end
end

local function flag(position, color, neon)
	pillar(position + Vector3.new(0, 4, 0), 8, 0.4, Color3.fromRGB(240, 240, 240))
	deco({
		Size = Vector3.new(3, 2, 0.2),
		Position = position + Vector3.new(1.6, 7, 0),
		Color = color,
		Material = neon and Enum.Material.Neon or Enum.Material.Fabric,
	})
end

-- Half-ring arch over the path at x, in the Y/Z plane.
local function gate(x, baseY, radius, colors, material)
	local segments = 22
	for i = 0, segments - 1 do
		local a0 = math.pi * i / segments
		local a1 = math.pi * (i + 1) / segments
		local p0 = Vector3.new(x, baseY + math.sin(a0) * radius, math.cos(a0) * radius)
		local p1 = Vector3.new(x, baseY + math.sin(a1) * radius, math.cos(a1) * radius)
		deco({
			Size = Vector3.new(2.2, 2.2, (p1 - p0).Magnitude + 0.3),
			CFrame = CFrame.lookAt((p0 + p1) / 2, p1),
			Color = colors[i % #colors + 1],
			Material = material,
		})
	end
end

local function sign(position, facing, size, title, subtitle, color)
	local board = deco({
		Size = size,
		CFrame = CFrame.lookAt(position, position + facing),
		Color = Color3.fromRGB(30, 30, 55),
	})
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 30
	gui.LightInfluence = 0
	local function line(text, y, h, textColor)
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Position = UDim2.fromScale(0.04, y)
		label.Size = UDim2.fromScale(0.92, h)
		label.Font = Enum.Font.FredokaOne
		label.TextScaled = true
		label.Text = text
		label.TextColor3 = textColor
		label.Parent = gui
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 4
		stroke.Parent = label
	end
	line(title, 0.08, 0.55, color)
	line(subtitle, 0.66, 0.26, Color3.new(1, 1, 1))
	gui.Parent = board
end


-- Luxury spawn plaza: marble floor with a gold rim, red carpet with gold trim and lamp posts,
-- twin gold fountains, a gold-framed Hall of Fame and a grand entrance arch.
local GOLD = Color3.fromRGB(255, 200, 60)
local MARBLE = Color3.fromRGB(245, 242, 235)

local function lamp(base)
	pillar(base + Vector3.new(0, 0.4, 0), 0.8, 1.6, GOLD, Enum.Material.Metal)
	pillar(base + Vector3.new(0, 4, 0), 8, 0.45, GOLD, Enum.Material.Metal)
	local bulb = ball(base + Vector3.new(0, 8.6, 0), 1.6, Color3.fromRGB(255, 235, 170), Enum.Material.Neon)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 220, 150)
	light.Range = 16
	light.Brightness = 1.5
	light.Parent = bulb
end

local function fountain(base)
	pillar(base + Vector3.new(0, 0.6, 0), 1.2, 12, MARBLE, Enum.Material.Marble)
	pillar(base + Vector3.new(0, 1.25, 0), 0.3, 12.4, GOLD, Enum.Material.Metal)
	pillar(base + Vector3.new(0, 1.05, 0), 0.3, 10.6, Color3.fromRGB(80, 190, 255), Enum.Material.Glass).Transparency = 0.25
	pillar(base + Vector3.new(0, 3, 0), 4, 1.4, GOLD, Enum.Material.Metal)
	pillar(base + Vector3.new(0, 5.1, 0), 0.4, 5, GOLD, Enum.Material.Metal)
	-- golden coin on top
	deco({
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.5, 3.2, 3.2),
		CFrame = CFrame.new(base + Vector3.new(0, 7.4, 0)),
		Color = GOLD,
		Material = Enum.Material.Neon,
	})
	local spout = deco({ Size = Vector3.new(1, 0.2, 1), Position = base + Vector3.new(0, 5.4, 0), Transparency = 1 })
	local water = Instance.new("ParticleEmitter")
	water.Color = ColorSequence.new(Color3.fromRGB(150, 220, 255))
	water.LightEmission = 0.4
	water.Rate = 60
	water.Lifetime = NumberRange.new(1, 1.4)
	water.Speed = NumberRange.new(7, 9)
	water.SpreadAngle = Vector2.new(25, 25)
	water.Acceleration = Vector3.new(0, -22, 0)
	water.Size = NumberSequence.new(0.5, 0.2)
	water.Transparency = NumberSequence.new(0.2, 0.8)
	water.Parent = spout
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Color = ColorSequence.new(GOLD)
	sparkle.LightEmission = 1
	sparkle.Rate = 6
	sparkle.Lifetime = NumberRange.new(1.5, 2.5)
	sparkle.Speed = NumberRange.new(1, 2)
	sparkle.Size = NumberSequence.new(0.3, 0)
	sparkle.Parent = spout
end

-- Applies a tiling Higgsfield texture (Assets.Lobby) to one face of a part, if the id is set.
local function lobbyTexture(partObj, key, face, studs)
	local id = (Config.LobbyArt or {})[key]
	if not Config.HasAsset(id) then
		return
	end
	local texture = Instance.new("Texture")
	texture.Texture = id
	texture.Face = face
	texture.StudsPerTileU = studs
	texture.StudsPerTileV = studs
	texture.Parent = partObj
end

local function goldRing(center, radius, thickness, color, material)
	local segments = 28
	for i = 0, segments - 1 do
		local a0, a1 = math.pi * 2 * i / segments, math.pi * 2 * (i + 1) / segments
		local p0 = center + Vector3.new(math.cos(a0) * radius, 0, math.sin(a0) * radius)
		local p1 = center + Vector3.new(math.cos(a1) * radius, 0, math.sin(a1) * radius)
		deco({ Size = Vector3.new(thickness, thickness, (p1 - p0).Magnitude + 0.2), CFrame = CFrame.lookAt((p0 + p1) / 2, p1), Color = color or GOLD, Material = material or Enum.Material.Neon })
	end
end

local function column(base, height)
	deco({ Size = Vector3.new(4.4, 1.2, 4.4), Position = base + Vector3.new(0, 0.6, 0), Color = GOLD, Material = Enum.Material.Metal })
	pillar(base + Vector3.new(0, height / 2 + 1.2, 0), height, 3, MARBLE, Enum.Material.Marble)
	for _, y in ipairs({ 3, height - 1 }) do
		pillar(base + Vector3.new(0, y + 1.2, 0), 0.5, 3.2, GOLD, Enum.Material.Metal)
	end
	deco({ Size = Vector3.new(4.4, 1.2, 4.4), Position = base + Vector3.new(0, height + 1.8, 0), Color = GOLD, Material = Enum.Material.Metal })
	local orb = ball(base + Vector3.new(0, height + 3.6, 0), 2.4, Color3.fromRGB(255, 235, 160), Enum.Material.Neon)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 215, 140)
	light.Range = 22
	light.Brightness = 1.4
	light.Parent = orb
end

local function topiary(base)
	pillar(base + Vector3.new(0, 1.5, 0), 3, 5, GOLD, Enum.Material.Metal)
	pillar(base + Vector3.new(0, 3.1, 0), 0.4, 5.4, Color3.fromRGB(120, 40, 150), Enum.Material.SmoothPlastic)
	pillar(base + Vector3.new(0, 4.5, 0), 3, 0.8, Color3.fromRGB(110, 75, 45), Enum.Material.Wood)
	ball(base + Vector3.new(0, 7.5, 0), 6, Color3.fromRGB(70, 170, 80), Enum.Material.Grass)
	ball(base + Vector3.new(0, 11, 0), 4, Color3.fromRGB(80, 185, 90), Enum.Material.Grass)
end

local function chandelier(center)
	goldRing(center, 7, 0.6, GOLD, Enum.Material.Metal)
	goldRing(center + Vector3.new(0, -2.5, 0), 4.5, 0.5, GOLD, Enum.Material.Metal)
	for k = 0, 7 do
		local a = math.pi * 2 * k / 8
		local bulb = ball(center + Vector3.new(math.cos(a) * 7, 0.9, math.sin(a) * 7), 1.1, Color3.fromRGB(255, 240, 190), Enum.Material.Neon)
		if k % 2 == 0 then
			local light = Instance.new("PointLight")
			light.Color = Color3.fromRGB(255, 220, 150)
			light.Range = 26
			light.Brightness = 1.2
			light.Parent = bulb
		end
	end
	local gem = ball(center + Vector3.new(0, -4.5, 0), 2.2, Color3.fromRGB(170, 235, 255), Enum.Material.Neon)
	gem.Transparency = 0.15
	pillar(center + Vector3.new(0, 14, 0), 28, 0.25, GOLD, Enum.Material.Metal) -- chain to the sky
end

-- Giant golden Gary on a marble pedestal. Uses the imported 3D statue (ServerStorage >
-- Landmarks > GaryStatue) if there is one; otherwise builds him out of gold parts.
local garyModel -- set below (gary() is defined later in this file)
local function statue(base)
	-- pedestal
	pillar(base + Vector3.new(0, 0.5, 0), 1, 30, MARBLE, Enum.Material.Marble)
	pillar(base + Vector3.new(0, 1.25, 0), 0.5, 26, GOLD, Enum.Material.Metal)
	pillar(base + Vector3.new(0, 3.25, 0), 3.5, 20, MARBLE, Enum.Material.Marble)
	pillar(base + Vector3.new(0, 5.2, 0), 0.4, 21, GOLD, Enum.Material.Metal)
	goldRing(base + Vector3.new(0, 1.1, 0), 15.2, 0.4)
	local plaque = deco({ Size = Vector3.new(0.4, 2.4, 10), Position = base + Vector3.new(10.1, 3.2, 0), Color = Color3.fromRGB(30, 22, 45) })
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Right
	gui.LightInfluence = 0
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.Text = "😈 GREEDY GARY 😈\nHe stole the Sky Coins. Get them back!"
	t.TextColor3 = GOLD
	t.Parent = gui
	gui.Parent = plaque
	local top = base + Vector3.new(0, 5.4, 0)

	local storage = game:GetService("ServerStorage"):FindFirstChild("Landmarks")
	local template = storage and storage:FindFirstChild("GaryStatue")
	if template then
		local model = template:Clone()
		if model:IsA("BasePart") then
			local wrapper = Instance.new("Model")
			model.Parent = wrapper
			model = wrapper
		end
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("BasePart") then
				d.Anchored, d.CanCollide, d.CanTouch, d.CanQuery = true, false, false, false
			end
		end
		local _, size = model:GetBoundingBox()
		if size.Y > 0 then
			model:ScaleTo(model:GetScale() * 38 / size.Y)
		end
		model:PivotTo(CFrame.lookAt(top, top + Vector3.new(1, 0, 0)))
		local cf, newSize = model:GetBoundingBox()
		model:PivotTo(model:GetPivot() + Vector3.new(top.X - cf.Position.X, top.Y - (cf.Position.Y - newSize.Y / 2), top.Z - cf.Position.Z))
		model.Parent = folder
	else
		garyModel(top, 2, Vector3.new(1, 0, 0), true)
	end
end

local function luxuryLobby(lobby, baseY)
	local L = Config.Lobby
	local floorTop = baseY - 0.5
	local R = L.Diameter / 2

	-- marble floor with a gold rim (walkable) + Higgsfield marble texture
	local rim = pillar(Vector3.new(lobby.X, floorTop - 0.17, lobby.Z), 0.3, L.Diameter - 4, GOLD, Enum.Material.Metal)
	local marble = pillar(Vector3.new(lobby.X, floorTop - 0.15, lobby.Z), 0.3, L.Diameter - 9, MARBLE, Enum.Material.Marble)
	rim.CanCollide, marble.CanCollide = true, true
	lobbyTexture(marble, "Marble", Enum.NormalId.Right, 16) -- Right = the top of an upright cylinder
	-- gold inlay circle
	pillar(Vector3.new(lobby.X, floorTop + 0.01, lobby.Z), 0.02, 124, GOLD, Enum.Material.Metal)
	local inner = pillar(Vector3.new(lobby.X, floorTop + 0.02, lobby.Z), 0.02, 122.6, MARBLE, Enum.Material.Marble)
	lobbyTexture(inner, "Marble", Enum.NormalId.Right, 16)

	-- red carpet: spawn -> statue plaza -> Hall of Fame, with gold trim
	local statueX = L.Statue.X
	local function carpet(x0, x1)
		local c = deco({ Size = Vector3.new(x0 - x1, 0.1, 9), Position = Vector3.new((x0 + x1) / 2, floorTop + 0.06, 0), Color = Color3.fromRGB(170, 15, 35), Material = Enum.Material.Fabric })
		c.Name = "RedCarpet"
		lobbyTexture(c, "Carpet", Enum.NormalId.Top, 9)
		for _, z in ipairs({ -4.7, 4.7 }) do
			deco({ Size = Vector3.new(x0 - x1, 0.12, 0.5), Position = Vector3.new((x0 + x1) / 2, floorTop + 0.07, z), Color = GOLD, Material = Enum.Material.Metal })
		end
	end
	carpet(-4, statueX + 19)
	carpet(statueX - 19, L.WallX + 6)
	-- round carpet plaza around the statue
	pillar(Vector3.new(statueX, floorTop + 0.05, 0), 0.08, 40, GOLD, Enum.Material.Metal)
	local plaza = pillar(Vector3.new(statueX, floorTop + 0.07, 0), 0.08, 38, Color3.fromRGB(170, 15, 35), Enum.Material.Fabric)
	lobbyTexture(plaza, "Carpet", Enum.NormalId.Right, 9)
	statue(Vector3.new(statueX, floorTop, 0))

	-- lamp posts along the carpet
	for x = -14, statueX + 24, -12 do
		lamp(Vector3.new(x, floorTop, -7))
		lamp(Vector3.new(x, floorTop, 7))
	end
	for x = statueX - 26, L.WallX + 28, -12 do -- stops before the podium
		lamp(Vector3.new(x, floorTop, -7))
		lamp(Vector3.new(x, floorTop, 7))
	end

	-- twin fountains, grand entrance arch, chandeliers
	fountain(Vector3.new(-30, floorTop, -26))
	fountain(Vector3.new(-30, floorTop, 26))
	gate(-10, floorTop, 12, { GOLD, MARBLE }, Enum.Material.Metal)
	chandelier(Vector3.new(-40, floorTop + 30, 0))
	chandelier(Vector3.new(statueX, floorTop + 52, 0))
	chandelier(Vector3.new(L.WallX + 25, floorTop + 30, 0))

	-- marble colonnade around the edge (open at the spawn entrance and behind the Hall of Fame)
	for deg = 0, 359, 18 do
		local a = math.rad(deg)
		local fromEast = math.abs(((deg + 180) % 360) - 180)
		if fromEast > 26 and fromEast < 158 then
			local base = Vector3.new(lobby.X + math.cos(a) * (R - 9), floorTop, lobby.Z + math.sin(a) * (R - 9))
			column(base, 18)
		end
	end
	-- topiary trees in gold pots
	for _, deg in ipairs({ 40, 140, 220, 320 }) do
		local a = math.rad(deg)
		topiary(Vector3.new(lobby.X + math.cos(a) * (R - 22), floorTop, lobby.Z + math.sin(a) * (R - 22)))
	end
	-- green trees just outside the colonnade
	for deg = 9, 359, 36 do
		local a = math.rad(deg)
		local fromEast = math.abs(((deg + 180) % 360) - 180)
		if fromEast > 30 then
			tree(Vector3.new(lobby.X + math.cos(a) * (R - 3), floorTop - 0.1, lobby.Z + math.sin(a) * (R - 3)))
		end
	end

	-- gold frame around the Hall of Fame wall
	for _, z in ipairs({ -27.5, 27.5 }) do
		pillar(Vector3.new(L.WallX - 1, floorTop + 16, z), 32, 2.6, GOLD, Enum.Material.Metal)
		ball(Vector3.new(L.WallX - 1, floorTop + 33, z), 3, Color3.fromRGB(255, 235, 150), Enum.Material.Neon)
	end
	deco({ Size = Vector3.new(2.6, 1.2, 55), Position = Vector3.new(L.WallX - 1, floorTop + 30.3, 0), Color = GOLD, Material = Enum.Material.Neon })
end

---------------------------------------------------------------- per-world scenery
local function buildSky(x0, x1, baseY)
	for _ = 1, 45 do
		cloud(Vector3.new(range(x0 - 80, x1), range(baseY - 25, baseY + 35), side(28, 140)), { Color3.new(1, 1, 1), Color3.fromRGB(235, 245, 255) })
	end
	for _ = 1, 12 do
		local center = Vector3.new(range(x0, x1), baseY + range(-15, 8), side(24, 70))
		island(center, center.Y, range(12, 18), 1, false)
		tree(center + Vector3.new(range(-3, 3), 0, range(-3, 3)))
	end
	-- Big islands out toward the horizon.
	for _ = 1, 14 do
		local center = Vector3.new(range(x0 - 400, x1 + 100), baseY + range(-22, 18), side(110, 380))
		local diameter = range(40, 85)
		island(center, center.Y, diameter, 1, false)
		for _ = 1, math.floor(diameter / 12) do
			local r, a = range(0, diameter * 0.35), range(0, math.pi * 2)
			tree(center + Vector3.new(math.cos(a) * r, -0.1, math.sin(a) * r))
		end
	end
	-- Rocks poking out of the lava sea.
	for _ = 1, 40 do
		ball(Vector3.new(range(x0 - 500, x1), baseY - 30, side(60, 600)), range(10, 40), Color3.fromRGB(range(70, 100), range(55, 75), range(45, 60)), Enum.Material.Basalt)
	end
	-- Giant rainbow in the background.
	local colors = {
		Color3.fromRGB(255, 70, 70), Color3.fromRGB(255, 160, 50), Color3.fromRGB(255, 235, 70),
		Color3.fromRGB(80, 220, 100), Color3.fromRGB(70, 160, 255), Color3.fromRGB(110, 90, 255),
		Color3.fromRGB(190, 90, 255),
	}
	local center = Vector3.new((x0 + x1) / 2, baseY - 30, -90)
	for band, color in ipairs(colors) do
		local radius = 90 - band * 3
		local segments = 26
		for i = 0, segments - 1 do
			local a = math.pi * (i + 0.5) / segments
			local length = math.pi * radius / segments + 0.4
			deco({
				Size = Vector3.new(length, 3, 1),
				CFrame = CFrame.new(center + Vector3.new(math.cos(a) * radius, math.sin(a) * radius, 0)) * CFrame.Angles(0, 0, a + math.pi / 2),
				Color = color,
				Material = Enum.Material.Neon,
				Transparency = 0.25,
			})
		end
	end
end

local CANDY = {
	Color3.fromRGB(255, 110, 180), Color3.fromRGB(170, 120, 255), Color3.fromRGB(255, 220, 90),
	Color3.fromRGB(110, 230, 190), Color3.fromRGB(255, 150, 90), Color3.fromRGB(110, 190, 255),
}

local function lollipop(base, height)
	pillar(base + Vector3.new(0, height / 2, 0), height, 0.8, Color3.new(1, 1, 1))
	local top = base + Vector3.new(0, height + 4, 0)
	local face = CFrame.Angles(0, math.rad(90), 0) -- disc faces the path
	local diameter = range(8, 12)
	deco({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.2, diameter, diameter), CFrame = CFrame.new(top) * face, Color = pick(CANDY) })
	local toward = Vector3.new(0, 0, base.Z > 0 and -0.4 or 0.4)
	deco({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.2, diameter * 0.62, diameter * 0.62), CFrame = CFrame.new(top + toward) * face, Color = pick(CANDY) })
	ball(top + toward * 2, diameter * 0.25, Color3.new(1, 1, 1))
end

local function candyCane(base)
	local red, white = Color3.fromRGB(235, 40, 50), Color3.new(1, 1, 1)
	for i = 0, 7 do
		pillar(base + Vector3.new(0, i * 2 + 1, 0), 2, 1.6, i % 2 == 0 and red or white)
	end
	local hookCenter = base + Vector3.new(2.4, 16, 0)
	for i = 0, 5 do
		local a = math.pi * i / 5
		ball(hookCenter + Vector3.new(-math.cos(a) * 2.4, math.sin(a) * 2.4, 0), 1.8, i % 2 == 0 and red or white)
	end
end

local function cupcake(base)
	pillar(base + Vector3.new(0, 2.5, 0), 5, 8, pick(CANDY))
	ball(base + Vector3.new(0, 6, 0), 9, Color3.fromRGB(255, 225, 240))
	ball(base + Vector3.new(0, 10.6, 0), 2.2, Color3.fromRGB(220, 30, 50))
end

local function buildCandy(x0, x1, baseY)
	for _ = 1, 25 do
		cloud(Vector3.new(range(x0, x1), range(baseY - 25, baseY + 35), side(30, 140)), {
			Color3.fromRGB(255, 190, 225), Color3.fromRGB(190, 220, 255), Color3.fromRGB(255, 235, 245),
		})
	end
	for _ = 1, 14 do
		lollipop(Vector3.new(range(x0, x1), baseY - range(18, 26), side(22, 55)), range(14, 22))
	end
	for _ = 1, 10 do
		local center = Vector3.new(range(x0, x1), baseY + range(-14, 4), side(26, 60))
		island(center, center.Y, 12, 2, false)
		if rng:NextNumber() < 0.5 then
			candyCane(center)
		else
			cupcake(center)
		end
	end
	for _ = 1, 22 do
		ball(Vector3.new(range(x0, x1), baseY + range(-20, 25), side(20, 80)), range(3, 7), pick(CANDY), Enum.Material.SmoothPlastic, 0.15)
	end
	-- Gumdrop hills rising out of the strawberry-milk sea.
	for _ = 1, 30 do
		ball(Vector3.new(range(x0 - 40, x1 + 40), baseY - 30, side(70, 600)), range(25, 80), pick(CANDY), Enum.Material.SmoothPlastic, 0.1)
	end
	-- Giant lollipop forest in the distance.
	for _ = 1, 16 do
		lollipop(Vector3.new(range(x0, x1), baseY - 30, side(90, 320)), range(40, 70))
	end
end

local function buildSpace(x0, x1, baseY)
	for _ = 1, 220 do
		local star = ball(
			Vector3.new(range(x0 - 120, x1 + 160), range(baseY - 60, baseY + 160), side(30, 260)),
			range(0.5, 1.6),
			pick({ Color3.new(1, 1, 1), Color3.fromRGB(255, 240, 180), Color3.fromRGB(180, 220, 255) }),
			Enum.Material.Neon
		)
		star.Shape = Enum.PartType.Ball
	end
	local planets = {
		{ Color = Color3.fromRGB(255, 120, 80), Size = 90, Ring = false },
		{ Color = Color3.fromRGB(120, 200, 255), Size = 60, Ring = true },
		{ Color = Color3.fromRGB(200, 120, 255), Size = 130, Ring = false },
		{ Color = Color3.fromRGB(120, 255, 170), Size = 45, Ring = true },
		{ Color = Color3.fromRGB(255, 220, 120), Size = 70, Ring = false },
	}
	for i, planet in ipairs(planets) do
		local position = Vector3.new(x0 + (x1 - x0) * (i - 0.5) / #planets + range(-40, 40), baseY + range(-10, 90), (i % 2 == 0 and 1 or -1) * range(170, 280))
		ball(position, planet.Size, planet.Color)
		if planet.Ring then
			deco({
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(0.6, planet.Size * 2.1, planet.Size * 2.1),
				CFrame = CFrame.new(position) * CFrame.Angles(math.rad(range(-25, 25)), 0, math.rad(70)),
				Color = Color3.fromRGB(240, 230, 255),
				Material = Enum.Material.Neon,
				Transparency = 0.55,
			})
		end
	end
	for _ = 1, 35 do
		ball(Vector3.new(range(x0, x1), baseY + range(-25, 30), side(20, 90)), range(3, 11), Color3.fromRGB(range(80, 130), range(75, 120), range(95, 140)), Enum.Material.Slate)
	end
	-- Far-off planets and a big asteroid belt below the course.
	for _ = 1, 6 do
		ball(Vector3.new(range(x0 - 300, x1 + 400), baseY + range(-150, 200), side(350, 700)), range(60, 200),
			pick({ Color3.fromRGB(255, 150, 120), Color3.fromRGB(140, 180, 255), Color3.fromRGB(220, 160, 255), Color3.fromRGB(150, 255, 210) }))
	end
	for _ = 1, 60 do
		ball(Vector3.new(range(x0 - 100, x1 + 300), baseY - range(40, 120), side(0, 300)), range(6, 22), Color3.fromRGB(range(70, 110), range(65, 100), range(90, 130)), Enum.Material.Slate)
	end
end

-- Gary's Lair: volcanoes with glowing craters, lava falls, floating basalt and Gary banners.
local function volcano(base, height, width)
	local rock = Color3.fromRGB(55, 45, 50)
	local layers = 5
	for i = 0, layers - 1 do
		local w = width * (1 - i / (layers + 1))
		pillar(base + Vector3.new(0, (i + 0.5) * height / layers, 0), height / layers, w, rock, Enum.Material.Basalt)
	end
	local top = base + Vector3.new(0, height, 0)
	pillar(top + Vector3.new(0, 0.3, 0), 0.8, width * 0.25, Color3.fromRGB(255, 110, 20), Enum.Material.Neon)
	-- lava fall down one side
	deco({
		Size = Vector3.new(1.2, height * 0.9, width * 0.08),
		Position = top + Vector3.new(width * 0.22, -height * 0.45, 0),
		Color = Color3.fromRGB(255, 90, 20),
		Material = Enum.Material.Neon,
	})
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 120, 40)
	light.Range = 40
	light.Brightness = 3
	light.Parent = deco({ Size = Vector3.one, Position = top + Vector3.new(0, 3, 0), Transparency = 1 })
end

local function buildLair(x0, x1, baseY)
	local density = math.clamp((x1 - x0) / 600, 1, 2)
	for _ = 1, math.floor(10 * density) do
		volcano(Vector3.new(range(x0 - 60, x1 + 60), baseY - 31, side(60, 400)), range(50, 140), range(40, 90))
	end
	for _ = 1, math.floor(30 * density) do
		ball(Vector3.new(range(x0, x1), baseY + range(-25, 30), side(22, 90)), range(3, 10), Color3.fromRGB(range(50, 80), range(40, 55), range(45, 60)), Enum.Material.Basalt)
	end
	-- Ember sparks hanging in the air
	for _ = 1, math.floor(60 * density) do
		ball(Vector3.new(range(x0, x1), baseY + range(-20, 60), side(15, 160)), range(0.4, 1), Color3.fromRGB(255, range(90, 170), 30), Enum.Material.Neon)
	end
	-- Gary's banners
	for _ = 1, math.floor(8 * density) do
		local p = Vector3.new(range(x0, x1), baseY - 4, side(26, 50))
		pillar(p + Vector3.new(0, 12, 0), 24, 0.8, Color3.fromRGB(40, 30, 30), Enum.Material.Metal)
		deco({ Size = Vector3.new(0.3, 9, 6), Position = p + Vector3.new(0, 18, 3.2 * (p.Z > 0 and -1 or 1)), Color = Color3.fromRGB(110, 40, 150), Material = Enum.Material.Fabric })
		ball(p + Vector3.new(0, 19, 3.4 * (p.Z > 0 and -1 or 1)), 3, Color3.fromRGB(255, 200, 40), Enum.Material.Neon)
	end
end

---------------------------------------------------------------- entry point
-- Optional hero landmarks: import 3D models (e.g. the Higgsfield GLBs) into
-- ServerStorage > Landmarks named "Sky", "Candy" and "Space"; they get placed and scaled here.
local function placeLandmark(name, position, targetSize, yaw)
	local storage = game:GetService("ServerStorage"):FindFirstChild("Landmarks")
	local template = storage and storage:FindFirstChild(name)
	if not template then
		return
	end
	local model = template:Clone()
	if model:IsA("BasePart") then
		local wrapper = Instance.new("Model")
		model.Parent = wrapper
		model = wrapper
	end
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
			d.CanTouch = false
			d.CanQuery = false
		end
	end
	local _, size = model:GetBoundingBox()
	local largest = math.max(size.X, size.Y, size.Z)
	if largest > 0 then
		model:ScaleTo(model:GetScale() * targetSize / largest)
	end
	model:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0))
	model.Parent = folder
end

local function buildHub(center, diameter, baseY)
	island(center, baseY - 0.55, diameter, 2, true)
	local padTop = baseY - 0.05
	-- Fountain with glowing water.
	pillar(center + Vector3.new(0, padTop - baseY + 1, 8), 2, 14, Color3.fromRGB(240, 240, 250), Enum.Material.Marble)
	pillar(center + Vector3.new(0, padTop - baseY + 1.6, 8), 1.4, 12, Color3.fromRGB(110, 200, 255), Enum.Material.Neon)
	pillar(center + Vector3.new(0, padTop - baseY + 4, 8), 5, 2, Color3.fromRGB(240, 240, 250), Enum.Material.Marble)
	ball(center + Vector3.new(0, padTop - baseY + 7, 8), 3, Color3.fromRGB(255, 205, 40), Enum.Material.Neon)
	-- Golden lamp posts around the edge.
	for i = 0, 7 do
		local a = math.pi * 2 * i / 8
		local p = center + Vector3.new(math.cos(a) * (diameter / 2 - 4), padTop - baseY, math.sin(a) * (diameter / 2 - 4))
		pillar(p + Vector3.new(0, 4, 0), 8, 0.6, Color3.fromRGB(60, 50, 40), Enum.Material.Metal)
		ball(p + Vector3.new(0, 8.5, 0), 1.6, Color3.fromRGB(255, 230, 150), Enum.Material.Neon)
	end
end

-- Greedy Gary, the villain: a giant goblin with a top hat, monocle and a sack of stolen coins.
-- His speech bubble (tag "GaryTaunt") is updated by Villain.server.
local function gary(position, scale, facing, gold)
	local before = {}
	for _, child in ipairs(folder:GetChildren()) do
		before[child] = true
	end
	local cf = CFrame.lookAt(position, position + facing)
	local function at(x, y, z)
		return (cf * CFrame.new(x * scale, y * scale, -z * scale)).Position
	end
	local green = Color3.fromRGB(110, 190, 70)
	local suit = Color3.fromRGB(110, 40, 150)
	pillar(at(0, 4, 0), 8 * scale, 7 * scale, suit) -- body
	ball(at(0, 10.5, 0), 8 * scale, green) -- head
	for _, side in ipairs({ -1, 1 }) do
		ball(at(side * 4.6, 11.5, 0), 2.6 * scale, green) -- ears
		ball(at(side * 1.6, 11.6, 3.4), 2 * scale, Color3.new(1, 1, 1)) -- eyes
		ball(at(side * 1.6, 11.6, 4.2), 0.9 * scale, Color3.new(0, 0, 0))
		ball(at(side * 4.2, 3.5, 1.5), 2.4 * scale, green) -- hands
	end
	deco({ -- monocle
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.3 * scale, 2.6 * scale, 2.6 * scale),
		CFrame = CFrame.new(at(1.6, 11.6, 4.5)) * cf.Rotation * CFrame.Angles(0, math.rad(90), 0),
		Color = Color3.fromRGB(255, 200, 40),
		Material = Enum.Material.Metal,
		Transparency = 0.3,
	})
	deco({ Size = Vector3.new(4.2, 0.7, 0.4) * scale, CFrame = CFrame.new(at(0, 9, 3.9)) * cf.Rotation, Color = Color3.fromRGB(40, 10, 10) }) -- grin
	pillar(at(0, 14.6, 0), 0.6 * scale, 8 * scale, Color3.fromRGB(20, 20, 25)) -- hat brim
	pillar(at(0, 17, 0), 4.5 * scale, 5 * scale, Color3.fromRGB(20, 20, 25)) -- hat
	pillar(at(0, 15.6, 0), 0.8 * scale, 5.1 * scale, Color3.fromRGB(200, 30, 60)) -- hat band
	ball(at(5.5, 4, -1), 6 * scale, Color3.fromRGB(150, 110, 60)) -- coin sack
	for i = 1, 5 do
		ball(at(5.5 + math.cos(i) * 1.5, 7 + i * 0.2, -1 + math.sin(i) * 1.5), 1.2 * scale, Color3.fromRGB(255, 205, 40), Enum.Material.Neon)
	end
	local anchor = deco({ Size = Vector3.one, Position = at(0, 21, 0), Transparency = 1 })
	local gui = Instance.new("BillboardGui")
	gui.Name = "GaryTaunt"
	gui.Size = UDim2.fromOffset(360, 90)
	gui.MaxDistance = 400
	gui.LightInfluence = 0
	local bubble = Instance.new("TextLabel")
	bubble.Size = UDim2.fromScale(1, 1)
	bubble.BackgroundColor3 = Color3.new(1, 1, 1)
	bubble.Font = Enum.Font.FredokaOne
	bubble.TextScaled = true
	bubble.TextColor3 = Color3.fromRGB(110, 40, 150)
	bubble.Text = "GREEDY GARY: You'll never escape!"
	bubble.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = bubble
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = bubble
	gui.Parent = anchor
	game:GetService("CollectionService"):AddTag(gui, "GaryTaunt")
	-- Statue version: everything solid polished gold (except his pupils, so he still stares at you).
	if gold then
		for _, child in ipairs(folder:GetChildren()) do
			if not before[child] and child:IsA("BasePart") and child.Transparency < 1 then
				if child.Color ~= Color3.new(0, 0, 0) then
					child.Color = GOLD
					child.Material = Enum.Material.Foil
					child.Transparency = 0
				end
				child.CastShadow = true
			end
		end
		local shine = deco({ Size = Vector3.one, Position = at(0, 10, 4), Transparency = 1 })
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 220, 120)
		light.Range = 30
		light.Brightness = 2
		light.Parent = shine
		local sparkle = Instance.new("ParticleEmitter")
		sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 230, 120))
		sparkle.LightEmission = 1
		sparkle.Rate = 12
		sparkle.Lifetime = NumberRange.new(1, 2)
		sparkle.Speed = NumberRange.new(2, 5)
		sparkle.SpreadAngle = Vector2.new(180, 180)
		sparkle.Size = NumberSequence.new(0.6, 0)
		sparkle.Parent = shine
	end
end
garyModel = gary

-- opts: { Stages, Spacing, BaseY, Zones (Config.Zones), ZoneIndex = function(stage), HubCenter, HubDiameter }
function Scenery.Build(opts)
	folder = Instance.new("Folder")
	folder.Name = "Scenery"

	local spacing, baseY = opts.Spacing, opts.BaseY
	local padTop = baseY + 0.5

	-- Islands + flags under every checkpoint.
	for stage = 1, opts.Stages do
		local x = (stage - 1) * spacing
		local zIndex = opts.ZoneIndex(stage)
		local isFinal = stage == opts.Stages
		if stage ~= 1 then
			island(Vector3.new(x, 0, 0), baseY - 0.55, isFinal and 20 or 15, zIndex, true)
		end
		if not isFinal then
			flag(Vector3.new(x + 4.5, padTop, 4.5), FLAG_COLORS[zIndex] or FLAG_COLORS[1], zIndex == 3)
		end
	end

	-- Spawn plaza: a big luxury island with the Hall of Fame, golden Gary statue, portals and NPCs.
	local LOBBY = Config.Lobby.Center
	island(LOBBY, baseY - 0.55, Config.Lobby.Diameter, 1, true)
	luxuryLobby(LOBBY, baseY)
	-- Title sign above the Hall of Fame wall.
	sign(Vector3.new(Config.Lobby.WallX - 1.5, baseY + 36, 0), Vector3.new(1, 0, 0), Vector3.new(52, 11, 1), "ESCAPE GREEDY GARY!", opts.Stages .. " STORY STAGES  •  1000-STAGE OP TOWER  •  OBBY RACE", Color3.fromRGB(255, 215, 60))

	-- Everything built so far (lobby, checkpoint islands) survives the plaza cleanup below.
	for _, p in ipairs(folder:GetChildren()) do
		p:SetAttribute("Keep", true)
	end

	-- World scenery.
	local zones = opts.Zones
	local builders = { buildSky, buildCandy, buildSpace, buildLair }
	for i, zone in ipairs(zones) do
		local builder = builders[i]
		if builder then
			local x0 = (zone.FirstStage - 1) * spacing
			local x1 = zones[i + 1] and (zones[i + 1].FirstStage - 1) * spacing or (opts.Stages - 1) * spacing
			builder(x0, x1, baseY)
		end
	end

	-- Gates at the start of each new world.
	if zones[2] then
		gate((zones[2].FirstStage - 1) * spacing - 7, baseY - 1, 16, { Color3.fromRGB(255, 110, 180), Color3.new(1, 1, 1) }, Enum.Material.SmoothPlastic)
	end
	if zones[3] then
		gate((zones[3].FirstStage - 1) * spacing - 7, baseY - 1, 16, { Color3.fromRGB(80, 230, 255), Color3.fromRGB(190, 90, 255) }, Enum.Material.Neon)
	end
	if zones[4] then
		gate((zones[4].FirstStage - 1) * spacing - 7, baseY - 1, 17, { Color3.fromRGB(255, 90, 20), Color3.fromRGB(40, 30, 30) }, Enum.Material.Neon)
	end

	-- Keep the spawn plaza clear of world decoration.
	for _, p in ipairs(folder:GetChildren()) do
		local offset = p.Position - Vector3.new(LOBBY.X, baseY, LOBBY.Z)
		if Vector2.new(offset.X, offset.Z).Magnitude < Config.Lobby.Diameter / 2 + 12 and offset.Y > -40 and offset.Y < 60 and not p:GetAttribute("Keep") then
			p:Destroy()
		end
	end

	-- Clear decoration that would poke through the hub island, then build the hub.
	if opts.HubCenter then
		local hub = opts.HubCenter
		local clearRadius = opts.HubDiameter / 2 + 14
		for _, p in ipairs(folder:GetChildren()) do
			local offset = p.Position - hub
			if Vector2.new(offset.X, offset.Z).Magnitude < clearRadius and offset.Y > -40 then
				p:Destroy()
			end
		end
		buildHub(hub, opts.HubDiameter, baseY)
	end

	-- Hero landmarks (only if you've imported them into ServerStorage > Landmarks).
	placeLandmark("Sky", Vector3.new(4 * spacing, baseY + 10, -140), 120, 30)
	if zones[2] then
		placeLandmark("Candy", Vector3.new(((zones[2].FirstStage - 1) + 4) * spacing, baseY, 150), 130, 200)
	end
	if zones[3] then
		placeLandmark("Space", Vector3.new(((zones[3].FirstStage - 1) + 8) * spacing, baseY + 40, -170), 160, 0)
	end

	-- Greedy Gary looms over the hub and the finish (the lobby has his golden statue).
	if opts.HubCenter then
		gary(opts.HubCenter + Vector3.new(0, 30, -36), 1.6, Vector3.new(0, 0, 1))
	end
	gary(Vector3.new((opts.Stages - 1) * spacing + 40, baseY - 4, -10), 1.8, Vector3.new(-1, 0, 0.3).Unit)

	-- Finish: golden arch and a giant trophy.
	local finishX = (opts.Stages - 1) * spacing
	gate(finishX - 9, baseY - 1, 18, { Color3.fromRGB(255, 205, 40), Color3.fromRGB(255, 240, 150) }, Enum.Material.Neon)
	local gold = Color3.fromRGB(255, 200, 40)
	local trophyBase = Vector3.new(finishX + 16, padTop, 0)
	pillar(trophyBase + Vector3.new(0, 1.5, 0), 3, 9, Color3.fromRGB(60, 45, 30), Enum.Material.Wood)
	pillar(trophyBase + Vector3.new(0, 6, 0), 6, 2, gold, Enum.Material.Metal)
	ball(trophyBase + Vector3.new(0, 13, 0), 11, gold, Enum.Material.Metal)
	for _, z in ipairs({ -6.5, 6.5 }) do
		ball(trophyBase + Vector3.new(0, 14, z), 3.5, gold, Enum.Material.Metal)
	end
	ball(trophyBase + Vector3.new(0, 20, 0), 3, Color3.new(1, 1, 1), Enum.Material.Neon)

	folder.Parent = workspace
end

return Scenery
