--[[
    Services
    Naming convention: ???
]]

local TextChatService = game:GetService("TextChatService")

--[[
    Modules
    Naming convention: ???
]]

local TCC = {}

--[[
    Tables
    Naming convention: ???
]]

TCC.Channel = {
	Default = TextChatService.TextChannels:WaitForChild("RBXGeneral"),
	System = TextChatService.TextChannels:WaitForChild("RBXSystem"),
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

---Sends a message to the default channel.
---@param message string The message to send.
function TCC.SendMessage(message)
	TCC.Channel.Default:SendAsync(message)
end

function TCC.SendSystemMessage(message)
	TCC.Channel.System:DisplaySystemMessage(message)
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]
return TCC
