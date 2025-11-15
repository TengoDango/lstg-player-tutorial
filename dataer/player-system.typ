#import "/include.typ": *

#show: book-page

= `player_system.lua` 解析

== `player_lib`

起到一个命名空间的作用, 纯粹就是含有一些自机组件的一个table.

== `defaultKeyEvent`

一个table, 记录了按键按下/松开对应的事件.
一个 "事件" 主要由触发条件和回调函数构成,
在满足它的触发条件时由系统自动执行对应的回调函数.
我们后面会看到这个体系是如何工作的.

语法上不用想太多, 就是一个用字符串索引的table.

里面的`__xxx_flag`不建议读取,
- 一方面, 下划线开头是一种命名约定,
  表示这个变量是私有的 (虽然弹幕制作有用到一些这类本该私有的变量);
- 另一方面, 后面会有更好用的变量可供使用.

总之形如 `self.__xxx_flag` 的属性表示按键按下
(true) 或松开 (false) 的状态, 别的没什么好说的.

== `defaultFrameEvent`

一个table, 记录了自机每帧需要执行的一些事件.
这些事件涉及自机各个系统的具体实现方法,
值得精读.

语法上不用想太多, 就是一个用字符串索引的table.

=== `["frame.updateDeathState"]`

根据 `self.death` ($0 <= dot <= 100$ 的整数)
将自机的死亡过程划分为几个阶段.

`/*TODO*/`

=== `["frame.updateSlow"]`

当自机没有被弹时 (`self.__death_state == 0`),
根据shift键的状态 (`self.__slow_flag`)
将 `self.slow` 设置为 0 / 1, 1 表示低速.

顺便一提, 当 `self.slowlock` 为真时,
自机会强制处于低速状态, 具体实现逻辑见
#cross-ref("dataer/player-system.typ", reference: [=== `["frame.move"]`])[`["frame.move"]`]

=== `["frame.control"]`

调用自机系统的 `shoot, spell, special` 函数,
从而实现自机的射击行为.
- 当按下射击键, 且完成冷却 (`self.nextshoot` 减到0以下) 时,
  执行一次`shoot`函数, 发射一次子弹.
- 放b和特殊操作 (c键) 同理, 对应的冷却时间为
  `self.nextspell, self.nextsp`.
- 特殊条件: `player_lib.debug_data.keep_shooting`
  对应调试功能: 保持射击.
  在游戏界面按 `F3` 可以找到对应开关.
  #image("/assets/images/player-system-1.png", width: 50%)
- 特殊条件: `lstg.var.bomb` 对应bomb数量,
  没有bomb时不会触发`spell`函数.
- 特殊条件: `lstg.var.block_spell` 为真时不会触发
  `spell`函数, 当你有需求时可以设置这个变量.
- 特殊条件: `self.dialog` 表示是否正在与boss对话,
  为真时`shoot, spell, special` 函数不会触发,
  从而自机无法射击, 放b 以及执行c键操作.
  在对话状态结束后的 15/30 帧内,
  自机无法 射击/放b.

=== `["frame.move"]`



// == `player_lib.system`

// 记录了自机回调函数具体逻辑的table.
// `plus.Class()`并不是我们通常使用的`Class`,
// 而只是在基础table的基础上加了元表来支持一些语法特性.
// 现阶段当成是普通的table就行.

// 以下简写为 `system`.
