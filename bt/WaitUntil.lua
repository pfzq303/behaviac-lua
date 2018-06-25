local WaitUntil = class("WaitUntil" , import(".Decorator"))

function WaitUntil:ctor(behavior)
    WaitUntil.super.ctor(self, 'WaitUntil', behavior)
end

function WaitUntil:run(dt, context)
    local status = self.behavior:update(dt, context)
    if status == 'success' then return 'success'
    else return 'running' end
end

return WaitUntil
