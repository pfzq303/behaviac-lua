--[[
随机抽取一个运行非failure的节点 ，如果所有节点都failure,那么这个节点状态设置为failure，如果是RUNNING的，则一直执行到返回结果
]]
local Random = class("Random" , import(".Behavior"))

function Random:ctor(name, behaviors)
    Random.super.ctor(self)
    self.name = name
    self.behaviors = behaviors
end

function Random:fixUpdate(dt, context)
    for i = 1, #self.behaviors do
        self.behaviors[i]:fixUpdate(dt, context)
    end
end

function Random:start(context)
    local t = 0
    for _ ,v in ipairs(self.behaviors) do
        if v.getWeight then
            t = t + v:getWeight()
        else
            t = t + 1
        end
    end
    local rv = math.random(t)
    local t = 0
    for i ,v in ipairs(self.behaviors) do
        if v.getWeight then
            t = t + v:getWeight()
        else
            t = t + 1
        end
        if rv <= t then
            self.current_behavior = i
            break
        end
    end
end

function Random:run(dt, context)
--    self.current_behavior = math.random(#self.behaviors)
    local start = self.current_behavior
    while true do
        local child = self.behaviors[self.current_behavior]
        local status = child:update(dt , context)
            
        if status ~= "failure" then
            return status
        end
            
        self.current_behavior = self.current_behavior + 1
        if self.current_behavior == #self.behaviors then
            self.current_behavior = 1
        end
        if self.current_behavior == start then
            return "failure"
        end
    end
end

function Random:onEditor()
    editorTools.createTreeNode(self.name , function()
        imgui.text( "current_behavior:")
        imgui.sameLine()
        imgui.text( tostring(self.current_behavior) )
        for i = 1, #self.behaviors do
            self.behaviors[i]:onEditor()
        end 
    end)
end

return Random