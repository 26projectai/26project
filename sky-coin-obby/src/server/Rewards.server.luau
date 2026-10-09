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

---------------------------------------------------------------- Promo codes
Remotes.RedeemCode.OnServerInvoke = function(player, code)
	local data = PlayerData.Get(player)
	if not data or type(code) ~= "string" then
		return false, "Try again"
	end
	code = code:upper():gsub("%s", "")
	local reward = Config.Codes[code]
	if not reward then
		return false, "That code doesn't exist (yet!)"
	end
	if data.RedeemedCodes[code] then
		return false, "You already used this code"
	end
	data.RedeemedCodes[code] = true
	PlayerData.AddCoins(player, reward, false)
	return true, ("Code redeemed: +%d coins!"):format(reward)
end

---------------------------------------------------------------- Group reward
Remotes.ClaimGroup.OnServerInvoke = function(player)
	local data = PlayerData.Get(player)
	if not data or Config.GroupId == 0 then
		return false, "No group set up yet"
	end
	if data.GroupRewardClaimed then
		return false, "Already claimed - thanks for joining!"
	end
	local ok, inGroup = pcall(player.IsInGroup, player, Config.GroupId)
	if not ok or not inGroup then
		return false, "Join our Roblox group first, then rejoin the game!"
	end
	data.GroupRewardClaimed = true
	PlayerData.AddCoins(player, Config.GroupReward, false)
	return true, ("Thanks for joining the group! +%d coins"):format(Config.GroupReward)
end

---------------------------------------------------------------- Friend invites (x3 coins)
-- Detection uses Roblox's referral data: when a friend joins through your invite
-- (the INVITE button / invite menu / referral link), their join data names you as the referrer.
-- Both of you then get x3 coins for Config.InviteBoostMinutes, plus Config.InviteReward coins.
-- If you'd already left, the reward waits for you in a DataStore and is given when you return.
local DataStoreService = game:GetService("DataStoreService")
local okPending, pendingStore = pcall(DataStoreService.GetDataStore, DataStoreService, "PendingReferrals_v1")
if not okPending then
	pendingStore = nil
end

local function giveInviteBoost(player, message)
	local session = PlayerData.Session(player)
	if not session then
		return
	end
	session.InviteBoostUntil = math.max(session.InviteBoostUntil or 0, workspace:GetServerTimeNow()) + Config.InviteBoostMinutes * 60
	PlayerData.AddCoins(player, Config.InviteReward, false)
	Remotes.Notify:FireClient(player, message, "gold")
	Remotes.Fx:FireClient(player, "Confetti")
end

local function rewardReferral(newPlayer)
	local ok, joinData = pcall(newPlayer.GetJoinData, newPlayer)
	local referrerId = ok and joinData and joinData.ReferredByPlayerId
	if not referrerId or referrerId == 0 or referrerId == newPlayer.UserId then
		return
	end
	local newData = PlayerData.WaitFor(newPlayer)
	if not newData then
		return
	end

	-- The friend who joined gets the boost once.
	if not newData.JoinedViaInvite then
		newData.JoinedViaInvite = true
		giveInviteBoost(newPlayer, ("You joined from a friend's invite: x%d COINS for %d minutes!"):format(Config.InviteBoostMultiplier, Config.InviteBoostMinutes))
	end

	-- The inviter: rewarded now if they're here, otherwise saved for later (once per friend).
	local referrer = Players:GetPlayerByUserId(referrerId)
	local referrerData = referrer and PlayerData.WaitFor(referrer)
	local key = tostring(newPlayer.UserId)
	if referrerData then
		if not referrerData.RewardedReferrals[key] then
			referrerData.RewardedReferrals[key] = true
			giveInviteBoost(referrer, ("%s joined from your invite! x%d COINS for %d minutes!"):format(newPlayer.DisplayName, Config.InviteBoostMultiplier, Config.InviteBoostMinutes))
		end
	elseif pendingStore then
		pcall(pendingStore.UpdateAsync, pendingStore, "Ref_" .. referrerId, function(list)
			list = list or {}
			if not table.find(list, key) and #list < 50 then
				table.insert(list, key)
			end
			return list
		end)
	end
end

-- Rewards for invites that joined while you were offline.
local function claimPending(player)
	if not pendingStore then
		return
	end
	local data = PlayerData.WaitFor(player)
	if not data then
		return
	end
	local claimed = {}
	pcall(pendingStore.UpdateAsync, pendingStore, "Ref_" .. player.UserId, function(list)
		for _, key in ipairs(list or {}) do
			if not data.RewardedReferrals[key] then
				data.RewardedReferrals[key] = true
				table.insert(claimed, key)
			end
		end
		return {}
	end)
	if #claimed > 0 then
		giveInviteBoost(player, ("%d friend(s) joined from your invites while you were away! x%d COINS for %d minutes!"):format(#claimed, Config.InviteBoostMultiplier, Config.InviteBoostMinutes))
	end
end

---------------------------------------------------------------- First 60 seconds: instant reward
-- New players get a welcome badge + coins right away (no tutorial, no reading).
local function welcome(player)
	Badges.Award(player, "Welcome")
	local data = PlayerData.WaitFor(player)
	if data and not data.WelcomeGiven then
		data.WelcomeGiven = true
		task.wait(3)
		if player.Parent then
			PlayerData.AddCoins(player, Config.WelcomeCoins or 50, false)
			Remotes.Notify:FireClient(player, ("WELCOME GIFT: +%d coins! Grab more coins ahead!"):format(Config.WelcomeCoins or 50), "gold")
			Remotes.Fx:FireClient(player, "Confetti")
		end
	end
end

local function onPlayerAdded(player)
	task.spawn(welcome, player)
	task.spawn(rewardReferral, player)
	task.spawn(claimPending, player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
