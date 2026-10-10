-- Client-side world animation (smooth, and costs no network):
--   FlowTexture: world floor textures drift by their FlowU/FlowV attributes (studs per second)
--   PortalSpin: portal vortex images spin by their Spin attribute (degrees per second)
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local function tracked(tagName, className)
	local set = {}
	local function add(instance)
		if instance:IsA(className) then
			set[instance] = true
		end
	end
	for _, instance in ipairs(CollectionService:GetTagged(tagName)) do
		add(instance)
	end
	CollectionService:GetInstanceAddedSignal(tagName):Connect(add)
	CollectionService:GetInstanceRemovedSignal(tagName):Connect(function(instance)
		set[instance] = nil
	end)
	return set
end

local textures = tracked("FlowTexture", "Texture")
local spinners = tracked("PortalSpin", "GuiObject")

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	-- a slow sway on top of the drift makes floors look liquid instead of a conveyor belt
	local sway = math.sin(t * 0.6) * 3
	for texture in pairs(textures) do
		local u = texture:GetAttribute("FlowU") or 0
		local v = texture:GetAttribute("FlowV") or 0
		texture.OffsetStudsU = (t * u + sway) % texture.StudsPerTileU
		texture.OffsetStudsV = (t * v - sway) % texture.StudsPerTileV
	end
	for gui in pairs(spinners) do
		gui.Rotation = (t * (gui:GetAttribute("Spin") or 30)) % 360
	end
end)
