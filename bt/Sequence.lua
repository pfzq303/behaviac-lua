--[[
一个序列是一个复合节点（它可以有多个孩子），它按顺序执行每个孩子。
如果一个孩子失败了，那么整个顺序就失败了，
但是如果一个孩子成功了，那么顺序就移到下一个。
如果所有孩子都成功了，那么顺序就成功了。
如果一个孩子仍然在运行，那么这个序列也会返回运行，并且在下一个帧中它将返回到该运行的节点。
]]
local Sequence = class("Sequence" , import(".Behavior"))

function Sequence:ctor(name, behaviors)
    Sequence.super.ctor(self)
    self.name = name
    self.behaviors = behaviors
    self.current_behavior = 1
end

function Sequence:fixUpdate(dt, context)
    for i = 1, #self.behaviors do
        self.behaviors[i]:fixUpdate(dt, context)
    end
end

function Sequence:run(dt, context)
    while true do
        local status = self.behaviors[self.current_behavior]:update(dt, context)
        if status ~= 'success' then return status end
        self.current_behavior = self.current_behavior + 1
        if self.current_behavior == #self.behaviors + 1 then return 'success' end
    end
end

function Sequence:start(context)
    self.current_behavior = 1
end

function Sequence:finish(status, context)
    
end

function Sequence:onEditor()
    editorTools.createTreeNode(self.name , function()
        imgui.text( "current_behavior:")
        imgui.sameLine()
        imgui.text( tostring(self.current_behavior) )
        for i = 1, #self.behaviors do
            self.behaviors[i]:onEditor()
        end 
    end)
end

return Sequence