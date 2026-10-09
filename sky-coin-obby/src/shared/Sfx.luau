-- Client helper: Sfx.Play("Coin") plays Config.Sounds.Coin (if an id is set).
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local Sfx = {}

local group = SoundService:FindFirstChild("SFX")
if not group then
	group = Instance.new("SoundGroup")
	group.Name = "SFX"
	group.Volume = Config.SfxVolume
	group.Parent = SoundService
end

local cache = {}

function Sfx.Play(name, pitch)
	local id = Config.Sounds[name]
	if not Config.HasAsset(id) then
		return
	end
	local template = cache[name]
	if not template then
		template = Instance.new("Sound")
		template.SoundId = id
		template.SoundGroup = group
		cache[name] = template
	end
	local sound = template:Clone()
	sound.PlaybackSpeed = pitch or 1
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
end

return Sfx
