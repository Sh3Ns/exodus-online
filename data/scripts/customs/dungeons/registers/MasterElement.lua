local MasterElement = Dungeon()

-- Basic info
MasterElement:setTitle("MasterElement")
MasterElement:setDuration(60 * 60 * 1000)
MasterElement:setMapFile("MasterElement")
MasterElement:setStartPosition(Position(116, 34, 7))
MasterElement:setRequiredParty(1, 5)

-- Boss
MasterElement:setBoss("Master of the Elements", Position(131, 256, 7))
MasterElement:setKillPercent(80)

-- Requirements
MasterElement:setRequiredLevel(300)
MasterElement:setRequiredGold(2 * 100 * 100) -- 1cc

-- Boss Loot
MasterElement:addReward(28033, 2, 8)
MasterElement:addReward(28058, 2, 6)
MasterElement:addReward(27177, 1, 38)
MasterElement:addReward(24774, 10, 5)
MasterElement:addReward(27133, 5, 90)
MasterElement:addReward(27149, 3, 25)
MasterElement:addReward(27137, 3, 80)
MasterElement:addReward(26779, 8, 10)
MasterElement:addReward(27138, 2, 50)
MasterElement:addReward(27139, 1, 35)
MasterElement:addReward(27140, 3, 32)
MasterElement:addReward(27141, 2, 30)
MasterElement:addReward(27142, 1, 28)
MasterElement:addReward(27143, 3, 26)
MasterElement:addReward(27144, 2, 22)
MasterElement:addReward(27145, 1, 20)
MasterElement:addReward(27146, 3, 18)
MasterElement:addReward(27147, 2, 13)
MasterElement:addReward(27148, 1, 8)
MasterElement:addReward(29619, 1, 5)
MasterElement:addReward(29620, 1, 4)
MasterElement:addReward(29621, 1, 3)
MasterElement:addReward(29622, 1, 2)
MasterElement:addReward(29623, 1, 3)




MasterElement:addChallenge(ChallengesIndex.MASTER_ELEMENTS_HUNTER)
MasterElement:addChallenge(ChallengesIndex.MASTER_ELEMENTS_FINISH)


-- Instances
MasterElement:addInstance(Position(10300, 10300, 0))


MasterElement:register()
