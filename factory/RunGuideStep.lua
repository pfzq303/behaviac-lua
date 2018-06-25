local BT = require("app.bt.BT")
local RunGuideAction = class("RunGuideAction" , BT.Action)

function RunGuideAction:ctor(args)
    RunGuideAction.super.ctor(self, "RunGuideAction_" .. args.StepName)
    self.args = args

    local action
    action = guideMgr.story_factory.storyActionFactory.getActionByType(args.StepName , clone(args.args) , args.text )
    if not action then
        action = guideMgr.story_factory.actionFactory.getActionByType(args.StepName , clone(args.args) , args.text )
    end

    self.action = action
end

function RunGuideAction:start(context)
    self.action:start_impl()
end

function RunGuideAction:run(dt , context)
    self.action:update_impl(nil , dt)
end

function RunGuideAction:run(context , dt)
    self.action:update_impl(nil , dt)
end

function RunGuideAction:finish(status , context)
    self.action:finish_impl()
end

return autoEnergy