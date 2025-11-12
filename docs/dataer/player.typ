#import "/book.typ": book-page, cross-ref

#show: book-page

= `player.lua` 解析

== `player_lib: table`（全局变量）

起到一个命名空间的作用，纯粹就是含有一些自机组件的一个table。

== `player_class: class`（全局变量）

这是自机需要继承的class（也就是每个自机都会有的`xxx_player = Class(player_class)`）。

根据`Class`函数的原理（`thlib-scripts\lib\Lobject.lua`），当一个自机class继承`player_class`时，它会自动获得`player_class`的`init,frame,render,colli,kill,del`六个函数。

同样地，`player_class = Class(object)`会让`player_class`获得`object`的六个函数。`object`是最基础的class，然后，data重写了其中四个：`init,frame,render,colli`。

至于`kill,del`，自机在这里是非常特殊的：一般的object在触发碰撞时会执行`kill`回调函数删掉自己，或者在需要时触发`del`回调函数删掉自己，而自机在触发碰撞时进行了特殊的处理，被设计成不会触发`kill,del`回调（具体见 \/\*TODO\*\/）。所以data没有重写`player_class`的对应回调。

=== `player_class:init()`

=== `player_class:frame()`
=== `player_class:render()`
=== `player_class:colli()`

=== `player_class:findtarget()`

