--[[
当函数成功时
]]
local Func = class("Func" , import(".Action"))

function Func:ctor(fn)
    Func.super.ctor(self , "Func")
    self.fn = fn
end

function Func:run(dt, context)
    if self.fn(context) then
        return "success"
    end
    return "failure"
end

return Func