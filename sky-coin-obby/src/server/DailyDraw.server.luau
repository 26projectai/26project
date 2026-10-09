-- Free Daily Draw (every Config.DrawCooldownHours): Common / Rare / Legendary.
-- The prize lasts until the next draw is available: jump boots, a smoke aura, a name tag
-- (Rare+ can set a filtered nickname) and, for Legendary, +50% coins and a flame trail.
-- No Robux involved, and the odds are shown in-game.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TextService = game:GetService("TextService")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Server = ServerScriptService:WaitForChild("Server")
local PlayerData = require(Server:WaitForChild("PlayerData"))
local Abilities = require(Server:WaitForChild("Abilities"))

local rng = Random.new()

local function roll()
	local total = 0
	for _, rarity in ipairs(Config.DrawRarities) do
		total += rarity.Chance
	end
	local pick = rng:NextNumber(0, total)
	for _, rarity in ipairs(Config.DrawRarities) do
		pick -= rarity.Chance
		if pick <= 0 then
			return rarity
		end
	end
	return Config.DrawRarities[1]
end

---------------------------------------------------------------- Visual effects
local AURAS = {
	Small = { Size = 0.6, Opacity = 0.08, RiseVelocity = 1, Color = Color3.fromRGB(230, 230, 240) },
	Medium = { Size = 1.4, Opacity = 0.14, RiseVelocity = 2, Color = Color3.fromRGB(120, 180, 255) },
	Super = { Size = 2.6, Opacity = 0.2, RiseVelocity = 3, Color = Color3.fromRGB(190, 110, 255) },
}

local TAG_STYLES = {
	Silver = { Color = Color3.fromRGB(215, 220, 230), Prefix = "" },
	Gold = { Color = Color3.fromRGB(255, 205, 50), Prefix = "★ " },
	Legendary = { Color = Color3.new(1, 1, 1), Prefix = "👑 ", Rainbow = true },
}

local function clearEffects(character)
	for _, d in ipairs(character:GetDescendants()) do
		if d:GetAttribute("DrawFx") then
			d:Destroy()
		end
	end
end

local function fx(className, parent)
	local inst = Instance.new(className)
	inst:SetAttribute("DrawFx", true)
	inst.Parent = parent
	return inst
end

local function applyEffects(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local head = character and character:FindFirstChild("Head")
	if not root or not head then
		return
	end
	clearEffects(character)
	local rarity = PlayerData.ActiveDraw(player)
	if not rarity then
		return
	end
	local data = PlayerData.Get(player)

	-- Smoke aura
	local aura = AURAS[rarity.Aura]
	if aura then
		local smoke = fx("Smoke", root)
		smoke.Size = aura.Size
		smoke.Opacity = aura.Opacity
		smoke.RiseVelocity = aura.RiseVelocity
		smoke.Color = aura.Color
	end
	if rarity.Aura == "Super" then
		local sparkles = fx("ParticleEmitter", root)
		sparkles.Color = ColorSequence.new(Color3.fromRGB(255, 220, 80), Color3.fromRGB(255, 120, 255))
		sparkles.LightEmission = 1
		sparkles.Size = NumberSequence.new(0.5, 0)
		sparkles.Rate = 25
		sparkles.Lifetime = NumberRange.new(0.8, 1.5)
		sparkles.Speed = NumberRange.new(2, 5)
		sparkles.SpreadAngle = Vector2.new(180, 180)
		local light = fx("PointLight", root)
		light.Color = Color3.fromRGB(255, 200, 120)
		light.Range = 14
		light.Brightness = 2
	end

	-- Legendary flame trail
	if rarity.Trail then
		local top = fx("Attachment", root)
		top.Position = Vector3.new(0, 1, 0.5)
		local bottom = fx("Attachment", root)
		bottom.Position = Vector3.new(0, -1, 0.5)
		local trail = fx("Trail", root)
		trail.Attachment0 = top
		trail.Attachment1 = bottom
		trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 120)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 80, 200)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 60, 255)),
		})
		trail.LightEmission = 1
		trail.Lifetime = 0.9
		trail.FaceCamera = true
		trail.Transparency = NumberSequence.new(0, 1)
	end

	-- Name tag
	local style = TAG_STYLES[rarity.Tag]
	if style then
		local gui = fx("BillboardGui", head)
		gui.Size = UDim2.fromOffset(200, 40)
		gui.StudsOffset = Vector3.new(0, 2.6, 0)
		gui.MaxDistance = 80
		gui.Adornee = head
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.FredokaOne
		label.TextScaled = true
		label.TextStrokeTransparency = 0
		label.TextColor3 = style.Color
		local nickname = rarity.Nickname and data.Draw.Nickname
		local name = (nickname and nickname ~= "") and nickname or player.DisplayName
		label.Text = style.Prefix .. name
		label.Parent = gui
		if style.Rainbow then
			local gradient = Instance.new("UIGradient")
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
				ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 220, 60)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 255, 140)),
				ColorSequenceKeypoint.new(0.75, Color3.fromRGB(80, 160, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 90, 255)),
			})
			gradient.Parent = label
			CollectionService:AddTag(gradient, "RainbowGradient") -- animated on clients
		end
	end
end

local function refresh(player)
	Abilities.Grant(player) -- updates the JumpBoost attribute
	applyEffects(player)
	PlayerData.Sync(player)
end

---------------------------------------------------------------- Remotes
Remotes.DailyDraw.OnServerInvoke = function(player)
	local data = PlayerData.Get(player)
	if not data then
		return false, "Still loading, try again"
	end
	local waitSeconds = Config.DrawCooldownHours * 3600 - (os.time() - data.LastDraw)
	if waitSeconds > 0 then
		return false, ("Next draw in %dh %dm"):format(waitSeconds // 3600, (waitSeconds % 3600) // 60)
	end
	local rarity = roll()
	local oldNickname = data.Draw and data.Draw.Nickname or ""
	data.LastDraw = os.time()
	data.Draw = {
		Rarity = rarity.Name,
		Expires = os.time() + Config.DrawCooldownHours * 3600,
		Nickname = rarity.Nickname and oldNickname or "",
	}
	refresh(player)
	return true, rarity.Name
end

Remotes.SetNickname.OnServerInvoke = function(player, text)
	local rarity = PlayerData.ActiveDraw(player)
	if not rarity or not rarity.Nickname then
		return false, "Nicknames need a Rare or Legendary draw"
	end
	if type(text) ~= "string" then
		return false, "Bad nickname"
	end
	text = text:gsub("^%s+", ""):gsub("%s+$", "")
	if #text < 1 or utf8.len(text) == nil or utf8.len(text) > 20 then
		return false, "Nicknames must be 1-20 characters"
	end
	-- Roblox text filtering is required for any player-written text shown to others.
	local ok, filtered = pcall(function()
		local result = TextService:FilterStringAsync(text, player.UserId, Enum.TextFilterContext.PublicChat)
		return result:GetNonChatStringForBroadcastAsync()
	end)
	if not ok or not filtered or filtered:find("#") then
		return false, "That nickname isn't allowed - try another"
	end
	PlayerData.Get(player).Draw.Nickname = filtered
	applyEffects(player)
	return true, "Nickname set to " .. filtered
end

---------------------------------------------------------------- Lifecycle
local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Head", 10)
		PlayerData.WaitFor(player)
		applyEffects(player)
	end)
	task.spawn(function()
		PlayerData.WaitFor(player)
		refresh(player)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Expire prizes when their time is up.
while true do
	task.wait(30)
	for _, player in ipairs(Players:GetPlayers()) do
		local data = PlayerData.Get(player)
		if data and data.Draw and os.time() >= (data.Draw.Expires or 0) and player:GetAttribute("JumpBoost") ~= 1 then
			refresh(player)
		end
	end
end
