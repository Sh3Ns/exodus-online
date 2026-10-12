local Rootkraken = Dungeon()

-- Basic info
Rootkraken:setTitle("Rootkraken")
Rootkraken:setDuration(60 * 60 * 1000)
Rootkraken:setMapFile("rootkraken")
Rootkraken:setStartPosition(Position(173, 200, 8))
Rootkraken:setRequiredParty(1, 5)

-- Boss
Rootkraken:setBoss("The Rootkraken", Position(311, 150, 12))
Rootkraken:setKillPercent(80)

-- Requirements
Rootkraken:setRequiredLevel(600)
Rootkraken:setRequiredGold(10 * 100 * 100)

-- Boss Loot
Rootkraken:addReward(2160, 25, 32)
Rootkraken:addReward(28081, 8, 32)
Rootkraken:addReward(28077, 8, 30)
Rootkraken:addReward(28089, 8, 28)
Rootkraken:addReward(28138, 5, 5)
Rootkraken:addReward(28142, 1, 28)
Rootkraken:addReward(28143, 2, 41)
Rootkraken:addReward(28144, 2, 14)
Rootkraken:addReward(28145, 2, 12)
Rootkraken:addReward(28146, 8, 28)
Rootkraken:addReward(28147, 4, 28)
Rootkraken:addReward(28148, 1, 28)
Rootkraken:addReward(28149, 6, 28)
Rootkraken:addReward(18432, 3, 8)
Rootkraken:addReward(18451, 1, 11)
Rootkraken:addReward(18450, 1, 11)
Rootkraken:addReward(18452, 1, 10)
Rootkraken:addReward(18454, 1, 9)
Rootkraken:addReward(18465, 1, 2)
Rootkraken:addReward(18453, 1, 4)
Rootkraken:addReward(18454, 1, 3)
Rootkraken:addReward(18401, 1, 3)
Rootkraken:addReward(18422, 9, 8)
Rootkraken:addReward(18423, 5, 8)
Rootkraken:addReward(29948, 1, 8)
Rootkraken:addReward(29619, 1, 5)
Rootkraken:addReward(29620, 1, 4)
Rootkraken:addReward(29621, 1, 3)
Rootkraken:addReward(29622, 1, 2)
Rootkraken:addReward(29623, 1, 3)




Rootkraken:addChallenge(ChallengesIndex.ROOTKRAKEN_HUNTER)
Rootkraken:addChallenge(ChallengesIndex.ROOTKRAKEN_FINISH)


-- Instances
Rootkraken:addInstance(Position(3300, 3300, 0))


Rootkraken:register()
