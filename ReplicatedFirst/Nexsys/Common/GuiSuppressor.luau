local GuiSuppressor = {}

local BaseGameData = require(script.Parent.BaseGameData)

local ATTRIBUTE_KEY = "SuppressGui"
local baseGameData = BaseGameData.new()

function GuiSuppressor.Suppress()
	baseGameData:SetAttribute(ATTRIBUTE_KEY, true)
end

function GuiSuppressor.Unsuppress()
	baseGameData:SetAttribute(ATTRIBUTE_KEY, false)
end

function GuiSuppressor.ListenSuppressChange(callback: (boolean) -> ())
	baseGameData:ListenAttributeChanged(ATTRIBUTE_KEY, callback)
end

return GuiSuppressor
