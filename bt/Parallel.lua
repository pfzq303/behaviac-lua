local Parallel = class("Parallel" , import(".Behavior"))

function Parallel:ctor(name, success_policy, failure_policy, behaviors)
    Parallel.super.ctor(self)
    self.name = name
    self.success_policy = success_policy
    self.failure_policy = failure_policy
    self.behaviors = behaviors
end

function Parallel:fixUpdate(dt , context)
    for i = 1, #self.behaviors do
        self.behaviors[i]:fixUpdate(dt, context)
    end
end

function Parallel:run(dt, context)
    local success_count, failure_count = 0, 0 
    for _, behavior in ipairs(self.behaviors) do
        local status = nil
        status = behavior:update(dt, context)

        if status == 'success' then
            success_count = success_count + 1
            -- Got one success and the success policy only requires one, so succeed
            -- same for failure in the next if statement.
            if self.success_policy == 'one' then return 'success' end
        end

        if status == 'failure' then
            failure_count = failure_count + 1
            if self.failure_policy == 'one' then return 'failure' end
        end
    end

    -- Has been through all behaviors, the failure/success policy is 'all' 
    -- and the number ofbehaviors matches the failure/success count? 
    -- Then fail/succeed!
    if self.failure_policy == 'all' and failure_count == #self.behaviors then 
        return 'failure' 
    end
    if self.success_policy == 'all' and success_count == #self.behaviors then 
        return 'success' 
    end
    return 'running'
end

function Parallel:finish(status, context)
    -- If the parallel node is done, finish all currently running behaviors so that 
    -- the next time the node is run it starts over instead of continuing 
    -- the previous run.
    for _, behavior in ipairs(self.behaviors) do
        if behavior.status == 'running' then
            behavior:finish(status, context)
        end
    end
end

function Parallel:onEditor()
    editorTools.createTreeNode(self.name , function()
        for i = 1, #self.behaviors do
            self.behaviors[i]:onEditor()
        end 
    end)
end

return Parallel