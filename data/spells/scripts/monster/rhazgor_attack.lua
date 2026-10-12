local combat1 = createCombatObject()
setCombatParam(combat1, COMBAT_PARAM_EFFECT, CONST_ME_ENERGYAREA)
setCombatParam(combat1, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatArea(combat1,createCombatArea({{2}}))

local combat2 = createCombatObject()
setCombatParam(combat2, COMBAT_PARAM_EFFECT, CONST_ME_TELEPORT)
setCombatParam(combat2, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatArea(combat2,createCombatArea({
{0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0},
{0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0},
{0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0},
{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
{0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0},
{0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0},
{0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0}}))

local combat3 = createCombatObject()
setCombatParam(combat3, COMBAT_PARAM_EFFECT, CONST_ME_ENERGYAREA)
setCombatParam(combat3, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatArea(combat3,createCombatArea({{2}}))

local combat4 = createCombatObject()
setCombatParam(combat4, COMBAT_PARAM_EFFECT, CONST_ME_TELEPORT)
setCombatParam(combat4, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatArea(combat4,createCombatArea({
{1, 0, 0, 0, 1},
{0, 0, 0, 0, 0},
{0, 0, 2, 0, 0},
{0, 0, 0, 0, 0},
{1, 0, 0, 0, 1}}))

local combat7 = createCombatObject()
setCombatParam(combat7, COMBAT_PARAM_EFFECT, CONST_ME_TELEPORT)
setCombatParam(combat7, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatArea(combat7,createCombatArea({
{1, 0, 0, 0, 0, 0, 0, 0, 1},
{0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 2, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0},
{1, 0, 0, 0, 0, 0, 0, 0, 1}}))

local combat6 = createCombatObject()
setCombatParam(combat6, COMBAT_PARAM_EFFECT, CONST_ME_TELEPORT)
setCombatParam(combat6, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatArea(combat6,createCombatArea({
{0, 0, 1, 0, 0, 0, 1, 0, 0},
{0, 1, 0, 0, 0, 0, 0, 1, 0},
{1, 0, 0, 0, 0, 0, 0, 0, 1},
{0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 2, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0},
{1, 0, 0, 0, 0, 0, 0, 0, 1},
{0, 1, 0, 0, 0, 0, 0, 1, 0},
{0, 0, 1, 0, 0, 0, 1, 0, 0}}))

local combat5 = createCombatObject()
setCombatParam(combat5, COMBAT_PARAM_EFFECT, CONST_ME_TELEPORT)
setCombatParam(combat5, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatArea(combat5,createCombatArea({
{1, 0, 1},
{0, 2, 0},
{1, 0, 1}}))

local combat0_Brush = createCombatObject()
setCombatParam(combat0_Brush, COMBAT_PARAM_EFFECT, CONST_ME_TELEPORT)
setCombatParam(combat0_Brush, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatArea(combat0_Brush,createCombatArea({
{0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0},
{0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0},
{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
{0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0},
{0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0}}))


local summons = {
    [1] = {name = "Pyroquill"}
}
local maxsummons = 4

local function combatSpell(c,cid,var,dirList,dirEmitPos)
	if (isCreature(cid)) then
		doCombat(cid, c, var)
		if (dirList ~= nil and dirEmitPos ~= nil) then
			local i = 2;
			while (i < #dirList) do
				doSendDistanceShoot(dirEmitPos,{x=dirEmitPos.x-dirList[i],y=dirEmitPos.y-dirList[i+1],z=dirEmitPos.z},dirList[1])
				i = i + 2
			end		
		end
	end
end

function onCastSpell(creature, var)
	local cid = creature:getId()

	if isCreature(cid) then
		creature:say("Pyroquill let's finish them!", TALKTYPE_MONSTER_SAY)
		creature:setNoMove(true)
	end
	addEvent(function()
	local summoncount = creature:getSummons()
	local creaturePos = creature:getPosition()
	if #summoncount < 4 then
		for i = 1, maxsummons do
			local mid = Game.createMonster(summons[math.random(#summons)].name, Position(creaturePos.x + math.random(-3, 3), creaturePos.y + math.random(-3, 3), creaturePos.z))
    		if not mid then
				return
			end
			mid:setMaster(creature)
		end
	end
	combatSpell(combat0_Brush,cid,var)
	addEvent(combatSpell,300,combat1,cid,var)
	addEvent(combatSpell,300,combat2,cid,var)
	addEvent(combatSpell,600,combat5,cid,var)
	addEvent(combatSpell,900,combat3,cid,var)
	addEvent(combatSpell,900,combat4,cid,var)
	addEvent(combatSpell,1400,combat7,cid,var)
	addEvent(combatSpell,1200,combat6,cid,var)
	addEvent(function()
        if isCreature(cid) then
            creature:setNoMove(false)
        end
    end, 2200)
	end, 2000)
	return true
end