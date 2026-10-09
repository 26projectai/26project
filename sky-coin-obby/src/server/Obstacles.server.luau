-- Obstacle behaviours, driven by CollectionService tags (Properties -> Tags in Studio):
--   KillPart  - kills on touch (anything inside Workspace.KillParts counts too)
--   Spinner   - spins around its Y axis. Attribute SpinSpeed (degrees/second, default 90)
--   Slider    - slides back and forth along its X axis. Attributes Distance (studs, default 10)
--               and Speed (cycles/second, default 0.3)
--   Fade      - vanishes shortly after being stepped on, then comes back.
--               Attributes FadeTime (default 0.6) and ReturnTime (default 2.5)
--   Conveyor  - pushes players along its front (look) direction. Attribute ConveyorSpeed (default 12)
--   JumpPad   - launches players upward; handled on the client in Movement (attribute Power)
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local function onTagged(tag, callback)
	for _, inst in ipairs(CollectionService:GetTagged(tag)) do
		task.spawn(callback, inst)
	end
	CollectionService:GetInstanceAddedSignal(tag):Connect(callback)
end

---------------------------------------------------------------- Kill parts
local deadly = {}
local function makeDeadly(part)
	if not part:IsA("BasePart") or deadly[part] then
		return
	end
	deadly[part] = true
	part.Touched:Connect(function(hit)
		local humanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			humanoid.Health = 0
		end
	end)
end

onTagged("KillPart", makeDeadly)

local function watchKillFolder(folder)
	for _, d in ipairs(folder:GetDescendants()) do
		makeDeadly(d)
	end
	folder.DescendantAdded:Connect(makeDeadly)
end

local killFolder = workspace:FindFirstChild("KillParts")
if killFolder then
	watchKillFolder(killFolder)
else
	-- The sample course builder may create it a moment later.
	local conn
	conn = workspace.ChildAdded:Connect(function(child)
		if child.Name == "KillParts" then
			conn:Disconnect()
			watchKillFolder(child)
		end
	end)
end

---------------------------------------------------------------- Fading platforms
onTagged("Fade", function(part)
	if not part:IsA("BasePart") then
		return
	end
	local busy = false
	local baseTransparency = part.Transparency
	part.Touched:Connect(function(hit)
		if busy or not Players:GetPlayerFromCharacter(hit.Parent) then
			return
		end
		busy = true
		local fadeTime = part:GetAttribute("FadeTime") or 0.6
		local tween = TweenService:Create(part, TweenInfo.new(fadeTime), { Transparency = 1 })
		tween:Play()
		tween.Completed:Wait()
		part.CanCollide = false
		task.wait(part:GetAttribute("ReturnTime") or 2.5)
		part.CanCollide = true
		part.Transparency = baseTransparency
		busy = false
	end)
end)

---------------------------------------------------------------- Conveyors
onTagged("Conveyor", function(part)
	if part:IsA("BasePart") then
		part.AssemblyLinearVelocity = part.CFrame.LookVector * (part:GetAttribute("ConveyorSpeed") or 12)
	end
end)

---------------------------------------------------------------- Spinners + sliders
local sliderOrigins = {}

RunService.Heartbeat:Connect(function(dt)
	for _, part in ipairs(CollectionService:GetTagged("Spinner")) do
		if part:IsA("BasePart") and part:IsDescendantOf(workspace) then
			local speed = part:GetAttribute("SpinSpeed") or 90
			part.CFrame *= CFrame.Angles(0, math.rad(speed) * dt, 0)
		end
	end

	local now = workspace:GetServerTimeNow()
	for _, part in ipairs(CollectionService:GetTagged("Slider")) do
		if part:IsA("BasePart") and part:IsDescendantOf(workspace) then
			local origin = sliderOrigins[part]
			if not origin then
				origin = part.CFrame
				sliderOrigins[part] = origin
			end
			local distance = part:GetAttribute("Distance") or 10
			local speed = part:GetAttribute("Speed") or 0.3
			local phase = part:GetAttribute("Phase") or 0
			local offset = math.sin((now * speed + phase) * math.pi * 2) * distance
			part.CFrame = origin * CFrame.new(offset, 0, 0)
		end
	end
end)
