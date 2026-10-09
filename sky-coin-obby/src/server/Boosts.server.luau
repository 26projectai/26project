-- Boost Station orbs (every Config.StationInterval stages): touch for a temporary coin boost.
-- Each orb works once per player every 10 minutes.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

local ORB_COOLDOWN = 600
local used = {} -- [Player] = { [stationId] = os.clock() }

local function onTouched(orb, hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	local session = player and PlayerData.Session(player)
	if not session then
		return
	end
	local id = orb:GetAttribute("StationId") or orb:GetFullName()
	used[player] = used[player] or {}
	local last = used[player][id]
	if last and os.clock() - last < ORB_COOLDOWN then
		return
	end
	used[player][id] = os.clock()
	session.StationBoostUntil = workspace:GetServerTimeNow() + Config.StationBoostSeconds
	PlayerData.Sync(player)
	Remotes.Notify:FireClient(player, ("BOOST STATION: x%d coins for %d seconds!"):format(Config.StationBoostMultiplier, Config.StationBoostSeconds), "gold")
	Remotes.Fx:FireClient(player, "Confetti")
end

local hooked = {}
local function hook(orb)
	if orb:IsA("BasePart") and not hooked[orb] then
		hooked[orb] = true
		orb.Touched:Connect(function(hit)
			onTouched(orb, hit)
		end)
		orb.Destroying:Connect(function()
			hooked[orb] = nil
		end)
	end
end
for _, orb in ipairs(CollectionService:GetTagged("BoostOrb")) do
	hook(orb)
end
CollectionService:GetInstanceAddedSignal("BoostOrb"):Connect(hook)

Players.PlayerRemoving:Connect(function(player)
	used[player] = nil
end)
