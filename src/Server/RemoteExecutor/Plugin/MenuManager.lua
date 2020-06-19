--- Menu Manager
-- @created 5/4/2020
-- @edited 5/4/2020
-- @usage Manages the menus, and exposes a quality of life API.
-- @dependencies Widget

--- Modules ---
local Widget = require(script.Parent.Widget)

--- Menu Manager ---
local Manager = {}
Manager.__index = Manager

function Manager.new()
	return setmetatable({
		CurrentMenu = Widget.RemotesMenu,
		CurrentSelectedMenuButton = nil
	}, Manager)
end

function Manager:Open(menu)
	self:Close()
	self.CurrentMenu = menu
	menu.Visible = true
end

function Manager:Close()
	if self.CurrentMenu then
		self.CurrentMenu.Visible = false

		if self.CurrentMenu == Widget.DisabledRemotesMenu then
			Widget.RemoteManager:ClearRestoredRemotes()
		end
	end
end

-- Main Menu Related Methods
function Manager:ShowMenuName(menu)
	self:HideMenuName()
	self.CurrentSelectedMenuButton = menu
	menu.Title.Visible = true
end

function Manager:HideMenuName()
	if self.CurrentSelectedMenuButton then
		self.CurrentSelectedMenuButton.Title.Visible = false
	end

	CurrentSelectedMenuButton = nil
end

function Manager:OpenMainMenu()
	local mainMenu = Widget.MainMenu
	mainMenu.Size = UDim2.new(0, 24, 0, 24 * 5)
	mainMenu.ClipsDescendants = false
end

function Manager:CloseMainMenu()
	local mainMenu = Widget.MainMenu
	mainMenu.Size = UDim2.new(0, 24, 0, 24)
	mainMenu.ClipsDescendants = true
	self:HideMenuName()
end

function Manager:ToggleMainMenu()
	local mainMenu = Widget.MainMenu

	if mainMenu.Size.Y.Offset == 24 then
		self:OpenMainMenu()
	else
		self:CloseMainMenu()
	end
end

return Manager.new()
