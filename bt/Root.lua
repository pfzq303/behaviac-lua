--[[
根节点是所有行为树中最顶端的节点，
因为我们需要在某个地方存储树状数据，
比如上下文
]]
local Root = class("Root" , import(".Behavior"))

function Root:ctor(object, behavior , customContext)
    Root.super.ctor(self)
    self.behavior = behavior
    self.object = object
    self.context = customContext or {}
    self.context.object = self.object
end

function Root:fixUpdate(dt)
    self.behavior:fixUpdate(dt , self.context)
end

function Root:update(dt)
    Root.super.update(self, dt)
    self:fixUpdate(dt)
end

function Root:run(dt)
    return self.behavior:update(dt, self.context)
end

function Root:finish(status)

end

function Root:onEditor()
    editorTools.createTreeNode("BTRoot" , function()
        editorTools.showDataInfo(self.context)
        self.behavior:onEditor()
    end)
end

return Root