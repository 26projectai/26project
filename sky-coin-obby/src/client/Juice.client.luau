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
