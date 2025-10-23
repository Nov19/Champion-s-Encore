--[[
    Services
    Naming convention: ???
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
    Modules
    Naming convention: ???
]]

local Communication = require(ReplicatedStorage.Modules.Communication)
local Push = {}

--[[
    Tables
    Naming convention: ???
]]

local ANIMATION_ID = 95625523160278
local DAMAGE = 20

--[[
    References & Parameters
]]

local HITBOX = ReplicatedStorage.Prefabs.Hitboxes:FindFirstChild("Hitbox_Push")

--[[
    Local functions
]]

--[[
    Functions
]]

--- The passed character executes the push action
---@param character any
function Push:Execute(character)
	if not HITBOX then
		warn("Push:Execute() - Missing asset : Hitbox_Push!")
	end

	local humanoid = character:WaitForChild("Humanoid")
	if not humanoid then
		warn("Push:Execute() - No humanoid found in passed character!")
		return
	end

	local animator = humanoid:WaitForChild("Animator")
	if not animator then
		warn("Push:Execute() - No animator found in passed character!")
		return
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. ANIMATION_ID
	local track = animator:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action

	-- Attach event
	local connection
	connection = track:GetMarkerReachedSignal("Hit"):Connect(function()
		local hitbox = character:FindFirstChild(HITBOX.Name)
		local overlapped = workspace:GetPartsInPart(hitbox)

		local affectedHumanoids = {}
		local targets2Impact = {}
		for _, part in overlapped do
			local hum = part.Parent:FindFirstChild("Humanoid")
			if hum and hum ~= character:FindFirstChild("Humanoid") and not affectedHumanoids[hum] then
				affectedHumanoids[hum] = true

				-- TODO Fire an event to the server to invoke the DoDamage function.
				table.insert(targets2Impact, Players:GetPlayerFromCharacter(part.Parent))
			end
		end

		Communication.FireServer("Push", targets2Impact)
	end)

	track.Stopped:Connect(function()
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end)

	track:Play()
end

--- Initialize hitbox
---@param character Model Initialize the hitbox for the given character
function Push:InitializeHitbox(character)
	local possibleHitbox = character:FindFirstChild(HITBOX.Name)
	if possibleHitbox then
		warn("Push:InitializeHitbox() - The hitbox is already exists!")
		return
	end

	local clonedHitbox = HITBOX:Clone()
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		warn("Push:InitializeHitbox() - No HumanoidRootPart found in the character!")
	end
	clonedHitbox.CFrame = root.CFrame * CFrame.new(0, 0, -3)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = clonedHitbox
	weld.Parent = clonedHitbox
	clonedHitbox.Parent = character
end

--- Applies damage and push force to affected characters (SERVER-SIDE ONLY)
---@param attacker Model The character performing the push attack
---@param targets table Array of characters to be affected by the push
function Push:DoDamage(attacker, targets)
	print("Push:DoDamage()", attacker, targets)

	-- Server-side validation
	local RunService = game:GetService("RunService")
	if not RunService:IsServer() then
		warn("Push:DoDamage() - This function should only be called on the server!")
		return
	end

	-- Validate attacker
	if
		not attacker
		or not attacker.Character
		or not attacker.Character:FindFirstChild("Humanoid")
		or not attacker.Character:FindFirstChild("HumanoidRootPart")
	then
		warn("Push:DoDamage() - Invalid attacker character!")
		return
	end

	-- Validate characters array
	if not targets or type(targets) ~= "table" then
		warn("Push:DoDamage() - Invalid characters parameter!")
		return
	end
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]
return Push
