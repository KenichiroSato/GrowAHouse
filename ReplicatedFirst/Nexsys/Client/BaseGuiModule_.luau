local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SystemDataModule_ = require(ReplicatedFirst.Nexsys.Client.SystemDataModule_)

--- @class BaseGuiModule_ : table
local BaseGuiModule_ = {}
BaseGuiModule_.__index = BaseGuiModule_
BaseGuiModule_.gui_ = nil

----------------------------------------------------------------------------------------------------
-- Setup
function BaseGuiModule_.WaitForLoaded(gui : ScreenGui)
	BaseGuiModule_.gui_ = gui
	local curDescsNum = 0
	local needNum = 0
	repeat
		local info = SystemDataModule_.GetGuiSetupInfo()
		if not info then
			warn("BaseGuiModule_.Setup, SystemDataModule_.GetGuiSetupInfo() is nil")
			task.wait()
			continue
		end

		needNum = info[gui.Name]
		curDescsNum = #gui:GetDescendants()
		warn("BaseGuiModule_.Setup", gui.Name, needNum, curDescsNum)
		task.wait()
	until needNum > 0 and curDescsNum >= needNum

	warn("BaseGuiModule_.Setup", gui.Name, "loaded")
end
----------------------------------------------------------------------------------------------------
-- Show
function BaseGuiModule_.Show()
	if BaseGuiModule_.gui_ then
		BaseGuiModule_.gui_.Enabled = true
	end
end
----------------------------------------------------------------------------------------------------
-- Hide
function BaseGuiModule_.Hide()
	if BaseGuiModule_.gui_ then
		BaseGuiModule_.gui_.Enabled = false
	end
end

return BaseGuiModule_