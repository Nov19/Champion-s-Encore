--[[
    Services
    Naming convention: Ser_???
]]

--[[
    Modules
    Naming convention: ???Module
]]

--[[
    Tables
    Naming convention: Tab_???
]]

local TH = {}

--[[
    References & Parameters
]]

--[[
    Functions
]]

--- Get the real size of the table (not the table.getn) for array-like tables.
---@param t table
---@return number size
function TH.GetTableSize(t)
    local size = #t

    -- If the table.getn == 0, we need to iterate through the table to get the real size
    if size == 0 then
        for _, _ in t do
            size = size + 1
        end
    end

    return size
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]

return TH