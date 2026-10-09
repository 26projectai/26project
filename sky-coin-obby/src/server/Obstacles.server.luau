-- Kill bricks and spinners.
--   Kill brick: any BasePart inside Workspace.KillParts, or tagged "KillPart".
--   Spinner:    any BasePart tagged "Spinner" (optional number attribute "SpinSpeed", degrees/second).
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local hooked = {}
local function makeDeadly(part)
	if not part:IsA("BasePart") or hooked[part] then
		return
	end
	hooked[part] = true
	part.Touched:Connect(function(hit)
		local humanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			humanoid.Health = 0
		end
	end)
end

for _, part in ipairs(CollectionService:GetTagged("KillPart")) do
	makeDeadly(part)
end
CollectionService:GetInstanceAddedSignal("KillPart"):Connect(makeDeadly)

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

RunService.Heartbeat:Connect(function(dt)
	for _, part in ipairs(CollectionService:GetTagged("Spinner")) do
		if part:IsA("BasePart") and part:IsDescendantOf(workspace) then
			local speed = part:GetAttribute("SpinSpeed") or 90
			part.CFrame *= CFrame.Angles(0, math.rad(speed) * dt, 0)
		end
	end
end)
