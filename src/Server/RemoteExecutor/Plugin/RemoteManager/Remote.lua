--- Remote
-- @created 5/4/2020
-- @edited 6/19/2020
-- @usage Exposes the plugin remote API.
-- @dependencies Widget, Constants, ArgumentManager

--- Services ---
local Players = game:GetService("Players")
local Selection = game:GetService("Selection")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

--- Modules ---
local Widget = require(script.Parent.Parent.Widget)
local PluginConstants = require(script.Parent.Parent.Constants)
local ArgumentManager = require(script.Parent.Parent.ArgumentManager)

--- Templates ---
local RemoteTemplate = Widget.Templates.Remote
local DisabledRemoteTemplate = Widget.Templates.DisabledRemote

--- Functions ---
local function Parse(content)
	-- Very simple (and awful) parsing. I'll probably (and hopefully) add a better method at some point.
	local number = tonumber(content)

	if number then
		return number
	else
		local _string = content:match("^%s*[\"'](.+)[\"']")

		if _string then
			return _string
		else
			local successful, response = pcall(HttpService.JSONDecode, HttpService, content)

			if successful then
				return response
			else
				error("The JSON you passed was invalid. If you meant to input a string don't forget to put it in quotes.", 0)
			end
		end
	end
end

--- Remote ---
local Remote = {}
Remote.__index = Remote

function Remote.new(plugin, remoteInstance)
	local path = remoteInstance:GetFullName()
	local remoteGUI = RemoteTemplate:Clone()
	local restoredGUI = RemoteTemplate:Clone()
	local disabledGUI = DisabledRemoteTemplate:Clone()

	local remoteObject = setmetatable({
		Path = path,
		Plugin = plugin,
		LastClicked = tick(),

		Enabled = not Widget.Settings.IgnoreList:Exists(path),
		Restored = false,
		Instance = remoteInstance,
		ArgumentManager = ArgumentManager.new(remoteInstance),

		GUI = remoteGUI,
		RestoredGUI = restoredGUI,
		DisabledGUI = disabledGUI
	}, Remote)

	-- Events
	do -- Remote GUI
		remoteGUI.Button.MouseButton1Click:Connect(function()
			Widget:SelectRemote(remoteObject)

			if tick() - remoteObject.LastClicked <= Widget.Settings:Get("DoubleClickThreshold") then
				Selection:Set({remoteInstance})
			end

			remoteObject.ArgumentManager:Show()
			remoteObject.LastClicked = tick()
		end)

		remoteGUI.Delete.MouseButton1Click:Connect(function()
			Widget:DeleteRemote(remoteObject)
			remoteObject.ArgumentManager:Hide()
		end)
	end

	do -- Restored GUI
		restoredGUI.Delete.MouseButton1Click:Connect(function()
			remoteObject:Delete()
		end)
	end

	do -- Disabled GUI
		disabledGUI.Restore.MouseButton1Click:Connect(function()
			remoteObject:Restore()
		end)
	end

	remoteObject:Render()
	return remoteObject
end

function Remote:Delete(noUpdate)
	self:Deselect()
	Widget.Settings:AppendIgnoreList(self.Path)

	self.Enabled = false
	self.Restored = false

	self.GUI.Parent = nil
	self.RestoredGUI.Parent = nil
	self.DisabledGUI.Parent = Widget.DisabledRemotesList

	-- Update
	if not noUpdate then
		Widget:UpdateRemoteCanvases()
	end

	self.ArgumentManager:Hide()
	Widget:UpdateArgumentsCanvas(0)
end

function Remote:Restore(noUpdate)
	Widget.Settings:RedactIgnoreList(self.Path)

	self.Enabled = true
	self.Restored = true


	self.GUI.Parent = Widget.RemotesList
	self.RestoredGUI.Parent = Widget.RestoredRemotesList
	self.DisabledGUI.Parent = nil

	-- Update
	if not noUpdate then
		Widget:UpdateRemoteCanvases()
	end
end

function Remote:Enable(noUpdate)
	self.Enabled = true
	self.Restored = false

	self.GUI.Parent = Widget.RemotesList
	self.RestoredGUI.Parent = nil
	self.DisabledGUI.Parent = nil

	-- Update
	if not noUpdate then
		Widget:UpdateRemoteCanvases()
	end
end

function Remote:UpdateParent()
	if self.Enabled then
		self:Enable(true)
	else
		self:Delete(true)
	end
end

-- Fires/invokes the remote.
function Remote:Execute()
	local player = Players:GetPlayers()[1]
	local isClient = RunService:IsClient()
	local arguments = {}

	for index, argumentObject in next, self.ArgumentManager.Arguments do
		local text = argumentObject.Content.Text

		if #text > 0 then -- Ignore empty arguments.
			arguments[#arguments + 1] = Parse(text)
		end
	end

	if self.Instance:IsA("RemoteEvent") then
		if isClient then
			self.Instance:FireServer(table.unpack(arguments))
		else
			self.Instance:FireClient(player, table.unpack(arguments))
		end
	else
		if isClient then
			self.Instance:InvokeServer(table.unpack(arguments))
		else
			self.Instance:InvokeClient(player, table.unpack(arguments))
		end
	end
end

function Remote:CheckExecute()
	local presetData = Widget.Preset
	local typeChecking = Widget.Settings:Get("UseTypeChecking")
	local invalidExecution = false

	if presetData and typeChecking ~= "None" and Widget.Settings:Get("ShowParameters") then
		local warnings = {}
		local remotePresetData = presetData.Remotes[self.Instance.Name]
		local remoteArgumentData = remotePresetData.Arguments

		if typeChecking == "Full" then
			-- Argument Checking
			local argumentWarnings = self:CheckArgumentCount()

			if #argumentWarnings > 0 then
				table.insert(warnings, #argumentWarnings == 1 and "\tInvalid Argument" or "\tInvalid Arguments")

				for index, warning in next, argumentWarnings do
					table.insert(warnings, warning)
				end
			end

			-- Type Checking
			local dataTypeWarnings = self:CheckDataTypes()

			if #dataTypeWarnings > 0 then
				if #argumentWarnings > 0 then
					table.insert(warnings, "\n")
				end

				table.insert(warnings, "\tInvalid Types")

				for index, warning in next, dataTypeWarnings do
					table.insert(warnings, warning)
				end
			end
		elseif typeChecking == "DataTypesOnly" then
			local dataTypeWarnings = self:CheckDataTypes()

			if #dataTypeWarnings > 0 then
				table.insert(warnings, "\tInvalid Types")

				for index, warning in next, dataTypeWarnings do
					table.insert(warnings, warning)
				end
			end
		elseif typeChecking == "ArgumentCountOnly" then
			local argumentWarnings = self:CheckArgumentCount()

			if #argumentWarnings > 0 then
				table.insert(warnings, #argumentWarnings == 1 and "\tInvalid Argument" or "\tInvalid Arguments")

				for index, warning in next, argumentWarnings do
					table.insert(warnings, warning)
				end
			end
		end

		if #warnings > 0 then
			invalidExecution = true
			table.insert(warnings, 1, "WARNINGS")

			-- Display Warnings
			for index, warning in next, warnings do
				warn(warning)
			end
		end
	end

	if Widget.Settings:Get("SendInvalidExecutions") or not invalidExecution then
		self:Execute()
	end
end

-- Type Checking
function Remote:CheckArgumentCount()
	local numArgs = #self.ArgumentManager.Arguments - #Widget.Preset.Remotes[self.Instance.Name].Arguments
	local warnings = {}
	local remotePresetData = Widget.Preset.Remotes[self.Instance.Name]
	local remoteArgumentData = remotePresetData.Arguments

	if numArgs < 0 then
		for index = 1, numArgs * -1 do
			table.insert(warnings, "\t\t" .. remoteArgumentData[#remoteArgumentData - index + 1].Name)
		end
	elseif numArgs > 0 then
		table.insert(warnings, ("\t\t%d too many arguments were passed"):format(numArgs))
	end

	return warnings
end

function Remote:CheckDataTypes()
	local warnings = {}
	local remotePresetData = Widget.Preset.Remotes[self.Instance.Name]
	local remoteArgumentData = remotePresetData.Arguments

	for index, argumentObject in next, self.ArgumentManager.Arguments do
		local data = remoteArgumentData[index]
		local content = argumentObject.Content.Text
		local dataType = data and data.DataType

		if dataType then
			if dataType == "string" then
				if not content:match("^%s*\"(.+)\"") then
					table.insert(warnings, ("\t\tType \"string\" expected for %s"):format(data.Name))
				end
			elseif dataType == "integer" then
				local num = tonumber(content)

				if not num or num % 1 ~= 0 then
					table.insert(warnings, ("\t\tType \"integer\" expected for %s"):format(data.Name))
				end
			elseif dataType == "double" then
				if not tonumber(content) then
					table.insert(warnings, ("\t\tType \"double\" expected for %s"):format(data.Name))
				end
			elseif dataType == "table" then
				local successful, result = pcall(HttpService.JSONDecode, HttpService, content)

				if not successful then
					table.insert(warnings, ("\t\tType \"table\" expected for %s"):format(data.Name))
				end
			end
		end
	end

	return warnings
end

-- Other
function Remote:Render()
	local remoteName = self.Instance.Name

	if self.Instance:IsA("RemoteFunction") then
		-- Set icons to RemoteFunction icon.
		self.GUI.Icon.Image.ImageRectOffset = Vector2.new(240, 0)
		self.RestoredGUI.Icon.Image.ImageRectOffset = Vector2.new(240, 0)
		self.DisabledGUI.Icon.Image.ImageRectOffset = Vector2.new(240, 0)
	end

	self.GUI.Name = remoteName
	self.RestoredGUI.Name = remoteName
	self.DisabledGUI.Name = remoteName

	self.GUI.Title.Text = remoteName
	self.RestoredGUI.Title.Text = remoteName
	self.DisabledGUI.Title.Text = remoteName

	self:UpdateParent()
end

function Remote:Select()
	self.GUI.Title.TextColor3 = PluginConstants.GUI_SELECTED_COLOR
	self.ArgumentManager:Show()
	self.ArgumentManager:Update()
end

function Remote:Deselect()
	self.GUI.Title.TextColor3 = PluginConstants.GUI_DESELECTED_COLOR
	self.ArgumentManager:Hide()
end

-- Context Menu
function Remote:DisplaySilenceContextMenu()
	local menu = self.Plugin:CreatePluginMenu("Remote_Silence_Menu", "Remote Silence")

	menu:AddNewAction("Silence_Confirm", "Execute Remote With Warning Surpression").Triggered:Connect(function()
		self:Execute()
	end)

	menu:ShowAsync()
	menu:Destroy()
end

return Remote
