---环绕子机

ExtraPlayer = Class(player_class)

function ExtraPlayer:init()
    player_class.init(self)
    self.imgs = {}
    for i = 1, 24 do self.imgs[i] = 'white' end
    -- 写入极坐标数据
    local r1, r2 = 90, 30
    self.slist = {
        {},
        { { r1, 0, r2, 0 } },
        { { r1, 0, r2, 0 }, { r1, 180, r2, 180 } },
        { { r1, 0, r2, 0 }, { r1, 120, r2, 120 }, { r1, 240, r2, 240 } },
        { { r1, 0, r2, 0 }, { r1, 90, r2, 90 },   { r1, 180, r2, 180 }, { r1, 270, r2, 270 } },
        { { r1, 0, r2, 0 }, { r1, 90, r2, 90 },   { r1, 180, r2, 180 }, { r1, 270, r2, 270 } },
    }
    -- 自定义属性
    self.spx = { 0, 0, 0, 0 } -- sp x
    self.spy = { 0, 0, 0, 0 } -- sp y
    self.spv = { 0, 0, 0, 0 } -- sp valid
    self.sp_angle = 0
end

function ExtraPlayer:frame()
    player_class.frame(self)
    -- 子机位置及有效性更新
    for i = 1, 4 do
        if self.sp[i] then
            local dist = self.sp[i][1]
            local angle = self.sp[i][2] + self.sp_angle
            self.spx[i] = self.supportx + dist * cos(angle)
            self.spy[i] = self.supporty + dist * sin(angle)
            self.spv[i] = self.sp[i][3]
            -- 殿梦A的小机制
            if self.spx[i] < -200 then
                self.spx[i] = self.spx[i] + 400
            end
            if self.spx[i] > 200 then
                self.spx[i] = self.spx[i] - 400
            end
        else
            self.spv[i] = 0
        end
    end
    if self.slow == 1 then
        self.sp_angle = self.sp_angle + 2
    else
        self.sp_angle = self.sp_angle + 6
    end
end

function ExtraPlayer:render()
    for i = 1, 4 do
        Render('leaf', self.spx[i], self.spy[i], self.timer * 2, self.spv[i])
    end
    player_class.render(self)
end
