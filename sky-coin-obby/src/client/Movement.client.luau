-- Jump pads, plus each zone's sky colours and gravity (space = moon jumps).
-- Runs on the client because players' characters are simulated on their own device.
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Sfx = require(Shared:WaitForChild("Sfx"))

local player = Players.LocalPlayer
local stageValue = player:WaitForChild("leaderstats"):WaitForChild("Stage")

---------------------------------------------------------------- Zone look + gravity
-- Atmosphere haze softens the horizon so the world fades out instead of ending abruptly.
local LOOKS = {
	["SKY ISLANDS"] = {
		Tint = Color3.new(1, 1, 1), Saturation = 0.1, Brightness = 2,
		Density = 0.32, Haze = 1.6, Glare = 0.3, Color = Color3.fromRGB(200, 225, 255), Decay = Color3.fromRGB(110, 160, 215),
	},
	["CANDY LAND"] = {
		Tint = Color3.fromRGB(255, 232, 245), Saturation = 0.25, Brightness = 2,
		Density = 0.36, Haze = 2.2, Glare = 0.4, Color = Color3.fromRGB(255, 215, 238), Decay = Color3.fromRGB(255, 160, 210),
	},
	["OUTER SPACE"] = {
		Tint = Color3.fromRGB(215, 205, 255), Saturation = 0.2, Brightness = 1,
		Density = 0.12, Haze = 0, Glare = 0, Color = Color3.fromRGB(60, 40, 110), Decay = Color3.fromRGB(20, 10, 50),
	},
	["FROZEN PEAKS"] = {
		Tint = Color3.fromRGB(225, 240, 255), Saturation = 0, Brightness = 2.2,
		Density = 0.35, Haze = 2, Glare = 0.5, Color = Color3.fromRGB(220, 240, 255), Decay = Color3.fromRGB(140, 190, 240),
	},
	["GOLDEN VAULT"] = {
		Tint = Color3.fromRGB(255, 240, 210), Saturation = 0.2, Brightness = 2,
		Density = 0.3, Haze = 1.8, Glare = 0.6, Color = Color3.fromRGB(255, 225, 160), Decay = Color3.fromRGB(220, 160, 70),
	},
	["GARY'S LAIR"] = {
		Tint = Color3.fromRGB(255, 220, 205), Saturation = 0.15, Brightness = 1.6,
		Density = 0.4, Haze = 2.4, Glare = 0.2, Color = Color3.fromRGB(255, 150, 110), Decay = Color3.fromRGB(150, 50, 40),
	},
}

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Offset = 0.2
atmosphere.Parent = Lighting

local correction = Lighting:FindFirstChild("ZoneCorrection") or Instance.new("ColorCorrectionEffect")
correction.Name = "ZoneCorrection"
correction.Parent = Lighting

local defaultJump = {}

-- Daily Draw jump boots multiply jump height (JumpBoost attribute, set by the server).
-- Players can switch them off (BootsOff attribute) for ranked runs.
local function jumpBoost()
	if player:GetAttribute("BootsOff") then
		return 1
	end
	return player:GetAttribute("JumpBoost") or 1
end

-- Extra jump height from the idle Jump Power stat (only while the player switched it on).
local function powerBonus()
	if not player:GetAttribute("PowerOn") then
		return 0
	end
	return (player:GetAttribute("JumpPower") or 0) * Config.JumpPowerHeight
end

-- Forgiving failure: small speed/jump assist after repeated deaths on a stage (server sets "Assist").
local function assistFactor()
	return 1 + 0.1 * (player:GetAttribute("Assist") or 0)
end

local function applyMovement(zone)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	workspace.Gravity = zone.Gravity
	if not humanoid then
		return
	end
	if not defaultJump[humanoid] then
		defaultJump[humanoid] = {
			UseJumpPower = humanoid.UseJumpPower,
			JumpPower = humanoid.JumpPower,
			JumpHeight = humanoid.JumpHeight,
			WalkSpeed = humanoid.WalkSpeed,
		}
	end
	local defaults = defaultJump[humanoid]
	local boost = jumpBoost() * assistFactor()
	-- Base height: moon jumps in low gravity (fixed 50 jump power), normal height otherwise.
	local baseHeight = zone.Gravity < 150 and (50 * 50) / (2 * zone.Gravity) or defaults.JumpHeight
	local height = baseHeight * boost + powerBonus()
	humanoid.UseJumpPower = true
	humanoid.JumpPower = math.sqrt(2 * zone.Gravity * height)
	humanoid.JumpHeight = height
	-- Don't fight a Speed Coil (it sets its own WalkSpeed while held).
	if not (character and character:FindFirstChild("Speed Coil")) then
		humanoid.WalkSpeed = defaults.WalkSpeed * assistFactor()
	end
end

-- In the OP tower the look follows the biome (gravity stays normal so the difficulty is fair).
local opLook = { Name = "OP", Gravity = 196.2 }

local function currentZoneInfo()
	if player:GetAttribute("Mode") == "OP" then
		local opStat = player.leaderstats:FindFirstChild("OP")
		local tier = math.floor(((opStat and opStat.Value or 1) - 1) / Config.OP.TierSize)
		local biomes = Config.OP.Biomes
		local biome = biomes[math.min(math.floor(tier / Config.OP.TiersPerBiome) + 1, #biomes)]
		opLook.LookName = biome.Look
		opLook.ClockTime = biome.ClockTime
		return opLook, biome.Look
	end
	local zone = Config.ZoneForStage(stageValue.Value)
	return zone, zone.Name
end

-- Custom skyboxes (Assets.Skyboxes) per world, if the ids have been set.
local SKY_FOR_LOOK = {
	["SKY ISLANDS"] = "Sky",
	["CANDY LAND"] = "Candy",
	["OUTER SPACE"] = "Space",
	["GARY'S LAIR"] = "Lair",
	["FROZEN PEAKS"] = "Sky",
	["GOLDEN VAULT"] = "Sky",
}
local function applySky(lookName)
	local ids = Config.Skyboxes[SKY_FOR_LOOK[lookName] or "Sky"]
	if not ids or not Config.HasAsset(ids.Ft) then
		return
	end
	local sky = Lighting:FindFirstChild("WorldSky") or Instance.new("Sky")
	sky.Name = "WorldSky"
	sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt = ids.Bk, ids.Dn, ids.Ft
	sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = ids.Lf, ids.Rt, ids.Up
	sky.CelestialBodiesShown = lookName ~= "OUTER SPACE"
	sky.Parent = Lighting
end

local lastLook
local function applyZone()
	local zone, lookName = currentZoneInfo()
	applyMovement(zone)
	if lookName == lastLook then
		return
	end
	lastLook = lookName
	applySky(lookName)
	local look = LOOKS[lookName] or LOOKS["SKY ISLANDS"]
	local info = TweenInfo.new(2, Enum.EasingStyle.Sine)
	TweenService:Create(Lighting, info, { ClockTime = zone.ClockTime, Brightness = look.Brightness }):Play()
	TweenService:Create(correction, info, { TintColor = look.Tint, Saturation = look.Saturation }):Play()
	TweenService:Create(atmosphere, info, {
		Density = look.Density,
		Haze = look.Haze,
		Glare = look.Glare,
		Color = look.Color,
		Decay = look.Decay,
	}):Play()
end

stageValue.Changed:Connect(applyZone)
player.leaderstats:WaitForChild("OP").Changed:Connect(applyZone)
for _, attribute in ipairs({ "JumpBoost", "BootsOff", "PowerOn", "JumpPower", "Assist", "Mode" }) do
	player:GetAttributeChangedSignal(attribute):Connect(applyZone)
end
player.CharacterAdded:Connect(function(character)
	character:WaitForChild("Humanoid")
	applyZone()
end)
applyZone()

---------------------------------------------------------------- Jump pads
local cooldown = 0
local function hookPad(pad)
	if not pad:IsA("BasePart") then
		return
	end
	pad.Touched:Connect(function(hit)
		local character = player.Character
		if not character or hit.Parent ~= character or os.clock() < cooldown then
			return
		end
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end
		cooldown = os.clock() + 0.4
		local v = root.AssemblyLinearVelocity
		if pad:GetAttribute("Yeet") then
			-- Straight up (so you land back where you started) - pure clip material.
			root.AssemblyLinearVelocity = Vector3.new(0, pad:GetAttribute("Power") or 250, 0)
			Sfx.Play("JumpPad", 0.5)
			player:SetAttribute("Yeeted", (player:GetAttribute("Yeeted") or 0) + 1)
		else
			root.AssemblyLinearVelocity = Vector3.new(v.X, pad:GetAttribute("Power") or 80, v.Z)
			Sfx.Play("JumpPad")
		end
	end)
end

for _, pad in ipairs(CollectionService:GetTagged("JumpPad")) do
	hookPad(pad)
end
CollectionService:GetInstanceAddedSignal("JumpPad"):Connect(hookPad)
