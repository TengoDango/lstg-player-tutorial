# 自机相关属性整理

可以尝试通过本页面上方的搜索栏查找指定条目。

## 所有类的共有属性 {#class-methods}

### `init(...)`

该回调在创建类的实例对象时执行一次。

### `frame()`

该回调在每帧更新对象状态时执行一次。

- 在 `frame` 为空函数时，有一些更新仍会进行，比如坐标 `x`,`y` 每帧自增 `vx`,`vy`。
- 菜单暂停时不会执行 `frame` 回调，因为此时对象状态不需要更新。

### `render()`

该回调在每帧渲染对象时执行一次。

- 只有 `render` 回调能够执行渲染函数。
- 暂停时也会调用，因为暂停时也需要渲染。所以不要在 `render` 里写状态更新，求求了。

### `colli(other)`

该回调在实例对象和另一个对象碰撞时执行一次。若为空函数则什么也不会发生。

需要注意执行的是哪个对象的 `colli` 回调。这涉及到 `CollisionCheck` 函数：

- `CollisionCheck(groupA, groupB)` 对 `groupA`,`groupB` 两个碰撞组的对象进行碰撞检测，
- 如果发生碰撞则**触发 `groupA` 对象的 `colli` 回调**，传入 `groupB` 的对象作为 `other` 参数。

### `kill()`,`del()`

该回调在用 `Kill`,`Del` 函数删除对象时执行一次。若为空函数，对象仍然会被删除。

- `Kill` 函数会将对象标记为 kill 状态，然后执行对象的 `kill` 回调。(`Del` 函数同理)
- 对象是否要删除是由 kill/del 状态决定的，所以 `kill`,`del` 为空函数时仍会删除对象。
- 另参考 [status](#status)

注：自机的 miss 不是通过 `Kill`/`Del` 实现的，所以自机不需要管 `kill`/`del` 回调。

## 自机类的特有属性

### `shoot`,`spell`,`special` 回调函数

对应自机的射击、使用 bomb、特殊操作 (c 键) 三个操作。

如果是空函数，按 z,c 键什么也不会发生，按 x 键会导致 bomb 数量蒸发 (乐)。

## 所有对象的共有属性

### `status: string` {#status}

【可读写】表示对象是否要被删除，取值有 "normal", "del", "kill" 三种。
"del", "kill" 都表示对象将被引擎自动回收。

可以用于取消死亡：在 `kill` 回调里写 `self.status = "normal"`，使得 `Kill()` 不会删除对象。`del` 同理。

不过这个和自机没什么关系，自机的 miss 不通过 `kill` 或 `del` 实现。

### `class`

【只读......吗】对象所属的类，决定对象的 `frame`,`render` 等回调。

编辑器提供的子弹会通过更改 `class` 属性实现弹雾效果，感兴趣的话可以找一下 `bullet.lua` 的相关代码。

### `world: integer`

【可读写】世界掩码，与更新、渲染、碰撞检测有关。

如果了解过 “掩码” 的概念那么应该能明白这个要怎么用，不过看起来几乎没有应用场景。

### `x,y: number`

【可读写】对象的坐标。

### `dx,dy: number`

【只读】坐标相对上一帧的变化量。

### `vx,vy,ax,ay,ag: number`

【可读写】速度、加速度。

`x`,`y` 属性每帧会自动加上 `vx`,`vy`，而 `vx`,`vy` 每帧会自动加上 `ax`,`ay`。

`vy` 每帧还会减去 `ag`，对应重力加速度。

### `maxv,maxvx,maxvy: number`

【可读写】最大速度，引擎会根据它们自动限制 `vx`,`vy` 属性的值。

### `_speed,_angle: number`

【不建议使用】速度 (`vx`,`vy`) 的大小和方向。

比较糟糕的设计。更建议用 `GetV` 和 `SetV` 函数：

```lua
---设置游戏对象的速度
---@param unit lstg.GameObject
---@param v number
---@param a number
---@param updaterot boolean @如果该参数为true，则同时设置对象的rot
function lstg.SetV(unit, v, a, updaterot)
end

---@param unit lstg.GameObject
---@return number, number @速度大小，速度朝向
function lstg.GetV(unit)
end

GetV = lstg.GetV
SetV = lstg.SetV
```

### `group: integer`

【可读写】碰撞组，取值为 0 ~ 15 的整数。但是更建议**使用 `GROUP_BULLET` 等变量名**，而非直接使用数值。

碰撞组影响对象遍历和碰撞检测，因此不应该在 `colli` 回调函数中，或使用 `lstg.ObjList` 遍历对象 (对应编辑器的 For Each Unit in Group 节点) 时修改碰撞组。

在无法确定游戏版本 (比如只发布 mod 压缩包) 时，**最好不要添加新的碰撞组**。尽管任何一个没被 data 使用的 0 ~ 15 整数都可以作为新的碰撞组，但不同版本的 data 使用的碰撞组数值可能发生变化，使得一个 “新的碰撞组” 可能在其他游戏版本已被使用，这也是建议用变量名而非数值的原因。

### `bound: bool`

【可读写】对象是否在离开边界时自动删除。

### `colli: bool`

【可读写】对象是否参与碰撞检测。

### `rect: bool`

【可读写】碰撞体的形状，`true` 时为矩形，`false` 为圆/椭圆。

### `a,b: number` {#ab}

【可读写】碰撞体的半径，`a` 为横向 (沿 `rot`) 的半径，`b` 为纵向 (垂直于 `rot`) 的半径。

注：更改对象的贴图时，会根据贴图设定的碰撞大小修改碰撞半径，如果对象的碰撞半径与贴图设定不同则需要注意这一点。

注：自机比较特殊，它的碰撞半径对应属性 [`A,B`](#AB)

### `img: string`

对象的渲染资源，可以是图片精灵 (我们常说的贴图)、图片序列 (动画, animation, ani)、HGE 粒子特效。

### `layer: number`

【可读写】渲染图层，影响各个对象渲染的先后顺序，数字越大，渲染越靠后，从而图层越靠上。

影响渲染回调的执行顺序，因此严禁在 `render` 回调中修改 `layer`。

### `hscale,vscale: number`

【可读写】贴图的缩放比例。

和碰撞半径完全没有关系。

### `rot,omiga: number`

【可读写】贴图的朝向和角速度。

和速度方向完全没有关系。

omiga 是 omega 拼写错了，不嘻嘻。

### `navi: bool`

【可读写】`true` 则自动根据对象的 `dx`,`dy` 设置朝向 `rot`，和 `omiga` 冲突

### `ani: integer`

【只读】连续自增动画计数器。

### `hide: bool`

【可读写】`true` 则不执行渲染回调。

### `timer: integer`

【可读...写】计数器/计时器，初始为 0，每帧加一。但是可以自由修改。

### `nopause: bool`

【可读写】`true` 则不受超级暂停 (super pause) 影响。

## 自机对象的特有属性

本小节的属性按 `player_system.lua` 里的出现顺序进行排列。

### `death: integer`

【可读写】死亡状态的计数器，倒计时，取值 0 ~ 100。

详见 [`player.death`](../dataer/player-system#death)。

### `lock: bool`

【可读写】`true` 时，方向键无法控制自机，并且造成一些[额外影响](#death-state)。

### `time_stop: bool`

【可读写】`true` 时，自机的一些预设行为不会执行：

- 低速法阵的若干状态更新，
- `timer` 属性的更新，
- 行走图系统的状态更新，
- 子机位置表的状态更新，

并且造成一些[额外影响](#death-state)。

### `__death_state: integer` {#death-state}

【只读】枚举 death state，主要由 `death` 属性决定，但开启 `lock` 或 `time_stop` 属性也会导致 death state 不为零。

death state 不为零的情况会影响一些自机行为的执行：

- 无法射击、使用 bomb、执行 c 键操作；
- `slow` 和 `fire` 属性不会更新；
- 不会吸引新的掉落物。

如果你的自机有一些类似的行为，建议也检测一下 death state。

其他 death state 取值参考 [`player.__death_state`](../dataer/player-system#death-state)。

### `slow: 0 or 1`

【只读】是否处于低速，低速为 1，高速为 0。

- 在 death state 非零时不会更新；
- 开启 `slowlock` 属性时强制为 1。

### `dialog: bool`

【可读写】开启该属性将对自机造成以下影响：

- 无法射击、使用 bomb、执行 c 键操作；
- `fire` 属性不会更新；
- 被弹时不会发生任何事 (连消弹都没有)。

### `nextshoot,nextspell,nextsp: integer`

【可读写】射击 / 使用 bomb / 执行 c 键操作对应的剩余冷却时间 (单位：帧)。

### `slowlock: bool`

【可读写】`true` 则 `slow` 属性强制为 1。

### `hspeed,lspeed: number`

【可读写】自机的高速、低速。前缀 `h`,`l` 表示 high 和 low。

### `__move_dx,__move_dy: number`

【只读】当前帧由方向键导致的移动量，详情见 [`player-system/frame-move`](../dataer/player-system#frame-move)

### `fire: 0 ~ 1`

【只读】平滑跟随射击键状态，按住射击键为 1，松开为 0。

### `collect_line: number`

【可读写】收集线高度。

### `lh: 0 ~ 1`

【只读】平滑跟随 `slow` 属性，每帧增加/减少 0.15，限制取值范围 0 ~ 1。

### `support: 0 ~ 4`

【只读】平滑跟随火力等级 `int(火力值 / 100) in {0,1,2,3,4}`，每帧增加/减少 0.0625。

### `supportx,supporty: number`

【只读】平滑跟随自机坐标，线性插值，一般用于子机。

### `protect: integer`

【可读写】自机剩余无敌时间 (单位：帧)。

### `slist: table`

【可读写】子机的设定位置表。

`self.slist[火力等级][子机编号] = {高速-x, 高速-y, 低速-x, 低速-y}`

### `sp: table`

【只读】子机的实际位置表。

`self.sp[火力等级][子机编号] = {x, y, 有效性:0~1}`

### `grazer: object`

擦弹圈的判定和低速法阵 (aura) 的渲染，属于 `GROUP_PLAYER` 碰撞组。

如果你在做一些类似的东西，比如子机 obj，或许可以参考一下 `player.lua` 的 `grazer` 类的写法。

### `target: object or nil`

给自机提供一个追踪目标，确保该目标有效、开启碰撞、属于 `GROUP_ENEMY` 或 `GROUP_NONTJT` 碰撞组。

没有按下射击键时固定为 `nil`。

### `imgs: table`

【可读写】自机的行走图，一般是一个 24 张图片的列表，前 8 张为静止动画，中间 8 张为左移动画，后 8 张为右移动画。

详见 [`PlayerWalkImageSystem`解析](../dataer/wisys)。

### `A,B: number` {#AB}

【可读写】自机的判定大小。由于行走图系统更换贴图时会[自动改变判定大小](#ab)，行走图系统每帧需要根据 `A`,`B` 属性把自机判定纠正回来。

详见 [`PlayerWalkImageSystem`解析](../dataer/wisys)。

## 自机子弹的特有属性

具体逻辑参考 `enemy.lua` 的 `enemybase:colli(other)` 或 `editor.lua` 的 `_object:colli(other)`。

### `dmg: number`

【可读写】damage，自机子弹的伤害。

### `mute: bool`

【可读写】`true` 则击中敌机时不会有音效。

### `killflag: bool`

【可读写】`true` 则击中敌机时自机子弹不会被删除。

### `killerenemy: object`

【可读写】击中的敌机 obj，似乎不太能用得上。