local function P(x, y, z)
    return Position(x, y, z)
end

MakeBelieveQuestConfig = {
    enabled = true,
    minimumLevel = 300,
    maximumPlayers = 4,
    runTimeSeconds = 60 * 60,
    cooldownSeconds = 20 * 60 * 60,
    entryLeverActionId = 42700,
    entryCooldownStorage = 730110,
    progressStorage = 730100,
    completionStorage = 730101,
    teleportItemId = 31839,
    portalDurationSeconds = 30,
    leverIds = { 1945, 1946 },

    rewards = {
        cloudInABottle = {
            itemId = 31930,
            mountId = 159,
            mountName = "Radiant Nimbus"
        },
        mimarHaffar = {
            mountId = 160,
            mountName = "Jarcal"
        },
        phosphorus = {
            mountId = 158,
            mountName = "Djinntaur",
            requiredKills = 5,
            killStorage = 730102
        }
    },

    vocationGroups = {
        shield = { [4] = true, [8] = true, [11] = true, [12] = true },
        fire = {
            [1] = true, [2] = true, [3] = true,
            [5] = true, [6] = true, [7] = true,
            [9] = true, [10] = true
        }
    },

    rooms = {
        mimar = {
            order = 1,
            participants = {
                P(34060, 31639, 8),
                P(34061, 31639, 8),
                P(34062, 31639, 8),
                P(34063, 31639, 8)
            },
            area = {
                from = P(34035, 31637, 9),
                to = P(34060, 31652, 9)
            },
            entrance = P(34041, 31643, 9),
            exit = P(34061, 31635, 8),
            boss = {
                name = "Mimar Haffar",
                position = P(34053, 31642, 9)
            },
            completionPortal = {
                actionId = 42750,
                position = P(34051, 31640, 9),
                destination = P(34062, 31642, 9)
            },

            crystalItemId = 31906,
            chargePerCrystal = 10,
            chargeTarget = 100,
            vulnerableSeconds = 60,
            cannons = {
                left = {
                    actionId = 42710,
                    itemId = 31907,
                    chargedItemId = 31909,
                    position = P(34044, 31646, 9)
                },
                right = {
                    actionId = 42711,
                    itemId = 31908,
                    chargedItemId = 31910,
                    position = P(34054, 31646, 9)
                }
            },
            miners = {
                name = "Moonstone Miner",
                waveSize = 5,
                spawnEverySeconds = 60,
                spawnArea = {
                    from = P(34035, 31637, 9),
                    to = P(34060, 31652, 9)
                }
            }
        },

        domus = {
            order = 2,
            area = {
                from = P(34060, 31632, 9),
                to = P(34079, 31650, 9)
            },
            entrance = P(34062, 31642, 9),
            exit = P(34061, 31635, 8),
            boss = {
                name = "Maior Domus",
                position = P(34070, 31639, 9),
                transformAtHealth = 185000,
                transformInto = "Maior Domus Echo"
            },
            completionPortal = {
                actionId = 42751,
                position = P(34066, 31635, 9),
                destination = P(34051, 31626, 10)
            },

            damageEverySeconds = 6,
            toggleEverySeconds = 15,
            toggleLineEffect = 463,
            vulnerableBossEffect = 438,
            invulnerableBossEffect = 462,
            randomTileDamage = {
                tileCount = 50,
                everySeconds = 9,
                warningSeconds = 2,
                warningEffect = 262,
                minDamage = -1000,
                maxDamage = -2000,
                damagePool = {
                    {
                        combatType = COMBAT_FIREDAMAGE,
                        effect = 433
                    },
                    {
                        combatType = COMBAT_DEATHDAMAGE,
                        effect = 437
                    },
                    {
                        combatType = COMBAT_ARCANEDAMAGE,
                        effect = 432
                    },
                    {
                        combatType = COMBAT_WATERDAMAGE,
                        effect = 434
                    },
                    {
                        combatType = COMBAT_HOLYDAMAGE,
                        effect = 435
                    },
                    {
                        combatType = COMBAT_PHYSICALDAMAGE,
                        effect = 436
                    },
                    {
                        combatType = COMBAT_EARTHDAMAGE,
                        effect = 431
                    }
                }
            },
            lines = {
                {
                    fromPosition = P(34064, 31635, 9),
                    toPosition = P(34064, 31647, 9),
                    combatType = COMBAT_ARCANEDAMAGE,
                    minDamage = -444,
                    maxDamage = -1111,
                    effect = 465
                },
                {
                    fromPosition = P(34068, 31635, 9),
                    toPosition = P(34068, 31647, 9),
                    combatType = COMBAT_DEATHDAMAGE,
                    minDamage = -444,
                    maxDamage = -1111,
                    effect = 464
                },
                {
                    fromPosition = P(34061, 31641, 9),
                    toPosition = P(34075, 31641, 9),
                    combatType = COMBAT_ARCANEDAMAGE,
                    minDamage = -444,
                    maxDamage = -1111,
                    effect = 457
                },
                {
                    fromPosition = P(34061, 31643, 9),
                    toPosition = P(34075, 31643, 9),
                    combatType = COMBAT_DEATHDAMAGE,
                    minDamage = -444,
                    maxDamage = -1111,
                    effect = 458
                }
            }
        },

        phosphorus = {
            order = 3,
            area = {
                from = P(34027, 31609, 10),
                to = P(34055, 31641, 10)
            },
            entrance = P(34051, 31626, 10),
            exit = P(34061, 31635, 8),
            boss = {
                name = "Phosphorus Manifestation",
                position = P(34039, 31617, 10),
                transformAtHealth = 350000,
                transformInto = "Phosphorus Ascendant"
            },
            completionPortal = {
                actionId = 42752,
                position = P(34038, 31614, 10),
                destination = P(34061, 31635, 8)
            },
            vulnerableSeconds = 40,
            requiredRivalKills = 5,
            rivalSpawnEverySeconds = 20,
            bossPedestalHoldSeconds = 3,
            failureHealthBonus = 30000,
            failureDamagePercent = 2,
            rivalSpawnPosition = P(34039, 31613, 10),
            storms = {
                name = "Storm",
                count = 2,
                spawnAfterSeconds = 60,
                minimumPlayerDistance = 5
            },
            arcaneTraps = {
                actionId = 42742,
                itemId = 31911,
                area = {
                    from = P(34035, 31613, 10),
                    to = P(34055, 31639, 10)
                },
                count = 20,
                spawnEverySeconds = 20,
                durationSeconds = 10,
                damageDelaySeconds = 2,
                combatType = COMBAT_ARCANEDAMAGE,
                minDamage = -1000,
                maxDamage = -3000,
                effect = 442
            },
            fear = {
                castEverySeconds = 20,
                durationSeconds = 5,
                stepIntervalMilliseconds = 500,
                range = 7,
                effect = 217
            },
            rivals = {
                {
                    vocation = "knight",
                    name = "Knight Rival",
                    pedestal = {
                        actionId = 42730,
                        itemId = 31902,
                        position = P(34041, 31635, 10),
                        radius = 1
                    }
                },
                {
                    vocation = "paladin",
                    name = "Paladin Rival",
                    pedestal = {
                        actionId = 42731,
                        itemId = 31903,
                        position = P(34046, 31631, 10),
                        radius = 1
                    }
                },
                {
                    vocation = "sorcerer",
                    name = "Sorcerer Rival",
                    pedestal = {
                        actionId = 42732,
                        itemId = 31904,
                        position = P(34048, 31623, 10),
                        radius = 1
                    }
                },
                {
                    vocation = "druid",
                    name = "Druid Rival",
                    pedestal = {
                        actionId = 42733,
                        itemId = 31905,
                        position = P(34043, 31615, 10),
                        radius = 1
                    }
                },
                {
                    vocation = "monk",
                    name = "Monk Rival",
                    pedestal = {
                        actionId = 42734,
                        itemId = 31901,
                        position = P(34037, 31616, 10),
                        radius = 1
                    }
                }
            },
            hazards = {
                enabled = true,
                curseEverySeconds = 12,
                curseDamagePerStack = 250,
                curseCombatType = COMBAT_DEATHDAMAGE,
                shimmeringField = {
                    actionId = 42740,
                    itemId = 0,
                    position = P(0, 0, 0)
                },
                rift = {
                    actionId = 42741,
                    itemId = 0,
                    spawnEverySeconds = 10,
                    lifeLossPercent = 40,
                    positions = {
                        P(0, 0, 0),
                        P(0, 0, 0),
                        P(0, 0, 0)
                    }
                }
            }
        }
    }
}
