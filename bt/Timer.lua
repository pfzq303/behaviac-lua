--[[
计时器，它在经过一段时间后运行子节点
]]
local Timer = class("Timer" , import(".Decorator"))

function Timer:ctor(name, duration, behavior)
    Timer.super.ctor(self, name, behavior)
    self.duration = duration
    self.running_time = 0
    self.ready_to_run = false
end

function Timer:fixUpdate(dt , context)
    Timer.super.fixUpdate(self , dt, context)
    if not self.ready_to_run then
        self.running_time = self.running_time + dt
        if self.running_time >= self.duration then
            self.ready_to_run =  true
        end
    end
end

function Timer:run(dt, context)
    if self.ready_to_run then
        local status = self.behavior:update(dt, context)
        return status
    else
        return 'running' 
    end
end

function Timer:start(context)
    self.ready_to_run = false
    self.running_time = 0
end

function Timer:finish(status, context)
    self.ready_to_run = false
end

return Timer