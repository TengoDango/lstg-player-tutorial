---手写子机系统 (殿魔A)

ExtraPlayer = Class(player_class)

---子机信息初始化
function ExtraPlayer:init()
    player_class.init(self)
    self.imgs = {}
    for i = 1, 24 do self.imgs[i] = 'white' end

    ---(自定义属性) 记录子机信息
    self.spinfo = {
        ---数组部分类似sp表, 每帧更新子机信息
        -- { 0, 0 }, { 0, 0 }, ...

        ---类似slist表
        list = {},
        ---平滑跟随火力等级 (0~8P)
        power = int(lstg.var.power / 50),
        ---最大子机数量
        num = 8,
        ---各子机的有效性 (0~1)
        valid = {},
    }
    local slist = self.spinfo.list
    for power = 0, 8 do
        local data = {}
        local da = 180 / 7
        local spread = da * (power - 1) / 2
        for i = 1, power do
            data[i] = {
                32 * cos(-90 - spread + da * (i - 1)),
                32 * sin(-90 - spread + da * (i - 1)),
                32 * cos(-90 + spread - da * (i - 1)),
                32 * sin(-90 + spread - da * (i - 1)),
            }
        end
        slist[power + 1] = data
    end
    -- 补全剩余数据
    ExtraPlayer.UpdateSupports(self)
end

function ExtraPlayer:frame()
    player_class.frame(self)
    ExtraPlayer.UpdateSupports(self)
end

---更新子机系统
function ExtraPlayer:UpdateSupports()
    local sp = self.spinfo

    -- 1. 火力等级更新

    local power = int(lstg.var.power / 50)
    if sp.power > power then
        sp.power = sp.power - 0.1
    elseif sp.power < power then
        sp.power = sp.power + 0.1
    end
    if abs(sp.power - power) < 0.1 then
        sp.power = power
    end

    -- 2. 子机slist表更新

    if not self.time_stop then
        local s = int(sp.power) + 1
        local t = sp.power - int(sp.power)
        for i = 1, sp.num do
            local valid0 = sp.list[s][i]
            local valid1 = sp.list[s + 1] and sp.list[s + 1][i]

            if valid0 and valid1 then
                sp[i] = MixTable(t,
                    MixTable(self.lh, sp.list[s][i]),
                    MixTable(self.lh, sp.list[s + 1][i]))
                sp.valid[i] = 1
            elseif valid0 and not valid1 then
                sp[i] = MixTable(self.lh, sp.list[s][i])
                sp.valid[i] = 1 - t
            elseif not valid0 and valid1 then
                sp[i] = MixTable(self.lh, sp.list[s + 1][i])
                sp.valid[i] = t
            else
                -- 此时sp[i]可能不存在, 使用时需要判断
                -- 如果sp的数组部分被合适地初始化, 那么sp[i]一定存在
                sp.valid[i] = 0
            end
        end
    end
end

---渲染子机
function ExtraPlayer:render()
    local sp = self.spinfo
    for i = 1, sp.num do
        if sp[i] then
            Render('parimg16', self.supportx + sp[i][1], self.supporty + sp[i][2], 0, sp.valid[i] / 2, 1 / 2)
        end
    end
    player_class.render(self)
end
