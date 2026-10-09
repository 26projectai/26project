-- Co-op: tether with a friend (both earn Config.TetherMultiplier coins while tethered),
-- and the Teamwork Vault in the hub, which only opens while two players stand on its plates.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

---------------------------------------------------------------- Tether
local pending = {} -- [requester] = { Target = Player, At = os.clock() }
local ropes = {} -- [Player] = RopeConstraint (stored on both players of a pair)

local function partnerOf(player)
	local session = PlayerData.Session(player)
	return session and session.TetheredWith and Players:GetPlayerByUserId(session.TetheredWith)
end

local function removeRope(player)
	local rope = ropes[player]
	if rope then
		rope:Destroy()
	end
	ropes[player] = nil
end

local function attachRope(a, b)
	removeRope(a)
	removeRope(b)
	local rootA = a.Character and a.Character:FindFirstChild("HumanoidRootPart")
	local rootB = b.Character and b.Character:FindFirstChild("HumanoidRootPart")
	if not rootA or not rootB then
		return
	end
	local att0 = Instance.new("Attachment")
	att0.Name = "TetherAttachment"
	att0.Parent = rootA
	local att1 = Instance.new("Attachment")
	att1.Name = "TetherAttachment"
	att1.Parent = rootB
	local rope = Instance.new("RopeConstraint")
	rope.Name = "Tether"
	rope.Attachment0 = att0
	rope.Attachment1 = att1
	rope.Length = Config.TetherLength
	rope.Visible = true
	rope.Thickness = 0.25
	rope.Color = BrickColor.new("Hot pink")
	rope.Parent = rootA
	rope.Destroying:Connect(function()
		att0:Destroy()
		att1:Destroy()
	end)
	ropes[a], ropes[b] = rope, rope
end

local function untether(player, reason)
	local partner = partnerOf(player)
	for _, p in ipairs({ player, partner }) do
		if p then
			removeRope(p)
			local session = PlayerData.Session(p)
			if session then
				session.TetheredWith = nil
				p:SetAttribute("TetheredWith", nil)
				PlayerData.Sync(p)
				if reason then
					Remotes.Notify:FireClient(p, reason, "bad")
				end
			end
		end
	end
end

local function tether(a, b)
	untether(a)
	untether(b)
	local sa, sb = PlayerData.Session(a), PlayerData.Session(b)
	if not sa or not sb then
		return
	end
	sa.TetheredWith, sb.TetheredWith = b.UserId, a.UserId
	a:SetAttribute("TetheredWith", b.DisplayName)
	b:SetAttribute("TetheredWith", a.DisplayName)
	attachRope(a, b)
	PlayerData.Sync(a)
	PlayerData.Sync(b)
	for _, p in ipairs({ a, b }) do
		Remotes.Notify:FireClient(p, ("TEAMED UP! x%s coins while you stay together."):format(tostring(Config.TetherMultiplier)), "gold")
		Remotes.Fx:FireClient(p, "Confetti")
	end
end

local function addPrompt(player, character)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not root then
		return
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "TeamUpPrompt"
	prompt.ActionText = "Team Up"
	prompt.ObjectText = player.DisplayName
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = root
	prompt.Triggered:Connect(function(requester)
		if requester == player then
			return
		end
		-- The target already asked the requester: that's a yes from both sides.
		local theirs = pending[player]
		if theirs and theirs.Target == requester and os.clock() - theirs.At < 30 then
			pending[player] = nil
			tether(requester, player)
			return
		end
		pending[requester] = { Target = player, At = os.clock() }
		Remotes.Notify:FireClient(requester, ("Request sent to %s!"):format(player.DisplayName), "good")
		Remotes.Notify:FireClient(player, ("%s wants to TEAM UP! Hold E on them to accept."):format(requester.DisplayName), "gold")
	end)
	-- Re-attach the rope after a respawn.
	local partner = partnerOf(player)
	if partner and partner.Character then
		attachRope(player, partner)
	end
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		addPrompt(player, character)
	end)
	if player.Character then
		task.spawn(addPrompt, player, player.Character)
	end
end
Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
Players.PlayerRemoving:Connect(function(player)
	untether(player, "Your teammate left.")
	pending[player] = nil
end)
Remotes.Untether.OnServerEvent:Connect(function(player)
	untether(player, "Tether removed.")
end)

-- Break the tether if teammates end up far apart (different modes, teleports).
task.spawn(function()
	while true do
		task.wait(2)
		for _, player in ipairs(Players:GetPlayers()) do
			local partner = partnerOf(player)
			local a = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local b = partner and partner.Character and partner.Character:FindFirstChild("HumanoidRootPart")
			if partner and a and b and (a.Position - b.Position).Magnitude > 120 then
				untether(player, "Tether snapped - you got too far apart!")
			end
		end
	end
end)

---------------------------------------------------------------- Teamwork Vault
local vaultClaims = {} -- [Player] = os.clock()

local function playersOn(plate)
	local found = {}
	local parts = workspace:GetPartBoundsInBox(plate.CFrame * CFrame.new(0, 3, 0), plate.Size + Vector3.new(0, 6, 0))
	for _, part in ipairs(parts) do
		local player = Players:GetPlayerFromCharacter(part.Parent)
		if player then
			found[player] = true
		end
	end
	return found
end

task.spawn(function()
	while true do
		task.wait(0.3)
		local plates = CollectionService:GetTagged("VaultPlate")
		local door = CollectionService:GetTagged("VaultDoor")[1]
		if #plates >= 2 and door then
			local onA, onB = playersOn(plates[1]), playersOn(plates[2])
			local open = false
			for a in pairs(onA) do
				for b in pairs(onB) do
					if a ~= b then
						open = true
					end
				end
			end
			for _, plate in ipairs(plates) do
				plate.Color = next(playersOn(plate)) and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 80, 80)
			end
			if open and door.CanCollide then
				door.CanCollide = false
				door.Transparency = 0.85
				task.delay(10, function()
					door.CanCollide = true
					door.Transparency = 0.3
				end)
			end
		end
	end
end)

local function hookChest(chest)
	chest.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then
			return
		end
		local last = vaultClaims[player]
		if last and os.clock() - last < Config.VaultCooldownMinutes * 60 then
			return
		end
		vaultClaims[player] = os.clock()
		local amount = PlayerData.AddCoins(player, Config.VaultReward, true)
		Remotes.Notify:FireClient(player, ("TEAMWORK VAULT: +%d coins!"):format(amount), "gold")
		Remotes.Fx:FireClient(player, "Confetti")
	end)
end
for _, chest in ipairs(CollectionService:GetTagged("VaultChest")) do
	hookChest(chest)
end
CollectionService:GetInstanceAddedSignal("VaultChest"):Connect(hookChest)
