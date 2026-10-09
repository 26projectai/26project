-- Background music (changes per zone, mute with the music button) and event sound effects.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Sfx = require(Shared:WaitForChild("Sfx"))

local player = Players.LocalPlayer
local stageValue = player:WaitForChild("leaderstats"):WaitForChild("Stage")

---------------------------------------------------------------- Music
local musicGroup = Instance.new("SoundGroup")
musicGroup.Name = "Music"
musicGroup.Volume = Config.MusicVolume
musicGroup.Parent = SoundService

local tracks = {}
local current

local function trackFor(name)
	local id = Config.Music[name]
	if not Config.HasAsset(id) then
		return nil
	end
	if not tracks[name] then
		local sound = Instance.new("Sound")
		sound.Name = name
		sound.SoundId = id
		sound.Looped = true
		sound.Volume = 0
		sound.SoundGroup = musicGroup
		sound.Parent = SoundService
		tracks[name] = sound
	end
	return tracks[name]
end

local function updateMusic()
	local muted = player:GetAttribute("MusicMuted")
	local wanted = not muted and trackFor(Config.ZoneForStage(stageValue.Value).Music) or nil
	if wanted == current then
		return
	end
	local old = current
	current = wanted
	if old then
		local fade = TweenService:Create(old, TweenInfo.new(1), { Volume = 0 })
		fade:Play()
		fade.Completed:Once(function()
			if current ~= old then
				old:Pause()
			end
		end)
	end
	if wanted then
		if not wanted.IsPlaying then
			wanted:Resume()
			if not wanted.IsPlaying then
				wanted:Play()
			end
		end
		TweenService:Create(wanted, TweenInfo.new(1.5), { Volume = 1 }):Play()
	end
end

stageValue.Changed:Connect(updateMusic)
player:GetAttributeChangedSignal("MusicMuted"):Connect(updateMusic)
updateMusic()

---------------------------------------------------------------- Sound effects
Remotes.CheckpointReached.OnClientEvent:Connect(function()
	Sfx.Play("Checkpoint")
end)

Remotes.Won.OnClientEvent:Connect(function()
	Sfx.Play("Win")
end)

local function onCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		Sfx.Play("Death")
	end)
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then
	task.spawn(onCharacter, player.Character)
end
