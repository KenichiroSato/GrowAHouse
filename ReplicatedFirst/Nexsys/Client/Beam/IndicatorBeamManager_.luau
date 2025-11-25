local ReplicatedFirst = game:GetService("ReplicatedFirst")
local IndicatorBeam_ = require(ReplicatedFirst.Nexsys.Client.Beam.IndicatorBeam_)

local IndicatorBeamManager_ = {}
IndicatorBeamManager_.__index = IndicatorBeamManager_
IndicatorBeamManager_.instance = nil
---------------------------------------------
function IndicatorBeamManager_:GetInstance()
	return IndicatorBeamManager_.instance
end 

function IndicatorBeamManager_.new()
	local self = setmetatable({}, IndicatorBeamManager_)
	IndicatorBeamManager_.Init(self)
	IndicatorBeamManager_.instance = self
	return self
end

function IndicatorBeamManager_:Init()
	self.beamList = {}
	self:SetEnabled(true)
end

function IndicatorBeamManager_:CreateBeam(targetAttachment: Attachment?)
	local beam = IndicatorBeam_.new(targetAttachment)
	table.insert(self.beamList, beam)
	return beam
end

function IndicatorBeamManager_:DestroyBeam(beamHandler)
	for index, item in ipairs(self.beamList) do
		if item == beamHandler then
			beamHandler:Destroy()
			table.remove(self.beamList, index)
			break
		end
	end
end

function IndicatorBeamManager_:Destroy()
	for _, beam in ipairs(self.beamList) do
		beam:Destroy()
	end
	self.beamList = {}
end

function IndicatorBeamManager_:SetEnabled(enabled : boolean)
	self.isEnabled = enabled
	local needUpd = false
	for _, beam in ipairs(self.beamList) do
		local ok = beam:OnSettingBeam(enabled)
		if not ok then
			needUpd = true
		end
	end
	
	-- remove old beam 
	if needUpd then
		for index, item in ipairs(self.beamList) do
			table.remove(self.beamList, index)
		end
	end
end

function IndicatorBeamManager_:IsEnabled()
	return self.isEnabled
end

if IndicatorBeamManager_.instance == nil then
	IndicatorBeamManager_:new()
end

return IndicatorBeamManager_.instance
