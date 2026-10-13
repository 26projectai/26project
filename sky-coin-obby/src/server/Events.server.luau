-- SERVER EVENTS: every few minutes a random event runs for everyone on the server for 60 seconds.
--   🪙 COIN RAIN      - coins fall all over the lobby; grab as many as you can
--   💰 2X COIN FRENZY - every coin you earn is doubled
--   🌙 LOW GRAVITY    - floaty moon jumps everywhere
-- The banner + timer are shown by Modes.client (workspace attributes EventName / EventEnds).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

local EVENT_SECONDS = 60
local FIRST_EVENT_AFTER = 120 -- seconds after the server starts
local GAP_MIN, GAP_MAX = 6 * 60, 9 * 60 -- time between events
local RAIN_COIN_VALUE = 10

local firstPad = workspace:WaitForChild("Checkpoints"):WaitForChild("1")
local Config = require(Shared:WaitForChild("Config"))
local LOBBY = firstPad.Position + Config.Lobby.Center

local function announce(text)
	for _, player in ipairs(Players:GetPlayers()) do
		Remotes.Notify:FireClient(player, text, "gold")
		Remotes.Fx:FireClient(player, "Confetti")
	end
end

---------------------------------------------------------------- Coin rain
local function dropCoin(folder)
	local angle = math.random() * math.pi * 2
	local radius = math.random() * (Config.Lobby.Diameter / 2 - 20)
	local ground = LOBBY + Vector3.new(math.cos(angle) * radius, 2.2, math.sin(angle) * radius)
	local coin = Instance.new("Part")
	coin.Name = "RainCoin"
	coin.Shape = Enum.PartType.Cylinder
	coin.Size = Vector3.new(0.5, 3, 3)
	coin.Color = Color3.fromRGB(255, 205, 40)
	coin.Material = Enum.Material.Neon
	coin.Anchored = true
	coin.CanCollide = false
	coin.CastShadow = false
	coin.CFrame = CFrame.new(ground + Vector3.new(0, 45, 0)) * CFrame.Angles(0, angle, 0)
	coin.Parent = folder
	TweenService:Create(coin, TweenInfo.new(1.4, Enum.EasingStyle.Bounce), { CFrame = CFrame.new(ground) * CFrame.Angles(0, angle, 0) }):Play()
	local taken = false
	coin.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if taken or not player then
			return
		end
		taken = true
		coin:Destroy()
		local amount = PlayerData.AddCoins(player, RAIN_COIN_VALUE, true)
		Remotes.CoinCollected:FireClient(player, nil, 0, amount)
	end)
end

local function coinRain(ends)
	local folder = Instance.new("Folder")
	folder.Name = "CoinRain"
	folder.Parent = workspace
	while workspace:GetServerTimeNow() < ends do
		for _ = 1, 3 do
			dropCoin(folder)
		end
		task.wait(1.5)
	end
	task.wait(3)
	folder:Destroy()
end

---------------------------------------------------------------- Event runner
local EVENTS = {
	{
		Name = "🪙 COIN RAIN in the lobby!",
		Start = function(ends)
			announce("🪙 COIN RAIN! Coins are falling in the lobby - press L to grab them!")
			coinRain(ends)
		end,
	},
	{
		Name = "💰 2X COIN FRENZY",
		Start = function(ends)
			workspace:SetAttribute("FrenzyUntil", ends) -- read by PlayerData.Multiplier
			announce("💰 2X COIN FRENZY! Every coin is doubled for 60 seconds!")
		end,
	},
	{
		Name = "🌙 LOW GRAVITY PARTY",
		Start = function(ends)
			workspace:SetAttribute("LowGravUntil", ends) -- read by Movement.client
			announce("🌙 LOW GRAVITY PARTY! Moon jumps for everyone!")
		end,
	},
}

local last
local function runEvent()
	local pick
	repeat
		pick = EVENTS[math.random(#EVENTS)]
	until pick ~= last or #EVENTS == 1
	last = pick
	local ends = workspace:GetServerTimeNow() + EVENT_SECONDS
	workspace:SetAttribute("EventName", pick.Name)
	workspace:SetAttribute("EventEnds", ends)
	task.spawn(pick.Start, ends)
	task.wait(EVENT_SECONDS)
	workspace:SetAttribute("EventName", nil)
	workspace:SetAttribute("EventEnds", nil)
end

task.spawn(function()
	task.wait(FIRST_EVENT_AFTER)
	while true do
		if #Players:GetPlayers() > 0 then
			runEvent()
		end
		task.wait(math.random(GAP_MIN, GAP_MAX))
	end
end)
