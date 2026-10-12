-- =====================================================================
-- UltraScan LIMS - Grid/Job Management Database Schema
-- =====================================================================
-- Database: gfac
-- Purpose:  HPC job submission tracking and cluster status monitoring
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `gfac`
  CHARACTER SET latin1
  COLLATE latin1_swedish_ci;

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
`metaschedulerClusterExecuting` varchar(64) DEFAULT NULL COMMENT 'Metascheduler cluster',
`us3_db` varchar(32) DEFAULT NULL COMMENT 'Institution database name',
`autoflowAnalysisID` int(11) DEFAULT NULL COMMENT 'AutoFlow analysis ID if applicable',
`stdout` longtext COMMENT 'Job standard output',
`stderr` longtext COMMENT 'Job standard error output',
`tarfile` mediumblob COMMENT 'Result archive file',
`status` enum('SUBMITTED','SUBMIT_TIMEOUT','RUNNING','RUN_TIMEOUT','DATA','DATA_TIMEOUT','COMPLETE','CANCELLED','CANCELED','FAILED','FAILED_DATA','ERROR') DEFAULT 'SUBMITTED' COMMENT 'Current job status',
`queue_msg` text COMMENT 'Queue system messages',
`time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last status update timestamp',
PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci
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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci
  COMMENT='HPC cluster status and availability monitoring';

-- =====================================================================
-- Table: metascheduler_decision
-- Purpose: Queryable record of every pick_cluster() routing decision, so an
--          operator can answer "why did job X land on cluster Y" (or "why
--          didn't it submit at all") after the fact without grepping a flat
--          log file. Written by pick_cluster_reserve() (home/us3/lims/bin/
--          gridctl/pick_cluster_reserve.php), the one shared entry point
--          both the autoflow (submitone.php) and interactive
--          (web/us3/lib/require_cluster.php) submission paths call.
-- =====================================================================
DROP TABLE IF EXISTS `metascheduler_decision`;
CREATE TABLE `metascheduler_decision` (
`id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique decision ID',
`pseudo_cluster` varchar(120) NOT NULL COMMENT 'Metascheduler pool name that was resolved',
`chosen` varchar(120) DEFAULT NULL COMMENT 'Real cluster chosen, or NULL when none was eligible',
`reason` varchar(255) DEFAULT NULL COMMENT 'pick_cluster() reason string for the outcome',
`tier` varchar(32) DEFAULT NULL COMMENT 'Tier the chosen cluster belongs to (local/national/...), NULL when nothing chosen',
`scores` text COMMENT 'JSON-encoded pick_cluster() scores for every candidate, for full post-hoc diagnosis',
`time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'When this decision was made',
PRIMARY KEY (`id`),
KEY `pseudo_cluster_time` (`pseudo_cluster`, `time`),
KEY `time` (`time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci
  COMMENT='Queryable history of metascheduler pick_cluster() decisions';

-- =====================================================================
-- Table: cluster_status_nudge
-- Purpose: Short-lived ledger of pick_cluster_reserve() decisions, read by
--          pick_cluster_status_snapshot() and added on top of the real
--          cluster_status probe row so two decisions made moments apart
--          never both read the same stale "idle" picture. Separate from
--          cluster_status itself (which only a real probe ever writes) so
--          a nudge can expire on its own after nudge_ttl_seconds instead of
--          persisting, wrongly, until the next probe (every 12 minutes by
--          default) -- see METASCHEDULER-DESIGN.md.
-- =====================================================================
DROP TABLE IF EXISTS `cluster_status_nudge`;
CREATE TABLE `cluster_status_nudge` (
`id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique nudge ID',
`cluster` varchar(64) NOT NULL COMMENT 'Real cluster this decision was nudged onto',
`time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'When this decision was made',
PRIMARY KEY (`id`),
KEY `cluster_time` (`cluster`, `time`),
KEY `time` (`time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci
  COMMENT='Short-lived pick_cluster_reserve() load nudges, independent of the real cluster_status probe';

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci
  COMMENT='Queue system message log for job tracking';
