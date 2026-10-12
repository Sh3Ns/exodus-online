local combat0_Brush = createCombatObject()
setCombatParam(combat0_Brush, COMBAT_PARAM_EFFECT, 340)
setCombatParam(combat0_Brush, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
setCombatArea(combat0_Brush,createCombatArea({{3, 0},
{0, 1}}))

local combat1_Brush = createCombatObject()
setCombatParam(combat1_Brush, COMBAT_PARAM_EFFECT, 340)
setCombatParam(combat1_Brush, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
setCombatArea(combat1_Brush,createCombatArea({{0, 2},
{1, 1}}))

local combat2_Brush = createCombatObject()
setCombatParam(combat2_Brush, COMBAT_PARAM_EFFECT, 340)
setCombatParam(combat2_Brush, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
setCombatArea(combat2_Brush,createCombatArea({{1, 0},
{1, 2}}))

local combat3_Brush = createCombatObject()
setCombatParam(combat3_Brush, COMBAT_PARAM_EFFECT, 340)
setCombatParam(combat3_Brush, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
setCombatArea(combat3_Brush,createCombatArea({{1, 1},
{2, 0}}))

local combat4_Brush = createCombatObject()
setCombatParam(combat4_Brush, COMBAT_PARAM_EFFECT, 340)
setCombatParam(combat4_Brush, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
setCombatArea(combat4_Brush,createCombatArea({{2, 1}}))
setCombatFormula(combat4_Brush, COMBAT_FORMULA_SKILL, 0, 0, 0, 0)

local combat4_Brush_2 = createCombatObject()
setCombatParam(combat4_Brush_2, COMBAT_PARAM_EFFECT, 339)
setCombatParam(combat4_Brush_2, COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
setCombatArea(combat4_Brush_2,createCombatArea({{1, 0, 0, 0, 1},
{0, 0, 0, 0, 0},
{0, 0, 2, 0, 0},
{0, 0, 0, 0, 0},
{1, 0, 0, 0, 1}}))

local combat5_Brush_4 = createCombatObject()
setCombatParam(combat5_Brush_4, COMBAT_PARAM_EFFECT, 342)
setCombatParam(combat5_Brush_4, COMBAT_PARAM_TYPE, COMBAT_POISONDAMAGE)
setCombatArea(combat5_Brush_4,createCombatArea({{0, 0, 0, 1, 0, 0, 0},
{0, 0, 1, 0, 1, 0, 0},
{0, 1, 0, 0, 0, 1, 0},
{1, 0, 0, 2, 0, 0, 1},
{0, 1, 0, 0, 0, 1, 0},
{0, 0, 1, 0, 1, 0, 0},
{0, 0, 0, 1, 0, 0, 0}}))

local combat6_Brush_5 = createCombatObject()
setCombatParam(combat6_Brush_5, COMBAT_PARAM_EFFECT, 343)
setCombatParam(combat6_Brush_5, COMBAT_PARAM_TYPE, COMBAT_WATERDAMAGE)
setCombatArea(combat6_Brush_5,createCombatArea({{0, 0, 1, 0, 0},
{0, 1, 0, 1, 0},
{1, 0, 2, 0, 1},
{0, 1, 0, 1, 0},
{0, 0, 1, 0, 0}}))

local combat15_Brush_8 = createCombatObject()
setCombatParam(combat15_Brush_8, COMBAT_PARAM_EFFECT, 384)
setCombatParam(combat15_Brush_8, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
setCombatArea(combat15_Brush_8,createCombatArea({{1, 1, 3, 1, 1}}))

local combat17_Brush_8 = createCombatObject()
setCombatParam(combat17_Brush_8, COMBAT_PARAM_EFFECT, 384)
setCombatParam(combat17_Brush_8, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
setCombatArea(combat17_Brush_8,createCombatArea({{1, 1, 1},
{0, 2, 0},
{1, 1, 1}}))

local combat19_Brush_8 = createCombatObject()
setCombatParam(combat19_Brush_8, COMBAT_PARAM_EFFECT, 384)
setCombatParam(combat19_Brush_8, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
setCombatArea(combat19_Brush_8,createCombatArea({{1},
{0},
{2},
{0},
{1}}))

setCombatFormula(combat0_Brush, COMBAT_FORMULA_DAMAGE, -2300, 0, -4000, 0)
setCombatFormula(combat1_Brush, COMBAT_FORMULA_DAMAGE, -2300, 0, -4000, 0)
setCombatFormula(combat2_Brush, COMBAT_FORMULA_DAMAGE, -2300, 0, -4000, 0)
setCombatFormula(combat3_Brush, COMBAT_FORMULA_DAMAGE, -2300, 0, -4000, 0)
setCombatFormula(combat4_Brush, COMBAT_FORMULA_DAMAGE, -2300, 0, -4000, 0)
setCombatFormula(combat4_Brush_2, COMBAT_FORMULA_DAMAGE, -2300, 0, -4000, 0)
setCombatFormula(combat5_Brush_4, COMBAT_FORMULA_DAMAGE, -2300, 0, -4000, 0)
setCombatFormula(combat6_Brush_5, COMBAT_FORMULA_DAMAGE, -2300, 0, -4000, 0)
setCombatFormula(combat15_Brush_8, COMBAT_FORMULA_DAMAGE, -2300, 0, -4000, 0)
setCombatFormula(combat17_Brush_8, COMBAT_FORMULA_DAMAGE, -2300, 0, -4000, 0)
setCombatFormula(combat19_Brush_8, COMBAT_FORMULA_DAMAGE, -2300, 0, -4000, 0)

local function RunPart(c,cid,var,dirList,dirEmitPos) 
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

local spell = Spell("instant")

function spell.onCastSpell(creature, var)

        local cid = creature:getId()
		RunPart(combat0_Brush,cid,var)
		addEvent(RunPart,100,combat1_Brush,cid,var)
		addEvent(RunPart,200,combat2_Brush,cid,var)
		addEvent(RunPart,300,combat3_Brush,cid,var)
		addEvent(RunPart,400,combat4_Brush,cid,var)
		addEvent(RunPart,400,combat4_Brush_2,cid,var)
		addEvent(RunPart,500,combat5_Brush_4,cid,var)
		addEvent(RunPart,600,combat6_Brush_5,cid,var)
		addEvent(RunPart,1500,combat15_Brush_8,cid,var)
		addEvent(RunPart,1700,combat17_Brush_8,cid,var)
		addEvent(RunPart,1900,combat19_Brush_8,cid,var)


    return true
end

spell:name("kraxxis corruption")
spell:words("###1134")
spell:isAggressive(true)
spell:blockWalls(true)
spell:needLearn(false)
spell:needDirection(true)
spell:register()
