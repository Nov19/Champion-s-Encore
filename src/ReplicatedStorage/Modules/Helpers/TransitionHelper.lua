--[[
    Services
    Naming convention: Ser_???
]]
local TweenService = game:GetService("TweenService")
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
local DEFAULT_PLAY_IN_TIME = 1
local DEFAULT_PLAY_OUT_TIME = 0.5
--[[
    Functions
]]
-- Utility: Play a loading animation (black dopey animation)
function TH:PlayLoadingAnimation(parent, playInTime, playOutTime)
	if not parent then
		warn("Invalid input - No parent provided!")
	end

	-- Play a loading animation (TweenService: a black dopey animation)
	local blackCircle = Instance.new("Frame")
	blackCircle.Size = UDim2.fromScale(0, 0)
	blackCircle.Position = UDim2.fromScale(0.5, 0.5)
	blackCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	blackCircle.BackgroundTransparency = 0
	blackCircle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	blackCircle.SizeConstraint = Enum.SizeConstraint.RelativeXX
	blackCircle.Parent = parent

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0.5, 0)
	UICorner.Parent = blackCircle

	local tween = TweenService:Create(
		blackCircle,
		TweenInfo.new(playInTime or DEFAULT_PLAY_IN_TIME, Enum.EasingStyle.Linear),
		{ Size = UDim2.fromScale(2, 2) }
	)
	tween:Play()
	tween.Completed:Wait()
	tween = TweenService:Create(
		blackCircle,
		TweenInfo.new(playOutTime or DEFAULT_PLAY_OUT_TIME, Enum.EasingStyle.Linear),
		{ BackgroundTransparency = 1 }
	)
	tween:Play()
	tween.Completed:Wait()
	blackCircle:Destroy()
end

--- Fade out a model, including all its children objects (Transparency, Color, etc.)
---@param model Model The model to fade out
---@param fadeOutTime number The time it takes to fade out the model
---@param shouldDestroy boolean Whether to destroy the model after fading out
---@param canCollide boolean Whether the model can colllide with other collisions while fading out
function TH:ModelFadeOut(model, fadeOutTime, shouldDestroy, canCollide)
	if not model then
		warn("Invalid input - No model provided!")
		return
	end

	-- Default fade out time if not provided
	fadeOutTime = fadeOutTime or 1

	-- Function to recursively find and fade out all transparent objects
	local function fadeOutObject(object)
		local objectsToFade = {}

		-- Disable collision for the object if canCollide is false
		if object:IsA("BasePart") and not canCollide then
			object.CanCollide = false
		end

		-- Check if the object itself can be made transparent d
		local objectType = object.ClassName
		if
			objectType == "BasePart"
			or objectType == "Part"
			or objectType == "MeshPart"
			or objectType == "Decal"
			or objectType == "Texture"
		then
			-- Parts, MeshParts, etc.
			table.insert(objectsToFade, {
				object = object,
				property = "Transparency",
				startValue = object.Transparency,
				endValue = 1,
			})
			-- elseif objectType == "SurfaceAppearance" and object.Color then
			-- 	-- SurfaceAppearance - handle transparency through Color property
			-- 	-- Note: SurfaceAppearance doesn't have a direct Transparency property
			-- 	-- We can modify the Color to make it more transparent
			-- 	local currentColor = object.Color
			-- 	table.insert(objectsToFade, {
			-- 		object = object,
			-- 		property = "Color",
			-- 		startValue = currentColor,
			-- 		endValue = Color3.new(currentColor.R, currentColor.G, currentColor.B), -- Keep same color but will be affected by transparency
			-- 	})
		end

		-- Recursively process all children
		for _, child in (object:GetChildren()) do
			local childObjects = fadeOutObject(child)
			for _, obj in childObjects do
				table.insert(objectsToFade, obj)
			end
		end

		return objectsToFade
	end

	-- Get all objects that need to be faded out
	local objectsToFade = fadeOutObject(model)

	if #objectsToFade == 0 then
		warn("No transparent objects found in model: " .. model.Name)
		return
	end

	-- Create tweens for all objects
	local tweens = {}
	for _, objData in objectsToFade do
		local tweenInfo = TweenInfo.new(fadeOutTime, Enum.EasingStyle.Linear)
		local tween = TweenService:Create(objData.object, tweenInfo, {
			[objData.property] = objData.endValue,
		})
		table.insert(tweens, tween)
	end

	-- Play all tweens
	for _, tween in tweens do
		tween:Play()
	end

	-- Wait for all tweens to complete
	task.wait(fadeOutTime)

	-- Destroy the model if requested
	if shouldDestroy then
		model:Destroy()
	end
end
--[[
    Event connections
    Conventional order: Remote events -> Bindable events -> Remote functions -> Bindable functions
]]

--[[
    Code execution
]]
return TH
