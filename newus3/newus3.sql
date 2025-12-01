-- =====================================================================
-- UltraScan LIMS - Central Registry Database Schema
-- =====================================================================
-- Database: newus3
-- Purpose:  Central registry for institution metadata and user accounts
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `newus3`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `newus3`;

-- =====================================================================
-- Table: metadata
-- Purpose: Institution registration and database connection information
-- =====================================================================
DROP TABLE IF EXISTS `metadata`;
CREATE TABLE `metadata` (
`metadataID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique institution ID',
`institution` varchar(255) DEFAULT NULL COMMENT 'Full institution name',
`inst_abbrev` varchar(10) DEFAULT NULL COMMENT 'Short institution code',
`dbname` varchar(30) DEFAULT NULL COMMENT 'Institution database name',
`dbuser` varchar(30) DEFAULT NULL COMMENT 'Database username',
`dbpasswd` varchar(30) DEFAULT NULL COMMENT 'Database password',
`dbhost` varchar(60) DEFAULT NULL COMMENT 'Database server hostname',
`limshost` varchar(60) DEFAULT NULL COMMENT 'LIMS web server hostname',
`secure_user` varchar(30) DEFAULT NULL COMMENT 'Secure connection username',
`secure_pw` varchar(30) DEFAULT NULL COMMENT 'Secure connection password',
`admin_fname` varchar(30) DEFAULT NULL COMMENT 'Administrator first name',
`admin_lname` varchar(30) DEFAULT NULL COMMENT 'Administrator last name',
`admin_email` varchar(128) NOT NULL COMMENT 'Administrator email',
`admin_pw` varchar(80) NOT NULL COMMENT 'Administrator password hash',
`lab_name` text COMMENT 'Laboratory name',
`lab_contact` text COMMENT 'Laboratory contact information',
`location` varchar(255) NOT NULL DEFAULT '' COMMENT 'Physical location/address',
`instrument_name` text COMMENT 'Primary instrument name',
`instrument_serial` text COMMENT 'Instrument serial number',
`status` enum('pending','denied','completed') DEFAULT 'pending' COMMENT 'Registration approval status',
`updateTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last update timestamp',
PRIMARY KEY (`metadataID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Institution registration and provisioning information';

-- =====================================================================
-- Table: people
-- Purpose: User account and authentication information
-- =====================================================================
DROP TABLE IF EXISTS `people`;
CREATE TABLE `people` (
`personID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique user ID',
`fname` varchar(30) DEFAULT NULL COMMENT 'First name',
`lname` varchar(30) DEFAULT NULL COMMENT 'Last name',
`address` varchar(255) DEFAULT NULL COMMENT 'Street address',
`city` varchar(30) DEFAULT NULL COMMENT 'City',
`state` char(2) DEFAULT NULL COMMENT 'State/province code',
`zip` varchar(10) DEFAULT NULL COMMENT 'Postal code',
`country` varchar(64) DEFAULT NULL COMMENT 'Country',
`phone` varchar(24) DEFAULT NULL COMMENT 'Contact phone number',
`email` varchar(63) NOT NULL COMMENT 'Email address (unique, used for login)',
`organization` varchar(45) DEFAULT NULL COMMENT 'Organization/institution affiliation',
`username` varchar(80) DEFAULT NULL COMMENT 'Login username',
`password` varchar(80) NOT NULL COMMENT 'Password hash',
`activated` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Account activation status (0=inactive, 1=active)',
`signup` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Account creation timestamp',
`lastLogin` datetime DEFAULT NULL COMMENT 'Most recent login timestamp',
`userlevel` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Permission level (0=user, higher=admin)',
PRIMARY KEY (`personID`),
UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='User accounts and authentication';