local BT = require("app.bt.BT")
local face = class("face" , BT.Action)
local mallConfig = _C("mall_config")

function face:ctor()
    face.super.ctor(self , "face")
    self:initAllFace()
end

function face:run(dt , context)
	modelMgr.fight:dispatchEvent({name = modelMgr.fight.SEND_EMOTION, data = { emotionId = self.allEmotions[math.random(1 , #self.allEmotions)], playerId = -1}})
    return "success"
end

function face:initAllFace()
    self.allEmotions = {}
    for _ , v in pairs(mallConfig) do
		if v.Goods[1] == G_Item_Type.Emotion then
			table.insert(self.allEmotions, v.ID)
		end
	end
end

return face