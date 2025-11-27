--[[
    Services
    Naming convention: Ser_???
]]
-- local Players = game:GetService("Players")

--[[
    Modules
    Naming convention: ???Module
]]
local OH = {}

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

-- Utility to safely get a deep descendant path, waiting if needed
---@param root Instance The ancester of the path
---@param path string A string that represents the wanted object
---@return Instance | nil
function OH.WaitForPath(root: Instance, path: string): Instance?
	local current = root
	for segment in string.gmatch(path, "[^%.]+") do
		current = current:WaitForChild(segment)
	end
	return current
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]

return OH
