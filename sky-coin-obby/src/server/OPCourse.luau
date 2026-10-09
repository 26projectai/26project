-- Streams the OP Obby: a tier (50 stages) is built when a player needs it and removed
-- once nobody has been there for a while, so 1000 stages never exist all at once.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Server = ServerScriptService:WaitForChild("Server")
local OPGen = require(Server:WaitForChild("OPGen"))
local PlayerData = require(Server:WaitForChild("PlayerData"))

local OPCourse = {}
OPCourse.TierOf = OPGen.TierOf
OPCourse.PadPosition = OPGen.PadPosition

local UNLOAD_AFTER = 45 -- seconds a tier stays after the last player leaves it
local built = {} -- [tier] = { Folders = {...}, LastNeeded = os.clock() }

function OPCourse.Ensure(tier)
	tier = math.clamp(tier, 1, #Config.OP.Tiers)
	local entry = built[tier]
	if not entry then
		entry = { Folders = OPGen.Build(tier) }
		built[tier] = entry
	end
	entry.LastNeeded = os.clock()
end

function OPCourse.PlaceOnStage(character, stage)
	stage = math.clamp(stage, 1, Config.OP.Stages)
	OPCourse.Ensure(OPGen.TierOf(stage))
	if character and character.Parent then
		character:PivotTo(CFrame.new(OPGen.PadPosition(stage) + Vector3.new(0, 3.5, 0)))
	end
end

local function neededTiers()
	local needed = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local data = PlayerData.Get(player)
		if data and data.Mode == "OP" then
			local tier = OPGen.TierOf(data.OPStage)
			needed[tier] = true
			-- Pre-build the next tier when they're close to its portal.
			if data.OPStage % Config.OP.TierSize >= Config.OP.TierSize - 3 then
				needed[tier + 1] = true
			end
		end
	end
	return needed
end

task.spawn(function()
	while true do
		task.wait(3)
		for tier in pairs(neededTiers()) do
			if tier <= #Config.OP.Tiers then
				OPCourse.Ensure(tier)
			end
		end
		for tier, entry in pairs(built) do
			if os.clock() - entry.LastNeeded > UNLOAD_AFTER then
				for _, folder in ipairs(entry.Folders) do
					folder:Destroy()
				end
				built[tier] = nil
			end
		end
	end
end)

return OPCourse
