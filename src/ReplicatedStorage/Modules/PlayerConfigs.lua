--[[
    Services
    Naming convention: ???
]]

--[[
    Modules
    Naming convention: ???
]]

local PlayerConfig = {}

--[[
    Tables
    Naming convention: ???
]]

PlayerConfig.Default = {
	MaxHealth = 100,
	AttackPower = 20,
	Animations = {
		Attack = "Push",
	},
	Cooldowns = {
		Push = 1.0,
	},
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

function PlayerConfig:GetConfigFor(player)
	local config = table.clone(self.Default)

	-- TODO Get the saved configs from DataStore

	return config
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]

return PlayerConfig
