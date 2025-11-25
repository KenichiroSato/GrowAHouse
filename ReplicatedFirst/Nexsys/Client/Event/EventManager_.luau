local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local Event_ = require(ReplicatedFirst.Nexsys.Client.Event.Event_)
local EventInstType = require(ReplicatedFirst.Nexsys.Common.Data.EventInstType)
local SystemTypes = require(ReplicatedFirst.Nexsys.Common.SystemTypes)

----------------------------------------------------------------------
-- 
----------------------------------------------------------------------
local EventManager_ = {}
local curEvent = nil
local updateConnection_ = nil

----------------------------------------------------------------------------------------------------
-- 
function EventManager_.StartEvent(eventKey, param)
	print("StartEvent", eventKey)
	curEvent = Event_.new(eventKey, param)
end
----------------------------------------------------------------------------------------------------
-- StartEventWithTalker
function EventManager_.StartEventWithTalker(eventKey, talker : Model, param : table?)
	if param then
		param.Talker = talker
	else
		param = {
			Talker = talker
		}
	end
	EventManager_.StartEvent(eventKey, param)
end

----------------------------------------------------------------------------------------------------
-- StartEventSync
function EventManager_.StartEventSync(eventKey, param) : boolean
	EventManager_.StartEvent(eventKey, param)
	-- ひとまずループ監視で終わりをとる
	while true do
		if curEvent == nil then
			break
		end
		task.wait()
	end
	-- イベント終了
	return true
end
----------------------------------------------------------------------------------------------------
-- StartSimpleTalkEvent
function EventManager_.StartSimpleTalkEvent(talkKey : string, talker : Model?, endTime : number?)
	local param : SystemTypes.SimpleTalkParam = {
		Talker = talker,
		EndTime = endTime,
	}
	EventManager_.StartSimpleTalkEventWithParam(talkKey, param)
end
----------------------------------------------------------------------------------------------------
-- StartSimpleTalkEventWithParam
function EventManager_.StartSimpleTalkEventWithParam(talkKey : string, param : SystemTypes.SimpleTalkParam?)
	-- ここでイベントデータ作成して再生
	local eventData = {
		{ EventInstType.TalkSequence, talkKey }
	}

	local eventParam : SystemTypes.EventParam = {
		Talker = param and param.Talker,
		TalkEndTime = param and param.EndTime,
	}
	print("StartSimpleTalkEvent", talkKey, eventParam)
	curEvent = Event_.newFromEventData(eventData, eventParam)
end
----------------------------------------------------------------------------------------------------
-- 
function EventManager_.OnUpdate(runTime, dt)
	if curEvent then
		curEvent:Update(dt)

		if not curEvent then
			warn("event end")
		end

		if curEvent:IsEnd() then
			curEvent = nil
		end
	end
end

function EventManager_.IsEventPlaying()
	if curEvent then
		return true
	else
		return false
	end
end

----------------------------------------------------------------------------------------------------
-- 初期化処理
----------------------------------------------------------------------------------------------------
if not updateConnection_ then
	updateConnection_ = RunService.Stepped:Connect(EventManager_.OnUpdate)
end

return EventManager_