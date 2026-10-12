print(">> World Bosses Loaded")

function notifyPlayers(markPos, markText, sound, extraBroadcast)
  Game.broadcastMessage(extraBroadcast or markText, MESSAGE_EVENT_ADVANCE)

  local players = Game.getPlayers()
  if #players == 0 then return end

  for _, p in ipairs(players) do
    if sound then
      playSoundPlayer(p, sound)
    end
    if markPos and markText then
      p:addMapMark(markPos, 22, markText)
    end
  end
end

function spawnBoss(bossName, bossPos)
  local tile = Tile(bossPos)
  local top  = tile and tile:getTopCreature() or nil
  if not top or not top:isMonster() or top:getName() ~= bossName then
    print("World Boss: " .. bossName .. " has appeared!")
    Game.createMonster(bossName, bossPos)
    return true
  end
  return false
end

local bosses = {
  {
    id       = "DreadscaleTheAncient",
    day      = "Sunday",
    time     = "0:00:00",
    bossName = "Dreadscale The Ancient",
    bossPos  = Position(32314, 31524, 9),
    markPos  = Position(32314, 31524, 7),
    markText = "World Boss: Dreadscale The Ancient",
    broadcast= "Dreadscale The Ancient has spawned on Dreadscale Island.",
    sound    = "expedition.ogg",
  },
  {
    id       = "AquaticOverlord",
    day      = "Monday",
    time     = "16:00:00",
    bossName = "Aquatic Overlord Thalassa",
    bossPos  = Position(33239, 32096, 9),
    markPos  = Position(33239, 32096, 7),
    markText = "World Boss: Aquatic Overlord Thalassa",
    broadcast= "Aquatic Overlord Thalassa has spawned on Thalassa Island.",
    sound    = "expedition.ogg",
  },
  {
    id       = "DrakTulTheSovereign",
    day      = "Tuesday",
    time     = "20:00:00",
    bossName = "Drak'thul The Void Sovereign",
    bossPos  = Position(32912, 31386, 10),
    markPos  = Position(32912, 31386, 7),
    markText = "World Boss: Drak'thul The Void Sovereign",
    broadcast= "Drak'thul The Void Sovereign has spawned on Sovereign Island.",
    sound    = "expedition.ogg",
  },
  {
    id       = "ThaladorTheStormbringer",
    day      = "Wednesday",
    time     = "20:00:00",
    bossName = "Thalador The Stormbringer",
    bossPos  = Position(31985, 31984, 5),
    markPos  = Position(31985, 31984, 7),
    markText = "World Boss: Thalador The Stormbringer",
    broadcast= "Thalador The Stormbringer has spawned on Thalador Island.",
    sound    = "expedition.ogg",
  },
  {
    id       = "VorondorEternalFlames",
    day      = "Thursday",
    time     = "20:00:00",
    bossName = "Vorondor The Eternal Flames",
    bossPos  = Position(32973, 31944, 7),
    markPos  = Position(32973, 31944, 7),
    markText = "World Boss: Vorondor The Eternal Flames",
    broadcast= "Vorondor The Eternal Flames has spawned on Eternal Island.",
    sound    = "expedition.ogg",
  },
  {
    id       = "AzazelSeraphim",
    day      = "Friday",
    time     = "20:00:00",
    bossName = "Azazel The Infernal Seraph",
    bossPos  = Position(33400, 31730, 6),
    markPos  = Position(33400, 31730, 7),
    markText = "World Boss: Azazel The Infernal Seraph",
    broadcast= "Azazel The Infernal Seraph has spawned on Azazel Island.",
    sound    = "expedition.ogg",
  },
  {
    id       = "MortisAndDreadbone",
    day      = "Saturday",
    time     = "12:00:00",
    multi    = {
      { name = "Mortis The Sovereign",  pos = Position(32964, 30960, 8) },
      { name = "Dreadbone The Eternal", pos = Position(32966, 30960, 8) },
    },
    markPos  = Position(32964, 30960, 7),
    markText = "World Boss: Mortis The Sovereign & Dreadbone The Eternal",
    broadcast= "Mortis and Dreadbone The Eternal have spawned on Horror Island.",
    sound    = "expedition.ogg",
  },
  {
    id       = "TymagronTheEarthshaker",
    day      = "Saturday",
    time     = "20:00:00",
    bossName = "Tymagron The Earthshaker",
    bossPos  = Position(32260, 31287, 7),
    markPos  = Position(32260, 31287, 7),
    markText = "World Boss: Tymagron The Earthshaker",
    broadcast= "Tymagron The Earthshaker has spawned on Earthshaker Island.",
    sound    = "expedition.ogg",
  },
  {
    id       = "GorgulTheFrenzied",
    day      = "Sunday",
    time     = "20:00:00",
    bossName = "Gor'gul The Frienzied",
    bossPos  = Position(32573, 31005, 9),
    markPos  = Position(32573, 31005, 7),
    markText = "World Boss: Gor'gul The Frienzied",
    broadcast= "Gor'gul The Frenzied has spawned on Gor'gul Island.",
    sound    = "expedition.ogg",
  },
}

local function createEvent(entry)
  local ev = GlobalEvent(entry.id)

  function ev.onTime()
    if os.date("%A") ~= entry.day then return true end

    if entry.multi then
      local spawnedAny = false
      for _, b in ipairs(entry.multi) do
        if spawnBoss(b.name, b.pos) then
          spawnedAny = true
        end
      end
      if spawnedAny then
        notifyPlayers(entry.markPos, entry.markText, entry.sound, entry.broadcast)
      end
    else
      if spawnBoss(entry.bossName, entry.bossPos) then
        notifyPlayers(entry.markPos, entry.markText, entry.sound, entry.broadcast)
      end
    end
    return true
  end

  ev:time(entry.time)
  ev:register()
end

for _, entry in ipairs(bosses) do
  createEvent(entry)
end