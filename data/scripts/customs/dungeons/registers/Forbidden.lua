local ForbiddenBoss = Dungeon()

-- Basic info
ForbiddenBoss:setTitle("Forbidden")
ForbiddenBoss:setDuration(60 * 60 * 1000)
ForbiddenBoss:setMapFile("forbidden")
ForbiddenBoss:setStartPosition(Position(205, 148, 0))
ForbiddenBoss:setRequiredParty(1, 5)

-- Boss
ForbiddenBoss:setBoss("Forbidden Chevalier", Position(153, 138, 10))
ForbiddenBoss:setKillPercent(80)

-- Requirements
ForbiddenBoss:setRequiredLevel(500)
ForbiddenBoss:setRequiredGold(5 * 100 * 100) 

-- Boss Loot
ForbiddenBoss:addReward(2160, 17, 25)
ForbiddenBoss:addReward(26795, 2, 25)
ForbiddenBoss:addReward(28117, 3, 20)
ForbiddenBoss:addReward(28119, 2, 18)
ForbiddenBoss:addReward(28122, 2, 18)
ForbiddenBoss:addReward(26780, 3, 25)
ForbiddenBoss:addReward(28080, 10, 80)
ForbiddenBoss:addReward(28088, 10, 80)
ForbiddenBoss:addReward(28076, 10, 80)
ForbiddenBoss:addReward(28124, 1, 8)
ForbiddenBoss:addReward(28125, 1, 5)
ForbiddenBoss:addReward(28126, 1, 4)
ForbiddenBoss:addReward(2128, 1, 1)
ForbiddenBoss:addReward(27653, 1, 4)
ForbiddenBoss:addReward(29941, 1, 4)
ForbiddenBoss:addReward(27654, 1, 4)
ForbiddenBoss:addReward(27656, 1, 4)
ForbiddenBoss:addReward(30002, 1, 4)
ForbiddenBoss:addReward(27658, 1, 4)
ForbiddenBoss:addReward(27660, 1, 4)
ForbiddenBoss:addReward(27661, 1, 4)
ForbiddenBoss:addReward(27663, 1, 4)
ForbiddenBoss:addReward(27664, 1, 4)
ForbiddenBoss:addReward(27665, 1, 4)
ForbiddenBoss:addReward(27667, 1, 4)
ForbiddenBoss:addReward(27668, 1, 4)
ForbiddenBoss:addReward(27669, 1, 4)
ForbiddenBoss:addReward(27670, 1, 4)
ForbiddenBoss:addReward(27671, 1, 4)
ForbiddenBoss:addReward(29619, 1, 5)
ForbiddenBoss:addReward(29620, 1, 4)
ForbiddenBoss:addReward(29621, 1, 3)
ForbiddenBoss:addReward(29622, 1, 2)
ForbiddenBoss:addReward(29623, 1, 3)




ForbiddenBoss:addChallenge(ChallengesIndex.FORBIDDEN_HUNTER)
ForbiddenBoss:addChallenge(ChallengesIndex.FORBIDDEN_FINISH)


-- Instances
ForbiddenBoss:addInstance(Position(10600, 10600, 0))
ForbiddenBoss:addInstance(Position(10900, 10900, 0))

ForbiddenBoss:register()
