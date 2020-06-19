--- Event
-- @usage Custom signal class.

return {
	new = function()
		local signalObject = {}

		function signalObject:Connect(callback)
			self.Callback = callback
		end

		function signalObject:Disconnect()
			self.Callback = nil
		end

		function signalObject:Fire(...)
			if self.Callback then
				self.Callback(...)
			end
		end

		return signalObject
	end
}
