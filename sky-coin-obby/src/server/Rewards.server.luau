-- Daily login rewards, friend-invite bonuses and the welcome badge.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Server = ServerScriptService:WaitForChild("Server")
local PlayerData = require(Server:WaitForChild("PlayerData"))
local Badges = require(Server:WaitForChild("Badges"))

---------------------------------------------------------------- Daily reward
Remotes.ClaimDaily.OnServerInvoke = function(player)
	local data = PlayerData.Get(player)
	if not data then
		return false, "Still loading, try again"
	end
	if not PlayerData.DailyReady(data) then
		local hoursLeft = math.ceil((Config.DailyCooldownHours * 3600 - (os.time() - data.LastDaily)) / 3600)
		return false, ("Come back in %d hour%s!"):format(hoursLeft, hoursLeft == 1 and "" or "s")
	end

	local continued = os.time() - data.LastDaily <= 48 * 3600
	data.DailyStreak = continued and data.DailyStreak + 1 or 1
	data.LastDaily = os.time()
	local day = (data.DailyStreak - 1) % #Config.DailyRewards + 1
	local reward = Config.DailyRewards[day]
	PlayerData.AddCoins(player, reward, false)
	return true, ("Day %d reward: +%d coins! Come back tomorrow for more."):format(day, reward)
end

---------------------------------------------------------------- Friend invites
-- When someone joins through a friend's invite link, and that friend is in this server,
-- both get Config.InviteReward coins (once per friend pair).
local function rewardReferral(newPlayer)
	local ok, joinData = pcall(newPlayer.GetJoinData, newPlayer)
	local referrerId = ok and joinData and joinData.ReferredByPlayerId
	if not referrerId or referrerId == 0 or referrerId == newPlayer.UserId then
		return
	end
	local referrer = Players:GetPlayerByUserId(referrerId)
	local newData = PlayerData.WaitFor(newPlayer)
	local referrerData = referrer and PlayerData.WaitFor(referrer)
	if not newData or not referrerData then
		return
	end
	local key = tostring(newPlayer.UserId)
	if referrerData.RewardedReferrals[key] then
		return
	end
	referrerData.RewardedReferrals[key] = true
	PlayerData.AddCoins(referrer, Config.InviteReward, false)
	Remotes.Notify:FireClient(referrer, ("%s joined from your invite! +%d coins"):format(newPlayer.DisplayName, Config.InviteReward), "good")
	if not newData.JoinedViaInvite then
		newData.JoinedViaInvite = true
		PlayerData.AddCoins(newPlayer, Config.InviteReward, false)
		Remotes.Notify:FireClient(newPlayer, ("Thanks for joining %s! +%d coins"):format(referrer.DisplayName, Config.InviteReward), "good")
	end
end

local function onPlayerAdded(player)
	Badges.Award(player, "Welcome")
	task.spawn(rewardReferral, player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
