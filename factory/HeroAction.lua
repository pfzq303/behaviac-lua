local BT = require("app.bt.BT")
local SpriteConst    = require("app.hero.SpriteConst")
local HTMLLabel = packMgr:addPackage("app.views.component.HtmlLabel")
local HeroAction = {}

-----------------------------------
local BaseHeroAction = class("BaseHeroAction" , BT.Action)

function BaseHeroAction:ctor(args ,text)
    BaseHeroAction.super.ctor(self, self.__cname)
    self.text = text
    self.args = args or {}
end
--------------------------------------------------------------
local Anim = class("Anim" , BaseHeroAction)

function Anim:start(context)
    context.object:play(self.args.anim , self.args.animLoop)
end

HeroAction.ANIM = Anim 

--------------------------------------------------------------
local Status = class("Status" , BaseHeroAction)

function Status:start(context)
    context.object:setStatus(self.args.status)
end

HeroAction.STATUS = Status 

--------------------------------------------------------------
local MoveTo = class("MoveTo" , BaseHeroAction)

function MoveTo:start(context)
    self.lastPos = context.object:getPositionX()
    if self.lastPos > self.args.posX then
        context.object:setDir(SpriteConst.Dir.left)
    else
        context.object:setDir(SpriteConst.Dir.right)
    end
    context.object:setFixTargets()
    context.object:setStatus(SpriteConst.St.run)
end

function MoveTo:run(dt , context)
    local pos = context.object:getPositionX()
    if (pos - self.args.posX) * (self.lastPos - self.args.posX) <= 0 then
        context.object:setStatus(SpriteConst.St.idle)
        return "success"
    end
    self.lastPos = pos
    return "running"
end

HeroAction.MOVE_TO = MoveTo 
--------------------------------------------------------------

local Camp = class("Camp" , BaseHeroAction)

function Camp:start(context)
    GuideConst.gameInst:getComponent("hero"):changeSpriteCamp(context.object , self.args.camp)
end

HeroAction.CAMP = Camp 

--------------------------------------------------------------

local Dir = class("Dir" , BaseHeroAction)

function Dir:start(context)
    context.object:setDir(self.args.dir)
end

HeroAction.DIR = Dir 

--------------------------------------------------------------

local Patrol = class("Patrol" , BaseHeroAction)

function Patrol:start(context)
    context.object:setStatus(1)
    context.object:setGuardian(true)
    context.object:setPatrolPoint(cc.p(self.args.posX, 0))
    context.object:setPatrolRang(self.args.range)
end

HeroAction.PATROL = Patrol 

--------------------------------------------------------------

local PatrolCancel = class("PatrolCancel" , BaseHeroAction)

function PatrolCancel:start(context)
    context.object:setGuardian(false)
end

HeroAction.PATROL_CANCEL = PatrolCancel 
--------------------------------------------------------------

local Die = class("Die" , BaseHeroAction)

function Die:start(context)
    context.object:setDie(true , true)
end

HeroAction.DIE = Die 
--------------------------------------------------------------

local Speak = class("Speak" , BaseHeroAction)

function Speak:start(context)
    self.isRunning = true
    local node = cc.CSLoader:createNode("story/HeroSpeak.csb")
	if self.text and self.text ~= "" then
		local label
		label = HTMLLabel.new({
			textWidth = self.args.width or 9999,
			space = self.args.space or 0,
		})
		label:setPosition(self.args.offsetX or 0 ,self.args.offsetY or 0)
		label:setString(self.text)
		label:setAnchorPoint(cc.p(0, 0.5))
		node:getChildByName("textContainer"):addChild(label)
		local bg = node:getChildByName("bgNode")
		local lwidth = label:getContentWidth()
		local lheight = label:getContentSize().height
		bg:setContentSize(cc.size(lwidth + 60 , lheight + 60))
		node:getChildByName("textContainer"):setPositionY(lheight / 2 + 45)
		if self.args.changeDir then
			node:getChildByName("textContainer"):setPositionX(-node:getChildByName("textContainer"):getPositionX())
			label:setPositionX(0 + (self.args.offsetX or 0))
			bg:setScaleX(-1)
		else
			label:setPositionX(-lwidth + (self.args.offsetX or 0))
		end
	end
	local size = context.object:getContentSize()
	local hpPos = rawget(context.object.class, "HP_POS_Y")
	node:setPosition(self.args.posX or 0 , self.args.posY or (size.height + context.object:getOffsetY() + (hpPos or 0) - 10))
	GuideConst.gameInst:getComponent("map"):addFloatText(node , context.object , true)
	node:runAction(cc.Sequence:create(cc.DelayTime:create(self.args.delayTime or 2) , cc.FadeOut:create(0.1), cc.RemoveSelf:create()))
    self:after(self.args.delayTime or 2 , function()
        self.isRunning = false
    end)
end

function Speak:run(dt , context)
    if self.isRunning then
        return "running"
    end
    return "success"
end

HeroAction.SPEAK = Speak 
--------------------------------------------------------------


local Atk = class("Atk" , BaseHeroAction)

function Atk:start(context)
    local targetRole = GuideConst.gameInst:getComponent("story"):getRoleById(self.args.target)
    if context.object then
        if targetRole then
            context.object:setFixTargets({ targetRole })
            context.object:setStatus(SpriteConst.St.run)
        else
            context.object:setFixTargets()
            context.object:setStatus(SpriteConst.St.run)
        end
    end
end

HeroAction.ATK = Atk 
--------------------------------------------------------------

local TowerAdd = class("TowerAdd" , BaseHeroAction)

function TowerAdd:start(context)
    GuideConst.gameInst:getComponent("hero"):addBuild(self.args.camp or SpriteConst.Camp.own
                                ,self.args.buildType
                                ,self.args.id
                                ,self.args.posX or 0 )
end

HeroAction.TOWER_ADD = TowerAdd 
--------------------------------------------------------------

local FightOver = class("FightOver" , BaseHeroAction)

function FightOver:start(context)
    GuideConst.gameInst:clientRequstGameOver(self.args.gameResult or FightConst.GameResult.fail)
end

HeroAction.FIGHT_OVER = FightOver 
--------------------------------------------------------------

local HeroAdd = class("HeroAdd" , BaseHeroAction)

function HeroAdd:start(context)
    GuideConst.gameInst:getComponent("story"):createStoryRole(self.args.name , 
                                                        self.args.npcId,  
                                                        self.args.posX,
                                                        self.args.posZ, 
                                                        self.args.camp,
                                                        self.args.dir,
                                                        self.args.status, 
                                                        self.args.hideEffect,
                                                        self.args.wudi,
                                                        self.args.skin)
end

HeroAction.HERO_ADD = HeroAdd 
--------------------------------------------------------------
-- 唤醒附近警戒的队友
local Notify = class("Notify" , BaseHeroAction)

function Notify:start(context)
    local px = context.object:getPositionX()
    local sprites
    if context.object:getCamp() == SpriteConst.Camp.own then
        sprites = GuideConst.gameInst:getComponent("hero"):getMySprites()
    else
        sprites = GuideConst.gameInst:getComponent("hero"):getEnemySprites()
    end
    self.args.range = self.args.range or 400
    for _ , v in ipairs(sprites) do
        if v:getStatus() == SpriteConst.St.warn and math.abs( v:getPositionX() , px) <= self.args.range then
            v:setStatus(SpriteConst.St.wait)
        end
    end
end

HeroAction.NOTIFY = Notify 
--------------------------------------------------------------

--什么都不做
local Keep = class("Keep" , BaseHeroAction)

function Keep:start(context)
    
end

HeroAction.KEEP = Keep 
--------------------------------------------------------------


--检测状态
local IsStatus = class("IsStatus" , BaseHeroAction)

function IsStatus:start(context)
    if context.object:getStatus() == self.args then
        return "success"
    end
    return "failure"
end

HeroAction.IS_STATUS = IsStatus 

--------------------------------------------------------------

return HeroAction
