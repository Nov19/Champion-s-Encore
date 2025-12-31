--[[
    Services
    Naming convention: ???
]]

--[[
    Modules
    Naming convention: ???
]]

local IGH = {}

--[[
    Tables
    Naming convention: ???
]]

--[[
    References & Parameters
]]

--[[
    Local functions
]]

-- Pre-cache CHARSET length for faster access
local CHAR_SET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
local CHAR_SET_LENGTH = #CHAR_SET
local DEFAULT_ID_LENGTH = 12

--[[
    Functions
]]

--- Generate a temporary ID for the LootBox
---@param idLength number? The length of the ID to generate. Defaults to DEFAULT_ID_LENGTH.
---@return string
function IGH.GenerateTempId(idLength: number?)
	idLength = idLength or DEFAULT_ID_LENGTH
	local result = table.create(idLength)
	for i = 1, idLength do
		-- Use bit32.band for faster random range (if available)
		local index = math.random(1, CHAR_SET_LENGTH)
		result[i] = string.sub(CHAR_SET, index, index) -- string.sub is slightly faster than :sub()
	end
	return table.concat(result)
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]

return IGH
