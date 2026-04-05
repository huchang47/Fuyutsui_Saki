local _, fu = ...
if fu.classId ~= 9 then return end
local creat = fu.updateOrCreatTextureByIndex
fu.HarmfulSpellId, fu.HelpfulSpellId = 686, 2061

fu.heroSpell = {
    [445486] = 1, -- 地狱召唤者
    [449614] = 2, -- 灵魂收割者
    [428514] = 3, -- 恶魔使徒
}

function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.group_blocks = nil
    fu.assistant_spells = nil
    if specIndex == 1 then
    elseif specIndex == 2 then
        fu.powerType = "MANA"
        fu.blocks = {
            assistant = 11,
            target_valid = 12,
            failedSpell = 13,
            hero_talent = 14,
            encounterID = 15,
            difficultyID = 16,
            wildImpCount = 17,
            soulShards = 18,
            auras = {
                ["魔典：邪能破坏者"] = {
                    index = 19,
                    auraRef = fu.updateAuras.byIcon[1276467],
                    showKey = "isIcon",
                },
            },
            castingSpell = 20,
            spell_cd = {
                [5782] = { index = 31, name = "恐惧", failed = true },
                [6789] = { index = 32, name = "死亡缠绕", failed = true },
                [20707] = { index = 33, name = "灵魂石" },
                [30283] = { index = 34, name = "暗影之怒", failed = true },
                [333889] = { index = 35, name = "邪能统御" },
                [108416] = { index = 36, name = "黑暗契约" },
                [196277] = { index = 37, name = "内爆", failed = true },
                [265187] = { index = 38, name = "召唤恶魔暴君", failed = true },
                [1276467] = { index = 39, name = "魔典：邪能破坏者", failed = true },
                [105174] = { index = 40, name = "古尔丹之手" },
                [1276672] = { index = 41, name = "召唤末日守卫", failed = true },
                [104316] = { index = 42, name = "召唤恐惧猎犬" },
                [264187] = { index = 43, name = "恶魔之箭", failed = true },
                [1276452] = { index = 44, name = "魔典：小鬼领主" },
                [1271748] = { index = 45, name = "虚弱灾厄" },
                [1271802] = { index = 46, name = "语言灾厄" },
                [132409] = { index = 47, name = "法术封锁" },
                [30146] = { index = 48, name = "召唤恶魔卫士" },
                [686] = { index = 49, name = "暗影箭" },
            },
        }
        fu.assistant_spells = {
            [105174] = 1,  -- 古尔丹之手
            [104316] = 2,  -- 召唤恐惧猎犬
            [30146] = 3,   -- 召唤恶魔卫士
            [264178] = 4,  -- 恶魔之箭
            [686] = 5,     -- 暗影箭
            [691] = 6,     -- 召唤地狱猎犬
            [688] = 7,     -- 召唤小鬼
            [1271748] = 8, -- 虚弱灾厄
            [1271802] = 9, -- 语言灾厄
            [434635] = 10, -- 陨灭(古尔丹之手)
            [434506] = 11, -- 狱火箭(暗影箭)
        }
    end
end

local staticSpells = {
    [1] = "恐惧",
    [2] = "死亡缠绕",
    [3] = "灵魂石",
    [4] = "[@cursor]暗影之怒",
    [5] = "邪能统御",
    [6] = "黑暗契约",
    [7] = "内爆",
    [8] = "召唤恶魔暴君",
    [9] = "魔典：邪能破坏者",
    [10] = "古尔丹之手",
    [11] = "召唤末日守卫",
    [12] = "召唤恐惧猎犬",
    [13] = "恶魔之箭",
    [14] = "魔典：小鬼领主",
    [15] = "虚弱灾厄",
    [16] = "语言灾厄",
    [17] = "召唤恶魔卫士",
    [18] = "法术封锁",
    [19] = "暗影箭",

}

function fu.CreateClassMacro()
    fu.CreateMacro({}, staticSpells)
end

-- ================================================================
--                          小鬼数量检测
-- ================================================================

-- 初始化数据结构
local WildImps = {}
local handOfGuldan = 105174 -- 古尔丹之手, 召唤3个"野生小鬼"
local Implosion = 196277    -- 内爆, 消耗6个"野生小鬼"，每2个返还1个
local Imp_Duration = 11     -- "野生小鬼"持续时间11秒

-- 清理过期的小鬼并返回当前数量
local function GetCurrentImpCount()
    local currentTime = GetTime()
    for i = #WildImps, 1, -1 do
        if WildImps[i] <= currentTime then
            table.remove(WildImps, i)
        end
    end
    return #WildImps
end

local function updateSpellSuccess(spellID)
    if not fu.blocks then return end
    local currentTime = GetTime()
    if fu.blocks.auras[spellID] then
        fu.blocks.auras[spellID].expirationTime = currentTime + fu.blocks.auras[spellID].duration
    elseif spellID == handOfGuldan then
        for i = 1, 3 do
            table.insert(WildImps, currentTime + Imp_Duration)
        end
    elseif spellID == Implosion then
        local currentCount = GetCurrentImpCount()
        local toConsume = math.min(currentCount, 6) -- 最多消耗6个
        local toRefund = math.floor(toConsume / 2)  -- 每2个返还1个
        local netLoss = toConsume - toRefund        -- 实际从队列移除的数量
        for i = 1, netLoss do
            if #WildImps > 0 then
                table.remove(WildImps, 1)
            end
        end
    end
end

local function updateOnUpdate()
    if not fu.blocks then return end
    local wildImpCount = GetCurrentImpCount()
    creat(fu.blocks.wildImpCount, wildImpCount / 255)
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
function frame:UNIT_SPELLCAST_SUCCEEDED(unitTarget, castGUID, spellID, castBarID)
    if not issecretvalue(spellID) then
        updateSpellSuccess(spellID)
    end
end

local timer10 = 0
frame:SetScript("OnUpdate", function(_, update)
    timer10 = timer10 + update
    if timer10 >= 1 then
        updateOnUpdate()
        timer10 = 0
    end
end)
