-- Fix: music plays one track at a time. Paste into the Studio command bar and press Run.
local client = game:GetService("StarterPlayer").StarterPlayerScripts:FindFirstChild("Client")
local audio = client and client:FindFirstChild("Audio")
if not audio then
	warn("Audio script not found - run the full installer instead.")
else
	audio.Source = [==[
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
-- ONE music player, so two tracks can never play on top of each other.
-- Switching fades the current track out, swaps it, then fades the new one in.
local musicGroup = SoundService:FindFirstChild("Music") or Instance.new("SoundGroup")
musicGroup.Name = "Music"
musicGroup.Volume = Config.MusicVolume
musicGroup.Parent = SoundService

-- Stop any music left over from older versions of the game.
for _, child in ipairs(SoundService:GetChildren()) do
	if child:IsA("Sound") and child.Looped and child.Name ~= "BackgroundMusic" then
		child:Stop()
		child:Destroy()
	end
end

local music = SoundService:FindFirstChild("BackgroundMusic") or Instance.new("Sound")
music.Name = "BackgroundMusic"
music.Looped = true
music.Volume = 0
music.SoundGroup = musicGroup
music.Parent = SoundService

-- Radio modes (MUSIC button): World (zone music; phonk in the OP tower), Calm, Phonk, Off.
local function wantedTrackName()
	local radio = player:GetAttribute("Radio") or "World"
	if radio == "Off" or player:GetAttribute("MusicMuted") then
		return nil
	elseif radio == "Calm" or radio == "Phonk" then
		return radio
	elseif player:GetAttribute("Mode") == "OP" then
		return Config.HasAsset(Config.Music.Phonk) and "Phonk" or "Space"
	end
	return Config.ZoneForStage(stageValue.Value).Music
end

local currentId = nil
local switchToken = 0
local function updateMusic()
	local name = wantedTrackName()
	local id = name and Config.Music[name]
	if not Config.HasAsset(id) then
		id = nil
	end
	if id == currentId then
		return
	end
	currentId = id
	switchToken += 1
	local token = switchToken
	task.spawn(function()
		-- Fade out whatever is playing, then swap.
		if music.IsPlaying then
			local fadeOut = TweenService:Create(music, TweenInfo.new(0.6), { Volume = 0 })
			fadeOut:Play()
			fadeOut.Completed:Wait()
		end
		if token ~= switchToken then
			return -- a newer switch happened meanwhile
		end
		music:Stop()
		if not id then
			return
		end
		music.SoundId = id
		music.TimePosition = 0
		music.Volume = 0
		music:Play()
		TweenService:Create(music, TweenInfo.new(1.2), { Volume = 1 }):Play()
	end)
end

stageValue.Changed:Connect(updateMusic)
for _, attribute in ipairs({ "MusicMuted", "Radio", "Mode" }) do
	player:GetAttributeChangedSignal(attribute):Connect(updateMusic)
end
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
]==]
	print("Music fix installed! Press Play to test.")
end
