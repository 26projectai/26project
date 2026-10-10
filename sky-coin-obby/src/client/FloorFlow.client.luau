-- Makes the world floors flow: scrolls every Texture tagged FlowTexture by its FlowU/FlowV
-- attributes (studs per second). Runs on the client so it's smooth and costs no network.
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local textures = {}

local function add(texture)
	if texture:IsA("Texture") then
		textures[texture] = true
	end
end
for _, texture in ipairs(CollectionService:GetTagged("FlowTexture")) do
	add(texture)
end
CollectionService:GetInstanceAddedSignal("FlowTexture"):Connect(add)
CollectionService:GetInstanceRemovedSignal("FlowTexture"):Connect(function(texture)
	textures[texture] = nil
end)

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	for texture in pairs(textures) do
		local u = texture:GetAttribute("FlowU") or 0
		local v = texture:GetAttribute("FlowV") or 0
		-- a slow sway on top of the drift makes it look liquid instead of a conveyor belt
		local sway = math.sin(t * 0.6) * 3
		texture.OffsetStudsU = (t * u + sway) % texture.StudsPerTileU
		texture.OffsetStudsV = (t * v - sway) % texture.StudsPerTileV
	end
end)
