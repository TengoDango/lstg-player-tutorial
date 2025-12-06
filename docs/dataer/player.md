# [`player.lua`](../appendix/player-lua) 解析

`player.lua` 主要记录了自机的基类和一些与自机有关的类。

## `player_lib`

起到一个命名空间的作用，语法上就是一个很普通的全局表。

## `player_class`

这是自机的基类，原则上所有的自机类都需要继承它 (也就是每个自机定义都会有的 `xxx_player = Class(player_class)`)。

当一个自机类继承 `player_class` 时，它会自动获得 `player_class` 的 `init`, `frame`, `render`, `colli`, `kill`, `del` 六个回调函数，从而自动执行 `player_class` 中记录的行为。

`player_class` 里记录了怎样的自机行为呢？要了解这一点，我们需要看 `player_class` 的 `init`, `frame`, `render`, `colli` 回调。

你可能会疑惑怎么没有 `kill`, `del` 回调？自机在这里是非常特殊的：

一般的 obj 在碰撞时通过 `Kill` 或 `Del` 函数删掉自己，这会相应地触发 obj 的 `kill` 或 `del` 回调。而自机在碰撞时进行了特殊的处理，不调用 `Kill`, `Del` 而是单独实现了一套逻辑来实现 miss 的流程。所以 data 不需要重写 `player_class` 的 `kill`, `del` 回调。

data 重写的四个回调写的很短，主要就是对 `player_lib.system` 的调用，详细的逻辑见 [`player_system.lua 解析`](./player-system)。

### `player_class:init()`

在 `init` 回调中，我们看到自机对象有 `_wisys`, `_playersys` 两个属性，对应自机的行走图系统和其他系统。这使得我们可以在不修改 data 的情况下覆盖自机的一些预设行为。

比如，如果你有一套自机行走图系统，那么可以把 `_wisys` 属性设为你的行走图系统。又比如你想把收点线换成自动收点，那么可以把 `_playersys` 里的对应逻辑换掉。
这不会导致 data 预设的自机系统改变。

### `player_class:findtarget()`

这个函数用于给自机寻找一个要追踪的敌人。话虽如此，你也可以把它用到其他 obj (比如自机的追踪弹)。

它的追踪逻辑是这样的：对于一次 `player_class.findtarget(obj)` 调用，

1. 遍历所有开启碰撞 (`colli` 属性为真) 的敌人 (`GROUP_ENEMY`, `GROUP_NONTJT` 两个碰撞组)，
2. 比较敌人与 `obj` 连线斜率的绝对值大小，选择绝对值最大的敌人，
3. 将敌人 obj 赋值给 `obj.target`。

也就是说，`obj` 正上方和正下方的优先级是最高的，越靠左 / 右，优先级越低。

## `MixTable(x, t1, t2)`

“子机位置表的线性插值”，注释如是写道。具体逻辑见 [`TODO`](./player-system)

## `grazer`

负责自机擦弹圈的判定和低速 aura 的渲染，好像没什么能讲的。

值得注意的是 `grazer` 的碰撞组是 `GROUP_PLAYER`，某些特殊需求可能会用到。

## `death_weapon`

负责在自机 miss 时对敌人造成反伤，在自机 miss 时自动生成一个。

它的判定是手写的，从第 60 帧开始，对半径 800 范围内的开启碰撞的每个敌人造成 (30 帧 $\times$ 0.75 帧/秒) 的伤害。

## `player_bullet_straight` {#straight}

直线自机子弹的模板，展示了一个自机子弹需要配置的基本属性。除了所有对象共有的属性之外，还有 `dmg` 属性 (damage, 伤害)。

注意它的 `init()` 参数中没有判定大小 `a,b`，它的判定大小是由加载贴图时设置的判定大小确定的。如果你的子弹判定大小与贴图设置的判定不同，需要在设置 `img` 属性之后再设置 `a,b` 属性。

## `player_bullet_hide`

隐形的直线自机子弹，在 `delay` 帧后开启判定。如果需要一开始就开启判定，可以不传入 `delay` 参数，或者传入0。

函数内容有一句 `self.delay = delay or 0`，这是有默认值的变量的常见写法。
这样在不传入 `delay` 参数时 (此时 `delay` 的值为 `nil`)，`self.delay` 会设置为0。

## `player_bullet_trail`

诱导弹的模板，在灵梦机体中被用到。它的目标 obj 在 init 回调传入，之后不再改变。

它的追踪原理写的比较难懂，代码翻译如下：

设子弹当前位置为 $S$，目标位置为 $T$，子弹朝向 `self.rot` = $\theta$，传入参数 `trail` = $t$.

子弹的速度大小不变，运动方向和贴图朝向一致。当目标存在且开启碰撞时，子弹的朝向发生改变：

$$
  \begin{align*}
    \theta_{ST} & := \text{Angle}(S,T), \\
    \Delta\theta & := (\theta_{ST} - \theta) \bmod 360\degree \\
    & (-180\degree \lt \Delta\theta \le 180\degree), \\
    \omega & := \dfrac{t \cdot 1\degree}{|ST| + 1}, \\
    \theta' & := \begin{cases}
      \theta_{ST} & \text{若 } |\Delta\theta| \le \omega, \\
      \theta + \omega \cdot \text{sign}(\Delta\theta) & \text{若 } |\Delta\theta| > \omega.
    \end{cases}
  \end{align*}
$$

$\theta'$ 为更新后的子弹朝向。

追踪的过程简单来说是子弹的朝向以一个动态的角速度 $\omega$ 告诉与敌人连线的方向，当朝向足够接近 (差值小于 $\omega$) 时直接设置为连线方向，以防止朝向抖动。子弹与敌人越近，角速度 $\omega$ 越大。

## `player_spell_mask`

自机 bomb 的遮罩特效。

`r,g,b` 参数表示整体颜色。

$0 \to t_1$ 时间段, 不透明度从0过渡到255；$t_1 \to t_1+t_2$ 时间段，不透明度不变；$t_1+t_2 \to t_1+t_2+t_3$ 时间段，不透明度从255过渡到0。

## `player_death_ef, deatheff`

负责自机死亡特效的渲染，好像也没有能讲的东西。

看到变量名有 `ef` 或 `eff` (effect 的缩写)，基本就说明这个类是负责特效的。

## `AddPlayerToPlayerList(...)`

其他几个自机加载的函数不用看，都没有实际用到。

`AddPlayerToPlayerList` 负责将自机信息添加到一个全局表。所谓的自机信息，就是三个字符串，含义在函数注释中已经说的很清楚了。

值得注意的是 `classname`，它对应我们定义的自机类的变量名。这就要求我们的自机类必须是全局变量。这涉及全局变量的原理。

在 lua 中，全局变量被保存在名为 `_G` 的表中，以变量名为索引可以获取对应的全局变量。比如我们可以通过 `_G["lstg"]` 读取全局变量 `lstg`。

对于自机也是这样。在**进入关卡**时，data 会根据变量名查找全局的自机类，从而生成对应的自机对象。

这意味着，我们对 `AddPlayerToPlayerList` 的调用位置其实是比较随意的。自带自机把调用写在自机文件最后面，我们也可以把调用写在定义自机类之后，甚至写在定义自机类之前也不会影响运行。

