CREATE TABLE `employees` (
  `id` mediumint(8) unsigned NOT NULL auto_increment,
  `first_name` varchar(100) collate utf8_unicode_ci NOT NULL default '',
  `last_name` varchar(100) collate utf8_unicode_ci NOT NULL default '',
  `email` varchar(200) collate utf8_unicode_ci NOT NULL default '',
  `department` varchar(50) collate utf8_unicode_ci NOT NULL default '',
  `hire_date` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=19 ;

--
-- Dumping data for table `employees`
--

INSERT INTO `employees` VALUES(2, 'Sally', 'Jones', 'sallyj@gmail.com', 'Marketing', '2004-10-26 14:19:00');
INSERT INTO `employees` VALUES(11, 'Chris', 'Smith', 'cjones@yahoo.com', 'Sales', '2008-05-07 09:50:27');
INSERT INTO `employees` VALUES(4, 'Jake', 'Johnson', 'jjohn@yahoo.com', 'Accounting', '1998-04-21 14:19:18');
INSERT INTO `employees` VALUES(12, 'Matt', 'Hansen', 'mh2003@gmail.com', 'Marketing', '2006-05-01 17:44:44');
INSERT INTO `employees` VALUES(13, 'Kristy', 'Snow', 'kristymsnow@gmail.com', 'Sales', '2000-01-12 17:45:00');
INSERT INTO `employees` VALUES(14, 'Karen', 'Martensen', 'karenm12@yahoo.com', 'Production', '2001-11-12 17:46:27');
INSERT INTO `employees` VALUES(15, 'Alex', 'Christensen', 'acstud@yahoo.com', 'Accounting', '2006-08-16 17:47:21');
INSERT INTO `employees` VALUES(16, 'Martha', 'Madrid', 'mmadrid@gmail.com', 'Marketing', '2004-09-03 17:52:37');
INSERT INTO `employees` VALUES(17, 'Jeff', 'Miller', 'jmiller90@yahoo.com', 'Marketing', '2007-12-17 18:04:14');


CREATE TABLE `login_info` (
  `id` mediumint(8) unsigned NOT NULL auto_increment,
  `employee_id` mediumint(8) unsigned NOT NULL default '0',
  `login` varchar(100) collate utf8_unicode_ci NOT NULL default '',
  `password` varchar(250) collate utf8_unicode_ci NOT NULL default '',
  `account_type` varchar(25) collate utf8_unicode_ci NOT NULL default 'User',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=14 ;

--
-- Dumping data for table `login_info`
--

INSERT INTO `login_info` VALUES(1, 4, 'jake152', '*55C92198D5AB8BC640B511D086878BC984485934', 'User');
INSERT INTO `login_info` VALUES(2, 2, 'sally343', '*13883BDDBE566ECECC0501CDE9B293303116521A', 'User');
INSERT INTO `login_info` VALUES(9, 17, 'jm2008gm', '*76E25B0C2E827CC0174B92C194694F742FED4169', 'Admin');
INSERT INTO `login_info` VALUES(8, 15, 'alexcwac', '*90314607B4F44EAE3739DDC2FDC40582B8D7100E', 'User');
INSERT INTO `login_info` VALUES(7, 11, 'chris687', '*55C92198D5AB8BC640B511D086878BC984485934', 'User');
INSERT INTO `login_info` VALUES(10, 14, 'martkaren81', '*A989D5EF29215DBA7401D5F5E9332440651FBE8C', 'User');
INSERT INTO `login_info` VALUES(11, 12, 'matt905', '*E33B6370704DC993651A9377C9BC2445E0D31359', 'Admin');
INSERT INTO `login_info` VALUES(12, 13, 'snow1998', '*5BAB9EF622391FCDD75DAA2615D54B39B5CC4FE6', 'Admin');
INSERT INTO `login_info` VALUES(13, 16, 'mmadrid', '*5347F5CDA963F661E67EC239E4C225DC2CD05E4F', 'User');

--
-- Create this table in your database if you want to use show/hide columns or order columns.
--
CREATE TABLE IF NOT EXISTS `mate_columns` (
  `id` mediumint(8) unsigned NOT NULL auto_increment,
  `mate_user_id` varchar(75) collate utf8_unicode_ci NOT NULL,
  `mate_var_prefix` varchar(100) collate utf8_unicode_ci NOT NULL,
  `mate_column` varchar(75) collate utf8_unicode_ci NOT NULL,
  `hidden` varchar(3) collate utf8_unicode_ci NOT NULL default 'No',
  `order_num` mediumint(4) unsigned NOT NULL,
  `date_updated` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `mate_user_id` (`mate_user_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1;
