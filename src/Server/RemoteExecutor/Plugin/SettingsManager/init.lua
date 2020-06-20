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
	-- General
	{
		Type = "Dropdown",
		Name = "ShowParameters",
		Details = "Shows parameter names next to arguments when a Parameter Preset is available.\n\nRefer to the Parameter Preset section for more information.",
		DisplayName = "Show Parameters",

		Choices = {
			{"true", true},
			{"false", false}
		}
	},

	{
		Type = "Dropdown",
		Name = "UseTypeChecking",
		Details = "When true (and if you have a parameter preset selected (refer to the Parameter Preset section for more information)) the plugin will do (very simple) type checking for your arguments.",
		DisplayName = "Use Type Checking",

		Choices = {
			{"None", "None"},
			{"Full", "Full"},
			{"Data Types Only", "DataTypesOnly"},
			{"Argument Count Only", "ArgumentCountOnly"}
		}
	},

	{
		Type = "Dropdown",
		Name = "SendInvalidExecutions",
		Details = "If you have UseTypeChecking enabled, and if a remote were to not have valid data inputted then the remote would not be executed.",
		DisplayName = "Send Invalid Execution",

		Choices = {
			{"true", true},
			{"false", false}
		}
	},

	{
		Type = "Input",
		Name = "DoubleClickThreshold",
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
	},

	-- Batch Request
	{
		Type = "Input",
		Name = "BatchSize",
		Details = "The number of requests to be sent in one batch.",
		DisplayName = "Batch Request Size",

		Sanitize = function(value)
			-- Number
			local newValue = tonumber(value)

			if newValue then
				if newValue > 0 and newValue % 1 == 0 then
					return true, newValue
				end
			end

			return false, "Enter an integer that is at least 1."
		end
	},

	{
		Name = "NumberOfBatches",
		Type = "Input",
		Details = "The number of times to repeat the batch of requests.",
		DisplayName = "Repeat Batches",

		Sanitize = function(value)
			-- Number
			local newValue = tonumber(value)

			if newValue then
				if newValue >= 0 and newValue % 1 == 0 then
					return true, newValue
				end
			end

			return false, "Enter an integer that is at least 0."
		end
	},

	{
		Type = "Input",
		Name = "TimeBetweenRequest",
		Details = "The time in between each request.",
		DisplayName = "Request Delay",

		Sanitize = function(value)
			-- Number
			local newValue = tonumber(value)

			if newValue then
				if newValue >= 0 then
					return true, newValue
				end
			end

			return false, "Enter a number that is at least 0."
		end
	},

	{
		Type = "Input",
		Name = "TimeBetweenBatches",
		Details = "The time in between each batch.",
		DisplayName = "Batch Delay",

		Sanitize = function(value)
			-- Number
			local newValue = tonumber(value)

			if newValue then
				if newValue >= 0 then
					return true, newValue
				end
			end

			return false, "Enter a number that is at least 0."
		end
	}
}

--- GUIs ---
local SettingsMenu = Widget.SettingsMenu
local SettingsList = Widget.SettingsList
local SettingsLayout = Widget.SettingsList.Layout
local SettingsDetails = Widget.SettingsDetails
local SettingsValuesList = Widget.SettingsValuesList

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
	for index, settingData in ipairs(SettingsData) do
		local setting = SettingTemplate:Clone()
		local settingName = settingData.Name

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
	settingsManagerObject:UpateListSize()
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

function Manager:UpateListSize()
	local size = UDim2.new(0, 0, 0, SettingsLayout.AbsoluteContentSize.Y + 4)
	SettingsList.CanvasSize = size
	SettingsValuesList.CanvasSize = size
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
