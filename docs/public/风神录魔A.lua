---风神录魔a: 更复杂的子机控制

ExtraPlayer = Class(player_class)

---子机"类"
local support = {}

function ExtraPlayer:init()
    player_class.init(self)
    self.imgs = {}
    for i = 1, 24 do self.imgs[i] = 'white' end

    -- 固定长度的循环链表
    -- 数据结构最有用的一集
    self.delay = 10
    self.xlist, self.ylist = {}, {}
    for i = 1, self.delay * 4 + 1 do
        self.xlist[i], self.ylist[i] = self.x, self.y
    end
    self.idx = 1

    -- 创建子机对象
    self.supports = {}
    for i = 1, 4 do
        self.supports[i] = support.create(i, self)
    end
end

---适配越界索引
local function set(list, index, value)
    index = (index - 1) % #list + 1
    list[index] = value
end

---适配越界索引
local function get(list, index)
    index = (index - 1) % #list + 1
    return list[index]
end

function ExtraPlayer:frame()
    player_class.frame(self)

    -- 自机位置历史记录更新
    if self.slow == 0 then
        -- 高速: 如果移动则正常更新
        local is_moving = not (self.__move_dx == 0 and self.__move_dy == 0)
        if is_moving then
            -- 循环链表插入当前位置
            self.idx = self.idx + 1
            set(self.xlist, self.idx, self.x)
            set(self.ylist, self.idx, self.y)
        end
    else
        -- 低速: 历史记录全体与自机同步移动
        for i = 1, #self.xlist do
            self.xlist[i] = self.xlist[i] + self.__move_dx
            self.ylist[i] = self.ylist[i] + self.__move_dy
        end
    end

    -- 子机位置更新
    for _, sp in ipairs(self.supports) do
        sp:update()
    end
end

function ExtraPlayer:render()
    for _, sp in ipairs(self.supports) do
        sp:render()
    end
    player_class.render(self)
end

--------------------------------------------------

---子机初始化
function support.create(i, player)
    local self = {}

    self.player = player
    self.delay = player.delay
    self.x, self.y = player.x, player.y
    self.i = i

    self.update = support.update
    self.render = support.render

    return self
end

---子机更新
function support:update()
    local player = self.player

    -- 子机对应的历史点, 比自机当前时间落后 i*delay 帧
    local idx = player.idx - self.i * self.delay

    -- 读取历史位置, 修改子机坐标
    local x = get(player.xlist, idx)
    local y = get(player.ylist, idx)
    self.x = self.x + (x - self.x) * 0.3
    self.y = self.y + (y - self.y) * 0.3

    -- 计算子机有效性, 由此决定放缩
    local valid = player.support - self.i + 1
    if valid < 0 then valid = 0 end
    if valid > 1 then valid = 1 end
    self.hscale = valid

    -- 还原特性: 火力提升时, 新生成的子机与前一个子机重叠
    -- 这里的方法是: 如果该子机无效, 那么用前一个子机的位置覆盖该子机未来的那些位置
    -- 我有一个绝妙的示意图, 但是这里地方太小了画不下 (
    if valid == 0 then
        local futureX = get(player.xlist, idx + self.delay)
        local futureY = get(player.ylist, idx + self.delay)
        for i = 0, self.delay - 1 do
            set(player.xlist, idx + i, futureX)
            set(player.ylist, idx + i, futureY)
        end
    end
end

---子机渲染
function support:render()
    Render('parimg15', self.x, self.y, 0, self.hscale, 1)
end
