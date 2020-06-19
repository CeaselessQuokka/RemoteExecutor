--- Setting
-- @created 5/4/2020
-- @edited 5/4/2020
-- @usage Exposes an API to help the Settings Manager.
-- @dependencies Event, Widget

--- Modules ---
local Event = require(script.Parent.Parent.Event)
local Widget = require(script.Parent.Parent.Widget)

--- GUIs ---
local SettingsValuesList = Widget.SettingsValuesList

--- Templates ---
local ChoiceTemplate = Widget.Templates.Choice
local InputSettingTemplate = Widget.Templates.InputSetting
local DropdownSettingTemplate = Widget.Templates.DropdownSetting

--- Data ---
local Settings = Widget.Settings

--- Setting ---
local Setting = {}
Setting.__index = Setting

function Setting.new(plugin, settingName, settingData)
	local settingValue
	local settingObject = setmetatable({
		GUI = nil,
		Name = settingName,
		Plugin = plugin
	}, Setting)

	if settingData.Type == "Dropdown" then
		local choices
		settingValue = DropdownSettingTemplate:Clone()
		choices = settingValue.Value.Choices

		-- Populate Choices
		for index, choiceData in next, settingData.Choices do
			local choiceGUI = ChoiceTemplate:Clone()
			choiceGUI.Content.Text = choiceData[1]
			choiceGUI.Parent = choices

			-- Events
			choiceGUI.MouseButton1Click:Connect(function()
				Settings:Set(settingName, choiceData[2])
				choices.Visible = false
				settingObject:Update()
			end)
		end

		choices.Size = UDim2.new(1, 0, 0, #settingData.Choices * 24)

		-- Events
		settingValue.Value.Content.MouseButton1Click:Connect(function()
			choices.Visible = not choices.Visible
		end)
	else
		settingValue = InputSettingTemplate:Clone()

		-- Events
		settingValue.Value.Content.FocusLost:Connect(function()
			local successful, result = settingData.Sanitize(settingValue.Value.Content.Text)

			if successful then
				Settings:Set(settingName, result)
				settingObject:Update()
			else
				warn(result)
			end
		end)
	end

	settingValue.Name = settingName
	settingValue.Value.Content.Text = tostring(Settings:Get(settingName))

	settingValue.Parent = SettingsValuesList

	-- Events
	settingValue.Reset.MouseButton1Click:Connect(function()
		settingObject:DisplayResetContextMenu()
	end)

	Event.new("SettingChanged", function(setting, value)
		if settingName == setting then
			settingValue.Value.Content.Text = tostring(value)
		end
	end)

	-- Create Object
	settingObject.GUI = settingValue
	return settingObject
end

function Setting:ResetToDefault()
	Settings:SetDefault(self.Name)
	self:Update()
end

function Setting:Update()
	self.GUI.Value.Content.Text = tostring(Settings:Get(self.Name))
end

-- Context Menus
function Setting:DisplayResetContextMenu()
	local menu = self.Plugin:CreatePluginMenu("Reset_Default_Menu", "Reset to Default")

	menu:AddNewAction("Menu_Confirm", "Reset to Default").Triggered:Connect(function()
		self:ResetToDefault()
	end)

	menu:AddNewAction("Menu_Cancel", "Do Not Reset to Default")

	menu:ShowAsync()
	menu:Destroy()
end

return Setting
