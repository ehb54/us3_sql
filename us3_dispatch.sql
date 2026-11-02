-- Dispatch scheduler tables in each LIMS instance database: requests, attempts and events.
-- The one definition: us3.sql, the upgrade migrations and new instances all load this file.
-- CREATE TABLE IF NOT EXISTS only, so it is safe to run against a live database.

CREATE TABLE IF NOT EXISTS dispatch_request (
  dispatchRequestID int(11) NOT NULL AUTO_INCREMENT,
  logicalKey varchar(191) NOT NULL,
  HPCAnalysisRequestID int(11) DEFAULT NULL,
  autoflowAnalysisID int(11) DEFAULT NULL,
  stageName varchar(32) NOT NULL DEFAULT 'interactive',
  stageOccurrence int(11) NOT NULL DEFAULT 1,
  parentBatchKey varchar(191) DEFAULT NULL,
  batchSealed tinyint(1) NOT NULL DEFAULT 1,
  submitterID int(11) NOT NULL,
  investigatorID int(11) NOT NULL,
  pool varchar(64) NOT NULL,
  pinnedCluster varchar(64) DEFAULT NULL,
  state enum('PENDING','ASSESSING','WAITING','BLOCKED','STAGING','SUBMITTING','SUBMISSION_UNKNOWN','ACCEPTED','MONITORED','CLOSED','FAILED','EXPIRED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  claimOwner varchar(128) DEFAULT NULL,
  claimGeneration int(11) NOT NULL DEFAULT 0,
  claimExpiresAt datetime DEFAULT NULL,
  cancelRequested tinyint(1) NOT NULL DEFAULT 0,
  retryAt datetime DEFAULT NULL,
  deadlineAt datetime NOT NULL,
  notifyAt datetime DEFAULT NULL,
  notifiedAt datetime DEFAULT NULL,
  policyVersion varchar(16) DEFAULT NULL,
  planHash varchar(16) DEFAULT NULL,
  selectedCluster varchar(64) DEFAULT NULL,
  inputRef varchar(255) NOT NULL DEFAULT '',
  inputChecksum varchar(64) NOT NULL,
  intakeChecksum varchar(64) NOT NULL DEFAULT '',
  priorityDirective text,
  reason text,
  reasonCode varchar(32) DEFAULT NULL,
  createdAt datetime NOT NULL,
  updatedAt datetime NOT NULL,
  PRIMARY KEY (dispatchRequestID),
  UNIQUE KEY logicalKey (logicalKey),
  KEY ready (state, retryAt),
  KEY batch (parentBatchKey),
  KEY request (HPCAnalysisRequestID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Dispatch requests (one per HPC request or batch child)';

CREATE TABLE IF NOT EXISTS dispatch_attempt (
  attemptID int(11) NOT NULL AUTO_INCREMENT,
  dispatchRequestID int(11) NOT NULL,
  attemptToken varchar(40) NOT NULL,
  cluster varchar(64) NOT NULL,
  planHash varchar(16) NOT NULL,
  planJson mediumtext NOT NULL,
  artifactChecksum varchar(64) DEFAULT NULL,
  phase enum('INTENT','ACCEPTED','NOT_ACCEPTED','UNKNOWN') NOT NULL DEFAULT 'INTENT',
  schedulerJobID varchar(80) DEFAULT NULL,
  outcomeReason varchar(255) DEFAULT NULL,
  createdAt datetime NOT NULL,
  resolvedAt datetime DEFAULT NULL,
  PRIMARY KEY (attemptID),
  UNIQUE KEY attemptToken (attemptToken),
  UNIQUE KEY schedulerJob (cluster, schedulerJobID),
  KEY request (dispatchRequestID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Submission attempts: intent before sbatch, then outcome';

CREATE TABLE IF NOT EXISTS dispatch_event (
  eventID int(11) NOT NULL AUTO_INCREMENT,
  dispatchRequestID int(11) NOT NULL,
  fromState varchar(24) DEFAULT NULL,
  toState varchar(24) NOT NULL,
  claimGeneration int(11) NOT NULL,
  reason text,
  createdAt datetime NOT NULL,
  PRIMARY KEY (eventID),
  KEY request (dispatchRequestID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Append-only dispatch state history';
