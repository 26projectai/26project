-- Creates the RemoteEvents/RemoteFunctions on the server and finds them on the client.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

local folder
if isServer then
	folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end
else
	folder = ReplicatedStorage:WaitForChild("Remotes")
end

local function get(name, className)
	if not isServer then
		return folder:WaitForChild(name)
	end
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new(className)
		remote.Name = name
		remote.Parent = folder
	end
	return remote
end

return {
	DataUpdated = get("DataUpdated", "RemoteEvent"), -- server -> client: full data snapshot
	RequestData = get("RequestData", "RemoteFunction"), -- client -> server: initial snapshot
	CoinCollected = get("CoinCollected", "RemoteEvent"), -- server -> client: (coin, respawnSeconds, amount)
	CheckpointReached = get("CheckpointReached", "RemoteEvent"), -- server -> client: (stage, reward)
	Won = get("Won", "RemoteEvent"), -- server -> client: (time or nil, isNewBest, reward, wins)
	Notify = get("Notify", "RemoteEvent"), -- server -> client: (message, kind)
	ShopAction = get("ShopAction", "RemoteFunction"), -- client -> server: Buy / Equip / Unequip
	ClaimDaily = get("ClaimDaily", "RemoteFunction"), -- client -> server: claim daily reward
	AssistUsed = get("AssistUsed", "RemoteEvent"), -- client -> server: used a game-pass ability this run
	TeleportStage = get("TeleportStage", "RemoteFunction"), -- client -> server: go to an unlocked stage
	DailyDraw = get("DailyDraw", "RemoteFunction"), -- client -> server: free daily draw
	SetNickname = get("SetNickname", "RemoteFunction"), -- client -> server: Rare+ name tag nickname
	RedeemCode = get("RedeemCode", "RemoteFunction"), -- client -> server: promo code
	ClaimGroup = get("ClaimGroup", "RemoteFunction"), -- client -> server: group member bonus
}
