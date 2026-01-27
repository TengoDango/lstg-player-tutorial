# `player_system.lua` 解析

`player_system.lua` 记录了自机一些系统的具体逻辑。由于内容比较杂，这里就不按代码顺序解析了。

## `player_lib.system` 总览

`player_lib.system`，以下简称 `system`，主要包含：
- 自机回调函数的默认逻辑，
- 事件系统和按键系统的可调用方法。

`system` 是调用 `plus.Class()` 生成的 lua 表，通过引入元表，它在普通的 lua 表的基础上增加了以下特性：
- 可以当作函数进行调用，类似于 python 的创建对象，调用的返回值是一个对象实例 (实质上还是一个 lua 表)：
  - 通过 `system.init` 方法初始化实例；
  - 实例可以通过属性名读取 `system` 的对应属性；
  - 修改实例的属性后，再读取该属性会得到实例的对应属性而非 `system` 的对应属性。也就是说，实例可以定制自己的属性，而不会使得 `system` 受到篡改。

`plus.Class(base)` 与不带参数生成的表的行为有所不同，但是我们篇幅有限就不讨论了。

自机基类 `player_class` 的 `init` 回调会生成一个 `system` 实例，赋值给自机对象的 `_playersys` 属性。这使得我们可以覆盖一些预设的自机行为，当然通常我们做自机不需要考虑这种事情，所以看不懂也没关系......

## 事件系统总览

`THlib/eventListener.lua` 提供了一个事件系统：
- 每个事件由**组名、事件名、优先级、回调函数**构成；
- 触发时执行**一个组**的所有事件，**优先级数值大**的先执行；
- 支持事件的添加、移除和**覆盖更新**。

自机 data 提供了以下类型事件的自动执行：
- key event：每帧根据按键的状态执行对应的事件，根据 “按键+状态” 分组；
- frame event：在 `system:frame()` 中执行的事件，一般用于系统预设的事件；
- frame/render/colli before/after event：在 `system:frame/render/colli()` 前后执行的事件，给写自机的人用的，但是教程不讲所以没什么人用 (讲了也用不上)。

data 预设的事件如下：
- 按键事件 `defaultKeyEvent`：在各个按键**保持按住/保持松开**时触发，维护 `player.__xxx_flag: bool` 的值给其他系统使用，属于 key event。
- 帧逻辑事件 `defaultFrameEvent`：各个自机系统每帧需要执行的事件，统一命名为 `frame.xxx`，属于 frame event。

想要添加、移除、覆盖事件可以用 `system` 提供的 `add/removeXXXEvent` 方法，比如 `player._playersys:addFrameAfterEvent(...)`

## 自机回调

### `system:init(player)`
- 给大部分自机特有的属性设置了默认值；
- 注册自机按键、添加 `defaultKeyEvent` 表中的按键事件；
- 添加 `defaultFrameEvent` 表中的帧逻辑事件；
- 函数参数 `slot` 已废弃，原本用于 2p 角色。

### `system:frame()`
- 更新按键状态；
- 更新追踪的敌人 obj ([`system:findTarget()`](#system-findtarget))；
- 执行所有帧逻辑事件；
- 更新行走图 (如果自机没有被时停)。

### `system:render()`
- 调用行走图系统的渲染方法。

### `system:shoot()` {#system-shoot}
- 调用自机所在类的 `shoot` 方法，对应通常射击。

### `system:spell()` {#system-spell}
- 处理符卡的资源和分数奖励 (`item.PlayerSpell()`)
- bomb 数量减 1；
- 调用自机所在类的 `spell` 方法，对应使用 bomb；
- 死亡计时器 `player.death` 归零 (也就是如果决死成功就不算 miss)；
- 设置自机的 `nextcollect` 属性，但这个属性似乎并没有用处。

### `system:special()` {#system-special}
- 调用自机所在类的 `special` 方法，对应 c 键操作。

### `system:colli(other)` {#system-colli}
- 如果开启了作弊，那么根据 debug data 处理音效、视效并删除子弹；
- 否则，
  - 如果自机已经被弹 (`player.death ~= 0`)，或者自机处于对话状态，那么以下逻辑不会执行；
  - 如果自机不处于无敌 (`player.protect == 0`)，那么播放死亡音效，并将死亡计时器 `player.death` 设为 100，由其他地方处理后续被弹逻辑；
  - 如果 `other` 的碰撞组是 `GROUP_ENEMY_BULLET`，那么删掉 `other`。

## 射击

### `player.fire: 0 ~ 1`
【自动更新，只读】平滑跟随射击键状态，按住射击键为 1，松开为 0。

更新逻辑见 `frame.fire` 事件：
- 如果自机 miss，该属性不会更新；
- 如果按住射击键，且不处于对话状态 (因为对话状态无法射击)，则 `player.fire` 每帧增加 0.16，否则每帧减少 0.16；
- 取值限制在 0 ~ 1。

### `player.dialog: bool`
【可读写】开启该属性将对自机造成以下影响：
- 无法射击、使用 bomb、执行 c 键操作；
- `fire` 属性不会更新；
- 被弹时不会发生任何事 (连消弹都没有)。

### `player.nextshoot,nextspell,nextsp: integer`
【自动更新，可读写】通常射击 / 使用 bomb / c 键操作的冷却倒计时 (单位：帧)。

### `frame.control` 事件
自机射击逻辑的框架。
- 通常射击：若冷却完成 (`nextshoot <= 0`)，且按下射击键 (`__shoot_flag`)，则执行 [`system:shoot()`](#system-shoot) 回调。
- 使用 bomb：若冷却完成 (`nextspell <= 0`)，且按下 bomb 键 (`__spell_flag`)，且 bomb 数量大于 0，则执行 [`system:spell()`](#system-spell) 回调。
- 特殊操作：若冷却完成 (`nextsp <= 0`)，且按下 c 键 (`__special_flag`)，则执行 [`system:special()`](#system-special) 回调。

还有一些额外的判断条件：
- 开启 F3 调试选项 `debug_data.keep_shooting` 可以绕过对射击键状态的判断，从而使自机自动射击；
- 将 `lstg.var.block_spell` 设为 `true` 可以让自机不能使用 bomb；
- `player.dialog` 为 `true` 时，自机不能通常射击、使用 bomb、进行 c 键操作；
- death state 不为 0 时，自机不能通常射击、使用 bomb、进行 c 键操作。

## 子机

### `player.supportx,supporty: number`

【自动更新，只读】平滑跟随自机坐标，线性插值，一般用于子机。

### `player.support: 0 ~ 4`

【自动更新，只读】平滑跟随火力等级 `int(火力值 / 100) in {0,1,2,3,4}`，每帧增/减 0.0625。

### `player.slist: table`

【可读写】子机设定位置表，支持对 0P、1P、...、4P 火力分别设置子机坐标，最多支持 4 个子机，且子机数量不能随火力增大而减少。以下是灵梦自机的 `slist`：

```lua
self.slist = {
    {
        -- 0P 火力的子机位置
    },
    {
        -- 1P 火力的子机位置
        -- { 高速x, 高速y, 低速x, 低速y }
        { 0, 36, 0, 24 },
    },
    {
        -- 2P 火力的子机位置
        { -32, 0, -12, 24 }, -- 子机 1
        { 32,  0, 12,  24 }, -- 子机 2
    },
    {
        -- 3P 火力的子机位置
        { -32, -8,  -16, 20 },
        { 0,   -32, 0,   28 },
        { 32,  -8,  16,  20 },
    },
    {
        -- 4P 火力的子机位置
        { -36, -12, -16, 20 }, -- 子机 1
        { -16, -32, -6,  28 }, -- 子机 2
        { 16,  -32, 6,   28 }, -- 子机 3
        { 36,  -12, 16,  20 }, -- 子机 4
    },
    {
        -- "5P" 火力的子机位置
        { -36, -12, -16, 20 },
        { -16, -32, -6,  28 },
        { 16,  -32, 6,   28 },
        { 36,  -12, 16,  20 },
    },
}
```

默认最高火力为 4P，但 `slist` 却需要设定 5P 的子机位置，这是子机系统实现上的小特性导致的，详见 [`frame.updateSupport` 事件](#update-support)。

### `player.sp: table`

【自动更新，只读】子机实际位置表，根据 `slist` 进行更新。以下是灵梦自机在某一时刻的 `sp` 表内的数据：

```lua
self.sp = {
    -- { x, y, 有效性 0~1 }
    { -36, -12, 1 }, -- 子机 1
    { -16, -32, 1 }, -- 子机 2
    { 16,  -32, 1 }, -- 子机 3
    { 36,  -12, 1 }, -- 子机 4
}
```

### `frame.updateSupport` 事件 {update-support}

根据 `slist` 属性计算 `sp` 属性，从而实现子机位置的更新。

由于风神录系统废弃，我们不用在意 `support == 5` 的分支。

如果自机被时停，或者 `slist` 属性不存在，那么子机位置不会更新。

- 设 `p` 为火力等级 (`int(player.support)`，对应原代码的 `s - 1`)
- 设 `t` 为 `p` 的小数部分。`t` 用于平滑过渡
- 对于每个子机 (编号为 `i`)：
  - (1) 如果在 `slist` 中，火力等级 `p` 子机 `i` 不存在，而火力等级 `p + 1` 子机 `i` 存在：
    - 根据 [`lh`](#player-lh) 属性将火力等级 `p + 1` 的高速位置和低速位置进行插值，得到位置 `{ x, y }`
    - `player.sp[i] = { x, y, t }`
  - (2) 如果火力等级 `p` 和 `p + 1` 的子机 `i` 都存在：
    - 根据 `lh` 属性和 `t` 对火力等级 `p`, `p + 1` 的高速和低速位置 (共 4 个位置) 进行插值，得到位置 `{ x, y }`
    - `player.sp[i] = { x, y, 1 }`

> 注 1：这个子机系统要求当前火力等级为 `p` 时，`slist` 中火力等级 `p + 1` 的信息必须存在，所以即使火力等级不会达到 5，我们仍然需要设置火力等级 5 的子机位置。换言之，`slist` 表的长度应当为 6 (以包含 0, 1, 2, 3, 4, 5 的火力等级)。

> 注 2：考虑火力等级不发生变化的简化情况。若为情况 (1)，则子机不存在，但 `sp` 表中存在对应子机信息 `player.sp[i] = { x, y, 0 }`；若为情况 (2)，则子机存在，`player.sp[i][3] = { x, y, 1 }`。这是我们通过 `player.sp[i][3]` 判断子机有效性的根据。

## 移动

### `player.hspeed,lspeed: number = 4, 2`

【可读写】自机的高速、低速。前缀 `h`,`l` 表示 high 和 low。

### `player.slow: 0 or 1`

【自动更新，只读】是否处于低速，低速为 1，高速为 0。

与 `__slow_flag` 不同的是，
- `slow` 在自机 death state 不为 0 时不会更新 (详见 `frame.updateSlow` 事件)，
- 当 `player.slowlock` 为 `true` 时，`slow` 强制为 1 (详见 `frame.move` 事件)。

### `player.slowlock: bool`

【可读写】为 `true` 时，`slow` 属性强制为 1。

### `player.lh: 0 ~ 1` {#player-lh}

【自动更新，只读】平滑跟随 `player.slow`，每帧增/减 0.5 * 0.3 = 0.15，限制取值范围为 0 ~ 1。

### `player.lock: bool`

【可读写】该属性为 `true` 时，方向键无法控制自机。

值得注意的是，该属性设为 `true` 会影响 [death state](#death-state)，从而导致一些额外的并不直观的后果：
- 自机无法射击、使用 bomb、执行 c 键操作；
- `slow` 和 `fire` 属性不会更新；
- 自机不会吸引新的掉落物。

### `player.time_stop: bool`

【可读写】该属性为 `true` 时，自机系统的若干预设操作不会执行：
- 移动、射击、使用 bomb、执行 c 键操作，
- `timer`, `slow`, `fire` 属性更新，
- 行走图系统的状态更新，
- 子机位置表的位置更新，
- 低速法阵的若干状态更新，
- 吸引新的掉落物。

### `player.__move_dx,__move_dy: number`

【自动更新，只读】当前帧由方向键导致的移动量，详情见 [`frame.move`](#frame-move)。

### `frame.move` 事件 {#frame-move}

记录了方向键改变自机位置的逻辑。自机 data 没有适配手柄操作 (虽然引擎有提供相关的接口)，想写的可以玩玩。
- 根据 `slow` 属性决定移速 (`hspeed` / `lspeed`)
- 根据方向键状态决定移动方向 (8 向 + 不动)
- 计算移速向量 (`dx`,`dy`)
- 自机坐标自增 (`dx`,`dy`)
- 自机坐标限制在 $l+8 \le x \le r-8, b+16 \le y \le t-32$，其中 $l$ 为 `lstg.world.pl = -192`，$r,b,t$ 同理。
- 用 `__move_dx`,`__move_dy` 属性记录 (`dx`,`dy`)
- 如果自机的 death state 不为 0，那么以上逻辑不会执行，`__move_dx`,`__move_dy` 设置为 0。

## 被弹

### `player.death: integer, 0 ~ 100` {#death}

【自动更新，可读写】死亡状态的计时器，倒计时。

自机 data 对 `death` 属性的修改除了每帧减 1 之外，主要还有两个地方：
- 触发碰撞回调时，将 `death` 设为 100，从而开启被弹流程；
- 使用 bomb 时，将 `death` 设为 0，从而中止被弹流程回到普通状态。

我们可以由此为参考实现一些特殊功能，比如自动雷。

### `player.__death_state: integer` (death state) {#death-state}

【自动更新，只读】枚举 death state，主要由死亡计时器 `player.death` 决定。`frame.updateDeathState` 事件描述了该属性如何取值：
| 值 | 情况 |
| :-: | :-- |
| 0 | 未进入 miss 流程 (`player.death == 0 or player.death > 90`)，且未禁止移动 (`not player.lock`) 未被时停 (`not player.time_stop`) |
| 1 | miss 流程第一阶段的起点 (`player.death == 90`) |
| 2 | miss 流程第二阶段的起点 (`player.death == 84`) |
| 3 | miss 流程第三阶段的起点 (`player.death == 50`) |
| 4 | miss 流程第三阶段的中间过程 (`player.death < 50`)，且未禁止移动、未被时停 |
| -1 | 其他情况 (比如 miss 阶段的中途、自机被时停) |

自机 data 一些地方会判断 death state 是否为 0 来决定是否要执行逻辑。我们需要注意 death state 为 0 不只表示自机没有被弹，还蕴含了对 `lock` 和 `time_stop` 属性的判断，所以不要想当然地认为只有被弹会影响这些逻辑的执行 (说到底就是 death state 这个名字它不合适，唉屎山)。

### `player.protect: integer`

【自动更新，可读写】自机剩余无敌时间 (单位：帧)。在 [`system:colli`](#system-colli)、行走图系统以及各自机的 `spell` 回调中用到。

### `frame.death1` 事件

death state 为 1 时执行逻辑，对应 miss 流程第一阶段的起点。
- 如果自机被时停，则 `death` 属性减 1 (非常困惑，时停又不影响 `death` 更新，这段代码就只是让 `death` 计时器多走了一帧)
- `item.PlayerMiss(player)`：处理符卡奖励和残机等游戏资源的变化
- `death_weapon`：对所有敌人造成一点点伤害
- `deatheff`：渲染反色圈
- `player_death_ef`：渲染粒子效果

### `frame.death2` 事件

death state 为 2 时执行逻辑，对应 miss 流程第二阶段的起点。
- 依然困惑的 `death` 属性减 1
- `hide` 属性设为 `true`，即关掉自机的渲染

### `frame.death3` 事件

death state 为 3 时执行逻辑，对应 miss 第三阶段的起点。
- 依然困惑的 `death` 属性减 1
- 自机坐标 `x`,`y` 以及子机基准坐标 `supportx`,`supporty` 设为 (0, -236)

### `frame.death4` 事件

death state 为 4 时执行逻辑，对应 miss 第三阶段的中间过程。
- 自机 y 坐标从大约 -250 匀速移动到 -192 (有 1 帧的瞬移吗，唉也行吧)

## 掉落物收集

### `frame.itemCollect` 事件
处理掉落物收集的逻辑。有一些多自机系统的残留成分，以下只考虑单自机的行为。
- 如果 death state 不为 0，以下逻辑不会执行；
- 如果自机坐标高于收集线 (`player.collect_line`)，则以最大速度 (速度 8) 收集所有掉落物；
- 否则收集自机附近一定距离的掉落物 (速度 3)。高速时收集半径为 24，低速为 48。

### `player.collect_line: number = 96`

收集线高度。

## 按键 // TODO

感觉没什么能用到的内容，以后再写吧

## 杂项

### `player.imgs: table`

自机的行走图。通常是一个 24 张图片的列表。前 8 张为静止，中间 8 张为左移动作，后 8 张为右移动作。

详情见 [`PlayerWalkImageSystem`解析](../dataer/wisys)。

### `player.A,B: number`

自机的判定大小。不使用 `a`,`b` 是因为行走图系统更换贴图时会自动把 `a`,`b` 修改为贴图的判定大小。行走图系统需要用 `A`,`B` 属性把自机判定纠正回来。

详情见 [`PlayerWalkImageSystem`解析](../dataer/wisys)。

### `system:findTarget()` {#system-findtarget}
- 如果自机当前的追踪目标 `player.target` “无效”，调用 [`player_class.findtarget`](../dataer/player#playerclass-findtarget) 更新追踪目标；
- 如果没有按下射击键，那么 `player.target` 设置为 `nil`。

这里的 “无效” 目标指 `not IsValid` 或没有开启碰撞。
