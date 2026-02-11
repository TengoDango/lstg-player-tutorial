---自动雷

ExtraPlayer = Class(player_class)

function ExtraPlayer:init()
    player_class.init(self)
    self.imgs = {}
    for i = 1, 24 do self.imgs[i] = 'white' end
end

function ExtraPlayer:frame()
    player_class.frame(self)
    -- 默认 data 中, death 属性在 90~100 为决死窗口
    if self.death > 95 then
        -- 这里是抄的data的bomb释放逻辑
        -- 假设自动雷要消耗两个bomb
        if self.__death_state == 0 and not self.dialog and self.nextspell <= 0 and lstg.var.bomb >= 2 and not lstg.var.block_spell then
            item.PlayerSpell()
            lstg.var.bomb = lstg.var.bomb - 2
            ExtraPlayer.spell(self)
            self.death = 0
        end
    end
end

function ExtraPlayer:spell()
    self.collect_line = self.collect_line - 500
    New(tasker, function()
        task.Wait(90)
        self.collect_line = self.collect_line + 500
    end)
    self.nextspell = 120
    self.protect = 120
    New(bullet_killer, self.x, self.y)
end
