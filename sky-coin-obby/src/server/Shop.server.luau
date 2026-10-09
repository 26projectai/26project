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

	if action == "Buy" then
		if data.Owned[itemId] and not item.RequiresVIP then
			return false, "You already own this"
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
