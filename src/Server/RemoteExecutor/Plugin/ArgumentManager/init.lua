--- Argument Manager
-- @created 5/4/2020
-- @edited 5/4/2020
-- @usage Manages remote arguments.
-- @dependencies Widget, Argument

--- Modules ---
local Widget = require(script.Parent.Widget)
local Argument = require(script.Argument)

--- Argument Manager ---
local Manager = {}
Manager.__index = Manager

function Manager.new(remoteInstance)
	return setmetatable({
		Remote = remoteInstance,
		Arguments = {}
	}, Manager)
end

-- Creates a new argument.
function Manager:Add(dontUpdate)
	local arguments = self.Arguments

	local widgetPreset = Widget.Preset
	local argumentData = widgetPreset and widgetPreset.Remotes[self.Remote.Name]
	argumentData = argumentData and argumentData.Arguments[#arguments + 1]

	local argumentObject = Argument.new(argumentData)
	local argumentGUI = argumentObject.GUI
	arguments[#arguments + 1] = argumentObject

	-- Events
	argumentGUI.Delete.MouseButton1Click:Connect(function()
		for index, _argumentObject in next, arguments do
			if _argumentObject == argumentObject then
				table.remove(arguments, index)
				break
			end
		end

		argumentObject:Remove()

		-- Updates
		self:Update()
	end)

	self:Update(dontUpdate)
	argumentGUI.Parent = Widget.ArgumentsList
end

function Manager:PresetChanged()
	-- Clean
	self:Clean()

	-- Update
	local data = Widget.Preset and Widget.Preset.Remotes[self.Remote.Name]

	if data then
		for index, argumentData in next, data.Arguments do
			self:Add(true)
		end
	end
end

-- Updates argument positioning, and arguments canvas.
function Manager:Update(dontUpdate)
	local arguments = self.Arguments

	for index, argumentObject in next, arguments do
		local widgetPreset = Widget.Preset
		local argumentData = widgetPreset and widgetPreset.Remotes[self.Remote.Name]
		argumentData = argumentData and argumentData.Arguments[index]

		if argumentData then
			argumentObject.ArgumentData = argumentData
		end

		argumentObject:Update()
		argumentObject.GUI.Position = UDim2.new(0, 0, 0, (index - 1) * 24)
	end

	if not dontUpdate then
		Widget:UpdateArgumentsCanvas(#arguments)
	end
end

-- Makes all arguments visible.
function Manager:Show()
	for index, argumentObject in next, self.Arguments do
		argumentObject:Show()
	end

	self:Update()
end

-- Makes all arguments invisible.
function Manager:Hide()
	for index, argumentObject in next, self.Arguments do
		argumentObject:Hide()
	end
end

-- Cleans up manager by removing all its arguments (and destroys the actual argument GUIs).
function Manager:Clean()
	for index, argumentObject in next, self.Arguments do
		argumentObject:Remove()
	end

	self.Arguments = {}
end

return Manager
