-- Coins: any BasePart inside Workspace.Coins. Each player can grab each coin once,
-- then it reappears for them after Config.CoinRespawnSeconds.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local PlayerData = require(ServerScriptService:WaitForChild("Server"):WaitForChild("PlayerData"))

local coinsFolder = workspace:WaitForChild("Coins")
local collected = {} -- [Player] = { [coin] = true }

local function onTouched(coin, hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root then
		return
	end

	local mine = collected[player]
	if not mine or mine[coin] then
		return
	end
	-- Basic sanity check against exploiters firing touches from far away.
	if (root.Position - coin.Position).Magnitude > coin.Size.Magnitude + 12 then
		return
	end

	mine[coin] = true
	local amount = PlayerData.AddCoins(player, coin:GetAttribute("Value") or Config.CoinValue, true)
	Remotes.CoinCollected:FireClient(player, coin, Config.CoinRespawnSeconds, amount)

	task.delay(Config.CoinRespawnSeconds, function()
		if collected[player] then
			collected[player][coin] = nil
		end
	end)
end

local hooked = {}
local function hook(part)
	if not part:IsA("BasePart") or hooked[part] then
		return
	end
	hooked[part] = true
	part.CanCollide = false
	part.Touched:Connect(function(hit)
		onTouched(part, hit)
	end)
end

for _, d in ipairs(coinsFolder:GetDescendants()) do
	hook(d)
end
coinsFolder.DescendantAdded:Connect(hook)

Players.PlayerAdded:Connect(function(player)
	collected[player] = {}
end)
for _, player in ipairs(Players:GetPlayers()) do
	collected[player] = {}
end
Players.PlayerRemoving:Connect(function(player)
	collected[player] = nil
end)
