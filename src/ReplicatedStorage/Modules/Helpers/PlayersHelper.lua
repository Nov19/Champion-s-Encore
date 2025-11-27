--[[
    Services
    Naming convention: Ser_???
]]
-- local Players = game:GetService("Players")

--[[
    Modules
    Naming convention: ???Module
]]
local PH = {}

--[[
    Tables
    Naming convention: Tab_???
]]

--[[
    References & Parameters
]]

--[[
    Functions
]]

--- This function returns the leaderstate folder that belongs to the given player, not the folder does not exist, a new folder will be created.
---@param player Player The player to get the leaderstats folder for
---@return Instance _ The leaderstats folder
function PH:GetPlayerLeaderStats(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	return leaderstats
end

--- This function instantly returns a string that contains the user thumbnail for the given player
---@param userId number The player's user ID
---@param thumbnailType Enum.ThumbnailType
---@param thumbnailSize Enum.ThumbnailSize
---@return string
function PH:GetUserThumbnailFast(userId: number, thumbnailType: Enum.ThumbnailType, thumbnailSize: Enum.ThumbnailSize)
	local typeName
	if thumbnailType == Enum.ThumbnailType.HeadShot then
		typeName = "AvatarHeadShot"
	elseif thumbnailType == Enum.ThumbnailType.AvatarBust then
		typeName = "AvatarBust"
	elseif thumbnailType == Enum.ThumbnailType.AvatarThumbnail then
		typeName = "Avatar"
	end

	return "rbxthumb://type="
		.. (typeName or "AvatarHeadShot")
		.. "&id="
		.. tostring(userId)
		.. "&w="
		.. string.split(thumbnailSize.Name, "x")[2]
		.. "&h="
		.. string.split(thumbnailSize.Name, "x")[2]
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]

return PH
