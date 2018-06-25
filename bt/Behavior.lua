--[[
行为树被用来以直观的方式描述游戏中实体的行为.
一棵树由节点组成（像普通树数据结构一样）;
节点可以运行一些操作，然后将该操作的状态返回给它的父节点;
通常使用三种状态：成功，失败和跑步。
行为树成为处理人工智能的有吸引力的选择。多帧的失败和动作是AI编码带来的某种痛苦，通常退化成一堆ifs或巨大的开关或其他一些不那么干净的结构。
将所有复杂性卸载到行为树（基本上在结构中执行所有这些ifs），并使其在一个安全的环境中编码，并且界面非常清晰（成功，失败，正在运行），这使得一切都变得更加简单。
最重要的是，行为和子树的可组合性使得重用代码变得更加容易，尽管我没有太久使用BT来查看自己是否真实，但它看起来完全如此。

function Entity:new(...)
    ...
    self.behavior_tree = Root.new(self, moveToPoint.new())
end

function Entity:update(dt)
    self.behavior_tree:update(dt)
end

]]
local Behavior = class("Behavior")

function Behavior:ctor()
    self.status = 'invalid'
end

function Behavior:update(dt, context)
    if self.status ~= 'running' then self:start(context) end
    self.status = self:run(dt, context)
    if self.status ~= 'running' then self:finish(self.status, context) end
    return self.status 
end

--强制更新整棵树的状态
function Behavior:fixUpdate(dt, context)
    
end

function Behavior:start(context)
    
end

function Behavior:run(dt , context)
    return "success"
end

function Behavior:finish(status , context)
    
end

function Behavior:onEditor()

end

return Behavior