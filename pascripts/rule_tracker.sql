CREATE TABLE `rule_tracker` (
	`id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT,
	`bgroup` VARCHAR(40) NOT NULL DEFAULT '' COLLATE 'utf8_unicode_ci',
	`requestor` VARCHAR(80) NOT NULL DEFAULT '' COLLATE 'utf8_unicode_ci',
	`push_date` VARCHAR(40) NOT NULL DEFAULT '' COLLATE 'utf8_unicode_ci',
	`reference` VARCHAR(40) NOT NULL DEFAULT '' COLLATE 'utf8_unicode_ci',
	`bapp` VARCHAR(80) NOT NULL DEFAULT '' COLLATE 'utf8_unicode_ci',
	`breason` TEXT NOT NULL COLLATE 'utf8_unicode_ci',
	`notes` TEXT NOT NULL COLLATE 'utf8_unicode_ci',
	`internet` INT(10) UNSIGNED NULL DEFAULT NULL,
	`global` INT(10) UNSIGNED NULL DEFAULT NULL,
	`management` INT(10) UNSIGNED NULL DEFAULT NULL,
	`db` INT(10) UNSIGNED NULL DEFAULT NULL,
	`files` INT(10) UNSIGNED NULL DEFAULT NULL,
	`rule_numbers` VARCHAR(500) NOT NULL DEFAULT '' COLLATE 'utf8_unicode_ci',
	`firewall` VARCHAR(60) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
	PRIMARY KEY (`id`)
)
COLLATE='utf8_unicode_ci'
ENGINE=MyISAM
AUTO_INCREMENT=1009
;
