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
	-- Pinned to the bottom-left, so the last button (MUSIC) can never fall off the screen.
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 12, 1, -10),
	Size = UDim2.fromOffset(84, 540),
	BackgroundTransparency = 1,
	Parent = gui,
}, {
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
	}),
})

-- Shrink the whole column to the space the screen really has (phones, small Studio windows).
do
	local sideScale = Instance.new("UIScale")
	sideScale.Parent = sideBar
	local USED = 5 * 8 + 5 * 84 + 64 -- gaps + five big buttons + the music button
	local function fitSideBar()
		local available = gui.AbsoluteSize.Y - 30
		if available > 0 then
			sideScale.Scale = math.clamp(available / USED, 0.4, 1)
		end
	end
	fitSideBar()
	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitSideBar)
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
-- Windows live in their own layer above every other button/bar on screen.
local windowsGui = make("ScreenGui", {
	Name = "ObbyWindows",
	ResetOnSpawn = false,
	DisplayOrder = 20,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = player:WaitForChild("PlayerGui"),
})

local shopWindow = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.92, 0.86),
	BackgroundColor3 = COLORS.Panel,
	Visible = false,
	ZIndex = 5,
	Parent = windowsGui,
}, {
	corner(18),
	stroke(4),
	make("UISizeConstraint", { MaxSize = Vector2.new(720, 540) }),
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

-- Category tabs
local tabBar = make("Frame", {
	Position = UDim2.fromOffset(14, 60),
	Size = UDim2.new(1, -28, 0, 34),
	BackgroundTransparency = 1,
	ZIndex = 5,
	Parent = shopWindow,
}, {
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})

local grid = make("ScrollingFrame", {
	Position = UDim2.fromOffset(14, 102),
	Size = UDim2.new(1, -28, 1, -116),
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

local SLOT_ORDER = { Trail = 1, Aura = 2, Halo = 3, Hat = 4, Back = 5, Pet = 6 }
local SLOT_NAME = { Trail = "Trail", Aura = "Aura", Halo = "Halo", Hat = "Hat", Back = "Wings", Pet = "Pet" }
local function unlockLevel(item)
	return (item.Stage or 0) + (item.OPStage and 100 + item.OPStage or 0)
end
local sorted = table.clone(Catalog.Items)
table.sort(sorted, function(a, b)
	if (a.RequiresVIP or false) ~= (b.RequiresVIP or false) then
		return b.RequiresVIP == true
	end
	if (a.UnlockText ~= nil) ~= (b.UnlockText ~= nil) then
		return b.UnlockText ~= nil
	end
	if unlockLevel(a) ~= unlockLevel(b) then
		return unlockLevel(a) < unlockLevel(b)
	end
	if a.Price ~= b.Price then
		return a.Price < b.Price
	end
	return (SLOT_ORDER[a.Slot] or 9) < (SLOT_ORDER[b.Slot] or 9)
end)

local currentTab = Catalog.Tabs[1]
local tabButtons = {}
local function applyTab()
	for _, card in pairs(cards) do
		card.Frame.Visible = currentTab.Slots == nil or currentTab.Slots[card.Item.Slot] == true
	end
	for tab, button in pairs(tabButtons) do
		button.BackgroundColor3 = tab == currentTab and COLORS.Gold or COLORS.Card
	end
	grid.CanvasPosition = Vector2.zero
end
for index, tab in ipairs(Catalog.Tabs) do
	local button = make("TextButton", {
		LayoutOrder = index,
		Size = UDim2.new(1 / #Catalog.Tabs, -6, 1, 0),
		BackgroundColor3 = COLORS.Card,
		Font = FONT,
		Text = tab.Name,
		TextScaled = true,
		TextColor3 = COLORS.Text,
		ZIndex = 6,
		Parent = tabBar,
	}, { corner(10), stroke(2), make("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) }) })
	button.Activated:Connect(function()
		currentTab = tab
		Sfx.Play("Click")
		applyTab()
	end)
	tabButtons[tab] = button
end

local function subtitleFor(item)
	if item.RequiresVIP then
		return "VIP only"
	elseif item.UnlockText then
		return "Milestone reward"
	elseif item.CoinBoost then
		return ("Pet  •  +%d%% coins"):format(math.floor(item.CoinBoost * 100 + 0.5))
	end
	return SLOT_NAME[item.Slot] or item.Slot
end

for index, item in ipairs(sorted) do
	local card = make("Frame", {
		LayoutOrder = index,
		BackgroundColor3 = item.RequiresVIP and Color3.fromRGB(90, 70, 20) or COLORS.Card,
		ZIndex = 5,
		Parent = grid,
	}, { corner(14), stroke(3) })
	local fallbackColor = ({ Trail = COLORS.Blue, Aura = COLORS.Pink, Halo = COLORS.Gold, Hat = COLORS.Purple, Back = COLORS.Green, Pet = COLORS.Orange })[item.Slot] or COLORS.Pink
	local art = icon(item.Icon, fallbackColor, item.Emoji or item.Name:sub(1, 1), {
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
		Text = subtitleFor(item),
		TextColor3 = (item.RequiresVIP or item.CoinBoost) and COLORS.Gold or Color3.fromRGB(190, 190, 220),
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
	cards[item.Id] = { Button = button, Item = item, Frame = card }
end
applyTab()

-- Hide the Roblox tool hotbar while a window is open (it would sit on top of the cards).
local function syncHotbar()
	local open = shopWindow.Visible or (windowsGui:FindFirstChild("PassesWindow") and windowsGui.PassesWindow.Visible)
	pcall(function()
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not open)
	end)
end
shopWindow:GetPropertyChangedSignal("Visible"):Connect(syncHotbar)

---------------------------------------------------------------- Game passes window
local PassCatalog = require(Shared:WaitForChild("PassCatalog"))

local passesWindow = make("Frame", {
	Name = "PassesWindow",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.9, 0.8),
	BackgroundColor3 = COLORS.Panel,
	Visible = false,
	ZIndex = 5,
	Parent = windowsGui,
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
		elseif Catalog.LockText(item, state.MaxStage, state.MaxOPStage) then
			button.Text = "🔒 " .. Catalog.LockText(item, state.MaxStage, state.MaxOPStage)
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

passesWindow:GetPropertyChangedSignal("Visible"):Connect(syncHotbar)

---------------------------------------------------------------- Fit small screens (phones)
local hudScale = make("UIScale", { Parent = hud })
local timerScale = make("UIScale", { Parent = timerLabel })
local function fitScreen()
	local viewport = workspace.CurrentCamera.ViewportSize
	hudScale.Scale = math.clamp(viewport.X / 560, 0.6, 1)
	timerScale.Scale = hudScale.Scale
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
