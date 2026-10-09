-- Helpers for finding checkpoints and moving players between stages.
local Course = {}

-- Latest finishes in this server (newest first), shown on the RECENT FINISHES board.
Course.RecentRuns = {}
function Course.AddRecentRun(name, seconds, assisted)
	table.insert(Course.RecentRuns, 1, { Name = name, Time = seconds, Assisted = assisted, At = os.time() })
	if #Course.RecentRuns > 10 then
		table.remove(Course.RecentRuns)
	end
end

local checkpoints = workspace:WaitForChild("Checkpoints")
Course.Checkpoints = checkpoints

function Course.FinalStage()
	local highest = 0
	for _, child in ipairs(checkpoints:GetChildren()) do
		local n = tonumber(child.Name)
		if n and n > highest then
			highest = n
		end
	end
	return highest
end

function Course.GetCheckpoint(stage)
	local checkpoint = checkpoints:FindFirstChild(tostring(math.clamp(stage, 1, math.max(Course.FinalStage(), 1))))
	if checkpoint and checkpoint:IsA("BasePart") then
		return checkpoint
	end
	return nil
end

-- Puts a character on top of a stage's checkpoint.
function Course.PlaceOnStage(character, stage)
	local checkpoint = Course.GetCheckpoint(stage)
	if checkpoint and character.Parent then
		character:PivotTo(CFrame.new(checkpoint.Position + Vector3.new(0, checkpoint.Size.Y / 2 + 3, 0)))
	end
end

return Course
