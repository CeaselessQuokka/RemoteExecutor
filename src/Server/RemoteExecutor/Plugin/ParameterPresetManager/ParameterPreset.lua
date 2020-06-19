--- Parameter Preset
-- @created 5/4/2020
-- @edited 5/4/2020
-- @usage Handles the creation and editing of parameter presets.
-- @dependencies Widget
-- @implements Serialize

--- Services ---
local HttpService = game:GetService("HttpService")

--- Modules ---
local Widget = require(script.Parent.Parent.Widget)

--- Parameter Preset ---
local ParameterPreset = {}
ParameterPreset.__index = ParameterPreset

function ParameterPreset.new(json)
	local parameterGUI = Widget.Templates.Preset:Clone()
	local parameterData = HttpService:JSONDecode(json)

	local presetName = parameterData.Name
	parameterGUI.Name = presetName
	parameterGUI.Title.Text = presetName

	parameterData.GUI = parameterGUI
	return parameterData
end

return ParameterPreset
