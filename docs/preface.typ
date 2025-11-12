#import "/book.typ": book-page

#show: book-page

= 没人看的序言

本教程基于 `LuaSTG aex+ v0.8.22` 版本，可能在你看到本教程时这个版本已经比较旧了，但我认为本教程仍然会有一定参考价值。

阅读该教程预计需要以下基础：
- 了解足够的lua语法（主要是table的用法）
- 能够使用自定义obj制作弹幕
- 有一个趁手的代码编辑器（记事本战神？失敬失敬）

一些术语的说明：
- table：Lua的一个数据类型，一般翻译为 "表"。

  作为Lua里为数不多的引用类型，table在LuaSTG中到处都是，而且用法多样，是语法上的一个重难点。

- class：面向对象里的 "类" 这一概念，也指LuaSTG里用`Class()`函数生成的对象模板。

  对应到Sharp就是 define bullet, define object 等节点。
  #image("/assets/images/preface-1.png", width: 250pt)

- object：面向对象里的 “对象” 这一概念，也指LuaSTG里用`New()`函数生成的对象实例。

  对应到Sharp就是 create bullet, create object 等节点。
  #image("/assets/images/preface-2.png", width: 500pt)

  另外，LuaSTG中最基本的class的变量名也是`object`。

- field：在面向对象中指class或object中存储数据的成员变量，有 "成员" "字段" "属性" 等等相似但又好像有微妙区别的名称。

  也可以指table中的一类元素，通常用形如 "`self.x`" 的形式表示，其中 `self` 是一个table，`x` 是对应的field名称。

  由于本质上LuaSTG里的class和object也是一种table，上述两种含义是相通的。

- 方法：函数类型的field，也就是定义在class和object里的函数。

  定义在一般table里的函数也可以叫方法。

- 回调函数：一类特殊的方法，由data在特定的时候自动调用，一般不需要手动调用。

  "调" 指函数调用，"回" 表示这个调用是别人（data或其他地方）*反过来*调用我们提供的函数。
