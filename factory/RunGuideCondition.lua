local BT = require("app.bt.BT")
local RunGuideCondition = class("RunGuideCondition", BT.Action)

function RunGuideCondition:ctor(name , args)
    RunGuideAction.super.ctor(self, name)
    self.args = args
    local condition , ret_type = guideMgr.story_factory.conditionFactory.getConditionByType(args.ConditionName , clone(args.args))
    if ret_type == GuideConst.ConditionType.OBJ then
        self.obj = condition
    elseif ret_type == GuideConst.ConditionType.FUNC then
        self.func = condition
    end
end

function RunGuideCondition:start(context)
    if self.obj then
        if self.obj.init_impl then
            self.obj:init_impl()
        end
    end
end

function RunGuideCondition:run(dt, context)
    if self.obj then
        if self.obj.update_impl then
            self.obj:update_impl(nil ,dt)
        end
        if self.obj.check_start_impl then
            if self.obj:check_start_impl() then
                return "success"
            end
        end
        if self.obj.check_finish_impl then
            if self.obj:check_finish_impl() then
                return "success"
            end
        end
    end
    if self.func then
        if self.func() then
            return "success"
        end
    end
    if self.args.isWait then
        return "running"
    end
    return "failure"
end

return RunGuideCondition