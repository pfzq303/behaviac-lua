--[[
装饰器是逆变器，它从孩子身上取得值并将其倒置
]]
local Inverter = class("Inverter" , import(".Decorator"))

function Inverter:ctor(behavior)
    Inverter.super.ctor(self, 'Inverter', behavior)
end

function Inverter:run(dt, context)
    local status = self.behavior:update(dt, context)
    if status == 'running' then return 'running'
    elseif status == 'success' then return 'failure'
    elseif status == 'failure' then return 'success' end
end

return Inverter