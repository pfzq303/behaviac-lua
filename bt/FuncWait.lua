--[[
一直等到函数执行成功
]]
local FuncWait = class("FuncWait" , import(".Action"))

function FuncWait:ctor(fn)
    FuncWait.super.ctor(self , "FuncWait")
    self.fn = fn
end

function FuncWait:run(dt, context)
    if self.fn(context) then
        return "success"
    end
    return "running"
end

return FuncWait