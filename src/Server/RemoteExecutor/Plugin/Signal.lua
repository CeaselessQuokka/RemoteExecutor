--- Event
-- @usage Custom signal class.

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({}, Signal)
end

function Signal:Connect(callback)
	self.Callback = callback
end

function Signal:Disconnect()
	self.Callback = nil
end

function Signal:Fire(...)
	if self.Callback then
		self.Callback(...)
	end
end

return Signal
