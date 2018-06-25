--[[
动作类。一个动作是一个叶节点，它将执行一些动作。
唯一有意义的变化是它需要一个名称，以便可以识别它

extend： 添加了定时器的功能
]]
local Action = class("Action" , import(".Behavior"))

function Action:ctor(name)
    Action.super.ctor(self)
    self.name = name or self.__cname
    self._eachTimeQueue = {}
    self._delayTimeQueue = {}
end

function Action:fixUpdate(dt , context)
    -- 执行固定间隔的函数
    if #self._eachTimeQueue > 0 then
        for i = 1, #self._eachTimeQueue do
            local info = self._eachTimeQueue[i]
            info.runningTime = info.runningTime + dt
            if info.runningTime >= info.totalTime then
                info.runFunc(context)
                info.runningTime = info.runningTime - info.totalTime
            end
        end
    end

    -- 执行延时的函数
    if #self._delayTimeQueue > 0 then
        local len = #self._delayTimeQueue
        local i = 1
        while i <= len do
            local info = self._delayTimeQueue[i]
            info.delayTime = info.delayTime - dt
            if info.delayTime <= 0 then
                info.runFunc(context)
                table.remove(self._delayTimeQueue , i)
                len = len - 1
            else
                i = i + 1
            end
        end
    end

end

function Action:eachTime(time , func)
    table.insert(self._eachTimeQueue , { totalTime = time , runFunc = func , runningTime = 0 } )
end

function Action:after(time, func)
    table.insert(self._delayTimeQueue , { delayTime = time , runFunc = func } )
end

function Action:onEditor()
    editorTools.createTreeNode(self.name, function()
        editorTools.showDataInfo(self)
    end)
end

return Action