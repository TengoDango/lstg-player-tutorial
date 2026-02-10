# 自动雷

我们来搓一个自动雷。自动雷的机制是这样的：自机中弹时，自动使用 bomb，并取消本次中弹流程。那么主要的问题就是怎样去检测与改变自机的中弹流程。

自机系统对中弹流程是怎样管理的呢？详细可以看[`player-system.lua`解析](../dataer/player-system#miss)，这里我们就简单地概括一下。

自机对象有一个属性 `self.death`，是对死亡状态的计数器。在正常状态下，这个计数器取值为 0；中弹时，这个计数器被设置为 100，而后每帧减一，减到 0 为止。

系统会根据 `self.death` 确定当前被弹流程进行到哪一阶段，并执行该阶段的对应行为。具体地，`self.death == 0` 是没有中弹，`self.death > 90` 是中弹但处于决死期间，其他情况则是不可 (不应当) 挽回的 miss 流程。

我们也可以自己每帧检测 `self.death` 的值，检测到正在决死时，手动调用自机的 spell 回调来使用 bomb。

触发自动雷的具体条件有多种选择：
- 可以在刚进入决死阶段时就触发，用 `self.death == 100` 或者 `self.death > 90` 等写法来判断
- 可以在决死即将结束时触发，用 `self.death == 91` 或者 `self.death > 90 and self.death <= 95` 等写法来判断
- 或者按你自己的想法来

在触发自动雷之后，就要编写自动雷的具体行为。这里我们让自动雷和正常使用 bomb 基本相同，只是自动雷需要消耗两个 bomb。

按照 data 使用 bomb 的逻辑，我们首先检测能否使用 bomb，需要以下条件都满足：

- `self.__death_state == 0`：简单来说，自机可以撤消中弹状态。具体含义见 [death state](../dataer/player-system#death-state)
- `not self.dialog`：自机不处于[对话状态](../dataer/player-system#dialog)
- `self.nextspell <= 0`：bomb 已经冷却完毕
- `lstg.var.bomb >= 2`：bomb 数量足够
- `not lstg.var.block_spell`：一个刻意设置的阻断条件

满足使用 bomb 的条件后，就按照 data 的逻辑使用 bomb：

- `item.PlayerSpell()`：符卡奖励相关行为
- `lstg.var.bomb = lstg.var.bomb - 2`：bomb 数量减 2
- `ExtraPlayer.spell(self)`：执行该自机类的 spell 回调
- `self.death = 0`：死亡计数器归零，从而撤消死亡状态

这样就实现了自动雷的机制。代码如下：

```lua
function ExtraPlayer:frame()
    player_class.frame(self)

    if self.death == 91 then
        local is_auto_bomb_valid =
            self.__death_state == 0
            and not self.dialog
            and self.nextspell <= 0
            and lstg.var.bomb >= 2
            and not lstg.var.block_spell
        if is_auto_bomb_valid then
            item.PlayerSpell()
            lstg.var.bomb = lstg.var.bomb - 2
            ExtraPlayer.spell(self)
            self.death = 0
        end
    end
end
```

完整代码见[自机代码下载](../mainline/appendix)。
