local BT = require("app.bt.BT")
local upgradeHero = class("upgradeHero" , BT.Action)

function upgradeHero:ctor(args)
    upgradeHero.super.ctor(self , "upgradeHero")
    self.args = args
    self.curHeroIndex = 0
    self.curLineCnt = 0
end

function upgradeHero:fixUpdate(dt , context)
    upgradeHero.super.fixUpdate(self, dt , context)
    if #self.args.heros > 0 and context.totalLine and context.totalLine > 0 then
        if self.curLineCnt + self.args.lineCnt <= context.totalLine then
            self.curLineCnt = self.curLineCnt + self.args.lineCnt
            self:after(1 , function()
                local heroInfo = self.args.heros[(self.curHeroIndex % #self.args.heros) + 1]
                self.curHeroIndex = self.curHeroIndex + 1
                for i = 1, heroInfo[2] or 1 do
                    table.insert(context.heroQueue , { id = heroInfo[1] , isAuto = true })
                end
            end)
        end
    end
end

return upgradeHero
