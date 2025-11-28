-- =====================================================================
-- UltraScan LIMS - Grid/Job Management Database Schema
-- =====================================================================
-- Database: gfac
-- Purpose:  HPC job submission tracking and cluster status monitoring
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `gfac`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `gfac`;

-- =====================================================================
-- Table: analysis
-- Purpose: Track individual HPC analysis job submissions and results
-- =====================================================================
DROP TABLE IF EXISTS `analysis`;
CREATE TABLE `analysis` (
`id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique analysis job ID',
`gfacID` varchar(80) DEFAULT NULL COMMENT 'Grid/cluster job identifier',
`cluster` varchar(64) DEFAULT NULL COMMENT 'Target cluster name',
`us3_db` varchar(32) DEFAULT NULL COMMENT 'Institution database name',
`autoflowAnalysisID` int(11) DEFAULT NULL COMMENT 'AutoFlow analysis ID if applicable',
`stdout` longtext COMMENT 'Job standard output',
`stderr` longtext COMMENT 'Job standard error output',
`tarfile` mediumblob COMMENT 'Result archive file',
`status` enum('SUBMITTED','SUBMIT_TIMEOUT','RUNNING','RUN_TIMEOUT','DATA','DATA_TIMEOUT','COMPLETE','CANCELLED','CANCELED','FAILED','FAILED_DATA','ERROR') DEFAULT 'SUBMITTED' COMMENT 'Current job status',
`queue_msg` text COMMENT 'Queue system messages',
`time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last status update timestamp',
PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='HPC analysis job tracking and results';

-- =====================================================================
-- Table: cluster_status
-- Purpose: Monitor current state and queue depth of HPC clusters
-- =====================================================================
DROP TABLE IF EXISTS `cluster_status`;
CREATE TABLE `cluster_status` (
`cluster` varchar(120) NOT NULL COMMENT 'Cluster hostname/identifier',
`queued` int(11) DEFAULT NULL COMMENT 'Number of jobs in queue',
`running` int(11) DEFAULT NULL COMMENT 'Number of jobs currently running',
`status` enum('up','down','warn','unknown') DEFAULT 'up' COMMENT 'Cluster operational status',
`time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last status check timestamp',
PRIMARY KEY (`cluster`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='HPC cluster status and availability monitoring';

-- =====================================================================
-- Table: queue_messages
-- Purpose: Log of queue system messages for analysis jobs
-- =====================================================================
DROP TABLE IF EXISTS `queue_messages`;
CREATE TABLE `queue_messages` (
`messageID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique message ID',
`analysisID` int(11) NOT NULL COMMENT 'Related analysis job ID',
`message` text COMMENT 'Queue system message content',
`time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Message timestamp',
PRIMARY KEY (`messageID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Queue system message log for job tracking';