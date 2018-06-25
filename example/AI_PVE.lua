local AI_PVE = class("AI_PVE")
local BT                = require("app.bt.BT")
local AI                = import(".FightAI")
local NpcConfig         = _C("npc_config")
local GlobalConfig      = _C("global_var_config")
local AiConfig          = _C("ai_config")
local LeveConfig        = _C("level_config") 
local FightModeConfig   = _C("fight_model_config")
local FightConst     = require("app.views.fight.FightConst")
local SpriteConst = require("app.hero.SpriteConst")

local SKILL_CD_ID = 5016

local GapXs = 
{
    front = 9125,
    middle = 9115,
    behind = 9005,
    gap_row = 9004, -- 不同排兵种x轴的间隔
	gap_col = 9006	--回合制同一排兵种X轴的间隔
}

function AI_PVE:ctor(params)
    self._parent   = params.parent
	self._screenId = params.screenId
    self._aiID     = params.id or LeveConfig[self._screenId].Ai
    local config        = AiConfig[self._aiID]
    print("模式id:" , self._parent._fightModeId)
    local modeConfig    = FightModeConfig[self._parent._fightModeId]
    self._autoNpcList   = config.AutoNpc    -- 自动兵种列表
    self._npcList       = config.Npc        --手动兵种列表
    local skillCDCfg    = GlobalConfig[SKILL_CD_ID]
    self.aiEnabled = true
    self._createSpriteNum = 0
    self.heroQueue = {}
    self.context = { 
        energy = config.StartEnergy > 0 and config.StartEnergy or modeConfig.EnergyValue , 
        heroQueue = self.heroQueue , 
        lineEnabled = true , 
        manualEnabled = true ,
        isOpenMaxLineLimit = modeConfig.MaxLineCnt and modeConfig.MaxLineCnt > 0,
        totalRemainLineCnt = modeConfig.MaxLineCnt,
        totalLineCnt = config.LineCnt ,
        handler = self,
    }
    self.behavior_tree = BT.Root.new( self._parent, BT.Sequence.new("aiLogic" , {
        AI.autoEnergy.new({ 
                increase = config.IncEnergy , 
                increaseTime = config.IncEnergyTime 
        }),
        AI.upgradeHero.new({ 
                heros = config.UpgradeNpc , 
                lineCnt = config.UpgradeLineCnt or 3 
        }),
        BT.Parallel.new("parallel" , "all" , "all" , {
            BT.Sequence.new("handHero", {
                AI.handHero.new({ 
                        heros = self._npcList , 
                        failRecheckTime = config.ManualFailRecheck or {3} 
                }),
                BT.Wait.new(config.ManualInterval[1] or 2, config.ManualInterval[2] or 5),
            }),
            BT.Sequence.new("line", {
                BT.Wait.new(config.AutoInterval[1] or 3 , config.AutoInterval[2] or 8),
                AI.lineHero.new({ 
                        cdTime = config.LineCD > 0 and config.LineCD or modeConfig.XiaoChuCd, 
                        isCd = modeConfig.CDTime > 0 , 
                        lineCnt = config.LineCnt , 
                        energy = {config.LineEnergy[1] or 100 , config.LineEnergy[2] or 100 } , 
                        heros = self._autoNpcList 
                }, self.context),
            }),
            BT.Sequence.new("sendFace", {
                BT.Wait.new(config.Expression and config.Expression[1] or -1 , config.Expression and config.Expression[2] or -1), -- -1 将会无限等待
                AI.face.new(),
            }),
            BT.Sequence.new("skill", {
                BT.Wait.new(skillCDCfg and skillCDCfg.VariableInt or 3),
                AI.skill.new({
                        skills = config.Skills , 
                        skillCdTime = config.SkillInterval , 
                        isSkillLimit = config.SkillLimit == 1 
                }),
            }),
        }),
    }) , self.context)
end

function AI_PVE:getStartPosRange(group)
    if group == FightConst.HeroGroup.None then
        local startPos = self._parent:getComponent("hero"):getOutPos(SpriteConst.Camp.own) 
        return startPos, startPos + 300
    elseif group == FightConst.HeroGroup.Front then
        return GlobalConfig[GapXs.front].VariableString[1] , GlobalConfig[GapXs.front].VariableString[2]
    elseif group == FightConst.HeroGroup.Middle then
        return GlobalConfig[GapXs.middle].VariableString[1] , GlobalConfig[GapXs.middle].VariableString[2]
    elseif group == FightConst.HeroGroup.Behind then
        return GlobalConfig[GapXs.behind].VariableString[1] , GlobalConfig[GapXs.behind].VariableString[2]
    end
end

function AI_PVE:logicUpdate(dt)
    if not self.aiEnabled or self.isForceClosed then return end
    self.behavior_tree:update(dt)
    if #self.heroQueue > 0 then
        local Ids = {}
        local isAuto = self.heroQueue[1].isAuto
        while #self.heroQueue > 0 do
            local info = table.remove(self.heroQueue , 1)
            if info.isAuto ~= isAuto then
                self:createSprite(Ids , nil , isAuto)
                Ids = {}
            end
            isAuto = info.isAuto
            Ids[#Ids + 1] = self:getSpriteDatas( info.id , isAuto)
        end
        self:createSprite(Ids , nil  , isAuto)
    end
end

function AI_PVE:setAiEnable(val)
    self.aiEnabled = val
end

function AI_PVE:forceCloseAI(val)
    self.isForceClosed = val
end

function AI_PVE:setPlayerReady(val)
    self.context.playerReady = val
end

function AI_PVE:setAutoEnabled(val)
	self.context.lineEnabled = val
end

function AI_PVE:setManualEnabled(val)
    -- 回合模式需要重置连线次数
    if val and self:isRoundMode() then 
        self.context.lineCnt = self.context.totalLineCnt
        self.context.is_line_cd = false
    end
	self.context.manualEnabled = val
end

function AI_PVE:getSpriteDatas(spriteId , isAuto)
	local id = self._parent:getComponent("hero"):getNextSpriteId()
	local data = {}
	data.id = id
	data.table_id = spriteId
	data.pos_z , data.pos_x = self:getSpritePos( spriteId , isAuto )
	self._createSpriteNum = self._createSpriteNum + 1
	return  data
end

function AI_PVE:sendFace(id)
    modelMgr.fight:dispatchEvent({name = modelMgr.fight.SEND_EMOTION, data = { emotionId = id, playerId = -1}})
end

function AI_PVE:setRoundMode(flag)
	self._isRoundMode = flag
end

function AI_PVE:isRoundMode()
	return self._isRoundMode
end

--function AI_PVE:getSpriteZ()
--	if not self:isRoundMode() then
--		return math.random(1, #self._parent:getComponent("hero").randomZ)
--	end
--	local randomZ = self._parent:getComponent("hero").randomZ
--	return (self._createSpriteNum % #randomZ) + 1
--end

function AI_PVE:getHeroGroup(spriteId , isAuto)
    if not self.groupRecord then
        self.groupRecord = { 
            curGroup = 1,
            groupCnt = {},
            spriteGroup = {}
        }
        for i = 0 , FightConst.HeroGroup.Behind do
            self.groupRecord.groupCnt[i] = 0
        end
    end
    if isAuto then
        local info = self._parent:getComponent("line"):getLineHeroInfo(spriteId)
        if info then 
            return info.DefaultGroup
        end
        return FightConst.HeroGroup.None
    else
        if not self.groupRecord.spriteGroup[spriteId] then
            self.groupRecord.spriteGroup[spriteId] = self.groupRecord.curGroup
            self.groupRecord.curGroup = (self.groupRecord.curGroup % FightConst.HeroGroup.Behind) + 1
        end
        return self.groupRecord.spriteGroup[spriteId]
    end
end

-- 需要改成 前、中、后 排位置
function AI_PVE:getSpritePos(spriteId , isAuto)
	if not self:isRoundMode() then
		return math.random(1, #self._parent:getComponent("hero").randomZ)
	end
    local groupId = self:getHeroGroup(spriteId , isAuto)
	local randomZ = self._parent:getComponent("hero").randomZ
    local p_s , p_e = self:getStartPosRange(groupId)
	local num = self.groupRecord.groupCnt[groupId]
    -- 增加
    self.groupRecord.groupCnt[groupId] = self.groupRecord.groupCnt[groupId] + 1
	local randomZ = self._parent:getComponent("hero").randomZ
    
	local row = #randomZ - (num % #randomZ)
    local col = math.floor(num / #randomZ)
	local x = p_s +  (col * GlobalConfig[GapXs.gap_col].VariableInt +  (#randomZ - row) * GlobalConfig[GapXs.gap_row].VariableInt) % (p_e - p_s)
    --print("!!!!!!!!" , num , groupId , row , col , x)
	return row , x
end

--创建精灵
function AI_PVE:createSprite(spriteIds, infos , isAuto)
	if not next(spriteIds) then 
		return 
	end
	local data  		= infos or {}
	data.monsters  		= spriteIds--self:getMonsters(monsterIds, math.random(1, 3))
	data.priorityEData  = self:getMonsterData(data.monsters)
	data.is_enemy   	= true
	data.severTime      = 0
    data.is_auto        = isAuto
	local parentMode = self._parent:getModel()
	parentMode:dispatchEvent({name = parentMode .EVENT_CREATE_SPRITE, data = data})
end

--[[
	function 根据id类表随机生成怪物数据
	ids      id列表
]]
function AI_PVE:getMonsterData(ids)
	local datas  = {}
	for i, v in ipairs(ids) do
		local npcId = v.table_id or v
		local config       = NpcConfig[npcId]
		datas[npcId] 		   = {}
		datas[npcId].id        = npcId
		datas[npcId].monsteId  = v.id or self._parent:getComponent("hero"):getNextSpriteId()
		datas[npcId].level     = config.Level[1]
		datas[npcId].hp        = config.MaxHp
		datas[npcId].speed     = config.MoveSpeed
		datas[npcId].attack    = config.Attack
		datas[npcId].crit      = config.Thump
		datas[npcId].atkspeed  = config.AttackSpeed
		datas[npcId].atkrange  = config.AttackRange
		datas[npcId].skill     = config.SkillID
		datas[npcId].isFight   = false
	end
	return datas
end

function AI_PVE:onEditor()
    editorTools.createTreeNode("AI_" .. self._aiID , function()
        self.behavior_tree:onEditor()
    end)
end

return AI_PVE