# 手写子机系统

这一期我们将参考 LuaSTG 自带的子机系统实现方法，自己编写一套子机系统，实现地灵殿魔A的8个子机。

<img src="../assets/images/8-supports.png" style="margin: 0 auto;">

## 总览

大体上，子机的位置由自机的火力和高低速状态决定。于是自带的子机系统用 `self.slist` 属性记录各个 (子机编号, 火力等级, 高速/低速) 对应的子机坐标。由于火力等级和高低速状态会发生变化，而我们不想看到子机瞬移，所以自带的子机系统引入**线性插值**来计算火力等级和高低速发生变化时的平滑过渡状态，就得到了 `self.sp` 的每帧更新逻辑。

另一方面，我们希望子机跟随自机移动时，不是生硬地随自机平移，而是要有一点 "惯性" 或者说 "滞后"，于是自带子机系统设置了 `self.supportx`、`self.supporty` 属性，利用**线性插值**让它们带惯性地跟随 `self.x`、`self.y`。

这两个线性插值虽然叫法一样，代码写出来也差不多，但它们所实现的变量随时间的变化趋势有很大区别，希望读者能体会到其背后的原理。

## 子机信息表

假如我们正在实现一套非常简单的子机，固定有4个子机且高速/低速坐标相同，那么我们完全可以不用子机系统，而是用原始的方法，直接计算子机的坐标，比如这样：

```lua
function reimu_player:render()
    Render("reimu_support", self.x - 36, self.y - 12)
    Render("reimu_support", self.x - 16, self.y - 32)
    Render("reimu_support", self.x + 16, self.y - 32)
    Render("reimu_support", self.x + 36, self.y - 12)
	player_class.render(self)
end
```

但是当情况变得更加复杂，比如需要更多的子机、需要高低速有不同的坐标、需要不同火力有不同的坐标，等等，那么我们用原始的方法硬写就会非常的坐牢。所以我们一般会用一个子机信息表存储不同子机位置的不同参数。

比如自带子机系统的 `self.slist`，用来记录不同火力等级、不同子机编号、高速/低速状态的子机坐标 (相对于自机的)；我们制作[环绕子机](./orbiting-supports)时会记录子机相对自机的极坐标 (不考虑自转的)；在复刻魔理沙自机时，除了子机坐标之外，还可以记录各个激光的朝向；如果火力对子机没有影响，还可以不管火力只记录高速/低速下的子机信息......

如果我们不需要搞平滑过渡，那么只用这样一个子机信息表就可以实现子机系统了。比如我们考虑只用 `self.slist` 渲染自带灵梦的子机：

```lua
function reimu_player:render()
	for i = 1, 4 do
		local power = int(lstg.var.power / 100) + 1
        local info = self.slist[power][i]
		if info then
			if self.slow == 0 then
				-- 高速
				Render('reimu_support', self.x + info[1], self.y + info[2])
			else
				-- 低速
				Render('reimu_support', self.x + info[3], self.y + info[4])
			end
		end
	end
	player_class.render(self)
end
```

我们现在要写的自机，有8个子机，且同时受到火力等级和高低速状态的影响，那么我们就仿照 `self.slist` 写一个子机信息表 `self.spinfo.list`：

```lua
self.spinfo = {
    ---子机信息表
    list = {},
    ---最大子机数量
    num = 8,
}
-- 地灵殿魔A的子机位置
local slist = self.spinfo.list
for power = 0, 8 do
    local data = {}
    local da = 180 / 7
    local spread = da * (power - 1) / 2
    for i = 1, power do
        data[i] = {
            32 * cos(-90 - spread + da * (i - 1)),
            32 * sin(-90 - spread + da * (i - 1)),
            32 * cos(-90 + spread - da * (i - 1)),
            32 * sin(-90 + spread - da * (i - 1)),
        }
    end
    slist[power + 1] = data
end
```

有了这个子机信息表，我们可以方便地获取指定子机在指定火力等级和高低速状态下的子机相对坐标。如果不考虑平滑过渡，我们就不需要其他的东西了，直接渲染子机和根据子机位置发弹并不困难，这里不做赘述。

## 平滑过渡

我们考虑三个方面的平滑过渡：高速/低速切换、火力等级改变、滞后跟随自机。

实现平滑过渡的核心思想是设置一个过渡值，让过渡值发生变化，根据过渡值去更新其他变量。比如，要让一个 obj 从一个位置匀速移动到另一个位置，那么我们会设置一个过渡值，在一段时间内从 0 匀速变为 1，然后根据该过渡值以及起点终点去计算某一时刻 obj 的位置。不同的平滑过渡需求会有不同的过渡值设置。

我们先添加一些属性：

```lua
self.spinfo = {
    ---子机信息表
    list = {},
    ---最大子机数量
    num = 8,

    ---数组部分: 实时更新子机信息
    { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 },
    ---平滑跟随火力等级 (0~8P)
    power = int(lstg.var.power / 50),
    ---平滑跟随高低速状态 (0~1)
    slow = 0,
    ---平滑跟随自机坐标
    x = self.x,
    y = self.y,
    ---各子机的有效性 (0~1)
    valid = {},
}
```

## 过渡一、高速/低速切换

高速/低速切换是一种简单的过渡。这种过渡只有两个固定的稳态位置，通常是 0 和 1，常用于 true/false 状态之间的过渡。自机系统的 `self.lh` (高低速)、`self.fire` (是否在射击) 都是这类过渡。

我们使用 `self.slow` 判断自机的高低速状态。该属性取值为 0 或 1，且会受到自机中弹流程和 `self.slowlock` 属性的影响，比检测 shift 按键更加合适。

我们设置一个属性 `self.spinfo.slow`，作为 `self.slow` 的平滑过渡。常见的过渡方法是让过渡值每帧匀速增大或减小，并限制过渡值的最大 (小) 值。具体代码是比较简单的：

```lua
local sp = self.spinfo
if self.slow == 1 then
    sp.slow = sp.slow + 0.15
else
    sp.slow = sp.slow - 0.15
end
if sp.slow < 0 then
    sp.slow = 0
elseif sp.slow > 1 then
    sp.slow = 1
end
```

或者这样：

```lua
local sp = self.spinfo
if self.slow == 1 then
    sp.slow = min(1, sp.slow + 0.15)
else
    sp.slow = max(0, sp.slow - 0.15)
end
```

有了这个过渡值，我们可以计算高速/低速切换时的过渡坐标。假设一个子机某一帧在高速状态的坐标为 $(x_1,y_1)$，低速状态的坐标为 $(x_2,y_2)$，过渡值为 $t$，那么这一帧子机的实际坐标可以这样计算：

$$ x = x_1 (1-t) + x_2 t, $$
$$ y = y_1 (1-t) + y_2 t. $$

上述计算高速/低速之间的过渡坐标的插值方式，使得过渡坐标必定在高速坐标和低速坐标的连线上，且线段比例由过渡值决定，被称为**线性插值**。读者可以根据上述计算公式自行检验下图各线段之间的比例关系。

<img src="../assets/images/linear-interpolation.png" style="margin: 0 auto;">

## 过渡二、火力等级改变

火力等级有若干个固定的稳态位置，这一期要做的自机的火力等级有 $0,1,...,8$ 共 9 个稳态位置。由于 LuaSTG 的火力值上限为 400，在不更改 data 的情况下，为了实现上限为 8 的火力等级，我们每 50 改力值划一档，将 `lstg.var.power` (火力值 0~400) 映射到 $0,1,...,8$ 的稳态位置 (其中 `int()` 为向下取整函数)：

```lua
local power = int(lstg.var.power / 50)
```

对于火力等级，我们也采用匀速变化的过渡模式，设过渡值为 `self.spinfo.power`，每帧更新过渡值的代码如下：

```lua
local sp = self.spinfo
local power = int(lstg.var.power / 50)

if sp.power > power then
    sp.power = sp.power - 0.1
elseif sp.power < power then
    sp.power = sp.power + 0.1
end
```

这时候会有一个小问题，只要过渡值没有严格等于稳态，它就会在稳态附近左右横跳，因此我们加一点代码以确保能够严格等于稳态：

```lua
local sp = self.spinfo
local power = int(lstg.var.power / 50)

if sp.power > power then
    sp.power = sp.power - 0.1
elseif sp.power < power then
    sp.power = sp.power + 0.1
end

if abs(sp.power - power) < 0.1 then
    sp.power = power
end
```

根据火力等级每帧的过渡值去更新子机位置不太容易。总的来说，子机位置只由离当前过渡值最近的两个整数火力等级的子机位置决定。考虑到有些火力等级下子机无效，我们还需要计算子机有效性的过渡值。考虑下图某个子机的信息随火力等级的变化，子机只在 $4,6,7,8$ 火力等级有效。

<img src="../assets/images/sp-power.png" style="margin: 0 auto;">

首先我们计算当 `sp.power` 不为整数时，离它最近的两个整数火力等级：

```lua
local s = int(sp.power) + 1
local t = sp.power - int(sp.power)
```

`s` 计算小于 `sp.power` 的火力等级，自然 `s+1` 就是大于 `sp.power` 的火力等级，而 `t` 计算 `sp.power` 的小数部分，作为子机有效性的参考。

假设火力等级 `s` 对应的子机信息为数值 `a`，火力等级 `s+1` 对应子机信息为数值 `b`，我们要计算当前 `sp.power` (小数部分为 `t`) 对应的子机信息 `c` 和子机有效性 `valid` (0~1)。

我们根据 `a,b` 是否有效 (是否为 `nil`) 分类讨论：

1. `a,b` 都有效 (例如上图中取 `sp.power = 6.5`)，那么 `c` 是 `a,b` 的线性插值，即 `c = a * (1 - t) + b * t`，有效性 `valid` 置为 `1`
2. `a` 有效、`b` 无效 (例如上图中取 `sp.power = 4.5`)，那么可以让 `c` 等于 `a`，有效性置为 `1 - t` (极端情况 `t = 0`，此时有效性为 `1`)
3. `a` 无效、`b` 有效 (例如上图中取 `sp.power = 5.5`)，那么可以让 `c` 等于 `b`，有效性置为 `t` (极端情况 `t = 1` (虽然取不到 `1`)，此时有效性为 `1`)
4. `a,b` 都无效 (例如上图中取 `sp.power = 2.5`)，那么有效性置零，子机信息已经无所谓了

上面是一个简化的模型，最终实现的子机系统代码 (如下) 要复杂一些，融合了火力等级的过渡和高低速的过渡，通过 `MixTable()` 函数进行批量的线性插值。

```lua
local sp = self.spinfo
if not self.time_stop then
    local s = int(sp.power) + 1
    local t = sp.power - int(sp.power)
    for i = 1, sp.num do
        local valid0 = sp.list[s][i]
        local valid1 = sp.list[s + 1] and sp.list[s + 1][i]

        -- sp[i]: 插值结果 { x, y }
        -- sp.valid[i]: 子机有效性
        if valid0 and valid1 then
            sp[i] = MixTable(t,
                MixTable(sp.slow, sp.list[s][i]),
                MixTable(sp.slow, sp.list[s + 1][i]))
            sp.valid[i] = 1
        elseif valid0 and not valid1 then
            sp[i] = MixTable(sp.slow, sp.list[s][i])
            sp.valid[i] = 1 - t
        elseif not valid0 and valid1 then
            sp[i] = MixTable(sp.slow, sp.list[s + 1][i])
            sp.valid[i] = t
        else -- not valid0 and not valid1
            sp.valid[i] = 0
        end
    end
end
```

> 一个小细节：由于 `self.spinfo.list` 没有 "火力等级 9P" 的数据，所以 `valid1` 先检测 `sp.list[s+1]` 以防止 8P 时 `sp.list[s+1] = list[10] = nil` 导致读取 `sp[s+1][i]` 时报错。

## 过渡三、滞后跟随自机

到现在为止，子机跟随自机的方式仍然是比较生硬的直接跟随。虽然好像这样也不是不可以，但我们还是想实现子机滞后跟随自机的效果。

这类过渡有一个不固定的稳态位置，之前的匀速逼近就不再好用了。举个例子，假如自机向右移动，速度为 4，假设过渡值想要匀速逼近自机坐标，那么：如果过渡值的变化速率小于 4，子机根本追不上自机；如果过渡值的变化速率大于 4，子机会瞬间追上自机，与生硬的直接跟随没有区别。

一个常用的方法是每帧计算过渡值和自机坐标的固定比例的线性插值，作为新的过渡值，具体来说是像下面这样 (`sp.x, sp.y` 为过渡值)：

```lua
sp.x = sp.x * 0.7 + self.x * 0.3
sp.y = sp.y * 0.7 + self.y * 0.3
```

这会实现一个 "离自机越远，逼近速度越快；离自机越近，逼近速度越慢" 的过渡效果，用在子机上效果非常的好。


