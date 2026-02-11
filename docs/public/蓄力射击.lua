---蓄力射击

ExtraPlayer = Class(player_class)
local charge_bullet = lstg.CreateGameObjectClass()

function ExtraPlayer:init()
    player_class.init(self)
    self.imgs = {}
    for i = 1, 24 do self.imgs[i] = 'white' end

    self.charge_counter = 0    -- 蓄力计数器
    self.min_charge_time = 20  -- 最小蓄力时间
    self.max_charge_time = 180 -- 最大蓄力时间
end

function ExtraPlayer:frame()
    player_class.frame(self)
    -- 自机状态
    local has_enough_power = int(lstg.var.power / 100) > 0
    local is_shooting = self.fire > 0.9
    local is_slow = self.slow == 1
    -- 状态转移条件
    local cond_clear = not (has_enough_power and is_shooting)
    local cond_charging = not cond_clear and is_slow
    local cond_firing = not cond_clear and not is_slow
    -- 状态转移事件
    if cond_clear then
        self.charge_counter = 0
    elseif cond_charging then
        if self.charge_counter < self.max_charge_time then
            self.charge_counter = self.charge_counter + 1
        else
            charge_bullet.create(
                self.x, self.y,
                int(lstg.var.power / 100),
                self.charge_counter)
        end
    elseif cond_firing then
        if self.charge_counter >= self.min_charge_time then
            charge_bullet.create(
                self.x, self.y,
                int(lstg.var.power / 100),
                self.charge_counter)
        end
        self.charge_counter = 0
    end
end

function ExtraPlayer:frame()
    player_class.frame(self)
    -- 状态转移条件
    local has_enough_power = int(lstg.var.power / 100) > 0
    local is_shooting = self.fire > 0.9
    local is_slow = self.slow == 1
    -- 状态转移逻辑
    if not has_enough_power or not is_shooting then
        self.charge_counter = 0
    else
        if is_slow then
            self.charge_counter = self.charge_counter + 1
        end
        if not is_slow or self.charge_counter >= self.max_charge_time then
            if self.charge_counter >= self.min_charge_time then
                charge_bullet.create(self.x, self.y,
                    int(lstg.var.power / 100), self.charge_counter)
            end
            self.charge_counter = 0
        end
    end
end

----------------------------------------------------------------

---随便写个诱导
function charge_bullet.create(x, y, power, counter)
    local self = New(charge_bullet)
    player_bullet_trail.init(self, 'leaf', x, y, 6, 90, nil, 900,
        0.5 * counter * (1 + (power - 1) / 3)) -- 瞎写的伤害计算公式
    self.v = 8
    local scale = counter / 100 + 1
    self.a, self.b = 12 * scale, 12 * scale
    self.hscale, self.vscale = scale, scale
end

function charge_bullet:frame()
    player_class.findtarget(self)
    player_bullet_trail.frame(self)
end

function ExtraPlayer:render()
    player_class.render(self)
    RenderTTF2('sc_name', self.charge_counter, 0, 0, 0, 0, 1, Color(0xffffffff), 'center')
end
