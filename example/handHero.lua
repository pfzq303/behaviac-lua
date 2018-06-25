local BT = require("app.bt.BT")
local handHero = class("handHero" , BT.Action)
local NpcConfig         = _C("npc_config")
local GroupConfig       = _C("npc_group_config")
local FightConst     = require("app.views.fight.FightConst")

function handHero:ctor(args)
    handHero.super.ctor(self, "handHero")
    self.args = args
    self.heroTotal = 0
    self.recheckCnt = 0
    for _ , v in ipairs(self.args.heros) do
        self.heroTotal = self.heroTotal + v[1]
    end
    self.isWait = self.args.startWait and #self.args.startWait > 0
    if #self.args.heros > 0 and self.isWait then
        self:after(math.random(self.args.startWait[1], self.args.startWait[2]) , function()
            self.isWait = false
            self:randomCreateSprite()
        end)
    else
        if #self.args.heros > 0 then
            self:randomCreateSprite()
        else
            self.isWait = true
        end
    end
end

--随机创建手动兵种
function handHero:randomCreateSprite()
    self.targetHero = nil
    self.targetEnergy = nil
    self.targetNum = nil
	local groupInfo = self:randomData(self.args.heros) --找出对应随机的出怪组
    if not groupInfo then 
        print("ai手动Group兵种失败")
        self.recheckCnt = self.recheckCnt + 1
        self.isWait = true
        self:after(self.args.failRecheckTime[self.recheckCnt] or self.args.failRecheckTime[#self.args.failRecheckTime] , function()
            self.isWait = false
            self:randomCreateSprite()
        end)
        return 
    end
	local groupConf = GroupConfig[groupInfo[2]].Group
	local heroId = self:randomData(groupConf)--找出对应随机的出怪物IDs
    if not heroId then 
        print("ai手动Hero兵种失败")
        self.recheckCnt = self.recheckCnt + 1
        self.isWait = true
        self:after(self.args.failRecheckTime[self.recheckCnt] or self.args.failRecheckTime[#self.args.failRecheckTime] , function()
            self.isWait = false
            self:randomCreateSprite()
        end)
        return 
    end
    self.recheckCnt = 0
    self.targetHero = heroId[2]
	local cfg = NpcConfig[self.targetHero]
    self.targetEnergy = cfg.UseEnergy
    self.targetNum = cfg.Num
end

function handHero:randomData(datas)
	if not next(datas) then 
		return 
	end
    -- 以100来控制是为了有时候让ai出不了兵。这样有一定几率ai能屯兵
	local max  = 0
    for i,v in ipairs(datas) do
        max = max + v[1]
    end
    max = math.max(100 , max)
	local range = 0
	local rand = math.random(1, max)
	for i,v in ipairs(datas) do
		range = v[1] + range
        print(range)
		if rand <= range then
			return v 
		end
	end
	return nil
end

function handHero:run(dt , context)
    if not context.manualEnabled or self.isWait then 
        return "running" 
    end
	if context.energy >= self.targetEnergy then
        context.energy = context.energy - self.targetEnergy
        for i = 1 , self.targetNum do
            table.insert(context.heroQueue , { id = self.targetHero , isAuto = false })
        end
        self:randomCreateSprite()
        return "success"
    else
        if context.handler:isRoundMode() then
            if context.playerReady then
                context.playerReady = false
                self:after(math.random(0.1, 2.0) , function()
                    context.handler._parent:sendFightStateMsg(FightConst.FightCommand.ProduceTimeOver)
                end)
            end
        end
        return "running"
    end

end

return handHero