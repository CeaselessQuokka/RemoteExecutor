--- Parameter Preset Manager
-- @created 5/4/2020
-- @edited 5/4/2020
-- @usage Manages all presets.
-- @dependencies Event, Widget, DetailsHandler, ParameterPreset, Constants, HelperFunctions
-- @implements Serialized

--- Services ---
local Workspace = game:GetService("Workspace")
local Selection = game:GetService("Selection")
local HttpService = game:GetService("HttpService")

--- Modules ---
local Event = require(script.Parent.Event)
local Widget = require(script.Parent.Widget)
local DetailsHandler = require(script.Parent.UI.DetailsHandler)
local ParameterPreset = require(script.ParameterPreset)
local PluginConstants = require(script.Parent.Constants)
local HelperFunctions = require(script.Parent.HelperFunctions)

--- GUIs ---
local PresetsList = Widget.PresetsList
local PresetsDetails = Widget.PresetsDetails
local SelectionSubMenu = Widget.PresetsMenu.Selection

--- Parameter Preset Manager ---
local Manager = {}
Manager.__index = Manager

function Manager.new(plugin)
	local parameterPresetManagerObject = setmetatable({
		Data = {},
		Plugin = plugin,
		CurrentPreset = nil,
		CurrentSelection = nil
	}, Manager)

	parameterPresetManagerObject:Initialize()
	return parameterPresetManagerObject
end

function Manager.fromSerialized(plugin, json)
	local parameterPresetManagerObject = setmetatable({
		Data = {},
		Plugin = plugin,
		CurrentPreset = nil,
		CurrentSelection = nil
	}, Manager)

	for name, preset in next, HttpService:JSONDecode(json) do
		parameterPresetManagerObject:Add(HttpService:JSONEncode(preset))
	end

	parameterPresetManagerObject:Initialize()
	return parameterPresetManagerObject
end

function Manager:Initialize()
	-- Handle Details
	PresetsDetails.Details.Text = "To create a preset click \"Create Preset\". The window will change and you then select the item you want to use as a preset. Only StringValues, LocalScripts, ModuleScripts, and Scripts are valid. After you have selected your preset press the \"Create Preset\" button below.\n\nParameter presets allows for argument names to be known and among other data, for example, argument value presets and data types.\n\nArgument value presets is preset text that you specify in the parameter preset data. If you have ShowParameters enabled in the settings then you will see a little down arrow next to all arguments.\n\nThis down arrow is a list of the preset arguments you specified. This is for quick use if you were testing a specific remote a lot.\n\nThe data type of each argument is also known (and the amount of parameters the remotes have). This allows the plugin to do some guess work on if you are passing too many arguments, not enough, or possibly a wrong data type.\n\nPlease note that the checking for data types isn't at all perfect (or even good), so it may mess up sometimes.\n\nIf you press the button below you will get an example preset that covers everything with in-depth comments."

	DetailsHandler.new(PresetsDetails)

	-- GUI Events
	PresetsList.CreatePreset.Button.MouseButton1Click:Connect(function()
		self:StartSelection()
	end)

	SelectionSubMenu.Back.MouseButton1Click:Connect(function()
		self:ClosePresetSelection()
	end)

	SelectionSubMenu.Create.MouseButton1Click:Connect(function()
		self:CreatePreset()
	end)

	Widget.PresetsMenu.Details.ViewExample.MouseButton1Click:Connect(function()
		local example = script.Parent.ExampleParameterPreset:Clone()
		example.Parent = Workspace

		Selection:Set({example})
	end)

	-- Service Events
	Selection.SelectionChanged:Connect(function()
		if SelectionSubMenu.Visible then
			self:UpdateSelection()
		end
	end)
end

function Manager:Serialize()
	-- Hacky... Very hacky; please ignore this. This is for your sake.
	local GUIs = {}
	local json = nil
	local data = self.Data

	for name, presetObject in next, data do
		GUIs[name] = presetObject.GUI
		presetObject.GUI = nil
	end

	json = HttpService:JSONEncode(data)

	for name, presetObject in next, data do
		presetObject.GUI = GUIs[name]
	end

	return json
end

function Manager:StartSelection()
	SelectionSubMenu.Visible = true
	PresetsDetails.Parent.Visible = false
	self:UpdateSelection()
end

function Manager:ClosePresetSelection()
	self.CurrentSelection = nil
	SelectionSubMenu.Visible = false
	PresetsDetails.Parent.Visible = true
end

function Manager:CreatePreset()
	if self.CurrentSelection then
		local json
		local currentSelection = self.CurrentSelection

		if currentSelection:IsA("StringValue") then
			json = currentSelection.Value
		else
			json = currentSelection.Source
		end

		self:ClosePresetSelection()

		-- Create actual preset GUIs and objects.
		self:Add(json)
	end
end

function Manager:UpdateSelection()
	-- Selection inception.. ooo, that rhymed!
	local selectedInstance = Selection:Get()[1]

	if selectedInstance and (selectedInstance:IsA("StringValue") or selectedInstance:IsA("LuaSourceContainer")) then
		self.CurrentSelection = selectedInstance
		SelectionSubMenu.Selection.Selection.Content.Text = HelperFunctions.GetPrettyPath(selectedInstance)
	else
		self.CurrentSelection = nil
		SelectionSubMenu.Selection.Selection.Content.Text = "N/A"
		warn("The preset needs to be contained in either a StringValue or LuaSourceContainer (LocalScript, ModuleScript, Script).")
	end
end

function Manager:UpdatePresetList()
	local index = 0

	for name, presetObject in next, self.Data do
		presetObject.GUI.Position = UDim2.new(0, 0, 0, index * 24)
		index = index + 1
	end

	PresetsList.CanvasSize = UDim2.new(0, 0, 0, index * 24)
	PresetsList.CreatePreset.Position = UDim2.new(0, 0, 0, index * 24)
end

function Manager:SetPreset(preset)
	if self.CurrentPreset ~= preset then
		if self.CurrentPreset then
			self.CurrentPreset.GUI.Title.TextColor3 = PluginConstants.GUI_DESELECTED_COLOR
		end

		preset.GUI.Title.TextColor3 = PluginConstants.GUI_SELECTED_COLOR
		self.CurrentPreset = preset

		-- Update
		Widget:UpdatePreset(self.CurrentPreset)
	end
end

function Manager:Add(json)
	local parameterPresetObject = ParameterPreset.new(json)
	local presetName = parameterPresetObject.Name
	local presetGUI = parameterPresetObject.GUI

	if self.Data[presetName] then
		self:Remove(presetName)
	end

	presetGUI.Parent = PresetsList
	self.Data[presetName] = parameterPresetObject

	-- Events
	presetGUI.Edit.MouseButton1Click:Connect(function()
		local GUI = parameterPresetObject.GUI
		parameterPresetObject.GUI = nil

		local container = Instance.new("Script")
		container.Name = presetName
		container.Source = HttpService:JSONEncode(parameterPresetObject)
		container.Parent = Workspace

		Selection:Set({container})
		parameterPresetObject.GUI = GUI
	end)

	presetGUI.Button.MouseButton1Click:Connect(function()
		self:SetPreset(parameterPresetObject)
	end)

	presetGUI.Delete.MouseButton1Click:Connect(function()
		self:DisplayDeleteContextMenu(presetName)
	end)

	-- Update
	self:UpdatePresetList()
	Event.Fire("SaveSettings")
end

function Manager:Remove(name)
	if self.CurrentPreset and self.CurrentPreset.Name == name then
		Widget:UpdatePreset(nil)
		self.CurrentPreset = nil
	end

	local data = self.Data
	data[name].GUI:Destroy()
	data[name] = nil

	self:UpdatePresetList()
	Event.Fire("SaveSettings")
end

-- Context Menu
function Manager:DisplayDeleteContextMenu(presetName)
	local menu = self.Plugin:CreatePluginMenu("Delete_Preset_Menu", "Delete Preset")

	menu:AddNewAction("Preset_Confirm", "Delete Preset").Triggered:Connect(function()
		self:Remove(presetName)
	end)

	menu:AddNewAction("Preset_Cancel", "Keep Preset")

	menu:ShowAsync()
	menu:Destroy()
end

return Manager
