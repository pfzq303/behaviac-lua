local ActiveSelector = class("ActiveSelector" , import(".Behavior"))

function ActiveSelector:ctor(name, behaviors)
    ActiveSelector.super.ctor(self)
    self.name = name
    self.behaviors = behaviors
end

function ActiveSelector:run(dt, context)
    -- Logic is exactly the same as a normal selector, except instead 
    -- of keeping track of which behavior we're in by using current_behavior, 
    -- we just don't do it at all and go through them all every frame.
    for _, behavior in ipairs(self.behaviors) do
        local status = behavior:update(dt, context)
        if status ~= 'failure' then return status end
    end
    return 'failure'
end

function ActiveSelector:fixUpdate(dt, context)
    for i = 1, #self.behaviors do
        self.behaviors[i]:fixUpdate(dt, context)
    end
end

function ActiveSelector:onEditor()
    editorTools.createTreeNode(self.name , function()
        for i = 1, #self.behaviors do
            self.behaviors[i]:onEditor()
        end 
    end)
end

return ActiveSelector