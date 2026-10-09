-- Leaderboards on in-world boards:
--   Board_Wins  - global Most Wins        (all servers)
--   Board_Time  - global Fastest Full Run (all servers)
--   Board_Live  - live race in this server, by current stage
-- Tag any part with one of these and it becomes that board.
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

local REFRESH_SECONDS = 60
local SHOWN = 10

local okStores, winsStore, timeStore, opStore = pcall(function()
	return DataStoreService:GetOrderedDataStore("Wins_" .. Config.LeaderboardVersion),
		DataStoreService:GetOrderedDataStore("BestTime_" .. Config.LeaderboardVersion),
		DataStoreService:GetOrderedDataStore("OPStage_" .. Config.LeaderboardVersion)
end)
if not okStores then
	warn("[Leaderboards] Unavailable:", winsStore)
	winsStore, timeStore, opStore = nil, nil, nil
end

local names = {}
local function nameFor(userId)
	if names[userId] then
		return names[userId]
	end
	local ok, name = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	names[userId] = ok and name or "Player"
	return names[userId]
end

local function formatTime(seconds)
	return ("%d:%05.2f"):format(seconds // 60, seconds % 60)
end

local function buildBoard(part, title, color)
	local gui = part:FindFirstChild("BoardGui") or Instance.new("SurfaceGui")
	gui.Name = "BoardGui"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui:ClearAllChildren()

	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
	bg.Parent = gui

	local header = Instance.new("TextLabel")
	header.Size = UDim2.fromScale(1, 0.14)
	header.BackgroundColor3 = color
	header.Font = Enum.Font.FredokaOne
	header.TextScaled = true
	header.TextColor3 = Color3.new(1, 1, 1)
	header.Text = title
	header.Parent = bg

	local list = Instance.new("Frame")
	list.Name = "List"
	list.Position = UDim2.fromScale(0.04, 0.16)
	list.Size = UDim2.fromScale(0.92, 0.82)
	list.BackgroundTransparency = 1
	list.Parent = bg
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	for i = 1, SHOWN do
		local row = Instance.new("TextLabel")
		row.Name = "Row" .. i
		row.LayoutOrder = i
		row.Size = UDim2.fromScale(1, 1 / SHOWN)
		row.BackgroundTransparency = 1
		row.Font = Enum.Font.FredokaOne
		row.TextScaled = true
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.TextColor3 = i == 1 and Color3.fromRGB(255, 215, 60)
			or i == 2 and Color3.fromRGB(220, 220, 235)
			or i == 3 and Color3.fromRGB(230, 150, 90)
			or Color3.new(1, 1, 1)
		row.Text = ""
		row.Parent = list
	end
	gui.Parent = part
	return list
end

local function fill(list, entries, formatValue)
	for i = 1, SHOWN do
		local row = list:FindFirstChild("Row" .. i)
		local entry = entries[i]
		row.Text = entry and ("#%d  %s  -  %s"):format(i, nameFor(tonumber(entry.key)), formatValue(entry.value)) or ""
	end
end

-- Boards are found by tag, so the same board type can appear in several places.
local CollectionService = game:GetService("CollectionService")

local function listsFor(tagName, title, color)
	local lists = {}
	local function add(part)
		if part:IsA("BasePart") then
			table.insert(lists, buildBoard(part, title, color))
		end
	end
	for _, part in ipairs(CollectionService:GetTagged(tagName)) do
		add(part)
	end
	CollectionService:GetInstanceAddedSignal(tagName):Connect(add)
	return lists
end

-- Wait for the course builder (boards are created at startup).
workspace:WaitForChild("Checkpoints", 30)
local winsLists = listsFor("Board_Wins", "MOST WINS", Color3.fromRGB(255, 170, 40))
local timeLists = listsFor("Board_Time", "FASTEST RUN", Color3.fromRGB(70, 160, 255))
local liveLists = listsFor("Board_Live", "LIVE RACE", Color3.fromRGB(80, 220, 120))
local opLists = listsFor("Board_OP", "OP TOWER TOP", Color3.fromRGB(255, 0, 90))

local function fillAll(lists, entries, formatValue)
	-- Boards in streamed OP tiers come and go; drop the ones that were destroyed.
	for i = #lists, 1, -1 do
		if not lists[i]:IsDescendantOf(workspace) then
			table.remove(lists, i)
		end
	end
	for _, list in ipairs(lists) do
		fill(list, entries, formatValue)
	end
end

local function setNotice(lists, text)
	for _, list in ipairs(lists) do
		list.Row1.Text = text
	end
end

local lastOPEntries = {}
local function refreshGlobal()
	if not winsStore then
		setNotice(winsLists, "Works once the game is published")
		setNotice(timeLists, "Works once the game is published")
		setNotice(opLists, "Works once the game is published")
		return
	end
	-- Upload everyone in this server first.
	for _, player in ipairs(Players:GetPlayers()) do
		local data = PlayerData.Get(player)
		if data then
			local key = tostring(player.UserId)
			if data.Wins > 0 then
				pcall(winsStore.SetAsync, winsStore, key, data.Wins)
			end
			if data.BestTime > 0 then
				pcall(timeStore.SetAsync, timeStore, key, math.floor(data.BestTime * 100)) -- hundredths
			end
			if data.OPStage > 1 then
				pcall(opStore.SetAsync, opStore, key, data.OPStage)
			end
		end
	end

	local okWins, winsPage = pcall(winsStore.GetSortedAsync, winsStore, false, SHOWN)
	if okWins then
		fillAll(winsLists, winsPage:GetCurrentPage(), function(v)
			return v .. " wins"
		end)
	end
	local okOP, opPage = pcall(opStore.GetSortedAsync, opStore, false, SHOWN)
	if okOP then
		lastOPEntries = opPage:GetCurrentPage()
	end
	local okTime, timePage = pcall(timeStore.GetSortedAsync, timeStore, true, SHOWN)
	if okTime then
		fillAll(timeLists, timePage:GetCurrentPage(), function(v)
			return formatTime(v / 100)
		end)
	end
end

-- Live race: everyone in this server, furthest stage first.
local function refreshLive()
	local entries = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local data = PlayerData.Get(player)
		if data then
			names[player.UserId] = player.DisplayName
			table.insert(entries, { key = tostring(player.UserId), value = data.Stage, wins = data.Wins })
		end
	end
	table.sort(entries, function(a, b)
		if a.value ~= b.value then
			return a.value > b.value
		end
		return a.wins > b.wins
	end)
	fillAll(liveLists, entries, function(v)
		return "Stage " .. v
	end)
	-- OP boards refresh often too, so newly streamed station boards fill quickly.
	fillAll(opLists, lastOPEntries, function(v)
		return "OP " .. v
	end)
end

task.spawn(function()
	while true do
		refreshLive()
		task.wait(2)
	end
end)

while true do
	refreshGlobal()
	task.wait(REFRESH_SECONDS)
end
