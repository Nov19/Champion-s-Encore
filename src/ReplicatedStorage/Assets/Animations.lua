--[[
    Services
    Naming convention: ???
]]

--[[
    Modules
    Naming convention: ???
]]

local Animations = {}

--[[
    Tables
    Naming convention: ???
]]

Animations.Name2Id = {
	["Attack"] = 95625523160278,
}

--[[
    References & Parameters
]]

--[[
    Local functions
]]

--[[
    Functions
]]

--- This function search the animation id by given name.
---@param name string The name of animation you want to search.
---@return number
function Animations:GetAnimationIdByName(name: string)
	if tostring(name) == nil then
		warn("Animations:GetAnimationIdByName() - The name received is either nil or not a string!")
	end

	return tonumber(Animations.Name2Id[name])
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]
return Animations
