local HeroBTFactory = class("HeroBTFactory")
local HeroAction = require("app.guide.behavior.HeroAction")
local HeroTreeConfig = _C("npc_tree_config")
local HeroTreeInfoConfig = _C("npc_behavior_info_config")
local Root = require("app.bt.Root")
local create_index = 0

local function getIndex()
    create_index = create_index + 1
    return create_index
end

local KeyMap = {
	RANDOM = { 
        -- args == 列表
        ctor = function(key , args , text)
            local list = {}
            for _ , v in ipairs(args) do
                table.insert(list , HeroBTFactory.createTreeItem(v))
            end
            return require("app.bt.Random").new("RANDOM_" .. getIndex() , list)
        end 
    },
    WEIGHT_WRAP = { 
        -- { 权重, id }
        ctor = function(key , args , text)
            return require("app.bt.WeightWrap").new(key .. "_" .. getIndex(), args[1] , HeroBTFactory.createTreeItem( args[2] ))
        end 
    },
	RANDOM_WEIGHT = { 
        -- args == 列表（带权重）
        ctor = function(key , args, text)
            local list = {}
            for _ , v in ipairs(args) do
                table.insert(list , HeroBTFactory.createByKey("WEIGHT_WRAP" , v))
            end
            return require("app.bt.Random").new("RANDOM_WEIGHT_" .. getIndex() , list)
        end 
    },
	SEQUENCE = {
        -- args == 列表
        ctor = function(key , args, text)
            local list = {}
            for _ , v in ipairs(args) do
                table.insert(list , HeroBTFactory.createTreeItem(v))
            end
            return require("app.bt.Sequence").new("SEQUENCE_" .. getIndex() , list)
        end 
    },
	DELAY = {
        -- min , max
        ctor = function(key , args, text)
            return require("app.bt.Wait").new(args.min , args.max)
        end 
    },
	SELECT = {
        -- args == 列表
        ctor = function(args, text)
            local list = {}
            for _ , v in ipairs(args) do
                table.insert(list , HeroBTFactory.createTreeItem(v))
            end
            return require("app.bt.ActiveSelector").new("SELECT_" .. getIndex() , list)
        end 
    },
	PARALLEL = { 
        -- args == 列表
        ctor = function(key , args, text)
            local list = {}
            for _ , v in ipairs(args) do
                table.insert(list , HeroBTFactory.createTreeItem(v))
            end
            return require("app.bt.Parallel").new("PARALLEL_" .. getIndex() , "all" , "all", list)
        end 
    },

	REPEAT_TRUE = { 
        -- args == id
        ctor = function(key , args , text)
            return require("app.bt.RepeatUntilFail").new(HeroBTFactory.createTreeItem( args ))
        end 
    },

	REPEAT_NUM = { 
        ctor = function(key , args , text)
            -- num , id
            return require("app.bt.RepeatUntilFail").new(args.num , HeroBTFactory.createTreeItem( args.id ))
        end 
    },

	WAIT_UNTIL = { 
        ctor = function(key , args , text)
            -- ConditionName , args 
            return require("app.bt.WaitUntil").new(HeroBTFactory.createTreeItem( args ))
        end 
    },

	RUN_ONCE = { 
        ctor = function(key , args , text)
            return require("app.bt.RunOnce").new( key .. "_" .. getIndex() , HeroBTFactory.createTreeItem( args ))
        end 
    },

	CONDITION = { 
        ctor = function(key , args , text)
            -- ConditionName , args 
            return require("app.guide.behavior.RunGuideCondition").new(key .. "_" .. getIndex() , args)
        end 
    },

    TREE = {
        ctor = function(key , args , text)
            -- args == id
            return HeroBTFactory.createTree(args)
        end 
    },

    DEFAULT = {
        ctor = function(key , args , text)
            if HeroAction[key] then
                return HeroAction[key].new(args, text)
            end
        end
    }
}

function HeroBTFactory.createByKey(key , args , text)
    key = string.trim( string.upper(key) )
    local info = KeyMap[key]
    if info then
        return info.ctor(key , args , text)
    else
        return KeyMap.DEFAULT.ctor(key , args , text)
    end
end


function HeroBTFactory.createTree(id)
	local cfg = HeroTreeConfig[id]
    if cfg then
        return HeroBTFactory.createByKey(cfg.RunType , cfg.Args)
    end
end

function HeroBTFactory.createTreeItem(id)
	local cfg = HeroTreeInfoConfig[id]
    if cfg then
        return HeroBTFactory.createByKey(cfg.RunType , cfg.Args , cfg.Text)
    end
end

function HeroBTFactory.createBTNodeWithHero(hero , id)
    return Root.new( hero , HeroBTFactory.createTree(id) )
end

return HeroBTFactory