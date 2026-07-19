# 风神录魔c：更复杂的子机

番外的最后两期我们聊一聊比较复杂的子机设计。风神录的魔a和魔c自机都有比较复杂的子机机制，它们没有固定的稳态子机位置，因此不适合用默认的设置 `slist` 的方法来实现，需要我们单独地写一套对应的子机系统。这一期我们写一下相对简单的魔c的子机系统。

魔c主要的机制就是高速和低速下子机行为的区别：
- 自机保持高速时，与默认的子机系统一致，有着指定的稳态位置
- 自机低速时，子机会固定在屏幕上，位置不会改变
- 切换到高速时，需要维持一秒，然后子机才会回收到自机前方

对于这类涉及延时的需求，常用的方法就是写一个计时器。我们在蓄力弹那一期写过更加复杂的需求，这里就不细说了。

```lua
--- 在 init 回调里:
self.counter = 0 -- 初始为保持高速的状态

--- 在 frame 回调里:
if self.slow == 0 then
    self.counter = self.counter - 1
else
    self.counter = 60
end
```

这时如果 `self.counter <= 0`，就可以确认自机保持在高速。

魔c在火力变化时的行为有点复杂，我们先考虑固定为满火力的情况，这时四个子机都有效。

由于要求低速时子机位置不变，我们需要存储子机的实际坐标，我这里选择创建 `spx,spy` 属性分别存放x坐标和y坐标。然后我们利用已有的 `sp` 表来更新实际坐标 `spx,spy`：

```lua
--- 在 init 回调里:
self.spx = {self.x, self.x, self.x, self.x}
self.spy = {self.y, self.y, self.y, self.y}

--- 在 frame 回调里:
for i = 1, 4 do
    -- 稳定在高速状态 -> 线性插值逼近
    if self.counter <= 0 then
        -- 因为我们自己写线性插值, 所以不需要用 supportx,supporty
        local x = self.x + self.sp[i][1]
        local y = self.y + self.sp[i][2]
        self.spx[i] = self.spx[i] + (x - self.spx[i]) * 0.3
        self.spy[i] = self.spy[i] + (y - self.spy[i]) * 0.3
    -- else: 低速状态 -> 子机位置不变
    end
end
```

而后在 render 回调里根据 `spx,spy` 的子机位置进行渲染即可，不再赘述。

最后我们把火力变化也考虑进来。当火力等级提高时，新的子机将出现在稳态位置；火力等级降低时，对应的子机会消失。为了检测火力等级变化，一个自然的思路是检测 `lstg.var.power`（0~400的火力值）的变化，不过此处我们可以有另一个办法。

在 frame 回调的开头，我们会写下一句 `player_class.frame(self)`，这是自机默认的每帧行为。实际上 `self.sp` 就是在这里更新的，在此之后，`self.sp` 已经更新，但是我们自己写的 `self.spx,self.spy` 尚未更新。我们完全可以通过比较它们的差异来判断子机的增减。

```lua
for i = 1, 4 do
    -- 子机是否在本帧有效
    local is_valid = self.sp[i] and self.sp[i][3] > 0.5
    -- 子机是否在上一帧有效
    local is_valid_prev = self.spx ~= nil
end
```

知道子机是增加、减少还是不变之后，就可以分情况执行对应的子机更新。详见附录的完整代码。

<!--此外，在powerup瞬间如在高速，子机会瞬间全部回收；低速时，子机会出现在自机的偏右上方。-->
