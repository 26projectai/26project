-- OBBY RACE: a separate game mode. Stand on the race pad in the lobby; when the countdown ends
-- everyone on the pad is sent to a freshly built race track. 3-2-1-GO, first to the finish wins.
--   * 4 tracks (built from the OP tower's obstacle sections), picked at random each race
--   * race checkpoints: falling or dying puts you back on your last race checkpoint
--   * live placements, a time limit, coin prizes by place, Race Wins + best times saved
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))
local Server = ServerScriptService:WaitForChild("Server")
local PlayerData = require(Server:WaitForChild("PlayerData"))
local OPGen = require(Server:WaitForChild("OPGen"))

local TRACK_ORIGIN = Vector3.new(0, 400, -2600) -- far from the story course and the OP tower
local SPACING = 40 -- studs between race checkpoints (the obstacle sections are built for this)
local RISE = 2
local PRIZES = { 150, 100, 75 } -- coins for 1st / 2nd / 3rd (other finishers get FINISH_PRIZE)
local FINISH_PRIZE = 40
local TRY_PRIZE = 10 -- for joining a race with other people, even without finishing

local MAPS = {
	{ Id = "SkySprint", Name = "SKY SPRINT", Sections = 6, Difficulty = 0.12, Seed = 7000, Color = Color3.fromRGB(80, 170, 255) },
	{ Id = "CandyRush", Name = "CANDY RUSH", Sections = 7, Difficulty = 0.25, Seed = 7100, Color = Color3.fromRGB(255, 120, 200) },
	{ Id = "LaserDash", Name = "LASER DASH", Sections = 8, Difficulty = 0.4, Seed = 7200, Color = Color3.fromRGB(150, 90, 255) },
	{ Id = "GaryGauntlet", Name = "GARY'S GAUNTLET", Sections = 9, Difficulty = 0.55, Seed = 7300, Color = Color3.fromRGB(255, 100, 30) },
}

local function padPosition(index) -- 0 = start line (virtual pad), 1..N = race checkpoints
	return TRACK_ORIGIN + Vector3.new(8 + SPACING * index, RISE * index, 0)
end

local function part(props, className, parent)
	local p = Instance.new(className or "Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for key, value in pairs(props) do
		p[key] = value
	end
	p.Parent = parent
	return p
end

local function billboard(parentPart, text, color, size, offset)
	local gui = Instance.new("BillboardGui")
	gui.Size = size or UDim2.fromOffset(260, 70)
	gui.StudsOffset = offset or Vector3.new(0, 6, 0)
	gui.MaxDistance = 150
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextStrokeTransparency = 0
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.Text = text
	label.Parent = gui
	gui.Parent = parentPart
	return label
end

---------------------------------------------------------------- Lobby race pad
local checkpoints = workspace:WaitForChild("Checkpoints")
local firstPad = checkpoints:WaitForChild("1")
local lobbyFolder = Instance.new("Folder")
lobbyFolder.Name = "RaceLobby"
lobbyFolder.Parent = workspace

local Config = require(Shared:WaitForChild("Config"))
local PAD_CENTER = firstPad.Position + Config.Lobby.RacePad + Vector3.new(0, -0.7, 0)
local racePad = part({
	Name = "RacePad",
	Size = Vector3.new(11, 0.4, 11),
	Position = PAD_CENTER,
	Color = Color3.fromRGB(40, 40, 50),
	Material = Enum.Material.Neon,
}, "Part", lobbyFolder)
-- checkered top
for x = 0, 4 do
	for z = 0, 4 do
		part({
			Name = "Checker",
			Size = Vector3.new(2.1, 0.1, 2.1),
			Position = PAD_CENTER + Vector3.new(-4.4 + x * 2.2, 0.22, -4.4 + z * 2.2),
			Color = (x + z) % 2 == 0 and Color3.new(1, 1, 1) or Color3.fromRGB(20, 20, 25),
			CanCollide = false,
			CanTouch = false,
		}, "Part", lobbyFolder)
	end
end
-- start-line arch with a checkered banner
for _, dz in ipairs({ -6.2, 6.2 }) do
	part({ Name = "ArchPole", Size = Vector3.new(0.8, 12, 0.8), Position = PAD_CENTER + Vector3.new(0, 6, dz), Color = Color3.fromRGB(255, 200, 60), Material = Enum.Material.Metal }, "Part", lobbyFolder)
end
for k = 0, 11 do
	for row = 0, 1 do
		part({
			Name = "Banner",
			Size = Vector3.new(0.3, 1, 1.05),
			Position = PAD_CENTER + Vector3.new(0, 11 + row, -5.8 + k * 1.05),
			Color = (k + row) % 2 == 0 and Color3.new(1, 1, 1) or Color3.fromRGB(20, 20, 25),
			CanCollide = false,
			CanTouch = false,
		}, "Part", lobbyFolder)
	end
end
local padLabel = billboard(racePad, "🏁 OBBY RACE\nStand here to join!", Color3.fromRGB(255, 230, 90), UDim2.fromOffset(300, 90), Vector3.new(0, 15, 0))

local function playersOnPad()
	local found, list = {}, {}
	local parts = workspace:GetPartBoundsInBox(racePad.CFrame * CFrame.new(0, 4, 0), racePad.Size + Vector3.new(0, 8, 0))
	for _, p in ipairs(parts) do
		local player = Players:GetPlayerFromCharacter(p.Parent)
		local humanoid = player and p.Parent:FindFirstChildOfClass("Humanoid")
		if player and not found[player] and humanoid and humanoid.Health > 0 then
			found[player] = true
			table.insert(list, player)
		end
	end
	return list
end

---------------------------------------------------------------- Track building
local track -- { Folder, Kills, Map, Total, Gate }

local function destroyTrack()
	if track then
		track.Folder:Destroy()
		track.Kills:Destroy()
		track = nil
	end
end

local function buildTrack(map)
	destroyTrack()
	local folder = Instance.new("Folder")
	folder.Name = "RaceTrack"
	local killParts = workspace:FindFirstChild("KillParts") or Instance.new("Folder")
	killParts.Name = "KillParts"
	killParts.Parent = workspace
	local kills = Instance.new("Folder")
	kills.Name = "RaceTrack"
	kills.Parent = killParts

	local light = map.Color:Lerp(Color3.new(1, 1, 1), 0.35)
	local dark = map.Color:Lerp(Color3.new(0, 0, 0), 0.25)
	local total = map.Sections

	-- Start platform + the gate that drops at GO.
	local start = part({ Name = "RaceStart", Size = Vector3.new(24, 1, 30), Position = TRACK_ORIGIN, Color = Color3.fromRGB(40, 40, 50) }, "Part", folder)
	billboard(start, "🏁 " .. map.Name, map.Color, UDim2.fromOffset(360, 70), Vector3.new(0, 14, 0))
	local gate = part({
		Name = "RaceGate",
		Size = Vector3.new(1, 12, 30),
		Position = TRACK_ORIGIN + Vector3.new(12.5, 6.5, 0),
		Color = Color3.fromRGB(255, 60, 60),
		Material = Enum.Material.ForceField,
		Transparency = 0.2,
	}, "Part", folder)
	for _, dz in ipairs({ -15.5, 15.5 }) do
		part({ Name = "StartWall", Size = Vector3.new(24, 6, 1), Position = TRACK_ORIGIN + Vector3.new(0, 3.5, dz), Color = map.Color, Transparency = 0.5 }, "Part", folder)
	end
	part({ Name = "StartWall", Size = Vector3.new(1, 6, 30), Position = TRACK_ORIGIN + Vector3.new(-12.5, 3.5, 0), Color = map.Color, Transparency = 0.5 }, "Part", folder)

	-- Checkpoints + obstacle sections between them.
	local ctx = {
		part = function(props, className, parent)
			return part(props, className, parent or folder)
		end,
		tag = function(p, tagName, attributes)
			CollectionService:AddTag(p, tagName)
			for key, value in pairs(attributes or {}) do
				p:SetAttribute(key, value)
			end
			return p
		end,
		kills = kills,
		light = light,
		dark = dark,
		color = map.Color,
		coin = function() end, -- no coins in races: just speed
	}
	for i = 1, total do
		OPGen.Section(map.Seed + i, padPosition(i - 1), RISE, ctx, map.Difficulty)
		local isFinish = i == total
		local pad = part({
			Name = isFinish and "RaceFinish" or "RaceCheckpoint",
			Size = isFinish and Vector3.new(16, 1, 16) or Vector3.new(8, 1, 10),
			Position = padPosition(i),
			Color = isFinish and Color3.fromRGB(255, 205, 40) or map.Color,
			Material = Enum.Material.Neon,
		}, "Part", folder)
		pad:SetAttribute("Index", i)
		CollectionService:AddTag(pad, isFinish and "RaceFinish" or "RaceCheckpoint")
		billboard(pad, isFinish and "🏁 FINISH!" or ("CP %d/%d"):format(i, total - 1), Color3.new(1, 1, 1), UDim2.fromOffset(160, 40), Vector3.new(0, 4, 0))
	end

	-- Lava under the whole track.
	local length = SPACING * (total + 1) + 80
	part({
		Name = "RaceLava",
		Size = Vector3.new(length, 2, 160),
		Position = TRACK_ORIGIN + Vector3.new(length / 2 - 40, -30, 0),
		Color = Color3.fromRGB(255, 80, 20),
		Material = Enum.Material.CrackedLava,
	}, "Part", kills)

	folder.Parent = workspace
	track = { Folder = folder, Kills = kills, Map = map, Total = total, Gate = gate }
	return track
end

---------------------------------------------------------------- Race state
local phase = "Idle" -- Idle -> Queue -> Starting -> Racing -> Results
local queueEnds = 0
local racers = {} -- [Player] = { CP = 0, Finished = false, Time = nil, Place = nil }
local finishOrder = {}
local raceStart, raceEnds = 0, 0

local function racerCount()
	local n = 0
	for _ in pairs(racers) do
		n += 1
	end
	return n
end

local function board()
	local rows = {}
	for player, info in pairs(racers) do
		table.insert(rows, { Name = player.DisplayName, UserId = player.UserId, CP = info.CP, Done = info.Finished, Time = info.Time, Place = info.Place })
	end
	table.sort(rows, function(a, b)
		if a.Done ~= b.Done then
			return a.Done
		end
		if a.Done then
			return a.Place < b.Place
		end
		return a.CP > b.CP
	end)
	return rows
end

local function sendAll(payload)
	for player in pairs(racers) do
		Remotes.RaceState:FireClient(player, payload)
	end
end

local function lobbyCFrame()
	local spot = firstPad.Position + Vector3.new(-26, 4, math.random(-6, 6))
	return CFrame.lookAt(spot, spot + Vector3.new(1, 0, 0))
end

local function removeRacer(player, toLobby)
	if not racers[player] then
		return
	end
	racers[player] = nil
	player:SetAttribute("Racing", nil)
	Remotes.RaceState:FireClient(player, { Phase = "Left" })
	if toLobby and player.Character then
		player.Character:PivotTo(lobbyCFrame())
		player:SetAttribute("InLobby", true)
	end
end

local function placeAtCheckpoint(player)
	local info = racers[player]
	local character = player.Character
	if not info or not character or not track then
		return
	end
	local index = info.CP
	local position
	if index <= 0 then
		position = TRACK_ORIGIN + Vector3.new(math.random(-8, 6), 4, math.random(-10, 10))
	else
		position = padPosition(index) + Vector3.new(0, 4, 0)
	end
	character:PivotTo(CFrame.lookAt(position, position + Vector3.new(1, 0, 0)))
end

local function finishRace()
	if phase ~= "Racing" then
		return
	end
	phase = "Results"
	local results = board()
	sendAll({ Phase = "Results", Map = track and track.Map.Name, Board = results })
	local multiplayer = #results >= 2
	for player, info in pairs(racers) do
		if not info.Finished and multiplayer then
			local amount = PlayerData.AddCoins(player, TRY_PRIZE, true)
			Remotes.Notify:FireClient(player, ("Race over! +%d coins for taking part."):format(amount), "gold")
		end
	end
	task.delay(7, function()
		for player in pairs(racers) do
			removeRacer(player, true)
		end
		racers, finishOrder = {}, {}
		destroyTrack()
		phase = "Idle"
	end)
end

local function onFinish(player)
	local info = racers[player]
	if phase ~= "Racing" or not info or info.Finished then
		return
	end
	info.Finished = true
	info.CP = track.Total
	info.Time = workspace:GetServerTimeNow() - raceStart
	table.insert(finishOrder, player)
	info.Place = #finishOrder
	local multiplayer = racerCount() >= 2
	local prize = PRIZES[info.Place] or FINISH_PRIZE
	if not multiplayer then
		prize = FINISH_PRIZE -- solo time trials pay the finisher prize
	end
	local amount = PlayerData.AddCoins(player, prize, true)

	local data = PlayerData.Get(player)
	local mapId = track.Map.Id
	local newBest = false
	if data then
		data.RaceBest = data.RaceBest or {}
		if not data.RaceBest[mapId] or info.Time < data.RaceBest[mapId] then
			data.RaceBest[mapId] = math.floor(info.Time * 100) / 100
			newBest = true
		end
		if info.Place == 1 and multiplayer then
			data.RaceWins = (data.RaceWins or 0) + 1
			player:SetAttribute("RaceWins", data.RaceWins)
		end
		PlayerData.Sync(player)
	end
	local placeText = ({ "1ST", "2ND", "3RD" })[info.Place] or (info.Place .. "TH")
	Remotes.Notify:FireClient(player, ("%s PLACE! %.2fs  +%d coins%s"):format(placeText, info.Time, amount, newBest and "  NEW BEST!" or ""), "gold")
	Remotes.Fx:FireClient(player, "Confetti")
	for other in pairs(racers) do
		if other ~= player then
			Remotes.Notify:FireClient(other, ("%s finished %s!"):format(player.DisplayName, placeText), "good")
		end
	end
	-- Everyone done? End early.
	local allDone = true
	for _, other in pairs(racers) do
		if not other.Finished then
			allDone = false
		end
	end
	if allDone then
		task.delay(2, finishRace)
	else
		raceEnds = math.min(raceEnds, workspace:GetServerTimeNow() + 30) -- 30s for the rest after a finish
	end
end

local function hookCheckpoint(pad)
	if not pad:IsA("BasePart") then
		return
	end
	pad.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		local info = player and racers[player]
		if not info or phase ~= "Racing" then
			return
		end
		if CollectionService:HasTag(pad, "RaceFinish") then
			onFinish(player)
			return
		end
		local index = pad:GetAttribute("Index") or 0
		if index > info.CP then
			info.CP = index
		end
	end)
end
CollectionService:GetInstanceAddedSignal("RaceCheckpoint"):Connect(hookCheckpoint)
CollectionService:GetInstanceAddedSignal("RaceFinish"):Connect(hookCheckpoint)

local function startRace(list)
	phase = "Starting"
	local map = MAPS[math.random(#MAPS)]
	buildTrack(map)
	racers, finishOrder = {}, {}
	for k, player in ipairs(list) do
		racers[player] = { CP = 0, Finished = false }
		player:SetAttribute("Racing", true)
		player:SetAttribute("InLobby", nil)
		local session = PlayerData.Session(player)
		if session then
			session.RunStart = nil -- leaving the course ends a timed story run
		end
		PlayerData.Sync(player)
		local character = player.Character
		if character then
			local col, row = (k - 1) % 5, math.floor((k - 1) / 5)
			local spot = TRACK_ORIGIN + Vector3.new(7 - row * 4, 4, -10 + col * 5)
			character:PivotTo(CFrame.lookAt(spot, spot + Vector3.new(1, 0, 0)))
		end
	end
	task.spawn(function()
		for count = 3, 1, -1 do
			sendAll({ Phase = "Countdown", Map = map.Name, Count = count, Total = track.Total })
			task.wait(1)
		end
		if not track then
			return
		end
		track.Gate:Destroy()
		raceStart = workspace:GetServerTimeNow()
		raceEnds = raceStart + 45 + map.Sections * 12
		phase = "Racing"
		sendAll({ Phase = "Go", Map = map.Name, Total = track.Total, Ends = raceEnds })
	end)
end

---------------------------------------------------------------- Main loop
task.spawn(function()
	local lastBoard = 0
	while true do
		task.wait(0.5)
		local now = workspace:GetServerTimeNow()
		if phase == "Idle" or phase == "Queue" then
			local queue = {}
			for _, player in ipairs(playersOnPad()) do
				local data = PlayerData.Get(player)
				if data and data.Mode ~= "OP" then
					table.insert(queue, player)
				end
			end
			if #queue == 0 then
				phase = "Idle"
				padLabel.Text = "🏁 OBBY RACE\nStand here to join!"
			else
				if phase == "Idle" then
					phase = "Queue"
					queueEnds = now + (#queue >= 2 and 10 or 15)
				elseif #queue >= 2 then
					queueEnds = math.min(queueEnds, now + 10)
				end
				local left = math.max(0, math.ceil(queueEnds - now))
				padLabel.Text = ("🏁 RACE: %d racer%s\nStarting in %d...%s"):format(#queue, #queue == 1 and "" or "s", left, #queue == 1 and "\n(solo = time trial)" or "")
				if now >= queueEnds then
					startRace(queue)
				end
			end
		elseif phase == "Racing" then
			-- Drop racers who left, went to the lobby or teleported away.
			for player in pairs(racers) do
				local root = player.Parent and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if not player.Parent or not player:GetAttribute("Racing") or player:GetAttribute("InLobby") then
					removeRacer(player, false)
				elseif root and (root.Position - TRACK_ORIGIN).Magnitude > 1500 then
					removeRacer(player, false)
				end
			end
			if racerCount() == 0 then
				finishRace()
			elseif now >= raceEnds then
				finishRace()
			elseif now - lastBoard >= 1 then
				lastBoard = now
				sendAll({ Phase = "Racing", Map = track.Map.Name, Total = track.Total, Ends = raceEnds, Board = board() })
			end
			padLabel.Text = ("🏁 Race in progress...\n%d:%02d left"):format(math.max(0, raceEnds - now) // 60, math.max(0, raceEnds - now) % 60)
		end
	end
end)

---------------------------------------------------------------- Respawning mid-race
local function onCharacterAdded(player, character)
	if not racers[player] then
		return
	end
	if not character:IsDescendantOf(workspace) then
		character.AncestryChanged:Wait()
	end
	task.wait(0.15)
	placeAtCheckpoint(player)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	player:SetAttribute("Racing", nil)
	task.spawn(function()
		local data = PlayerData.WaitFor(player)
		if data then
			player:SetAttribute("RaceWins", data.RaceWins or 0)
		end
	end)
end
Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
Players.PlayerRemoving:Connect(function(player)
	racers[player] = nil
end)
