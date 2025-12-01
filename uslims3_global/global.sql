-- =====================================================================
-- UltraScan LIMS - Global Database Schema
-- =====================================================================
-- Database: uslims3_global
-- Purpose:  Global shared data for cross-institution tracking
-- Version:  1.0
-- Last Modified: 2025-11-27
-- =====================================================================

-- Database creation (idempotent)
CREATE DATABASE IF NOT EXISTS `uslims3_global`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `uslims3_global`;

-- =====================================================================
-- Table: investigators
-- Purpose: Global registry of investigators across all institutions
-- =====================================================================
DROP TABLE IF EXISTS `investigators`;
CREATE TABLE `investigators` (
`invGlobal_ID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Global unique investigator ID',
`InvestigatorID` int(11) NOT NULL COMMENT 'Institution-local investigator ID',
`Investigator_Name` varchar(61) DEFAULT NULL COMMENT 'Full name of investigator',
`db` varchar(30) DEFAULT NULL COMMENT 'Institution database name',
`Email` varchar(100) DEFAULT NULL COMMENT 'Contact email address',
`Signup` datetime DEFAULT NULL COMMENT 'Account creation timestamp',
`LastLogin` datetime DEFAULT NULL COMMENT 'Most recent login timestamp',
`Userlevel` tinyint(4) DEFAULT '0' COMMENT 'User permission level (0=user, higher=admin)',
PRIMARY KEY (`invGlobal_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Global investigator registry across all institutions';

-- =====================================================================
-- Table: submissions
-- Purpose: Global tracking of HPC job submissions and resource usage
-- =====================================================================
DROP TABLE IF EXISTS `submissions`;
CREATE TABLE `submissions` (
`HPCGlobal_ID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Global unique submission ID',
`HPCAnalysis_ID` int(11) NOT NULL COMMENT 'Institution-local analysis ID',
`db` varchar(30) DEFAULT NULL COMMENT 'Institution database name',
`DateTime` datetime DEFAULT NULL COMMENT 'Job submission timestamp',
`EndDateTime` datetime DEFAULT NULL COMMENT 'Job completion timestamp',
`CPUTime` double DEFAULT NULL COMMENT 'Total CPU hours consumed',
`Cluster_Name` varchar(80) DEFAULT NULL COMMENT 'HPC cluster hostname',
`CPU_Number` int(11) DEFAULT NULL COMMENT 'Number of CPUs allocated',
`Result_Count` int(11) DEFAULT '1' COMMENT 'Number of result files generated',
`InvestigatorID` int(11) NOT NULL COMMENT 'Investigator who owns the analysis',
`Investigator_Name` varchar(61) DEFAULT NULL COMMENT 'Investigator full name (denormalized)',
`SubmitterID` int(11) NOT NULL COMMENT 'User who submitted the job',
`Submitter_Name` varchar(61) DEFAULT NULL COMMENT 'Submitter full name (denormalized)',
PRIMARY KEY (`HPCGlobal_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Global HPC job submission tracking and resource usage';