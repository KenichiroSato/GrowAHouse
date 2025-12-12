local TALKER_PATH = "ReplicatedStorage.Models.Noob"
local items = {
    FirstTalkWelcome = {
        { Text = "Welcole！", TextJP = "ようこそ！", NoDistanceHide = true, TalkerPath = TALKER_PATH, TalkEndTime = nil },
    },
	FirstTalkYouCanBuild = {
		{ Text = "In here, you can build your own dream house!", TextJP = "ここでは君だけの理想の家が作れるよ", NoDistanceHide = true, TalkerPath = TALKER_PATH, TalkEndTime = 5, IsWaitInput = false},
	},
	FirstTalkDecolateHome = {
		{ Text = "Buy furniture and toys in the shop and decorate your home freely!", TextJP = "お店で家具やおもちゃを買って自由に家をかざろう", NoDistanceHide = true, TalkerPath = TALKER_PATH, TalkEndTime = 5, IsWaitInput = false },
	},
	FirstBuild = {
		{ Text = "Let's start by building the floor of your house!", TextJP = "まずは家の床を作ってみよう！", NoDistanceHide = true, TalkerPath = TALKER_PATH, TalkEndTime = 3, IsWaitInput = false },
	},
}
return items