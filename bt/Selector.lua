--[[
选择器是一个复合节点，它按顺序执行其中的每个子节点，但是，与序列不同，
如果其子节点中的任何一个子节点成功，则成功
并且只有在所有子节点失败时才会失败。
每当一个节点出现故障时，它就会转到下一个节点并尝试它，如果失败了，它会继续下一个节点，直到成功或返回running。
与序列类似，running也会使选择器返回到下一帧的运行节点。
逻辑与序列几乎相同，只是颠倒过来。
]]
local Selector = class("Sequence" , import(".Behavior"))

function Selector:ctor(name, behaviors)
    Selector.super.ctor(self)
    self.name = name
    self.behaviors = behaviors 
    self.current_behavior = 1
end

function Selector:run(dt, context)
    while true do
        local status = self.behaviors[self.current_behavior]:update(dt, context)
        if status ~= 'failure' then return status end
        self.current_behavior = self.current_behavior + 1
        if self.current_behavior == #self.behaviors + 1 then return 'failure' end
    end
end

function Selector:fixUpdate(dt, context)
    for i = 1, #self.behaviors do
        self.behaviors[i]:fixUpdate(dt, context)
    end
end

function Selector:start(context)
    self.current_behavior = 1
end

function Selector:finish(status, context)

end

function Selector:onEditor()
    editorTools.createTreeNode(self.name , function()
        imgui.text( "current_behavior:")
        imgui.sameLine()
        imgui.text( tostring(self.current_behavior) )
        for i = 1, #self.behaviors do
            self.behaviors[i]:onEditor()
        end 
    end)
end

return Selector