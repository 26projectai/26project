-- HUD (coins + stage), shop window, and pop-up messages. All UI is built in code,
-- so there's nothing to set up in StarterGui.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Catalog = require(Shared:WaitForChild("ShopCatalog"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local player = Players.LocalPlayer

local COLORS = {
	Panel = Color3.fromRGB(30, 30, 50),
	Card = Color3.fromRGB(48, 48, 78),
	Outline = Color3.fromRGB(15, 15, 25),
	Gold = Color3.fromRGB(255, 205, 40),
	Green = Color3.fromRGB(70, 210, 100),
	Blue = Color3.fromRGB(70, 150, 255),
	Pink = Color3.fromRGB(255, 90, 170),
	Red = Color3.fromRGB(235, 70, 70),
	Text = Color3.new(1, 1, 1),
}
local FONT = Enum.Font.FredokaOne

local state = { Coins = 0, Stage = 1, Owned = {}, Equipped = {} }

local function hasImage(id)
	return type(id) == "string" and id ~= "" and not id:match("://0$")
end

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
	if hasImage(imageId) then
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
		Parent = frame,
	})
	return frame
end

local function playSound(id)
	if hasImage(id) then
		local sound = Instance.new("Sound")
		sound.SoundId = id
		sound.Parent = workspace.CurrentCamera
		sound.PlayOnRemove = true
		sound:Destroy()
	end
end

local gui = make("ScreenGui", {
	Name = "ObbyUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = player:WaitForChild("PlayerGui"),
})

---------------------------------------------------------------- HUD
local coinPanel = make("Frame", {
	Position = UDim2.fromOffset(12, 12),
	Size = UDim2.fromOffset(170, 52),
	BackgroundColor3 = COLORS.Panel,
	Parent = gui,
}, { corner(14), stroke(3) })
local coinScale = make("UIScale", { Parent = coinPanel })
icon(Config.Images.Coin, COLORS.Gold, "$", {
	Position = UDim2.fromOffset(6, 6),
	Size = UDim2.fromOffset(40, 40),
	Parent = coinPanel,
})
local coinLabel = text({
	Position = UDim2.fromOffset(54, 8),
	Size = UDim2.new(1, -62, 0, 36),
	Text = "0",
	TextColor3 = COLORS.Gold,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = coinPanel,
})

local stagePanel = make("Frame", {
	Position = UDim2.fromOffset(12, 72),
	Size = UDim2.fromOffset(170, 40),
	BackgroundColor3 = COLORS.Panel,
	Parent = gui,
}, { corner(12), stroke(3) })
local stageLabel = text({
	Position = UDim2.fromOffset(10, 6),
	Size = UDim2.new(1, -20, 1, -12),
	Text = "Stage 1",
	Parent = stagePanel,
})

local shopButton = make("TextButton", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 12, 0.5, 0),
	Size = UDim2.fromOffset(84, 96),
	BackgroundColor3 = COLORS.Pink,
	Text = "",
	AutoButtonColor = true,
	Parent = gui,
}, { corner(16), stroke(3) })
icon(Config.Images.ShopButton, COLORS.Gold, "🛒", {
	Position = UDim2.fromOffset(10, 4),
	Size = UDim2.fromOffset(64, 64),
	Parent = shopButton,
})
text({
	Position = UDim2.new(0, 4, 1, -28),
	Size = UDim2.new(1, -8, 0, 24),
	Text = "SHOP",
	Parent = shopButton,
})

---------------------------------------------------------------- Toasts
local toastLabel = text({
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, -80),
	Size = UDim2.new(0.6, 0, 0, 48),
	Text = "",
	ZIndex = 10,
	Parent = gui,
})
local toastToken = 0
local function toast(message, color)
	toastToken += 1
	local token = toastToken
	toastLabel.Text = message
	toastLabel.TextColor3 = color or COLORS.Text
	TweenService:Create(toastLabel, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, 0, 0, 24),
	}):Play()
	task.delay(2.2, function()
		if token == toastToken then
			TweenService:Create(toastLabel, TweenInfo.new(0.25), {
				Position = UDim2.new(0.5, 0, 0, -80),
			}):Play()
		end
	end)
end

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
	make("UISizeConstraint", { MaxSize = Vector2.new(640, 460) }),
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

local cards = {} -- [itemId] = { Button = TextButton }

local function setOpen(open)
	shopWindow.Visible = open
end

shopButton.Activated:Connect(function()
	setOpen(not shopWindow.Visible)
end)
closeButton.Activated:Connect(function()
	setOpen(false)
end)

local busy = false
local function onCardClicked(item)
	if busy then
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
	toast(message or "", ok and COLORS.Green or COLORS.Red)
	if ok and action == "Buy" then
		playSound(Config.Sounds.Purchase)
	end
end

for index, item in ipairs(Catalog.Items) do
	local card = make("Frame", {
		LayoutOrder = index,
		BackgroundColor3 = COLORS.Card,
		ZIndex = 5,
		Parent = grid,
	}, { corner(14), stroke(3) })
	local fallbackColor = item.Slot == "Trail" and COLORS.Blue or COLORS.Pink
	local art = icon(item.Icon, fallbackColor, item.Name:sub(1, 1), {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 8),
		Size = UDim2.fromOffset(88, 88),
		ZIndex = 5,
		Parent = card,
	})
	for _, d in ipairs(art:GetDescendants()) do
		if d:IsA("GuiObject") then
			d.ZIndex = 6
		end
	end
	text({
		Position = UDim2.new(0, 6, 0, 100),
		Size = UDim2.new(1, -12, 0, 22),
		Text = item.Name,
		ZIndex = 5,
		Parent = card,
	})
	text({
		Position = UDim2.new(0, 6, 0, 122),
		Size = UDim2.new(1, -12, 0, 16),
		Text = item.Slot,
		TextColor3 = Color3.fromRGB(190, 190, 220),
		ZIndex = 5,
		Parent = card,
	})
	local button = make("TextButton", {
		Position = UDim2.new(0, 10, 1, -44),
		Size = UDim2.new(1, -20, 0, 34),
		Font = FONT,
		TextScaled = true,
		TextColor3 = COLORS.Text,
		ZIndex = 5,
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

---------------------------------------------------------------- Refresh
local function totalStages()
	local folder = workspace:FindFirstChild("Checkpoints")
	local highest = 0
	for _, child in ipairs(folder and folder:GetChildren() or {}) do
		highest = math.max(highest, tonumber(child.Name) or 0)
	end
	return highest
end

local lastCoins
local function refresh()
	coinLabel.Text = tostring(state.Coins)
	if lastCoins and state.Coins > lastCoins then
		coinScale.Scale = 1.2
		TweenService:Create(coinScale, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	end
	lastCoins = state.Coins

	local total = totalStages()
	stageLabel.Text = total > 0 and ("Stage %d / %d"):format(state.Stage, total) or ("Stage " .. state.Stage)

	for id, card in pairs(cards) do
		local button = card.Button
		if state.Equipped[card.Item.Slot] == id then
			button.Text = "Equipped ✓"
			button.BackgroundColor3 = COLORS.Green
		elseif state.Owned[id] then
			button.Text = "Equip"
			button.BackgroundColor3 = COLORS.Blue
		else
			button.Text = "$ " .. card.Item.Price
			button.BackgroundColor3 = state.Coins >= card.Item.Price and COLORS.Gold or Color3.fromRGB(110, 110, 130)
		end
	end
end

Remotes.DataUpdated.OnClientEvent:Connect(function(data)
	state = data
	refresh()
end)

Remotes.CheckpointReached.OnClientEvent:Connect(function(stage, isFinal)
	playSound(Config.Sounds.Checkpoint)
	if isFinal then
		toast("🎉 YOU BEAT THE OBBY! 🎉", COLORS.Gold)
	else
		toast(("Checkpoint! Stage %d  (+%d coins)"):format(stage, Config.CheckpointReward), COLORS.Green)
	end
end)

local initial = Remotes.RequestData:InvokeServer()
if initial then
	state = initial
end
refresh()
