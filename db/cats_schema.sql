-- phpMyAdmin SQL Dump
-- version 4.0.10.1
-- http://www.phpmyadmin.net
--
-- Host: 74.208.69.196
-- Generation Time: Jun 30, 2016 at 10:25 AM
-- Server version: 5.5.49-37.9-log
-- PHP Version: 5.5.37-1+deprecated+dontuse+deb.sury.org~trusty+1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Table structure for table `access_level`
--

DROP TABLE IF EXISTS `access_level`;
CREATE TABLE IF NOT EXISTS `access_level` (
  `access_level_id` int(11) NOT NULL DEFAULT '0',
  `short_description` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `long_description` text COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`access_level_id`),
  KEY `IDX_access_level` (`short_description`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `access_level`
--

INSERT INTO `access_level` (`access_level_id`, `short_description`, `long_description`) VALUES
(0, 'Account Disabled', 'Disabled - The lowest access level. User cannot log in.'),
(100, 'Read Only', 'Read Only - A standard user that can view data on the system in a read-only mode.'),
(200, 'Add / Edit', 'Edit - All lower access, plus the ability to edit information on the system.'),
(300, 'Add / Edit / Delete', 'Delete - All lower access, plus the ability to delete information on the system.'),
(400, 'Site Administrator', 'Site Administrator - All lower access, plus the ability to add, edit, and remove site users, as well as the ability to edit site settings.'),
(500, 'Root', 'Root Administrator - All lower access, plus the ability to add, edit, and remove sites, as well as the ability to assign Site Administrator status to a user.');

-- --------------------------------------------------------

--
-- Table structure for table `activity`
--

DROP TABLE IF EXISTS `activity`;
CREATE TABLE IF NOT EXISTS `activity` (
  `activity_id` int(11) NOT NULL AUTO_INCREMENT,
  `data_item_id` int(11) NOT NULL DEFAULT '0',
  `data_item_type` int(11) NOT NULL DEFAULT '0',
  `joborder_id` int(11) DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `entered_by` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `type` int(11) NOT NULL DEFAULT '0',
  `notes` text COLLATE utf8_unicode_ci,
  `date_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`activity_id`),
  KEY `IDX_entered_by` (`entered_by`),
  KEY `IDX_site_id` (`site_id`),
  KEY `IDX_type` (`type`),
  KEY `IDX_data_item_type` (`data_item_type`),
  KEY `IDX_type_id` (`data_item_type`,`data_item_id`),
  KEY `IDX_joborder_id` (`joborder_id`),
  KEY `IDX_date_created` (`date_created`),
  KEY `IDX_date_modified` (`date_modified`),
  KEY `IDX_data_item_id_type_site` (`site_id`,`data_item_id`,`data_item_type`),
  KEY `IDX_site_created` (`site_id`,`date_created`),
  KEY `IDX_activity_site_type_created_job` (`site_id`,`data_item_type`,`date_created`,`entered_by`,`joborder_id`),
  KEY `IDX_data_item_id` (`data_item_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `activity_type`
--

DROP TABLE IF EXISTS `activity_type`;
CREATE TABLE IF NOT EXISTS `activity_type` (
  `activity_type_id` int(11) NOT NULL DEFAULT '0',
  `short_description` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`activity_type_id`),
  KEY `IDX_activity_type1` (`short_description`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `activity_type`
--

INSERT INTO `activity_type` (`activity_type_id`, `short_description`) VALUES
(100, 'Call'),
(200, 'Email'),
(300, 'Meeting'),
(400, 'Other'),
(500, 'Call (Talked)'),
(600, 'Call (LVM)'),
(700, 'Call (Missed)');

-- --------------------------------------------------------

--
-- Table structure for table `admin_user`
--

DROP TABLE IF EXISTS `admin_user`;
CREATE TABLE IF NOT EXISTS `admin_user` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(40) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `password` varchar(10) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `disabled` int(1) NOT NULL DEFAULT '0',
  `can_change_password` int(1) NOT NULL DEFAULT '1',
  `last_name` varchar(40) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `first_name` varchar(40) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`user_id`),
  KEY `IDX_first_name` (`first_name`),
  KEY `IDX_last_name` (`last_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `admin_user_login`
--

DROP TABLE IF EXISTS `admin_user_login`;
CREATE TABLE IF NOT EXISTS `admin_user_login` (
  `user_login_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0',
  `ip` varchar(128) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `user_agent` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `successful` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_login_id`),
  KEY `IDX_user_id` (`user_id`),
  KEY `IDX_ip` (`ip`),
  KEY `IDX_date` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `attachment`
--

DROP TABLE IF EXISTS `attachment`;
CREATE TABLE IF NOT EXISTS `attachment` (
  `attachment_id` int(11) NOT NULL AUTO_INCREMENT,
  `data_item_id` int(11) NOT NULL DEFAULT '0',
  `data_item_type` int(11) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL DEFAULT '0',
  `title` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `original_filename` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `stored_filename` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `content_type` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `resume` int(1) NOT NULL DEFAULT '0',
  `text` text COLLATE utf8_unicode_ci,
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `profile_image` int(1) DEFAULT '0',
  `md5_sum` varchar(40) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `file_size_kb` int(11) DEFAULT '0',
  `md5_sum_text` varchar(40) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `directory_name` varchar(40) COLLATE utf8_unicode_ci DEFAULT '0',
  PRIMARY KEY (`attachment_id`),
  KEY `IDX_type_id` (`data_item_type`,`data_item_id`),
  KEY `IDX_data_item_id` (`data_item_id`),
  KEY `IDX_CANDIDATE_MD5_SUM` (`md5_sum`),
  KEY `IDX_site_file_size` (`site_id`,`file_size_kb`),
  KEY `IDX_site_file_size_created` (`site_id`,`file_size_kb`,`date_created`),
  FULLTEXT KEY `IDX_text` (`text`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `calendar_event`
--

DROP TABLE IF EXISTS `calendar_event`;
CREATE TABLE IF NOT EXISTS `calendar_event` (
  `calendar_event_id` int(11) NOT NULL AUTO_INCREMENT,
  `type` int(11) NOT NULL DEFAULT '0',
  `date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `all_day` int(1) NOT NULL DEFAULT '0',
  `data_item_id` int(11) NOT NULL DEFAULT '-1',
  `data_item_type` int(11) NOT NULL DEFAULT '-1',
  `entered_by` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `site_id` int(11) NOT NULL DEFAULT '0',
  `joborder_id` int(11) NOT NULL DEFAULT '-1',
  `description` text COLLATE utf8_unicode_ci,
  `duration` int(11) NOT NULL DEFAULT '60',
  `reminder_enabled` int(1) NOT NULL DEFAULT '0',
  `reminder_email` text COLLATE utf8_unicode_ci,
  `reminder_time` int(11) DEFAULT '0',
  `public` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`calendar_event_id`),
  KEY `IDX_site_id_date` (`site_id`,`date`),
  KEY `IDX_site_data_item_type_id` (`site_id`,`data_item_type`,`data_item_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `calendar_event_type`
--

DROP TABLE IF EXISTS `calendar_event_type`;
CREATE TABLE IF NOT EXISTS `calendar_event_type` (
  `calendar_event_type_id` int(11) NOT NULL DEFAULT '0',
  `short_description` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `icon_image` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`calendar_event_type_id`),
  KEY `IDX_short_description` (`short_description`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `calendar_event_type`
--

INSERT INTO `calendar_event_type` (`calendar_event_type_id`, `short_description`, `icon_image`) VALUES
(100, 'Call', 'images/phone.gif'),
(200, 'Email', 'images/email.gif'),
(300, 'Meeting', 'images/meeting.gif'),
(400, 'Interview', 'images/interview.gif'),
(500, 'Personal', 'images/personal.gif'),
(600, 'Other', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `calendar_settings`
--

DROP TABLE IF EXISTS `calendar_settings`;
CREATE TABLE IF NOT EXISTS `calendar_settings` (
  `calendar_settings_id` int(11) NOT NULL AUTO_INCREMENT,
  `setting` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `entered_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`calendar_settings_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `candidate`
--

DROP TABLE IF EXISTS `candidate`;
CREATE TABLE IF NOT EXISTS `candidate` (
  `candidate_id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `last_name` varchar(64) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `first_name` varchar(64) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `middle_name` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone_home` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone_cell` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone_work` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8_unicode_ci,
  `city` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date_available` datetime DEFAULT NULL,
  `can_relocate` int(1) NOT NULL DEFAULT '0',
  `notes` text COLLATE utf8_unicode_ci,
  `key_skills` text COLLATE utf8_unicode_ci,
  `current_employer` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `entered_by` int(11) NOT NULL DEFAULT '0' COMMENT 'Created-by user.',
  `owner` int(11) DEFAULT NULL,
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `email1` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email2` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `web_site` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `import_id` int(11) NOT NULL DEFAULT '0',
  `is_hot` int(1) NOT NULL DEFAULT '0',
  `eeo_ethnic_type_id` int(11) DEFAULT '0',
  `eeo_veteran_type_id` int(11) DEFAULT '0',
  `eeo_disability_status` varchar(5) COLLATE utf8_unicode_ci DEFAULT '',
  `eeo_gender` varchar(5) COLLATE utf8_unicode_ci DEFAULT '',
  `desired_pay` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `current_pay` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_active` int(1) DEFAULT '1',
  `is_admin_hidden` int(1) DEFAULT '0',
  `best_time_to_call` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`candidate_id`),
  KEY `IDX_first_name` (`first_name`),
  KEY `IDX_last_name` (`last_name`),
  KEY `IDX_phone_home` (`phone_home`),
  KEY `IDX_phone_cell` (`phone_cell`),
  KEY `IDX_phone_work` (`phone_work`),
  KEY `IDX_key_skills` (`key_skills`(255)),
  KEY `IDX_entered_by` (`entered_by`),
  KEY `IDX_owner` (`owner`),
  KEY `IDX_date_created` (`date_created`),
  KEY `IDX_date_modified` (`date_modified`),
  KEY `IDX_site_first_last_modified` (`site_id`,`first_name`,`last_name`,`date_modified`),
  KEY `IDX_site_id_email_1_2` (`site_id`,`email1`(8),`email2`(8)),
  KEY `IDX_site_id` (`site_id`),
  KEY `IDX_email1` (`email1`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `candidate_foreign`
--

DROP TABLE IF EXISTS `candidate_foreign`;
CREATE TABLE IF NOT EXISTS `candidate_foreign` (
  `alien_id` int(11) NOT NULL AUTO_INCREMENT,
  `assoc_id` int(11) DEFAULT NULL,
  `field_name` varchar(255) DEFAULT NULL,
  `value` text,
  `import_id` int(11) DEFAULT NULL,
  `site_id` int(11) DEFAULT '0',
  PRIMARY KEY (`alien_id`),
  KEY `assoc_id` (`assoc_id`),
  KEY `IDX_site_id` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `candidate_foreign_settings`
--

DROP TABLE IF EXISTS `candidate_foreign_settings`;
CREATE TABLE IF NOT EXISTS `candidate_foreign_settings` (
  `alien_id` int(11) NOT NULL AUTO_INCREMENT,
  `field_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `import_id` int(11) DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime DEFAULT NULL,
  PRIMARY KEY (`alien_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `candidate_joborder`
--

DROP TABLE IF EXISTS `candidate_joborder`;
CREATE TABLE IF NOT EXISTS `candidate_joborder` (
  `candidate_joborder_id` int(11) NOT NULL AUTO_INCREMENT,
  `candidate_id` int(11) NOT NULL DEFAULT '0',
  `joborder_id` int(11) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  `date_submitted` datetime DEFAULT NULL,
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `rating_value` int(5) DEFAULT NULL,
  `added_by` int(11) DEFAULT NULL,
  `match_value` int(5) DEFAULT NULL,
  PRIMARY KEY (`candidate_joborder_id`),
  KEY `IDX_candidate_id` (`candidate_id`),
  KEY `IDX_site_id` (`site_id`),
  KEY `IDX_date_submitted` (`date_submitted`),
  KEY `IDX_date_created` (`date_created`),
  KEY `IDX_date_modified` (`date_modified`),
  KEY `IDX_status_special` (`site_id`,`status`),
  KEY `IDX_site_joborder` (`site_id`,`joborder_id`),
  KEY `IDX_joborder_id` (`joborder_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `candidate_joborder_status`
--

DROP TABLE IF EXISTS `candidate_joborder_status`;
CREATE TABLE IF NOT EXISTS `candidate_joborder_status` (
  `candidate_joborder_status_id` int(11) NOT NULL DEFAULT '0',
  `short_description` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `can_be_scheduled` int(1) NOT NULL DEFAULT '0',
  `triggers_email` int(1) NOT NULL DEFAULT '1',
  `is_enabled` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`candidate_joborder_status_id`),
  KEY `IDX_short_description` (`short_description`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `candidate_joborder_status`
--

INSERT INTO `candidate_joborder_status` (`candidate_joborder_status_id`, `short_description`, `can_be_scheduled`, `triggers_email`, `is_enabled`) VALUES
(100, 'No Contact', 0, 0, 1),
(200, 'Contacted', 0, 0, 1),
(300, 'Negotiating', 0, 1, 1),
(400, 'Submitted', 0, 1, 1),
(500, 'Interviewing', 0, 1, 1),
(600, 'Offered', 0, 1, 1),
(700, 'Client Declined', 0, 0, 1),
(800, 'Placed', 0, 1, 1),
(0, 'No Status', 0, 0, 1),
(650, 'Not in Consideration', 0, 0, 1),
(250, 'Candidate Responded', 0, 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `candidate_joborder_status_history`
--

DROP TABLE IF EXISTS `candidate_joborder_status_history`;
CREATE TABLE IF NOT EXISTS `candidate_joborder_status_history` (
  `candidate_joborder_status_history_id` int(11) NOT NULL AUTO_INCREMENT,
  `candidate_id` int(11) NOT NULL DEFAULT '0',
  `joborder_id` int(11) NOT NULL DEFAULT '0',
  `date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `status_from` int(11) NOT NULL DEFAULT '0',
  `status_to` int(11) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL,
  PRIMARY KEY (`candidate_joborder_status_history_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `candidate_jobordrer_status_type`
--

DROP TABLE IF EXISTS `candidate_jobordrer_status_type`;
CREATE TABLE IF NOT EXISTS `candidate_jobordrer_status_type` (
  `candidate_status_type_id` int(11) NOT NULL DEFAULT '0',
  `short_description` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `can_be_scheduled` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`candidate_status_type_id`),
  KEY `IDX_short_description` (`short_description`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `candidate_source`
--

DROP TABLE IF EXISTS `candidate_source`;
CREATE TABLE IF NOT EXISTS `candidate_source` (
  `source_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  `date_created` datetime DEFAULT NULL,
  PRIMARY KEY (`source_id`),
  KEY `siteID` (`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `career_portal_questionnaire`
--

DROP TABLE IF EXISTS `career_portal_questionnaire`;
CREATE TABLE IF NOT EXISTS `career_portal_questionnaire` (
  `career_portal_questionnaire_id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL DEFAULT '',
  `site_id` int(11) NOT NULL DEFAULT '0',
  `description` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`career_portal_questionnaire_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `career_portal_questionnaire_answer`
--

DROP TABLE IF EXISTS `career_portal_questionnaire_answer`;
CREATE TABLE IF NOT EXISTS `career_portal_questionnaire_answer` (
  `career_portal_questionnaire_answer_id` int(11) NOT NULL AUTO_INCREMENT,
  `career_portal_questionnaire_question_id` int(11) NOT NULL,
  `career_portal_questionnaire_id` int(11) NOT NULL,
  `text` varchar(255) NOT NULL DEFAULT '',
  `action_source` varchar(128) DEFAULT NULL,
  `action_notes` text,
  `action_is_hot` tinyint(1) DEFAULT '0',
  `action_is_active` tinyint(1) DEFAULT '0',
  `action_can_relocate` tinyint(1) DEFAULT '0',
  `action_key_skills` varchar(255) DEFAULT NULL,
  `position` int(4) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`career_portal_questionnaire_answer_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `career_portal_questionnaire_history`
--

DROP TABLE IF EXISTS `career_portal_questionnaire_history`;
CREATE TABLE IF NOT EXISTS `career_portal_questionnaire_history` (
  `career_portal_questionnaire_history_id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `candidate_id` int(11) NOT NULL DEFAULT '0',
  `question` varchar(255) NOT NULL DEFAULT '',
  `answer` varchar(255) NOT NULL DEFAULT '',
  `questionnaire_title` varchar(255) NOT NULL DEFAULT '',
  `questionnaire_description` varchar(255) NOT NULL DEFAULT '',
  `date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`career_portal_questionnaire_history_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `career_portal_questionnaire_question`
--

DROP TABLE IF EXISTS `career_portal_questionnaire_question`;
CREATE TABLE IF NOT EXISTS `career_portal_questionnaire_question` (
  `career_portal_questionnaire_question_id` int(11) NOT NULL AUTO_INCREMENT,
  `career_portal_questionnaire_id` int(11) NOT NULL,
  `text` varchar(255) NOT NULL DEFAULT '',
  `minimum_length` int(11) DEFAULT NULL,
  `maximum_length` int(11) DEFAULT NULL,
  `required` tinyint(1) NOT NULL DEFAULT '0',
  `position` int(4) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL DEFAULT '0',
  `type` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`career_portal_questionnaire_question_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `career_portal_template`
--

DROP TABLE IF EXISTS `career_portal_template`;
CREATE TABLE IF NOT EXISTS `career_portal_template` (
  `career_portal_template_id` int(11) NOT NULL AUTO_INCREMENT,
  `career_portal_name` varchar(255) DEFAULT NULL,
  `setting` varchar(128) NOT NULL DEFAULT '',
  `value` text,
  PRIMARY KEY (`career_portal_template_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=78 ;

--
-- Dumping data for table `career_portal_template`
--

INSERT INTO `career_portal_template` (`career_portal_template_id`, `career_portal_name`, `setting`, `value`) VALUES
(56, 'Blank Page', 'Left', ''),
(57, 'Blank Page', 'Footer', ''),
(58, 'Blank Page', 'Header', ''),
(59, 'Blank Page', 'Content - Main', ''),
(60, 'Blank Page', 'CSS', ''),
(61, 'Blank Page', 'Content - Search Results', ''),
(62, 'Blank Page', 'Content - Questionnaire', ''),
(63, 'Blank Page', 'Content - Job Details', ''),
(64, 'Blank Page', 'Content - Thanks for your Submission', ''),
(65, 'Blank Page', 'Content - Apply for Position', ''),
(66, 'CATS 2.0', 'Left', ''),
(67, 'CATS 2.0', 'Footer', '</div>'),
(68, 'CATS 2.0', 'Header', '<div id="container">\r\n	<div id="logo"><img src="images/careers_cats.gif" alt="IMAGE: CATS Applicant Tracking System Careers Page" /></div>\r\n    <div id="actions">\r\n    	<h2>Shortcuts:</h2>\r\n        <a href="index.php" onmouseover="buttonMouseOver(''returnToMain'',true);" onmouseout="buttonMouseOver(''returnToMain'',false);"><img src="images/careers_return.gif" id="returnToMain" alt="IMAGE: Return to Main" /></a>\r\n<a href="<rssURL>" onmouseover="buttonMouseOver(''rssFeed'',true);" onmouseout="buttonMouseOver(''rssFeed'',false);"><img src="images/careers_rss.gif" id="rssFeed" alt="IMAGE: RSS Feed" /></a>\r\n        <a href="index.php?m=careers&p=showAll" onmouseover="buttonMouseOver(''showAllJobs'',true);" onmouseout="buttonMouseOver(''showAllJobs'',false);"><img src="images/careers_show.gif" id="showAllJobs" alt="IMAGE: Show All Jobs" /></a>\r\n    </div>'),
(69, 'CATS 2.0', 'Content - Main', '<div id="careerContent">\r\n        <registeredCandidate>\r\n        <h1>Available Openings at <siteName></h1>\r\n        <div id="descriptive">\r\n               <p>Change your life today by becoming an integral part of our winning team.</p>\r\n               <p>If you are interested, we invite you to view the <a href="index.php?m=careers&p=showAll">current opening positions</a> at our company.</p><br /><br /><registeredLoginTitle><h1 style="padding:0;margin:0;border:0">Have you applied with us before?</h1></registeredLoginTitle><registeredLogin>\r\n        </div>\r\n        <div id="detailsTools">\r\n        	<h2>Perform an action:</h2>\r\n        	<ul>\r\n                    <li><a href="">Visit our website</a></li>\r\n                </ul>\r\n        </div>\r\n</div>'),
(70, 'CATS 2.0', 'CSS', 'table.sortable\r\n{\r\ntext-align:left;\r\nempty-cells: show;\r\nwidth: 940px;\r\n}\r\ntd\r\n{\r\npadding:5px;\r\n}\r\ntr.rowHeading\r\n{\r\n background: #e0e0e0; border: 1px solid #cccccc; border-left: none; border-right: none;\r\n}\r\ntr.oddTableRow\r\n{\r\nbackground: #ebebeb; \r\n}\r\ntr.evenTableRow\r\n{\r\n background: #ffffff; \r\n}\r\na.sortheader:hover,\r\na.sortheader:link,\r\na.sortheader:visited\r\n{\r\ncolor:#000;\r\n}\r\n\r\nbody, html { margin: 0; padding: 0; background: #ffffff; font: normal 12px/14px Arial, Helvetica, sans-serif; color: #000000; }\r\n#container { margin: 0 auto; padding: 0; width: 940px; height: auto; }\r\n#logo { float: left; margin: 0; }\r\n	#logo img { width: 424px; height: 103px; }\r\n#actions { float: right; margin: 0; width: 310px; height: 100px; background: #efefef; border: 1px solid #cccccc; }\r\n	#actions img { float: left; margin: 2px 6px 2px 15px; width: 130px; height: 25px; }\r\n#footer { clear: both; margin: 20px auto 0 auto; width: 150px; }\r\n	#footer img { width: 137px; height: 38px; }\r\n\r\na:link, a:active { color: #1763b9; }\r\na:hover { color: #c75a01; }\r\na:visited { color: #333333; }\r\nimg { border: none; }\r\n\r\nh1 { margin: 0 0 10px 0; font: bold 18px Arial, Helvetica, sans-serif; }\r\nh2 { margin: 8px 0 8px 15px; font: bold 14px Arial, Helvetica, sans-serif; }\r\nh3 { margin: 0; font: bold 14px Arial, Helvetica, sans-serif; }\r\np { font: normal 12px Arial, Helvetica, sans-serif; }\r\np.instructions { margin: 0 0 0 10px; font: italic 12px Arial, Helvetica, sans-serif; color: #666666; }\r\n\r\n\r\n/* CONTENTS ON PAGE SPECS */\r\n#careerContent { clear: both; padding: 15px 0 0 0; }\r\n\r\n	\r\n/* DISPLAY JOB DETAILS */\r\n#detailsTable { width: 400px; }\r\n	#detailsTable td.detailsHeader { width: 30%; }\r\ndiv#descriptive { float: left; width: 585px; }\r\ndiv#detailsTools { float: right; padding: 0 0 8px 0; width: 280px; background: #ffffff; border: 1px solid #cccccc; }\r\n	div#detailsTools img { margin: 2px 6px 5px 15px;  }\r\n\r\n/* DISPLAY APPLICATION FORM */\r\ndiv.applyBoxLeft, div.applyBoxRight { width: 450px; height: 470px; background: #f9f9f9; border: 1px solid #cccccc; border-top: none; }\r\ndiv.applyBoxLeft { float: left; margin: 0 10px 0 0; }\r\ndiv.applyBoxRight { float: right; margin: 0 0 0 10px; }\r\n	div.applyBoxLeft div, div.applyBoxRight div { margin: 0 0 5px 0; padding: 3px 10px; background: #efefef; border-top: 1px solid #cccccc; border-bottom: 1px solid #cccccc; }\r\n	div.applyBoxLeft table, div.applyBoxRight table { margin: 0 auto; width: 420px; }\r\n	div.applyBoxLeft table td, div.applyBoxRight table td { padding: 3px; vertical-align: top; }\r\n		td.label { text-align: right; width: 110px; }\r\n        form#applyToJobForm {  }\r\n	form#applyToJobForm label { font-weight: bold; }\r\n	form#applyToJobForm input.inputBoxName, form#applyToJobForm input.inputBoxNormal { width: 285px; height: 15px; }\r\n        form#applyToJobForm input.submitButton { width: 197px; height: 27px; background: url(''images/careers_submit.gif'') no-repeat; }\r\n\r\n        form#applyToJobForm input.submitButtonDown { width: 197px; height: 27px; background: url(''images/careers_submit-o.gif'') no-repeat; }\r\n	form#applyToJobForm textarea { margin: 8px 0 0 0; width: 410px; height: 170px; }\r\n	form#applyToJobForm textarea.inputBoxArea{ width: 285px; height: 70px; }\r\n\r\n'),
(71, 'CATS 2.0', 'Content - Search Results', '<div id="careerContent">\r\n        <registeredCandidate>\r\n        <h1>Current Available Openings, Recently Posted Jobs: <numberOfSearchResults></h1>\r\n<searchResultsTable>\r\n    </div>'),
(72, 'CATS 2.0', 'Content - Questionnaire', '<div id="careerContent">\r\n<questionnaire>\r\n<br /><br />\r\n<div style="text-align: right;">\r\n<submit value="Continue">\r\n</div>\r\n</div>'),
(73, 'CATS 2.0', 'Content - Job Details', '<div id="careerContent">\r\n        <registeredCandidate>\r\n        <h1>Position Details: <title></h1>\r\n        <table id="detailsTable">\r\n            <tr>\r\n                <td class="detailsHeader"><strong>Location:</strong></td>\r\n                <td><city>, <state></td>\r\n			</tr>\r\n			<tr>\r\n                <td class="detailsHeader"><strong>Openings:</strong></td>\r\n                <td><openings></td>\r\n			</tr>\r\n            <tr>\r\n                <td class="detailsHeader"><strong>Salary Range:</strong></td>\r\n                <td><salary></td>\r\n            </tr>\r\n        </table>\r\n        <div id="descriptive">\r\n            <p><strong>Description:</strong></p>\r\n            <description>\r\n		</div>\r\n        <div id="detailsTools">\r\n        	<h2>Perform an action:</h2>\r\n        	<a-applyToJob onmouseover="buttonMouseOver(''applyToPosition'',true);" onmouseout="buttonMouseOver(''applyToPosition'',false);"><img src="images/careers_apply.gif" id="applyToPosition" alt="IMAGE: Apply to Position" /></a>\r\n        </div>\r\n    </div>'),
(74, 'CATS 2.0', 'Content - Thanks for your Submission', '<div id="careerContent">\r\n            <h1>Application Submitted For: <title></h1>\r\n            <div id="descriptive">\r\n                <p>Please check your email inbox &#8212; You should receive an email confirmation of your application.</p>\r\n                <p>Thank you for submitting your application to us. We will review it shortly and make contact with you soon.</p>\r\n                </div>\r\n			<div id="detailsTools">\r\n                <h2>Perform an action:</h2>\r\n                <ul>\r\n                	<li><a href="">Visit our website</a></li>\r\n		</ul>\r\n        	</div>\r\n    </div>'),
(75, 'CATS 2.0', 'Content - Apply for Position', '<div id="careerContent">\r\n        <h1>Applying to: <title></h1>\r\n        <div class="applyBoxLeft">\r\n            <div><h3>1. Import Resume (or CV) and Populate Fields</h3></div>\r\n            <table>\r\n                <tr>\r\n                    <td>\r\n                      \r\n                    <input-resumeUploadPreview>\r\n                    </td>\r\n                </tr>\r\n            </table>\r\n            <br />\r\n\r\n            <div><h3>2. Tell us about yourself</h3></div>\r\n            <p class="instructions">All fields marked with asterisk (*) are required.</p>\r\n            <table>\r\n                <tr>\r\n                    <td class="label"><label id="firstNameLabel" for="firstName">*First Name:</label></td>\r\n                    <td><input-firstName></td>\r\n                </tr>\r\n                <tr>\r\n                    <td class="label"><label id="lastNameLabel" for="lastName">*Last Name:</label></td>\r\n                    <td><input-lastName></td>\r\n                </tr>\r\n                <tr>\r\n                    <td class="label"><label id="emailLabel" for="email">*Email Adddress:</label></td>\r\n                    <td><input-email></td>\r\n                </tr>\r\n                <tr>\r\n                    <td class="label"><label id="emailConfirmLabel" for="emailconfirm">*Confirm Email:</label></td>\r\n                    <td><input-emailconfirm></td>\r\n                </tr>\r\n            </table>\r\n        </div>\r\n       \r\n        <div class="applyBoxRight">\r\n            <div><h3>3. How may we contact you?</h3></div>\r\n            <table>\r\n                <tr>\r\n                    <td class="label"><label id="homePhoneLabel" for="homePhone">Home Phone:</label></td>\r\n                    <td><input-phone-home></td>\r\n                </tr>\r\n                <tr>\r\n                    <td class="label"><label id="mobilePhoneLabel" for="mobilePhone">Mobile Phone:</label></td>\r\n                    <td><input-phone-cell></td>\r\n                </tr>\r\n                <tr>\r\n                    <td class="label"><label id="workPhoneLabel" for="workPhone">Work Phone:</label></td>\r\n                    <td><input-phone></td>\r\n                </tr>\r\n                <tr>\r\n                    <td class="label"><label id="bestTimeLabel" for="bestTime">*Best time to call:</label></td>\r\n                    <td><input-best-time-to-call></td>\r\n                </tr>\r\n                <tr>\r\n                    <td class="label"><label id="mailingAddressLabel" for="mailingAddress">Mailing Address:</label></td>\r\n                    <td><input-address></td>\r\n                </tr>\r\n                <tr>\r\n                    <td class="label"><label id="cityProvinceLabel" for="cityProvince">*City/Province:</label></td>\r\n                    <td><input-city></td>\r\n                </tr>\r\n                <tr>\r\n                    <td class="label"><label id="stateCountryLabel" for="stateCountry">*State/Country:</label></td>\r\n                    <td><input-state></td>\r\n                </tr>\r\n                <tr>\r\n                    <td class="label"><label id="zipPostalLabel" for="zipPostal">*Zip/Postal Code:</label></td>\r\n                    <td><input-zip></td>\r\n                </tr>\r\n            </table>\r\n            <br />\r\n            <div><h3>4. Additional Information</h3></div>\r\n            <table>\r\n                <tr>\r\n                    <td class="label"><label id="keySkillsLabel" for="keySkills">*Key Skills:</label></td>\r\n                    <td><input-keySkills></td>\r\n                </tr>\r\n                <tr>\r\n                    <td>&nbsp;</td>\r\n                    <td><img src="images/careers_submit.gif" onmouseover="buttonMouseOver(''submitApplicationNow'',true)" onmouseout="buttonMouseOver(''submitApplicationNow'',false)" style="cursor: pointer;" id="submitApplicationNow" alt="Submit Application Now" onclick="if (applyValidate()) { document.applyToJobForm.submit(); }" /></td>\r\n                </tr>\r\n            </table>\r\n               </div>\r\n    </div>'),
(76, 'CATS 2.0', 'Content - Candidate Registration', '<div id="careerContent">\r\n    <h1><applyContent>Applying to <title></applyContent></h1>\r\n    <center>\r\n    <table cellpadding="0" cellspacing="0">\r\n        <tr>\r\n            <td><label id="emailLabel" for="email"><h2>Enter your e-mail address:</h2></label></td>\r\n            <td><input-email></td>\r\n        </tr>\r\n        <tr>\r\n            <td align="right" valign="top"><input-new></td>\r\n            <td style="line-height: 18px;">\r\n                <applyContent>\r\n                <strong>I have not registered on this website.</strong><br />\r\n                (I haven''t applied to any jobs online)\r\n                </applyContent>\r\n            </td>\r\n        </tr>\r\n        <tr>\r\n            <td align="right" valign="top"><input-registered></td>\r\n            <td style="line-height: 20px;">\r\n                <strong>I have registered before</strong><br />\r\n                and my last name is:<br />\r\n                <input-lastName><br />\r\n                and my zip code is:<br />\r\n                <input-zip><br /><br />\r\n                <input-rememberMe> Remember my information for future visits<br /><br />\r\n                <input-submit><br /><br />\r\n            </td>\r\n        </tr>\r\n    </table>\r\n    </center>\r\n</div>\r\n'),
(77, 'CATS 2.0', 'Content - Candidate Profile', '<div id="careerContent">    <h1 style="padding: 0; margin: 0; border: 0;">My Profile</h1><h3 style="font-weight: normal;">Any changes you make to your profile will be updated on our website for all    past and future jobs you apply for.</h3>    <br />    <div class="applyBoxLeft">        <div><h3>1. Tell us about yourself</h3></div>        <p class="instructions">All fields marked with asterisk (*) are required.</p>        <table>            <tr>                <td class="label"><label id="firstNameLabel" for="firstName">*First Name:</label></td>                <td><input-firstName></td>            </tr>            <tr>                <td class="label"><label id="lastNameLabel" for="lastName">*Last Name:</label></td>                <td><input-lastName></td>            </tr>            <tr>                <td class="label"><label id="emailLabel" for="email">*Email Adddress:</label></td>                <td><input-email1></td>            </tr>            <tr>                <td colspan="2">                    <input-resume>                </td>            </tr>        </table>    </div>    <div class="applyBoxRight">        <div><h3>2. How may we contact you?</h3></div>        <table>            <tr>                <td class="label"><label id="homePhoneLabel" for="homePhone">Home Phone:</label></td>                <td><input-phoneHome></td>            </tr>            <tr>                <td class="label"><label id="mobilePhoneLabel" for="mobilePhone">Mobile Phone:</label></td>                <td><input-phoneCell></td>            </tr>            <tr>                <td class="label"><label id="workPhoneLabel" for="workPhone">Work Phone:</label></td>                <td><input-phoneWork></td>            </tr>            <tr>                <td class="label"><label id="bestTimeLabel" for="bestTime">*Best time to call:</label></td>                <td><input-bestTimeToCall></td>            </tr>            <tr>                <td class="label"><label id="mailingAddressLabel" for="mailingAddress">Mailing Address:</label></td>                <td><input-address></td>            </tr>            <tr>                <td class="label"><label id="cityProvinceLabel" for="cityProvince">*City/Province:</label></td>                <td><input-city></td>            </tr>            <tr>                <td class="label"><label id="stateCountryLabel" for="stateCountry">*State/Country:</label></td>                <td><input-state></td>            </tr>            <tr>                <td class="label"><label id="zipPostalLabel" for="zipPostal">*Zip/Postal Code:</label></td>                <td><input-zip></td>            </tr>        </table>        <br />        <div><h3>3. Additional Information</h3></div>        <table>            <tr>                <td class="label"><label id="keySkillsLabel" for="keySkills">*Key Skills:</label></td>                <td><input-keySkills></td>            </tr>            <tr>                <td>&nbsp;</td>                <td style="padding-top: 40px;"><input-submit></td>            </tr>        </table>    </div></div>');

-- --------------------------------------------------------

--
-- Table structure for table `career_portal_template_site`
--

DROP TABLE IF EXISTS `career_portal_template_site`;
CREATE TABLE IF NOT EXISTS `career_portal_template_site` (
  `career_portal_template_id` int(11) NOT NULL AUTO_INCREMENT,
  `career_portal_name` varchar(255) DEFAULT NULL,
  `site_id` int(11) NOT NULL,
  `setting` varchar(128) NOT NULL DEFAULT '',
  `value` text,
  PRIMARY KEY (`career_portal_template_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE IF NOT EXISTS `categories` (
  `site_id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `id` int(11) DEFAULT NULL,
  PRIMARY KEY (`site_id`),
  KEY `IDX_category` (`category`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=181 ;

-- --------------------------------------------------------

--
-- Table structure for table `client`
--

DROP TABLE IF EXISTS `client`;
CREATE TABLE IF NOT EXISTS `client` (
  `client_id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `billing_contact` int(11) DEFAULT NULL,
  `name` varchar(64) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `address` text COLLATE utf8_unicode_ci,
  `city` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone1` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone2` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `key_technologies` text COLLATE utf8_unicode_ci,
  `Internal Postings` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `default_client` int(11) NOT NULL DEFAULT '0',
  `notes` text COLLATE utf8_unicode_ci,
  `entered_by` int(11) DEFAULT NULL,
  `owner` int(11) DEFAULT NULL,
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `is_hot` int(1) DEFAULT NULL,
  `fax_number` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `import_id` int(11) DEFAULT NULL,
  `default_company` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`client_id`),
  KEY `IDX_site_id` (`site_id`),
  KEY `IDX_name` (`name`),
  KEY `IDX_key_technologies` (`key_technologies`(255)),
  KEY `IDX_entered_by` (`entered_by`),
  KEY `IDX_owner` (`owner`),
  KEY `IDX_date_created` (`date_created`),
  KEY `IDX_date_modified` (`date_modified`),
  KEY `IDX_is_hot` (`is_hot`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `client_department`
--

DROP TABLE IF EXISTS `client_department`;
CREATE TABLE IF NOT EXISTS `client_department` (
  `department_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `client_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `date_created` datetime NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`department_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=11 ;

-- --------------------------------------------------------

--
-- Table structure for table `client_foreign`
--

DROP TABLE IF EXISTS `client_foreign`;
CREATE TABLE IF NOT EXISTS `client_foreign` (
  `alien_id` int(11) NOT NULL AUTO_INCREMENT,
  `assoc_id` int(11) DEFAULT NULL,
  `field_name` varchar(255) DEFAULT NULL,
  `value` text,
  `import_id` int(11) DEFAULT NULL,
  `site_id` int(11) DEFAULT '0',
  PRIMARY KEY (`alien_id`),
  KEY `assoc_id` (`assoc_id`),
  KEY `IDX_site_id` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `client_foreign_settings`
--

DROP TABLE IF EXISTS `client_foreign_settings`;
CREATE TABLE IF NOT EXISTS `client_foreign_settings` (
  `alien_id` int(11) NOT NULL AUTO_INCREMENT,
  `field_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `import_id` int(11) DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime DEFAULT NULL,
  PRIMARY KEY (`alien_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=4 ;

--
-- Dumping data for table `client_foreign_settings`
--

INSERT INTO `client_foreign_settings` (`alien_id`, `field_name`, `import_id`, `site_id`, `date_created`) VALUES
(1, 'AdminUser', NULL, 180, '2005-06-01 00:00:00'),
(2, 'UnixName', NULL, 180, '2005-06-01 00:00:00'),
(3, 'BillingNotes', NULL, 180, '2005-06-01 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `company`
--

DROP TABLE IF EXISTS `company`;
CREATE TABLE IF NOT EXISTS `company` (
  `company_id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `billing_contact` int(11) DEFAULT NULL,
  `name` varchar(64) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `address` text COLLATE utf8_unicode_ci,
  `city` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone1` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone2` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `key_technologies` text COLLATE utf8_unicode_ci,
  `notes` text COLLATE utf8_unicode_ci,
  `entered_by` int(11) DEFAULT NULL,
  `owner` int(11) DEFAULT NULL,
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `is_hot` int(1) DEFAULT NULL,
  `fax_number` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `import_id` int(11) DEFAULT NULL,
  `default_company` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`company_id`),
  KEY `IDX_site_id` (`site_id`),
  KEY `IDX_name` (`name`),
  KEY `IDX_key_technologies` (`key_technologies`(255)),
  KEY `IDX_entered_by` (`entered_by`),
  KEY `IDX_owner` (`owner`),
  KEY `IDX_date_created` (`date_created`),
  KEY `IDX_date_modified` (`date_modified`),
  KEY `IDX_is_hot` (`is_hot`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `company_department`
--

DROP TABLE IF EXISTS `company_department`;
CREATE TABLE IF NOT EXISTS `company_department` (
  `company_department_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`company_department_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `contact`
--

DROP TABLE IF EXISTS `contact`;
CREATE TABLE IF NOT EXISTS `contact` (
  `contact_id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `last_name` varchar(64) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `first_name` varchar(64) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `title` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email1` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email2` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone_work` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone_cell` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone_other` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8_unicode_ci,
  `city` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_hot` int(1) DEFAULT NULL,
  `notes` text COLLATE utf8_unicode_ci,
  `entered_by` int(11) NOT NULL DEFAULT '0',
  `owner` int(11) DEFAULT NULL,
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `left_company` int(1) NOT NULL DEFAULT '0',
  `import_id` int(11) NOT NULL DEFAULT '0',
  `company_department_id` int(11) NOT NULL,
  `reports_to` int(11) DEFAULT '-1',
  `department_id` int(11) DEFAULT '0',
  PRIMARY KEY (`contact_id`),
  KEY `IDX_site_id` (`site_id`),
  KEY `IDX_first_name` (`first_name`),
  KEY `IDX_last_name` (`last_name`),
  KEY `IDX_client_id` (`company_id`),
  KEY ` IDX_title` (`title`),
  KEY `IDX_owner` (`owner`),
  KEY `IDX_date_created` (`date_created`),
  KEY `IDX_date_modified` (`date_modified`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `contact_foreign`
--

DROP TABLE IF EXISTS `contact_foreign`;
CREATE TABLE IF NOT EXISTS `contact_foreign` (
  `alien_id` int(11) NOT NULL AUTO_INCREMENT,
  `assoc_id` int(11) DEFAULT NULL,
  `field_name` varchar(255) DEFAULT NULL,
  `value` text,
  `import_id` int(11) DEFAULT NULL,
  `site_id` int(11) DEFAULT '0',
  PRIMARY KEY (`alien_id`),
  KEY `assoc_id` (`assoc_id`),
  KEY `IDX_site_id` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `contact_foreign_settings`
--

DROP TABLE IF EXISTS `contact_foreign_settings`;
CREATE TABLE IF NOT EXISTS `contact_foreign_settings` (
  `alien_id` int(11) NOT NULL AUTO_INCREMENT,
  `field_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `import_id` int(11) DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime DEFAULT NULL,
  PRIMARY KEY (`alien_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=2 ;

--
-- Dumping data for table `contact_foreign_settings`
--

INSERT INTO `contact_foreign_settings` (`alien_id`, `field_name`, `import_id`, `site_id`, `date_created`) VALUES
(1, 'IPAddress', NULL, 180, '2005-06-01 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `dashboard_component`
--

DROP TABLE IF EXISTS `dashboard_component`;
CREATE TABLE IF NOT EXISTS `dashboard_component` (
  `dashboard_component_id` int(11) NOT NULL AUTO_INCREMENT,
  `module_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `module_parameters` text COLLATE utf8_unicode_ci,
  `site_id` int(11) DEFAULT NULL,
  `column_number` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  PRIMARY KEY (`dashboard_component_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=26 ;

--
-- Dumping data for table `dashboard_component`
--

INSERT INTO `dashboard_component` (`dashboard_component_id`, `module_name`, `module_parameters`, `site_id`, `column_number`, `position`) VALUES
(13, 'text', '"Welcome, ((USERNAME))!\r\nDate: ((DATE))\r\nTime: ((TIME))"', 1, 0, 1),
(14, 'myUpcomingEvents', '"6"', 1, 0, 2),
(15, 'titleBar', '"Current Status: ((LASTWEEKTHROUGHTHISWEEK)) (Last Two Weeks)"', 1, 2, 0),
(16, 'newJobOrders', NULL, 1, 2, 3),
(17, 'newCandidates', NULL, 1, 2, 3),
(18, 'recentJobOrders', '"8"', 1, 1, 1),
(19, 'activity', NULL, 1, 0, 6),
(20, 'titleBar', '"Recent Activity (Last Two Weeks)"', 1, 0, 5),
(21, 'newSubmissions', NULL, 1, 2, 4),
(22, 'pipeline', '"DarkGreen","DarkGreen","DarkGreen","DarkGreen","DarkGreen","Orange","DarkGreen","AlmostBlack","DarkGreen"', 1, 1, 0),
(23, 'titleBar', '"((SITENAME)) Links"', 1, 0, 3),
(24, 'titleBar', '"Welcome!"', 1, 0, 0),
(25, 'html', '"<a href=""http://www.catsone.com/forum/"" target=newwin1> CATS Forums</a><br />\r\n<a href=""http://www.cognizo.com"" target=newwin2>Cognizo Technologies</a>"', 1, 0, 4);

-- --------------------------------------------------------

--
-- Table structure for table `dashboard_module`
--

DROP TABLE IF EXISTS `dashboard_module`;
CREATE TABLE IF NOT EXISTS `dashboard_module` (
  `dashboard_module_id` int(11) NOT NULL AUTO_INCREMENT,
  `object` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `function` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `preview_image` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parameter_CSV` text COLLATE utf8_unicode_ci,
  `parameter_defaults` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`dashboard_module_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=12 ;

--
-- Dumping data for table `dashboard_module`
--

INSERT INTO `dashboard_module` (`dashboard_module_id`, `object`, `name`, `function`, `title`, `description`, `preview_image`, `parameter_CSV`, `parameter_defaults`) VALUES
(1, 'graphs', 'activity', 'activityDashboard', 'Activity', 'Shows the current week and previous week activity count on a bar graph.', 'images/dashboard_preview/activity.png', NULL, NULL),
(2, 'calendar', 'myUpcomingEvents', 'getUpcomingDashboard', 'My Upcoming Events', 'Shows a list of todays events.', 'images/dashboard_preview/upcoming_events.png', '"Number of events to show: ,vartextshort"', NULL),
(3, 'generic', 'titleBar', 'titleBar', 'Title Bar', 'Displays a custom title bar.', 'images/dashboard_preview/title_bar.png', '"Title: ,vartext"', ''),
(4, 'generic', 'text', 'text', 'Text', 'Displays text.', 'images/dashboard_preview/text.png', '"Text: ,vartextlong"', NULL),
(5, 'jobOrders', 'recentJobOrders', 'recentJobOrdersDashboard', 'Recent Job Orders', 'Displays the latest job orders added to the system.', 'images/dashboard_preview/recent_job_orders.png', '"Number of job orders to display: ,vartextshort"', '"6"'),
(6, 'generic', 'html', 'html', 'HTML', 'Displays formatted HTML.', NULL, '"HTML Code: ,vartextlong"', NULL),
(7, 'graphs', 'newCandidates', 'newCandidatesDashboard', 'New Candidates', 'Shows the current week and previous week new candidate count on a bar graph.', 'images/dashboard_preview/candidates.png', NULL, NULL),
(8, 'graphs', 'newJobOrders', 'newJobOrdersDashboard', 'New Job Orders', 'Shows the current week and previous week new job order count on a bar graph.', 'images/dashboard_preview/joborders.png', NULL, NULL),
(9, 'graphs', 'newSubmissions', 'newSubmissionsDashboard', 'New Submissions', 'Shows the current week and previous week new count of how many candidates were submitted to job orders on a bar graph.', 'images/dashboard_preview/submissions.png', NULL, NULL),
(10, 'generic', 'image', 'image', 'Image', 'Displays an image.', 'images/dashboard_preview/image.png', '"URL to image: ,vartext","Optional hyperlink URL: ,vartext"', NULL),
(11, 'graphs', 'pipeline', 'pipelineDashboard', 'Pipeline', 'Displays the current pipeline status on a graph.', 'images/dashboard_preview/pipeline.png', '"Total Pipeline Color: ,colorpickerartichow","Contacted Color: ,colorpickerartichow","Candidate Replied Color: ,colorpickerartichow","Negotiating Color: ,colorpickerartichow","Submitted Color: ,colorpickerartichow","Interviewing Color: ,colorpickerartichow","Offered Color: ,colorpickerartichow","Client Declined Color: ,colorpickerartichow","Placed Color: ,colorpickerartichow"', '"DarkGreen","DarkGreen","DarkGreen","DarkGreen","DarkGreen","Orange","DarkGreen","AlmostBlack","DarkGreen"');

-- --------------------------------------------------------

--
-- Table structure for table `data_item_type`
--

DROP TABLE IF EXISTS `data_item_type`;
CREATE TABLE IF NOT EXISTS `data_item_type` (
  `data_item_type_id` int(11) NOT NULL DEFAULT '0',
  `short_description` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`data_item_type_id`),
  KEY `IDX_short_description` (`short_description`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `data_item_type`
--

INSERT INTO `data_item_type` (`data_item_type_id`, `short_description`) VALUES
(100, 'Candidate'),
(200, 'Company'),
(300, 'Contact'),
(400, 'Job Order');

-- --------------------------------------------------------

--
-- Table structure for table `eeo_ethnic_type`
--

DROP TABLE IF EXISTS `eeo_ethnic_type`;
CREATE TABLE IF NOT EXISTS `eeo_ethnic_type` (
  `eeo_ethnic_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(128) NOT NULL DEFAULT '',
  PRIMARY KEY (`eeo_ethnic_type_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=6 ;

--
-- Dumping data for table `eeo_ethnic_type`
--

INSERT INTO `eeo_ethnic_type` (`eeo_ethnic_type_id`, `type`) VALUES
(1, 'American Indian'),
(2, 'Asian or Pacific Islander'),
(3, 'Hispanic or Latino'),
(4, 'Non-Hispanic Black'),
(5, 'Non-Hispanic White');

-- --------------------------------------------------------

--
-- Table structure for table `eeo_veteran_type`
--

DROP TABLE IF EXISTS `eeo_veteran_type`;
CREATE TABLE IF NOT EXISTS `eeo_veteran_type` (
  `eeo_veteran_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(128) NOT NULL DEFAULT '',
  PRIMARY KEY (`eeo_veteran_type_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

--
-- Dumping data for table `eeo_veteran_type`
--

INSERT INTO `eeo_veteran_type` (`eeo_veteran_type_id`, `type`) VALUES
(1, 'No Veteran Status'),
(2, 'Eligible Veteran'),
(3, 'Disabled Veteran'),
(4, 'Eligible and Disabled');

-- --------------------------------------------------------

--
-- Table structure for table `email_history`
--

DROP TABLE IF EXISTS `email_history`;
CREATE TABLE IF NOT EXISTS `email_history` (
  `email_history_id` int(11) NOT NULL AUTO_INCREMENT,
  `from_addr` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `to_addr` varchar(192) COLLATE utf8_unicode_ci DEFAULT NULL,
  `text` text COLLATE utf8_unicode_ci,
  `user_id` int(11) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL DEFAULT '0',
  `date` datetime DEFAULT NULL,
  PRIMARY KEY (`email_history_id`),
  KEY `IDX_site_id` (`site_id`),
  KEY `IDX_date` (`date`),
  KEY `IDX_user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `email_template`
--

DROP TABLE IF EXISTS `email_template`;
CREATE TABLE IF NOT EXISTS `email_template` (
  `email_template_id` int(11) NOT NULL AUTO_INCREMENT,
  `text` text COLLATE utf8_unicode_ci,
  `allow_substitution` int(1) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL DEFAULT '0',
  `tag` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `possible_variables` text COLLATE utf8_unicode_ci,
  `disabled` int(1) DEFAULT '0',
  PRIMARY KEY (`email_template_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=32 ;

--
-- Dumping data for table `email_template`
--

INSERT INTO `email_template` (`email_template_id`, `text`, `allow_substitution`, `site_id`, `tag`, `title`, `possible_variables`, `disabled`) VALUES
(20, '* Auto generated message. Please DO NOT reply *\r\n%DATETIME%\r\n\r\nDear %CANDFULLNAME%,\r\n\r\nThis E-Mail is a notification that your status in our database has been changed for the position %JBODTITLE% (%JBODCLIENT%).\r\n\r\nYour previous status was <B>%CANDPREVSTATUS%</B>.\r\nYour new status is <B>%CANDSTATUS%</B>.\r\n\r\nTake care,\r\n%USERFULLNAME%\r\n%SITENAME%', 1, 1, 'EMAIL_TEMPLATE_STATUSCHANGE', 'Status Changed (Sent to Candidate)', '%CANDSTATUS%%CANDOWNER%%CANDFIRSTNAME%%CANDFULLNAME%%CANDPREVSTATUS%%JBODCLIENT%%JBODTITLE%', 0),
(28, '%DATETIME%\r\n\r\nDear %CANDOWNER%,\r\n\r\nThis E-Mail is a notification that a Candidate has been assigned to you.\r\n\r\nCandidate Name: %CANDFULLNAME%\r\nCandidate URL: %CANDCATSURL%\r\n\r\nTake care,\r\nCATS \r\n%SITENAME%', 1, 1, 'EMAIL_TEMPLATE_OWNERSHIPASSIGNCANDIDATE', 'Candidate Assigned (Sent to Assigned Recruiter)', '%CANDOWNER%%CANDFIRSTNAME%%CANDFULLNAME%%CANDCATSURL%', 0),
(27, '%DATETIME%\r\n\r\nDear %JBODOWNER%,\r\n\r\nThis E-Mail is a notification that a Job Order has been assigned to you.\r\n\r\nJob Order Title: %JBODTITLE%\r\nJob Order Client: %JBODCLIENT%\r\nJob Order ID: %JBODID%\r\nJob Order URL: %JBODCATSURL%\r\n\r\nTake care,\r\nCATS \r\n%SITENAME%', 1, 1, 'EMAIL_TEMPLATE_OWNERSHIPASSIGNJOBORDER', 'Job Order Assigned (Sent to Assigned Recruiter)', '%JBODOWNER%%JBODTITLE%%JBODCLIENT%%JBODCATSURL%%JBODID%', 0),
(26, '%DATETIME%\r\n\r\nDear %CONTOWNER%,\r\n\r\nThis E-Mail is a notification that a Contact has been assigned to you.\r\n\r\nContact Name: %CONTFULLNAME%\r\nContact Client: %CONTCLIENTNAME%\r\nContact URL: %CONTCATSURL%\r\n\r\nTake care,\r\nCATS \r\n%SITENAME%', 1, 1, 'EMAIL_TEMPLATE_OWNERSHIPASSIGNCONTACT', 'Contact Assigned (Sent to Assigned Recruiter)', '%CONTOWNER%%CONTFIRSTNAME%%CONTFULLNAME%%CONTCLIENTNAME%%CONTCATSURL%', 0),
(25, '%DATETIME%\r\n\r\nDear %CLNTOWNER%,\r\n\r\nThis E-Mail is a notification that a Client has been assigned to you.\r\n\r\nClient Name: %CLNTNAME%\r\nClient URL %CLNTCATSURL%\r\n\r\nTake care,\r\nCATS \r\n%SITENAME%', 1, 1, 'EMAIL_TEMPLATE_OWNERSHIPASSIGNCLIENT', 'Client Assigned (Sent to Assigned Recruiter)', '%CLNTOWNER%%CLNTNAME%%CLNTCATSURL%', 0),
(29, '%%FULLNAME,\r\n\r\nThanks for your interest in CATS!  You have just set up a CATS employer site (Trial) which can be accessed from:\r\n\r\nLogin page: <a href="%%LOGINPAGE">%%LOGINPAGE</a>\r\nUsername: %%USERNAME\r\nPassword: %%PASSWORD\r\n\r\nIt is an empty database.\r\n\r\nAfter 30 days, your trial will expire.  At this time, you can continue to use our site by purchasing a site license.  Purchasing a site license also allows you to add more users to the system.\r\n\r\nMore information can be found at <a href="http://www.catsone.net/index.php?m=asp&a=purchaseinfo">http://www.catsone.net/index.php?m=asp&a=purchaseinfo</a> or by visiting ''My Account'' through the CATS settings tab.\r\n\r\nIf you have any questions or suggestions, feel free to contact us through the forums at <a href="http://www.catsone.com/forum/">http://www.catsone.com/forum/</a> or through E-Mail at <a href="http://catsone.com/?page_id=9">http://catsone.com/?page_id=9</a>.\r\n\r\nHappy recruiting!\r\n- CATS Team', 1, 180, 'EMAIL_TEMPLATE_WELCOME_TO_CATS', 'Welcome to CATS (Sent to new SA)', NULL, 0),
(30, '* Auto generated message. Please DO NOT reply *\r\n%DATETIME%\r\n\r\nDear %CANDFULLNAME%,\r\n\r\nThank you for applying to the job %JBODTITLE% with our online career portal!  Your application has been entered in the system and a recruiter will review it shortly.\r\n\r\nTake care,\r\n%SITENAME%', 1, 1, 'EMAIL_TEMPLATE_CANDIDATEAPPLY', 'Candidate Application Recieved (Sent to Candidate using Career Portal)', '%CANDFIRSTNAME%%CANDFULLNAME%%JBODCLIENT%%JBODTITLE%%JBODOWNER%', 0),
(31, '%DATETIME%\r\n\r\nDear %JBODOWNER%,\r\n\r\nThis E-Mail is a notification that a Candidate has applied to your job order through the online candidate portal.\r\n\r\nCandidate Name: %CANDFULLNAME%\r\nCandidate URL: %CANDCATSURL%\r\nJob Order URL: %JBODCATSURL%\r\n\r\nTake care,\r\nCATS \r\n%SITENAME%', 1, 1, 'EMAIL_TEMPLATE_CANDIDATEPORTALNEW', 'Candidate Application Recieved (Sent to Owner of Job Order from Career Portal)', '%CANDFIRSTNAME%%CANDFULLNAME%%JBODOWNER%%JBODTITLE%%JBODCLIENT%%JBODCATSURL%%JBODID%%CANDCATSURL%', 0);

-- --------------------------------------------------------

--
-- Table structure for table `extension_statistics`
--

DROP TABLE IF EXISTS `extension_statistics`;
CREATE TABLE IF NOT EXISTS `extension_statistics` (
  `extension_statistics_id` int(11) NOT NULL AUTO_INCREMENT,
  `extension` varchar(128) NOT NULL DEFAULT '',
  `action` varchar(128) NOT NULL DEFAULT '',
  `user` varchar(128) NOT NULL DEFAULT '',
  `date` date DEFAULT NULL,
  PRIMARY KEY (`extension_statistics_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `extra_field`
--

DROP TABLE IF EXISTS `extra_field`;
CREATE TABLE IF NOT EXISTS `extra_field` (
  `extra_field_id` int(11) NOT NULL AUTO_INCREMENT,
  `data_item_id` int(11) DEFAULT '0',
  `field_name` varchar(255) DEFAULT NULL,
  `value` text,
  `import_id` int(11) DEFAULT NULL,
  `site_id` int(11) DEFAULT '0',
  `data_item_type` int(11) DEFAULT '0',
  PRIMARY KEY (`extra_field_id`),
  KEY `assoc_id` (`data_item_id`),
  KEY `IDX_site_id` (`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `extra_field_settings`
--

DROP TABLE IF EXISTS `extra_field_settings`;
CREATE TABLE IF NOT EXISTS `extra_field_settings` (
  `extra_field_settings_id` int(11) NOT NULL AUTO_INCREMENT,
  `field_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `import_id` int(11) DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime DEFAULT NULL,
  `data_item_type` int(11) DEFAULT '0',
  `extra_field_type` int(11) NOT NULL DEFAULT '1',
  `extra_field_options` text COLLATE utf8_unicode_ci,
  `position` int(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`extra_field_settings_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=5 ;

--
-- Dumping data for table `extra_field_settings`
--

INSERT INTO `extra_field_settings` (`extra_field_settings_id`, `field_name`, `import_id`, `site_id`, `date_created`, `data_item_type`, `extra_field_type`, `extra_field_options`, `position`) VALUES
(1, 'AdminUser', NULL, 180, '2005-06-01 00:00:00', 200, 1, NULL, 1),
(2, 'UnixName', NULL, 180, '2005-06-01 00:00:00', 200, 1, NULL, 2),
(3, 'BillingNotes', NULL, 180, '2005-06-01 00:00:00', 200, 1, NULL, 3),
(4, 'IPAddress', NULL, 180, '2005-06-01 00:00:00', 300, 1, NULL, 4);

-- --------------------------------------------------------

--
-- Table structure for table `feedback`
--

DROP TABLE IF EXISTS `feedback`;
CREATE TABLE IF NOT EXISTS `feedback` (
  `feedback_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `subject` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `reply_to_address` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `reply_to_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `feedback` text COLLATE utf8_unicode_ci NOT NULL,
  `archived` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`feedback_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `history`
--

DROP TABLE IF EXISTS `history`;
CREATE TABLE IF NOT EXISTS `history` (
  `history_id` int(11) NOT NULL AUTO_INCREMENT,
  `data_item_type` int(11) DEFAULT NULL,
  `data_item_id` int(11) DEFAULT NULL,
  `the_field` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `previous_value` text COLLATE utf8_unicode_ci,
  `new_value` text COLLATE utf8_unicode_ci,
  `description` varchar(192) COLLATE utf8_unicode_ci DEFAULT NULL,
  `set_date` datetime DEFAULT NULL,
  `entered_by` int(11) DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`history_id`),
  KEY `IDX_DATA_TYPE` (`data_item_type`),
  KEY `IDX_DATA_ID` (`data_item_id`),
  KEY `IDX_DATA_ENTERED_BY` (`entered_by`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `hot_list`
--

DROP TABLE IF EXISTS `hot_list`;
CREATE TABLE IF NOT EXISTS `hot_list` (
  `hot_list_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `data_item_type` int(11) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`hot_list_id`),
  KEY `IDX_data_item_type` (`data_item_type`),
  KEY `IDX_description` (`description`),
  KEY `IDX_site_id` (`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `hot_list_entry`
--

DROP TABLE IF EXISTS `hot_list_entry`;
CREATE TABLE IF NOT EXISTS `hot_list_entry` (
  `hot_list_entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `hot_list_id` int(11) NOT NULL DEFAULT '0',
  `data_item_type` int(11) NOT NULL DEFAULT '0',
  `data_item_id` int(11) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`hot_list_entry_id`),
  KEY `IDX_type_id` (`data_item_type`,`data_item_id`),
  KEY `IDX_data_item_type` (`data_item_type`),
  KEY `IDX_data_item_id` (`data_item_id`),
  KEY `IDX_hot_list_id` (`hot_list_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `http_log`
--

DROP TABLE IF EXISTS `http_log`;
CREATE TABLE IF NOT EXISTS `http_log` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `remote_addr` char(16) NOT NULL,
  `http_user_agent` varchar(255) DEFAULT NULL,
  `script_filename` varchar(255) DEFAULT NULL,
  `request_method` varchar(16) DEFAULT NULL,
  `query_string` varchar(255) DEFAULT NULL,
  `request_uri` varchar(255) DEFAULT NULL,
  `script_name` varchar(255) DEFAULT NULL,
  `log_type` int(11) NOT NULL,
  `date` datetime DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`log_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `http_log_types`
--

DROP TABLE IF EXISTS `http_log_types`;
CREATE TABLE IF NOT EXISTS `http_log_types` (
  `log_type_id` int(11) NOT NULL,
  `name` varchar(16) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `default_log_type` tinyint(1) unsigned zerofill NOT NULL DEFAULT '0',
  PRIMARY KEY (`log_type_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `http_log_types`
--

INSERT INTO `http_log_types` (`log_type_id`, `name`, `description`, `default_log_type`) VALUES
(1, 'XML', 'XML Job Feed', 0);

-- --------------------------------------------------------

--
-- Table structure for table `import`
--

DROP TABLE IF EXISTS `import`;
CREATE TABLE IF NOT EXISTS `import` (
  `import_id` int(11) NOT NULL AUTO_INCREMENT,
  `module_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `reverted` int(1) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL DEFAULT '0',
  `import_errors` text COLLATE utf8_unicode_ci,
  `added_lines` int(11) DEFAULT NULL,
  PRIMARY KEY (`import_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `industries`
--

DROP TABLE IF EXISTS `industries`;
CREATE TABLE IF NOT EXISTS `industries` (
  `site_id` int(11) NOT NULL AUTO_INCREMENT,
  `industry` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `id` int(11) DEFAULT NULL,
  PRIMARY KEY (`site_id`),
  KEY `IDX_industry` (`industry`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=181 ;

-- --------------------------------------------------------

--
-- Table structure for table `installtest`
--

DROP TABLE IF EXISTS `installtest`;
CREATE TABLE IF NOT EXISTS `installtest` (
  `id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `joborder`
--

DROP TABLE IF EXISTS `joborder`;
CREATE TABLE IF NOT EXISTS `joborder` (
  `joborder_id` int(11) NOT NULL AUTO_INCREMENT,
  `recruiter` int(11) DEFAULT NULL,
  `contact_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `entered_by` int(11) NOT NULL DEFAULT '0',
  `owner` int(11) DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `client_job_id` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(64) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `description` text COLLATE utf8_unicode_ci,
  `notes` text COLLATE utf8_unicode_ci,
  `type` varchar(64) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'C',
  `duration` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rate_max` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `salary` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(16) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Active',
  `is_hot` int(1) NOT NULL DEFAULT '0',
  `openings` int(11) DEFAULT NULL,
  `city` varchar(64) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `state` varchar(64) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `start_date` datetime DEFAULT NULL,
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `date_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `public` int(1) NOT NULL DEFAULT '0',
  `company_department_id` int(11) DEFAULT NULL,
  `is_admin_hidden` int(1) DEFAULT '0',
  `openings_available` int(11) DEFAULT '0',
  `questionnaire_id` int(11) DEFAULT NULL,
  `department_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`joborder_id`),
  KEY `IDX_recruiter` (`recruiter`),
  KEY `IDX_title` (`title`),
  KEY `IDX_client_id` (`company_id`),
  KEY `IDX_start_date` (`start_date`),
  KEY `IDX_contact_id` (`contact_id`),
  KEY `IDX_is_hot` (`is_hot`),
  KEY `IDX_jopenings` (`openings`),
  KEY `IDX_owner` (`owner`),
  KEY `IDX_entered_by` (`entered_by`),
  KEY `IDX_date_created` (`date_created`),
  KEY `IDX_date_modified` (`date_modified`),
  KEY `IDX_site_id_status` (`site_id`,`status`(8)),
  KEY `IDX_site_id` (`site_id`),
  KEY `IDX_status` (`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `job_board_settings`
--

DROP TABLE IF EXISTS `job_board_settings`;
CREATE TABLE IF NOT EXISTS `job_board_settings` (
  `job_board_settings_id` int(11) NOT NULL AUTO_INCREMENT,
  `setting` varchar(128) NOT NULL DEFAULT '',
  `value` text,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `entered_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`job_board_settings_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `job_board_template`
--

DROP TABLE IF EXISTS `job_board_template`;
CREATE TABLE IF NOT EXISTS `job_board_template` (
  `job_board_template_id` int(11) NOT NULL AUTO_INCREMENT,
  `job_board_name` varchar(96) NOT NULL,
  `setting` varchar(128) NOT NULL DEFAULT '',
  `value` text,
  PRIMARY KEY (`job_board_template_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=31 ;

--
-- Dumping data for table `job_board_template`
--

INSERT INTO `job_board_template` (`job_board_template_id`, `job_board_name`, `setting`, `value`) VALUES
(16, 'CATS Standard', 'Header', '<div style="text-align:center;" class="mainLogoText"><siteName></div>\r\n<div style="text-align:center;" class="subLogoText">Career Center</div>\r\n<br />\r\n<center>\r\n<table width="950">\r\n<tr style="vertical-align: top; border-collapse: collapse;">\r\n<td style="width:180px;">\r\n<p class="noteUnsized">Menu</p>\r\n<br />\r\n<a-LinkMain>Main Page</a><br />\r\n<a-ListAll>List All Jobs</a><br />\r\n</td>'),
(17, 'CATS Standard', 'Content - Main', '<td>\r\n<p class="noteUnsized">Main</p>\r\n<br />\r\n<!-- Main content starts here -->\r\nWelcome to the <siteName> Career Portal!<br />\r\n<p class="mainHeading">Careers at <siteName></p>\r\nIf you are interested in joining a winning team, we invite you to view our current openings and submit your resume.<br />\r\n<p class="mainHeading">Current Openings</p>\r\nThere are currently <numberOfOpenPositions> openings.  <a-ListAll>Click Here</a> to view them.\r\n</td>'),
(18, 'CATS Standard', 'Content - Apply for Position', '<td>\r\n<p class="noteUnsized">Apply to Position</p>\r\n<br>\r\nYou are applying for the position ''<title>''.  Please type in your information below - we will match the provided E-Mail address with our system and update your existing profile if it exists.<br>\r\n<br>\r\n<table>\r\n<tr><td style="width:200px;">First Name:</td><td><input-firstName></td></tr>\r\n<tr><td style="width:200px;">Last Name:</td><td><input-lastName></td></tr>\r\n<tr><td>&nbsp;</td><td>&nbsp;</td></tr>\r\n<tr><td style="width:200px;">E-Mail Address:</td><td><input-email></td></tr>\r\n<tr><td style="width:200px;">Retype E-Mail:</td><td><input-emailconfirm></td></tr>\r\n<tr><td>&nbsp;</td><td>&nbsp;</td></tr>\r\n<tr><td style="width:200px;">Resume Upload:</td><td><input-resumeUpload></td></tr>\r\n<tr><td style="width:200px;">Extra notes concerning this position:</td><td><input-extraNotes></td></tr>\r\n</table>\r\n<br>\r\n<submit value="Apply for Position">\r\n</td>'),
(19, 'CATS Standard', 'Footer', '</tr>\r\n</table>\r\n</center>'),
(20, 'CATS Standard', 'CSS', 'body\r\n{\r\npadding: 8px 18px 8px 18px;\r\nmargin: 0px;\r\nfont: normal normal normal 10px Verdana, Tahoma, sans-serif;\r\n}\r\n.inputBoxName\r\n{\r\nwidth:220px;\r\n}\r\n.inputBoxNormal\r\n{\r\nwidth:300px;\r\n}\r\n.inputBoxArea\r\n{\r\nwidth:250px;\r\nheight:100px;\r\n}\r\n.mainLogoText\r\n{\r\ncolor: #2f4f88;\r\nmargin-bottom: 0px;\r\npadding: 0px 5px 0px 5px;\r\nfont: normal normal bold 30px Verdana, Tahoma, sans-serif;\r\n}\r\n.subLogoText\r\n{\r\ncolor: #000000;\r\nmargin-bottom: 0px;\r\npadding: 0px 2px 0px 2px;\r\nfont: normal normal bold 14px Verdana, Tahoma, sans-serif;\r\n}\r\np.mainHeading\r\n{\r\ncolor: #000000;\r\nmargin-bottom: 0px;\r\npadding: 0px 2px 0px 2px;\r\nfont: normal normal bold 16px Verdana, Tahoma, sans-serif;\r\n}\r\np.noteUnsized\r\n{\r\nbackground-image: url(''images/blue_gradient.jpg'');\r\nbackground-repeat: repeat-x;\r\npadding: 4px;\r\nmargin-top: 0px;\r\nmargin-bottom: 8px;\r\nborder-top: 1px solid #bbb;\r\nborder-bottom: 1px solid #bbb;\r\nfont: normal normal bold  12px/120% Verdana, Tahoma, sans-serif;\r\ncolor: #f4f4f4;\r\n}\r\np.noteUnsized\r\n{\r\nbackground-image: url(''images/blue_gradient.jpg'');\r\nbackground-repeat: repeat-x;\r\npadding: 4px;\r\nmargin-top: 0px;\r\nmargin-bottom: 8px;\r\nborder-top: 1px solid #bbb;\r\nborder-bottom: 1px solid #bbb;\r\nfont: normal normal bold  12px/120% Verdana, Tahoma, sans-serif;\r\ncolor: #f4f4f4;\r\n}\r\ntable.sortable\r\n{\r\nmargin: 5px 0px 5px 0px;\r\nborder-collapse: collapse;\r\nborder: 1px solid #ccc;\r\nfont: normal normal normal  10px Verdana, Tahoma, sans-serif;\r\nempty-cells: show;\r\n}\r\ntr.rowHeading\r\n{\r\ntext-align:center;\r\nbackground-image: url(''images/blue_gradient.jpg'');\r\nbackground-repeat: repeat-x;\r\npadding: 4px;\r\nmargin-top: 0px;\r\nmargin-bottom: 8px;\r\nborder-top: 1px solid #bbb;\r\nborder-bottom: 1px solid #bbb;\r\nfont: normal normal bold  10px Verdana, Tahoma, sans-serif;\r\ncolor: #2f4c87;\r\n}\r\ntr.oddTableRow\r\n{\r\nbackground: #fff;\r\nheight:20px;\r\n}\r\ntr.evenTableRow\r\n{\r\nbackground: #f4f4f4;\r\nheight:20px;\r\n}\r\na.sortheader:hover,\r\na.sortheader:link,\r\na.sortheader:visited\r\n{text-decoration: none;}\r\n '),
(21, 'CATS Standard', 'Content - Search Results', '<td>\r\n<p class="noteUnsized">Search Results</p>\r\n<br />\r\nWe have found the following <numberOfSearchResults> positions for you:<br />\r\n<searchResultsTable>\r\n</td>'),
(22, 'CATS Standard', 'Content - Job Details', '<td>\r\n<p class="noteUnsized">Job Details</p>\r\n<br>\r\n<table>\r\n<tr><td style="width:160px; font-weight:bold;">Title:</td><td><title></td></tr>\r\n<tr><td style="width:160px; font-weight:bold;">Date Created:</td><td><created></td></tr>\r\n<tr><td style="width:160px; font-weight:bold;">Location:</td><td><city>, <state></td></tr>\r\n<tr><td style="width:160px; font-weight:bold;">Openings:</td><td><openings></td></tr>\r\n</table>\r\n<br>\r\n<description><br />\r\n<br />\r\n<br>\r\n<a-applyToJob>Apply to Job</a><br>\r\n</td>'),
(23, 'CATS Standard', 'Content - Thanks for your Submission', '<td>\r\n<p class="noteUnsized">Apply to Position</p>\r\n<br>\r\n<br>\r\nThanks for your submission!<br>\r\n<br>\r\nYou should receive an e-mail confirmation of your submission shortly.<br>\r\n<br>\r\n\r\n<a-jobDetails>Go Back to Job Details</a>\r\n</td>'),
(24, 'Blank Page', 'Header', ''),
(25, 'Blank Page', 'Left', ''),
(26, 'Blank Page', 'Content - Main', ''),
(27, 'Blank Page', 'Content - Apply for Position', NULL),
(28, 'Blank Page', 'Content - Search Results', ''),
(29, 'Blank Page', 'Footer', ''),
(30, 'Blank Page', 'CSS', '');

-- --------------------------------------------------------

--
-- Table structure for table `job_board_template_site`
--

DROP TABLE IF EXISTS `job_board_template_site`;
CREATE TABLE IF NOT EXISTS `job_board_template_site` (
  `job_board_template_id` int(11) NOT NULL AUTO_INCREMENT,
  `job_board_name` varchar(96) NOT NULL,
  `site_id` int(11) NOT NULL,
  `setting` varchar(128) NOT NULL DEFAULT '',
  `value` text,
  PRIMARY KEY (`job_board_template_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `mailer_settings`
--

DROP TABLE IF EXISTS `mailer_settings`;
CREATE TABLE IF NOT EXISTS `mailer_settings` (
  `mailer_settings_id` int(11) NOT NULL AUTO_INCREMENT,
  `setting` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `entered_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`mailer_settings_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `messaging`
--

DROP TABLE IF EXISTS `messaging`;
CREATE TABLE IF NOT EXISTS `messaging` (
  `id` int(11) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL,
  `date_modified` date DEFAULT NULL,
  `date_created` date DEFAULT NULL,
  `date_sent` date DEFAULT NULL,
  `subject` varchar(128) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `message` varchar(512) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `status` varchar(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `user_id` int(11) DEFAULT NULL,
  `modifiedby_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `module_schema`
--

DROP TABLE IF EXISTS `module_schema`;
CREATE TABLE IF NOT EXISTS `module_schema` (
  `module_schema_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  PRIMARY KEY (`module_schema_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=27 ;

--
-- Dumping data for table `module_schema`
--

INSERT INTO `module_schema` (`module_schema_id`, `name`, `version`) VALUES
(1, 'wizard', 0),
(2, 'queue', 0),
(3, 'contacts', 0),
(4, 'import', 0),
(5, 'activity', 0),
(6, 'linkedin', 0),
(7, 'tests', 0),
(8, 'xml', 0),
(9, 'reports', 0),
(10, 'messaging', 0),
(11, 'install', 47),
(12, 'attachments', 0),
(13, 'settings', 0),
(14, 'calendar', 0),
(15, 'lists', 0),
(16, 'candidates', 0),
(17, 'toolbar', 0),
(18, 'rss', 0),
(19, 'login', 0),
(20, 'joborders', 0),
(21, 'home', 0),
(22, 'graphs', 0),
(23, 'specialization', 0),
(24, 'companies', 0),
(25, 'export', 0),
(26, 'careers', 0);

-- --------------------------------------------------------

--
-- Table structure for table `mru`
--

DROP TABLE IF EXISTS `mru`;
CREATE TABLE IF NOT EXISTS `mru` (
  `mru_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL DEFAULT '0',
  `data_item_type` int(11) NOT NULL DEFAULT '0',
  `data_item_text` varchar(64) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `url` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`mru_id`),
  KEY `IDX_user_site` (`user_id`,`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `queue`
--

DROP TABLE IF EXISTS `queue`;
CREATE TABLE IF NOT EXISTS `queue` (
  `queue_id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `task` varchar(125) NOT NULL,
  `args` text,
  `priority` tinyint(2) NOT NULL DEFAULT '5' COMMENT '1-5, 1 is highest priority',
  `date_created` datetime NOT NULL,
  `date_timeout` datetime NOT NULL,
  `date_completed` datetime DEFAULT NULL,
  `locked` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `error` tinyint(1) unsigned DEFAULT '0',
  `response` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`queue_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `saved_list`
--

DROP TABLE IF EXISTS `saved_list`;
CREATE TABLE IF NOT EXISTS `saved_list` (
  `saved_list_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(64) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `data_item_type` int(11) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL DEFAULT '0',
  `is_dynamic` int(1) DEFAULT '0',
  `datagrid_instance` varchar(64) COLLATE utf8_unicode_ci DEFAULT '',
  `parameters` text COLLATE utf8_unicode_ci,
  `created_by` int(11) DEFAULT '0',
  `number_entries` int(11) DEFAULT '0',
  `date_created` datetime DEFAULT NULL,
  `date_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`saved_list_id`),
  KEY `IDX_data_item_type` (`data_item_type`),
  KEY `IDX_description` (`description`),
  KEY `IDX_site_id` (`site_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `saved_list_entry`
--

DROP TABLE IF EXISTS `saved_list_entry`;
CREATE TABLE IF NOT EXISTS `saved_list_entry` (
  `saved_list_entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `saved_list_id` int(11) NOT NULL,
  `data_item_type` int(11) NOT NULL DEFAULT '0',
  `data_item_id` int(11) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime DEFAULT NULL,
  PRIMARY KEY (`saved_list_entry_id`),
  KEY `IDX_type_id` (`data_item_type`,`data_item_id`),
  KEY `IDX_data_item_type` (`data_item_type`),
  KEY `IDX_data_item_id` (`data_item_id`),
  KEY `IDX_hot_list_id` (`saved_list_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `saved_search`
--

DROP TABLE IF EXISTS `saved_search`;
CREATE TABLE IF NOT EXISTS `saved_search` (
  `search_id` int(11) NOT NULL AUTO_INCREMENT,
  `data_item_text` text COLLATE utf8_unicode_ci,
  `url` text COLLATE utf8_unicode_ci,
  `is_custom` int(1) DEFAULT NULL,
  `data_item_type` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  `date_created` datetime DEFAULT NULL,
  PRIMARY KEY (`search_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
CREATE TABLE IF NOT EXISTS `settings` (
  `settings_id` int(11) NOT NULL AUTO_INCREMENT,
  `setting` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `settings_type` int(11) DEFAULT '0',
  PRIMARY KEY (`settings_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=13 ;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`settings_id`, `setting`, `value`, `site_id`, `settings_type`) VALUES
(1, 'fromAddress', 'support@ignitedsolution.com', 1, 1),
(2, 'fromAddress', 'support@ignitedsolution.com', 180, 1),
(3, 'configured', '1', 1, 1),
(4, 'configured', '1', 180, 1),
(5, 'fromAddress', 'support@ignitedsolution.com', 1, 1),
(6, 'fromAddress', 'support@ignitedsolution.com', 180, 1),
(7, 'configured', '1', 1, 1),
(8, 'configured', '1', 180, 1),
(9, 'fromAddress', 'support@ignitedsolution.com', 1, 1),
(10, 'fromAddress', 'support@ignitedsolution.com', 180, 1),
(11, 'configured', '1', 1, 1),
(12, 'configured', '1', 180, 1);

-- --------------------------------------------------------

--
-- Table structure for table `site`
--

DROP TABLE IF EXISTS `site`;
CREATE TABLE IF NOT EXISTS `site` (
  `site_id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `is_demo` int(1) NOT NULL DEFAULT '0',
  `user_licenses` int(11) NOT NULL DEFAULT '0',
  `entered_by` int(11) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `unix_name` varchar(128) CHARACTER SET utf8 DEFAULT NULL,
  `client_id` int(11) DEFAULT NULL,
  `is_trial` int(1) NOT NULL DEFAULT '0',
  `is_free` int(1) NOT NULL,
  `trial_expires` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `account_active` int(1) NOT NULL DEFAULT '1',
  `account_deleted` int(1) NOT NULL DEFAULT '0',
  `reason_disabled` text CHARACTER SET utf8,
  `time_zone` int(5) DEFAULT '0',
  `time_format_24` int(1) DEFAULT '0',
  `date_format_ddmmyy` int(1) DEFAULT '0',
  `is_hr_mode` int(1) DEFAULT '0',
  `first_time_setup` tinyint(4) DEFAULT '0',
  `localization_configured` int(1) DEFAULT '0',
  `agreed_to_license` int(1) DEFAULT '0',
  `last_viewed_day` date DEFAULT NULL,
  `page_view_days` int(11) DEFAULT '0',
  `page_views` bigint(20) DEFAULT '0',
  `file_size_kb` int(11) DEFAULT '0',
  PRIMARY KEY (`site_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=181 ;

--
-- Dumping data for table `site`
--

INSERT INTO `site` (`site_id`, `company_id`, `name`, `is_demo`, `user_licenses`, `entered_by`, `date_created`, `unix_name`, `client_id`, `is_trial`, `is_free`, `trial_expires`, `account_active`, `account_deleted`, `reason_disabled`, `time_zone`, `time_format_24`, `date_format_ddmmyy`, `is_hr_mode`, `first_time_setup`, `localization_configured`, `agreed_to_license`, `last_viewed_day`, `page_view_days`, `page_views`, `file_size_kb`) VALUES
(1, 0, 'default_site', 0, 0, 0, '2016-06-23 14:16:46', NULL, NULL, 0, 1, '0000-00-00 00:00:00', 1, 0, NULL, -5, 0, 0, 0, 0, 0, 1, '2016-06-29', 2, 95, 0),
(180, 0, 'CATS_ADMIN', 0, 0, 0, '2005-06-01 00:00:00', 'catsadmin', NULL, 0, 0, '0000-00-00 00:00:00', 1, 0, NULL, -5, 0, 0, 0, 0, 0, 0, NULL, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `sph_counter`
--

DROP TABLE IF EXISTS `sph_counter`;
CREATE TABLE IF NOT EXISTS `sph_counter` (
  `counter_id` int(11) NOT NULL,
  `max_doc_id` int(11) NOT NULL,
  PRIMARY KEY (`counter_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `system`
--

DROP TABLE IF EXISTS `system`;
CREATE TABLE IF NOT EXISTS `system` (
  `system_id` int(20) NOT NULL DEFAULT '0',
  `uid` int(20) DEFAULT NULL,
  `avaliable_version` int(20) DEFAULT NULL,
  `date_version_checked` date NOT NULL,
  `avaliable_version_description` text,
  `disable_version_check` int(1) NOT NULL DEFAULT '0',
  `schema_version` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`system_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `system`
--

INSERT INTO `system` (`system_id`, `uid`, `avaliable_version`, `date_version_checked`, `avaliable_version_description`, `disable_version_check`, `schema_version`) VALUES
(0, 0, NULL, '0000-00-00', NULL, 0, 1200);

-- --------------------------------------------------------

--
-- Table structure for table `template`
--

DROP TABLE IF EXISTS `template`;
CREATE TABLE IF NOT EXISTS `template` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `modifiedby_id` int(11) NOT NULL,
  `title` varchar(55) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `content` varchar(512) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `emailsignature` varchar(512) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `shared_list` int(11) NOT NULL,
  `shared_group` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `date_created` date NOT NULL,
  `date_modified` date NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE IF NOT EXISTS `user` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `candidate_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `user_name` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  `access_level` int(11) NOT NULL DEFAULT '100',
  `can_change_password` int(1) NOT NULL DEFAULT '1',
  `is_test_user` int(1) NOT NULL DEFAULT '0',
  `last_name` varchar(40) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `first_name` varchar(40) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `is_demo` int(1) DEFAULT '0',
  `categories` varchar(192) COLLATE utf8_unicode_ci DEFAULT NULL,
  `session_cookie` varchar(48) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pipeline_entries_per_page` int(8) DEFAULT '15',
  `column_preferences` longtext COLLATE utf8_unicode_ci,
  `force_logout` int(1) DEFAULT '0',
  `title` varchar(64) COLLATE utf8_unicode_ci DEFAULT '',
  `phone_work` varchar(64) COLLATE utf8_unicode_ci DEFAULT '',
  `phone_cell` varchar(64) COLLATE utf8_unicode_ci DEFAULT '',
  `phone_other` varchar(64) COLLATE utf8_unicode_ci DEFAULT '',
  `address` text COLLATE utf8_unicode_ci,
  `notes` text COLLATE utf8_unicode_ci,
  `company` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip_code` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `can_see_eeo_info` int(1) DEFAULT '0',
  PRIMARY KEY (`user_id`),
  KEY `IDX_site_id` (`site_id`),
  KEY `IDX_first_name` (`first_name`),
  KEY `IDX_last_name` (`last_name`),
  KEY `IDX_access_level` (`access_level`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1251 ;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `candidate_id`, `site_id`, `user_name`, `email`, `password`, `access_level`, `can_change_password`, `is_test_user`, `last_name`, `first_name`, `is_demo`, `categories`, `session_cookie`, `pipeline_entries_per_page`, `column_preferences`, `force_logout`, `title`, `phone_work`, `phone_cell`, `phone_other`, `address`, `notes`, `company`, `city`, `state`, `zip_code`, `country`, `can_see_eeo_info`) VALUES
(1, 0, 1, 'admin', '', 'cats', 500, 1, 0, 'Administrator', 'CATS', 0, NULL, 'CATS=lhfqhd18egm3ro4l7n2b6nek07', 15, 'a:10:{s:31:"home:ImportantPipelineDashboard";a:6:{i:0;a:2:{s:4:"name";s:10:"First Name";s:5:"width";i:85;}i:1;a:2:{s:4:"name";s:9:"Last Name";s:5:"width";i:75;}i:2;a:2:{s:4:"name";s:6:"Status";s:5:"width";i:75;}i:3;a:2:{s:4:"name";s:8:"Position";s:5:"width";i:275;}i:4;a:2:{s:4:"name";s:7:"Company";s:5:"width";i:210;}i:5;a:2:{s:4:"name";s:8:"Modified";s:5:"width";i:80;}}s:18:"home:CallsDataGrid";a:2:{i:0;a:2:{s:4:"name";s:4:"Time";s:5:"width";i:90;}i:1;a:2:{s:4:"name";s:4:"Name";s:5:"width";i:175;}}s:19:"lists:ListsDataGrid";a:7:{i:0;a:2:{s:4:"name";s:5:"Count";s:5:"width";i:45;}i:1;a:2:{s:4:"name";s:11:"Description";s:5:"width";i:355;}i:2;a:2:{s:4:"name";s:9:"Data Type";s:5:"width";i:75;}i:3;a:2:{s:4:"name";s:9:"List Type";s:5:"width";i:75;}i:4;a:2:{s:4:"name";s:5:"Owner";s:5:"width";i:75;}i:5;a:2:{s:4:"name";s:7:"Created";s:5:"width";i:60;}i:6;a:2:{s:4:"name";s:8:"Modified";s:5:"width";i:60;}}s:35:"contacts:ContactsListByViewDataGrid";a:9:{i:0;a:2:{s:4:"name";s:11:"Attachments";s:5:"width";i:10;}i:1;a:2:{s:4:"name";s:10:"First Name";s:5:"width";i:80;}i:2;a:2:{s:4:"name";s:9:"Last Name";s:5:"width";i:80;}i:3;a:2:{s:4:"name";s:7:"Company";s:5:"width";i:135;}i:4;a:2:{s:4:"name";s:5:"Title";s:5:"width";i:135;}i:5;a:2:{s:4:"name";s:10:"Work Phone";s:5:"width";i:85;}i:6;a:2:{s:4:"name";s:5:"Owner";s:5:"width";i:85;}i:7;a:2:{s:4:"name";s:7:"Created";s:5:"width";i:60;}i:8;a:2:{s:4:"name";s:8:"Modified";s:5:"width";i:60;}}s:37:"companies:CompaniesListByViewDataGrid";a:9:{i:0;a:2:{s:4:"name";s:11:"Attachments";s:5:"width";i:10;}i:1;a:2:{s:4:"name";s:4:"Name";s:5:"width";i:255;}i:2;a:2:{s:4:"name";s:4:"Jobs";s:5:"width";i:40;}i:3;a:2:{s:4:"name";s:4:"City";s:5:"width";i:90;}i:4;a:2:{s:4:"name";s:5:"State";s:5:"width";i:50;}i:5;a:2:{s:4:"name";s:5:"Phone";s:5:"width";i:85;}i:6;a:2:{s:4:"name";s:5:"Owner";s:5:"width";i:65;}i:7;a:2:{s:4:"name";s:7:"Created";s:5:"width";i:60;}i:8;a:2:{s:4:"name";s:8:"Modified";s:5:"width";i:60;}}s:39:"candidates:candidatesListByViewDataGrid";a:9:{i:0;a:2:{s:4:"name";s:11:"Attachments";s:5:"width";i:31;}i:1;a:2:{s:4:"name";s:10:"First Name";s:5:"width";i:75;}i:2;a:2:{s:4:"name";s:9:"Last Name";s:5:"width";i:85;}i:3;a:2:{s:4:"name";s:4:"City";s:5:"width";i:75;}i:4;a:2:{s:4:"name";s:5:"State";s:5:"width";i:50;}i:5;a:2:{s:4:"name";s:10:"Key Skills";s:5:"width";i:215;}i:6;a:2:{s:4:"name";s:5:"Owner";s:5:"width";i:65;}i:7;a:2:{s:4:"name";s:7:"Created";s:5:"width";i:60;}i:8;a:2:{s:4:"name";s:8:"Modified";s:5:"width";i:60;}}s:37:"joborders:JobOrdersListByViewDataGrid";a:12:{i:0;a:2:{s:4:"name";s:11:"Attachments";s:5:"width";i:10;}i:1;a:2:{s:4:"name";s:2:"ID";s:5:"width";i:26;}i:2;a:2:{s:4:"name";s:5:"Title";s:5:"width";i:170;}i:3;a:2:{s:4:"name";s:7:"Company";s:5:"width";i:135;}i:4;a:2:{s:4:"name";s:4:"Type";s:5:"width";i:30;}i:5;a:2:{s:4:"name";s:6:"Status";s:5:"width";i:40;}i:6;a:2:{s:4:"name";s:7:"Created";s:5:"width";i:55;}i:7;a:2:{s:4:"name";s:3:"Age";s:5:"width";i:30;}i:8;a:2:{s:4:"name";s:9:"Submitted";s:5:"width";i:18;}i:9;a:2:{s:4:"name";s:8:"Pipeline";s:5:"width";i:18;}i:10;a:2:{s:4:"name";s:9:"Recruiter";s:5:"width";i:65;}i:11;a:2:{s:4:"name";s:5:"Owner";s:5:"width";i:55;}}s:25:"activity:ActivityDataGrid";a:7:{i:0;a:2:{s:4:"name";s:4:"Date";s:5:"width";i:110;}i:1;a:2:{s:4:"name";s:10:"First Name";s:5:"width";i:85;}i:2;a:2:{s:4:"name";s:9:"Last Name";s:5:"width";i:75;}i:3;a:2:{s:4:"name";s:9:"Regarding";s:5:"width";i:125;}i:4;a:2:{s:4:"name";s:8:"Activity";s:5:"width";i:65;}i:5;a:2:{s:4:"name";s:5:"Notes";s:5:"width";i:240;}i:6;a:2:{s:4:"name";s:10:"Entered By";s:5:"width";i:60;}}s:53:"candidates:candidatesSavedListByViewDataGrid:s:1:"1";";a:9:{i:0;a:2:{s:4:"name";s:11:"Attachments";s:5:"width";i:31;}i:1;a:2:{s:4:"name";s:10:"First Name";s:5:"width";i:75;}i:2;a:2:{s:4:"name";s:9:"Last Name";s:5:"width";i:85;}i:3;a:2:{s:4:"name";s:4:"City";s:5:"width";i:75;}i:4;a:2:{s:4:"name";s:5:"State";s:5:"width";i:50;}i:5;a:2:{s:4:"name";s:10:"Key Skills";s:5:"width";i:200;}i:6;a:2:{s:4:"name";s:5:"Owner";s:5:"width";i:65;}i:7;a:2:{s:4:"name";s:8:"Modified";s:5:"width";i:60;}i:8;a:2:{s:4:"name";s:13:"Added To List";s:5:"width";i:75;}}s:37:"messaging:messagingListByViewDataGrid";a:5:{i:0;a:2:{s:4:"name";s:7:"Subject";s:5:"width";i:150;}i:1;a:2:{s:4:"name";s:6:"Status";s:5:"width";i:40;}i:2;a:2:{s:4:"name";s:12:"Date Created";s:5:"width";i:150;}i:3;a:2:{s:4:"name";s:9:"Date Sent";s:5:"width";i:150;}i:4;a:2:{s:4:"name";s:11:"Modified By";s:5:"width";i:150;}}}', 0, '', '', '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(1250, 0, 180, 'cats@rootadmin', '0', 'cantlogin', 0, 0, 0, 'Automated', 'CATS', 0, NULL, NULL, 15, NULL, 0, '', '', '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `user_login`
--

DROP TABLE IF EXISTS `user_login`;
CREATE TABLE IF NOT EXISTS `user_login` (
  `user_login_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `site_id` int(11) NOT NULL DEFAULT '0',
  `ip` varchar(128) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `user_agent` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `successful` int(1) NOT NULL DEFAULT '0',
  `host` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date_refreshed` datetime DEFAULT NULL,
  PRIMARY KEY (`user_login_id`),
  KEY `IDX_user_id` (`user_id`),
  KEY `IDX_ip` (`ip`),
  KEY `IDX_date` (`date`),
  KEY `IDX_date_refreshed` (`date_refreshed`),
  KEY `IDX_site_id_date` (`site_id`,`date`),
  KEY `IDX_successful_site_id` (`successful`,`site_id`),
  KEY `IDX_successful` (`successful`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=8 ;

--
-- Dumping data for table `user_login`
--

INSERT INTO `user_login` (`user_login_id`, `user_id`, `site_id`, `ip`, `user_agent`, `date`, `successful`, `host`, `date_refreshed`) VALUES
(1, 1, 1, '142.205.241.254', 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36', '2016-06-24 11:02:28', 1, '142.205.241.254', '2016-06-24 11:02:28'),
(2, 1, 1, '142.205.241.254', 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36', '2016-06-24 11:04:03', 1, '142.205.241.254', '2016-06-24 11:38:04'),
(3, 1, 1, '142.205.241.254', 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36', '2016-06-24 14:41:14', 1, '142.205.241.254', '2016-06-24 14:42:04'),
(4, 1, 1, '142.205.241.254', 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36', '2016-06-29 12:51:18', 1, '142.205.241.254', '2016-06-29 12:51:18'),
(5, 1, 1, '142.205.241.254', 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36', '2016-06-29 12:51:52', 1, '142.205.241.254', '2016-06-29 12:51:52'),
(6, 1, 1, '142.205.241.254', 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36', '2016-06-29 12:52:01', 1, '142.205.241.254', '2016-06-29 12:52:01'),
(7, 1, 1, '142.205.241.254', 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36', '2016-06-29 12:52:35', 1, '142.205.241.254', '2016-06-29 12:57:06');

-- --------------------------------------------------------

--
-- Table structure for table `version`
--

DROP TABLE IF EXISTS `version`;
CREATE TABLE IF NOT EXISTS `version` (
  `db_version` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `version`
--

INSERT INTO `version` (`db_version`) VALUES
('0.5.5');

-- --------------------------------------------------------

--
-- Table structure for table `word_verification`
--

DROP TABLE IF EXISTS `word_verification`;
CREATE TABLE IF NOT EXISTS `word_verification` (
  `word_verification_ID` int(11) NOT NULL AUTO_INCREMENT,
  `word` varchar(28) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`word_verification_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `xml_feeds`
--

DROP TABLE IF EXISTS `xml_feeds`;
CREATE TABLE IF NOT EXISTS `xml_feeds` (
  `xml_feed_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `post_url` varchar(255) NOT NULL,
  `success_string` varchar(255) NOT NULL,
  `xml_template_name` varchar(255) NOT NULL,
  PRIMARY KEY (`xml_feed_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `xml_feeds`
--

INSERT INTO `xml_feeds` (`xml_feed_id`, `name`, `description`, `website`, `post_url`, `success_string`, `xml_template_name`) VALUES
(1, 'Indeed', 'Indeed.com job search engine.', 'http://www.indeed.com', 'http://www.indeed.com/jsp/includejobs.jsp', 'Thank you for submitting your XML job feed', 'indeed'),
(2, 'SimplyHired', 'SimplyHired.com job search engine', 'http://www.simplyhired.com', 'http://www.simplyhired.com/confirmation.php', 'Thanks for Contacting Us', 'simplyhired');

-- --------------------------------------------------------

--
-- Table structure for table `xml_feed_submits`
--

DROP TABLE IF EXISTS `xml_feed_submits`;
CREATE TABLE IF NOT EXISTS `xml_feed_submits` (
  `feed_id` int(11) NOT NULL AUTO_INCREMENT,
  `feed_site` varchar(75) NOT NULL,
  `feed_url` varchar(255) NOT NULL,
  `date_last_post` date NOT NULL,
  PRIMARY KEY (`feed_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `zipcodes`
--

DROP TABLE IF EXISTS `zipcodes`;
CREATE TABLE IF NOT EXISTS `zipcodes` (
  `zipcode` mediumint(9) NOT NULL DEFAULT '0',
  `city` tinytext COLLATE utf8_unicode_ci NOT NULL,
  `state` varchar(2) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `areacode` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`zipcode`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
