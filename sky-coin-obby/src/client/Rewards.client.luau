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

local feedback = text({
	LayoutOrder = 5,
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
local ZONE_COLORS = { Color3.fromRGB(80, 170, 255), Color3.fromRGB(255, 120, 200), Color3.fromRGB(150, 90, 255) }
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
