local CommonMessageHandler_ = {}

local StarterGui = game:GetService("StarterGui")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEventFolder = ReplicatedStorage:WaitForChild("RemoteEvent")
local commonMessageEvent = remoteEventFolder:WaitForChild("CommonMessageEvent")

function CommonMessageHandler_.Start()
	commonMessageEvent.OnClientEvent:Connect(function(message: string)
		StarterGui:SetCore("SendNotification", {
			Title = message,
			Text = "",
			Duration = 3
		})
	end)
end

return CommonMessageHandler_
