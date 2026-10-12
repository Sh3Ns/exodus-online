local creatureevent = CreatureEvent("SincOutfit")

-- Sync outfits that player own with Znote AAC
-- So its possible to see which full sets player
-- has in characterprofile.php

znote_outfit_list = {
	{ -- Female outfits
		136, 137, 138, 139, 140, 141, 142, 147, 148,
		149, 150, 155, 156, 157, 158, 252, 269, 270,
		279, 288, 324, 329, 336, 366, 431, 433, 464,
		466, 471, 513, 514, 542, 575, 578, 618, 620,
		632, 635, 636, 664, 666, 683, 694, 696, 698,
		724, 732, 745, 749, 759, 845, 852, 874, 885,
		900, 910, 912, 914, 916, 918, 920, 922, 924, 926,
		971, 973, 985, 998, 1000, 1015, 1017, 1038, 1065, 
		1067, 1189, 1199, 1200, 1201, 1202, 1203, 1204, 1205,
		1207, 1208, 1210, 1212, 1214, 1216, 1218, 1220, 1229,
		1238, 1241, 1243, 1245, 1247, 1249, 1251, 1253, 1263, 1300,
		1372, 1456, 1458, 1465
	},
	{ -- Male outfits
		128, 129, 130, 131, 132, 133, 134, 143, 144,
		145, 146, 151, 152, 153, 154, 251, 268, 273,
		278, 289, 325, 328, 335, 367, 430, 432, 463,
		465, 472, 512, 516, 541, 574, 577, 610, 619,
		633, 634, 637, 665, 667, 684, 695, 697, 699,
		725, 733, 746, 750, 760, 846, 853, 873, 884,
		899, 909, 911, 913, 915, 917, 919, 921, 923, 925, 972,
		974, 984, 997, 999, 1014, 1016, 1037, 1064, 1066, 1188,
		1194, 1195, 1196, 1197, 1198, 1206, 1207, 1208, 
		1211, 1213, 1215, 1217, 1219, 1221, 1224, 1228, 1237, 1240,
		1242, 1244, 1246, 1248, 1250, 1252, 1262, 1299, 1373, 1455, 1458, 1464
	}
}

function creatureevent.onLogin(player)
	-- storage_value + 1000 storages (highest outfit id) must not be used in other script.
	-- Must be identical to Znote AAC config.php: $config['EQ_shower'] -> storage_value
	local storage_value = 10000
	-- Loop through outfits
	for _, outfit in pairs(znote_outfit_list[player:getSex() + 1]) do
		if player:hasOutfit(outfit,3) then
			if player:getStorageValue(storage_value + outfit) ~= 3 then
				player:setStorageValue(storage_value + outfit, 3)
			end
		end
	end
	return true
end

creatureevent:register()
