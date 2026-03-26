local _, fu = ...
if fu.classId ~= 9 then return end
local creat = fu.updateOrCreatTextureByIndex

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

fu.HarmfulSpellId, fu.HelpfulSpellId = 686, 2061
local dynamicSpells = {}
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
    fu.CreateMacro(dynamicSpells, staticSpells)
end

function fu.updateSpellSuccess(spellID)
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

function fu.updateSpellOverride(baseSpellID, overrideSpellID)
    if not fu.blocks or not fu.blocks.auras then return end
end

function fu.updateSpellIcon(spellId)
    if not fu.blocks or not fu.blocks.auras then return end
    local overrideSpellID = C_Spell.GetOverrideSpell(spellId)
end

-- 更新法术发光效果
function fu.updateSpellOverlay(spellId)
    if not fu.blocks or not fu.blocks.auras then return end
    --[[if spellId == 2061 then
        local isSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed(spellId)
        if isSpellOverlayed then
            fu.blocks.auras.lightBurst.expirationTime = GetTime() + fu.blocks.auras.lightBurst.duration
        else
            fu.blocks.auras.lightBurst.expirationTime = nil
        end
    end]]
end

-- 更新法术警报, SPELL_ACTIVATION_OVERLAY_SHOW
function fu.spellActivationOverlayShow(spellID)
    if not fu.blocks.auras then return end
end

-- 更新法术警报, SPELL_ACTIVATION_OVERLAY_HIDE
function fu.spellActivationOverlayHide(spellID)
    if not fu.blocks.auras then return end
end

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
                [132409] = {
                    index = 19,
                    name = "魔典：邪能破坏者",
                    remaining = 0,
                    duration = 120,
                    expirationTime = nil,
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
        }
    end
end

function fu.updateHeroTalent()
    if fu.blocks and fu.blocks.hero_talent then
        local hero_talent = 0
        if C_SpellBook.IsSpellKnown(428514) then
            hero_talent = 1
        elseif C_SpellBook.IsSpellKnown(449614) then
            hero_talent = 2
        end
        creat(fu.blocks.hero_talent, hero_talent / 255)
    end
end

function fu.updateOnUpdate()
    if not fu.blocks then return end
    local wildImpCount = GetCurrentImpCount()
    creat(fu.blocks.wildImpCount, wildImpCount / 255)
    if not fu.blocks.auras then return end
    for _, aura in pairs(fu.blocks.auras) do
        if aura.expirationTime then
            aura.remaining = math.floor(aura.expirationTime - GetTime() + 0.5)
            if aura.remaining > 0 then
                creat(aura.index, aura.remaining / 255)
            else
                aura.expirationTime = nil
                creat(aura.index, 0)
            end
        else
            aura.remaining = 0
            creat(aura.index, 0)
        end
        if aura.applications and aura.applications <= 0 then
            aura.expirationTime = nil
            creat(aura.index, 0)
        end
    end
end
