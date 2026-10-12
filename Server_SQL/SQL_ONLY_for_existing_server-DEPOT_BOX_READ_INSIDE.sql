--- If you have already a server started, this SQL will add DEPOT BOXES to all existing players in game.
--- You can get some duplicateds if you have added the SQL on website and a new user has been created ( it's normal )
--- Execute this SQL to add 21 Depot Boxes inside the depot to every existing player, for new ones, website will create it automatically on each character.


INSERT IGNORE INTO `player_depotitems`
  (`player_id`,`pid`,`sid`,`itemtype`,`count`,`attributes`)
SELECT
  p.`id`                          AS player_id,
  t.`town_id`                     AS pid,
  (t.`town_id` * 100) + b.`sid`   AS sid,
  b.`itemtype`                    AS itemtype,
  1                               AS count,
  ''                              AS attributes
FROM
  `players` AS p
CROSS JOIN (
  SELECT  0 AS sid, 25453 AS itemtype UNION ALL
  SELECT  1,        25454       UNION ALL
  SELECT  2,        25455       UNION ALL
  SELECT  3,        25456       UNION ALL
  SELECT  4,        25457       UNION ALL
  SELECT  5,        25458       UNION ALL
  SELECT  6,        25459       UNION ALL
  SELECT  7,        25460       UNION ALL
  SELECT  8,        25461       UNION ALL
  SELECT  9,        25462       UNION ALL
  SELECT 10,        25463       UNION ALL
  SELECT 11,        25464       UNION ALL
  SELECT 12,        25465       UNION ALL
  SELECT 13,        25466       UNION ALL
  SELECT 14,        25467       UNION ALL
  SELECT 15,        25468       UNION ALL
  SELECT 16,        25469       UNION ALL
  SELECT 17,        29841       UNION ALL
  SELECT 18,        29842       UNION ALL
  SELECT 19,        29843       UNION ALL
  SELECT 20,        29844
) AS b
CROSS JOIN (
  SELECT  1 AS town_id UNION ALL
  SELECT  2 UNION ALL
  SELECT  3 UNION ALL
  SELECT  4 UNION ALL
  SELECT  5 UNION ALL
  SELECT  6 UNION ALL
  SELECT  7 UNION ALL
  SELECT  8 UNION ALL
  SELECT  9 UNION ALL
  SELECT 10 UNION ALL
  SELECT 11 UNION ALL
  SELECT 12 UNION ALL
  SELECT 13 UNION ALL
  SELECT 14 UNION ALL
  SELECT 28 UNION ALL
  SELECT 29 UNION ALL
  SELECT 31 UNION ALL
  SELECT 32 UNION ALL
  SELECT 33 UNION ALL
  SELECT 34
) AS t
;
