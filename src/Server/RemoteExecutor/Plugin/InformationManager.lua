--- Information Manager
-- @created 5/6/2020
-- @edited 5/6/2020
-- @usage Manages the changing between information tabs in the Information section.
-- @dependencies Widget, DetailsHandler

--- Modules ---
local Widget = require(script.Parent.Widget)
local DetailsHandler = require(script.Parent.UI.DetailsHandler)

--- GUIs ---
local InformationList = Widget.InformationList
local InformationDetails = Widget.InformationDetails

--- Data ---
local InformationDetailsMap = {
	About = "This plugin was designed to streamline remote security testing throughout your games.",
	Features = "Test the security of remotes\n\nParameter Presets (refer to the Parameter Presets section for more information)\n\nRemote ignoring, and ignored remotes only show up (in the remote ignore list menu) if they are in the place\n\nArgument and type checking for your passed arguments\n\nArgument name display for those (like me) who forget what their remotes take",
	Credits = "To sircfenner (@sircfennerRBX on Twitter) for the idea of this plugin.\n\nTo Google for the the Dropdown Arrow icon.\n\nTo Freepik for the Menu, Show Parameters, Parameter Preset, Information, Create Preset, and Restore icons.\n\nTo Kiranshastry for the Parameter Edit icon.\n\nTo Pixel perfect for the Settings, Hide Parameters, Add Argument, Reset to Defaults, and Ignore List icons.\n\nTo Pixelmeetup for the Delete icon.\n\nTo Smashicons for the Remote icon.\n\nAnd to you for finding use in my plugins! Thank you so much.\n\nP.S. All mentioned icon creators can be found on flaticon.com (this is where all the icons were downloaded from for free).",
	Contact = "You can contact me on Twitter @CeaSoul."
}

--- Menu Manager ---
local Manager = {}
Manager.__index = Manager

function Manager.new()
	local informationManagerObject = setmetatable({
		CurrentInformation = "About"
	}, Manager)

	-- Events
	for index, button in next, InformationList:GetChildren() do
		if button:IsA("TextButton") then
			button.MouseButton1Click:Connect(function()
				informationManagerObject.CurrentInformation = button.Name
				informationManagerObject:Display()
			end)
		end
	end

	DetailsHandler.new(InformationDetails)
	informationManagerObject:Display()
	return informationManagerObject
end

function Manager:Display()
	InformationDetails.Details.Text = InformationDetailsMap[self.CurrentInformation]
end

return Manager.new()
