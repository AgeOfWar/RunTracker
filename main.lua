local mod = RegisterMod("[F9] Run Tracker", 1)
local json = require("json")

if not InputHelper then
    require("scripts.inputhelper")
    if not InputHelper then
        error("Mod Config Menu requires Input Helper to function", 2)
    end
end

if not ScreenHelper then
    require("scripts.screenhelper")
    if not ScreenHelper then
        error("Mod Config Menu requires Screen Helper to function", 2)
    end
end

local statsMenuSprite = Sprite()
statsMenuSprite:Load("gfx/ui/runstats/menu.anm2", true)
statsMenuSprite:SetFrame("Idle", 0)
local cursorSpriteRight = Sprite()
cursorSpriteRight:Load("gfx/ui/runstats/menu.anm2", true)
cursorSpriteRight:SetFrame("Cursor", 0)
local cursorSpriteLeft = Sprite()
cursorSpriteLeft:Load("gfx/ui/runstats/menu.anm2", true)
cursorSpriteLeft:SetFrame("Cursor", 3)
local hudSprite = Sprite()
hudSprite:Load("gfx/ui/hudstats2.anm2", true)
hudSprite.Color = Color(1, 1, 1, 0.5)
hudSprite:SetFrame("Idle", 9)

local font16Bold = Font()
font16Bold:Load("font/teammeatfont16bold.fnt")
local font12 = Font()
font12:Load("font/teammeatfont12.fnt")
local font10 = Font()
font10:Load("font/teammeatfont10.fnt")
local hudFont = Font()
hudFont:Load("font/luaminioutlined.fnt")

local titleColor = KColor(34 / 255, 32 / 255, 30 / 255, 1)
local selectedColor = KColor(34 / 255, 32 / 255, 30 / 255, 1)
local unselectedColor = KColor(34 / 255, 32 / 255, 30 / 255, 0.5)
local textColor = KColor(34 / 255, 32 / 255, 30 / 255, 1)
local hintColor = KColor(1, 1, 1, 0.4)

mod.statsMenuOpen = false
mod.statsMenuSelectedCharacter = PlayerType.PLAYER_ISAAC
mod.players = {
    [0] = "Isaac",
    [1] = "Magdalene",
    [2] = "Cain",
    [3] = "Judas",
    [4] = "???",
    [5] = "Eve",
    [6] = "Samson",
    [7] = "Azazel",
    [8] = "Lazarus",
    [9] = "Eden",
    [10] = "The Lost",
    [13] = "Lilith",
    [14] = "Keeper",
    [15] = "Apollyon",
    [16] = "The Forgotten",
    [18] = "Bethany",
    [19] = "Jacob & Esau",

    [21] = "Tainted Isaac",
    [22] = "Tainted Magdalene",
    [23] = "Tainted Cain",
    [24] = "Tainted Judas",
    [25] = "Tainted ???",
    [26] = "Tainted Eve",
    [27] = "Tainted Samson",
    [28] = "Tainted Azazel",
    [29] = "Tainted Lazarus",
    [30] = "Tainted Eden",
    [31] = "Tainted The Lost",
    [32] = "Tainted Lilith",
    [33] = "Tainted Keeper",
    [34] = "Tainted Apollyon",
    [35] = "T. The Forgotten",
    [36] = "Tainted Bethany",
    [37] = "Tainted Jacob"
}
mod.gameModes = {
    [Difficulty.DIFFICULTY_NORMAL] = "Normal",
    [Difficulty.DIFFICULTY_HARD] = "Hard",
    [Difficulty.DIFFICULTY_GREED] = "Greed",
    [Difficulty.DIFFICULTY_GREEDIER] = "Greedier"
}
mod.warnTime = 0

local function SaveData()
    Isaac.SaveModData(mod, json.encode(mod.data))
end

local function ResetData()
    local currentPlayerType = nil
    local currentDifficulty = nil
    local hudOffset = 196
    local hudData = "globalData.longestStreak"
    local openStatsMenuKey = Keyboard.KEY_F9
    if mod.data then
        currentPlayerType = mod.data.currentPlayerType
        currentDifficulty = mod.data.currentDifficulty
        hudOffset = mod.data.hudOffset
        hudData = mod.data.hudData
        openStatsMenuKey = mod.data.openStatsMenuKey or Keyboard.KEY_F9
    end
    mod.data = {
        openStatsMenuKey = openStatsMenuKey,
        hudOffset = hudOffset,
        hudData = hudData,
        currentPlayerType = currentPlayerType,
        currentDifficulty = currentDifficulty,
        playerData = {},
        globalData = {
            [tostring(Difficulty.DIFFICULTY_NORMAL)] = {
                streak = 0,
                longestStreak = 0
            },
            [tostring(Difficulty.DIFFICULTY_HARD)] = {
                streak = 0,
                longestStreak = 0
            },
            [tostring(Difficulty.DIFFICULTY_GREED)] = {
                streak = 0,
                longestStreak = 0
            },
            [tostring(Difficulty.DIFFICULTY_GREEDIER)] = {
                streak = 0,
                longestStreak = 0
            },
        }
    }
    for playerType, _ in pairs(mod.players) do
        mod.data.playerData[tostring(playerType)] = {
            [tostring(Difficulty.DIFFICULTY_NORMAL)] = {
                wins = 0,
                deaths = 0,
                resets = 0,
                playTime = 0,
                streak = 0,
                longestStreak = 0
            },
            [tostring(Difficulty.DIFFICULTY_HARD)] = {
                wins = 0,
                deaths = 0,
                resets = 0,
                playTime = 0,
                streak = 0,
                longestStreak = 0
            },
            [tostring(Difficulty.DIFFICULTY_GREED)] = {
                wins = 0,
                deaths = 0,
                resets = 0,
                playTime = 0,
                streak = 0,
                longestStreak = 0
            },
            [tostring(Difficulty.DIFFICULTY_GREEDIER)] = {
                wins = 0,
                deaths = 0,
                resets = 0,
                playTime = 0,
                streak = 0,
                longestStreak = 0
            }
        }
    end
    SaveData()
end

local function GetSaveData()
    if Isaac.HasModData(mod) then
        mod.data = json.decode(Isaac.LoadModData(mod))
        if not mod.data.openStatsMenuKey then
            mod.data.openStatsMenuKey = Keyboard.KEY_F9
            SaveData()
        end
    else
        ResetData()
    end
end

local function GetSumPlayerData(difficulty, data)
    local sum = 0
    for _, playerData in pairs(mod.data.playerData) do
        sum = sum + playerData[tostring(difficulty)][data]
    end
    return sum
end

local function PreviousPlayerType(type)
    if type == 0 then
        return 19
    end
    if type == 21 then
        return 37
    end
    local i = type - 1
    while not mod.players[i] do
        i = i - 1
    end
    return i
end

local function NextPlayerType(type)
    if type == 37 then
        return 21
    end
    if type == 19 then
        return 0
    end
    local i = type + 1
    while not mod.players[i] do
        i = i + 1
    end
    return i
end

local function NextTaintedPlayerType(type)
    local map = {
        [0]  = 21,
        [1]  = 22,
        [2]  = 23,
        [3]  = 24,
        [4]  = 25,
        [5]  = 26,
        [6]  = 27,
        [7]  = 28,
        [8]  = 29,
        [9]  = 30,
        [10] = 31,
        [13] = 32,
        [14] = 33,
        [15] = 34,
        [16] = 35,
        [18] = 36,
        [19] = 37,

        [21] = 0,
        [22] = 1,
        [23] = 2,
        [24] = 3,
        [25] = 4,
        [26] = 5,
        [27] = 6,
        [28] = 7,
        [29] = 8,
        [30] = 9,
        [31] = 10,
        [32] = 13,
        [33] = 14,
        [34] = 15,
        [35] = 16,
        [36] = 18,
        [37] = 19
    }
    return map[type]
end

local function RoomIsSafe()
    local roomHasDanger = false

    for _, entity in pairs(Isaac.GetRoomEntities()) do
        if entity:IsActiveEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
            roomHasDanger = true
        elseif entity.Type == EntityType.ENTITY_PROJECTILE and entity:ToProjectile().ProjectileFlags & ProjectileFlags.CANT_HIT_PLAYER ~= 1 then
            roomHasDanger = true
        elseif entity.Type == EntityType.ENTITY_BOMBDROP then
            roomHasDanger = true
        end
    end

    local game = Game()
    local room = game:GetRoom()

    if room:IsClear() and not roomHasDanger then
      return true
    end

    return false
end

local function OpenStatsMenu()
    if RoomIsSafe() then
        mod.statsMenuSelectedCharacter = mod.data.currentPlayerType or Isaac.GetPlayer(0):GetPlayerType()
        mod.statsMenuOpen = true
        if ModConfigMenu then
            ModConfigMenu.CloseConfigMenu()
        end
        Game():GetHUD():SetVisible(false)
    else
        local sfx = SFXManager()
        sfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ, 0.75, 0, false, 1)
    end
end

local function CloseStatsMenu()
    mod.statsMenuOpen = false
    if Game():GetRoom():GetType() == RoomType.ROOM_DUNGEON and Game():GetLevel():GetAbsoluteStage() == LevelStage.STAGE8 then -- The Beast fight
        return
    end
    Game():GetHUD():SetVisible(true)
end

local function ToggleStatsMenu()
    if mod.statsMenuOpen then
        CloseStatsMenu()
    else
        OpenStatsMenu()
    end
end

local function DrawString(s, x, y, color, font)
    if not pcall(function ()
        (font or font10):DrawString(s, x, y, color, 0, true)
    end) then
        Isaac.DebugString("Error: Cannot DrawString('" .. s .. "').")
    end
end

local function DrawTitle(s, x, y, color, font)
    if not pcall(function ()
        DrawString(s, x, y, color, font or font16Bold)
    end) then
        Isaac.DebugString("Error: Cannot DrawString('" .. s .. "').")
    end
end

local function KeyboardTriggered(key)
    for i = 0, 4 do
        if InputHelper.KeyboardTriggered(key, i) then
            return true
        end
    end
    return false
end

local function ButtonPressed(key)
    for i = 0, 4 do
        if Input.IsButtonPressed(key, i) then
            return true
        end
    end
    return false
end

local function TimeToString(time)
    if time ~= time then
        return "N/A"
    end
    local t = math.floor(time) // 30
    local s = math.fmod(t, 60)
    local m = math.fmod(t // 60, 60)
    local h = t // 3600
    if h > 0 then
        return h .. "h" .. m .. "m"
    else
        return m .. "m" .. s .. "s"
    end
end

local function RenderStatsMenu()
    local center = ScreenHelper.GetScreenCenter()

    statsMenuSprite:Render(center, Vector(0,0), Vector(0,0))
    DrawTitle("Statistics", 265, 17, titleColor)
    local slot = 0
    if mod.statsMenuSelectedCharacter <= 19 then
        for i = 0, 19 do
            local player = mod.players[i]
            if player then
                DrawString(player, 53, 33 + slot * 12, i == mod.statsMenuSelectedCharacter and selectedColor or unselectedColor)
                slot = slot + 1
            end
        end
        cursorSpriteRight:Render(Vector(160, 135), Vector(0,0), Vector(0,0))
    else
        for i = 21, 38 do
            local player = mod.players[i]
            if player then
                DrawString(player, 53, 33 + slot * 12, i == mod.statsMenuSelectedCharacter and selectedColor or unselectedColor)
                slot = slot + 1
            end
        end
        cursorSpriteLeft:Render(Vector(160, 135), Vector(0,0), Vector(0,0))
    end

    local difficulty = mod.data.currentDifficulty or Game().Difficulty

    local globalData = mod.data.globalData[tostring(difficulty)]
    local globalWins = GetSumPlayerData(difficulty, "wins")
    local globalDeaths = GetSumPlayerData(difficulty, "deaths")
    local globalCompletedRuns = globalWins + globalDeaths
    local globalWinrate = globalWins / globalCompletedRuns
    local globalResets = GetSumPlayerData(difficulty, "resets")
    local globalWinrateString = globalWinrate ~= globalWinrate and "N/A" or (string.format("%.2f", globalWinrate * 100) .. "%")
    local globalStreak = globalData.streak
    local globalLongestStreak = globalData.longestStreak
    local globalPlayTime = GetSumPlayerData(difficulty, "playTime")

    local modeData = mod.data.playerData[tostring(mod.statsMenuSelectedCharacter)][tostring(difficulty)]
    local modeWins = modeData.wins
    local modeDeaths = modeData.deaths
    local modeCompletedRuns = modeWins + modeDeaths
    local modeWinrate = modeWins / modeCompletedRuns
    local modeResets = modeData.resets
    local modeWinrateString = modeWinrate ~= modeWinrate and "N/A" or (string.format("%.2f", modeWinrate * 100) .. "%")
    local modeStreak = modeData.streak
    local modeLongestStreak = modeData.longestStreak
    local modePlayTime = modeData.playTime
    local modeAverageRunDuration = modeData.playTime / modeCompletedRuns

    local globalOffset = 52
    DrawString(mod.gameModes[difficulty] .. " (All characters)", 200, globalOffset - 2, textColor, font12)
    DrawString("Winrate: " .. globalWinrateString, 200, globalOffset + 13, textColor)
    DrawString("Play time: " .. TimeToString(globalPlayTime), 310, globalOffset + 13, textColor)
    DrawString("Streak: " .. globalStreak, 200, globalOffset + 26, textColor)
    DrawString("Longest streak: " .. globalLongestStreak, 310, globalOffset + 26, textColor)
    DrawString("Wins: " .. globalWins, 200, globalOffset + 39, textColor)
    DrawString("Deaths: " .. globalDeaths, 310, globalOffset + 39, textColor)
    DrawString("Completed runs: " .. globalCompletedRuns, 200, globalOffset + 52, textColor)
    DrawString("Resets: " .. globalResets, 200, globalOffset + 65, textColor)

    local modeOffset = 142
    DrawString(mod.gameModes[difficulty] .. " (" .. mod.players[mod.statsMenuSelectedCharacter] .. ")", 200, modeOffset - 2, textColor, font12)
    DrawString("Winrate: " .. modeWinrateString, 200, modeOffset + 13, textColor)
    DrawString("Play time: " .. TimeToString(modePlayTime), 310, modeOffset + 13, textColor)
    DrawString("Streak: " .. modeStreak, 200, modeOffset + 26, textColor)
    DrawString("Longest streak: " .. modeLongestStreak, 310, modeOffset + 26, textColor)
    DrawString("Wins: " .. modeWins, 200, modeOffset + 39, textColor)
    DrawString("Deaths: " .. modeDeaths, 310, modeOffset + 39, textColor)
    DrawString("Completed runs: " .. modeCompletedRuns, 200, modeOffset + 52, textColor)
    DrawString("Resets: " .. modeResets, 200, modeOffset + 65, textColor)
    DrawString("Average run duration: " .. TimeToString(modeAverageRunDuration), 200, modeOffset + 78, textColor)

    DrawString("Hold SHIFT to modify HUD", 200, 248, hintColor)
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    local game = Game()
    local isPaused = game:IsPaused() or AwaitingTextInput
    local editLayout = mod.statsMenuOpen and ButtonPressed(Keyboard.KEY_LEFT_SHIFT) and not ButtonPressed(Keyboard.KEY_LEFT_CONTROL)

    if not isPaused then
        if KeyboardTriggered(mod.data.openStatsMenuKey) then
            ToggleStatsMenu()
        end

        if mod.warnTime > 0 then
            DrawString("Run Tracker will be enabled from the next run", 100, ScreenHelper.GetScreenBottomRight(0).Y - 64, KColor(1, 1, 1, math.min(mod.warnTime / 10, 1) - 0.5))
            mod.warnTime = mod.warnTime - 1
        end
    end

    if mod.statsMenuOpen then
        game:GetHUD():SetVisible(editLayout)

        if not RoomIsSafe() then
            CloseStatsMenu()
            sfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ, 0.75, 0, false, 1)
        end
        if isPaused then
            CloseStatsMenu()
        end
        if ModConfigMenu and ModConfigMenu.IsVisible then
            CloseStatsMenu()
            game:GetHUD():SetVisible(false)
        end
        if InputHelper.MultipleButtonTriggered({ Controller.BUTTON_B }) then
            CloseStatsMenu()
        end
        if InputHelper.MultipleActionTriggered({ ButtonAction.ACTION_MAP, ButtonAction.ACTION_MENUBACK }) then
            CloseStatsMenu()
        end

        if editLayout then
            if KeyboardTriggered(Keyboard.KEY_DOWN) or KeyboardTriggered(Keyboard.KEY_S) then
                if mod.data.hudOffset < 233 then
                    mod.data.hudOffset = mod.data.hudOffset + 12.2
                    SaveData()
                end
            end
            if KeyboardTriggered(Keyboard.KEY_UP) or KeyboardTriggered(Keyboard.KEY_W) then
                if mod.data.hudOffset > 184 then
                    mod.data.hudOffset = mod.data.hudOffset - 12.2
                    SaveData()
                end
            end
            if KeyboardTriggered(Keyboard.KEY_RIGHT) or KeyboardTriggered(Keyboard.KEY_D) then
                if mod.data.hudData == "globalData.streak" then
                    mod.data.hudData = "playerData.streak"
                elseif mod.data.hudData == "playerData.streak" then
                    mod.data.hudData = "globalData.longestStreak"
                elseif mod.data.hudData == "globalData.longestStreak" then
                    mod.data.hudData = "playerData.longestStreak"
                elseif mod.data.hudData == "playerData.longestStreak" then
                    mod.data.hudData = "globalData.wins"
                elseif mod.data.hudData == "globalData.wins" then
                    mod.data.hudData = "playerData.wins"
                elseif mod.data.hudData == "playerData.wins" then
                    mod.data.hudData = "disabled"
                else
                    mod.data.hudData = "globalData.streak"
                end
                SaveData()
            end
            if KeyboardTriggered(Keyboard.KEY_LEFT) or KeyboardTriggered(Keyboard.KEY_A) then
                if mod.data.hudData == "globalData.streak" then
                    mod.data.hudData = "disabled"
                elseif mod.data.hudData == "playerData.streak" then
                    mod.data.hudData = "globalData.streak"
                elseif mod.data.hudData == "globalData.longestStreak" then
                    mod.data.hudData = "playerData.streak"
                elseif mod.data.hudData == "playerData.longestStreak" then
                    mod.data.hudData = "globalData.longestStreak"
                elseif mod.data.hudData == "globalData.wins" then
                    mod.data.hudData = "playerData.longestStreak"
                elseif mod.data.hudData == "playerData.wins" then
                    mod.data.hudData = "globalData.wins"
                elseif mod.data.hudData == "disabled" then
                    mod.data.hudData = "globalData.streak"
                else
                    mod.data.hudData = "globalData.streak"
                end
                SaveData()
            end
            if KeyboardTriggered(Keyboard.KEY_R) then
                mod.data.hudOffset = 196
                SaveData()
            end
            DrawString("Use UP or DOWN to position HUD", 200, 222, hintColor)
            DrawString("Use LEFT or RIGHT to change counter", 200, 235, hintColor)
            DrawString("Press R to reset position", 200, 248, hintColor)
        else
            if InputHelper.MultipleActionTriggered({ ButtonAction.ACTION_DOWN, ButtonAction.ACTION_SHOOTDOWN, ButtonAction.ACTION_MENUDOWN }) then
                mod.statsMenuSelectedCharacter = NextPlayerType(mod.statsMenuSelectedCharacter)
            end
            if InputHelper.MultipleActionTriggered({ ButtonAction.ACTION_UP, ButtonAction.ACTION_SHOOTUP, ButtonAction.ACTION_MENUUP }) then
                mod.statsMenuSelectedCharacter = PreviousPlayerType(mod.statsMenuSelectedCharacter)
            end
            if InputHelper.MultipleActionTriggered({ ButtonAction.ACTION_RIGHT, ButtonAction.ACTION_MENURIGHT, ButtonAction.ACTION_LEFT, ButtonAction.ACTION_MENULEFT }) then
                mod.statsMenuSelectedCharacter = NextTaintedPlayerType(mod.statsMenuSelectedCharacter)
            end

            RenderStatsMenu()
        end
    end

    -- streak hud stat
    if not editLayout and (game.Challenge ~= Challenge.CHALLENGE_NULL or mod.data.hudData == "disabled" or not mod.data.currentPlayerType or not Options.FoundHUD or not game:GetHUD():IsVisible() or (game:GetRoom():GetType() == RoomType.ROOM_DUNGEON and game:GetLevel():GetAbsoluteStage() == LevelStage.STAGE8) or game:GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD)) then
        return
    end
    local hudoffset = Options.HUDOffset * Vector(20, 12)
    if Isaac.GetPlayer(0):GetPlayerType() == PlayerType.PLAYER_JACOB then
        if mod.data.hudOffset < 214 then
            hudoffset = hudoffset + Vector(0, 30)
        else
            hudoffset = hudoffset + Vector(0, 5.6)
        end
    end
    hudSprite:Render(Vector(hudoffset.X, hudoffset.Y + mod.data.hudOffset), Vector(0, 0), Vector(0, 0))
    local data = nil
    local d = tostring(game.Difficulty)
    local p = tostring(mod.data.currentPlayerType or Isaac.GetPlayer(0):GetPlayerType())
    if mod.data.hudData == "globalData.streak" then
        data = mod.data.globalData[d].streak
    elseif mod.data.hudData == "playerData.streak" then
        data = mod.data.playerData[p][d].streak
    elseif mod.data.hudData == "globalData.longestStreak" then
        local streak = mod.data.globalData[d].streak
        if streak < 0 then
            streak = 0
        end
        data = streak .. "/" .. mod.data.globalData[d].longestStreak
    elseif mod.data.hudData == "playerData.longestStreak" then
        local streak = mod.data.playerData[p][d].streak
        if streak < 0 then
            streak = 0
        end
        data = streak .. "/" .. mod.data.playerData[p][d].longestStreak
    elseif mod.data.hudData == "globalData.wins" then
        data = GetSumPlayerData(game.Difficulty, "wins") .. "-" .. GetSumPlayerData(game.Difficulty, "deaths")
    elseif mod.data.hudData == "playerData.wins" then
        data = mod.data.playerData[p][d].wins .. "-" .. mod.data.playerData[p][d].deaths
    end
    if data ~= nil or mod.data.hudData == "disabled" then
        if editLayout then
            local hudData = {
                ["globalData.streak"] = "streak (all characters)",
                ["playerData.streak"] = "streak (this character)",
                ["globalData.longestStreak"] = "streak / longest streak (all characters)",
                ["playerData.longestStreak"] = "streak / longest streak (this character)",
                ["globalData.wins"] = "wins - deaths (all characters)",
                ["playerData.wins"] = "wins - deaths (this character)"
            }
            DrawString(tostring(data or "") .. "  < " .. (hudData[mod.data.hudData] or mod.data.hudData) .. " >", hudoffset.X + 16, hudoffset.Y + mod.data.hudOffset + 2, KColor(1, 1, 1, 0.5), hudFont)
        else
            DrawString(tostring(data or ""), hudoffset.X + 16, hudoffset.Y + mod.data.hudOffset + 2, KColor(1, 1, 1, 0.5), hudFont)
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isContinued)
    GetSaveData()
    if ModConfigMenu then
        local openMenuKeyboardSetting = ModConfigMenu.AddKeyboardSetting(
            "Run Tracker",
            "OpenMenuKeyboard",
            mod.data.openStatsMenuKey,
            "Open Menu",
            true,
            "Choose what button on your keyboard will open Run Tracker Menu."
        )
        local oldOnChange = openMenuKeyboardSetting.OnChange
        openMenuKeyboardSetting.OnChange = function (currentValue)
            local value = oldOnChange(currentValue)
            mod.data.openStatsMenuKey = currentValue
            SaveData()
            return value
        end
    end

    local game = Game()
    if not isContinued or game.Challenge ~= Challenge.CHALLENGE_NULL then -- New Game
        if mod.data.currentPlayerType ~= nil then
            local data = mod.data.playerData[tostring(mod.data.currentPlayerType)][tostring(mod.data.currentDifficulty)]
            data.resets = data.resets + 1
        end
        if game.Challenge == Challenge.CHALLENGE_NULL then
            mod.data.currentPlayerType = Isaac.GetPlayer(0):GetPlayerType()
            mod.data.currentDifficulty = game.Difficulty
        else
            mod.data.currentPlayerType = nil
            mod.data.currentDifficulty = nil
        end
        SaveData()
    else
        if mod.data.currentDifficulty ~= game.Difficulty then
            mod.data.currentPlayerType = nil
            mod.data.currentDifficulty = nil
            SaveData()
        end
        if mod.data.currentPlayerType == nil then
            mod.warnTime = 600
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_GAME_END, function(_, isGameOver)
    if mod.data.currentPlayerType then -- Game started after mod enabled
        local game = Game()
        if game.Challenge ~= Challenge.CHALLENGE_NULL then
            return
        end
        local data = mod.data.playerData[tostring(mod.data.currentPlayerType)][tostring(mod.data.currentDifficulty)]
        local globalData = mod.data.globalData[tostring(mod.data.currentDifficulty)]
        if isGameOver then
            data.deaths = data.deaths + 1
            if data.streak > 0 then
                data.streak = -1
            else
                data.streak = data.streak - 1
            end
            if globalData.streak > 0 then
                globalData.streak = -1
            else
                globalData.streak = globalData.streak - 1
            end
        else
            data.wins = data.wins + 1
            if data.streak < 0 then
                data.streak = 1
            else
                data.streak = data.streak + 1
            end
            if globalData.streak < 0 then
                globalData.streak = 1
            else
                globalData.streak = globalData.streak + 1
            end
            if data.streak > data.longestStreak then
                data.longestStreak = data.streak
            end
            if globalData.streak > globalData.longestStreak then
                globalData.longestStreak = globalData.streak
            end
        end
        data.playTime = data.playTime + game:GetFrameCount()
        mod.data.currentPlayerType = nil
        mod.data.currentDifficulty = nil
        SaveData()
    end
end)

mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, inputHook, buttonAction)
    if mod.statsMenuOpen and buttonAction ~= ButtonAction.ACTION_FULLSCREEN and buttonAction ~= ButtonAction.ACTION_CONSOLE then
        if inputHook == InputHook.IS_ACTION_PRESSED or inputHook == InputHook.IS_ACTION_TRIGGERED then
            return false
        else
            return 0
        end
    end
end)

-- crash
-- mod:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, function()
--     mod.data.currentPlayerType = nil
--     mod.data.currentDifficulty = nil
--     SaveData()
-- end)
