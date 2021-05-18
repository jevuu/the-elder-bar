TEB = {
    name = "TEB",
    displayName = "The Elder Bar |cff8040Reloaded|r",
    author = "SimonIllyan",
    website = "",
    version = "11.0.2",
    debug = ""
}

-- libraries
local LAM2 = LibAddonMenu2
local LSV = LibSavedVars

-- globals of this addon
local G = {
    addonInitialized = false,
    LFDB = LIB_FOOD_DRINK_BUFF,
    ap_SessionStart = os.time(),
    ap_SessionStartPoints = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER),
    barAlpha = 1,
    centerTimer = 300000, -- 5 min in ms
    combatAlpha = 0,
    deaths = 0,
    goldBankUnformatted = 0,
    goldBank = "",
    highestFPS = 0,
    killingBlows = 0,
    kills = 0,
    lastTopBarAlpha = 1,
    lowestFPS = 10000,
    lvl = 0,
    movingGadget = "",
    movingGadgetName = "",
    original = { },
    pulseList = { },
    pulseTimer = 0,
    refreshTimer = 99,
    screenHeight = GuiRoot:GetHeight(),
    screenWidth = GuiRoot:GetWidth(),
    showCombatOpacity = 0,
    spacer = 15,
    topBarAlphaList = { },
    trackerDropdown = { },
}
TEB.G = G

local LIGHTBLUE = "|c00ddff"
local OFFWHITE = "|ccccccc"

local gadgetReference
local gadgetSettings = { }
local settings

-- default values for settings
local defaults = {
    ap = {
        ["DisplayPreference"] = "Total Points",
    },
    autohide = {
        ["Bank"] = true,
        ["Chatter"] = true,
        ["Crafting"] = true,
        ["GameMenu"] = true,
        ["GuildBank"] = true,
    },
    bag = {
        ["DisplayPreference"] = "slots used/total slots",
        ["good"] = true,
        ["critical"] = 90,
        ["danger"] = 75,
        ["warning"] = 50,
        ["UsageAsPercentage"] = true,
    },
    bank = {
        ["DisplayPreference"] = "slots used/total slots",
        ["good"] = true,
        ["critical"] = 90,
        ["danger"] = 75,
        ["warning"] = 50,
        ["UsageAsPercentage"] = true,
    },
    bar = {
        Layer = 0,
        Locked = true,
        Position = "top",
        Width = "dynamic",
        Y = 0,
        backgroundOpacity = 100,
        bumpActionBar = true,
        bumpCompass = true,
        colors = {
            critical = "|cff0000",
            danger =   "|cff0000",  
            warning =  "|cff8000", 
            caution =  "|cffff00", 
            normal =   "|ccccccc",
        },
        combatIndicator = true,
        combatOpacity = 100,
        controlsPosition = "center",
        customColor = ZO_ColorDef:New("ffcccccc"),
        font = "Univers57",
        gadgetsLocked = true,
        iconsMode = "color",
        lockMessage = true,
        opacity = 100,
        pulseType = "fade out",
        pulseWhenCritical = false,
        scale = 100,
        thousandsSeparator = true,
    },
    bounty = {
        ["critical"] = "red",
        ["danger"] = "orange",
        ["DisplayPreference"] = "simple",
        ["Dynamic"] = true,
        ["good"] = "normal",
        ["warning"] = "yellow",
    },
    clock = {
        DisplayPreference = "local time",
        Type = "24h",
        DateFormat = "%Y-%m-%d",
    },
    durability = {
        ["critical"] = 10,
        ["danger"] = 25,
        ["DisplayPreference"] = "durability %",
        ["good"] = true,
        ["warning"] = 50,
    },
    enlightenment = {
        ["critical"] = 500000,
        ["danger"] = 100000,
        ["Dynamic"]    = false,
        ["warning"] = 200000,
    },
    et = {
        ["danger"] = 12,
        ["DisplayPreference"] = "tickets",
        ["Dynamic"] = true,
        ["warning"] = 9,
    },
    experience = {
        ["DisplayPreference"] = "% towards next level/CP",
    },
    food = {
        ["critical"] = 120,
        ["danger"] = 300,
        ["DisplayPreference"] = "simple",
        ["Dynamic"] = true,
        ["PulseAfter"] = false,
        ["warning"] = 600,
    },
    fps = {
        ["caution"] = 40,
        ["danger"] = 15,
        ["Fixed"] = false,
        ["FixedLength"] = 20,
        ["good"] = true,
        ["warning"] = 30,
    },
    ft = {
        ["DisplayPreference"] = "time left/cost",
        ["Dynamic"] = true,
        ["good"] = false,
        ["TimerDisplayPreference"] = "simple",
    },
    gadgetText = { },
    gadgets_pve = { "Level", "Experience", "Bag Space", "Gold", "Mount Timer", "Durability",
        "Weapon Charge/Poison", "Bounty/Heat Timer"},
    gadgets_pvp = { "Level", "Experience", "Bag Space", "Gold", "Mount Timer",
        "Durability", "Weapon Charge/Poison"},
    gold = {
        ["DisplayPreference"] = "gold on character",
        ["high"] = {
            ["danger"] = 999999999,
            ["warning"] = 999999999,
        },
        ["low"] = {
            ["danger"] = 0,
            ["warning"] = 0,
        },
        Tracker = {},
    },
    iconIndicator = { },
    kc = {
        ["DisplayPreference"] = "Killing Blows/Deaths (Kill Ratio)",
    },
    latency = {
        ["caution"] = 100,
        ["danger"] = 500,
        ["Fixed"] = false,
        ["FixedLength"] = 30,
        ["good"] = true,
        ["warning"] = 200,
    },
    level = {
        notmax = {
            icon = 1,
            cp = false,
            DisplayPreference = 1,
            Dynamic = true,
        },
        max = {
            icon = 1,
            cp = true,
            DisplayPreference = 3,
            Dynamic = true,
        },
    },
    location = {
        ["DisplayPreference"] = "(x, y) Zone Name",
    },
    mail = {
        ["critical"] = false,
        ["Dynamic"] = true,
        ["good"] = false,
    },
    memory = {
        danger = 768,
        good = true,
        warning = 512,
    },
    mount = {
        ["critical"] = false,
        ["DisplayPreference"] = "simple",
        ["Dynamic"] = true,
        ["good"] = false,
        ["Tracker"] = { },
    },
    mundus = {
        DisplayPreference = "Full",
    },
    research = {
        ["DisplayAllSlots"] = true,
        ["DisplayPreference"] = "simple",
        ["Dynamic"] = true,
        ["FreeText"] = "--",
        ["ShowShortest"] = false,
    },
    skyshards = {
        ["DisplayPreference"] = "collected/unspent points",
    },
    soulgems = {
        ["ColorCrown"] = true,
        ["ColorNormal"] = true,
        ["DisplayPreference"] = "total filled/empty",
    },
    tt = {
        ["danger"] = 10,
        ["DisplayPreference"] = "stolen treasures/stolen goods (lockpicks)",
        ["good"] = true,
        ["InvDanger"] = 75,
        ["InvWarning"] = 50,
        ["warning"] = 25,
    },
    vampirism = {
        ["TimerPreference"] = "simple",
        ["DisplayPreference"] = "Stage (Timer)",
        ["Dynamic"] = true,
        ["StageColor"] = {
            "green",
            "yellow",
            "orange",
            "red",
        },
    },
    wc = {
        ["AutoPoison"] = true,
        ["critical"] = 10,
        ["danger"] = 25,
        ["good"] = true,
        ["PoisonCritical"] = 5,
        ["PoisonDanger"] = 10,
        ["PoisonWarning"] = 20,
        ["warning"] = 50,
    },
}

local Vampirism_StageColors = {
         green  = { "|c00ff00", "good", },
         yellow = { "|cffff00", "caution", },
         orange = { "|cff8000", "warning", },
         red    = { "|cff0000", "danger", },
    }

local mundusStoneReference = {
    Full = {
        "Warrior", "Mage", "Thief", "Serpent", "Lady", "Steed", "Lord",
        "Apprentice", "Atronach", "Ritual", "Lover", "Shadow", "Tower",
    },
    Abbreviated = {
        "Warr", "Mage", "Thf", "Serp", "Lady", "Std", "Lord",
        "Appr", "Atro", "Rit", "Lvr", "Shad", "Twr",
    },

}

local equipSlotReference = {
    [0] = "head",
    [2] = "chest",
    [3] = "shoulders",
    [6] = "waist",
    [8] = "legs",
    [9] = "feet",
    [16] = "hands",
}

local ClassNames = {
    "Dragon Knight", "Sorcerer", "Night Blade", "Warden", "Necromancer", "Templar",
}

local timeFormats = {
    ["24h"] = "%H:%M",
    ["24h with seconds"] = "%H:%M:%S",
    ["12h"] = "%I:%M %p",
    ["12h no leading zero"] = "%I:%M %p",
    ["12h with seconds"] = "%I:%M:%S %p",
}

local traitReference = {
    [1] = "Powered",
    [2] = "Charged",
    [3] = "Precise",
    [4] = "Infused",
    [5] = "Defending",
    [6] = "Training",
    [7] = "Sharpened",
    [8] = "Decisive",
    [9] = "Intricate",
    [10] = "Ornate",
    [11] = "Sturdy",
    [12] = "Inpenetrable",
    [13] = "Reinforced",
    [14] = "Well Fitted",
    [15] = "Training",
    [16] = "Infused",
    [17] = "Invigorating",
    [18] = "Divines",
    [19] = "Ornate",
    [20] = "Intricate",
    [21] = "Healthy",
    [22] = "Arcane",
    [23] = "Robust",
    [24] = "Ornate",
    [25] = "Nirnhoned",
    [26] = "Nirnhoned",
    [27] = "Intricate",
    [28] = "Swift",
    [29] = "Harmony",
    [30] = "Triune",
    [31] = "Bloodthirsty",
    [32] = "Protective",
    [33] = "Infused",
}

local iconReference = {
    ["TEBTopAPIcon"] = "Alliance Points",
    ["TEBTopBagIcon"] = "Bag Space",
    ["TEBTopBankIcon"] = "Bank Space",
    ["TEBTopBountyIcon"] = "Bounty/Heat Timer",
    ["TEBTopDurabilityIcon"] = "Durability",
    ["TEBTopEnlightenmentIcon"] = "Enlightenment",
    ["TEBTopETIcon"] = "Event Tickets",
    ["TEBTopFoodIcon"] = "Food Buff Timer",
    ["TEBTopFPSIcon"] = "FPS",
    ["TEBTopFTIcon"] = "Fast Travel Timer",
    ["TEBTopGoldIcon"] = "Gold",
    ["TEBTopKillsIcon"] = "Kill Counter",
    ["TEBTopLatencyIcon"] = "Latency",
    ["TEBTopLevelIcon"] = "Level",
    ["TEBTopLocationIcon"] = "Location",
    ["TEBTopMailIcon"] = "Unread Mail",
    ["TEBTopMemoryIcon"] = "Memory Usage",
    ["TEBTopMountIcon"] = "Mount Timer",
    ["TEBTopMundusIcon"] = "Mundus Stone",
    ["TEBTopResearchBlacksmithingIcon"] = "Blacksmithing Research Timer",
    ["TEBTopResearchClothingIcon"] = "Clothing Research Timer",
    ["TEBTopResearchJewelryCraftingIcon"] = "Jewelry Crafting Research Timer",
    ["TEBTopResearchWoodworkingIcon"] = "Woodworking Research Timer",
    ["TEBTopSkyShardsIcon"] = "Sky Shards",
    ["TEBTopSoulGemsIcon"] = "Soul Gems",
    ["TEBTopTCIcon"] = "Transmute Crystals",
    ["TEBTopTelvarIcon"] = "Tel Var Stones",
    ["TEBTopTimeIcon"] = "Clock",
    ["TEBTopTTIcon"] = "Thief's Tools",
    ["TEBTopVampirismIcon"] = "Vampirism",
    ["TEBTopWCIcon"] = "Weapon Charge/Poison",
    ["TEBTopWritIcon"] = "Writ Vouchers",
    ["TEBTopXPIcon"] = "Experience",
}

local conditionsTable
local defaultGadgets = {
    "Level", "Gold", "Tel Var Stones", "Transmute Crystals", "Writ Vouchers", "Soul Gems",
    "Alliance Points", "Bag Space", "Mount Timer", "Experience", "Clock", "Sky Shards",
    "Durability", "Blacksmithing Research Timer", "Clothing Research Timer",
    "Woodworking Research Timer", "Jewelry Crafting Research Timer", "Bank Space",
    "Latency", "FPS", "Weapon Charge/Poison", "Location", "Thief's Tools", "Memory Usage",
    "Fast Travel Timer", "Kill Counter", "Enlightenment", "Unread Mail", "Event Tickets",
    "Food Buff Timer", "Mundus Stone", "Bounty/Heat Timer", "Vampirism",
}

-- it all begins here…
function TEB.OnAddOnLoaded(event, addOnName)
    if addOnName == TEB.name and not G.addonInitialized then
        TEB.Initialize()
    end
end

function TEB.Initialize()
    local events = {
        [EVENT_INVENTORY_SINGLE_SLOT_UPDATE] = TEB.CalculateBagItems,
        [EVENT_OPEN_BANK] = TEB.BankHideBar,
        [EVENT_CLOSE_BANK] = TEB.ShowBar,
        [EVENT_CHATTER_BEGIN] = TEB.ChatterHideBar,
        [EVENT_CHATTER_END] = TEB.ShowBar,
        [EVENT_CRAFTING_STATION_INTERACT] = TEB.CraftingHideBar,
        [EVENT_END_CRAFTING_STATION_INTERACT] = TEB.ShowBar,
        [EVENT_OPEN_GUILD_BANK] = TEB.GuildBankHideBar,
        [EVENT_CLOSE_GUILD_BANK] = TEB.ShowBar,
        [EVENT_JUSTICE_STOLEN_ITEMS_REMOVED] = TEB.CalculateBagItems,
        [EVENT_COMBAT_EVENT] = TEB.UpdateKillingBlows,
        [EVENT_PLAYER_DEAD] = TEB.UpdateDeaths,
        [EVENT_PLAYER_ACTIVATED] = TEB.FinishInitialization,
    }

    TEB.debug = TEB.debug .. "Initialize\n"
    for k, f in pairs(events) do
        EVENT_MANAGER:RegisterForEvent(TEB.name, k, f)
    end

    EVENT_MANAGER:AddFilterForEvent(TEB.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_KILLING_BLOW)

    ZO_CreateStringId("SI_BINDING_NAME_RUN_TEB", GetString(SI_CWA_KEY_BINDING))
    ZO_CreateStringId("SI_BINDING_NAME_LOCK_UNLOCK_BAR", "Lock/Unlock Bar")
    ZO_CreateStringId("SI_BINDING_NAME_LOCK_UNLOCK_GADGETS", "Lock/Unlock Gadgets")

    TEBTop:SetWidth(G.screenWidth)
    TEBTop:SetHidden(false)
    TEBTooltip:SetHidden(true)

    G.account = GetDisplayName("player")
    G.characterName = GetUnitName("player")
    G.playerClass = GetUnitClassId("player")
    -- for TEB.SetBarPosition
    G.original.TargetUnitFrameTop = ZO_TargetUnitFramereticleover:GetTop()
    G.original.CompassTop = ZO_CompassFrame:GetTop()
    G.original.ActionBarTop = ZO_ActionBar1:GetTop()
    G.original.HealthTop = ZO_PlayerAttributeHealth:GetTop()
    G.original.MagickaTop = ZO_PlayerAttributeMagicka:GetTop()
    G.original.StaminaTop = ZO_PlayerAttributeStamina:GetTop()
    G.original.MountStaminaTop = ZO_PlayerAttributeMountStamina:GetTop()
    G.original.BountyTop = ZO_HUDInfamyMeter:GetTop()

    -- default: all gadgets on
    for _, gadgetName in ipairs(defaultGadgets) do
        defaults.gadgetText[gadgetName] = true
        defaults.iconIndicator[gadgetName] = true
    end

    -- 1. Icon Object (object)
    -- 2. Text Object (object)
    -- 3. Icon File Base (string)
    -- 4. Icon Object (string)
    -- 5. Current Icon Texture (string)
    -- 6. Gadget Is Pulsing
    -- 7. Function providing value

    gadgetReference = {
        ["Alliance Points"] = { TEBTopAPIcon, TEBTopAP, "ap", "TEBTopAPIcon", "", false, function() return G.apString end, },
        ["Bag Space"] = { TEBTopBagIcon, TEBTopBag, "bag", "TEBTopBagIcon", "", false, function() return G.bagInfo end, },
        ["Bank Space"] = { TEBTopBankIcon, TEBTopBank, "bank", "TEBTopBankIcon", "", false, function() return G.bankInfo end, },
        ["Blacksmithing Research Timer"] = { TEBTopResearchBlacksmithingIcon, TEBTopResearchBlacksmithing, "blacksmithing", "TEBTopResearchBlacksmithingIcon", "", false, function() return G.blackSmithingInfo end, },
        ["Bounty/Heat Timer"] = { TEBTopBountyIcon, TEBTopBounty, "bounty", "TEBTopBountyIcon", "", false, function() return G.bounty end, },
        ["Clock"] = { TEBTopTimeIcon, TEBTopTime, "clock", "TEBTopTimeIcon", "", false, function() return G.clockString end, },
        ["Clothing Research Timer"] = { TEBTopResearchClothingIcon, TEBTopResearchClothing, "clothing", "TEBTopResearchClothingIcon", "", false, function() return G.clothingInfo end, },
        ["Durability"] = { TEBTopDurabilityIcon, TEBTopDurability, "durability", "TEBTopDurabilityIcon", "", false, function() return G.durabilityInfo end, },
        ["Enlightenment"] = { TEBTopEnlightenmentIcon, TEBTopEnlightenment, "enlightenment", "TEBTopEnlightenmentIcon", "", false, function() return G.enlightenment end, },
        ["Event Tickets"] = { TEBTopETIcon, TEBTopET, "eventtickets", "TEBTopETIcon", "", false, function() return G.eventtickets end, },
        ["Experience"] = { TEBTopXPIcon, TEBTopXP, "experience", "TEBTopXPIcon", "", false, function() return G.gxpString end, },
        ["FPS"] = { TEBTopFPSIcon, TEBTopFPS, "fps", "TEBTopFPSIcon", "", false, function() return G.fps end, },
        ["Fast Travel Timer"] = { TEBTopFTIcon, TEBTopFT, "ft", "TEBTopFTIcon", "", false, function() return G.ft end, },
        ["Food Buff Timer"] = { TEBTopFoodIcon, TEBTopFood, "foodbuff", "TEBTopFoodIcon", "", false, function() return G.food end, },
        ["Gold"] = { TEBTopGoldIcon, TEBTopGold, "gold", "TEBTopGoldIcon", "", false, function() return G.gold end, },
        ["Jewelry Crafting Research Timer"] = { TEBTopResearchJewelryCraftingIcon, TEBTopResearchJewelryCrafting, "jewelry", "TEBTopResearchJewelryCraftingIcon", "", false, function() return G.jewelryCraftingInfo end, },
        ["Kill Counter"] = { TEBTopKillsIcon, TEBTopKills, "kc", "TEBTopKillsIcon", "", false, function() return G.killCount end, },
        ["Latency"] = { TEBTopLatencyIcon, TEBTopLatency, "latency", "TEBTopLatencyIcon", "", false, function() return G.latency end, },
        ["Level"] = { TEBTopLevelIcon, TEBTopLevel, "cp", "TEBTopLevelIcon", "", false, function() return G.lvlText end, },
        ["Location"] = { TEBTopLocationIcon, TEBTopLocation, "location", "TEBTopLocationIcon", "", false, function() return G.location end, },
        ["Memory Usage"] = { TEBTopMemoryIcon, TEBTopMemory, "ram", "TEBTopMemoryIcon", "", false, function() return G.memory end, },
        ["Mount Timer"] = { TEBTopMountIcon, TEBTopMount, "mount", "TEBTopMountIcon", "", false, function() return G.mountlbltxt end, },
        ["Mundus Stone"] = { TEBTopMundusIcon, TEBTopMundus, "mundus", "TEBTopMundusIcon", "", false, function() return mundusStoneReference[settings.mundus.DisplayPreference][G.mundus] end, },
        ["Sky Shards"] = { TEBTopSkyShardsIcon, TEBTopSkyShards, "skyshards", "TEBTopSkyShardsIcon", "", false, function() return G.skyShardsInfo end, },
        ["Soul Gems"] = { TEBTopSoulGemsIcon, TEBTopSoulGems, "soulgem", "TEBTopSoulGemsIcon", "", false, function() return G.soulGemInfo end, },
        ["Tel Var Stones"] = { TEBTopTelvarIcon, TEBTopTelvar, "telvar", "TEBTopTelvarIcon", "", false, function() return G.telvar end, },
        ["Thief's Tools"] = { TEBTopTTIcon, TEBTopTT, "tt", "TEBTopTTIcon", "", false, function() return G.tt end, },
        ["Transmute Crystals"] = { TEBTopTCIcon, TEBTopTC, "transmute", "TEBTopTCIcon", "", false, function() return G.crystal end, },
        ["Unread Mail"] = { TEBTopMailIcon, TEBTopMail, "mail", "TEBTopMailIcon", "", false, function() return G.unread_mail end, },
        ["Vampirism"] = { TEBTopVampirismIcon, TEBTopVampirism, "vampirism", "TEBTopVampirismIcon", "", false, function() return G.vampireText end, },
        ["Weapon Charge/Poison"] = { TEBTopWCIcon, TEBTopWC, "wc", "TEBTopWCIcon", "", false, function() return G.weaponCharge end, },
        ["Woodworking Research Timer"] = { TEBTopResearchWoodworkingIcon, TEBTopResearchWoodworking, "woodworking", "TEBTopResearchWoodworkingIcon", "", false, function() return G.woodWorkingInfo end, },
        ["Writ Vouchers"] = { TEBTopWritIcon, TEBTopWrit, "writs", "TEBTopWritIcon", "", false, function() return G.writs end, },
    }

    conditionsTable = {
        ["Mount Timer"]                     = function() return G.mountTimerNotMaxed or not settings.mount.Dynamic end,
        ["Blacksmithing Research Timer"]    = function() return G.blackSmithingTimerRunning or not settings.research.Dynamic end,
        ["Clothing Research Timer"]         = function() return G.clothingTimerRunning or not settings.research.Dynamic end,
        ["Woodworking Research Timer"]      = function() return G.woodWorkingTimerRunning or not settings.research.Dynamic end,
        ["Jewelry Crafting Research Timer"] = function() return G.jewelryTimerRunning or not settings.research.Dynamic end,
        ["Fast Travel Timer"]               = function() return G.ftTimerRunning or not settings.ft.Dynamic end,
        ["Enlightenment"]                   = function() return G.enlightenmentVisible or not settings.enlightenment.Dynamic end,
        ["Unread Mail"]                     = function() return G.mailUnread or not settings.mail.Dynamic end,
        ["Event Tickets"]                   = function() return G.etHasTickets or not settings.et.Dynamic end,
        ["Food Buff Timer"]                 = function() return G.foodTimerRunning or not settings.food.Dynamic or settings.food.PulseAfter and G.foodBuffWasActive end,
        ["Bounty/Heat Timer"]               = function() return G.bountyTimerRunning or not settings.bounty.Dynamic or not settings.bar.gadgetsLocked end,
        ["Vampirism"]                       = function() return G.isVampire or not settings.vampirism.Dynamic end,
    }

    settings = LSV:NewAccountWide(TEB.name .. "SavedVariables", "Account", defaults):
        MigrateFromAccountWide( { name = TEB.name .. "SavedVariables" } ):
        -- when changing settings structure:
        Version(7, TEB.Upgrade_to_7):
        EnableDefaultsTrimming()
    --[[
        -- no LibSavedVars, use ZOS API directly
        settings = ZO_SavedVars:NewAccountWide("TEBSavedVariables", TEB.settingsRev, nil, defaults)
    ]]--
    TEB.settings = settings
    TEB.debug = TEB.debug .. string.format("LSV done: %d %d\n",
        TEB.CountKeys(TEB.settings), TEB.CountKeys(defaults))
    
    TEB.CreateSettingsWindow()
    TEB.debug = TEB.debug .. "CreateSettingsWindow done\n"

    TEB.DefragGadgets()
    TEB.SetWidth(settings.latency, TEBTopLatency)
    TEB.SetWidth(settings.fps, TEBTopFPS)
    TEBTop:ClearAnchors()
    TEBTop:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, settings.bar.Y)
    TEB.SetBarLayer()
    TEB.LockUnlockBar(settings.bar.Locked)
    TEB.LockUnlockGadgets(settings.bar.gadgetsLocked)
    TEB.ConvertGadgetSettings()
    TEB.CalculateBagItems()
    TEB.SetOpacity()
    TEB.SetBarPosition()
    TEB.SetBarWidth(settings.bar.Width)
    TEB.RebuildBar()
    TEB.UpdateControlsPosition()
    TEB.ResizeBar()
    TEB.AddToMountDatabase(GetUnitName("player"))
    TEB.AddToGoldDatabase(GetUnitName("player"))

    TEB.debug = TEB.debug .. "Initialize done\n"
end

-- auxiliary functions

function round(val, decimal)
    local divisor = 10 ^ (decimal or 0) -- 10 ^ 0 == 1
    return math.floor( val * divisor + 0.5) / divisor
end

local function ucfirst(s)
    return s:gsub("([a-zA-Z])(%w*)", function(a,b) return string.upper(a)..b end)
end

local function titlecase(first, rest)
   return first:upper() .. rest:lower()
end

function TEB.fixname(itemName)
    return zo_strformat("<<C:1>>", itemName)
end

function FormatTooltip(left, right)
    TEBTooltipLeft:SetText(left)
    TEBTooltipRight:SetText(right)
    TEBTooltip:SetHeight(TEBTooltipLeft:GetHeight())
    TEBTooltip:SetWidth(TEBTooltipLeft:GetWidth() + TEBTooltipRight:GetWidth() + G.spacer)
end

function TEB.CountKeys(s)
    local count = 0
    for k, v in pairs(s) do
        if key ~= "__dataSource" then
            count = count +1 
        end
        --[[
        if type(v) == "table" then
            count = count + TEB.CountKeys(v)
        else
            count = count +1
        end
        ]]--
    end
    return count
end

-- called from TEB.Initialize

function TEB.FinishInitialization(eventCode)
    if not G.addonInitialized then
        -- needs to be done at first player activation only
        df("%s v. %s initialized.", TEB.displayName, TEB.version)
        G.addonInitialized = true
    end
end

function TEB.Upgrade_to_7(sv_data)
    local move_to_bar_subtable = {
        backdropOpacity = "backgroundOpacity",
        barLayer = "Layer",
        barLocked = "Locked",
        barPosition = "Position",
        barY = "Y",
        bumpActionBar = "bumpActionBar",
        bumpCompass = "bumpCompass",
        combatIndicator = "combatIndicator",
        combatOpacity = "combatOpacity",
        controlsPosition = "controlsPosition",
        font = "font",
        gadgetsLocked = "gadgetsLocked",
        icons_Mode = "iconsMode",
        lockMessage = "lockMessage",
        pulseType = "pulseType",
        pulseWhenCritical = "pulseWhenCritical",
        scale = "scale",
        thousandsSeparator = "thousandsSeparator",
        Width = "Width",
    }
    -- create subtables
    for k, _ in pairs(defaults) do
        if sv_data[k] == nil then
            sv_data[k] = { }
        end
    end
    -- analyze the data
    for old_key, old_v in pairs(sv_data) do
        TEB.debug = TEB.debug .. string.format("# %s\n", old_key)
        local new_subkey = move_to_bar_subtable[old_key]
        if new_subkey then
            TEB.debug = TEB.debug .. string.format("BAR.%s = %s\n", new_subkey, old_key)
            sv_data.bar[new_subkey] = old_v
            sv_data[old_key] = nil
        elseif old_key == "gadgets" then 
            sv_data["gadgets_pve"] = old_v
            sv_data[old_key] = nil
        else            
            for k, _ in pairs(defaults) do
                local c_start, c_end = string.find(old_key, k)
                if c_start and c_start == 1 and c_end < #old_key then
                    -- remove prefix (including _ if present)
                    new_subkey = old_key:sub(c_end+1, c_end+1) == '_' and
                        old_key:sub(c_end+2, -1) or old_key:sub(c_end+1, -1)
                    if new_subkey == "Critical" or new_subkey == "Danger" or
                        new_subkey == "Warning" or new_subkey == "Caution" then
                        new_subkey = string.lower(new_subkey)
                    end
                    sv_data[k][new_subkey] = old_v
                    TEB.debug = TEB.debug .. string.format("%s.%s = %s\n", k, new_subkey, old_key)
                    sv_data[old_key] = nil
                end
            end
        end
        for old, new in pairs({ ["Bounty Timer"] = "Bounty/Heat Timer",
                                ["Weapon Charge"] = "Weapon Charge/Poison" }) do
            for _, submenu in ipairs({"gadgetText", "iconIndicator"}) do
                sv_data[submenu][new] = sv_data[submenu][old]
                sv_data[submenu][old] = nil
            end
            for _, submenu in ipairs({"gadgets_pve", "gadgets_pvp"}) do
                for i = 1, #sv_data[submenu] do
                    if sv_data[submenu][i] == old then
                        sv_data[submenu][i] = new
                    end                        
                end
            end
        end
    end
end
    
function TEB.SetWidth(setting, gadget)
    if setting.Fixed then
        gadget:SetWidth(setting.FixedLength)
    else
        local x = gadget:GetTextWidth()
        gadget:SetWidth(x)
    end
end

function TEB.SetBarLayer()
    TEBTop:SetDrawLayer(settings.bar.Layer)
    TEBTooltip:SetDrawLayer(4)
end

function TEB.HideBar()
    if settings.autohide.GameMenu then
        G.hideBar = true
    end
end

function TEB.ShowBar()
    G.hideBar = false
end

function TEB.ChatterHideBar()
    if settings.autohide.Chatter then G.hideBar = true end
end

function TEB.CraftingHideBar()
    if settings.autohide.Crafting then G.hideBar = true end
end

function TEB.BankHideBar()
    if settings.autohide.Bank then G.hideBar = true end
end

function TEB.GuildBankHideBar()
    if settings.autohide.GuildBank then G.hideBar = true end
end

function TEB.SetOpacity()
    TEBTop:SetAlpha(settings.bar.opacity/100)
    TEBTopBG:SetAlpha(settings.bar.backgroundOpacity/100)
end

function TEB.RebuildGadget(gadget, icon, lastGadget, firstGadgetAdded)
    gadget:SetHidden(false)
    icon:SetHidden(false)
    if firstGadgetAdded then
        icon:SetAnchor(LEFT, lastGadget, RIGHT, 20, 0)
    else
        icon:SetAnchor(LEFT, lastGadget, RIGHT, 0, 0)
        firstGadgetAdded = true
   end
    gadget:SetAnchor(TOPLEFT, icon, TOPRIGHT, 0, 0)
    gadget:SetAnchor(BOTTOMLEFT, icon, BOTTOMRIGHT, 0, 0)
    gadget:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    gadget:SetMaxLineCount(1)
    -- gadget:SetWidth(gadget:GetTextWidth())
    lastGadget = gadget
    return lastGadget, firstGadgetAdded
end

local classTexture = {
    "dragonknight", "sorcerer", "nightblade", "warden", "necromancer", "templar",
}

function TEB.RebuildLevel(lastGadget, firstGadgetAdded)
    local iconType = G.lvl < 50 and settings.level.notmax.icon or settings.level.max.icon
    local texturePath =  iconType == 1 and
            string.format("TEB/Images/class_%s_%s.dds",
            classTexture[G.playerClass], settings.bar.iconsMode )
            or
            string.format("TEB/Images/cp_%s.dds",
            settings.bar.iconsMode )
    TEBTopLevelIcon:SetNormalTexture(texturePath)
    return TEB.RebuildGadget(TEBTopLevel, TEBTopLevelIcon, lastGadget, firstGadgetAdded)
end

function TEB.RebuildBar()
    TEB.DefragGadgets()
    if G.pvpMode then
        gadgetList = settings.gadgets_pvp
    else
        gadgetList = settings.gadgets_pve
    end
    local lastGadget = TEBTopInfoAnchor
    local firstGadgetAdded = false
    for k, v in pairs(gadgetReference) do
        if ignoreGadget ~= gadgetReference[k][4] then
            for i = 1, 2 do
                gadgetReference[k][i]:ClearAnchors()
                gadgetReference[k][i]:SetHidden(true)
            end
        end
    end
    for _, name in ipairs(gadgetList) do
        if name ~= "(None)" then
            TEB.SetIcon(name, "normal")
            local icon, gadget = unpack(gadgetReference[name])
            -- condition is a function or nil
            local condition = conditionsTable[name]
            -- df("%s %s %s", name, tostring(gadget), tostring(condition))
            if name == "Level" then
                lastGadget, firstGadgetAdded = TEB.RebuildLevel(lastGadget, firstGadgetAdded)
            -- gadget shouldn't be shown if locked and condition() returns false
            elseif not settings.bar.gadgetsLocked or not condition or
                condition and condition() then
                lastGadget, firstGadgetAdded = TEB.RebuildGadget(gadget, icon, lastGadget, firstGadgetAdded)
            end
        end
    end
    TEBTopEndingAnchor:ClearAnchors()
    TEBTopEndingAnchor:SetAnchor(LEFT, lastGadget, RIGHT, 0, 0)
    TEB.UpdateControlsPosition()
end

function TEB.AddToGoldDatabase(character)
    local foundCharacter = false
    for k, v in pairs(settings.gold.Tracker) do
        if k == character then
            foundCharacter = true
        end
    end
    local goldCharacter = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)

    if not foundCharacter then
        settings.gold.Tracker[character] = { true, goldCharacter }
    else
        local characterTracked = settings.gold.Tracker[character][1]
        settings.gold.Tracker[character] = { characterTracked, goldCharacter }
    end
end

function TEB.AddToMountDatabase(character)
    local foundCharacter = false
    for k, v in pairs(settings.mount.Tracker) do
        if k == character then
            foundCharacter = true
        end
    end
    local mountTimeLeft = GetTimeUntilCanBeTrained() / 1000
    local trainTime = os.time() + mountTimeLeft

    if not foundCharacter then
        if not STABLE_MANAGER:IsRidingSkillMaxedOut() then
            settings.mount.Tracker[character] = {true, trainTime}
        end
    else
        local characterTracked = settings.mount.Tracker[character][1]
        local savedTrainTime = settings.mount.Tracker[character][2]
        if not STABLE_MANAGER:IsRidingSkillMaxedOut() and savedTrainTime ~= -1 then
            settings.mount.Tracker[character] = {characterTracked, trainTime}
        else
            settings.mount.Tracker[character] = {false, -1}
        end
    end
end

function TEB.RebuildMountTrackerList()
    G.trackerDropdown = {}
    G.trackerDropdown[1] = "(choose a character)"
    local index = 2
    for k, v in pairs(settings.mount.Tracker) do
        if v[2] ~= -1 then
            G.trackerDropdown[index] = string.format("%s (%stracked)", k, v[1] and "" or "un")
            index = index + 1
        end
    end
end

function TEB.DisableMountTracker()
    return not settings.mount.Tracker[G.characterName]
end

function TEB.DisableGoldTracker()
    return not settings.gold.Tracker[G.characterName]
end

function TEB.GetCharacterGoldTracked()
    return settings.gold.Tracker[G.characterName] and
        settings.gold.Tracker[G.characterName][1] or false
end

function TEB.GetCharacterMountTracked()
    return settings.mount.Tracker[G.characterName] and
        settings.mount.Tracker[G.characterName][1] or false
end

function TEB.SetCharacterMountTracked(track)
    if settings.mount.Tracker[G.characterName] then
        local mountTimeLeft = GetTimeUntilCanBeTrained() / 1000
        local trainTime = os.time() + mountTimeLeft
        settings.mount.Tracker[G.characterName] = { track, trainTime }
    end
end

function TEB.SetCharacterGoldTracked(track)
    if settings.gold.Tracker[G.characterName] then
        local goldCharacter = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
        settings.gold.Tracker[G.characterName] = { track, goldCharacter }
    end
end

function TEB.SetIcon(gadgetName, iconStyle)
    gadgetData = gadgetReference[gadgetName]
    iconStyle = string.lower(iconStyle)
    -- bar.iconsMode : white, color
    -- iconStyle: green, caution, warning, danger
    local colorTag
    if iconStyle == "normal" then
        colorTag = settings.bar.iconsMode
    elseif iconStyle == "critical" then
        colorTag = "danger"
    else
        colorTag = iconStyle
    end
    local fileName =
        string.format("%s_%s.dds", gadgetData[3], string.lower(colorTag))
    if TEB.IconDifferent(gadgetName, fileName) then
        gadgetData[1]:SetNormalTexture("TEB/Images/"..fileName)
        gadgetData[5] = fileName
    end
end

function TEB.SetIconByIndicator(gadgetName, iconStyle)
    if settings.iconIndicator[gadgetName] and iconStyle ~= "normal" then
        TEB.SetIcon(gadgetName, iconStyle)
    else
        TEB.SetIcon(gadgetName, "normal")
    end
end

function TEB.IconDifferent(gadgetName, fileName)
    return gadgetReference[gadgetName][5] ~= fileName
end

function TEB.UpdateControlsPosition()
    local controlsWidth = TEBTopEndingAnchor:GetLeft() - TEBTopInfoAnchor:GetLeft()
    local newX
    if settings.bar.controlsPosition == "left" then
        newX = 20
    elseif settings.bar.controlsPosition == "right" then
        newX = G.screenWidth - controlsWidth - 20
    else
        newX =  (G.screenWidth - controlsWidth) / 2
    end
    TEBTopInfoAnchor:SetAnchor(LEFT, TEBTop, LEFT, newX, 0)
end

function TEB.ResizeBar()
    local fontPath = string.format("EsoUI/Common/Fonts/%s.otf", settings.bar.font)
    local fontSize = 0.18 * settings.bar.scale
    local fontOutline = "shadow"
    local barHeight = 0.32 * settings.bar.scale
    for k, v in pairs(gadgetReference) do
        gadgetIcon, gadgetLabel = v[1], v[2]
        gadgetLabel:SetFont(string.format("%s|%s|%s", fontPath, fontSize, fontOutline))
        -- gadgetLabel:SetHeight(barHeight)
        gadgetIcon:SetScale(settings.bar.scale / 100)
    end
    TEBTop:SetHeight(barHeight)
    TEBTopInfoAnchor:SetHeight(barHeight)
    TEBTopEndingAnchor:SetHeight(barHeight)
    TEB.SetBarWidth(settings.bar.Width)
end

function TEB.SetBarWidth(Width)
    for _, g in ipairs({ TEBTopBG, TEBTopCombatBG }) do
        if Width == "screen width" then
            -- TEBTop has the full width of screen
            g:SetAnchor(TOPLEFT, TEBTop, TOPLEFT, -15, 0)
            g:SetAnchor(BOTTOMRIGHT, TEBTop, BOTTOMRIGHT, 15, 0)
        else
            g:SetAnchor(TOPLEFT, TEBTopInfoAnchor, TOPLEFT, -15, 0)
            g:SetAnchor(BOTTOMRIGHT, TEBTopEndingAnchor, BOTTOMRIGHT, 15, 0)
        end
    end
end

function TEB.SetBarPosition()
    ZO_TargetUnitFramereticleover:ClearAnchors()
    if settings.bar.bumpCompass then
        local offset = settings.bar.Position == "top"  and 24 + settings.bar.Y or 0
        ZO_CompassFrame:ClearAnchors()
        ZO_CompassFrame:SetAnchor( TOP, GuiRoot, TOP, 0, G.original.CompassTop + offset )
        ZO_TargetUnitFramereticleover:SetAnchor( TOP, GuiRoot, TOP, 0,
            G.original.TargetUnitFrameTop + offset )
    end
    if settings.bar.bumpActionBar then
        local bottomBump = settings.bar.Position == "bottom" and
            G.screenHeight - settings.bar.Y + 6 or 0
        ZO_ActionBar1:ClearAnchors()
        ZO_ActionBar1:SetAnchor( TOP, GuiRoot, TOP, 0, G.original.ActionBarTop - bottomBump )
        ZO_PlayerAttributeHealth:SetAnchor( TOP, GuiRoot, TOP, 0, G.original.HealthTop - bottomBump )
        ZO_PlayerAttributeMagicka:SetAnchor( TOPRIGHT, GuiRoot, TOPRIGHT,
            ZO_PlayerAttributeMagicka:GetRight() - G.screenWidth, G.original.MagickaTop - bottomBump)
        ZO_PlayerAttributeStamina:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT,
            ZO_PlayerAttributeStamina:GetLeft(), G.original.StaminaTop - bottomBump)
        ZO_PlayerAttributeMountStamina:SetAnchor(TOPLEFT, ZO_PlayerAttributeStamina, BOTTOMLEFT, 0, 0)
        ZO_HUDInfamyMeter:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT,
            ZO_HUDInfamyMeter:GetLeft(), G.original.BountyTop - bottomBump )
    end
end

function TEB.AddPulseItem(itemName)
    gadgetReference[itemName][6] = true
    table.insert(G.pulseList, itemName)
end

function TEB.RemovePulseItem(itemName)
    gadgetReference[itemName][6] = false
    for i=1, #G.pulseList do
        if G.pulseList[i] == itemName then
            table.remove(G.pulseList, i)
        end
    end
    gadgetReference[itemName][1]:SetAlpha(1)
    gadgetReference[itemName][2]:SetAlpha(1)
end

function TEB.KeyLockUnlockBar()
    TEB.LockUnlockBar(not settings.bar.Locked)
end

function TEB.KeyLockUnlockGadgets()
    TEB.LockUnlockGadgets(not settings.bar.gadgetsLocked)
end

function TEB.LockUnlockBar(newValue)
    settings.bar.Locked = newValue
    TEBTop:SetMovable(not newValue)
    if settings.bar.lockMessage then
        df("|c2A8FEEThe Elder Bar is now |cFFFFFF%s.", newValue and "LOCKED" or "UNLOCKED")
    end
end

function TEB.LockUnlockGadgets(newValue)
    settings.bar.gadgetsLocked = newValue
    for k,v in pairs(gadgetReference) do
        gadgetReference[k][1]:SetMovable(not newValue)
    end
    TEB.RebuildBar()
    if settings.bar.lockMessage then
        if newValue then
            d("|c2A8FEEThe Elder Bar gadgets are now |cFFFFFFLOCKED.")
        else
            d("|c2A8FEEThe Elder Bar gadgets are now |cFFFFFFUNLOCKED.")
        end
    end
end

function TEB.GetNumberGadgets()
    local lastItem = 0
    for i=1, #defaultGadgets do
        if settings.gadgets_pve[i] == "(None)" then
            lastItem = i
            break
        end
    end
    return lastItem
end

function TEB.UpdateGadgetList(gadgetName, whichBar)
    if whichBar == 0 then
        for i=1, #defaultGadgets do
            if settings.gadgets_pve[i] == gadgetName then
               settings.gadgets_pve[i] = "(None)"
            end
            if settings.gadgets_pvp[i] == gadgetName then
               settings.gadgets_pvp[i] = "(None)"
            end
        end
    end
    if whichBar == 1 then
        local alreadyOnPVE = false
        for i=1, #defaultGadgets do
            if settings.gadgets_pve[i] == gadgetName then alreadyOnPVE = true end
            if settings.gadgets_pvp[i] == gadgetName then
               settings.gadgets_pvp[i] = "(None)"
            end
        end
        if not alreadyOnPVE then
            settings.gadgets_pve[TEB.GetNumberGadgets()+1] = gadgetName
        end
    end
    if whichBar == 2 then
        local alreadyOnPVP = false
        for i=1, #defaultGadgets do
            if settings.gadgets_pvp[i] == gadgetName then alreadyOnPVP = true end
            if settings.gadgets_pve[i] == gadgetName then
               settings.gadgets_pve[i] = "(None)"
            end
        end
        if not alreadyOnPVP then
            settings.gadgets_pvp[TEB.GetNumberGadgets()+1] = gadgetName
        end
    end
    if whichBar == 3 then
        local alreadyOnPVE = false
        local alreadyOnPVP = false
        for i=1, #defaultGadgets do
            if settings.gadgets_pvp[i] == gadgetName then alreadyOnPVP = true end
            if settings.gadgets_pve[i] == gadgetName then alreadyOnPVE = true end
        end
        if not alreadyOnPVP then
            settings.gadgets_pvp[TEB.GetNumberGadgets()+1] = gadgetName
        end
        if not alreadyOnPVE then
            settings.gadgets_pve[TEB.GetNumberGadgets()+1] = gadgetName
        end
    end

    TEB.RebuildBar()
end

function TEB.ConvertGadgetSettings()
    gadgetSettings = {}
    for i=1, #defaultGadgets do
        local gadgetName = defaultGadgets[i]
        gadgetSettings[gadgetName] = 0
    end

    for i=1, #defaultGadgets do
        for k,v in pairs(gadgetReference) do
            if settings.gadgets_pve[i] == k then gadgetSettings[k] = 1 end
        end
    end

    for i=1, #defaultGadgets do
        for k,v in pairs(gadgetReference) do
            if settings.gadgets_pvp[i] == k then
                if gadgetSettings[k] == 1 then
                    gadgetSettings[k] = 3
                else
                    gadgetSettings[k] = 2
                end
            end
        end
    end
end

local thresholdLevels = { "critical", "danger", "warning", "caution", "normal", }

function TEB.checkThresholds(testval, direction, group)
--[[
direction == true -> check testval > threshold (upper limits)
direction == false -> check testval < threshold (lower limits)
group is subtree in settings, like settings.food; 
values of group[x] for x in thresholdLevels must be descending if direction is true,
ascending otherwise
]]--
    local tag
    if group then
        for _, tag in ipairs(thresholdLevels) do
            if group[tag] then
                if direction and testval > group[tag] or
                    not direction and testval < group[tag] then
                    return settings.bar.colors[tag], tag
                end
            end
        end
        tag = "normal"
        return settings.bar.colors[tag], tag
    end
end

-- self refers to a gadget object
function TEB.StartMovingGadget(self)
    local gadgetTop = self:GetTop()
    local gadgetLeft = self:GetLeft()
    G.movingGadget = self
    ignoreGadget = self:GetName()
    local findGadget = iconReference[ignoreGadget]
    if G.pvpMode then
        gadgetList = settings.gadgets_pvp
    else
        gadgetList = settings.gadgets_pve
    end
    for i=1, #defaultGadgets do
        if gadgetList[i] == findGadget then
            G.movingGadgetName = gadgetList[i]
            gadgetList[i] = "(None)"
        end
    end
    TEB.RebuildBar()
    self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, gadgetLeft, gadgetTop)
end

function TEB.StopMovingGadget(self)
    local foundGadget = ""
    local testGadgetObject = ""
    local targetGadgetNumber = 0
    if G.pvpMode then
        gadgetList = settings.gadgets_pvp
    else
        gadgetList = settings.gadgets_pve
    end
    for i=1, #defaultGadgets do
        for k,v in pairs(gadgetReference) do
            if gadgetList[i] == k then testGadgetObject = gadgetReference[k][2] end
        end

        if gadgetList[i] ~= "(None)" then
            if G.movingGadget:GetLeft() <= testGadgetObject:GetLeft() and targetGadgetNumber == 0 then
                local goodTarget = true
                if testGadgetObject:IsHidden() then goodTarget = false end
                if goodTarget then
                    targetGadgetNumber = i
                end
            end
        end
    end
    if targetGadgetNumber == 0 then targetGadgetNumber = TEB.GetNumberGadgets()+1 end

    for i=#defaultGadgets-1, targetGadgetNumber, -1 do
        if G.pvpMode then
            settings.gadgets_pvp[i+1] = settings.gadgets_pvp[i]
        else
            settings.gadgets_pve[i+1] = settings.gadgets_pve[i]
        end
    end

    if G.pvpMode then
        settings.gadgets_pvp[targetGadgetNumber] = G.movingGadgetName
    else
        settings.gadgets_pve[targetGadgetNumber] = G.movingGadgetName
    end
    ignoreGadget = ""
    TEB.RebuildBar()
end

--====================================================
-- TOOLTIPS
--====================================================

local function SetToolTip(toolTipLeft, toolTipRight, self)
    FormatTooltip(toolTipLeft, toolTipRight)
    if self:GetTop() > G.screenHeight / 2 then
        TEBTooltip:SetAnchor(TOPLEFT, self, BOTTOMRIGHT, -12, -12 - TEBTop:GetHeight() - TEBTooltip:GetHeight())
    else
        TEBTooltip:SetAnchor(TOPLEFT, self, BOTTOMRIGHT, -12, 12)
    end
    TEBTooltip:SetHidden(false)
end

-- self refers to a gadget object
function TEB.ShowToolTipNameLevel(self)
    local left = {
        string.format("|cffffff%s|ccccccc\n", G.characterName),
        string.format("%s level", ClassNames[G.playerClass]),
        "Champion Points\n",
        "Unspent Craft Points",
        "Unspent Warfare Points",
        "Unspent Fitness Points",
        "Total Unspent Points",
    }
    local right = {
        "\n",
        string.format("%d", G.lvl),
        string.format("%d\n", G.cp),
        string.format("|C51AB0D|t18:18:esoui/art/champion/champion_points_stamina_icon.dds|t%d", unspentThief),
        string.format("|C1970C9|t18:18:esoui/art/champion/champion_points_magicka_icon.dds|t%d", unspentMage),
        string.format("|CD6660C|t18:18:esoui/art/champion/champion_points_health_icon.dds|t%d", unspentWarrior),
        string.format("|CFFFFAA|t18:18:TEB/Images/cp_color.dds|t%s|r", unspentTotal),
    }
    local toolTipLeft = table.concat(left, "\n")
    local toolTipRight = table.concat(right, "\n")
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipMundus(self)
    local toolTipLeft = string.format("Mundus Stone.\n\n|cffffff%s",
        mundusStoneReference["Full"][G.mundus])
    local toolTipRight = ""
    SetToolTip(toolTipLeft, toolTipRight, self)
end

-- used by TEB.ShowToolTipBag and ShowToolTipBank
local bagToolTips = {
    ["used%"] = "Percentage of %s space used:\n|cffffff%s",
    ["slots free/total slots"] = "%s space free / maximum size:\n|cffffff%s",
    ["slots free"] = "%s space free:\n|cffffff%s",
    ["free%"] = "Percentage of %s space free:\n|cffffff%s",
}

function TEB.ShowToolTipBag(self)
    local fmt = bagToolTips[settings.bag.DisplayPreference] or "%s space used / maximum size:\n|cffffff%s"
    local toolTipLeft = zo_strformat("<<C:1>>", string.format(fmt, "bag", G.bagInfo))
    local toolTipRight = ""
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipVampirism(self)
    local toolTipLeft = "Stage\nTime until stage expires"
    local toolTipRight = vampTooltipRight
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipBank(self)
    local fmt = bagToolTips[settings.bank.DisplayPreference] or "%s space used / maximum size:\n|cffffff%s"
    local toolTipLeft = zo_strformat("<<C:1>>", string.format(fmt, "bank", G.bankInfo))
    local toolTipRight = ""
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipMail(self)
    local toolTipLeft = "Unread Mail"
    local toolTipRight = G.unread_mail
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipFood(self)
    local toolTipLeft = "Food Buff Remaining"
    local toolTipRight = G.food
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipInfamy(self)
    local toolTipLeft = "Heat Time Left\nBounty Time Left\nInfamy\nPayoff"
    local toolTipRight = string.format("%s\n%s\n%s\n|t18:18:TEB/Images/gold_color.dds|t%s", heatTimerText, bountyTimerText, infamyText, tostring(bountyPayoff))
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipLatency(self)
    local toolTipLeft = string.format("Current network latency: %sms", G.latency)
    local toolTipRight = ""
    SetToolTip(toolTipLeft, toolTipRight, self)
end

local locationToolTips = {
    ["(x, y) Zone Name"] = "(Coordinates) Zone Name.\n\n",
    ["Zone Name (x, y)"] = "Zone Name (Coordinates).\n\n",
    ["Zone Name"] = "Current zone name.\n\n",
    ["x, y"] = "Current coordinates.\n\n",
}

function TEB.ShowToolTipLocation(self)
    local toolTipLeft, toolTipRight
    toolTipLeft = locationToolTips[settings.location.DisplayPreference] or ""
    toolTipLeft = string.format("%s%s\n(%s)", toolTipLeft, zoneName, coordinates)
    toolTipRight = ""
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipTT(self)
    local toolTipLeft = "Thief's Tools.\n\nLockpicks\nStolen Treasures\nOther Stolen Items\n\nFence Interactions\nLaunder Interactions"
    local toolTipRight = string.format("\n\n%s\n%s\n%s\n\n%s/%s\n%s/%s",
        G.lockpicks, G.treasures, G.not_treasures,
        G.sellsUsed, G.totalSells, G.laundersUsed, G.totalLaunders)
    SetToolTip(toolTipLeft, toolTipRight, self)
end

local goldToolTips = {
    ["gold on character"] = "Gold on your character.\n",
    ["gold on character/gold in bank"] = "Gold on your character/gold in the bank.\n",
    ["gold on character (gold in bank)"] = "Gold on your character (gold in the bank).\n",
    ["character+bank gold"] = "Gold on your character + gold in the bank.\n",
    ["tracked gold"] = "Gold on all tracked characters.\n",
    ["tracked+bank gold"] = "Gold on all tracked characters + bank.\n",
}

function TEB.ShowToolTipGold(self)
    TEBTooltip:SetHidden(false)
    local totalGold = 0
    local toolTipLeft = { goldToolTips[settings.gold.DisplayPreference] or "" }
    local toolTipRight = { "\n" }
    local rowColor, goldAmount

    local tempKeys = {}
    for k in pairs(settings.gold.Tracker) do
        table.insert(tempKeys, k)
    end
    table.sort(tempKeys)

    for _, k in ipairs(tempKeys) do
        local v = settings.gold.Tracker[k]
        if v[1] and k ~= "LocalPlayer" then
            totalGold = totalGold + v[2]
            goldAmount = settings.bar.thousandsSeparator and
                zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(v[2])) or
                tostring(v[2])
            rowColor = (k == G.characterName) and LIGHTBLUE or OFFWHITE
            table.insert(toolTipLeft, rowColor .. k)
            table.insert(toolTipRight, rowColor .. goldAmount)
        end
    end

    totalGold = totalGold + G.goldBankUnformatted
    if settings.bar.thousandsSeparator then
        totalGold = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(totalGold))
    else
        totalGold = tostring(totalGold)
    end
    table.insert(toolTipLeft, OFFWHITE .. "\n\nGold in bank\n______________________\n\nTotal gold")
    table.insert(toolTipRight,
        string.format("\n\n%s\n______\n\n%s", G.goldBank, totalGold))
    FormatTooltip(table.concat(toolTipLeft, "\n"), table.concat(toolTipRight, "\n"))
    if self:GetTop() > G.screenHeight / 2 then
        TEBTooltip:SetAnchor(TOPLEFT, self, BOTTOMRIGHT, -12,-12 - TEBTop:GetHeight() - TEBTooltip:GetHeight())
    else
        TEBTooltip:SetAnchor(TOPLEFT, self, BOTTOMRIGHT, -12,12)
    end
end

function TEB.ShowToolTipFPS(self)
    local toolTipLeft = "Current frames per second.\n\nLowest FPS this session\nHighest FPS this session"
    local toolTipRight = string.format("\n\n%d\n%d", G.lowestFPS, G.highestFPS)
    SetToolTip(toolTipLeft, toolTipRight, self)
end

-- tables for TEB.ShowToolTipCurrencies
local currencyTooltips = {
    ["telvar"] = "Tel Var Stones you own.\n" ,
    ["writs"]  = "Writ Vouchers you own.\n",
    ["tc"]     = "Transmute Crystals you own.\n",
    ["et"]     = "Event Tickets you own.\n",
    -- ap is separate case
}

local apTooltips = {
    ["Total Points"] = "Total Alliance Points.",
    ["Session Points"] = "Session Alliance Points.",
    ["Points Per Hour"] = "Alliance Points/hour.",
    ["Total Points/Points Per Hour"] = "Total Alliance Points/Points hr.",
    ["Session Points/Points Per Hour"] = "Session Points/Points hr.",
    ["Total Points/Session Points"] = "Total Alliance Points/Session Points.",
    ["Total Points/Session Points (Points Per Hour)"] = "Total Points/Session Points (Points/hr).",
    ["Total Points/Session Points/Points Per Hour"] = "Total Points/Session Points/Points hr.",
}

function TEB.ShowToolTipCurrencies(self, currentCurrency)
    TEBTooltip:SetHidden(false)
    local toolTipLeft, toolTipRight

    local function currencyColor(currency)
        return (currency == currentCurrency and LIGHTBLUE or OFFWHITE)
    end

    local telvarColor   = currencyColor("telvar")
    local tcColor       = currencyColor("tc")
    local writsColor    = currencyColor("writs")
    local apColor       = currencyColor("ap")
    local etColor       = currencyColor("et")

    if currentCurrency == "ap" then
        toolTipLeft = apTooltips[settings.ap.DisplayPreference] .. "\n\nPoints gained this session\nPoints gained per hour\n"
        toolTipRight = string.format("%s\n%s\n\n", ap_Session, ap_Hour)
    else
        toolTipLeft = currencyTooltips[currentCurrency] or ""
        toolTipRight = ""
    end

    toolTipLeft = table.concat( { toolTipLeft,
        apColor, "Alliance Points\n",
        etColor, "Event Tickets\n",
        telvarColor, "Tel Var Stones\n",
        tcColor, "Transmute Crystals\n",
        writsColor, "Writ Vouchers",
    }, "" )
    local fmt = "|t18:18:TEB/Images/%s_color.dds|t%s%s" -- 18x18 icons?
    toolTipRight = table.concat( { toolTipRight,
        string.format(fmt, "ap", apColor, G.apString),
        string.format(fmt, "eventtickets", etColor, G.eventtickets),
        string.format(fmt, "telvar", telvarColor, G.telvar),
        string.format(fmt, "transmute", tcColor, G.crystal),
        string.format(fmt, "writs", writsColor, G.writs),
    }, "\n")
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipM(self)
    TEBTooltip:SetHidden(false)

    local toolTipLeft = ""
    local toolTipRight = "|CFFFFFF\n"

    toolTipLeft = toolTipLeft .. "|c2A8FEECurrent Training:\n"
    toolTipLeft = toolTipLeft .. "|CEEEEEESpeed\n"
    toolTipLeft = toolTipLeft .. "Stamina\n"
    toolTipLeft = toolTipLeft .. "Carry Capacity\n\n"

    carry, carryMax, stamina, staminaBonus, speed, speedMax = GetRidingStats()

    toolTipRight = toolTipRight .. string.format(speed).."/60\n"
    toolTipRight = toolTipRight .. string.format(stamina).."/60\n"
    toolTipRight = toolTipRight .. string.format(carry).."/60\n\n"

    toolTipLeft = toolTipLeft .. "|c2A8FEEMount Training Tracker:"

    local tempKeys = {}
    for k in pairs(settings.mount.Tracker) do table.insert(tempKeys, k) end
    table.sort(tempKeys)

    for _, k in ipairs(tempKeys) do
        v = settings.mount.Tracker[k]
        if v[1] and v[2] ~= -1 and k ~= "LocalPlayer" then
            local timeLeft = v[2] - os.time()
            local rowColor = "|ceeeeee"
            if k == G.characterName then rowColor = "|cffffff" end
            if timeLeft <=0 then
                timeLeft="TRAIN!"
                rowColor = "|c00ee00"
                if k == G.characterName then rowColor = "|c22ff22" end
            else
                timeLeft = TEB.ConvertSeconds(settings.mount.DisplayPreference, timeLeft)
            end
            toolTipLeft = toolTipLeft .. "\n"..rowColor..k
            toolTipRight = toolTipRight .. "\n"..rowColor..timeLeft
        end
    end

    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipMemory(self)
    local toolTipLeft, toolTipRight = "Memory usage of all loaded addons.", ""
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipXP(self)
    local levelThing = G.lvl == 50 and "champion point" or "level"
    if settings.experience.DisplayPreference == "% towards next level/CP" then
        FormatTooltip("Experience towards next "..levelThing..":\n|cffffff"..G.gxpString, "")
    end
    if settings.experience.DisplayPreference == "% needed for next level/CP" then
        FormatTooltip("Experience needed for next "..levelThing..":\n|cffffff"..G.gxpString, "")
    end
    if settings.experience.DisplayPreference == "current XP" then
        FormatTooltip("Current experience:\n|cffffff"..G.gxpString, "")
    end
    if settings.experience.DisplayPreference == "needed XP" then
        FormatTooltip("Needed experience for next "..levelThing..":\n|cffffff"..G.gxpString, "")
    end
    if settings.experience.DisplayPreference == "current XP/total needed" then
        FormatTooltip("Current experience/total experience needed:\n|cffffff"..G.gxpString, "")
    end
    if self:GetTop() > G.screenHeight / 2 then
        TEBTooltip:SetAnchor(TOPLEFT, self, BOTTOMRIGHT, -12,-12 - TEBTop:GetHeight() - TEBTooltip:GetHeight())
    else
        TEBTooltip:SetAnchor(TOPLEFT, self, BOTTOMRIGHT, -12,12)
    end
end

function TEB.ShowToolTipClock(self)
    local tbl = {
        {"Local date"   , G.earthDate,    },
        {"Local time"   , G.localTime,    },
        {"UTC time"     , G.UTCTime,      },
        {"In-game time" , G.inGameTime,   },
        {"Imperial date", G.imperialDate, },
        {"Argonian date", G.argonianDate, },
    }
    local left, right = {}, {}
    for _, r in pairs(tbl) do
        table.insert(left, string.format("%s:", r[1]))
        table.insert(right, string.format("|cffffff%s|ccccccc", r[2]))
    end
    local toolTipLeft, toolTipRight = table.concat(left, "\n"), table.concat(right, "\n")
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipSoulGems(self)
    local toolTipLeft = G.soulGemsToolTipLeft
    local toolTipRight = G.soulGemsToolTipRight
    SetToolTip(toolTipLeft, toolTipRight, self)
end

local skyshardsToolTips = {
    ["collected/unspent points"] = "Collected skyshards / unspent skill points.",
    ["collected"] = "Collected skyshards.",
    ["collected/total needed (unspent points)"] = "Collected skyshards/total needed for skill point (unspent skill points).",
    ["needed/unspent points"] = "Needed skyshards / unspent skill points.",
    ["needed"] = "Needed skyshards.",
}

function TEB.ShowToolTipSkyShards(self)
    local toolTipLeft, toolTipRight =
        skyshardsToolTips[settings.skyshards.DisplayPreference] or "",
        string.format("\n\n%d\n%s", G.skyShards, G.availablePoints)
    toolTipLeft = string.format("%s\n\nCollected Sky Shards\nUnspent Skill Points", toolTipLeft)
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipDurability(self)
    local toolTipLeft = G.durabilityTooltipLeft
    local toolTipRight = G.durabilityTooltipRight
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipKills(self)
    local toolTipLeft = "Kill Counter.\n\nKilling Blows\nAssists\nDeaths\nKill/Death Ratio"
    local toolTipRight = string.format("\n\n%s\n%s\n%s\n%s", G.killingBlows, G.kills, G.deaths, G.killRatio)
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipEnlightenment(self)
    local toolTipLeft = string.format("Current enlightenment:\n|cffffff%s", G.enlightenment)
    local toolTipRight = ""
    SetToolTip(toolTipLeft, toolTipRight, self)
end

local ftToolTips = {
    ["time left"] = "Recall time left until cheapest.\n",
    ["cost"] = "Recall current cost.\n",
    ["time left/cost"] = "Recall time left until cheapest/cost.\n",
}

function TEB.ShowToolTipFT(self)
    local toolTipLeft = ftToolTips[settings.ft.DisplayPreference]  or "\n"
    local toolTipRight = ""
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipWC(self)
    local toolTipLeft, toolTipRight = wcTooltipLeft, wcTooltipRight
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipBlacksmith(self)
    local toolTipLeft = "Time until blacksmithing research is complete.\n"
    local toolTipRight = string.format("\n\n%s", G.blackSmithToolTipRight)
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipJewelry(self)
    local toolTipLeft = string.format("Time until jewelry crafting research is complete.\n%s", G.jewelryToolTipLeft)
    local toolTipRight = string.format("\n\n\n%s", G.jewelryToolTipRight)
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipWoodworking(self)
    local toolTipLeft = string.format("Time until woodworking research is complete.\n%s", G.woodWorkingToolTipLeft)
    local toolTipRight = string.format("\n\n\n%s", G.woodWorkingToolTipRight)
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.ShowToolTipClothing(self)
    local toolTipLeft = string.format("Time until clothing research is complete.\n%s", G.woodWorkingToolTipLeft)
    local toolTipRight = string.format("\n\n\n%s", G.clothingToolTipRight)
    SetToolTip(toolTipLeft, toolTipRight, self)
end

function TEB.HideTooltip()
    TEBTooltip:SetHidden(true)
end

--====================================================
-- global variable updaters (called from TEB.OnUpdate)
--====================================================

function TEB.latency()
    local latencyValue = GetLatency()
    local latencyColor, iconColor
    latencyColor, iconColor = TEB.checkThresholds(condition, true, settings.latency)
    G.latency = string.format("%s%d", latencyColor, latencyValue)
    TEB.SetIconByIndicator("Latency", iconColor)
end

function TEB.fps()
    local fpsColor, iconColor
    local fpsValue = math.floor(GetFramerate())
    if fpsValue < G.lowestFPS then G.lowestFPS = fpsValue end
    if fpsValue > G.highestFPS then G.highestFPS = fpsValue end
    fpsColor, iconColor = TEB.checkThresholds(fpsValue, false, settings.fps)
    G.fps = string.format("%s%d", fpsColor, fpsValue)
    TEB.SetIconByIndicator("FPS", iconColor)
end

local monthNames = {
    -- Imperial
    ["I"] = {
        "Morning Star",
        "Sun's Dawn",
        "First Seed",
        "Rain's Hand",
        "Second Seed",
        "Midyear",
        "Sun's Height",
        "Last Seed",
        "Hearthfire",
        "Frostfall",
        "Sun's Dusk	",
        "Evening Star",
    },
    -- Argonian
    ["A"] = {
        "Vakka",
        "Xeech",
        "Sisei",
        "Hist-Deek",
        "Hist-Dooka",
        "Hist-Tsoko",
        "Thtithil-Gah",
        "Thtithil",
        "Nushmeeko",
        "Shaja-Nushmeeko",
        "Saxhleel",
        "Xulomaht",
    }
}

function TEB.localTime()
    local timeFormat = timeFormats[settings.clock.Type]
    local month
    local date_format = settings.clock.DateFormat
    local dp = settings.clock.DisplayPreference
    -- ingame seconds/day = 20955
    local inGameTimeSeconds = 86400 * (GetTimeStamp() % 20955) / 20955
    G.inGameTime = os.date(timeFormat, inGameTimeSeconds)
    G.localTime = os.date(timeFormat)
    G.UTCTime = os.date("!" .. timeFormat)
    if settings.clock.Type == "12h no leading zero" then 
        if G.inGameTime:sub(1, 1) == "0" then G.inGameTime = G.inGameTime:sub(2, -1) end
        if G.localTime:sub(1, 1) == "0" then G.localTime = G.localTime:sub(2, -1) end
        if G.UTCTime:sub(1, 1) == "0" then G.UTCTime = G.UTCTime:sub(2, -1) end
    end
    local d = os.date("*t")
    -- circumvent the 100034 bug, to be removed
    local tamrielDateFmt = GetAPIVersion() == 100034 and 
        "<<1>><<i:1>> <<G:2>>" or "<<i:1>> <<G:2>>"
    G.argonianDate = ZO_CachedStrFormat(tamrielDateFmt, d.day, monthNames.A[d.month])
    G.imperialDate = ZO_CachedStrFormat(tamrielDateFmt, d.day, monthNames.I[d.month])
    G.earthDate = os.date(settings.clock.DateFormat)
    local translation = date_format:sub(-1, -1)
    if translation == 'I' then
        G.localDate = G.imperialDate 
    elseif translation == 'A' then 
        G.localDate = G.argonianDate
    else
        G.localDate = G.earthDate
    end
    G.clockString = dp == "ingame time" and G.inGameTime or
        dp == "UTC time" and G.UTCTime or dp == "local time" and G.localTime or
        dp == "local date and time" and string.format("%s %s", G.localDate, G.localTime) or
        string.format("%s/%s", G.localTime, G.inGameTime)
end

function TEB.experience()
    local gcp, gmaxxp, gxp, gxpCurrentPercentage, gxpperc, gxpneeded
    if IsUnitChampion("player") then
        gcp = GetUnitChampionPoints("player")
        if gcp < GetChampionPointsPlayerProgressionCap() then
            gcp = GetChampionPointsPlayerProgressionCap()
        elseif gcp == 3600 then
            gcp = 3599
        end
        gmaxxp = GetNumChampionXPInChampionPoint(gcp)
        gxp = GetPlayerChampionXP()
    else
        gmaxxp = GetUnitXPMax("player")
        gxp = GetUnitXP("player")
    end

    gxpCurrentPercentage = 100 * gxp / gmaxxp
    gxpCurrentPercentage = round(gxpCurrentPercentage, 1)
    gxpperc = 100 - gxpCurrentPercentage
    gxpneeded = gmaxxp - gxp

    if settings.bar.thousandsSeparator then
        gxp = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(gxp))
        gmaxxp = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(gmaxxp))
        gxpneeded = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(gxpneeded))
    else
        gxp = string.format(gxp)
        gmaxxp = string.format(gmaxxp)
        gxpneeded = string.format(gxpneeded)
    end

    if settings.experience.DisplayPreference == "% towards next level/CP" then
        G.gxpString = string.format(gxpCurrentPercentage).."%"
    elseif settings.experience.DisplayPreference == "% needed for next level/CP" then
        G.gxpString = string.format(gxpperc).."%"
    elseif settings.experience.DisplayPreference == "current XP" then
        G.gxpString = gxp
    elseif settings.experience.DisplayPreference == "needed XP" then
        G.gxpString = gxpneeded
    elseif settings.experience.DisplayPreference == "current XP/total needed" then
        G.gxpString = gxp.."/"..gmaxxp
    end

end

function TEB.zone()
    local x, y, heading = GetMapPlayerPosition("player")
    x = round(x * 100,0)
    y = round(y * 100,0)
    zoneName = GetPlayerActiveSubzoneName()
    if zoneName == "" then zoneName = GetUnitZone("player") end

    zoneName = TEB.fixname(zoneName)
    coordinates = string.format(x)..", "..string.format(y)

    if settings.location.DisplayPreference == "(x, y) Zone Name" then
        G.location = "("..coordinates..") "..zoneName
    end
    if settings.location.DisplayPreference == "Zone Name (x, y)" then
        G.location = zoneName.." ("..coordinates..")"
    end
    if settings.location.DisplayPreference == "Zone Name" then
        G.location = zoneName
    end
    if settings.location.DisplayPreference == "x, y" then
        G.location = coordinates
    end
end

function TEB.memory()
    G.memory = string.format(math.floor(collectgarbage("count") / 1024 + 0.5)).."MB"
end

function TEB.enlightenment()
    local enlightenment_amount = 0
    if IsEnlightenedAvailableForCharacter() then
        enlightenment_amount = GetEnlightenedPool()
        if settings.bar.thousandsSeparator then
            G.enlightenment = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(enlightenment_amount))
        else
            G.enlightenment = string.format(enlightenment_amount)
        end
    else
        G.enlightenment = "--"
    end

    if enlightenment_amount > 0 and not G.enlightenmentVisible then
        if not G.enlightenmentVisible then
            G.enlightenmentVisible = true
            TEB.RebuildBar()
        end
    elseif enlightenment_amount == 0 and G.enlightenmentVisible then
        if G.enlightenmentVisible then
            G.enlightenmentVisible = false
            TEB.RebuildBar()
        end
    end

    local enlightenmentColor
    enlightenmentColor, iconColor = TEB.checkThresholds(enlightenment_amount, true, settings.enlightenment)
    G.enlightenment = enlightenmentColor .. G.enlightenment
    TEB.SetIconByIndicator("Enlightenment", iconColor)
end

function TEB.pvp()
    pvp = IsUnitPvPFlagged("player")
    if pvp ~= G.pvpMode then
        G.pvpMode = pvp
        TEB.ShowBar()
        TEB.RebuildBar()
        if G.pvpMode then
            G.kills = 0
            G.killingBlows = 0
            G.deaths = 0
        end
    end

    G.killRatio = 0
    if G.deaths == 0 then
        G.killRatio = string.format(G.killingBlows)
    else
        G.killRatio = string.format(round(G.killingBlows/G.deaths, 1))..":1"
    end
    if settings.kc.DisplayPreference == "Assists/Killing Blows/Deaths (Kill Ratio)" then
        G.killCount = string.format(G.kills).."/"..string.format(G.killingBlows).."/"..string.format(G.deaths).." ("..G.killRatio..")"
    end
    if settings.kc.DisplayPreference == "Assists/Killing Blows/Deaths" then
        G.killCount = string.format(G.kills).."/"..string.format(G.killingBlows).."/"..string.format(G.deaths)
    end
    if settings.kc.DisplayPreference == "Killing Blows/Deaths (Kill Ratio)" then
        G.killCount = string.format(G.killingBlows).."/"..string.format(G.deaths).." ("..G.killRatio..")"
    end
    if settings.kc.DisplayPreference == "Killing Blows/Deaths" then
        G.killCount = string.format(G.killingBlows).."/"..string.format(G.deaths)
    end
    if settings.kc.DisplayPreference == "Kill Ratio" then
        G.killCount = G.killRatio
    end
end

function TEB.recall()
    local remain, duration = GetRecallCooldown()
    cost = GetRecallCost()
    G.ftTimerRunning = remain > 0
    if G.ftTimerRunning ~= G.ftTimerVisible then
        G.ftTimerVisible = G.ftTimerRunning
        TEB.RebuildBar()
    end
    seconds = math.floor(remain / 1000)
    timeLeft = TEB.ConvertSeconds("simple", seconds)
    if timeLeft == "" then timeLeft = "--" end
    cost = settings.bar.thousandsSeparator and zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(cost)) or tostring(cost)
    G.ft =  settings.ft.DisplayPreference == "time left" and timeLeft or
            settings.ft.DisplayPreference == "cost" and cost.."g" or
            zo_strformat("<<1>>/<<2>>g", timeLeft, cost)
end

local apFormats = {
    ["Total Points"] = "<<1>>",
    ["Session Points"] = "<<2>>",
    ["Points Per Hour"] = "<<3>>",
    ["Total Points/Points Per Hour"] = "<<1>>/<<3>>",
    ["Session Points/Points Per Hour"] = "<<2>>/<<3>>",
    ["Total Points/Session Points"] = "<<1>>/<<2>>",
    ["Total Points/Session Points (Points Per Hour)"] = "<<1>>/<<2>> (<<3>>)",
    ["Total Points/Session Points/Points Per Hour"] = "<<1>>/<<2>>/<<3>>",
}

local lvlFormats = { "<<1>>", "<<1>>/<<2>>", "<<2>>", }

local unspentFormats = {
    "|C51AB0D|t18:18:esoui/art/champion/champion_points_stamina_icon.dds|t%d",
    "|C1970C9|t18:18:esoui/art/champion/champion_points_magicka_icon.dds|t%d",
    "|CD6660C|t18:18:esoui/art/champion/champion_points_health_icon.dds|t%d",
}

function TEB.balance()
    G.lvl = GetUnitLevel("player")
    G.cp = GetPlayerChampionPointsEarned()
    local telvarc = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_CHARACTER)
    local telvarb = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_BANK)
    local goldCharacter = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    G.goldBankUnformatted = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)
    local goldTotal = goldCharacter + G.goldBankUnformatted
    G.trackedGold = 0
    local maxeventtickets = 12
    G.eventtickets = GetCurrencyAmount(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT)
    local ap = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER)
    G.crystal = GetCurrencyAmount(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)
    G.writs = GetCurrencyAmount(CURT_WRIT_VOUCHERS, CURRENCY_LOCATION_CHARACTER)
    G.etHasTickets = G.eventtickets > 0
    G.telvar = telvarc + telvarb
    goldColor, iconColor = TEB.checkThresholds(goldCharacter, false, settings.gold.low)

    if iconColor == "normal" then
        goldColor, iconColor = TEB.checkThresholds(goldCharacter, true, settings.gold.high)
    end

    if settings.bar.thousandsSeparator then
        goldCharacter = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(goldCharacter))
        G.goldBank = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(G.goldBankUnformatted))
        goldTotal = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(goldTotal))
    else
        goldCharacter = tostring(goldCharacter)
        G.goldBank = tostring(G.goldBankUnformatted)
        goldTotal = tostring(goldTotal)
    end

    if settings.gold.DisplayPreference == "gold on character" then
        G.gold = string.format("%s%s", goldColor, goldCharacter)
    elseif settings.gold.DisplayPreference == "gold on character/gold in bank" then
        G.gold = string.format("%s%s|r/%s", goldColor, goldCharacter, G.goldBank)
    elseif settings.gold.DisplayPreference == "gold on character (gold in bank)" then
        G.gold = string.format("%s%s|r (%s)", goldColor, goldCharacter, G.goldBank)
    elseif settings.gold.DisplayPreference == "character+bank gold" then
        G.gold = goldTotal
    elseif settings.gold.DisplayPreference == "tracked gold" or
        settings.gold.DisplayPreference == "tracked+bank gold" then
        if settings.gold.DisplayPreference == "tracked+bank gold" then
            G.trackedGold = G.goldBankUnformatted
        end
        for k, v in pairs(settings.gold.Tracker) do
            if v[1] then
                G.trackedGold = G.trackedGold + v[2]
            end
        end
        G.Gold = settings.bar.thousandsSeparator and
            zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(G.trackedGold)) or
            zo_strformat("<<1>>", G.trackedGold)
    end
    TEB.SetIconByIndicator("Gold", iconColor)

    local ap_Session = ap - G.ap_SessionStartPoints
    local ap_Hour = 0
    if os.time() - G.ap_SessionStart > 0 then
        if os.time() - G.ap_SessionStart < 3600 then
            ap_Hour = math.floor(ap_Session)
        else
            ap_Hour = math.floor(ap_Session / ((os.time() - G.ap_SessionStart) / 3600))
        end
    end

    if settings.bar.thousandsSeparator then
        G.telvar = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(G.telvar))
        ap = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(ap))
        ap_Session = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(ap_Session))
        ap_Hour = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(ap_Hour))
        G.crystal = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(G.crystal))
        G.writs = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(G.writs))
    else
        G.telvar = tostring(G.telvar)
        ap = string.format(ap)
        ap_Session = string.format(ap_Session)
        ap_Hour = string.format(ap_Hour)
        G.crystal = string.format(G.crystal)
        G.writs = string.format(G.writs)
    end
    G.apString = zo_strformat(apFormats[settings.ap.DisplayPreference],
        ap, ap_Session, ap_Hour)

    -- tickets
    local etIcon = "normal"
    local etColor = "|ccccccc"
    if G.eventtickets >= settings.et.danger then
        etColor = "|ccc0000"
        etIcon = "danger"
    elseif G.eventtickets >= settings.et.warning then
        etColor = "|cffdf00"
        etIcon = "warning"
    end
    G.eventtickets = string.format("%s%s", etColor, G.eventtickets)
    if settings.et.DisplayPreference == "tickets/max" then
        G.eventtickets = G.eventtickets.."/12"
    end
    TEB.SetIcon("Event Tickets", etIcon)

    -- level & CP
    G.lvlText = ""
    unspentMage = GetNumUnspentChampionPoints( 1 )
    unspentWarrior = GetNumUnspentChampionPoints( 2 )
    unspentThief = GetNumUnspentChampionPoints( 3 )
    unspentTotal = unspentWarrior + unspentMage + unspentThief
    local fmt = G.lvl < 50 and lvlFormats[settings.level.notmax.DisplayPreference] or
        lvlFormats[settings.level.max.DisplayPreference]
    local unspentText = ""
    if G.lvl < 50 and settings.level.notmax.cp or settings.level.max.cp then
        local dyn = G.lvl < 50 and settings.level.notmax.Dynamic or settings.level.max.Dynamic
        if not dyn or unspentTotal > 0 then
            local t = { " (" }
            for i, u in ipairs({unspentThief, unspentMage, unspentWarrior}) do
                if not dyn or u > 0 then
                    table.insert(t, string.format(unspentFormats[i], u))
                end
            end
            table.insert(t, "|ccccccc)")
            unspentText = table.concat(t, "")
        end
    end
    G.lvlText = zo_strformat(fmt, G.lvl, G.cp) .. unspentText
end

function TEB.mounttimer()
    mountTimeLeft = GetTimeUntilCanBeTrained() / 1000
    if STABLE_MANAGER:IsRidingSkillMaxedOut() then
        G.mountlbltxt = "Maxed"
        G.mountTimerNotMaxed = false
    else
        G.mountTimerNotMaxed = true
        if mountTimeLeft == 0 then
            G.mountlbltxt = "TRAIN!"
        else
            G.mountlbltxt = TEB.ConvertSeconds(settings.mount.DisplayPreference, mountTimeLeft)
        end
    end

    if G.mountlbltxt == "Maxed" and not G.mountTimerVisible then
        G.mountTimerVisible = true
        TEB.RebuildBar()
    end
    if G.mountlbltxt ~= "Maxed" and G.mountTimerVisible then
        G.mountTimerVisible = false
        TEB.RebuildBar()
    end

    if G.mountlbltxt == "TRAIN!" then
        if settings.mount.good then G.mountlbltxt = "|c00e900"..G.mountlbltxt end
        if settings.mount.good and settings.iconIndicator["Mount Timer"] then
            TEB.SetIcon("Mount Timer", "good")
        end
    else
        if gadgetReference["Mount Timer"][6] then
                TEB.RemovePulseItem("Mount Timer")
        end
        if settings.mount.good and settings.iconIndicator["Mount Timer"] then
            TEB.SetIcon("Mount Timer", "normal")
        end
    end
end

-- for bag and bank
local bagFormats = {
    ["slots used/total slots"] = "<<1>><<2>>/<<4>>",
    ["used%"] = "<<1>><<5>>",
    ["slots free/total slots"] = "<<1>><<3>>/<<4>>",
    ["slots free"] = "<<1>><<3>>",
    ["free%"] = "<<1>><<6>>",
}

function TEB.bang(name, usedslots, maxslots, bagOrBank) -- bank & bag
    local freeSlots = maxslots - usedslots
    local bagPercentUsed = math.floor((usedslots / maxslots) * 100)
    local bagPercentFree = 100 - bagPercentUsed
    local testval = bagOrBank.UsageAsPercentage and bagPercentUsed or usedslots
    local bagColor, iconColor = TEB.checkThresholds(testval, true, bagOrBank)
    TEB.SetIconByIndicator(name, iconColor)
    if iconColor == "critical" and settings.bar.pulseWhenCritical then
        TEB.AddPulseItem(name)
    else
        TEB.RemovePulseItem(name)
    end
    local fmt = bagFormats[bagOrBank.DisplayPreference]
    return zo_strformat(fmt, bagColor, usedslots, freeSlots, maxslots, bagPercentUsed, bagPercentFree)
end

function TEB.bags()
    G.bagUsedSlots, G.bagMaxSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
    G.bagInfo = TEB.bang("Bag Space", G.bagUsedSlots, G.bagMaxSlots, settings.bag)
end

function TEB.bank()
    G.bankUsedSlots, G.bankMaxSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BANK)
    G.bankInfo = TEB.bang("Bank Space", G.bankUsedSlots, G.bankMaxSlots, settings.bank)
end

function TEB.weaponcharge()
    local activeWeaponPair, locked = GetActiveWeaponPairInfo()

    local mainHandChargePerc = 0
    local offHandChargePerc = 0
    local mainHandHasPoison = false
    local mainHandPoisonCount = 0
    local backupMainHandChargePerc = 0
    local backupOffHandChargePerc = 0

    local mainHandHasPoison, mainHandPoisonCount = getpoisoncount(EQUIP_SLOT_MAIN_HAND)
    local backupMainHandHasPoison, backupMainHandPoisonCount = getpoisoncount(EQUIP_SLOT_BACKUP_MAIN)

    mainHandChargePerc = getitemcharge(EQUIP_SLOT_MAIN_HAND)
    offHandChargePerc = getitemcharge(EQUIP_SLOT_OFF_HAND)
    backupMainHandChargePerc = getitemcharge(EQUIP_SLOT_BACKUP_MAIN)
    backupOffHandChargePerc = getitemcharge(EQUIP_SLOT_BACKUP_OFF)

    if activeWeaponPair == 0 then
        wcToolTipLeft = "|cffffffWeapon Charge:|cccccc\nNo weapons are equipped."
        wcToolTipRight = ""
        G.weaponCharge = "--"
        return
    end
    if activeWeaponPair == 1 then
        mainCharge = mainHandChargePerc
        offCharge = offHandChargePerc
        hasPoison = mainHandHasPoison
        poisonCount = mainHandPoisonCount
    elseif activeWeaponPair == 2 then
        mainCharge = backupMainHandChargePerc
        offCharge = backupOffHandChargePerc
        hasPoison = backupMainHandHasPoison
        poisonCount = backupMainHandPoisonCount
    end

    local leastPerc = mainCharge
    if offCharge < mainCharge then leastPerc = offCharge end

    local wcColor, iconColor, poisonColor = getWCColor(leastPerc, hasPoison, poisonCount)
    if hasPoison and settings.wc.AutoPoison then
        G.weaponCharge = poisonColor..string.format(poisonCount)
    else
        if leastPerc == 10000 then
            G.weaponCharge = wcColor.."--"
        else
            G.weaponCharge = wcColor..string.format(leastPerc).."%"
        end
    end

    TEB.SetIconByIndicator("Weapon Charge/Poison", iconColor)

    if hasPoison and settings.wc.AutoPoison then
        if poisonCount < settings.wc.PoisonCritical and settings.bar.pulseWhenCritical then
            TEB.AddPulseItem("Weapon Charge/Poison")
        end
        if poisonCount >= settings.wc.PoisonCritical or not settings.bar.pulseWhenCritical then
            TEB.RemovePulseItem("Weapon Charge/Poison")
        end
    else
        if leastPerc < settings.wc.critical and settings.bar.pulseWhenCritical then
            TEB.AddPulseItem("Weapon Charge/Poison")
        end
        if leastPerc >= settings.wc.critical or not settings.bar.pulseWhenCritical then
            TEB.RemovePulseItem("Weapon Charge/Poison")
        end
    end

    wcTooltipLeft = "|cffffffWeapon Charge:|cccccc\n"
    wcTooltipRight = ""

    if mainHandChangePerc ~= 10000 and mainHandChargePerc then
        local wcColor, iconColor, poisonColor = getWCColor(mainHandChargePerc, mainHandHasPoison, mainHandPoisonCount)
        wcTooltipLeft = wcTooltipLeft .. "\n"..wcColor..TEB.fixname(GetItemName(BAG_WORN, EQUIP_SLOT_MAIN_HAND))
        wcTooltipRight = wcTooltipRight .. "\n"..wcColor..string.format(mainHandChargePerc).."%"
    end
    if offHandChargePerc ~= 10000 and offHandChargePerc then
        local wcColor, iconColor, poisonColor = getWCColor(offHandChargePerc, mainHandHasPoison, mainHandPoisonCount)
        wcTooltipLeft = wcTooltipLeft .. "\n"..wcColor..TEB.fixname(GetItemName(BAG_WORN, EQUIP_SLOT_OFF_HAND))
        wcTooltipRight = wcTooltipRight .. "\n"..wcColor..string.format(offHandChargePerc).."%"
    end
    if backupMainHandChargePerc ~= 10000 and backupMainHandChargePerc then
        local wcColor, iconColor, poisonColor = getWCColor(backupMainHandChargePerc, backupMainHandHasPoison, backupMainHandPoisonCount)
        wcTooltipLeft = wcTooltipLeft .. "\n"..wcColor..TEB.fixname(GetItemName(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN))
        wcTooltipRight = wcTooltipRight .. "\n"..wcColor..string.format(backupMainHandChargePerc).."%"
    end
    if backupOffHandChargePerc ~= 10000 and backupOffHandChargePerc then
        local wcColor, iconColor, poisonColor = getWCColor(backupOffHandChargePerc, backupMainHandHasPoison, backupMainHandPoisonCount)
        wcTooltipLeft = wcTooltipLeft .. "\n"..wcColor..TEB.fixname(GetItemName(BAG_WORN, EQUIP_SLOT_BACKUP_OFF))
        wcTooltipRight = wcTooltipRight .. "\n"..wcColor..string.format(backupOffHandChargePerc).."%"
    end

    if mainHandHasPoison or backupMainHandHasPoison then
        wcTooltipLeft = wcTooltipLeft .. "\n\nPoison Count:"
        wcTooltipRight = wcTooltipRight .. "\n\n"

        if mainHandHasPoison then
            local wcColor, iconColor, poisonColor = getWCColor(mainHandChargePerc, mainHandHasPoison, mainHandPoisonCount)
            wcTooltipLeft = wcTooltipLeft .. "\n"..poisonColor.."Primary Weapon"
            wcTooltipRight = wcTooltipRight .. "\n"..poisonColor..string.format(mainHandPoisonCount)
        end
        if backupMainHandHasPoison  then
            local wcColor, iconColor, poisonColor = getWCColor(backupMainHandChargePerc, backupMainHandHasPoison, backupMainHandPoisonCount)
            wcTooltipLeft = wcTooltipLeft .. "\n"..poisonColor.."Secondary Weapon"
            wcTooltipRight = wcTooltipRight .. "\n"..poisonColor..string.format(backupMainHandPoisonCount)
        end
    end

end

function getpoisoncount(slotNum)
    local hasPoison, poisonCount, poisonHeader, poisonItemLink = GetItemPairedPoisonInfo(slotNum)
    return hasPoison, poisonCount
end

function getitemcharge(slotNum)
    local itemLink = GetItemLink( BAG_WORN, slotNum )
    if itemLink == nil or link == "" then
        return 10000
    end
    if not IsItemChargeable( BAG_WORN, slotNum ) then
        return 10000
    end
    local currentCharge = GetItemLinkNumEnchantCharges(itemLink)
    local maxCharge = GetItemLinkMaxEnchantCharges(itemLink)
    return math.floor((currentCharge / maxCharge) * 100)
end

function getWCColor(wcPerc, hasPoison, poisonCount)
    local wcColor = "|ccccccc"
    local poisonColor = "|cccccc"
    local iconColor = "normal"
    if hasPoison and settings.wc.AutoPoison then
        if poisonCount <= settings.wc.PoisonWarning then
            poisonColor = "|cffff00"
            iconColor = "caution"
        end
        if poisonCount <= settings.wc.PoisonDanger then
            poisonColor = "|cff8000"
            iconColor = "warning"
        end
        if poisonCount <= settings.wc.PoisonCritical then
            poisonColor = "|cff0000"
            iconColor = "danger"
        end
    else
        if wcPerc then
            if wcPerc <= settings.wc.warning then
                wcColor = "|cffff00"
                iconColor = "caution"
            end
            if wcPerc <= settings.wc.danger then
                wcColor = "|cff8000"
                iconColor = "warning"
            end
            if wcPerc <= settings.wc.critical then
                wcColor = "|cff0000"
                iconColor = "danger"
            end
        end
    end
    return wcColor, iconColor, poisonColor
end

local durabilityFormats = {
    ["durability %" ] = "<<1>>%",
    ["durability %/repair cost" ] = "<<1>>%|ccccccc/<<2>>",
    ["repair cost" ] = "<<2>>",
    ["durability % (repair kits)" ] = "<<1>>% (<<3>>)",
    ["durability %/repair cost (repair kits)" ] = "<<1>>%|ccccccc/<<2>> (<<3>>)",
    ["repair cost (repair kits)" ] = "<<2>> (<<3>>)",
    ["most damaged" ] = "<<4>>",
    ["most damaged/durability %" ] = "<<4>>/<<5>>%",
    ["most damaged/durability %/repair cost" ] = "<<4>>/<<5>>%/<<6>>g",
    ["most damaged/repair cost" ] = "<<4>>/<<6>>g",
}

function TEB.durability()
    local repairCost
    local leastDurability = 100
    local totalRepairCost = 0
    local mostDamagedItem = ""
    local mostDamagedCost = 0
    local mostDamagedCondition = 100
    local durabilityColor
    local toolTipLeft = { "Armor durability." }
    local toolTipRight = { "" }

    for slotIndex = 0, 16, 1 do
        if DoesItemHaveDurability(BAG_WORN, slotIndex) then
            if repairCost == nil or repairCost == "" then
                repairCost = 0
            else
                repairCost = GetItemRepairCost(BAG_WORN, slotIndex)
            end
            totalRepairCost = totalRepairCost + repairCost
            condition = GetItemCondition(BAG_WORN, slotIndex)
            if condition < mostDamagedCondition then
                mostDamagedItem = equipSlotReference[slotIndex]
                mostDamagedCost = repairCost
                mostDamagedCondition = condition
            end
            if leastDurability > condition then
                leastDurability = condition
            end
            durabilityColor, iconColor = TEB.checkThresholds(condition, false, settings.durability)
            table.insert(toolTipLeft, zo_strformat("<<C:1>>", GetItemName(BAG_WORN, slotIndex)))
            table.insert(toolTipRight, string.format("%s(%dg) %d%%", durabilityColor, repairCost, condition))
        end
    end

    if settings.bar.thousandsSeparator then
        totalRepairCost = zo_strformat("<<1>>g", ZO_LocalizeDecimalNumber(totalRepairCost))
    else
        totalRepairCost = zo_strformat("<<1>>g", totalRepairCost)
    end

    G.durabilityTooltipLeft = table.concat( toolTipLeft, "\n") ..
        table.concat( { "\n|cff3030Total Repair Cost|r\n", "Petty Repair Kit", "Minor Repair Kit", "Lesser Repair Kit",
            "Common Repair Kit", "Greater Repair Kit", "Grand Repair Kit",
            "Crown Repair Kit" }, "\n")
    G.durabilityTooltipRight = table.concat( toolTipRight, "\n") ..
        table.concat( { "\n|cff3030" .. totalRepairCost, "|r",
            G.pettyRepairKit, G.minorRepairKit, G.lesserRepairKit,
            G.commonRepairKit, G.greaterRepairKit, G.grandRepairKit,
            G.crownRepairKit }, "\n")

    local durabilityColor
    durabilityColor, iconColor = TEB.checkThresholds(leastDurability, false, settings.durability)
    TEB.SetIconByIndicator("Durability", iconColor)
    if iconColor == "critical" and settings.bar.pulseWhenCritical then
        TEB.AddPulseItem("Durability")
    else
        TEB.RemovePulseItem("Durability")
    end

    local fmt = durabilityFormats[settings.durability.DisplayPreference]
    G.durabilityInfo = zo_strformat(fmt,
        leastDurability, totalRepairCost, G.totalRepairKits,
        mostDamagedItem, mostDamagedCondition, mostDamagedCost)
end

local skyshardsFormats = {
    ["collected/unspent points"] = "<<1>>/<<2>>",
    ["collected/total needed (unspent points)"] = "<<1>>/3 (<<2>>)",
    ["collected"] = "<<1>>",
    ["needed/unspent points"] = "<<3>>/<<2>>",
    ["needed"] = "<<3>>",
}

function TEB.skyshards()
    G.availablePoints = GetAvailableSkillPoints()
    G.skyShards = GetNumSkyShards()
    local fmt = skyshardsFormats[settings.skyshards.DisplayPreference]
    G.skyShardsInfo = zo_strformat(fmt, G.skyShards, G.availablePoints, 3 - G.skyShards)
end

function TEB.blacksmithing()
    G.blackSmithingInfo, G.blackSmithingTimerRunning,
    G.blackSmithToolTipLeft, G.blackSmithToolTipRight =
    TEB.researchtimer(TEBTopResearchBlacksmithingIcon, CRAFTING_TYPE_BLACKSMITHING)

    if G.blackSmithingTimerRunning and not G.blacksmithTimerVisible then
        G.blacksmithTimerVisible = true
        TEB.RebuildBar()
    elseif not G.blackSmithingTimerRunning and G.blacksmithTimerVisible then
        G.blacksmithTimerVisible = false
        TEB.RebuildBar()
    end
end

function TEB.clothing()
    G.clothingInfo, G.clothingTimerRunning, G.clothingToolTipLeft, G.clothingToolTipRight = TEB.researchtimer(TEBTopResearchClothingIcon, CRAFTING_TYPE_CLOTHIER)
    if G.clothingTimerRunning and not G.clothingTimerVisible then
        G.clothingTimerVisible = true
        TEB.RebuildBar()
    elseif not G.clothingTimerRunning and G.clothingTimerVisible then
        G.clothingTimerVisible = false
        TEB.RebuildBar()
    end
end

function TEB.woodworking()
    G.woodWorkingInfo, G.woodWorkingTimerRunning, G.woodWorkingToolTipLeft, G.woodWorkingToolTipRight = TEB.researchtimer(TEBTopResearchWoodworkingIcon, CRAFTING_TYPE_WOODWORKING)
    if G.woodWorkingTimerRunning and not G.woodworkingTimerVisible then
        G.woodworkingTimerVisible = true
        TEB.RebuildBar()
    elseif not G.woodWorkingTimerRunning and G.woodworkingTimerVisible then
        G.woodworkingTimerVisible = false
        TEB.RebuildBar()
    end
end

function TEB.jewelrycrafting()
    G.jewelryCraftingInfo, G.jewelryTimerRunning, G.jewelryToolTipLeft, G.jewelryToolTipRight = TEB.researchtimer(TEBTopResearchJewelryCraftingIcon, CRAFTING_TYPE_JEWELRYCRAFTING)
    if G.jewelryTimerRunning and not G.jewelryTimerVisible or
        not G.jewelryTimerRunning and G.jewelryTimerVisible then
        G.jewelryTimerVisible = G.jewelryTimerRunning
        TEB.RebuildBar()
    end
end

function TEB.researchtimer(researchIcon, craftId)
    researchInfo = ""
    local leastTime = 9999999
    local toolTipLeft = ""
    local toolTipRight = ""
    local timerRunning = false
    local freeSlots = 0
    local timers, totalSlots, traits = TEB.CalculateCraftingTimers(craftId)
    if #timers > 0 then
        timerRunning = true
        for timerIndex=1,#timers do
            if timers[timerIndex] < leastTime then
                leastTime = timers[timerIndex]
            end
            toolTipLeft = toolTipLeft .. "\n" .. "Slot "..string.format(timerIndex).." - "..traits[timerIndex]
            if researchInfo ~= "" then
                researchInfo = researchInfo .."|ccccccc/"
            end
            local timerString = TEB.ConvertSeconds(settings.research.DisplayPreference, timers[timerIndex])
            researchInfo = researchInfo .. timerString
            toolTipRight = toolTipRight .."\n".. timerString
        end
        for timerIndex=#timers+1,totalSlots do
            freeSlots = freeSlots + 1
            toolTipLeft = toolTipLeft .. "\n" .. "Slot "..string.format(timerIndex)
            toolTipRight = toolTipRight .."\n"..settings.research.FreeText
        end
        if settings.research.DisplayAllSlots then
            for timerIndex=#timers+1,totalSlots do
                if researchInfo ~= "" then
                    researchInfo = researchInfo .."|ccccccc/"
                end
                researchInfo = researchInfo ..settings.research.FreeText
            end
        end
    end
    toolTipLeft = toolTipLeft .. "\n\n".."Free Slots: "..string.format(freeSlots).."\nTotal Slots: "..string.format(totalSlots)

    if settings.research.ShowShortest then
        if leastTime == 9999999 then
            researchInfo = settings.research.FreeText
        else
            researchInfo = TEB.ConvertSeconds(settings.research.DisplayPreference, leastTime)
        end
    end

    if settings.research.DisplayAllSlots then
        if researchInfo ~= "" then
            researchInfo = researchInfo .."|ccccccc ("..string.format(freeSlots)..")"
        end
    end

    return researchInfo, timerRunning, toolTipLeft, toolTipRight
end

function TEB.ConvertSeconds(displayMethod, seconds)

    local timeString = ""
    local days = math.floor(seconds/86400)
    local hours = math.floor(seconds/3600)
    local mins = math.floor(seconds/60 - (hours*60))
    local secs = math.floor(seconds - hours*3600 - mins *60)
    if days > 0 then hours = hours - (days * 24) end
    if displayMethod == "short" then
        if days > 0 then
            timeString = string.format(days).."d"..string.format(hours).."h"
        end
        if hours > 0 and timeString == "" then
            timeString = string.format(hours).."h"..string.format(mins).."m"
        end
        if mins > 0 and timeString == "" then
            timeString = string.format(mins).."m"..string.format(secs).."s"
        end
        if secs > 0 and timeString == "" then
            timeString = string.format(secs).."s"
        end
    end
    if displayMethod == "simple" then
        if days > 0 then
            timeString = string.format(days).."d"
        end
        if hours > 0 and timeString == "" then
            timeString = string.format(hours+1).."h"
        end
        if mins > 0 and timeString == "" then
            timeString = string.format(mins+1).."m"
        end
        if secs > 0 and timeString == "" then
            timeString = string.format(secs).."s"
        end
    end
    if displayMethod == "exact" then
        timeString = ""
        if days > 1 then
            timeString = timeString .. string.format(days) .. "d"
        end
        timeString = timeString .. string.format("%02.f", hours).."h"..string.format("%02.f", mins).."m"..string.format("%02.f", secs).."s"
    end
    return timeString
end

function TEB.CalculateCraftingTimers(craftId)
    timers = {}
    local totalSlots = GetMaxSimultaneousSmithingResearch(craftId)
    local totalResearchLines = GetNumSmithingResearchLines(craftId)
    local usedSlots = 0
    traits = {}

    for researchLine = 1, totalResearchLines do
        local lineName, icon, totalTraits, researchTimeSecs = GetSmithingResearchLineInfo(craftId, researchLine)
        for traitNum=1, totalTraits do
            totalSecs, remainingSecs = GetSmithingResearchLineTraitTimes(craftId, researchLine, traitNum)
            if remainingSecs ~= nil then
                local traitId, traitDescription, known = GetSmithingResearchLineTraitInfo(craftId, researchLine, traitNum)
                usedSlots = usedSlots + 1
                timers[usedSlots] = remainingSecs
                traits[usedSlots] = traitReference[traitId]
            end

        end
    end

    return timers, totalSlots, traits
end

function TEB.UpdateKillingBlows( eventID, result , isError , abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log )
    if G.pvpMode then
        local target = zo_strformat("<<1>>", targetName)
        local source = zo_strformat("<<1>>", sourceName)
        if sourceType == COMBAT_UNIT_TYPE_PLAYER and targetType == COMBAT_UNIT_TYPE_OTHER then
            G.kills = G.kills + 1
            if abilityName ~= "" then -- If I got the killing blow
                G.killingBlows = G.killingBlows + 1
            end
        end
     end
end

function TEB.buffs()
    local textColor, iconColor
    local isBuffActive, timeLeftInSeconds, abilityId = G.LFDB:IsFoodBuffActiveAndGetTimeLeft("player")
    if isBuffActive then
        G.foodTimerRunning = true
        G.foodBuffWasActive = true
        local numBuffs = GetNumBuffs("player")
        for buffIndex=1, numBuffs do
            local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, BuffEffectType, AbilityType, StatusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("player", buffIndex)
        end
    else
        G.foodTimerRunning = false
    end

    if timeLeftInSeconds < settings.food.critical and timeLeftInSeconds > 0 or
        timeLeftInSecond == 0 and G.foodBuffWasActive and settings.bar.pulseWhenCritical then
        TEB.AddPulseItem("Food Buff Timer")
    elseif timeLeftInSeconds >= settings.food.critical or
        not settings.bar.pulseWhenCritical then
        TEB.RemovePulseItem("Food Buff Timer")
    end
    local foodColor
    foodColor, iconColor = TEB.checkThresholds(timeLeftInSeconds, false, settings.food)
    TEB.SetIconByIndicator("Food Buff Timer", iconColor)
    if G.foodTimerRunning ~= G.foodTimerVisible then
        G.foodTimerVisible = G.foodTimerRunning
        TEB.RebuildBar()
    end
    foodTooltip = TEB.ConvertSeconds(settings.food.DisplayPreference, timeLeftInSeconds)
    G.food = foodColor..foodTooltip
    G.mundus = "None"
    numBuffs = GetNumBuffs("player")
    if numBuffs then
        for i = 0, numBuffs, 1 do
            buffName,timeStarted,timeEnding,buffSlot,stackCount,textureName, buffType, effectType, abilityType, statusEffectType,abilityId,canClickOff = GetUnitBuffInfo("player", i)
            if textureName and textureName ~= "" and
                PlainStringFind(textureName,"ability_mundusstones_") then
                local mundusBuff = ZO_CachedStrFormat("<<C:1>>", textureName)
                G.mundus = tonumber(string.sub(mundusBuff,-7, -5))
            end
            if textureName and textureName ~= "" and PlainStringFind(textureName,"_vampire_infection_") then
                if not G.isVampire then
                    G.isVampire = true
                    TEB.RebuildBar()
                end
                local timeEnding = math.floor(timeEnding) * 1000
                local timeStarted = math.floor(timeStarted)
                local vampireStage = string.match(buffName,"%d+")
                local stage = tonumber(vampireStage)
                local buffTimeLeft = math.floor((timeEnding - GetFrameTimeMilliseconds()) / 1000)
                local vampireTimeLeft = TEB.ConvertSeconds(settings.vampirism.TimerPreference, buffTimeLeft)
                local skillIndex = 0
                local SkillLinesCount = GetNumSkillLines(SKILL_TYPE_WORLD)
                local nextRankXP
                local currentXP
                local lineName
                local lineLevel = 0
                local skillLineId
                local vampireSkillsID = 51
                for i=1, SkillLinesCount, 1 do
                    skillLineId = GetSkillLineId(SKILL_TYPE_WORLD, i)
                    if skillLineId == vampireSkillsID then
                        skillIndex = i
                        break
                    end
                end
                if skillIndex > 0 then
                    local rank,advised,active,discovered = GetSkillLineDynamicInfo(SKILL_TYPE_WORLD, skillIndex)
                    if discovered == true and active == true then
                        _, nextRankXP, currentXP = GetSkillLineXPInfo(SKILL_TYPE_WORLD, skillIndex)
                    end
                    if GetSkillLineInfo then
                        _, lineLevel = GetSkillLineInfo(SKILL_TYPE_WORLD, skillIndex)
                    else
                        local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(SKILL_TYPE_WORLD, skillIndex)
                        if skillLineData then
                            _, lineLevel = skillLineData:GetName(), skillLineData:GetCurrentRank()
                        end
                    end
                end
                vampireLevel = lineLevel
                --vampireLevelPercent = round((currentXP / nextRankXP)*100, 1)
                --vampireLevelPercentLeft = round(100 - vampireLevelPercent, 1)
                if stage == 1 then vampireTimeLeft = "--" end
                local textColor = "|ccccccc"
                iconColor = "normal"
                local s = settings.vampirism.StageColor[stage]
                if s ~= "normal" then
                    textColor, iconColor = unpack(Vampirism_StageColors[s])
                end
                G.vampireText = textColor .. vampireTimeLeft
                if settings.vampirism.DisplayPreference == "Stage (Timer)" then
                    G.vampireText = string.format("%s%s (%s)", textColor, vampireStage, vampireTimeLeft)
                end
                TEB.SetIcon("Vampirism", iconColor)
                vampTooltipRight = string.format("%s%s\n|ccccccc%s", textColor, vampireStage, vampireTimeLeft)
           end
        end
    end

end

local bountyColors = {
    yellow = { "|cffff00", "caution", },
    orange = { "|cff8000", "warning", },
    red =    { "|cff0000", "danger", },
}

function TEB.bounty()
    local infamyLevels = {
        [INFAMY_THRESHOLD_DISREPUTABLE] = { "Disreputable", settings.bounty.warning, },
        [INFAMY_THRESHOLD_NOTORIOUS] = { "Notorious", settings.bounty.danger, },
        [INFAMY_THRESHOLD_FUGITIVE] = { "Fugitive", settings.bounty.critical, },
    }
    local bountyColor, iconColor
    local bountyTime = GetSecondsUntilBountyDecaysToZero()
    local heatTime = GetSecondsUntilHeatDecaysToZero()
    G.bountyTimerRunning =  bountyTime > 0 or heatTime > 0
    local longestTime = heatTime
    if bountyTime > heatTime then longestTime = bountyTime end
    if settings.bounty.good == "normal" then
        bountyColor = "|ccccccc"
        iconColor = "normal"
    else
        bountyColor = "|c00ff00"
        iconColor = "good"
    end
    local infamyAmount =  GetInfamy()
    local infamy = GetInfamyLevel(infamyAmount)
    infamyText = "Upstanding"
    if infamyLevels[infamy] then
        infamyText, bountyLevel = unpack(infamyLevels[infamy])
        bountyColor, iconColor = unpack(bountyColors[bountyLevel])
    end
    bountyPayoff = GetReducedBountyPayoffAmount()
    bountyTimerText = TEB.ConvertSeconds(settings.bounty.DisplayPreference, bountyTime)
    heatTimerText = TEB.ConvertSeconds(settings.bounty.DisplayPreference, heatTime)
    infamyText = bountyColor..infamyText
    G.bounty = bountyColor..TEB.ConvertSeconds(settings.bounty.DisplayPreference, longestTime)
    TEB.SetIcon("Bounty/Heat Timer", iconColor)
    if G.bountyTimerRunning and not G.bountyTimerVisible then
        -- turn on
        G.bountyTimerVisible = true
        TEB.RebuildBar()
    elseif not G.bountyTimerRunning and G.bountyTimerVisible then
        -- turn off
        G.bountyTimerVisible = false
        TEB.RebuildBar()
    end
end

function TEB.mail()
    G.unread_mail = GetNumUnreadMail()
    if not G.mailUnread and G.unread_mail > 0  then
        G.mailUnread = true
        TEB.RebuildBar()
    elseif G.mailUnread and G.unread_mail == 0 then
        G.mailUnread = false
        TEB.RebuildBar()
    end

    if G.unread_mail > 0 then
        if settings.mail.good and settings.iconIndicator["Unread Mail"] then
            TEB.SetIcon("Unread Mail", "good")
        else
            TEB.SetIcon("Unread Mail", "normal")
        end
    end
    if settings.mail.good and G.unread_mail > 0 then
        G.unread_mail = string.format("|c00e900%s", G.unread_mail)
    end

end

function TEB.UpdateDeaths()
    if G.pvpMode then
        G.deaths = G.deaths + 1
    end
end

local soulgemToolTips = {
    ["total filled/empty"] = "Total filled / empty soul gems.",
    ["total filled (crown)/empty"] = "Total filled (crown filled) / empty soul gems.",
    ["total filled (empty)"] = "Total filled (empty) soul gems.",
    ["normal filled/crown/empty"] = "Normal filled / crown / empty soul gems.",
    ["total filled"] = "Total filled soul gems.",
    ["normal filled"] = "Normal filled soul gems.",
}

local soulgemsFormats = {
    ["total filled/empty"] =  "<<1>>|ccccccc/<<4>>",
    ["total filled (crown)/empty"] = "<<1>> |ccccccc(<<3>>|ccccccc)/<<4>>",
    ["total filled (empty)"] = "<<1>>|ccccccc(<<4>>)",
    ["normal filled/crown/empty"] = "<<2>>|ccccccc/<<3>>|ccccccc/<<4>>",
    ["total filled"] = "<<1>>",
    ["normal filled"] = "<<2>>",
}

local ttFormats = {

    ["lockpicks"] = "<<1>>",
    ["total stolen"] = "<<2>>",
    ["total stolen (lockpicks)"] = "<<2>> (<<1>>)",
    ["stolen treasures/stolen goods"] = "<<3>>/<<4>>",
    ["stolen treasures/stolen goods (lockpicks)"] = "<<3>>/<<4>> (<<1>>)",
    ["stolen treasures/fence_remaining stolen goods/launder_remaining"] = "<<3>>/<<7>><<5>>|ccccccc <<4>>/<<8>><<6>>",
    ["stolen treasures/fence_remaining stolen goods/launder_remaining (lockpicks)"] = "<<3>>/<<7>><<5>>|ccccccc <<4>>/<<8>><<6>>|ccccccc (<<1>>)",
    ["stolen treasures/stolen goods fence_remaining/launder_remaining"] = "<<3>>/<<4>> <<7>><<5>>|ccccccc/<<8>><<6>>",
    ["stolen treasures/stolen goods fence_remaining/launder_remaining (lockpicks)"] = "<<3>>/<<4>> <<7>><<5>>|ccccccc/<<8>><<6>>|ccccccc (<<1>>)",
}

local itemsInSlot = {
    [33271] = "normal_filled",
    [61080] = "crown_filled",
    [33265] = "empty",
    [44874] = "pettyRepairKit",
    [44875] = "minorRepairKit",
    [44876] = "lesserRepairKit",
    [44877] = "commonRepairKit",
    [44878] = "greaterRepairKit",
    [44879] = "grandRepairKit",
    [61079] = "crownRepairKit",
    -- to initialize G[n] in the same loop
    ["treasures"]       = "treasures" ,
    ["not_treasures"]   = "not_treasures",
    ["stolenSlots"] =   "stolenSlots",
}

function TEB.CalculateBagItems()
    G.bagUsedSlots, G.bagMaxSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)

    for k, n in pairs(itemsInSlot) do
        G[n] = 0
    end

    for slotIndex = 0, G.bagMaxSlots-1 do
        local itemLink = GetItemLink( INVENTORY_BACKPACK, slotIndex )
        local itemType, specializedItemType = GetItemLinkItemType( itemLink )
        local itemId = GetItemLinkItemId( itemLink )
        local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType,
            itemStyleId, itemQuality = GetItemInfo(INVENTORY_BACKPACK, slotIndex)
        local key
        if IsItemLinkStolen( itemLink ) then
            G.stolenSlots = G.stolenSlots + 1
            key = itemType == ITEMTYPE_TREASURE and "treasures" or "not_treasures"
        else
            key = itemsInSlot[itemId]
        end
        if key then
            -- d(zo_strformat("<<1>> <<2>> <<3>>", itemId, key, stack))
            G[key] = G[key] + stack
        end
    end

    -- repair kits
    G.totalRepairKits = G.pettyRepairKit + G.minorRepairKit + G.lesserRepairKit +
        G.commonRepairKit + G.greaterRepairKit + G.grandRepairKit + G.crownRepairKit

    -- soul gems
    G.total_filled = G.normal_filled + G.crown_filled
    local crown_color, total_color, normal_color, empty_color
    if settings.soulgems.Color then
        crown_color = crown_filled == 0 and "|ccc0000" or "|cffdf00"
        total_color = total_filled == 0 and "|ccc0000" or "|c8080ff"
        normal_color = normal_filled == 0 and "|ccc0000" or "|cbb00ff"
        empty_color = empty == 0 and "|ccc0000" or "|c8800ff"
    else
        crown_color = "|ccccccc"
        total_color = "|ccccccc"
        normal_color = "|ccccccc"
        empty_color = "|ccccccc"
    end
    local soulgemStrings = {
        total_color .. G.total_filled,
        normal_color .. G.normal_filled,
        crown_color .. G.crown_filled,
        empty_color .. G.empty,
    }
    local fmt = soulgemsFormats[settings.soulgems.DisplayPreference]
    G.soulGemInfo = zo_strformat(fmt, unpack(soulgemStrings))
    G.soulGemsToolTipLeft =
        string.format("%s\n%sTotal filled\n%sRegular filled\n%sCrown Soul Gems\n%sEmpty",
        soulgemToolTips[settings.soulgems.DisplayPreference] or "",
        total_color, normal_color, crown_color, empty_color)
    G.soulGemsToolTipRight = "\n" .. table.concat( soulgemStrings, "\n" )

    -- thieves' tools
    G.lockpicks = GetNumLockpicksLeft()
    G.total_stolen = G.treasures + G.not_treasures
    G.totalSells, G.sellsUsed, _ = GetFenceSellTransactionInfo()
    local fence = G.totalSells - G.sellsUsed
    G.totalLaunders, G.laundersUsed, _ = GetFenceLaunderTransactionInfo()
    local launder = G.totalLaunders - G.laundersUsed

    local fenceColor =
        fence <= settings.tt.danger and "|ccc0000" or
        fence <= settings.tt.warning and "|cffdf00" or "|ccccccc"
    local launderColor =
        launder <= settings.tt.danger and "|ccc0000" or
        launder <= settings.tt.warning and "|cffdf00" or "|ccccccc"

    local stolenInvPerc = 100 * G.stolenSlots / G.bagMaxSlots
    fmt = ttFormats[settings.tt.DisplayPreference]
    G.tt = zo_strformat(fmt,
        G.lockpicks, G.total_stolen, G.treasures, G.not_treasures,
        fence, launder, fenceColor, launderColor)
end

-- called from XML

function TEB.OnUpdate()

    if not G.addonInitialized or not settings then
        return
    end

    if G.refreshTimer > 19 then
        G.refreshTimer = 0

        TEB.balance()
        TEB.skyshards()
        TEB.bags()
        TEB.mounttimer()
        TEB.experience()
        TEB.localTime()
        TEB.durability()
        TEB.blacksmithing()
        TEB.clothing()
        TEB.woodworking()
        TEB.jewelrycrafting()
        TEB.bank()
        TEB.latency()
        TEB.fps()
        TEB.weaponcharge()
        TEB.zone()
        TEB.memory()
        TEB.recall()
        TEB.pvp()
        TEB.enlightenment()
        TEB.mail()
        TEB.buffs()
        TEB.bounty()
        TEB.AddToMountDatabase(G.characterName)
        TEB.AddToGoldDatabase(G.characterName)

        for name, gadget in pairs(gadgetReference) do
            local control, value = gadget[2], gadget[7]
            local txt = settings.gadgetText[name] and value() or ""
            control:SetText(txt)
        end

    end

    G.pulseTimer = (G.pulseTimer + 1) % 60

    if settings.bar.pulseType == "none" then
        pulseAlpha = 1
    elseif settings.bar.pulseType == "fade in" then
        pulseAlpha = G.pulseTimer / 60 
    elseif settings.bar.pulseType == "fade out" then
        pulseAlpha =  1 - G.pulseTimer / 60
    elseif settings.bar.pulseType == "fade in/out" then
        pulseAlpha = math.abs(30 - G.pulseTimer) / 30
    elseif settings.bar.pulseType == "slow toggle" then
        pulseAlpha = G.pulseTimer < 30 and 2 or 3
    elseif settings.bar.pulseType == "slow blink" then
        pulseAlpha = G.pulseTimer < 30 and 1 or 0
    elseif settings.bar.pulseType == "fast blink" then
        pulseAlpha =  math.floor(G.pulseTimer / 15) % 2 == 1 and 1 or 0
    end

    for i = 1, #G.pulseList do
        if pulseAlpha < 2 then
            gadgetReference[G.pulseList[i]][1]:SetAlpha(pulseAlpha)
            gadgetReference[G.pulseList[i]][2]:SetAlpha(pulseAlpha)
        end
    end

    local currentTopBarAlpha = ZO_TopBarBackground:GetAlpha()

    if currentTopBarAlpha ~= 1 then
        table.insert(G.topBarAlphaList, currentTopBarAlpha)
    elseif G.lastTopBarAlpha ~= currentTopBarAlpha then
        if G.topBarAlphaList[1] > G.topBarAlphaList[#G.topBarAlphaList] then
            TEB.ShowBar()
        else
            TEB.HideBar()
        end
        G.topBarAlphaList = {}
    end

    G.lastTopBarAlpha = currentTopBarAlpha

    if G.centerTimer > 60 * 60 * 5 then
        TEB.UpdateControlsPosition()
    end

    if  settings.bar.bumpCompass and settings.bar.Position == "top" and 
        ZO_CompassFrame:GetTop() == G.original.CompassTop then
        TEB.SetBarPosition()
    end

    if G.hideBar then
        if G.barAlpha > 0 then
            G.barAlpha = G.barAlpha - .05
            if G.barAlpha < 0 then G.barAlpha = 0 end
            TEBTop:SetAlpha(G.barAlpha)
        end
    else
        if G.barAlpha < 1 then
            G.barAlpha = G.barAlpha + .05
            if G.barAlpha > 1 then G.barAlpha = 1 end
            TEBTop:SetAlpha(G.barAlpha)
        end
    end

    G.inCombat = IsUnitInCombat("player")

    local maxAlpha = settings.bar.combatOpacity / 100
    local incrementAlpha = maxAlpha / 20

    if G.showCombatOpacity > 0 then
        G.showCombatOpacity = G.showCombatOpacity - 1
        TEBTopCombatBG:SetAlpha(maxAlpha)
        G.combatAlpha = maxAlpha
    end

    if G.inCombat and G.combatAlpha < maxAlpha and settings.bar.combatIndicator then
        G.combatAlpha = G.combatAlpha + incrementAlpha
        if G.combatAlpha > maxAlpha then G.combatAlpha = maxAlpha end
        TEBTopCombatBG:SetAlpha(G.combatAlpha)
    end
    if not G.inCombat and G.combatAlpha > 0 and G.showCombatOpacity == 0 then
        G.combatAlpha = G.combatAlpha - incrementAlpha
        if G.combatAlpha < 0 then G.combatAlpha = 0 end
        TEBTopCombatBG:SetAlpha(G.combatAlpha)
    end

    G.refreshTimer = G.refreshTimer + 1
    G.centerTimer = G.centerTimer + 1
end

-- self refers to the bar
function TEB.StopMovingBar()
    local barY = TEBTop:GetTop()
    settings.bar.Y = barY
    settings.bar.Position =
        barY < 72 and "top" or barY > G.screenHeight - 144 and "bottom" or "middle"
    TEB.SetBarPosition()
    TEBTop:SetDrawLayer(settings.bar.Layer)
end

-- called from TEB.Initialize

function TEB.DefragGadgets()
    local gadgets_pve, gadgets_pvp = settings.gadgets_pve, settings.gadgets_pvp

    for i = #gadgets_pve, 1, -1 do
        if gadgets_pve[i] == "(None)" or gadgets_pve[i] == "" then
            table.remove(gadgets_pve, i)
        end
    end

    for i = #gadgets_pve + 1, #defaultGadgets do
        gadgets_pve[i] = "(None)"

    end

    for i = #gadgets_pvp, 1, -1 do
        if gadgets_pvp[i] == "(None)" or gadgets_pvp[i] == "" then
            table.remove(gadgets_pvp, i)
        end
    end

    for i = #gadgets_pvp+1, #defaultGadgets do
        gadgets_pvp[i] = "(None)"
    end

end

function TEB.ConvertArrayToTable(arr)
    local tbl = { }
    local pair
    for _, pair in ipairs(tbl) do
        local k, v = unpack(pair)
        tbl[k] = v
    end
    return tbl
end

function TEB.GetArrayKeysAndValues(tbl)
    local keys, values = { }, { }
    for k, v in ipairs(tbl) do
        table.insert(keys, k)
        table.insert(values, v)
    end
    return keys, values
end

function TEB.CreateSettingsWindow()
    panelData = {
        type = "panel",
        name = "The Elder Bar Reloaded",
        displayName = TEB.displayName,
        author = TEB.author,
        version = TEB.version,
        slashCommand = "/teb",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local visibilityChoiceList = { "Off", "PvE only ", "PvP only", "Both", }
    local visibilityValueList = { 0, 1, 2, 3, }
    local lvlChoiceList = { "Character Level", "Character Level/Champion Points", "Champion Points", }
    local lvlValueList = { 1, 2, 3, }
    local iconChoiceList = { "Character class icon", "CP icon", }
    local iconValueList = { 1, 2, }

    local function GadgetGetterFactory(title)
        return function() return gadgetSettings[title] end
    end

    local function GadgetSetterFactory(title)
        return function(newValue)
                    gadgetSettings[title] = newValue
                    TEB.UpdateGadgetList(title, newValue)
                end
    end

    local function VampireStageFactory(stage)
        return {
            type = "dropdown",
            name = string.format("Stage %d", stage),
            default = "normal",
            choices = {"normal", "green", "yellow", "orange", "red"},
            getFunc = function() return settings.vampirism.StageColor[stage] end,
            setFunc = function(newValue)
                settings.vampirism.StageColor[stage] = newValue
            end,
        }
    end

    local function GetterFactory(submenu, option)
        return function() return settings[submenu][option] end                
    end

    local function SetterFactory(submenu, option)
        return function(newValue) settings[submenu][option] = newValue end
    end

    local function DTCheckBoxFactory(name)
        return  {
                    type = "checkbox",
                    name = "Display Text",
                    default = true,
                    tooltip = "Display text for this gadget.",
                    getFunc = function() return settings.gadgetText[name] end,
                    setFunc = function(newValue)
                        settings.gadgetText[name] = newValue
                    end,
                }
    end

    local function GoldLimit(name, high_low, danger_level)
        return {
            type = "editbox",
            textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
            name = name,
            tooltip = string.format("Enter %d to disable",
                high_low == "high" and 999999999 or 0),
            default = high_low == "high" and 999999999 or 0,
            isMultiline = false,
            isExtraWide = false,
            maxChars = 9,
            getFunc = function() return settings.gold[high_low][danger_level] end,
            setFunc = function(newValue)
                settings.gold[high_low][danger_level] = tonumber(newValue)
            end,
        }
    end

    local function SetBangAsPercentageFactory(subsettings, maxItems, bagOrBank)
        return function(newValue)
            subsettings.UsageAsPercentage = newValue
            local newMax = newValue and 100 or maxItems
            local factor = newValue and 100/maxItems or maxItems/100
            local slidervalue 
                
            for i, w in ipairs({"Caution", "Warning", "Danger", "Critical"}) do
                local objname = string.format("TEB%sSlider%s", bagOrBank, w)
                local s = _G[objname]
                -- controlStructure[n].controls[i], where bag: n=7, bank: n=8, sliders: i=4..7
                slidervalue = s.data.getFunc()
                s.data.max = newMax
                s.slider:SetMinMax(0, newMax)
                s.maxText:SetText(newMax)
                s:UpdateValue(false, slidervalue * factor)                            
            end
        end
    end

    -- 0 = Off, 1 = PvE, 2 = PvP, 3 = Both
    local GadgetVisibilityControls = {
        { name = "Alliance Points",                 default = 0, },
        { name = "Bag Space",                       default = 3, },
        { name = "Bank Space",                      default = 1, },
        { name = "Blacksmithing Research Timer",    default = 0, },
        { name = "Bounty/Heat Timer",               default = 1, },
        { name = "Clock",                           default = 3, },
        { name = "Clothing Research Timer",         default = 0, },
        { name = "Durability",                      default = 3, },
        { name = "Enlightenment",                   default = 0, },
        { name = "Event Tickets",                   default = 1, },
        { name = "Experience",                      default = 3, },
        { name = "Fast Travel Timer",               default = 0, },
        { name = "Food Buff Timer",                 default = 3, },
        { name = "FPS",                             default = 3, },
        { name = "Gold",                            default = 3, },
        { name = "Kill Counter",                    default = 2, },
        { name = "Latency",                         default = 3, },
        { name = "Level",                           default = 3, },
        { name = "Location",                        default = 1, },
        { name = "Jewelry Crafting Research Timer", default = 0, },
        { name = "Memory Usage",                    default = 0, },
        { name = "Mount Timer",                     default = 1, },
        { name = "Mundus Stone",                    default = 0, },
        { name = "Sky Shards",                      default = 0, },
        { name = "Soul Gems",                       default = 0, },
        { name = "Tel Var Stones",                  default = 0, },
        { name = "Thief's Tools",                   default = 0, },
        { name = "Transmute Crystals",              default = 1, },
        { name = "Unread Mail",                     default = 3, },
        { name = "Vampirism",                       default = 3, },
        { name = "Weapon Charge/Poison",            default = 3, },
        { name = "Woodworking Research Timer",      default = 0, },
        { name = "Writ Vouchers",                   default = 0, },
    }

    -- complete visibility controls
    for _, gadget in ipairs(GadgetVisibilityControls) do
        gadget.type = "dropdown"
        gadget.choices = visibilityChoiceList
        gadget.choicesValues = visibilityValueList
        gadget.getFunc = GadgetGetterFactory(gadget.name)
        gadget.setFunc = GadgetSetterFactory(gadget.name)
    end

    local controlStructure
    controlStructure = {
        {
            type = "submenu",
            name = "General Settings",
            controls = {
                {
                    type = "checkbox",
                    name = "Lock the bar",
                    tooltip = "Lock the bar, preventing it from being moved.",
                    default = true,
                    getFunc = function() return settings.bar.Locked end,
                    setFunc = function(newValue)
                        TEB.LockUnlockBar(newValue)
                    end,
                },
                {
                    type = "checkbox",
                    name = "Lock the gadgets",
                    tooltip = "Lock the gadgets, preventing them from being moved.",
                    default = true,
                    getFunc = function() return settings.bar.gadgetsLocked end,
                    setFunc = function(newValue)
                        TEB.LockUnlockGadgets(newValue)
                    end,
                },
                {
                    type = "checkbox",
                    name = "Show lock messages in chat",
                    tooltip = "Show a message in chat each time the bar or gadgets are locked or unlocked.",
                    default = true,
                    getFunc = GetterFactory("bar", "lockMessage"), setFunc = SetterFactory("bar", "lockMessage"),
                },
                {
                    type = "dropdown",
                    name = "Icon color",
                    tooltip = "Choose how you'd like the icons displayed.",
                    default = "color",
                    choices = {"monochrome", "color"},
                    choicesValues = {"white", "color"}, 
                    getFunc = function() return settings.bar.iconsMode end,
                    setFunc = function(newValue)
                        settings.bar.iconsMode  = newValue
                        TEB.RebuildBar()
                    end,
                },
                {
                    type = "colorpicker",
                    name = "Custom color",
                    tooltip = "Choose what color you'd like the icons/text to be.",
                    default = defaults.bar.customColor,				
                    getFunc = function() return settings.bar.customColor:UnpackRGBA() end,
                    setFunc = function(r, g, b, a)
                        settings.bar.customColor = ZO_ColorDef:New(r, g, b, a)
                        settings.bar.colors.normal =
                            "|c" .. settings.bar.customColor:ToHex(r, g, b)
                        TEB.RebuildBar()
                    end,
                   
                },
                {
                    type = "slider",
                    name = "Draw Layer (0=background, 4=foreground)",
                    tooltip = "Choose which layer on which you'd like the bar drawn. Background is underneath everything, foreground is on top of everything.",
                    min = 0,
                    max = 4,
                    step = 1,
                    default = 0,
                    getFunc = function() return settings.bar.Layer end,
                    setFunc = function(newValue)
                        settings.bar.Layer = newValue
                        TEB.SetBarLayer()
                    end,
                },
                {
                    type = "checkbox",
                    name = "Bump compass down when bar at top",
                    tooltip = "Bump the compass down if the bar position is set to top. Disable this if other addons will be moving the compass.",
                    default = true,
                    warning = "Disabling this will cause UI reload.",
                    getFunc = function() return settings.bar.bumpCompass end,
                    setFunc = function(newValue)
                        settings.bar.bumpCompass = newValue
                        ReloadUI("ingame")
                        if not settings.bar.bumpCompass then
                            ReloadUI("ingame")
                        else
                            TEB.SetBarPosition()
                            TEB.UpdateControlsPosition()
                        end
                    end,
                },
                {
                    type = "checkbox",
                    name = "Bump action/resource bars up when bar at bottom",
                    tooltip = "Bump the action bar, magicka, health, and stamina bars up if the bar position is set to bottom. Disable this if other addons will be moving the action bar or health/stamina/magicka bars.",
                    default = true,
                    warning = "Disabling this will cause UI reload.",
                    getFunc = function() return settings.bar.bumpActionBar end,
                    setFunc = function(newValue)
                        settings.bar.bumpActionBar = newValue
                        if not settings.bar.bumpActionBar then
                            ReloadUI("ingame")
                        else
                            TEB.SetBarPosition()
                            TEB.UpdateControlsPosition()
                        end
                    end,
                },
                {
                    type = "dropdown",
                    name = "Gadgets position",
                    tooltip = "Set The Elder Bar's horizontal position on the screen.",
                    default = "center",
                    choices = {"left", "center", "right"},
                    getFunc = function() return settings.bar.controlsPosition end,
                    setFunc = function(newValue)
                        settings.bar.controlsPosition = newValue
                        TEB.UpdateControlsPosition()
                    end,
                },
                {
                    type = "dropdown",
                    name = "Font",
                    tooltip = "Set the font used for gadget text.",
                    default = "Univers57",
                    choices = {"Univers57", "Univers67", "FTN47", "FTN57", "FTN87", "ProseAntiquePSMT", "Handwritten_Bold", "TrajanPro-Regular"},
                    getFunc = function() return settings.bar.font end,
                    setFunc = function(newValue)
                      settings.bar.font = newValue
                      TEB.ResizeBar()
                    end,
                },
                {
                    type = "slider",
                    name = "Scale",
                    tooltip = "Set The Elder Bar's scale.",
                    min = 50,
                    max = 150,
                    step = 1,
                    default = 100,
                    getFunc = function() return settings.bar.scale end,
                    setFunc = function(newValue)
                      settings.bar.scale = newValue
                      TEB.ResizeBar()
                    end,
                },
                {
                    type = "checkbox",
                    name = "Use thousands separator",
                    tooltip = "Makes numbers a bit more readable by adding a thousands separator (comma, space, period, etc).",
                    default = true,
                    getFunc = GetterFactory("bar", "thousandsSeparator"), setFunc = SetterFactory("bar", "thousandsSeparator"),
                },
                {
                    type = "checkbox",
                    name = "Pulse gadgets when critical",
                    tooltip = "Pulse gadgets when the critical threshold is reached.",
                    default = false,
                    getFunc = GetterFactory("bar", "pulseWhenCritical"), setFunc = SetterFactory("bar", "pulseWhenCritical"),
                },
                {
                    type = "dropdown",
                    name = "Pulse type",
                    tooltip = "Choose the type of pulse used when a gadget needs your attention.",
                    default = "fade in",
                    choices = {"none", "fade in", "fade out", "fade in/out", "slow blink", "fast blink"},
                    getFunc = GetterFactory("bar", "pulseType"), setFunc = SetterFactory("bar", "pulseType"),
                },
                {
                    type = "dropdown",
                    name = "Background width",
                    tooltip = "Choose how you'd like the bar background displays, either full screen width or dynamic.",
                    default = "dynamic",
                    choices = {"dynamic", "screen width"},
                    getFunc = function() return settings.bar.Width end,
                    setFunc = function(newValue)
                        settings.bar.Width = newValue
                        TEB.SetBarWidth(newValue)
                    end,
                },
                {
                    type = "slider",
                    name = "Bar transparency",
                    tooltip = "Set The Elder Bar's transparency. Lower number means more transparent.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 100,
                    getFunc = function() return settings.bar.opacity end,
                    setFunc = function(newValue)
                        settings.bar.opacity = newValue
                        TEB.SetOpacity()
                    end,
                },
                {
                    type = "slider",
                    name = "Bar background transparency",
                    tooltip = "Set The Elder Bar's background transparency. Lower number means more transparent.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 0,
                    getFunc = function() return settings.bar.backgroundOpacity end,
                    setFunc = function(newValue)
                        settings.bar.backgroundOpacity = newValue
                        TEB.SetOpacity()
                    end,
                },
                {
                    type = "checkbox",
                    name = "Turn the bar red when in combat",
                    tooltip = "Turn the bar red with in combat.",
                    default = true,
                    getFunc = GetterFactory("bar", "combatIndicator"), setFunc = SetterFactory("bar", "combatIndicator"),
                },
                {
                    type = "slider",
                    name = "Combat indicator transparency",
                    tooltip = "Set the combat indicator's transparency. Lower number means more transparent.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 100,
                    getFunc = function() return settings.bar.combatOpacity end,
                    setFunc = function(newValue)
                        settings.bar.combatOpacity = newValue
                        G.showCombatOpacity = 300
                    end,
                },
            },
        },
        {
            type = "submenu",
            name = "AUTO-HIDE Settings",
            controls = {
                {
                    type = "description",
                    text = [[Choose when The Elder Bar will automatically hide and show itself. Hide the bar when:]],
                },
                {
                    type = "checkbox",
                    name = "Opening the game menu",
                    default = true,
                    tooltip = "Hide the bar when you open the game menu (crown store, map, character, inventory, skills, etc.",
                    getFunc = GetterFactory("autohide", "GameMenu"), setFunc = SetterFactory("autohide", "GameMenu"),
                },
                {
                    type = "checkbox",
                    name = "Conversing with NPCs",
                    default = true,
                    tooltip = "Hide the bar when you talk to any NPC.",
                    getFunc = GetterFactory("autohide", "Chatter"), setFunc = SetterFactory("autohide", "Chatter"),
                },
                {
                    type = "checkbox",
                    name = "Using a crafting station",
                    default = true,
                    tooltip = "Hide the bar when you use a crafting station.",
                    getFunc = GetterFactory("autohide", "Crafting"), setFunc = SetterFactory("autohide", "Crafting"),
                },
                {
                    type = "checkbox",
                    name = "Opening your personal bank",
                    default = true,
                    tooltip = "Hide the bar when you open your bank. (only applies if you don't hide the bar when conversing with NPCs)",
                    getFunc = GetterFactory("autohide", "Bank"), setFunc = SetterFactory("autohide", "Bank"),
                },
                {
                    type = "checkbox",
                    name = "Opening your guild's bank",
                    default = true,
                    tooltip = "Hide the bar when you open your guild's bank. (only applies if you don't hide the bar when conversing with NPCs)",
                    getFunc = GetterFactory("autohide", "GuildBank"), setFunc = SetterFactory("autohide", "GuildBank"),
                },
            },
        },
        {
            type = "submenu",
            name = "Gadget Visibility",
            controls = GadgetVisibilityControls,
        },
        {
            type = "header",
            name = "|cff8040Gadget Options|r",

        },
        {
            type = "submenu",
            name = "Alliance Points",
            controls = {
                DTCheckBoxFactory("Alliance Points"),
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display alliance points.",
                    default = "Total Points",
                    choices = {"Total Points", "Session Points", "Points Per Hour", "Total Points/Points Per Hour", "Session Points/Points Per Hour", "Total Points/Session Points", "Total Points/Session Points (Points Per Hour)", "Total Points/Session Points/Points Per Hour"},
                    getFunc = GetterFactory("ap", "DisplayPreference"), setFunc = SetterFactory("ap", "DisplayPreference"),
                },
            },
        },
        {
            type = "submenu",
            name = "Bag Space",
            controls = {
                DTCheckBoxFactory("Bag Space"),
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display bag space.",
                    default = "slots used/total slots",
                    choices = {"slots used/total slots", "used%", "slots free/total slots", "slots free", "free%"},
                    getFunc = GetterFactory("bag", "DisplayPreference"), setFunc = SetterFactory("bag", "DisplayPreference"),
                },
                {
                    type = "checkbox",
                    name = "Thresholds as percentage of the total space",
                    tooltip = "Thresholds are expressed in percents of total space rather than absolute values",
                    default = true,
                    getFunc = GetterFactory("bag", "UsageAsPercentage"), 
                    setFunc = SetBangAsPercentageFactory(settings.bag, 210, "Bag"), 
                },
                {
                    type = "slider",
                    name = "Caution threshold",
                    tooltip = "Choose at what percentage bag space will be colored yellow.",
                    min = 0,
                    max = settings.bag.UsageAsPercentage and 100 or 210,
                    step = 1,
                    default = settings.bag.UsageAsPercentage and 50 or 105,
                    decimals = 0,
                    reference = "TEBBagSliderCaution",
                    getFunc = GetterFactory("bag", "caution"), setFunc = SetterFactory("bag", "caution"),
                },
                {
                    type = "slider",
                    name = "Warning threshold",
                    tooltip = "Choose at what percentage bag space will be colored orange.",
                    min = 0,
                    max = settings.bag.UsageAsPercentage and 100 or 210,
                    step = 1,
                    default = settings.bag.UsageAsPercentage and 80 or 168,
                    decimals = 0,
                    reference = "TEBBagSliderWarning",
                    getFunc = GetterFactory("bag", "warning"), setFunc = SetterFactory("bag", "warning"),
                },
                {
                    type = "slider",
                    name = "Danger threshold",
                    tooltip = "Choose at what percentage bag space will be colored red.",
                    min = 0,
                    max = settings.bag.UsageAsPercentage and 100 or 210,
                    step = 1,
                    default = settings.bag.UsageAsPercentage and 90 or 189,
                    decimals = 0,
                    reference = "TEBBagSliderDanger",
                    getFunc = GetterFactory("bag", "danger"), setFunc = SetterFactory("bag", "danger"),
                },
                {
                    type = "slider",
                    name = "Critical threshold",
                    tooltip = "Bag Space used over this percentage will cause the gadget to pulse.",
                    min = 0,
                    max = settings.bag.UsageAsPercentage and 100 or 210,
                    step = 1,
                    default = settings.bag.UsageAsPercentage and 99 or 209,
                    decimals = 0,
                    reference = "TEBBagSliderCritical",
                    getFunc = GetterFactory("bag", "critical"), setFunc = SetterFactory("bag", "critical"),
                },
            },
        },
        {
            type = "submenu",
            name = "Bank Space",
            controls = {
                DTCheckBoxFactory("Bank Space"),
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display bank space.",
                    default = "slots used/total slots",
                    choices = {"slots used/total slots", "used%", "slots free/total slots", "slots free", "free%"},
                    getFunc = GetterFactory("bank", "DisplayPreference"), setFunc = SetterFactory("bank", "DisplayPreference"),
                },
                {
                    type = "checkbox",
                    name = "Thresholds as percentage of the total space",
                    tooltip = "Thresholds are expressed in percents of total space rather than absolute values",
                    default = false,
                    getFunc = GetterFactory("bank", "UsageAsPercentage"), 
                    setFunc = SetBangAsPercentageFactory(settings.bank, 480, "Bank"),
                },
                {
                    type = "slider",
                    name = "Caution threshold",
                    tooltip = "Choose at what percentage bank space will be colored yellow.",
                    min = 0,
                    max = settings.bank.UsageAsPercentage and 100 or 480,
                    step = 1,
                    default = settings.bank.UsageAsPercentage and 50 or 240,
                    decimals = 0,
                    reference = "TEBBankSliderCaution",
                    getFunc = GetterFactory("bank", "caution"), setFunc = SetterFactory("bank", "caution"),
                },
                {
                    type = "slider",
                    name = "Warning threshold",
                    tooltip = "Choose at what percentage bank space will be colored orange.",
                    min = 0,
                    max = settings.bank.UsageAsPercentage and 100 or 480,
                    step = 1,
                    default = 360,
                    decimals = 0,
                    reference = "TEBBankSliderWarning",
                    getFunc = GetterFactory("bank", "warning"), setFunc = SetterFactory("bank", "warning"),
                    reference = "TEBBankSliderWarning",
                },
                {
                    type = "slider",
                    name = "Danger threshold",
                    tooltip = "Choose at what percentage bank space will be colored red.",
                    min = 0,
                    max = settings.bank.UsageAsPercentage and 100 or 480,
                    step = 1,
                    default = settings.bank.UsageAsPercentage and 90 or 432,
                    decimals = 0,
                    reference = "TEBBankSliderDanger",
                    getFunc = GetterFactory("bank", "danger"), setFunc = SetterFactory("bank", "danger"),
                    reference = "TEBBankSliderDanger",
                },
                {
                    type = "slider",
                    name = "Critical threshold",
                    tooltip = "Bank Space used over this percentage will cause the gadget to pulse.",
                    min = 0,
                    max = settings.bank.UsageAsPercentage and 100 or 480,
                    step = 1,
                    default = settings.bank.UsageAsPercentage and 99 or 479,
                    decimals = 0,
                    reference = "TEBBankSliderCritical",
                    getFunc = GetterFactory("bank", "critical"), setFunc = SetterFactory("bank", "critical"),
                    reference = "TEBBankSliderCritical",

                },
            },
        },
        {
            type = "submenu",
            name = "Bounty/Heat Timer",
            controls = {
                DTCheckBoxFactory("Bounty/Heat Timer"),
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display the bounty timer.",
                    default = "simple",
                    choices = {"simple", "short", "exact"},
                    getFunc = GetterFactory("bounty", "DisplayPreference"), setFunc = SetterFactory("bounty", "DisplayPreference"),
                },
                {
                    type = "checkbox",
                    name = "Dynamically show timer",
                    default = true,
                    tooltip = "Show the icon and timer only when you have a bounty or heat.",
                    getFunc = function() return settings.bounty.Dynamic end,
                    setFunc = function(newValue)
                        settings.bounty.Dynamic = newValue
                        TEB.RebuildBar()
                    end,
                },
                {
                    type = "dropdown",
                    name = "Upstanding",
                    default = "normal",
                    choices = {"normal", "green"},
                    getFunc = GetterFactory("bounty", "good"), setFunc = SetterFactory("bounty", "good"),
                },
                {
                    type = "dropdown",
                    name = "Disreputable",
                    default = "yellow",
                    choices = {"normal", "yellow", "orange", "red"},
                    getFunc = GetterFactory("bounty", "warning"), setFunc = SetterFactory("bounty", "warning"),
                },
                {
                    type = "dropdown",
                    name = "Notorious",
                    default = "orange",
                    choices = {"normal", "yellow", "orange", "red"},
                    getFunc = GetterFactory("bounty", "danger"), setFunc = SetterFactory("bounty", "danger"),
                },
                {
                    type = "dropdown",
                    name = "Fugitive from Justice",
                    default = "red",
                    choices = {"normal", "yellow", "orange", "red"},
                    getFunc = GetterFactory("bounty", "critical"), setFunc = SetterFactory("bounty", "critical"),
                },
            },
        },
        {
            type = "submenu",
            name = "Clock",
            controls = {
                DTCheckBoxFactory("Clock"),
                {
                    type = "dropdown",
                    name = "Clock(s) to display",
                    tooltip = "Choose what to display as clock.",
                    default = "local time",
                    choices = {"local time", "UTC time", "ingame time", "local time/ingame time", "local date and time"},
                    getFunc = GetterFactory("clock", "DisplayPreference"), setFunc = SetterFactory("clock", "DisplayPreference"),
                },
                {
                    type = "dropdown",
                    name = "Time format",
                    tooltip = "Choose how to display the time.",
                    default = "24h",
                    choices = { "24h", "24h with seconds", "12h", "12h no leading zero", "12h with seconds" },
                    getFunc = GetterFactory("clock", "Type"), setFunc = SetterFactory("clock", "Type"),
                },
                {
                    type = "dropdown",
                    name = "Date format",
                    tooltip = "Choose how to display the date.",
                    default = "24h",
                    choices = {"YYYY-MM-DD", "DD.MM.YY", "DD Mon", "DD Month", "Imperial", "Argonian" },
                    choicesValues = { "%Y-%m-%d", "%d.%m.%y", "%d %b", "%d %B", "%d %BI", "%d %BA", },
                    getFunc = GetterFactory("clock", "DateFormat"), setFunc = SetterFactory("clock", "DateFormat"),
                },
            },
        },
        {
            type = "submenu",
            name = "Durability",
            controls = {
                DTCheckBoxFactory("Durability"),
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display durability.",
                    default = "durability %",
                    choices = {"durability %", "durability %/repair cost", "repair cost", "durability % (repair kits)", "durability %/repair cost (repair kits)", "repair cost (repair kits)", "most damaged", "most damaged/durability %", "most damaged/durability %/repair cost", "most damaged/repair cost"},
                    getFunc = GetterFactory("durability", "DisplayPreference"), setFunc = SetterFactory("durability", "DisplayPreference"),
                },
                {
                    type = "slider",
                    name = "Warning threshold (yellow)",
                    tooltip = "Choose at what percentage durability will be colored yellow.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 50,
                    getFunc = GetterFactory("durability", "warning"), setFunc = SetterFactory("durability", "warning"),
                },
                {
                    type = "slider",
                    name = "Danger threshold (red)",
                    tooltip = "Choose at what percentage durability will be colored red, indicating armor is about to break.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 25,
                    getFunc = GetterFactory("durability", "danger"), setFunc = SetterFactory("durability", "danger"),
                },
                {
                    type = "slider",
                    name = "Critical threshold (pulse red)",
                    tooltip = "Durability below this number will cause the gadget to pulse.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 10,
                    getFunc = GetterFactory("durability", "critical"), setFunc = SetterFactory("durability", "critical"),
                },
            },
        },
        {
            type = "submenu",
            name = "Enlightenment",
            controls = {
                DTCheckBoxFactory("Enlightenment"),
                {
                    type = "checkbox",
                    name = "Hide when enlighenment empty",
                    default = true,
                    tooltip = "Automatically hide the Enlighenment gadget, when there is no enlightenment to spend.",
                    getFunc = function() return settings.enlightenment.Dynamic end,
                    setFunc = function(newValue)
                        settings.enlightenment.Dynamic = newValue
                        TEB.RebuildBar()
                    end,
                },
                {
                    type = "slider",
                    name = "Warning threshold (yellow)",
                    tooltip = "Enlightenment below this number will be colored yellow.",
                    min = 0,
                    max = 1200000,
                    step = 10000,
                    default = 200000,
                    getFunc = GetterFactory("enlightenment", "warning"), setFunc = SetterFactory("enlightenment", "warning"),
                },
                {
                    type = "slider",
                    name = "Danger threshold (red)",
                    tooltip = "Enlightenment below this number will be colored red.",
                    min = 0,
                    max = 1200000,
                    step = 10000,
                    default = 100000,
                    getFunc = GetterFactory("enlightenment", "danger"), setFunc = SetterFactory("enlightenment", "danger"),
                },
                {
                    type = "slider",
                    name = "Critical threshold (pulse red)",
                    tooltip = "Enlightenment below this number will cause the gadget to pulse.",
                    min = 0,
                    max = 1200000,
                    step = 10000,
                    default = 500000,
                    getFunc = GetterFactory("enlightenment", "critical"), setFunc = SetterFactory("enlightenment", "critical"),
                },
            },
        },
        {
            type = "submenu",
            name = "Experience",
            controls = {
                DTCheckBoxFactory("Experience"),
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display experience.",
                    default = "% towards next level/CP",
                    choices = {"% towards next level/CP", "% needed for next level/CP", "current XP", "needed XP", "current XP/total needed"},
                    getFunc = GetterFactory("experience", "DisplayPreference"), setFunc = SetterFactory("experience", "DisplayPreference"),
                },
            },
        },
        {
            type = "submenu",
            name = "Event Tickets",
            controls = {
                DTCheckBoxFactory("Event Tickets"),
                {
                    type = "checkbox",
                    name = "Hide when have no tickets",
                    default = true,
                    tooltip = "Automatically hide the Event Tickets gadget when the character has no event tickets.",
                    getFunc = function() return settings.et.Dynamic end,
                    setFunc = function(newValue)
                        settings.et.Dynamic = newValue
                        TEB.RebuildBar()
                    end,
                },
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display event tickets.",
                    default = "tickets",
                    choices = {"tickets", "tickets/max"},
                    getFunc = GetterFactory("et", "DisplayPreference"), setFunc = SetterFactory("et", "DisplayPreference"),
                },
                {
                    type = "slider",
                    name = "Warning threshold",
                    tooltip = "The warning color will be used when the number of tickets is equal to or higher than what is set here.",
                    min = 0,
                    max = 12,
                    step = 1,
                    default = 9,
                    getFunc = GetterFactory("et", "warning"), setFunc = SetterFactory("et", "warning"),
                },
                {
                    type = "slider",
                    name = "Danger threshold",
                    tooltip = "The danger color will be used when the number of tickets is equal to or higher than what is set here.",
                    min = 0,
                    max = 12,
                    step = 1,
                    default = 12,
                    getFunc = GetterFactory("et", "danger"), setFunc = SetterFactory("et", "danger"),
                },
            },
        },
        {
            type = "submenu",
            name = "Fast Travel Timer",
            controls = {
                DTCheckBoxFactory("Fast Travel Timer"),
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display fast travel timer.",
                    default = "time left/cost",
                    choices = {"time left", "cost", "time left/cost"},
                    getFunc = GetterFactory("ft", "DisplayPreference"), setFunc = SetterFactory("ft", "DisplayPreference"),
                },
                {
                    type = "dropdown",
                    name = "Timer display format",
                    tooltip = "Choose how to display fast travel time left until cheapest.",
                    default = "simple",
                    choices = {"simple", "short", "exact"},
                    getFunc = GetterFactory("ft", "TimerDisplayPreference"), setFunc = SetterFactory("ft", "TimerDisplayPreference"),
                },
                {
                    type = "checkbox",
                    name = "Only show timer after traveling",
                    default = true,
                    tooltip = "Show the icon and timer only after you've fast traveled. When the timer reaches zero, the timer disappears again.",
                    getFunc = function() return settings.ft.Dynamic end,
                    setFunc = function(newValue)
                        settings.ft.Dynamic = newValue
                        TEB.RebuildBar()
                    end,
                },
            },
        },
        {
            type = "submenu",
            name = "Food Buff Timer",
            controls = {
                DTCheckBoxFactory("Food Buff Timer"),
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display the food buff timer.",
                    default = "simple",
                    choices = {"simple", "short", "exact"},
                    getFunc = GetterFactory("food", "DisplayPreference"), setFunc = SetterFactory("food", "DisplayPreference"),
                },
                {
                    type = "slider",
                    name = "Warning threshold (minutes remaining)",
                    tooltip = "The warning color will be used when the timer falls below what is set here.",
                    min = 0,
                    max = 120,
                    step = 1,
                    default = 15,
                    -- set/display in minutes, but store in seconds
                    getFunc = function() return settings.food.warning / 60 end,
                    setFunc = function(newValue)
                        settings.food.warning = newValue * 60
                    end,
                },
                {
                    type = "slider",
                    name = "Danger threshold (minutes remaining)",
                    tooltip = "The danger color will be used when the timer falls below what is set here.",
                    min = 0,
                    max = 120,
                    step = 1,
                    default = 7,
                    getFunc = function() return settings.food.danger / 60 end,
                    setFunc = function(newValue)
                        settings.food.danger = newValue * 60
                    end,
                },
                {
                    type = "slider",
                    name = "Critical threshold (minutes remaining)",
                    tooltip = "The gadget will pulse when the timer falls below what is set here.",
                    min = 0,
                    max = 120,
                    step = 1,
                    default = 2,
                    getFunc = function() return settings.food.critical / 60 end,
                    setFunc = function(newValue)
                        settings.food.critical = newValue * 60
                    end,
                },
                {
                    type = "checkbox",
                    name = "Keep Pulsing After Expiring",
                    default = true,
                    tooltip = "Allows the gadget to continue pulsing even after the timer has expired.",
                    getFunc = GetterFactory("food", "PulseAfter"), setFunc = SetterFactory("food", "PulseAfter"),
                },
                {
                    type = "checkbox",
                    name = "Only show timer when buff active",
                    default = true,
                    tooltip = "Show the icon and timer only when a food buff is active.",
                    getFunc = function() return settings.food.Dynamic end,
                    setFunc = function(newValue)
                        settings.food.Dynamic = newValue
                        TEB.RebuildBar()
                    end,
                  },
            },
        },
        {
            type = "submenu",
            name = "FPS",
            controls = {
                DTCheckBoxFactory("FPS"),
                {
                    type = "slider",
                    name = "Caution threshold (yellow)",
                    tooltip = "FPS below this number will be colored yellow.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 30,
                    getFunc = GetterFactory("fps", "caution"), setFunc = SetterFactory("fps", "caution"),
                },
                {
                    type = "slider",
                    name = "Warning threshold (orange)",
                    tooltip = "FPS below this number will be colored orange.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 30,
                    getFunc = GetterFactory("fps", "warning"), setFunc = SetterFactory("fps", "warning"),
                },
                {
                    type = "slider",
                    name = "Danger threshold (red)",
                    tooltip = "FPS below this number will be colored red.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 15,
                    getFunc = GetterFactory("fps", "danger"), setFunc = SetterFactory("fps", "danger"),
                },
                {
                    type = "checkbox",
                    name = "Use fixed width",
                    default = true,
                    tooltip = "Use fixed width for this gadget.",
                    getFunc = function() return settings.fps.Fixed end,
                    setFunc = function(newValue)
                        settings.fps.Fixed = newValue
                        TEB.SetWidth(settings.fps, TEBTopFPS)
                    end,
                },
                {
                    type = "slider",
                    name = "Fixed Width Size",
                    tooltip = "The size in pixels for the gadget.",
                    min = 20,
                    max = 60,
                    step = 1,
                    default = 20,
                    getFunc = function() return settings.fps.FixedLength end,
                    setFunc = function(newValue)
                        settings.fps.FixedLength = newValue
                        TEB.SetWidth(settings.fps, TEBTopFPS)
                    end,
                },
            },
        },
        {
            type = "submenu",
            name = "Gold",
            controls = {
                DTCheckBoxFactory("Gold"),
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display gold.",
                    default = "gold on character",
                    choices = {
                        "gold on character",
                        "gold on character/gold in bank",
                        "gold on character (gold in bank)",
                        "character+bank gold",
                        "tracked gold",
                        "tracked+bank gold",
                    },
                    getFunc = GetterFactory("gold", "DisplayPreference"), setFunc = SetterFactory("gold", "DisplayPreference"),
                },
                GoldLimit("Warning below this level", "low", "warning"),
                GoldLimit("Danger below this level", "low", "danger"),
                GoldLimit("Warning above this level", "high", "warning"),
                GoldLimit("Danger above this level", "high", "danger"),
                {
                    type = "checkbox",
                    name = "Track this character",
                    tooltip = "Track this character's gold.",
                    default = true,
                    disabled = function() return TEB.DisableGoldTracker() end,
                    getFunc = function() return TEB.GetCharacterGoldTracked() end,
                    setFunc = function(newValue)
                        TEB.SetCharacterGoldTracked(newValue)
                    end,
                },
            },
        },
        {
            type = "submenu",
            name = "Kill Counter",
            controls = {
                DTCheckBoxFactory("Kill Counter"),
                {
                    type = "dropdown",
                    name = "Kill Counter display format",
                    tooltip = "Choose how to display the kill counter.",
                    default = "Killing Blows/Deaths (Kill Ratio)",
                    choices = {"Assists/Killing Blows/Deaths (Kill Ratio)", "Assists/Killing Blows/Deaths", "Killing Blows/Deaths (Kill Ratio)", "Killing Blows/Deaths", "Kill Ratio"},
                    getFunc = GetterFactory("kc", "DisplayPreference"), setFunc = SetterFactory("kc", "DisplayPreference"),
                },
            },
        },
        {
            type = "submenu",
            name = "Latency",
            controls = {
                DTCheckBoxFactory("Latency"),
                {
                    type = "slider",
                    name = "Warning threshold (yellow)",
                    tooltip = "Latency above this number will be colored yellow.",
                    min = 0,
                    max = 5000,
                    step = 10,
                    default = 100,
                    getFunc = GetterFactory("latency", "warning"), setFunc = SetterFactory("latency", "warning"),
                },
                {
                    type = "slider",
                    name = "Danger threshold (red)",
                    tooltip = "Latency above this number will be colored red.",
                    min = 0,
                    max = 5000,
                    step = 10,
                    default = 500,
                    getFunc = GetterFactory("latency", "danger"), setFunc = SetterFactory("latency", "danger"),
                },
                {
                    type = "checkbox",
                    name = "Use Fixed Width",
                    default = true,
                    tooltip = "Use fixed width for this gadget.",
                    getFunc = function() return settings.latency.Fixed end,
                    setFunc = function(newValue)
                        settings.latency.Fixed = newValue
                        TEB.SetWidth(settings.latency, TEBTopLatency)
                    end,
                },
                {
                    type = "slider",
                    name = "Fixed width size",
                    tooltip = "The size in pixels for the gadget.",
                    min = 30,
                    max = 60,
                    step = 1,
                    default = 30,
                    getFunc = function() return settings.latency.FixedLength end,
                    setFunc = function(newValue)
                        settings.latency.FixedLength = newValue
                        TEB.SetWidth(settings.latency, TEBTopLatency)
                    end,
                },
            },
        },
        {
            type = "submenu",
            name = "Level",
            controls = {
                DTCheckBoxFactory("Level"),

                {
                    type = "description",
                    text = "Display format when |cff0000below|r level 50",
                },
                {
                    type = "dropdown",
                    name = "Icon to use (<L50)",
                    tooltip = "Choose icon to precede level when below level 50.",
                    default = 1,
                    choices = iconChoiceList,
                    choicesValues = iconValueList,
                    getFunc = function() return settings.level.notmax.icon end,
                    setFunc = function(newValue)
                        settings.level.notmax.icon = newValue
                        TEB.RebuildBar()
                    end,
                },
                {
                    type = "dropdown",
                    name = "Display level (<L50)",
                    tooltip = "Choose how to display the level when below level 50.",
                    default = 1,
                    choices = lvlChoiceList,
                    choicesValues = lvlValueList,
                    getFunc = function() return settings.level.notmax.DisplayPreference end,
                    setFunc = function(newValue)
                        settings.level.notmax.DisplayPreference = newValue
                        TEB.RebuildBar()
                    end,
                },
                {
                    type = "checkbox",
                    name = "Display Champion Points (<L50)",
                    default = true,
                    tooltip = "Display Champion Points after level when below level 50.",
                    getFunc = function() return settings.level.notmax.cp end,
                    setFunc = function(newValue)
                        settings.level.notmax.cp = newValue
                        TEB.RebuildBar()
                    end,
                },
                {
                    type = "checkbox",
                    name = "Dynamically show champion points (<L50)",
                    default = true,
                    tooltip = "Show the icon and unspent points only when there is at least one point to spend.",
                    getFunc = function() return settings.level.notmax.Dynamic end,
                    setFunc = function(newValue)
                        settings.level.notmax.Dynamic = newValue
                        TEB.RebuildBar()
                    end,
                },

                {
                    type = "description",
                    text = "Display format when |cff0000at|r level 50",
                },
                {
                    type = "dropdown",
                    name = "Icon to use",
                    tooltip = "Choose icon to precede level when at level 50.",
                    default = 1,
                    choices = iconChoiceList,
                    choicesValues = iconValueList,
                    getFunc = function() return settings.level.max.icon end,
                    setFunc = function(newValue)
                        settings.level.max.icon = newValue
                        TEB.RebuildBar()
                    end,
                },
                {
                    type = "dropdown",
                    name = "Display level",
                    tooltip = "Choose how to display the level when at level 50.",
                    default = 1,
                    choices = lvlChoiceList,
                    choicesValues = lvlValueList,
                    getFunc = function() return settings.level.max.DisplayPreference end,
                    setFunc = function(newValue)
                        settings.level.max.DisplayPreference = newValue
                        TEB.RebuildBar()
                    end,
                },
                {
                    type = "checkbox",
                    name = "Display Champion Points",
                    default = true,
                    tooltip = "Display Champion Points after level when at level 50.",
                    getFunc = function() return settings.level.max.cp end,
                    setFunc = function(newValue)
                        settings.level.max.cp = newValue
                        TEB.RebuildBar()
                    end,
                },
                {
                    type = "checkbox",
                    name = "Dynamically show champion points",
                    default = true,
                    tooltip = "Show the icon and unspent points only when there is at least one point to spend.",
                    getFunc = function() return settings.level.max.Dynamic end,
                    setFunc = function(newValue)
                        settings.level.max.Dynamic = newValue
                        TEB.RebuildBar()
                    end,
                },

            },
        },
        {
            type = "submenu",
            name = "Location",
            controls = {
                DTCheckBoxFactory("Location"),
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display your location.",
                    default = "(x, y) Zone Name",
                    choices = {"(x, y) Zone Name", "Zone Name (x, y)", "Zone Name", "x, y"},
                    getFunc = GetterFactory("location", "DisplayPreference"), setFunc = SetterFactory("location", "DisplayPreference"),
                },
            },
        },
        {
            type = "submenu",
            name = "Memory Usage",
            controls = {
                DTCheckBoxFactory("Memory Usage"),
                {
                    type = "slider",
                    name = "Warning threshold (yellow)",
                    tooltip = "Memory Usage above this number will be colored yellow.",
                    min = 0,
                    max = 1024,
                    step = 8,
                    default = 512,
                    getFunc = GetterFactory("memory", "warning"), setFunc = SetterFactory("memory", "warning"),
                },
                {
                    type = "slider",
                    name = "Danger threshold (red)",
                    tooltip = "Memory usage above this number will be colored red.",
                    min = 0,
                    max = 1024,
                    step = 8,
                    default = 768,
                    getFunc = GetterFactory("memory", "danger"), setFunc = SetterFactory("memory", "danger"),
                },
            },
        },
        {
            type = "submenu",
            name = "Mount Timer",
            controls = {
                DTCheckBoxFactory("Mount Timer"),
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display the mount timer.",
                    default = "simple",
                    choices = {"simple", "short", "exact"},
                    getFunc = GetterFactory("mount", "DisplayPreference"), setFunc = SetterFactory("mount", "DisplayPreference"),
                },
                {
                    type = "checkbox",
                    name = "Automatically hide timer when mount fully trained",
                    default = true,
                    tooltip = "Hide the icon and timer only when the mount is fully trained.",
                    getFunc = function() return settings.mount.Dynamic end,
                    setFunc = function(newValue)
                        settings.mount.Dynamic = newValue
                        TEB.RebuildBar()
                    end,
                },
                {
                    type = "checkbox",
                    name = "Indicate when the timer has reached zero",
                    default = true,
                    tooltip = "When the timer has reached zero, turn the gadget green.",
                    getFunc = GetterFactory("mount", "good"), setFunc = SetterFactory("mount", "good"),
                },
                {
                    type = "checkbox",
                    name = "Pulse gadget",
                    default = true,
                    tooltip = "Pulse the gadget when it is time to train your mount.",
                    getFunc = GetterFactory("mount", "critical"), setFunc = SetterFactory("mount", "critical"),
                },
                {
                    type = "checkbox",
                    name = "Track this character",
                    tooltip = "Track this character's mount training time left.",
                    default = true,
                    disabled = function() return TEB.DisableMountTracker() end,
                    reference = "mountTrackCheckbox",
                    getFunc = function() return TEB.GetCharacterMountTracked() end,
                    setFunc = function(newValue)
                        TEB.SetCharacterMountTracked(newValue)
                    end,
                },
            },
        },
        {
            type = "submenu",
            name = "Mundus Stone",
            controls = {
                DTCheckBoxFactory("Mundus Stone"),
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display your Mundus",
                    default = "Full",
                    choices = {"Abbreviated", "Full"},
                    getFunc = GetterFactory("mundus", "DisplayPreference"), setFunc = SetterFactory("mundus", "DisplayPreference"),
                },

            },
        },
        {
            type = "submenu",
            name = "Research Timers",
            controls = {
                {
                    type = "checkbox",
                    name = "Display Text",
                    default = true,
                    tooltip = "Display text for these gadgets.",
                    getFunc = function() return settings.gadgetText["Blacksmithing Research Timer"] end,
                    setFunc = function(newValue)
                        settings.gadgetText["Blacksmithing Research Timer"] = newValue
                        settings.gadgetText["Clothing Research Timer"] = newValue
                        settings.gadgetText["Woodworking Research Timer"] = newValue
                        settings.gadgetText["Jewelry Crafting Research Timer"] = newValue
                    end,
                },
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display research timers.",
                    default = "simple",
                    choices = {"simple", "short", "exact"},
                    getFunc = GetterFactory("research", "DisplayPreference"), setFunc = SetterFactory("research", "DisplayPreference"),
                },
                {
                    type = "checkbox",
                    name = "Only show timers while researching",
                    default = true,
                    tooltip = "Show the icon and timer only when you are actively researching.",
                    getFunc = function() return settings.research.Dynamic end,
                    setFunc = function(newValue)
                        settings.research.Dynamic = newValue
                        TEB.RebuildBar()
                    end,
                },
                {
                    type = "checkbox",
                    name = "Only show the shortest timer",
                    default = false,
                    tooltip = "When researching multiple items, only show the timer that has the least amount of time left.",
                    getFunc = GetterFactory("research", "ShowShortest"), setFunc = SetterFactory("research", "ShowShortest"),
                },
                {
                    type = "checkbox",
                    name = "Show free slots",
                    default = true,
                    tooltip = "Show the number of free slots available for research.",
                    getFunc = GetterFactory("research", "DisplayAllSlots"), setFunc = SetterFactory("research", "DisplayAllSlots"),
                },
                {
                    type = "dropdown",
                    name = "Display free slots as",
                    tooltip = "Choose how to display free research slots.",
                    default = "--",
                    choices = {"--", "-", "free", "0", "done"},
                    getFunc = GetterFactory("research", "FreeText"), setFunc = SetterFactory("research", "FreeText"),
                },
            },
        },
        {
            type = "submenu",
            name = "Sky Shards",
            controls = {
                DTCheckBoxFactory("Sky Shards"),
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display sky shard count.",
                    default = "collected/unspent points",
                    choices = {"collected/unspent points", "collected/total needed (unspent points)", "needed/unspent points", "collected", "needed"},
                    getFunc = GetterFactory("skyshards", "DisplayPreference"), setFunc = SetterFactory("skyshards", "DisplayPreference"),
                },
            },
        },
        {
            type = "submenu",
            name = "Soul Gems",
            controls = {
                DTCheckBoxFactory("Soul Gems"),
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display soul gem count.\ntotal filled = normal (non-crown) filled soul gems + crown soul gems\nnormal filled = normal (non-crown) filled soul gems\ncrown = crown soul gems\nempty = empty soul gems",
                    default = "total filled/empty",
                    choices = {"total filled/empty", "total filled (empty)", "total filled (crown)/empty", "normal filled/crown/empty", "total filled", "normal filled"},
                    getFunc = function() return settings.soulgems.DisplayPreference end,
                    setFunc = function(newValue)
                        settings.soulgems.DisplayPreference = newValue
                        TEB.CalculateBagItems()
                    end,
                },
                {
                    type = "checkbox",
                    name = "Color soul gems",
                    default = true,
                    tooltip = "Appriopriately color each kind of soul gems in tooltips",
                    getFunc = GetterFactory("soulgems", "Color"), setFunc = SetterFactory("soulgems", "Color"),
                },
            },
        },
        {
            type = "submenu",
            name = "Tel Var Stones",
            controls = {
                DTCheckBoxFactory("Tel Var Stones"),
            },
        },
        {
            type = "submenu",
            name = "Thief's Tools",
            controls = {
                DTCheckBoxFactory("Thief's Tools"),
                {
                    type = "slider",
                    name = "Interactions warning threshold (yellow)",
                    tooltip = "Fence and launder interactions below this number will be colored yellow.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 25,
                    getFunc = function() return settings.tt.warning end,
                    setFunc = function(newValue)
                        settings.tt.warning = newValue
                        TEB.CalculateBagItems()
                    end,
                },
                {
                    type = "slider",
                    name = "Interactions danger threshold (red)",
                    tooltip = "Fence and launder interactions below this number will be colored red.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 10,
                    getFunc = function() return settings.tt.danger end,
                    setFunc = function(newValue)
                        settings.tt.danger = newValue
                        TEB.CalculateBagItems()
                    end,
                },
                {
                    type = "dropdown",
                    name = "Display format",
                    tooltip = "Choose how to display the thief's tools.",
                    default = "stolen treasures/stolen goods (lockpicks)",
                    choices = {"lockpicks", "total stolen", "total stolen (lockpicks)", "stolen treasures/stolen goods", "stolen treasures/stolen goods (lockpicks)", "stolen treasures/fence_remaining stolen goods/launder_remaining", "stolen treasures/fence_remaining stolen goods/launder_remaining (lockpicks)", "stolen treasures/stolen goods fence_remaining/launder_remaining", "stolen treasures/stolen goods fence_remaining/launder_remaining (lockpicks)"},
                    getFunc = function() return settings.tt.DisplayPreference end,
                    setFunc = function(newValue)
                        settings.tt.DisplayPreference = newValue
                        TEB.CalculateBagItems()
                    end,
                },
            },
        },
        {
            type = "submenu",
            name = "Transmute Crystals",
            controls = {
                DTCheckBoxFactory("Transmute Crystals"),
            },
        },
        {
            type = "submenu",
            name = "Unread Mail",
            controls =
            {
                DTCheckBoxFactory("Unread Mail"),
                {
                    type = "checkbox",
                    name = "Automatically hide when no unread mail",
                    default = true,
                    tooltip = "Hide the gadget only when there in no unread mail.",
                    getFunc = function() return settings.mail.Dynamic end,
                    setFunc = function(newValue)
                        settings.mail.Dynamic = newValue
                        TEB.RebuildBar()
                    end,
                },
                {
                    type = "checkbox",
                    name = "Indicate when there is unread mail",
                    default = true,
                    tooltip = "When there is unread mail, turn the gadget green.",
                    getFunc = GetterFactory("mail", "good"), setFunc = SetterFactory("mail", "good"),
                },
                {
                    type = "checkbox",
                    name = "Pulse gadget",
                    default = true,
                    tooltip = "Pulse the gadget when there is unread mail.",
                    getFunc = GetterFactory("mail", "critical"), setFunc = SetterFactory("mail", "critical"),
                },
            },
        },
        {
            type = "submenu",
            name = "Vampirism",
            controls = {
            DTCheckBoxFactory("Vampirism"),
            {
                type = "dropdown",
                name = "Display format",
                tooltip = "Choose how to display the vampirism gadget information.",
                default = "Stage (Timer)",
                choices = {"Stage (Timer)", "Timer"},
                getFunc = GetterFactory("vampirism", "DisplayPreference"), setFunc = SetterFactory("vampirism", "DisplayPreference"),
            },
            {
                type = "dropdown",
                name = "Timer Display format",
                tooltip = "Choose how to display the vampirism stage timer.",
                default = "simple",
                choices = {"simple", "short", "exact"},
                getFunc = GetterFactory("vampirism", "TimerPreference"), setFunc = SetterFactory("vampirism", "TimerPreference"),
            },
            {
                type = "checkbox",
                name = "Hide if not a vampire",
                default = true,
                tooltip = "Show the gadget only if you are a vampire.",
                getFunc = function() return settings.vampirism.Dynamic end,
                setFunc = function(newValue)
                    settings.vampirism.Dynamic = newValue
                    TEB.RebuildBar()
                end,
            },
            VampireStageFactory(1),
            VampireStageFactory(2),
            VampireStageFactory(3),
            VampireStageFactory(4),
        },
    },
        {
            type = "submenu",
            name = "Weapon Charge/Poison",
            controls = {
                DTCheckBoxFactory("Weapon Charge/Poison"),
                {
                    type = "checkbox",
                    name = "Display poison count when poison is applied",
                    default = true,
                    tooltip = "Replace weapon charge display with poison count whenever poison is applied to a weapon.",
                    getFunc = GetterFactory("wc", "AutoPoison"), setFunc = SetterFactory("wc", "AutoPoison"),
                },
                {
                        type = "description",
                        text = "|c2A8FEEWeapon Charge Thresholds:",
                        width = "full"
                },
                {
                    type = "slider",
                    name = "Warning threshold (yellow)",
                    tooltip = "Weapon charge below this number will be colored yellow.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 50,
                    getFunc = GetterFactory("wc", "warning"), setFunc = SetterFactory("wc", "warning"),
                },
                {
                    type = "slider",
                    name = "Danger threshold (red)",
                    tooltip = "Weapon charge below this number will be colored red.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 25,
                    getFunc = GetterFactory("wc", "danger"), setFunc = SetterFactory("wc", "danger"),
                },
                {
                    type = "slider",
                    name = "Critical threshold (pulse)",
                    tooltip = "Weapon charge below this number will cause the gadget to pulse.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 10,
                    getFunc = GetterFactory("wc", "critical"), setFunc = SetterFactory("wc", "critical"),
                },
                {
                        type = "description",
                        text = "|c2A8FEEPoison Count Thresholds:",
                        width = "full"
                },
                {
                    type = "slider",
                    name = "Warning threshold (yellow)",
                    tooltip = "Poison Count below this number will be colored yellow.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 20,
                    getFunc = GetterFactory("wc", "PoisonWarning"), setFunc = SetterFactory("wc", "PoisonWarning"),
                },
                {
                    type = "slider",
                    name = "Danger threshold (red)",
                    tooltip = "Poison Count below this number will be colored red.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 10,
                    getFunc = GetterFactory("wc", "PoisonDanger"), setFunc = SetterFactory("wc", "PoisonDanger"),
                },
                {
                    type = "slider",
                    name = "Critical threshold (pulse)",
                    tooltip = "Poison Count below this number will cause the gadget to pulse.",
                    min = 0,
                    max = 100,
                    step = 1,
                    default = 5,
                    getFunc = GetterFactory("wc", "PoisonCritical"), setFunc = SetterFactory("wc", "PoisonCritical"),
                },
            },
        },
        {
            type = "submenu",
            name = "Writ Vouchers",
            controls = {
                DTCheckBoxFactory("Writ Vouchers"),
            },
        },
    }
    
    TEB.panelControl = LAM2:RegisterAddonPanel("TEB_ASUGB", panelData)
    LAM2:RegisterOptionControls("TEB_ASUGB", controlStructure)

end

EVENT_MANAGER:RegisterForEvent(TEB.name, EVENT_ADD_ON_LOADED, TEB.OnAddOnLoaded)

TEB.debug = TEB.debug .. "Main code finished\n"

-- THE END
