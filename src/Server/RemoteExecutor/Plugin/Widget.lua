--- Widget
-- @created 5/4/2020
-- @edited 5/4/2020
-- @usage Exposes methods and fields to the rest of the plugin.
-- @dependencies Event

--- Declarations ---
local Root = script.Parent.Parent
local GUIs = Root.GUIs

local RemoteExecutorGUI = GUIs.Main

--- Modules ---
local Event = require(script.Parent.Event)

--- Widget ---
local Widget = {}

function Widget:Initialize(plugin)
	-- Behold, the holy grail of a field-bloated class.

	local menus = RemoteExecutorGUI.Menus
	local pluginWidget = plugin:CreateDockWidgetPluginGui(
		"QDT_Remote_Executor_Version_2",
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, false, false, 0, 0, 360, 200)
	)

	pluginWidget.Title = "Remote Executor"
	RemoteExecutorGUI.Parent = pluginWidget

	-- Menu Locals
	local remotesMenu = menus.Executor
	local presetsMenu = menus.Presets
	local settingsMenu = menus.Settings
	local informationMenu = menus.Information
	local disabledRemotesMenu = menus.DisabledRemotes

	-- Primary Fields (no idea what I mean by primary, it just sounds good, tbh)
	self.Widget = RemoteExecutorGUI
	self.MainMenu = RemoteExecutorGUI.Menu
	self.PluginWidget = pluginWidget
	self.CurrentRemote = nil

	-- Menus
	self.Menus = menus
	self.RemotesMenu = remotesMenu
	self.PresetsMenu = presetsMenu
	self.SettingsMenu = settingsMenu
	self.InformationMenu = informationMenu
	self.DisabledRemotesMenu = disabledRemotesMenu

	-- Lists
	self.RemotesList = remotesMenu.Remotes.List
	self.ArgumentsList = remotesMenu.Arguments.List

	self.SettingsList = settingsMenu.Settings.List
	self.SettingsValuesList = settingsMenu.Values.List

	self.InformationList = informationMenu.Information.List

	self.DisabledRemotesList = disabledRemotesMenu.Disabled.List
	self.RestoredRemotesList = disabledRemotesMenu.Restored.List

	self.PresetsList = presetsMenu.Presets.List

	-- Details
	self.PresetsDetails = presetsMenu.Details.ScrollArea
	self.SettingsDetails = settingsMenu.Details.ScrollArea
	self.InformationDetails = informationMenu.Details.ScrollArea

	-- Miscellaneous
	self.Templates = GUIs.Templates
end

function Widget:SetTitle(title)
	self.PluginWidget.Title = title
end

function Widget:SelectRemote(remoteObject)
	remoteObject:Select()

	if self.CurrentRemote and self.CurrentRemote ~= remoteObject then
		self.CurrentRemote:Deselect()
	end

	self.CurrentRemote = remoteObject
end

function Widget:DeleteRemote(remoteObject)
	remoteObject:Delete()

	if self.CurrentRemote == remoteObject then
		self.CurrentRemote = nil
	end
end

function Widget:Enable()
	self.PluginWidget.Enabled = true
end

function Widget:Disable()
	self.PluginWidget.Enabled = false
end

-- Updates
function Widget:UpdatePreset(parameterPresetObject)
	self.Preset = parameterPresetObject

	-- Update Arguments
	Event.Fire("PresetChanged")
end

function Widget:UpdateRemoteCanvases()
	self:UpdateRemoteCanvas()
	self:UpdateRestoredRemoteCanvas()
	self:UpdateDisabledRemoteCanvas()
end

function Widget:UpdateRemoteCanvas()
	self.RemotesList.CanvasSize = UDim2.new(0, 0, 0, (#self.RemotesList:GetChildren() - 1) * 24)
end

function Widget:UpdateRestoredRemoteCanvas()
	self.RestoredRemotesList.CanvasSize = UDim2.new(0, 0, 0, (#self.RestoredRemotesList:GetChildren() - 1) * 24)
end

function Widget:UpdateDisabledRemoteCanvas()
	self.DisabledRemotesList.CanvasSize = UDim2.new(0, 0, 0, (#self.DisabledRemotesList:GetChildren() - 1) * 24)
end

function Widget:UpdateArgumentsCanvas(numArgs)
	local position = (numArgs + 1) * 24
	self.ArgumentsList.CanvasSize = UDim2.new(0, 0, 0, position + 4)
	self.ArgumentsList.AddArgument.Position = UDim2.new(0, 0, 0, position - 24)
end

return Widget
