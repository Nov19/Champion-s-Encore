--[[
    Services
    Naming convention: Ser_???
]]
local RunService = game:GetService("RunService")
--[[
    Modules
    Naming convention: ???Module
]]

local VH = {}
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

--- This method make the particle emitter to keep the correct acceleration accordingly to a relative object
---@param vfx ParticleEmitter|{ParticleEmitter} The particle emitter(s) to track the acceleration of. Can be a single emitter or a table of emitters.
---@param relativeObject Instance The object whose forward vector to track.
---@return RBXScriptConnection The connection that can be used to disconnect the tracking.
function VH.AccelerationTracker(vfx, relativeObject)
	-- Ensure vfx is always a table for consistent handling
	local vfxTable = {}
	if typeof(vfx) == "table" then
		vfxTable = vfx
	else
		vfxTable = { vfx }
	end

	-- Validate that all VFX objects are ParticleEmitters and store original acceleration magnitudes
	local originalAccelerations = {}
	for _, emitter in pairs(vfxTable) do
		if not emitter:IsA("ParticleEmitter") then
			warn("VH.AccelerationTracker: Invalid VFX object provided. Expected ParticleEmitter, got:", typeof(emitter))
			return nil
		end

		-- Store the original acceleration magnitude for this emitter
		local originalAccel = emitter.Acceleration
		if originalAccel.Magnitude == 0 then
			warn("VH.AccelerationTracker: Particle emitter does not have an acceleration")
			return nil
		end
		originalAccelerations[emitter] = originalAccel.Magnitude
	end

	-- Validate relative object
	if not relativeObject then
		warn("VH.AccelerationTracker: No relative object provided")
		return nil
	end

	if vfx.Acceleration == Vector3.new(0, 0, 0) then
		warn("VH.AccelerationTracker: Particle emitter does not have an acceleration")
		return
	end

	-- Connect to RunService to continuously update acceleration based on relative object's forward vector
	local connection = RunService.Heartbeat:Connect(function()
		-- Get the forward vector of the relative object
		local forwardVector = relativeObject.CFrame.LookVector

		-- Calculate the negative of the forward vector as a unit vector
		local negativeForwardVector = -forwardVector

		-- Update acceleration for all VFX objects
		for _, emitter in pairs(vfxTable) do
			if emitter and emitter.Parent and originalAccelerations[emitter] then -- Check if emitter still exists
				-- Use the negative forward vector as unit vector multiplied by original acceleration magnitude
				local originalMagnitude = originalAccelerations[emitter]
				emitter.Acceleration = negativeForwardVector.Unit * originalMagnitude
			end
		end
	end)

	return connection
end

--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]
return VH
