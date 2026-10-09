-- Small shared helpers for building UI in code (used by client scripts).
local UI = {}

UI.FONT = Enum.Font.FredokaOne
UI.COLORS = {
	Panel = Color3.fromRGB(30, 30, 50),
	Card = Color3.fromRGB(48, 48, 78),
	Outline = Color3.fromRGB(15, 15, 25),
	Gold = Color3.fromRGB(255, 205, 40),
	Green = Color3.fromRGB(70, 210, 100),
	Blue = Color3.fromRGB(70, 150, 255),
	Pink = Color3.fromRGB(255, 90, 170),
	Purple = Color3.fromRGB(150, 90, 255),
	Orange = Color3.fromRGB(255, 140, 40),
	Red = Color3.fromRGB(235, 70, 70),
	Grey = Color3.fromRGB(110, 110, 130),
	Text = Color3.new(1, 1, 1),
}

function UI.make(className, props, children)
	local inst = Instance.new(className)
	local parent = props.Parent
	props.Parent = nil
	for key, value in pairs(props) do
		inst[key] = value
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	inst.Parent = parent
	return inst
end

function UI.corner(radius)
	return UI.make("UICorner", { CornerRadius = UDim.new(0, radius or 12) })
end

function UI.stroke(thickness)
	return UI.make("UIStroke", {
		Thickness = thickness or 3,
		Color = UI.COLORS.Outline,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function UI.text(props)
	props.BackgroundTransparency = 1
	props.Font = UI.FONT
	props.TextColor3 = props.TextColor3 or UI.COLORS.Text
	props.TextScaled = true
	local label = UI.make("TextLabel", props)
	UI.make("UIStroke", { Thickness = 2, Color = UI.COLORS.Outline, Parent = label })
	return label
end

function UI.button(props)
	props.Font = UI.FONT
	props.TextScaled = true
	props.TextColor3 = props.TextColor3 or UI.COLORS.Text
	props.AutoButtonColor = true
	return UI.make("TextButton", props, {
		UI.corner(10),
		UI.stroke(2),
		UI.make("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) }),
	})
end

-- A centered window with a title and close button. Returns frame, content area.
function UI.window(parent, title, maxSize)
	local frame = UI.make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.9, 0.82),
		BackgroundColor3 = UI.COLORS.Panel,
		Visible = false,
		ZIndex = 5,
		Parent = parent,
	}, { UI.corner(18), UI.stroke(4), UI.make("UISizeConstraint", { MaxSize = maxSize or Vector2.new(560, 560) }) })
	UI.text({
		Position = UDim2.fromOffset(18, 10),
		Size = UDim2.new(1, -90, 0, 44),
		Text = title,
		TextColor3 = UI.COLORS.Gold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 5,
		Parent = frame,
	})
	local close = UI.button({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.fromOffset(40, 40),
		BackgroundColor3 = UI.COLORS.Red,
		Text = "X",
		ZIndex = 6,
		Parent = frame,
	})
	close.Activated:Connect(function()
		frame.Visible = false
	end)
	local content = UI.make("ScrollingFrame", {
		Position = UDim2.fromOffset(14, 62),
		Size = UDim2.new(1, -28, 1, -74),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 5,
		Parent = frame,
	})
	return frame, content
end

function UI.formatDuration(seconds)
	seconds = math.max(0, math.floor(seconds))
	if seconds >= 3600 then
		return ("%dh %dm"):format(seconds // 3600, (seconds % 3600) // 60)
	end
	return ("%d:%02d"):format(seconds // 60, seconds % 60)
end

return UI
