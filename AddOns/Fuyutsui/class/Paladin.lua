local _, fu = ...
if fu.classId ~= 2 then return end

local creat = fu.updateOrCreatTextureByIndex

local dynamicSpells = { "神圣震击", "圣光闪现", "圣光术", "荣耀圣令", "清洁术", "圣疗术" }
local specialSpells = {}
local staticSpells = {
    [1] = "牺牲祝福",
    [2] = "代祷",
    [3] = "圣盾术",
    [4] = "盲目之光",
    [5] = "[@mouseover]保护祝福",
    [6] = "审判",
    [7] = "制裁之锤",
    [8] = "光环掌握",
    [9] = "圣洁鸣钟",
    [10] = "正义盾击",
    [11] = "黎明之光",
    [12] = "[@mouseover]自由祝福",
    [13] = "神圣棱镜",
    [14] = "神圣震击",
    [15] = "公正之剑",
    [16] = "圣洁鸣钟",
    [17] = "处决宣判",
    [18] = "最终审判",
    [19] = "复仇之怒",
    [20] = "灰烬觉醒",
    [21] = "复仇者之盾",
    [22] = "责难",
    [23] = "远古列王守卫",
    [24] = "祝福之锤",
    [25] = "炽热防御者",
    [26] = "[@mouseover]破咒祝福",
    [27] = "神圣风暴",
    [28] = "奉献",
    [29] = "神圣壁垒",
    [30] = "[@player]荣耀圣令",
}

fu.HelpfulSpellId = 19750
fu.HarmfulSpellId = 275773
fu.HarmfulRemoteSpellId = 275773
fu.HarmfulMeleeSpellId = 853

-- 创建圣骑士宏
function fu.CreateClassMacro()
    fu.CreateMacro(dynamicSpells, staticSpells, specialSpells)
end

-- 更新法术成功效果
function fu.updateSpellSuccess(spellID)
    if not fu.blocks or not fu.blocks.auras then return end
    if spellID == 82326 and fu.blocks.auras[414273].applications > 0 then
        fu.blocks.auras[414273].applications = fu.blocks.auras[414273].applications - 1
    end
end

-- 更新法术冷却更新
function fu.updateSpellCooldownByEvent(spellId)
    if not fu.blocks or not fu.blocks.auras then return end
    if fu.blocks.auras[spellId] then
        fu.blocks.auras[spellId].expirationTime = GetTime() + fu.blocks.auras[spellId].duration
        if spellId == 414273 then
            fu.blocks.auras[414273].applications = 2
        end
    end
end

function fu.updateSpellIcon(spellId)
    if not fu.blocks then return end
    local overrideSpellID = C_Spell.GetOverrideSpell(spellId)
    if spellId == 432459 and fu.blocks.holyBulwark then
        if overrideSpellID == 432472 then
            creat(fu.blocks.holyBulwark, 2 / 255)
        else
            creat(fu.blocks.holyBulwark, 1 / 255)
        end
    end
end

-- 更新法术发光效果
function fu.updateSpellOverlay(spellId)
    if not fu.blocks or not fu.blocks.auras then return end
    local isSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed(spellId)
    if spellId == 82326 and fu.blocks.auras[414273] then
        if isSpellOverlayed then
            fu.blocks.auras[414273].expirationTime = GetTime() + fu.blocks.auras[414273].duration
            fu.blocks.auras[414273].applications = 2
        else
            fu.blocks.auras[414273].expirationTime = nil
            fu.blocks.auras[414273].applications = 0
        end
    elseif spellId == 85673 and fu.blocks.auras[327510] then -- 荣耀圣令(闪耀之光)
        fu.blocks.auras[327510].expirationTime = nil
    end
end

-- 更新法术警报, SPELL_ACTIVATION_OVERLAY_SHOW
function fu.spellActivationOverlayShow(spellID)
    if not fu.blocks or not fu.blocks.auras then return end
    if spellID == 223819 and fu.blocks.auras[223819] then
        fu.blocks.auras[223819].expirationTime = GetTime() + fu.blocks.auras[223819].duration
    elseif spellID == 54149 and fu.blocks.auras[54149] then
        fu.blocks.auras[54149].expirationTime = GetTime() + fu.blocks.auras[54149].duration
    end
end

-- 更新法术警报, SPELL_ACTIVATION_OVERLAY_HIDE
function fu.spellActivationOverlayHide(spellID)
    if not fu.blocks or not fu.blocks.auras then return end
    if spellID == 223819 and fu.blocks.auras[223819] then
        fu.blocks.auras[223819].expirationTime = nil
    elseif spellID == 54149 and fu.blocks.auras[54149] then
        fu.blocks.auras[54149].expirationTime = nil
    end
end

function fu.updateOnUpdate()
    if not fu.blocks or not fu.blocks.auras then return end
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

function fu.updateSpecInfo()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    fu.powerType = nil
    fu.blocks = nil
    fu.group_blocks = nil
    fu.assistant_spells = nil
    if specIndex == 1 then
        fu.powerType = "MANA"
        fu.blocks = {
            holyPower = 11,
            target_valid = 12,
            group_type = 13,
            members_count = 14,
            encounterID = 15,
            difficultyID = 16,
            failedSpell = 17,
            auras = {
                [223819] = {
                    name = "神圣意志",
                    index = 18,
                    remaining = 0,
                    duration = 12,
                    expirationTime = nil,
                },
                [54149] = {
                    name = "圣光灌注",
                    index = 19,
                    remaining = 0,
                    duration = 15,
                    expirationTime = nil,
                },
                [414273] = {
                    name = "神性之手",
                    index = 20,
                    remaining = 0,
                    duration = 19.5,
                    applications = 0,
                    expirationTime = nil,
                },
            },
            spell_cd = {
                [20473] = { index = 21, spellId = 20473, name = "神圣震击" },
                [4987] = { index = 22, spellId = 4987, name = "清洁术" },
                [115750] = { index = 23, spellId = 115750, name = "盲目之光", failed = true },
                [275773] = { index = 24, spellId = 275773, name = "审判" },
                [375576] = { index = 25, spellId = 375576, name = "圣洁鸣钟" },
                [114165] = { index = 26, spellId = 114165, name = "神圣棱镜" },
                [31821] = { index = 27, spellId = 31821, name = "光环掌握", failed = true },
                [6940] = { index = 28, spellId = 6940, name = "牺牲祝福" },
                [1044] = { index = 29, spellId = 1044, name = "自由祝福", failed = true },
                [853] = { index = 30, spellId = 853, name = "制裁之锤", failed = true },
                [1022] = { index = 31, spellId = 1022, name = "保护祝福", failed = true },
                [633] = { index = 32, spellId = 633, name = "圣疗术" },
            },
            spell_charge = {
                [20473] = { index = 32, spellId = 20473, name = "神圣震击" },
            },
        }
        fu.group_blocks = {
            unit_start = 40,
            block_num = 6,
            healthPercent = 1,
            role = 2,
            dispel = 3,
            aura = {
                [4] = { 156322 },        -- 永恒之火
                [5] = { 1244893 },       -- 救世道标
                [6] = { 53563, 156910 }, -- 圣光道标, 信仰道标
            },
        }
        fu.assistant_spells = {
        }
    elseif specIndex == 2 then
        fu.HarmfulSpellId = 275779
        fu.powerType = "MANA"
        fu.blocks = {
            holyPower = 11,
            target_valid = 12,
            assistant = 13,
            failedSpell = 14,
            holyBulwark = 15,
            auras = {
                [223819] = {
                    name = "神圣意志",
                    index = 16,
                    remaining = 0,
                    duration = 12,
                    expirationTime = nil,
                },
                [432496] = {
                    name = "神圣壁垒",
                    index = 17,
                    remaining = 0,
                    duration = 20,
                    expirationTime = nil,
                },
                [432502] = {
                    name = "圣洁武器",
                    index = 18,
                    remaining = 0,
                    duration = 20,
                    expirationTime = nil,
                },
                [327510] = {
                    name = "闪耀之光",
                    index = 19,
                    remaining = 0,
                    duration = 30,
                    expirationTime = nil,
                },
            },
            spell_cd = {
                [213644] = { index = 21, spellId = 213644, name = "清毒术" },
                [115750] = { index = 22, spellId = 115750, name = "盲目之光", failed = true },
                [275779] = { index = 23, spellId = 275779, name = "审判" },
                [375576] = { index = 24, spellId = 375576, name = "圣洁鸣钟" },
                [6940] = { index = 25, spellId = 6940, name = "牺牲祝福" },
                [1044] = { index = 26, spellId = 1044, name = "自由祝福", failed = true },
                [853] = { index = 27, spellId = 853, name = "制裁之锤", failed = true },
                [1022] = { index = 28, spellId = 1022, name = "保护祝福", failed = true },
                [432459] = { index = 29, spellId = 432459, name = "神圣壁垒" },
                [31935] = { index = 31, spellId = 31935, name = "复仇者之盾" },
                [26573] = { index = 32, spellId = 26573, name = "奉献" },
                [53600] = { index = 33, spellId = 53600, name = "正义盾击" },
                [204019] = { index = 34, spellId = 204019, name = "祝福之锤" },
            },
            spell_charge = {
                [432459] = { index = 30, spellId = 432459, name = "神圣壁垒" },
            },
        }
        fu.assistant_spells = {
            [375576] = 1, -- 圣洁鸣钟
            [31935] = 2,  -- 复仇者之盾
            [26573] = 3,  -- 奉献
            [275779] = 4, -- 审判
            [53600] = 5,  -- 正义盾击
            [204019] = 6, -- 祝福之锤
        }
        fu.updateSpellIcon(432459)
    elseif specIndex == 3 then
        fu.HarmfulSpellId = 20271
        fu.powerType = "MANA"
        fu.blocks = {
            holyPower = 11,
            target_valid = 12,
            assistant = 13,
            failedSpell = 14,
            auras = {
                [223819] = {
                    name = "神圣意志",
                    index = 16,
                    remaining = 0,
                    duration = 12,
                    expirationTime = nil,
                },
            },
            spell_cd = {
                [213644] = { index = 31, spellId = 213644, name = "清毒术" },
                [115750] = { index = 32, spellId = 115750, name = "盲目之光", failed = true },
                [20271] = { index = 33, spellId = 20271, name = "审判" },
                [375576] = { index = 34, spellId = 375576, name = "圣洁鸣钟" },
                [6940] = { index = 35, spellId = 6940, name = "牺牲祝福" },
                [1044] = { index = 36, spellId = 1044, name = "自由祝福", failed = true },
                [853] = { index = 37, spellId = 853, name = "制裁之锤", failed = true },
                [1022] = { index = 38, spellId = 1022, name = "保护祝福", failed = true },
                [184575] = { index = 39, spellId = 184575, name = "公正之剑" },
                [343527] = { index = 40, spellId = 343527, name = "处决宣判" },
                [255937] = { index = 41, spellId = 255937, name = "灰烬觉醒" },
            },
            spell_charge = {
                [20271] = { index = 42, spellId = 20271, name = "审判充能" },
            },
        }
        fu.assistant_spells = {
            [184575] = 1, -- 公正之剑
            [375576] = 2, -- 圣洁鸣钟
            [20271] = 3,  -- 审判
            [383328] = 4, -- 最终审判
            [255937] = 5, -- 灰烬觉醒
            [53385] = 6,  -- 神圣风暴
            [427453] = 7, -- 圣光之锤(灰烬觉醒)
            [24275] = 8,  -- 愤怒之锤(审判)
            [343527] = 9, -- 处决宣判
        }
    end
end
