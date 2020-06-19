--- Ignore List
-- @created 5/4/2020
-- @edited 5/4/2020
-- @usage A clean way to manage the ignore list for the plugin.
-- @implements Serialize

--- Services ---
local HttpService = game:GetService("HttpService")

--- Ignore List ---
local IgnoreList = {}
IgnoreList.__index = IgnoreList

function IgnoreList.new(json)
	return setmetatable(json and HttpService:JSONDecode(json) or {}, IgnoreList)
end

function IgnoreList:Serialize()
	return HttpService:JSONEncode(self)
end

function IgnoreList:Exists(path)
	return self[path] ~= nil
end

function IgnoreList:Add(path)
	if not self:Exists(path) then
		self[path] = true
		return true
	end

	return false
end

function IgnoreList:Remove(path)
	if self:Exists(path) then
		self[path] = nil
		return true
	end

	return false
end

return IgnoreList
