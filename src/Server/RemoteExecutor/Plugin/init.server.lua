--- Remote Executor
-- @created 5/4/2020
-- @edited 6/19/2020
-- @usage Handles the creation, initiation, and function of the plugin.
-- @dependencies HelperFunctions, Event, Widget, MenuManager, RemoteManager, SettingsManager, InformationManager

--- Declarations --
local Toolbar = plugin:CreateToolbar("Quokka's Developer Tools")
local Button = Toolbar:CreateButton("", "", "rbxassetid://4978429323")

--- Module ---
local HelperFunctions = require(script.HelperFunctions)

if HelperFunctions.IsEnvironmentValid() then
	--- Modules ---
	local Event = require(script.Event)
	local Widget = require(script.Widget)

	Widget:Initialize(plugin)
	Widget.Settings = require(script.Settings).new(plugin)

	local MenuManager = require(script.MenuManager)
	local RemoteManager = require(script.RemoteManager)
	require(script.SettingsManager).new(plugin)
	require(script.InformationManager)

	--- Functions ---
	local function Activate()
		plugin:Activate(true)
		Button:SetActive(true)
		Widget:Enable()
	end

	local function Deactivate()
		plugin:Activate(false)
		Button:SetActive(false)
		Widget:Disable()
	end

	--- Plugin ---
	do -- Initiate
		Widget.RemoteManager = RemoteManager.new(plugin)

		local offset = Vector2.new(Widget.Settings:Get("ShowParameters") and 224 or 160, 0)
		Widget.RemotesMenu.Arguments.TitleBar.ToggleParameter.Icon.ImageRectOffset = offset

		-- Events
		Widget.ArgumentsList.AddArgument.Button.MouseButton1Click:Connect(function()
			-- Adds an argument to the currently selected remote.
			if Widget.CurrentRemote then
				Widget.CurrentRemote.ArgumentManager:Add()
			else
				warn("First select a remote to create an argument for.")
			end
		end)

		do -- Main Menu
			local mainMenu = Widget.MainMenu

			mainMenu.Open.MouseButton1Click:Connect(function()
				MenuManager:ToggleMainMenu()
			end)

			for index, button in next, mainMenu:GetChildren() do
				if button ~= mainMenu.Open then
					button.MouseEnter:Connect(function()
						-- Displays menu name.
						MenuManager:ShowMenuName(button)
					end)

					button.MouseButton1Click:Connect(function()
						-- Opens menu.
						MenuManager:Open(Widget.Menus[button.Name])
						MenuManager:CloseMainMenu()
					end)

					button.MouseLeave:Connect(function()
						-- Hides menu name.
						if MenuManager.CurrentSelectedMenuButton == button then
							MenuManager:HideMenuName()
						end
					end)
				end
			end
		end

		Widget.RemotesMenu.Remotes.TitleBar.IgnoreList.MouseButton1Click:Connect(function()
			-- Goes to disabled remote view.
			MenuManager:Open(Widget.DisabledRemotesMenu)
		end)

		Widget.RemotesMenu.Arguments.Execute.MouseButton1Click:Connect(function()
			-- Fires/invokes the remote.
			local remote = Widget.CurrentRemote

			if remote then
				remote:CheckExecute()
			end
		end)

		Widget.RemotesMenu.Arguments.Execute.MouseButton2Click:Connect(function()
			-- Fires/invokes the remote with warning supression.
			local remote = Widget.CurrentRemote

			if remote then
				remote:DisplaySilenceContextMenu()
			end
		end)

		Widget.Widget.CommandBar.Input.Content.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				HelperFunctions.RunLocal(Widget.Widget.CommandBar.Input.Content.Text)
			end
		end)

		Widget.RemotesMenu.Arguments.TitleBar.ToggleParameter.MouseButton1Click:Connect(function()
			Widget.Settings:Set("ShowParameters", not Widget.Settings:Get("ShowParameters"))
		end)

		Event.new("SettingChanged", function(setting, value)
			if setting == "ShowParameters" then
				local offset = Vector2.new(value and 224 or 160, 0)
				Widget.RemotesMenu.Arguments.TitleBar.ToggleParameter.Icon.ImageRectOffset = offset
			end
		end)
	end

	-- Button Events
	Button.Click:Connect(function()
		if Widget.PluginWidget.Enabled then
			Deactivate()
		else
			Activate()
		end
	end)

	-- Plugin Events
	plugin.Deactivation:Connect(Deactivate)
else
	Button.Click:Connect(function()
		warn("This plugin is only usable in a running instance.")
	end)
end

--[[
	Notes
		I accidentally made everything a class out of habit when I didn't need to at all
		since the plugin is only instantiated once. This is why you see the Widget module
		aggregating so many other modules. Basically, this plugin is structured fairly terribly,
		and I don't recommend thinking this is good code to learn from (at least structure-wise).
		It'll help you learn the Roblox API and Lua syntax, though.

		Also, if you are new to Lua: technically me referring to these modules as "classes" is wrong.
		Lua doesn't have classes, but there are methods to emulate classes to some degree (using metatables),
		but for all intents and purposes they are classes (at least for Lua).

		I am also sorry for how unorganized the actual plugin hierarchy is. I hope you find use in the plugin!
		Thank you for taking it and using it, :), it means a lot.

	GitHub
		https://github.com/CeaselessQuokka/RemoteExecutor
]]
