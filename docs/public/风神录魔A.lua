---风神录魔a: 更复杂的子机控制

ExtraPlayer = Class(player_class)

function ExtraPlayer:init()
    player_class.init(self)
    self.imgs = {}
    for i = 1, 24 do self.imgs[i] = 'white' end

    self.delay = 10
    self.xlist, self.ylist = {}, {}
    for i = 1, self.delay * 4 + 1 do
        self.xlist[i], self.ylist[i] = self.x, self.y
    end

    self.spx, self.spy, self.valid = {}, {}, {}
    for i = 1, 4 do
        self.spx[i], self.spy[i], self.valid[i] = self.x, self.y, 0
    end
end

function ExtraPlayer:frame()
    player_class.frame(self)
    ExtraPlayer.UpdateHistory(self)
    ExtraPlayer.UpdateSupports(self)
end

---自机位置历史记录更新
function ExtraPlayer:UpdateHistory()
    local n = #self.xlist
    local m = n - math.ceil(self.support) * self.delay
    if self.slow == 0 then
        -- 高速: 如果移动则更新
        local is_moving = not (self.__move_dx == 0 and self.__move_dy == 0)
        if is_moving then
            for i = m, n - 1 do
                self.xlist[i] = self.xlist[i + 1]
                self.ylist[i] = self.ylist[i + 1]
            end
            self.xlist[n] = self.x
            self.ylist[n] = self.y
        end
    else
        -- 低速: 历史记录与自机同步移动
        for i = m, n do
            self.xlist[i] = self.xlist[i] + self.dx
            self.ylist[i] = self.ylist[i] + self.dy
        end
    end
    -- 还原特性: 火力提升时, 新生成的子机与前一个重叠
    for i = 1, m - 1 do
        self.xlist[i] = self.xlist[m]
        self.ylist[i] = self.ylist[m]
    end
end

---子机位置更新
function ExtraPlayer:UpdateSupports()
    for i = 1, 4 do
        local valid = self.support - i + 1
        self.valid[i] = max(0, min(1, valid))

        local index = #self.xlist - i * self.delay
        local x = self.xlist[index]
        local y = self.ylist[index]
        self.spx[i] = self.spx[i] * 0.7 + x * 0.3
        self.spy[i] = self.spy[i] * 0.7 + y * 0.3
    end
end

function ExtraPlayer:render()
    for i = 1, 4 do
        Render('parimg15', self.spx[i], self.spy[i], 0, self.valid[i], 1)
    end
    player_class.render(self)
end
