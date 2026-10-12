function Dungeon:onQueue()
	local queue = self:getQueue()
	local players = Game.getPlayers()
	local inQueue = queue:getPlayersNumber()
	for _, player in ipairs(players) do
	  player:sendExtendedOpcode(
		ExtendedOPCodes.CODE_DUNGEONS,
		json.encode({action = "queueUpdate", data = {id = self:getId(), queue = inQueue, estimated = self:getEstimatedQueueTime(player)}})
	  )
	end
  end
  
  function Dungeon:onPrepare(instance, player)
	player:sendExtendedOpcode(ExtendedOPCodes.CODE_DUNGEONS, json.encode({action = "prepare"}))
  end
  
  function Dungeon:onStart(instance, player)
	player:sendExtendedOpcode(
	  ExtendedOPCodes.CODE_DUNGEONS,
	  json.encode(
		{
		  action = "start",
		  data = {
			boss = self:getBoss(),
			left = instance:getMonstersTotalCount(),
			duration = self:getDuration(),
			objectives = self:getBonusObjectives()
		  }
		}
	  )
	)
  end
  
  function Dungeon:onSuccess(instance)
	local runners = instance:getRunners()
  
	local reqParty = self:getRequiredParty()
	if #runners > 1 then
	  self:updateGroupRun(instance)
	else
	  self:updateSoloRun(instance)
	end
	
	if self:getTitle() == "Rootkraken" then
		for _, runner in ipairs(runners) do
		  if not runner:hasCompletedChallenge(ChallengesIndex.ROOTKRAKEN_HUNTER) then
			runner:completeChallenge(ChallengesIndex.ROOTKRAKEN_FINISH)
		  end
		end
	  end
	if self:getTitle() == "Forbidden" then
		for _, runner in ipairs(runners) do
		  if not runner:hasCompletedChallenge(ChallengesIndex.FORBIDDEN_HUNTER) then
			runner:completeChallenge(ChallengesIndex.FORBIDDEN_FINISH)
		  end
		end
	  end
	if self:getTitle() == "MasterElement" then
	  for _, runner in ipairs(runners) do
		if not runner:hasCompletedChallenge(ChallengesIndex.MASTER_ELEMENTS_HUNTER) then
		  runner:completeChallenge(ChallengesIndex.MASTER_ELEMENTS_FINISH)
		end
	  end
	end
	if self:getTitle() == "Bones" then
		for _, runner in ipairs(runners) do
		  if not runner:hasCompletedChallenge(ChallengesIndex.BONES_HUNTER) then
			runner:completeChallenge(ChallengesIndex.BONES_FINISH)
		  end
		end
	  end
  
	for _, runner in ipairs(runners) do
	  if runner:getLastDifficulty(self:getId()) < 6 and instance:getDifficulty() >= runner:getLastDifficulty(self:getId()) then
		runner:setLastDifficulty(self:getId(), instance:getDifficulty() + 1)
	  end
	end
  end
  
  function Dungeon:onFail(instance)
  end
  
  function Dungeon:onPlayerLeft(instance, player)
	player:sendExtendedOpcode(
	  ExtendedOPCodes.CODE_DUNGEONS,
	  json.encode({action = "finish", data = {success = instance:isBossSpawned() and not instance:getBoss()}})
	)
  end
  
  function Dungeon:onMonstersCount(instance, count)
  end