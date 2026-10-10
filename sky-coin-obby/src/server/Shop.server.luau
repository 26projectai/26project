-- Cosmetic shop: handles Buy / Equip / Unequip and puts trails + auras on characters.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Catalog = require(Shared:WaitForChild("ShopCatalog"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

local function cosmetic(className, parent)
	local inst = Instance.new(className)
	inst:SetAttribute("Cosmetic", true)
	inst.Parent = parent
	return inst
end

local function clearCosmetics(character)
	for _, d in ipairs(character:GetDescendants()) do
		if d:GetAttribute("Cosmetic") then
			d:Destroy()
		end
	end
end

local function addTrail(root, item)
	local top = cosmetic("Attachment", root)
	top.Position = Vector3.new(0, 0.9, 0.4)
	local bottom = cosmetic("Attachment", root)
	bottom.Position = Vector3.new(0, -0.9, 0.4)

	local trail = Instance.new("Trail")
	trail:SetAttribute("Cosmetic", true)
	trail.Attachment0 = top
	trail.Attachment1 = bottom
	trail.Color = item.Color
	trail.Lifetime = 0.7
	trail.LightEmission = 0.6
	trail.FaceCamera = true
	trail.Transparency = NumberSequence.new(0.1, 1)
	trail.WidthScale = NumberSequence.new(1, 0.3)
	trail.Parent = root
end

local function addAura(character, root, item)
	if item.Kind == "Sparkles" then
		local emitter = Instance.new("ParticleEmitter")
		emitter:SetAttribute("Cosmetic", true)
		emitter.Color = item.Color
		emitter.LightEmission = 1
		emitter.Rate = 18
		emitter.Lifetime = NumberRange.new(0.8, 1.4)
		emitter.Speed = NumberRange.new(1, 3)
		emitter.SpreadAngle = Vector2.new(180, 180)
		emitter.Size = NumberSequence.new(0.45, 0)
		emitter.Parent = root
	elseif item.Kind == "Bubbles" then
		local emitter = Instance.new("ParticleEmitter")
		emitter:SetAttribute("Cosmetic", true)
		emitter.Color = item.Color
		emitter.LightEmission = 0.3
		emitter.Transparency = NumberSequence.new(0.3, 1)
		emitter.Rate = 8
		emitter.Lifetime = NumberRange.new(1.5, 2.5)
		emitter.Speed = NumberRange.new(1, 2)
		emitter.Acceleration = Vector3.new(0, 3, 0)
		emitter.SpreadAngle = Vector2.new(180, 180)
		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.3, 0.8),
			NumberSequenceKeypoint.new(1, 1),
		})
		emitter.Parent = root
	elseif item.Kind == "Fire" then
		local fire = Instance.new("Fire")
		fire:SetAttribute("Cosmetic", true)
		fire.Color = item.Color
		fire.SecondaryColor = item.SecondaryColor
		fire.Size = 6
		fire.Heat = 4
		fire.Parent = root
	elseif item.Kind == "Particles" then
		local emitter = Instance.new("ParticleEmitter")
		emitter:SetAttribute("Cosmetic", true)
		emitter.Color = item.Color
		emitter.LightEmission = 0.8
		emitter.Rate = item.Rate or 15
		emitter.Lifetime = NumberRange.new(1, 1.8)
		emitter.Speed = NumberRange.new(0.5, 2)
		emitter.Acceleration = item.Accel or Vector3.zero
		emitter.SpreadAngle = Vector2.new(180, 180)
		emitter.Size = NumberSequence.new(item.Size or 0.4, 0)
		if item.Above then
			local att = cosmetic("Attachment", root)
			att.Position = Vector3.new(0, 4, 0)
			emitter.Parent = att
		else
			emitter.Parent = root
		end
	elseif item.Kind == "Smoke" then
		local smoke = Instance.new("Smoke")
		smoke:SetAttribute("Cosmetic", true)
		smoke.Color = item.Color
		smoke.Opacity = 0.25
		smoke.Size = 1.5
		smoke.RiseVelocity = 1.5
		smoke.Parent = root
	elseif item.Kind == "Glow" then
		local highlight = Instance.new("Highlight")
		highlight:SetAttribute("Cosmetic", true)
		highlight.FillColor = item.Color
		highlight.FillTransparency = 0.55
		highlight.OutlineColor = Color3.fromRGB(255, 245, 200)
		highlight.Parent = character
		local light = Instance.new("PointLight")
		light:SetAttribute("Cosmetic", true)
		light.Color = item.Color
		light.Range = 12
		light.Brightness = 2
		light.Parent = root
	end
end

-- A glowing ring floating above the head.
local function addHalo(character, item)
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end
	local halo = Instance.new("Part")
	halo:SetAttribute("Cosmetic", true)
	halo.Name = "Halo"
	halo.Shape = Enum.PartType.Cylinder
	halo.Size = Vector3.new(0.2, 2.4, 2.4)
	halo.Color = item.Color
	halo.Material = Enum.Material.Neon
	halo.Transparency = 0.15
	halo.CanCollide = false
	halo.CanQuery = false
	halo.CanTouch = false
	halo.Massless = true
	halo.CFrame = head.CFrame * CFrame.new(0, 1.6, 0) * CFrame.Angles(0, 0, math.rad(90))
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = head
	weld.Part1 = halo
	weld.Parent = halo
	local light = Instance.new("PointLight")
	light.Color = item.Color
	light.Range = 8
	light.Parent = halo
	halo.Parent = character
end

---------------------------------------------------------------- Hats, wings and pets (built from parts)
-- Each piece is welded to the head / root, massless and non-colliding, so it never affects movement.
local function piece(character, anchor, offset, props)
	local p = Instance.new("Part")
	p:SetAttribute("Cosmetic", true)
	p.Name = "Cosmetic"
	p.Anchored = false
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for key, value in pairs(props) do
		p[key] = value
	end
	p.CFrame = anchor.CFrame * offset
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = anchor
	weld.Part1 = p
	weld.Parent = p
	p.Parent = character
	return p
end

local UP = CFrame.Angles(0, 0, math.rad(90)) -- stands a cylinder upright
local GOLD = Color3.fromRGB(255, 200, 40)

local function addHat(character, item)
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end
	local top = head.Size.Y / 2
	local c = item.Color
	if item.Kind == "PartyHat" then
		for k = 0, 4 do
			local d = 1.3 - k * 0.26
			piece(character, head, CFrame.new(0, top + 0.15 + k * 0.28, 0) * UP, {
				Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, d, d),
				Color = k % 2 == 0 and c or Color3.fromRGB(255, 230, 80),
			})
		end
		piece(character, head, CFrame.new(0, top + 1.6, 0), { Shape = Enum.PartType.Ball, Size = Vector3.one * 0.4, Color = Color3.new(1, 1, 1), Material = Enum.Material.Neon })
	elseif item.Kind == "CatEars" then
		for _, side in ipairs({ -1, 1 }) do
			piece(character, head, CFrame.new(side * 0.45, top + 0.3, 0) * CFrame.Angles(0, math.rad(90), math.rad(side * -12)), {
				Size = Vector3.new(0.2, 0.7, 0.55), Color = c,
			})
			piece(character, head, CFrame.new(side * 0.45, top + 0.27, -0.05) * CFrame.Angles(0, 0, math.rad(side * -12)), {
				Size = Vector3.new(0.3, 0.45, 0.1), Color = Color3.fromRGB(255, 220, 230),
			})
		end
	elseif item.Kind == "TopHat" then
		piece(character, head, CFrame.new(0, top + 0.05, 0) * UP, { Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.12, 1.9, 1.9), Color = c })
		piece(character, head, CFrame.new(0, top + 0.65, 0) * UP, { Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.1, 1.25, 1.25), Color = c })
		piece(character, head, CFrame.new(0, top + 0.3, 0) * UP, { Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.22, 1.28, 1.28), Color = GOLD, Material = Enum.Material.Metal })
	elseif item.Kind == "Horns" then
		for _, side in ipairs({ -1, 1 }) do
			piece(character, head, CFrame.new(side * 0.4, top + 0.25, 0) * CFrame.Angles(0, 0, math.rad(side * -25)) * UP, {
				Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.6, 0.32, 0.32), Color = c,
			})
			piece(character, head, CFrame.new(side * 0.55, top + 0.55, 0), { Shape = Enum.PartType.Ball, Size = Vector3.one * 0.25, Color = c, Material = Enum.Material.Neon })
		end
	elseif item.Kind == "Crown" then
		piece(character, head, CFrame.new(0, top + 0.2, 0) * UP, { Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.35, 1.35, 1.35), Color = c, Material = Enum.Material.Metal })
		for k = 0, 5 do
			local a = math.pi * 2 * k / 6
			piece(character, head, CFrame.new(math.cos(a) * 0.6, top + 0.55, math.sin(a) * 0.6) * CFrame.Angles(0, -a, 0), {
				Size = Vector3.new(0.18, 0.45, 0.3), Color = c, Material = Enum.Material.Metal,
			})
			piece(character, head, CFrame.new(math.cos(a) * 0.62, top + 0.82, math.sin(a) * 0.62), {
				Shape = Enum.PartType.Ball, Size = Vector3.one * 0.2,
				Color = k % 2 == 0 and Color3.fromRGB(255, 40, 90) or Color3.fromRGB(60, 160, 255), Material = Enum.Material.Neon,
			})
		end
	end
end

local function addBack(character, root, item)
	if item.Kind == "Jetpack" then
		for _, side in ipairs({ -0.45, 0.45 }) do
			piece(character, root, CFrame.new(side, 0.2, 0.75) * UP, {
				Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.6, 0.7, 0.7), Color = item.Color, Material = Enum.Material.Metal,
			})
			local nozzle = piece(character, root, CFrame.new(side, -0.75, 0.75), { Size = Vector3.new(0.4, 0.3, 0.4), Color = Color3.fromRGB(60, 60, 70), Material = Enum.Material.Metal })
			local fire = Instance.new("Fire")
			fire.Size = 2
			fire.Heat = -6
			fire.Parent = nozzle
			piece(character, root, CFrame.new(side, 1.05, 0.75), { Shape = Enum.PartType.Ball, Size = Vector3.one * 0.7, Color = Color3.fromRGB(255, 70, 70) })
		end
		return
	end
	-- Wings: three feathers per side, fanned out.
	for _, side in ipairs({ -1, 1 }) do
		for k = 0, 2 do
			local length = 2.6 - k * 0.5
			piece(character, root, CFrame.new(side * 0.4, 0.5, 0.65)
				* CFrame.Angles(0, side * math.rad(-20), side * math.rad(-60 + k * 30))
				* CFrame.new(side * length / 2, 0, 0), {
				Size = Vector3.new(length, 0.55, 0.12),
				Color = item.Color,
				Material = item.Neon and Enum.Material.Neon or Enum.Material.SmoothPlastic,
				Transparency = item.Transparency or 0,
			})
		end
	end
end

local function addPet(character, root, item)
	local c = item.Color
	local offset = CFrame.new(2.6, 1.6, 1.2)
	local body
	if item.Kind == "Coin" then
		body = piece(character, root, offset * CFrame.Angles(0, math.rad(90), 0), { Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.35, 1.5, 1.5), Color = c, Material = Enum.Material.Metal })
	else
		body = piece(character, root, offset, {
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * (item.Kind == "Dragon" and 1.7 or 1.4),
			Color = c,
			Material = (item.Kind == "Star" or item.Kind == "Dragon") and Enum.Material.Neon or Enum.Material.SmoothPlastic,
			Transparency = item.Kind == "Ghost" and 0.25 or 0,
		})
	end
	-- face (looks forward, same way as the player)
	for _, side in ipairs({ -0.25, 0.25 }) do
		piece(character, root, offset * CFrame.new(side, 0.15, -0.62), { Shape = Enum.PartType.Ball, Size = Vector3.one * 0.32, Color = Color3.new(1, 1, 1) })
		piece(character, root, offset * CFrame.new(side, 0.15, -0.76), { Shape = Enum.PartType.Ball, Size = Vector3.one * 0.16, Color = Color3.new(0, 0, 0) })
	end
	if item.Kind == "Gary" then
		piece(character, root, offset * CFrame.new(0, 0.75, 0) * UP, { Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.6, 0.7, 0.7), Color = Color3.fromRGB(30, 25, 35) })
		piece(character, root, offset * CFrame.new(0, 0.45, 0) * UP, { Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.08, 1.1, 1.1), Color = Color3.fromRGB(30, 25, 35) })
	elseif item.Kind == "Dragon" then
		for _, side in ipairs({ -1, 1 }) do
			piece(character, root, offset * CFrame.new(side * 0.9, 0.3, 0.2) * CFrame.Angles(0, 0, side * math.rad(-30)), { Size = Vector3.new(1, 0.1, 0.7), Color = Color3.fromRGB(200, 30, 30), Material = Enum.Material.Neon })
		end
	end
	if item.Kind == "Star" or item.Kind == "Dragon" or item.Kind == "Coin" then
		local sparkle = Instance.new("ParticleEmitter")
		sparkle.Color = ColorSequence.new(c)
		sparkle.LightEmission = 1
		sparkle.Rate = 6
		sparkle.Lifetime = NumberRange.new(0.6, 1)
		sparkle.Speed = NumberRange.new(0.5, 1)
		sparkle.Size = NumberSequence.new(0.25, 0)
		sparkle.Parent = body
	end
	local tag = Instance.new("BillboardGui")
	tag.Size = UDim2.fromOffset(110, 22)
	tag.StudsOffset = Vector3.new(0, 1.3, 0)
	tag.MaxDistance = 40
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 230, 120)
	label.TextStrokeTransparency = 0
	label.Text = ("+%d%% coins"):format(math.floor((item.CoinBoost or 0) * 100 + 0.5))
	label.Parent = tag
	tag.Parent = body
end

local function applyCosmetics(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local data, session = PlayerData.Get(player), PlayerData.Session(player)
	if not root or not data then
		return
	end
	clearCosmetics(character)
	for _, itemId in pairs(data.Equipped) do
		local item = Catalog.Get(itemId)
		if item and (data.Owned[itemId] or (item.RequiresVIP and session.Passes.VIP)) then
			if item.Slot == "Trail" then
				addTrail(root, item)
			elseif item.Slot == "Aura" then
				addAura(character, root, item)
			elseif item.Slot == "Halo" then
				addHalo(character, item)
			elseif item.Slot == "Hat" then
				addHat(character, item)
			elseif item.Slot == "Back" then
				addBack(character, root, item)
			elseif item.Slot == "Pet" then
				addPet(character, root, item)
			end
		end
	end
end

local lastRequest = {}
Remotes.ShopAction.OnServerInvoke = function(player, action, itemId)
	-- Light rate limit so spam-clicking can't hammer the server.
	local now = os.clock()
	if lastRequest[player] and now - lastRequest[player] < 0.25 then
		return false, "Slow down!"
	end
	lastRequest[player] = now

	if type(action) ~= "string" or type(itemId) ~= "string" then
		return false, "Bad request"
	end
	local item = Catalog.Get(itemId)
	local data = PlayerData.Get(player)
	if not item then
		return false, "Unknown item"
	end
	if not data then
		return false, "Still loading, try again"
	end

	local message
	local isVIP = PlayerData.Session(player).Passes.VIP
	if item.RequiresVIP and not isVIP then
		return false, "This item is for VIP pass owners"
	end
	if item.RequiresVIP and action ~= "Unequip" then
		data.Owned[itemId] = true -- VIP items are free
	end

	if item.UnlockText and not data.Owned[itemId] then
		return false, item.UnlockText .. " to unlock this!"
	end

	if action == "Buy" then
		if data.Owned[itemId] and not item.RequiresVIP then
			return false, "You already own this"
		end
		local lock = Catalog.LockText(item, data.MaxStage, math.max(data.MaxOPStage or 1, data.OPStage or 1))
		if lock then
			return false, ("Reach %s to unlock this!"):format(lock)
		end
		if item.Price > 0 and not PlayerData.SpendCoins(player, item.Price) then
			return false, ("You need %d more coins"):format(item.Price - data.Coins)
		end
		data.Owned[itemId] = true
		data.Equipped[item.Slot] = itemId
		message = "Bought " .. item.Name .. "!"
	elseif action == "Equip" then
		if not data.Owned[itemId] then
			return false, "You don't own this yet"
		end
		data.Equipped[item.Slot] = itemId
		message = "Equipped " .. item.Name
	elseif action == "Unequip" then
		if data.Equipped[item.Slot] == itemId then
			data.Equipped[item.Slot] = nil
		end
		message = "Unequipped " .. item.Name
	else
		return false, "Bad request"
	end

	applyCosmetics(player)
	PlayerData.Sync(player)
	return true, message
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart", 10)
		PlayerData.WaitFor(player)
		applyCosmetics(player)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
	if player.Character then
		task.spawn(applyCosmetics, player)
	end
end
Players.PlayerRemoving:Connect(function(player)
	lastRequest[player] = nil
end)
