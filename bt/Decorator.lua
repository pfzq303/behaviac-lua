--[[
装饰器是一个节点，只能有一个孩子，并执行一些逻辑来更改从单个孩子返回的结果。
]]
local Decorator = class("Decorator" , import(".Behavior"))

function Decorator:ctor(name, behavior)
    Decorator.super.ctor(self)
    self.name = name
    self.behavior = behavior
end

--强制更新整棵树的状态
function Decorator:fixUpdate(dt, context)
    self.behavior:fixUpdate(dt , context)
end

function Decorator:run(dt, context)
    return self.behavior:update(dt, context)
end

function Decorator:onEditor()
    editorTools.createTreeNode(self.name, function()
        editorTools.showDataInfo(self)
        self.behavior:onEditor()
    end)
end

return Decorator