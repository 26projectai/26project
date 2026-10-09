-- Greedy Gary's speech bubbles cycle through taunts, and first-time players get a 3-second
-- story intro (no reading required to start playing).
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

local function onPlayerAdded(player)
	local data = PlayerData.WaitFor(player)
	if data and not data.SeenIntro then
		data.SeenIntro = true
		task.wait(1.5)
		Remotes.Fx:FireClient(player, "Intro", Config.Intro)
	end
end
Players.PlayerAdded:Connect(function(player)
	task.spawn(onPlayerAdded, player)
end)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

local index = 0
while true do
	task.wait(6)
	index = index % #Config.VillainTaunts + 1
	for _, gui in ipairs(CollectionService:GetTagged("GaryTaunt")) do
		local label = gui:FindFirstChildOfClass("TextLabel")
		if label then
			label.Text = Config.VillainName:upper() .. ": " .. Config.VillainTaunts[index]
		end
	end
end
