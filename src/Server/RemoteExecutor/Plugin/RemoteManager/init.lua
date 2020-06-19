--- Remote Manager
-- @created 5/4/2020
-- @edited 5/4/2020
-- @usage Manages remotes.
-- @dependencies Event, Widget, Remote, HelperFunctions

--- Modules ---
local Event = require(script.Parent.Event)
local Widget = require(script.Parent.Widget)
local Remote = require(script.Remote)
local HelperFunctions = require(script.Parent.HelperFunctions)

--- Argument Manager ---
local Manager = {}
Manager.__index = Manager

function Manager.new(plugin)
	local managerObject = setmetatable({}, Manager)

	for index, remote in next, HelperFunctions.GetRemotes() do
		managerObject[#managerObject + 1] = Remote.new(plugin, remote)
	end

	-- Connect Custom Events
	Event.new("SettingChanged", function(setting)
		if setting == "ShowParameters" then
			for index, remoteObject in next, managerObject do
				remoteObject.ArgumentManager:Update(false)
			end

			-- Update Canvases
			if Widget.CurrentRemote then
				Widget.CurrentRemote.ArgumentManager:Show()
			else
				Widget:UpdateArgumentsCanvas(0)
			end
		end
	end)

	Event.new("PresetChanged", function()
		for index, remoteObject in next, managerObject do
			remoteObject.ArgumentManager:PresetChanged()
			remoteObject.ArgumentManager:Hide()
		end

		-- Update Canvases
		if Widget.CurrentRemote then
			Widget.CurrentRemote.ArgumentManager:Show()
		else
			Widget:UpdateArgumentsCanvas(0)
		end
	end)

	Widget:UpdateRemoteCanvases()
	return managerObject
end

function Manager:ClearRestoredRemotes()
	for index, remoteObject in next, self do
		if remoteObject.Restored then
			remoteObject:Enable()
		end
	end
end

return Manager
