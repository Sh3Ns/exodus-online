GemsSocket = GemsSocket or {}

-- Enable or Disable the system --
GemsSocket.ENABLED = true
GemsSocket.OPCODE = 232
GemsSocket.MAX_SOCKETS = 5
GemsSocket.DEFAULT_SOCKET_COUNT = 1

GemsSocket.PERFORMANCE = {
    -- Use True, to test performance of system, turn false if you put server alive.
    enableMetrics = false,
    -- Restricted creature visibility updates processed per game-thread slice.
    visibilitySyncBatchSize = 75,
    visibilitySyncIntervalMs = 10,
    visibilitySyncNearbyRangeX = 18,
    visibilitySyncNearbyRangeY = 14,
    damageGemFlushDamage = 10000,
    damageGemCriticalFlushDamage = 50000,
    cowardsCrownScanThrottleMs = 500,
}

GemsSocket.REQUIRE_EXTRACTOR = true
GemsSocket.EXTRACTOR_ITEM_ID = 27149

GemsSocket.SOCKET_ADDER_ITEMS = {
    -- Hardcoded a table for the items that can get sockets
    -- [ITEM_ID] = sockets of item 
    -- Why a hardcode table, because is a bit the same as adding a new attribute on the item itself on items.xml and add a new <attribute "socket" value = 1>, instead i added a table, probably better for people that has a running server and their own items.
    -- I added the most important items of the game, low items have no socket added.
    [2195] = 1, -- BOH
    [2342] = 1, -- helmet of the ancients
    [2447] = 1, -- twin axe
    [2469] = 1, -- DSL
    [2470] = 1, -- GL
    [2471] = 2, -- golden helmet
    [2474] = 2, -- winged helmet
    [2477] = 1, -- KL
    [2488] = 1, -- crown legs
    [2493] = 1, -- demon helmet
    [2495] = 1, -- demon legs
    [2498] = 1, -- royal helmet
    [2390] = 1, -- magic longsword
    [2393] = 1, -- giant sword
    [2400] = 1, -- magic sword
    [2408] = 1, -- warlord sword
    [2414] = 1, -- dragon lance
    [2415] = 1, -- great axe
    [2421] = 1, -- thunder hammer
    [2427] = 1, -- guardian halberd
    [2431] = 1, -- stonecutter axe
    [2443] = 1, -- ravager's axe
    [2444] = 1, -- hammer of wrath
    [2452] = 1, -- heavy mace
    [2453] = 1, -- arcane staff
    [2454] = 1, -- war axe
    [2466] = 1, -- golden armor
    [2472] = 1, -- mpa
    [2476] = 1, -- knight armor
    [2487] = 1, -- crown armor
    [2492] = 1, -- dsm
    [2494] = 1, -- demon armor
    [2500] = 1, -- amazon armor
    [2503] = 1, -- dwarven armor
    [2505] = 1, -- elven mail
    [2506] = 1, -- rsh 
    [2514] = 1, -- mastermind shield
    [2519] = 1, -- crown shield
    [2522] = 1, -- Great shield
    [2523] = 2, -- blessed shield
    [2536] = 1, -- medusa shield
    [2537] = 1, -- amazon shield
    [2542] = 1, -- tempest shield
    [2645] = 1, -- steel boots
    [2646] = 1, -- golden boots
    [2656] = 1, -- blue robe
    [5741] = 1, -- skull helmet
    [5803] = 1, -- arbalest
    [6391] = 1, -- nightmare shield
    [6433] = 1, -- necromancer shield
    [6528] = 1, -- the avenger
    [6553] = 1, -- ruthless axe
    [7382] = 1, -- demonrage sword
    [7384] = 1, -- mystic blade
    [7388] = 1, -- vile axe
    [7389] = 1, -- heroic axe
    [7390] = 1, -- the justice seeker
    [7402] = 1, -- dragon slayer
    [7403] = 1, -- berserker
    [7405] = 1, -- havoc blade
    [7410] = 1, -- queen's sceptre
    [7414] = 1, -- abyss hammer
    [7415] = 1, -- cranial basher
    [7416] = 1, -- bloody edge
    [7417] = 1, -- runed sword
    [7418] = 1, -- nightmare blade
    [7420] = 1, -- reaper's axe
    [7421] = 1, -- onyx flail
    [7422] = 1, -- jade hammer
    [7423] = 1, -- skullcrusher
    [7428] = 1, -- bonebreaker
    [7429] = 1, -- blessed sceptre
    [7431] = 1, -- demonbone
    [7433] = 1, -- ravenwing
    [7434] = 1, -- royal axe
    [7435] = 1, -- impaler
    [7450] = 1, -- hammer of prophecy
    [7453] = 1, -- executioner
    [7455] = 1, -- mythril axe
    [7884] = 1, -- terra mantle
    [7887] = 1, -- terra amulet
    [7888] = 1, -- glacier amulet
    [7889] = 1, -- lightning pendant
    [7890] = 1, -- magma amulet
    [7897] = 1, -- glacier robe
    [7898] = 1, -- lightning robe
    [7899] = 1, -- magma coat
    [8850] = 1, -- chain bolter
    [8851] = 1, -- royal crossbow
    [8852] = 1, -- the devileye
    [8853] = 1, -- the ironworker
    [8854] = 1, -- warsinger bow
    [8856] = 1, -- Yol's bow
    [8858] = 1, -- Elethriel's elemental bow
    [8865] = 1, -- dark lord's cape
    [8866] = 1, -- robe of the ice queen
    [8867] = 1, -- dragon robe
    [8868] = 1, -- velvet mantle
    [8869] = 1, -- greenwood coat
    [8877] = 1, -- lavos armor
    [8878] = 1, -- crystalline armor
    [8879] = 1, -- voltage armor
    [8880] = 1, -- swamplair armor
    [8881] = 1, -- fireborn giant armor
    [8882] = 1, -- earthborn titan armor
    [8883] = 1, -- windborn colossus armor
    [8884] = 1, -- oceanborn leviathan armor
    [8885] = 1, -- divine plate
    [8886] = 1, -- molten plate
    [8887] = 1, -- frozen plate
    [8888] = 1, -- master archer's armor
    [8889] = 1, -- skullcracker armor
    [8890] = 1, -- robe of the underworld
    [8891] = 1, -- paladin armor
    [8903] = 1, -- spellbook of lost souls
    [8904] = 1, -- spellscroll of prophecies
    [8905] = 1, -- rainbow shield
    [8906] = 1, -- fiery rainbow shield
    [8907] = 1, -- icy rainbow shield
    [8908] = 1, -- sparking rainbow shield
    [8909] = 1, -- terran rainbow shield
    [8918] = 1, -- spellbook of dark mysteries
    [8924] = 1, -- hellforged axe
    [8925] = 1, -- solar axe
    [8926] = 1, -- demonwing axe
    [8927] = 1, -- dark trinity mace
    [8928] = 1, -- obsidian truncheon
    [8929] = 1, -- the stomper
    [8930] = 1, -- emerald sword
    [8931] = 1, -- the epiphany
    [8932] = 1, -- the calamity
    [9776] = 1, -- yalahari armor
    [9777] = 1, -- yalahari leg piece
    [9778] = 1, -- yalahari mask
    [10218] = 1, -- bonfire amulet
    [10219] = 1, -- sacred tree amulet
    [10220] = 1, -- leviathan's amulet
    [10221] = 1, -- shockwave amulet
    [11117] = 1, -- crystal boots
    [11118] = 1, -- dragon scale boots
    [11240] = 1, -- guardian boots
    [11301] = 1, -- zaoan armor
    [11302] = 1, -- zaoan helmet
    [11304] = 1, -- zaoan legs
    [11305] = 1, -- drakinata
    [11307] = 1, -- Zaoan sword
    [11308] = 1, -- drachaku
    [11355] = 1, -- spellweaver's robe
    [11356] = 1, -- Zaoan robe
    [11368] = 1, -- jade hat
    [12607] = 1, -- elite draken mail
    [12613] = 1, -- twiceslicer
    [12642] = 1, -- royal draken mail
    [12643] = 1, -- royal scale robe
    [12644] = 1, -- shield of corruption
    [12645] = 1, -- elite draken helmet
    [12646] = 1, -- draken boots
    [12647] = 1, -- snake god's wristguard
    [12648] = 1, -- snake god's sceptre
    [12649] = 1, -- blade of corruption
    [15403] = 1, -- necklace of the deep
    [15404] = 1, -- deepling axe
    [15406] = 2, -- ornate chestplate
    [15407] = 2, -- depth lorica
    [15408] = 2, -- depth galea
    [15409] = 1, -- depth ocrea
    [15410] = 2, -- depth calcei
    [15411] = 1, -- depth scutum
    [15412] = 2, -- ornate legs
    [15413] = 1, -- ornate shield
    [15414] = 1, -- ornate mace
    [15489] = 1, -- calopteryx cape
    [15490] = 1, -- grasshopper legs
    [15492] = 1, -- hive scythe
    [15643] = 1, -- hive bow
    [16111] = 2, -- thorn spitter
    [16112] = 2, -- spellbook of ancient arcana
    [18398] = 2, -- gill gugel
    [18399] = 2, -- gill coat
    [18400] = 2, -- gill legs
    [18401] = 1, -- spellbook of vigilance
    [18402] = 2, -- gill necklace
    [18403] = 2, -- prismatic helmet
    [18404] = 1, -- prismatic armor
    [18405] = 2, -- prismatic legs
    [18406] = 2, -- prismatic boots
    [18407] = 2, -- prismatic necklace
    [18408] = 1, -- prismatic ring
    [18409] = 1, -- wand of everblazing
    [18410] = 2, -- prismatic shield
    [18411] = 1, -- muck rod
    [18412] = 3, -- glacial rod
    [18450] = 1, -- crystalline sword
    [18453] = 1, -- crystal crossbow
    [18454] = 1, -- mycological bow
    [18528] = 1, -- prismatic ring
    [20108] = 1, -- pair of iron fists
    [21690] = 1, -- triple bolt crossbow
    [21691] = 2, -- shrunken head necklace
    [21725] = 1, -- furious frock
    [22398] = 1, -- crude umbral blade
    [22399] = 1, -- umbral blade
    [22400] = 3, -- umbral masterblade
    [22401] = 1, -- crude umbral slayer
    [22402] = 1, -- umbral slayer
    [22403] = 3, -- umbral master slayer
    [22404] = 1, -- crude umbral axe
    [22405] = 1, -- umbral axe
    [22406] = 3, -- umbral master axe
    [22407] = 1, -- crude umbral chopper
    [22408] = 1, -- umbral chopper
    [22409] = 3, -- umbral master chopper
    [22410] = 1, -- crude umbral mace
    [22411] = 1, -- umbral mace
    [22412] = 3, -- umbral master mace
    [22413] = 1, -- crude umbral hammer
    [22414] = 1, -- umbral hammer
    [22415] = 3, -- umbral master hammer
    [22416] = 1, -- crude umbral bow
    [22417] = 2, -- umbral bow
    [22418] = 3, -- umbral master bow
    [22419] = 1, -- crude umbral crossbow
    [22420] = 2, -- umbral crossbow
    [22421] = 3, -- umbral master crossbow
    [22422] = 1, -- crude umbral spellbook
    [22423] = 1, -- umbral spellbook
    [22424] = 3, -- umbral master spellbook
    [22516] = 2, -- ring of ending
    [23529] = 1, -- glooth spear
    [23536] = 1, -- rubber cap
    [23539] = 1, -- alloy legs
    [23541] = 1, -- gearwheel chain
    [23554] = 1, -- glooth amulet
    [24261] = 1, -- crest of the deep seas
    [24637] = 1, -- oriental shoes
    [24742] = 1, -- badger boots
    [24851] = 1, -- onyx pendant
    [25174] = 2, -- fireheart cuirass
    [25175] = 2, -- fireheart hauberk
    [25176] = 2, -- fireheart platemail
    [25180] = 2, -- thunderheart cuirass
    [25181] = 2, -- thunderheart hauberk
    [25182] = 2, -- thunderheart platemail
    [25183] = 2, -- frostheart cuirass
    [25184] = 2, -- frostheart hauberk
    [25185] = 2, -- frostheart platemail
    [25186] = 2, -- firesoul tabard
    [25188] = 2, -- thundersoul tabard
    [25189] = 2, -- frostsoul tabard
    [25190] = 2, -- firemind raiment
    [25192] = 2, -- thundermind raiment
    [25193] = 2, -- frostmind raiment
    [25383] = 1, -- rift lance
    [25410] = 1, -- V.O.T.E.D (visage of the end days)
    [25411] = 2, -- book of lies
    [25413] = 2, -- shroud of despair
    [25414] = 2, -- death gaze
    [25415] = 2, -- plague bite
    [25416] = 2, -- impaler of the igniter
    [25418] = 2, -- maimer
    [25429] = 1, -- boots of homecoming
    [25522] = 1, -- rift bow
    [25523] = 1, -- rift crossbow
    [26132] = 2, -- void boots
    [26803] = 1, -- gnome armor
    [26804] = 1, -- gnome legs
    [26805] = 1, -- gnome shield
    [26809] = 2, -- swan feather cloak
    [27193] = 2, -- deepling ceremonial dagger
    [27194] = 2, -- deepling fork
    [27195] = 3, -- falcon circlet
    [27196] = 3, -- falcon coif
    [27197] = 3, -- falcon rod
    [27198] = 3, -- falcon wand
    [27199] = 3, -- falcon bow
    [27200] = 3, -- falcon plate
    [27201] = 3, -- falcon greaves
    [27202] = 3, -- falcon shield
    [27203] = 3, -- falcon escutcheon
    [27204] = 3, -- falcon longsword
    [27205] = 3, -- falcon battleaxe
    [27206] = 3, -- falcon mace
    [27208] = 3, -- cobra wand
    [27209] = 3, -- cobra rod
    [27210] = 3, -- cobra club
    [27211] = 2, -- cobra boots
    [27212] = 3, -- cobra crossbow
    [27213] = 3, -- cobra hood
    [27214] = 3, -- cobra sword
    [27215] = 3, -- cobra amulet
    [27216] = 3, -- cobra axe
    [27218] = 1, -- leaf star
    [27219] = 1, -- royal star
    [27226] = 2, -- bear skin
    [27227] = 2, -- terra helmet
    [27228] = 2, -- embrace of nature
    [27229] = 2, -- mortal mace
    [27230] = 2, -- bow of cataclysm
    [27231] = 2, -- galea mortis
    [27232] = 2, -- toga mortis
    [27249] = 2, -- winged boots
    [27251] = 2, -- rainbow necklace
    [27269] = 3, -- tagralt blade
    [27285] = 2, -- phantasmal axe
    [27286] = 2, -- fabulous legs
    [27287] = 2, -- soulful legs
    [27288] = 1, -- pair of nightmare boots
    [27295] = 2, -- ghost chestplate
    [27377] = 3, -- soulcutter
    [27378] = 3, -- soulshredder
    [27379] = 3, -- soulbiter
    [27380] = 3, -- souleater
    [27381] = 3, -- soulcrusher
    [27382] = 3, -- soulmaimer
    [27383] = 3, -- soulbleeder
    [27384] = 3, -- soulpiercer
    [27385] = 3, -- soultainter
    [27386] = 3, -- soulhexer
    [27387] = 3, -- soulshanks
    [27388] = 3, -- soulstrider
    [27389] = 3, -- soulshell
    [27390] = 3, -- soulmantle
    [27391] = 3, -- soulshroud
    [27392] = 3, -- pair of soulwalkers
    [27393] = 3, -- pair of soulstalkers
    [27394] = 3, -- soulbastion
    [27395] = 3, -- lion longbow
    [27396] = 3, -- lion rod
    [27397] = 3, -- lion wand
    [27398] = 2, -- lion spellbook
    [27399] = 3, -- lion shield
    [27400] = 3, -- lion longsword
    [27401] = 2, -- lion spangenhelm
    [27402] = 3, -- lion plate
    [27403] = 2, -- lion amulet
    [27404] = 3, -- lion axe
    [27405] = 3, -- lion hammer
    [27458] = 3, -- sanguine blade
    [27459] = 3, -- grand sanguine blade
    [27460] = 3, -- sanguine cudgel
    [27461] = 3, -- grand sanguine cudgel
    [27462] = 3, -- sanguine hatchet
    [27463] = 3, -- grand sanguine hatchet
    [27464] = 3, -- sanguine razor
    [27465] = 3, -- grand sanguine razor
    [27466] = 3, -- sanguine bludgeon
    [27467] = 3, -- grand sanguine bludgeon
    [27468] = 3, -- sanguine battleaxe
    [27469] = 3, -- grand sanguine battleaxe
    [27470] = 3, -- sanguine legs
    [27471] = 3, -- sanguine bow
    [27472] = 3, -- grand sanguine bow
    [27473] = 3, -- sanguine crossbow
    [27474] = 3, -- grand sanguine crossbow
    [27475] = 3, -- sanguine greaves
    [27476] = 3, -- sanguine coil
    [27477] = 3, -- grand sanguine coil
    [27478] = 3, -- sanguine boots
    [27479] = 3, -- sanguine rod
    [27480] = 3, -- grand sanguine rod
    [27481] = 3, -- sanguine galoshes
    [27642] = 2, -- jungle flail
    [27643] = 2, -- throwing axe
    [27644] = 1, -- exotic legs
    [27645] = 2, -- bast legs
    [27646] = 2, -- jungle bow
    [27647] = 2, -- makeshift boots
    [27648] = 2, -- make-do boots
    [27649] = 2, -- jungle rod
    [27650] = 2, -- jungle wand
    [27652] = 2, -- exotic amulet
    [27653] = 3, -- eldritch shield
    [27654] = 3, -- eldritch claymore
    [27655] = 3, -- gilded eldritch claymore
    [27656] = 3, -- eldritch warmace
    [27657] = 3, -- gilded eldritch warmace
    [27658] = 3, -- eldritch greataxe
    [27659] = 3, -- gilded eldritch greataxe
    [27660] = 3, -- eldritch cuirass
    [27661] = 3, -- eldritch bow
    [27662] = 3, -- gilded eldritch bow
    [27664] = 3, -- eldritch breeches
    [27665] = 3, -- eldritch wand
    [27666] = 3, -- gilded eldritch wand
    [27667] = 2, -- eldritch cowl
    [27668] = 2, -- eldritch hood
    [27669] = 3, -- eldritch folio
    [27670] = 3, -- eldritch tome
    [27671] = 3, -- eldritch rod
    [27672] = 3, -- gilded eldritch rod
    [27673] = 3, -- spiritthorn armor
    [27674] = 3, -- spiritthorn helmet
    [27675] = 3, -- alicorn headguard
    [27677] = 3, -- arcanomancer regalia
    [27678] = 3, -- Arcanomancer Folio
    [27679] = 3, -- Arboreal Crown
    [27680] = 3, -- Arboreal Tome
    [27681] = 3, -- Naga Sword
    [27682] = 3, -- Naga Axe
    [27683] = 3, -- Naga Club
    [27684] = 3, -- Frostflower boots
    [27685] = 3, -- Naga crossbow
    [27687] = 3, -- feverbloom boots
    [27688] = 3, -- naga wand
    [27689] = 3, -- naga rod
    [27690] = 3, -- dawnfire sherwani
    [27691] = 3, -- midnight tunic
    [27692] = 3, -- dawnfire pantaloons
    [27693] = 3, -- midnight sarong
    [28018] = 3, -- Astro Helmet
    [28019] = 3, -- Astro Armor
    [28020] = 3, -- Astro Legs
    [28021] = 3, -- Astro Boots
    [28022] = 3, -- Astro Amulet
    [28023] = 3, -- Astro Ring
    [28024] = 3, -- Astro Shield
    [28025] = 3, -- Astro Axe
    [28026] = 3, -- Astro Blade
    [28027] = 3, -- Astro Mace
    [28035] = 3, -- Arodis Helmet
    [28036] = 3, -- Arodis Robe
    [28037] = 3, -- Arodis Pants
    [28038] = 3, -- Arodis Galoshes
    [28039] = 3, -- Arodis Spellbook
    [28040] = 3, -- Arodis Amulet
    [28041] = 3, -- Arodis Ring
    [28042] = 3, -- Arodis Wand
    [28044] = 3, -- Mercurial Helmet
    [28045] = 3, -- Mercurial Tabard
    [28046] = 3, -- Mercurial Greaves
    [28047] = 3, -- Mercurial Boots
    [28048] = 3, -- Mercurial Necklace
    [28049] = 3, -- Mercurial Ring
    [28051] = 3, -- Mercurial Piercer
    [28052] = 3, -- Mercurial Bleeder
    [28098] = 3, -- embersage helmet
    [28099] = 3, -- embersage armor
    [28100] = 3, -- embersage legs
    [28101] = 3, -- embersage boots
    [28102] = 3, -- embersage sword
    [28103] = 3, -- embersage axe
    [28104] = 3, -- embersage club
    [28105] = 3, -- embersage shield
    [28106] = 3, -- vigils helmet
    [28107] = 3, -- vigils armor
    [28108] = 3, -- vigils legs
    [28109] = 3, -- vigils boots
    [28110] = 3, -- vigils wand
    [28111] = 3, -- vigils spellbook
    [28112] = 3, -- shadewalker helmet
    [28113] = 3, -- shadewalker armor
    [28114] = 3, -- shadewalker legs
    [28115] = 3, -- shadewalker boots
    [28116] = 3, -- shadewalker bow
    [28125] = 3, -- forbidden ring
    [28126] = 3, -- forbidden pendant
    [28128] = 3, -- amber slayer
    [28129] = 3, -- amber greataxe
    [28130] = 3, -- amber bludgeon
    [28131] = 3, -- amber bow
    [28132] = 3, -- amber wand
    [28133] = 3, -- amber rod
    [28134] = 3, -- amber sabre
    [28135] = 3, -- amber axe
    [28136] = 3, -- amber cudgel
    [28137] = 3, -- amber crossbow
    [28373] = 3, -- Moist Sword
    [28374] = 3, -- Moist Axe
    [28375] = 3, -- Moist Hammer
    [28376] = 3, -- Moist Wand
    [28377] = 3, -- Moist Bow
    [28378] = 3, -- Moist Crossbow
    [28380] = 3, -- Moist Spellbook
    [28381] = 3, -- Moist Shield
    [28382] = 3, -- Moist Helmet
    [28383] = 3, -- Moist Armor
    [28384] = 3, -- Moist Legs
    [28385] = 3, -- Moist Boots
    [28386] = 3, -- Moist Hood
    [28387] = 3, -- Moist Robe
    [28388] = 3, -- Moist Pants
    [28389] = 3, -- Moist Shoes
    [28390] = 3, -- Moist Coiff
    [28391] = 3, -- Moist Vestment
    [28392] = 3, -- Moist Breeches
    [28393] = 3, -- Moist Greaves
    [28688] = 2, -- Cocoa Grimoire
    [28689] = 2, -- Creamy Grimoire
    [28690] = 2, -- Candy necklace
    [28691] = 1, -- ring of temptation
    [28692] = 2, -- biscuit barrier
    [28706] = 2, -- Candy Helmet
    [28707] = 2, -- Candy Armor
    [28708] = 2, -- Candy Legs
    [28709] = 2, -- Pastry Helmet
    [28710] = 2, -- Pastry Robe
    [28711] = 2, -- Pastry Pants
    [28712] = 2, -- Candy Axe
    [28713] = 2, -- Candy Bow
    [28714] = 2, -- Candy Mace
    [28715] = 2, -- Candy Crossbow
    [28716] = 2, -- Candy Sword
    [28717] = 2, -- Candy Wand
    [29469] = 2, -- maliceforged helmet
    [29470] = 2, -- hellstalker visor
    [29471] = 3, -- dreadfire headpiece
    [29472] = 3, -- demonfang mask
    [29477] = 3, -- water inferniarch bow
    [29478] = 3, -- arcane inferniarch bow
    [29479] = 3, -- water inferniarch arbalest
    [29480] = 3, -- arcane inferniarch arbalest
    [29481] = 3, -- water inferniarch battleaxe
    [29482] = 3, -- arcane inferniarch battleaxe
    [29483] = 3, -- water inferniarch mace
    [29484] = 3, -- arcane inferniarch mace
    [29485] = 3, -- water inferniarch blade
    [29486] = 3, -- arcane inferniarch blade
    [29487] = 3, -- water inferniarch wand
    [29488] = 3, -- arcane inferniarch wand
    [29489] = 3, -- water inferniarch rod
    [29490] = 3, -- arcane inferniarch rod
    [29556] = 3, -- Deathlord Cleaver
    [29557] = 3, -- Deathlord Mace
    [29558] = 3, -- Deathlord Blade
    [29559] = 3, -- Deathlord Shield
    [29560] = 3, -- Deathlord Headguard
    [29561] = 3, -- Deathlord Cuirass
    [29562] = 3, -- Deathlord Greaves
    [29563] = 3, -- Deathlord Walkers
    [29564] = 3, -- Haloed Bolter
    [29565] = 3, -- Haloed Bow
    [29567] = 3, -- Haloed Coif
    [29568] = 3, -- Haloed Tabard
    [29569] = 3, -- Haloed Legs
    [29570] = 3, -- Haloed Shoes
    [29571] = 3, -- Soulbinder Wand
    [29572] = 3, -- Soulbinder Tome
    [29573] = 3, -- Soulbinder Mask
    [29574] = 3, -- Soulbinder Mantle
    [29575] = 3, -- Soulbinder Kilt
    [29576] = 3, -- Soulbinder Sandals
    [29577] = 2, -- Shadowwoven Gloves
    [29578] = 2, -- Shadowwoven Belt
    [29582] = 2, -- Tidewoven Gloves
    [29583] = 2, -- Verdantbound Gloves
    [29584] = 2, -- Infernal Grip
    [29586] = 2, -- Radiant Handwraps
    [29587] = 2, -- Eclipsed Guantlets
    [29588] = 2, -- Graveclasp Gloves
    [29589] = 2, -- Frostbind Mitts
    [29590] = 2, -- Tenebral Fists
    [29591] = 2, -- Tidewoven Belt
    [29592] = 2, -- Verdantbound Gridle
    [29593] = 2, -- Infernal Cinch
    [29594] = 2, -- Radiant Sash
    [29595] = 2, -- Eclipsed Waistguard
    [29596] = 2, -- Graveclasp Belt
    [29597] = 2, -- Frostbind Waistwrap
    [29598] = 2, -- Tenebral Cincture
    [29861] = 4, -- Myst Regalia Helmet
    [29862] = 4, -- Myst Regalia Mantle
    [29863] = 4, -- Myst Regalia Legs
    [29864] = 4, -- Myst Regalia Galoshes
    [29865] = 4, -- Myst Regalia Spellbook
    [29866] = 4, -- Myst Regalia Wand
    [29867] = 3, -- Myst Regalia Amulet
    [29868] = 2, -- Myst Regalia Ring
    [29869] = 4, -- Seraphic Helmet
    [29870] = 4, -- Seraphic Tabard
    [29871] = 4, -- Seraphic Greaves
    [29872] = 4, -- Seraphic Boots
    [29874] = 4, -- Seraphic Bleeder
    [29875] = 4, -- Seraphic Piercer
    [29876] = 3, -- Seraphic Necklace
    [29877] = 2, -- Seraphic Ring
    [29878] = 4, -- Dawnforged Helmet
    [29879] = 4, -- Dawnforged Plate
    [29880] = 4, -- Dawnforged Legs
    [29881] = 4, -- Dawnforged Boots
    [29882] = 4, -- Dawnforged Shield
    [29883] = 4, -- Dawnforged Blade
    [29884] = 4, -- Dawnforged Longsword
    [29885] = 4, -- Dawnforged Chopper
    [29886] = 4, -- Dawnforged Great Axe
    [29887] = 4, -- Dawnforged Mace
    [29888] = 4, -- Dawnforged Skull Crusher
    [29889] = 3, -- Dawnforged Amulet
    [29890] = 2, -- Dawnforged Ring
    [29914] = 4, -- Myst Regalia Belt
    [29915] = 4, -- Seraphic Belt
    [29916] = 4, -- Dawnforged Belt
    [29917] = 2, -- Myst Regalia Gloves
    [29918] = 2, -- Seraphic Gloves
    [29919] = 2, -- Dawnforged Gloves
    [29934] = 1, -- Sai
    [29935] = 1, -- Crude Umbral Katar
    [29936] = 1, -- Depth Claws
    [29937] = 2, -- Bambus Jo
    [29938] = 2, -- Nunchaku of Destruction
    [29939] = 3, -- Umbral Master Katar
    [29940] = 3, -- Cobra Bo
    [29941] = 3, -- Eldritch Crescent Moon Spade
    [29942] = 3, -- Gilded Eldritch Crescent Moon Spade
    [29943] = 3, -- Lion Claws
    [29944] = 3, -- Arcane Inferniarch Claws
    [29945] = 3, -- Water Inferniarch Claws
    [29946] = 3, -- Falcon Sai
    [29947] = 3, -- Naga Katar
    [29948] = 3, -- Amber Kusarigama
    [29949] = 3, -- Soulkamas
    [29950] = 4, -- Sanguine Claws
    [29951] = 4, -- Grand Sanguine Claws
    [29952] = 3, -- Embersage Sai
    [29953] = 3, -- Astro Katar
    [29954] = 3, -- Amber Claw
    [29955] = 3, -- Deathlord Reaper
    [29956] = 1, -- Sai of Enlightenment
    [29957] = 1, -- Umbral Katar
    [29970] = 1, -- Coned Hat of Enlightenment
    [29971] = 2, -- Dark Vision Bandana
    [29972] = 3, -- Demon Mengu
    [29973] = 3, -- Ethereal Coned Hat
    [29974] = 1, -- Jade Conical Hat
    [29976] = 2, -- Death Oyoroi
    [29977] = 2, -- Energy Robe
    [29978] = 1, -- Ghazbaran Oyoroi
    [29979] = 2, -- Gnomish Cuirass
    [29980] = 2, -- Ice Robe
    [29981] = 2, -- Leaf Robe
    [29982] = 2, -- Magma Robe
    [29983] = 3, -- Merudri Battle Mail
    [29984] = 1, -- Merudri Nanbando
    [29985] = 1, -- Merudri Scale Mail
    [29987] = 3, -- Naga Tanko
    [29989] = 2, -- Robe of Enlightenment
    [29990] = 3, -- Soulgarb
    [29991] = 1, -- Spirit Bind
    [29992] = 3, -- Stoic Iks Robe
    [29994] = 2, -- Jade Legs
    [29995] = 1, -- Jungle Survivor Legs
    [29997] = 1, -- Legs of Wisdom
    [29998] = 3, -- Mutant Hide Trousers
    [29999] = 4, -- Sanguine Trousers
    [30001] = 3, -- Eldritch Monk Boots
    [30002] = 2, -- Gnomish Footwraps
    [30003] = 3, -- Iks Footwraps
    [30004] = 3, -- Soulsoles
    [30005] = 1, -- Yalahari Footwraps
    [30006] = 3, -- Charged Ethereal Ring
    [30007] = 3, -- Ethereal Ring
    [30008] = 1, -- ring of orange plasma
    [30009] = 1, -- ring of orange plasma
    [30010] = 2, -- collar of orange plasma
    [30011] = 2, -- collar of orange plasma
    [30012] = 2, -- enchanted merudri brooch
    [30014] = 3, -- Stoic Iks Casque
    [30015] = 3, -- Stoic Iks Headpiece
    [30016] = 3, -- Arcane Dragon Robe
    [30017] = 3, -- Dauntless Dragon Scale Armor
    [30018] = 3, -- Mystical Dragon Robe
    [30019] = 3, -- Stoic Iks Chestplate
    [30020] = 3, -- Stoic Iks Cuirass
    [30021] = 3, -- Unerring Dragon Scale Armor
    [30022] = 3, -- Stoic Iks Culet
    [30023] = 3, -- Stoic Iks Faulds
    [30024] = 3, -- stoic iks boots
    [30025] = 3, -- stoic iks sandals
    [30035] = 4, -- Molten Helmet
    [30036] = 4, -- Molten Shroud
    [30037] = 4, -- Molten Pants
    [30038] = 4, -- Molten Stalkers
    [30039] = 4, -- Molten Reaper
    [30040] = 2, -- blade of destruction
    [30041] = 2, -- slayer of destruction
    [30042] = 2, -- axe of destruction
    [30043] = 2, -- chopper of destruction
    [30044] = 2, -- mace of destruction
    [30045] = 2, -- hammer of destruction
    [30046] = 2, -- bow of destruction
    [30047] = 2, -- crossbow of destruction
    [30048] = 2, -- wand of destruction
    [30049] = 2, -- rod of destruction
    [30050] = 2, -- Molten Belt
    [30051] = 2, -- Molten Gloves
    [30052] = 2, -- Molten Ring
    [30053] = 3, -- Molten Amulet
    [30110] = 3, -- norcferatu skullguard
    [30111] = 2, -- norcferatu bonehood
    [30112] = 3, -- norcferatu tuskplate
    [30113] = 3, -- norcferatu bloodhide
    [30114] = 3, -- norcferatu bonecloak
    [30115] = 3, -- norcferatu thornwraps
    [30116] = 3, -- norcferatu bloodstrider
    [30117] = 2, -- norcferatu fleshguards
    [30118] = 3, -- norcferatu goretrampers
    [30119] = 3, -- norcferatu fangstompers
    [30121] = 3, -- stag helmet
    [30122] = 3, -- stag robe
    [30123] = 3, -- stag plate
    [30124] = 3, -- stag legs
    [30125] = 3, -- stag shinguards
    [30126] = 3, -- stag boots
    [30127] = 3, -- stag footwraps
    [30128] = 3, -- stag spellbook
    [30129] = 3, -- stag scrolls
    [30130] = 3, -- stag shield
    [30131] = 3, -- crypt spine
    [30132] = 3, -- crypt splitter
    [30133] = 3, -- crypt breaker
    [30134] = 3, -- crypt strike
    [30135] = 3, -- crypt bile
    [30136] = 3, -- crypt jaw
    [30137] = 3, -- crypt slicer
    [30589] = 4, -- astral disciple mask
    [30590] = 4, -- astral disciple mantle
    [30591] = 4, -- astral disciple legs
    [30592] = 4, -- astral disciple boots
    [30593] = 4, -- astral disciple dagger
    [30594] = 4, -- silent lotus hood
    [30595] = 4, -- silent lotus armor
    [30596] = 4, -- silent lotus greaves
    [30597] = 4, -- silent lotus boots
    [30599] = 4, -- silent lotus bow
    [30600] = 4, -- silent lotus crossbow
    [30601] = 4, -- twilight helm
    [30603] = 4, -- twilight greaves
    [30604] = 4, -- twilight boots
    [30605] = 4, -- twilight hellrender
    [30606] = 4, -- twilight maul
    [30607] = 4, -- twilight wrathblade
    [30608] = 4, -- twilight shield
    [30609] = 4, -- phantom hat
    [30610] = 4, -- phantom mantle
    [30611] = 4, -- phantom legs
    [30612] = 4, -- phantom boots
    [30613] = 4, -- phantom wand
    [30614] = 4, -- phantom tome
    [30926] = 4, -- moonsilver epee
    [30927] = 4, -- stellar moonsilver epee
    [30928] = 4, -- moonsilver claymore
    [30929] = 4, -- stellar moonsilver claymore
    [30930] = 4, -- moonsilver axe
    [30931] = 4, -- stellar moonsilver axe
    [30932] = 4, -- moonsilver chopper
    [30933] = 4, -- stellar moonsilver chopper
    [30934] = 4, -- moonsilvr crusher
    [30935] = 4, -- stellar moonsilver crusher
    [30936] = 4, -- moonsilver mace
    [30937] = 4, -- stellar moonsilver mace
    [30938] = 4, -- moonsilver channeler
    [30939] = 4, -- stellar moonsilver channeler
    [30940] = 4, -- moonsilver sceptre
    [30941] = 4, -- stellar moonsilver sceptre
    [30942] = 4, -- moonsilver katar
    [30943] = 4, -- stellar moonsilver katar
    [30944] = 4, -- moonsilver bow
    [30945] = 4, -- stellar moonsilver bow
    [30946] = 4, -- moonsilver crossbow
    [30947] = 4, -- stellar moonsilver crossbow
    [30948] = 4, -- moonsilver battle visor
    [30949] = 4, -- moonsilver trail hood
    [30950] = 4, -- moonsilver nimbus hat
    [30951] = 4, -- moonsilver spirit mask
    [30952] = 4, -- moonsilver strike helm
}

GemsSocket.ESSENCE = {
    outputItemId = 30658,
    levelPower = {
        [1] = 5,
        [2] = 13,
        [3] = 25,
        [4] = 50,
        [5] = 75,
        [6] = 100
    }
}

GemsSocket.SPECIALS = {
    riftstep = {
        riftRadius = 3,
        teleportEffect = CONST_ME_TELEPORT,
        riftSpawnEffect = CONST_ME_PURPLEENERGY,
        riftPulseEffect = CONST_ME_PURPLEENERGY,
        message = "Riftstep Gem tears space open and pulls you to safety.",
    },
    siphonBloom = {
        durationMs = 5000,
        spawnEffect = 185,
        pulseEffect = 185,
        consumeEffect = 185,
        message = "Siphon Bloom restores your vitality.",
    },
    ambushGem = {
        monsters = { "Hydra", "Serpent Spawn", "Behemoth", "Sea Serpent", "Destroyer", "Demon", "Seacrest Serpent", "Vexclaw", "Grimeleech", "Dark Torturer", "Medusa", "Frazzlemaw", "Terrorsleep", "Guzzlemaw", "Silencer", "Retching Horror", "Fury", "Hellfire Fighter", "Converter", "Darklight Construct", "Darklight Emitter", "Darklight Matter", "Darklight Source", "Darklight Striker", "Elder Bloodjaw", "Meandering Mushroom", "Mycobiontic Beetle", "Oozing Carcass", "Oozing Corpus", "Rotten Man-Maggot", "Sopping Carcass", "Sopping Corpus", "Walking Pillar", "Wandering Pillar", "Hand of Cursed Fate", "Capricious Phantom", "Turbulent Elemental", "Juggernaut", "Many Faces", "Burning Book", "Guardian of Tales", "Squid Warden", "Cursed Voidcaller", "Dreadhorn Ravager", "Necroflame Idol", "Spineback Devourer", "Eldritch Devourer", "Venom Ooze", "Void Ooze", "Brachiodemon", "Branchy Crawler", "Bony Sea Devil", "Capricious Phantom", "Cloak of Terror", "Courage Leech", "Distorted Phantom", "Druid's Apparition", "Hazardous Phantom", "Illusionist's Apparition", "Infernal Demon", "Infernal Phantom", "Knight's Apparition", "Many Faces", "Monk's Apparition", "Mould Phantom", "Rotten Golem", "Paladin's Apparition", "Sorcerer's Apparition", "Turbulent Elemental", "Vibrant Phantom", "Brain Squid", "Energetic Book", "Floating Savant", "Energuardian of Tales", "Burning Book", "Animated Feather", "Guardian of Tales", "Icecold Book", "Knowledge Elemental", "Rage Squid", "Squid Warden" },
        goldItemId = 2160,
        gemPowerItemId = GemsSocket.ESSENCE.outputItemId,
        spawnEffect = CONST_ME_MORTAREA,
        expireEffect = CONST_ME_POFF,
    },
    treasureEchoGem = {
        chestItemId = 30659,
        goldItemId = 2152,
        gemPowerItemId = GemsSocket.ESSENCE.outputItemId,
        spawnEffect = CONST_ME_MAGIC_GREEN,
        materialItems = {
            { itemId = 30222, weight = 100 },
            { itemId = 30223, weight = 100 },
            { itemId = 30224, weight = 100 },
            { itemId = 30225, weight = 100 },
            { itemId = 30226, weight = 100 },
            { itemId = 30227, weight = 100 },
            { itemId = 30228, weight = 100 },
            { itemId = 30229, weight = 100 },
            { itemId = 30230, weight = 100 },
            { itemId = 30231, weight = 100 },
            { itemId = 30232, weight = 100 },
            { itemId = 30233, weight = 100 },
            { itemId = 30234, weight = 100 },
            { itemId = 30235, weight = 100 },
            { itemId = 30236, weight = 100 },
            { itemId = 30237, weight = 100 },
            { itemId = 30238, weight = 100 },
            { itemId = 30239, weight = 100 },
            { itemId = 30240, weight = 100 },
            { itemId = 30241, weight = 100 },
            { itemId = 30242, weight = 100 },
            { itemId = 30243, weight = 100 },
            { itemId = 30244, weight = 100 },
            { itemId = 30245, weight = 100 },
            { itemId = 30246, weight = 100 },
            { itemId = 30247, weight = 100 },
            { itemId = 30248, weight = 100 },
            { itemId = 30249, weight = 100 },
            { itemId = 30250, weight = 100 },
            { itemId = 30251, weight = 100 },
            { itemId = 30252, weight = 100 },
            { itemId = 30253, weight = 100 },
            { itemId = 30254, weight = 100 },
            { itemId = 30255, weight = 100 },
            { itemId = 30256, weight = 100 },
            { itemId = 30257, weight = 100 },
            { itemId = 30258, weight = 100 },
            { itemId = 30259, weight = 100 },
            { itemId = 30260, weight = 100 },
            { itemId = 30261, weight = 100 },
            { itemId = 30262, weight = 100 },
            { itemId = 30263, weight = 100 },
            { itemId = 30264, weight = 100 },
            { itemId = 30265, weight = 100 },
            { itemId = 30266, weight = 100 },
            { itemId = 30267, weight = 100 },
            { itemId = 30268, weight = 100 },
            { itemId = 30269, weight = 100 },
            { itemId = 30270, weight = 100 },
            { itemId = 30271, weight = 100 },
        },
    },
    luckyHourglassGem = {
        monsterLevelRange = 5,
        monsterLevelMax = 500,
        monsterLevelHealthBonusPerLevel = 0.0074,
        monsterLevelEffect = CONST_ME_MAGIC_RED,
    },
    artisanLuckGem = {
        refundCount = 1,
        effect = CONST_ME_MAGIC_GREEN,
        message = "Artisan's Luck refunds %d %s.",
    },
    phoenix = {
        reviveDelayMs = 100,
        invulnerabilitySeconds = 1,
        triggerEffect = 185,
        restoreEffect = 27,
        chargeMessage = "Phoenix Gem gains a revive charge.",
        reviveMessage = "Phoenix Gem saves you from death and restores your strength.",
    },
    hauntedHunt = {
        leashRadius = 30,
        awaySeconds = 8,
        waveCount = 2,
        waveSize = 5,
        waveIntervalMs = 2500,
        bossSpawnDelayMs = 6000,
        comebackCheckMessage = "You feel a hostile presence stalking your hunt.",
        comebackSpawnMessage = "The haunted boss has found you again.",
        waveStartMessage = "A haunted rift opens nearby.",
        successMessage = "The haunted boss is defeated. The hunt falls silent.",
        failMessage = "The haunted boss slips away and binds itself to your soul.",
        spawnEffect = 388,
        waveEffect = 377,
        bossEffect = 384,
        successEffect = 387,
        failEffect = 385,
        rewardItemId = GemsSocket.ESSENCE.outputItemId,
        rewardBaseCount = 2,
        rewardPerHauntLevel = 1,
        families = {
            {
                id = "dragon",
                boss = "Death Dragon",
                monsters = { "Dragon", "Dragon Hatchling", "Dragon Lord", "Black Dragon", "Frosted Dragon", "Thawing Dragon Lord" },
            },
            {
                id = "demon",
                boss = "Orshabaal",
                monsters = { "Demon", "Grim Reaper", "Brachiodemon", "Hellspawn", "Juggernaut", "Infernal Demon" },
            },
            {
                id = "goblin",
                boss = "One-Eye Ollie",
                monsters = { "Bat Goblin", "Thief Goblin", "Mounted Warrior Goblin", "Mounted Mage Goblin", "Mounted Archer Goblin", "Mechanic Goblin", "Charged Mechanic Goblin" },
            },
            {
                id = "bone",
                boss = "Prince Skeletal",
                monsters = { "Bone Warrior", "Bone Knight", "Bone Archer", "Bone Mage", "Bone Berserker", "Bone Master", "Bone Slicer", "Bone Ruthless" },
            },
            {
                id = "werebeast",
                boss = "Feroxa",
                monsters = { "Werelion", "Werelioness", "Werehyaena", "Werecrocodile", "Feral Werecrocodile", "Weretiger", "White Weretiger", "Werepanther" },
            },
            {
                id = "phantom",
                boss = "Goshnar's Malice",
                monsters = { "Vibrant Phantom", "Infernal Phantom", "Distorted Phantom", "Mould Phantom", "Capricious Phantom", "Vibrant Phantom" },
            },
            {
                id = "desert",
                boss = "Urmahlullu the Weakened",
                monsters = { "Sphinx", "Feral Sphinx", "Black Sphinx Acolyte", "Lamassu", "Manticore", "Gryphon" },
            },
            {
                id = "undead",
                boss = "Count Vlarkorth",
                monsters = { "Walking Dread", "Crypt Warden", "Grave Sentinel", "Risen Soldier", "Soulless Minion", "Varg" },
            },
            {
                id = "inferniarch",
                boss = "Arbaziloth Master",
                monsters = { "Arbaziloth", "Broodrider Inferniarch", "Brinebrute Inferniarch", "Hellhunter Inferniarch", "Sineater Inferniarch", "Spellreaper Inferniarch" },
            },
            {
                id = "waystone",
                boss = "Vorgrun of the jade Fangs",
                monsters = { "Armorcoil", "Nexlurith", "Voidwagner", "Blazefang", "Gorgulith", "Aegis Sentinel", "Flarevein Wyrm", "Gloomstinger", "Pyroquill", "Toxic Mauler" },
            },
            {
                id = "library",
                boss = "Ghulosh",
                monsters = { "Animated Feather", "Biting Book", "Brain Squid", "Cursed Book", "Energetic Book", "Energuardian of Tales", "Floating Savant", "Guardin of Tales", "Icecold Book", "Ink blob", "Knowledge Elemental", "Rage Squid", "Squid Warden" },
            },
            {
                id = "necromantic",
                boss = "Vladrukh",
                monsters = { "Creephy Crawler", "Crypt Construct", "Crypt Fiend", "Crypt Mage", "Cyclursus", "Gloom Maw", "Night Harpy", "Orclops Bloodbreaker", "Roaming Dread", "Varg", "Walking Dread" },
            },
            {
                id = "feaster",
                boss = "The Dread Maiden",
                monsters = { "Cursed Prospector", "Evil Prospector", "Flimsy Lost Soul", "Mean Lost Soul" },
            },
            {
                id = "falcon",
                boss = "Gran Master Oberon",
                monsters = { "Falcon Knight", "Falcon Paladin" },
            },
            {
                id = "cobra",
                boss = "Custodian",
                monsters = { "Cobra Assassin", "Cobra Scout", "Cobra Vizier" },
            },
            {
                id = "candy",
                boss = "Candy Fairy",
                monsters = { "Angry Sugar Fairy", "Candy floss Elemental", "Candy Horror", "Goggle Cake", "Nible Maw" },
            },
            {
                id = "bounac",
                boss = "Drume",
                monsters = { "Usurper Archer", "Usurper Knight", "Usurper Warlock" },
            },
            {
                id = "corruption",
                boss = "Gravexon The Devourer",
                monsters = { "Abyssal Nightreaver", "Ancient Moss Guardian", "Ancient Root Tyrant", "Arcaneseer Djinn", "Ashen Hellhound", "Blacksteel Brute", "Baldecoil Stalker", "Brood Abomination", "Cinderheart Abomination", "Cursed Voidcaller", "Dreadhorn Ravager", "Dunestalker Hunter", "Eldritch Devourer", "Emerflame Conjurer", "Hellscythe Reaver", "Hive Widow", "Ironburrow Devourer", "Magmafang Incinerator", "Shardback Behemoth", "Necroflame Idol", "Spineback Devourer", "Stonehide Ravager", "Stormfang Ravager", "Totem Warbeast", "Venom Ooze", "Venomcoil Automaton", "Verdant Rootwalker", "Void Ooze", "Voltstrike Hound" },
            },
        }
    },
    abattoir = {
        minMonsterHealth = 100,
        idleResetSeconds = 900,
        monitorIntervalSeconds = 2,
        eventLeashRadius = 30,
        spawnSearchMinRange = 1,
        spawnSearchMaxRange = 4,
        heatPerChain = 0.1,
        maxHeat = 100,
        resetOnLogout = true,
        resetOnDeath = true,
        resetOnProtectionZone = true,
        removeSpawnsOnReset = true,
        ambushSpawnEffect = 218,
        bossSpawnEffect = 217,
        resetEffect = CONST_ME_POFF,
        rewardEffect = 223,
        rewardItemId = GemsSocket.ESSENCE.outputItemId,
        rewardBaseCount = 2,
        rewardPerGemLevel = 1,
        rewardPerHeatTier = 1,
        chainByHealth = {
            { min = 100, max = 1499, chain = 1 },
            { min = 1500, max = 4999, chain = 2 },
            { min = 5000, max = 14999, chain = 3 },
            { min = 15000, max = 49999, chain = 4 },
            { min = 50000, max = 999999999, chain = 7 },
        },
        messages = {
            heatGain = "Abattoir heat rises: %d%%.",
            ambush = "The Abattoir answers your slaughter.",
            boss = "The Abattoir opens. Survive the executioner.",
            reset = "Your Abattoir chain has been lost.",
            reward = "The Abattoir is satisfied.",
        },
    },
    triCraft = {
        balanceTolerancePercent = 10,
        bonusEffect = CONST_ME_MAGIC_GREEN,
        levelUpEffect = CONST_ME_HOLYAREA,
        messages = {
            bonus = "Tri-Craft Gem yields %dx extra %s.",
            levelUp = "Tri-Craft Gem harmonizes into level %d.",
        },
        materials = {
            mining = {
                26398, 26399, 26404, 26401, 26400, 26402, 26403,
                30222, 30223, 30228, 30229, 30250, 30251, 30253, 30254,
                30256, 30257, 30259, 30260, 30262, 30263, 30264, 30265, 30266,
            },
            woodcutting = {
                26593, 26594, 26595, 26596, 26597, 26598,
                30225, 30239, 30240, 30241, 30242, 30243,
                30267, 30268, 30269, 30270, 30271,
            },
            herbalist = {
                26723, 26724, 26725, 26726, 26727, 26728, 26729, 26730, 26731, 26732,
                30226, 30227, 30231, 30232, 30233, 30234, 30235, 30236, 30237, 30238,
                30244, 30245, 30246, 30247, 30248, 30249,
            },
        },
    },
    paradox = {
        monsterName = "Paradox",
        durationSeconds = 5,
        triggerEffect = 387,
        collapseEffect = 389,
        message = "Paradox Gem splits your timeline and leaves a false self behind.",
    },
    manaNova = {
        radius = 4,
        restoreIntervalMs = 1000,
        triggerEffect = 223,
        areaEffect = 223,
        hitEffect = CONST_ME_HOLYDAMAGE,
        message = "Mana Nova erupts from your empty spirit.",
    },
    conditionMirror = {
        triggerEffect = 400,
        message = "Hexmirror Gem reflects a random curse nearby.",
    },
    chameleon = {
        triggerEffect = 401,
        message = "Chameleon Gem adapts to the last element.",
    },
    galvanic = {
        chargeEffect = CONST_ME_ENERGYHIT,
        chainEffect = CONST_ME_ENERGYAREA,
        message = "Galvanic Gem discharges stored energy.",
    },
    tide = {
        peakStartHour = 18,
        peakEndHour = 23,
        checkIntervalSeconds = 600,
    },
    professionMastery = {
        tierStarts = { 0, 500, 1000, 2000, 4000, 10000 },
        efficiencyByTier = { 0, 25, 50, 100, 150, 200 },
        rareFindGathersFor100 = 20000,
    }
}

GemsSocket.GEMS = {
  --- Slots can have aswell "ammo", i did not add any quiver , but if you wish you can add the quivers on the list.
    -- Normal --
    -- 1 --
    garnet = {
        itemId = 30666,
        name = "Garnet Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "weapon" },
        bestFor = { "Knight", "Paladin", "Druid" },
        style = "AoE Burst",
        bonuses = {
            socket_onkill_blast_chance = 2,
            socket_onkill_blast_percent = 3,
        },
        tooltip = "+2% Blast Chance\nOn kill, explode for 3% of the monster max HP.\nDetails: Onkill Blast Chance: 2%, Onkill Blast Percent: 3%",
        tiers = {
            [1] = { name = "Small Garnet", bonuses = { socket_onkill_blast_chance = 2, socket_onkill_blast_percent = 3 }, tooltip = "+2% Blast Chance\nOn kill, explode for 3% of the monster max HP.\nDetails: Onkill Blast Chance: 2%, Onkill Blast Percent: 3%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Garnet", bonuses = { socket_onkill_blast_chance = 3, socket_onkill_blast_percent = 4 }, tooltip = "+3% Blast Chance\nOn kill, explode for 4% of the monster max HP.\nDetails: Onkill Blast Chance: 3%, Onkill Blast Percent: 4%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Garnet", bonuses = { socket_onkill_blast_chance = 4, socket_onkill_blast_percent = 5 }, tooltip = "+4% Blast Chance\nOn kill, explode for 5% of the monster max HP.\nDetails: Onkill Blast Chance: 4%, Onkill Blast Percent: 5%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Garnet", bonuses = { socket_onkill_blast_chance = 5, socket_onkill_blast_percent = 7 }, tooltip = "+5% Blast Chance\nOn kill, explode for 7% of the monster max HP.\nDetails: Onkill Blast Chance: 5%, Onkill Blast Percent: 7%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Garnet", bonuses = { socket_onkill_blast_chance = 7, socket_onkill_blast_percent = 10 }, tooltip = "+7% Blast Chance\nOn kill, explode for 10% of the monster max HP.\nDetails: Onkill Blast Chance: 7%, Onkill Blast Percent: 10%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Garnet", bonuses = { socket_onkill_blast_chance = 10, socket_onkill_blast_percent = 13 }, tooltip = "+10% Blast Chance\nOn kill, explode for 13% of the monster max HP.\nDetails: Onkill Blast Chance: 10%, Onkill Blast Percent: 13%" }
        }
    },

    -- 2 --
    emerald = {
        itemId = 30667,
        name = "Dodge Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield" },
        effect = 406,
        bonuses = {
            socket_dodge_chance = 3,
        },
        tooltip = "+3% Dodge Chance",
        tiers = {
            [1] = { name = "Small Dodge", bonuses = { socket_dodge_chance = 2 }, tooltip = "+2% Dodge Chance", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Dodge", bonuses = { socket_dodge_chance = 3 }, tooltip = "+3% Dodge Chance", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Dodge", bonuses = { socket_dodge_chance = 4 }, tooltip = "+4% Dodge Chance", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Dodge", bonuses = { socket_dodge_chance = 5 }, tooltip = "+5% Dodge Chance", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Dodge", bonuses = { socket_dodge_chance = 7 }, tooltip = "+7% Dodge Chance", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Dodge", bonuses = { socket_dodge_chance = 10 }, tooltip = "+10% Dodge Chance" }
        }
    },

    -- 3 --
    bloodstone = {
        itemId = 30668,
        name = "Bloodstone Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield" },
        effect = 399,
        bonuses = {
            socket_parry_chance = 3,
            socket_parry_percent = 25,
        },
        tooltip = "+3% Parry Chance\nReflect 25% of received damage",
        tiers = {
            [1] = { name = "Small Bloodstone", bonuses = { socket_parry_chance = 2, socket_parry_percent = 25 }, tooltip = "+2% Parry Chance\nReflect 25% of received damage", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Bloodstone", bonuses = { socket_parry_chance = 3, socket_parry_percent = 30 }, tooltip = "+3% Parry Chance\nReflect 30% of received damage", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Bloodstone", bonuses = { socket_parry_chance = 4, socket_parry_percent = 40 }, tooltip = "+4% Parry Chance\nReflect 40% of received damage", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Bloodstone", bonuses = { socket_parry_chance = 5, socket_parry_percent = 50 }, tooltip = "+5% Parry Chance\nReflect 50% of received damage", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Bloodstone", bonuses = { socket_parry_chance = 7, socket_parry_percent = 65 }, tooltip = "+7% Parry Chance\nReflect 65% of received damage", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Bloodstone", bonuses = { socket_parry_chance = 10, socket_parry_percent = 80 }, tooltip = "+10% Parry Chance\nReflect 80% of received damage" }
        }
    },
    -- 4 --
    pyrestone = {
        itemId = 30669,
        name = "Pyrestone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        effect = 400,
        bonuses = {
            socket_thorns_chance = 3,
            socket_thorns_damage = 30,
        },
        tooltip = "+3% Thorns Chance\nReflect 30 physical damage",
        tiers = {
            [1] = { name = "Small Pyrestone", bonuses = { socket_thorns_chance = 2, socket_thorns_damage = 30 }, tooltip = "+2% Thorns Chance\nReflect 30 physical damage", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Pyrestone", bonuses = { socket_thorns_chance = 3, socket_thorns_damage = 60 }, tooltip = "+3% Thorns Chance\nReflect 60 physical damage", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Pyrestone", bonuses = { socket_thorns_chance = 4, socket_thorns_damage = 90 }, tooltip = "+4% Thorns Chance\nReflect 90 physical damage", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Pyrestone", bonuses = { socket_thorns_chance = 5, socket_thorns_damage = 130 }, tooltip = "+5% Thorns Chance\nReflect 130 physical damage", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Pyrestone", bonuses = { socket_thorns_chance = 7, socket_thorns_damage = 160 }, tooltip = "+7% Thorns Chance\nReflect 160 physical damage", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Pyrestone", bonuses = { socket_thorns_chance = 10, socket_thorns_damage = 200 }, tooltip = "+10% Thorns Chance\nReflect 200 physical damage" }
        }
    },
    -- 5 --
    froststone = {
        itemId = 30670,
        name = "Froststone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bonuses = {
            socket_cripple_chance = 3,
            socket_cripple_duration = 3,
            socket_cripple_speed = 15,
        },
        effect = 405,
        tooltip = "+3% Cripple Chance\nSlow target by 15% for 3s",
        tiers = {
            [1] = { name = "Small Froststone", bonuses = { socket_cripple_chance = 2, socket_cripple_duration = 3, socket_cripple_speed = 15 }, tooltip = "+2% Cripple Chance\nSlow target by 15% for 3s", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Froststone", bonuses = { socket_cripple_chance = 3, socket_cripple_duration = 3, socket_cripple_speed = 20 }, tooltip = "+3% Cripple Chance\nSlow target by 20% for 3s", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Froststone", bonuses = { socket_cripple_chance = 4, socket_cripple_duration = 4, socket_cripple_speed = 30 }, tooltip = "+4% Cripple Chance\nSlow target by 30% for 4s", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Froststone", bonuses = { socket_cripple_chance = 5, socket_cripple_duration = 4, socket_cripple_speed = 40 }, tooltip = "+5% Cripple Chance\nSlow target by 40% for 4s", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Froststone", bonuses = { socket_cripple_chance = 7, socket_cripple_duration = 4, socket_cripple_speed = 50 }, tooltip = "+7% Cripple Chance\nSlow target by 50% for 4s", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Froststone", bonuses = { socket_cripple_chance = 10, socket_cripple_duration = 5, socket_cripple_speed = 60 }, tooltip = "+10% Cripple Chance\nSlow target by 60% for 5s" }
        }
    },
    -- 6 --
    stormstone = {
        itemId = 30671,
        name = "Stormstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bonuses = {
            socket_mana_surge_chance = 2,
            socket_mana_surge_percent = 1,
        },
        tooltip = "+2% Mana Surge Chance\nRestore 1% max mana when hit",
        tiers = {
            [1] = { name = "Small Stormstone", bonuses = { socket_mana_surge_chance = 2, socket_mana_surge_percent = 1 }, tooltip = "+2% Mana Surge Chance\nRestore 1% max mana when hit", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Stormstone", bonuses = { socket_mana_surge_chance = 3, socket_mana_surge_percent = 1 }, tooltip = "+3% Mana Surge Chance\nRestore 1% max mana when hit", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Stormstone", bonuses = { socket_mana_surge_chance = 4, socket_mana_surge_percent = 2 }, tooltip = "+4% Mana Surge Chance\nRestore 2% max mana when hit", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Stormstone", bonuses = { socket_mana_surge_chance = 5, socket_mana_surge_percent = 2 }, tooltip = "+5% Mana Surge Chance\nRestore 2% max mana when hit", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Stormstone", bonuses = { socket_mana_surge_chance = 7, socket_mana_surge_percent = 3 }, tooltip = "+7% Mana Surge Chance\nRestore 3% max mana when hit", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Stormstone", bonuses = { socket_mana_surge_chance = 10, socket_mana_surge_percent = 4 }, tooltip = "+10% Mana Surge Chance\nRestore 4% max mana when hit" }
        }
    },
    -- 7 --
    earthstone = {
        itemId = 30672,
        name = "Earthstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bonuses = {
            socket_guard_chance = 2,
            socket_guard_percent = 5,
        },
        tooltip = "+2% Guard Chance\nReduce hit damage by 5%",
        tiers = {
            [1] = { name = "Small Earthstone", bonuses = { socket_guard_chance = 2, socket_guard_percent = 5 }, tooltip = "+2% Guard Chance\nReduce hit damage by 5%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Earthstone", bonuses = { socket_guard_chance = 3, socket_guard_percent = 8 }, tooltip = "+3% Guard Chance\nReduce hit damage by 8%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Earthstone", bonuses = { socket_guard_chance = 4, socket_guard_percent = 12 }, tooltip = "+4% Guard Chance\nReduce hit damage by 12%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Earthstone", bonuses = { socket_guard_chance = 5, socket_guard_percent = 15 }, tooltip = "+5% Guard Chance\nReduce hit damage by 15%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Earthstone", bonuses = { socket_guard_chance = 7, socket_guard_percent = 20 }, tooltip = "+7% Guard Chance\nReduce hit damage by 20%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Earthstone", bonuses = { socket_guard_chance = 10, socket_guard_percent = 25 }, tooltip = "+10% Guard Chance\nReduce hit damage by 25%" }
        }
    },
    -- 8 --
    deathstone = {
        itemId = 30673,
        name = "Deathstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bonuses = {
            socket_execute_chance = 2,
            socket_execute_threshold = 12,
            socket_execute_percent = 15,
        },
        tooltip = "+2% Execute Chance\nAt or below 12% HP, deal +15% hit damage",
        tiers = {
            [1] = { name = "Small Deathstone", bonuses = { socket_execute_chance = 2, socket_execute_threshold = 12, socket_execute_percent = 15 }, tooltip = "+2% Execute Chance\nAt or below 12% HP, deal +15% hit damage", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Deathstone", bonuses = { socket_execute_chance = 3, socket_execute_threshold = 20, socket_execute_percent = 20 }, tooltip = "+3% Execute Chance\nAt or below 20% HP, deal +20% hit damage", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Deathstone", bonuses = { socket_execute_chance = 4, socket_execute_threshold = 25, socket_execute_percent = 25 }, tooltip = "+4% Execute Chance\nAt or below 25% HP, deal +25% hit damage", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Deathstone", bonuses = { socket_execute_chance = 5, socket_execute_threshold = 30, socket_execute_percent = 30 }, tooltip = "+5% Execute Chance\nAt or below 30% HP, deal +30% hit damage", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Deathstone", bonuses = { socket_execute_chance = 7, socket_execute_threshold = 35, socket_execute_percent = 35 }, tooltip = "+7% Execute Chance\nAt or below 35% HP, deal +35% hit damage", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Deathstone", bonuses = { socket_execute_chance = 10, socket_execute_threshold = 40, socket_execute_percent = 40 }, tooltip = "+10% Execute Chance\nAt or below 40% HP, deal +40% hit damage" }
        }
    },
    -- 9 --
    holystone = {
        itemId = 30674,
        name = "Holystone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bonuses = {
            socket_cleanse_chance = 5,
        },
        tooltip = "+5% Cleanse Chance\nRemove 1 random debuff when hit",
        tiers = {
            [1] = { name = "Small Holystone", bonuses = { socket_cleanse_chance = 2 }, tooltip = "+2% Cleanse Chance\nRemove 1 random debuff when hit", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Holystone", bonuses = { socket_cleanse_chance = 3 }, tooltip = "+3% Cleanse Chance\nRemove 1 random debuff when hit", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Holystone", bonuses = { socket_cleanse_chance = 4 }, tooltip = "+4% Cleanse Chance\nRemove 1 random debuff when hit", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Holystone", bonuses = { socket_cleanse_chance = 5 }, tooltip = "+5% Cleanse Chance\nRemove 1 random debuff when hit", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Holystone", bonuses = { socket_cleanse_chance = 7 }, tooltip = "+7% Cleanse Chance\nRemove 1 random debuff when hit", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Holystone", bonuses = { socket_cleanse_chance = 10 }, tooltip = "+10% Cleanse Chance\nRemove 1 random debuff when hit" }
        }
    },
    -- 10 --
    waterstone = {
        itemId = 30675,
        name = "Waterstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bonuses = {
            socket_second_wind_chance = 2,
            socket_second_wind_percent = 1,
        },
        tooltip = "+2% Second Wind Chance\nRestore 1% max health when hit",
        tiers = {
            [1] = { name = "Small Waterstone", bonuses = { socket_second_wind_chance = 2, socket_second_wind_percent = 1 }, tooltip = "+2% Second Wind Chance\nRestore 1% max health when hit", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Waterstone", bonuses = { socket_second_wind_chance = 3, socket_second_wind_percent = 1 }, tooltip = "+3% Second Wind Chance\nRestore 1% max health when hit", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Waterstone", bonuses = { socket_second_wind_chance = 4, socket_second_wind_percent = 2 }, tooltip = "+4% Second Wind Chance\nRestore 2% max health when hit", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Waterstone", bonuses = { socket_second_wind_chance = 5, socket_second_wind_percent = 2 }, tooltip = "+5% Second Wind Chance\nRestore 2% max health when hit", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Waterstone", bonuses = { socket_second_wind_chance = 7, socket_second_wind_percent = 3 }, tooltip = "+7% Second Wind Chance\nRestore 3% max health when hit", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Waterstone", bonuses = { socket_second_wind_chance = 10, socket_second_wind_percent = 4 }, tooltip = "+10% Second Wind Chance\nRestore 4% max health when hit" }
        }
    },
    -- 11 --
    abyssstone = {
        itemId = 30676,
        name = "Abyssstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Knight", "Paladin", "Sorcerer", "Druid" },
        style = "Momentum",
        bonuses = {
            socket_abyssal_depths_chance = 2,
            socket_abyssal_depths_percent = 1,
        },
        tooltip = "Dealing damage has 2% chance every 20s to grant Abyssal Depths for 6s\nWhile active, increase damage done by 1%",
        tiers = {
            [1] = { name = "Small Abyssstone", bonuses = { socket_abyssal_depths_chance = 2, socket_abyssal_depths_percent = 1 }, tooltip = "Dealing damage has 2% chance every 20s to grant Abyssal Depths for 6s\nWhile active, increase damage done by 1%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Abyssstone", bonuses = { socket_abyssal_depths_chance = 3, socket_abyssal_depths_percent = 2 }, tooltip = "Dealing damage has 3% chance every 20s to grant Abyssal Depths for 6s\nWhile active, increase damage done by 2%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Abyssstone", bonuses = { socket_abyssal_depths_chance = 4, socket_abyssal_depths_percent = 3 }, tooltip = "Dealing damage has 4% chance every 20s to grant Abyssal Depths for 6s\nWhile active, increase damage done by 3%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Abyssstone", bonuses = { socket_abyssal_depths_chance = 5, socket_abyssal_depths_percent = 4 }, tooltip = "Dealing damage has 5% chance every 20s to grant Abyssal Depths for 6s\nWhile active, increase damage done by 4%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Abyssstone", bonuses = { socket_abyssal_depths_chance = 7, socket_abyssal_depths_percent = 5 }, tooltip = "Dealing damage has 7% chance every 20s to grant Abyssal Depths for 6s\nWhile active, increase damage done by 5%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Abyssstone", bonuses = { socket_abyssal_depths_chance = 10, socket_abyssal_depths_percent = 6 }, tooltip = "Dealing damage has 10% chance every 20s to grant Abyssal Depths for 6s\nWhile active, increase damage done by 6%" }
        },
    },

    -- 12 --
    spellstone = {
        itemId = 30677,
        name = "Spellstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Sorcerer", "Druid" },
        style = "Spellburst",
        bonuses = {
            socket_spellfury_chance = 2,
            socket_spellfury_percent = 1,
        },
        tooltip = "Spell damage has 2% chance every 20s to grant Spellfury for 6s\nWhile active, increase spell damage by 1%",
        tiers = {
            [1] = { name = "Small Spellstone", bonuses = { socket_spellfury_chance = 2, socket_spellfury_percent = 1 }, tooltip = "Spell damage has 2% chance every 20s to grant Spellfury for 6s\nWhile active, increase spell damage by 1%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Spellstone", bonuses = { socket_spellfury_chance = 3, socket_spellfury_percent = 2 }, tooltip = "Spell damage has 3% chance every 20s to grant Spellfury for 6s\nWhile active, increase spell damage by 2%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Spellstone", bonuses = { socket_spellfury_chance = 4, socket_spellfury_percent = 3 }, tooltip = "Spell damage has 4% chance every 20s to grant Spellfury for 6s\nWhile active, increase spell damage by 3%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Spellstone", bonuses = { socket_spellfury_chance = 5, socket_spellfury_percent = 4 }, tooltip = "Spell damage has 5% chance every 20s to grant Spellfury for 6s\nWhile active, increase spell damage by 4%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Spellstone", bonuses = { socket_spellfury_chance = 7, socket_spellfury_percent = 5 }, tooltip = "Spell damage has 7% chance every 20s to grant Spellfury for 6s\nWhile active, increase spell damage by 5%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Spellstone", bonuses = { socket_spellfury_chance = 10, socket_spellfury_percent = 6 }, tooltip = "Spell damage has 10% chance every 20s to grant Spellfury for 6s\nWhile active, increase spell damage by 6%" }
        },
    },

    -- 13 --
    ascendstone = {
        itemId = 30678,
        name = "Ascendstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Paladin", "Sorcerer", "Druid" },
        style = "Ascendance",
        effect = 406,
        bonuses = {
            socket_ascendance_chance = 2,
            socket_ascendance_dodge = 2,
            socket_ascendance_blast_percent = 8,
        },
        tooltip = "Dealing damage has 2% chance every 20s to grant Ascendance for 6s\nWhile active, gain +2% dodge and unleash 3 arcane blasts every 2s.\nDetails: Ascendance Blast Percent: 8%",
        tiers = {
            [1] = { name = "Small Ascendstone", bonuses = { socket_ascendance_chance = 2, socket_ascendance_dodge = 2, socket_ascendance_blast_percent = 8 }, tooltip = "Dealing damage has 2% chance every 20s to grant Ascendance for 6s\nWhile active, gain +2% dodge and unleash 3 arcane blasts every 2s.\nDetails: Ascendance Blast Percent: 8%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Ascendstone", bonuses = { socket_ascendance_chance = 3, socket_ascendance_dodge = 2, socket_ascendance_blast_percent = 9 }, tooltip = "Dealing damage has 3% chance every 20s to grant Ascendance for 6s\nWhile active, gain +2% dodge and unleash 3 arcane blasts every 2s.\nDetails: Ascendance Blast Percent: 9%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Ascendstone", bonuses = { socket_ascendance_chance = 4, socket_ascendance_dodge = 2, socket_ascendance_blast_percent = 10 }, tooltip = "Dealing damage has 4% chance every 20s to grant Ascendance for 6s\nWhile active, gain +2% dodge and unleash 3 arcane blasts every 2s.\nDetails: Ascendance Blast Percent: 10%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Ascendstone", bonuses = { socket_ascendance_chance = 5, socket_ascendance_dodge = 2, socket_ascendance_blast_percent = 11 }, tooltip = "Dealing damage has 5% chance every 20s to grant Ascendance for 6s\nWhile active, gain +2% dodge and unleash 3 arcane blasts every 2s.\nDetails: Ascendance Blast Percent: 11%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Ascendstone", bonuses = { socket_ascendance_chance = 7, socket_ascendance_dodge = 2, socket_ascendance_blast_percent = 13 }, tooltip = "Dealing damage has 7% chance every 20s to grant Ascendance for 6s\nWhile active, gain +2% dodge and unleash 3 arcane blasts every 2s.\nDetails: Ascendance Blast Percent: 13%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Ascendstone", bonuses = { socket_ascendance_chance = 10, socket_ascendance_dodge = 2, socket_ascendance_blast_percent = 15 }, tooltip = "Dealing damage has 10% chance every 20s to grant Ascendance for 6s\nWhile active, gain +2% dodge and unleash 3 arcane blasts every 2s.\nDetails: Ascendance Blast Percent: 15%" }
        },
    },

    -- 14 --
    voltstone = {
        itemId = 30679,
        name = "Voltstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Sorcerer", "Druid", "Paladin" },
        style = "Static Field",
        bonuses = {
            socket_voltstone_chance = 2,
            socket_voltstone_percent = 50,
        },
        tooltip = "Dealing damage has 2% chance every 20s to create a fixed 3x3 energy burst\nThe burst deals 50% of the triggering hit",
        tiers = {
            [1] = { name = "Small Voltstone", bonuses = { socket_voltstone_chance = 2, socket_voltstone_percent = 50 }, tooltip = "Dealing damage has 2% chance every 20s to create a fixed 3x3 energy burst\nThe burst deals 50% of the triggering hit.", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Voltstone", bonuses = { socket_voltstone_chance = 3, socket_voltstone_percent = 55 }, tooltip = "Dealing damage has 3% chance every 20s to create a fixed 3x3 energy burst\nThe burst deals 55% of the triggering hit.", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Voltstone", bonuses = { socket_voltstone_chance = 4, socket_voltstone_percent = 60 }, tooltip = "Dealing damage has 4% chance every 20s to create a fixed 3x3 energy burst\nThe burst deals 60% of the triggering hit.", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Voltstone", bonuses = { socket_voltstone_chance = 5, socket_voltstone_percent = 65 }, tooltip = "Dealing damage has 5% chance every 20s to create a fixed 3x3 energy burst\nThe burst deals 65% of the triggering hit.", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Voltstone", bonuses = { socket_voltstone_chance = 7, socket_voltstone_percent = 70 }, tooltip = "Dealing damage has 7% chance every 20s to create a fixed 3x3 energy burst\nThe burst deals 70% of the triggering hit.", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Voltstone", bonuses = { socket_voltstone_chance = 10, socket_voltstone_percent = 80 }, tooltip = "Dealing damage has 10% chance every 20s to create a fixed 3x3 energy burst\nThe burst deals 80% of the triggering hit." }
        },
    },

    -- 15 --
    emberstone = {
        itemId = 30680,
        name = "Emberstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Sorcerer", "Druid", "Knight" },
        style = "Chain Explosion",
        bonuses = {
            socket_emberstone_chance = 2,
            socket_emberstone_percent = 20,
            socket_emberstone_burn_percent = 8,
        },
        effect = 409,
        tooltip = "Dealing damage has 2% chance every 20s to ignite Emberstorm for 6s\nEvery 2s, explode a nearby enemy and burn it.\nDetails: Damage: 20%, Burn Percent: 8%",
        tiers = {
            [1] = { name = "Small Emberstone", bonuses = { socket_emberstone_chance = 2, socket_emberstone_percent = 20, socket_emberstone_burn_percent = 8 }, tooltip = "Dealing damage has 2% chance every 20s to ignite Emberstorm for 6s\nEvery 2s, explode a nearby enemy and burn it.\nDetails: Damage: 20%, Burn Percent: 8%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Emberstone", bonuses = { socket_emberstone_chance = 3, socket_emberstone_percent = 25, socket_emberstone_burn_percent = 9 }, tooltip = "Dealing damage has 3% chance every 20s to ignite Emberstorm for 6s\nEvery 2s, explode a nearby enemy and burn it.\nDetails: Damage: 25%, Burn Percent: 9%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Emberstone", bonuses = { socket_emberstone_chance = 4, socket_emberstone_percent = 30, socket_emberstone_burn_percent = 10 }, tooltip = "Dealing damage has 4% chance every 20s to ignite Emberstorm for 6s\nEvery 2s, explode a nearby enemy and burn it.\nDetails: Damage: 30%, Burn Percent: 10%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Emberstone", bonuses = { socket_emberstone_chance = 5, socket_emberstone_percent = 35, socket_emberstone_burn_percent = 11 }, tooltip = "Dealing damage has 5% chance every 20s to ignite Emberstorm for 6s\nEvery 2s, explode a nearby enemy and burn it.\nDetails: Damage: 35%, Burn Percent: 11%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Emberstone", bonuses = { socket_emberstone_chance = 7, socket_emberstone_percent = 40, socket_emberstone_burn_percent = 13 }, tooltip = "Dealing damage has 7% chance every 20s to ignite Emberstorm for 6s\nEvery 2s, explode a nearby enemy and burn it.\nDetails: Damage: 40%, Burn Percent: 13%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Emberstone", bonuses = { socket_emberstone_chance = 10, socket_emberstone_percent = 50, socket_emberstone_burn_percent = 15 }, tooltip = "Dealing damage has 10% chance every 20s to ignite Emberstorm for 6s\nEvery 2s, explode a nearby enemy and burn it.\nDetails: Damage: 50%, Burn Percent: 15%" }
        },
    },

    -- 16 --
    bindstone = {
        itemId = 30681,
        name = "Bindstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Knight", "Paladin", "Sorcerer", "Druid" },
        style = "Control",
        bonuses = {
            socket_bindstone_chance = 3,
            socket_bindstone_duration = 1,
        },
        tooltip = "Dealing damage has 2% chance every 20s to immobilize the target for 1s.\nDetails: Chance: 3%, Duration: 1s",
        tiers = {
            [1] = {
                name = "Small Bindstone",
                bonuses = { socket_bindstone_chance = 2, socket_bindstone_duration = 1 },
                tooltip = "Dealing damage has 2% chance every 20s to immobilize the target for 1s.\nDetails: Duration: 1s",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Bindstone",
                bonuses = { socket_bindstone_chance = 3, socket_bindstone_duration = 2 },
                tooltip = "Dealing damage has 3% chance every 20s to immobilize the target for 2s.\nDetails: Duration: 2s",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Bindstone",
                bonuses = { socket_bindstone_chance = 4, socket_bindstone_duration = 2 },
                tooltip = "Dealing damage has 4% chance every 20s to immobilize the target for 2s.\nDetails: Duration: 2s",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Bindstone",
                bonuses = { socket_bindstone_chance = 5, socket_bindstone_duration = 3 },
                tooltip = "Dealing damage has 5% chance every 20s to immobilize the target for 3s.\nDetails: Duration: 3s",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Bindstone",
                bonuses = { socket_bindstone_chance = 7, socket_bindstone_duration = 3 },
                tooltip = "Dealing damage has 7% chance every 20s to immobilize the target for 3s.\nDetails: Duration: 3s",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Bindstone",
                bonuses = { socket_bindstone_chance = 10, socket_bindstone_duration = 4 },
                tooltip = "Dealing damage has 10% chance every 20s to immobilize the target for 4s.\nDetails: Duration: 4s"
            }
        }
    },

    -- 17 --
    surgestone = {
        itemId = 30682,
        name = "Surgestone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Sorcerer", "Druid", "Paladin" },
        style = "Chain Shock",
        bonuses = {
            socket_surgestone_chance = 2,
            socket_surgestone_percent = 35,
        },
        effect = 408,
        tooltip = "Dealing damage has 2% chance every 20s to chain lightning to nearby enemies\nEach chain deals 35% of the triggering hit",
        tiers = {
            [1] = { name = "Small Surgestone", bonuses = { socket_surgestone_chance = 2, socket_surgestone_percent = 35 }, tooltip = "Dealing damage has 2% chance every 20s to chain lightning to nearby enemies\nEach chain deals 35% of the triggering hit.", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Surgestone", bonuses = { socket_surgestone_chance = 3, socket_surgestone_percent = 40 }, tooltip = "Dealing damage has 3% chance every 20s to chain lightning to nearby enemies\nEach chain deals 40% of the triggering hit.", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Surgestone", bonuses = { socket_surgestone_chance = 4, socket_surgestone_percent = 45 }, tooltip = "Dealing damage has 4% chance every 20s to chain lightning to nearby enemies\nEach chain deals 45% of the triggering hit.", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Surgestone", bonuses = { socket_surgestone_chance = 5, socket_surgestone_percent = 50 }, tooltip = "Dealing damage has 5% chance every 20s to chain lightning to nearby enemies\nEach chain deals 50% of the triggering hit.", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Surgestone", bonuses = { socket_surgestone_chance = 7, socket_surgestone_percent = 55 }, tooltip = "Dealing damage has 7% chance every 20s to chain lightning to nearby enemies\nEach chain deals 55% of the triggering hit.", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Surgestone", bonuses = { socket_surgestone_chance = 10, socket_surgestone_percent = 65 }, tooltip = "Dealing damage has 10% chance every 20s to chain lightning to nearby enemies\nEach chain deals 65% of the triggering hit." }
        },
    },

    -- 18 --
    warstone = {
        itemId = 30683,
        name = "Warstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Knight", "Paladin", "Sorcerer", "Druid" },
        style = "Blood Rage",
        bonuses = {
            socket_warstone_chance = 2,
            socket_warstone_percent = 2,
        },
        tooltip = "While taking damage, if the hit pushes you below 50% life, you have 2% chance every 20s to enter Blood Rage for 6s\nWhile active, increase damage done by 2%",
        tiers = {
            [1] = { name = "Small Warstone", bonuses = { socket_warstone_chance = 2, socket_warstone_percent = 2 }, tooltip = "While taking damage, if the hit pushes you below 50% life, you have 2% chance every 20s to enter Blood Rage for 6s\nWhile active, increase damage done by 2%.", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Warstone", bonuses = { socket_warstone_chance = 3, socket_warstone_percent = 3 }, tooltip = "While taking damage, if the hit pushes you below 50% life, you have 3% chance every 20s to enter Blood Rage for 6s\nWhile active, increase damage done by 3%.", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Warstone", bonuses = { socket_warstone_chance = 4, socket_warstone_percent = 4 }, tooltip = "While taking damage, if the hit pushes you below 50% life, you have 4% chance every 20s to enter Blood Rage for 6s\nWhile active, increase damage done by 4%.", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Warstone", bonuses = { socket_warstone_chance = 5, socket_warstone_percent = 5 }, tooltip = "While taking damage, if the hit pushes you below 50% life, you have 5% chance every 20s to enter Blood Rage for 6s\nWhile active, increase damage done by 5%.", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Warstone", bonuses = { socket_warstone_chance = 7, socket_warstone_percent = 7 }, tooltip = "While taking damage, if the hit pushes you below 50% life, you have 7% chance every 20s to enter Blood Rage for 6s\nWhile active, increase damage done by 7%.", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Warstone", bonuses = { socket_warstone_chance = 10, socket_warstone_percent = 10 }, tooltip = "While taking damage, if the hit pushes you below 50% life, you have 10% chance every 20s to enter Blood Rage for 6s\nWhile active, increase damage done by 10%." }
        },
    },

    -- 19 --
    boonstone = {
        itemId = 30684,
        name = "Boonstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Knight", "Paladin", "Sorcerer", "Druid" },
        style = "Battle Boon",
        bonuses = {
            socket_boonstone_chance = 2,
            socket_boonstone_speed_percent = 2,
            socket_boonstone_damage_percent = 2,
        },
        tooltip = "Casting a buff spell has 2% chance every 30s to grant Battle Boon for 6s\nWhile active, increase speed by 2% and damage done by 2%",
        tiers = {
            [1] = { name = "Small Boonstone", bonuses = { socket_boonstone_chance = 2, socket_boonstone_speed_percent = 2, socket_boonstone_damage_percent = 2 }, tooltip = "Casting a buff spell has 2% chance every 30s to grant Battle Boon for 6s\nWhile active, increase speed by 2% and damage done by 2%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Boonstone", bonuses = { socket_boonstone_chance = 3, socket_boonstone_speed_percent = 3, socket_boonstone_damage_percent = 3 }, tooltip = "Casting a buff spell has 3% chance every 30s to grant Battle Boon for 6s\nWhile active, increase speed by 3% and damage done by 3%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Boonstone", bonuses = { socket_boonstone_chance = 4, socket_boonstone_speed_percent = 4, socket_boonstone_damage_percent = 4 }, tooltip = "Casting a buff spell has 4% chance every 30s to grant Battle Boon for 6s\nWhile active, increase speed by 4% and damage done by 4%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Boonstone", bonuses = { socket_boonstone_chance = 5, socket_boonstone_speed_percent = 5, socket_boonstone_damage_percent = 5 }, tooltip = "Casting a buff spell has 5% chance every 30s to grant Battle Boon for 6s\nWhile active, increase speed by 5% and damage done by 5%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Boonstone", bonuses = { socket_boonstone_chance = 7, socket_boonstone_speed_percent = 7, socket_boonstone_damage_percent = 7 }, tooltip = "Casting a buff spell has 7% chance every 30s to grant Battle Boon for 6s\nWhile active, increase speed by 7% and damage done by 7%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Boonstone", bonuses = { socket_boonstone_chance = 10, socket_boonstone_speed_percent = 10, socket_boonstone_damage_percent = 10 }, tooltip = "Casting a buff spell has 10% chance every 30s to grant Battle Boon for 6s\nWhile active, increase speed by 10% and damage done by 10%" }
        },
    },

    -- 20 --
    venomstone = {
        itemId = 30685,
        name = "Venomstone Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Knight", "Paladin", "Sorcerer", "Druid" },
        style = "Venom Guard",
        effect = 403,
        bonuses = {
            socket_venomstone_chance = 2,
            socket_venomstone_percent = 0.3,
        },
        tooltip = "When receiving a hit, you have 2% chance every 20s to poison the attacker for 6s\nThe poison deals 0.3% of its max life every second.\nDetails: Percent: 0.3%",
        tiers = {
            [1] = { name = "Small Venomstone", bonuses = { socket_venomstone_chance = 2, socket_venomstone_percent = 0.3 }, tooltip = "When receiving a hit, you have 2% chance every 20s to poison the attacker for 6s\nThe poison deals 0.3% of its max life every second.\nDetails: Percent: 0.3%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Venomstone", bonuses = { socket_venomstone_chance = 3, socket_venomstone_percent = 0.5 }, tooltip = "When receiving a hit, you have 3% chance every 20s to poison the attacker for 6s\nThe poison deals 2% of its max life every second.\nDetails: Percent: 0.5%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Venomstone", bonuses = { socket_venomstone_chance = 4, socket_venomstone_percent = 0.75 }, tooltip = "When receiving a hit, you have 4% chance every 20s to poison the attacker for 6s\nThe poison deals 3% of its max life every second.\nDetails: Percent: 0.75%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Venomstone", bonuses = { socket_venomstone_chance = 5, socket_venomstone_percent = 1 }, tooltip = "When receiving a hit, you have 5% chance every 20s to poison the attacker for 6s\nThe poison deals 4% of its max life every second.\nDetails: Percent: 1%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Venomstone", bonuses = { socket_venomstone_chance = 7, socket_venomstone_percent = 1.25 }, tooltip = "When receiving a hit, you have 7% chance every 20s to poison the attacker for 6s\nThe poison deals 5% of its max life every second.\nDetails: Percent: 1.25%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Venomstone", bonuses = { socket_venomstone_chance = 10, socket_venomstone_percent = 1.75 }, tooltip = "When receiving a hit, you have 10% chance every 20s to poison the attacker for 6s\nThe poison deals 6% of its max life every second.\nDetails: Percent: 1.75%" }
        },
    },
    -- 21 --
    dreadstone = {
        itemId = 30686,
        name = "Dreadstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Knight", "Paladin", "Sorcerer", "Druid" },
        style = "Terror Pulse",
        bonuses = {
            socket_dreadstone_chance = 2,
            socket_dreadstone_duration = 4,
        },
        tooltip = "When receiving a hit, you have 2% chance every 20s to fear nearby enemies for 4s.\nDetails: Duration: 4s",
        tiers = {
            [1] = { name = "Small Dreadstone", bonuses = { socket_dreadstone_chance = 2, socket_dreadstone_duration = 4 }, tooltip = "When receiving a hit, you have 2% chance every 20s to fear nearby enemies for 4s.\nDetails: Duration: 4s", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Dreadstone", bonuses = { socket_dreadstone_chance = 3, socket_dreadstone_duration = 4 }, tooltip = "When receiving a hit, you have 3% chance every 20s to fear nearby enemies for 4s.\nDetails: Duration: 4s", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Dreadstone", bonuses = { socket_dreadstone_chance = 4, socket_dreadstone_duration = 4 }, tooltip = "When receiving a hit, you have 4% chance every 20s to fear nearby enemies for 4s.\nDetails: Duration: 4s", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Dreadstone", bonuses = { socket_dreadstone_chance = 5, socket_dreadstone_duration = 4 }, tooltip = "When receiving a hit, you have 5% chance every 20s to fear nearby enemies for 4s.\nDetails: Duration: 4s", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Dreadstone", bonuses = { socket_dreadstone_chance = 7, socket_dreadstone_duration = 5 }, tooltip = "When receiving a hit, you have 7% chance every 20s to fear nearby enemies for 5s.\nDetails: Duration: 5s", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Dreadstone", bonuses = { socket_dreadstone_chance = 10, socket_dreadstone_duration = 6 }, tooltip = "When receiving a hit, you have 10% chance every 20s to fear nearby enemies for 6s.\nDetails: Duration: 6s" }
        },
    },

    -- 22 --
    spiritstone = {
        itemId = 30687,
        name = "Spiritstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Knight", "Paladin", "Sorcerer", "Druid" },
        style = "Spirit Recovery",
        bonuses = {
            socket_spiritstone_chance = 4,
            socket_spiritstone_health = 10,
            socket_spiritstone_mana = 10,
        },
        tooltip = "When receiving a hit, you have 4% chance every 30s to restore 10 health and 10 mana every second for 10s",
        tiers = {
            [1] = { name = "Small Spiritstone", bonuses = { socket_spiritstone_chance = 4, socket_spiritstone_health = 10, socket_spiritstone_mana = 10 }, tooltip = "When receiving a hit, you have 4% chance every 30s to restore 10 health and 10 mana every second for 10s", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Spiritstone", bonuses = { socket_spiritstone_chance = 6, socket_spiritstone_health = 30, socket_spiritstone_mana = 30 }, tooltip = "When receiving a hit, you have 6% chance every 30s to restore 30 health and 30 mana every second for 10s", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Spiritstone", bonuses = { socket_spiritstone_chance = 8, socket_spiritstone_health = 50, socket_spiritstone_mana = 50 }, tooltip = "When receiving a hit, you have 8% chance every 30s to restore 50 health and 50 mana every second for 10s", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Spiritstone", bonuses = { socket_spiritstone_chance = 12, socket_spiritstone_health = 75, socket_spiritstone_mana = 75 }, tooltip = "When receiving a hit, you have 12% chance every 30s to restore 75 health and 75 mana every second for 10s", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Spiritstone", bonuses = { socket_spiritstone_chance = 15, socket_spiritstone_health = 100, socket_spiritstone_mana = 100 }, tooltip = "When receiving a hit, you have 15% chance every 30s to restore 100 health and 100 mana every second for 10s", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Spiritstone", bonuses = { socket_spiritstone_chance = 20, socket_spiritstone_health = 150, socket_spiritstone_mana = 150 }, tooltip = "When receiving a hit, you have 20% chance every 30s to restore 150 health and 150 mana every second for 10s" }
        },
    },

    -- 23 --
    voidstone = {
        itemId = 30688,
        name = "Voidstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Knight", "Paladin", "Sorcerer", "Druid" },
        style = "Void Mark",
        bonuses = {
            socket_voidstone_chance = 2,
            socket_voidstone_percent = 2,
        },
        tooltip = "Dealing damage has 2% chance every 20s to apply Void Mark for 6s\nWhile marked, the target takes 2% more damage from your hits",
        tiers = {
            [1] = { name = "Small Voidstone", bonuses = { socket_voidstone_chance = 2, socket_voidstone_percent = 2 }, tooltip = "Dealing damage has 2% chance every 20s to apply Void Mark for 6s\nWhile marked, the target takes 2% more damage from your hits.", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Voidstone", bonuses = { socket_voidstone_chance = 3, socket_voidstone_percent = 3 }, tooltip = "Dealing damage has 3% chance every 20s to apply Void Mark for 6s\nWhile marked, the target takes 3% more damage from your hits.", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Voidstone", bonuses = { socket_voidstone_chance = 4, socket_voidstone_percent = 4 }, tooltip = "Dealing damage has 4% chance every 20s to apply Void Mark for 6s\nWhile marked, the target takes 4% more damage from your hits.", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Voidstone", bonuses = { socket_voidstone_chance = 5, socket_voidstone_percent = 5 }, tooltip = "Dealing damage has 5% chance every 20s to apply Void Mark for 6s\nWhile marked, the target takes 5% more damage from your hits.", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Voidstone", bonuses = { socket_voidstone_chance = 7, socket_voidstone_percent = 7 }, tooltip = "Dealing damage has 7% chance every 20s to apply Void Mark for 6s\nWhile marked, the target takes 7% more damage from your hits.", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Voidstone", bonuses = { socket_voidstone_chance = 10, socket_voidstone_percent = 10 }, tooltip = "Dealing damage has 10% chance every 20s to apply Void Mark for 6s\nWhile marked, the target takes 10% more damage from your hits." }
        },
    },
    -- 24 --
    gravitystone = {
        itemId = 30689,
        name = "Gravitystone Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Knight", "Paladin", "Sorcerer", "Druid" },
        style = "Gravity Field",
        bonuses = {
            socket_gravitystone_chance = 2,
            socket_gravitystone_percent = 1,
        },
        effect = 405,
        tooltip = "Dealing damage has 2% chance every 25s to create a gravity field for 6s\nEnemies around the target are slowed, pulled inward, and take 1% of the triggering hit each second",
        tiers = {
            [1] = { name = "Small Gravitystone", bonuses = { socket_gravitystone_chance = 2, socket_gravitystone_percent = 1 }, tooltip = "Dealing damage has 2% chance every 25s to create a gravity field for 6s\nEnemies around the target are slowed, pulled inward, and take 1% of the triggering hit each second.", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Gravitystone", bonuses = { socket_gravitystone_chance = 3, socket_gravitystone_percent = 2 }, tooltip = "Dealing damage has 3% chance every 25s to create a gravity field for 6s\nEnemies around the target are slowed, pulled inward, and take 2% of the triggering hit each second.", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Gravitystone", bonuses = { socket_gravitystone_chance = 4, socket_gravitystone_percent = 3 }, tooltip = "Dealing damage has 4% chance every 25s to create a gravity field for 6s\nEnemies around the target are slowed, pulled inward, and take 3% of the triggering hit each second.", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Gravitystone", bonuses = { socket_gravitystone_chance = 5, socket_gravitystone_percent = 4 }, tooltip = "Dealing damage has 5% chance every 25s to create a gravity field for 6s\nEnemies around the target are slowed, pulled inward, and take 4% of the triggering hit each second.", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Gravitystone", bonuses = { socket_gravitystone_chance = 7, socket_gravitystone_percent = 5 }, tooltip = "Dealing damage has 7% chance every 25s to create a gravity field for 6s\nEnemies around the target are slowed, pulled inward, and take 5% of the triggering hit each second.", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Gravitystone", bonuses = { socket_gravitystone_chance = 10, socket_gravitystone_percent = 7 }, tooltip = "Dealing damage has 10% chance every 25s to create a gravity field for 6s\nEnemies around the target are slowed, pulled inward, and take 7% of the triggering hit each second." }
        },
    },
    -- 25 --
    chronostone = {
        itemId = 30690,
        name = "Chronostone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Knight", "Paladin", "Sorcerer", "Druid" },
        style = "Time Slip",
        bonuses = {
            socket_chronostone_chance = 2,
            socket_chronostone_percent = 2,
        },
        tooltip = "When receiving a hit, you have 2% chance every 25s to gain Time Slip for 6s\nWhile active, your spell cooldowns recover 2% faster.\nDetails: Percent: 2%",
        tiers = {
            [1] = { name = "Small Chronostone", bonuses = { socket_chronostone_chance = 2, socket_chronostone_percent = 2 }, tooltip = "When receiving a hit, you have 2% chance every 25s to gain Time Slip for 6s\nWhile active, your spell cooldowns recover 2% faster.\nDetails: Percent: 2%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Chronostone", bonuses = { socket_chronostone_chance = 3, socket_chronostone_percent = 3 }, tooltip = "When receiving a hit, you have 3% chance every 25s to gain Time Slip for 6s\nWhile active, your spell cooldowns recover 3% faster.\nDetails: Percent: 3%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Chronostone", bonuses = { socket_chronostone_chance = 4, socket_chronostone_percent = 4 }, tooltip = "When receiving a hit, you have 4% chance every 25s to gain Time Slip for 6s\nWhile active, your spell cooldowns recover 4% faster.\nDetails: Percent: 4%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Chronostone", bonuses = { socket_chronostone_chance = 5, socket_chronostone_percent = 5 }, tooltip = "When receiving a hit, you have 5% chance every 25s to gain Time Slip for 6s\nWhile active, your spell cooldowns recover 5% faster.\nDetails: Percent: 5%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Chronostone", bonuses = { socket_chronostone_chance = 7, socket_chronostone_percent = 7 }, tooltip = "When receiving a hit, you have 7% chance every 25s to gain Time Slip for 6s\nWhile active, your spell cooldowns recover 7% faster.\nDetails: Percent: 7%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Chronostone", bonuses = { socket_chronostone_chance = 10, socket_chronostone_percent = 10 }, tooltip = "When receiving a hit, you have 10% chance every 25s to gain Time Slip for 6s\nWhile active, your spell cooldowns recover 10% faster.\nDetails: Percent: 10%" }
        },
    },
    -- 26 --
    marksmanstone = {
        itemId = 30691,
        name = "Marksmanstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Paladin" },
        style = "Volley Echo",
        bonuses = {
            socket_marksmanstone_chance = 2,
        },
        tooltip = "Arrow and bolt hits have 2% chance every 20s to fire an extra shot at the same target",
        tiers = {
            [1] = { name = "Small Marksmanstone", bonuses = { socket_marksmanstone_chance = 2 }, tooltip = "Arrow and bolt hits have 2% chance every 20s to fire an extra shot at the same target", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Marksmanstone", bonuses = { socket_marksmanstone_chance = 4 }, tooltip = "Arrow and bolt hits have 4% chance every 20s to fire an extra shot at the same target", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Marksmanstone", bonuses = { socket_marksmanstone_chance = 6 }, tooltip = "Arrow and bolt hits have 6% chance every 20s to fire an extra shot at the same target", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Marksmanstone", bonuses = { socket_marksmanstone_chance = 8 }, tooltip = "Arrow and bolt hits have 8% chance every 20s to fire an extra shot at the same target", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Marksmanstone", bonuses = { socket_marksmanstone_chance = 10 }, tooltip = "Arrow and bolt hits have 10% chance every 20s to fire an extra shot at the same target", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Marksmanstone", bonuses = { socket_marksmanstone_chance = 15 }, tooltip = "Arrow and bolt hits have 15% chance every 20s to fire an extra shot at the same target" }
        },
    },
    -- 27 --
    battlestone = {
        itemId = 30692,
        name = "Battlestone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Knight" },
        style = "Spell Echo",
        bonuses = {
            socket_battlestone_chance = 2,
        },
        tooltip = "Attack spells have 2% chance every 25s to echo their damage on the next spell hit",
        tiers = {
            [1] = { name = "Small Battlestone", bonuses = { socket_battlestone_chance = 2 }, tooltip = "Attack spells have 2% chance every 25s to echo their damage on the next spell hit", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Battlestone", bonuses = { socket_battlestone_chance = 3 }, tooltip = "Attack spells have 3% chance every 25s to echo their damage on the next spell hit", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Battlestone", bonuses = { socket_battlestone_chance = 4 }, tooltip = "Attack spells have 4% chance every 25s to echo their damage on the next spell hit", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Battlestone", bonuses = { socket_battlestone_chance = 5 }, tooltip = "Attack spells have 5% chance every 25s to echo their damage on the next spell hit", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Battlestone", bonuses = { socket_battlestone_chance = 7 }, tooltip = "Attack spells have 7% chance every 25s to echo their damage on the next spell hit", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Battlestone", bonuses = { socket_battlestone_chance = 10 }, tooltip = "Attack spells have 10% chance every 25s to echo their damage on the next spell hit" }
        },
    },
    -- 28 --
    arcanestone = {
        itemId = 30693,
        name = "Arcanestone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "wand", "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Illusionist", "Sorcerer", "Druid" },
        style = "Mana Echo",
        bonuses = {
            socket_arcanestone_chance = 2,
        },
        tooltip = "Attack spells have 2% chance every 25s to refund the mana spent on the cast",
        tiers = {
            [1] = { name = "Small Arcanestone", bonuses = { socket_arcanestone_chance = 2 }, tooltip = "Attack spells have 2% chance every 25s to refund the mana spent on the cast", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Arcanestone", bonuses = { socket_arcanestone_chance = 3 }, tooltip = "Attack spells have 3% chance every 25s to refund the mana spent on the cast", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Arcanestone", bonuses = { socket_arcanestone_chance = 4 }, tooltip = "Attack spells have 4% chance every 25s to refund the mana spent on the cast", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Arcanestone", bonuses = { socket_arcanestone_chance = 5 }, tooltip = "Attack spells have 5% chance every 25s to refund the mana spent on the cast", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Arcanestone", bonuses = { socket_arcanestone_chance = 7 }, tooltip = "Attack spells have 7% chance every 25s to refund the mana spent on the cast", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Arcanestone", bonuses = { socket_arcanestone_chance = 10 }, tooltip = "Attack spells have 10% chance every 25s to refund the mana spent on the cast" }
        },
    },
    -- 29 --
    mendstone = {
        itemId = 30694,
        name = "Mendstone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "weapon", "ring", "necklace", "armor", "legs" },
        bestFor = { "Monk" },
        style = "Sacred Mending",
        effect = 402,
        bonuses = {
            socket_mendstone_chance = 2,
        },
        tooltip = "Healing spells have 2% chance every 25s to empower you for 6s\nWhile active, your self-healing spells restore double health",
        tiers = {
            [1] = { name = "Small Mendstone", bonuses = { socket_mendstone_chance = 2 }, tooltip = "Healing spells have 2% chance every 25s to empower you for 6s\nWhile active, your self-healing spells restore double health", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Mendstone", bonuses = { socket_mendstone_chance = 3 }, tooltip = "Healing spells have 3% chance every 25s to empower you for 6s\nWhile active, your self-healing spells restore double health", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Mendstone", bonuses = { socket_mendstone_chance = 4 }, tooltip = "Healing spells have 4% chance every 25s to empower you for 6s\nWhile active, your self-healing spells restore double health", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Mendstone", bonuses = { socket_mendstone_chance = 5 }, tooltip = "Healing spells have 5% chance every 25s to empower you for 6s\nWhile active, your self-healing spells restore double health", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Mendstone", bonuses = { socket_mendstone_chance = 7 }, tooltip = "Healing spells have 7% chance every 25s to empower you for 6s\nWhile active, your self-healing spells restore double health", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Mendstone", bonuses = { socket_mendstone_chance = 10 }, tooltip = "Healing spells have 10% chance every 25s to empower you for 6s\nWhile active, your self-healing spells restore double health" }
        },
    },
    -- 30 --
    totemgem = {
        itemId = 30695,
        name = "Totem Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "weapon", "wand", "ring", "necklace", "armor", "legs" },
        bestFor = { "Knight", "Paladin", "Sorcerer", "Druid", "Monk", "Illusionist" },
        style = "Area Control",
        totems = {
            fire = { itemId = 30661 },
            healing = { itemId = 30663 },
            storm = { itemId = 30660 },
            protection = { itemId = 30662 },
        },
        bonuses = {
            socket_totem_chance = 2,
            socket_totem_power = 10,
        },
        tooltip = "Dealing damage has 2% chance every 25s to summon a random totem for 10s\nFire burns nearby enemies, Healing restores allies, Storm chains lightning, Protection reduces damage nearby.\nDetails: Power: 10",
        tiers = {
            [1] = { name = "Small Totem Gem", bonuses = { socket_totem_chance = 2, socket_totem_power = 10 }, tooltip = "Dealing damage has 2% chance every 25s to summon a random totem for 10s\nFire burns nearby enemies, Healing restores allies, Storm chains lightning, Protection reduces damage nearby.\nDetails: Power: 10", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Totem Gem", bonuses = { socket_totem_chance = 3, socket_totem_power = 11 }, tooltip = "Dealing damage has 3% chance every 25s to summon a random totem for 10s\nFire burns nearby enemies, Healing restores allies, Storm chains lightning, Protection reduces damage nearby.\nDetails: Power: 11", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Totem Gem", bonuses = { socket_totem_chance = 4, socket_totem_power = 12 }, tooltip = "Dealing damage has 4% chance every 25s to summon a random totem for 10s\nFire burns nearby enemies, Healing restores allies, Storm chains lightning, Protection reduces damage nearby.\nDetails: Power: 12", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Totem Gem", bonuses = { socket_totem_chance = 5, socket_totem_power = 13 }, tooltip = "Dealing damage has 5% chance every 25s to summon a random totem for 10s\nFire burns nearby enemies, Healing restores allies, Storm chains lightning, Protection reduces damage nearby.\nDetails: Power: 13", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Totem Gem", bonuses = { socket_totem_chance = 7, socket_totem_power = 15 }, tooltip = "Dealing damage has 7% chance every 25s to summon a random totem for 10s\nFire burns nearby enemies, Healing restores allies, Storm chains lightning, Protection reduces damage nearby.\nDetails: Power: 15", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Totem Gem", bonuses = { socket_totem_chance = 10, socket_totem_power = 20 }, tooltip = "Dealing damage has 10% chance every 25s to summon a random totem for 10s\nFire burns nearby enemies, Healing restores allies, Storm chains lightning, Protection reduces damage nearby.\nDetails: Power: 20" }
        },
    },
    -- 31 --
    sacredlinkgem = {
        itemId = 30696,
        name = "Sacred Link Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "shield", "armor", "ring", "necklace", "helmet", "legs" },
        bestFor = { "Knight", "Paladin", "Monk" },
        style = "Guardian Support",
        bonuses = {
            socket_sacred_link_chance = 2,
            socket_sacred_link_redirect = 10,
            socket_sacred_link_resistance = 10,
            socket_sacred_link_shield = 12,
        },
        tooltip = "When receiving a hit, you have 2% chance every 30s to activate Sacred Link for 6s\nParty only: allies within 7 SQM redirect 10% of incoming damage to you, while you gain 10% resistance.\nDetails: Shield: 12",
        tiers = {
            [1] = { name = "Small Sacred Link Gem", bonuses = { socket_sacred_link_chance = 2, socket_sacred_link_redirect = 10, socket_sacred_link_resistance = 10, socket_sacred_link_shield = 12 }, tooltip = "When receiving a hit, you have 2% chance every 30s to activate Sacred Link for 6s\nParty only: allies within 7 SQM redirect 10% of incoming damage to you, while you gain 10% resistance.\nDetails: Shield: 12", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Sacred Link Gem", bonuses = { socket_sacred_link_chance = 3, socket_sacred_link_redirect = 12, socket_sacred_link_resistance = 11, socket_sacred_link_shield = 17 }, tooltip = "When receiving a hit, you have 3% chance every 30s to activate Sacred Link for 6s\nParty only: allies within 7 SQM redirect 12% of incoming damage to you, while you gain 11% resistance.\nDetails: Shield: 17", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Sacred Link Gem", bonuses = { socket_sacred_link_chance = 4, socket_sacred_link_redirect = 15, socket_sacred_link_resistance = 12, socket_sacred_link_shield = 22 }, tooltip = "When receiving a hit, you have 4% chance every 30s to activate Sacred Link for 6s\nParty only: allies within 7 SQM redirect 15% of incoming damage to you, while you gain 12% resistance.\nDetails: Shield: 22", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Sacred Link Gem", bonuses = { socket_sacred_link_chance = 5, socket_sacred_link_redirect = 18, socket_sacred_link_resistance = 13, socket_sacred_link_shield = 27 }, tooltip = "When receiving a hit, you have 5% chance every 30s to activate Sacred Link for 6s\nParty only: allies within 7 SQM redirect 18% of incoming damage to you, while you gain 13% resistance.\nDetails: Shield: 27", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Sacred Link Gem", bonuses = { socket_sacred_link_chance = 7, socket_sacred_link_redirect = 22, socket_sacred_link_resistance = 15, socket_sacred_link_shield = 32 }, tooltip = "When receiving a hit, you have 7% chance every 30s to activate Sacred Link for 6s\nParty only: allies within 7 SQM redirect 22% of incoming damage to you, while you gain 15% resistance.\nDetails: Shield: 32", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Sacred Link Gem", bonuses = { socket_sacred_link_chance = 10, socket_sacred_link_redirect = 25, socket_sacred_link_resistance = 17, socket_sacred_link_shield = 42 }, tooltip = "When receiving a hit, you have 10% chance every 30s to activate Sacred Link for 6s\nParty only: allies within 7 SQM redirect 25% of incoming damage to you, while you gain 17% resistance.\nDetails: Shield: 42" }
        },
    },
    -- 32 --
    gemofreversal = {
        itemId = 30697,
        name = "Gem of Reversal",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "weapon", "wand", "ring", "necklace", "armor", "legs" },
        bestFor = { "Paladin", "Monk", "Druid", "Illusionist" },
        style = "Twisted Recovery",
        bonuses = {
            socket_reversal_chance = 2,
            socket_reversal_store = 10,
            socket_reversal_holy = 10,
        },
        tooltip = "When receiving a hit, you have 2% chance every 30s to gain Reversal for 6s\nOverhealing becomes holy damage around you, and 10% of damage taken is stored as delayed healing",
        tiers = {
            [1] = { name = "Small Gem of Reversal", bonuses = { socket_reversal_chance = 2, socket_reversal_store = 10, socket_reversal_holy = 12 }, tooltip = "When receiving a hit, you have 2% chance every 30s to gain Reversal for 6s\nOverhealing becomes holy damage around you, and 10% of damage taken is stored as delayed healing.\nDetails: Holy: 12", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Gem of Reversal", bonuses = { socket_reversal_chance = 3, socket_reversal_store = 12, socket_reversal_holy = 15 }, tooltip = "When receiving a hit, you have 3% chance every 30s to gain Reversal for 6s\nOverhealing becomes holy damage around you, and 12% of damage taken is stored as delayed healing.\nDetails: Holy: 15", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Gem of Reversal", bonuses = { socket_reversal_chance = 4, socket_reversal_store = 15, socket_reversal_holy = 18 }, tooltip = "When receiving a hit, you have 4% chance every 30s to gain Reversal for 6s\nOverhealing becomes holy damage around you, and 15% of damage taken is stored as delayed healing.\nDetails: Holy: 18", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Gem of Reversal", bonuses = { socket_reversal_chance = 5, socket_reversal_store = 18, socket_reversal_holy = 22 }, tooltip = "When receiving a hit, you have 5% chance every 30s to gain Reversal for 6s\nOverhealing becomes holy damage around you, and 18% of damage taken is stored as delayed healing.\nDetails: Holy: 22", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Gem of Reversal", bonuses = { socket_reversal_chance = 7, socket_reversal_store = 20, socket_reversal_holy = 25 }, tooltip = "When receiving a hit, you have 7% chance every 30s to gain Reversal for 6s\nOverhealing becomes holy damage around you, and 20% of damage taken is stored as delayed healing.\nDetails: Holy: 25", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Gem of Reversal", bonuses = { socket_reversal_chance = 10, socket_reversal_store = 22, socket_reversal_holy = 30 }, tooltip = "When receiving a hit, you have 10% chance every 30s to gain Reversal for 6s\nOverhealing becomes holy damage around you, and 22% of damage taken is stored as delayed healing" }
        },
    },
    -- 33 --
    revenantstone = {
        itemId = 30698,
        name = "Revenant Stone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "weapon", "wand", "ring", "necklace", "armor", "legs" },
        bestFor = { "Any Vocation" },
        style = "Undead",
        bonuses = {
            socket_revenant_chance = 1,
            socket_revenant_duration = 20,
        },
        tooltip = "When you kill a monster, 1% chance to raise a revenant servant for 20s.\nDetails: Duration: 20s",
        tiers = {
            [1] = { name = "Small Revenant Stone", bonuses = { socket_revenant_chance = 1, socket_revenant_duration = 20 }, tooltip = "When you kill a monster, 1% chance to raise a revenant servant for 20s.\nDetails: Duration: 20s", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Revenant Stone", bonuses = { socket_revenant_chance = 3, socket_revenant_duration = 20 }, tooltip = "When you kill a monster, 3% chance to raise a revenant servant for 20s.\nDetails: Duration: 20s", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Revenant Stone", bonuses = { socket_revenant_chance = 5, socket_revenant_duration = 20 }, tooltip = "When you kill a monster, 5% chance to raise a revenant servant for 20s.\nDetails: Duration: 20s", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Revenant Stone", bonuses = { socket_revenant_chance = 7, socket_revenant_duration = 20 }, tooltip = "When you kill a monster, 7% chance to raise a revenant servant for 20s.\nDetails: Duration: 20s", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Revenant Stone", bonuses = { socket_revenant_chance = 10, socket_revenant_duration = 20 }, tooltip = "When you kill a monster, 10% chance to raise a revenant servant for 20s.\nDetails: Duration: 20s", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Revenant Stone", bonuses = { socket_revenant_chance = 12, socket_revenant_duration = 20 }, tooltip = "When you kill a monster, 12% chance to raise a revenant servant for 20s.\nDetails: Duration: 20s" }
        },
    },
    -- 34 --
    runeheartstone = {
        itemId = 30699,
        name = "Runeheart Stone Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "ring", "necklace", "belt", "armor" },
        bestFor = { "Any Vocation" },
        style = "Living Engraving",
        runes = {
            { id = 2268, name = "Sudden Death Rune" },
            { id = 2274, name = "Avalanche Rune" },
            { id = 2304, name = "Great Fireball Rune" },
            { id = 2313, name = "Explosion Rune" },
            { id = 2287, name = "Light Magic Missile Rune" },
            { id = 2311, name = "Heavy Magic Missile Rune" },
            { id = 2293, name = "Magic Wall Rune" },
            { id = 2261, name = "Destroy Field Rune" },
        },
        bonuses = {
            socket_runeheart_interval = 600,
        },
        tooltip = "Every 10 minutes, creates a random combat rune in your backpack.\nDetails: Runeheart Interval: 600s",
        tiers = {
            [1] = { name = "Small Runeheart Stone", bonuses = { socket_runeheart_interval = 300 }, tooltip = "Every 10 minutes, creates a random combat rune in your backpack.\nDetails: Interval: 300s", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Runeheart Stone", bonuses = { socket_runeheart_interval = 540 }, tooltip = "Every 9 minutes, creates a random combat rune in your backpack.\nDetails: Interval: 540s", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Runeheart Stone", bonuses = { socket_runeheart_interval = 420 }, tooltip = "Every 7 minutes, creates a random combat rune in your backpack.\nDetails: Interval: 420s", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Runeheart Stone", bonuses = { socket_runeheart_interval = 300 }, tooltip = "Every 5 minutes, creates a random combat rune in your backpack.\nDetails: Interval: 300s", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Runeheart Stone", bonuses = { socket_runeheart_interval = 240 }, tooltip = "Every 4 minutes, creates a random combat rune in your backpack.\nDetails: Interval: 240s", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Runeheart Stone", bonuses = { socket_runeheart_interval = 120 }, tooltip = "Every 2 minutes, creates a random combat rune in your backpack.\nDetails: Interval: 120s" }
        },
    },
    -- 35 --
    dreamcatcherstone = {
        itemId = 30700,
        name = "Dreamcatcher Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace", "belt", "armor" },
        bestFor = { "Any Vocation" },
        style = "Nightmares",
        bonuses = {
            socket_dreamcatcher_chance = 1,
            socket_dreamcatcher_min = 1,
            socket_dreamcatcher_max = 2,
        },
        tooltip = "Monster kills have 1% chance to grant 1 Gem Power directly to you.\nDetails: Min: 1, Max: 2",
        tiers = {
            [1] = { name = "Small Dreamcatcher Gem", bonuses = { socket_dreamcatcher_chance = 2, socket_dreamcatcher_min = 1, socket_dreamcatcher_max = 1 }, tooltip = "Monster kills have 1% chance to grant 1 Gem Power directly to you.\nDetails: Chance: 2%, Min: 1, Max: 1", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Dreamcatcher Gem", bonuses = { socket_dreamcatcher_chance = 3, socket_dreamcatcher_min = 1, socket_dreamcatcher_max = 2 }, tooltip = "Monster kills have 1% chance to grant 1-2 Gem Power directly to you.\nDetails: Chance: 3%, Min: 1, Max: 2", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Dreamcatcher Gem", bonuses = { socket_dreamcatcher_chance = 4, socket_dreamcatcher_min = 1, socket_dreamcatcher_max = 2 }, tooltip = "Monster kills have 2% chance to grant 1-2 Gem Power directly to you.\nDetails: Chance: 4%, Min: 1, Max: 2", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Dreamcatcher Gem", bonuses = { socket_dreamcatcher_chance = 5, socket_dreamcatcher_min = 1, socket_dreamcatcher_max = 3 }, tooltip = "Monster kills have 2% chance to grant 1-3 Gem Power directly to you.\nDetails: Chance: 5%, Min: 1, Max: 3", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Dreamcatcher Gem", bonuses = { socket_dreamcatcher_chance = 7, socket_dreamcatcher_min = 2, socket_dreamcatcher_max = 3 }, tooltip = "Monster kills have 3% chance to grant 2-3 Gem Power directly to you.\nDetails: Chance: 7%, Min: 2, Max: 3", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Dreamcatcher Gem", bonuses = { socket_dreamcatcher_chance = 10, socket_dreamcatcher_min = 2, socket_dreamcatcher_max = 3 }, tooltip = "Monster kills have 10% chance to grant 2-3 Gem Power directly to you.\nDetails: Min: 2, Max: 3" }
        },
    },
    -- 36 --
    mirrorgem = {
        itemId = 30701,
        name = "Mirrorgem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "weapon", "wand", "ring", "necklace", "belt", "armor" },
        bestFor = { "Any Vocation" },
        style = "Spell Reflection",
        bonuses = {
            socket_mirrorgem_cooldown = 30,
            socket_mirrorgem_damage = 15,
        },
        effect = 400,
        tooltip = "Every 30s, mirrors one attack spell hit for 15% damage with no mana cost.\nDetails: Cooldown: 30s",
        tiers = {
            [1] = { name = "Small Mirrorgem", bonuses = { socket_mirrorgem_cooldown = 30, socket_mirrorgem_damage = 15 }, tooltip = "Every 30s, mirrors one attack spell hit for 15% damage with no mana cost.\nDetails: Cooldown: 30s", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Mirrorgem", bonuses = { socket_mirrorgem_cooldown = 30, socket_mirrorgem_damage = 20 }, tooltip = "Every 30s, mirrors one attack spell hit for 20% damage with no mana cost.\nDetails: Cooldown: 30s", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Mirrorgem", bonuses = { socket_mirrorgem_cooldown = 30, socket_mirrorgem_damage = 25 }, tooltip = "Every 30s, mirrors one attack spell hit for 25% damage with no mana cost.\nDetails: Cooldown: 30s", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Mirrorgem", bonuses = { socket_mirrorgem_cooldown = 30, socket_mirrorgem_damage = 30 }, tooltip = "Every 30s, mirrors one attack spell hit for 30% damage with no mana cost.\nDetails: Cooldown: 30s", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Mirrorgem", bonuses = { socket_mirrorgem_cooldown = 30, socket_mirrorgem_damage = 40 }, tooltip = "Every 30s, mirrors one attack spell hit for 40% damage with no mana cost.\nDetails: Cooldown: 30s", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Mirrorgem", bonuses = { socket_mirrorgem_cooldown = 30, socket_mirrorgem_damage = 50 }, tooltip = "Every 30s, mirrors one attack spell hit for 50% damage with no mana cost.\nDetails: Cooldown: 30s" }
        },
    },
    -- 37 --
    forgestone = {
        itemId = 30702,
        name = "Forge Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "ring", "necklace", "belt", "gloves" },
        bestFor = { "Any Vocation" },
        style = "Increase Rarity",
        bonuses = {
            socket_forge_rarity_chance = 3,
        },
        tooltip = "Crafted equipment has +3% chance to gain rarity",
        tiers = {
            [1] = { name = "Small Forge Gem", bonuses = { socket_forge_rarity_chance = 3 }, tooltip = "Crafted equipment has +3% chance to gain rarity", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Forge Gem", bonuses = { socket_forge_rarity_chance = 4 }, tooltip = "Crafted equipment has +4% chance to gain rarity", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Forge Gem", bonuses = { socket_forge_rarity_chance = 5 }, tooltip = "Crafted equipment has +5% chance to gain rarity", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Forge Gem", bonuses = { socket_forge_rarity_chance = 6 }, tooltip = "Crafted equipment has +6% chance to gain rarity", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Forge Gem", bonuses = { socket_forge_rarity_chance = 8 }, tooltip = "Crafted equipment has +8% chance to gain rarity", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Forge Gem", bonuses = { socket_forge_rarity_chance = 10 }, tooltip = "Crafted equipment has +10% chance to gain rarity" }
        },
    },
    -- 38 --
    fortunestone = {
        itemId = 30703,
        name = "Fortune Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "ring", "necklace", "belt", "gloves" },
        bestFor = { "Any Vocation" },
        style = "Loot Rarity",
        bonuses = {
            socket_loot_rarity_chance = 3,
        },
        tooltip = "Monster equipment loot has +3% chance to gain rarity",
        tiers = {
            [1] = { name = "Small Fortune Gem", bonuses = { socket_loot_rarity_chance = 3 }, tooltip = "Monster equipment loot has +3% chance to gain rarity", storage = 980101, storageValue = 1, upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Fortune Gem", bonuses = { socket_loot_rarity_chance = 4 }, tooltip = "Monster equipment loot has +4% chance to gain rarity", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Fortune Gem", bonuses = { socket_loot_rarity_chance = 5 }, tooltip = "Monster equipment loot has +5% chance to gain rarity", storage = 980102, storageValue = 1, upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Fortune Gem", bonuses = { socket_loot_rarity_chance = 6 }, tooltip = "Monster equipment loot has +6% chance to gain rarity", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Fortune Gem", bonuses = { socket_loot_rarity_chance = 8 }, storage = 980103, storageValue = 1, tooltip = "Monster equipment loot has +8% chance to gain rarity", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Fortune Gem", bonuses = { socket_loot_rarity_chance = 10 }, storage = 980104, storageValue = 1, tooltip = "Monster equipment loot has +10% chance to gain rarity" }
        },
    },
    -- 39 --
    shockwavestone = {
        itemId = 30704,
        name = "Shockwave Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "armor", "shield", "ring", "necklace", "belt", "boots" },
        bestFor = { "Any Vocation" },
        style = "Repulse",
        bonuses = {
            socket_repulse_chance = 3,
            socket_repulse_cooldown = 30,
            socket_repulse_range = 1,
            socket_repulse_push = 1,
            socket_repulse_damage = 80,
            socket_repulse_collision_damage = 140,
        },
        tooltip = "When hit, has a chance every 30s to release a shockwave that pushes nearby monsters away. Monsters blocked by terrain take bonus collision damage.\nDetails: Repulse Chance: 3%, Repulse Cooldown: 30s, Repulse Range: 1 SQM, Repulse Push: 1, Repulse Damage: 80, Repulse Collision Damage: 140",
        tiers = {
            [1] = { name = "Small Shockwave Gem", bonuses = { socket_repulse_chance = 2, socket_repulse_cooldown = 30, socket_repulse_range = 1, socket_repulse_push = 1, socket_repulse_damage = 80, socket_repulse_collision_damage = 140 }, tooltip = "When hit, has a chance every 30s to release a shockwave that pushes nearby monsters away. Monsters blocked by terrain take bonus collision damage.\nDetails: Repulse Chance: 2%, Repulse Cooldown: 30s, Repulse Range: 1 SQM, Repulse Push: 1, Repulse Damage: 80, Repulse Collision Damage: 140", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Shockwave Gem", bonuses = { socket_repulse_chance = 3, socket_repulse_cooldown = 30, socket_repulse_range = 1, socket_repulse_push = 1, socket_repulse_damage = 85, socket_repulse_collision_damage = 145 }, tooltip = "When hit, has a chance every 30s to release a shockwave that pushes nearby monsters away. Monsters blocked by terrain take bonus collision damage.\nDetails: Repulse Chance: 3%, Repulse Cooldown: 30s, Repulse Range: 1 SQM, Repulse Push: 1, Repulse Damage: 85, Repulse Collision Damage: 145", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Shockwave Gem", bonuses = { socket_repulse_chance = 4, socket_repulse_cooldown = 30, socket_repulse_range = 2, socket_repulse_push = 1, socket_repulse_damage = 90, socket_repulse_collision_damage = 150 }, tooltip = "When hit, has a chance every 30s to release a shockwave that pushes nearby monsters away. Monsters blocked by terrain take bonus collision damage.\nDetails: Repulse Chance: 4%, Repulse Cooldown: 30s, Repulse Range: 2 SQM, Repulse Push: 1, Repulse Damage: 90, Repulse Collision Damage: 150", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Shockwave Gem", bonuses = { socket_repulse_chance = 5, socket_repulse_cooldown = 30, socket_repulse_range = 2, socket_repulse_push = 1, socket_repulse_damage = 95, socket_repulse_collision_damage = 155 }, tooltip = "When hit, has a chance every 30s to release a shockwave that pushes nearby monsters away. Monsters blocked by terrain take bonus collision damage.\nDetails: Repulse Chance: 5%, Repulse Cooldown: 30s, Repulse Range: 2 SQM, Repulse Push: 1, Repulse Damage: 95, Repulse Collision Damage: 155", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Shockwave Gem", bonuses = { socket_repulse_chance = 7, socket_repulse_cooldown = 30, socket_repulse_range = 3, socket_repulse_push = 1, socket_repulse_damage = 100, socket_repulse_collision_damage = 160 }, tooltip = "When hit, has a chance every 30s to release a shockwave that pushes nearby monsters away. Monsters blocked by terrain take bonus collision damage.\nDetails: Repulse Chance: 7%, Repulse Cooldown: 30s, Repulse Range: 3 SQM, Repulse Push: 1, Repulse Damage: 100, Repulse Collision Damage: 160", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Shockwave Gem", bonuses = { socket_repulse_chance = 10, socket_repulse_cooldown = 30, socket_repulse_range = 3, socket_repulse_push = 1, socket_repulse_damage = 110, socket_repulse_collision_damage = 170 }, tooltip = "When hit, has a chance every 30s to release a shockwave that pushes nearby monsters away. Monsters blocked by terrain take bonus collision damage.\nDetails: Repulse Chance: 10%, Repulse Cooldown: 30s, Repulse Range: 3 SQM, Repulse Push: 1, Repulse Damage: 110, Repulse Collision Damage: 170" }
        },
    },
    -- 40 --
    treasurygem = {
        itemId = 30705,
        name = "Treasury Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "ring", "necklace", "belt", "armor", "weapon", "wand" },
        bestFor = { "Any Vocation" },
        style = "Wealth Chronicle",
        bonuses = {},
        storage = 980151,
        storageValue = 1,
        tooltip = "Records the gold value generated in monster loot while socketed on equipped gear. Its wealth history remains bound to the gem itself.",
        tiers = {
            [1] = {
                name = "Small Treasury Gem",
                bonuses = {},
                tooltip = "Records monster loot gold while socketed on equipped gear. The total remains on the gem even if extracted or traded.",
            }
        }
    },
    -- 41 --
    soulmarkgem = {
        itemId = 30706,
        name = "Soulmark Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace", "belt" },
        bestFor = { "Any Vocation" },
        style = "Unique Hunt Mark",
        bonuses = {
            socket_soulmark_damage = 1,
        },
        tooltip = "First monster hit marks that target. Further hits to the marked target deal +1% damage. New marks can be made every 30s.",
        tiers = {
            [1] = {
                name = "Small Soulmark Gem",
                bonuses = { socket_soulmark_damage = 1 },
                tooltip = "First monster hit marks that target. Further hits to the marked target deal +1% damage. New marks can be made every 30s.",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Soulmark Gem",
                bonuses = { socket_soulmark_damage = 2 },
                tooltip = "First monster hit marks that target. Further hits to the marked target deal +2% damage. New marks can be made every 30s.",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Soulmark Gem",
                bonuses = { socket_soulmark_damage = 3 },
                tooltip = "First monster hit marks that target. Further hits to the marked target deal +3% damage. New marks can be made every 30s.",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Soulmark Gem",
                bonuses = { socket_soulmark_damage = 4 },
                tooltip = "First monster hit marks that target. Further hits to the marked target deal +4% damage. New marks can be made every 30s.",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Soulmark Gem",
                bonuses = { socket_soulmark_damage = 5 },
                tooltip = "First monster hit marks that target. Further hits to the marked target deal +5% damage. New marks can be made every 30s.",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Soulmark Gem",
                bonuses = { socket_soulmark_damage = 6 },
                tooltip = "First monster hit marks that target. Further hits to the marked target deal +6% damage. New marks can be made every 30s."
            }
        }
    },
    -- 42 --
    kingsguardgem = {
        itemId = 30707,
        name = "Kingsguard Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "shield" },
        bestFor = { "Knight", "Paladin" },
        style = "Unique PvP Silence",
        bonuses = {
            socket_kingsguard_chance = 5,
            socket_kingsguard_duration = 2,
            socket_kingsguard_cooldown = 30,
        },
        tooltip = "While guilded, the next PvP hit against you every 30s has 5% chance to silence the attacker for 2s.\nDetails: Duration: 2s, Cooldown: 30s",
        tiers = {
            [1] = { name = "Small Kingsguard Gem", bonuses = { socket_kingsguard_chance = 5, socket_kingsguard_duration = 2, socket_kingsguard_cooldown = 30 }, tooltip = "While guilded, the next PvP hit against you every 30s has 5% chance to silence the attacker for 2s.\nDetails: Duration: 2s, Cooldown: 30s", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Kingsguard Gem", bonuses = { socket_kingsguard_chance = 7, socket_kingsguard_duration = 2, socket_kingsguard_cooldown = 30 }, tooltip = "While guilded, the next PvP hit against you every 30s has 7% chance to silence the attacker for 2s.\nDetails: Duration: 2s, Cooldown: 30s", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Kingsguard Gem", bonuses = { socket_kingsguard_chance = 9, socket_kingsguard_duration = 2, socket_kingsguard_cooldown = 30 }, tooltip = "While guilded, the next PvP hit against you every 30s has 9% chance to silence the attacker for 2s.\nDetails: Duration: 2s, Cooldown: 30s", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Kingsguard Gem", bonuses = { socket_kingsguard_chance = 11, socket_kingsguard_duration = 2, socket_kingsguard_cooldown = 30 }, tooltip = "While guilded, the next PvP hit against you every 30s has 11% chance to silence the attacker for 2s.\nDetails: Duration: 2s, Cooldown: 30s", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Kingsguard Gem", bonuses = { socket_kingsguard_chance = 13, socket_kingsguard_duration = 2, socket_kingsguard_cooldown = 30 }, tooltip = "While guilded, the next PvP hit against you every 30s has 13% chance to silence the attacker for 2s.\nDetails: Duration: 2s, Cooldown: 30s", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Kingsguard Gem", bonuses = { socket_kingsguard_chance = 15, socket_kingsguard_duration = 3, socket_kingsguard_cooldown = 30},
            storage = 980133,
            storageValue = 1,
            tooltip = "While guilded, the next PvP hit against you every 30s has 15% chance to silence the attacker for 3s.\nDetails: Duration: 3s, Cooldown: 30s" }
        },
    },
    -- 43 --
    mimicgem = {
        itemId = 30708,
        name = "Mimic Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace", "belt" },
        bestFor = { "Any Vocation" },
        style = "Unique Living Loot",
        bonuses = {
            socket_mimic_chance = 2,
            socket_mimic_extra_rolls = 1,
        },
        tooltip = "Normal monster kills have 2% chance to spawn a hostile mimic of that monster. Mimics drop one extra loot roll.\nDetails: Extra Rolls: 1",
        tiers = {
            [1] = { name = "Small Mimic Gem", bonuses = { socket_mimic_chance = 2, socket_mimic_extra_rolls = 1 }, tooltip = "Normal monster kills have 1% chance to spawn a hostile mimic of that monster. Mimics drop one extra loot roll.\nDetails: Chance: 2%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Mimic Gem", bonuses = { socket_mimic_chance = 3, socket_mimic_extra_rolls = 1 }, tooltip = "Normal monster kills have 1% chance to spawn a hostile mimic of that monster. Mimics drop one extra loot roll.\nDetails: Chance: 3%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Mimic Gem", bonuses = { socket_mimic_chance = 4, socket_mimic_extra_rolls = 1 }, tooltip = "Normal monster kills have 2% chance to spawn a hostile mimic of that monster. Mimics drop one extra loot roll.\nDetails: Chance: 4%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Mimic Gem", bonuses = { socket_mimic_chance = 5, socket_mimic_extra_rolls = 1 }, tooltip = "Normal monster kills have 2% chance to spawn a hostile mimic of that monster. Mimics drop one extra loot roll.\nDetails: Chance: 5%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Mimic Gem", bonuses = { socket_mimic_chance = 7, socket_mimic_extra_rolls = 1 }, tooltip = "Normal monster kills have 3% chance to spawn a hostile mimic of that monster. Mimics drop one extra loot roll.\nDetails: Chance: 7%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Mimic Gem", bonuses = { socket_mimic_chance = 10, socket_mimic_extra_rolls = 2 }, tooltip = "Normal monster kills have 10% chance to spawn a hostile mimic of that monster. Mimics drop two extra loot roll.\nDetails: Chance: 10%, Extra Rolls: 2" }
        },
    },
    -- 44 --
    cowardscrowngem = {
        itemId = 30709,
        name = "Coward's Crown Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet" },
        bestFor = { "Any Vocation" },
        style = "Unique Panic Blink",
        bonuses = {
            socket_coward_crown_threshold = 5,
            socket_coward_crown_range = 2,
            socket_coward_crown_cooldown = 30,
        },
        tooltip = "When 5+ nearby monsters surround you, blink behind the weakest nearby monster. 30s cooldown.\nDetails: Threshold: 5%, Range: 2 SQM",
        tiers = {
            [1] = { name = "Small Coward's Crown Gem", bonuses = { socket_coward_crown_threshold = 5, socket_coward_crown_range = 2, socket_coward_crown_cooldown = 30 }, tooltip = "When 5+ nearby monsters surround you, blink behind the weakest nearby monster. 30s cooldown.\nDetails: Threshold: 5%, Range: 2 SQM", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Coward's Crown Gem", bonuses = { socket_coward_crown_threshold = 5, socket_coward_crown_range = 3, socket_coward_crown_cooldown = 30 }, tooltip = "When 5+ nearby monsters surround you, blink behind the weakest nearby monster. 30s cooldown.\nDetails: Threshold: 5%, Range: 3 SQM", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Coward's Crown Gem", bonuses = { socket_coward_crown_threshold = 4, socket_coward_crown_range = 3, socket_coward_crown_cooldown = 30 }, tooltip = "When 4+ nearby monsters surround you, blink behind the weakest nearby monster. 30s cooldown.\nDetails: Threshold: 4%, Range: 3 SQM", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Coward's Crown Gem", bonuses = { socket_coward_crown_threshold = 4, socket_coward_crown_range = 3, socket_coward_crown_cooldown = 30 }, tooltip = "When 4+ nearby monsters surround you, blink behind the weakest nearby monster. 30s cooldown.\nDetails: Threshold: 4%, Range: 3 SQM", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Coward's Crown Gem", bonuses = { socket_coward_crown_threshold = 3, socket_coward_crown_range = 3, socket_coward_crown_cooldown = 30 }, tooltip = "When 3+ nearby monsters surround you, blink behind the weakest nearby monster. 30s cooldown.\nDetails: Threshold: 3%, Range: 3 SQM", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Coward's Crown Gem", bonuses = { socket_coward_crown_threshold = 3, socket_coward_crown_range = 4, socket_coward_crown_cooldown = 30 }, tooltip = "When 3+ nearby monsters surround you, blink behind the weakest nearby monster. 30s cooldown.\nDetails: Threshold: 3%, Range: 4 SQM" }
        },
    },
    -- 45 --
    betrayalgem = {
        itemId = 30710,
        name = "Betrayal Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "shield", "ring", "necklace" },
        bestFor = { "Any Vocation" },
        style = "Unique Monster Treason",
        bonuses = {
            socket_betrayal_chance = 5,
            socket_betrayal_duration = 3,
            socket_betrayal_cooldown = 30,
            socket_betrayal_range = 3,
        },
        effect = 400,
        tooltip = "When hit by a normal monster, 5% chance every 30s to make reflect the monster attacks to another nearby monster for 3s.\nDetails: Duration: 3s, Cooldown: 30s, Range: 3 SQM",
        tiers = {
            [1] = { name = "Small Betrayal Gem", bonuses = { socket_betrayal_chance = 5, socket_betrayal_duration = 3, socket_betrayal_cooldown = 30, socket_betrayal_range = 3 }, tooltip = "When hit by a normal monster, 5% chance every 30s to make reflect the monster attacks to another nearby monster for 3s.\nDetails: Duration: 3s, Cooldown: 30s, Range: 3 SQM", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Betrayal Gem", bonuses = { socket_betrayal_chance = 6, socket_betrayal_duration = 3, socket_betrayal_cooldown = 30, socket_betrayal_range = 3 }, tooltip = "When hit by a normal monster, 6% chance every 30s to make reflect the monster attacks to another nearby monster for 3s.\nDetails: Duration: 3s, Cooldown: 30s, Range: 3 SQM", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Betrayal Gem", bonuses = { socket_betrayal_chance = 8, socket_betrayal_duration = 3, socket_betrayal_cooldown = 30, socket_betrayal_range = 3 }, tooltip = "When hit by a normal monster, 8% chance every 30s to make reflect the monster attacks to another nearby monster for 3s.\nDetails: Duration: 3s, Cooldown: 30s, Range: 3 SQM", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Betrayal Gem", bonuses = { socket_betrayal_chance = 10, socket_betrayal_duration = 3, socket_betrayal_cooldown = 30, socket_betrayal_range = 3 }, tooltip = "When hit by a normal monster, 10% chance every 30s to make reflect the monster attacks to another nearby monster for 3s.\nDetails: Duration: 3s, Cooldown: 30s, Range: 3 SQM", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Betrayal Gem", bonuses = { socket_betrayal_chance = 12, socket_betrayal_duration = 3, socket_betrayal_cooldown = 30, socket_betrayal_range = 3 }, tooltip = "When hit by a normal monster, 12% chance every 30s to make reflect the monster attacks to another nearby monster for 3s.\nDetails: Duration: 3s, Cooldown: 30s, Range: 3 SQM", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Betrayal Gem", bonuses = { socket_betrayal_chance = 15, socket_betrayal_duration = 3, socket_betrayal_cooldown = 30, socket_betrayal_range = 3 }, tooltip = "When hit by a normal monster, 15% chance every 30s to make reflect the monster attacks to another nearby monster for 3s.\nDetails: Duration: 3s, Cooldown: 30s, Range: 3 SQM" }
        },
    },
    -- 46 --
    gravediggersmalachite = {
        itemId = 30711,
        name = "The Gravedigger's Malachite",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield" },
        bestFor = { "Any Vocation" },
        style = "Unique Server Funerals",
        gravedigger = {
            deathsPerStack = 50,
            healthPerStack = 12,
            manaPerStack = 12,
        },
        bonuses = {
            socket_gravedigger_health = 0,
            socket_gravedigger_mana = 0,
        },
        storage = 980134,
        storageValue = 1,
        tooltip = "Records global player deaths while socketed on equipped gear. Every 50 deaths recorded grants this gem +12 max HP and +12 max Mana.",
        tiers = {
            [1] = {
                name = "Small The Gravedigger's Malachite",
                bonuses = { socket_gravedigger_health = 0, socket_gravedigger_mana = 0 },
                tooltip = "Records global player deaths while socketed on equipped gear. Every 50 deaths recorded grants this gem +12 max HP and +12 max Mana.",
            }
        },
    },
    -- 47 --
    obsidiangrudge = {
        itemId = 30712,
        name = "Obsidian Grudge",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "armor", "shield", "ring", "necklace", "belt" },
        bestFor = { "Any Vocation" },
        style = "Counterattack",
        bonuses = {
            socket_obsidian_chance = 100,
            socket_obsidian_window = 5,
            socket_obsidian_stack_cooldown = 6,
            socket_obsidian_max_stacks = 3,
            socket_obsidian_damage_percent = 4,
        },
        tooltip = "When damaged, if you do not deal damage back within 5s, gain 1 Grudge stack. Your next hit consumes up to 3 stacks for +4% damage per stack. 6s stack cooldown.\nDetails: Chance: 100%, Window: 5s, Max Stacks: 3",
        tiers = {
            [1] = {
                name = "Small Obsidian Grudge",
                bonuses = { socket_obsidian_chance = 100, socket_obsidian_window = 5, socket_obsidian_stack_cooldown = 6, socket_obsidian_max_stacks = 3, socket_obsidian_damage_percent = 4 },
                tooltip = "When damaged, if you do not deal damage back within 5s, gain 1 Grudge stack. Your next hit consumes up to 3 stacks for +4% damage per stack. 6s stack cooldown.\nDetails: Chance: 100%, Window: 5s, Max Stacks: 3",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Obsidian Grudge",
                bonuses = { socket_obsidian_chance = 100, socket_obsidian_window = 4, socket_obsidian_stack_cooldown = 6, socket_obsidian_max_stacks = 3, socket_obsidian_damage_percent = 5 },
                tooltip = "When damaged, if you do not deal damage back within 4s, gain 1 Grudge stack. Your next hit consumes up to 3 stacks for +5% damage per stack. 6s stack cooldown.\nDetails: Chance: 100%, Window: 4s, Max Stacks: 3",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Obsidian Grudge",
                bonuses = { socket_obsidian_chance = 100, socket_obsidian_window = 4, socket_obsidian_stack_cooldown = 5, socket_obsidian_max_stacks = 3, socket_obsidian_damage_percent = 6 },
                tooltip = "When damaged, if you do not deal damage back within 4s, gain 1 Grudge stack. Your next hit consumes up to 3 stacks for +6% damage per stack. 5s stack cooldown.\nDetails: Chance: 100%, Window: 4s, Max Stacks: 3",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Obsidian Grudge",
                bonuses = { socket_obsidian_chance = 100, socket_obsidian_window = 3, socket_obsidian_stack_cooldown = 5, socket_obsidian_max_stacks = 3, socket_obsidian_damage_percent = 8 },
                tooltip = "When damaged, if you do not deal damage back within 3s, gain 1 Grudge stack. Your next hit consumes up to 3 stacks for +8% damage per stack. 5s stack cooldown.\nDetails: Chance: 100%, Window: 3s, Max Stacks: 3",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Obsidian Grudge",
                bonuses = { socket_obsidian_chance = 100, socket_obsidian_window = 3, socket_obsidian_stack_cooldown = 4, socket_obsidian_max_stacks = 4, socket_obsidian_damage_percent = 10 },
                tooltip = "When damaged, if you do not deal damage back within 3s, gain 1 Grudge stack. Your next hit consumes up to 4 stacks for +10% damage per stack. 4s stack cooldown.\nDetails: Chance: 100%, Window: 3s, Max Stacks: 4",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Obsidian Grudge",
                bonuses = { socket_obsidian_chance = 100, socket_obsidian_window = 2, socket_obsidian_stack_cooldown = 4, socket_obsidian_max_stacks = 4, socket_obsidian_damage_percent = 12 },
                tooltip = "When damaged, if you do not deal damage back within 2s, gain 1 Grudge stack. Your next hit consumes up to 3 stacks for +12% damage per stack. 4s stack cooldown.\nDetails: Chance: 100%, Window: 2s, Max Stacks: 4"
            }
        }
    },
    -- 48 --
    bondgem = {
        itemId = 30713,
        name = "Gem of Bond",
        uniquePerItem = true,
        uniqueEquipped = true,
        requiresBondBinding = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield" },
        bestFor = { "Party Players" },
        style = "Permanent Bond",
        bonuses = {
            socket_bond_cooldown = 300,
        },
        storage = 980154,
        storageValue = 1,
        tooltip = "Use the loose gem on another player to bind it forever. While equipped, use talkaction !teleport to travel to that player every 300s when both players are safe.\nDetails: Cooldown: 300s",
    },
    -- 49 --
    collectorgem = {
        itemId = 30714,
        name = "Collector Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield" },
        bestFor = { "Collectors" },
        style = "Collection Tracking",
        bonuses = {},
        storage = 980140,
        storageValue = 1,
        tooltip = "Displays the current wearer's unlocked outfit and mount percentages.",
    },
    -- 50 --
    traininggem = {
        itemId = 30715,
        name = "Training Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield" },
        bestFor = { "Gatherers" },
        style = "Pet Gathering",
        bonuses = {
            socket_training_range = 3,
            socket_training_cooldown = 30,
        },
        tooltip = "Every 30s, a living summoned pet can gather an eligible mining, woodcutting, or herbalism resource within 3 tiles using your profession skill.\nDetails: Range: 3 SQM, Cooldown: 30s",
        tiers = {
            [1] = { name = "Small Training Gem", storage = 980108, storageValue = 1, bonuses = { socket_training_range = 3, socket_training_cooldown = 30 }, tooltip = "Every 30s, a living summoned pet can gather an eligible mining, woodcutting, or herbalism resource within 3 tiles using your profession skill.\nDetails: Range: 3 SQM, Cooldown: 30s", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Training Gem", bonuses = { socket_training_range = 3, socket_training_cooldown = 28 }, tooltip = "Every 28s, a living summoned pet can gather an eligible mining, woodcutting, or herbalism resource within 3 tiles using your profession skill.\nDetails: Range: 3 SQM, Cooldown: 28s", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Training Gem", storage = 980109, storageValue = 1, bonuses = { socket_training_range = 4, socket_training_cooldown = 28 }, tooltip = "Every 28s, a living summoned pet can gather an eligible mining, woodcutting, or herbalism resource within 4 tiles using your profession skill.\nDetails: Range: 4 SQM, Cooldown: 28s", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Training Gem", bonuses = { socket_training_range = 4, socket_training_cooldown = 25 }, tooltip = "Every 25s, a living summoned pet can gather an eligible mining, woodcutting, or herbalism resource within 4 tiles using your profession skill.\nDetails: Range: 4 SQM, Cooldown: 25s", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Training Gem", bonuses = { socket_training_range = 5, socket_training_cooldown = 25 }, tooltip = "Every 25s, a living summoned pet can gather an eligible mining, woodcutting, or herbalism resource within 5 tiles using your profession skill.\nDetails: Range: 5 SQM, Cooldown: 25s", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Training Gem", storage = 980110, storageValue = 1, bonuses = { socket_training_range = 7, socket_training_cooldown = 20 }, tooltip = "Every 20s, a living summoned pet can gather an eligible mining, woodcutting, or herbalism resource within 7 tiles using your profession skill.\nDetails: Range: 7 SQM, Cooldown: 20s" }
        },
    },
    -- 51 --
    formationstone = {
        itemId = 30716,
        name = "Formation Stone",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield" },
        bestFor = { "Party Players", "Tanks", "Supports" },
        style = "Tight Formation",
        bonuses = {
            socket_formation_range = 3,
            socket_formation_max_members = 2,
            socket_formation_defense_per_member = 2,
        },
        tooltip = "Party members within 3 SQM form ranks. For each nearby member, the group gains 2% damage reduction, up to 4%.\nDetails: Range: 3 SQM, Max Members: 2, Defense Per Member: 2",
        tiers = {
            [1] = { name = "Small Formation Stone", bonuses = { socket_formation_range = 3, socket_formation_max_members = 2, socket_formation_defense_per_member = 2 }, tooltip = "Party members within 3 SQM form ranks. For each nearby member, the group gains 2% damage reduction, up to 4%.\nDetails: Range: 3 SQM, Max Members: 2, Defense Per Member: 2", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Formation Stone", bonuses = { socket_formation_range = 3, socket_formation_max_members = 3, socket_formation_defense_per_member = 2 }, tooltip = "Party members within 3 SQM form ranks. For each nearby member, the group gains 2% damage reduction, up to 6%.\nDetails: Range: 3 SQM, Max Members: 3, Defense Per Member: 2", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Formation Stone", bonuses = { socket_formation_range = 4, socket_formation_max_members = 3, socket_formation_defense_per_member = 3 }, storage = 980118, storageValue = 1, tooltip = "Party members within 4 SQM form ranks. For each nearby member, the group gains 3% damage reduction, up to 9%.\nDetails: Range: 4 SQM, Max Members: 3, Defense Per Member: 3", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Formation Stone", bonuses = { socket_formation_range = 4, socket_formation_max_members = 4, socket_formation_defense_per_member = 3 }, tooltip = "Party members within 4 SQM form ranks. For each nearby member, the group gains 3% damage reduction, up to 12%.\nDetails: Range: 4 SQM, Max Members: 4, Defense Per Member: 3", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Formation Stone", bonuses = { socket_formation_range = 5, socket_formation_max_members = 4, socket_formation_defense_per_member = 4 }, tooltip = "Party members within 5 SQM form ranks. For each nearby member, the group gains 4% damage reduction, up to 16%.\nDetails: Range: 5 SQM, Max Members: 4, Defense Per Member: 4", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Formation Stone", bonuses = { socket_formation_range = 6, socket_formation_max_members = 4, socket_formation_defense_per_member = 5 }, storage = 980119, storageValue = 1, tooltip = "Party members within 6 SQM form ranks. For each nearby member, the group gains 5% damage reduction, up to 20%.\nDetails: Range: 6 SQM, Max Members: 4, Defense Per Member: 5" }
        },
    },
    -- 52 --
    huntersfocus = {
        itemId = 30717,
        name = "Hunter's Focus",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand" },
        bestFor = { "Boss Hunters", "Single Target Builds" },
        style = "Single Target Mastery",
        bonuses = {
            socket_hunters_focus_percent = 1,
            socket_hunters_focus_interval = 5,
            socket_hunters_focus_max = 10,
        },
        tooltip = "Fighting the same monster builds +1% damage every 5s, up to +10%. Switching targets resets the focus.\nDetails: Hunters Focus Percent: 1%, Hunters Focus Interval: 5s, Hunters Focus Max: 10",
        tiers = {
            [1] = { name = "Small Hunter's Focus", bonuses = { socket_hunters_focus_percent = 1, socket_hunters_focus_interval = 5, socket_hunters_focus_max = 10 }, tooltip = "Fighting the same monster builds +1% damage every 5s, up to +10%. Switching targets resets the focus.\nDetails: Hunters Focus Percent: 1%, Hunters Focus Interval: 5s, Hunters Focus Max: 10", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Hunter's Focus", bonuses = { socket_hunters_focus_percent = 2, socket_hunters_focus_interval = 5, socket_hunters_focus_max = 12 }, tooltip = "Fighting the same monster builds +2% damage every 5s, up to +12%. Switching targets resets the focus.\nDetails: Hunters Focus Percent: 2%, Hunters Focus Interval: 5s, Hunters Focus Max: 12", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Hunter's Focus", bonuses = { socket_hunters_focus_percent = 3, socket_hunters_focus_interval = 5, socket_hunters_focus_max = 15 }, tooltip = "Fighting the same monster builds +3% damage every 5s, up to +15%. Switching targets resets the focus.\nDetails: Hunters Focus Percent: 3%, Hunters Focus Interval: 5s, Hunters Focus Max: 15", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Hunter's Focus", bonuses = { socket_hunters_focus_percent = 4, socket_hunters_focus_interval = 5, socket_hunters_focus_max = 16 }, tooltip = "Fighting the same monster builds +4% damage every 5s, up to +16%. Switching targets resets the focus.\nDetails: Hunters Focus Percent: 4%, Hunters Focus Interval: 5s, Hunters Focus Max: 16", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Hunter's Focus", bonuses = { socket_hunters_focus_percent = 5, socket_hunters_focus_interval = 5, socket_hunters_focus_max = 20 }, tooltip = "Fighting the same monster builds +5% damage every 5s, up to +20%. Switching targets resets the focus.\nDetails: Hunters Focus Percent: 5%, Hunters Focus Interval: 5s, Hunters Focus Max: 20", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Hunter's Focus", bonuses = { socket_hunters_focus_percent = 6, socket_hunters_focus_interval = 5, socket_hunters_focus_max = 24 }, tooltip = "Fighting the same monster builds +6% damage every 5s, up to +24%. Switching targets resets the focus.\nDetails: Hunters Focus Percent: 6%, Hunters Focus Interval: 5s, Hunters Focus Max: 24" }
        },
    },
    -- 53 --
    pendulumstone = {
        itemId = 30718,
        name = "Pendulum Stone",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield", "weapon", "wand" },
        bestFor = { "Adaptive Fighters", "Risk Builds" },
        style = "Rhythm Shift",
        bonuses = {
            socket_pendulum_period = 60,
            socket_pendulum_aggressive_damage = 30,
            socket_pendulum_aggressive_defense_penalty = 30,
            socket_pendulum_defensive_defense = 30,
            socket_pendulum_defensive_damage_penalty = 30,
        },
        tooltip = "Alternates every 60s. Aggressive: +30% damage, but take 30% more damage. Defensive: take 30% less damage, but deal 30% less damage.\nDetails: Period: 60s",
        tiers = {
            [1] = { name = "Small Pendulum Stone", bonuses = { socket_pendulum_period = 60, socket_pendulum_aggressive_damage = 30, socket_pendulum_aggressive_defense_penalty = 30, socket_pendulum_defensive_defense = 30, socket_pendulum_defensive_damage_penalty = 30 }, tooltip = "Alternates every 60s. Aggressive: +30% damage, but take 30% more damage. Defensive: take 30% less damage, but deal 30% less damage.\nDetails: Period: 60s", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Pendulum Stone", bonuses = { socket_pendulum_period = 60, socket_pendulum_aggressive_damage = 30, socket_pendulum_aggressive_defense_penalty = 28, socket_pendulum_defensive_defense = 30, socket_pendulum_defensive_damage_penalty = 28 }, tooltip = "Alternates every 60s. Aggressive: +30% damage, but take 28% more damage. Defensive: take 30% less damage, but deal 28% less damage.\nDetails: Period: 60s", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Pendulum Stone", bonuses = { socket_pendulum_period = 60, socket_pendulum_aggressive_damage = 30, socket_pendulum_aggressive_defense_penalty = 26, socket_pendulum_defensive_defense = 30, socket_pendulum_defensive_damage_penalty = 26 }, tooltip = "Alternates every 60s. Aggressive: +30% damage, but take 26% more damage. Defensive: take 30% less damage, but deal 26% less damage.\nDetails: Period: 60s", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Pendulum Stone", bonuses = { socket_pendulum_period = 60, socket_pendulum_aggressive_damage = 30, socket_pendulum_aggressive_defense_penalty = 22, socket_pendulum_defensive_defense = 30, socket_pendulum_defensive_damage_penalty = 22 }, tooltip = "Alternates every 60s. Aggressive: +30% damage, but take 22% more damage. Defensive: take 30% less damage, but deal 22% less damage.\nDetails: Period: 60s", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Pendulum Stone", bonuses = { socket_pendulum_period = 60, socket_pendulum_aggressive_damage = 30, socket_pendulum_aggressive_defense_penalty = 18, socket_pendulum_defensive_defense = 30, socket_pendulum_defensive_damage_penalty = 18 }, tooltip = "Alternates every 60s. Aggressive: +30% damage, but take 18% more damage. Defensive: take 30% less damage, but deal 18% less damage.\nDetails: Period: 60s", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Pendulum Stone", bonuses = { socket_pendulum_period = 60, socket_pendulum_aggressive_damage = 30, socket_pendulum_aggressive_defense_penalty = 12, socket_pendulum_defensive_defense = 30, socket_pendulum_defensive_damage_penalty = 12 }, storage = 980159, storageValue = 1, tooltip = "Alternates every 60s. Aggressive: +30% damage, but take 12% more damage. Defensive: take 30% less damage, but deal 12% less damage.\nDetails: Period: 60s" }
        },
    },
    -- 54 --
    anchorstone = {
        itemId = 30719,
        name = "Anchor Stone",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield" },
        bestFor = { "Tanks", "Defensive Builds", "Stationary Fighters" },
        style = "Immovable Defense",
        bonuses = {
            socket_anchor_stack_interval = 1,
            socket_anchor_max_stacks = 1,
            socket_anchor_defense_per_stack = 2,
            socket_anchor_damage_per_level_per_stack = 0.07,
            socket_anchor_range = 2,
        },
        tooltip = "Standing still gains one Anchor stack each second, up to 1. Each stack reduces damage taken by 2%. Moving consumes all stacks and releases an arcane shockwave dealing 0.07 damage per level for each stack.\nDetails: Stack Interval: 1s, Max Stacks: 1, Defense per Stack: 2, Range: 2 SQM",
        tiers = {
            [1] = { name = "Small Anchor Stone", bonuses = { socket_anchor_stack_interval = 1, socket_anchor_max_stacks = 1, socket_anchor_defense_per_stack = 2, socket_anchor_damage_per_level_per_stack = 0.07, socket_anchor_range = 2 }, tooltip = "Standing still gains one Anchor stack each second, up to 1. Each stack reduces damage taken by 2%. Moving consumes all stacks and releases an arcane shockwave dealing 0.07 damage per level for each stack.\nDetails: Stack Interval: 1s, Max Stacks: 1, Defense per Stack: 2, Range: 2 SQM", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Anchor Stone", bonuses = { socket_anchor_stack_interval = 1, socket_anchor_max_stacks = 1, socket_anchor_defense_per_stack = 2, socket_anchor_damage_per_level_per_stack = 0.15, socket_anchor_range = 2 }, tooltip = "Standing still gains one Anchor stack each second, up to 1. Each stack reduces damage taken by 2%. Moving consumes all stacks and releases an arcane shockwave dealing 0.15 damage per level for each stack.\nDetails: Stack Interval: 1s, Max Stacks: 1, Defense per Stack: 2, Range: 2 SQM", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Anchor Stone", bonuses = { socket_anchor_stack_interval = 1, socket_anchor_max_stacks = 1, socket_anchor_defense_per_stack = 2, socket_anchor_damage_per_level_per_stack = 0.20, socket_anchor_range = 2 }, storage = 980120, storageValue = 1, tooltip = "Standing still gains one Anchor stack each second, up to 1. Each stack reduces damage taken by 2%. Moving consumes all stacks and releases an arcane shockwave dealing 0.20 damage per level for each stack.\nDetails: Stack Interval: 1s, Max Stacks: 1, Defense per Stack: 2, Range: 2 SQM", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Anchor Stone", bonuses = { socket_anchor_stack_interval = 1, socket_anchor_max_stacks = 1, socket_anchor_defense_per_stack = 2, socket_anchor_damage_per_level_per_stack = 0.30, socket_anchor_range = 2 }, tooltip = "Standing still gains one Anchor stack each second, up to 1. Each stack reduces damage taken by 2%. Moving consumes all stacks and releases an arcane shockwave dealing 0.3 damage per level for each stack.\nDetails: Stack Interval: 1s, Max Stacks: 1, Defense per Stack: 2, Range: 2 SQM", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Anchor Stone", bonuses = { socket_anchor_stack_interval = 1, socket_anchor_max_stacks = 2, socket_anchor_defense_per_stack = 2, socket_anchor_damage_per_level_per_stack = 0.4, socket_anchor_range = 2 }, tooltip = "Standing still gains one Anchor stack each second, up to 2. Each stack reduces damage taken by 2%. Moving consumes all stacks and releases an arcane shockwave dealing 0.4 damage per level for each stack.\nDetails: Stack Interval: 1s, Max Stacks: 2, Defense per Stack: 2, Range: 2 SQM", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Anchor Stone", bonuses = { socket_anchor_stack_interval = 1, socket_anchor_max_stacks = 2, socket_anchor_defense_per_stack = 2, socket_anchor_damage_per_level_per_stack = 0.50, socket_anchor_range = 2 }, storage = 980121, storageValue = 1, tooltip = "Standing still gains one Anchor stack each second, up to 2. Each stack reduces damage taken by 2%. Moving consumes all stacks and releases an arcane shockwave dealing 0.5 damage per level for each stack.\nDetails: Stack Interval: 1s, Max Stacks: 2, Defense per Stack: 2, Range: 2 SQM" }
        },
    },
    -- 55 --
    steadyhandgem = {
        itemId = 30720,
        name = "Steady Hand Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace", "gloves" },
        bestFor = { "Any Vocation" },
        style = "Stable Casting",
        bonuses = { socket_steady_hand_cooldown = 8, socket_steady_hand_percent = 1, socket_steady_hand_still_seconds = 2 },
        tooltip = "If you have not moved for 2s, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 1%, Still Time: 2s",
        tiers = {
            [1] = { name = "Small Steady Hand Gem", bonuses = { socket_steady_hand_cooldown = 8, socket_steady_hand_percent = 1, socket_steady_hand_still_seconds = 2 }, tooltip = "If you have not moved for 2s, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 1%, Still Time: 2s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Steady Hand Gem", bonuses = { socket_steady_hand_cooldown = 8, socket_steady_hand_percent = 2, socket_steady_hand_still_seconds = 2 }, tooltip = "If you have not moved for 2s, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 2%, Still Time: 2s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Steady Hand Gem", bonuses = { socket_steady_hand_cooldown = 8, socket_steady_hand_percent = 3, socket_steady_hand_still_seconds = 2 }, tooltip = "If you have not moved for 2s, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 3%, Still Time: 2s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Steady Hand Gem", bonuses = { socket_steady_hand_cooldown = 8, socket_steady_hand_percent = 4, socket_steady_hand_still_seconds = 2 }, tooltip = "If you have not moved for 2s, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 4%, Still Time: 2s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Steady Hand Gem", bonuses = { socket_steady_hand_cooldown = 8, socket_steady_hand_percent = 5, socket_steady_hand_still_seconds = 2 }, tooltip = "If you have not moved for 2s, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 5%, Still Time: 2s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Steady Hand Gem", bonuses = { socket_steady_hand_cooldown = 8, socket_steady_hand_percent = 6, socket_steady_hand_still_seconds = 2 }, tooltip = "If you have not moved for 2s, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 6%, Still Time: 2s" }
        },
    },
    -- 56 --
    quickstepgem = {
        itemId = 30721,
        name = "Quick Step Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "boots", "weapon", "ring" },
        bestFor = { "Any Vocation" },
        style = "Mobile Strike",
        bonuses = { socket_quick_step_cooldown = 8, socket_quick_step_percent = 2, socket_quick_step_tiles = 8 },
        tooltip = "After moving 8 tiles, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 2%",
        tiers = {
            [1] = { name = "Small Quick Step Gem", bonuses = { socket_quick_step_cooldown = 8, socket_quick_step_percent = 2, socket_quick_step_tiles = 8 }, tooltip = "After moving 8 tiles, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 2%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Quick Step Gem", bonuses = { socket_quick_step_cooldown = 8, socket_quick_step_percent = 3, socket_quick_step_tiles = 7 }, tooltip = "After moving 7 tiles, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 3%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Quick Step Gem", bonuses = { socket_quick_step_cooldown = 8, socket_quick_step_percent = 3, socket_quick_step_tiles = 7 }, tooltip = "After moving 7 tiles, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 3%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Quick Step Gem", bonuses = { socket_quick_step_cooldown = 8, socket_quick_step_percent = 5, socket_quick_step_tiles = 6 }, tooltip = "After moving 6 tiles, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 5%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Quick Step Gem", bonuses = { socket_quick_step_cooldown = 8, socket_quick_step_percent = 7, socket_quick_step_tiles = 5 }, tooltip = "After moving 5 tiles, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 7%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Quick Step Gem", bonuses = { socket_quick_step_cooldown = 8, socket_quick_step_percent = 10, socket_quick_step_tiles = 4 }, tooltip = "After moving 4 tiles, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 10%" }
        },
    },
    -- 57 --
    guardedbreathgem = {
        itemId = 30722,
        name = "Guarded Breath Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "shield", "armor", "necklace" },
        bestFor = { "Any Vocation" },
        style = "Defensive Pause",
        bonuses = { socket_guarded_breath_cooldown = 15, socket_guarded_breath_idle_seconds = 6, socket_guarded_breath_reduce_percent = 1 },
        tooltip = "If you have not attacked for 6, your next received hit is reduced.\nDetails: Cooldown: 15s, Idle Time: 6s, Reduction: 1%",
        tiers = {
            [1] = { name = "Small Guarded Breath Gem", bonuses = { socket_guarded_breath_cooldown = 15, socket_guarded_breath_idle_seconds = 6, socket_guarded_breath_reduce_percent = 1 }, tooltip = "If you have not attacked for 6s, your next received hit is reduced.\nDetails: Cooldown: 15s, Idle Time: 6s, Reduction: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Guarded Breath Gem", bonuses = { socket_guarded_breath_cooldown = 15, socket_guarded_breath_idle_seconds = 5, socket_guarded_breath_reduce_percent = 2 }, tooltip = "If you have not attacked for 5s, your next received hit is reduced.\nDetails: Cooldown: 15s, Idle Time: 5s, Reduction: 2%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Guarded Breath Gem", bonuses = { socket_guarded_breath_cooldown = 12, socket_guarded_breath_idle_seconds = 5, socket_guarded_breath_reduce_percent = 3 }, tooltip = "If you have not attacked for 5s, your next received hit is reduced.\nDetails: Cooldown: 12s, Idle Time: 5s, Reduction: 3%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Guarded Breath Gem", bonuses = { socket_guarded_breath_cooldown = 10, socket_guarded_breath_idle_seconds = 4, socket_guarded_breath_reduce_percent = 4 }, tooltip = "If you have not attacked for 4s, your next received hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 4s, Reduction: 4%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Guarded Breath Gem", bonuses = { socket_guarded_breath_cooldown = 10, socket_guarded_breath_idle_seconds = 3, socket_guarded_breath_reduce_percent = 5 }, tooltip = "If you have not attacked for 3s, your next received hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 3s, Reduction: 5%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Guarded Breath Gem", bonuses = { socket_guarded_breath_cooldown = 10, socket_guarded_breath_idle_seconds = 2, socket_guarded_breath_reduce_percent = 6 }, tooltip = "If you have not attacked for 2s, your next received hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 2s, Reduction: 6%" }
        },
    },
    -- 58 --
    revengesparkgem = {
        itemId = 30864,
        name = "Revenge Spark Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "ring", "gloves" },
        bestFor = { "Any Vocation" },
        style = "Counter Hit",
        bonuses = { socket_revenge_spark_cooldown = 8, socket_revenge_spark_percent = 1, socket_revenge_spark_window = 5 },
        tooltip = "After receiving damage, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 1%, Window: 5s",
        tiers = {
            [1] = { name = "Small Revenge Spark Gem", bonuses = { socket_revenge_spark_cooldown = 8, socket_revenge_spark_percent = 1, socket_revenge_spark_window = 5 }, tooltip = "After receiving damage, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 1%, Window: 5s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Revenge Spark Gem", bonuses = { socket_revenge_spark_cooldown = 8, socket_revenge_spark_percent = 2, socket_revenge_spark_window = 5 }, tooltip = "After receiving damage, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 2%, Window: 5s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Revenge Spark Gem", bonuses = { socket_revenge_spark_cooldown = 8, socket_revenge_spark_percent = 3, socket_revenge_spark_window = 5 }, tooltip = "After receiving damage, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 3%, Window: 5s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Revenge Spark Gem", bonuses = { socket_revenge_spark_cooldown = 8, socket_revenge_spark_percent = 4, socket_revenge_spark_window = 5 }, tooltip = "After receiving damage, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 4%, Window: 5s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Revenge Spark Gem", bonuses = { socket_revenge_spark_cooldown = 8, socket_revenge_spark_percent = 5, socket_revenge_spark_window = 5 }, tooltip = "After receiving damage, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 5%, Window: 5s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Revenge Spark Gem", bonuses = { socket_revenge_spark_cooldown = 8, socket_revenge_spark_percent = 6, socket_revenge_spark_window = 5 }, tooltip = "After receiving damage, your next hit deals slightly more damage.\nDetails: Cooldown: 8s, Damage: 6%, Window: 5s" }
        },
    },
    -- 59 --
    bracegem = {
        itemId = 30865,
        name = "Brace Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "legs", "shield", "belt" },
        bestFor = { "Any Vocation" },
        style = "Anti Burst",
        bonuses = { socket_brace_cooldown = 12, socket_brace_reduce_percent = 1, socket_brace_threshold = 15 },
        tooltip = "Large received hits are slightly reduced.\nDetails: Cooldown: 12s, Reduction: 1%, Threshold: 15%",
        tiers = {
            [1] = { name = "Small Brace Gem", bonuses = { socket_brace_cooldown = 12, socket_brace_reduce_percent = 1, socket_brace_threshold = 15 }, tooltip = "Large received hits are slightly reduced.\nDetails: Cooldown: 12s, Reduction: 1%, Threshold: 15%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Brace Gem", bonuses = { socket_brace_cooldown = 12, socket_brace_reduce_percent = 3, socket_brace_threshold = 15 }, tooltip = "Large received hits are slightly reduced.\nDetails: Cooldown: 12s, Reduction: 3%, Threshold: 15%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Brace Gem", bonuses = { socket_brace_cooldown = 12, socket_brace_reduce_percent = 5, socket_brace_threshold = 15 }, tooltip = "Large received hits are slightly reduced.\nDetails: Cooldown: 12s, Reduction: 5%, Threshold: 15%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Brace Gem", bonuses = { socket_brace_cooldown = 12, socket_brace_reduce_percent = 6, socket_brace_threshold = 15 }, tooltip = "Large received hits are slightly reduced.\nDetails: Cooldown: 12s, Reduction: 6%, Threshold: 15%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Brace Gem", bonuses = { socket_brace_cooldown = 12, socket_brace_reduce_percent = 8, socket_brace_threshold = 15 }, tooltip = "Large received hits are slightly reduced.\nDetails: Cooldown: 12s, Reduction: 8%, Threshold: 15%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Brace Gem", bonuses = { socket_brace_cooldown = 12, socket_brace_reduce_percent = 10, socket_brace_threshold = 15 }, tooltip = "Large received hits are slightly reduced.\nDetails: Cooldown: 12s, Reduction: 10%, Threshold: 15%" }
        },
    },
    -- 60 --
    laststandgem = {
        itemId = 30723,
        name = "Last Stand Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "shield", "ring", "necklace" },
        bestFor = { "Any Vocation" },
        style = "Low HP Defense",
        bonuses = { socket_last_stand_cooldown = 20, socket_last_stand_reduce_percent = 1, socket_last_stand_threshold = 20 },
        tooltip = "When below 20% HP, your next received hit is reduced.\nDetails: Cooldown: 20s, Reduction: 1%, Threshold: 20%",
        tiers = {
            [1] = { name = "Small Last Stand Gem", bonuses = { socket_last_stand_cooldown = 20, socket_last_stand_reduce_percent = 1, socket_last_stand_threshold = 20 }, tooltip = "When below 20% HP, your next received hit is reduced.\nDetails: Cooldown: 20s, Reduction: 1%, Threshold: 20%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Last Stand Gem", bonuses = { socket_last_stand_cooldown = 18, socket_last_stand_reduce_percent = 3, socket_last_stand_threshold = 25 }, tooltip = "When below 25% HP, your next received hit is reduced.\nDetails: Cooldown: 18s, Reduction: 3%, Threshold: 25%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Last Stand Gem", bonuses = { socket_last_stand_cooldown = 15, socket_last_stand_reduce_percent = 5, socket_last_stand_threshold = 30 }, tooltip = "When below 30% HP, your next received hit is reduced.\nDetails: Cooldown: 15s, Reduction: 5%, Threshold: 30%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Last Stand Gem", bonuses = { socket_last_stand_cooldown = 14, socket_last_stand_reduce_percent = 7, socket_last_stand_threshold = 35 }, tooltip = "When below 35% HP, your next received hit is reduced.\nDetails: Cooldown: 14s, Reduction: 7%, Threshold: 35%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Last Stand Gem", bonuses = { socket_last_stand_cooldown = 13, socket_last_stand_reduce_percent = 10, socket_last_stand_threshold = 40 }, tooltip = "When below 40% HP, your next received hit is reduced.\nDetails: Cooldown: 13s, Reduction: 10%, Threshold: 40%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Last Stand Gem", bonuses = { socket_last_stand_cooldown = 12, socket_last_stand_reduce_percent = 12, socket_last_stand_threshold = 50 }, tooltip = "When below 50% HP, your next received hit is reduced.\nDetails: Cooldown: 12s, Reduction: 12%, Threshold: 50%" }
        },
    },
    -- 61 --
    desperatefocusgem = {
        itemId = 30724,
        name = "Desperate Focus Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring" },
        bestFor = { "Any Vocation" },
        style = "Low HP Offense",
        bonuses = { socket_desperate_focus_cooldown = 20, socket_desperate_focus_percent = 1, socket_desperate_focus_threshold = 20 },
        tooltip = "When below 20% HP, your next hit deals slightly more damage.\nDetails: Cooldown: 20s, Damage: 1%, Threshold: 20%",
        tiers = {
            [1] = { name = "Small Desperate Focus Gem", bonuses = { socket_desperate_focus_cooldown = 20, socket_desperate_focus_percent = 1, socket_desperate_focus_threshold = 20 }, tooltip = "When below 20% HP, your next hit deals slightly more damage.\nDetails: Cooldown: 20s, Damage: 1%, Threshold: 20%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Desperate Focus Gem", bonuses = { socket_desperate_focus_cooldown = 18, socket_desperate_focus_percent = 2, socket_desperate_focus_threshold = 25 }, tooltip = "When below 25% HP, your next hit deals slightly more damage.\nDetails: Cooldown: 18s, Damage: 2%, Threshold: 25%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Desperate Focus Gem", bonuses = { socket_desperate_focus_cooldown = 15, socket_desperate_focus_percent = 3, socket_desperate_focus_threshold = 30 }, tooltip = "When below 30% HP, your next hit deals slightly more damage.\nDetails: Cooldown: 15s, Damage: 3%, Threshold: 30%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Desperate Focus Gem", bonuses = { socket_desperate_focus_cooldown = 14, socket_desperate_focus_percent = 5, socket_desperate_focus_threshold = 35 }, tooltip = "When below 35% HP, your next hit deals slightly more damage.\nDetails: Cooldown: 14s, Threshold: 35%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Desperate Focus Gem", bonuses = { socket_desperate_focus_cooldown = 13, socket_desperate_focus_percent = 7, socket_desperate_focus_threshold = 40 }, tooltip = "When below 40% HP, your next hit deals slightly more damage.\nDetails: Cooldown: 13s, Damage: 7%, Threshold: 40%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Desperate Focus Gem", bonuses = { socket_desperate_focus_cooldown = 12, socket_desperate_focus_percent = 10, socket_desperate_focus_threshold = 50 }, tooltip = "When below 50% HP, your next hit deals slightly more damage.\nDetails: Cooldown: 12s, Damage: 10%, Threshold: 50%" }
        },
    },
    -- 62 --
    emptymindgem = {
        itemId = 30725,
        name = "Empty Mind Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "ring", "necklace", "wand" },
        bestFor = { "Any Vocation" },
        style = "Low Mana Recovery",
        bonuses = { socket_empty_mind_cooldown = 20, socket_empty_mind_mana_percent = 1, socket_empty_mind_threshold = 15 },
        tooltip = "When below 15% mana, your next hit restores mana.\nDetails: Cooldown: 20s, Mana: 1%, Threshold: 15%",
        tiers = {
            [1] = { name = "Small Empty Mind Gem", bonuses = { socket_empty_mind_cooldown = 20, socket_empty_mind_mana_percent = 1, socket_empty_mind_threshold = 15 }, tooltip = "When below 15% mana, your next hit restores mana.\nDetails: Cooldown: 20s, Mana: 1%, Threshold: 15%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Empty Mind Gem", bonuses = { socket_empty_mind_cooldown = 20, socket_empty_mind_mana_percent = 1, socket_empty_mind_threshold = 18 }, tooltip = "When below 18% mana, your next hit restores mana.\nDetails: Cooldown: 20s, Mana: 1%, Threshold: 18%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Empty Mind Gem", bonuses = { socket_empty_mind_cooldown = 20, socket_empty_mind_mana_percent = 1, socket_empty_mind_threshold = 20 }, tooltip = "When below 20% mana, your next hit restores mana.\nDetails: Cooldown: 20s, Mana: 1%, Threshold: 20%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Empty Mind Gem", bonuses = { socket_empty_mind_cooldown = 20, socket_empty_mind_mana_percent = 2, socket_empty_mind_threshold = 25 }, tooltip = "When below 25% mana, your next hit restores mana.\nDetails: Cooldown: 20s, Mana: 2%, Threshold: 25%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Empty Mind Gem", bonuses = { socket_empty_mind_cooldown = 20, socket_empty_mind_mana_percent = 3, socket_empty_mind_threshold = 30 }, tooltip = "When below 30% mana, your next hit restores mana.\nDetails: Cooldown: 20s, Mana: 3%, Threshold: 30%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Empty Mind Gem", bonuses = { socket_empty_mind_cooldown = 20, socket_empty_mind_mana_percent = 3, socket_empty_mind_threshold = 40 }, tooltip = "When below 40% mana, your next hit restores mana.\nDetails: Cooldown: 20s, Mana: 3%, Threshold: 40%" }
        },
    },
    -- 63 --
    fullmindgem = {
        itemId = 30726,
        name = "Full Mind Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "wand", "helmet", "ring" },
        bestFor = { "Any Vocation" },
        style = "High Mana Spell",
        bonuses = { socket_full_mind_cooldown = 15, socket_full_mind_spell_percent = 1, socket_full_mind_threshold = 90 },
        tooltip = "When above 90% mana, your next spell hit deals slightly more damage.\nDetails: Cooldown: 15s, Spell Damage: 1%, Threshold: 90%",
        tiers = {
            [1] = { name = "Small Full Mind Gem", bonuses = { socket_full_mind_cooldown = 15, socket_full_mind_spell_percent = 1, socket_full_mind_threshold = 90 }, tooltip = "When above 90% mana, your next spell hit deals slightly more damage.\nDetails: Cooldown: 15s, Spell Damage: 1%, Threshold: 90%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Full Mind Gem", bonuses = { socket_full_mind_cooldown = 15, socket_full_mind_spell_percent = 2, socket_full_mind_threshold = 85 }, tooltip = "When above 85% mana, your next spell hit deals slightly more damage.\nDetails: Cooldown: 15s, Spell Damage: 2%, Threshold: 85%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Full Mind Gem", bonuses = { socket_full_mind_cooldown = 14, socket_full_mind_spell_percent = 3, socket_full_mind_threshold = 80 }, tooltip = "When above 80% mana, your next spell hit deals slightly more damage.\nDetails: Cooldown: 14s, Spell Damage: 3%, Threshold: 80%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Full Mind Gem", bonuses = { socket_full_mind_cooldown = 13, socket_full_mind_spell_percent = 4, socket_full_mind_threshold = 75 }, tooltip = "When above 75% mana, your next spell hit deals slightly more damage.\nDetails: Cooldown: 13s, Spell Damage: 4%, Threshold: 75%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Full Mind Gem", bonuses = { socket_full_mind_cooldown = 13, socket_full_mind_spell_percent = 5, socket_full_mind_threshold = 70 }, tooltip = "When above 70% mana, your next spell hit deals slightly more damage.\nDetails: Cooldown: 13s, Spell Damage: 5%, Threshold: 70%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Full Mind Gem", bonuses = { socket_full_mind_cooldown = 12, socket_full_mind_spell_percent = 6, socket_full_mind_threshold = 65 }, tooltip = "When above 65% mana, your next spell hit deals slightly more damage.\nDetails: Cooldown: 12s, Spell Damage: 6%, Threshold: 65%" }
        },
    },
    -- 64 --
    thickskingem = {
        itemId = 30727,
        name = "Thick Skin Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "legs", "boots" },
        bestFor = { "Any Vocation" },
        style = "First Hit Protection",
        bonuses = { socket_thick_skin_cooldown = 10, socket_thick_skin_idle_seconds = 10, socket_thick_skin_reduce_percent = 1 },
        tooltip = "If you have not been hit for 10s, your next received hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 10s, Reduction: 1%",
        tiers = {
            [1] = { name = "Small Thick Skin Gem", bonuses = { socket_thick_skin_cooldown = 10, socket_thick_skin_idle_seconds = 10, socket_thick_skin_reduce_percent = 1 }, tooltip = "If you have not been hit for 10s, your next received hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 10s, Reduction: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Thick Skin Gem", bonuses = { socket_thick_skin_cooldown = 8, socket_thick_skin_idle_seconds = 8, socket_thick_skin_reduce_percent = 2 }, tooltip = "If you have not been hit for 8s, your next received hit is reduced.\nDetails: Cooldown: 8s, Idle Time: 8s, Reduction: 2%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Thick Skin Gem", bonuses = { socket_thick_skin_cooldown = 7, socket_thick_skin_idle_seconds = 8, socket_thick_skin_reduce_percent = 3 }, tooltip = "If you have not been hit for 7s, your next received hit is reduced.\nDetails: Cooldown: 7s, Idle Time: 8s, Reduction: 3%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Thick Skin Gem", bonuses = { socket_thick_skin_cooldown = 6, socket_thick_skin_idle_seconds = 8, socket_thick_skin_reduce_percent = 5 }, tooltip = "If you have not been hit for 6s, your next received hit is reduced.\nDetails: Cooldown: 6s, Idle Time: 8s, Reduction: 5%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Thick Skin Gem", bonuses = { socket_thick_skin_cooldown = 5, socket_thick_skin_idle_seconds = 8, socket_thick_skin_reduce_percent = 7 }, tooltip = "If you have not been hit for 5s, your next received hit is reduced.\nDetails: Cooldown: 5s, Idle Time: 8s, Reduction: 7%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Thick Skin Gem", bonuses = { socket_thick_skin_cooldown = 4, socket_thick_skin_idle_seconds = 8, socket_thick_skin_reduce_percent = 10 }, tooltip = "If you have not been hit for 4s, your next received hit is reduced.\nDetails: Cooldown: 4s, Idle Time: 8s, Reduction: 10%" }
        },
    },
    -- 65 --
    battlerhythmgem = {
        itemId = 30738,
        name = "Battle Rhythm Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "gloves" },
        bestFor = { "Any Vocation" },
        style = "Hit Counter",
        bonuses = { socket_battle_rhythm_hit_count = 8, socket_battle_rhythm_percent = 5 },
        tooltip = "Every 8th successful hit deals slightly more damage.\nDetails: Damage: 5%",
        tiers = {
            [1] = { name = "Small Battle Rhythm Gem", bonuses = { socket_battle_rhythm_hit_count = 8, socket_battle_rhythm_percent = 5 }, tooltip = "Every 8th successful hit deals slightly more damage.\nDetails: Damage: 5%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Battle Rhythm Gem", bonuses = { socket_battle_rhythm_hit_count = 7, socket_battle_rhythm_percent = 6 }, tooltip = "Every 7th successful hit deals slightly more damage.\nDetails: Damage: 6%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Battle Rhythm Gem", bonuses = { socket_battle_rhythm_hit_count = 7, socket_battle_rhythm_percent = 7 }, tooltip = "Every 7th successful hit deals slightly more damage.\nDetails: Damage: 7%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Battle Rhythm Gem", bonuses = { socket_battle_rhythm_hit_count = 6, socket_battle_rhythm_percent = 8 }, tooltip = "Every 6th successful hit deals slightly more damage.\nDetails: Damage: 8%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Battle Rhythm Gem", bonuses = { socket_battle_rhythm_hit_count = 5, socket_battle_rhythm_percent = 9 }, tooltip = "Every 5th successful hit deals slightly more damage.\nDetails: Damage: 9%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Battle Rhythm Gem", bonuses = { socket_battle_rhythm_hit_count = 4, socket_battle_rhythm_percent = 10 }, tooltip = "Every 4th successful hit deals slightly more damage.\nDetails: Damage: 10%" }
        },
    },
    -- 66 --
    safetyrhythmgem = {
        itemId = 30729,
        name = "Safety Rhythm Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "shield", "belt" },
        bestFor = { "Any Vocation" },
        style = "Defense Counter",
        bonuses = { socket_safety_rhythm_hit_count = 8, socket_safety_rhythm_reduce_percent = 5 },
        tooltip = "Every 8th received hit is slightly reduced.\nDetails: Reduction: 5%",
        tiers = {
            [1] = { name = "Small Safety Rhythm Gem", bonuses = { socket_safety_rhythm_hit_count = 8, socket_safety_rhythm_reduce_percent = 5 }, tooltip = "Every 8th received hit is slightly reduced.\nDetails: Reduction: 5%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Safety Rhythm Gem", bonuses = { socket_safety_rhythm_hit_count = 7, socket_safety_rhythm_reduce_percent = 6 }, tooltip = "Every 7th received hit is slightly reduced.\nDetails: Reduction: 6%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Safety Rhythm Gem", bonuses = { socket_safety_rhythm_hit_count = 7, socket_safety_rhythm_reduce_percent = 7 }, tooltip = "Every 7th received hit is slightly reduced.\nDetails: Reduction: 7%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Safety Rhythm Gem", bonuses = { socket_safety_rhythm_hit_count = 6, socket_safety_rhythm_reduce_percent = 8 }, tooltip = "Every 6th received hit is slightly reduced.\nDetails: Reduction: 8%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Safety Rhythm Gem", bonuses = { socket_safety_rhythm_hit_count = 5, socket_safety_rhythm_reduce_percent = 9 }, tooltip = "Every 5th received hit is slightly reduced.\nDetails: Reduction: 9%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Safety Rhythm Gem", bonuses = { socket_safety_rhythm_hit_count = 4, socket_safety_rhythm_reduce_percent = 10 }, tooltip = "Every 4th received hit is slightly reduced.\nDetails: Reduction: 10%" }
        },
    },
    -- 67 --
    cleankillgem = {
        itemId = 30730,
        name = "Clean Kill Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring" },
        bestFor = { "Any Vocation" },
        style = "Rewarded Control",
        bonuses = { socket_clean_kill_cooldown = 15, socket_clean_kill_mana_percent = 1, socket_clean_kill_safe_seconds = 5 },
        tooltip = "Kills restore mana if you were not recently hit.\nDetails: Cooldown: 15s, Mana Restored: 1%, Safe Window: 5s",
        tiers = {
            [1] = { name = "Small Clean Kill Gem", bonuses = { socket_clean_kill_cooldown = 15, socket_clean_kill_mana_percent = 1, socket_clean_kill_safe_seconds = 5 }, tooltip = "Kills restore mana if you were not recently hit (5s).\nDetails: Cooldown: 15s, Mana Restored: 1%, Safe Window: 5s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Clean Kill Gem", bonuses = { socket_clean_kill_cooldown = 15, socket_clean_kill_mana_percent = 1, socket_clean_kill_safe_seconds = 5 }, tooltip = "Kills restore mana if you were not recently hit (5s).\nDetails: Cooldown: 15s, Mana Restored: 1%, Safe Window: 5s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Clean Kill Gem", bonuses = { socket_clean_kill_cooldown = 15, socket_clean_kill_mana_percent = 2, socket_clean_kill_safe_seconds = 4 }, tooltip = "Kills restore mana if you were not recently hit (4s).\nDetails: Cooldown: 15s, Mana Restored: 2%, Safe Window: 4s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Clean Kill Gem", bonuses = { socket_clean_kill_cooldown = 15, socket_clean_kill_mana_percent = 2, socket_clean_kill_safe_seconds = 4 }, tooltip = "Kills restore mana if you were not recently hit (4s).\nDetails: Cooldown: 15s, Mana Restored: 2%, Safe Window: 4s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Clean Kill Gem", bonuses = { socket_clean_kill_cooldown = 15, socket_clean_kill_mana_percent = 3, socket_clean_kill_safe_seconds = 3 }, tooltip = "Kills restore mana if you were not recently hit (3s).\nDetails: Cooldown: 15s, Mana Restored: 3%, Safe Window: 3s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Clean Kill Gem", bonuses = { socket_clean_kill_cooldown = 15, socket_clean_kill_mana_percent = 3, socket_clean_kill_safe_seconds = 3 }, tooltip = "Kills restore mana if you were not recently hit (3s).\nDetails: Cooldown: 15s, Mana Restored: 3%, Safe Window: 3s" }
        },
    },
    -- 68 --
    dirtykillgem = {
        itemId = 30731,
        name = "Dirty Kill Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring" },
        bestFor = { "Any Vocation" },
        style = "Revenge Reward",
        bonuses = { socket_dirty_kill_cooldown = 15, socket_dirty_kill_heal_percent = 1, socket_dirty_kill_window = 8 },
        tooltip = "Kills restore health if you were recently hit.\nDetails: Cooldown: 15s, Health Restored: 1%, Window: 8s",
        tiers = {
            [1] = { name = "Small Dirty Kill Gem", bonuses = { socket_dirty_kill_cooldown = 15, socket_dirty_kill_heal_percent = 1, socket_dirty_kill_window = 7 }, tooltip = "Kills restore health if you were recently hit.\nDetails: Cooldown: 15s, Health Restored: 1%, Window: 7s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Dirty Kill Gem", bonuses = { socket_dirty_kill_cooldown = 15, socket_dirty_kill_heal_percent = 1, socket_dirty_kill_window = 7 }, tooltip = "Kills restore health if you were recently hit.\nDetails: Cooldown: 15s, Health Restored: 1%, Window: 7s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Dirty Kill Gem", bonuses = { socket_dirty_kill_cooldown = 15, socket_dirty_kill_heal_percent = 2, socket_dirty_kill_window = 6 }, tooltip = "Kills restore health if you were recently hit.\nDetails: Cooldown: 15s, Health Restored: 2%, Window: 6s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Dirty Kill Gem", bonuses = { socket_dirty_kill_cooldown = 15, socket_dirty_kill_heal_percent = 2, socket_dirty_kill_window = 6 }, tooltip = "Kills restore health if you were recently hit.\nDetails: Cooldown: 15s, Health Restored: 2%, Window: 6s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Dirty Kill Gem", bonuses = { socket_dirty_kill_cooldown = 15, socket_dirty_kill_heal_percent = 3, socket_dirty_kill_window = 5 }, tooltip = "Kills restore health if you were recently hit.\nDetails: Cooldown: 15s, Health Restored: 3%, Window: 5s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Dirty Kill Gem", bonuses = { socket_dirty_kill_cooldown = 15, socket_dirty_kill_heal_percent = 3, socket_dirty_kill_window = 4 }, tooltip = "Kills restore health if you were recently hit.\nDetails: Cooldown: 15s, Health Restored: 3%, Window: 4s" }
        },
    },
    -- 69 --
    mercygem = {
        itemId = 30732,
        name = "Mercy Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "necklace" },
        bestFor = { "Any Vocation" },
        style = "Overkill Control",
        bonuses = { socket_mercy_cooldown = 20, socket_mercy_mana_percent = 1 },
        tooltip = "Overkill monster kills restore mana.\nDetails: Cooldown: 20s, Mana Restored: 1%",
        tiers = {
            [1] = { name = "Small Mercy Gem", bonuses = { socket_mercy_cooldown = 20, socket_mercy_mana_percent = 1 }, tooltip = "Overkill monster kills restore mana.\nDetails: Cooldown: 20s, Mana Restored: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Mercy Gem", bonuses = { socket_mercy_cooldown = 20, socket_mercy_mana_percent = 1 }, tooltip = "Overkill monster kills restore mana.\nDetails: Cooldown: 20s, Mana Restored: 1%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Mercy Gem", bonuses = { socket_mercy_cooldown = 20, socket_mercy_mana_percent = 2 }, tooltip = "Overkill monster kills restore mana.\nDetails: Cooldown: 20s, Mana Restored: 2%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Mercy Gem", bonuses = { socket_mercy_cooldown = 20, socket_mercy_mana_percent = 2 }, tooltip = "Overkill monster kills restore mana.\nDetails: Cooldown: 20s, Mana Restored: 2%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Mercy Gem", bonuses = { socket_mercy_cooldown = 20, socket_mercy_mana_percent = 3 }, tooltip = "Overkill monster kills restore mana.\nDetails: Cooldown: 20s, Mana Restored: 3%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Mercy Gem", bonuses = { socket_mercy_cooldown = 20, socket_mercy_mana_percent = 3 }, tooltip = "Overkill monster kills restore mana.\nDetails: Cooldown: 20s, Mana Restored: 3%" }
        },
    },
    -- 70 --
    bloodtithegem = {
        itemId = 30733,
        name = "Blood Tithe Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring" },
        bestFor = { "Any Vocation" },
        style = "Sacrifice Hit",
        bonuses = { socket_blood_tithe_cooldown = 15, socket_blood_tithe_damage_percent = 3, socket_blood_tithe_hp_cost_percent = 1 },
        tooltip = "Your next hit can deal 3% more damage but cost current 1% HP, 15s cooldown.",
        tiers = {
            [1] = { name = "Small Blood Tithe Gem", bonuses = { socket_blood_tithe_cooldown = 15, socket_blood_tithe_damage_percent = 3, socket_blood_tithe_hp_cost_percent = 1 }, tooltip = "Your next hit can deal 3% more damage but cost current 1% HP, 15s cooldown." , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Blood Tithe Gem", bonuses = { socket_blood_tithe_cooldown = 15, socket_blood_tithe_damage_percent = 5, socket_blood_tithe_hp_cost_percent = 1 }, tooltip = "Your next hit can deal 5% more damage but cost current 1% HP, 15s cooldown." , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Blood Tithe Gem", bonuses = { socket_blood_tithe_cooldown = 15, socket_blood_tithe_damage_percent = 10, socket_blood_tithe_hp_cost_percent = 2 }, tooltip = "Your next hit can deal 10% more damage but cost current 2% HP, 15s cooldown." , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Blood Tithe Gem", bonuses = { socket_blood_tithe_cooldown = 15, socket_blood_tithe_damage_percent = 15, socket_blood_tithe_hp_cost_percent = 2 }, tooltip = "Your next hit can deal 15% more damage but cost current HP, 15s cooldown.\nDetails: HP Cost: 2%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Blood Tithe Gem", bonuses = { socket_blood_tithe_cooldown = 15, socket_blood_tithe_damage_percent = 20, socket_blood_tithe_hp_cost_percent = 3 }, tooltip = "Your next hit can deal 20% more damage but cost current 3% HP, 15s cooldown." , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Blood Tithe Gem", bonuses = { socket_blood_tithe_cooldown = 15, socket_blood_tithe_damage_percent = 30, socket_blood_tithe_hp_cost_percent = 5 }, tooltip = "Your next hit can deal 30% more damage but cost current 5% HP, 15s cooldown." }
        },
    },
    -- 71 --
    manapricegem = {
        itemId = 30734,
        name = "Mana Price Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring" },
        bestFor = { "Any Vocation" },
        style = "Mana Burn Hit",
        bonuses = { socket_mana_price_cooldown = 10, socket_mana_price_damage_percent = 3, socket_mana_price_mana_cost_percent = 1 },
        tooltip = "Your next hit can deal more damage but cost current mana.\nDetails: Cooldown: 10s, Damage: 3%, Mana Cost: 1%",
        tiers = {
            [1] = { name = "Small Mana Price Gem", bonuses = { socket_mana_price_cooldown = 10, socket_mana_price_damage_percent = 3, socket_mana_price_mana_cost_percent = 1 }, tooltip = "Your next hit can deal more damage but cost current mana.\nDetails: Cooldown: 10s, Damage: 3%, Mana Cost: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Mana Price Gem", bonuses = { socket_mana_price_cooldown = 10, socket_mana_price_damage_percent = 2, socket_mana_price_mana_cost_percent = 1 }, tooltip = "Your next hit can deal more damage but cost current mana.\nDetails: Cooldown: 10s, Damage: 5%, Mana Cost: 1%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Mana Price Gem", bonuses = { socket_mana_price_cooldown = 10, socket_mana_price_damage_percent = 3, socket_mana_price_mana_cost_percent = 2 }, tooltip = "Your next hit can deal more damage but cost current mana.\nDetails: Cooldown: 10s, Damage: 10%, Mana Cost: 2%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Mana Price Gem", bonuses = { socket_mana_price_cooldown = 10, socket_mana_price_damage_percent = 4, socket_mana_price_mana_cost_percent = 2 }, tooltip = "Your next hit can deal more damage but cost current mana.\nDetails: Cooldown: 10s, Damage: 15%, Mana Cost: 2%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Mana Price Gem", bonuses = { socket_mana_price_cooldown = 10, socket_mana_price_damage_percent = 5, socket_mana_price_mana_cost_percent = 3 }, tooltip = "Your next hit can deal more damage but cost current mana.\nDetails: Cooldown: 10s, Damage: 20%, Mana Cost: 3%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Mana Price Gem", bonuses = { socket_mana_price_cooldown = 10, socket_mana_price_damage_percent = 6, socket_mana_price_mana_cost_percent = 5 }, tooltip = "Your next hit can deal more damage but cost current mana.\nDetails: Cooldown: 10s, Damage: 30%, Mana Cost: 5%" }
        },
    },
    -- 72 --
    potionsavergem = {
        itemId = 30735,
        name = "Potion Saver Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "belt", "gloves", "necklace" },
        bestFor = { "Any Vocation" },
        style = "Efficient Potion",
        bonuses = { socket_potion_saver_chance = 1, socket_potion_saver_cooldown = 20 },
        tooltip = "Potion use has a chance to preserve the potion.\nDetails: Chance: 3%, Cooldown: 20s",
        tiers = {
            [1] = { name = "Small Potion Saver Gem", bonuses = { socket_potion_saver_chance = 3, socket_potion_saver_cooldown = 20 }, tooltip = "Potion use has a chance to preserve the potion.\nDetails: Chance: 3%, Cooldown: 20s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Potion Saver Gem", bonuses = { socket_potion_saver_chance = 5, socket_potion_saver_cooldown = 20 }, tooltip = "Potion use has a chance to preserve the potion.\nDetails: Chance: 5%, Cooldown: 20s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Potion Saver Gem", bonuses = { socket_potion_saver_chance = 8, socket_potion_saver_cooldown = 20 }, tooltip = "Potion use has a chance to preserve the potion.\nDetails: Chance: 8%, Cooldown: 20s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Potion Saver Gem", bonuses = { socket_potion_saver_chance = 12, socket_potion_saver_cooldown = 20 }, tooltip = "Potion use has a chance to preserve the potion.\nDetails: Chance: 12%, Cooldown: 20s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Potion Saver Gem", bonuses = { socket_potion_saver_chance = 15, socket_potion_saver_cooldown = 20 }, tooltip = "Potion use has a chance to preserve the potion.\nDetails: Chance: 15%, Cooldown: 20s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Potion Saver Gem", bonuses = { socket_potion_saver_chance = 20, socket_potion_saver_cooldown = 20 }, tooltip = "Potion use has a chance to preserve the potion.\nDetails: Chance: 20%, Cooldown: 20s" }
        },
    },
    -- 73 --
    potionechogem = {
        itemId = 30736,
        name = "Potion Echo Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "belt", "gloves", "necklace" },
        bestFor = { "Any Vocation" },
        style = "Potion Echo",
        bonuses = { socket_potion_echo_cooldown = 15, socket_potion_echo_percent = 2 },
        tooltip = "Potion use adds a tiny extra potion effect.\nDetails: Cooldown: 15s, Percent: 2%",
        tiers = {
            [1] = { name = "Small Potion Echo Gem", bonuses = { socket_potion_echo_cooldown = 15, socket_potion_echo_percent = 2 }, tooltip = "Potion use adds a tiny extra potion effect.\nDetails: Cooldown: 15s, Percent: 2%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Potion Echo Gem", bonuses = { socket_potion_echo_cooldown = 15, socket_potion_echo_percent = 4 }, tooltip = "Potion use adds a tiny extra potion effect.\nDetails: Cooldown: 15s, Percent: 4%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Potion Echo Gem", bonuses = { socket_potion_echo_cooldown = 15, socket_potion_echo_percent = 6 }, tooltip = "Potion use adds a tiny extra potion effect.\nDetails: Cooldown: 15s, Percent: 6%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Potion Echo Gem", bonuses = { socket_potion_echo_cooldown = 15, socket_potion_echo_percent = 8 }, tooltip = "Potion use adds a tiny extra potion effect.\nDetails: Cooldown: 15s, Percent: 8%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Potion Echo Gem", bonuses = { socket_potion_echo_cooldown = 15, socket_potion_echo_percent = 12 }, tooltip = "Potion use adds a tiny extra potion effect.\nDetails: Cooldown: 15s, Percent: 12%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Potion Echo Gem", bonuses = { socket_potion_echo_cooldown = 15, socket_potion_echo_percent = 20 }, storage = 980130, storageValue = 1, tooltip = "Potion use adds a tiny extra potion effect.\nDetails: Cooldown: 15s, Percent: 20%" }
        },
    },
    -- 74 --
    dryflaskgem = {
        itemId = 30737,
        name = "Dry Flask Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "belt", "ring" },
        bestFor = { "Any Vocation" },
        style = "Emergency Potion",
        bonuses = { socket_dry_flask_cooldown = 12, socket_dry_flask_percent = 3, socket_dry_flask_threshold = 25 },
        tooltip = "Health potions are slightly stronger below 25% HP.\nDetails: Cooldown: 12s, Potion Bonus: 3%, Threshold: 25%",
        tiers = {
            [1] = { name = "Small Dry Flask Gem", bonuses = { socket_dry_flask_cooldown = 12, socket_dry_flask_percent = 3, socket_dry_flask_threshold = 25 }, tooltip = "Health potions are slightly stronger below 25% HP.\nDetails: Cooldown: 12s, Potion Bonus: 3%, Threshold: 25%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Dry Flask Gem", bonuses = { socket_dry_flask_cooldown = 12, socket_dry_flask_percent = 5, socket_dry_flask_threshold = 30 }, tooltip = "Health potions are slightly stronger below 25% HP.\nDetails: Cooldown: 12s, Potion Bonus: 5%, Threshold: 30%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Dry Flask Gem", bonuses = { socket_dry_flask_cooldown = 12, socket_dry_flask_percent = 7, socket_dry_flask_threshold = 35 }, tooltip = "Health potions are slightly stronger below 25% HP.\nDetails: Cooldown: 12s, Potion Bonus: 7%, Threshold: 35%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Dry Flask Gem", bonuses = { socket_dry_flask_cooldown = 12, socket_dry_flask_percent = 9, socket_dry_flask_threshold = 40 }, tooltip = "Health potions are slightly stronger below 40% HP.\nDetails: Cooldown: 12s, Potion Bonus: 9%, Threshold: 40%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Dry Flask Gem", bonuses = { socket_dry_flask_cooldown = 12, socket_dry_flask_percent = 12, socket_dry_flask_threshold = 45 }, tooltip = "Health potions are slightly stronger below 25% HP.\nDetails: Cooldown: 12s, Potion Bonus: 12%, Threshold: 45%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Dry Flask Gem", bonuses = { socket_dry_flask_cooldown = 12, socket_dry_flask_percent = 15, socket_dry_flask_threshold = 50 }, tooltip = "Health potions are slightly stronger below 25% HP.\nDetails: Cooldown: 12s, Potion Bonus: 15%, Threshold: 50%" }
        },
    },
    -- 75 --
    spellpausegem = {
        itemId = 30738,
        name = "Spell Pause Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "wand", "ring" },
        bestFor = { "Any Vocation" },
        style = "Patient Casting",
        bonuses = { socket_spell_pause_cooldown = 12, socket_spell_pause_idle_seconds = 4, socket_spell_pause_mana_reduce_percent = 1 },
        tooltip = "If you have not cast for 4s, the next spell refunds some mana.\nDetails: Cooldown: 12s, Idle Time: 4s, Mana Reduce Percent: 1%",
        tiers = {
            [1] = { name = "Small Spell Pause Gem", bonuses = { socket_spell_pause_cooldown = 12, socket_spell_pause_idle_seconds = 4, socket_spell_pause_mana_reduce_percent = 1 }, tooltip = "If you have not cast for 4s, the next spell refunds some mana.\nDetails: Cooldown: 12s, Idle Time: 4s, Mana Reduce Percent: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Spell Pause Gem", bonuses = { socket_spell_pause_cooldown = 12, socket_spell_pause_idle_seconds = 4, socket_spell_pause_mana_reduce_percent = 2 }, tooltip = "If you have not cast for 4s, the next spell refunds some mana.\nDetails: Cooldown: 12s, Idle Time: 4s, Mana Reduce Percent: 2%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Spell Pause Gem", bonuses = { socket_spell_pause_cooldown = 12, socket_spell_pause_idle_seconds = 4, socket_spell_pause_mana_reduce_percent = 3 }, tooltip = "If you have not cast for 4s, the next spell refunds some mana.\nDetails: Cooldown: 12s, Idle Time: 4s, Mana Reduce Percent: 3%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Spell Pause Gem", bonuses = { socket_spell_pause_cooldown = 12, socket_spell_pause_idle_seconds = 4, socket_spell_pause_mana_reduce_percent = 4 }, tooltip = "If you have not cast for 4s, the next spell refunds some mana.\nDetails: Cooldown: 12s, Idle Time: 4s, Mana Reduce Percent: 4%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Spell Pause Gem", bonuses = { socket_spell_pause_cooldown = 12, socket_spell_pause_idle_seconds = 3, socket_spell_pause_mana_reduce_percent = 5 }, tooltip = "If you have not cast for 3s, the next spell refunds some mana.\nDetails: Cooldown: 12s, Idle Time: 4s, Mana Reduce Percent: 5%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Spell Pause Gem", bonuses = { socket_spell_pause_cooldown = 12, socket_spell_pause_idle_seconds = 3, socket_spell_pause_mana_reduce_percent = 6 }, tooltip = "If you have not cast for 4s, the next spell refunds some mana.\nDetails: Cooldown: 12s, Idle Time: 3s, Mana Reduce Percent: 6%" }
        },
    },
    -- 76 --
    spellchaingem = {
        itemId = 30739,
        name = "Spell Chain Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "wand", "ring" },
        bestFor = { "Any Vocation" },
        style = "Repeated Casting",
        bonuses = { socket_spell_chain_count = 8, socket_spell_chain_mana_percent = 1 },
        tooltip = "Every 8th spell cast restores mana.\nDetails: Count: 8, Mana: 1%",
        tiers = {
            [1] = { name = "Small Spell Chain Gem", bonuses = { socket_spell_chain_count = 8, socket_spell_chain_mana_percent = 1 }, tooltip = "Every 8th spell cast restores mana.\nDetails: Count: 8, Mana: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Spell Chain Gem", bonuses = { socket_spell_chain_count = 7, socket_spell_chain_mana_percent = 1 }, tooltip = "Every 7th spell cast restores mana.\nDetails: Count: 7, Mana: 1%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Spell Chain Gem", bonuses = { socket_spell_chain_count = 6, socket_spell_chain_mana_percent = 2 }, tooltip = "Every 6th spell cast restores mana.\nDetails: Count: 6, Mana: 2%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Spell Chain Gem", bonuses = { socket_spell_chain_count = 6, socket_spell_chain_mana_percent = 2 }, tooltip = "Every 6th spell cast restores mana.\nDetails: Count: 5, Mana: 2%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Spell Chain Gem", bonuses = { socket_spell_chain_count = 5, socket_spell_chain_mana_percent = 3 }, tooltip = "Every 5th spell cast restores mana.\nDetails: Count: 5, Mana: 3%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Spell Chain Gem", bonuses = { socket_spell_chain_count = 4, socket_spell_chain_mana_percent = 4 }, tooltip = "Every 4th spell cast restores mana.\nDetails: Count: 4, Mana: 4%" }
        },
    },
    -- 77 --
    weaponchaingem = {
        itemId = 30740,
        name = "Weapon Chain Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "gloves", "ring" },
        bestFor = { "Any Vocation" },
        style = "Repeated Attacks",
        bonuses = { socket_weapon_chain_count = 8, socket_weapon_chain_heal_percent = 1 },
        tooltip = "Every 8th weapon hit restores health.\nDetails: Count: 5, Healing: 1%",
        tiers = {
            [1] = { name = "Small Weapon Chain Gem", bonuses = { socket_weapon_chain_count = 8, socket_weapon_chain_heal_percent = 1 }, tooltip = "Every 8th weapon hit restores health.\nDetails: Count: 8, Healing: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Weapon Chain Gem", bonuses = { socket_weapon_chain_count = 7, socket_weapon_chain_heal_percent = 1 }, tooltip = "Every 7th weapon hit restores health.\nDetails: Count: 7, Healing: 1%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Weapon Chain Gem", bonuses = { socket_weapon_chain_count = 6, socket_weapon_chain_heal_percent = 2 }, tooltip = "Every 6th weapon hit restores health.\nDetails: Count: 6, Healing: 2%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Weapon Chain Gem", bonuses = { socket_weapon_chain_count = 6, socket_weapon_chain_heal_percent = 2 }, tooltip = "Every 6th weapon hit restores health.\nDetails: Count: 6, Healing: 2%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Weapon Chain Gem", bonuses = { socket_weapon_chain_count = 5, socket_weapon_chain_heal_percent = 3 }, tooltip = "Every 5th weapon hit restores health.\nDetails: Count: 5, Healing: 3%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Weapon Chain Gem", bonuses = { socket_weapon_chain_count = 4, socket_weapon_chain_heal_percent = 4 }, tooltip = "Every 4th weapon hit restores health.\nDetails: Count: 4, Healing: 4%" }
        },
    },
    -- 78 --
    calmrecoverygem = {
        itemId = 30741,
        name = "Calm Recovery Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "necklace", "ring" },
        bestFor = { "Any Vocation" },
        style = "Out of Combat Recovery",
        bonuses = { socket_calm_recovery_cooldown = 15, socket_calm_recovery_idle_seconds = 8, socket_calm_recovery_percent = 1 },
        tooltip = "If you have not dealt or received damage for 8s, your next self-heal is stronger.\nDetails: Cooldown: 15s, Idle Time: 8s, Health: 1%",
        tiers = {
            [1] = { name = "Small Calm Recovery Gem", bonuses = { socket_calm_recovery_cooldown = 15, socket_calm_recovery_idle_seconds = 8, socket_calm_recovery_percent = 1 }, tooltip = "If you have not dealt or received damage for 8s, your next self-heal is stronger.\nDetails: Cooldown: 15s, Idle Time: 8s, Health: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Calm Recovery Gem", bonuses = { socket_calm_recovery_cooldown = 15, socket_calm_recovery_idle_seconds = 8, socket_calm_recovery_percent = 2 }, tooltip = "If you have not dealt or received damage for 8s, your next self-heal is stronger.\nDetails: Cooldown: 15s, Idle Time: 8s, Health: 2%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Calm Recovery Gem", bonuses = { socket_calm_recovery_cooldown = 15, socket_calm_recovery_idle_seconds = 8, socket_calm_recovery_percent = 3 }, tooltip = "If you have not dealt or received damage for 8s, your next self-heal is stronger.\nDetails: Cooldown: 15s, Idle Time: 8s, Health: 3%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Calm Recovery Gem", bonuses = { socket_calm_recovery_cooldown = 15, socket_calm_recovery_idle_seconds = 8, socket_calm_recovery_percent = 4 }, tooltip = "If you have not dealt or received damage for 8s, your next self-heal is stronger.\nDetails: Cooldown: 15s, Idle Time: 8s, Health: 4%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Calm Recovery Gem", bonuses = { socket_calm_recovery_cooldown = 15, socket_calm_recovery_idle_seconds = 8, socket_calm_recovery_percent = 5 }, tooltip = "If you have not dealt or received damage for 8s, your next self-heal is stronger.\nDetails: Cooldown: 15s, Idle Time: 8s, Health: 5%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Calm Recovery Gem", bonuses = { socket_calm_recovery_cooldown = 15, socket_calm_recovery_idle_seconds = 8, socket_calm_recovery_percent = 6 }, tooltip = "If you have not dealt or received damage for 8s, your next self-heal is stronger.\nDetails: Cooldown: 15s, Idle Time: 8s, Health: 6%" }
        },
    },
    -- 79 --
    panicrecoverygem = {
        itemId = 30742,
        name = "Panic Recovery Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "necklace", "ring" },
        bestFor = { "Any Vocation" },
        style = "Emergency Healing",
        bonuses = { socket_panic_recovery_cooldown = 20, socket_panic_recovery_percent = 1, socket_panic_recovery_threshold = 25 },
        tooltip = "Below 25% HP, your next self-heal is stronger.\nDetails: Cooldown: 20s, Healing: 1%, Threshold: 25%",
        tiers = {
            [1] = { name = "Small Panic Recovery Gem", bonuses = { socket_panic_recovery_cooldown = 20, socket_panic_recovery_percent = 1, socket_panic_recovery_threshold = 25 }, tooltip = "Below 25% HP, your next self-heal is stronger.\nDetails: Cooldown: 20s, Healing: 1%, Threshold: 25%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Panic Recovery Gem", bonuses = { socket_panic_recovery_cooldown = 20, socket_panic_recovery_percent = 2, socket_panic_recovery_threshold = 25 }, tooltip = "Below 25% HP, your next self-heal is stronger.\nDetails: Cooldown: 20s, Healing: 2%, Threshold: 25%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Panic Recovery Gem", bonuses = { socket_panic_recovery_cooldown = 20, socket_panic_recovery_percent = 3, socket_panic_recovery_threshold = 30 }, tooltip = "Below 30% HP, your next self-heal is stronger.\nDetails: Cooldown: 20s, Healing: 3%, Threshold: 25%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Panic Recovery Gem", bonuses = { socket_panic_recovery_cooldown = 20, socket_panic_recovery_percent = 4, socket_panic_recovery_threshold = 30 }, tooltip = "Below 30% HP, your next self-heal is stronger.\nDetails: Cooldown: 20s, Healing: 4%, Threshold: 25%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Panic Recovery Gem", bonuses = { socket_panic_recovery_cooldown = 20, socket_panic_recovery_percent = 5, socket_panic_recovery_threshold = 35 }, tooltip = "Below 35% HP, your next self-heal is stronger.\nDetails: Cooldown: 20s, Healing: 5%, Threshold: 25%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Panic Recovery Gem", bonuses = { socket_panic_recovery_cooldown = 20, socket_panic_recovery_percent = 6, socket_panic_recovery_threshold = 40 }, tooltip = "Below 40% HP, your next self-heal is stronger.\nDetails: Cooldown: 20s, Healing: 6%, Threshold: 25%" }
        },
    },
    -- 80 --
    narrowescapegem = {
        itemId = 30743,
        name = "Narrow Escape Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "boots", "ring", "necklace" },
        bestFor = { "Any Vocation" },
        style = "Survival",
        bonuses = { socket_narrow_escape_cooldown = 30, socket_narrow_escape_mana_percent = 1, socket_narrow_escape_threshold = 10 },
        tooltip = "If a hit leaves you below 10% HP, restore mana.\nDetails: Cooldown: 30s, Mana Restored: 1%, Threshold: 10%",
        tiers = {
            [1] = { name = "Small Narrow Escape Gem", bonuses = { socket_narrow_escape_cooldown = 30, socket_narrow_escape_mana_percent = 1, socket_narrow_escape_threshold = 10 }, tooltip = "If a hit leaves you below 10% HP, restore mana.\nDetails: Cooldown: 30s, Mana Restored: 1%, Threshold: 10%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Narrow Escape Gem", bonuses = { socket_narrow_escape_cooldown = 30, socket_narrow_escape_mana_percent = 1, socket_narrow_escape_threshold = 15 }, tooltip = "If a hit leaves you below 15% HP, restore mana.\nDetails: Cooldown: 30s, Mana Restored: 1%, Threshold: 15%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Narrow Escape Gem", bonuses = { socket_narrow_escape_cooldown = 30, socket_narrow_escape_mana_percent = 2, socket_narrow_escape_threshold = 20 }, tooltip = "If a hit leaves you below 20% HP, restore mana.\nDetails: Cooldown: 30s, Mana Restored: 2%, Threshold: 20%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Narrow Escape Gem", bonuses = { socket_narrow_escape_cooldown = 30, socket_narrow_escape_mana_percent = 2, socket_narrow_escape_threshold = 25 }, tooltip = "If a hit leaves you below 25% HP, restore mana.\nDetails: Cooldown: 30s, Mana Restored: 2%, Threshold: 25%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Narrow Escape Gem", bonuses = { socket_narrow_escape_cooldown = 30, socket_narrow_escape_mana_percent = 3, socket_narrow_escape_threshold = 30 }, tooltip = "If a hit leaves you below 30% HP, restore mana.\nDetails: Cooldown: 30s, Mana Restored: 3%, Threshold: 10%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Narrow Escape Gem", bonuses = { socket_narrow_escape_cooldown = 30, socket_narrow_escape_mana_percent = 5, socket_narrow_escape_threshold = 35 }, tooltip = "If a hit leaves you below 35% HP, restore mana.\nDetails: Cooldown: 30s, Mana Restored: 5%, Threshold: 10%" }
        },
    },
    -- 81 --
    secondsipgem = {
        itemId = 30744,
        name = "Second Sip Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "belt", "gloves" },
        bestFor = { "Any Vocation" },
        style = "Potion Follow-up",
        bonuses = { socket_second_sip_cooldown = 15, socket_second_sip_percent = 1, socket_second_sip_window = 8 },
        tooltip = "After a health potion, your next mana potion is stronger.\nDetails: Cooldown: 15s, Mana: 1%, Window: 8s",
        tiers = {
            [1] = { name = "Small Second Sip Gem", bonuses = { socket_second_sip_cooldown = 15, socket_second_sip_percent = 1, socket_second_sip_window = 8 }, tooltip = "After a health potion, your next mana potion is stronger.\nDetails: Cooldown: 15s, Mana: 1%, Window: 8s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Second Sip Gem", bonuses = { socket_second_sip_cooldown = 15, socket_second_sip_percent = 2, socket_second_sip_window = 8 }, tooltip = "After a health potion, your next mana potion is stronger.\nDetails: Cooldown: 15s, Mana: 2%, Window: 8s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Second Sip Gem", bonuses = { socket_second_sip_cooldown = 15, socket_second_sip_percent = 3, socket_second_sip_window = 8 }, tooltip = "After a health potion, your next mana potion is stronger.\nDetails: Cooldown: 15s, Mana: 3%, Window: 8s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Second Sip Gem", bonuses = { socket_second_sip_cooldown = 15, socket_second_sip_percent = 4, socket_second_sip_window = 8 }, tooltip = "After a health potion, your next mana potion is stronger.\nDetails: Cooldown: 15s, Mana: 4%, Window: 8s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Second Sip Gem", bonuses = { socket_second_sip_cooldown = 15, socket_second_sip_percent = 5, socket_second_sip_window = 8 }, tooltip = "After a health potion, your next mana potion is stronger.\nDetails: Cooldown: 15s, Mana: 5%, Window: 8s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Second Sip Gem", bonuses = { socket_second_sip_cooldown = 15, socket_second_sip_percent = 6, socket_second_sip_window = 8 }, tooltip = "After a health potion, your next mana potion is stronger.\nDetails: Cooldown: 15s, Mana: 6%, Window: 8s" }
        },
    },
    -- 82 --
    mirrorsipgem = {
        itemId = 30745,
        name = "Mirror Sip Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "belt", "gloves" },
        bestFor = { "Any Vocation" },
        style = "Balanced Potion",
        bonuses = { socket_mirror_sip_cooldown = 20, socket_mirror_sip_percent = 1 },
        tooltip = "Health potions restore a tiny amount of mana too.\nDetails: Cooldown: 20s, Mana: 1%",
        tiers = {
            [1] = { name = "Small Mirror Sip Gem", bonuses = { socket_mirror_sip_cooldown = 20, socket_mirror_sip_percent = 1 }, tooltip = "Health potions restore a tiny amount of mana too.\nDetails: Cooldown: 20s, Mana: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Mirror Sip Gem", bonuses = { socket_mirror_sip_cooldown = 20, socket_mirror_sip_percent = 1 }, tooltip = "Health potions restore a tiny amount of mana too.\nDetails: Cooldown: 20s, Mana: 1%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Mirror Sip Gem", bonuses = { socket_mirror_sip_cooldown = 20, socket_mirror_sip_percent = 2 }, tooltip = "Health potions restore a tiny amount of mana too.\nDetails: Cooldown: 20s, Mana: 2%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Mirror Sip Gem", bonuses = { socket_mirror_sip_cooldown = 20, socket_mirror_sip_percent = 2 }, tooltip = "Health potions restore a tiny amount of mana too.\nDetails: Cooldown: 20s, Mana: 2%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Mirror Sip Gem", bonuses = { socket_mirror_sip_cooldown = 20, socket_mirror_sip_percent = 3 }, tooltip = "Health potions restore a tiny amount of mana too.\nDetails: Cooldown: 20s, Mana: 3%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Mirror Sip Gem", bonuses = { socket_mirror_sip_cooldown = 20, socket_mirror_sip_percent = 4 }, tooltip = "Health potions restore a tiny amount of mana too.\nDetails: Cooldown: 20s, Mana: 4%" }
        },
    },
    -- 83 --
    warmupgem = {
        itemId = 30746,
        name = "Warmup Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring" },
        bestFor = { "Any Vocation" },
        style = "Slow Start",
        bonuses = { socket_warmup_cooldown = 10, socket_warmup_idle_seconds = 5, socket_warmup_percent = 1 },
        tooltip = "First hit after 5s without attacking deals more damage.\nDetails: Cooldown: 10s, Idle Time: 5s, Damage: 1%",
        tiers = {
            [1] = { name = "Small Warmup Gem", bonuses = { socket_warmup_cooldown = 10, socket_warmup_idle_seconds = 5, socket_warmup_percent = 1 }, tooltip = "First hit after 5s without attacking deals more damage.\nDetails: Cooldown: 10s, Idle Time: 5s, Damage: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Warmup Gem", bonuses = { socket_warmup_cooldown = 10, socket_warmup_idle_seconds = 5, socket_warmup_percent = 3 }, tooltip = "First hit after 5s without attacking deals more damage.\nDetails: Cooldown: 10s, Idle Time: 5s, Damage: 3%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Warmup Gem", bonuses = { socket_warmup_cooldown = 10, socket_warmup_idle_seconds = 4, socket_warmup_percent = 5 }, tooltip = "First hit after 5s without attacking deals more damage.\nDetails: Cooldown: 10s, Idle Time: 4s, Damage: 5%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Warmup Gem", bonuses = { socket_warmup_cooldown = 10, socket_warmup_idle_seconds = 4, socket_warmup_percent = 7 }, tooltip = "First hit after 5s without attacking deals more damage.\nDetails: Cooldown: 10s, Idle Time: 4s, Damage: 7%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Warmup Gem", bonuses = { socket_warmup_cooldown = 10, socket_warmup_idle_seconds = 3, socket_warmup_percent = 10 }, tooltip = "First hit after 5s without attacking deals more damage.\nDetails: Cooldown: 10s, Idle Time: 3s, Damage: 10%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Warmup Gem", bonuses = { socket_warmup_cooldown = 10, socket_warmup_idle_seconds = 2, socket_warmup_percent = 13 }, tooltip = "First hit after 5s without attacking deals more damage.\nDetails: Cooldown: 10s, Idle Time: 2s, Damage: 13%" }
        },
    },
    -- 84 --
    cooldowngem = {
        itemId = 30747,
        name = "Cooldown Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "shield", "ring" },
        bestFor = { "Any Vocation" },
        style = "Defensive Reset",
        bonuses = { socket_cooldown_cooldown = 10, socket_cooldown_idle_seconds = 5, socket_cooldown_reduce_percent = 1 },
        tooltip = "First received hit after 5s without being hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 5s, Reduction: 1s",
        tiers = {
            [1] = { name = "Small Cooldown Gem", bonuses = { socket_cooldown_cooldown = 10, socket_cooldown_idle_seconds = 5, socket_cooldown_reduce_percent = 1 }, tooltip = "First received hit after 5s without being hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 5s, Reduction: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Cooldown Gem", bonuses = { socket_cooldown_cooldown = 10, socket_cooldown_idle_seconds = 5, socket_cooldown_reduce_percent = 2 }, tooltip = "First received hit after 5s without being hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 5s, Reduction: 2%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Cooldown Gem", bonuses = { socket_cooldown_cooldown = 10, socket_cooldown_idle_seconds = 4, socket_cooldown_reduce_percent = 3 }, tooltip = "First received hit after 4s without being hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 4s, Reduction: 3%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Cooldown Gem", bonuses = { socket_cooldown_cooldown = 10, socket_cooldown_idle_seconds = 4, socket_cooldown_reduce_percent = 4 }, tooltip = "First received hit after 4s without being hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 4s, Reduction: 4%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Cooldown Gem", bonuses = { socket_cooldown_cooldown = 10, socket_cooldown_idle_seconds = 3, socket_cooldown_reduce_percent = 5 }, tooltip = "First received hit after 3s without being hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 3s, Reduction: 5%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Cooldown Gem", bonuses = { socket_cooldown_cooldown = 10, socket_cooldown_idle_seconds = 3, socket_cooldown_reduce_percent = 6 }, tooltip = "First received hit after 3s without being hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 3s, Reduction: 6%" }
        },
    },
    -- 85 --
    luckyscratchgem = {
        itemId = 30748,
        name = "Lucky Scratch Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "gloves", "ring" },
        bestFor = { "Any Vocation" },
        style = "Small Proc",
        bonuses = { socket_lucky_scratch_chance = 1, socket_lucky_scratch_cooldown = 12, socket_lucky_scratch_damage_percent = 2 },
        tooltip = "Hits have a small chance to deal tiny bonus damage.\nDetails: Chance: 1%, Cooldown: 12s, Damage: 2%",
        tiers = {
            [1] = { name = "Small Lucky Scratch Gem", bonuses = { socket_lucky_scratch_chance = 2, socket_lucky_scratch_cooldown = 12, socket_lucky_scratch_damage_percent = 2 }, tooltip = "Hits have a small chance to deal tiny bonus damage.\nDetails: Chance: 2%, Cooldown: 12s, Damage: 2%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Lucky Scratch Gem", bonuses = { socket_lucky_scratch_chance = 3, socket_lucky_scratch_cooldown = 12, socket_lucky_scratch_damage_percent = 4 }, tooltip = "Hits have a small chance to deal tiny bonus damage.\nDetails: Chance: 3%, Cooldown: 12s, Damage: 4%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Lucky Scratch Gem", bonuses = { socket_lucky_scratch_chance = 4, socket_lucky_scratch_cooldown = 12, socket_lucky_scratch_damage_percent = 6 }, tooltip = "Hits have a small chance to deal tiny bonus damage.\nDetails: Chance: 4%, Cooldown: 12s, Damage: 6%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Lucky Scratch Gem", bonuses = { socket_lucky_scratch_chance = 5, socket_lucky_scratch_cooldown = 12, socket_lucky_scratch_damage_percent = 8 }, tooltip = "Hits have a small chance to deal tiny bonus damage.\nDetails: Chance: 5%, Cooldown: 12s, Damage: 8%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Lucky Scratch Gem", bonuses = { socket_lucky_scratch_chance = 7, socket_lucky_scratch_cooldown = 12, socket_lucky_scratch_damage_percent = 12 }, tooltip = "Hits have a small chance to deal tiny bonus damage.\nDetails: Chance: 7%, Cooldown: 12s, Damage: 12%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Lucky Scratch Gem", bonuses = { socket_lucky_scratch_chance = 10, socket_lucky_scratch_cooldown = 12, socket_lucky_scratch_damage_percent = 15 }, tooltip = "Hits have a small chance to deal tiny bonus damage.\nDetails: Chance: 10%, Cooldown: 12s, Damage: 15%" }
        },
    },
    -- 86 --
    luckyguardgem = {
        itemId = 30749,
        name = "Lucky Guard Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "shield", "armor", "ring" },
        bestFor = { "Any Vocation" },
        style = "Small Defense Proc",
        bonuses = { socket_lucky_guard_chance = 1, socket_lucky_guard_cooldown = 8, socket_lucky_guard_reduce_percent = 2 },
        tooltip = "Received hits have a small chance to be reduced.\nDetails: Chance: 1%, Cooldown: 12s, Reduction: 2%",
        tiers = {
            [1] = { name = "Small Lucky Guard Gem", bonuses = { socket_lucky_guard_chance = 2, socket_lucky_guard_cooldown = 12, socket_lucky_guard_reduce_percent = 2 }, tooltip = "Received hits have a small chance to be reduced.\nDetails: Chance: 2%, Cooldown: 12s, Reduction: 2%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Lucky Guard Gem", bonuses = { socket_lucky_guard_chance = 3, socket_lucky_guard_cooldown = 12, socket_lucky_guard_reduce_percent = 4 }, tooltip = "Received hits have a small chance to be reduced.\nDetails: Chance: 3%, Cooldown: 12s, Reduction: 4%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Lucky Guard Gem", bonuses = { socket_lucky_guard_chance = 4, socket_lucky_guard_cooldown = 12, socket_lucky_guard_reduce_percent = 6 }, tooltip = "Received hits have a small chance to be reduced.\nDetails: Chance: 4%, Cooldown: 12s, Reduction: 6%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Lucky Guard Gem", bonuses = { socket_lucky_guard_chance = 5, socket_lucky_guard_cooldown = 12, socket_lucky_guard_reduce_percent = 8 }, tooltip = "Received hits have a small chance to be reduced.\nDetails: Chance: 5%, Cooldown: 12s, Reduction: 8%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Lucky Guard Gem", bonuses = { socket_lucky_guard_chance = 7, socket_lucky_guard_cooldown = 12, socket_lucky_guard_reduce_percent = 12 }, tooltip = "Received hits have a small chance to be reduced.\nDetails: Chance: 7%, Cooldown: 12s, Reduction: 12%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Lucky Guard Gem", bonuses = { socket_lucky_guard_chance = 10, socket_lucky_guard_cooldown = 12, socket_lucky_guard_reduce_percent = 15 }, tooltip = "Received hits have a small chance to be reduced.\nDetails: Chance: 10%, Cooldown: 12s, Reduction: 15%" }
        },
    },
    -- 87 --
    minorfeastgem = {
        itemId = 30750,
        name = "Minor Feast Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "necklace", "ring" },
        bestFor = { "Any Vocation" },
        style = "Kill Sustain",
        bonuses = { socket_minor_feast_heal_percent = 1, socket_minor_feast_kill_count = 8 },
        tooltip = "Every 8th monster kill restores health.\nDetails: Healing: 1%",
        tiers = {
            [1] = { name = "Small Minor Feast Gem", bonuses = { socket_minor_feast_heal_percent = 1, socket_minor_feast_kill_count = 8 }, tooltip = "Every 8th monster kill restores health.\nDetails: Healing: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Minor Feast Gem", bonuses = { socket_minor_feast_heal_percent = 1, socket_minor_feast_kill_count = 7 }, tooltip = "Every 7th monster kill restores health.\nDetails: Healing: 1%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Minor Feast Gem", bonuses = { socket_minor_feast_heal_percent = 2, socket_minor_feast_kill_count = 6 }, tooltip = "Every 6th monster kill restores health.\nDetails: Healing: 2%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Minor Feast Gem", bonuses = { socket_minor_feast_heal_percent = 2, socket_minor_feast_kill_count = 5 }, tooltip = "Every 5th monster kill restores health.\nDetails: Healing: 2%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Minor Feast Gem", bonuses = { socket_minor_feast_heal_percent = 3, socket_minor_feast_kill_count = 4 }, tooltip = "Every 4th monster kill restores health.\nDetails: Healing: 3%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Minor Feast Gem", bonuses = { socket_minor_feast_heal_percent = 4, socket_minor_feast_kill_count = 3 }, tooltip = "Every 3th monster kill restores health.\nDetails: Healing: 4%" }
        },
    },
    -- 88 --
    minorfocusgem = {
        itemId = 30751,
        name = "Minor Focus Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "necklace", "ring" },
        bestFor = { "Any Vocation" },
        style = "Kill Mana",
        bonuses = { socket_minor_focus_kill_count = 8, socket_minor_focus_mana_percent = 1 },
        tooltip = "Every 8th monster kill restores mana.\nDetails: Mana: 1%",
        tiers = {
            [1] = { name = "Small Minor Focus Gem", bonuses = { socket_minor_focus_kill_count = 8, socket_minor_focus_mana_percent = 1 }, tooltip = "Every 8th monster kill restores mana.\nDetails: Mana: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Minor Focus Gem", bonuses = { socket_minor_focus_kill_count = 7, socket_minor_focus_mana_percent = 1 }, tooltip = "Every 7th monster kill restores mana.\nDetails: Mana: 1%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Minor Focus Gem", bonuses = { socket_minor_focus_kill_count = 6, socket_minor_focus_mana_percent = 2 }, tooltip = "Every 6th monster kill restores mana.\nDetails: Mana: 2%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Minor Focus Gem", bonuses = { socket_minor_focus_kill_count = 5, socket_minor_focus_mana_percent = 2 }, tooltip = "Every 5th monster kill restores mana.\nDetails: Mana: 2%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Minor Focus Gem", bonuses = { socket_minor_focus_kill_count = 4, socket_minor_focus_mana_percent = 3 }, tooltip = "Every 4th monster kill restores mana.\nDetails: Mana: 3%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Minor Focus Gem", bonuses = { socket_minor_focus_kill_count = 3, socket_minor_focus_mana_percent = 4 }, tooltip = "Every 3th monster kill restores mana.\nDetails: Mana: 4%" }
        },
    },
    -- 89 --
    safehandsgem = {
        itemId = 30752,
        name = "Safe Hands Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "gloves", "belt" },
        bestFor = { "Any Vocation" },
        style = "Defensive Potion",
        bonuses = { socket_safe_hands_cooldown = 15, socket_safe_hands_reduce_percent = 1 },
        tooltip = "After using a potion, your next received hit is reduced.\nDetails: Cooldown: 15s, Reduction: 1%",
        tiers = {
            [1] = { name = "Small Safe Hands Gem", bonuses = { socket_safe_hands_cooldown = 15, socket_safe_hands_reduce_percent = 1 }, tooltip = "After using a potion, your next received hit is reduced.\nDetails: Cooldown: 15s, Reduction: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Safe Hands Gem", bonuses = { socket_safe_hands_cooldown = 15, socket_safe_hands_reduce_percent = 2 }, tooltip = "After using a potion, your next received hit is reduced.\nDetails: Cooldown: 15s, Reduction: 2%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Safe Hands Gem", bonuses = { socket_safe_hands_cooldown = 15, socket_safe_hands_reduce_percent = 3 }, tooltip = "After using a potion, your next received hit is reduced.\nDetails: Cooldown: 15s, Reduction: 3%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Safe Hands Gem", bonuses = { socket_safe_hands_cooldown = 15, socket_safe_hands_reduce_percent = 4 }, tooltip = "After using a potion, your next received hit is reduced.\nDetails: Cooldown: 15s, Reduction: 4%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Safe Hands Gem", bonuses = { socket_safe_hands_cooldown = 15, socket_safe_hands_reduce_percent = 5 }, tooltip = "After using a potion, your next received hit is reduced.\nDetails: Cooldown: 15s, Reduction: 5%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Safe Hands Gem", bonuses = { socket_safe_hands_cooldown = 15, socket_safe_hands_reduce_percent = 6 }, tooltip = "After using a potion, your next received hit is reduced.\nDetails: Cooldown: 15s, Reduction: 6%" }
        },
    },
    -- 90 --
    sharphandsgem = {
        itemId = 30753,
        name = "Sharp Hands Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "gloves", "belt" },
        bestFor = { "Any Vocation" },
        style = "Offensive Potion",
        bonuses = { socket_sharp_hands_cooldown = 15, socket_sharp_hands_percent = 1 },
        tooltip = "After using a potion, your next hit deals more damage.\nDetails: Cooldown: 15s, Damage: 1%",
        tiers = {
            [1] = { name = "Small Sharp Hands Gem", bonuses = { socket_sharp_hands_cooldown = 15, socket_sharp_hands_percent = 1 }, tooltip = "After using a potion, your next hit deals more damage.\nDetails: Cooldown: 15s, Damage: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Sharp Hands Gem", bonuses = { socket_sharp_hands_cooldown = 15, socket_sharp_hands_percent = 2 }, tooltip = "After using a potion, your next hit deals more damage.\nDetails: Cooldown: 15s, Damage: 2%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Sharp Hands Gem", bonuses = { socket_sharp_hands_cooldown = 15, socket_sharp_hands_percent = 3 }, tooltip = "After using a potion, your next hit deals more damage.\nDetails: Cooldown: 15s, Damage: 3%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Sharp Hands Gem", bonuses = { socket_sharp_hands_cooldown = 15, socket_sharp_hands_percent = 4 }, tooltip = "After using a potion, your next hit deals more damage.\nDetails: Cooldown: 15s, Damage: 4%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Sharp Hands Gem", bonuses = { socket_sharp_hands_cooldown = 15, socket_sharp_hands_percent = 5 }, tooltip = "After using a potion, your next hit deals more damage.\nDetails: Cooldown: 15s, Damage: 5%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Sharp Hands Gem", bonuses = { socket_sharp_hands_cooldown = 15, socket_sharp_hands_percent = 6 }, tooltip = "After using a potion, your next hit deals more damage.\nDetails: Cooldown: 15s, Damage: 6%" }
        },
    },
    -- 91 --
    softlandinggem = {
        itemId = 30754,
        name = "Soft Landing Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "boots", "legs" },
        bestFor = { "Any Vocation" },
        style = "Anti Combo",
        bonuses = { socket_soft_landing_cooldown = 12, socket_soft_landing_reduce_percent = 1, socket_soft_landing_window = 1 },
        tooltip = "If you receive two hits within 1s, the second hit is reduced.\nDetails: Cooldown: 12s, Reduction: 1%, Window: 1s",
        tiers = {
            [1] = { name = "Small Soft Landing Gem", bonuses = { socket_soft_landing_cooldown = 12, socket_soft_landing_reduce_percent = 1, socket_soft_landing_window = 1 }, tooltip = "If you receive two hits within 1s, the second hit is reduced.\nDetails: Cooldown: 12s, Reduction: 1%, Window: 1s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Soft Landing Gem", bonuses = { socket_soft_landing_cooldown = 12, socket_soft_landing_reduce_percent = 2, socket_soft_landing_window = 1 }, tooltip = "If you receive two hits within 1s, the second hit is reduced.\nDetails: Cooldown: 12s, Reduction: 2%, Window: 1s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Soft Landing Gem", bonuses = { socket_soft_landing_cooldown = 12, socket_soft_landing_reduce_percent = 3, socket_soft_landing_window = 1 }, tooltip = "If you receive two hits within 1s, the second hit is reduced.\nDetails: Cooldown: 12s, Reduction: 3%, Window: 1s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Soft Landing Gem", bonuses = { socket_soft_landing_cooldown = 12, socket_soft_landing_reduce_percent = 4, socket_soft_landing_window = 1 }, tooltip = "If you receive two hits within 1s, the second hit is reduced.\nDetails: Cooldown: 12s, Reduction: 4%, Window: 1s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Soft Landing Gem", bonuses = { socket_soft_landing_cooldown = 12, socket_soft_landing_reduce_percent = 5, socket_soft_landing_window = 1 }, tooltip = "If you receive two hits within 1s, the second hit is reduced.\nDetails: Cooldown: 12s, Reduction: 5%, Window: 1s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Soft Landing Gem", bonuses = { socket_soft_landing_cooldown = 12, socket_soft_landing_reduce_percent = 6, socket_soft_landing_window = 1 }, tooltip = "If you receive two hits within 1s, the second hit is reduced.\nDetails: Cooldown: 12s, Reduction: 6%, Window: 1s" }
        },
    },
    -- 92 --
    hardlandinggem = {
        itemId = 30755,
        name = "Hard Landing Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "boots", "weapon" },
        bestFor = { "Any Vocation" },
        style = "Retaliation Combo",
        bonuses = { socket_hard_landing_cooldown = 12, socket_hard_landing_percent = 1, socket_hard_landing_window = 1 },
        tooltip = "After receiving two hits within 1s, your next hit deals more damage.\nDetails: Cooldown: 12s, Damage: 1%, Window: 1s",
        tiers = {
            [1] = { name = "Small Hard Landing Gem", bonuses = { socket_hard_landing_cooldown = 12, socket_hard_landing_percent = 1, socket_hard_landing_window = 1 }, tooltip = "After receiving two hits within 1s, your next hit deals more damage.\nDetails: Cooldown: 12s, Damage: 1%, Window: 1s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Hard Landing Gem", bonuses = { socket_hard_landing_cooldown = 12, socket_hard_landing_percent = 2, socket_hard_landing_window = 1 }, tooltip = "After receiving two hits within 1s, your next hit deals more damage.\nDetails: Cooldown: 12s, Damage: 2%, Window: 1s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Hard Landing Gem", bonuses = { socket_hard_landing_cooldown = 12, socket_hard_landing_percent = 3, socket_hard_landing_window = 1 }, tooltip = "After receiving two hits within 1s, your next hit deals more damage.\nDetails: Cooldown: 12s, Damage: 3%, Window: 1s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Hard Landing Gem", bonuses = { socket_hard_landing_cooldown = 12, socket_hard_landing_percent = 4, socket_hard_landing_window = 1 }, tooltip = "After receiving two hits within 1s, your next hit deals more damage.\nDetails: Cooldown: 12s, Damage: 4%, Window: 1s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Hard Landing Gem", bonuses = { socket_hard_landing_cooldown = 12, socket_hard_landing_percent = 5, socket_hard_landing_window = 1 }, tooltip = "After receiving two hits within 1s, your next hit deals more damage.\nDetails: Cooldown: 12s, Damage: 5%, Window: 1s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Hard Landing Gem", bonuses = { socket_hard_landing_cooldown = 12, socket_hard_landing_percent = 6, socket_hard_landing_window = 1 }, tooltip = "After receiving two hits within 1s, your next hit deals more damage.\nDetails: Cooldown: 12s, Damage: 6%, Window: 1s" }
        },
    },
    -- 93 --
    lowflamegem = {
        itemId = 30756,
        name = "Low Flame Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring" },
        bestFor = { "Any Vocation" },
        style = "Small Power",
        bonuses = { socket_low_flame_chance = 1, socket_low_flame_cooldown = 12, socket_low_flame_damage_percent = 5, socket_low_flame_threshold = 50 },
        tooltip = "Below 50% HP, hits have a small chance for tiny bonus damage.\nDetails: Chance: 1%, Cooldown: 12s, Damage: 5%, Threshold: 50%",
        tiers = {
            [1] = { name = "Small Low Flame Gem", bonuses = { socket_low_flame_chance = 2, socket_low_flame_cooldown = 12, socket_low_flame_damage_percent = 5, socket_low_flame_threshold = 50 }, tooltip = "Below 50% HP, hits have a small chance for tiny bonus damage.\nDetails: Chance: 2%, Cooldown: 12s, Damage: 5%, Threshold: 50%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Low Flame Gem", bonuses = { socket_low_flame_chance = 3, socket_low_flame_cooldown = 12, socket_low_flame_damage_percent = 5, socket_low_flame_threshold = 50 }, tooltip = "Below 50% HP, hits have a small chance for tiny bonus damage.\nDetails: Chance: 3%, Cooldown: 12s, Damage: 5%, Threshold: 50%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Low Flame Gem", bonuses = { socket_low_flame_chance = 4, socket_low_flame_cooldown = 12, socket_low_flame_damage_percent = 5, socket_low_flame_threshold = 50 }, tooltip = "Below 50% HP, hits have a small chance for tiny bonus damage.\nDetails: Chance: 4%, Cooldown: 12s, Damage: 5%, Threshold: 50%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Low Flame Gem", bonuses = { socket_low_flame_chance = 5, socket_low_flame_cooldown = 12, socket_low_flame_damage_percent = 5, socket_low_flame_threshold = 50 }, tooltip = "Below 50% HP, hits have a small chance for tiny bonus damage.\nDetails: Chance: 5%, Cooldown: 12s, Damage: 5%, Threshold: 50%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Low Flame Gem", bonuses = { socket_low_flame_chance = 7, socket_low_flame_cooldown = 12, socket_low_flame_damage_percent = 5, socket_low_flame_threshold = 50 }, tooltip = "Below 50% HP, hits have a small chance for tiny bonus damage.\nDetails: Chance: 7%, Cooldown: 12s, Damage: 5%, Threshold: 50%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Low Flame Gem", bonuses = { socket_low_flame_chance = 10, socket_low_flame_cooldown = 12, socket_low_flame_damage_percent = 5, socket_low_flame_threshold = 50 }, tooltip = "Below 50% HP, hits have a small chance for tiny bonus damage.\nDetails: Chance: 10%, Cooldown: 12s, Damage: 5%, Threshold: 50%" }
        },
    },
    -- 94 --
    highflamegem = {
        itemId = 30757,
        name = "High Flame Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring" },
        bestFor = { "Any Vocation" },
        style = "Confidence",
        bonuses = { socket_high_flame_chance = 1, socket_high_flame_cooldown = 15, socket_high_flame_damage_percent = 5, socket_high_flame_threshold = 80 },
        tooltip = "Above 80% HP, hits have a small chance for tiny bonus damage.\nDetails: Chance: 1%, Cooldown: 15s, Damage: 5%, Threshold: 80%",
        tiers = {
            [1] = { name = "Small High Flame Gem", bonuses = { socket_high_flame_chance = 2, socket_high_flame_cooldown = 15, socket_high_flame_damage_percent = 5, socket_high_flame_threshold = 80 }, tooltip = "Above 80% HP, hits have a small chance for tiny bonus damage.\nDetails: Chance: 2%, Cooldown: 15s, Damage: 5%, Threshold: 80%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser High Flame Gem", bonuses = { socket_high_flame_chance = 3, socket_high_flame_cooldown = 15, socket_high_flame_damage_percent = 5, socket_high_flame_threshold = 80 }, tooltip = "Above 80% HP, hits have a small chance for tiny bonus damage.\nDetails: Chance: 3%, Cooldown: 15s, Damage: 5%, Threshold: 80%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater High Flame Gem", bonuses = { socket_high_flame_chance = 4, socket_high_flame_cooldown = 15, socket_high_flame_damage_percent = 5, socket_high_flame_threshold = 80 }, tooltip = "Above 80% HP, hits have a small chance for tiny bonus damage.\nDetails: Chance: 4%, Cooldown: 15s, Damage: 5%, Threshold: 80%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super High Flame Gem", bonuses = { socket_high_flame_chance = 5, socket_high_flame_cooldown = 15, socket_high_flame_damage_percent = 5, socket_high_flame_threshold = 80 }, tooltip = "Above 80% HP, hits have a small chance for tiny bonus damage.\nDetails: Chance: 5%, Cooldown: 15s, Damage: 5%, Threshold: 80%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega High Flame Gem", bonuses = { socket_high_flame_chance = 7, socket_high_flame_cooldown = 15, socket_high_flame_damage_percent = 5, socket_high_flame_threshold = 80 }, tooltip = "Above 80% HP, hits have a small chance for tiny bonus damage.\nDetails: Chance: 7%, Cooldown: 15s, Damage: 5%, Threshold: 80%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal High Flame Gem", bonuses = { socket_high_flame_chance = 10, socket_high_flame_cooldown = 15, socket_high_flame_damage_percent = 5, socket_high_flame_threshold = 80 }, tooltip = "Above 80% HP, hits have a small chance for tiny bonus damage.\nDetails: Chance: 10%, Cooldown: 15s, Damage: 5%, Threshold: 80%" }
        },
    },
    -- 95 --
    lowtidegem = {
        itemId = 30758,
        name = "Low Tide Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "ring", "necklace" },
        bestFor = { "Any Vocation" },
        style = "Low Mana Defense",
        bonuses = { socket_low_tide_cooldown = 15, socket_low_tide_reduce_percent = 1, socket_low_tide_threshold = 25 },
        tooltip = "Below 25% mana, your next received hit is reduced.\nDetails: Cooldown: 15s, Reduction: 1%, Threshold: 25%",
        tiers = {
            [1] = { name = "Small Low Tide Gem", bonuses = { socket_low_tide_cooldown = 15, socket_low_tide_reduce_percent = 1, socket_low_tide_threshold = 25 }, tooltip = "Below 25% mana, your next received hit is reduced.\nDetails: Cooldown: 15s, Reduction: 1%, Threshold: 25%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Low Tide Gem", bonuses = { socket_low_tide_cooldown = 15, socket_low_tide_reduce_percent = 2, socket_low_tide_threshold = 25 }, tooltip = "Below 25% mana, your next received hit is reduced.\nDetails: Cooldown: 15s, Reduction: 2%, Threshold: 25%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Low Tide Gem", bonuses = { socket_low_tide_cooldown = 15, socket_low_tide_reduce_percent = 3, socket_low_tide_threshold = 25 }, tooltip = "Below 25% mana, your next received hit is reduced.\nDetails: Cooldown: 15s, Reduction: 3%, Threshold: 25%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Low Tide Gem", bonuses = { socket_low_tide_cooldown = 15, socket_low_tide_reduce_percent = 4, socket_low_tide_threshold = 25 }, tooltip = "Below 25% mana, your next received hit is reduced.\nDetails: Cooldown: 15s, Reduction: 4%, Threshold: 25%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Low Tide Gem", bonuses = { socket_low_tide_cooldown = 15, socket_low_tide_reduce_percent = 5, socket_low_tide_threshold = 25 }, tooltip = "Below 25% mana, your next received hit is reduced.\nDetails: Cooldown: 15s, Reduction: 5%, Threshold: 25%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Low Tide Gem", bonuses = { socket_low_tide_cooldown = 15, socket_low_tide_reduce_percent = 6, socket_low_tide_threshold = 25 }, tooltip = "Below 25% mana, your next received hit is reduced.\nDetails: Cooldown: 15s, Reduction: 6%, Threshold: 25%" }
        },
    },
    -- 96 --
    hightidegem = {
        itemId = 30759,
        name = "High Tide Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "ring", "necklace", "wand" },
        bestFor = { "Any Vocation" },
        style = "High Mana Recovery",
        bonuses = { socket_high_tide_cooldown = 20, socket_high_tide_heal_percent = 1, socket_high_tide_threshold = 80 },
        tooltip = "Above 80% mana, your next received hit restores health.\nDetails: Cooldown: 20s, Healing: 1%, Threshold: 80%",
        tiers = {
            [1] = { name = "Small High Tide Gem", bonuses = { socket_high_tide_cooldown = 20, socket_high_tide_heal_percent = 1, socket_high_tide_threshold = 80 }, tooltip = "Above 80% mana, your next received hit restores health.\nDetails: Cooldown: 20s, Healing: 1%, Threshold: 80%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser High Tide Gem", bonuses = { socket_high_tide_cooldown = 20, socket_high_tide_heal_percent = 1, socket_high_tide_threshold = 80 }, tooltip = "Above 80% mana, your next received hit restores health.\nDetails: Cooldown: 20s, Healing: 1%, Threshold: 80%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater High Tide Gem", bonuses = { socket_high_tide_cooldown = 20, socket_high_tide_heal_percent = 2, socket_high_tide_threshold = 80 }, tooltip = "Above 80% mana, your next received hit restores health.\nDetails: Cooldown: 20s, Healing: 2%, Threshold: 80%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super High Tide Gem", bonuses = { socket_high_tide_cooldown = 20, socket_high_tide_heal_percent = 2, socket_high_tide_threshold = 80 }, tooltip = "Above 80% mana, your next received hit restores health.\nDetails: Cooldown: 20s, Healing: 2%, Threshold: 80%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega High Tide Gem", bonuses = { socket_high_tide_cooldown = 20, socket_high_tide_heal_percent = 3, socket_high_tide_threshold = 80 }, tooltip = "Above 80% mana, your next received hit restores health.\nDetails: Cooldown: 20s, Healing: 3%, Threshold: 80%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal High Tide Gem", bonuses = { socket_high_tide_cooldown = 20, socket_high_tide_heal_percent = 4, socket_high_tide_threshold = 80 }, tooltip = "Above 80% mana, your next received hit restores health.\nDetails: Cooldown: 20s, Healing: 4%, Threshold: 80%" }
        },
    },
    -- 97 --
    shortfusegem = {
        itemId = 30760,
        name = "Short Fuse Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring" },
        bestFor = { "Any Vocation" },
        style = "Fast Combat",
        bonuses = { socket_short_fuse_cooldown = 15, socket_short_fuse_percent = 1, socket_short_fuse_window = 2 },
        tooltip = "Hits shortly after receiving damage gain tiny bonus damage.\nDetails: Cooldown: 15s, Damage: 1%, Window: 2s",
        tiers = {
            [1] = { name = "Small Short Fuse Gem", bonuses = { socket_short_fuse_cooldown = 15, socket_short_fuse_percent = 1, socket_short_fuse_window = 2 }, tooltip = "Hits shortly after receiving damage gain tiny bonus damage.\nDetails: Cooldown: 15s, Damage: 1%, Window: 2s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Short Fuse Gem", bonuses = { socket_short_fuse_cooldown = 15, socket_short_fuse_percent = 2, socket_short_fuse_window = 2 }, tooltip = "Hits shortly after receiving damage gain tiny bonus damage.\nDetails: Cooldown: 15s, Damage: 2%, Window: 2s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Short Fuse Gem", bonuses = { socket_short_fuse_cooldown = 15, socket_short_fuse_percent = 3, socket_short_fuse_window = 2 }, tooltip = "Hits shortly after receiving damage gain tiny bonus damage.\nDetails: Cooldown: 15s, Damage: 3%, Window: 2s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Short Fuse Gem", bonuses = { socket_short_fuse_cooldown = 15, socket_short_fuse_percent = 4, socket_short_fuse_window = 2 }, tooltip = "Hits shortly after receiving damage gain tiny bonus damage.\nDetails: Cooldown: 15s, Damage: 4%, Window: 2s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Short Fuse Gem", bonuses = { socket_short_fuse_cooldown = 15, socket_short_fuse_percent = 5, socket_short_fuse_window = 2 }, tooltip = "Hits shortly after receiving damage gain tiny bonus damage.\nDetails: Cooldown: 15s, Damage: 5%, Window: 2s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Short Fuse Gem", bonuses = { socket_short_fuse_cooldown = 15, socket_short_fuse_percent = 6, socket_short_fuse_window = 2 }, tooltip = "Hits shortly after receiving damage gain tiny bonus damage.\nDetails: Cooldown: 15s, Damage: 6%, Window: 2s" }
        },
    },
    -- 98 --
    longfusegem = {
        itemId = 30761,
        name = "Long Fuse Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring" },
        bestFor = { "Any Vocation" },
        style = "Delayed Combat",
        bonuses = { socket_long_fuse_cooldown = 12, socket_long_fuse_percent = 1, socket_long_fuse_wait_seconds = 4 },
        tooltip = "Waiting after damage makes your next hit stronger.\nDetails: Cooldown: 12s, Damage: 1%, Wait Seconds: 4s",
        tiers = {
            [1] = { name = "Small Long Fuse Gem", bonuses = { socket_long_fuse_cooldown = 12, socket_long_fuse_percent = 1, socket_long_fuse_wait_seconds = 4 }, tooltip = "Waiting after damage makes your next hit stronger.\nDetails: Cooldown: 12s, Damage: 1%, Wait Seconds: 4s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Long Fuse Gem", bonuses = { socket_long_fuse_cooldown = 12, socket_long_fuse_percent = 3, socket_long_fuse_wait_seconds = 4 }, tooltip = "Waiting after damage makes your next hit stronger.\nDetails: Cooldown: 12s, Damage: 3%, Wait Seconds: 4s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Long Fuse Gem", bonuses = { socket_long_fuse_cooldown = 12, socket_long_fuse_percent = 5, socket_long_fuse_wait_seconds = 4 }, tooltip = "Waiting after damage makes your next hit stronger.\nDetails: Cooldown: 12s, Damage: 5%, Wait Seconds: 4s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Long Fuse Gem", bonuses = { socket_long_fuse_cooldown = 12, socket_long_fuse_percent = 7, socket_long_fuse_wait_seconds = 3 }, tooltip = "Waiting after damage makes your next hit stronger.\nDetails: Cooldown: 12s, Damage: 7%, Wait Seconds: 3s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Long Fuse Gem", bonuses = { socket_long_fuse_cooldown = 12, socket_long_fuse_percent = 9, socket_long_fuse_wait_seconds = 3 }, tooltip = "Waiting after damage makes your next hit stronger.\nDetails: Cooldown: 12s, Damage: 9%, Wait Seconds: 3s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Long Fuse Gem", bonuses = { socket_long_fuse_cooldown = 12, socket_long_fuse_percent = 12, socket_long_fuse_wait_seconds = 2 }, tooltip = "Waiting after damage makes your next hit stronger.\nDetails: Cooldown: 12s, Damage: 12%, Wait Seconds: 2s" }
        },
    },
    -- 99 --
    quietarmorgem = {
        itemId = 30762,
        name = "Quiet Armor Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "legs", "shield" },
        bestFor = { "Any Vocation" },
        style = "Defensive Silence",
        bonuses = { socket_quiet_armor_cooldown = 10, socket_quiet_armor_idle_seconds = 6, socket_quiet_armor_reduce_percent = 1 },
        tooltip = "If you have not cast for 6s, your next received hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 6s, Reduction: 1%",
        tiers = {
            [1] = { name = "Small Quiet Armor Gem", bonuses = { socket_quiet_armor_cooldown = 10, socket_quiet_armor_idle_seconds = 6, socket_quiet_armor_reduce_percent = 1 }, tooltip = "If you have not cast for 6s, your next received hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 6s, Reduction: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Quiet Armor Gem", bonuses = { socket_quiet_armor_cooldown = 10, socket_quiet_armor_idle_seconds = 5, socket_quiet_armor_reduce_percent = 2 }, tooltip = "If you have not cast for 5s, your next received hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 5s, Reduction: 2%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Quiet Armor Gem", bonuses = { socket_quiet_armor_cooldown = 10, socket_quiet_armor_idle_seconds = 5, socket_quiet_armor_reduce_percent = 3 }, tooltip = "If you have not cast for 5s, your next received hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 5s, Reduction: 3%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Quiet Armor Gem", bonuses = { socket_quiet_armor_cooldown = 10, socket_quiet_armor_idle_seconds = 4, socket_quiet_armor_reduce_percent = 4 }, tooltip = "If you have not cast for 4s, your next received hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 4s, Reduction: 4%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Quiet Armor Gem", bonuses = { socket_quiet_armor_cooldown = 10, socket_quiet_armor_idle_seconds = 4, socket_quiet_armor_reduce_percent = 5 }, tooltip = "If you have not cast for 4s, your next received hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 4s, Reduction: 5%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Quiet Armor Gem", bonuses = { socket_quiet_armor_cooldown = 10, socket_quiet_armor_idle_seconds = 3, socket_quiet_armor_reduce_percent = 6 }, tooltip = "If you have not cast for 3s, your next received hit is reduced.\nDetails: Cooldown: 10s, Idle Time: 3s, Reduction: 6%" }
        },
    },
    -- 100 --
    loudarmorgem = {
        itemId = 30763,
        name = "Loud Armor Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "legs", "shield" },
        bestFor = { "Any Vocation" },
        style = "Casting Guard",
        bonuses = { socket_loud_armor_cooldown = 12, socket_loud_armor_reduce_percent = 1, socket_loud_armor_window = 4 },
        tooltip = "After casting a spell, your next received hit is reduced.\nDetails: Cooldown: 12s, Reduction: 1%, Window: 4s",
        tiers = {
            [1] = { name = "Small Loud Armor Gem", bonuses = { socket_loud_armor_cooldown = 12, socket_loud_armor_reduce_percent = 1, socket_loud_armor_window = 4 }, tooltip = "After casting a spell, your next received hit is reduced.\nDetails: Cooldown: 12s, Reduction: 1%, Window: 4s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Loud Armor Gem", bonuses = { socket_loud_armor_cooldown = 12, socket_loud_armor_reduce_percent = 2, socket_loud_armor_window = 4 }, tooltip = "After casting a spell, your next received hit is reduced.\nDetails: Cooldown: 12s, Reduction: 2%, Window: 4s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Loud Armor Gem", bonuses = { socket_loud_armor_cooldown = 12, socket_loud_armor_reduce_percent = 3, socket_loud_armor_window = 4 }, tooltip = "After casting a spell, your next received hit is reduced.\nDetails: Cooldown: 12s, Reduction: 3%, Window: 4s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Loud Armor Gem", bonuses = { socket_loud_armor_cooldown = 12, socket_loud_armor_reduce_percent = 4, socket_loud_armor_window = 4 }, tooltip = "After casting a spell, your next received hit is reduced.\nDetails: Cooldown: 12s, Reduction: 4%, Window: 4s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Loud Armor Gem", bonuses = { socket_loud_armor_cooldown = 12, socket_loud_armor_reduce_percent = 5, socket_loud_armor_window = 4 }, tooltip = "After casting a spell, your next received hit is reduced.\nDetails: Cooldown: 12s, Reduction: 5%, Window: 4s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Loud Armor Gem", bonuses = { socket_loud_armor_cooldown = 12, socket_loud_armor_reduce_percent = 6, socket_loud_armor_window = 4 }, tooltip = "After casting a spell, your next received hit is reduced.\nDetails: Cooldown: 12s, Reduction: 6%, Window: 4s" }
        },
    },
    -- 101 --
    luckybootsgem = {
        itemId = 30764,
        name = "Lucky Boots Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "boots" },
        bestFor = { "Any Vocation" },
        style = "Movement Luck",
        bonuses = { socket_lucky_boots_chance = 1, socket_lucky_boots_cooldown = 10, socket_lucky_boots_reduce_percent = 10, socket_lucky_boots_tiles = 10 },
        tooltip = "After moving 10 tiles, your next received hit can be reduced.\nDetails: Chance: 1%, Cooldown: 10s, Reduction: 10%",
        tiers = {
            [1] = { name = "Small Lucky Boots Gem", bonuses = { socket_lucky_boots_chance = 2, socket_lucky_boots_cooldown = 10, socket_lucky_boots_reduce_percent = 10, socket_lucky_boots_tiles = 10 }, tooltip = "After moving 10 tiles, your next received hit can be reduced.\nDetails: Chance: 2%, Cooldown: 10s, Reduction: 10%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Lucky Boots Gem", bonuses = { socket_lucky_boots_chance = 3, socket_lucky_boots_cooldown = 10, socket_lucky_boots_reduce_percent = 10, socket_lucky_boots_tiles = 9 }, tooltip = "After moving 9 tiles, your next received hit can be reduced.\nDetails: Chance: 3%, Cooldown: 10s, Reduction: 10%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Lucky Boots Gem", bonuses = { socket_lucky_boots_chance = 4, socket_lucky_boots_cooldown = 10, socket_lucky_boots_reduce_percent = 10, socket_lucky_boots_tiles = 8 }, tooltip = "After moving 8 tiles, your next received hit can be reduced.\nDetails: Chance: 4%, Cooldown: 10s, Reduction: 10%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Lucky Boots Gem", bonuses = { socket_lucky_boots_chance = 5, socket_lucky_boots_cooldown = 10, socket_lucky_boots_reduce_percent = 10, socket_lucky_boots_tiles = 7 }, tooltip = "After moving 7 tiles, your next received hit can be reduced.\nDetails: Chance: 5%, Cooldown: 10s, Reduction: 10%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Lucky Boots Gem", bonuses = { socket_lucky_boots_chance = 7, socket_lucky_boots_cooldown = 10, socket_lucky_boots_reduce_percent = 10, socket_lucky_boots_tiles = 6 }, tooltip = "After moving 6 tiles, your next received hit can be reduced.\nDetails: Chance: 7%, Cooldown: 10s, Reduction: 10%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Lucky Boots Gem", bonuses = { socket_lucky_boots_chance = 10, socket_lucky_boots_cooldown = 10, socket_lucky_boots_reduce_percent = 10, socket_lucky_boots_tiles = 5 }, tooltip = "After moving 5 tiles, your next received hit can be reduced.\nDetails: Chance: 10%, Cooldown: 10s, Reduction: 10%" }
        },
    },
    -- 102 --
    fightersmarkgem = {
        itemId = 30765,
        name = "Fighter's Mark Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "gloves", "ring" },
        bestFor = { "Any Vocation" },
        style = "Duel Momentum",
        bonuses = { socket_fighters_mark_cooldown = 8, socket_fighters_mark_hits = 3, socket_fighters_mark_percent = 1 },
        tooltip = "The 3rd hit on the same target gains tiny bonus damage.\nDetails: Fighters Mark Cooldown: 8s, Fighters Mark Hits: 3, Fighters Mark Percent: 1%",
        tiers = {
            [1] = { name = "Small Fighter's Mark Gem", bonuses = { socket_fighters_mark_cooldown = 8, socket_fighters_mark_hits = 3, socket_fighters_mark_percent = 1 }, tooltip = "The 3rd hit on the same target gains tiny bonus damage.\nDetails: Fighters Mark Cooldown: 8s, Fighters Mark Hits: 3, Fighters Mark Percent: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Fighter's Mark Gem", bonuses = { socket_fighters_mark_cooldown = 8, socket_fighters_mark_hits = 3, socket_fighters_mark_percent = 2 }, tooltip = "The 3rd hit on the same target gains tiny bonus damage.\nDetails: Fighters Mark Cooldown: 8s, Fighters Mark Hits: 3, Fighters Mark Percent: 2%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Fighter's Mark Gem", bonuses = { socket_fighters_mark_cooldown = 8, socket_fighters_mark_hits = 3, socket_fighters_mark_percent = 3 }, tooltip = "The 3rd hit on the same target gains tiny bonus damage.\nDetails: Fighters Mark Cooldown: 8s, Fighters Mark Hits: 3, Fighters Mark Percent: 3%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Fighter's Mark Gem", bonuses = { socket_fighters_mark_cooldown = 8, socket_fighters_mark_hits = 3, socket_fighters_mark_percent = 4 }, tooltip = "The 3rd hit on the same target gains tiny bonus damage.\nDetails: Fighters Mark Cooldown: 8s, Fighters Mark Hits: 3, Fighters Mark Percent: 4%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Fighter's Mark Gem", bonuses = { socket_fighters_mark_cooldown = 8, socket_fighters_mark_hits = 3, socket_fighters_mark_percent = 5 }, tooltip = "The 3rd hit on the same target gains tiny bonus damage.\nDetails: Fighters Mark Cooldown: 8s, Fighters Mark Hits: 3, Fighters Mark Percent: 5%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Fighter's Mark Gem", bonuses = { socket_fighters_mark_cooldown = 8, socket_fighters_mark_hits = 3, socket_fighters_mark_percent = 6 }, tooltip = "The 3rd hit on the same target gains tiny bonus damage.\nDetails: Fighters Mark Cooldown: 8s, Fighters Mark Hits: 3, Fighters Mark Percent: 6%" }
        },
    },
    -- 103 --
    stubborngem = {
        itemId = 30766,
        name = "Stubborn Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "shield", "necklace" },
        bestFor = { "Any Vocation" },
        style = "Refuse Death",
        bonuses = { socket_stubborn_heal_percent = 1, socket_stubborn_threshold = 20 },
        tooltip = "Below 20% HP, received healing is slightly increased.\nDetails: Healing: 1%, Threshold: 20%",
        tiers = {
            [1] = { name = "Small Stubborn Gem", bonuses = { socket_stubborn_heal_percent = 1, socket_stubborn_threshold = 20 }, tooltip = "Below 20% HP, received healing is slightly increased.\nDetails: Healing: 1%, Threshold: 20%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Stubborn Gem", bonuses = { socket_stubborn_heal_percent = 2, socket_stubborn_threshold = 20 }, tooltip = "Below 20% HP, received healing is slightly increased.\nDetails: Healing: 2%, Threshold: 20%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Stubborn Gem", bonuses = { socket_stubborn_heal_percent = 3, socket_stubborn_threshold = 20 }, tooltip = "Below 20% HP, received healing is slightly increased.\nDetails: Healing: 3%, Threshold: 20%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Stubborn Gem", bonuses = { socket_stubborn_heal_percent = 4, socket_stubborn_threshold = 20 }, tooltip = "Below 20% HP, received healing is slightly increased.\nDetails: Healing: 4%, Threshold: 20%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Stubborn Gem", bonuses = { socket_stubborn_heal_percent = 5, socket_stubborn_threshold = 20 }, tooltip = "Below 20% HP, received healing is slightly increased.\nDetails: Healing: 5%, Threshold: 20%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Stubborn Gem", bonuses = { socket_stubborn_heal_percent = 6, socket_stubborn_threshold = 20 }, tooltip = "Below 20% HP, received healing is slightly increased.\nDetails: Healing: 6%, Threshold: 20%" }
        },
    },
    -- 104 --
    freshstartgem = {
        itemId = 30767,
        name = "Fresh Start Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "ring", "necklace", "armor" },
        bestFor = { "Any Vocation" },
        style = "Relog Recovery",
        bonuses = { socket_fresh_start_potion_percent = 1 },
        tooltip = "After login or respawn, your first potion is slightly stronger.\nDetails: Potion Percent: 3%",
        tiers = {
            [1] = { name = "Small Fresh Start Gem", bonuses = { socket_fresh_start_potion_percent = 3 }, tooltip = "After login or respawn, your first potion is slightly stronger.\nDetails: Potion Percent: 3%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Fresh Start Gem", bonuses = { socket_fresh_start_potion_percent = 5 }, tooltip = "After login or respawn, your first potion is slightly stronger.\nDetails: Potion Percent: 5%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Fresh Start Gem", bonuses = { socket_fresh_start_potion_percent = 7 }, tooltip = "After login or respawn, your first potion is slightly stronger.\nDetails: Potion Percent: 7%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Fresh Start Gem", bonuses = { socket_fresh_start_potion_percent = 9 }, tooltip = "After login or respawn, your first potion is slightly stronger.\nDetails: Potion Percent: 9%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Fresh Start Gem", bonuses = { socket_fresh_start_potion_percent = 12 }, tooltip = "After login or respawn, your first potion is slightly stronger.\nDetails: Potion Percent: 12%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Fresh Start Gem", bonuses = { socket_fresh_start_potion_percent = 15 }, tooltip = "After login or respawn, your first potion is slightly stronger.\nDetails: Potion Percent: 15%" }
        },
    },
    -- 105 --
    overhealgem = {
        itemId = 30768,
        name = "Overheal Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "ring", "necklace", "belt" },
        bestFor = { "Mages", "Druids", "Sustain Builds" },
        style = "Overheal Mana",
        bonuses = { socket_overheal_mana_percent = 1, socket_overheal_cooldown = 15 },
        tooltip = "Self-healing above max HP restores mana from part of the overheal.\nDetails: Mana: 1%, Cooldown: 15s",
        tiers = {
            [1] = { name = "Small Overheal Gem", bonuses = { socket_overheal_mana_percent = 1, socket_overheal_cooldown = 8 }, tooltip = "Self-healing above max HP restores mana from part of the overheal.\nDetails: Mana: 1%, Cooldown: 15s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Overheal Gem", bonuses = { socket_overheal_mana_percent = 1, socket_overheal_cooldown = 8 }, tooltip = "Self-healing above max HP restores mana from part of the overheal.\nDetails: Mana: 1%, Cooldown: 15s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Overheal Gem", bonuses = { socket_overheal_mana_percent = 2, socket_overheal_cooldown = 8 }, tooltip = "Self-healing above max HP restores mana from part of the overheal.\nDetails: Mana: 2%, Cooldown: 15s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Overheal Gem", bonuses = { socket_overheal_mana_percent = 2, socket_overheal_cooldown = 7 }, tooltip = "Self-healing above max HP restores mana from part of the overheal.\nDetails: Mana: 2%, Cooldown: 15s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Overheal Gem", bonuses = { socket_overheal_mana_percent = 3, socket_overheal_cooldown = 7 }, tooltip = "Self-healing above max HP restores mana from part of the overheal.\nDetails: Mana: 3%, Cooldown: 15s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Overheal Gem", bonuses = { socket_overheal_mana_percent = 4, socket_overheal_cooldown = 6 }, tooltip = "Self-healing above max HP restores mana from part of the overheal.\nDetails: Mana: 4%, Cooldown: 15s" }
        },
    },
    -- 106 --
    barriersipgem = {
        itemId = 30769,
        name = "Barrier Sip Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "legs", "shield", "ring", "necklace", "belt" },
        bestFor = { "Knights", "Solo Players", "Bosses" },
        style = "Potion Barrier",
        bonuses = { socket_barrier_sip_reduction_percent = 3, socket_barrier_sip_duration = 3, socket_barrier_sip_cooldown = 12 },
        tooltip = "Using a health potion grants brief damage reduction.\nDetails: Reduction Percent: 3%, Duration: 3s, Cooldown: 12s",
        tiers = {
            [1] = { name = "Small Barrier Sip Gem", bonuses = { socket_barrier_sip_reduction_percent = 3, socket_barrier_sip_duration = 3, socket_barrier_sip_cooldown = 12 }, tooltip = "Using a health potion grants brief damage reduction.\nDetails: Reduction Percent: 3%, Duration: 3s, Cooldown: 12s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Barrier Sip Gem", bonuses = { socket_barrier_sip_reduction_percent = 4, socket_barrier_sip_duration = 3, socket_barrier_sip_cooldown = 12 }, tooltip = "Using a health potion grants brief damage reduction.\nDetails: Reduction Percent: 4%, Duration: 3s, Cooldown: 12s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Barrier Sip Gem", bonuses = { socket_barrier_sip_reduction_percent = 5, socket_barrier_sip_duration = 3, socket_barrier_sip_cooldown = 11 }, tooltip = "Using a health potion grants brief damage reduction.\nDetails: Reduction Percent: 5%, Duration: 3s, Cooldown: 11s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Barrier Sip Gem", bonuses = { socket_barrier_sip_reduction_percent = 6, socket_barrier_sip_duration = 4, socket_barrier_sip_cooldown = 10 }, tooltip = "Using a health potion grants brief damage reduction.\nDetails: Reduction Percent: 6%, Duration: 4s, Cooldown: 10s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Barrier Sip Gem", bonuses = { socket_barrier_sip_reduction_percent = 8, socket_barrier_sip_duration = 4, socket_barrier_sip_cooldown = 10 }, tooltip = "Using a health potion grants brief damage reduction.\nDetails: Reduction Percent: 8%, Duration: 4s, Cooldown: 10s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Barrier Sip Gem", bonuses = { socket_barrier_sip_reduction_percent = 10, socket_barrier_sip_duration = 5, socket_barrier_sip_cooldown = 9 }, tooltip = "Using a health potion grants brief damage reduction.\nDetails: Reduction Percent: 10%, Duration: 5s, Cooldown: 9s" }
        },
    },
    -- 107 --
    firstbloodgem = {
        itemId = 30770,
        name = "First Blood Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "gloves" },
        bestFor = { "Hunts", "Burst Openers" },
        style = "Opening Hit",
        bonuses = { socket_first_blood_damage_percent = 4, socket_first_blood_cooldown = 8 },
        tooltip = "Your first hit against a full-HP monster deals bonus damage.\nDetails: Damage: 4%, Cooldown: 8s",
        tiers = {
            [1] = { name = "Small First Blood Gem", bonuses = { socket_first_blood_damage_percent = 4, socket_first_blood_cooldown = 8 }, tooltip = "Your first hit against a full-HP monster deals bonus damage.\nDetails: Damage: 4%, Cooldown: 8s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser First Blood Gem", bonuses = { socket_first_blood_damage_percent = 5, socket_first_blood_cooldown = 8 }, tooltip = "Your first hit against a full-HP monster deals bonus damage.\nDetails: Damage: 5%, Cooldown: 8s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater First Blood Gem", bonuses = { socket_first_blood_damage_percent = 6, socket_first_blood_cooldown = 7 }, tooltip = "Your first hit against a full-HP monster deals bonus damage.\nDetails: Damage: 6%, Cooldown: 7s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super First Blood Gem", bonuses = { socket_first_blood_damage_percent = 8, socket_first_blood_cooldown = 6 }, tooltip = "Your first hit against a full-HP monster deals bonus damage.\nDetails: Damage: 8%, Cooldown: 6s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega First Blood Gem", bonuses = { socket_first_blood_damage_percent = 10, socket_first_blood_cooldown = 6 }, tooltip = "Your first hit against a full-HP monster deals bonus damage.\nDetails: Damage: 10%, Cooldown: 6s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal First Blood Gem", bonuses = { socket_first_blood_damage_percent = 12, socket_first_blood_cooldown = 5 }, tooltip = "Your first hit against a full-HP monster deals bonus damage.\nDetails: Damage: 12%, Cooldown: 5s" }
        },
    },
    -- 108 --
    manabatterygem = {
        itemId = 30771,
        name = "Mana Battery Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "wand", "ring", "necklace", "belt" },
        bestFor = { "Mages", "Paladins" },
        style = "Mana Spend Refund",
        bonuses = { socket_mana_battery_spend_percent = 20, socket_mana_battery_restore_percent = 1, socket_mana_battery_chance = 30, socket_mana_battery_cooldown = 12 },
        tooltip = "After spending enough mana on attack spells, restore a small percent of max mana.\nDetails: Spend Percent: 20%, Restore Percent: 1%, Chance: 30%, Cooldown: 12s",
        tiers = {
            [1] = { name = "Small Mana Battery Gem", bonuses = { socket_mana_battery_spend_percent = 20, socket_mana_battery_restore_percent = 1, socket_mana_battery_chance = 30, socket_mana_battery_cooldown = 12 }, tooltip = "After spending enough mana on attack spells, restore a small percent of max mana.\nDetails: Spend Percent: 20%, Restore Percent: 1%, Chance: 30%, Cooldown: 12s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Mana Battery Gem", bonuses = { socket_mana_battery_spend_percent = 18, socket_mana_battery_restore_percent = 1.5, socket_mana_battery_chance = 40, socket_mana_battery_cooldown = 12 }, tooltip = "After spending enough mana on attack spells, restore a small percent of max mana.\nDetails: Spend Percent: 18%, Restore Percent: 1.5%, Chance: 40%, Cooldown: 12s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Mana Battery Gem", bonuses = { socket_mana_battery_spend_percent = 16, socket_mana_battery_restore_percent = 2, socket_mana_battery_chance = 50, socket_mana_battery_cooldown = 12 }, tooltip = "After spending enough mana on attack spells, restore a small percent of max mana.\nDetails: Spend Percent: 16%, Restore Percent: 2%, Chance: 50%, Cooldown: 12s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Mana Battery Gem", bonuses = { socket_mana_battery_spend_percent = 14, socket_mana_battery_restore_percent = 2.5, socket_mana_battery_chance = 60, socket_mana_battery_cooldown = 12 }, tooltip = "After spending enough mana on attack spells, restore a small percent of max mana.\nDetails: Spend Percent: 14%, Restore Percent: 2.5%, Chance: 60%, Cooldown: 12s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Mana Battery Gem", bonuses = { socket_mana_battery_spend_percent = 12, socket_mana_battery_restore_percent = 3, socket_mana_battery_chance = 80, socket_mana_battery_cooldown = 12 }, tooltip = "After spending enough mana on attack spells, restore a small percent of max mana.\nDetails: Spend Percent: 12%, Restore Percent: 3%, Chance: 80%, Cooldown: 12s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Mana Battery Gem", bonuses = { socket_mana_battery_spend_percent = 10, socket_mana_battery_restore_percent = 3.5, socket_mana_battery_chance = 100, socket_mana_battery_cooldown = 12 }, tooltip = "After spending enough mana on attack spells, restore a small percent of max mana.\nDetails: Spend Percent: 10%, Restore Percent: 3.5%, Chance: 100%, Cooldown: 12s" }
        },
    },
    -- 109 --
    cleansesipgem = {
        itemId = 30772,
        name = "Cleanse Sip Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "ring", "necklace" },
        bestFor = { "Any Vocation" },
        style = "Potion Cleanse",
        bonuses = { socket_cleanse_sip_chance = 5, socket_cleanse_sip_cooldown = 12 },
        tooltip = "Using a potion can remove one negative condition.\nDetails: Chance: 5%, Cooldown: 12s",
        tiers = {
            [1] = { name = "Small Cleanse Sip Gem", bonuses = { socket_cleanse_sip_chance = 5, socket_cleanse_sip_cooldown = 12 }, tooltip = "Using a potion can remove one negative condition.\nDetails: Chance: 5%, Cooldown: 12s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Cleanse Sip Gem", bonuses = { socket_cleanse_sip_chance = 6, socket_cleanse_sip_cooldown = 12 }, tooltip = "Using a potion can remove one negative condition.\nDetails: Chance: 6%, Cooldown: 12s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Cleanse Sip Gem", bonuses = { socket_cleanse_sip_chance = 7, socket_cleanse_sip_cooldown = 11 }, tooltip = "Using a potion can remove one negative condition.\nDetails: Chance: 7%, Cooldown: 11s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Cleanse Sip Gem", bonuses = { socket_cleanse_sip_chance = 9, socket_cleanse_sip_cooldown = 10 }, tooltip = "Using a potion can remove one negative condition.\nDetails: Chance: 9%, Cooldown: 10s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Cleanse Sip Gem", bonuses = { socket_cleanse_sip_chance = 12, socket_cleanse_sip_cooldown = 9 }, tooltip = "Using a potion can remove one negative condition.\nDetails: Chance: 12%, Cooldown: 9s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Cleanse Sip Gem", bonuses = { socket_cleanse_sip_chance = 15, socket_cleanse_sip_cooldown = 8 }, tooltip = "Using a potion can remove one negative condition.\nDetails: Chance: 15%, Cooldown: 8s" }
        },
    },
    -- 110 --
    stabilitygem = {
        itemId = 30773,
        name = "Stability Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "armor", "legs", "shield", "ring", "necklace" },
        bestFor = { "Any Vocation" },
        style = "Consistent Combat",
        bonuses = { socket_stability_damage_percent = 1, socket_stability_reduction_percent = 1 },
        tooltip = "Slightly increases damage dealt and slightly reduces damage taken.\nDetails: Damage: 1%, Reduction Percent: 1%",
        tiers = {
            [1] = { name = "Small Stability Gem", bonuses = { socket_stability_damage_percent = 1, socket_stability_reduction_percent = 1 }, tooltip = "Slightly increases damage dealt and slightly reduces damage taken.\nDetails: Damage: 1%, Reduction Percent: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Stability Gem", bonuses = { socket_stability_damage_percent = 1, socket_stability_reduction_percent = 2 }, tooltip = "Slightly increases damage dealt and slightly reduces damage taken.\nDetails: Damage: 1%, Reduction Percent: 2%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Stability Gem", bonuses = { socket_stability_damage_percent = 2, socket_stability_reduction_percent = 2 }, tooltip = "Slightly increases damage dealt and slightly reduces damage taken.\nDetails: Damage: 2%, Reduction Percent: 2%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Stability Gem", bonuses = { socket_stability_damage_percent = 2, socket_stability_reduction_percent = 3 }, tooltip = "Slightly increases damage dealt and slightly reduces damage taken.\nDetails: Damage: 2%, Reduction Percent: 3%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Stability Gem", bonuses = { socket_stability_damage_percent = 3, socket_stability_reduction_percent = 3 }, tooltip = "Slightly increases damage dealt and slightly reduces damage taken.\nDetails: Damage: 3%, Reduction Percent: 3%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Stability Gem", bonuses = { socket_stability_damage_percent = 3, socket_stability_reduction_percent = 4 }, tooltip = "Slightly increases damage dealt and slightly reduces damage taken.\nDetails: Damage: 3%, Reduction Percent: 4%" }
        },
    },
    -- 111 --
    runesavergem = {
        itemId = 30774,
        name = "Rune Saver Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "wand", "ring", "necklace", "belt" },
        bestFor = { "Rune Users", "Mages" },
        style = "Rune Mana Refund",
        bonuses = { socket_rune_saver_chance = 5, socket_rune_saver_mana_percent = 0.5, socket_rune_saver_cooldown = 10 },
        tooltip = "Using an attack rune has a chance to restore a small amount of mana.\nDetails: Chance: 5%, Mana: 0.5%, Cooldown: 10s",
        tiers = {
            [1] = { name = "Small Rune Saver Gem", bonuses = { socket_rune_saver_chance = 5, socket_rune_saver_mana_percent = 0.5, socket_rune_saver_cooldown = 10 }, tooltip = "Using an attack rune has a chance to restore a small amount of mana.\nDetails: Chance: 5%, Mana: 0.5%, Cooldown: 10s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Rune Saver Gem", bonuses = { socket_rune_saver_chance = 7, socket_rune_saver_mana_percent = 1, socket_rune_saver_cooldown = 10 }, tooltip = "Using an attack rune has a chance to restore a small amount of mana.\nDetails: Chance: 7%, Mana: 1%, Cooldown: 10s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Rune Saver Gem", bonuses = { socket_rune_saver_chance = 9, socket_rune_saver_mana_percent = 1.5, socket_rune_saver_cooldown = 10 }, tooltip = "Using an attack rune has a chance to restore a small amount of mana.\nDetails: Chance: 9%, Mana: 1.5%, Cooldown: 10s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Rune Saver Gem", bonuses = { socket_rune_saver_chance = 10, socket_rune_saver_mana_percent = 2, socket_rune_saver_cooldown = 10 }, tooltip = "Using an attack rune has a chance to restore a small amount of mana.\nDetails: Chance: 10%, Mana: 2%, Cooldown: 10s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Rune Saver Gem", bonuses = { socket_rune_saver_chance = 12, socket_rune_saver_mana_percent = 2.5, socket_rune_saver_cooldown = 10 }, tooltip = "Using an attack rune has a chance to restore a small amount of mana.\nDetails: Chance: 12%, Mana: 2.5%, Cooldown: 10s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Rune Saver Gem", bonuses = { socket_rune_saver_chance = 15, socket_rune_saver_mana_percent = 3, socket_rune_saver_cooldown = 10 }, tooltip = "Using an attack rune has a chance to restore a small amount of mana.\nDetails: Chance: 15%, Mana: 3%, Cooldown: 10s" }
        },
    },
    -- 112 --
    serratededgegem = {
        itemId = 30775,
        name = "Serrated Edge Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "gloves", "belt", "ring" },
        bestFor = { "Knights", "Paladins" },
        effect = 407,
        style = "Light Bleed",
        bonuses = { socket_serrated_edge_chance = 4, socket_serrated_edge_damage_percent = 5, socket_serrated_edge_delay_ms = 500 },
        tooltip = "Basic attacks can add one short physical bleed tick.\nDetails: Chance: 4%, Damage: 5%, Delay: 0.5s",
        tiers = {
            [1] = { name = "Small Serrated Edge Gem", bonuses = { socket_serrated_edge_chance = 5, socket_serrated_edge_damage_percent = 5, socket_serrated_edge_delay_ms = 500 }, tooltip = "Basic attacks can add one short physical bleed tick.\nDetails: Chance: 5%, Damage: 5%, Delay: 0.5s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Serrated Edge Gem", bonuses = { socket_serrated_edge_chance = 6, socket_serrated_edge_damage_percent = 6, socket_serrated_edge_delay_ms = 500 }, tooltip = "Basic attacks can add one short physical bleed tick.\nDetails: Chance: 6%, Damage: 6%, Delay: 0.5s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Serrated Edge Gem", bonuses = { socket_serrated_edge_chance = 7, socket_serrated_edge_damage_percent = 7, socket_serrated_edge_delay_ms = 450 }, tooltip = "Basic attacks can add one short physical bleed tick.\nDetails: Chance: 7%, Damage: 7%, Delay: 0.45s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Serrated Edge Gem", bonuses = { socket_serrated_edge_chance = 8, socket_serrated_edge_damage_percent = 8, socket_serrated_edge_delay_ms = 400 }, tooltip = "Basic attacks can add one short physical bleed tick.\nDetails: Chance: 9%, Damage: 8%, Delay: 0.4s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Serrated Edge Gem", bonuses = { socket_serrated_edge_chance = 12, socket_serrated_edge_damage_percent = 9, socket_serrated_edge_delay_ms = 400 }, tooltip = "Basic attacks can add one short physical bleed tick.\nDetails: Chance: 12%, Damage: 9%, Delay: 0.4s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Serrated Edge Gem", bonuses = { socket_serrated_edge_chance = 15, socket_serrated_edge_damage_percent = 10, socket_serrated_edge_delay_ms = 300 }, tooltip = "Basic attacks can add one short physical bleed tick.\nDetails: Chance: 15%, Damage: 10%, Delay: 0.3s" }
        },
    },
    -- 113 --
    huntercompassgem = {
        itemId = 30776,
        name = "Hunter Compass Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "boots", "ring", "necklace", "belt" },
        bestFor = { "Long Hunts", "Farmers" },
        style = "Hunt Momentum",
        bonuses = { socket_hunter_compass_kills = 8, socket_hunter_compass_speed = 10, socket_hunter_compass_duration = 4, socket_hunter_compass_cooldown = 15 },
        tooltip = "Repeated kills of the same monster grant temporary speed.\nDetails: Kills: 8, Speed: 10, Duration: 4s, Cooldown: 15s",
        tiers = {
            [1] = { name = "Small Hunter Compass Gem", bonuses = { socket_hunter_compass_kills = 8, socket_hunter_compass_speed = 10, socket_hunter_compass_duration = 4, socket_hunter_compass_cooldown = 15 }, tooltip = "Repeated kills of the same monster grant temporary speed.\nDetails: Kills: 8, Speed: 10, Duration: 4s, Cooldown: 15s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Hunter Compass Gem", bonuses = { socket_hunter_compass_kills = 7, socket_hunter_compass_speed = 15, socket_hunter_compass_duration = 4, socket_hunter_compass_cooldown = 15 }, tooltip = "Repeated kills of the same monster grant temporary speed.\nDetails: Kills: 7, Speed: 15, Duration: 4s, Cooldown: 15s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Hunter Compass Gem", bonuses = { socket_hunter_compass_kills = 7, socket_hunter_compass_speed = 20, socket_hunter_compass_duration = 5, socket_hunter_compass_cooldown = 14 }, tooltip = "Repeated kills of the same monster grant temporary speed.\nDetails: Kills: 7, Speed: 20, Duration: 5s, Cooldown: 14s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Hunter Compass Gem", bonuses = { socket_hunter_compass_kills = 6, socket_hunter_compass_speed = 25, socket_hunter_compass_duration = 5, socket_hunter_compass_cooldown = 13 }, tooltip = "Repeated kills of the same monster grant temporary speed.\nDetails: Kills: 6, Speed: 25, Duration: 5s, Cooldown: 13s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Hunter Compass Gem", bonuses = { socket_hunter_compass_kills = 5, socket_hunter_compass_speed = 30, socket_hunter_compass_duration = 6, socket_hunter_compass_cooldown = 12 }, tooltip = "Repeated kills of the same monster grant temporary speed.\nDetails: Kills: 5, Speed: 30, Duration: 6s, Cooldown: 12s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Hunter Compass Gem", bonuses = { socket_hunter_compass_kills = 4, socket_hunter_compass_speed = 35, socket_hunter_compass_duration = 7, socket_hunter_compass_cooldown = 10 }, tooltip = "Repeated kills of the same monster grant temporary speed.\nDetails: Kills: 4, Speed: 35, Duration: 7s, Cooldown: 10s" }
        },
    },
    -- 114 --
    recoverywindowgem = {
        itemId = 30777,
        name = "Recovery Window Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "legs", "shield", "ring", "necklace", "belt" },
        bestFor = { "Tanks", "Bosses" },
        style = "Post-Burst Recovery",
        bonuses = { socket_recovery_window_big_hit_percent = 18, socket_recovery_window_heal_percent = 4, socket_recovery_window_duration = 4, socket_recovery_window_cooldown = 20 },
        tooltip = "After taking a big hit, healing received is briefly increased.\nDetails: Big Hit Percent: 18%, Healing: 4s, Duration: 4s, Cooldown: 20s",
        tiers = {
            [1] = { name = "Small Recovery Window Gem", bonuses = { socket_recovery_window_big_hit_percent = 18, socket_recovery_window_heal_percent = 4, socket_recovery_window_duration = 4, socket_recovery_window_cooldown = 20 }, tooltip = "After taking a big hit, healing received is briefly increased.\nDetails: Big Hit Percent: 18%, Healing: 4s, Duration: 4s, Cooldown: 20s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Recovery Window Gem", bonuses = { socket_recovery_window_big_hit_percent = 16, socket_recovery_window_heal_percent = 5, socket_recovery_window_duration = 4, socket_recovery_window_cooldown = 20 }, tooltip = "After taking a big hit, healing received is briefly increased.\nDetails: Big Hit Percent: 16%, Healing: 5s, Duration: 4s, Cooldown: 20s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Recovery Window Gem", bonuses = { socket_recovery_window_big_hit_percent = 15, socket_recovery_window_heal_percent = 6, socket_recovery_window_duration = 4, socket_recovery_window_cooldown = 18 }, tooltip = "After taking a big hit, healing received is briefly increased.\nDetails: Big Hit Percent: 15%, Healing: 6s, Duration: 4s, Cooldown: 18s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Recovery Window Gem", bonuses = { socket_recovery_window_big_hit_percent = 13, socket_recovery_window_heal_percent = 8, socket_recovery_window_duration = 5, socket_recovery_window_cooldown = 18 }, tooltip = "After taking a big hit, healing received is briefly increased.\nDetails: Big Hit Percent: 13%, Healing: 8s, Duration: 5s, Cooldown: 18s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Recovery Window Gem", bonuses = { socket_recovery_window_big_hit_percent = 12, socket_recovery_window_heal_percent = 10, socket_recovery_window_duration = 5, socket_recovery_window_cooldown = 16 }, tooltip = "After taking a big hit, healing received is briefly increased.\nDetails: Big Hit Percent: 12%, Healing: 10s, Duration: 5s, Cooldown: 16s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Recovery Window Gem", bonuses = { socket_recovery_window_big_hit_percent = 10, socket_recovery_window_heal_percent = 12, socket_recovery_window_duration = 6, socket_recovery_window_cooldown = 15 }, tooltip = "After taking a big hit, healing received is briefly increased.\nDetails: Big Hit Percent: 10%, Healing: 12s, Duration: 6s, Cooldown: 15s" }
        },
    },
    -- Rare --
    -- 115 --
    chroniclegem = {
        itemId = 30778,
        name = "Chronicle Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "weapon", "wand", "ring", "necklace", "armor", "legs", "belt" },
        bestFor = { "Any Vocation" },
        style = "Legacy",
        chronicle = {
            monsterKillsPerStack = 100000,
            bossKillsPerStack = 100,
            damagePerStack = 1,
            healthPerStack = 200,
            manaPerStack = 125,
            maxMonsterStacks = 1,
            maxBossStacks = 1,
        },
        bonuses = {
            socket_chronicle_damage_percent = 0,
            socket_chronicle_health = 0,
            socket_chronicle_mana = 0,
        },
        tooltip = "Every 100000 monster kills grants +1% damage. Every 100 boss kills grants +200 HP and +125 Mana. Tier cap: 1 / 1.",
        tiers = {
            [1] = {
                name = "Small Chronicle Gem",
                bonuses = {},
                chronicle = { maxMonsterStacks = 1, maxBossStacks = 1 },
                tooltip = "Every 100000 monster kills grants +1% damage. Every 100 boss kills grants +200 HP and +125 Mana. Tier cap: 1 / 1.",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Chronicle Gem",
                bonuses = {},
                chronicle = { maxMonsterStacks = 2, maxBossStacks = 2 },
                tooltip = "Every 100000 monster kills grants +1% damage. Every 100 boss kills grants +200 HP and +125 Mana. Tier cap: 2 / 2.",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Chronicle Gem",
                bonuses = {},
                chronicle = { maxMonsterStacks = 3, maxBossStacks = 3 },
                tooltip = "Every 100000 monster kills grants +1% damage. Every 100 boss kills grants +200 HP and +125 Mana. Tier cap: 3 / 3.",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Chronicle Gem",
                bonuses = {},
                chronicle = { maxMonsterStacks = 5, maxBossStacks = 5 },
                tooltip = "Every 100000 monster kills grants +1% damage. Every 100 boss kills grants +200 HP and +125 Mana. Tier cap: 5 / 5.",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Chronicle Gem",
                bonuses = {},
                chronicle = { maxMonsterStacks = 7, maxBossStacks = 7 },
                tooltip = "Every 100000 monster kills grants +1% damage. Every 100 boss kills grants +200 HP and +125 Mana. Tier cap: 7 / 7.",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Chronicle Gem",
                bonuses = {},
                chronicle = { maxMonsterStacks = 10, maxBossStacks = 10 },
                tooltip = "Every 100000 monster kills grants +1% damage. Every 100 boss kills grants +200 HP and +125 Mana. Tier cap: 10 / 10."
            }
        }
    },
    -- 116 --
    predatoreye = {
        itemId = 30779,
        name = "Predator Eye",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "weapon", "wand", "ring", "necklace", "belt", "armor" },
        bestFor = { "Any Vocation" },
        style = "Monster Mastery",
        predator = {
            killsRequired = 500,
            damagePercent = 12,
            executeThreshold = 5,
        },
        bonuses = {},
        tooltip = "Learns one monster after 500 kills while socketed on equipped gear. Deals bonus damage and executes that learned monster below 5% HP. Learning 500 kills of a new monster replaces the prey.",
        excludeFromInventoryPanels = true,
        tiers = {
            [1] = {
                name = "Small Predator Eye",
                predator = {
                    killsRequired = 500,
                    damagePercent = 5,
                    executeThreshold = 5,
                },
                bonuses = {},
                tooltip = "Learns one monster after 500 kills while socketed on equipped gear. Deals bonus damage and executes that learned monster below 5% HP. Learning 500 kills of a new monster replaces the prey.",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Predator Eye",
                predator = {
                    killsRequired = 450,
                    damagePercent = 7,
                    executeThreshold = 7,
                },
                bonuses = {},
                tooltip = "Learns one monster after 450 kills while socketed on equipped gear. Deals bonus damage and executes that learned monster below 7% HP. Learning 450 kills of a new monster replaces the prey.",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Lesser Predator Eye",
                predator = {
                    killsRequired = 400,
                    damagePercent = 8,
                    executeThreshold = 8,
                },
                bonuses = {},
                tooltip = "Learns one monster after 400 kills while socketed on equipped gear. Deals bonus damage and executes that learned monster below 5% HP. Learning 400 kills of a new monster replaces the prey.",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [4] = {
                name = "Lesser Predator Eye",
                predator = {
                    killsRequired = 350,
                    damagePercent = 9,
                    executeThreshold = 9,
                },
                bonuses = {},
                tooltip = "Learns one monster after 350 kills while socketed on equipped gear. Deals bonus damage and executes that learned monster below 5% HP. Learning 350 kills of a new monster replaces the prey.",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [5] = {
                name = "Lesser Predator Eye",
                predator = {
                    killsRequired = 300,
                    damagePercent = 10,
                    executeThreshold = 10,
                },
                bonuses = {},
                tooltip = "Learns one monster after 300 kills while socketed on equipped gear. Deals bonus damage and executes that learned monster below 5% HP. Learning 300 kills of a new monster replaces the prey.",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [6] = {
                name = "Lesser Predator Eye",
                predator = {
                    killsRequired = 250,
                    damagePercent = 12,
                    executeThreshold = 12,
                },
                bonuses = {},
                tooltip = "Learns one monster after 250 kills while socketed on equipped gear. Deals bonus damage and executes that learned monster below 5% HP. Learning 250 kills of a new monster replaces the prey.",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            }
        }
    },
    -- 117 --
    phoenixgem = {
        itemId = 30780,
        name = "Phoenix Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "ring", "necklace", "belt" },
        bestFor = { "Any Vocation" },
        style = "Rebirth",
        phoenix = {
            killsRequired = 5000,
            maxCharges = 1,
        },
        bonuses = {},
        tooltip = "Stores revive charges while socketed on equipped gear. A lethal hit is reduced to 1 HP, then the wearer becomes briefly invincible before restoring full health and mana.",
        tiers = {
            [1] = {
                name = "Small Phoenix Gem",
                phoenix = {
                    killsRequired = 5000,
                    maxCharges = 1,
                },
                bonuses = {},
                tooltip = "Stores up to 1 revive. Each new charge requires 5000 monster kills while socketed on equipped gear.",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Phoenix Gem",
                phoenix = {
                    killsRequired = 4000,
                    maxCharges = 1,
                },
                bonuses = {},
                tooltip = "Stores up to 1 revive. Each new charge requires 4000 monster kills while socketed on equipped gear.",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Phoenix Gem",
                phoenix = {
                    killsRequired = 3500,
                    maxCharges = 2,
                },
                bonuses = {},
                tooltip = "Stores up to 2 revives. Each new charge requires 3500 monster kills while socketed on equipped gear.",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Phoenix Gem",
                phoenix = {
                    killsRequired = 3000,
                    maxCharges = 2,
                },
                bonuses = {},
                tooltip = "Stores up to 2 revives. Each new charge requires 3000 monster kills while socketed on equipped gear.",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Super Phoenix Gem",
                phoenix = {
                    killsRequired = 2500,
                    maxCharges = 3,
                },
                bonuses = {},
                tooltip = "Stores up to 3 revives. Each new charge requires 2500 monster kills while socketed on equipped gear.",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [6] = {
                name = "Super Phoenix Gem",
                phoenix = {
                    killsRequired = 2000,
                    maxCharges = 4,
                },
                bonuses = {},
                tooltip = "Stores up to 4 revives. Each new charge requires 2000 monster kills while socketed on equipped gear.",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            }
        }
    },
    -- 118 --
    livinggem = {
        itemId = 30781,
        name = "Living Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "weapon" },
        bestFor = { "Knight", "Paladin", "Monk", "Any Vocation" },
        style = "Living Weapon",
        living = {
            stages = {
                [1] = { form = "Dormant", requiredKills = 0, damagePercent = 2 , upgrade = {items = {{ id = 30658, count = 10 }}} },
                [2] = { form = "Bone", requiredKills = 5000, damagePercent = 4 , upgrade = {items = {{ id = 30658, count = 25 }}} },
                [3] = { form = "Flesh", requiredKills = 15000, damagePercent = 6 , upgrade = {items = {{ id = 30658, count = 50 }}} },
                [4] = { form = "Hungry", requiredKills = 25000, damagePercent = 8 , upgrade = {items = {{ id = 30658, count = 100 }}} },
                [5] = { form = "Elder", requiredKills = 50000, damagePercent = 10 , upgrade = {items = {{ id = 30658, count = 150 }}} },
                [6] = { form = "Tyrant", requiredKills = 100000, damagePercent = 12 },
            }
        },
        bonuses = {
            socket_living_damage_percent = 0,
        },
        tooltip = "This weapon-bound gem absorbs kills and evolves through living forms. Its soul, progress, and power remain on the gem itself.",
        tiers = {
            [1] = { name = "Small Living Gem", bonuses = { socket_living_damage_percent = 2 }, tooltip = "This weapon-bound gem absorbs kills and evolves through living forms. Its soul, progress, and power remain on the gem itself.\nDetails: Damage: 2%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Living Gem", bonuses = { socket_living_damage_percent = 4 }, tooltip = "This weapon-bound gem absorbs kills and evolves through living forms. Its soul, progress, and power remain on the gem itself.\nDetails: Damage: 4%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Living Gem", bonuses = { socket_living_damage_percent = 6 }, tooltip = "This weapon-bound gem absorbs kills and evolves through living forms. Its soul, progress, and power remain on the gem itself.\nDetails: Damage: 6%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Living Gem", bonuses = { socket_living_damage_percent = 8 }, tooltip = "This weapon-bound gem absorbs kills and evolves through living forms. Its soul, progress, and power remain on the gem itself.\nDetails: Damage: 8%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Living Gem", bonuses = { socket_living_damage_percent = 10 }, tooltip = "This weapon-bound gem absorbs kills and evolves through living forms. Its soul, progress, and power remain on the gem itself.\nDetails: Damage: 10%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Living Gem", bonuses = { socket_living_damage_percent = 12 }, tooltip = "This weapon-bound gem absorbs kills and evolves through living forms. Its soul, progress, and power remain on the gem itself.\nDetails: Damage: 12%" }
        },
    },
    -- 119 --
    alchemistgem = {
        itemId = 30782,
        name = "Alchemist Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "ring", "necklace", "belt", "gloves" },
        bestFor = { "Any Vocation" },
        style = "Unique Potion Conservation",
        bonuses = {
            socket_alchemist_save_chance = 3,
        },
        tooltip = "Potion use has 3% chance to preserve the potion instead of consuming it.\nDetails: Save Chance: 3%",
        tiers = {
            [1] = { name = "Small Alchemist Gem", bonuses = { socket_alchemist_save_chance = 3 }, tooltip = "Potion use has 3% chance to preserve the potion instead of consuming it.\nDetails: Save Chance: 3%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Alchemist Gem", bonuses = { socket_alchemist_save_chance = 5 }, tooltip = "Potion use has 5% chance to preserve the potion instead of consuming it.\nDetails: Save Chance: 5%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Alchemist Gem", bonuses = { socket_alchemist_save_chance = 7 }, tooltip = "Potion use has 7% chance to preserve the potion instead of consuming it.\nDetails: Save Chance: 7%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Alchemist Gem", bonuses = { socket_alchemist_save_chance = 9 }, tooltip = "Potion use has 9% chance to preserve the potion instead of consuming it.\nDetails: Save Chance: 9%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Alchemist Gem", bonuses = { socket_alchemist_save_chance = 12 }, tooltip = "Potion use has 12% chance to preserve the potion instead of consuming it.\nDetails: Save Chance: 12%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Alchemist Gem", bonuses = { socket_alchemist_save_chance = 15 }, tooltip = "Potion use has 15% chance to preserve the potion instead of consuming it.\nDetails: Save Chance: 15%" }
        },
    },
    -- 120 --
    warcrygem = {
        itemId = 30783,
        name = "Warcry Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "shield", "helmet", "ring", "necklace", "belt" },
        bestFor = { "Knight", "Paladin", "Druid" },
        style = "Party Support",
        bonuses = {
            socket_warcry_chance = 4,
            socket_warcry_cooldown = 90,
            socket_warcry_shield_percent = 3,
            socket_warcry_duration = 5,
            socket_warcry_range = 5,
        },
        tooltip = "Dealing damage has 4% chance every 90s to rally nearby party members, granting a temporary max HP shield equal to 3% of max HP for 8s.",
        tiers = {
            [1] = {
                name = "Small Warcry Gem",
                bonuses = { socket_warcry_chance = 4, socket_warcry_cooldown = 90, socket_warcry_shield_percent = 3, socket_warcry_duration = 5, socket_warcry_range = 5 },
                tooltip = "Dealing damage has 4% chance every 90s to rally nearby party members, granting a temporary max HP shield equal to 3% of max HP for 8s.",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Warcry Gem",
                bonuses = { socket_warcry_chance = 6, socket_warcry_cooldown = 85, socket_warcry_shield_percent = 4, socket_warcry_duration = 6, socket_warcry_range = 6 },
                tooltip = "Dealing damage has 6% chance every 85s to rally nearby party members, granting a temporary max HP shield equal to 4% of max HP for 6s.",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Warcry Gem",
                bonuses = { socket_warcry_chance = 8, socket_warcry_cooldown = 75, socket_warcry_shield_percent = 6, socket_warcry_duration = 7, socket_warcry_range = 6 },
                tooltip = "Dealing damage has 8% chance every 75s to rally nearby party members, granting a temporary max HP shield equal to 6% of max HP for 7s.",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Warcry Gem",
                bonuses = { socket_warcry_chance = 10, socket_warcry_cooldown = 75, socket_warcry_shield_percent = 8, socket_warcry_duration = 8, socket_warcry_range = 7 },
                tooltip = "Dealing damage has 10% chance every 75s to rally nearby party members, granting a temporary max HP shield equal to 8% of max HP for 8s.",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Warcry Gem",
                bonuses = { socket_warcry_chance = 12, socket_warcry_cooldown = 70, socket_warcry_shield_percent = 9, socket_warcry_duration = 9, socket_warcry_range = 8 },
                tooltip = "Dealing damage has 12% chance every 70s to rally nearby party members, granting a temporary max HP shield equal to 9% of max HP for 9s.",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Warcry Gem",
                bonuses = { socket_warcry_chance = 15, socket_warcry_cooldown = 60, socket_warcry_shield_percent = 10, socket_warcry_duration = 10, socket_warcry_range = 8 },
                tooltip = "Dealing damage has 15% chance every 60s to rally nearby party members, granting a temporary max HP shield equal to 10% of max HP for 10s."
            }
        }
    },
    -- 121 --
    martyrgem = {
        itemId = 30784,
        name = "Martyr Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "shield", "helmet", "ring", "necklace", "belt" },
        bestFor = { "Knight", "Paladin", "Druid" },
        style = "Legendary Party Support",
        bonuses = {
            socket_martyr_redirect_percent = 15,
            socket_martyr_shield_percent = 3,
            socket_martyr_shield_duration = 6,
            socket_martyr_range = 5,
            socket_martyr_cooldown = 180,
        },
        tooltip = "When a nearby party member would take lethal damage, redirect 15% of the hit to yourself and grant them a 3% max HP shield for 6s. 180s cooldown.\nDetails: Range: 5 SQM",
        tiers = {
            [1] = {
                name = "Small Martyr Gem",
                bonuses = { socket_martyr_redirect_percent = 15, socket_martyr_shield_percent = 3, socket_martyr_shield_duration = 6, socket_martyr_range = 5, socket_martyr_cooldown = 180 },
                tooltip = "When a nearby party member would take lethal damage, redirect 15% of the hit to yourself and grant them a 3% max HP shield for 6s. 180s cooldown.\nDetails: Range: 5 SQM",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Martyr Gem",
                bonuses = { socket_martyr_redirect_percent = 20, socket_martyr_shield_percent = 4, socket_martyr_shield_duration = 6, socket_martyr_range = 6, socket_martyr_cooldown = 165 },
                tooltip = "When a nearby party member would take lethal damage, redirect 20% of the hit to yourself and grant them a 4% max HP shield for 6s. 165s cooldown.\nDetails: Range: 6 SQM",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Martyr Gem",
                bonuses = { socket_martyr_redirect_percent = 25, socket_martyr_shield_percent = 5, socket_martyr_shield_duration = 7, socket_martyr_range = 7, socket_martyr_cooldown = 150 },
                tooltip = "When a nearby party member would take lethal damage, redirect 35% of the hit to yourself and grant them a 5% max HP shield for 7s. 150s cooldown.\nDetails: Range: 7 SQM",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Martyr Gem",
                bonuses = { socket_martyr_redirect_percent = 30, socket_martyr_shield_percent = 6, socket_martyr_shield_duration = 8, socket_martyr_range = 8, socket_martyr_cooldown = 135 },
                tooltip = "When a nearby party member would take lethal damage, redirect 40% of the hit to yourself and grant them a 6% max HP shield for 8s. 135s cooldown.\nDetails: Shield Duration: 7s, Range: 8 SQM",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Martyr Gem",
                bonuses = { socket_martyr_redirect_percent = 35, socket_martyr_shield_percent = 8, socket_martyr_shield_duration = 9, socket_martyr_range = 9, socket_martyr_cooldown = 120 },
                tooltip = "When a nearby party member would take lethal damage, redirect 45% of the hit to yourself and grant them a % max HP shield for 9s. 120s cooldown.\nDetails: Shield Duration: 7s, Range: 9 SQM",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Martyr Gem",
                bonuses = { socket_martyr_redirect_percent = 50, socket_martyr_shield_percent = 10, socket_martyr_shield_duration = 10, socket_martyr_range = 10, socket_martyr_cooldown = 90 },
                tooltip = "When a nearby party member would take lethal damage, redirect 50% of the hit to yourself and grant them a 10% max HP shield for 10s. 90s cooldown.\nDetails: Range: 10 SQM"
            }
        }
    },
    -- 122 --
    heraldgem = {
        itemId = 30785,
        name = "Herald Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand" },
        bestFor = { "Damage Dealers" },
        style = "Energy Barrage",
        effect = 404,
        bonuses = {
            socket_herald_chance = 1,
            socket_herald_cooldown = 30,
            socket_herald_max_shots = 1,
            socket_herald_range = 3,
            socket_herald_damage_percent = 20,
            socket_herald_explosion_percent = 25,
        },
        tooltip = "Dealing damage has 3% chance every 30s to fire up to 1 energy shot at nearby enemies. Kills from the shot burst into a small energy blast.\nDetails: Cooldown: 30s, Max Shots: 1, Range: 3 SQM, Damage: 20%, Explosion Percent: 25%",
        tiers = {
            [1] = {
                name = "Small Herald Gem",
                bonuses = { socket_herald_chance = 3, socket_herald_cooldown = 30, socket_herald_max_shots = 1, socket_herald_range = 3, socket_herald_damage_percent = 20, socket_herald_explosion_percent = 25 },
                tooltip = "Dealing damage has 3% chance every 30s to fire up to 1 energy shot at nearby enemies. Kills from the shot burst into a small energy blast.\nDetails: Cooldown: 30s, Max Shots: 1, Range: 3 SQM, Damage: 20%, Explosion Percent: 25%",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Herald Gem",
                bonuses = { socket_herald_chance = 5, socket_herald_cooldown = 30, socket_herald_max_shots = 2, socket_herald_range = 3, socket_herald_damage_percent = 25, socket_herald_explosion_percent = 30 },
                tooltip = "Dealing damage has 5% chance every 30s to fire up to 2 energy shot at nearby enemies. Kills from the shot burst into a small energy blast.\nDetails: Cooldown: 30s, Max Shots: 1, Range: 4 SQM, Damage: 25%, Explosion Percent: 30%",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Herald Gem",
                bonuses = { socket_herald_chance = 7, socket_herald_cooldown = 30, socket_herald_max_shots = 2, socket_herald_range = 4, socket_herald_damage_percent = 30, socket_herald_explosion_percent = 35 },
                tooltip = "Dealing damage has 7% chance every 30s to fire up to 2 energy shot at nearby enemies. Kills from the shot burst into a small energy blast.\nDetails: Cooldown: 30s, Max Shots: 2, Range: 4 SQM, Damage: 30%, Explosion Percent: 35%",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Herald Gem",
                bonuses = { socket_herald_chance = 9, socket_herald_cooldown = 30, socket_herald_max_shots = 3, socket_herald_range = 5, socket_herald_damage_percent = 35, socket_herald_explosion_percent = 40 },
                tooltip = "Dealing damage has 9% chance every 30s to fire up to 3 energy shot at nearby enemies. Kills from the shot burst into a small energy blast.\nDetails: Cooldown: 30s, Max Shots: 2, Range: 5 SQM, Damage: 35%, Explosion Percent: 40%",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Herald Gem",
                bonuses = { socket_herald_chance = 12, socket_herald_cooldown = 30, socket_herald_max_shots = 4, socket_herald_range = 6, socket_herald_damage_percent = 40, socket_herald_explosion_percent = 45 },
                tooltip = "Dealing damage has 12% chance every 30s to fire up to 4 energy shot at nearby enemies. Kills from the shot burst into a small energy blast.\nDetails: Cooldown: 30s, Max Shots: 3, Range: 6 SQM, Damage: 40%, Explosion Percent: 45%",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Herald Gem",
                bonuses = { socket_herald_chance = 15, socket_herald_cooldown = 30, socket_herald_max_shots = 5, socket_herald_range = 7, socket_herald_damage_percent = 50, socket_herald_explosion_percent = 60 },
                tooltip = "Dealing damage has 15% chance every 30s to fire up to 5 energy shot at nearby enemies. Kills from the shot burst into a small energy blast.\nDetails: Cooldown: 30s, Max Shots: 3, Range: 7 SQM, Damage: 50%, Explosion Percent: 60%"
            }
        }
    },
    -- 123 --
    obituarygem = {
        itemId = 30786,
        name = "The Obituary Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield", "weapon", "wand" },
        bestFor = { "Boss Learners", "Revenge Builds", "Hardcore Hunters" },
        style = "Death Diary",
        bonuses = {
            socket_obituary_damage_per_death = 2,
            socket_obituary_duration = 7200,
            socket_obituary_max_entries = 1,
        },
        tooltip = "When you die to a monster while wearing this gem, it records the killer for 2h. Each active death entry grants +6% damage against that monster.\nDetails: Duration: 2h, Max Entries: 1",
        [1] = {
                name = "Small Obituary Gem",
                bonuses = { socket_obituary_damage_per_death = 2, socket_obituary_duration = 7200, socket_obituary_max_entries = 1},
                tooltip = "When you die to a monster while wearing this gem, it records the killer for 6h. Each active death entry grants +2% damage against that monster.\nDetails: Duration: 2h, Max Entries: 1",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
        [2] = {
                name = "Lesser Obituary Gem",
                bonuses = { socket_obituary_damage_per_death = 4, socket_obituary_duration = 21600, socket_obituary_max_entries = 1},
                tooltip = "When you die to a monster while wearing this gem, it records the killer for 8h. Each active death entry grants +4% damage against that monster.\nDetails: Duration: 8h, Max Entries: 1",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
        [3] = {
                name = "Greater Obituary Gem",
                bonuses = { socket_obituary_damage_per_death = 6, socket_obituary_duration = 43200, socket_obituary_max_entries = 2},
                tooltip = "When you die to a monster while wearing this gem, it records the killer for 12h. Each active death entry grants +6% damage against that monster.\nDetails: Duration: 12h, Max Entries: 2",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
        [4] = {
                name = "Super Obituary Gem",
                bonuses = { socket_obituary_damage_per_death = 7, socket_obituary_duration = 57600, socket_obituary_max_entries = 2},
                tooltip = "When you die to a monster while wearing this gem, it records the killer for 16h. Each active death entry grants +7% damage against that monster.\nDetails: Duration: 16h, Max Entries: 2",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
        [5] = {
                name = "Mega Obituary Gem",
                bonuses = { socket_obituary_damage_per_death = 8, socket_obituary_duration = 72000, socket_obituary_max_entries = 3},
                tooltip = "When you die to a monster while wearing this gem, it records the killer for 20h. Each active death entry grants +8% damage against that monster.\nDetails: Duration: 20h, Max Entries: 3",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
        [6] = {
                name = "Abyssal Obituary Gem",
                bonuses = { socket_obituary_damage_per_death = 9, socket_obituary_duration = 86400, socket_obituary_max_entries = 3},
                tooltip = "When you die to a monster while wearing this gem, it records the killer for 24h. Each active death entry grants +9% damage against that monster.\nDetails: Duration: 24h, Max Entries: 3",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },

    },
    -- 124 --
    lastbreathgem = {
        itemId = 30787,
        name = "Last Breath Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield", "weapon", "wand" },
        bestFor = { "Risk Builds", "Healers", "Damage Dealers" },
        style = "Critical Health Escalation",
        bonuses = {
            socket_last_breath_threshold = 10,
            socket_last_breath_reset_threshold = 20,
            socket_last_breath_percent_per_second = 1,
            socket_last_breath_max_percent = 10,
            socket_last_breath_heal_percent_per_second = 0.5,
            socket_last_breath_cooldown = 60,
        },
        tooltip = "When damaged below 10% HP, Last Breath activates every 60s. While active below 10% HP, recover 0.5% max HP and gain +1% damage/healing each second, up to +10%. Resets above 20% HP.\nDetails: Trigger Threshold: 10%, Reset Threshold: 20%, Heal Per Second: 0.5%, Damage/Healing Per Second: 1%, Max Bonus: 10%, Cooldown: 60s",
        tiers = {
            [1] = { name = "Small Last Breath Gem", bonuses = { socket_last_breath_threshold = 10, socket_last_breath_reset_threshold = 20, socket_last_breath_percent_per_second = 1, socket_last_breath_max_percent = 10, socket_last_breath_heal_percent_per_second = 0.5, socket_last_breath_cooldown = 60 }, tooltip = "When damaged below 10% HP, Last Breath activates every 60s. While active below 10% HP, recover 0.5% max HP and gain +1% damage/healing each second, up to +10%. Resets above 20% HP.\nDetails: Trigger Threshold: 10%, Reset Threshold: 20%, Heal Per Second: 0.5%, Damage/Healing Per Second: 1%, Max Bonus: 10%, Cooldown: 60s", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Last Breath Gem", bonuses = { socket_last_breath_threshold = 15, socket_last_breath_reset_threshold = 25, socket_last_breath_percent_per_second = 1.5, socket_last_breath_max_percent = 10, socket_last_breath_heal_percent_per_second = 1, socket_last_breath_cooldown = 60 }, tooltip = "When damaged below 15% HP, Last Breath activates every 60s. While active below 15% HP, recover 1% max HP and gain +1.5% damage/healing each second, up to +10%. Resets above 25% HP.\nDetails: Trigger Threshold: 15%, Reset Threshold: 25%, Heal Per Second: 1%, Damage/Healing Per Second: 1.5%, Max Bonus: 10%, Cooldown: 60s", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Last Breath Gem", bonuses = { socket_last_breath_threshold = 20, socket_last_breath_reset_threshold = 30, socket_last_breath_percent_per_second = 2, socket_last_breath_max_percent = 10, socket_last_breath_heal_percent_per_second = 1.5, socket_last_breath_cooldown = 60 }, tooltip = "When damaged below 20% HP, Last Breath activates every 60s. While active below 20% HP, recover 1.5% max HP and gain +2% damage/healing each second, up to +10%. Resets above 30% HP.\nDetails: Trigger Threshold: 20%, Reset Threshold: 30%, Heal Per Second: 1.5%, Damage/Healing Per Second: 2%, Max Bonus: 10%, Cooldown: 60s", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Last Breath Gem", bonuses = { socket_last_breath_threshold = 25, socket_last_breath_reset_threshold = 35, socket_last_breath_percent_per_second = 2.5, socket_last_breath_max_percent = 15, socket_last_breath_heal_percent_per_second = 2, socket_last_breath_cooldown = 60 }, tooltip = "When damaged below 25% HP, Last Breath activates every 60s. While active below 25% HP, recover 2% max HP and gain +2.5% damage/healing each second, up to +15%. Resets above 35% HP.\nDetails: Trigger Threshold: 25%, Reset Threshold: 35%, Heal Per Second: 2%, Damage/Healing Per Second: 2.5%, Max Bonus: 15%, Cooldown: 60s", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Last Breath Gem", bonuses = { socket_last_breath_threshold = 30, socket_last_breath_reset_threshold = 40, socket_last_breath_percent_per_second = 3, socket_last_breath_max_percent = 15, socket_last_breath_heal_percent_per_second = 2.5, socket_last_breath_cooldown = 60 }, tooltip = "When damaged below 30% HP, Last Breath activates every 60s. While active below 30% HP, recover 2.5% max HP and gain +3% damage/healing each second, up to +15%. Resets above 40% HP.\nDetails: Trigger Threshold: 30%, Reset Threshold: 40%, Heal Per Second: 2.5%, Damage/Healing Per Second: 3%, Max Bonus: 15%, Cooldown: 60s", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Last Breath Gem", bonuses = { socket_last_breath_threshold = 35, socket_last_breath_reset_threshold = 45, socket_last_breath_percent_per_second = 4, socket_last_breath_max_percent = 20, socket_last_breath_heal_percent_per_second = 3, socket_last_breath_cooldown = 60 }, tooltip = "When damaged below 35% HP, Last Breath activates every 60s. While active below 35% HP, recover 3% max HP and gain +4% damage/healing each second, up to +20%. Resets above 45% HP.\nDetails: Trigger Threshold: 35%, Reset Threshold: 45%, Heal Per Second: 3%, Damage/Healing Per Second: 4%, Max Bonus: 20%, Cooldown: 60s" }
        },
    },
    -- 125 --
    overkillgem = {
        itemId = 30788,
        name = "Overkill Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand" },
        bestFor = { "Damage Dealers", "Boss Hunters" },
        style = "Excess Damage Reservoir",
        bonuses = {
            socket_overkill_store_percent = 50,
            socket_overkill_release_percent = 100,
            socket_overkill_max_damage = 1000,
        },
        tooltip = "Killing damage stores 50% of the hit's excess damage, up to 1,000. Your next damaging attack releases the stored damage. Released damage cannot be stored again.\nDetails: Release Percent: 100%, Max Damage: 1000",
        tiers = {
            [1] = { name = "Small Overkill Gem", bonuses = { socket_overkill_store_percent = 20, socket_overkill_release_percent = 100, socket_overkill_max_damage = 1000 }, tooltip = "Killing damage stores 50% of the hit's excess damage, up to 1,000. Your next damaging attack releases the stored damage. Released damage cannot be stored again.\nDetails: Release Percent: 100%, Max Damage: 1000", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Overkill Gem", bonuses = { socket_overkill_store_percent = 30, socket_overkill_release_percent = 105, socket_overkill_max_damage = 1500 }, tooltip = "Killing damage stores 30% of the hit's excess damage, up to 1,500. Your next damaging attack releases the stored damage. Released damage cannot be stored again.\nDetails: Release Percent: 105%, Max Damage: 1500", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Overkill Gem", bonuses = { socket_overkill_store_percent = 40, socket_overkill_release_percent = 110, socket_overkill_max_damage = 2000 }, tooltip = "Killing damage stores 40% of the hit's excess damage, up to 2,000. Your next damaging attack releases the stored damage. Released damage cannot be stored again.\nDetails: Release Percent: 110%, Max Damage: 2000", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Overkill Gem", bonuses = { socket_overkill_store_percent = 50, socket_overkill_release_percent = 115, socket_overkill_max_damage = 50015 }, tooltip = "Killing damage stores 50% of the hit's excess damage, up to 2,500. Your next damaging attack releases the stored damage. Released damage cannot be stored again.\nDetails: Release Percent: 115%, Max Damage: 2500", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Overkill Gem", bonuses = { socket_overkill_store_percent = 60, socket_overkill_release_percent = 120, socket_overkill_max_damage = 3000 }, tooltip = "Killing damage stores 60% of the hit's excess damage, up to 3,000. Your next damaging attack releases the stored damage. Released damage cannot be stored again.\nDetails: Release Percent: 120%, Max Damage: 3000", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Overkill Gem", bonuses = { socket_overkill_store_percent = 70, socket_overkill_release_percent = 130, socket_overkill_max_damage = 5000 }, tooltip = "Killing damage stores 70% of the hit's excess damage, up to 5,000. Your next damaging attack releases the stored damage. Released damage cannot be stored again.\nDetails: Release Percent: 130%, Max Damage: 5000" }
        },
    },
    -- 126 --
    requiemgem = {
        itemId = 30789,
        name = "Requiem Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield", "weapon", "wand" },
        bestFor = { "Solo Players", "Boss Hunters", "Survival Builds" },
        style = "Soul-Fueled Salvation",
        bonuses = {
            socket_requiem_souls_required = 300,
            socket_requiem_souls_per_kill = 1,
        },
        tooltip = "Normal monster kills collect souls. At 300 souls, the next lethal hit is prevented and leaves you at 1 HP, consuming every soul.",
        tiers = {
            [1] = { name = "Small Requiem Gem", bonuses = { socket_requiem_souls_required = 300, socket_requiem_souls_per_kill = 1 }, tooltip = "Normal monster kills collect souls. At 300 souls, the next lethal hit is prevented and leaves you at 1 HP, consuming every soul.", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Requiem Gem", bonuses = { socket_requiem_souls_required = 250, socket_requiem_souls_per_kill = 1 }, tooltip = "Normal monster kills collect souls. At 250 souls, the next lethal hit is prevented and leaves you at 1 HP, consuming every soul.", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Requiem Gem", bonuses = { socket_requiem_souls_required = 200, socket_requiem_souls_per_kill = 1 }, tooltip = "Normal monster kills collect souls. At 200 souls, the next lethal hit is prevented and leaves you at 1 HP, consuming every soul.", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Requiem Gem", bonuses = { socket_requiem_souls_required = 150, socket_requiem_souls_per_kill = 1 }, tooltip = "Normal monster kills collect souls. At 150 souls, the next lethal hit is prevented and leaves you at 1 HP, consuming every soul.", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Requiem Gem", bonuses = { socket_requiem_souls_required = 125, socket_requiem_souls_per_kill = 1 }, tooltip = "Normal monster kills collect souls. At 125 souls, the next lethal hit is prevented and leaves you at 1 HP, consuming every soul.", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Requiem Gem", bonuses = { socket_requiem_souls_required = 100, socket_requiem_souls_per_kill = 1 }, storage = 980139, storageValue = 1, tooltip = "Normal monster kills collect souls. At 100 souls, the next lethal hit is prevented and leaves you at 1 HP, consuming every soul." }
        },
    },
    -- 127 --
    momentumgem = {
        itemId = 30790,
        name = "Momentum Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "boots", "legs" },
        bestFor = { "Fast Fighters", "Spellcasters" },
        style = "Movement-Fueled Spell",
        bonuses = {
            socket_momentum_per_tile = 1,
            socket_momentum_max = 200,
            socket_momentum_stop_seconds = 5,
            socket_momentum_tiles_per_percent = 50,
            socket_momentum_max_damage_percent = 4,
        },
        tooltip = "Continuous walking stores Momentum, up to 200. After standing still for 5s, the next offensive spell consumes it for +1% damage per 50 Momentum, up to +4%. Teleports grant nothing and reset unarmed Momentum.\nDetails: Max: 200, Stop Seconds: 5s, Max Damage Percent: 4%",
        tiers = {
            [1] = { name = "Small Momentum Gem", bonuses = { socket_momentum_per_tile = 1, socket_momentum_max = 200, socket_momentum_stop_seconds = 5, socket_momentum_tiles_per_percent = 50, socket_momentum_max_damage_percent = 4 }, tooltip = "Continuous walking stores Momentum, up to 200. After standing still for 5s, the next offensive spell consumes it for +1% damage per 50 Momentum, up to +20%. Teleports grant nothing and reset unarmed Momentum.\nDetails: Max: 200, Stop Seconds: 5s, Max Damage Percent: 4%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Momentum Gem", bonuses = { socket_momentum_per_tile = 1, socket_momentum_max = 200, socket_momentum_stop_seconds = 5, socket_momentum_tiles_per_percent = 40, socket_momentum_max_damage_percent = 5 }, tooltip = "Continuous walking stores Momentum, up to 200. After standing still for 5s, the next offensive spell consumes it for +1% damage per 40 Momentum, up to +25%. Teleports grant nothing and reset unarmed Momentum.\nDetails: Max: 200, Stop Seconds: 5s, Max Damage Percent: 5%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Momentum Gem", bonuses = { socket_momentum_per_tile = 1, socket_momentum_max = 300, socket_momentum_stop_seconds = 4, socket_momentum_tiles_per_percent = 30, socket_momentum_max_damage_percent = 10 }, tooltip = "Continuous walking stores Momentum, up to 300. After standing still for 4s, the next offensive spell consumes it for +1% damage per 30 Momentum, up to +30%. Teleports grant nothing and reset unarmed Momentum.\nDetails: Max: 300, Stop Seconds: 4s, Max Damage Percent: 10%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Momentum Gem", bonuses = { socket_momentum_per_tile = 1, socket_momentum_max = 300, socket_momentum_stop_seconds = 4, socket_momentum_tiles_per_percent = 25, socket_momentum_max_damage_percent = 12 }, tooltip = "Continuous walking stores Momentum, up to 300. After standing still for 4s, the next offensive spell consumes it for +1% damage per 25 Momentum, up to +35%. Teleports grant nothing and reset unarmed Momentum.\nDetails: Max: 300, Stop Seconds: 4s, Max Damage Percent: 12%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Momentum Gem", bonuses = { socket_momentum_per_tile = 1, socket_momentum_max = 400, socket_momentum_stop_seconds = 3, socket_momentum_tiles_per_percent = 20, socket_momentum_max_damage_percent = 20 }, tooltip = "Continuous walking stores Momentum, up to 400. After standing still for 3s, the next offensive spell consumes it for +1% damage per 20 Momentum, up to +40%. Teleports grant nothing and reset unarmed Momentum.\nDetails: Max: 400, Stop Seconds: 3s, Max Damage Percent: 20%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Momentum Gem", bonuses = { socket_momentum_per_tile = 1, socket_momentum_max = 500, socket_momentum_stop_seconds = 3, socket_momentum_tiles_per_percent = 15, socket_momentum_max_damage_percent = 30 }, tooltip = "Continuous walking stores Momentum, up to 500. After standing still for 3s, the next offensive spell consumes it for +1% damage per 15 Momentum, up to +50%. Teleports grant nothing and reset unarmed Momentum.\nDetails: Max: 500, Stop Seconds: 3s, Max Damage Percent: 30%" }
        },
    },
    -- 128 --
    gamblersoulgem = {
        itemId = 30791,
        name = "Gambler's Soul",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "ring", "necklace", "belt", "gloves" },
        bestFor = { "Boss Hunters", "Risk Takers" },
        style = "Boss Loot Gamble",
        gambler = {
            fortuneWeight = 10,
            nothingWeight = 60,
            misfortuneWeight = 30,
            fortuneExtraRollPercent = 35,
            misfortuneLootPercent = 35,
        },
        bonuses = {
            socket_gambler_soul_enabled = 1,
        },
        tooltip = "Each reward-boss corpse rolls once: Fortune adds an independent 35% roll of every standard loot entry, Nothing keeps normal loot, and Misfortune reduces standard loot chances to 35%.",
        tiers = {
            [1] = { name = "Small Gambler's Soul", gambler = { fortuneWeight = 10, nothingWeight = 60, misfortuneWeight = 30, fortuneExtraRollPercent = 35, misfortuneLootPercent = 35 }, bonuses = { socket_gambler_soul_enabled = 1 }, storage = 980136, storageValue = 1, tooltip = "Each reward-boss corpse rolls once: Fortune adds an independent 35% roll of every standard loot entry, Nothing keeps normal loot, and Misfortune reduces standard loot chances to 35%.\nDetails: 10 Fortune, 60 normal, 30 misfortune.", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Gambler's Soul", gambler = { fortuneWeight = 15, nothingWeight = 60, misfortuneWeight = 25, fortuneExtraRollPercent = 40, misfortuneLootPercent = 40 }, bonuses = { socket_gambler_soul_enabled = 1 }, tooltip = "Each reward-boss corpse rolls once: Fortune adds an independent 40% roll of every standard loot entry, Nothing keeps normal loot, and Misfortune reduces standard loot chances to 40%.\nDetails: 15 Fortune, 60 normal, 25 misfortune", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Gambler's Soul", gambler = { fortuneWeight = 20, nothingWeight = 60, misfortuneWeight = 20, fortuneExtraRollPercent = 45, misfortuneLootPercent = 45 }, storage = 980137, storageValue = 1, bonuses = { socket_gambler_soul_enabled = 1 }, tooltip = "Each reward-boss corpse rolls once: Fortune adds an independent 45% roll of every standard loot entry, Nothing keeps normal loot, and Misfortune reduces standard loot chances to 45%.\nDetails: 20 Fortune, 60 normal, 20 misfortune", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Gambler's Soul", gambler = { fortuneWeight = 25, nothingWeight = 50, misfortuneWeight = 25, fortuneExtraRollPercent = 50, misfortuneLootPercent = 50 }, bonuses = { socket_gambler_soul_enabled = 1 }, tooltip = "Each reward-boss corpse rolls once: Fortune adds an independent 50% roll of every standard loot entry, Nothing keeps normal loot, and Misfortune reduces standard loot chances to 50%.\nDetails: 25 Fortune, 50 normal, 25 misfortune", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Gambler's Soul", gambler = { fortuneWeight = 30, nothingWeight = 40, misfortuneWeight = 30, fortuneExtraRollPercent = 55, misfortuneLootPercent = 55 }, bonuses = { socket_gambler_soul_enabled = 1 }, tooltip = "Each reward-boss corpse rolls once: Fortune adds an independent 55% roll of every standard loot entry, Nothing keeps normal loot, and Misfortune reduces standard loot chances to 55%.\nDetails: 30 Fortune, 40 normal, 30 misfortune", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Gambler's Soul", gambler = { fortuneWeight = 35, nothingWeight = 30, misfortuneWeight = 35, fortuneExtraRollPercent = 60, misfortuneLootPercent = 60 }, storage = 980138, storageValue = 1, bonuses = { socket_gambler_soul_enabled = 1 }, tooltip = "Each reward-boss corpse rolls once: Fortune adds an independent 60% roll of every standard loot entry, Nothing keeps normal loot, and Misfortune reduces standard loot chances to 60%.\nDetails: 35 Fortune, 30 normal, 35 misfortune" }
        },
    },
    -- 129 --
    infectiongem = {
        itemId = 30792,
        name = "Infection Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace" },
        bestFor = { "High-Risk Hunters", "Area Fighters" },
        style = "Chaining Monster Evolution",
        infection = {
            healthBonusPerLevel = 0.0074,
            effect = 403,
        },
        bonuses = {
            socket_infection_chance = 3,
            socket_infection_range = 3,
            socket_infection_targets = 2,
            socket_infection_levels = 50,
            socket_infection_max_level = 50,
        },
        tooltip = "Normal monster kills have 3% chance to infect up to 2 eligible monsters within 4 SQM. Infection adds 50 monster levels, chaining up to level 1000 and increasing HP, damage, and loot. It never increases experience.\nDetails: Range: 3 SQM, Targets: 2, Max Level: 50",
        tiers = {
            [1] = { name = "Small Infection Gem", bonuses = { socket_infection_chance = 3, socket_infection_range = 3, socket_infection_targets = 2, socket_infection_levels = 50, socket_infection_max_level = 50 }, tooltip = "Normal monster kills have 3% chance to infect up to 2 eligible monsters within 3 SQM. Infection adds 50 monster levels, chaining up to level 1000 and increasing HP, damage, and loot. It never increases experience.\nDetails: Range: 3 SQM, Targets: 2, Max Level: 50", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Infection Gem", bonuses = { socket_infection_chance = 5, socket_infection_range = 4, socket_infection_targets = 2, socket_infection_levels = 50, socket_infection_max_level = 150 }, tooltip = "Normal monster kills have 5% chance to infect up to 2 eligible monsters within 4 SQM. Infection adds 50 monster levels, chaining up to level 150 and increasing HP, damage, and loot. It never increases experience.\nDetails: Range: 4 SQM, Targets: 3, Max Level: 150", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Infection Gem", bonuses = { socket_infection_chance = 8, socket_infection_range = 4, socket_infection_targets = 3, socket_infection_levels = 50, socket_infection_max_level = 300 }, tooltip = "Normal monster kills have 8% chance to infect up to 3 eligible monsters within 4 SQM. Infection adds 50 monster levels, chaining up to level 300 and increasing HP, damage, and loot. It never increases experience.\nDetails: Range: 4 SQM, Targets: 3, Max Level: 300", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Infection Gem", bonuses = { socket_infection_chance = 12, socket_infection_range = 4, socket_infection_targets = 3, socket_infection_levels = 100, socket_infection_max_level = 500 }, tooltip = "Normal monster kills have 12% chance to infect up to 3 eligible monsters within 4 SQM. Infection adds 100 monster levels, chaining up to level 500 and increasing HP, damage, and loot. It never increases experience.\nDetails: Range: 4 SQM, Targets: 3, Max Level: 500", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Infection Gem", bonuses = { socket_infection_chance = 15, socket_infection_range = 5, socket_infection_targets = 3, socket_infection_levels = 100, socket_infection_max_level = 800 }, tooltip = "Normal monster kills have 15% chance to infect up to 3 eligible monsters within 5 SQM. Infection adds 100 monster levels, chaining up to level 800 and increasing HP, damage, and loot. It never increases experience.\nDetails: Range: 5 SQM, Targets: 3, Max Level: 800", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Infection Gem", bonuses = { socket_infection_chance = 20, socket_infection_range = 6, socket_infection_targets = 4, socket_infection_levels = 200, socket_infection_max_level = 1000 }, tooltip = "Normal monster kills have 20% chance to infect up to 4 eligible monsters within 6 SQM. Infection adds 200 monster levels, chaining up to level 1000 and increasing HP, damage, and loot. It never increases experience.\nDetails: Range: 6 SQM, Targets: 4, Max Level: 1000" }
        },
    },
    -- 130 --
    damagegem = {
        itemId = 30793,
        name = "Damage Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield", "weapon", "wand" },
        bestFor = { "Collectors", "Damage Dealers" },
        style = "Lifetime Damage Record",
        bonuses = {
            socket_damage_tracker_enabled = 1,
        },
        tooltip = "Purely cosmetic. Permanently records the total effective damage dealt to monsters while this gem is socketed on equipped gear.",
    },
    -- 131 --
    bloodpricegem = {
        itemId = 30794,
        name = "Blood Price Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand" },
        bestFor = { "Spellcasters", "Risk Builds", "Damage Dealers" },
        style = "Life-Fueled Sorcery",
        bonuses = {
            socket_blood_price_health_per_mana = 1,
            socket_blood_price_damage_percent = 15,
        },
        tooltip = "When an offensive spell lacks mana, each missing mana costs 1 HP and that cast deals 15% more damage. It never activates unless the full cost leaves you at 1 HP or higher. Only mana actually spent grants magic training.\nDetails: Health Per Mana: 1",
        tiers = {
            [1] = { name = "Small Blood Price Gem", bonuses = { socket_blood_price_health_per_mana = 1, socket_blood_price_damage_percent = 15 }, tooltip = "When an offensive spell lacks mana, each missing mana costs 1 HP and that cast deals 15% more damage. It never activates unless the full cost leaves you at 1 HP or higher. Only mana actually spent grants magic training.\nDetails: Health Per Mana: 1", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Blood Price Gem", bonuses = { socket_blood_price_health_per_mana = 2, socket_blood_price_damage_percent = 20 }, tooltip = "When an offensive spell lacks mana, each missing mana costs 2 HP and that cast deals 20% more damage. It never activates unless the full cost leaves you at 1 HP or higher. Only mana actually spent grants magic training.\nDetails: Health Per Mana: 2", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Blood Price Gem", bonuses = { socket_blood_price_health_per_mana = 3, socket_blood_price_damage_percent = 25 }, tooltip = "When an offensive spell lacks mana, each missing mana costs 3 HP and that cast deals 25% more damage. It never activates unless the full cost leaves you at 1 HP or higher. Only mana actually spent grants magic training.\nDetails: Health Per Mana: 3", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Blood Price Gem", bonuses = { socket_blood_price_health_per_mana = 4, socket_blood_price_damage_percent = 30 }, tooltip = "When an offensive spell lacks mana, each missing mana costs 4 HP and that cast deals 30% more damage. It never activates unless the full cost leaves you at 1 HP or higher. Only mana actually spent grants magic training.\nDetails: Health Per Mana: 4", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Blood Price Gem", bonuses = { socket_blood_price_health_per_mana = 5, socket_blood_price_damage_percent = 35 }, tooltip = "When an offensive spell lacks mana, each missing mana costs 5 HP and that cast deals 35% more damage. It never activates unless the full cost leaves you at 1 HP or higher. Only mana actually spent grants magic training.\nDetails: Health Per Mana: 5", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Blood Price Gem", bonuses = { socket_blood_price_health_per_mana = 6, socket_blood_price_damage_percent = 45 }, tooltip = "When an offensive spell lacks mana, each missing mana costs 6 HP and that cast deals 45% more damage. It never activates unless the full cost leaves you at 1 HP or higher. Only mana actually spent grants magic training.\nDetails: Health Per Mana: 6" }
        },
    },
    -- 132 --
    pacifistgem = {
        itemId = 30795,
        name = "Pacifist Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield", "weapon", "wand" },
        bestFor = { "Healers", "Support Builds", "Peaceful Adventurers" },
        style = "Patient Restoration",
        bonuses = {
            socket_pacifist_interval = 2,
            socket_pacifist_percent_per_interval = 1,
            socket_pacifist_max_percent = 12,
        },
        tooltip = "Gain +1% healing power every 2s without dealing damage, up to +12%. This does not heal you by itself; it increases your healing effects. Dealing actual damage resets all accumulated power.\nDetails: Interval: 2s, Percent Per Interval: 1s, Max Percent: 12%",
        tiers = {
            [1] = { name = "Small Pacifist Gem", bonuses = { socket_pacifist_interval = 2, socket_pacifist_percent_per_interval = 1, socket_pacifist_max_percent = 12 }, tooltip = "Gain +1% healing power every 2s without dealing damage, up to +12%. This does not heal you by itself; it increases your healing effects. Dealing actual damage resets all accumulated power.\nDetails: Interval: 2s, Percent Per Interval: 1s, Max Percent: 12%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Pacifist Gem", bonuses = { socket_pacifist_interval = 2, socket_pacifist_percent_per_interval = 1, socket_pacifist_max_percent = 15 }, tooltip = "Gain +1% healing power every 2s without dealing damage, up to +15%. This does not heal you by itself; it increases your healing effects. Dealing actual damage resets all accumulated power.\nDetails: Interval: 2s, Percent Per Interval: 1s, Max Percent: 15%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Pacifist Gem", bonuses = { socket_pacifist_interval = 2, socket_pacifist_percent_per_interval = 1, socket_pacifist_max_percent = 18 }, tooltip = "Gain +1% healing power every 2s without dealing damage, up to +18%. This does not heal you by itself; it increases your healing effects. Dealing actual damage resets all accumulated power.\nDetails: Interval: 2s, Percent Per Interval: 1s, Max Percent: 18%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Pacifist Gem", bonuses = { socket_pacifist_interval = 2, socket_pacifist_percent_per_interval = 1, socket_pacifist_max_percent = 22 }, tooltip = "Gain +1% healing power every 2s without dealing damage, up to +22%. This does not heal you by itself; it increases your healing effects. Dealing actual damage resets all accumulated power.\nDetails: Interval: 2s, Percent Per Interval: 1s, Max Percent: 22%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Pacifist Gem", bonuses = { socket_pacifist_interval = 2, socket_pacifist_percent_per_interval = 1, socket_pacifist_max_percent = 25 }, tooltip = "Gain +1% healing power every 2s without dealing damage, up to +25%. This does not heal you by itself; it increases your healing effects. Dealing actual damage resets all accumulated power.\nDetails: Interval: 2s, Percent Per Interval: 1s, Max Percent: 25%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Pacifist Gem", bonuses = { socket_pacifist_interval = 2, socket_pacifist_percent_per_interval = 1, socket_pacifist_max_percent = 30 }, tooltip = "Gain +1% healing power every 2s without dealing damage, up to +30%. This does not heal you by itself; it increases your healing effects. Dealing actual damage resets all accumulated power.\nDetails: Interval: 2s, Percent Per Interval: 1s, Max Percent: 30%" }
        },
    },
    -- 133 --
    carriongem = {
        itemId = 30796,
        name = "Carrion Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace" },
        bestFor = { "Fast Hunters", "Spellcasters", "Chain Kill Builds" },
        style = "Kill-Chain Frenzy",
        bonuses = {
            socket_carrion_chain_required = 4,
            socket_carrion_chain_window = 4,
            socket_carrion_frenzy_duration = 2,
            socket_carrion_spell_cooldown_ms = 800,
        },
        tooltip = "Killing 4 normal monsters within 4s triggers Frenzy for 2s. During Frenzy, offensive spells receive 0.8s spell and group cooldown. The chain resets after 4s without a kill.",
        tiers = {
            [1] = {
                name = "Small Carrion Gem",
                bonuses = { socket_carrion_chain_required = 4, socket_carrion_chain_window = 4, socket_carrion_frenzy_duration = 2, socket_carrion_spell_cooldown_ms = 800 },
                tooltip = "Killing 4 normal monsters within 4s triggers Frenzy for 2s. During Frenzy, offensive spells receive 0.8s spell and group cooldown. The chain resets after 4s without a kill.",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Carrion Gem",
                bonuses = { socket_carrion_chain_required = 4, socket_carrion_chain_window = 4, socket_carrion_frenzy_duration = 3, socket_carrion_spell_cooldown_ms = 600 },
                tooltip = "Killing 4 normal monsters within 4s triggers Frenzy for 3s. During Frenzy, offensive spells receive 0.6s spell and group cooldown. The chain resets after 4s without a kill.",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Carrion Gem",
                bonuses = { socket_carrion_chain_required = 3, socket_carrion_chain_window = 5, socket_carrion_frenzy_duration = 4, socket_carrion_spell_cooldown_ms = 400 },
                tooltip = "Killing 3 normal monsters within 5s triggers Frenzy for 4s. During Frenzy, offensive spells receive 0.4s spell and group cooldown. The chain resets after 4s without a kill.",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Carrion Gem",
                bonuses = { socket_carrion_chain_required = 3, socket_carrion_chain_window = 5, socket_carrion_frenzy_duration = 5, socket_carrion_spell_cooldown_ms = 200 },
                tooltip = "Killing 3 normal monsters within 4s triggers Frenzy for 5s. During Frenzy, offensive spells receive 0.2s spell and group cooldown. The chain resets after 4s without a kill.",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Carrion Gem",
                bonuses = { socket_carrion_chain_required = 2, socket_carrion_chain_window = 5, socket_carrion_frenzy_duration = 6, socket_carrion_spell_cooldown_ms = 0 },
                tooltip = "Killing 2 normal monsters within 5s triggers Frenzy for 6s. During Frenzy, offensive spells receive 0.1s spell and group cooldown. The chain resets after 4s without a kill.",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Carrion Gem",
                bonuses = { socket_carrion_chain_required = 2, socket_carrion_chain_window = 5, socket_carrion_frenzy_duration = 7, socket_carrion_spell_cooldown_ms = 0 },
                tooltip = "Killing 2 normal monsters within 5s triggers Frenzy for 7s. During Frenzy, offensive spells receive 0s spell and group cooldown. The chain resets after 4s without a kill."
            }
        },
    },
    -- 134 --
    executionersmercygem = {
        itemId = 30797,
        name = "Executioner's Mercy Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace" },
        bestFor = { "Fast Hunters", "Finishers", "Damage Dealers" },
        style = "Kill-Triggered Execute",
        bonuses = {
            socket_executioner_damage_percent = 10,
            socket_executioner_threshold = 30,
            socket_executioner_window = 5,
            socket_executioner_cooldown = 30,
        },
        tooltip = "Killing a monster arms your next hit for 5s. If it hits a monster below 30% HP, it deals bonus damage. 30s cooldown.\nDetails: Damage: 10%, Threshold: 30%, Window: 5s",
        tiers = {
            [1] = { name = "Small Executioner's Mercy Gem", bonuses = { socket_executioner_damage_percent = 10, socket_executioner_threshold = 30, socket_executioner_window = 5, socket_executioner_cooldown = 30 }, tooltip = "Killing a monster arms your next hit for 5s. If it hits a monster below 30% HP, it deals bonus damage. 30s cooldown.\nDetails: Damage: 10%, Threshold: 30%, Window: 5s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Executioner's Mercy Gem", bonuses = { socket_executioner_damage_percent = 12, socket_executioner_threshold = 30, socket_executioner_window = 5, socket_executioner_cooldown = 30 }, tooltip = "Killing a monster arms your next hit for 5s. If it hits a monster below 30% HP, it deals bonus damage. 30s cooldown.\nDetails: Damage: 12%, Threshold: 30%, Window: 5s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Executioner's Mercy Gem", bonuses = { socket_executioner_damage_percent = 14, socket_executioner_threshold = 30, socket_executioner_window = 5, socket_executioner_cooldown = 30 }, tooltip = "Killing a monster arms your next hit for 5s. If it hits a monster below 30% HP, it deals bonus damage. 30s cooldown.\nDetails: Damage: 14%, Threshold: 30%, Window: 5s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Executioner's Mercy Gem", bonuses = { socket_executioner_damage_percent = 16, socket_executioner_threshold = 30, socket_executioner_window = 5, socket_executioner_cooldown = 30 }, tooltip = "Killing a monster arms your next hit for 5s. If it hits a monster below 30% HP, it deals bonus damage. 30s cooldown.\nDetails: Damage: 16%, Threshold: 30%, Window: 5s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Executioner's Mercy Gem", bonuses = { socket_executioner_damage_percent = 18, socket_executioner_threshold = 30, socket_executioner_window = 5, socket_executioner_cooldown = 30 }, tooltip = "Killing a monster arms your next hit for 5s. If it hits a monster below 30% HP, it deals bonus damage. 30s cooldown.\nDetails: Damage: 18%, Threshold: 30%, Window: 5s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Executioner's Mercy Gem", bonuses = { socket_executioner_damage_percent = 20, socket_executioner_threshold = 30, socket_executioner_window = 5, socket_executioner_cooldown = 30 }, tooltip = "Killing a monster arms your next hit for 5s. If it hits a monster below 30% HP, it deals bonus damage. 30s cooldown.\nDetails: Damage: 20%, Threshold: 30%, Window: 5s" }
        },
    },
    -- 135 --
    echostrikegem = {
        itemId = 30798,
        name = "Echo Strike Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand" },
        bestFor = { "Knights", "Paladins", "Boss Hunters" },
        style = "Delayed Repeat Hit",
        bonuses = {
            socket_echo_strike_chance = 3,
            socket_echo_strike_damage_percent = 30,
            socket_echo_strike_delay_ms = 500,
        },
        tooltip = "Basic single-target attacks have a chance to repeat after 0.5s for reduced damage.\nDetails: Chance: 3%, Damage: 30%, Delay: 0.5s",
        tiers = {
            [1] = { name = "Small Echo Strike Gem", bonuses = { socket_echo_strike_chance = 2, socket_echo_strike_damage_percent = 30, socket_echo_strike_delay_ms = 500 }, tooltip = "Basic single-target attacks have a chance to repeat after 0.5s for reduced damage.\nDetails: Chance: 2%, Damage: 30%, Delay: 0.5s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Echo Strike Gem", bonuses = { socket_echo_strike_chance = 3, socket_echo_strike_damage_percent = 35, socket_echo_strike_delay_ms = 500 }, tooltip = "Basic single-target attacks have a chance to repeat after 0.5s for reduced damage.\nDetails: Chance: 3%, Damage: 35%, Delay: 0.5s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Echo Strike Gem", bonuses = { socket_echo_strike_chance = 4, socket_echo_strike_damage_percent = 40, socket_echo_strike_delay_ms = 500 }, tooltip = "Basic single-target attacks have a chance to repeat after 0.5s for reduced damage.\nDetails: Chance: 4%, Damage: 40%, Delay: 0.5s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Echo Strike Gem", bonuses = { socket_echo_strike_chance = 5, socket_echo_strike_damage_percent = 45, socket_echo_strike_delay_ms = 500 }, tooltip = "Basic single-target attacks have a chance to repeat after 0.5s for reduced damage.\nDetails: Chance: 5%, Damage: 45%, Delay: 0.5s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Echo Strike Gem", bonuses = { socket_echo_strike_chance = 7, socket_echo_strike_damage_percent = 50, socket_echo_strike_delay_ms = 500 }, tooltip = "Basic single-target attacks have a chance to repeat after 0.5s for reduced damage.\nDetails: Chance: 7%, Damage: 50%, Delay: 0.5s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Echo Strike Gem", bonuses = { socket_echo_strike_chance = 10, socket_echo_strike_damage_percent = 60, socket_echo_strike_delay_ms = 500 }, tooltip = "Basic single-target attacks have a chance to repeat after 0.5s for reduced damage.\nDetails: Chance: 10%, Damage: 60%, Delay: 0.5s" }
        },
    },
    -- 136 --
    stonebloodgem = {
        itemId = 30799,
        name = "Stoneblood Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "shield", "ring", "necklace", "belt", "gloves" },
        bestFor = { "Tanks", "Risk Builds", "Solo Players" },
        style = "Low Health Resistance",
        bonuses = {
            socket_stoneblood_max_resistance = 5,
        },
        tooltip = "The lower your HP, the more incoming damage you resist, up to the tier cap.\nDetails: Max Resistance: 5%",
        tiers = {
            [1] = { name = "Small Stoneblood Gem", bonuses = { socket_stoneblood_max_resistance = 6 }, tooltip = "The lower your HP, the more incoming damage you resist, up to the tier cap.\nDetails: Max Resistance: 6%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Stoneblood Gem", bonuses = { socket_stoneblood_max_resistance = 7 }, tooltip = "The lower your HP, the more incoming damage you resist, up to the tier cap.\nDetails: Max Resistance: 7%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Stoneblood Gem", bonuses = { socket_stoneblood_max_resistance = 9 }, tooltip = "The lower your HP, the more incoming damage you resist, up to the tier cap.\nDetails: Max Resistance: 9%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Stoneblood Gem", bonuses = { socket_stoneblood_max_resistance = 11 }, tooltip = "The lower your HP, the more incoming damage you resist, up to the tier cap.\nDetails: Max Resistance: 11%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Stoneblood Gem", bonuses = { socket_stoneblood_max_resistance = 13 }, tooltip = "The lower your HP, the more incoming damage you resist, up to the tier cap.\nDetails: Max Resistance: 13%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Stoneblood Gem", bonuses = { socket_stoneblood_max_resistance = 15 }, tooltip = "The lower your HP, the more incoming damage you resist, up to the tier cap.\nDetails: Max Resistance: 15%" }
        },
    },
    -- 137 --
    rupturegem = {
        itemId = 30800,
        name = "Rupture Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand" },
        bestFor = { "Boss Hunters", "Single Target Builds" },
        style = "Stacking Bleed",
        bonuses = {
            socket_rupture_damage_percent_per_stack = 1,
            socket_rupture_max_stacks = 3,
            socket_rupture_ticks = 3,
            socket_rupture_tick_interval = 2,
        },
        effect = 407,
        tooltip = "Repeated hits on the same monster stack a physical bleed. Switching targets resets stacks.\nDetails: Damage Percent Per Stack: 1%, Max Stacks: 3, Ticks: 3, Tick Interval: 2s",
        tiers = {
            [1] = { name = "Small Rupture Gem", bonuses = { socket_rupture_damage_percent_per_stack = 1.0, socket_rupture_max_stacks = 3, socket_rupture_ticks = 3, socket_rupture_tick_interval = 2 }, tooltip = "Repeated hits on the same monster stack a physical bleed. Switching targets resets stacks.\nDetails: Damage Percent Per Stack: 1%, Max Stacks: 3, Ticks: 3, Tick Interval: 2s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Rupture Gem", bonuses = { socket_rupture_damage_percent_per_stack = 1.2, socket_rupture_max_stacks = 3, socket_rupture_ticks = 3, socket_rupture_tick_interval = 2 }, tooltip = "Repeated hits on the same monster stack a physical bleed. Switching targets resets stacks.\nDetails: Damage Percent Per Stack: 1.2%, Max Stacks: 3, Ticks: 3, Tick Interval: 2s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Rupture Gem", bonuses = { socket_rupture_damage_percent_per_stack = 1.4, socket_rupture_max_stacks = 4, socket_rupture_ticks = 3, socket_rupture_tick_interval = 2 }, tooltip = "Repeated hits on the same monster stack a physical bleed. Switching targets resets stacks.\nDetails: Damage Percent Per Stack: 1.4%, Max Stacks: 4, Ticks: 3, Tick Interval: 2s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Rupture Gem", bonuses = { socket_rupture_damage_percent_per_stack = 1.6, socket_rupture_max_stacks = 4, socket_rupture_ticks = 3, socket_rupture_tick_interval = 2 }, tooltip = "Repeated hits on the same monster stack a physical bleed. Switching targets resets stacks.\nDetails: Damage Percent Per Stack: 1.6%, Max Stacks: 4, Ticks: 3, Tick Interval: 2s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Rupture Gem", bonuses = { socket_rupture_damage_percent_per_stack = 1.8, socket_rupture_max_stacks = 5, socket_rupture_ticks = 3, socket_rupture_tick_interval = 1.5 }, tooltip = "Repeated hits on the same monster stack a physical bleed. Switching targets resets stacks.\nDetails: Damage Percent Per Stack: 1.8%, Max Stacks: 5, Ticks: 3, Tick Interval: 1.5s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Rupture Gem", bonuses = { socket_rupture_damage_percent_per_stack = 2.0, socket_rupture_max_stacks = 6, socket_rupture_ticks = 4, socket_rupture_tick_interval = 1 }, tooltip = "Repeated hits on the same monster stack a physical bleed. Switching targets resets stacks.\nDetails: Damage Percent Per Stack: 2%, Max Stacks: 6, Ticks: 4, Tick Interval: 1s" }
        },
    },
    -- 138 --
    guardianpulsegem = {
        itemId = 30801,
        name = "Guardian Pulse Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "shield", "ring", "necklace", "belt", "gloves" },
        bestFor = { "Team Hunts", "Tanks", "Supports" },
        style = "Party Shield Pulse",
        bonuses = {
            socket_guardian_pulse_cooldown = 20,
            socket_guardian_pulse_shield_percent = 3,
            socket_guardian_pulse_duration = 6,
            socket_guardian_pulse_range = 5,
        },
        tooltip = "When you take damage, nearby party members receive a temporary HP shield. Does not affect yourself.\nDetails: Cooldown: 20s, Shield Percent: 3%, Duration: 6s, Range: 5 SQM",
        tiers = {
            [1] = { name = "Small Guardian Pulse Gem", bonuses = { socket_guardian_pulse_cooldown = 20, socket_guardian_pulse_shield_percent = 3, socket_guardian_pulse_duration = 6, socket_guardian_pulse_range = 5 }, tooltip = "When you take damage, nearby party members receive a temporary HP shield. Does not affect yourself.\nDetails: Cooldown: 20s, Shield Percent: 3%, Duration: 6s, Range: 5 SQM" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Guardian Pulse Gem", bonuses = { socket_guardian_pulse_cooldown = 20, socket_guardian_pulse_shield_percent = 4, socket_guardian_pulse_duration = 6, socket_guardian_pulse_range = 5 }, tooltip = "When you take damage, nearby party members receive a temporary HP shield. Does not affect yourself.\nDetails: Cooldown: 20s, Shield Percent: 4%, Duration: 6s, Range: 5 SQM" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Guardian Pulse Gem", bonuses = { socket_guardian_pulse_cooldown = 20, socket_guardian_pulse_shield_percent = 5, socket_guardian_pulse_duration = 6, socket_guardian_pulse_range = 5 }, tooltip = "When you take damage, nearby party members receive a temporary HP shield. Does not affect yourself.\nDetails: Cooldown: 20s, Shield Percent: 5%, Duration: 6s, Range: 5 SQM" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Guardian Pulse Gem", bonuses = { socket_guardian_pulse_cooldown = 20, socket_guardian_pulse_shield_percent = 6, socket_guardian_pulse_duration = 6, socket_guardian_pulse_range = 5 }, tooltip = "When you take damage, nearby party members receive a temporary HP shield. Does not affect yourself.\nDetails: Cooldown: 20s, Shield Percent: 6%, Duration: 6s, Range: 5 SQM" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Guardian Pulse Gem", bonuses = { socket_guardian_pulse_cooldown = 20, socket_guardian_pulse_shield_percent = 7, socket_guardian_pulse_duration = 6, socket_guardian_pulse_range = 5 }, tooltip = "When you take damage, nearby party members receive a temporary HP shield. Does not affect yourself.\nDetails: Cooldown: 20s, Shield Percent: 7%, Duration: 6s, Range: 5 SQM" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Guardian Pulse Gem", bonuses = { socket_guardian_pulse_cooldown = 20, socket_guardian_pulse_shield_percent = 8, socket_guardian_pulse_duration = 6, socket_guardian_pulse_range = 5 }, tooltip = "When you take damage, nearby party members receive a temporary HP shield. Does not affect yourself.\nDetails: Cooldown: 20s, Shield Percent: 8%, Duration: 6s, Range: 5 SQM" }
        },
    },
    -- 139 --
    secondskingem = {
        itemId = 30802,
        name = "Second Skin Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "shield", "ring", "necklace", "belt", "gloves" },
        bestFor = { "Boss Hunters", "Defensive Builds" },
        style = "Repeated Element Protection",
        bonuses = {
            socket_second_skin_big_hit_percent = 20,
            socket_second_skin_reduction_percent = 10,
            socket_second_skin_duration = 8,
            socket_second_skin_cooldown = 25,
        },
        tooltip = "After taking a big hit, your next hit of the same damage type is reduced.\nDetails: Big Hit Percent: 20%, Reduction Percent: 10%, Duration: 8s, Cooldown: 25s",
        tiers = {
            [1] = { name = "Small Second Skin Gem", bonuses = { socket_second_skin_big_hit_percent = 20, socket_second_skin_reduction_percent = 10, socket_second_skin_duration = 8, socket_second_skin_cooldown = 25 }, tooltip = "After taking a big hit, your next hit of the same damage type is reduced.\nDetails: Big Hit Percent: 20%, Reduction Percent: 10%, Duration: 8s, Cooldown: 25s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Second Skin Gem", bonuses = { socket_second_skin_big_hit_percent = 18, socket_second_skin_reduction_percent = 12, socket_second_skin_duration = 8, socket_second_skin_cooldown = 25 }, tooltip = "After taking a big hit, your next hit of the same damage type is reduced.\nDetails: Big Hit Percent: 18%, Reduction Percent: 12%, Duration: 8s, Cooldown: 25s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Second Skin Gem", bonuses = { socket_second_skin_big_hit_percent = 16, socket_second_skin_reduction_percent = 14, socket_second_skin_duration = 8, socket_second_skin_cooldown = 25 }, tooltip = "After taking a big hit, your next hit of the same damage type is reduced.\nDetails: Big Hit Percent: 16%, Reduction Percent: 14%, Duration: 8s, Cooldown: 25s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Second Skin Gem", bonuses = { socket_second_skin_big_hit_percent = 14, socket_second_skin_reduction_percent = 16, socket_second_skin_duration = 8, socket_second_skin_cooldown = 25 }, tooltip = "After taking a big hit, your next hit of the same damage type is reduced.\nDetails: Big Hit Percent: 14%, Reduction Percent: 16%, Duration: 8s, Cooldown: 25s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Second Skin Gem", bonuses = { socket_second_skin_big_hit_percent = 12, socket_second_skin_reduction_percent = 18, socket_second_skin_duration = 8, socket_second_skin_cooldown = 25 }, tooltip = "After taking a big hit, your next hit of the same damage type is reduced.\nDetails: Big Hit Percent: 12%, Reduction Percent: 18%, Duration: 8s, Cooldown: 25s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Second Skin Gem", bonuses = { socket_second_skin_big_hit_percent = 10, socket_second_skin_reduction_percent = 20, socket_second_skin_duration = 8, socket_second_skin_cooldown = 25 }, tooltip = "After taking a big hit, your next hit of the same damage type is reduced.\nDetails: Big Hit Percent: 10%, Reduction Percent: 20%, Duration: 8s, Cooldown: 25s" }
        },
    },
    -- 140 --
    panicwardgem = {
        itemId = 30803,
        name = "Panic Ward Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "shield", "ring", "necklace", "belt", "gloves" },
        bestFor = { "Survival Builds", "Solo Players", "Escape Tools" },
        style = "Surrounded Defense",
        bonuses = {
            socket_panic_ward_monsters = 4,
            socket_panic_ward_range = 2,
            socket_panic_ward_duration = 5,
            socket_panic_ward_speed = 100,
            socket_panic_ward_reduction_percent = 5,
            socket_panic_ward_cooldown = 30,
        },
        tooltip = "When surrounded by enough monsters, gain temporary speed and damage reduction.\nDetails: Monsters: 4, Range: 2 SQM, Duration: 5s, Speed: 100, Reduction Percent: 5%, Cooldown: 30s",
        tiers = {
            [1] = { name = "Small Panic Ward Gem", bonuses = { socket_panic_ward_monsters = 4, socket_panic_ward_range = 2, socket_panic_ward_duration = 5, socket_panic_ward_speed = 100, socket_panic_ward_reduction_percent = 5, socket_panic_ward_cooldown = 30 }, tooltip = "When surrounded by enough monsters, gain temporary speed and damage reduction.\nDetails: Monsters: 4, Range: 2 SQM, Duration: 5s, Speed: 100, Reduction Percent: 5%, Cooldown: 30s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Panic Ward Gem", bonuses = { socket_panic_ward_monsters = 4, socket_panic_ward_range = 2, socket_panic_ward_duration = 5, socket_panic_ward_speed = 125, socket_panic_ward_reduction_percent = 6, socket_panic_ward_cooldown = 30 }, tooltip = "When surrounded by enough monsters, gain temporary speed and damage reduction.\nDetails: Monsters: 4, Range: 2 SQM, Duration: 5s, Speed: 125, Reduction Percent: 6%, Cooldown: 30s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Panic Ward Gem", bonuses = { socket_panic_ward_monsters = 4, socket_panic_ward_range = 2, socket_panic_ward_duration = 5, socket_panic_ward_speed = 150, socket_panic_ward_reduction_percent = 7, socket_panic_ward_cooldown = 30 }, tooltip = "When surrounded by enough monsters, gain temporary speed and damage reduction.\nDetails: Monsters: 4, Range: 2 SQM, Duration: 5s, Speed: 150, Reduction Percent: 7%, Cooldown: 30s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Panic Ward Gem", bonuses = { socket_panic_ward_monsters = 4, socket_panic_ward_range = 2, socket_panic_ward_duration = 5, socket_panic_ward_speed = 175, socket_panic_ward_reduction_percent = 8, socket_panic_ward_cooldown = 30 }, tooltip = "When surrounded by enough monsters, gain temporary speed and damage reduction.\nDetails: Monsters: 4, Range: 2 SQM, Duration: 5s, Speed: 175, Reduction Percent: 8%, Cooldown: 30s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Panic Ward Gem", bonuses = { socket_panic_ward_monsters = 3, socket_panic_ward_range = 3, socket_panic_ward_duration = 6, socket_panic_ward_speed = 200, socket_panic_ward_reduction_percent = 9, socket_panic_ward_cooldown = 30 }, tooltip = "When surrounded by enough monsters, gain temporary speed and damage reduction.\nDetails: Monsters: 3, Range: 3 SQM, Duration: 6s, Speed: 200, Reduction Percent: 9%, Cooldown: 30s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Panic Ward Gem", bonuses = { socket_panic_ward_monsters = 3, socket_panic_ward_range = 3, socket_panic_ward_duration = 7, socket_panic_ward_speed = 250, socket_panic_ward_reduction_percent = 10, socket_panic_ward_cooldown = 30 }, tooltip = "When surrounded by enough monsters, gain temporary speed and damage reduction.\nDetails: Monsters: 3, Range: 3 SQM, Duration: 7s, Speed: 250, Reduction Percent: 10%, Cooldown: 30s" }
        },
    },
    -- 141 --
    cartelgem = {
        itemId = 30804,
        name = "Cartel Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "ring", "necklace", "belt", "gloves" },
        bestFor = { "Gold Farmers", "Tradeoff Builds" },
        style = "Gold for Rarity Tradeoff",
        bonuses = {
            socket_cartel_gold_multiplier = 0.5,
            socket_cartel_rarity_penalty = 0.5,
        },
        tooltip = "Gold coin loot is multiplied, but rarity loot chance is reduced.\nDetails: Gold Multiplier: x0.5, Rarity Penalty: 0.5",
        tiers = {
            [1] = { name = "Small Cartel Gem", bonuses = { socket_cartel_gold_multiplier = 0.5, socket_cartel_rarity_penalty = 0.5 }, tooltip = "Gold coin loot is multiplied, but rarity loot chance is reduced.\nDetails: Gold Multiplier: x0.5, Rarity Penalty: 0.5" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Cartel Gem", bonuses = { socket_cartel_gold_multiplier = 1.0, socket_cartel_rarity_penalty = 1.0 }, tooltip = "Gold coin loot is multiplied, but rarity loot chance is reduced.\nDetails: Gold Multiplier: x1, Rarity Penalty: 1" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Cartel Gem", bonuses = { socket_cartel_gold_multiplier = 1.5, socket_cartel_rarity_penalty = 1.5 }, tooltip = "Gold coin loot is multiplied, but rarity loot chance is reduced.\nDetails: Gold Multiplier: x1.5, Rarity Penalty: 1.5" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Cartel Gem", bonuses = { socket_cartel_gold_multiplier = 2.0, socket_cartel_rarity_penalty = 2.0 }, tooltip = "Gold coin loot is multiplied, but rarity loot chance is reduced.\nDetails: Gold Multiplier: x2, Rarity Penalty: 2" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Cartel Gem", bonuses = { socket_cartel_gold_multiplier = 2.5, socket_cartel_rarity_penalty = 2.5 }, tooltip = "Gold coin loot is multiplied, but rarity loot chance is reduced.\nDetails: Gold Multiplier: x2.5, Rarity Penalty: 2.5" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Cartel Gem", bonuses = { socket_cartel_gold_multiplier = 3.0, socket_cartel_rarity_penalty = 3.0 }, tooltip = "Gold coin loot is multiplied, but rarity loot chance is reduced.\nDetails: Gold Multiplier: x3, Rarity Penalty: 3" }
        },
    },
    -- 142 --
    memorygem = {
        itemId = 30805,
        name = "Memory Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace" },
        bestFor = { "Long Hunts", "Single Spawn Farmers" },
        style = "Repeated Monster Mastery",
        bonuses = {
            socket_memory_required_kills = 50,
            socket_memory_damage_percent = 1,
        },
        tooltip = "Kill the same monster type 50 times in a row to activate a damage bonus against that monster type. Switching monster type resets progress.\nDetails: Required Kills: 30, Damage: 1%",
        tiers = {
            [1] = { name = "Small Memory Gem", bonuses = { socket_memory_required_kills = 50, socket_memory_damage_percent = 1 }, tooltip = "Kill the same monster type 30 times in a row to activate a damage bonus against that monster type. Switching monster type resets progress.\nDetails: Required Kills: 50, Damage: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Memory Gem", bonuses = { socket_memory_required_kills = 45, socket_memory_damage_percent = 2 }, tooltip = "Kill the same monster type 30 times in a row to activate a damage bonus against that monster type. Switching monster type resets progress.\nDetails: Required Kills: 45, Damage: 2%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Memory Gem", bonuses = { socket_memory_required_kills = 40, socket_memory_damage_percent = 3 }, tooltip = "Kill the same monster type 30 times in a row to activate a damage bonus against that monster type. Switching monster type resets progress.\nDetails: Required Kills: 40, Damage: 3%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Memory Gem", bonuses = { socket_memory_required_kills = 35, socket_memory_damage_percent = 4 }, tooltip = "Kill the same monster type 30 times in a row to activate a damage bonus against that monster type. Switching monster type resets progress.\nDetails: Required Kills: 35, Damage: 4%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Memory Gem", bonuses = { socket_memory_required_kills = 30, socket_memory_damage_percent = 5 }, tooltip = "Kill the same monster type 30 times in a row to activate a damage bonus against that monster type. Switching monster type resets progress.\nDetails: Required Kills: 30, Damage: 5%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Memory Gem", bonuses = { socket_memory_required_kills = 20, socket_memory_damage_percent = 6 }, tooltip = "Kill the same monster type 30 times in a row to activate a damage bonus against that monster type. Switching monster type resets progress.\nDetails: Required Kills: 20, Damage: 6%" }
        },
    },
    -- 143 --
    cursedfortunegem = {
        itemId = 30806,
        name = "Cursed Fortune Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "ring", "necklace", "belt", "gloves" },
        bestFor = { "Risk Takers", "Rarity Hunters" },
        style = "Rarity for Danger Tradeoff",
        bonuses = {
            socket_cursed_fortune_rarity_chance = 2,
            socket_cursed_fortune_damage_taken_percent = 3,
        },
        tooltip = "Increases rarity loot chance, but monsters deal more damage to you.\nDetails: Rarity Chance: 2%, Damage Taken Percent: 3%",
        tiers = {
            [1] = { name = "Small Cursed Fortune Gem", bonuses = { socket_cursed_fortune_rarity_chance = 2, socket_cursed_fortune_damage_taken_percent = 3 }, tooltip = "Increases rarity loot chance, but monsters deal more damage to you.\nDetails: Rarity Chance: 2%, Damage Taken Percent: 3%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Cursed Fortune Gem", bonuses = { socket_cursed_fortune_rarity_chance = 3, socket_cursed_fortune_damage_taken_percent = 4 }, tooltip = "Increases rarity loot chance, but monsters deal more damage to you.\nDetails: Rarity Chance: 3%, Damage Taken Percent: 4%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Cursed Fortune Gem", bonuses = { socket_cursed_fortune_rarity_chance = 4, socket_cursed_fortune_damage_taken_percent = 6 }, tooltip = "Increases rarity loot chance, but monsters deal more damage to you.\nDetails: Rarity Chance: 4%, Damage Taken Percent: 6%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Cursed Fortune Gem", bonuses = { socket_cursed_fortune_rarity_chance = 5, socket_cursed_fortune_damage_taken_percent = 8 }, tooltip = "Increases rarity loot chance, but monsters deal more damage to you.\nDetails: Rarity Chance: 5%, Damage Taken Percent: 8%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Cursed Fortune Gem", bonuses = { socket_cursed_fortune_rarity_chance = 7, socket_cursed_fortune_damage_taken_percent = 10 }, tooltip = "Increases rarity loot chance, but monsters deal more damage to you.\nDetails: Rarity Chance: 7%, Damage Taken Percent: 10%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Cursed Fortune Gem", bonuses = { socket_cursed_fortune_rarity_chance = 10, socket_cursed_fortune_damage_taken_percent = 15 }, tooltip = "Increases rarity loot chance, but monsters deal more damage to you.\nDetails: Rarity Chance: 10%, Damage Taken Percent: 15%" }
        },
    },
    -- 144 --
    bloodechogem = {
        itemId = 30807,
        name = "Blood Echo Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "wand", "ring", "necklace", "belt", "gloves" },
        bestFor = { "Druids", "Healers", "Support Builds" },
        style = "Healing Burst Damage",
        bonuses = {
            socket_blood_echo_chance = 3,
            socket_blood_echo_damage_percent = 15,
            socket_blood_echo_range = 3,
        },
        tooltip = "Self-healing has a chance to damage nearby monsters based on the healing amount.\nDetails: Chance: 3%, Damage: 15%, Range: 3 SQM",
        tiers = {
            [1] = { name = "Small Blood Echo Gem", bonuses = { socket_blood_echo_chance = 2, socket_blood_echo_damage_percent = 15, socket_blood_echo_range = 3 }, tooltip = "Self-healing has a chance to damage nearby monsters based on the healing amount.\nDetails: Chance: 2%, Damage: 15%, Range: 3 SQM" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Blood Echo Gem", bonuses = { socket_blood_echo_chance = 4, socket_blood_echo_damage_percent = 20, socket_blood_echo_range = 3 }, tooltip = "Self-healing has a chance to damage nearby monsters based on the healing amount.\nDetails: Chance: 4%, Damage: 20%, Range: 3 SQM" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Blood Echo Gem", bonuses = { socket_blood_echo_chance = 6, socket_blood_echo_damage_percent = 25, socket_blood_echo_range = 3 }, tooltip = "Self-healing has a chance to damage nearby monsters based on the healing amount.\nDetails: Chance: 6%, Damage: 25%, Range: 3 SQM" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Blood Echo Gem", bonuses = { socket_blood_echo_chance = 8, socket_blood_echo_damage_percent = 30, socket_blood_echo_range = 4 }, tooltip = "Self-healing has a chance to damage nearby monsters based on the healing amount.\nDetails: Chance: 8%, Damage: 30%, Range: 4 SQM" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Blood Echo Gem", bonuses = { socket_blood_echo_chance = 10, socket_blood_echo_damage_percent = 35, socket_blood_echo_range = 4 }, tooltip = "Self-healing has a chance to damage nearby monsters based on the healing amount.\nDetails: Chance: 10%, Damage: 35%, Range: 4 SQM" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Blood Echo Gem", bonuses = { socket_blood_echo_chance = 14, socket_blood_echo_damage_percent = 40, socket_blood_echo_range = 5 }, tooltip = "Self-healing has a chance to damage nearby monsters based on the healing amount.\nDetails: Chance: 14%, Damage: 40%, Range: 5 SQM" }
        },
    },
    -- 145 --
    sundergem = {
        itemId = 30808,
        name = "Sunder Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand" },
        bestFor = { "Boss Hunters", "Team Damage", "Single Target Builds" },
        style = "Stacking Armor Break",
        bonuses = {
            socket_sunder_chance = 8,
            socket_sunder_armor_reduction_percent = 1,
            socket_sunder_max_stacks = 3,
            socket_sunder_duration = 6,
        },
        tooltip = "Hits can sunder a monster for a few seconds. Sunder stacks lightly and makes later player hits deal more damage.\nDetails: Chance: 8%, Armor Reduction Percent: 1%, Max Stacks: 3, Duration: 6s",
        tiers = {
            [1] = { name = "Small Sunder Gem", bonuses = { socket_sunder_chance = 2, socket_sunder_armor_reduction_percent = 1.0, socket_sunder_max_stacks = 3, socket_sunder_duration = 6 }, tooltip = "Hits can sunder a monster for a few seconds. Sunder stacks lightly and makes later player hits deal more damage.\nDetails: Chance: 2%, Armor Reduction Percent: 1%, Max Stacks: 3, Duration: 6s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Sunder Gem", bonuses = { socket_sunder_chance = 3, socket_sunder_armor_reduction_percent = 1.3, socket_sunder_max_stacks = 3, socket_sunder_duration = 6 }, tooltip = "Hits can sunder a monster for a few seconds. Sunder stacks lightly and makes later player hits deal more damage.\nDetails: Chance: 3%, Armor Reduction Percent: 1.3%, Max Stacks: 3, Duration: 6s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Sunder Gem", bonuses = { socket_sunder_chance = 4, socket_sunder_armor_reduction_percent = 1.5, socket_sunder_max_stacks = 4, socket_sunder_duration = 7 }, tooltip = "Hits can sunder a monster for a few seconds. Sunder stacks lightly and makes later player hits deal more damage.\nDetails: Chance: 4%, Armor Reduction Percent: 1.5%, Max Stacks: 4, Duration: 7s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Sunder Gem", bonuses = { socket_sunder_chance = 5, socket_sunder_armor_reduction_percent = 1.8, socket_sunder_max_stacks = 4, socket_sunder_duration = 7 }, tooltip = "Hits can sunder a monster for a few seconds. Sunder stacks lightly and makes later player hits deal more damage.\nDetails: Chance: 5%, Armor Reduction Percent: 1.8%, Max Stacks: 4, Duration: 7s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Sunder Gem", bonuses = { socket_sunder_chance = 7, socket_sunder_armor_reduction_percent = 2.0, socket_sunder_max_stacks = 5, socket_sunder_duration = 8 }, tooltip = "Hits can sunder a monster for a few seconds. Sunder stacks lightly and makes later player hits deal more damage.\nDetails: Chance: 7%, Armor Reduction Percent: 2%, Max Stacks: 5, Duration: 8s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Sunder Gem", bonuses = { socket_sunder_chance = 10, socket_sunder_armor_reduction_percent = 2.5, socket_sunder_max_stacks = 5, socket_sunder_duration = 8 }, tooltip = "Hits can sunder a monster for a few seconds. Sunder stacks lightly and makes later player hits deal more damage.\nDetails: Chance: 10%, Armor Reduction Percent: 2.5%, Max Stacks: 5, Duration: 8s" }
        },
    },
    -- 146 --
    sharedgracegem = {
        itemId = 30809,
        name = "Shared Grace Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "wand", "ring", "necklace", "belt", "gloves" },
        bestFor = { "Druids", "Supports", "Team Hunts" },
        style = "Self-Heal Sharing",
        bonuses = {
            socket_shared_grace_percent = 6,
            socket_shared_grace_range = 5,
            socket_shared_grace_cooldown = 2,
        },
        tooltip = "Self-healing also heals the lowest nearby party member for a percent of the healed amount.\nDetails: Healing: 6%, Range: 5 SQM, Cooldown: 2s",
        tiers = {
            [1] = { name = "Small Shared Grace Gem", bonuses = { socket_shared_grace_percent = 6, socket_shared_grace_range = 5, socket_shared_grace_cooldown = 2 }, tooltip = "Self-healing also heals the lowest nearby party member for a percent of the healed amount.\nDetails: Healing: 6%, Range: 5 SQM, Cooldown: 2s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Shared Grace Gem", bonuses = { socket_shared_grace_percent = 8, socket_shared_grace_range = 5, socket_shared_grace_cooldown = 2 }, tooltip = "Self-healing also heals the lowest nearby party member for a percent of the healed amount.\nDetails: Healing: 8%, Range: 5 SQM, Cooldown: 2s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Shared Grace Gem", bonuses = { socket_shared_grace_percent = 10, socket_shared_grace_range = 5, socket_shared_grace_cooldown = 2 }, tooltip = "Self-healing also heals the lowest nearby party member for a percent of the healed amount.\nDetails: Healing: 10%, Range: 5 SQM, Cooldown: 2s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Shared Grace Gem", bonuses = { socket_shared_grace_percent = 12, socket_shared_grace_range = 5, socket_shared_grace_cooldown = 2 }, tooltip = "Self-healing also heals the lowest nearby party member for a percent of the healed amount.\nDetails: Healing: 12%, Range: 5 SQM, Cooldown: 2s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Shared Grace Gem", bonuses = { socket_shared_grace_percent = 14, socket_shared_grace_range = 6, socket_shared_grace_cooldown = 2 }, tooltip = "Self-healing also heals the lowest nearby party member for a percent of the healed amount.\nDetails: Healing: 14%, Range: 6 SQM, Cooldown: 2s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Shared Grace Gem", bonuses = { socket_shared_grace_percent = 16, socket_shared_grace_range = 6, socket_shared_grace_cooldown = 2 }, tooltip = "Self-healing also heals the lowest nearby party member for a percent of the healed amount.\nDetails: Healing: 16%, Range: 6 SQM, Cooldown: 2s" }
        },
    },
    -- 147 --
    beacongem = {
        itemId = 30810,
        name = "Beacon Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "wand", "ring", "necklace", "belt", "gloves" },
        bestFor = { "Druids", "Party Supports", "Boss Teams" },
        style = "Heal-Triggered Protection",
        bonuses = {
            socket_beacon_reduction_percent = 3,
            socket_beacon_duration = 4,
        },
        tooltip = "Healing a party member marks them. Marked party members take slightly less damage for 4s.\nDetails: Reduction Percent: 3%, Duration: 4s",
        tiers = {
            [1] = { name = "Small Beacon Gem", bonuses = { socket_beacon_reduction_percent = 3, socket_beacon_duration = 4 }, tooltip = "Healing a party member marks them. Marked party members take slightly less damage for 4s.\nDetails: Reduction Percent: 3%, Duration: 4s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Beacon Gem", bonuses = { socket_beacon_reduction_percent = 4, socket_beacon_duration = 4 }, tooltip = "Healing a party member marks them. Marked party members take slightly less damage for 4s.\nDetails: Reduction Percent: 4%, Duration: 4s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Beacon Gem", bonuses = { socket_beacon_reduction_percent = 5, socket_beacon_duration = 4 }, tooltip = "Healing a party member marks them. Marked party members take slightly less damage for 4s.\nDetails: Reduction Percent: 5%, Duration: 4s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Beacon Gem", bonuses = { socket_beacon_reduction_percent = 6, socket_beacon_duration = 4 }, tooltip = "Healing a party member marks them. Marked party members take slightly less damage for 4s.\nDetails: Reduction Percent: 6%, Duration: 4s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Beacon Gem", bonuses = { socket_beacon_reduction_percent = 8, socket_beacon_duration = 4 }, tooltip = "Healing a party member marks them. Marked party members take slightly less damage for 4s.\nDetails: Reduction Percent: 8%, Duration: 4s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Beacon Gem", bonuses = { socket_beacon_reduction_percent = 10, socket_beacon_duration = 4 }, tooltip = "Healing a party member marks them. Marked party members take slightly less damage for 4s.\nDetails: Reduction Percent: 10%, Duration: 4s" }
        },
    },
    -- 148 --
    artisansluckgem = {
        itemId = 30811,
        name = "Artisan's Luck Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "ring", "necklace", "belt", "gloves" },
        bestFor = { "Crafters", "Material Farmers", "Progression" },
        style = "Craft Material Refund",
        bonuses = {
            socket_artisan_luck_chance = 2,
        },
        tooltip = "Crafted items have a chance to refund one consumed material.\nDetails: Chance: 2%",
        tiers = {
            [1] = { name = "Small Artisan's Luck Gem", bonuses = { socket_artisan_luck_chance = 2 }, tooltip = "Crafted items have a chance to refund one consumed material.\nDetails: Chance: 2%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Artisan's Luck Gem", bonuses = { socket_artisan_luck_chance = 3 }, tooltip = "Crafted items have a chance to refund one consumed material.\nDetails: Chance: 3%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Artisan's Luck Gem", bonuses = { socket_artisan_luck_chance = 4 }, tooltip = "Crafted items have a chance to refund one consumed material.\nDetails: Chance: 4%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Artisan's Luck Gem", bonuses = { socket_artisan_luck_chance = 5 }, tooltip = "Crafted items have a chance to refund one consumed material.\nDetails: Chance: 5%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Artisan's Luck Gem", bonuses = { socket_artisan_luck_chance = 7 }, tooltip = "Crafted items have a chance to refund one consumed material.\nDetails: Chance: 7%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Artisan's Luck Gem", bonuses = { socket_artisan_luck_chance = 10 }, tooltip = "Crafted items have a chance to refund one consumed material.\nDetails: Chance: 10%" }
        },
    },
    -- 149 --
    glassheartgem = {
        itemId = 30812,
        name = "Glassheart Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace", "armor", "legs", "belt" },
        bestFor = { "High Risk Damage", "Boss Damage", "Fast Hunts" },
        style = "Damage for Vulnerability",
        bonuses = {
            socket_glassheart_damage_dealt_percent = 3,
            socket_glassheart_damage_taken_percent = 2,
        },
        tooltip = "You deal more damage, but take more damage.\nDetails: Damage Dealt Percent: 3%, Damage Taken Percent: 2%",
        tiers = {
            [1] = { name = "Small Glassheart Gem", bonuses = { socket_glassheart_damage_dealt_percent = 3, socket_glassheart_damage_taken_percent = 2 }, tooltip = "You deal more damage, but take more damage.\nDetails: Damage Dealt Percent: 3%, Damage Taken Percent: 2%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Glassheart Gem", bonuses = { socket_glassheart_damage_dealt_percent = 5, socket_glassheart_damage_taken_percent = 3 }, tooltip = "You deal more damage, but take more damage.\nDetails: Damage Dealt Percent: 5%, Damage Taken Percent: 3%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Glassheart Gem", bonuses = { socket_glassheart_damage_dealt_percent = 7, socket_glassheart_damage_taken_percent = 4 }, tooltip = "You deal more damage, but take more damage.\nDetails: Damage Dealt Percent: 7%, Damage Taken Percent: 4%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Glassheart Gem", bonuses = { socket_glassheart_damage_dealt_percent = 10, socket_glassheart_damage_taken_percent = 5 }, tooltip = "You deal more damage, but take more damage.\nDetails: Damage Dealt Percent: 10%, Damage Taken Percent: 5%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Glassheart Gem", bonuses = { socket_glassheart_damage_dealt_percent = 12, socket_glassheart_damage_taken_percent = 7 }, tooltip = "You deal more damage, but take more damage.\nDetails: Damage Dealt Percent: 12%, Damage Taken Percent: 7%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Glassheart Gem", bonuses = { socket_glassheart_damage_dealt_percent = 15, socket_glassheart_damage_taken_percent = 9 }, tooltip = "You deal more damage, but take more damage.\nDetails: Damage Dealt Percent: 15%, Damage Taken Percent: 9%" }
        },
    },
    -- 150 --
    bulwarkgem = {
        itemId = 30813,
        name = "Bulwark Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "shield", "belt", "gloves" },
        bestFor = { "Tanks", "Bosses", "Survival" },
        style = "Low Health Damage Reduction",
        bonuses = {
            socket_bulwark_threshold = 35,
            socket_bulwark_reduction_percent = 6,
            socket_bulwark_duration = 4,
            socket_bulwark_cooldown = 45,
        },
        tooltip = "Dropping below 35% HP grants short damage reduction. Long cooldown.\nDetails: Threshold: 35%, Reduction Percent: 6%, Duration: 4s, Cooldown: 45s",
        tiers = {
            [1] = { name = "Small Bulwark Gem", bonuses = { socket_bulwark_threshold = 35, socket_bulwark_reduction_percent = 6, socket_bulwark_duration = 4, socket_bulwark_cooldown = 45 }, tooltip = "Dropping below 35% HP grants short damage reduction. Long cooldown.\nDetails: Threshold: 35%, Reduction Percent: 6%, Duration: 4s, Cooldown: 45s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Bulwark Gem", bonuses = { socket_bulwark_threshold = 35, socket_bulwark_reduction_percent = 8, socket_bulwark_duration = 4, socket_bulwark_cooldown = 45 }, tooltip = "Dropping below 35% HP grants short damage reduction. Long cooldown.\nDetails: Threshold: 35%, Reduction Percent: 8%, Duration: 4s, Cooldown: 45s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Bulwark Gem", bonuses = { socket_bulwark_threshold = 35, socket_bulwark_reduction_percent = 10, socket_bulwark_duration = 4, socket_bulwark_cooldown = 45 }, tooltip = "Dropping below 35% HP grants short damage reduction. Long cooldown.\nDetails: Threshold: 35%, Reduction Percent: 10%, Duration: 4s, Cooldown: 45s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Bulwark Gem", bonuses = { socket_bulwark_threshold = 35, socket_bulwark_reduction_percent = 12, socket_bulwark_duration = 4, socket_bulwark_cooldown = 42 }, tooltip = "Dropping below 35% HP grants short damage reduction. Long cooldown.\nDetails: Threshold: 35%, Reduction Percent: 12%, Duration: 4s, Cooldown: 42s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Bulwark Gem", bonuses = { socket_bulwark_threshold = 35, socket_bulwark_reduction_percent = 14, socket_bulwark_duration = 4, socket_bulwark_cooldown = 40 }, tooltip = "Dropping below 35% HP grants short damage reduction. Long cooldown.\nDetails: Threshold: 35%, Reduction Percent: 14%, Duration: 4s, Cooldown: 40s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Bulwark Gem", bonuses = { socket_bulwark_threshold = 35, socket_bulwark_reduction_percent = 16, socket_bulwark_duration = 4, socket_bulwark_cooldown = 38 }, tooltip = "Dropping below 35% HP grants short damage reduction. Long cooldown.\nDetails: Threshold: 35%, Reduction Percent: 16%, Duration: 4s, Cooldown: 38s" }
        },
    },
    -- 151 --
    vampiricshardgem = {
        itemId = 30814,
        name = "Vampiric Shard",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace", "belt", "gloves" },
        bestFor = { "Sustain", "Solo Hunts", "Boss Damage" },
        style = "Damage Life Leech",
        bonuses = {
            socket_vampiric_chance = 3,
            socket_vampiric_heal_percent = 1,
        },
        tooltip = "Damage dealt has a chance to heal you for a small percent of the hit.\nDetails: Chance: 3%, Healing: 1%",
        tiers = {
            [1] = { name = "Small Vampiric Shard", bonuses = { socket_vampiric_chance = 2, socket_vampiric_heal_percent = 1 }, tooltip = "Damage dealt has a chance to heal you for a small percent of the hit.\nDetails: Chance: 2%, Healing: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Vampiric Shard", bonuses = { socket_vampiric_chance = 3, socket_vampiric_heal_percent = 1 }, tooltip = "Damage dealt has a chance to heal you for a small percent of the hit.\nDetails: Chance: 3%, Healing: 1%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Vampiric Shard", bonuses = { socket_vampiric_chance = 4, socket_vampiric_heal_percent = 2 }, tooltip = "Damage dealt has a chance to heal you for a small percent of the hit.\nDetails: Chance: 4%, Healing: 2%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Vampiric Shard", bonuses = { socket_vampiric_chance = 5, socket_vampiric_heal_percent = 3 }, tooltip = "Damage dealt has a chance to heal you for a small percent of the hit.\nDetails: Chance: 5%, Healing: 3%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Vampiric Shard", bonuses = { socket_vampiric_chance = 7, socket_vampiric_heal_percent = 4 }, tooltip = "Damage dealt has a chance to heal you for a small percent of the hit.\nDetails: Chance: 7%, Healing: 4%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Vampiric Shard", bonuses = { socket_vampiric_chance = 10, socket_vampiric_heal_percent = 5 }, tooltip = "Damage dealt has a chance to heal you for a small percent of the hit.\nDetails: Chance: 10%, Healing: 5%" }
        },
    },
    -- 152 --
    manaleechgem = {
        itemId = 30815,
        name = "Mana Leech Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace", "belt", "gloves" },
        bestFor = { "Mages", "Paladins", "Long Hunts" },
        style = "Hit Mana Sustain",
        bonuses = {
            socket_mana_leech_chance = 4,
            socket_mana_leech_restore_percent = 1,
            socket_mana_leech_cooldown = 15,
        },
        tooltip = "Hits have a chance to restore a percent of max mana. Short cooldown.\nDetails: Chance: 4%, Restore Percent: 1%, Cooldown: 15s",
        tiers = {
            [1] = { name = "Small Mana Leech Gem", bonuses = { socket_mana_leech_chance = 2, socket_mana_leech_restore_percent = 1, socket_mana_leech_cooldown = 15 }, tooltip = "Hits have a chance to restore a percent of max mana. Short cooldown.\nDetails: Chance: 2%, Restore Percent: 1%, Cooldown: 15s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Mana Leech Gem", bonuses = { socket_mana_leech_chance = 3, socket_mana_leech_restore_percent = 1.5, socket_mana_leech_cooldown = 15 }, tooltip = "Hits have a chance to restore a percent of max mana. Short cooldown.\nDetails: Chance: 3%, Restore Percent: 1.5%, Cooldown: 15s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Mana Leech Gem", bonuses = { socket_mana_leech_chance = 4, socket_mana_leech_restore_percent = 2, socket_mana_leech_cooldown = 15 }, tooltip = "Hits have a chance to restore a percent of max mana. Short cooldown.\nDetails: Chance: 4%, Restore Percent: 2%, Cooldown: 15s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Mana Leech Gem", bonuses = { socket_mana_leech_chance = 5, socket_mana_leech_restore_percent = 2.5, socket_mana_leech_cooldown = 15 }, tooltip = "Hits have a chance to restore a percent of max mana. Short cooldown.\nDetails: Chance: 5%, Restore Percent: 2.5%, Cooldown: 15s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Mana Leech Gem", bonuses = { socket_mana_leech_chance = 7, socket_mana_leech_restore_percent = 3, socket_mana_leech_cooldown = 15 }, tooltip = "Hits have a chance to restore a percent of max mana. Short cooldown.\nDetails: Chance: 7%, Restore Percent: 3%, Cooldown: 15s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Mana Leech Gem", bonuses = { socket_mana_leech_chance = 10, socket_mana_leech_restore_percent = 3.5, socket_mana_leech_cooldown = 15 }, tooltip = "Hits have a chance to restore a percent of max mana. Short cooldown.\nDetails: Chance: 10%, Restore Percent: 3.5%, Cooldown: 15s" }
        },
    },
    -- 153 --
    bloodpactgem = {
        itemId = 30816,
        name = "Blood Pact Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "wand", "ring", "necklace", "belt", "gloves" },
        bestFor = { "Mages", "Risk Damage", "Spell Builds" },
        style = "HP Cost Spell Damage",
        bonuses = {
            socket_blood_pact_spell_damage_percent = 4,
            socket_blood_pact_hp_cost_percent = 1,
        },
        tooltip = "Attack spells cost current HP but deal more damage.\nDetails: Spell Damage Percent: 4%, HP Cost: 1%",
        tiers = {
            [1] = { name = "Small Blood Pact Gem", bonuses = { socket_blood_pact_spell_damage_percent = 4, socket_blood_pact_hp_cost_percent = 1 }, tooltip = "Attack spells cost current HP but deal more damage.\nDetails: Spell Damage Percent: 4%, HP Cost: 1%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Blood Pact Gem", bonuses = { socket_blood_pact_spell_damage_percent = 5, socket_blood_pact_hp_cost_percent = 1 }, tooltip = "Attack spells cost current HP but deal more damage.\nDetails: Spell Damage Percent: 5%, HP Cost: 1%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Blood Pact Gem", bonuses = { socket_blood_pact_spell_damage_percent = 6, socket_blood_pact_hp_cost_percent = 1 }, tooltip = "Attack spells cost current HP but deal more damage.\nDetails: Spell Damage Percent: 6%, HP Cost: 1%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Blood Pact Gem", bonuses = { socket_blood_pact_spell_damage_percent = 7, socket_blood_pact_hp_cost_percent = 1 }, tooltip = "Attack spells cost current HP but deal more damage.\nDetails: Spell Damage Percent: 7%, HP Cost: 1%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Blood Pact Gem", bonuses = { socket_blood_pact_spell_damage_percent = 8, socket_blood_pact_hp_cost_percent = 1 }, tooltip = "Attack spells cost current HP but deal more damage.\nDetails: Spell Damage Percent: 8%, HP Cost: 1%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Blood Pact Gem", bonuses = { socket_blood_pact_spell_damage_percent = 10, socket_blood_pact_hp_cost_percent = 1 }, tooltip = "Attack spells cost current HP but deal more damage.\nDetails: Spell Damage Percent: 10%, HP Cost: 1%" }
        },
    },
    -- 154 --
    titangem = {
        itemId = 30817,
        name = "Titan Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "shield", "belt", "gloves" },
        bestFor = { "Bosses", "Anti Burst", "Tanks" },
        style = "Large Hit Smoothing",
        bonuses = {
            socket_titan_threshold_percent = 20,
            socket_titan_excess_reduction_percent = 10,
            socket_titan_cooldown = 8,
        },
        tooltip = "Large hits have part of their excess damage reduced. Short cooldown.\nDetails: Threshold Percent: 20%, Excess Reduction Percent: 10%, Cooldown: 8s",
        tiers = {
            [1] = { name = "Small Titan Gem", bonuses = { socket_titan_threshold_percent = 20, socket_titan_excess_reduction_percent = 10, socket_titan_cooldown = 8 }, tooltip = "Large hits have part of their excess damage reduced. Short cooldown.\nDetails: Threshold Percent: 20%, Excess Reduction Percent: 10%, Cooldown: 8s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Titan Gem", bonuses = { socket_titan_threshold_percent = 20, socket_titan_excess_reduction_percent = 14, socket_titan_cooldown = 8 }, tooltip = "Large hits have part of their excess damage reduced. Short cooldown.\nDetails: Threshold Percent: 20%, Excess Reduction Percent: 14%, Cooldown: 8s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Titan Gem", bonuses = { socket_titan_threshold_percent = 20, socket_titan_excess_reduction_percent = 18, socket_titan_cooldown = 8 }, tooltip = "Large hits have part of their excess damage reduced. Short cooldown.\nDetails: Threshold Percent: 20%, Excess Reduction Percent: 18%, Cooldown: 8s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Titan Gem", bonuses = { socket_titan_threshold_percent = 20, socket_titan_excess_reduction_percent = 22, socket_titan_cooldown = 8 }, tooltip = "Large hits have part of their excess damage reduced. Short cooldown.\nDetails: Threshold Percent: 20%, Excess Reduction Percent: 22%, Cooldown: 8s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Titan Gem", bonuses = { socket_titan_threshold_percent = 20, socket_titan_excess_reduction_percent = 26, socket_titan_cooldown = 8 }, tooltip = "Large hits have part of their excess damage reduced. Short cooldown.\nDetails: Threshold Percent: 20%, Excess Reduction Percent: 26%, Cooldown: 8s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Titan Gem", bonuses = { socket_titan_threshold_percent = 20, socket_titan_excess_reduction_percent = 30, socket_titan_cooldown = 8 }, tooltip = "Large hits have part of their excess damage reduced. Short cooldown.\nDetails: Threshold Percent: 20%, Excess Reduction Percent: 30%, Cooldown: 8s" }
        },
    },
    -- 155 --
    stonefootgem = {
        itemId = 30818,
        name = "Stonefoot Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "boots", "legs", "armor", "belt", "gloves" },
        bestFor = { "PvP", "Bosses", "Tanks" },
        style = "Slow Resistance",
        bonuses = {
            socket_stonefoot_slow_ignore_chance = 10,
        },
        tooltip = "Incoming combat has a chance to remove movement slow.\nDetails: Slow Ignore Chance: 10%",
        tiers = {
            [1] = { name = "Small Stonefoot Gem", bonuses = { socket_stonefoot_slow_ignore_chance = 2 }, tooltip = "Incoming combat has a chance to remove movement slow.\nDetails: Slow Ignore Chance: 2%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Stonefoot Gem", bonuses = { socket_stonefoot_slow_ignore_chance = 3 }, tooltip = "Incoming combat has a chance to remove movement slow.\nDetails: Slow Ignore Chance: 3%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Stonefoot Gem", bonuses = { socket_stonefoot_slow_ignore_chance = 4 }, tooltip = "Incoming combat has a chance to remove movement slow.\nDetails: Slow Ignore Chance: 4%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Stonefoot Gem", bonuses = { socket_stonefoot_slow_ignore_chance = 5 }, tooltip = "Incoming combat has a chance to remove movement slow.\nDetails: Slow Ignore Chance: 5%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Stonefoot Gem", bonuses = { socket_stonefoot_slow_ignore_chance = 7 }, tooltip = "Incoming combat has a chance to remove movement slow.\nDetails: Slow Ignore Chance: 7%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Stonefoot Gem", bonuses = { socket_stonefoot_slow_ignore_chance = 10 }, tooltip = "Incoming combat has a chance to remove movement slow.\nDetails: Slow Ignore Chance: 10%" }
        },
    },
    -- 156 --
    evasiongem = {
        itemId = 30819,
        name = "Evasion Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "boots", "legs", "ring", "necklace", "belt", "gloves" },
        bestFor = { "Kiting", "Defensive Movement", "Solo Hunts" },
        style = "Movement Dodge Window",
        effect = 406,
        bonuses = {
            socket_evasion_tiles_required = 10,
            socket_evasion_dodge_percent = 5,
            socket_evasion_duration = 3,
            socket_evasion_cooldown = 10,
        },
        tooltip = "Moving enough tiles primes a short defensive dodge window.\nDetails: Tiles Required: 10, Dodge Percent: 5%, Duration: 3s, Cooldown: 10s",
        tiers = {
            [1] = { name = "Small Evasion Gem", bonuses = { socket_evasion_tiles_required = 10, socket_evasion_dodge_percent = 5, socket_evasion_duration = 3, socket_evasion_cooldown = 10 }, tooltip = "Moving enough tiles primes a short defensive dodge window.\nDetails: Tiles Required: 10, Dodge Percent: 5%, Duration: 3s, Cooldown: 10s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Evasion Gem", bonuses = { socket_evasion_tiles_required = 9, socket_evasion_dodge_percent = 6, socket_evasion_duration = 3, socket_evasion_cooldown = 10 }, tooltip = "Moving enough tiles primes a short defensive dodge window.\nDetails: Tiles Required: 9, Dodge Percent: 6%, Duration: 3s, Cooldown: 10s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Evasion Gem", bonuses = { socket_evasion_tiles_required = 9, socket_evasion_dodge_percent = 8, socket_evasion_duration = 3, socket_evasion_cooldown = 10 }, tooltip = "Moving enough tiles primes a short defensive dodge window.\nDetails: Tiles Required: 9, Dodge Percent: 8%, Duration: 3s, Cooldown: 10s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Evasion Gem", bonuses = { socket_evasion_tiles_required = 8, socket_evasion_dodge_percent = 10, socket_evasion_duration = 3, socket_evasion_cooldown = 10 }, tooltip = "Moving enough tiles primes a short defensive dodge window.\nDetails: Tiles Required: 8, Dodge Percent: 10%, Duration: 3s, Cooldown: 10s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Evasion Gem", bonuses = { socket_evasion_tiles_required = 8, socket_evasion_dodge_percent = 12, socket_evasion_duration = 3, socket_evasion_cooldown = 10 }, tooltip = "Moving enough tiles primes a short defensive dodge window.\nDetails: Tiles Required: 8, Dodge Percent: 12%, Duration: 3s, Cooldown: 10s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Evasion Gem", bonuses = { socket_evasion_tiles_required = 6, socket_evasion_dodge_percent = 14, socket_evasion_duration = 3, socket_evasion_cooldown = 10 }, tooltip = "Moving enough tiles primes a short defensive dodge window.\nDetails: Tiles Required: 6, Dodge Percent: 14%, Duration: 3s, Cooldown: 10s" }
        },
    },
    -- 157 --
    counterspellgem = {
        itemId = 30820,
        name = "Counterspell Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "shield", "ring", "necklace", "belt" },
        bestFor = { "Anti Mage", "Bosses", "Elemental Hunts" },
        style = "Magic Hit Reduction",
        bonuses = {
            socket_counterspell_chance = 3,
            socket_counterspell_reduction_percent = 25,
        },
        tooltip = "Incoming magic damage has a chance to be reduced.\nDetails: Chance: 3%, Reduction Percent: 25%",
        tiers = {
            [1] = { name = "Small Counterspell Gem", bonuses = { socket_counterspell_chance = 2, socket_counterspell_reduction_percent = 25 }, tooltip = "Incoming magic damage has a chance to be reduced.\nDetails: Chance: 2%, Reduction Percent: 25%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Counterspell Gem", bonuses = { socket_counterspell_chance = 3, socket_counterspell_reduction_percent = 25 }, tooltip = "Incoming magic damage has a chance to be reduced.\nDetails: Chance: 3%, Reduction Percent: 25%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Counterspell Gem", bonuses = { socket_counterspell_chance = 4, socket_counterspell_reduction_percent = 25 }, tooltip = "Incoming magic damage has a chance to be reduced.\nDetails: Chance: 4%, Reduction Percent: 25%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Counterspell Gem", bonuses = { socket_counterspell_chance = 5, socket_counterspell_reduction_percent = 25 }, tooltip = "Incoming magic damage has a chance to be reduced.\nDetails: Chance: 5%, Reduction Percent: 25%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Counterspell Gem", bonuses = { socket_counterspell_chance = 7, socket_counterspell_reduction_percent = 25 }, tooltip = "Incoming magic damage has a chance to be reduced.\nDetails: Chance: 7%, Reduction Percent: 25%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Counterspell Gem", bonuses = { socket_counterspell_chance = 10, socket_counterspell_reduction_percent = 25 }, tooltip = "Incoming magic damage has a chance to be reduced.\nDetails: Chance: 10%, Reduction Percent: 25%" }
        },
    },
    -- 158 --
    lifelinegem = {
        itemId = 30821,
        name = "Lifeline Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "wand", "ring", "necklace", "belt", "gloves" },
        bestFor = { "Party Supports", "Team Hunts", "Boss Teams" },
        style = "Low Health Party Rescue",
        bonuses = {
            socket_lifeline_threshold_percent = 25,
            socket_lifeline_heal_percent = 3,
            socket_lifeline_range = 5,
            socket_lifeline_cooldown = 60,
        },
        tooltip = "When a nearby party member drops low, heal them. Long cooldown.\nDetails: Threshold Percent: 25%, Healing: 3%, Range: 5 SQM, Cooldown: 60s",
        tiers = {
            [1] = { name = "Small Lifeline Gem", bonuses = { socket_lifeline_threshold_percent = 25, socket_lifeline_heal_percent = 3, socket_lifeline_range = 5, socket_lifeline_cooldown = 60 }, tooltip = "When a nearby party member drops low, heal them. Long cooldown.\nDetails: Threshold Percent: 25%, Healing: 3%, Range: 5 SQM, Cooldown: 60s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Lifeline Gem", bonuses = { socket_lifeline_threshold_percent = 25, socket_lifeline_heal_percent = 4, socket_lifeline_range = 5, socket_lifeline_cooldown = 60 }, tooltip = "When a nearby party member drops low, heal them. Long cooldown.\nDetails: Threshold Percent: 25%, Healing: 4%, Range: 5 SQM, Cooldown: 60s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Lifeline Gem", bonuses = { socket_lifeline_threshold_percent = 25, socket_lifeline_heal_percent = 5, socket_lifeline_range = 5, socket_lifeline_cooldown = 60 }, tooltip = "When a nearby party member drops low, heal them. Long cooldown.\nDetails: Threshold Percent: 25%, Healing: 5%, Range: 5 SQM, Cooldown: 60s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Lifeline Gem", bonuses = { socket_lifeline_threshold_percent = 25, socket_lifeline_heal_percent = 6, socket_lifeline_range = 5, socket_lifeline_cooldown = 60 }, tooltip = "When a nearby party member drops low, heal them. Long cooldown.\nDetails: Threshold Percent: 25%, Healing: 6%, Range: 5 SQM, Cooldown: 60s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Lifeline Gem", bonuses = { socket_lifeline_threshold_percent = 25, socket_lifeline_heal_percent = 8, socket_lifeline_range = 5, socket_lifeline_cooldown = 60 }, tooltip = "When a nearby party member drops low, heal them. Long cooldown.\nDetails: Threshold Percent: 25%, Healing: 8%, Range: 5 SQM, Cooldown: 60s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Lifeline Gem", bonuses = { socket_lifeline_threshold_percent = 25, socket_lifeline_heal_percent = 10, socket_lifeline_range = 5, socket_lifeline_cooldown = 60 }, tooltip = "When a nearby party member drops low, heal them. Long cooldown.\nDetails: Threshold Percent: 25%, Healing: 10%, Range: 5 SQM, Cooldown: 60s" }
        },
    },
    -- 159 --
    spellhungergem = {
        itemId = 30822,
        name = "Spell Hunger Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "wand", "ring", "necklace", "belt" },
        bestFor = { "Mages", "Spell Hunters" },
        style = "Spell Kill Mana",
        bonuses = { socket_spell_hunger_mana_percent = 1, socket_spell_hunger_window = 4, socket_spell_hunger_cooldown = 5 },
        tooltip = "Killing a monster shortly after a spell hit restores mana.\nDetails: Mana: 1%, Window: 4s, Cooldown: 5s",
        tiers = {
            [1] = { name = "Small Spell Hunger Gem", bonuses = { socket_spell_hunger_mana_percent = 1, socket_spell_hunger_window = 4, socket_spell_hunger_cooldown = 5 }, tooltip = "Killing a monster shortly after a spell hit restores mana.\nDetails: Mana: 1%, Window: 4s, Cooldown: 5s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Spell Hunger Gem", bonuses = { socket_spell_hunger_mana_percent = 1.5, socket_spell_hunger_window = 4, socket_spell_hunger_cooldown = 5 }, tooltip = "Killing a monster shortly after a spell hit restores mana.\nDetails: Mana: 1.5%, Window: 4s, Cooldown: 5s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Spell Hunger Gem", bonuses = { socket_spell_hunger_mana_percent = 2, socket_spell_hunger_window = 5, socket_spell_hunger_cooldown = 5 }, tooltip = "Killing a monster shortly after a spell hit restores mana.\nDetails: Mana: 2%, Window: 5s, Cooldown: 5s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Spell Hunger Gem", bonuses = { socket_spell_hunger_mana_percent = 2.5, socket_spell_hunger_window = 5, socket_spell_hunger_cooldown = 4 }, tooltip = "Killing a monster shortly after a spell hit restores mana.\nDetails: Mana: 2.5%, Window: 5s, Cooldown: 4s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Spell Hunger Gem", bonuses = { socket_spell_hunger_mana_percent = 3, socket_spell_hunger_window = 6, socket_spell_hunger_cooldown = 4 }, tooltip = "Killing a monster shortly after a spell hit restores mana.\nDetails: Mana: 3%, Window: 6s, Cooldown: 4s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Spell Hunger Gem", bonuses = { socket_spell_hunger_mana_percent = 4, socket_spell_hunger_window = 6, socket_spell_hunger_cooldown = 3 }, tooltip = "Killing a monster shortly after a spell hit restores mana.\nDetails: Mana: 4%, Window: 6s, Cooldown: 3s" }
        },
    },
    -- 160 --
    lastembergem = {
        itemId = 30823,
        name = "Last Ember Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "wand", "weapon", "ring", "necklace" },
        bestFor = { "Risk Damage", "Mages" },
        style = "Low HP Element",
        bonuses = { socket_last_ember_threshold = 30, socket_last_ember_damage_percent = 4, socket_last_ember_cooldown = 10 },
        tooltip = "At low HP, elemental attacks gain bonus damage.\nDetails: Threshold: 30%, Damage: 4%, Cooldown: 10s",
        tiers = {
            [1] = { name = "Small Last Ember Gem", bonuses = { socket_last_ember_threshold = 30, socket_last_ember_damage_percent = 4, socket_last_ember_cooldown = 10 }, tooltip = "At low HP, elemental attacks gain bonus damage.\nDetails: Threshold: 30%, Damage: 4%, Cooldown: 10s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Last Ember Gem", bonuses = { socket_last_ember_threshold = 30, socket_last_ember_damage_percent = 5, socket_last_ember_cooldown = 10 }, tooltip = "At low HP, elemental attacks gain bonus damage.\nDetails: Threshold: 30%, Damage: 5%, Cooldown: 10s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Last Ember Gem", bonuses = { socket_last_ember_threshold = 30, socket_last_ember_damage_percent = 6, socket_last_ember_cooldown = 9 }, tooltip = "At low HP, elemental attacks gain bonus damage.\nDetails: Threshold: 30%, Damage: 6%, Cooldown: 9s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Last Ember Gem", bonuses = { socket_last_ember_threshold = 30, socket_last_ember_damage_percent = 8, socket_last_ember_cooldown = 8 }, tooltip = "At low HP, elemental attacks gain bonus damage.\nDetails: Threshold: 30%, Damage: 8%, Cooldown: 8s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Last Ember Gem", bonuses = { socket_last_ember_threshold = 30, socket_last_ember_damage_percent = 10, socket_last_ember_cooldown = 7 }, tooltip = "At low HP, elemental attacks gain bonus damage.\nDetails: Threshold: 30%, Damage: 10%, Cooldown: 7s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Last Ember Gem", bonuses = { socket_last_ember_threshold = 30, socket_last_ember_damage_percent = 12, socket_last_ember_cooldown = 6 }, tooltip = "At low HP, elemental attacks gain bonus damage.\nDetails: Threshold: 30%, Damage: 12%, Cooldown: 6s" }
        },
    },
    -- 161 --
    armorechogem = {
        itemId = 30824,
        name = "Armor Echo Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "shield", "belt" },
        bestFor = { "Tanks", "Knights" },
        style = "Reflect Chip",
        effect = 400,
        bonuses = { socket_armor_echo_chance = 4, socket_armor_echo_damage_percent = 5, socket_armor_echo_cooldown = 2 },
        tooltip = "Incoming monster hits can echo a small physical hit back.\nDetails: Chance: 4%, Damage: 5%, Cooldown: 2s",
        tiers = {
            [1] = { name = "Small Armor Echo Gem", bonuses = { socket_armor_echo_chance = 2, socket_armor_echo_damage_percent = 5, socket_armor_echo_cooldown = 2 }, tooltip = "Incoming monster hits can echo a small physical hit back.\nDetails: Chance: 2%, Damage: 5%, Cooldown: 2s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Armor Echo Gem", bonuses = { socket_armor_echo_chance = 3, socket_armor_echo_damage_percent = 6, socket_armor_echo_cooldown = 2 }, tooltip = "Incoming monster hits can echo a small physical hit back.\nDetails: Chance: 3%, Damage: 6%, Cooldown: 2s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Armor Echo Gem", bonuses = { socket_armor_echo_chance = 4, socket_armor_echo_damage_percent = 7, socket_armor_echo_cooldown = 2 }, tooltip = "Incoming monster hits can echo a small physical hit back.\nDetails: Chance: 4%, Damage: 7%, Cooldown: 2s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Armor Echo Gem", bonuses = { socket_armor_echo_chance = 5, socket_armor_echo_damage_percent = 8, socket_armor_echo_cooldown = 2 }, tooltip = "Incoming monster hits can echo a small physical hit back.\nDetails: Chance: 5%, Damage: 8%, Cooldown: 2s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Armor Echo Gem", bonuses = { socket_armor_echo_chance = 7, socket_armor_echo_damage_percent = 10, socket_armor_echo_cooldown = 2 }, tooltip = "Incoming monster hits can echo a small physical hit back.\nDetails: Chance: 7%, Damage: 10%, Cooldown: 2s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Armor Echo Gem", bonuses = { socket_armor_echo_chance = 10, socket_armor_echo_damage_percent = 12, socket_armor_echo_cooldown = 1 }, tooltip = "Incoming monster hits can echo a small physical hit back.\nDetails: Chance: 10%, Damage: 12%, Cooldown: 1s" }
        },
    },
    -- 162 --
    weakpointgem = {
        itemId = 30825,
        name = "Weak Point Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "gloves", "ring", "belt" },
        bestFor = { "Boss Damage", "Single Target" },
        style = "Next Hit Mark",
        bonuses = { socket_weak_point_chance = 4, socket_weak_point_damage_percent = 8, socket_weak_point_window = 5 },
        tooltip = "Hits can mark a monster so your next hit against it is stronger.\nDetails: Chance: 4%, Damage: 8%, Window: 5s",
        tiers = {
            [1] = { name = "Small Weak Point Gem", bonuses = { socket_weak_point_chance = 2, socket_weak_point_damage_percent = 8, socket_weak_point_window = 5 }, tooltip = "Hits can mark a monster so your next hit against it is stronger.\nDetails: Chance: 2%, Damage: 8%, Window: 5s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Weak Point Gem", bonuses = { socket_weak_point_chance = 3, socket_weak_point_damage_percent = 10, socket_weak_point_window = 5 }, tooltip = "Hits can mark a monster so your next hit against it is stronger.\nDetails: Chance: 3%, Damage: 10%, Window: 5s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Weak Point Gem", bonuses = { socket_weak_point_chance = 4, socket_weak_point_damage_percent = 12, socket_weak_point_window = 5 }, tooltip = "Hits can mark a monster so your next hit against it is stronger.\nDetails: Chance: 4%, Damage: 12%, Window: 5s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Weak Point Gem", bonuses = { socket_weak_point_chance = 5, socket_weak_point_damage_percent = 15, socket_weak_point_window = 6 }, tooltip = "Hits can mark a monster so your next hit against it is stronger.\nDetails: Chance: 5%, Damage: 15%, Window: 6s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Weak Point Gem", bonuses = { socket_weak_point_chance = 7, socket_weak_point_damage_percent = 18, socket_weak_point_window = 6 }, tooltip = "Hits can mark a monster so your next hit against it is stronger.\nDetails: Chance: 7%, Damage: 18%, Window: 6s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Weak Point Gem", bonuses = { socket_weak_point_chance = 10, socket_weak_point_damage_percent = 20, socket_weak_point_window = 7 }, tooltip = "Hits can mark a monster so your next hit against it is stronger.\nDetails: Chance: 10%, Damage: 20%, Window: 7s" }
        },
    },
    -- 163 --
    guardbreakgem = {
        itemId = 30826,
        name = "Guard Break Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "gloves", "ring",  "belt", },
        bestFor = { "Boss Damage", "Team Hunts" },
        style = "Defense Break",
        bonuses = { socket_guard_break_chance = 5, socket_guard_break_damage_percent = 3, socket_guard_break_duration = 5 },
        tooltip = "Hits can weaken a monster, making it take slightly more damage.\nDetails: Chance: 5%, Bonus Damage Taken: 3%, Duration: 5s",
        tiers = {
            [1] = { name = "Small Guard Break Gem", bonuses = { socket_guard_break_chance = 2, socket_guard_break_damage_percent = 3, socket_guard_break_duration = 5 }, tooltip = "Hits can weaken a monster, making it take slightly more damage.\nDetails: Chance: 2%, Bonus Damage Taken: 3%, Duration: 5s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Guard Break Gem", bonuses = { socket_guard_break_chance = 3, socket_guard_break_damage_percent = 4, socket_guard_break_duration = 5 }, tooltip = "Hits can weaken a monster, making it take slightly more damage.\nDetails: Chance: 3%, Bonus Damage Taken: 4%, Duration: 5s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Guard Break Gem", bonuses = { socket_guard_break_chance = 4, socket_guard_break_damage_percent = 5, socket_guard_break_duration = 5 }, tooltip = "Hits can weaken a monster, making it take slightly more damage.\nDetails: Chance: 4%, Bonus Damage Taken: 5%, Duration: 5s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Guard Break Gem", bonuses = { socket_guard_break_chance = 5, socket_guard_break_damage_percent = 6, socket_guard_break_duration = 6 }, tooltip = "Hits can weaken a monster, making it take slightly more damage.\nDetails: Chance: 5%, Bonus Damage Taken: 6%, Duration: 6s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Guard Break Gem", bonuses = { socket_guard_break_chance = 7, socket_guard_break_damage_percent = 7, socket_guard_break_duration = 6 }, tooltip = "Hits can weaken a monster, making it take slightly more damage.\nDetails: Chance: 7%, Bonus Damage Taken: 7%, Duration: 6s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Guard Break Gem", bonuses = { socket_guard_break_chance = 10, socket_guard_break_damage_percent = 8, socket_guard_break_duration = 7 }, tooltip = "Hits can weaken a monster, making it take slightly more damage.\nDetails: Chance: 10%, Bonus Damage Taken: 8%, Duration: 7s" }
        },
    },
    -- 164 --
    nullstepgem = {
        itemId = 30827,
        name = "Nullstep Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "boots", "ring", "necklace", "belt" },
        bestFor = { "Mobile Players", "Escapes" },
        style = "Movement Guard",
        bonuses = { socket_nullstep_min_distance = 2, socket_nullstep_reduction_percent = 5, socket_nullstep_window = 3, socket_nullstep_cooldown = 8 },
        tooltip = "After a large movement jump, your next incoming hit is reduced.\nDetails: Min Distance: 2, Reduction Percent: 5%, Window: 3s, Cooldown: 8s",
        tiers = {
            [1] = { name = "Small Nullstep Gem", bonuses = { socket_nullstep_min_distance = 2, socket_nullstep_reduction_percent = 5, socket_nullstep_window = 3, socket_nullstep_cooldown = 8 }, tooltip = "After a large movement jump, your next incoming hit is reduced.\nDetails: Min Distance: 2, Reduction Percent: 5%, Window: 3s, Cooldown: 8s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Nullstep Gem", bonuses = { socket_nullstep_min_distance = 2, socket_nullstep_reduction_percent = 7, socket_nullstep_window = 3, socket_nullstep_cooldown = 8 }, tooltip = "After a large movement jump, your next incoming hit is reduced.\nDetails: Min Distance: 2, Reduction Percent: 7%, Window: 3s, Cooldown: 8s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Nullstep Gem", bonuses = { socket_nullstep_min_distance = 2, socket_nullstep_reduction_percent = 9, socket_nullstep_window = 3, socket_nullstep_cooldown = 8 }, tooltip = "After a large movement jump, your next incoming hit is reduced.\nDetails: Min Distance: 2, Reduction Percent: 9%, Window: 3s, Cooldown: 8s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Nullstep Gem", bonuses = { socket_nullstep_min_distance = 2, socket_nullstep_reduction_percent = 11, socket_nullstep_window = 4, socket_nullstep_cooldown = 7 }, tooltip = "After a large movement jump, your next incoming hit is reduced.\nDetails: Min Distance: 2, Reduction Percent: 11%, Window: 4s, Cooldown: 7s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Nullstep Gem", bonuses = { socket_nullstep_min_distance = 2, socket_nullstep_reduction_percent = 13, socket_nullstep_window = 4, socket_nullstep_cooldown = 7 }, tooltip = "After a large movement jump, your next incoming hit is reduced.\nDetails: Min Distance: 2, Reduction Percent: 13%, Window: 4s, Cooldown: 7s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Nullstep Gem", bonuses = { socket_nullstep_min_distance = 2, socket_nullstep_reduction_percent = 16, socket_nullstep_window = 4, socket_nullstep_cooldown = 6 }, tooltip = "After a large movement jump, your next incoming hit is reduced.\nDetails: Min Distance: 2, Reduction Percent: 16%, Window: 4s, Cooldown: 6s" }
        },
    },
    -- 165 --
    duelistgem = {
        itemId = 30828,
        name = "Duelist Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "shield", "armor", "ring" },
        bestFor = { "Bosses", "Solo Elites" },
        style = "One Enemy Defense",
        bonuses = { socket_duelist_reduction_percent = 3, socket_duelist_range = 3, socket_duelist_max_monsters = 1, socket_duelist_scan_interval = 2 },
        tooltip = "When one or two monsters are nearby, incoming damage is reduced.\nDetails: Reduction Percent: 3%, Range: 3 SQM, Max Monsters: 1, Scan Interval: 2s",
        tiers = {
            [1] = { name = "Small Duelist Gem", bonuses = { socket_duelist_reduction_percent = 3, socket_duelist_range = 3, socket_duelist_max_monsters = 1, socket_duelist_scan_interval = 2 }, tooltip = "When one or two monsters are nearby, incoming damage is reduced.\nDetails: Reduction Percent: 3%, Range: 3 SQM, Max Monsters: 1, Scan Interval: 2s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Duelist Gem", bonuses = { socket_duelist_reduction_percent = 4, socket_duelist_range = 3, socket_duelist_max_monsters = 1, socket_duelist_scan_interval = 2 }, tooltip = "When one or two monsters are nearby, incoming damage is reduced.\nDetails: Reduction Percent: 4%, Range: 3 SQM, Max Monsters: 1, Scan Interval: 2s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Duelist Gem", bonuses = { socket_duelist_reduction_percent = 5, socket_duelist_range = 3, socket_duelist_max_monsters = 1, socket_duelist_scan_interval = 2 }, tooltip = "When one or two monsters are nearby, incoming damage is reduced.\nDetails: Reduction Percent: 5%, Range: 3 SQM, Max Monsters: 1, Scan Interval: 2s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Duelist Gem", bonuses = { socket_duelist_reduction_percent = 7, socket_duelist_range = 3, socket_duelist_max_monsters = 1, socket_duelist_scan_interval = 2 }, tooltip = "When one or two monsters are nearby, incoming damage is reduced.\nDetails: Reduction Percent: 7%, Range: 3 SQM, Max Monsters: 1, Scan Interval: 2s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Duelist Gem", bonuses = { socket_duelist_reduction_percent = 8, socket_duelist_range = 3, socket_duelist_max_monsters = 1, socket_duelist_scan_interval = 2 }, tooltip = "When one or two monsters are nearby, incoming damage is reduced.\nDetails: Reduction Percent: 8%, Range: 3 SQM, Max Monsters: 1, Scan Interval: 2s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Duelist Gem", bonuses = { socket_duelist_reduction_percent = 10, socket_duelist_range = 3, socket_duelist_max_monsters = 1, socket_duelist_scan_interval = 2 }, tooltip = "When one or two monsters are nearby, incoming damage is reduced.\nDetails: Reduction Percent: 10%, Range: 3 SQM, Max Monsters: 1, Scan Interval: 2s" }
        },
    },
    -- Epic --
    -- 166 --
    phantomstone = {
        itemId = 30829,
        name = "Phantomstone",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "weapon", "wand", "ring", "necklace", "belt", "armor" },
        bestFor = { "Any Vocation" },
        style = "Ghost Double",
        bonuses = {
            socket_phantom_chance = 5,
            socket_phantom_duration = 8,
            socket_phantom_cooldown = 30,
        },
        tooltip = "Attack spells have 3% chance every 30s to summon your phantom double for 10s",
        tiers = {
            [1] = { name = "Small Phantomstone", bonuses = { socket_phantom_chance = 3, socket_phantom_duration = 8, socket_phantom_cooldown = 30 }, tooltip = "Attack spells have 3% chance every 30s to summon your phantom double for 8s", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Phantomstone", bonuses = { socket_phantom_chance = 4, socket_phantom_duration = 9, socket_phantom_cooldown = 30 }, tooltip = "Attack spells have 4% chance every 30s to summon your phantom double for 9s", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Phantomstone", bonuses = { socket_phantom_chance = 5, socket_phantom_duration = 10, socket_phantom_cooldown = 30 }, tooltip = "Attack spells have 5% chance every 30s to summon your phantom double for 10s", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Phantomstone", bonuses = { socket_phantom_chance = 7, socket_phantom_duration = 10, socket_phantom_cooldown = 30 }, tooltip = "Attack spells have 7% chance every 30s to summon your phantom double for 10s", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Phantomstone", bonuses = { socket_phantom_chance = 10, socket_phantom_duration = 10, socket_phantom_cooldown = 30 }, tooltip = "Attack spells have 10% chance every 30s to summon your phantom double for 10s", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Phantomstone", bonuses = { socket_phantom_chance = 12, socket_phantom_duration = 12, socket_phantom_cooldown = 30 }, tooltip = "Attack spells have 12% chance every 30s to summon your phantom double for 12s" }
        },
    },
    -- 167 --
    wayfindergem = {
        itemId = 30830,
        name = "Wayfinder Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "boots", "ring", "necklace", "belt", "armor" },
        bestFor = { "Any Vocation" },
        style = "Hunt Momentum",
        bonuses = {
            socket_wayfinder_speed = 120,
            socket_wayfinder_duration = 4,
            socket_wayfinder_cooldown = 10,
            socket_wayfinder_effect = CONST_ME_MAGIC_BLUE,
        },
        tooltip = "Monster kills grant +120 speed for 4s. 10s cooldown.\nDetails: Duration: 4s",
        tiers = {
            [1] = { name = "Small Wayfinder Gem", bonuses = { socket_wayfinder_speed = 120, socket_wayfinder_duration = 4, socket_wayfinder_cooldown = 10 }, tooltip = "Monster kills grant +120 speed for 4s. 10s cooldown.\nDetails: Duration: 4s", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Wayfinder Gem", bonuses = { socket_wayfinder_speed = 125, socket_wayfinder_duration = 4, socket_wayfinder_cooldown = 10 }, tooltip = "Monster kills grant +125 speed for 4s. 10s cooldown.\nDetails: Duration: 4s", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Wayfinder Gem", bonuses = { socket_wayfinder_speed = 130, socket_wayfinder_duration = 4, socket_wayfinder_cooldown = 10 }, tooltip = "Monster kills grant +130 speed for 4s. 10s cooldown.\nDetails: Duration: 4s", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Wayfinder Gem", bonuses = { socket_wayfinder_speed = 135, socket_wayfinder_duration = 4, socket_wayfinder_cooldown = 10 }, tooltip = "Monster kills grant +135 speed for 4s. 10s cooldown.\nDetails: Duration: 4s", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Wayfinder Gem", bonuses = { socket_wayfinder_speed = 140, socket_wayfinder_duration = 4, socket_wayfinder_cooldown = 10 }, tooltip = "Monster kills grant +140 speed for 4s. 10s cooldown.\nDetails: Duration: 4s", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Wayfinder Gem", bonuses = { socket_wayfinder_speed = 150, socket_wayfinder_duration = 4, socket_wayfinder_cooldown = 10 }, tooltip = "Monster kills grant +150 speed for 4s. 10s cooldown.\nDetails: Duration: 4s" }
        },
    },
    -- 168 --
    riftstepgem = {
        itemId = 30831,
        name = "Riftstep Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "armor", "legs", "boots", "ring", "necklace", "belt" },
        bestFor = { "Any Vocation" },
        style = "Panic Escape",
        bonuses = {
            socket_riftstep_threshold = 35,
            socket_riftstep_cooldown = 30,
            socket_riftstep_min_distance = 1,
            socket_riftstep_max_distance = 2,
            socket_riftstep_rift_damage = 90,
            socket_riftstep_rift_duration = 4,
        },
        tooltip = "When a hit would drop you below 35% HP, teleport to a nearby safe tile and leave a damaging rift behind. 30s cooldown.\nDetails: Threshold: 35%, Min Distance: 1, Max Distance: 2, Rift Damage: 90, Rift Duration: 4s",
        tiers = {
            [1] = { name = "Small Riftstep Gem", bonuses = { socket_riftstep_threshold = 35, socket_riftstep_cooldown = 30, socket_riftstep_min_distance = 1, socket_riftstep_max_distance = 2, socket_riftstep_rift_damage = 90, socket_riftstep_rift_duration = 4 }, tooltip = "When a hit would drop you below 35% HP, teleport to a nearby safe tile and leave a damaging rift behind. 30s cooldown.\nDetails: Threshold: 35%, Min Distance: 1, Max Distance: 2, Rift Damage: 90, Rift Duration: 4s", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Riftstep Gem", bonuses = { socket_riftstep_threshold = 35, socket_riftstep_cooldown = 30, socket_riftstep_min_distance = 1, socket_riftstep_max_distance = 2, socket_riftstep_rift_damage = 95, socket_riftstep_rift_duration = 4 }, tooltip = "When a hit would drop you below 35% HP, teleport to a nearby safe tile and leave a damaging rift behind. 30s cooldown.\nDetails: Threshold: 35%, Min Distance: 1, Max Distance: 2, Rift Damage: 95, Rift Duration: 4s", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Riftstep Gem", bonuses = { socket_riftstep_threshold = 35, socket_riftstep_cooldown = 30, socket_riftstep_min_distance = 2, socket_riftstep_max_distance = 2, socket_riftstep_rift_damage = 100, socket_riftstep_rift_duration = 4 }, tooltip = "When a hit would drop you below 35% HP, teleport to a nearby safe tile and leave a damaging rift behind. 30s cooldown.\nDetails: Threshold: 35%, Min Distance: 2, Max Distance: 2, Rift Damage: 100, Rift Duration: 4s", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Riftstep Gem", bonuses = { socket_riftstep_threshold = 35, socket_riftstep_cooldown = 30, socket_riftstep_min_distance = 2, socket_riftstep_max_distance = 2, socket_riftstep_rift_damage = 105, socket_riftstep_rift_duration = 4 }, tooltip = "When a hit would drop you below 35% HP, teleport to a nearby safe tile and leave a damaging rift behind. 30s cooldown.\nDetails: Threshold: 35%, Min Distance: 2, Max Distance: 2, Rift Damage: 105, Rift Duration: 4s", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Riftstep Gem", bonuses = { socket_riftstep_threshold = 35, socket_riftstep_cooldown = 30, socket_riftstep_min_distance = 3, socket_riftstep_max_distance = 2, socket_riftstep_rift_damage = 110, socket_riftstep_rift_duration = 4 }, tooltip = "When a hit would drop you below 35% HP, teleport to a nearby safe tile and leave a damaging rift behind. 30s cooldown.\nDetails: Threshold: 35%, Min Distance: 3, Max Distance: 2, Rift Damage: 110, Rift Duration: 4s", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Riftstep Gem", bonuses = { socket_riftstep_threshold = 35, socket_riftstep_cooldown = 30, socket_riftstep_min_distance = 3, socket_riftstep_max_distance = 2, socket_riftstep_rift_damage = 120, socket_riftstep_rift_duration = 4 }, tooltip = "When a hit would drop you below 35% HP, teleport to a nearby safe tile and leave a damaging rift behind. 30s cooldown.\nDetails: Threshold: 35%, Min Distance: 3, Max Distance: 2, Rift Damage: 120, Rift Duration: 4s" }
        },
    },
    -- 169 --
    siphonbloomgem = {
        itemId = 30832,
        name = "Siphon Bloom",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "armor", "ring", "necklace", "belt", "boots" },
        bestFor = { "Any Vocation" },
        style = "Harvest",
        bonuses = {
            socket_bloom_cooldown = 30,
            socket_bloom_health_percent = 0.25,
            socket_bloom_mana_percent = 0.25,
        },
        tooltip = "Every 30s, your next monster kill creates a healing bloom on the corpse tile. Stand on it within 5s to restore health and mana.\nDetails: Cooldown: 30s, Health: 0.25%, Mana: 0.25%",
        tiers = {
            [1] = {
                name = "Small Siphon Bloom",
                bonuses = { socket_bloom_cooldown = 30, socket_bloom_health_percent = 0.25, socket_bloom_mana_percent = 0.25 },
                tooltip = "Every 30s, your next monster kill creates a healing bloom on the corpse tile. Stand on it within 5s to restore health and mana.\nDetails: Cooldown: 30s, Health: 0.25%, Mana: 0.25%",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Siphon Bloom",
                bonuses = { socket_bloom_cooldown = 30, socket_bloom_health_percent = 0.5, socket_bloom_mana_percent = 0.5 },
                tooltip = "Every 30s, your next monster kill creates a healing bloom on the corpse tile. Stand on it within 5s to restore health and mana.\nDetails: Cooldown: 30s, Health: 0.5%, Mana: 0.5%",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Siphon Bloom",
                bonuses = { socket_bloom_cooldown = 30, socket_bloom_health_percent = 1, socket_bloom_mana_percent = 1 },
                tooltip = "Every 30s, your next monster kill creates a healing bloom on the corpse tile. Stand on it within 5s to restore health and mana.\nDetails: Cooldown: 30s, Health: 1%, Mana: 1%",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Siphon Bloom",
                bonuses = { socket_bloom_cooldown = 30, socket_bloom_health_percent = 1.5, socket_bloom_mana_percent = 1.5 },
                tooltip = "Every 30s, your next monster kill creates a healing bloom on the corpse tile. Stand on it within 5s to restore health and mana.\nDetails: Cooldown: 30s, Health: 1.5%, Mana: 1.5%",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Siphon Bloom",
                bonuses = { socket_bloom_cooldown = 30, socket_bloom_health_percent = 2, socket_bloom_mana_percent = 2 },
                tooltip = "Every 30s, your next monster kill creates a healing bloom on the corpse tile. Stand on it within 5s to restore health and mana.\nDetails: Cooldown: 30s, Health: 2%, Mana: 2%",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Siphon Bloom",
                bonuses = { socket_bloom_cooldown = 30, socket_bloom_health_percent = 3, socket_bloom_mana_percent = 3 },
                tooltip = "Every 30s, your next monster kill creates a healing bloom on the corpse tile. Stand on it within 5s to restore health and mana.\nDetails: Cooldown: 30s, Health: 3%, Mana: 3%"
            }
        }
    },
    -- 170 --
    amplifiergem = {
        itemId = 30833,
        name = "Amplifier Gem",
        uniquePerItem = true,
        uniqueEquipped = false,
        nonSocketable = true,
        slots = {},
        bestFor = { "Any Vocation" },
        style = "Socket Expansion",
        socketAmplifier = {
            addSockets = 2,
            maxCurrentSockets = 3,
            useConfiguredSocketItems = true,
            allowedItemIds = {},
        },
        bonuses = {},
        tooltip = "Use on allowed equipment with 3 or fewer sockets to add 2 more sockets.",
        tiers = {
            [1] = {
                name = "Small Amplifier Gem",
                bonuses = {},
                tooltip = "Use on allowed equipment with 3 or fewer sockets to add 2 more sockets.",
            }
        }
    },
    -- 171 --
    oathboundgem = {
        itemId = 30834,
        name = "Oathbound Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield" },
        bestFor = { "Any Vocation" },
        style = "Guild PvP Defense",
        bonuses = {
            socket_oathbound_pvp_reduction = 1,
        },
        tooltip = "+1% PvP damage reduction while you are in a guild",
        tiers = {
            [1] = {
                name = "Small Oathbound Gem",
                bonuses = { socket_oathbound_pvp_reduction = 1 },
                tooltip = "+1% PvP damage reduction while you are in a guild",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Oathbound Gem",
                bonuses = { socket_oathbound_pvp_reduction = 2 },
                tooltip = "+2% PvP damage reduction while you are in a guild",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Oathbound Gem",
                bonuses = { socket_oathbound_pvp_reduction = 3 },
                tooltip = "+3% PvP damage reduction while you are in a guild",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Oathbound Gem",
                bonuses = { socket_oathbound_pvp_reduction = 4 },
                tooltip = "+4% PvP damage reduction while you are in a guild",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Oathbound Gem",
                bonuses = { socket_oathbound_pvp_reduction = 5 },
                tooltip = "+5% PvP damage reduction while you are in a guild",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Oathbound Gem",
                bonuses = { socket_oathbound_pvp_reduction = 7 },
                storage = 980135, storageValue = 1,
                tooltip = "+7% PvP damage reduction while you are in a guild"
            }
        }
    },
    -- 172 --
    vowkeepergem = {
        itemId = 30835,
        name = "Vowkeeper Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield" },
        bestFor = { "Any Vocation" },
        style = "Unique Guild Ward",
        bonuses = {
            socket_vowkeeper_reduction = 1,
            socket_vowkeeper_online_bonus = 1,
        },
        tooltip = "+1% damage reduction while you are in a guild\n+1% more while another guild member is online",
        tiers = {
            [1] = {
                name = "Small Vowkeeper Gem",
                bonuses = { socket_vowkeeper_reduction = 1, socket_vowkeeper_online_bonus = 1 },
                tooltip = "+1% damage reduction while you are in a guild\n+1% more while another guild member is online",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Vowkeeper Gem",
                bonuses = { socket_vowkeeper_reduction = 2, socket_vowkeeper_online_bonus = 1 },
                tooltip = "+2% damage reduction while you are in a guild\n+1% more while another guild member is online",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Vowkeeper Gem",
                bonuses = { socket_vowkeeper_reduction = 3, socket_vowkeeper_online_bonus = 1 },
                tooltip = "+3% damage reduction while you are in a guild\n+1% more while another guild member is online",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Vowkeeper Gem",
                bonuses = { socket_vowkeeper_reduction = 4, socket_vowkeeper_online_bonus = 1 },
                tooltip = "+4% damage reduction while you are in a guild\n+1% more while another guild member is online",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Vowkeeper Gem",
                bonuses = { socket_vowkeeper_reduction = 5, socket_vowkeeper_online_bonus = 2 },
                tooltip = "+5% damage reduction while you are in a guild\n+2% more while another guild member is online",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Vowkeeper Gem",
                bonuses = { socket_vowkeeper_reduction = 6, socket_vowkeeper_online_bonus = 2 },
                tooltip = "+6% damage reduction while you are in a guild\n+2% more while another guild member is online"
            }
        }
    },
    -- 173 --
    paradoxgem = {
        itemId = 30836,
        name = "Paradox Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "ring", "necklace", "belt", "boots" },
        bestFor = { "Any Vocation" },
        style = "Unique Timeline Split",
        bonuses = {
            socket_paradox_threshold = 15,
            socket_paradox_duration = 5,
            socket_paradox_cooldown = 45,
            socket_paradox_radius = 6,
        },
        tooltip = "When a monster hit drops you to 35% HP or lower, you become ghosted for 5s and a false timeline copy fights in your place. 45s cooldown.\nDetails: Threshold: 15%, Duration: 5s, Radius: 6 SQM",
        tiers = {
            [1] = { name = "Small Paradox Gem", bonuses = { socket_paradox_threshold = 15, socket_paradox_duration = 5, socket_paradox_cooldown = 45, socket_paradox_radius = 6 }, tooltip = "When a monster hit drops you to 15% HP or lower, you become ghosted for 5s and a false timeline copy fights in your place. 45s cooldown.\nDetails: Threshold: 15%, Duration: 5s, Radius: 6 SQM", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Paradox Gem", bonuses = { socket_paradox_threshold = 20, socket_paradox_duration = 5, socket_paradox_cooldown = 45, socket_paradox_radius = 6 }, tooltip = "When a monster hit drops you to 20% HP or lower, you become ghosted for 5s and a false timeline copy fights in your place. 45s cooldown.\nDetails: Threshold: 20%, Duration: 5s, Radius: 6 SQM", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Paradox Gem", bonuses = { socket_paradox_threshold = 25, socket_paradox_duration = 5, socket_paradox_cooldown = 45, socket_paradox_radius = 6 }, tooltip = "When a monster hit drops you to 25% HP or lower, you become ghosted for 5s and a false timeline copy fights in your place. 45s cooldown.\nDetails: Threshold: 25%, Duration: 5s, Radius: 6 SQM", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Paradox Gem", bonuses = { socket_paradox_threshold = 30, socket_paradox_duration = 5, socket_paradox_cooldown = 45, socket_paradox_radius = 6 }, tooltip = "When a monster hit drops you to 30% HP or lower, you become ghosted for 5s and a false timeline copy fights in your place. 45s cooldown.\nDetails: Threshold: 30%, Duration: 5s, Radius: 6 SQM", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Paradox Gem", bonuses = { socket_paradox_threshold = 35, socket_paradox_duration = 6, socket_paradox_cooldown = 45, socket_paradox_radius = 6 }, tooltip = "When a monster hit drops you to 35% HP or lower, you become ghosted for 6s and a false timeline copy fights in your place. 45s cooldown.\nDetails: Threshold: 35%, Duration: 5s, Radius: 6 SQM", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Paradox Gem", bonuses = { socket_paradox_threshold = 40, socket_paradox_duration = 7, socket_paradox_cooldown = 45, socket_paradox_radius = 6 }, storage = 980114, storageValue = 1, tooltip = "When a monster hit drops you to 40% HP or lower, you become ghosted for 7s and a false timeline copy fights in your place. 45s cooldown.\nDetails: Threshold: 40%, Duration: 5s, Radius: 6 SQM" }
        },
    },
    -- 174 --
    mananovagem = {
        itemId = 30837,
        name = "Mana Nova Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "helmet", "ring", "necklace", "belt" },
        bestFor = { "Sorcerer", "Druid", "Illusionist", "Paladin" },
        style = "Unique Empty Mana Burst",
        effect = 389,
        bonuses = {
            socket_mana_nova_cooldown = 60,
            socket_mana_nova_restore_percent = 0.3,
            socket_mana_nova_restore_seconds = 5,
            socket_mana_nova_damage_percent = 10,
            socket_mana_nova_blind_seconds = 4,
        },
        tooltip = "When mana drain reaches 0 mana, erupt in a 4 SQM holy explosion, dazzle nearby monsters, and restore 0.3% max mana every second for 5s. 60s cooldown.\nDetails: Damage: 10%, Blind Seconds: 4s",
        tiers = {
            [1] = { name = "Small Mana Nova Gem", bonuses = { socket_mana_nova_cooldown = 60, socket_mana_nova_restore_percent = 0.3, socket_mana_nova_restore_seconds = 5, socket_mana_nova_damage_percent = 10, socket_mana_nova_blind_seconds = 4 }, tooltip = "When mana drain reaches 0 mana, erupt in a 4 SQM holy explosion, dazzle nearby monsters, and restore 0.3% max mana every second for 4s. 60s cooldown.\nDetails: Damage: 10%, Blind Seconds: 4s", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Mana Nova Gem", bonuses = { socket_mana_nova_cooldown = 60, socket_mana_nova_restore_percent = 0.5, socket_mana_nova_restore_seconds = 5, socket_mana_nova_damage_percent = 11, socket_mana_nova_blind_seconds = 4 }, tooltip = "When mana drain reaches 0 mana, erupt in a 4 SQM holy explosion, dazzle nearby monsters, and restore 2% max mana every second for 5s. 60s cooldown.\nDetails: Restore Seconds: 10s, Damage: 11%, Blind Seconds: 4s", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Mana Nova Gem", bonuses = { socket_mana_nova_cooldown = 60, socket_mana_nova_restore_percent = 0.75, socket_mana_nova_restore_seconds = 6, socket_mana_nova_damage_percent = 12, socket_mana_nova_blind_seconds = 4 }, tooltip = "When mana drain reaches 0 mana, erupt in a 4 SQM holy explosion, dazzle nearby monsters, and restore 3% max mana every second for 6s. 60s cooldown.\nDetails: Restore Seconds: 10s, Damage: 12%, Blind Seconds: 4s", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Mana Nova Gem", bonuses = { socket_mana_nova_cooldown = 60, socket_mana_nova_restore_percent = 1, socket_mana_nova_restore_seconds = 6, socket_mana_nova_damage_percent = 13, socket_mana_nova_blind_seconds = 4 }, tooltip = "When mana drain reaches 0 mana, erupt in a 4 SQM holy explosion, dazzle nearby monsters, and restore 4% max mana every second for 6s. 60s cooldown.\nDetails: Restore Seconds: 10s, Damage: 13%, Blind Seconds: 4s", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Mana Nova Gem", bonuses = { socket_mana_nova_cooldown = 60, socket_mana_nova_restore_percent = 1.25, socket_mana_nova_restore_seconds = 7, socket_mana_nova_damage_percent = 15, socket_mana_nova_blind_seconds = 4 }, tooltip = "When mana drain reaches 0 mana, erupt in a 4 SQM holy explosion, dazzle nearby monsters, and restore 5% max mana every second for 7s. 60s cooldown.\nDetails: Restore Seconds: 10s, Damage: 15%, Blind Seconds: 4s", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Mana Nova Gem", bonuses = { socket_mana_nova_cooldown = 60, socket_mana_nova_restore_percent = 1.5, socket_mana_nova_restore_seconds = 8, socket_mana_nova_damage_percent = 17, socket_mana_nova_blind_seconds = 4 }, storage = 980152, storageValue = 1, tooltip = "When mana drain reaches 0 mana, erupt in a 4 SQM holy explosion, dazzle nearby monsters, and restore 6% max mana every second for 8s. 60s cooldown.\nDetails: Restore Seconds: 10s, Damage: 17%, Blind Seconds: 4s" }
        },
    },

    -- 175 --
    volleychaingem = {
        itemId = 30838,
        name = "Volley Chain Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "ring", "necklace", "belt" },
        bestFor = { "Paladin" },
        style = "Unique Ranged Chain",
        bonuses = {
            socket_volley_chain_cooldown = 10,
            socket_volley_chain_targets = 1,
            socket_volley_chain_range = 3,
            socket_volley_chain_damage_percent = 30,
        },
        tooltip = "Paladin bow and bolt attacks chain to up to 1 nearby monsters for 60% of the triggering hit. 10s cooldown.\nDetails: Targets: 1, Range: 3 SQM, Damage: 30%",
        tiers = {
            [1] = { name = "Small Volley Chain Gem", bonuses = { socket_volley_chain_cooldown = 10, socket_volley_chain_targets = 1, socket_volley_chain_range = 3, socket_volley_chain_damage_percent = 30 }, tooltip = "Paladin bow and bolt attacks chain to up to 1 nearby monsters for 30% of the triggering hit. 10s cooldown.\nDetails: Targets: 1, Range: 3 SQM, Damage: 60%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Volley Chain Gem", bonuses = { socket_volley_chain_cooldown = 10, socket_volley_chain_targets = 1, socket_volley_chain_range = 3, socket_volley_chain_damage_percent = 35 }, tooltip = "Paladin bow and bolt attacks chain to up to 1 nearby monsters for 35% of the triggering hit. 10s cooldown.\nDetails: Targets: 1, Range: 3 SQM, Damage: 35%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Volley Chain Gem", bonuses = { socket_volley_chain_cooldown = 10, socket_volley_chain_targets = 2, socket_volley_chain_range = 4, socket_volley_chain_damage_percent = 45 }, tooltip = "Paladin bow and bolt attacks chain to up to 1 nearby monsters for 45% of the triggering hit. 10s cooldown.\nDetails: Targets: 2, Range: 4 SQM, Damage: 45%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Volley Chain Gem", bonuses = { socket_volley_chain_cooldown = 10, socket_volley_chain_targets = 2, socket_volley_chain_range = 4, socket_volley_chain_damage_percent = 50 }, tooltip = "Paladin bow and bolt attacks chain to up to 1 nearby monsters for 50% of the triggering hit. 10s cooldown.\nDetails: Targets: 2, Range: 4 SQM, Damage: 50%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Volley Chain Gem", bonuses = { socket_volley_chain_cooldown = 10, socket_volley_chain_targets = 3, socket_volley_chain_range = 5, socket_volley_chain_damage_percent = 60 }, tooltip = "Paladin bow and bolt attacks chain to up to 1 nearby monsters for 60% of the triggering hit. 10s cooldown.\nDetails: Targets: 3, Range: 5 SQM, Damage: 60%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Volley Chain Gem", bonuses = { socket_volley_chain_cooldown = 10, socket_volley_chain_targets = 4, socket_volley_chain_range = 6, socket_volley_chain_damage_percent = 70 }, tooltip = "Paladin bow and bolt attacks chain to up to 1 nearby monsters for 70% of the triggering hit. 10s cooldown.\nDetails: Targets: 4, Range: 6 SQM, Damage: 70%" }
        },
    },
    -- 176 --
    hexmirrorgem = {
        itemId = 30839,
        name = "Hexmirror Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor", "shield", "ring", "necklace", "belt" },
        bestFor = { "Any Vocation" },
        style = "Unique Condition Reflection",
        bonuses = {
            socket_hexmirror_cooldown = 60,
            socket_hexmirror_targets = 2,
            socket_hexmirror_range = 3,
            socket_hexmirror_duration = 5,
            socket_hexmirror_damage = 80,
        },
        effect = 400,
        tooltip = "When condition damage harms you, reflect a random harmful condition to up to 2 nearby monsters. 60s cooldown.\nDetails: Targets: 2, Range: 3 SQM, Duration: 5s, Damage: 80",
        tiers = {
            [1] = { name = "Small Hexmirror Gem", bonuses = { socket_hexmirror_cooldown = 60, socket_hexmirror_targets = 2, socket_hexmirror_range = 3, socket_hexmirror_duration = 5, socket_hexmirror_damage = 80 }, tooltip = "When condition damage harms you, reflect a random harmful condition to up to 2 nearby monsters. 60s cooldown.\nDetails: Targets: 2, Range: 3 SQM, Duration: 5s, Damage: 80", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Hexmirror Gem", bonuses = { socket_hexmirror_cooldown = 60, socket_hexmirror_targets = 3, socket_hexmirror_range = 3, socket_hexmirror_duration = 6, socket_hexmirror_damage = 120 }, tooltip = "When condition damage harms you, reflect a random harmful condition to up to 3 nearby monsters. 60s cooldown.\nDetails: Targets: 3, Range: 3 SQM, Duration: 6s, Damage: 120", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Hexmirror Gem", bonuses = { socket_hexmirror_cooldown = 60, socket_hexmirror_targets = 3, socket_hexmirror_range = 4, socket_hexmirror_duration = 6, socket_hexmirror_damage = 160 }, tooltip = "When condition damage harms you, reflect a random harmful condition to up to 3 nearby monsters. 60s cooldown.\nDetails: Targets: 3, Range: 4 SQM, Duration: 6s, Damage: 160", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Hexmirror Gem", bonuses = { socket_hexmirror_cooldown = 60, socket_hexmirror_targets = 4, socket_hexmirror_range = 5, socket_hexmirror_duration = 7, socket_hexmirror_damage = 200 }, tooltip = "When condition damage harms you, reflect a random harmful condition to up to 4 nearby monsters. 60s cooldown.\nDetails: Targets: 4, Range: 5 SQM, Duration: 7s, Damage: 200", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Hexmirror Gem", bonuses = { socket_hexmirror_cooldown = 60, socket_hexmirror_targets = 5, socket_hexmirror_range = 5, socket_hexmirror_duration = 7, socket_hexmirror_damage = 300 }, tooltip = "When condition damage harms you, reflect a random harmful condition to up to 5 nearby monsters. 60s cooldown.\nDetails: Targets: 5, Range: 5 SQM, Duration: 7s, Damage: 300", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Hexmirror Gem", bonuses = { socket_hexmirror_cooldown = 60, socket_hexmirror_targets = 6, socket_hexmirror_range = 6, socket_hexmirror_duration = 8, socket_hexmirror_damage = 450 }, storage = 980153, storageValue = 1, tooltip = "When condition damage harms you, reflect a random harmful condition to up to 6 nearby monsters. 60s cooldown.\nDetails: Targets: 6, Range: 6 SQM, Duration: 8s, Damage: 450" }
        },
    },
    -- 177 --
    chameleongem = {
        itemId = 30840,
        name = "Chameleon Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "armor" },
        bestFor = { "Any Vocation" },
        style = "Unique Adaptive Resistance",
        bonuses = {
            socket_chameleon_cooldown = 30,
            socket_chameleon_resistance = 10,
        },
        tooltip = "Every 30s, the next elemental hit against you is reduced by 10% as your armor adapts to that element.\nDetails: Cooldown: 30s, Resistance: 10%",
        tiers = {
            [1] = { name = "Small Chameleon Gem", bonuses = { socket_chameleon_cooldown = 30, socket_chameleon_resistance = 10 }, tooltip = "Every 30s, the next elemental hit against you is reduced by 10% as your armor adapts to that element.\nDetails: Cooldown: 30s, Resistance: 10%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Chameleon Gem", bonuses = { socket_chameleon_cooldown = 30, socket_chameleon_resistance = 11 }, tooltip = "Every 30s, the next elemental hit against you is reduced by 11% as your armor adapts to that element.\nDetails: Cooldown: 30s, Resistance: 11%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Chameleon Gem", bonuses = { socket_chameleon_cooldown = 30, socket_chameleon_resistance = 12 }, tooltip = "Every 30s, the next elemental hit against you is reduced by 12% as your armor adapts to that element.\nDetails: Cooldown: 30s, Resistance: 12%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Chameleon Gem", bonuses = { socket_chameleon_cooldown = 30, socket_chameleon_resistance = 13 }, tooltip = "Every 30s, the next elemental hit against you is reduced by 13% as your armor adapts to that element.\nDetails: Cooldown: 30s, Resistance: 13%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Chameleon Gem", bonuses = { socket_chameleon_cooldown = 30, socket_chameleon_resistance = 15 }, tooltip = "Every 30s, the next elemental hit against you is reduced by 15% as your armor adapts to that element.\nDetails: Cooldown: 30s, Resistance: 15%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Chameleon Gem", bonuses = { socket_chameleon_cooldown = 30, socket_chameleon_resistance = 17 }, storage = 980158, storageValue = 1, tooltip = "Every 30s, the next elemental hit against you is reduced by 17% as your armor adapts to that element.\nDetails: Cooldown: 30s, Resistance: 17%" }
        },
    },
    -- 178 --
    galvanicgem = {
        itemId = 30841,
        name = "Galvanic Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "wand", "weapon", "ring", "necklace", "belt" },
        bestFor = { "Sorcerer", "Druid", "Illusionist" },
        style = "Unique Charged Arc",
        bonuses = {
            socket_galvanic_cooldown = 30,
            socket_galvanic_charge_seconds = 12,
            socket_galvanic_targets = 2,
            socket_galvanic_range = 3,
            socket_galvanic_damage_percent = 30,
        },
        effect = 408,
        tooltip = "Wand and rod basic attacks charge monsters. Hitting a charged monster with an energy spell chains lightning to up to 2 nearby monsters for 30% of the spell hit. 30s cooldown.\nDetails: Charge Seconds: 12s, Targets: 2, Range: 3 SQM, Damage: 30%",
        tiers = {
            [1] = { name = "Small Galvanic Gem", bonuses = { socket_galvanic_cooldown = 30, socket_galvanic_charge_seconds = 12, socket_galvanic_targets = 2, socket_galvanic_range = 3, socket_galvanic_damage_percent = 30 }, tooltip = "Wand and rod basic attacks charge monsters. Hitting a charged monster with an energy spell chains lightning to up to 2 nearby monsters for 30% of the spell hit. 30s cooldown.\nDetails: Charge Seconds: 12s, Targets: 2, Range: 3 SQM, Damage: 30%", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Galvanic Gem", bonuses = { socket_galvanic_cooldown = 30, socket_galvanic_charge_seconds = 12, socket_galvanic_targets = 3, socket_galvanic_range = 4, socket_galvanic_damage_percent = 55 }, tooltip = "Wand and rod basic attacks charge monsters. Hitting a charged monster with an energy spell chains lightning to up to 3 nearby monsters for 55% of the spell hit. 30s cooldown.\nDetails: Charge Seconds: 12s, Targets: 3, Range: 3 SQM, Damage: 35%", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Galvanic Gem", bonuses = { socket_galvanic_cooldown = 30, socket_galvanic_charge_seconds = 12, socket_galvanic_targets = 3, socket_galvanic_range = 4, socket_galvanic_damage_percent = 60 }, tooltip = "Wand and rod basic attacks charge monsters. Hitting a charged monster with an energy spell chains lightning to up to 3 nearby monsters for 60% of the spell hit. 30s cooldown.\nDetails: Charge Seconds: 12s, Targets: 3, Range: 4 SQM, Damage: 45%", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Galvanic Gem", bonuses = { socket_galvanic_cooldown = 30, socket_galvanic_charge_seconds = 12, socket_galvanic_targets = 3, socket_galvanic_range = 4, socket_galvanic_damage_percent = 65 }, tooltip = "Wand and rod basic attacks charge monsters. Hitting a charged monster with an energy spell chains lightning to up to 3 nearby monsters for 65% of the spell hit. 30s cooldown.\nDetails: Charge Seconds: 12s, Targets: 3, Range: 4 SQM, Damage: 55%", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Galvanic Gem", bonuses = { socket_galvanic_cooldown = 30, socket_galvanic_charge_seconds = 12, socket_galvanic_targets = 3, socket_galvanic_range = 5, socket_galvanic_damage_percent = 70 }, tooltip = "Wand and rod basic attacks charge monsters. Hitting a charged monster with an energy spell chains lightning to up to 3 nearby monsters for 70% of the spell hit. 30s cooldown.\nDetails: Charge Seconds: 12s, Targets: 3, Range: 5 SQM, Damage: 65%", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Galvanic Gem", bonuses = { socket_galvanic_cooldown = 30, socket_galvanic_charge_seconds = 12, socket_galvanic_targets = 3, socket_galvanic_range = 6, socket_galvanic_damage_percent = 80 }, storage = 980156, storageValue = 1, tooltip = "Wand and rod basic attacks charge monsters. Hitting a charged monster with an energy spell chains lightning to up to 3 nearby monsters for 80% of the spell hit. 30s cooldown.\nDetails: Charge Seconds: 12s, Targets: 3, Range: 6 SQM, Damage: 80%" }
        },
    },
    -- 179 --
    nemesisbrandgem = {
        itemId = 30842,
        name = "Nemesis Brand Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "ring", "necklace", "belt" },
        bestFor = { "PvP", "Revenge Builds", "Duelists" },
        style = "Killer's Mark",
        bonuses = {
            socket_nemesis_duration = 3600,
            socket_nemesis_damage_percent = 5,
            socket_nemesis_resistance_percent = 5,
        },
        tooltip = "When a player kills you, their name is branded into this gem for 1h. Against that player you deal +5% damage and take 5% less damage. The brand clears if you kill them or when it expires.\nDetails: Duration: 1h, Resistance Percent: 10%",
        tiers = {
            [1] = {
                name = "Small Nemesis Brand Gem",
                bonuses = { socket_nemesis_duration = 3600, socket_nemesis_damage_percent = 5, socket_nemesis_resistance_percent = 5 },
                storage = 980105, storageValue = 1,
                tooltip = "When a player kills you, their name is branded into this gem for 1h. Against that player you deal +5% damage and take 5% less damage. The brand clears if you kill them or when it expires.\nDetails: Duration: 3600s, Resistance Percent: 5%",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Nemesis Brand Gem",
                bonuses = { socket_nemesis_duration = 7200, socket_nemesis_damage_percent = 6, socket_nemesis_resistance_percent = 6 },
                tooltip = "When a player kills you, their name is branded into this gem for 2h. Against that player you deal +6% damage and take 6% less damage. The brand clears if you kill them or when it expires.\nDetails: Duration: 2h, Resistance Percent: 6%",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Nemesis Brand Gem",
                bonuses = { socket_nemesis_duration = 10800, socket_nemesis_damage_percent = 7, socket_nemesis_resistance_percent = 7 },
                storage = 980106, storageValue = 1,
                tooltip = "When a player kills you, their name is branded into this gem for 3h. Against that player you deal +7% damage and take 7% less damage. The brand clears if you kill them or when it expires.\nDetails: Duration: 3h, Resistance Percent: 7%",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Nemesis Brand Gem",
                bonuses = { socket_nemesis_duration = 14400, socket_nemesis_damage_percent = 8, socket_nemesis_resistance_percent = 8 },
                tooltip = "When a player kills you, their name is branded into this gem for 4h. Against that player you deal +8% damage and take 8% less damage. The brand clears if you kill them or when it expires.\nDetails: Duration: 14400s, Resistance Percent: 8%",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Nemesis Brand Gem",
                bonuses = { socket_nemesis_duration = 18000, socket_nemesis_damage_percent = 9, socket_nemesis_resistance_percent = 9 },
                tooltip = "When a player kills you, their name is branded into this gem for 5h. Against that player you deal +9% damage and take 9% less damage. The brand clears if you kill them or when it expires.\nDetails: Duration: 18000s, Resistance Percent: 9%",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Nemesis Brand Gem",
                bonuses = { socket_nemesis_duration = 21600, socket_nemesis_damage_percent = 15, socket_nemesis_resistance_percent = 10 },
                storage = 980107, storageValue = 1,
                tooltip = "When a player kills you, their name is branded into this gem for 6h. Against that player you deal +15% damage and take 10% less damage. The brand clears if you kill them or when it expires.\nDetails: Duration: 21600s, Resistance Percent: 10%"
            }
        },
    },
    -- 180 --
    madnessgem = {
        itemId = 30843,
        name = "Madness Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield", "weapon", "wand" },
        bestFor = { "Chaos Builds", "Adaptive Fighters" },
        style = "Random Buff and Downside",
        bonuses = {
            socket_madness_interval = 60,
            socket_madness_damage_percent = 5,
            socket_madness_element_percent = 2.5,
            socket_madness_weapon_percent = 3,
            socket_madness_defense_percent = 2.5,
            socket_madness_skill_value = 1,
        },
        tooltip = "Every 60s rolls one temporary buff and one temporary downside. Possible rolls affect damage, elemental defense, weapon attacks, defense, magic level, or melee skills.\nDetails: Interval: 60s, Damage: 5%, Element Percent: 2.5%, Weapon Percent: 3%, Defense Percent: 2.5%, Skill Value: 1",
        tiers = {
            [1] = { name = "Small Madness Gem", bonuses = { socket_madness_interval = 60, socket_madness_damage_percent = 5, socket_madness_element_percent = 2.5, socket_madness_weapon_percent = 3, socket_madness_defense_percent = 2.5, socket_madness_skill_value = 1 }, tooltip = "Every 60s rolls one temporary buff and one temporary downside. Possible rolls affect damage, elemental defense, weapon attacks, defense, magic level, or melee skills.\nDetails: Interval: 60s, Damage: 5%, Element Percent: 2.5%, Weapon Percent: 3%, Defense Percent: 2.5%, Skill Value: 1" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Madness Gem", bonuses = { socket_madness_interval = 60, socket_madness_damage_percent = 6, socket_madness_element_percent = 3.0, socket_madness_weapon_percent = 3.5, socket_madness_defense_percent = 3.0, socket_madness_skill_value = 2 }, tooltip = "Every 60s rolls one temporary buff and one temporary downside. Possible rolls affect damage, elemental defense, weapon attacks, defense, magic level, or melee skills.\nDetails: Interval: 60s, Damage: 6%, Element Percent: 3%, Weapon Percent: 3.5%, Defense Percent: 3%, Skill Value: 2" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Madness Gem", bonuses = { socket_madness_interval = 60, socket_madness_damage_percent = 7, socket_madness_element_percent = 3.5, socket_madness_weapon_percent = 4.0, socket_madness_defense_percent = 3.5, socket_madness_skill_value = 3 }, tooltip = "Every 60s rolls one temporary buff and one temporary downside. Possible rolls affect damage, elemental defense, weapon attacks, defense, magic level, or melee skills.\nDetails: Interval: 60s, Damage: 7%, Element Percent: 3.5%, Weapon Percent: 4%, Defense Percent: 3.5%, Skill Value: 3" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Madness Gem", bonuses = { socket_madness_interval = 60, socket_madness_damage_percent = 8, socket_madness_element_percent = 4.0, socket_madness_weapon_percent = 4.5, socket_madness_defense_percent = 4.0, socket_madness_skill_value = 4 }, tooltip = "Every 60s rolls one temporary buff and one temporary downside. Possible rolls affect damage, elemental defense, weapon attacks, defense, magic level, or melee skills.\nDetails: Interval: 60s, Damage: 8%, Element Percent: 4%, Weapon Percent: 4.5%, Defense Percent: 4%, Skill Value: 4" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Madness Gem", bonuses = { socket_madness_interval = 60, socket_madness_damage_percent = 9, socket_madness_element_percent = 4.5, socket_madness_weapon_percent = 5.0, socket_madness_defense_percent = 4.5, socket_madness_skill_value = 5 }, tooltip = "Every 60s rolls one temporary buff and one temporary downside. Possible rolls affect damage, elemental defense, weapon attacks, defense, magic level, or melee skills.\nDetails: Interval: 60s, Damage: 9%, Element Percent: 4.5%, Weapon Percent: 5%, Defense Percent: 4.5%, Skill Value: 5" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Madness Gem", bonuses = { socket_madness_interval = 60, socket_madness_damage_percent = 10, socket_madness_element_percent = 5.0, socket_madness_weapon_percent = 5.5, socket_madness_defense_percent = 5.0, socket_madness_skill_value = 6 }, tooltip = "Every 60s rolls one temporary buff and one temporary downside. Possible rolls affect damage, elemental defense, weapon attacks, defense, magic level, or melee skills.\nDetails: Interval: 60s, Damage: 10%, Element Percent: 5%, Weapon Percent: 5.5%, Defense Percent: 5%" }
        },
    },
    -- 181 --
    potionbloomgem = {
        itemId = 30844,
        name = "Potion Bloom Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "wand", "ring", "necklace", "belt" },
        bestFor = { "Druids", "Team Hunts", "Supports" },
        style = "Potion Party Heal",
        bonuses = { socket_potion_bloom_chance = 5, socket_potion_bloom_heal_percent = 2, socket_potion_bloom_range = 4, socket_potion_bloom_cooldown = 15 },
        tooltip = "Health potions can heal nearby party members for a small percent.\nDetails: Chance: 5%, Healing: 2%, Range: 4 SQM, Cooldown: 15s",
        tiers = {
            [1] = { name = "Small Potion Bloom Gem", bonuses = { socket_potion_bloom_chance = 2, socket_potion_bloom_heal_percent = 2, socket_potion_bloom_range = 4, socket_potion_bloom_cooldown = 15 }, tooltip = "Health potions can heal nearby party members for a small percent.\nDetails: Chance: 2%, Healing: 2%, Range: 4 SQM, Cooldown: 15s" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Potion Bloom Gem", bonuses = { socket_potion_bloom_chance = 3, socket_potion_bloom_heal_percent = 2.5, socket_potion_bloom_range = 4, socket_potion_bloom_cooldown = 15 }, tooltip = "Health potions can heal nearby party members for a small percent.\nDetails: Chance: 3%, Healing: 2.5%, Range: 4 SQM, Cooldown: 15s" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Potion Bloom Gem", bonuses = { socket_potion_bloom_chance = 4, socket_potion_bloom_heal_percent = 3, socket_potion_bloom_range = 4, socket_potion_bloom_cooldown = 14 }, tooltip = "Health potions can heal nearby party members for a small percent.\nDetails: Chance: 4%, Healing: 3%, Range: 4 SQM, Cooldown: 14s" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Potion Bloom Gem", bonuses = { socket_potion_bloom_chance = 5, socket_potion_bloom_heal_percent = 4, socket_potion_bloom_range = 5, socket_potion_bloom_cooldown = 13 }, tooltip = "Health potions can heal nearby party members for a small percent.\nDetails: Chance: 5%, Healing: 4%, Range: 5 SQM, Cooldown: 13s" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Potion Bloom Gem", bonuses = { socket_potion_bloom_chance = 7, socket_potion_bloom_heal_percent = 5, socket_potion_bloom_range = 5, socket_potion_bloom_cooldown = 12 }, tooltip = "Health potions can heal nearby party members for a small percent.\nDetails: Chance: 7%, Healing: 5%, Range: 5 SQM, Cooldown: 12s" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Potion Bloom Gem", bonuses = { socket_potion_bloom_chance = 10, socket_potion_bloom_heal_percent = 6, socket_potion_bloom_range = 5, socket_potion_bloom_cooldown = 10 }, tooltip = "Health potions can heal nearby party members for a small percent.\nDetails: Chance: 10%, Healing: 6%, Range: 5 SQM, Cooldown: 10s" }
        },
    },
    -- 182 --
    bossfocusgem = {
        itemId = 30845,
        name = "Boss Focus Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace", "gloves", "belt" },
        bestFor = { "Bosses", "High HP Monsters" },
        style = "Boss Damage",
        bonuses = { socket_boss_focus_damage_percent = 3, socket_boss_focus_min_health = 50000 },
        tooltip = "Deals bonus damage to high-HP monsters.\nDetails: Damage: 3%, Min Health: 50000",
        tiers = {
            [1] = { name = "Small Boss Focus Gem", bonuses = { socket_boss_focus_damage_percent = 3, socket_boss_focus_min_health = 50000 }, tooltip = "Deals bonus damage to high-HP monsters.\nDetails: Damage: 3%, Min Health: 50000" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Boss Focus Gem", bonuses = { socket_boss_focus_damage_percent = 4, socket_boss_focus_min_health = 45000 }, tooltip = "Deals bonus damage to high-HP monsters.\nDetails: Damage: 4%, Min Health: 45000" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Boss Focus Gem", bonuses = { socket_boss_focus_damage_percent = 5, socket_boss_focus_min_health = 40000 }, tooltip = "Deals bonus damage to high-HP monsters.\nDetails: Damage: 5%, Min Health: 40000" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Boss Focus Gem", bonuses = { socket_boss_focus_damage_percent = 6, socket_boss_focus_min_health = 35000 }, tooltip = "Deals bonus damage to high-HP monsters.\nDetails: Damage: 6%, Min Health: 35000" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Boss Focus Gem", bonuses = { socket_boss_focus_damage_percent = 8, socket_boss_focus_min_health = 30000 }, tooltip = "Deals bonus damage to high-HP monsters.\nDetails: Damage: 8%, Min Health: 30000" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Boss Focus Gem", bonuses = { socket_boss_focus_damage_percent = 10, socket_boss_focus_min_health = 25000 }, tooltip = "Deals bonus damage to high-HP monsters.\nDetails: Damage: 10%, Min Health: 25000" }
        },
    },
    -- Legendary --
    -- 183 --
    hivestone = {
        itemId = 30846,
        name = "Hive Stone",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "helmet", "wand", "ring", "necklace", "belt", "armor" },
        bestFor = { "Any Vocation" },
        style = "Hidden Hive",
        bonuses = {
            socket_hive_altar = 1,
        },
        tooltip = "Reveals hidden Hive altars that unleash monster waves for 15 minutes",
        tiers = {
            [1] = { name = "Small Hive Stone", bonuses = { socket_hive_altar = 1 }, tooltip = "Reveals hidden Hive altars that unleash monster waves for 15 minutes.\nDetails: Difficulty: 1", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Hive Stone", bonuses = { socket_hive_altar = 1 }, tooltip = "Reveals hidden Hive altars that unleash monster waves for 15 minutes.\nDetails: Difficulty: 2", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Hive Stone", bonuses = { socket_hive_altar = 1 }, tooltip = "Reveals hidden Hive altars that unleash monster waves for 15 minutes.\nDetails: Difficulty: 3", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Hive Stone", bonuses = { socket_hive_altar = 1 }, tooltip = "Reveals hidden Hive altars that unleash monster waves for 15 minutes.\nDetails: Difficulty: 4", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Hive Stone", bonuses = { socket_hive_altar = 1 }, tooltip = "Reveals hidden Hive altars that unleash monster waves for 15 minutes.\nDetails: Difficulty: 5", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Hive Stone", bonuses = { socket_hive_altar = 1 }, storage = 980149, storageValue = 1, tooltip = "Reveals hidden Hive altars that unleash monster waves for 15 minutes.\nDetails: Difficulty: 6" }
        },
    },

    -- 184 --
    veilstone = {
        itemId = 30847,
        name = "Veilstone",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "ring", "necklace", "belt", "armor" },
        bestFor = { "Any Vocation" },
        style = "Hidden Paths",
        bonuses = {
            socket_veilstone_unlock = 1,
        },
        tooltip = "While socketed, this gem reveals zones that are more populated of monsters.\nDetails: Unlock: 1",
        tiers = {
            [1] = { name = "Small Veilstone", bonuses = { socket_veilstone_unlock = 1 }, storage = 980144, storageValue = 1, tooltip = "While socketed, this gem reveals zones that are more populated of monsters.\nDetails: Unlock: Lower and Upper Roshamuul.", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Veilstone", bonuses = { socket_veilstone_unlock = 1 }, tooltip = "While socketed, this gem reveals zones that are more populated of monsters.\nDetails: Unlock: Roshamuul and Flimsys Zones", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Veilstone", bonuses = { socket_veilstone_unlock = 1 }, tooltip = "While socketed, this gem reveals zones that are more populated of monsters.\nDetails: Unlock: Roshamuul, Flimsys, Azura Palace and Expedition Isles", storage = 980145, storageValue = 1, upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Veilstone", bonuses = { socket_veilstone_unlock = 1 }, tooltip = "While socketed, this gem reveals zones that are more populated of monsters.\nDetails: Unlock: Roshamuul, Flimsys, Azura Palace, Expedition Isles, Waystone Map 1 & 2", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Veilstone", storage = 980146, storageValue = 1, bonuses = { socket_veilstone_unlock = 1 }, tooltip = "While socketed, this gem reveals zones that are more populated of monsters.\nDetails: Unlock: Roshamuul, Flimsys, Azura Palace, Expedition Isles, Waystone Map 1 - 4", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Veilstone", storage = 980147, storageValue = 1, bonuses = { socket_veilstone_unlock = 1 }, tooltip = "While socketed, this gem reveals zones that are more populated of monsters.\nDetails: Unlock: Roshamuul, Flimsys, Azura Palace, Expedition Isles, Waystone Map 1 - 6" }
        },
    },

    -- 185 --
    nemesis = {
        itemId = 30848,
        name = "Nemesis Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "ring", "necklace", "belt", "armor" },
        bestFor = { "Any Vocation" },
        style = "Hidden Boss Altars",
        bonuses = {
            socket_nemesis_altar = 1,
        },
        tooltip = "Reveals hidden Nemesis altars. Higher levels awaken stronger hidden bosses.\nDetails: Difficulty: 1",
        tiers = {
            [1] = {
                name = "Small Nemesis Gem",
                bonuses = { socket_nemesis_altar = 1 },
                tooltip = "Reveals hidden Nemesis altars. Higher levels awaken stronger hidden bosses.\nDetails: Difficulty: 1",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Nemesis Gem",
                bonuses = { socket_nemesis_altar = 1 },
                tooltip = "Reveals hidden Nemesis altars. Higher levels awaken stronger hidden bosses.\nDetails: Difficulty: 2",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Nemesis Gem",
                bonuses = { socket_nemesis_altar = 1 },
                tooltip = "Reveals hidden Nemesis altars. Higher levels awaken stronger hidden bosses.\nDetails: Difficulty: 3",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Nemesis Gem",
                bonuses = { socket_nemesis_altar = 1 },
                tooltip = "Reveals hidden Nemesis altars. Higher levels awaken stronger hidden bosses.\nDetails: Difficulty: 4",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Nemesis Gem",
                bonuses = { socket_nemesis_altar = 1 },
                tooltip = "Reveals hidden Nemesis altars. Higher levels awaken stronger hidden bosses.\nDetails: Difficulty: 5",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Nemesis Gem",
                bonuses = { socket_nemesis_altar = 1 },
                storage = 980148, storageValue = 1,
                tooltip = "Reveals hidden Nemesis altars. Higher levels awaken stronger hidden bosses.\nDetails: Difficulty: 6"
            }
        }
    },
    -- 186 --
    hauntedhuntgem = {
        itemId = 30849,
        name = "Haunted Hunt Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace", "belt", "armor" },
        bestFor = { "Any Vocation" },
        style = "Haunted Hunt",
        hauntedHunt = {
            progressRequired = 500,
            progressPerKill = 1,
            comebackChance = 10,
        },
        bonuses = {},
        tooltip = "Kill attuned monster families while socketed on equipped gear to awaken a haunted hunt. If you flee the boss, it will return during future hunts.",
        tiers = {
            [1] = {
                name = "Small Haunted Hunt Gem",
                hauntedHunt = {
                    progressRequired = 500,
                    progressPerKill = 1,
                    comebackChance = 10,
                },
                bonuses = {},
                tooltip = "Attuned kills fill the haunted bar. At 100%, waves begin and a haunted boss emerges. If you flee, it returns later.",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Haunted Hunt Gem",
                hauntedHunt = {
                    progressRequired = 470,
                    progressPerKill = 1,
                    comebackChance = 15,
                },
                bonuses = {},
                tooltip = "Attuned kills fill the haunted bar faster. Escaped haunted bosses have a higher chance to return.",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Haunted Hunt Gem",
                hauntedHunt = {
                    progressRequired = 450,
                    progressPerKill = 1,
                    comebackChance = 15,
                },
                bonuses = {},
                tooltip = "Attuned kills charge the haunt quickly, and escaped bosses return more often.",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Haunted Hunt Gem",
                hauntedHunt = {
                    progressRequired = 420,
                    progressPerKill = 1,
                    comebackChance = 18,
                },
                bonuses = {},
                tooltip = "The haunt builds rapidly, and escaped bosses almost never stay gone for long.",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Haunted Hunt Gem",
                hauntedHunt = {
                    progressRequired = 400,
                    progressPerKill = 1,
                    comebackChance = 22,
                },
                bonuses = {},
                tooltip = "The haunt builds rapidly, and escaped bosses almost never stay gone for long.",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [6] = {
                name = "Abyssal Haunted Hunt Gem",
                hauntedHunt = {
                    progressRequired = 300,
                    progressPerKill = 1,
                    comebackChance = 25,
                },
                storage = 980150,
                storageValue = 1,
                bonuses = {},
                tooltip = "The haunt builds rapidly, and escaped bosses almost never stay gone for long.",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            }
        }
    },
    -- 187 --
    possessiongem = {
        itemId = 30850,
        name = "Gem of Possession",
        uniquePerItem = true,
        uniqueEquipped = false,
        slots = { "weapon" },
        bestFor = { "Any Vocation" },
        style = "Possession",
        possession = {
            unlockKills = 1000,
            maxActiveSouls = 3,
            cooldown = 30,
            damageMin = 120,
            damageMax = 200,
            slowDurationMs = 2500,
            slowPercent = 20,
        },
        effect = 405,
        bonuses = {},
        tooltip = "Absorbs monster souls while socketed on equipped weapons. Every 1000 kills, a monster soul can enter the active possession list. Only the last 3 active souls can cast their compatible monster attacks.",
        tiers = {
            [1] = {
                name = "Small Gem of Possession",
                possession = { damageMin = 120, damageMax = 200, cooldown = 30, slowDurationMs = 2500, slowPercent = 20 },
                bonuses = {},
                tooltip = "Captures souls from monsters you slay. Compatible active souls can cast their native monster attacks in PvE only.",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Gem of Possession",
                possession = { damageMin = 150, damageMax = 250, cooldown = 30, slowDurationMs = 2800, slowPercent = 22 },
                bonuses = {},
                tooltip = "Captured souls strike harder and slow longer.",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Gem of Possession",
                possession = { damageMin = 190, damageMax = 320, cooldown = 30, slowDurationMs = 3200, slowPercent = 24 },
                bonuses = {},
                tooltip = "Possessed monster attacks gain stronger damage and control.",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Gem of Possession",
                possession = { damageMin = 250, damageMax = 420, cooldown = 30, slowDurationMs = 3600, slowPercent = 27 },
                bonuses = {},
                tooltip = "Possessed monster attacks become far deadlier.",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Gem of Possession",
                possession = { damageMin = 320, damageMax = 540, cooldown = 30, slowDurationMs = 4000, slowPercent = 30 },
                bonuses = {},
                tooltip = "Possessed souls unleash powerful monster attacks.",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Gem of Possession",
                possession = { damageMin = 420, damageMax = 700, cooldown = 30, slowDurationMs = 4500, slowPercent = 35 },
                bonuses = {},
                storage = 980157, storageValue = 1,
                tooltip = "The strongest possessed souls strike with terrifying PvE power.",
            }
        }
    },
    -- 188 --
    abattoirgem = {
        itemId = 30851,
        name = "Abattoir Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace", "belt" },
        bestFor = { "Any Vocation" },
        style = "Unique Slaughter Chain",
        bonuses = {
            socket_abattoir_chain_bonus = 0,
            socket_abattoir_ambush_bonus = 0,
            socket_abattoir_boss_bonus = 0,
        },
        tooltip = "Large monster kills build Kill Chain and Slaughter Heat. Higher heat attracts Abattoir ambushes and executioners. Leaving the event area, dying, logging out, entering protection zone, or idling resets it.",
        tiers = {
            [1] = {
                name = "Small Abattoir Gem",
                bonuses = { socket_abattoir_chain_bonus = 0, socket_abattoir_ambush_bonus = 0, socket_abattoir_boss_bonus = 0 },
                tooltip = "Large monster kills build Kill Chain and Slaughter Heat. Higher heat attracts Abattoir ambushes and executioners. Leaving the event area, dying, logging out, entering protection zone, or idling resets it.\nDetails: Ambush Bonus: 85, Ambush Bonus: 55",
                upgrade = {items = {{ id = 30658, count = 10 }}},
            },
            [2] = {
                name = "Lesser Abattoir Gem",
                bonuses = { socket_abattoir_chain_bonus = 2, socket_abattoir_ambush_bonus = 1, socket_abattoir_boss_bonus = 0 },
                tooltip = "Large monster kills build Kill Chain and Slaughter Heat. Higher heat attracts Abattoir ambushes and executioners. Leaving the event area, dying, logging out, entering protection zone, or idling resets it.\nDetails: Chain Bonus: 5, Ambush Bonus: 1",
                upgrade = {items = {{ id = 30658, count = 25 }}},
            },
            [3] = {
                name = "Greater Abattoir Gem",
                bonuses = { socket_abattoir_chain_bonus = 3, socket_abattoir_ambush_bonus = 2, socket_abattoir_boss_bonus = 1 },
                tooltip = "Large monster kills build Kill Chain and Slaughter Heat. Higher heat attracts Abattoir ambushes and executioners. Leaving the event area, dying, logging out, entering protection zone, or idling resets it.\nDetails: Chain Bonus: 10, Ambush Bonus: 2, Boss Bonus: 1",
                upgrade = {items = {{ id = 30658, count = 50 }}},
            },
            [4] = {
                name = "Super Brutal Abattoir Gem",
                bonuses = { socket_abattoir_chain_bonus = 4, socket_abattoir_ambush_bonus = 3, socket_abattoir_boss_bonus = 1 },
                tooltip = "Large monster kills build Kill Chain and Slaughter Heat. Higher heat attracts Abattoir ambushes and executioners. Leaving the event area, dying, logging out, entering protection zone, or idling resets it.\nDetails: Chain Bonus: 15, Ambush Bonus: 3, Boss Bonus: 1",
                upgrade = {items = {{ id = 30658, count = 100 }}},
            },
            [5] = {
                name = "Mega Infernal Abattoir Gem",
                bonuses = { socket_abattoir_chain_bonus = 5, socket_abattoir_ambush_bonus = 4, socket_abattoir_boss_bonus = 2 },
                tooltip = "Large monster kills build Kill Chain and Slaughter Heat. Higher heat attracts Abattoir ambushes and executioners. Leaving the event area, dying, logging out, entering protection zone, or idling resets it.\nDetails: Chain Bonus: 20, Ambush Bonus: 4, Boss Bonus: 2",
                upgrade = {items = {{ id = 30658, count = 150 }}},
            },
            [6] = {
                name = "Abyssal Abattoir Gem",
                bonuses = { socket_abattoir_chain_bonus = 8, socket_abattoir_ambush_bonus = 5, socket_abattoir_boss_bonus = 3 }, storage = 980142, storageValue = 1,
                tooltip = "Large monster kills build Kill Chain and Slaughter Heat. Higher heat attracts Abattoir ambushes and executioners. Leaving the event area, dying, logging out, entering protection zone, or idling resets it.\nDetails: Chain Bonus: 25, Ambush Bonus: 5, Boss Bonus: 3"
            }
        }
    },
    -- 189 --
    tricraftgem = {
        itemId = 30852,
        name = "Tri-Craft Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "ring", "necklace", "belt", "gloves" },
        bestFor = { "Gatherers" },
        style = "Unique Three Professions",
        bonuses = {
            socket_tricraft_bonus_chance = 3,
        },
        tooltip = "Progresses only through Mining, Woodcutting, and Herbalist. Each tier requires balance between all three professions and can yield extra profession materials.\nDetails: Tricraft Bonus Chance: 3%",
        tiers = {
            [1] = {
                name = "Small Tri-Craft Gem",
                bonuses = { socket_tricraft_bonus_chance = 2 },
                triCraft = {
                    requiredPerProfession = 1000,
                    bonusChance = 3,
                    bonusCount = 5,
                },
                tooltip = "Progresses only through Mining, Woodcutting, and Herbalist. Each tier requires balance between all three professions and can yield extra profession materials.\nDetails: Tricraft Bonus Chance: 2%",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Stonebound Tri-Craft Gem",
                bonuses = { socket_tricraft_bonus_chance = 3 },
                triCraft = {
                    requiredPerProfession = 1500,
                    bonusChance = 5,
                    bonusCount = 10,
                },
                tooltip = "Progresses only through Mining, Woodcutting, and Herbalist. Each tier requires balance between all three professions and can yield extra profession materials.\nDetails: Tricraft Bonus Chance: 3%",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Rootbound Tri-Craft Gem",
                bonuses = { socket_tricraft_bonus_chance = 4 },
                triCraft = {
                    requiredPerProfession = 2500,
                    bonusChance = 7,
                    bonusCount = 15,
                },
                storage = 980122,
                storageValue = 1,
                tooltip = "Progresses only through Mining, Woodcutting, and Herbalist. Each tier requires balance between all three professions and can yield extra profession materials.\nDetails: Tricraft Bonus Chance: 4%",
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Blooming Tri-Craft Gem",
                bonuses = { socket_tricraft_bonus_chance = 5 },
                triCraft = {
                    requiredPerProfession = 4000,
                    bonusChance = 9,
                    bonusCount = 20,
                },
                tooltip = "Progresses only through Mining, Woodcutting, and Herbalist. Each tier requires balance between all three professions and can yield extra profession materials.\nDetails: Tricraft Bonus Chance: 5%",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Balanced Tri-Craft Gem",
                bonuses = { socket_tricraft_bonus_chance = 7 },
                triCraft = {
                    requiredPerProfession = 6000,
                    bonusChance = 12,
                    bonusCount = 25,
                },
                tooltip = "Progresses only through Mining, Woodcutting, and Herbalist. Each tier requires balance between all three professions and can yield extra profession materials.\nDetails: Tricraft Bonus Chance: 7%",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Primal Tri-Craft Gem",
                bonuses = { socket_tricraft_bonus_chance = 10 },
                triCraft = {
                    requiredPerProfession = 10000,
                    bonusChance = 15,
                    bonusCount = 30,
                },
                storage = 980123,
                storageValue = 1,
                tooltip = "Progresses only through Mining, Woodcutting, and Herbalist. Each tier requires balance between all three professions and can yield extra profession materials.\nDetails: Tricraft Bonus Chance: 10%"
            }
        }
    },
    -- 190 --
    treasuregoblingem = {
        itemId = 30853,
        name = "Treasure Goblin Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace", "belt", "armor" },
        bestFor = { "Any Vocation" },
        style = "Unique Loot Chase",
        treasureGoblin = {
            monsters = { "Gem Hoarder Goblin", "Goldsnatch Goblin", "Portal Scavenger Goblin" },
            spawnMinRange = 1,
            spawnMaxRange = 3,
            fleeSeconds = 20,
            lifetimeSeconds = 20,
            fleeIntervalMs = 700,
            spawnEffect = CONST_ME_TELEPORT,
            fleeEffect = 0,
            message = "A treasure goblin slips out of the corpse and starts running!",
        },
        bonuses = {
            socket_treasure_goblin_chance = 1,
            socket_treasure_goblin_cooldown = 180,
        },
        tooltip = "Normal monster kills have 1% chance every 3 minutes to spawn a fleeing treasure goblin from a pool of rare goblins. It disappears after 60s if not killed.\nDetails: Cooldown: 180s",
        tiers = {
            [1] = { name = "Small Treasure Goblin Gem", bonuses = { socket_treasure_goblin_chance = 2, socket_treasure_goblin_cooldown = 180 }, tooltip = "Normal monster kills have 2% chance every 3 minutes to spawn a fleeing treasure goblin from a pool of rare goblins. It disappears after 60s if not killed.\nDetails: Cooldown: 180s", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Treasure Goblin Gem", bonuses = { socket_treasure_goblin_chance = 3, socket_treasure_goblin_cooldown = 180 }, tooltip = "Normal monster kills have 3% chance every 3 minutes to spawn a fleeing treasure goblin from a pool of rare goblins. It disappears after 60s if not killed.\nDetails: Cooldown: 180s", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Treasure Goblin Gem", bonuses = { socket_treasure_goblin_chance = 4, socket_treasure_goblin_cooldown = 180 }, storage = 980128, storageValue = 1, tooltip = "Normal monster kills have 4% chance every 3 minutes to spawn a fleeing treasure goblin from a pool of rare goblins. It disappears after 60s if not killed.\nDetails: Cooldown: 180s", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Treasure Goblin Gem", bonuses = { socket_treasure_goblin_chance = 5, socket_treasure_goblin_cooldown = 180 }, tooltip = "Normal monster kills have 5% chance every 3 minutes to spawn a fleeing treasure goblin from a pool of rare goblins. It disappears after 60s if not killed.\nDetails: Cooldown: 180s", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Treasure Goblin Gem", bonuses = { socket_treasure_goblin_chance = 7, socket_treasure_goblin_cooldown = 180 }, tooltip = "Normal monster kills have 7% chance every 3 minutes to spawn a fleeing treasure goblin from a pool of rare goblins. It disappears after 60s if not killed.\nDetails: Cooldown: 180s", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Treasure Goblin Gem", bonuses = { socket_treasure_goblin_chance = 10, socket_treasure_goblin_cooldown = 180 }, storage = 980129, storageValue = 1, tooltip = "Normal monster kills have 10% chance every 3 minutes to spawn a fleeing treasure goblin from a pool of rare goblins. It disappears after 60s if not killed.\nDetails: Cooldown: 180s" }
        },
    },
    -- 191 --
    rollgem = {
        itemId = 30854,
        name = "Roll Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace", "belt", "armor", "legs" },
        bestFor = { "Any Vocation" },
        style = "Unique Chaos Roll",
        rollGem = {
            range = 3,
            blastRange = 1,
            pushDistance = 2,
            damage = 250,
            healPercent = 1,
            manaPercent = 1,
            hasteSeconds = 5,
            hasteSpeed = 250,
            paralyzeSeconds = 2,
            pushImpactDamagePercent = 10,
            gemPowerMin = 1,
            gemPowerMax = 3,
            effect = 404,
            blastEffect = CONST_ME_EXPLOSIONAREA,
            pushEffect = CONST_ME_POFF,
            pushImpactEffect = 401,
            healEffect = 402,
            manaEffect = CONST_ME_MAGIC_BLUE,
            hasteEffect = CONST_ME_MAGIC_BLUE,
            paralyzeEffect = CONST_ME_STUN,
        },
        bonuses = {
            socket_roll_chance = 4,
            socket_roll_cooldown = 60,
        },
        tooltip = "Normal monster kills have a chance every 60s to roll one random effect: push, 3x3 blast, heal, mana, haste, paralyze, or Gem Power.\nDetails: Chance: 4%, Cooldown: 60s",
        tiers = {
            [1] = {
                name = "Small Roll Gem",
                bonuses = { socket_roll_chance = 4, socket_roll_cooldown = 60 },
                tooltip = "Normal monster kills have a chance every 60s to roll one random effect: push, 3x3 blast, heal, mana, haste, paralyze, or Gem Power.\nDetails: Chance: 2%",
                upgrade = {items = {{ id = 30658, count = 10 }}}
            },
            [2] = {
                name = "Lesser Roll Gem",
                bonuses = { socket_roll_chance = 5, socket_roll_cooldown = 55 },
                tooltip = "Normal monster kills have a chance every 55s to roll one random effect: push, 3x3 blast, heal, mana, haste, paralyze, or Gem Power.\nDetails: Chance: 5%",
                upgrade = {items = {{ id = 30658, count = 25 }}}
            },
            [3] = {
                name = "Greater Roll Gem",
                bonuses = { socket_roll_chance = 7, socket_roll_cooldown = 50 },
                tooltip = "Normal monster kills have a chance every 50s to roll one random effect: push, 3x3 blast, heal, mana, haste, paralyze, or Gem Power.\nDetails: Chance: 7%",
                storage = 980124, storageValue = 1,
                upgrade = {items = {{ id = 30658, count = 50 }}}
            },
            [4] = {
                name = "Super Roll Gem",
                bonuses = { socket_roll_chance = 10, socket_roll_cooldown = 50 },
                tooltip = "Normal monster kills have a chance every 50s to roll one random effect: push, 3x3 blast, heal, mana, haste, paralyze, or Gem Power.\nDetails: Chance: 10%",
                upgrade = {items = {{ id = 30658, count = 100 }}}
            },
            [5] = {
                name = "Mega Roll Gem",
                bonuses = { socket_roll_chance = 12, socket_roll_cooldown = 45 },
                tooltip = "Normal monster kills have a chance every 45s to roll one random effect: push, 3x3 blast, heal, mana, haste, paralyze, or Gem Power.\nDetails: Chance: 12%",
                upgrade = {items = {{ id = 30658, count = 150 }}}
            },
            [6] = {
                name = "Abyssal Roll Gem",
                bonuses = { socket_roll_chance = 15, socket_roll_cooldown = 40 },
                storage = 980125, storageValue = 1,
                tooltip = "Normal monster kills have a chance every 40s to roll one random effect: push, 3x3 blast, heal, mana, haste, paralyze, or Gem Power.\nDetails: Chance: 15%"
            }
        }
    },
    -- 192 --
    cartographygem = {
        itemId = 30855,
        name = "Cartography Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = {},
        bestFor = { "Explorers" },
        style = "World Exploration",
        bonuses = {},
        storage = 980131,
        storageValue = 1,
        tooltip = "Discovers configured world zones while equipped. Progress is weighted by each zone's exploration points and belongs to the wearer.",
    },
    -- 193 --
    professionmasterygem = {
        itemId = 30856,
        name = "Profession Mastery Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        requiresProfessionBinding = true,
        slots = {},
        bestFor = { "Gatherers" },
        style = "Profession Progression",
        bonuses = {},
        storage = 980143,
        storageValue = 1,
        tooltip = "Use this loose gem to permanently bind Mining, Herbalist, or Woodcutting before socketing it. Successful matching gathers improve its tier, efficiency, and Rare Find.",
    },
    -- 194 --
    corruptiongem = {
        itemId = 30857,
        name = "Gem of Corruption",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = {},
        bestFor = { "Waystone Hunters" },
        style = "Waystone Currency Loot",
        bonuses = {
            socket_corruption_exalted_bonus = 30,
            socket_corruption_chaos_bonus = 15,
            socket_corruption_divine_bonus = 8,
            socket_corruption_angel_bonus = 3,
            socket_corruption_mirror_bonus = 0.10,
        },
        tooltip = "Waystone monsters and bosses have increased chance to loot Exalted, Chaos, Divine, Angel, and Mirror currency from their original loot.\nDetails: Exalted Bonus: 30, Chaos Bonus: 15, Divine Bonus: 8, Angel Bonus: 3, Mirror Bonus: 0.1",
        tiers = {
            [1] = { name = "Small Gem of Corruption", bonuses = { socket_corruption_exalted_bonus = 30, socket_corruption_chaos_bonus = 15, socket_corruption_divine_bonus = 8, socket_corruption_angel_bonus = 3, socket_corruption_mirror_bonus = 1 }, storage = 980114, storageValue = 1, tooltip = "Waystone monsters and bosses have increased chance to loot Exalted, Chaos, Divine, Angel, and Mirror currency from their original loot.\nDetails: Exalted Bonus: 30, Chaos Bonus: 15, Divine Bonus: 8, Angel Bonus: 3, Mirror Bonus: 1", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Gem of Corruption", bonuses = { socket_corruption_exalted_bonus = 35, socket_corruption_chaos_bonus = 20, socket_corruption_divine_bonus = 9, socket_corruption_angel_bonus = 4, socket_corruption_mirror_bonus = 2 }, tooltip = "Waystone monsters and bosses have increased chance to loot Exalted, Chaos, Divine, Angel, and Mirror currency from their original loot.\nDetails: Exalted Bonus: 35, Chaos Bonus: 20, Divine Bonus: 9, Angel Bonus: 4, Mirror Bonus: 2", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Gem of Corruption", bonuses = { socket_corruption_exalted_bonus = 40, socket_corruption_chaos_bonus = 25, socket_corruption_divine_bonus = 10, socket_corruption_angel_bonus = 5, socket_corruption_mirror_bonus = 3 }, storage = 980115, storageValue = 1, tooltip = "Waystone monsters and bosses have increased chance to loot Exalted, Chaos, Divine, Angel, and Mirror currency from their original loot.\nDetails: Exalted Bonus: 40, Chaos Bonus: 25, Divine Bonus: 10, Angel Bonus: 5, Mirror Bonus: 3", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Gem of Corruption", bonuses = { socket_corruption_exalted_bonus = 45, socket_corruption_chaos_bonus = 30, socket_corruption_divine_bonus = 11, socket_corruption_angel_bonus = 6, socket_corruption_mirror_bonus = 4 }, tooltip = "Waystone monsters and bosses have increased chance to loot Exalted, Chaos, Divine, Angel, and Mirror currency from their original loot.\nDetails: Exalted Bonus: 45, Chaos Bonus: 30, Divine Bonus: 11, Angel Bonus: 6, Mirror Bonus: 4", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Gem of Corruption", bonuses = { socket_corruption_exalted_bonus = 50, socket_corruption_chaos_bonus = 35, socket_corruption_divine_bonus = 13, socket_corruption_angel_bonus = 8, socket_corruption_mirror_bonus = 5 }, tooltip = "Waystone monsters and bosses have increased chance to loot Exalted, Chaos, Divine, Angel, and Mirror currency from their original loot.\nDetails: Exalted Bonus: 50, Chaos Bonus: 35, Divine Bonus: 13, Angel Bonus: 8, Mirror Bonus: 5", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Gem of Corruption", bonuses = { socket_corruption_exalted_bonus = 60, socket_corruption_chaos_bonus = 45, socket_corruption_divine_bonus = 15, socket_corruption_angel_bonus = 10, socket_corruption_mirror_bonus = 6 }, storage = 980116, storageValue = 1, tooltip = "Waystone monsters and bosses have increased chance to loot Exalted, Chaos, Divine, Angel, and Mirror currency from their original loot.\nDetails: Exalted Bonus: 60, Chaos Bonus: 45, Divine Bonus: 15, Angel Bonus: 10, Mirror Bonus: 6" }
        },
    },
    -- 195 --
    puritygem = {
        itemId = 30858,
        name = "Gem of Purity",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = {},
        bestFor = { "Defensive Builds", "Waystone Hunters" },
        style = "Debuff Immunity",
        bonuses = {
            socket_purity_cleanse = 1,
        },
        storage = 980155,
        storageValue = 1,
        tooltip = "While equipped, poison, fire, energy, bleed, paralyze, drunk, drown, freeze, dazzle, curse, splashed, and bewitched effects doesn't affect you.",
    },
    -- 196 --
    tidegem = {
        itemId = 30859,
        name = "Tide Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield", "weapon", "wand" },
        bestFor = { "Hunters", "Party Players" },
        style = "Server Rhythm",
        bonuses = {
            socket_tide_loot_percent = 5,
            socket_tide_xp_percent = 5,
        },
        tooltip = "During configured peak hours, gain +5% loot rarity chance. During off-peak hours, gain +5% experience instead.",
        tiers = {
            [1] = { name = "Small Tide Gem", bonuses = { socket_tide_loot_percent = 5, socket_tide_xp_percent = 5 }, tooltip = "During configured peak hours, gain +5% loot rarity chance. During off-peak hours, gain +5% experience instead.", upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Tide Gem", bonuses = { socket_tide_loot_percent = 6, socket_tide_xp_percent = 6 }, tooltip = "During configured peak hours, gain +6% loot rarity chance. During off-peak hours, gain +6% experience instead.", upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Tide Gem", bonuses = { socket_tide_loot_percent = 7, socket_tide_xp_percent = 7 }, tooltip = "During configured peak hours, gain +7% loot rarity chance. During off-peak hours, gain +7% experience instead.", upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Tide Gem", bonuses = { socket_tide_loot_percent = 8, socket_tide_xp_percent = 8 }, tooltip = "During configured peak hours, gain +8% loot rarity chance. During off-peak hours, gain +8% experience instead.", upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Tide Gem", bonuses = { socket_tide_loot_percent = 10, socket_tide_xp_percent = 10 }, tooltip = "During configured peak hours, gain +10% loot rarity chance. During off-peak hours, gain +10% experience instead.", upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Tide Gem", bonuses = { socket_tide_loot_percent = 12, socket_tide_xp_percent = 12 }, storage = 980141, storageValue = 1, tooltip = "During configured peak hours, gain +12% loot rarity chance. During off-peak hours, gain +12% experience instead." }
        },
    },
    -- 197 --
    waystoneconquerorgem = {
        itemId = 30860,
        name = "Waystone Conqueror Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        storage = 980132,
        storageValue = 1,
        slots = { "helmet", "armor", "legs", "boots", "gloves", "belt", "ring", "necklace", "shield", "weapon", "wand" },
        bestFor = { "Waystone Hunters", "Boss Hunters" },
        style = "Waystone Conquest",
        bonuses = {
            socket_waystone_cooldown_reduction_per_map = 2,
            socket_waystone_max_maps = 12,
            socket_waystone_max_cooldown_reduction = 24,
        },
        tooltip = "Defeat each of the 12 Waystone map bosses while equipped. Every unique map conquered permanently reduces all Waystone boss entry cooldowns by 2%, up to 24%.\nDetails: Cooldown Reduction Per Map: 2s, Max Maps: 12, Max Cooldown Reduction: 24s",
    },
    -- 198 --
    ambushgem = {
        itemId = 30861,
        name = "Ambush Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "weapon", "wand", "ring", "necklace", "belt" },
        bestFor = { "Risk Hunters", "Fast Farmers", "Event Builds" },
        style = "Kill-Spawn Ambush",
        bonuses = {
            socket_ambush_chance = 1,
            socket_ambush_cooldown = 45,
            socket_ambush_count = 2,
            socket_ambush_lifetime = 45,
            socket_ambush_level_bonus = 2,
            socket_ambush_reward_gold_min = 1,
            socket_ambush_reward_gold_max = 2,
            socket_ambush_reward_gempower_chance = 5,
            socket_ambush_reward_gempower_count = 1,
        },
        tooltip = "After killing a monster, has a chance to spawn a temporary ambush pack nearby. Ambush kills can reward gold or Gem Power.\nDetails: Chance: 1%, Cooldown: 45s, Count: 2, Lifetime: 45s, Level Bonus: 2, Reward Crystal Min: 1, Reward Crystal Max: 2, Reward Gempower Chance: 5%, Reward Gempower Count: 1",
        tiers = {
            [1] = { name = "Small Ambush Gem", bonuses = { socket_ambush_chance = 2, socket_ambush_cooldown = 45, socket_ambush_count = 2, socket_ambush_lifetime = 45, socket_ambush_level_bonus = 2, socket_ambush_reward_gold_min = 1, socket_ambush_reward_gold_max = 2, socket_ambush_reward_gempower_chance = 5, socket_ambush_reward_gempower_count = 1 }, tooltip = "After killing a monster, has a chance to spawn a temporary ambush pack nearby. Ambush kills can reward gold or Gem Power.\nDetails: Chance: 2%, Cooldown: 45s, Count: 2, Lifetime: 45s, Level Bonus: 2,  Reward Crystal Min: 1, Reward Crystal Max: 2, Reward Gempower Chance: 5%, Reward Gempower Count: 1" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Ambush Gem", bonuses = { socket_ambush_chance = 3, socket_ambush_cooldown = 45, socket_ambush_count = 2, socket_ambush_lifetime = 45, socket_ambush_level_bonus = 4, socket_ambush_reward_gold_min = 2, socket_ambush_reward_gold_max = 5, socket_ambush_reward_gempower_chance = 10, socket_ambush_reward_gempower_count = 1 }, tooltip = "After killing a monster, has a chance to spawn a temporary ambush pack nearby. Ambush kills can reward gold or Gem Power.\nDetails: Chance: 3%, Cooldown: 45s, Count: 2, Lifetime: 45s, Level Bonus: 4,  Reward Crystal Min: 2, Reward Crystal Max: 5, Reward Gempower Chance: 10%, Reward Gempower Count: 1" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Ambush Gem", bonuses = { socket_ambush_chance = 4, socket_ambush_cooldown = 40, socket_ambush_count = 3, socket_ambush_lifetime = 45, socket_ambush_level_bonus = 6, socket_ambush_reward_gold_min = 3, socket_ambush_reward_gold_max = 7, socket_ambush_reward_gempower_chance = 15, socket_ambush_reward_gempower_count = 1 }, storage = 980126 , storageValue = 1, tooltip = "After killing a monster, has a chance to spawn a temporary ambush pack nearby. Ambush kills can reward gold or Gem Power.\nDetails: Chance: 4%, Cooldown: 40s, Count: 3, Lifetime: 45s, Level Bonus: 6,  Reward Crystal Min: 3, Reward Crystal Max: 7, Reward Gempower Chance: 15%, Reward Gempower Count: 1" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Ambush Gem", bonuses = { socket_ambush_chance = 5, socket_ambush_cooldown = 40, socket_ambush_count = 3, socket_ambush_lifetime = 50, socket_ambush_level_bonus = 8, socket_ambush_reward_gold_min = 4, socket_ambush_reward_gold_max = 10, socket_ambush_reward_gempower_chance = 20, socket_ambush_reward_gempower_count = 2 }, tooltip = "After killing a monster, has a chance to spawn a temporary ambush pack nearby. Ambush kills can reward gold or Gem Power.\nDetails: Chance: 5%, Cooldown: 40s, Count: 3, Lifetime: 50s, Level Bonus: 8,  Reward Crystal Min: 4, Reward Crystal Max: 10, Reward Gempower Chance: 20%, Reward Gempower Count: 2" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Ambush Gem", bonuses = { socket_ambush_chance = 7, socket_ambush_cooldown = 35, socket_ambush_count = 4, socket_ambush_lifetime = 50, socket_ambush_level_bonus = 10, socket_ambush_reward_gold_min = 7, socket_ambush_reward_gold_max = 15, socket_ambush_reward_gempower_chance = 30, socket_ambush_reward_gempower_count = 2 }, tooltip = "After killing a monster, has a chance to spawn a temporary ambush pack nearby. Ambush kills can reward gold or Gem Power.\nDetails: Chance: 30%, Cooldown: 35s, Count: 4, Lifetime: 50s, Level Bonus: 10,  Reward Crystal Min: 7, Reward Crystal Max: 15, Reward Gempower Chance: 7%, Reward Gempower Count: 2" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Ambush Gem", bonuses = { socket_ambush_chance = 10, socket_ambush_cooldown = 30, socket_ambush_count = 4, socket_ambush_lifetime = 60, socket_ambush_level_bonus = 15, socket_ambush_reward_gold_min = 10, socket_ambush_reward_gold_max = 20, socket_ambush_reward_gempower_chance = 50, socket_ambush_reward_gempower_count = 3 }, storage = 980127, storageValue = 1, tooltip = "After killing a monster, has a chance to spawn a temporary ambush pack nearby. Ambush kills can reward gold or Gem Power.\nDetails: Chance: 10%, Cooldown: 30s, Count: 4, Lifetime: 60s, Level Bonus: 15,  Reward Crystal Min: 10, Reward Crystal Max: 20, Reward Gempower Chance: 50%, Reward Gempower Count: 3" }
        },
    },
    -- 199 --
    treasureechogem = {
        itemId = 30862,
        name = "Treasure Echo Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "ring", "necklace", "belt", "gloves" },
        bestFor = { "Gold Farmers", "Material Farmers", "Long Hunts" },
        style = "Temporary Kill Chest",
        bonuses = {
            socket_treasure_echo_chance = 1,
            socket_treasure_echo_cooldown = 60,
            socket_treasure_echo_lifetime = 30,
            socket_treasure_echo_gold_min = 50,
            socket_treasure_echo_gold_max = 100,
            socket_treasure_echo_material_chance = 15,
            socket_treasure_echo_material_count = 1,
            socket_treasure_echo_gempower_chance = 8,
            socket_treasure_echo_gempower_count = 1,
        },
        tooltip = "Monster kills can spawn a temporary treasure chest beside the corpse. The chest lasts 30s and contains gold, materials, or Gem Power.\nDetails: Chance: 1%, Cooldown: 60s, Lifetime: 30s, Gold Min: 50, Gold Max: 100, Material Chance: 15%, Material Count: 1, Gempower Chance: 8%, Gempower Count: 1",
        tiers = {
            [1] = { name = "Small Treasure Echo Gem", bonuses = { socket_treasure_echo_chance = 2, socket_treasure_echo_cooldown = 60, socket_treasure_echo_lifetime = 30, socket_treasure_echo_gold_min = 50, socket_treasure_echo_gold_max = 100, socket_treasure_echo_material_chance = 2, socket_treasure_echo_material_count = 1, socket_treasure_echo_gempower_chance = 2, socket_treasure_echo_gempower_count = 1 }, storage = 980111, storageValue = 1, tooltip = "Monster kills can spawn a temporary treasure chest beside the corpse. The chest lasts 30s and contains gold, materials, or Gem Power.\nDetails: Chance: 2%, Cooldown: 60s, Lifetime: 30s, Gold Min: 50, Gold Max: 100, Material Chance: 2%, Material Count: 1, Gempower Chance: 2%, Gempower Count: 1" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Treasure Echo Gem", bonuses = { socket_treasure_echo_chance = 3, socket_treasure_echo_cooldown = 60, socket_treasure_echo_lifetime = 30, socket_treasure_echo_gold_min = 60, socket_treasure_echo_gold_max = 120, socket_treasure_echo_material_chance = 3, socket_treasure_echo_material_count = 1, socket_treasure_echo_gempower_chance = 3, socket_treasure_echo_gempower_count = 1 }, tooltip = "Monster kills can spawn a temporary treasure chest beside the corpse. The chest lasts 30s and contains gold, materials, or Gem Power.\nDetails: Chance: 3%, Cooldown: 60s, Lifetime: 30s, Gold Min: 60, Gold Max: 120, Material Chance: 3%, Material Count: 1, Gempower Chance: 3%, Gempower Count: 1" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Treasure Echo Gem", bonuses = { socket_treasure_echo_chance = 4, socket_treasure_echo_cooldown = 55, socket_treasure_echo_lifetime = 30, socket_treasure_echo_gold_min = 70, socket_treasure_echo_gold_max = 150, socket_treasure_echo_material_chance = 4, socket_treasure_echo_material_count = 1, socket_treasure_echo_gempower_chance = 4, socket_treasure_echo_gempower_count = 1 }, storage = 980112, storageValue = 1, tooltip = "Monster kills can spawn a temporary treasure chest beside the corpse. The chest lasts 30s and contains gold, materials, or Gem Power.\nDetails: Chance: 4%, Cooldown: 55s, Lifetime: 30s, Gold Min: 70, Gold Max: 150, Material Chance: 4%, Material Count: 1, Gempower Chance: 4%, Gempower Count: 1" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Treasure Echo Gem", bonuses = { socket_treasure_echo_chance = 5, socket_treasure_echo_cooldown = 50, socket_treasure_echo_lifetime = 30, socket_treasure_echo_gold_min = 80, socket_treasure_echo_gold_max = 170, socket_treasure_echo_material_chance = 5, socket_treasure_echo_material_count = 2, socket_treasure_echo_gempower_chance = 5, socket_treasure_echo_gempower_count = 2 }, tooltip = "Monster kills can spawn a temporary treasure chest beside the corpse. The chest lasts 30s and contains gold, materials, or Gem Power.\nDetails: Chance: 5%, Cooldown: 50s, Lifetime: 30s, Gold Min: 80, Gold Max: 170, Material Chance: 5%, Material Count: 2, Gempower Chance: 5%, Gempower Count: 2" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Treasure Echo Gem", bonuses = { socket_treasure_echo_chance = 7, socket_treasure_echo_cooldown = 45, socket_treasure_echo_lifetime = 30, socket_treasure_echo_gold_min = 120, socket_treasure_echo_gold_max = 250, socket_treasure_echo_material_chance = 7, socket_treasure_echo_material_count = 2, socket_treasure_echo_gempower_chance = 7, socket_treasure_echo_gempower_count = 2 }, tooltip = "Monster kills can spawn a temporary treasure chest beside the corpse. The chest lasts 30s and contains gold, materials, or Gem Power.\nDetails: Chance: 7%, Cooldown: 45s, Lifetime: 30s, Gold Min: 120, Gold Max: 250, Material Chance: 7%, Material Count: 2, Gempower Chance: 7%, Gempower Count: 2" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Treasure Echo Gem", bonuses = { socket_treasure_echo_chance = 10, socket_treasure_echo_cooldown = 40, socket_treasure_echo_lifetime = 30, socket_treasure_echo_gold_min = 200, socket_treasure_echo_gold_max = 400, socket_treasure_echo_material_chance = 10, socket_treasure_echo_material_count = 3, socket_treasure_echo_gempower_chance = 10, socket_treasure_echo_gempower_count = 3 }, storage = 980113, storageValue = 1, tooltip = "Monster kills can spawn a temporary treasure chest beside the corpse. The chest lasts 30s and contains gold, materials, or Gem Power.\nDetails: Chance: 10%, Cooldown: 40s, Lifetime: 30s, Gold Min: 200, Gold Max: 400, Material Chance: 10%, Gempower Chance: 10%, Gempower Count: 3" }
        },
    },
    -- 200 --
    luckyhourglassgem = {
        itemId = 30863,
        name = "Lucky Hourglass Gem",
        uniquePerItem = true,
        uniqueEquipped = true,
        slots = { "ring", "necklace", "belt", "gloves" },
        bestFor = { "Risk Builds", "Gold Farmers", "Spellcasters" },
        style = "Rotating Fortune",
        bonuses = {
            socket_lucky_hourglass_interval = 180,
            socket_lucky_hourglass_duration = 60,
            socket_lucky_hourglass_gold_multiplier = 1,
            socket_lucky_hourglass_cooldown_reduction_percent = 2,
            socket_lucky_hourglass_monster_level_bonus = 2,
            socket_lucky_hourglass_healing_penalty_percent = 5,
        },
        tooltip = "Every few minutes, rolls one personal modifier: extra gold, faster attack spell cooldowns, empowered nearby monsters, or reduced healing.\nDetails: Interval: 180s, Duration: 60s, Gold Multiplier: x1, Cooldown Reduction Percent: 2, Monster Level Bonus: 2, Healing Penalty Percent: 5%",
        tiers = {
            [1] = { name = "Small Lucky Hourglass Gem", bonuses = { socket_lucky_hourglass_interval = 180, socket_lucky_hourglass_duration = 45, socket_lucky_hourglass_gold_multiplier = 0.5, socket_lucky_hourglass_cooldown_reduction_percent = 2, socket_lucky_hourglass_monster_level_bonus = 2, socket_lucky_hourglass_healing_penalty_percent = 5 }, tooltip = "Every few minutes, rolls one personal modifier: extra gold, faster attack spell cooldowns, empowered nearby monsters, or reduced healing.\nDetails: Interval: 180s, Duration: 45s, Gold Multiplier: x0.5, Cooldown Reduction Percent: 2, Monster Level Bonus: 2, Healing Penalty Percent: 5%" , upgrade = {items = {{ id = 30658, count = 10 }}}  },
            [2] = { name = "Lesser Lucky Hourglass Gem", bonuses = { socket_lucky_hourglass_interval = 180, socket_lucky_hourglass_duration = 50, socket_lucky_hourglass_gold_multiplier = 0.75, socket_lucky_hourglass_cooldown_reduction_percent = 3, socket_lucky_hourglass_monster_level_bonus = 3, socket_lucky_hourglass_healing_penalty_percent = 6 }, tooltip = "Every few minutes, rolls one personal modifier: extra gold, faster attack spell cooldowns, empowered nearby monsters, or reduced healing.\nDetails: Interval: 180s, Duration: 50s, Gold Multiplier: x0.75, Cooldown Reduction Percent: 3, Monster Level Bonus: 3, Healing Penalty Percent: 6%" , upgrade = {items = {{ id = 30658, count = 25 }}}  },
            [3] = { name = "Greater Lucky Hourglass Gem", bonuses = { socket_lucky_hourglass_interval = 180, socket_lucky_hourglass_duration = 55, socket_lucky_hourglass_gold_multiplier = 1.0, socket_lucky_hourglass_cooldown_reduction_percent = 5, socket_lucky_hourglass_monster_level_bonus = 4, socket_lucky_hourglass_healing_penalty_percent = 7 }, tooltip = "Every few minutes, rolls one personal modifier: extra gold, faster attack spell cooldowns, empowered nearby monsters, or reduced healing.\nDetails: Interval: 180s, Duration: 55s, Gold Multiplier: x1, Cooldown Reduction Percent: 5, Monster Level Bonus: 4, Healing Penalty Percent: 7%" , upgrade = {items = {{ id = 30658, count = 50 }}}  },
            [4] = { name = "Super Lucky Hourglass Gem", bonuses = { socket_lucky_hourglass_interval = 180, socket_lucky_hourglass_duration = 60, socket_lucky_hourglass_gold_multiplier = 1.25, socket_lucky_hourglass_cooldown_reduction_percent = 7, socket_lucky_hourglass_monster_level_bonus = 5, socket_lucky_hourglass_healing_penalty_percent = 8 }, tooltip = "Every few minutes, rolls one personal modifier: extra gold, faster attack spell cooldowns, empowered nearby monsters, or reduced healing.\nDetails: Interval: 180s, Duration: 60s, Gold Multiplier: x1.25, Cooldown Reduction Percent: 7, Monster Level Bonus: 5, Healing Penalty Percent: 8%" , upgrade = {items = {{ id = 30658, count = 100 }}}  },
            [5] = { name = "Mega Lucky Hourglass Gem", bonuses = { socket_lucky_hourglass_interval = 180, socket_lucky_hourglass_duration = 70, socket_lucky_hourglass_gold_multiplier = 1.5, socket_lucky_hourglass_cooldown_reduction_percent = 10, socket_lucky_hourglass_monster_level_bonus = 6, socket_lucky_hourglass_healing_penalty_percent = 9 }, tooltip = "Every few minutes, rolls one personal modifier: extra gold, faster attack spell cooldowns, empowered nearby monsters, or reduced healing.\nDetails: Interval: 180s, Duration: 70s, Gold Multiplier: x1.5, Cooldown Reduction Percent: 10, Monster Level Bonus: 6, Healing Penalty Percent: 9%" , upgrade = {items = {{ id = 30658, count = 150 }}}  },
            [6] = { name = "Abyssal Lucky Hourglass Gem", bonuses = { socket_lucky_hourglass_interval = 180, socket_lucky_hourglass_duration = 80, socket_lucky_hourglass_gold_multiplier = 2.0, socket_lucky_hourglass_cooldown_reduction_percent = 12, socket_lucky_hourglass_monster_level_bonus = 8, socket_lucky_hourglass_healing_penalty_percent = 10 }, tooltip = "Every few minutes, rolls one personal modifier: extra gold, faster attack spell cooldowns, empowered nearby monsters, or reduced healing.\nDetails: Interval: 180s, Duration: 80s, Gold Multiplier: x2, Cooldown Reduction Percent: 12, Monster Level Bonus: 8, Healing Penalty Percent: 10%" }
        },
    },

}



local function cloneTable(value)
    if type(value) ~= "table" then
        return value
    end

    local copied = {}
    for key, nestedValue in pairs(value) do
        copied[key] = cloneTable(nestedValue)
    end
    return copied
end

local function applyMetadataDefaults(gemData)
    if type(gemData) ~= "table" then
        return
    end

    if type(gemData.bestFor) ~= "table" then
        gemData.bestFor = { "Any Vocation" }
    end

    if type(gemData.style) ~= "string" or gemData.style == "" then
        gemData.style = "Hybrid"
    end

    if type(gemData.tiers) == "table" then
        for _, tierData in pairs(gemData.tiers) do
            if type(tierData) == "table" then
                if type(tierData.bestFor) ~= "table" then
                    tierData.bestFor = cloneTable(gemData.bestFor)
                end
                if type(tierData.style) ~= "string" or tierData.style == "" then
                    tierData.style = gemData.style
                end
            end
        end
    end
end

for _, gemData in pairs(GemsSocket.GEMS) do
    applyMetadataDefaults(gemData)
end

function GemsSocket_isEnabled()
    return GemsSocket ~= nil and GemsSocket.ENABLED ~= false
end

if type(_G.GemsSocket_registerAmplifierGem) == "function" then
    _G.GemsSocket_registerAmplifierGem()
end


