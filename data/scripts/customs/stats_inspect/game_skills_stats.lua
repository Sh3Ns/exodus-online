local StatUpdateOpcode = 219

CHARSTAT_STRENGTH     = 0
CHARSTAT_INTELLIGENCE = 1
CHARSTAT_DEXTERITY    = 2
CHARSTAT_VITALITY     = 3
CHARSTAT_SPIRIT       = 4
CHARSTAT_WISDOM       = 5

CHARSTAT_FIRST = CHARSTAT_STRENGTH
CHARSTAT_LAST  = CHARSTAT_WISDOM


local StatUpdateEvent = CreatureEvent("StatUpdateOpcode")

function StatUpdateEvent.onExtendedOpcode(player, opcode, buffer)
  if opcode == StatUpdateOpcode then
    local stats = {}
    for i = CHARSTAT_FIRST, CHARSTAT_LAST do
      stats[i + 1] = {
        value = player:getCharacterStat(i),
        max = maxValues[i]
      }
    end
    player:sendExtendedOpcode(StatUpdateOpcode, json.encode({stats = stats, absorptions = player:getAbsorptionStats()}))
  end
end

StatUpdateEvent:register()
StatUpdateEvent:type("extendedopcode")


local LoginStatEvent = CreatureEvent("StatUpdateLogin")

function LoginStatEvent.onLogin(player)
  player:registerEvent("StatUpdateOpcode")
  return true
end

LoginStatEvent:register()
LoginStatEvent:type("login")
