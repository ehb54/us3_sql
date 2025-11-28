-- =====================================================================
-- UltraScan LIMS - Notice System Database Schema
-- =====================================================================
-- Database: us3_notice
-- Purpose:  System-wide notices and version update notifications
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `us3_notice`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `us3_notice`;

-- =====================================================================
-- Table: notice
-- Purpose: Store system notices for UltraScan client updates and alerts
-- =====================================================================
DROP TABLE IF EXISTS `notice`;

CREATE TABLE `notice` (
`id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique notice ID',
`type` enum('info','warn','crit') NOT NULL COMMENT 'Notice severity: info, warn, or crit',
`revision` varchar(12) DEFAULT NULL COMMENT 'UltraScan version this notice applies to',
`message` longtext DEFAULT NULL COMMENT 'Notice message text (may contain URLs)',
`lastUpdated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last modification timestamp',
PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='System notices for UltraScan client version updates and alerts';