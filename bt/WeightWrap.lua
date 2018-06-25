--[[
权重封装器
]]
local WeightWrap = class("WeightWrap" , import(".Decorator"))

function WeightWrap:ctor( name , value , behavior)
    WeightWrap.super.ctor(self, name, behavior)
    self.value = value
end

function WeightWrap:getWeight()
    return self.value
end

return WeightWrap