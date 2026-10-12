ChallengesIndex = {
  MASTER_ELEMENTS_HUNTER = 1,
  MASTER_ELEMENTS_FINISH = 2,
  BONES_HUNTER = 3,
  BONES_FINISH = 4,
  FORBIDDEN_HUNTER = 5,
  FORBIDDEN_FINISH = 6,
  ROOTKRAKEN_HUNTER = 7,
  ROOTKRAKEN_FINISH = 8
}

ChallengesList = {
  [ChallengesIndex.MASTER_ELEMENTS_HUNTER] = {
    title = "Monster Hunter",
    description = "Kill all monster on MOTE in Normal difficulty.",
    points = 5
  },
  [ChallengesIndex.MASTER_ELEMENTS_FINISH] = {
    title = "Master Elements Dungeon",
    description = "Finish dungeon on Normal difficulty.",
    points = 15
  },
  [ChallengesIndex.BONES_HUNTER] = {
    title = "Monster Hunter",
    description = "Kill all monster on Bones in Normal difficulty.",
    points = 5
  },
  [ChallengesIndex.BONES_FINISH] = {
    title = "Bones Dungeon",
    description = "Finish dungeon on Normal difficulty.",
    points = 15
  },
  [ChallengesIndex.FORBIDDEN_HUNTER] = {
    title = "Monster Hunter",
    description = "Kill all monster on Forbidden in Normal difficulty.",
    points = 5
  },
  [ChallengesIndex.FORBIDDEN_FINISH] = {
    title = "Bones Dungeon",
    description = "Finish dungeon on Normal difficulty.",
    points = 15
  },
  [ChallengesIndex.ROOTKRAKEN_HUNTER] = {
    title = "Monster Hunter",
    description = "Kill all monster on Rootkraken in Normal difficulty.",
    points = 5
  },
  [ChallengesIndex.ROOTKRAKEN_FINISH] = {
    title = "Rootkraken Dungeon",
    description = "Finish dungeon on Normal difficulty.",
    points = 15
  }
}

function Player:addChallengeProgress(id, value)
  self:setStorageValue(PlayerStorageKeys.challengeComplete + id, self:getChallengeProgress(id) + value)
end

function Player:getChallengeProgress(id)
  local progress = self:getSorageValue(PlayerStorageKeys.challengeProgress + id)
  if progress == -1 then
    progress = 0
  end
  return progress
end

function Player:completeChallenge(id)
  self:setStorageValue(PlayerStorageKeys.challengeComplete + id, 1)
  self:addChallengePoints(ChallengesList[id].points)
  self:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "challenge", data = ChallengesList[id].title}))
end

function Player:hasCompletedChallenge(id)
  return self:getStorageValue(PlayerStorageKeys.challengeComplete + id) > 0
end

function Player:addChallengePoints(value)
  self:setStorageValue(PlayerStorageKeys.challengePoints, self:getChallengePoints() + value)
end

function Player:setChallengePoints(value)
  self:setStorageValue(PlayerStorageKeys.challengePoints, value)
end

function Player:getChallengePoints()
  local points = self:getStorageValue(PlayerStorageKeys.challengePoints)
  if points == -1 then
    points = 0
  end

  return points
end
