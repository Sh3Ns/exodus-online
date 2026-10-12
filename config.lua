-- Debug Mode for test scripts, see errors
debugMode = false

-- Combat settings
-- NOTE: valid values for worldType are: "pvp", "no-pvp" and "pvp-enforced"
worldType = "pvp"
hotkeyAimbotEnabled = true
protectionLevel = 1
killsToRedSkull = 3
killsToBlackSkull = 6
pzLocked = 60000
removeChargesFromRunes = true
removeChargesFromPotions = true
removeWeaponAmmunition = true
removeWeaponCharges = true
timeToDecreaseFrags = 24 * 60 * 60
whiteSkullTime = 15 * 60
stairJumpExhaustion = 2000
experienceByKillingPlayers = false
expFromPlayersLevelRange = 75

-- Connection Config
-- NOTE: maxPlayers set to 0 means no limit
-- NOTE: allowWalkthrough is only applicable to players
ip = "127.0.0.1"
bindOnlyGlobalAddress = false
loginProtocolPort = 7171
gameProtocolPort = 7172
statusProtocolPort = 7171
maxPlayers = 500
motd = "Welcome to Hellgrave Exodus Server!"
onePlayerOnlinePerAccount = false
allowClones = false
allowWalkthrough = true
serverName = "Hellgrave"
statusTimeout = 5000
replaceKickOnLogin = true
maxPacketsPerSecond = 120
battlePassEndDate = "20.09.2125.10.00"

-- Deaths
-- NOTE: Leave deathLosePercent as -1 if you want to use the default
-- death penalty formula. For the old formula, set it to 10. For
-- no skill/experience loss, set it to 0.
deathLosePercent = -1

-- Houses
-- NOTE: set housePriceEachSQM to -1 to disable the ingame buy house functionality
-- NOTE: valid values for houseRentPeriod are: "daily", "weekly", "monthly", "yearly"
-- use any other value to disable the rent system
housePriceEachSQM = 1836
houseRentPeriod = "never"
houseOwnedByAccount = false
houseDoorShowPrice = true
onlyInvitedCanMoveHouseItems = true

---- Monster Levels

monsterBonusHealth = 0.0074
monsterBonusSpeed = 0.0085
monsterBonusDamage = 0.0015

-- Item Usage
timeBetweenActions = 200
timeBetweenExActions = 1000

-- Rates Reward Boss Chest
-- If a player meets their share of the expectedScore (totalScore/contributors), they receive a lootRate according to the rewardBaseRate.
rewardBaseRate = 1
rewardRateDamageDone = 0.7
rewardRateDamageTaken = 0.6
rewardRateHealingDone = 0.6

--- Rain
weatherRain = true
thunderEffect = true
-- Map
-- NOTE: set mapName WITHOUT .otbm at the end
mapName = "realmap_exodus"
mapAuthor = ""

-- Market
marketOfferDuration = 30 * 24 * 60 * 60
premiumToCreateMarketOffer = true
checkExpiredMarketOffersEachMinutes = 120 --- Default 120 = 2 hours
checkExpireOfferBatchSize = 1000 --- Check X offers in one way // Default 1000 each 2h
maxMarketOffersAtATimePerPlayer = 100

-- MySQL
mysqlHost = "127.0.0.1"
mysqlUser = "root"
mysqlPass = "root"
mysqlDatabase = "exodus_dungeon"
mysqlPort = 3306
mysqlSock = ""
passwordType = "sha1"

-- Misc.
-- NOTE: classicAttackSpeed set to true makes players constantly attack at regular
-- intervals regardless of other actions such as item (potion) use. This setting
-- may cause high CPU usage with many players and potentially affect performance!
-- NOTE: forceMonsterTypesOnLoad loads all monster types on startup to validate them.
-- You can disable it to save some memory if you don't see any errors at startup.
allowChangeOutfit = true
freePremium = false
kickIdlePlayerAfterMinutes = 15
maxMessageBuffer = 4
emoteSpells = true
classicEquipmentSlots = false
classicAttackSpeed = false
showScriptsLogInConsole = false
showOnlineStatusInCharlist = false
yellMinimumLevel = 2
yellAlwaysAllowPremium = false
forceMonsterTypesOnLoad = true
cleanProtectionZones = false
luaItemDesc = false
showPlayerLogInConsole = true

-- VIP and Depot limits
-- NOTE: you can set custom limits per group in data/XML/groups.xml
vipFreeLimit = 20
vipPremiumLimit = 100
depotFreeLimit = 2000
depotPremiumLimit = 10000

-- World Light
-- NOTE: if defaultWorldLight is set to true the world light algorithm will
-- be handled in the sources. set it to false to avoid conflicts if you wish
-- to make use of the function setWorldLight(level, color)
defaultWorldLight = true

-- Server Save
-- NOTE: serverSaveNotifyDuration in minutes
serverSaveNotifyMessage = true
serverSaveNotifyDuration = 5
serverSaveCleanMap = false
serverSaveClose = false
serverSaveShutdown = true

-- Experience stages
-- NOTE: to use a flat experience multiplier, set experienceStages to nil
-- minlevel and multiplier are MANDATORY
-- maxlevel is OPTIONAL, but is considered infinite by default
-- to disable stages, create a stage with minlevel 1 and no maxlevel
experienceStages = {
    { minlevel = 1,    maxlevel = 20,   multiplier = 20 },
    { minlevel = 21,   maxlevel = 50,   multiplier = 100 },
    { minlevel = 51,   maxlevel = 100,  multiplier = 80 },
    { minlevel = 101,  maxlevel = 200,  multiplier = 65 },
    { minlevel = 201,  maxlevel = 300,  multiplier = 50 },
    { minlevel = 301,  maxlevel = 500,  multiplier = 45 },
    { minlevel = 501,  maxlevel = 700,  multiplier = 38 },
    { minlevel = 701,  maxlevel = 900,  multiplier = 32 },
    { minlevel = 901,  maxlevel = 1100, multiplier = 26 },
    { minlevel = 1101, maxlevel = 1300, multiplier = 21 },
    { minlevel = 1301, maxlevel = 1500, multiplier = 16 },
    { minlevel = 1501, maxlevel = 1700, multiplier = 13 },
    { minlevel = 1701, maxlevel = 1900, multiplier = 10 },
    { minlevel = 1901, maxlevel = 2100, multiplier = 9 },
    { minlevel = 2101, maxlevel = 2300, multiplier = 8 },
    { minlevel = 2301, maxlevel = 2500, multiplier = 7 },
    { minlevel = 2501, maxlevel = 2750, multiplier = 6 },
    { minlevel = 2751, maxlevel = 3000, multiplier = 4 },
    { minlevel = 3001, multiplier = 3 }
}

-- Rates
-- NOTE: rateExp is not used if you have enabled stages above
rateExp = 5
rateSkill = 3
rateLoot = 1
rateMagic = 2
rateSpawn = 1

-- Monster Despawn Config
-- despawnRange is the amount of floors a monster can be from its spawn position
-- despawnRadius is how many tiles away it can be from its spawn position
-- removeOnDespawn will remove the monster if true or teleport it back to its spawn position if false
-- walkToSpawnRadius is the allowed distance that the monster will stay away from spawn position when left with no targets, 0 to disable
deSpawnRange = 2
deSpawnRadius = 50
removeOnDespawn = true
walkToSpawnRadius = 15

-- Stamina
staminaSystem = true

-- Scripts
warnUnsafeScripts = true
convertUnsafeScripts = true

-- Startup
-- NOTE: defaultPriority only works on Windows and sets process
-- priority, valid values are: "normal", "above-normal", "high"
defaultPriority = "high"
startupDatabaseOptimization = false

-- Status Server Information
ownerName = "Alexv45"
ownerEmail = ""
url = "https://opengamescommunity.com/"
location = "Spain"
