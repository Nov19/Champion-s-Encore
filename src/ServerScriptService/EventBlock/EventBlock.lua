--[[
    Services
    Naming convention: Ser_???
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--[[
    Modules
    Naming convention: ???Module
]]
local ConfigLoader = require(ReplicatedStorage.Modules.ConfigLoader)

--- @class EventBlock
--- @field model Model
--- @field hitbox BasePart
--- @field collision BasePart
--- @field blockType string
--- @field config table
local EventBlock = {}

--[[
    Tables
    Naming convention: Tab_???
]]

local BlockConfigs = ConfigLoader:GetConfig("EventBlockConfigs")
local BlockConfigsByName = ConfigLoader:RemapConfigs(BlockConfigs, "Name")
print(BlockConfigsByName)

--[[
    References & Parameters
]]
local overlapParam = OverlapParams.new()
overlapParam.RespectCanCollide = true

--[[
    Local functions
]]

--- Check if the model is valid
---@param model Model | nil
---@return boolean If the model is valid, return true, otherwise return false
local function IsValidModel(model)
	if not model then
		warn("IsValidModel() - Model is nil")
		return false
	end

	if not model:IsA("Model") then
		warn("IsValidModel() - Model is not a Model")
		return false
	end

	if not model:FindFirstChild("Hitbox") then
		warn("IsValidModel() - Model does not have a Hitbox")
		return false
	end

	return true
end

--[[
    Functions
]]

--- Creates a new EventBlock instance
--- @param model Model?
--- @param blockType string? Optional block type, defaults to "FireBlock"
--- @return EventBlock
function EventBlock:New(model, blockType)
	if not IsValidModel(model) then
		return nil
	end

	local object = {}
	object.model = model
	object.hitbox = object.model:FindFirstChild("Hitbox")
	object.collision = object.model:FindFirstChild("Collision")

	-- Set block type and load configuration
	object.blockType = blockType or "FireBlock"
	object.config = BlockConfigsByName[object.blockType]

	if not object.config then
		warn("EventBlock:New() - Block type '" .. object.blockType .. "' not found in config, using FireBlock")
		object.blockType = "FireBlock"
		object.config = BlockConfigsByName["FireBlock"]
	end

	setmetatable(object, self)
	self.__index = self

	return object
end

--- Get visual effect properties for this block type
---@return table
function EventBlock:GetVisualProperties()
	local visualProps = {
		FireBlock = {
			Color = Color3.fromRGB(255, 100, 100),
			Material = Enum.Material.Neon,
			Transparency = 0.3,
		},
		SlowBlock = {
			Color = Color3.fromRGB(100, 100, 255),
			Material = Enum.Material.ForceField,
			Transparency = 0.5,
		},
		ShockBlock = {
			Color = Color3.fromRGB(255, 255, 100),
			Material = Enum.Material.Neon,
			Transparency = 0.2,
		},
	}

	return visualProps[self.blockType] or visualProps.FireBlock
end

--- Get the position of the event block
---@return any
function EventBlock:GetPosition()
	if not IsValidModel(self.model) then
		warn("EventBlock:GetPosition() - Model is not valid")
		return nil
	end

	return self.model.PrimaryPart.CFrame.Position
end

--- Get the players that have hit the event block
---@return any
function EventBlock:GetHitPlayers()
	if not IsValidModel(self.model) then
		warn("EventBlock:GetHitPlayers() - Model is not valid")
		return nil
	end

	local players = {}
	local parts = self.hitbox and workspace:GetPartsInPart(self.hitbox) or nil -- Parts that are in the hitbox

	if not parts or #parts == 0 then
		return players
	end

	local addedUserIds = {}
	for _, part in ipairs(parts) do
		if part and part.Name == "HumanoidRootPart" then
			local characterModel = part.Parent
			if characterModel and characterModel:IsA("Model") and characterModel:FindFirstChildOfClass("Humanoid") then
				local player = Players:GetPlayerFromCharacter(characterModel)
				if player and not addedUserIds[player.UserId] then
					table.insert(players, player)
					addedUserIds[player.UserId] = true
				end
			end
		end
	end

	return players
end

--- Get the block type
---@return string
function EventBlock:GetBlockType()
	return self.blockType
end

--- Get the block configuration
---@return table
function EventBlock:GetConfig()
	return self.config
end

--- Apply the block's effect to a player
---@param player Player
function EventBlock:Activate(player)
	if not player or not player.Character or not player.Character:FindFirstChild("Humanoid") then
		return
	end

	self.collision.Material = self.config.Material
	task.delay(0.2, function()
		self.collision.Material = Enum.Material.Plastic
	end)

	local humanoid = player.Character.Humanoid

	-- Apply damage
	if self.config.Damage and self.config.Damage > 0 then
		humanoid.Health = humanoid.Health - self.config.Damage
	end

	-- Apply slow effect
	if self.config.Slow and self.config.Slow > 0 then
		-- Store original walkspeed
		if not humanoid:GetAttribute("OriginalWalkSpeed") then
			humanoid:SetAttribute("OriginalWalkSpeed", humanoid.WalkSpeed)
		end
		humanoid.WalkSpeed = humanoid.WalkSpeed * (1 - self.config.Slow)

		-- Restore walkspeed after a delay
		task.delay(3, function()
			if humanoid and humanoid.Parent then
				local originalSpeed = humanoid:GetAttribute("OriginalWalkSpeed")
				if originalSpeed then
					humanoid.WalkSpeed = originalSpeed
					humanoid:SetAttribute("OriginalWalkSpeed", nil)
				end
			end
		end)
	end

	-- Apply stun effect
	if self.config.Stun and self.config.Stun > 0 then
		-- Disable movement temporarily
		humanoid.PlatformStand = true
		task.delay(self.config.Stun, function()
			if humanoid and humanoid.Parent then
				humanoid.PlatformStand = false
			end
		end)
	end
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]
return EventBlock
