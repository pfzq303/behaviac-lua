local Wait = class("Wait" , import(".Action"))

function Wait:ctor(minDuration , maxDuration)
    Wait.super.ctor(self, "Wait")
    self.minDuration = minDuration
    self.maxDuration = maxDuration or minDuration
    self.done = false
end

function Wait:run(dt, context)
    if self.done then return 'success'
    else return 'running' end
end

function Wait:start(context)
    self.done = false
    if self.minDuration >= 0 and self.maxDuration >= 0 then
        self:after( math.random(self.minDuration , self.maxDuration), function() 
            self.done = true 
        end)
    end
end

return Wait