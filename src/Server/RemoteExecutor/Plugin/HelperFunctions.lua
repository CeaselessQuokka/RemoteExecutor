--- Helper Function
-- @created 5/4/2020
-- @edited 6/19/2020
-- @usage Random helper functions.

--- Services ---
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--- Declarations ---
local Player = Players.LocalPlayer
local RemoteStorages = {Lighting, Workspace, ReplicatedStorage}

--- Functions ---
function CopyTable(tbl)
	-- Doesn't support metatables and cyclic tables.

	if type(tbl) == "table" then
		local copy = {}

		for key, value in next, tbl do
			copy[key] = CopyTable(value)
		end

		return copy
	else
		return tbl
	end
end

--- Helper Functions ---
return {
	RunLocal = function(code)
		local localScript = Instance.new("LocalScript")
		localScript.Source = code
		localScript.Parent = Player.PlayerScripts
	end,

	GetRemotes = function()
		local remotes = {}

		for index, storage in next, RemoteStorages do
			for index, remote in next, storage:GetDescendants() do
				if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
					remotes[#remotes + 1] = remote
				end
			end
		end

		return remotes
	end,

	IsEnvironmentValid = function()
		return RunService:IsRunning()
	end,

	GetPrettyPath = function(instance)
		-- Pretty ugly and fairly inefficient (look at that concatenation), but don't judge me, D:.

		local fullName = instance:GetFullName()
		local prettyPath = ""

		for node in fullName:gmatch("[^%.]+") do
			if node:match("%W") or node:match("^%d") then
				prettyPath = prettyPath .. ("[%q]"):format(node)
			else
				prettyPath = prettyPath .. "." .. node
			end
		end

		return prettyPath:gsub("^%.", "")
	end,

	CopyTable = CopyTable
}
