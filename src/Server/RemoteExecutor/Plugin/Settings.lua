--- Settings
-- @created 5/4/2020
-- @edited 5/4/2020
-- @usage Manages all the settings for the plugin.
-- @dependencies Event, IgnoreList, Constants, HelperFunctions, ParameterPresetManager
-- @implements Serialize

--- Services ---
local HttpService = game:GetService("HttpService")

--- Declarations ---
local DefaultSettings = {
	-- General
	ShowParameters = true,
	UseTypeChecking = "Full",
	DoubleClickThreshold = 0.5, -- The default Windows speed.
	SendInvalidExecutions = true,

	-- Batch Requesting
	BatchSize = 10,
	NumberOfBatches = 0,
	TimeBetweenRequest = 0,
	TimeBetweenBatches = 0
}

local DefaultIgnoreList = {
	["ReplicatedStorage.DefaultChatSystemChatEvents.OnNewMessage"] = true,
	["ReplicatedStorage.DefaultChatSystemChatEvents.OnMessageDoneFiltering"] = true,
	["ReplicatedStorage.DefaultChatSystemChatEvents.OnNewSystemMessage"] = true,
	["ReplicatedStorage.DefaultChatSystemChatEvents.OnChannelJoined"] = true,
	["ReplicatedStorage.DefaultChatSystemChatEvents.OnChannelLeft"] = true,
	["ReplicatedStorage.DefaultChatSystemChatEvents.OnMuted"] = true,
	["ReplicatedStorage.DefaultChatSystemChatEvents.OnUnmuted"] = true,
	["ReplicatedStorage.DefaultChatSystemChatEvents.OnMainChannelSet"] = true,
	["ReplicatedStorage.DefaultChatSystemChatEvents.ChannelNameColorUpdated"] = true,
	["ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest"] = true,
	["ReplicatedStorage.DefaultChatSystemChatEvents.SetBlockedUserIdsRequest"] = true,
	["ReplicatedStorage.DefaultChatSystemChatEvents.GetInitDataRequest"] = true,
	["ReplicatedStorage.DefaultChatSystemChatEvents.MutePlayerRequest"] = true,
	["ReplicatedStorage.DefaultChatSystemChatEvents.UnMutePlayerRequest"] = true
}

--- Modules ---
local Event = require(script.Parent.Event)
local IgnoreList = require(script.Parent.IgnoreList)
local PluginConstants = require(script.Parent.Constants)
local HelperFunctions = require(script.Parent.HelperFunctions)
local ParameterPresetManager = require(script.Parent.ParameterPresetManager)

--- Definitions ---
local IgnoreListKey = PluginConstants.IGNORE_LIST_KEY
local PluginSettingsKey = PluginConstants.PLUGIN_SETTINGS_KEY
local PresetsSettingsKey = PluginConstants.PRESETS_SETTINGS_KEY

--- Settings ---
local Settings = {}
Settings.__index = Settings

function Settings.new(plugin)
	-- I use multiple keys to keep it clean and just in case Roblox were to ever change the data limit for
	-- plugin settings.

	local presets = plugin:GetSetting(PresetsSettingsKey)
	presets = presets and ParameterPresetManager.fromSerialized(plugin, presets) or ParameterPresetManager.new(plugin)

	local ignoreList = plugin:GetSetting(IgnoreListKey)
	ignoreList = IgnoreList.new(ignoreList or HttpService:JSONEncode(DefaultIgnoreList))

	local pluginSettings = plugin:GetSetting(PluginSettingsKey)
	pluginSettings = (
		pluginSettings and HttpService:JSONDecode(pluginSettings) or
		HelperFunctions.CopyTable(DefaultSettings)
	)

	local settingsObject = setmetatable({
		Plugin = pluginSettings,
		Presets = presets,
		IgnoreList = ignoreList,
		PluginInstance = plugin
	}, Settings)

	-- Connect Custom Events
	Event.new("SaveSettings", function()
		settingsObject:Save()
	end)

	return settingsObject
end

function Settings:Serialize()
	return HttpService:JSONEncode(self.Plugin)
end

function Settings:Get(setting)
	return self.Plugin[setting]
end

function Settings:Set(setting, value)
	self.Plugin[setting] = value
	self:Save()

	-- Fire Events
	Event.Fire("SettingChanged", setting, value)
end

function Settings:SetDefault(setting)
	local value = DefaultSettings[setting]
	self.Plugin[setting] = value
	self:Save()

	-- Fire Events
	Event.Fire("SettingChanged", setting, value)
end

function Settings:AppendIgnoreList(path)
	if self.IgnoreList:Add(path) then
		self:Save()
	end
end

function Settings:RedactIgnoreList(path)
	if self.IgnoreList:Remove(path) then
		self:Save()
	end
end

function Settings:Save()
	local plugin = self.PluginInstance
	plugin:SetSetting(PluginSettingsKey, self:Serialize())
	plugin:SetSetting(IgnoreListKey, self.IgnoreList:Serialize())
	plugin:SetSetting(PresetsSettingsKey, self.Presets:Serialize())
end

return Settings
