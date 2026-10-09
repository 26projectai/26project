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
	Size = UDim2.fromOffset(470, 52),
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
local _, stageLabel = hudPanel(2, 150)
local _, winsLabel = hudPanel(3, 150, Config.Images.Trophy, COLORS.Orange, "W", COLORS.Gold)

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
		Position = UDim2.new(0.5, 0, 0, 96),
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
	Position = UDim2.new(0, 12, 0.6, 0),
	Size = UDim2.fromOffset(84, 460),
	BackgroundTransparency = 1,
	Parent = gui,
}, {
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}),
})

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
local dailyButton = sideButton(2, "DAILY", COLORS.Purple, Config.Images.Daily, "!")
local inviteButton = sideButton(3, "INVITE", COLORS.Green, Config.Images.Invite, "+")
local skipButton = sideButton(4, "SKIP", COLORS.Orange, Config.Images.Skip, ">>")
local musicButton = sideButton(5, "MUSIC", COLORS.Blue, Config.Images.Music, "♪", 64)
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

-- Game pass buttons (only shown for passes that have an id in Config).
local passBar = make("Frame", {
	Position = UDim2.fromOffset(14, 62),
	Size = UDim2.new(1, -28, 0, 44),
	BackgroundTransparency = 1,
	ZIndex = 5,
	Parent = shopWindow,
}, {
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 10),
	}),
})
local passButtons = {}
local PASS_LABELS = { DoubleCoins = "2X COINS", VIP = "VIP" }
for name, id in pairs(Config.GamePasses) do
	if id ~= 0 then
		local button = make("TextButton", {
			Size = UDim2.fromOffset(200, 44),
			BackgroundColor3 = name == "VIP" and COLORS.Gold or COLORS.Purple,
			Font = FONT,
			TextScaled = true,
			TextColor3 = COLORS.Text,
			Text = "Get " .. (PASS_LABELS[name] or name),
			ZIndex = 5,
			Parent = passBar,
		}, { corner(10), stroke(2), make("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }) })
		button.Activated:Connect(function()
			MarketplaceService:PromptGamePassPurchase(player, id)
		end)
		passButtons[name] = button
	end
end
local hasPassBar = next(passButtons) ~= nil
passBar.Visible = hasPassBar

local grid = make("ScrollingFrame", {
	Position = UDim2.fromOffset(14, hasPassBar and 114 or 64),
	Size = UDim2.new(1, -28, 1, hasPassBar and -128 or -78),
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
		Text = item.RequiresVIP and "VIP only" or item.Slot,
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

---------------------------------------------------------------- Daily / invite / skip / music
dailyButton.Activated:Connect(function()
	local ok, message = Remotes.ClaimDaily:InvokeServer()
	toast(message or "", ok and "gold" or "bad")
	if ok then
		Sfx.Play("Daily")
	end
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

musicButton.Activated:Connect(function()
	local muted = not player:GetAttribute("MusicMuted")
	player:SetAttribute("MusicMuted", muted)
	musicButton.BackgroundColor3 = muted and COLORS.Grey or COLORS.Blue
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

Remotes.Won.OnClientEvent:Connect(function(elapsed, isNewBest, reward, wins)
	local lines = {}
	if elapsed then
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
local totalStages = 0
local function countStages()
	local folder = workspace:FindFirstChild("Checkpoints")
	local highest = 0
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

	stageLabel.Text = totalStages > 0 and ("Stage %d/%d"):format(state.Stage, totalStages) or ("Stage " .. state.Stage)
	winsLabel.Text = ("%d  x%s"):format(state.Wins, tostring(math.floor(state.Multiplier * 100 + 0.5) / 100))
	dailyDot.Visible = state.DailyReady == true
	skipButton.Visible = Config.Products.SkipStage ~= 0 and state.Stage < totalStages - 1

	local zone = Config.ZoneForStage(state.Stage)
	if lastZone and zone ~= lastZone then
		showBanner(zone)
	end
	lastZone = zone

	for name, button in pairs(passButtons) do
		button.Visible = not state.Passes[name]
	end

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
		else
			button.Text = "$ " .. item.Price
			button.BackgroundColor3 = state.Coins >= item.Price and COLORS.Gold or COLORS.Grey
		end
	end
end

RunService.RenderStepped:Connect(function()
	if state.RunStart then
		local best = state.BestTime > 0 and ("   Best " .. formatTime(state.BestTime)) or ""
		timerLabel.Text = formatTime(workspace:GetServerTimeNow() - state.RunStart) .. best
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

Remotes.CheckpointReached.OnClientEvent:Connect(function(stage, reward)
	if reward and reward > 0 then
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
	if sender and sender:GetAttribute("VIP") then
		properties.PrefixText = '<font color="#FFD23F">[VIP]</font> ' .. message.PrefixText
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
if state.DailyReady then
	task.delay(2, function()
		toast("Your daily reward is ready! Tap DAILY", "gold")
	end)
end
