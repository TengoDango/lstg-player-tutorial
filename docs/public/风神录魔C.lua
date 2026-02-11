---风神录魔c: 更复杂的子机控制

ExtraPlayer = Class(player_class)

function ExtraPlayer:init()
    player_class.init(self)
    self.imgs = {}
    for i = 1, 24 do self.imgs[i] = 'white' end
    self.slist = {
        {},
        { { 0, 35, 0, 35 } },
        { { -15, 35, -10, 35 }, { 15, 35, 10, 35 } },
        { { -30, 30, -30, 30 }, { 30, 30, 30, 30 }, { 0, 35, 0, 35 } },
        { { -45, 30, -45, 30 }, { 45, 30, 45, 30 }, { -15, 35, -15, 35 }, { 15, 35, 15, 35 } }
    }
    self.slist[6] = self.slist[5]

    -- 子机实际位置
    self.spx = { nil, nil, nil, nil }
    self.spy = { nil, nil, nil, nil }
    -- 延时回收子机的计数器
    self.counter = 60
end

function ExtraPlayer:frame()
    player_class.frame(self)
    -- 计数器更新
    if self.slow == 0 then
        self.counter = self.counter + 1
    else
        self.counter = 0
    end
    -- 子机位置更新
    for i = 1, 4 do
        local is_valid = self.sp[i] and self.sp[i][3] > 0.5
        if is_valid and not self.spx[i] then
            -- 火力提高, 新出现的子机 -> 指定初始位置
            self.spx[i] = self.x + self.sp[i][1]
            self.spy[i] = self.y + self.sp[i][2]
        elseif not is_valid and self.spx[i] then
            -- 火力降低, 子机消失 -> 清除位置
            self.spx[i], self.spy[i] = nil, nil
        elseif is_valid and self.spx[i] and self.counter >= 60 then
            -- 稳定在高速状态 -> 指数逼近设定位置
            local x = self.x + self.sp[i][1]
            local y = self.y + self.sp[i][2]
            self.spx[i] = self.spx[i] + (x - self.spx[i]) * 0.3
            self.spy[i] = self.spy[i] + (y - self.spy[i]) * 0.3
        end -- 其他 -> 子机位置不变
    end
end

function ExtraPlayer:render()
    player_class.render(self)
    if self.counter >= 60 then
        SetImageState('parimg15', 'mul+add', Color(255, 255, 255, 255))
    else
        -- 子机频闪
        local c = (self.counter % 4) / 3 * 255
        SetImageState('parimg15', 'mul+add', Color(255, c, c, 255))
    end
    -- 子机渲染
    for i = 1, 4 do
        if self.sp[i] and self.spx[i] then
            Render('parimg15', self.spx[i], self.spy[i], 0, 1.4)
        end
    end
end

-- function ExtraPlayer:special()
--     self.nextsp = 30
--     if self.x < 0 then
--         lstg.var.power = lstg.var.power - 100
--     else
--         lstg.var.power = lstg.var.power + 100
--     end
--     lstg.var.power = max(0, min(400, lstg.var.power))
-- end
