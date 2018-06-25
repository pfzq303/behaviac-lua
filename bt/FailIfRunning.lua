--[[
在RUNNING状态失败
]]
local FailIfRunning = class("FailIfRunning" , import(".Decorator"))

function FailIfRunning:ctor(behavior)
    FailIfRunning.super.ctor(self, 'FailIfRunning', behavior)
end

function FailIfRunning:run(dt, context)
    local status = self.behavior:update(dt, context)
    if status == 'running' then return 'failure'
    else return status end
end

return FailIfRunning