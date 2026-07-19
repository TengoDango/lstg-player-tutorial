# 一些术语的说明

这页记录了对一些常用术语的解释。是一边写教程一边收集的，所以记的比较散乱，解释内容也可能比较难懂，还望体谅。

## data

在我们平时的讨论中，data 指 LuaSTG 的 lua 层，这是因为稍早的版本中 lua 文件集中在名为 data 的文件夹中。

相对地，“引擎” “底层” 一般特指 LuaSTG 的 c++ 层，c++ 代码没有包含在游戏本体中。不过除了引擎开发者以外一般不需要在意底层的代码是怎么写的，只看 data 也就是 lua 层就够了。

## 表（Table）

表是 lua 语言的一个数据类型，用法多样，是语法上的一个重难点。

表的语法特性使得它在 LuaSTG 中有着广泛的应用。LuaSTG 的类和对象（包括但不限于子弹、激光、自机、boss、UI 等等）本质都是表。

如果你担心自己对表的了解不够，可以参考以下教程：
- [表，tables - Lua 编程（第 4 版）](https://lua.xfoss.com/tables.html)

## 语法糖

“语法糖” 指的是让代码看起来更简洁、更易读的语法形式。所有用语法糖写出的代码，都可以用更基础、更原始的方式等价地表达出来。

Lua 的语法糖主要是关于表和函数的，比如：
- `self.x` 是读取或修改 `self` 表内元素的语法糖，对应的原始写法是 `self["x"]`
- `function class:init(...) ... end` 是定义 `class` 表内函数的语法糖，对应的原始写法是 `function class.init(self, ...) ... end` {#method}
- `class:init(...)` 是调用 `class` 表内函数的语法糖，对应的原始写法是 `class.init(class, ...)`

## 类 (Class) 与对象 (Object)

类和对象是 “面向对象” 的两个基本概念，类似于 “模板” 与 “实例” 的关系。

对于 LuaSTG，我们平时讨论的 “类” 和 “对象” 特指能够在游戏中渲染出来的那种 (正式名称为 GameObject)，比如子弹、自机、boss 等。类是由 `Class(...)` 函数返回的表，对应到编辑器则是 define bullet, define object 等节点；对象是由 `New(...)` 函数返回的表，对应编辑器中 create bullet, create object 等节点。

至于 data 里经常使用的 `plus.Class`，以及 lua 教程讨论的更加一般的类和对象，本教程不会涉及。

LuaSTG 模拟了面向对象编程的 “继承” 机制，`derived = Class(base)` 可以创建继承了 `base` 基类的 `derived` 子类。

LuaSTG 中最基本的类是 `object`。

不过请记住，我们用的是 Lua 而不是什么面向对象的编程语言，类也好对象也罢，本质上都是表。

## 属性 (Field)

在面向对象编程中，field 指类和对象里的数据成员，有 “成员” “字段” “属性” 等相似但又有些微妙区别的叫法，本教程统一称其为 “属性”。

例：`self.x`, `self.y`, `self.rot`

## 方法 (Method)

“方法” 在面向对象编程中特指依附于类或对象的一种函数，这种函数的运行结果通常与它所依附的类或对象相关。

例：`class:init()`, `class:frame()`, `class:render()`

Lua 提供了一个语法糖来模拟面向对象语言的写法，我们可以看下面的例子：

```lua
local point = { x = 20, y = 30 }
function point:dist()
    return math.sqrt(self.x * self.x + self.y * self.y)
end
print(point:dist())
```

如果你已经理解了[上文的语法糖](#method)，应该能够理解这个例子是如何工作的。

但 LuaSTG 的面向对象机制更像是下面的样子：
```lua
--- 类
local point_class = {}
function point_class:init(x, y)
    -- 这个 self 并非 point_class 类, 而是新创建的 obj 对象
    self.x, self.y = x, y
    self.class = point_class
end
function point_class:dist()
    return math.sqrt(self.x * self.x + self.y * self.y)
end
--- 对象
local function New(class, ...)
    local obj = {}
    point_class.init(obj, ...)
    return obj
end
--- 创建对象
local point_object = New(point_class, 20, 30)
--- 调用方法
print(point_class.dist(point_object))
```

尽管我们可以通过 `self.class.dist()` 调用 `self` 所属类的方法，但 `self:dist()` 这样的语法糖是不适用的，因为 `self` 不会自动得到类的方法。

## 回调函数 (Callback Function)

回调函数 (简称回调) 是一种特殊的函数。“调” 指函数调用，“回” 是假设了一个情境，这个函数由我们定义，由其他人 “反过来” 调用我们提供的函数。

回调与其他的函数与方法没有本质的区别。把一个函数或方法称为 “回调” 只是为了强调它的定义和调用是分开的，我们定义函数时需要特定的函数名和函数参数，来保证其他地方调用函数时不出问题。

说到 LuaSTG 里的回调函数，最经典的当属任何类都有的六个回调：`init`, `frame`, `render`, `colli`, `kill`, `del`。它们的调用由 data (Lua 层) 和底层 (C++ 层) 共同负责，定义则由对应类的编写者负责。新创建的类还会自动得到它的基类的这六个回调。
