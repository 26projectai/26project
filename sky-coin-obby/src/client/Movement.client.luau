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
local LOOKS = {
	["SKY ISLANDS"] = { Tint = Color3.new(1, 1, 1), Saturation = 0.1, Brightness = 2 },
	["CANDY LAND"] = { Tint = Color3.fromRGB(255, 232, 245), Saturation = 0.25, Brightness = 2 },
	["OUTER SPACE"] = { Tint = Color3.fromRGB(215, 205, 255), Saturation = 0.2, Brightness = 1 },
}

local correction = Lighting:FindFirstChild("ZoneCorrection") or Instance.new("ColorCorrectionEffect")
correction.Name = "ZoneCorrection"
correction.Parent = Lighting

local defaultJump = {}
local currentZone

local function applyMovement(zone)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	workspace.Gravity = zone.Gravity
	if not humanoid then
		return
	end
	if not defaultJump[humanoid] then
		defaultJump[humanoid] = { UseJumpPower = humanoid.UseJumpPower, JumpPower = humanoid.JumpPower }
	end
	if zone.Gravity < 150 then
		-- Fixed jump power + low gravity = big floaty moon jumps.
		humanoid.UseJumpPower = true
		humanoid.JumpPower = 50
	else
		humanoid.UseJumpPower = defaultJump[humanoid].UseJumpPower
		humanoid.JumpPower = defaultJump[humanoid].JumpPower
	end
end

local function applyZone()
	local zone = Config.ZoneForStage(stageValue.Value)
	applyMovement(zone)
	if zone == currentZone then
		return
	end
	currentZone = zone
	local look = LOOKS[zone.Name] or LOOKS["SKY ISLANDS"]
	local info = TweenInfo.new(2, Enum.EasingStyle.Sine)
	TweenService:Create(Lighting, info, { ClockTime = zone.ClockTime, Brightness = look.Brightness }):Play()
	TweenService:Create(correction, info, { TintColor = look.Tint, Saturation = look.Saturation }):Play()
end

stageValue.Changed:Connect(applyZone)
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
		root.AssemblyLinearVelocity = Vector3.new(v.X, pad:GetAttribute("Power") or 80, v.Z)
		Sfx.Play("JumpPad")
	end)
end

for _, pad in ipairs(CollectionService:GetTagged("JumpPad")) do
	hookPad(pad)
end
CollectionService:GetInstanceAddedSignal("JumpPad"):Connect(hookPad)
