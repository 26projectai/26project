-- Game passes (2x Coins, VIP) and the Skip Stage developer product.
-- Ids live in Config.GamePasses / Config.Products; anything set to 0 is ignored.
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Server = ServerScriptService:WaitForChild("Server")
local PlayerData = require(Server:WaitForChild("PlayerData"))
local Course = require(Server:WaitForChild("Course"))

local passNameById = {}
for name, id in pairs(Config.GamePasses) do
	if id ~= 0 then
		passNameById[id] = name
	end
end

local function checkPasses(player)
	PlayerData.WaitFor(player)
	for name, id in pairs(Config.GamePasses) do
		if id ~= 0 then
			local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, id)
			if ok and owns then
				PlayerData.SetPass(player, name, true)
			end
		end
	end
	if PlayerData.Session(player) and PlayerData.Session(player).Passes.VIP then
		player:SetAttribute("VIP", true) -- used for the [VIP] chat tag
	end
end

Players.PlayerAdded:Connect(checkPasses)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(checkPasses, player)
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
	local name = passNameById[passId]
	if purchased and name then
		PlayerData.SetPass(player, name, true)
		if name == "VIP" then
			player:SetAttribute("VIP", true)
		end
		Remotes.Notify:FireClient(player, "Thanks for your support! Pass activated.", "good")
	end
end)

---------------------------------------------------------------- Developer products
local handled = {} -- receipts already granted in this server

local productHandlers = {}
productHandlers[Config.Products.SkipStage] = function(player)
	local data = PlayerData.Get(player)
	if not data then
		return false
	end
	local final = Course.FinalStage()
	if data.Stage >= final - 1 then
		-- Skipping can't hand out a win (the Skip button hides here); compensate with coins instead.
		PlayerData.AddCoins(player, Config.WinReward, false)
		Remotes.Notify:FireClient(player, ("Last stage can't be skipped - here's +%d coins instead!"):format(Config.WinReward), "good")
		return true
	end
	PlayerData.Session(player).RunStart = nil -- skipped runs don't count for speedrun times
	PlayerData.SetStage(player, data.Stage + 1)
	if player.Character then
		Course.PlaceOnStage(player.Character, data.Stage)
	end
	Remotes.Notify:FireClient(player, ("Skipped to stage %d!"):format(data.Stage), "good")
	return true
end

MarketplaceService.ProcessReceipt = function(receipt)
	if handled[receipt.PurchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	local handler = productHandlers[receipt.ProductId]
	if not player or not handler then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local ok, granted = pcall(handler, player)
	if ok and granted then
		handled[receipt.PurchaseId] = true
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end
