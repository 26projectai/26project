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
	DataUpdated = get("DataUpdated", "RemoteEvent"), -- server -> client: coins/stage/owned/equipped
	RequestData = get("RequestData", "RemoteFunction"), -- client -> server: initial snapshot
	CoinCollected = get("CoinCollected", "RemoteEvent"), -- server -> client: hide a coin locally
	CheckpointReached = get("CheckpointReached", "RemoteEvent"), -- server -> client: celebration
	ShopAction = get("ShopAction", "RemoteFunction"), -- client -> server: Buy / Equip / Unequip
}
