--[[
一直重复执行直到返回failure
]]
local RepeatUntilFail = class("RepeatUntilFail" , import(".Decorator"))

function RepeatUntilFail:ctor(behavior)
    RepeatUntilFail.super.ctor(self, 'RepeatUntilFail', behavior)
end

function RepeatUntilFail:run(dt, context)
    local status = self.behavior:update(dt, context)
    if status ~= 'failure' then return 'running'
    else return 'success' end
end

return RepeatUntilFail