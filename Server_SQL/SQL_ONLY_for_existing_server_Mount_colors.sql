ALTER TABLE `players`
  ADD COLUMN `lookmounthead` int NOT NULL DEFAULT '0' AFTER `looklegs`,
  ADD COLUMN `lookmountbody` int NOT NULL DEFAULT '0' AFTER `lookmounthead`,
  ADD COLUMN `lookmountlegs` int NOT NULL DEFAULT '0' AFTER `lookmountbody`,
  ADD COLUMN `lookmountfeet` int NOT NULL DEFAULT '0' AFTER `lookmountlegs`;
