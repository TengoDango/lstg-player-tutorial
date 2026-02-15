---手写子机系统 (殿魔A)

ExtraPlayer = Class(player_class)

function ExtraPlayer:init()
    player_class.init(self)
    ExtraPlayer.InitSupports(self)
    self.imgs = {}
    for i = 1, 24 do self.imgs[i] = 'white' end
end

function ExtraPlayer:frame()
    player_class.frame(self)
    ExtraPlayer.UpdateSupports(self)
    ExtraPlayer.UpdateVariables(self)
end

function ExtraPlayer:render()
    ExtraPlayer.RenderSupports(self)
    player_class.render(self)
end

---子机信息初始化
function ExtraPlayer:InitSupports()
    self.spinfo = {
        ---数组部分类似sp表, 每帧更新子机信息
        { 0, 0 },
        { 0, 0 },
        { 0, 0 },
        { 0, 0 },

        ---类似slist表
        list = {},
        ---最大子机数量
        num = 8,

        ---平滑跟随火力等级 (0~8P)
        power = int(lstg.var.power / 50),
        ---平滑跟随高低速状态 (0~1)
        slow = 0,
        ---平滑跟随自机坐标
        x = self.x,
        y = self.y,
        ---各子机的有效性 (0~1)
        valid = {},
    }
    -- 地灵殿魔A的子机位置
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

---线性插值 (两个表)
---@param t number
---@param A number[]
---@param B number[]
---@return number[]
local function mix_table(t, A, B)
    local C = {}
    for i = 1, #A do
        C[i] = (1 - t) * A[i] + t * B[i]
    end
    return C
end

---线性插值 (一个表的左右半边)
---@param t number
---@param A number[]
---@return number[]
local function mix_in_table(t, A)
    local B = {}
    local n = #A / 2
    for i = 1, n do
        B[i] = (1 - t) * A[i] + t * A[i + n]
    end
    return B
end

---子机信息更新
function ExtraPlayer:UpdateSupports()
    local sp = self.spinfo
    if not self.time_stop then
        local s = int(sp.power) + 1
        local t = sp.power - int(sp.power)
        for i = 1, sp.num do
            local valid0 = sp.list[s][i]
            local valid1 = sp.list[s + 1] and sp.list[s + 1][i]

            -- 插值实现平滑过渡
            if valid0 and valid1 then
                sp[i] = mix_table(t,
                    mix_in_table(sp.slow, sp.list[s][i]),
                    mix_in_table(sp.slow, sp.list[s + 1][i]))
                sp.valid[i] = 1
            elseif valid0 and not valid1 then
                sp[i] = mix_in_table(sp.slow, sp.list[s][i])
                sp.valid[i] = 1 - t
            elseif not valid0 and valid1 then
                sp[i] = mix_in_table(sp.slow, sp.list[s + 1][i])
                sp.valid[i] = t
            else -- not valid0 and not valid1
                sp.valid[i] = 0
            end
        end
    end
end

---相关属性更新
function ExtraPlayer:UpdateVariables()
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

    -- 2. 高低速状态更新
    if self.slow == 1 then
        sp.slow = min(1, sp.slow + 0.15)
    else
        sp.slow = max(0, sp.slow - 0.15)
    end

    -- 3. 自机坐标更新
    sp.x = sp.x * 0.7 + self.x * 0.3
    sp.y = sp.y * 0.7 + self.y * 0.3
end

---渲染子机
function ExtraPlayer:RenderSupports()
    local sp = self.spinfo
    for i = 1, sp.num do
        Render('parimg15', sp.x + sp[i][1], sp.y + sp[i][2], 0, sp.valid[i], 1)
    end
end
