-- Spins + bobs coins locally, and hides coins you've collected until they respawn for you.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Sfx = require(Shared:WaitForChild("Sfx"))

local coinsFolder = workspace:WaitForChild("Coins")
local baseCFrames = {} -- [coin] = original CFrame

local player = Players.LocalPlayer
local predicted = {} -- [coin] = os.clock() when we played the effects locally
local collectLocally -- defined below (needs setVisible + burst)

local function track(part)
	if part:IsA("BasePart") then
		baseCFrames[part] = part.CFrame
		-- Play the sound the instant YOUR character touches a coin (no waiting for the server).
		part.Touched:Connect(function(hit)
			local character = player.Character
			if character and hit:IsDescendantOf(character) and collectLocally then
				collectLocally(part)
			end
		end)
	end
end

for _, d in ipairs(coinsFolder:GetDescendants()) do
	track(d)
end
coinsFolder.DescendantAdded:Connect(track)
coinsFolder.DescendantRemoving:Connect(function(d)
	baseCFrames[d] = nil
end)

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	for coin, base in pairs(baseCFrames) do
		local bob = math.sin(t * 2 + base.Position.X * 0.1) * 0.3
		coin.CFrame = CFrame.new(base.Position + Vector3.new(0, bob, 0))
			* CFrame.Angles(0, t * Config.CoinSpinSpeed, 0)
			* base.Rotation
	end
end)

local function setVisible(coin, visible)
	local value = visible and 0 or 1
	coin.LocalTransparencyModifier = value
	for _, d in ipairs(coin:GetDescendants()) do
		if d:IsA("Decal") or d:IsA("BasePart") then
			d.LocalTransparencyModifier = value
		elseif d:IsA("ParticleEmitter") or d:IsA("Light") or d:IsA("BillboardGui") then
			d.Enabled = visible
		end
	end
end

local function burst(position)
	local holder = Instance.new("Part")
	holder.Anchored = true
	holder.CanCollide = false
	holder.CanQuery = false
	holder.CanTouch = false
	holder.Transparency = 1
	holder.Size = Vector3.one
	holder.Position = position
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 220, 60))
	emitter.LightEmission = 1
	emitter.Lifetime = NumberRange.new(0.3, 0.6)
	emitter.Speed = NumberRange.new(8, 14)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Size = NumberSequence.new(0.5, 0)
	emitter.Rate = 0
	emitter.Parent = holder
	holder.Parent = workspace
	emitter:Emit(20)
	task.delay(1, function()
		holder:Destroy()
	end)
end

-- Grabbing coins quickly in a row raises the pitch a little, like a combo.
local combo, lastCoin = 0, 0

local function ding(position)
	if position then
		burst(position)
	end
	combo = os.clock() - lastCoin < 1.2 and math.min(combo + 1, 5) or 0
	lastCoin = os.clock()
	Sfx.Play("Coin", 1 + combo * 0.05)
end

local function hideUntilRespawn(coin, seconds)
	setVisible(coin, false)
	task.delay(seconds, function()
		if coin.Parent then
			setVisible(coin, true)
			predicted[coin] = nil
		end
	end)
end

function collectLocally(coin)
	if predicted[coin] then
		return -- already grabbed (and hidden) on this device
	end
	predicted[coin] = os.clock()
	ding(coin.Position)
	hideUntilRespawn(coin, Config.CoinRespawnSeconds)
end

Remotes.CoinCollected.OnClientEvent:Connect(function(coin, respawnSeconds)
	-- Coin Rain coins (and coins streamed out of view) arrive as nil: still play the sound.
	if not coin or not coin.Parent then
		ding(nil)
		return
	end
	if predicted[coin] and os.clock() - predicted[coin] < 3 then
		return -- we already played it the moment you touched it
	end
	predicted[coin] = os.clock()
	ding(coin.Position)
	hideUntilRespawn(coin, respawnSeconds or Config.CoinRespawnSeconds)
end)
