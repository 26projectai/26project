-- On-screen UI for the extra modes:
--   OBBY RACE: 3-2-1-GO countdown, live race bar (time left, your place, checkpoint), results board
--   SERVER EVENTS: a banner while an event is running (workspace attributes EventName / EventEnds)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))
local Sfx = require(Shared:WaitForChild("Sfx"))

local player = Players.LocalPlayer
local FONT = Enum.Font.FredokaOne

local gui = Instance.new("ScreenGui")
gui.Name = "ModesUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 8
gui.Parent = player:WaitForChild("PlayerGui")

local function label(props)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Font = FONT
	t.TextScaled = true
	t.TextColor3 = Color3.new(1, 1, 1)
	for key, value in pairs(props) do
		t[key] = value
	end
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Parent = t
	return t
end

local function panel(props)
	local f = Instance.new("Frame")
	f.BackgroundColor3 = Color3.fromRGB(25, 22, 45)
	f.BackgroundTransparency = 0.1
	for key, value in pairs(props) do
		f[key] = value
	end
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = f
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Parent = f
	return f
end

---------------------------------------------------------------- Race UI
local bigText = label({
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.42),
	Size = UDim2.fromOffset(420, 160),
	Text = "",
	Visible = false,
	Parent = gui,
})

local raceBar = panel({
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 175),
	Size = UDim2.fromOffset(460, 44),
	Visible = false,
	Parent = gui,
})
local raceText = label({
	Position = UDim2.fromOffset(10, 4),
	Size = UDim2.new(1, -20, 1, -8),
	Text = "",
	Parent = raceBar,
})

local results = panel({
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(380, 330),
	Visible = false,
	Parent = gui,
})
label({
	Position = UDim2.fromOffset(12, 8),
	Size = UDim2.new(1, -24, 0, 40),
	Text = "🏁 RACE RESULTS",
	TextColor3 = Color3.fromRGB(255, 215, 60),
	Parent = results,
})
local resultRows = Instance.new("Frame")
resultRows.BackgroundTransparency = 1
resultRows.Position = UDim2.fromOffset(16, 56)
resultRows.Size = UDim2.new(1, -32, 1, -68)
resultRows.Parent = results
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = resultRows

local MEDALS = { "🥇", "🥈", "🥉" }
local function ordinal(n)
	return ({ "1st", "2nd", "3rd" })[n] or (n .. "th")
end
local function clock(seconds)
	seconds = math.max(0, seconds)
	return ("%d:%02d"):format(seconds // 60, seconds % 60)
end

local race = { Ends = 0, Total = 0, Map = "", Place = 0, Count = 0, CP = 0, Active = false }

local function showBig(text, color, hold)
	bigText.Text = text
	bigText.TextColor3 = color
	bigText.Visible = true
	bigText.Size = UDim2.fromOffset(620, 240)
	TweenService:Create(bigText, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Size = UDim2.fromOffset(420, 160) }):Play()
	local token = {}
	bigText:SetAttribute("Token", tostring(token))
	task.delay(hold or 0.9, function()
		if bigText:GetAttribute("Token") == tostring(token) then
			bigText.Visible = false
		end
	end)
end

local function updateFromBoard(rows)
	race.Count = #rows
	for i, row in ipairs(rows) do
		if row.UserId == player.UserId then
			race.Place = i
			race.CP = row.CP
		end
	end
end

local function showResults(rows)
	for _, child in ipairs(resultRows:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	for i, row in ipairs(rows) do
		if i > 8 then
			break
		end
		local mine = row.UserId == player.UserId
		local text
		if row.Done then
			text = ("%s %s  %s  %.2fs"):format(MEDALS[row.Place] or "🏁", ordinal(row.Place), row.Name, row.Time or 0)
		else
			text = ("❌ DNF  %s  (CP %d)"):format(row.Name, row.CP or 0)
		end
		label({
			LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, 28),
			Text = text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = mine and Color3.fromRGB(255, 230, 90) or Color3.new(1, 1, 1),
			Parent = resultRows,
		})
	end
	results.Visible = true
	task.delay(6.5, function()
		results.Visible = false
	end)
end

Remotes.RaceState.OnClientEvent:Connect(function(state)
	if state.Phase == "Countdown" then
		race.Active = false
		race.Map = state.Map or ""
		race.Total = state.Total or 0
		raceBar.Visible = true
		raceText.Text = "🏁 " .. race.Map .. "  •  GET READY!"
		showBig(tostring(state.Count), Color3.fromRGB(255, 230, 90), 0.9)
		Sfx.Play("Click", 0.8 + (3 - (state.Count or 3)) * 0.15)
	elseif state.Phase == "Go" then
		race.Active = true
		race.Ends = state.Ends or 0
		race.Total = state.Total or race.Total
		showBig("GO!", Color3.fromRGB(90, 255, 120), 0.9)
		Sfx.Play("Checkpoint", 1.3)
	elseif state.Phase == "Racing" then
		race.Active = true
		race.Ends = state.Ends or race.Ends
		updateFromBoard(state.Board or {})
	elseif state.Phase == "Results" then
		race.Active = false
		raceBar.Visible = false
		showResults(state.Board or {})
		Sfx.Play("Win")
	elseif state.Phase == "Left" then
		race.Active = false
		raceBar.Visible = false
	end
end)

---------------------------------------------------------------- Server event banner
local eventBar = panel({
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 175),
	Size = UDim2.fromOffset(420, 40),
	BackgroundColor3 = Color3.fromRGB(120, 40, 160),
	Visible = false,
	Parent = gui,
})
local eventText = label({
	Position = UDim2.fromOffset(10, 4),
	Size = UDim2.new(1, -20, 1, -8),
	Text = "",
	Parent = eventBar,
})

RunService.Heartbeat:Connect(function()
	local now = workspace:GetServerTimeNow()
	if race.Active then
		local cpText = race.Total > 1 and ("CP %d/%d"):format(math.min(race.CP, race.Total - 1), race.Total - 1) or ""
		local placeText = race.Place > 0 and ("%s / %d"):format(ordinal(race.Place), race.Count) or ""
		raceText.Text = ("🏁 %s  •  ⏱ %s  •  %s  •  %s"):format(race.Map, clock(race.Ends - now), placeText, cpText)
	end
	local name = workspace:GetAttribute("EventName")
	local ends = workspace:GetAttribute("EventEnds") or 0
	if name and ends > now then
		eventBar.Visible = true
		-- sit below the race bar when both are on screen
		eventBar.Position = UDim2.new(0.5, 0, 0, raceBar.Visible and 225 or 175)
		eventText.Text = ("%s  %s"):format(name, clock(ends - now))
	else
		eventBar.Visible = false
	end
end)
