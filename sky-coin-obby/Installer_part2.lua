-- Sky Coin Obby installer: paste into the Studio command bar and press Run.
-- Creates every folder and script. Safe to run again (it replaces the old copies).
local function folder(parent, name)
	local old = parent:FindFirstChild(name)
	if old then old:Destroy() end
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end
local function add(parent, className, name, source)
	local s = Instance.new(className)
	s.Name = name
	s.Source = source
	s.Parent = parent
end
-- Keep the Assets module (your Roblox ids) from a previous install.
local oldShared = game:GetService("ReplicatedStorage"):FindFirstChild("Shared")
local oldAssets = oldShared and oldShared:FindFirstChild("Assets")
local keptAssets = oldAssets and oldAssets.Source
local f_client = folder(game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"), "Client")
add(f_client, "LocalScript", "Abilities", [==[
-- Game-pass abilities on the player's own device:
--   Double/Triple Jump (MaxJumps attribute, toggle with the player's "MultiJumpOff" attribute),
--   Rocket Launcher (click to launch), Speed Coil and Gravity Coil (hold to use).
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))
local Sfx = require(Shared:WaitForChild("Sfx"))

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function parts()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return character, humanoid, root
end

local function puff(root, color, count)
	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0, -2.5, 0)
	attachment.Parent = root
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(color)
	emitter.LightEmission = 0.6
	emitter.Size = NumberSequence.new(0.9, 0)
	emitter.Lifetime = NumberRange.new(0.3, 0.6)
	emitter.Speed = NumberRange.new(6, 12)
	emitter.SpreadAngle = Vector2.new(180, 20)
	emitter.Rate = 0
	emitter.Parent = attachment
	emitter:Emit(count or 16)
	task.delay(1, function()
		attachment:Destroy()
	end)
end

---------------------------------------------------------------- Double / triple jump
local extraJumpsUsed = 0
local airborneSince = 0

RunService.Heartbeat:Connect(function()
	local _, humanoid = parts()
	if not humanoid then
		return
	end
	if humanoid.FloorMaterial ~= Enum.Material.Air then
		extraJumpsUsed = 0
		airborneSince = os.clock()
	end
end)

UserInputService.JumpRequest:Connect(function()
	local maxJumps = player:GetAttribute("MaxJumps") or 1
	if maxJumps <= 1 or player:GetAttribute("MultiJumpOff") then
		return
	end
	local _, humanoid, root = parts()
	if not humanoid or not root or humanoid.Health <= 0 then
		return
	end
	-- Only in mid-air, and not in the instant right after the normal jump (held jump key).
	if humanoid.FloorMaterial ~= Enum.Material.Air or os.clock() - airborneSince < 0.2 then
		return
	end
	if extraJumpsUsed >= maxJumps - 1 then
		return
	end
	extraJumpsUsed += 1
	airborneSince = os.clock()
	local jumpVelocity = humanoid.UseJumpPower and humanoid.JumpPower or math.sqrt(2 * workspace.Gravity * humanoid.JumpHeight)
	local v = root.AssemblyLinearVelocity
	root.AssemblyLinearVelocity = Vector3.new(v.X, jumpVelocity, v.Z)
	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	puff(root, Color3.fromRGB(120, 230, 255))
	Sfx.Play("JumpPad", 1.4)
	Remotes.AssistUsed:FireServer()
end)

---------------------------------------------------------------- Boosted jumps count as assisted
local function watchJumps(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Jumping and not player:GetAttribute("BootsOff") and (player:GetAttribute("JumpBoost") or 1) > 1 then
			Remotes.AssistUsed:FireServer()
		end
	end)
end
player.CharacterAdded:Connect(watchJumps)
if player.Character then
	task.spawn(watchJumps, player.Character)
end

---------------------------------------------------------------- Rainbow name tags (Legendary draw)
RunService.RenderStepped:Connect(function()
	local rotation = (os.clock() * 120) % 360
	for _, gradient in ipairs(CollectionService:GetTagged("RainbowGradient")) do
		gradient.Rotation = rotation
		gradient.Offset = Vector2.new(math.sin(os.clock() * 2) * 0.3, 0)
	end
end)

---------------------------------------------------------------- Tools
local GRAPPLE_RANGE = 110
local GRAPPLE_SPEED = 75
local ROCKET_SPEED = 115
local ROCKET_COOLDOWN = 1.2
local SPEED_COIL_WALKSPEED = 26
local GRAVITY_COIL_LIFT = 0.6 -- cancels this fraction of gravity

local lastRocket = 0
local hooked = {}

local function hookTool(tool)
	if not tool:IsA("Tool") or hooked[tool] then
		return
	end
	hooked[tool] = true

	if tool.Name == "Rocket Launcher" then
		tool.Activated:Connect(function()
			local _, humanoid, root = parts()
			if not root or not humanoid or humanoid.Health <= 0 or os.clock() - lastRocket < ROCKET_COOLDOWN then
				return
			end
			lastRocket = os.clock()
			local direction = camera.CFrame.LookVector
			root.AssemblyLinearVelocity = direction * ROCKET_SPEED + Vector3.new(0, 25, 0)
			humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
			puff(root, Color3.fromRGB(255, 150, 40), 30)
			Sfx.Play("JumpPad", 0.6)
			Remotes.AssistUsed:FireServer()
		end)
	elseif tool.Name == "Grappling Hook" then
		local mouse = player:GetMouse()
		local grappling = false
		tool.Activated:Connect(function()
			local _, humanoid, root = parts()
			if grappling or not root or not humanoid or humanoid.Health <= 0 then
				return
			end
			-- Only glowing grapple points work, so the obby can't be skipped with the hook.
			local target = mouse.Target
			if not (target and CollectionService:HasTag(target, "GrapplePoint")) then
				pcall(StarterGui.SetCore, StarterGui, "SendNotification", {
					Title = "Grappling Hook",
					Text = "Aim at a glowing cyan grapple point!",
					Duration = 2,
				})
				return
			end
			local point = target.Position
			if (point - root.Position).Magnitude > GRAPPLE_RANGE then
				return
			end
			grappling = true
			Sfx.Play("JumpPad", 1.6)
			-- Rope visual
			local handle = tool:FindFirstChild("Handle")
			local a0 = Instance.new("Attachment")
			a0.Parent = handle or root
			local a1 = Instance.new("Attachment")
			a1.WorldPosition = point
			a1.Parent = workspace.Terrain
			local beam = Instance.new("Beam")
			beam.Attachment0, beam.Attachment1 = a0, a1
			beam.Width0, beam.Width1 = 0.25, 0.25
			beam.Color = ColorSequence.new(Color3.fromRGB(80, 255, 255))
			beam.LightEmission = 1
			beam.FaceCamera = true
			beam.Parent = a1
			humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
			local started = os.clock()
			while os.clock() - started < 1.1 do
				local offset = point - root.Position
				if offset.Magnitude < 5 then
					break
				end
				root.AssemblyLinearVelocity = offset.Unit * GRAPPLE_SPEED + Vector3.new(0, 6, 0)
				RunService.Heartbeat:Wait()
			end
			a0:Destroy()
			a1:Destroy()
			grappling = false
			Remotes.AssistUsed:FireServer()
		end)
	elseif tool.Name == "Slap Hand" then
		tool.Activated:Connect(function()
			local _, _, root = parts()
			if not root then
				return
			end
			local nearest, best = nil, 9
			for _, other in ipairs(Players:GetPlayers()) do
				local otherRoot = other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart")
				if otherRoot then
					local distance = (otherRoot.Position - root.Position).Magnitude
					if distance < best then
						nearest, best = other, distance
					end
				end
			end
			Sfx.Play("Click", 0.7)
			if nearest then
				Remotes.Slap:FireServer(nearest)
			end
		end)
	elseif tool.Name == "Speed Coil" then
		local normalSpeed
		tool.Equipped:Connect(function()
			local _, humanoid = parts()
			if humanoid then
				normalSpeed = humanoid.WalkSpeed
				humanoid.WalkSpeed = SPEED_COIL_WALKSPEED
				Remotes.AssistUsed:FireServer()
			end
		end)
		tool.Unequipped:Connect(function()
			local _, humanoid = parts()
			if humanoid and normalSpeed then
				humanoid.WalkSpeed = normalSpeed
			end
		end)
	elseif tool.Name == "Gravity Coil" then
		local force, conn
		tool.Equipped:Connect(function()
			local _, _, root = parts()
			if not root then
				return
			end
			force = Instance.new("VectorForce")
			local attachment = root:FindFirstChild("RootAttachment")
			if not attachment then
				attachment = Instance.new("Attachment")
				attachment.Parent = root
			end
			force.Attachment0 = attachment
			force.RelativeTo = Enum.ActuatorRelativeTo.World
			force.ApplyAtCenterOfMass = true
			force.Parent = root
			conn = RunService.Heartbeat:Connect(function()
				force.Force = Vector3.new(0, root.AssemblyMass * workspace.Gravity * GRAVITY_COIL_LIFT, 0)
			end)
			Remotes.AssistUsed:FireServer()
		end)
		tool.Unequipped:Connect(function()
			if conn then
				conn:Disconnect()
			end
			if force then
				force:Destroy()
			end
		end)
	end
end

local function watch(container)
	for _, child in ipairs(container:GetChildren()) do
		hookTool(child)
	end
	container.ChildAdded:Connect(hookTool)
end

player.CharacterAdded:Connect(function(character)
	watch(character)
	watch(player:WaitForChild("Backpack"))
end)
if player.Character then
	watch(player.Character)
end
watch(player:WaitForChild("Backpack"))
]==])
add(f_client, "LocalScript", "Audio", [==[
-- Background music (changes per zone, mute with the music button) and event sound effects.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Sfx = require(Shared:WaitForChild("Sfx"))

local player = Players.LocalPlayer
local stageValue = player:WaitForChild("leaderstats"):WaitForChild("Stage")

---------------------------------------------------------------- Music
-- ONE music player, so two tracks can never play on top of each other.
-- Switching fades the current track out, swaps it, then fades the new one in.
local musicGroup = SoundService:FindFirstChild("Music") or Instance.new("SoundGroup")
musicGroup.Name = "Music"
musicGroup.Volume = Config.MusicVolume
musicGroup.Parent = SoundService

-- Stop any music left over from older versions of the game.
for _, child in ipairs(SoundService:GetChildren()) do
	if child:IsA("Sound") and child.Looped and child.Name ~= "BackgroundMusic" then
		child:Stop()
		child:Destroy()
	end
end

local music = SoundService:FindFirstChild("BackgroundMusic") or Instance.new("Sound")
music.Name = "BackgroundMusic"
music.Looped = true
music.Volume = 0
music.SoundGroup = musicGroup
music.Parent = SoundService

-- Radio modes (MUSIC button): World (zone music; phonk in the OP tower), Calm, Phonk, Off.
local function wantedTrackName()
	local radio = player:GetAttribute("Radio") or "World"
	if radio == "Off" or player:GetAttribute("MusicMuted") then
		return nil
	elseif radio == "Calm" or radio == "Phonk" then
		return radio
	elseif player:GetAttribute("Mode") == "OP" then
		return Config.HasAsset(Config.Music.Phonk) and "Phonk" or "Space"
	end
	return Config.ZoneForStage(stageValue.Value).Music
end

local currentId = nil
local switchToken = 0
local function updateMusic()
	local name = wantedTrackName()
	local id = name and Config.Music[name]
	if not Config.HasAsset(id) then
		id = nil
	end
	if id == currentId then
		return
	end
	currentId = id
	switchToken += 1
	local token = switchToken
	task.spawn(function()
		-- Fade out whatever is playing, then swap.
		if music.IsPlaying then
			local fadeOut = TweenService:Create(music, TweenInfo.new(0.6), { Volume = 0 })
			fadeOut:Play()
			fadeOut.Completed:Wait()
		end
		if token ~= switchToken then
			return -- a newer switch happened meanwhile
		end
		music:Stop()
		if not id then
			return
		end
		music.SoundId = id
		music.TimePosition = 0
		music.Volume = 0
		music:Play()
		TweenService:Create(music, TweenInfo.new(1.2), { Volume = 1 }):Play()
	end)
end

stageValue.Changed:Connect(updateMusic)
for _, attribute in ipairs({ "MusicMuted", "Radio", "Mode" }) do
	player:GetAttributeChangedSignal(attribute):Connect(updateMusic)
end
updateMusic()

---------------------------------------------------------------- Sound effects
Remotes.CheckpointReached.OnClientEvent:Connect(function()
	Sfx.Play("Checkpoint")
end)

Remotes.Won.OnClientEvent:Connect(function()
	Sfx.Play("Win")
end)

local function onCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		Sfx.Play("Death")
	end)
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then
	task.spawn(onCharacter, player.Character)
end
]==])
add(f_client, "LocalScript", "Coins", [==[
-- Spins + bobs coins locally, and hides coins you've collected until they respawn for you.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Sfx = require(Shared:WaitForChild("Sfx"))

local coinsFolder = workspace:WaitForChild("Coins")
local baseCFrames = {} -- [coin] = original CFrame

local function track(part)
	if part:IsA("BasePart") then
		baseCFrames[part] = part.CFrame
	end
end

for _, d in ipairs(coinsFolder:GetDescendants()) do
	track(d)
end
coinsFolder.DescendantAdded:Connect(track)
coinsFolder.DescendantRemoving:Connect(function(d)
	baseCFrames[d] = nil
end)

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	for coin, base in pairs(baseCFrames) do
		local bob = math.sin(t * 2 + base.Position.X * 0.1) * 0.3
		coin.CFrame = CFrame.new(base.Position + Vector3.new(0, bob, 0))
			* CFrame.Angles(0, t * Config.CoinSpinSpeed, 0)
			* base.Rotation
	end
end)

local function setVisible(coin, visible)
	local value = visible and 0 or 1
	coin.LocalTransparencyModifier = value
	for _, d in ipairs(coin:GetDescendants()) do
		if d:IsA("Decal") or d:IsA("BasePart") then
			d.LocalTransparencyModifier = value
		elseif d:IsA("ParticleEmitter") or d:IsA("Light") or d:IsA("BillboardGui") then
			d.Enabled = visible
		end
	end
end

local function burst(position)
	local holder = Instance.new("Part")
	holder.Anchored = true
	holder.CanCollide = false
	holder.CanQuery = false
	holder.CanTouch = false
	holder.Transparency = 1
	holder.Size = Vector3.one
	holder.Position = position
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 220, 60))
	emitter.LightEmission = 1
	emitter.Lifetime = NumberRange.new(0.3, 0.6)
	emitter.Speed = NumberRange.new(8, 14)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Size = NumberSequence.new(0.5, 0)
	emitter.Rate = 0
	emitter.Parent = holder
	holder.Parent = workspace
	emitter:Emit(20)
	task.delay(1, function()
		holder:Destroy()
	end)
end

-- Grabbing coins quickly in a row raises the pitch, like a combo.
local combo, lastCoin = 0, 0

Remotes.CoinCollected.OnClientEvent:Connect(function(coin, respawnSeconds)
	if not coin or not coin.Parent then
		return
	end
	burst(coin.Position)
	combo = os.clock() - lastCoin < 1.5 and math.min(combo + 1, 8) or 0
	lastCoin = os.clock()
	Sfx.Play("Coin", 1 + combo * 0.06)
	setVisible(coin, false)
	task.delay(respawnSeconds, function()
		if coin.Parent then
			setVisible(coin, true)
		end
	end)
end)
]==])
add(f_client, "LocalScript", "Interface", [==[
-- All on-screen UI, built in code (nothing to set up in StarterGui):
-- HUD (coins, stage, wins, speedrun timer), side buttons (shop, daily, invite, skip, music),
-- shop window with game passes, pop-ups, zone banners and the win screen.
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Catalog = require(Shared:WaitForChild("ShopCatalog"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Sfx = require(Shared:WaitForChild("Sfx"))

local player = Players.LocalPlayer

local COLORS = {
	Panel = Color3.fromRGB(30, 30, 50),
	Card = Color3.fromRGB(48, 48, 78),
	Outline = Color3.fromRGB(15, 15, 25),
	Gold = Color3.fromRGB(255, 205, 40),
	Green = Color3.fromRGB(70, 210, 100),
	Blue = Color3.fromRGB(70, 150, 255),
	Pink = Color3.fromRGB(255, 90, 170),
	Purple = Color3.fromRGB(150, 90, 255),
	Orange = Color3.fromRGB(255, 140, 40),
	Red = Color3.fromRGB(235, 70, 70),
	Grey = Color3.fromRGB(110, 110, 130),
	Text = Color3.new(1, 1, 1),
}
local FONT = Enum.Font.FredokaOne

local refreshPasses -- defined with the game passes window

local state = { Coins = 0, Stage = 1, Wins = 0, BestTime = 0, Owned = {}, Equipped = {}, Multiplier = 1, Passes = {} }

---------------------------------------------------------------- UI helpers
local function make(className, props, children)
	local inst = Instance.new(className)
	local parent = props.Parent
	props.Parent = nil
	for key, value in pairs(props) do
		inst[key] = value
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	inst.Parent = parent
	return inst
end

local function corner(radius)
	return make("UICorner", { CornerRadius = UDim.new(0, radius or 12) })
end

local function stroke(thickness)
	return make("UIStroke", {
		Thickness = thickness or 3,
		Color = COLORS.Outline,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function text(props)
	props.BackgroundTransparency = 1
	props.Font = FONT
	props.TextColor3 = props.TextColor3 or COLORS.Text
	props.TextScaled = true
	local label = make("TextLabel", props)
	make("UIStroke", { Thickness = 2, Color = COLORS.Outline, Parent = label })
	return label
end

-- Image if an asset id is set in Config/Catalog, otherwise a simple drawn fallback.
local function icon(imageId, fallbackColor, fallbackText, props)
	if Config.HasAsset(imageId) then
		props.Image = imageId
		props.BackgroundTransparency = 1
		props.ScaleType = Enum.ScaleType.Fit
		return make("ImageLabel", props)
	end
	props.BackgroundColor3 = fallbackColor
	local frame = make("Frame", props, { corner(999), stroke(2) })
	text({
		Size = UDim2.fromScale(0.7, 0.7),
		Position = UDim2.fromScale(0.15, 0.15),
		Text = fallbackText,
		ZIndex = (props.ZIndex or 1) + 1,
		Parent = frame,
	})
	return frame
end

local function formatTime(seconds)
	return ("%d:%05.2f"):format(seconds // 60, seconds % 60)
end

local function pop(guiObject)
	local scale = guiObject:FindFirstChildOfClass("UIScale") or make("UIScale", { Parent = guiObject })
	scale.Scale = 1.2
	TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
end

local gui = make("ScreenGui", {
	Name = "ObbyUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = player:WaitForChild("PlayerGui"),
})

---------------------------------------------------------------- HUD (top centre, clear of chat + leaderboard)
local hud = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 8),
	Size = UDim2.fromOffset(628, 52),
	BackgroundTransparency = 1,
	Parent = gui,
}, {
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})

local function hudPanel(order, width, iconId, iconColor, iconText, textColor)
	local panel = make("Frame", {
		LayoutOrder = order,
		Size = UDim2.fromOffset(width, 52),
		BackgroundColor3 = COLORS.Panel,
		Parent = hud,
	}, { corner(14), stroke(3) })
	local x = 10
	if iconText then
		icon(iconId, iconColor, iconText, {
			Position = UDim2.fromOffset(6, 6),
			Size = UDim2.fromOffset(40, 40),
			Parent = panel,
		})
		x = 52
	end
	local label = text({
		Position = UDim2.fromOffset(x, 9),
		Size = UDim2.new(1, -x - 8, 0, 34),
		Text = "",
		TextColor3 = textColor or COLORS.Text,
		TextXAlignment = iconText and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
		Parent = panel,
	})
	return panel, label
end

local coinPanel, coinLabel = hudPanel(1, 150, Config.Images.Coin, COLORS.Gold, "$", COLORS.Gold)
local stagePanel, stageLabel = hudPanel(2, 150)
-- Click the stage counter to open STAGE SELECT.
local stageClick = make("TextButton", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "",
	ZIndex = 3,
	Parent = stagePanel,
})
stageClick.Activated:Connect(function()
	player:SetAttribute("StageSelectOpen", not player:GetAttribute("StageSelectOpen"))
end)
local _, winsLabel = hudPanel(3, 150, Config.Images.Trophy, COLORS.Orange, "W", COLORS.Gold)
-- Jump Power: grows +1 every second; click to switch it on/off (on = unranked runs).
local powerPanel, powerLabel = hudPanel(4, 150, nil, nil, nil, Color3.fromRGB(120, 230, 255))
local powerClick = make("TextButton", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "",
	ZIndex = 3,
	Parent = powerPanel,
})
local function refreshPower()
	local on = player:GetAttribute("PowerOn")
	powerLabel.Text = ("⚡%d %s"):format(player:GetAttribute("JumpPower") or 0, on and "ON" or "OFF")
	powerPanel.BackgroundColor3 = on and Color3.fromRGB(30, 80, 110) or COLORS.Panel
end
powerClick.Activated:Connect(function()
	player:SetAttribute("PowerOn", not player:GetAttribute("PowerOn"))
	if player:GetAttribute("PowerOn") then
		Remotes.AssistUsed:FireServer()
	end
	refreshPower()
end)
player:GetAttributeChangedSignal("JumpPower"):Connect(refreshPower)
refreshPower()

local timerLabel = text({
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 64),
	Size = UDim2.fromOffset(260, 26),
	Text = "",
	Parent = gui,
})

---------------------------------------------------------------- Toasts
local toastLabel = text({
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, -120),
	Size = UDim2.new(0.6, 0, 0, 36),
	Text = "",
	ZIndex = 10,
	Parent = gui,
})
local toastToken = 0
local TOAST_COLORS = { good = COLORS.Green, bad = COLORS.Red, gold = COLORS.Gold }
local function toast(message, color)
	toastToken += 1
	local token = toastToken
	toastLabel.Text = message
	toastLabel.TextColor3 = TOAST_COLORS[color] or color or COLORS.Text
	TweenService:Create(toastLabel, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, 0, 0, 146),
	}):Play()
	task.delay(2.6, function()
		if token == toastToken then
			TweenService:Create(toastLabel, TweenInfo.new(0.25), {
				Position = UDim2.new(0.5, 0, 0, -120),
			}):Play()
		end
	end)
end

-- Floating "+3" next to the coin counter.
local function coinPopup(amount)
	local label = text({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 1, 10),
		Size = UDim2.fromOffset(90, 28),
		Text = "+" .. amount,
		TextColor3 = COLORS.Gold,
		ZIndex = 5,
		Parent = coinPanel,
	})
	TweenService:Create(label, TweenInfo.new(0.8), { Position = UDim2.new(0.5, 0, 1, 40), TextTransparency = 1 }):Play()
	task.delay(0.8, function()
		label:Destroy()
	end)
end

---------------------------------------------------------------- Side buttons (left)
local sideBar = make("Frame", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 12, 0.5, 40),
	Size = UDim2.fromOffset(84, 600),
	BackgroundTransparency = 1,
	Parent = gui,
}, {
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}),
})

-- Shrink the whole column on small screens (phones, small Studio windows) so every button,
-- including MUSIC at the bottom, always fits between the top bar and the bottom edge.
do
	local sideScale = Instance.new("UIScale")
	sideScale.Parent = sideBar
	local function fitSideBar()
		local camera = workspace.CurrentCamera
		local height = camera and camera.ViewportSize.Y or 800
		local used = 6 * 8 + 5 * 84 + 64 -- gaps + five big buttons + the music button
		sideScale.Scale = math.clamp((height - 190) / used, 0.45, 1)
	end
	fitSideBar()
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(fitSideBar)
	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitSideBar)
	end
end

local function sideButton(order, title, color, iconId, fallbackText, height)
	local button = make("TextButton", {
		LayoutOrder = order,
		Size = UDim2.fromOffset(84, height or 84),
		BackgroundColor3 = color,
		Text = "",
		AutoButtonColor = true,
		Parent = sideBar,
	}, { corner(16), stroke(3) })
	local iconSize = (height or 84) - 30
	icon(iconId, COLORS.Panel, fallbackText, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 4),
		Size = UDim2.fromOffset(iconSize, iconSize),
		Parent = button,
	})
	text({
		Position = UDim2.new(0, 4, 1, -24),
		Size = UDim2.new(1, -8, 0, 20),
		Text = title,
		Parent = button,
	})
	button.Activated:Connect(function()
		Sfx.Play("Click")
	end)
	return button
end

local shopButton = sideButton(1, "SHOP", COLORS.Pink, Config.Images.ShopButton, "$")
local passesButton = sideButton(2, "PASSES", COLORS.Gold, Config.Images.Passes, "R$")
local dailyButton = sideButton(3, "REWARDS", COLORS.Purple, Config.Images.Rewards or Config.Images.Daily, "!")
local inviteButton = sideButton(4, "INVITE=3x", COLORS.Green, Config.Images.Invite, "+")
local skipButton = sideButton(5, "SKIP", COLORS.Orange, Config.Images.Skip, ">>")
local musicButton = sideButton(6, "MUSIC", COLORS.Blue, Config.Images.Music, "♪", 64)
skipButton.Visible = Config.Products.SkipStage ~= 0

local dailyDot = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(1, -6, 0, 6),
	Size = UDim2.fromOffset(22, 22),
	BackgroundColor3 = COLORS.Red,
	Visible = false,
	ZIndex = 3,
	Parent = dailyButton,
}, { corner(999), stroke(2) })

-- Gently pulse the daily button while a reward is waiting.
task.spawn(function()
	while true do
		task.wait(1)
		if dailyDot.Visible then
			pop(dailyButton)
		end
	end
end)

---------------------------------------------------------------- Shop window
local shopWindow = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.9, 0.8),
	BackgroundColor3 = COLORS.Panel,
	Visible = false,
	ZIndex = 5,
	Parent = gui,
}, {
	corner(18),
	stroke(4),
	make("UISizeConstraint", { MaxSize = Vector2.new(660, 500) }),
})
text({
	Position = UDim2.fromOffset(18, 10),
	Size = UDim2.new(1, -90, 0, 44),
	Text = "COSMETIC SHOP",
	TextColor3 = COLORS.Gold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 5,
	Parent = shopWindow,
})
local closeButton = make("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -12, 0, 12),
	Size = UDim2.fromOffset(40, 40),
	BackgroundColor3 = COLORS.Red,
	Font = FONT,
	Text = "X",
	TextScaled = true,
	TextColor3 = COLORS.Text,
	ZIndex = 5,
	Parent = shopWindow,
}, { corner(10), stroke(2) })

local grid = make("ScrollingFrame", {
	Position = UDim2.fromOffset(14, 64),
	Size = UDim2.new(1, -28, 1, -78),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 6,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ZIndex = 5,
	Parent = shopWindow,
}, {
	make("UIGridLayout", {
		CellSize = UDim2.fromOffset(140, 190),
		CellPadding = UDim2.fromOffset(12, 12),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
	make("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }),
})

local cards = {} -- [itemId] = { Button, Item }

shopButton.Activated:Connect(function()
	shopWindow.Visible = not shopWindow.Visible
end)
closeButton.Activated:Connect(function()
	shopWindow.Visible = false
end)

local busy = false
local function onCardClicked(item)
	if busy then
		return
	end
	if item.RequiresVIP and not state.Passes.VIP then
		if Config.GamePasses.VIP ~= 0 then
			MarketplaceService:PromptGamePassPurchase(player, Config.GamePasses.VIP)
		else
			toast("VIP isn't on sale yet", "bad")
		end
		return
	end
	local action
	if state.Equipped[item.Slot] == item.Id then
		action = "Unequip"
	elseif state.Owned[item.Id] then
		action = "Equip"
	else
		action = "Buy"
	end
	busy = true
	local ok, message = Remotes.ShopAction:InvokeServer(action, item.Id)
	busy = false
	toast(message or "", ok and "good" or "bad")
	Sfx.Play(ok and action == "Buy" and "Purchase" or "Click")
end

local sorted = table.clone(Catalog.Items)
table.sort(sorted, function(a, b)
	if (a.RequiresVIP or false) ~= (b.RequiresVIP or false) then
		return b.RequiresVIP == true
	end
	return a.Price < b.Price
end)

for index, item in ipairs(sorted) do
	local card = make("Frame", {
		LayoutOrder = index,
		BackgroundColor3 = item.RequiresVIP and Color3.fromRGB(90, 70, 20) or COLORS.Card,
		ZIndex = 5,
		Parent = grid,
	}, { corner(14), stroke(3) })
	local fallbackColor = item.Slot == "Trail" and COLORS.Blue or COLORS.Pink
	local art = icon(item.Icon, fallbackColor, item.Name:sub(1, 1), {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 8),
		Size = UDim2.fromOffset(88, 88),
		ZIndex = 6,
		Parent = card,
	})
	for _, d in ipairs(art:GetDescendants()) do
		if d:IsA("GuiObject") then
			d.ZIndex = 7
		end
	end
	text({
		Position = UDim2.new(0, 6, 0, 100),
		Size = UDim2.new(1, -12, 0, 22),
		Text = item.Name,
		ZIndex = 6,
		Parent = card,
	})
	text({
		Position = UDim2.new(0, 6, 0, 122),
		Size = UDim2.new(1, -12, 0, 16),
		Text = item.RequiresVIP and "VIP only" or item.UnlockText and "Milestone reward" or item.Slot,
		TextColor3 = item.RequiresVIP and COLORS.Gold or Color3.fromRGB(190, 190, 220),
		ZIndex = 6,
		Parent = card,
	})
	local button = make("TextButton", {
		Position = UDim2.new(0, 10, 1, -44),
		Size = UDim2.new(1, -20, 0, 34),
		Font = FONT,
		TextScaled = true,
		TextColor3 = COLORS.Text,
		ZIndex = 6,
		Parent = card,
	}, { corner(10), stroke(2), make("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
	}) })
	button.Activated:Connect(function()
		onCardClicked(item)
	end)
	cards[item.Id] = { Button = button, Item = item }
end

---------------------------------------------------------------- Game passes window
local PassCatalog = require(Shared:WaitForChild("PassCatalog"))

local passesWindow = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.9, 0.8),
	BackgroundColor3 = COLORS.Panel,
	Visible = false,
	ZIndex = 5,
	Parent = gui,
}, {
	corner(18),
	stroke(4),
	make("UISizeConstraint", { MaxSize = Vector2.new(660, 520) }),
})
text({
	Position = UDim2.fromOffset(18, 10),
	Size = UDim2.new(1, -90, 0, 44),
	Text = "GAME PASSES",
	TextColor3 = COLORS.Gold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 5,
	Parent = passesWindow,
})
local passesClose = make("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -12, 0, 12),
	Size = UDim2.fromOffset(40, 40),
	BackgroundColor3 = COLORS.Red,
	Font = FONT,
	Text = "X",
	TextScaled = true,
	TextColor3 = COLORS.Text,
	ZIndex = 5,
	Parent = passesWindow,
}, { corner(10), stroke(2) })
local passGrid = make("ScrollingFrame", {
	Position = UDim2.fromOffset(14, 64),
	Size = UDim2.new(1, -28, 1, -78),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 6,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ZIndex = 5,
	Parent = passesWindow,
}, {
	make("UIGridLayout", {
		CellSize = UDim2.fromOffset(185, 230),
		CellPadding = UDim2.fromOffset(12, 12),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
	make("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }),
})

local JUMP_PASSES = { DoubleJump = true, TripleJump = true }
local passCards = {} -- [key] = { Button, Pass, Id, Price }

local function onPassClicked(card)
	if state.Passes[card.Pass.Key] then
		if JUMP_PASSES[card.Pass.Key] then
			player:SetAttribute("MultiJumpOff", not player:GetAttribute("MultiJumpOff"))
			refreshPasses()
		end
		return
	end
	MarketplaceService:PromptGamePassPurchase(player, card.Id)
end

for index, pass in ipairs(PassCatalog) do
	local id = Config.GamePasses[pass.Key] or 0
	if id ~= 0 then
		local cardFrame = make("Frame", {
			LayoutOrder = index,
			BackgroundColor3 = COLORS.Card,
			ZIndex = 5,
			Parent = passGrid,
		}, { corner(14), stroke(3) })
		local art = make("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 8),
			Size = UDim2.fromOffset(84, 84),
			BackgroundColor3 = COLORS.Purple,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 6,
			Parent = cardFrame,
		}, { corner(14) })
		text({
			Position = UDim2.new(0, 6, 0, 96),
			Size = UDim2.new(1, -12, 0, 24),
			Text = pass.Name,
			TextColor3 = COLORS.Gold,
			ZIndex = 6,
			Parent = cardFrame,
		})
		text({
			Position = UDim2.new(0, 8, 0, 122),
			Size = UDim2.new(1, -16, 0, 50),
			Text = pass.Description,
			TextWrapped = true,
			ZIndex = 6,
			Parent = cardFrame,
		})
		local button = make("TextButton", {
			Position = UDim2.new(0, 10, 1, -46),
			Size = UDim2.new(1, -20, 0, 36),
			Font = FONT,
			TextScaled = true,
			TextColor3 = COLORS.Text,
			BackgroundColor3 = COLORS.Green,
			Text = "Buy",
			ZIndex = 6,
			Parent = cardFrame,
		}, { corner(10), stroke(2), make("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) }) })
		local card = { Button = button, Pass = pass, Id = id }
		passCards[pass.Key] = card
		button.Activated:Connect(function()
			onPassClicked(card)
		end)
		-- Fetch the pass's real icon and price from Roblox.
		task.spawn(function()
			local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id, Enum.InfoType.GamePass)
			if ok and info then
				if info.IconImageAssetId and info.IconImageAssetId ~= 0 then
					art.Image = "rbxassetid://" .. info.IconImageAssetId
					art.BackgroundTransparency = 1
				end
				card.Price = info.PriceInRobux
				if refreshPasses then
					refreshPasses()
				end
			end
		end)
	end
end
passesButton.Visible = next(passCards) ~= nil

refreshPasses = function()
	for key, card in pairs(passCards) do
		local button = card.Button
		if state.Passes[key] then
			if JUMP_PASSES[key] then
				local off = player:GetAttribute("MultiJumpOff")
				button.Text = off and "Jumps: OFF" or "Jumps: ON"
				button.BackgroundColor3 = off and COLORS.Grey or COLORS.Blue
			else
				button.Text = "Owned ✓"
				button.BackgroundColor3 = COLORS.Grey
			end
		else
			button.Text = card.Price and ("R$ " .. card.Price) or "Buy"
			button.BackgroundColor3 = COLORS.Green
		end
	end
end

passesButton.Activated:Connect(function()
	passesWindow.Visible = not passesWindow.Visible
	shopWindow.Visible = false
end)
passesClose.Activated:Connect(function()
	passesWindow.Visible = false
end)
shopButton.Activated:Connect(function()
	passesWindow.Visible = false
end)

---------------------------------------------------------------- Daily / invite / skip / music
-- The REWARDS and STAGE SELECT windows live in Rewards.client; toggled via attributes.
dailyButton.Activated:Connect(function()
	shopWindow.Visible = false
	passesWindow.Visible = false
	player:SetAttribute("RewardsOpen", not player:GetAttribute("RewardsOpen"))
end)

local function promptInvite()
	local ok, canInvite = pcall(SocialService.CanSendGameInviteAsync, SocialService, player)
	if ok and canInvite then
		pcall(SocialService.PromptGameInvite, SocialService, player)
	else
		toast("Invites aren't available right now", "bad")
	end
end
inviteButton.Activated:Connect(promptInvite)

skipButton.Activated:Connect(function()
	MarketplaceService:PromptProductPurchase(player, Config.Products.SkipStage)
end)

-- Radio: World music -> Calm -> Phonk -> Off (Audio.client plays whatever is picked).
local RADIO = { "World", "Calm", "Phonk", "Off" }
musicButton.Activated:Connect(function()
	local current = player:GetAttribute("Radio") or "World"
	local nextMode = RADIO[(table.find(RADIO, current) or 1) % #RADIO + 1]
	player:SetAttribute("Radio", nextMode)
	player:SetAttribute("MusicMuted", nextMode == "Off")
	musicButton.BackgroundColor3 = nextMode == "Off" and COLORS.Grey or COLORS.Blue
	for _, d in ipairs(musicButton:GetDescendants()) do
		if d:IsA("TextLabel") and d.Text ~= "♪" and d.Size.Y.Offset == 20 then
			d.Text = nextMode:upper()
		end
	end
end)

---------------------------------------------------------------- Zone banner
local banner = text({
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.32),
	Size = UDim2.new(0.8, 0, 0, 80),
	Text = "",
	TextTransparency = 1,
	ZIndex = 8,
	Parent = gui,
})
local bannerStroke = banner:FindFirstChildOfClass("UIStroke")
local ZONE_SUBTITLES = {
	["CANDY LAND"] = "Watch out - platforms vanish!",
	["OUTER SPACE"] = "Low gravity - MOON JUMPS!",
	["GARY'S LAIR"] = "Gary's home turf - the final 25 stages!",
}
local function showBanner(zone)
	local subtitle = ZONE_SUBTITLES[zone.Name]
	banner.Text = zone.Name .. (subtitle and ("\n" .. subtitle) or "")
	banner.TextTransparency = 0
	bannerStroke.Transparency = 0
	pop(banner)
	task.delay(3, function()
		TweenService:Create(banner, TweenInfo.new(1), { TextTransparency = 1 }):Play()
		TweenService:Create(bannerStroke, TweenInfo.new(1), { Transparency = 1 }):Play()
	end)
end

---------------------------------------------------------------- Win screen
local winScreen = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.45),
	Size = UDim2.fromOffset(420, 300),
	BackgroundColor3 = COLORS.Panel,
	Visible = false,
	ZIndex = 20,
	Parent = gui,
}, { corner(20), stroke(4), make("UIScale", {}) })
text({
	Position = UDim2.fromOffset(16, 14),
	Size = UDim2.new(1, -32, 0, 64),
	Text = "YOU WIN!",
	TextColor3 = COLORS.Gold,
	ZIndex = 21,
	Parent = winScreen,
})
local winDetails = text({
	Position = UDim2.fromOffset(24, 84),
	Size = UDim2.new(1, -48, 0, 120),
	Text = "",
	ZIndex = 21,
	Parent = winScreen,
})
local raceButton = make("TextButton", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -16),
	Size = UDim2.new(1, -48, 0, 50),
	BackgroundColor3 = COLORS.Green,
	Font = FONT,
	TextScaled = true,
	TextColor3 = COLORS.Text,
	Text = "Invite friends to race you!",
	ZIndex = 21,
	Parent = winScreen,
}, { corner(12), stroke(2), make("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }) })
raceButton.Activated:Connect(promptInvite)

local function confetti()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0, 3, 0)
	attachment.Parent = root
	for _, color in ipairs({ COLORS.Gold, COLORS.Pink, COLORS.Blue, COLORS.Green, COLORS.Purple }) do
		local emitter = Instance.new("ParticleEmitter")
		emitter.Color = ColorSequence.new(color)
		emitter.LightEmission = 0.5
		emitter.Size = NumberSequence.new(0.35)
		emitter.Lifetime = NumberRange.new(2, 3)
		emitter.Speed = NumberRange.new(18, 30)
		emitter.SpreadAngle = Vector2.new(60, 60)
		emitter.Acceleration = Vector3.new(0, -25, 0)
		emitter.Rotation = NumberRange.new(0, 360)
		emitter.RotSpeed = NumberRange.new(-200, 200)
		emitter.EmissionDirection = Enum.NormalId.Top
		emitter.Rate = 0
		emitter.Parent = attachment
		emitter:Emit(40)
	end
	task.delay(4, function()
		attachment:Destroy()
	end)
end

Remotes.Won.OnClientEvent:Connect(function(elapsed, isNewBest, reward, wins, assisted)
	local lines = {}
	if elapsed and assisted then
		table.insert(lines, "Time: " .. formatTime(elapsed) .. " (used passes - not ranked)")
	elseif elapsed then
		table.insert(lines, "Time: " .. formatTime(elapsed) .. (isNewBest and "  NEW BEST!" or ""))
	else
		table.insert(lines, "Start from stage 1 for a timed run!")
	end
	table.insert(lines, ("+%d coins   |   Wins: %d"):format(reward, wins))
	table.insert(lines, ("Coin bonus is now x%.2f"):format(math.min(1 + wins * Config.WinMultiplierStep, Config.MaxWinMultiplier)))
	winDetails.Text = table.concat(lines, "\n")
	winScreen.Visible = true
	pop(winScreen)
	confetti()
	task.delay(Config.SecondsBeforeRestart + 1, function()
		winScreen.Visible = false
	end)
end)

---------------------------------------------------------------- Refresh + events
-- The real stage count comes from Config: counting the Checkpoints folder on the client is
-- wrong when streaming only sends the nearby ones (that showed "Stage 5/22").
local totalStages = 0
local function countStages()
	local folder = workspace:FindFirstChild("Checkpoints")
	local highest = Config.Stages or 0
	for _, child in ipairs(folder and folder:GetChildren() or {}) do
		highest = math.max(highest, tonumber(child.Name) or 0)
	end
	totalStages = highest
end

local lastCoins, lastZone
local function refresh()
	countStages()
	coinLabel.Text = tostring(state.Coins)
	if lastCoins and state.Coins > lastCoins then
		pop(coinPanel)
		coinPopup(state.Coins - lastCoins)
	end
	lastCoins = state.Coins

	if state.Mode == "OP" then
		stageLabel.Text = ("OP %d/%d"):format(state.OPStage or 1, Config.OP.Stages)
	else
		stageLabel.Text = totalStages > 0 and ("Stage %d/%d"):format(state.Stage, totalStages) or ("Stage " .. state.Stage)
	end
	winsLabel.Text = ("%d  x%s"):format(state.Wins, tostring(math.floor(state.Multiplier * 100 + 0.5) / 100))
	dailyDot.Visible = state.DailyReady == true or (state.NextDrawIn or 1) <= 0
	skipButton.Visible = Config.Products.SkipStage ~= 0 and state.Stage < totalStages - 1

	local zone = Config.ZoneForStage(state.Stage)
	if lastZone and zone ~= lastZone then
		showBanner(zone)
	end
	lastZone = zone

	refreshPasses()

	for id, card in pairs(cards) do
		local button, item = card.Button, card.Item
		if state.Equipped[item.Slot] == id then
			button.Text = "Equipped ✓"
			button.BackgroundColor3 = COLORS.Green
		elseif state.Owned[id] or (item.RequiresVIP and state.Passes.VIP) then
			button.Text = "Equip"
			button.BackgroundColor3 = COLORS.Blue
		elseif item.RequiresVIP then
			button.Text = "Get VIP"
			button.BackgroundColor3 = COLORS.Gold
		elseif item.UnlockText then
			button.Text = item.UnlockText
			button.BackgroundColor3 = COLORS.Grey
		else
			button.Text = "$ " .. item.Price
			button.BackgroundColor3 = state.Coins >= item.Price and COLORS.Gold or COLORS.Grey
		end
	end
end

RunService.RenderStepped:Connect(function()
	if state.RunStart then
		local best = state.BestTime > 0 and ("   Best " .. formatTime(state.BestTime)) or ""
		local tag = state.RunAssisted and "  (passes used)" or ""
		timerLabel.Text = formatTime(workspace:GetServerTimeNow() - state.RunStart) .. tag .. best
	elseif state.BestTime > 0 then
		timerLabel.Text = "Best " .. formatTime(state.BestTime)
	else
		timerLabel.Text = ""
	end
end)

Remotes.DataUpdated.OnClientEvent:Connect(function(data)
	state = data
	refresh()
end)

Remotes.CheckpointReached.OnClientEvent:Connect(function(stage, reward, mode)
	if mode == "OP" then
		local tier = Config.OP.Tiers[math.floor((stage - 1) / Config.OP.TierSize) + 1]
		toast(("OP STAGE %d  [%s]  (+%d coins)"):format(stage, tier and tier[1] or "", reward or 0), "good")
	elseif reward and reward > 0 then
		toast(("Checkpoint! Stage %d  (+%d coins)"):format(stage, reward), "good")
	else
		toast(("Checkpoint! Stage %d"):format(stage), "good")
	end
end)

Remotes.Notify.OnClientEvent:Connect(function(message, kind)
	toast(message, kind)
end)

---------------------------------------------------------------- [VIP] chat tag
TextChatService.OnIncomingMessage = function(message)
	local properties = Instance.new("TextChatMessageProperties")
	local source = message.TextSource
	local sender = source and Players:GetPlayerByUserId(source.UserId)
	local prefix = message.PrefixText
	if sender and (sender:GetAttribute("Rebirths") or 0) > 0 then
		prefix = ('<font color="#FF5078">[Rebirth %d]</font> '):format(sender:GetAttribute("Rebirths")) .. prefix
	end
	if sender and sender:GetAttribute("VIP") then
		prefix = '<font color="#FFD23F">[VIP]</font> ' .. prefix
	end
	if prefix ~= message.PrefixText then
		properties.PrefixText = prefix
	end
	return properties
end

---------------------------------------------------------------- Fit small screens (phones)
local hudScale = make("UIScale", { Parent = hud })
local sideScale = make("UIScale", { Parent = sideBar })
local timerScale = make("UIScale", { Parent = timerLabel })
local function fitScreen()
	local viewport = workspace.CurrentCamera.ViewportSize
	hudScale.Scale = math.clamp(viewport.X / 560, 0.6, 1)
	timerScale.Scale = hudScale.Scale
	sideScale.Scale = math.clamp(viewport.Y / 640, 0.55, 1)
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScreen)
fitScreen()

---------------------------------------------------------------- Start
local initial = Remotes.RequestData:InvokeServer()
if initial then
	state = initial
end
refresh()
if state.DailyReady or (state.NextDrawIn or 1) <= 0 then
	task.delay(2, function()
		toast("Free rewards waiting! Tap REWARDS", "gold")
	end)
end
]==])
add(f_client, "LocalScript", "Juice", [==[
-- Game feel ("juice"): screen shake on hard landings, checkpoint bursts + flash, confetti,
-- slaps, trap-door stingers, Greedy Gary jumpscares, the 3-second story intro,
-- the coin-skip offer after repeated fails, and the fast RESET (R key / button).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Sfx = require(Shared:WaitForChild("Sfx"))
local UI = require(Shared:WaitForChild("UI"))

local player = Players.LocalPlayer
local COLORS = UI.COLORS
local make, text, button = UI.make, UI.text, UI.button

local gui = make("ScreenGui", {
	Name = "JuiceUI",
	ResetOnSpawn = false,
	DisplayOrder = 10,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = player:WaitForChild("PlayerGui"),
})

local function root()
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart"), character and character:FindFirstChildOfClass("Humanoid")
end

---------------------------------------------------------------- Screen shake
local shakeUntil, shakeStrength = 0, 0
local function shake(strength, duration)
	shakeStrength = math.max(shakeStrength, strength)
	shakeUntil = math.max(shakeUntil, os.clock() + duration)
end
RunService.RenderStepped:Connect(function()
	local _, humanoid = root()
	if not humanoid then
		return
	end
	if os.clock() < shakeUntil then
		local s = shakeStrength * (shakeUntil - os.clock())
		humanoid.CameraOffset = Vector3.new(math.random() - 0.5, math.random() - 0.5, 0) * s
	elseif humanoid.CameraOffset ~= Vector3.zero then
		humanoid.CameraOffset = Vector3.zero
		shakeStrength = 0
	end
end)

-- Hard landings shake the camera a little.
local function watchLandings(character)
	local humanoid = character:WaitForChild("Humanoid")
	local hrp = character:WaitForChild("HumanoidRootPart")
	local fallSpeed = 0
	local conn = RunService.Heartbeat:Connect(function()
		fallSpeed = math.min(fallSpeed, hrp.AssemblyLinearVelocity.Y)
	end)
	character.Destroying:Once(function()
		conn:Disconnect()
	end)
	humanoid.Died:Once(function()
		conn:Disconnect()
	end)
	humanoid.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Landed then
			if fallSpeed < -70 then
				shake(math.clamp(-fallSpeed / 80, 0.6, 2.5), 0.25)
			end
			fallSpeed = 0
		end
	end)
end
player.CharacterAdded:Connect(watchLandings)
if player.Character then
	task.spawn(watchLandings, player.Character)
end

---------------------------------------------------------------- Bursts + flash
local flash = make("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 1,
	ZIndex = 1,
	Parent = gui,
})
local function screenFlash(color)
	flash.BackgroundColor3 = color
	flash.BackgroundTransparency = 0.6
	TweenService:Create(flash, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
end

local function burst(colors, count, speed)
	local hrp = root()
	if not hrp then
		return
	end
	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0, 2, 0)
	attachment.Parent = hrp
	for _, color in ipairs(colors) do
		local emitter = Instance.new("ParticleEmitter")
		emitter.Color = ColorSequence.new(color)
		emitter.LightEmission = 0.6
		emitter.Size = NumberSequence.new(0.35, 0.1)
		emitter.Lifetime = NumberRange.new(1, 2)
		emitter.Speed = NumberRange.new(speed * 0.6, speed)
		emitter.SpreadAngle = Vector2.new(70, 70)
		emitter.Acceleration = Vector3.new(0, -30, 0)
		emitter.Rotation = NumberRange.new(0, 360)
		emitter.RotSpeed = NumberRange.new(-300, 300)
		emitter.EmissionDirection = Enum.NormalId.Top
		emitter.Rate = 0
		emitter.Parent = attachment
		emitter:Emit(count)
	end
	task.delay(3, function()
		attachment:Destroy()
	end)
end

local CONFETTI = { COLORS.Gold, COLORS.Pink, COLORS.Blue, COLORS.Green, COLORS.Purple }

Remotes.CheckpointReached.OnClientEvent:Connect(function()
	burst({ COLORS.Green, COLORS.Gold }, 18, 22)
	screenFlash(Color3.fromRGB(120, 255, 160))
end)

---------------------------------------------------------------- Gary jumpscare + intro
local garyImage = Config.Images.Gary
local scare = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.7, 0.7),
	BackgroundTransparency = 1,
	Visible = false,
	ZIndex = 20,
	Parent = gui,
}, { make("UIAspectRatioConstraint", { AspectRatio = 1 }) })
make("ImageLabel", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Image = Config.HasAsset(garyImage) and garyImage or "",
	ZIndex = 20,
	Parent = scare,
})
text({
	Size = UDim2.fromScale(1, 0.4),
	Position = UDim2.fromScale(0, 0.3),
	Text = "😈 GARY!",
	TextColor3 = Color3.fromRGB(140, 230, 90),
	Visible = not Config.HasAsset(garyImage),
	ZIndex = 21,
	Parent = scare,
})
local scareLine = text({
	Position = UDim2.fromScale(0, 0.85),
	Size = UDim2.fromScale(1, 0.15),
	Text = "",
	ZIndex = 21,
	Parent = scare,
})
local scareScale = make("UIScale", { Parent = scare })

local function jumpscare(line)
	scareLine.Text = line or ""
	scare.Visible = true
	scareScale.Scale = 0.2
	TweenService:Create(scareScale, TweenInfo.new(0.18, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	shake(2.5, 0.5)
	Sfx.Play("Death", 0.6)
	task.delay(1.2, function()
		scare.Visible = false
	end)
end

local intro = make("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(20, 10, 35),
	BackgroundTransparency = 0.25,
	Visible = false,
	ZIndex = 30,
	Parent = gui,
})
local introTitle = text({
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.38),
	Size = UDim2.fromScale(0.8, 0.14),
	Text = Config.GameTitle,
	TextColor3 = COLORS.Gold,
	ZIndex = 31,
	Parent = intro,
})
local introBody = text({
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.56),
	Size = UDim2.fromScale(0.8, 0.16),
	Text = "",
	TextWrapped = true,
	ZIndex = 31,
	Parent = intro,
})
local function showIntro(body)
	introBody.Text = body or ""
	intro.Visible = true
	pcall(function()
		introTitle:FindFirstChildOfClass("UIStroke").Thickness = 3
	end)
	task.delay(3.5, function()
		TweenService:Create(intro, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(introTitle, TweenInfo.new(0.6), { TextTransparency = 1 }):Play()
		TweenService:Create(introBody, TweenInfo.new(0.6), { TextTransparency = 1 }):Play()
		task.wait(0.7)
		intro.Visible = false
	end)
end

---------------------------------------------------------------- Coin-skip offer (after many fails)
local skipOffer = button({
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -110),
	Size = UDim2.fromOffset(320, 50),
	BackgroundColor3 = COLORS.Orange,
	Text = "",
	Visible = false,
	ZIndex = 15,
	Parent = gui,
})
skipOffer.Activated:Connect(function()
	local ok, message = Remotes.SkipWithCoins:InvokeServer()
	skipOffer.Text = message or ""
	task.delay(1.2, function()
		skipOffer.Visible = false
	end)
	if ok then
		Sfx.Play("Checkpoint")
	end
end)

---------------------------------------------------------------- Server effects
Remotes.Fx.OnClientEvent:Connect(function(name, ...)
	local args = { ... }
	if name == "Confetti" then
		burst(CONFETTI, 30, 28)
		Sfx.Play("Purchase", 1.2)
	elseif name == "Slapped" then
		local hrp, humanoid = root()
		if hrp and humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
			hrp.AssemblyLinearVelocity = args[1] * 70 + Vector3.new(0, 35, 0)
			shake(2, 0.3)
			Sfx.Play("Death", 1.6)
		end
	elseif name == "SlapHit" then
		Sfx.Play("Purchase", 0.7)
	elseif name == "Trap" then
		shake(1.5, 0.3)
		Sfx.Play("Death", 0.8)
	elseif name == "Jumpscare" then
		jumpscare(args[1])
	elseif name == "Intro" then
		showIntro(args[1])
	elseif name == "OfferSkip" then
		skipOffer.Text = ("Stuck? SKIP this stage for %d coins"):format(args[1] or Config.CoinSkipCost)
		skipOffer.Visible = true
		task.delay(10, function()
			skipOffer.Visible = false
		end)
	end
end)

-- Yeet pad celebration.
player:GetAttributeChangedSignal("Yeeted"):Connect(function()
	shake(1.5, 0.4)
	pcall(game:GetService("StarterGui").SetCore, game:GetService("StarterGui"), "SendNotification", {
		Title = "YEEEEET!",
		Text = "Gary told you not to touch it.",
		Duration = 3,
	})
end)

---------------------------------------------------------------- Fast reset (R / button)
local resetButton = button({
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 110, 1, -16),
	Size = UDim2.fromOffset(110, 40),
	BackgroundColor3 = COLORS.Red,
	Text = "RESET (R)",
	ZIndex = 5,
	Parent = gui,
})
local function quickReset()
	Remotes.QuickReset:FireServer()
end
resetButton.Activated:Connect(quickReset)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.R then
		quickReset()
	end
end)

---------------------------------------------------------------- Co-op tether
local untetherButton = button({
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 230, 1, -16),
	Size = UDim2.fromOffset(190, 40),
	BackgroundColor3 = COLORS.Pink,
	Text = "",
	Visible = false,
	ZIndex = 5,
	Parent = gui,
})
local function refreshTether()
	local partner = player:GetAttribute("TetheredWith")
	untetherButton.Visible = partner ~= nil
	untetherButton.Text = partner and ("UNTETHER (%s)"):format(partner) or ""
end
untetherButton.Activated:Connect(function()
	Remotes.Untether:FireServer()
end)
player:GetAttributeChangedSignal("TetheredWith"):Connect(refreshTether)
refreshTether()

-- Hide your own "Team Up" prompt (you can't team up with yourself).
local function hideOwnPrompt(character)
	local hrp = character:WaitForChild("HumanoidRootPart", 10)
	local prompt = hrp and hrp:WaitForChild("TeamUpPrompt", 10)
	if prompt then
		prompt.Enabled = false
	end
end
player.CharacterAdded:Connect(hideOwnPrompt)
if player.Character then
	task.spawn(hideOwnPrompt, player.Character)
end

---------------------------------------------------------------- Lobby teleport: one toggle button (or L key)
-- Out on the course it says LOBBY; in the lobby the same button says BACK TO STAGE.
local lobbyButton = button({
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 110, 1, -62),
	Size = UDim2.fromOffset(150, 40),
	BackgroundColor3 = COLORS.Blue,
	Text = "🏠 LOBBY (L)",
	ZIndex = 5,
	Parent = gui,
})

local busyTeleport = false
local function teleport(remote)
	if busyTeleport then
		return
	end
	busyTeleport = true
	local ok = remote:InvokeServer()
	if ok then
		screenFlash(Color3.fromRGB(160, 200, 255))
		Sfx.Play("Checkpoint", 1.2)
	end
	busyTeleport = false
end

local function toggleLobby()
	teleport(player:GetAttribute("InLobby") and Remotes.BackToStage or Remotes.GoLobby)
end
lobbyButton.Activated:Connect(toggleLobby)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.L then
		toggleLobby()
	end
end)

local function refreshLobbyButton()
	local inLobby = player:GetAttribute("InLobby") == true
	lobbyButton.Text = inLobby and "↩ BACK TO STAGE" or "🏠 LOBBY (L)"
	lobbyButton.BackgroundColor3 = inLobby and COLORS.Green or COLORS.Blue
end
player:GetAttributeChangedSignal("InLobby"):Connect(refreshLobbyButton)
refreshLobbyButton()
]==])
add(f_client, "LocalScript", "Movement", [==[
-- Jump pads, plus each zone's sky colours and gravity (space = moon jumps).
-- Runs on the client because players' characters are simulated on their own device.
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Sfx = require(Shared:WaitForChild("Sfx"))

local player = Players.LocalPlayer
local stageValue = player:WaitForChild("leaderstats"):WaitForChild("Stage")

---------------------------------------------------------------- Zone look + gravity
-- Atmosphere haze softens the horizon so the world fades out instead of ending abruptly.
local LOOKS = {
	["SKY ISLANDS"] = {
		Tint = Color3.new(1, 1, 1), Saturation = 0.1, Brightness = 2,
		Density = 0.32, Haze = 1.6, Glare = 0.3, Color = Color3.fromRGB(200, 225, 255), Decay = Color3.fromRGB(110, 160, 215),
	},
	["CANDY LAND"] = {
		Tint = Color3.fromRGB(255, 232, 245), Saturation = 0.25, Brightness = 2,
		Density = 0.36, Haze = 2.2, Glare = 0.4, Color = Color3.fromRGB(255, 215, 238), Decay = Color3.fromRGB(255, 160, 210),
	},
	["OUTER SPACE"] = {
		Tint = Color3.fromRGB(215, 205, 255), Saturation = 0.2, Brightness = 1,
		Density = 0.12, Haze = 0, Glare = 0, Color = Color3.fromRGB(60, 40, 110), Decay = Color3.fromRGB(20, 10, 50),
	},
	["FROZEN PEAKS"] = {
		Tint = Color3.fromRGB(225, 240, 255), Saturation = 0, Brightness = 2.2,
		Density = 0.35, Haze = 2, Glare = 0.5, Color = Color3.fromRGB(220, 240, 255), Decay = Color3.fromRGB(140, 190, 240),
	},
	["GOLDEN VAULT"] = {
		Tint = Color3.fromRGB(255, 240, 210), Saturation = 0.2, Brightness = 2,
		Density = 0.3, Haze = 1.8, Glare = 0.6, Color = Color3.fromRGB(255, 225, 160), Decay = Color3.fromRGB(220, 160, 70),
	},
	["GARY'S LAIR"] = {
		Tint = Color3.fromRGB(255, 220, 205), Saturation = 0.15, Brightness = 1.6,
		Density = 0.4, Haze = 2.4, Glare = 0.2, Color = Color3.fromRGB(255, 150, 110), Decay = Color3.fromRGB(150, 50, 40),
	},
}

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Offset = 0.2
atmosphere.Parent = Lighting

local correction = Lighting:FindFirstChild("ZoneCorrection") or Instance.new("ColorCorrectionEffect")
correction.Name = "ZoneCorrection"
correction.Parent = Lighting

local defaultJump = {}

-- Daily Draw jump boots multiply jump height (JumpBoost attribute, set by the server).
-- Players can switch them off (BootsOff attribute) for ranked runs.
local function jumpBoost()
	if player:GetAttribute("BootsOff") then
		return 1
	end
	return player:GetAttribute("JumpBoost") or 1
end

-- Extra jump height from the idle Jump Power stat (only while the player switched it on).
local function powerBonus()
	if not player:GetAttribute("PowerOn") then
		return 0
	end
	return (player:GetAttribute("JumpPower") or 0) * Config.JumpPowerHeight
end

-- Forgiving failure: small speed/jump assist after repeated deaths on a stage (server sets "Assist").
local function assistFactor()
	return 1 + 0.1 * (player:GetAttribute("Assist") or 0)
end

local function applyMovement(zone)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	workspace.Gravity = zone.Gravity
	if not humanoid then
		return
	end
	if not defaultJump[humanoid] then
		defaultJump[humanoid] = {
			UseJumpPower = humanoid.UseJumpPower,
			JumpPower = humanoid.JumpPower,
			JumpHeight = humanoid.JumpHeight,
			WalkSpeed = humanoid.WalkSpeed,
		}
	end
	local defaults = defaultJump[humanoid]
	local boost = jumpBoost() * assistFactor()
	-- Base height: moon jumps in low gravity (fixed 50 jump power), normal height otherwise.
	local baseHeight = zone.Gravity < 150 and (50 * 50) / (2 * zone.Gravity) or defaults.JumpHeight
	local height = baseHeight * boost + powerBonus()
	humanoid.UseJumpPower = true
	humanoid.JumpPower = math.sqrt(2 * zone.Gravity * height)
	humanoid.JumpHeight = height
	-- Don't fight a Speed Coil (it sets its own WalkSpeed while held).
	if not (character and character:FindFirstChild("Speed Coil")) then
		humanoid.WalkSpeed = defaults.WalkSpeed * assistFactor()
	end
end

-- In the OP tower the look follows the biome (gravity stays normal so the difficulty is fair).
local opLook = { Name = "OP", Gravity = 196.2 }

local function currentZoneInfo()
	if player:GetAttribute("Mode") == "OP" then
		local opStat = player.leaderstats:FindFirstChild("OP")
		local tier = math.floor(((opStat and opStat.Value or 1) - 1) / Config.OP.TierSize)
		local biomes = Config.OP.Biomes
		local biome = biomes[math.min(math.floor(tier / Config.OP.TiersPerBiome) + 1, #biomes)]
		opLook.LookName = biome.Look
		opLook.ClockTime = biome.ClockTime
		return opLook, biome.Look
	end
	local zone = Config.ZoneForStage(stageValue.Value)
	return zone, zone.Name
end

-- Custom skyboxes (Assets.Skyboxes) per world, if the ids have been set.
local SKY_FOR_LOOK = {
	["SKY ISLANDS"] = "Sky",
	["CANDY LAND"] = "Candy",
	["OUTER SPACE"] = "Space",
	["GARY'S LAIR"] = "Lair",
	["FROZEN PEAKS"] = "Sky",
	["GOLDEN VAULT"] = "Sky",
}
local function applySky(lookName)
	local ids = Config.Skyboxes[SKY_FOR_LOOK[lookName] or "Sky"]
	if not ids or not Config.HasAsset(ids.Ft) then
		return
	end
	local sky = Lighting:FindFirstChild("WorldSky") or Instance.new("Sky")
	sky.Name = "WorldSky"
	sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt = ids.Bk, ids.Dn, ids.Ft
	sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = ids.Lf, ids.Rt, ids.Up
	sky.CelestialBodiesShown = lookName ~= "OUTER SPACE"
	sky.Parent = Lighting
end

local lastLook
local function applyZone()
	local zone, lookName = currentZoneInfo()
	applyMovement(zone)
	if lookName == lastLook then
		return
	end
	lastLook = lookName
	applySky(lookName)
	local look = LOOKS[lookName] or LOOKS["SKY ISLANDS"]
	local info = TweenInfo.new(2, Enum.EasingStyle.Sine)
	TweenService:Create(Lighting, info, { ClockTime = zone.ClockTime, Brightness = look.Brightness }):Play()
	TweenService:Create(correction, info, { TintColor = look.Tint, Saturation = look.Saturation }):Play()
	TweenService:Create(atmosphere, info, {
		Density = look.Density,
		Haze = look.Haze,
		Glare = look.Glare,
		Color = look.Color,
		Decay = look.Decay,
	}):Play()
end

stageValue.Changed:Connect(applyZone)
player.leaderstats:WaitForChild("OP").Changed:Connect(applyZone)
for _, attribute in ipairs({ "JumpBoost", "BootsOff", "PowerOn", "JumpPower", "Assist", "Mode" }) do
	player:GetAttributeChangedSignal(attribute):Connect(applyZone)
end
player.CharacterAdded:Connect(function(character)
	character:WaitForChild("Humanoid")
	applyZone()
end)
applyZone()

---------------------------------------------------------------- Jump pads
local cooldown = 0
local function hookPad(pad)
	if not pad:IsA("BasePart") then
		return
	end
	pad.Touched:Connect(function(hit)
		local character = player.Character
		if not character or hit.Parent ~= character or os.clock() < cooldown then
			return
		end
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end
		cooldown = os.clock() + 0.4
		local v = root.AssemblyLinearVelocity
		if pad:GetAttribute("Yeet") then
			-- Straight up (so you land back where you started) - pure clip material.
			root.AssemblyLinearVelocity = Vector3.new(0, pad:GetAttribute("Power") or 250, 0)
			Sfx.Play("JumpPad", 0.5)
			player:SetAttribute("Yeeted", (player:GetAttribute("Yeeted") or 0) + 1)
		else
			root.AssemblyLinearVelocity = Vector3.new(v.X, pad:GetAttribute("Power") or 80, v.Z)
			Sfx.Play("JumpPad")
		end
	end)
end

for _, pad in ipairs(CollectionService:GetTagged("JumpPad")) do
	hookPad(pad)
end
CollectionService:GetInstanceAddedSignal("JumpPad"):Connect(hookPad)
]==])
add(f_client, "LocalScript", "RaceBar", [==[
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

local ZONE_COLORS = { Color3.fromRGB(80, 170, 255), Color3.fromRGB(255, 120, 200), Color3.fromRGB(150, 90, 255), Color3.fromRGB(255, 100, 30) }
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
]==])
add(f_client, "LocalScript", "Rewards", [==[
-- REWARDS window (Daily Draw, daily login, promo codes, group bonus) and the STAGE SELECT window.
-- Opened from the Interface (REWARDS button / clicking the stage counter) via player attributes.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Sfx = require(Shared:WaitForChild("Sfx"))
local UI = require(Shared:WaitForChild("UI"))

local player = Players.LocalPlayer
local COLORS = UI.COLORS
local make, text, button = UI.make, UI.text, UI.button

local state = { Passes = {}, Unlocks = {}, RedeemedCodes = {}, MaxStage = 1, NextDrawIn = 0 }
local stateTime = os.clock() -- when `state` arrived (for countdowns)

local gui = make("ScreenGui", {
	Name = "RewardsUI",
	ResetOnSpawn = false,
	DisplayOrder = 5,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = player:WaitForChild("PlayerGui"),
})

local function rarityByName(name)
	for _, rarity in ipairs(Config.DrawRarities) do
		if rarity.Name == name then
			return rarity
		end
	end
	return nil
end

local function section(parent, order, height)
	return make("Frame", {
		LayoutOrder = order,
		Size = UDim2.new(1, -8, 0, height),
		BackgroundColor3 = COLORS.Card,
		ZIndex = 5,
		Parent = parent,
	}, { UI.corner(14), UI.stroke(2) })
end

---------------------------------------------------------------- REWARDS window
local rewardsWindow, rewardsContent = UI.window(gui, "REWARDS", Vector2.new(560, 600))
make("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = rewardsContent })
make("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), Parent = rewardsContent })

-- Daily Draw
local drawSection = section(rewardsContent, 1, 300)
local card = make("Frame", {
	Position = UDim2.fromOffset(12, 12),
	Size = UDim2.fromOffset(150, 200),
	BackgroundColor3 = COLORS.Grey,
	ZIndex = 6,
	Parent = drawSection,
}, { UI.corner(14), UI.stroke(3) })
local cardImage = make("ImageLabel", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	ScaleType = Enum.ScaleType.Fit,
	ZIndex = 7,
	Parent = card,
})
local cardText = text({
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(1, -12, 0, 40),
	Text = "?",
	ZIndex = 8,
	Parent = card,
})
text({
	Position = UDim2.fromOffset(176, 12),
	Size = UDim2.new(1, -188, 0, 32),
	Text = "DAILY DRAW",
	TextColor3 = COLORS.Gold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 6,
	Parent = drawSection,
})
local drawStatus = text({
	Position = UDim2.fromOffset(176, 46),
	Size = UDim2.new(1, -188, 0, 100),
	Text = "",
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	ZIndex = 6,
	Parent = drawSection,
})
local oddsParts = {}
for _, rarity in ipairs(Config.DrawRarities) do
	table.insert(oddsParts, ("%s %d%%"):format(rarity.Name, rarity.Chance))
end
text({
	Position = UDim2.fromOffset(176, 150),
	Size = UDim2.new(1, -188, 0, 20),
	Text = "Odds: " .. table.concat(oddsParts, "  •  "),
	TextColor3 = Color3.fromRGB(190, 190, 220),
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 6,
	Parent = drawSection,
})
local drawButton = button({
	Position = UDim2.fromOffset(176, 176),
	Size = UDim2.new(1, -188, 0, 40),
	BackgroundColor3 = COLORS.Green,
	Text = "DRAW!",
	ZIndex = 6,
	Parent = drawSection,
})
local nicknameBox = make("TextBox", {
	Position = UDim2.fromOffset(12, 224),
	Size = UDim2.new(1, -140, 0, 32),
	BackgroundColor3 = COLORS.Panel,
	PlaceholderText = "Type a nickname (Rare+)",
	Text = "",
	ClearTextOnFocus = false,
	Font = UI.FONT,
	TextScaled = true,
	TextColor3 = COLORS.Text,
	ZIndex = 6,
	Parent = drawSection,
}, { UI.corner(8) })
local nicknameButton = button({
	Position = UDim2.new(1, -120, 0, 224),
	Size = UDim2.fromOffset(108, 32),
	BackgroundColor3 = COLORS.Gold,
	Text = "SET",
	ZIndex = 6,
	Parent = drawSection,
})
local bootsToggle = button({
	Position = UDim2.fromOffset(12, 262),
	Size = UDim2.new(0.5, -18, 0, 30),
	BackgroundColor3 = COLORS.Blue,
	Text = "Jump Boots: ON",
	ZIndex = 6,
	Parent = drawSection,
})
local jumpsToggle = button({
	Position = UDim2.new(0.5, 6, 0, 262),
	Size = UDim2.new(0.5, -18, 0, 30),
	BackgroundColor3 = COLORS.Blue,
	Text = "Multi-Jump: ON",
	ZIndex = 6,
	Parent = drawSection,
})

-- Daily login
local loginSection = section(rewardsContent, 2, 96)
text({
	Position = UDim2.fromOffset(14, 10),
	Size = UDim2.new(1, -28, 0, 28),
	Text = "DAILY LOGIN STREAK",
	TextColor3 = COLORS.Gold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 6,
	Parent = loginSection,
})
local loginStatus = text({
	Position = UDim2.fromOffset(14, 44),
	Size = UDim2.new(1, -170, 0, 36),
	Text = "",
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 6,
	Parent = loginSection,
})
local loginButton = button({
	Position = UDim2.new(1, -150, 0, 42),
	Size = UDim2.fromOffset(136, 40),
	BackgroundColor3 = COLORS.Purple,
	Text = "CLAIM",
	ZIndex = 6,
	Parent = loginSection,
})

-- Codes
local codeSection = section(rewardsContent, 3, 96)
text({
	Position = UDim2.fromOffset(14, 10),
	Size = UDim2.new(1, -28, 0, 28),
	Text = "CODES",
	TextColor3 = COLORS.Gold,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 6,
	Parent = codeSection,
})
local codeBox = make("TextBox", {
	Position = UDim2.fromOffset(14, 44),
	Size = UDim2.new(1, -170, 0, 38),
	BackgroundColor3 = COLORS.Panel,
	PlaceholderText = "Enter code",
	Text = "",
	ClearTextOnFocus = false,
	Font = UI.FONT,
	TextScaled = true,
	TextColor3 = COLORS.Text,
	ZIndex = 6,
	Parent = codeSection,
}, { UI.corner(8) })
local codeButton = button({
	Position = UDim2.new(1, -150, 0, 42),
	Size = UDim2.fromOffset(136, 40),
	BackgroundColor3 = COLORS.Green,
	Text = "REDEEM",
	ZIndex = 6,
	Parent = codeSection,
})

-- Group bonus (only if Config.GroupId is set)
local groupSection = section(rewardsContent, 4, 70)
groupSection.Visible = Config.GroupId ~= 0
local groupButton = button({
	Position = UDim2.fromOffset(14, 14),
	Size = UDim2.new(1, -28, 0, 42),
	BackgroundColor3 = COLORS.Orange,
	Text = ("Join our group for +%d coins"):format(Config.GroupReward),
	ZIndex = 6,
	Parent = groupSection,
})

-- Rebirth
local rebirthSection = section(rewardsContent, 5, 96)
text({
	Position = UDim2.fromOffset(14, 10),
	Size = UDim2.new(1, -28, 0, 28),
	Text = "REBIRTH",
	TextColor3 = Color3.fromRGB(255, 80, 120),
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 6,
	Parent = rebirthSection,
})
local rebirthStatus = text({
	Position = UDim2.fromOffset(14, 44),
	Size = UDim2.new(1, -170, 0, 40),
	Text = "",
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 6,
	Parent = rebirthSection,
})
local rebirthButton = button({
	Position = UDim2.new(1, -150, 0, 42),
	Size = UDim2.fromOffset(136, 40),
	BackgroundColor3 = Color3.fromRGB(255, 80, 120),
	Text = "REBIRTH",
	ZIndex = 6,
	Parent = rebirthSection,
})

local feedback = text({
	LayoutOrder = 6,
	Size = UDim2.new(1, -8, 0, 28),
	Text = "",
	ZIndex = 6,
	Parent = rewardsContent,
})
local function say(message, good)
	feedback.Text = message or ""
	feedback.TextColor3 = good and COLORS.Green or COLORS.Red
end

---------------------------------------------------------------- Draw card + refresh
local function showRarity(rarity)
	if not rarity then
		card.BackgroundColor3 = COLORS.Grey
		cardImage.Image = ""
		cardText.Text = "?"
		return
	end
	card.BackgroundColor3 = rarity.Color
	local image = Config.Images["Draw" .. rarity.Name]
	cardImage.Image = Config.HasAsset(image) and image or ""
	cardText.Text = Config.HasAsset(image) and "" or rarity.Name:upper()
end

local drawing = false
local function refresh()
	local elapsed = os.clock() - stateTime
	local active = state.Draw and rarityByName(state.Draw.Rarity)
	local left = (state.DrawSecondsLeft or 0) - elapsed
	if active and left <= 0 then
		active = nil
	end
	if not drawing then
		showRarity(active)
	end
	if active then
		drawStatus.Text = ("%s prize active (%s left):\n• %s"):format(active.Name, UI.formatDuration(left), table.concat(active.Perks, "\n• "))
	else
		drawStatus.Text = "Draw a free prize every day!\nJump boots, auras, name tags...\nLegendary = +50% coins!"
	end
	local nextDraw = (state.NextDrawIn or 0) - elapsed
	if nextDraw <= 0 then
		drawButton.Text = "DRAW!"
		drawButton.BackgroundColor3 = COLORS.Green
	else
		drawButton.Text = "Next draw in " .. UI.formatDuration(nextDraw)
		drawButton.BackgroundColor3 = COLORS.Grey
	end
	local canNickname = active and active.Nickname
	nicknameBox.Visible = canNickname == true
	nicknameButton.Visible = canNickname == true
	bootsToggle.Visible = active ~= nil
	bootsToggle.Text = player:GetAttribute("BootsOff") and "Jump Boots: OFF" or "Jump Boots: ON"
	bootsToggle.BackgroundColor3 = player:GetAttribute("BootsOff") and COLORS.Grey or COLORS.Blue
	jumpsToggle.Visible = (player:GetAttribute("MaxJumps") or 1) > 1
	jumpsToggle.Text = player:GetAttribute("MultiJumpOff") and "Multi-Jump: OFF" or "Multi-Jump: ON"
	jumpsToggle.BackgroundColor3 = player:GetAttribute("MultiJumpOff") and COLORS.Grey or COLORS.Blue

	if state.DailyReady then
		loginStatus.Text = ("Day %d reward: %d coins"):format(state.NextDailyDay or 1, state.NextDailyReward or 0)
		loginButton.Text = "CLAIM"
		loginButton.BackgroundColor3 = COLORS.Purple
	else
		loginStatus.Text = "Come back tomorrow for the next day!"
		loginButton.Text = "CLAIMED"
		loginButton.BackgroundColor3 = COLORS.Grey
	end
	groupSection.Visible = Config.GroupId ~= 0 and not state.GroupRewardClaimed

	local rebirths = state.Rebirths or 0
	local nextMult = 1 + (rebirths + 1) * Config.RebirthMultiplierStep
	rebirthStatus.Text = ("Rebirths: %d. Next: permanent x%s coins + trail + chat title. Costs %d coins + %d win, resets coins/wins/stage.")
		:format(rebirths, tostring(nextMult), state.RebirthCost or Config.RebirthCost, Config.RebirthWinsNeeded)
end

drawButton.Activated:Connect(function()
	if drawing then
		return
	end
	drawing = true
	local ok, result = Remotes.DailyDraw:InvokeServer()
	if not ok then
		drawing = false
		say(result, false)
		return
	end
	-- Reveal: flick through the rarities, slowing down, then land on the prize.
	local delayTime = 0.05
	for i = 1, 16 do
		showRarity(Config.DrawRarities[(i - 1) % #Config.DrawRarities + 1])
		Sfx.Play("Click", 0.8 + i * 0.04)
		task.wait(delayTime)
		delayTime *= 1.18
	end
	local rarity = rarityByName(result)
	showRarity(rarity)
	local scale = card:FindFirstChildOfClass("UIScale") or make("UIScale", { Parent = card })
	scale.Scale = 1.3
	TweenService:Create(scale, TweenInfo.new(0.4, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	Sfx.Play(result == "Legendary" and "Win" or "Purchase")
	say(("You got %s!"):format(result:upper()), true)
	drawing = false
	refresh()
end)

nicknameButton.Activated:Connect(function()
	local ok, message = Remotes.SetNickname:InvokeServer(nicknameBox.Text)
	say(message, ok)
end)

bootsToggle.Activated:Connect(function()
	player:SetAttribute("BootsOff", not player:GetAttribute("BootsOff"))
	refresh()
end)
jumpsToggle.Activated:Connect(function()
	player:SetAttribute("MultiJumpOff", not player:GetAttribute("MultiJumpOff"))
	refresh()
end)

loginButton.Activated:Connect(function()
	local ok, message = Remotes.ClaimDaily:InvokeServer()
	say(message, ok)
	if ok then
		Sfx.Play("Daily")
	end
end)

codeButton.Activated:Connect(function()
	local ok, message = Remotes.RedeemCode:InvokeServer(codeBox.Text)
	say(message, ok)
	if ok then
		codeBox.Text = ""
		Sfx.Play("Purchase")
	end
end)

rebirthButton.Activated:Connect(function()
	local ok, message = Remotes.Rebirth:InvokeServer()
	say(message, ok)
	if ok then
		Sfx.Play("Win")
	end
end)

groupButton.Activated:Connect(function()
	local ok, message = Remotes.ClaimGroup:InvokeServer()
	say(message, ok)
end)

---------------------------------------------------------------- STAGE SELECT window
local stagesWindow, stagesContent = UI.window(gui, "STAGE SELECT", Vector2.new(560, 520))
make("UIGridLayout", {
	CellSize = UDim2.fromOffset(72, 56),
	CellPadding = UDim2.fromOffset(8, 8),
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = stagesContent,
})
local ZONE_COLORS = { Color3.fromRGB(80, 170, 255), Color3.fromRGB(255, 120, 200), Color3.fromRGB(150, 90, 255), Color3.fromRGB(255, 100, 30) }
local stageButtons = {}

local function zoneIndex(stage)
	local index = 1
	for i, zone in ipairs(Config.Zones) do
		if stage >= zone.FirstStage then
			index = i
		end
	end
	return index
end

local opTierButtons = {}
local function rebuildOPTiers()
	local reached = math.floor(((state.OPStage or 1) - 1) / Config.OP.TierSize) + 1
	for tier, info in ipairs(Config.OP.Tiers) do
		local b = opTierButtons[tier]
		if not b then
			b = button({
				LayoutOrder = 1000 + tier,
				Text = "OP " .. tier,
				ZIndex = 6,
				Parent = stagesContent,
			})
			b.Activated:Connect(function()
				local ok, message = Remotes.TeleportOPTier:InvokeServer(tier)
				if ok then
					stagesWindow.Visible = false
				end
				Sfx.Play(ok and "Checkpoint" or "Click")
				say(message, ok)
			end)
			opTierButtons[tier] = b
		end
		b.BackgroundColor3 = tier <= reached and info[2] or COLORS.Grey
		b.TextColor3 = (tier <= reached and info[2].R + info[2].G + info[2].B > 2.2) and Color3.new(0, 0, 0) or COLORS.Text
	end
end

local function rebuildStages()
	local checkpoints = workspace:FindFirstChild("Checkpoints")
	local total = 0
	for _, child in ipairs(checkpoints and checkpoints:GetChildren() or {}) do
		total = math.max(total, tonumber(child.Name) or 0)
	end
	for stage = 1, math.max(total - 1, 1) do
		local b = stageButtons[stage]
		if not b then
			b = button({
				LayoutOrder = stage,
				Text = tostring(stage),
				ZIndex = 6,
				Parent = stagesContent,
			})
			b.Activated:Connect(function()
				local ok, message = Remotes.TeleportStage:InvokeServer(stage)
				if ok then
					stagesWindow.Visible = false
				else
					b.Text = "🔒"
					task.delay(1, function()
						b.Text = tostring(stage)
					end)
				end
				Sfx.Play(ok and "Checkpoint" or "Click")
				if message then
					say(message, ok)
				end
			end)
			stageButtons[stage] = b
		end
		local unlocked = stage <= (state.MaxStage or 1)
		b.BackgroundColor3 = unlocked and (ZONE_COLORS[zoneIndex(stage)] or COLORS.Blue) or COLORS.Grey
		b.AutoButtonColor = unlocked
	end
end

---------------------------------------------------------------- Open / close + data
player:GetAttributeChangedSignal("RewardsOpen"):Connect(function()
	rewardsWindow.Visible = not rewardsWindow.Visible
	stagesWindow.Visible = false
	refresh()
end)
player:GetAttributeChangedSignal("StageSelectOpen"):Connect(function()
	stagesWindow.Visible = not stagesWindow.Visible
	rewardsWindow.Visible = false
	rebuildStages()
	rebuildOPTiers()
end)
for _, attribute in ipairs({ "MaxJumps", "JumpBoost" }) do
	player:GetAttributeChangedSignal(attribute):Connect(refresh)
end

Remotes.DataUpdated.OnClientEvent:Connect(function(data)
	state = data
	stateTime = os.clock()
	refresh()
	if stagesWindow.Visible then
		rebuildStages()
	end
end)

local initial = Remotes.RequestData:InvokeServer()
if initial then
	state = initial
	stateTime = os.clock()
end
refresh()

-- Keep countdowns ticking while the window is open.
while true do
	task.wait(1)
	if rewardsWindow.Visible then
		refresh()
	end
end
]==])
add(f_client, "LocalScript", "WorldFx", [==[
-- Client-side world animation (smooth, and costs no network):
--   FlowTexture: world floor textures drift by their FlowU/FlowV attributes (studs per second)
--   PortalSpin: portal vortex images spin by their Spin attribute (degrees per second)
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local function tracked(tagName, className)
	local set = {}
	local function add(instance)
		if instance:IsA(className) then
			set[instance] = true
		end
	end
	for _, instance in ipairs(CollectionService:GetTagged(tagName)) do
		add(instance)
	end
	CollectionService:GetInstanceAddedSignal(tagName):Connect(add)
	CollectionService:GetInstanceRemovedSignal(tagName):Connect(function(instance)
		set[instance] = nil
	end)
	return set
end

local textures = tracked("FlowTexture", "Texture")
local spinners = tracked("PortalSpin", "GuiObject")

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	-- a slow sway on top of the drift makes floors look liquid instead of a conveyor belt
	local sway = math.sin(t * 0.6) * 3
	for texture in pairs(textures) do
		local u = texture:GetAttribute("FlowU") or 0
		local v = texture:GetAttribute("FlowV") or 0
		texture.OffsetStudsU = (t * u + sway) % texture.StudsPerTileU
		texture.OffsetStudsV = (t * v - sway) % texture.StudsPerTileV
	end
	for gui in pairs(spinners) do
		gui.Rotation = (t * (gui:GetAttribute("Spin") or 30)) % 360
	end
end)
]==])
print(keptAssets and "Sky Coin Obby updated! (your Assets ids were kept) Press Play to test." or "Sky Coin Obby installed! Press Play to test.")
