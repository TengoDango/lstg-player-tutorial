# 一些术语的说明

这页记录了对一些常用术语的解释。是一边写教程一边收集的，所以记的比较散乱，解释内容也可能比较难懂，还望体谅。

## 表 (Table)

表 (table) 是 lua 语言的一个数据类型，属于引用类型，用法多样，是语法上的一个重难点。

表的语法特性使得它在 LuaSTG 中有着广泛的应用。LuaSTG 的类和对象 (包括但不限于简单子弹、自定义子弹、激光、自机、boss 等等) 本质都是表。

如果你担心自己对表的了解不够，我可以向你推荐以下教程：
- [表，tables - Lua 编程（第 4 版）](https://lua.xfoss.com/tables.html)

## 语法糖

“语法糖” 指的是让代码看起来更简洁、更易读的语法形式，而又不增加语言本身的表达能力 —— 所有用语法糖写出的代码，都可以用更基础、更原始的方式等价地表达出来。

Lua 的语法糖主要是关于表和函数的，比如：
- `tab.x` 是访问 / 修改表中元素的一个语法糖，对应的原始写法是 `tab["x"]`
- `function tab:init(...) ... end` 是定义表中函数的一个语法糖，对应的原始写法是 `function tab.init(self, ...) ... end` {#method}
- `tab:init(...)` 是调用表中函数的一个语法糖，对应的原始写法是 `tab.init(tab, ...)`

## 类 (Class) 与对象 (Object)

类和对象是 “面向对象编程” 的两个基本概念，类似于 “模板” 与 “实例” 的关系。

LuaSTG 中的类是由 `Class(...)` 函数返回的表，对应到编辑器则是 define bullet, define object 等节点；而对象是由 `New(...)` 函数返回的表，对应编辑器中 create bullet, create object 等节点。

LuaSTG 模拟了面向对象编程的 “继承” 机制，`derived = Class(base)` 语句可以创建一个继承了 `base` 基类的 `derived` 子类。

LuaSTG 中最基本的类对应的变量名是 `object`。

不过请记住，我们用的是 Lua 而不是什么面向对象的编程语言，类也好对象也罢，本质上都是表的运用。

## Field

在面向对象编程中，field 指类和对象里的数据成员，有 “成员” “字段” “属性” 等相似但又有些微妙区别的叫法，本教程统一称其为 “属性”。

例：`self.x`, `self.y`, `self.rot`

在 Lua 中，field 指表中存储的键值对中的键，尤其指用合法变量名字符串表示的键。

由于 LuaSTG 的类和对象本质上都是表，上述两种含义是相通的。

## 方法 (Method)

“方法” 在面向对象编程中特指依附于类或对象的一种函数，这种函数的运行结果通常与它所依附的类或对象的当前状态相关。

例：`class:init()`, `class:frame()`, `class:render()`

Lua 提供了一个语法糖来表现方法的特性，我们可以看下面的例子：

```lua
local point = { x = 20, y = 30 }
function point:dist()
    return math.sqrt(self.x * self.x + self.y * self.y)
end
print(point:dist())
```

如果你已经知道了[上文的语法糖](#method)，你应该能够理解这个例子是如何工作的。

但 LuaSTG 的面向对象机制的模拟更像是下面的样子：
```lua
-- 类
local point_class = {}
function point_class:init(x, y)
    self.x, self.y = x, y
    self.class = point_class
end
function point_class:dist()
    return math.sqrt(self.x * self.x + self.y * self.y)
end
-- 对象
local function New(class, ...)
    local obj = {}
    point_class.init(obj, ...)
    return obj
end
local point_object = New(point_class, 20, 30)
print(point_class.dist(point_object))
```

在创建对象时，对象不会获取类的方法，虽然可以通过 `self.class.dist()` 调用类方法，但 `self:dist()` 这样的语法糖是不能适用的。

## 回调函数 (Callback Function)

回调函数 (简称回调) 是一种特殊的方法，由系统在特定时候自动调用。

“调” 指函数调用，“回” 表示这个调用是由别人 (data 或其他地方) **反过来**调用我们提供的函数。

说到 LuaSTG 里的回调函数，最经典的当属所有类都有的六个回调：`init`, `frame`, `render`, `colli`, `kill`, `del`。它们的调用由 data (Lua 层) 和底层 (C++ 层) 共同负责，定义则由对应类的编写者负责。
