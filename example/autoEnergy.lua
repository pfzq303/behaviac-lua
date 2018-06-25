local BT = require("app.bt.BT")
local autoEnergy = class("autoEnergy" , BT.Action)

function autoEnergy:ctor(args)
    autoEnergy.super.ctor(self, "autoEnergy")
    self.args = args
    if self.args.increase and self.args.increase > 0 
        and self.args.increaseTime and self.args.increaseTime > 0 then
        self:eachTime(self.args.increaseTime , function(context)
            context.energy = context.energy and (context.energy + self.args.increase) or self.args.increase
        end)
    end
end

return autoEnergy