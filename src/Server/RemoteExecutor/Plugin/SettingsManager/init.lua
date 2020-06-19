--- Settings Manager
-- @created 5/4/2020
-- @edited 5/4/2020
-- @usage Manages the displaying of the settings.
-- @dependencies Widget, Setting, DetailsHandler

--- Modules ---
local Widget = require(script.Parent.Widget)
local Setting = require(script.Setting)
local DetailsHandler = require(script.Parent.UI.DetailsHandler)

--- Data ---
local SettingsData = {
	ShowParameters = {
		Type = "Dropdown",
		Details = "Shows parameter names next to arguments when a Parameter Preset is available.\n\nRefer to the Parameter Preset section for more information.",
		DisplayName = "Show Parameters",

		Choices = {
			{"true", true},
			{"false", false}
		}
	},

	UseTypeChecking = {
		Type = "Dropdown",
		Details = "When true (and if you have a parameter preset selected (refer to the Parameter Preset section for more information)) the plugin will do (very simple) type checking for your arguments.",
		DisplayName = "Use Type Checking",

		Choices = {
			{"None", "None"},
			{"Full", "Full"},
			{"Data Types Only", "DataTypesOnly"},
			{"Argument Count Only", "ArgumentCountOnly"}
		}
	},

	SendInvalidExecutions = {
		Type = "Dropdown",
		Details = "If you have UseTypeChecking enabled, and if a remote were to not have valid data inputted then the remote would not be executed.",
		DisplayName = "Send Invalid Execution",

		Choices = {
			{"true", true},
			{"false", false}
		}
	},

	DoubleClickThreshold = {
		Type = "Input",
		Details = "The speed in which you have to click twice to make a secondary action happen.",
		DisplayName = "Double Click Threshold",

		Sanitize = function(value)
			-- Number
			local newValue = tonumber(value)

			if newValue then
				if newValue >= 0.25 and newValue <= 5 then
					return true, newValue
				end
			end

			return false, "Enter a number that is at least 0.25 and at most 5."
		end
	}
}

--- GUIs ---
local SettingsMenu = Widget.SettingsMenu
local SettingsList = Widget.SettingsList
local SettingsDetails = Widget.SettingsDetails

--- Templates ---
local SettingTemplate = Widget.Templates.Setting

--- Settings Manager ---
local Manager = {}
Manager.__index = Manager

function Manager.new(plugin)
	local settingsManagerObject = setmetatable({
		Plugin = plugin,
		SettingValues = {}
	}, Manager)

	-- Create settings and its corresponding value.
	for settingName, settingData in next, SettingsData do
		local setting = SettingTemplate:Clone()

		setting.Name = settingName
		setting.Title.Text = settingData.DisplayName

		setting.Parent = SettingsList

		-- Create corresponding value.
		table.insert(settingsManagerObject.SettingValues, Setting.new(plugin, settingName, settingData))

		-- Setting Events
		setting.Information.MouseButton1Click:Connect(function()
			-- Display setting details.
			settingsManagerObject:DisplayDetails(settingData.DisplayName, settingData.Details)
		end)
	end

	-- Events
	Widget.SettingsMenu.Values.TitleBar.Reset.MouseButton1Click:Connect(function()
		settingsManagerObject:DisplayResetAllContextMenu()
	end)

	Widget.SettingsMenu.Details.Back.MouseButton1Click:Connect(function()
		-- Display setting values.
		settingsManagerObject:DisplayValues()
	end)

	-- Register
	DetailsHandler.new(SettingsDetails)
	return settingsManagerObject
end

function Manager:DisplayDetails(displayName, details)
	SettingsMenu.Values.Visible = false
	SettingsMenu.Details.Visible = true

	-- Display details.
	SettingsDetails.Details.Text = details
	SettingsMenu.Details.TitleBar.Title.Text = displayName
end

function Manager:DisplayValues()
	SettingsMenu.Values.Visible = true
	SettingsMenu.Details.Visible = false
end

-- Context Menus
function Manager:DisplayResetAllContextMenu()
	local menu = self.Plugin:CreatePluginMenu("Reset_Defaults_Menu", "Reset to Defaults")

	menu:AddNewAction("Menus_Confirm", "Reset to Defaults").Triggered:Connect(function()
		for index, settingObject in next, self.SettingValues do
			settingObject:ResetToDefault()
		end
	end)

	menu:AddNewAction("Menus_Cancel", "Do Not Reset to Defaults")

	menu:ShowAsync()
	menu:Destroy()
end

return Manager
