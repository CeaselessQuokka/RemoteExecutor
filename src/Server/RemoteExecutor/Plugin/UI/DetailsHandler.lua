--- Details Handler
-- @created 5/4/2020
-- @edited 5/4/2020
-- @usage Handles ScrollArea resizing for details.

--- Services ---
local TextService = game:GetService("TextService")

--- Details Handler ---
local Handler = {}
Handler.__index = Handler

function Handler.new(scrollArea)
	local details = scrollArea.Details
	local detailsHandlerObject = {
		Details = details,
		ScrollArea = scrollArea
	}

	-- Events
	details:GetPropertyChangedSignal("Text"):Connect(function()
		detailsHandlerObject:Update()
	end)

	details:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		detailsHandlerObject:Update()
	end)

	return setmetatable(detailsHandlerObject, Handler)
end

function Handler:Update()
	local details = self.Details
	local x = details.AbsoluteSize.X

	-- Subtract 4 for the scrollbar size.
	local y = TextService:GetTextSize(details.Text, details.TextSize, details.Font, Vector2.new(x - 4, 2 ^ 16)).Y
	self.ScrollArea.CanvasSize = UDim2.new(0, 0, 0, y + details.TextSize)
end

function Handler:SetContent(content)
	self.Details.Text = content
	self:Update()
end

return Handler
