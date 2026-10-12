local Bones = Dungeon()

-- Basic info
Bones:setTitle("Bones")
Bones:setDuration(60 * 60 * 1000)
Bones:setMapFile("bonesdungeon")
Bones:setStartPosition(Position(78, 32, 7))
Bones:setRequiredParty(1, 5)

-- Boss
Bones:setBoss("Prince Skeletal", Position(312, 106, 7))
Bones:setKillPercent(80)

-- Requirements
Bones:setRequiredLevel(200)
Bones:setRequiredGold(1 * 100 * 100) -- 1cc

-- Boss Loot
Bones:addReward(2160, 7, 65)
Bones:addReward(2145, 8, 20)
Bones:addReward(9971, 2, 14)
Bones:addReward(28033, 2, 8)
Bones:addReward(7437, 1, 8)
Bones:addReward(7452, 1, 8)
Bones:addReward(2079, 1, 7)
Bones:addReward(8878, 1, 7)
Bones:addReward(7404, 1, 7)
Bones:addReward(28058, 2, 6)
Bones:addReward(2492, 1, 5)
Bones:addReward(8885, 1, 5)
Bones:addReward(26711, 1, 4)
Bones:addReward(26709, 1, 4)
Bones:addReward(30005, 1, 3)
Bones:addReward(26710, 1, 3)
Bones:addReward(26708, 1, 3)
Bones:addReward(29619, 1, 5)
Bones:addReward(29620, 1, 4)
Bones:addReward(29621, 1, 3)
Bones:addReward(29622, 1, 2)
Bones:addReward(29623, 1, 3)

Bones:addChallenge(ChallengesIndex.BONES_HUNTER)
Bones:addChallenge(ChallengesIndex.BONES_FINISH)


-- Instances
Bones:addInstance(Position(9000, 9000, 0))
Bones:addInstance(Position(9450, 9450, 0))
--Bones:addInstance(Position(10160, 10000, 0))

Bones:register()
