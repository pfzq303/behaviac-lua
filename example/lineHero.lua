local BT = require("app.bt.BT")
local lineHero = class("lineHero" , BT.Action)
local FightConst     = require("app.views.fight.FightConst")

function lineHero:ctor(args , context)
    lineHero.super.ctor(self , "lineHero")
    self.args = args
    self.isWait = false
    context.lineCnt = self.args.isCd and 0 or self.args.lineCnt
end

function lineHero:checkNext(context)
    if not context.lineEnabled and context.handler:isRoundMode() then
        if context.playerReady then
            context.playerReady = false
            context.handler._parent:sendFightStateMsg(FightConst.FightCommand.LineTimeOver)
        end
    end
end

function lineHero:run(dt , context)
    if not context.lineEnabled or context.is_line_cd then
        self:checkNext(context)
        return "failure"
    end
    --进入到cd时间
    if context.lineCnt <= 0 then
        context.is_line_cd = true
        if context.handler:isRoundMode() then
            context.lineEnabled = false
            context.lineCnt = self.args.lineCnt
            self:checkNext(context)
        else
            self:after(self.args.cdTime , function()
                print("cd finish")
                context.is_line_cd = false
                context.lineCnt = self.args.lineCnt
            end)
        end
        return "failure" 
    end
    context.totalLine = context.totalLine and (context.totalLine + 1) or 1
    context.lineCnt = context.lineCnt - 1
    if context.isOpenMaxLineLimit then
        context.totalRemainLineCnt = context.totalRemainLineCnt - 1
        if context.totalRemainLineCnt == 0 then
            context.lineCnt = 0
            context.lineEnabled = false
        end
    end
    modelMgr.fight:dispatchEvent({name = modelMgr.fight.ON_LINE_UPDATE , data = { player_id = -1, line_remain = context.lineCnt, total_line_remain = context.totalRemainLineCnt }})
    --增加能量
    context.energy = context.energy + math.random(self.args.energy[1] , self.args.energy[2] or self.args.energy[1])
    --出兵
    local hero = self:randomData(self.args.heros)
    if hero then
        table.insert(context.heroQueue , { id = hero[2] , isAuto = true } )
    end
    return "success"
end

function lineHero:randomData(datas)
	if not next(datas) then 
		return 
	end
	local max  = 0
    for i,v in ipairs(datas) do
        max = max + v[1]
    end
	local range = 0
	local rand = math.random(1, max)
	for i,v in ipairs(datas) do
		local _range = v[1] + range
		if rand <= _range then
			return v 
		end
		range = _range
	end
	return nil
end

return lineHero