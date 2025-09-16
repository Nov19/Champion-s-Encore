local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Configuration for movement behavior
local MovementConfig = {
	baseWalkSpeed = 16, -- Default Roblox speed
	maxWalkSpeed = 26, -- Cap when fully accelerated
	accelerationPerSecond = 20, -- Units per second gained while moving
	decelerationPerSecond = 18, -- Units per second lost while sliding
	walkSpeedLerpRate = 10, -- Lerp rate for WalkSpeed smoothing
	slideEnable = true,
	slideMinSpeed = 6, -- Stop sliding below this speed
	slideFrictionBoostWhenTurning = 1.5, -- Extra decel when player reverses quickly
}

-- Simple lerp helper
local function lerp(a, b, t)
	return a + (b - a) * t
end

local function startControllerForCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	-- State
	local currentSpeed = MovementConfig.baseWalkSpeed
	local targetSpeed = MovementConfig.baseWalkSpeed
	local lastMoveDir = Vector3.zero
	local slidingSpeed = 0
	local isSliding = false
	local conn -- Heartbeat connection

	-- Ensure baseline WalkSpeed
	humanoid.WalkSpeed = MovementConfig.baseWalkSpeed

	local function cleanup()
		if conn then
			conn:Disconnect()
			conn = nil
		end
		-- Restore defaults to avoid sticky state across spawns
		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = MovementConfig.baseWalkSpeed
		end
	end

	-- Teardown on character removal
	character.AncestryChanged:Connect(function(_, parent)
		if not parent then
			cleanup()
		end
	end)

	-- Main update loop
	local lastVelocityDir = Vector3.zero
	conn = RunService.Heartbeat:Connect(function(dt)
		-- Safety
		if not character.Parent or humanoid.Health <= 0 then
			cleanup()
			return
		end

		local moveDir = humanoid.MoveDirection
		local hasInput = moveDir.Magnitude > 0.001

		-- Normalize direction safely
		if hasInput then
			moveDir = moveDir.Unit
		end

		-- Detect rapid direction flip to add friction during slide start
		if hasInput then
			lastVelocityDir = rootPart.AssemblyLinearVelocity.Magnitude > 0.01 and rootPart.AssemblyLinearVelocity.Unit or lastVelocityDir
		end

		if hasInput then
			-- Build speed while moving
			targetSpeed = math.clamp(
				currentSpeed + MovementConfig.accelerationPerSecond * dt,
				MovementConfig.baseWalkSpeed,
				MovementConfig.maxWalkSpeed
			)
			lastMoveDir = moveDir
			isSliding = false
		else
			-- No input: begin or continue sliding using last direction
			if MovementConfig.slideEnable and lastMoveDir.Magnitude > 0 then
				if not isSliding then
					-- Start slide with current speed snapshot
					slidingSpeed = math.max(currentSpeed, MovementConfig.baseWalkSpeed)
					isSliding = true
				end

				-- If we recently had velocity opposite to lastMoveDir, increase friction a bit
				local frictionBoost = 1
				if lastVelocityDir.Magnitude > 0 then
					local dot = lastVelocityDir:Dot(lastMoveDir)
					if dot < 0 then
						frictionBoost = MovementConfig.slideFrictionBoostWhenTurning
					end
				end

				-- Decay sliding speed
				slidingSpeed = math.max(0, slidingSpeed - (MovementConfig.decelerationPerSecond * frictionBoost * dt))

				-- Nudge the humanoid in last direction without re-implementing physics
				-- This feeds desired motion while WalkSpeed lerps down
				if slidingSpeed > MovementConfig.slideMinSpeed then
					-- Use Humanoid:Move to preserve built-in stepping/physics
					humanoid:Move(lastMoveDir, false)
					targetSpeed = math.clamp(slidingSpeed, MovementConfig.baseWalkSpeed, MovementConfig.maxWalkSpeed)
				else
					isSliding = false
					-- Return to base speed once slide ends
					targetSpeed = MovementConfig.baseWalkSpeed
				end
			else
				-- Sliding disabled or no last direction
				targetSpeed = MovementConfig.baseWalkSpeed
				isSliding = false
			end
		end

		-- Smoothly approach target WalkSpeed
		local alpha = math.clamp(dt * MovementConfig.walkSpeedLerpRate, 0, 1)
		currentSpeed = lerp(currentSpeed, targetSpeed, alpha)
		humanoid.WalkSpeed = currentSpeed
	end)
end

-- Bootstrap for local player
local localPlayer = Players.LocalPlayer

local function onCharacter(character)
	startControllerForCharacter(character)
end

if localPlayer.Character then
	onCharacter(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(onCharacter)
