local BT = require("app.bt.BT")
local skill = class("skill" , BT.Action)
local AiSkillConfig     = _C("ai_skill_config")
local SkillConfig       = _C("new_skill_config")

function skill:ctor(args)
    skill.super.ctor(self , "skill")
    self.args = args
    self:initAiSkillData(self.args.skills)
    self._skillInterval = self.args.skillCdTime
    self._nowUseSKillTime = self._skillInterval
    self._isSkillLimit = self.args.isSkillLimit
end

function skill:run(dt , context)
    self._parent = context.object
    if self:checkSkill(dt) then
        return "success"
    else
        return "failure"
    end
end

function skill:checkSkill(dt)
	self._nowUseSKillTime = self._nowUseSKillTime + dt
	if self._nowUseSKillTime >= self._skillInterval then --技能施法间隔是否满足条件
		local index = self:isUsinSkill()
		if index then
			self:usingSkill(index)
            return true
		end
	end
    return false
end

function skill:usingSkill(index)
	self._nowUseSKillTime = 0
	local skill  = self._skills[index]
	local config = SkillConfig[skill.skillId]
	local parentModel = self._parent:getModel()
	local data        = {}
	local targetType  = config.TargetType
	local target      = targetType == 1 and self._enemyTargets[1] or self._enemyTargets[1]
	data.is_enemy     = -9999
	data.skill_id     = skill.skillId
	data.pos          = {x = target:getPositionX(), y = target:getPositionY()}
	parentModel:dispatchEvent({name = parentModel.USING_SKILL, data = data})
	if self._isSkillLimit then
		skill.cd = config.ColdTime
	end
end

function skill:isUsinSkill()
	for i,v in ipairs(self._skills) do
		if v.cd <= 0 then
			if self:analyticSkillData(v.aiID) then
				return i
			end
		end
	end
	return nil
end

function skill:initAiSkillData(skills)
	self._skills = {}
	for i,v in ipairs(skills) do
		self._skills[i] = {aiID = v[2], cd = 0, skillId = v[1]}
	end
end

--更新技能Cd时间
function skill:updateSkillTime(dt)
	for k,v in ipairs(self._skills) do
		if v.cd > 0 then
			v.cd = v.cd - dt
		end
	end
end

function skill:fixUpdate(dt , context)
    skill.super.fixUpdate(self , dt , context)
    if self._isSkillLimit then
        self:updateSkillTime(dt)
    end
end

--[[
	targets  查找列表
	minNum  最小的数目
	dist    最小的距离
]]
function skill:findTarget(minNum, dist, targets)
	local targets = targets--self._parent:getMySprites()
	local minNum = minNum
	local dist   = dist
	-- local t      = {}
	for _, t in ipairs(targets) do
		local size = 0
		local q = {}
		table.insert(q, t)
		for __, t1 in ipairs(targets) do
			if t ~= t1 then
				local offsetX = math.abs(t:getPositionX() - t1:getPositionX())
				if offsetX <= dist then
					size = size + 1
					table.insert(q, t1)
				end
			end
		end
		if #q >= minNum then
			return q
		end
	end
	return nil
end

function skill:getSpriteToHero(targets)
	local t = {}
	for i,v in ipairs(targets) do
		if v:getSpriteType() == SpriteConst.SpriteT.hero then
			table.insert(t, v)
		end
	end
	return t
end

--[[
	检测多个英雄是否在一起
	minNum  一起的数量
	dist   距离
]]
function skill:checkSpriteRange(minNum, dist, targets)
	if dist == 0 then
		return targets
	else
		return self:findTarget(minNum, dist, targets)
	end
end

--检测英雄的数量
function skill:checkSpriteNum(num, targets)
	if num == 0 then
		return true
	else
		return #targets >= num
	end
end

--解析AI数据（此方法耗性能, 条件列表越多 性能越差）
function skill:analyticSkillData(aiId)
	local config  = AiSkillConfig[aiId]
	local friendSpr = self:getSpriteToHero(self._parent:getComponent("hero"):getEnemySprites())
	local enemySpr  = self:getSpriteToHero(self._parent:getComponent("hero"):getMySprites())
	if self:checkSpriteNum(config.MNum, friendSpr) then --检测友军数量
		if self:checkSpriteNum(config.YNum, enemySpr) then --检测敌军数量
			local mytargets = self:checkSpriteRange(config.MNum, config.MDist, friendSpr)
			if mytargets then --检测友军
				self._friendTargets = mytargets
				local ytargets = self:checkSpriteRange(config.YNum, config.YDist, enemySpr) 
				self._enemyTargets = ytargets
				if ytargets then --检测敌军
					if self:checkHpPercent(mytargets, config.MHp) then
						if self:checkHpPercent(ytargets, config.YHp) then
							if self:checkBuildDist(self._parent:getComponent("hero"):getEnemySprites(), ytargets, config.TowerDist, SpriteConst.SpriteT.tower) then
								if self:checkBuildDist(self._parent:getComponent("hero"):getEnemySprites(), ytargets, config.BuildDist, SpriteConst.SpriteT.build) then
									return true
								end
							end
						end
					end
				end
			end
		end
	end
	return false
end

return skill