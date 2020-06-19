--- Argument
-- @created 5/4/2020
-- @edited 5/4/2020
-- @usage The argument class for remotes.
-- @dependencies Widget

--- Services ---
local TextService = game:GetService("TextService")

--- Modules ---
local Widget = require(script.Parent.Parent.Widget)

--- Templates ---
local ChoiceTemplate = Widget.Templates.Choice
local ArgumentTemplate = Widget.Templates.Argument

--- Argument ---
local Argument = {}
Argument.__index = Argument

function Argument.new(argumentData)
	local argumentGUI = ArgumentTemplate:Clone()
	local argumentObject = setmetatable({
		GUI = argumentGUI,
		Content = argumentGUI.Input.Content,
		Choices = argumentGUI.Input.Choices,
		Parameter = argumentGUI.Input.Parameter,
		ArgumentData = argumentData,
		DropdownButton = argumentGUI.Input.Dropdown
	}, Argument)

	-- Events
	argumentObject.DropdownButton.MouseButton1Click:Connect(function()
		if argumentObject.ArgumentData and #argumentObject.Choices:GetChildren() > 1 then
			argumentObject.Choices.Visible = not argumentObject.Choices.Visible
		end
	end)

	return argumentObject
end

-- Updates input sizing based off settings, and updates dropdown.
function Argument:Update()
	local contentSize = -4
	local parameterContainer = self.Parameter
	local parameter = parameterContainer.Content

	if Widget.Settings:Get("ShowParameters") then
		self.DropdownButton.Visible = true
		self.Content.Position = UDim2.new(1, -16, 0, 0)

		if self.ArgumentData then
			local parameterSize
			parameter.Text = self.ArgumentData.Name .. ":"

			-- parameterSize = parameter.TextBounds.X + 4
			parameterSize = TextService:GetTextSize(
				parameter.Text,
				parameter.TextSize,
				parameter.Font,
				Vector2.new(2^16, 0)
			).X + 4

			parameterContainer.Size = UDim2.new(0, parameterSize, 1, -6)

			contentSize = contentSize - parameterSize - 21
			self.Parameter.Visible = true
		else
			self.Parameter.Visible = false
			contentSize = contentSize - 16
			self.Parameter.Content.Text = ""
			parameterContainer.Size = UDim2.new(0, 0, 1, -6)
		end
	else
		self.Parameter.Visible = false
		self.DropdownButton.Visible = false
		self.Content.Position = UDim2.new(1, 0, 0, 0)
	end

	self.Content.Size = UDim2.new(1, contentSize, 1, 0)
	self:UpdateDropdown()
end

function Argument:ClearDropdown()
	for index, instance in next, self.Choices:GetChildren() do
		if not instance:IsA("UIListLayout") then
			instance:Destroy()
		end
	end
end

-- Updates dropdown if preset is active.
function Argument:UpdateDropdown()
	local argumentData = self.ArgumentData
	self.Choices.Visible = false
	self:ClearDropdown()

	if argumentData then
		if argumentData.Presets then
			for index, preset in next, argumentData.Presets do
				local choice = ChoiceTemplate:Clone()

				choice.Name = "Preset" .. index
				choice.Content.Text = preset

				choice.Parent = self.Choices

				-- Events
				choice.MouseButton1Click:Connect(function()
					if self.ArgumentData.DataType == "string" then
						self.Content.Text = ("%q"):format(choice.Content.Text)
					else
						self.Content.Text = choice.Content.Text
					end

					self.Choices.Visible = false
				end)
			end

			self.Choices.Size = UDim2.new(10, 0, 0, (#self.Choices:GetChildren() - 1) * 24)
		end
	end
end

-- Shows argument.
function Argument:Show()
	self.GUI.Visible = true
end

-- Hides argument.
function Argument:Hide()
	self.GUI.Visible = false
end

-- Destroys argument GUI.
function Argument:Remove()
	self.GUI:Destroy()
end

return Argument
