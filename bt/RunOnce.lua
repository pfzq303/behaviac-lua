--[[
装饰器是逆变器，它从孩子身上取得值并将其倒置
]]
local RunOnce = class("RunOnce" , import(".Decorator"))

function RunOnce:ctor(name , behavior)
    RunOnce.super.ctor(self, name, behavior)
    self.isRun = false
end

function RunOnce:run(dt, context)
    if self.isRun then
        return "failure"
    end
    local status = self.behavior:update(dt, context)
    if status == 'success' then
        self.isRun = true
    end
    return status
end

return RunOnce