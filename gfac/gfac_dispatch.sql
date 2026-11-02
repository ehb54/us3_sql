-- Dispatch scheduler tables in gfac: controller claims, rotation state, turn events, decisions, alerts and heartbeats.
-- The one definition: us3.sql, the upgrade migrations and new instances all load this file.
-- CREATE TABLE IF NOT EXISTS only, so it is safe to run against a live database.

CREATE TABLE IF NOT EXISTS dispatch_controller_claim (
  controller varchar(128) NOT NULL,
  claimOwner varchar(128) DEFAULT NULL,
  claimGeneration int(11) NOT NULL DEFAULT 0,
  claimExpiresAt datetime DEFAULT NULL,
  PRIMARY KEY (controller)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='One availability-decision lane per shared scheduler';

CREATE TABLE IF NOT EXISTS dispatch_rotation (
  scopeKey varchar(191) NOT NULL,
  stateJson text NOT NULL,
  updatedAt datetime NOT NULL,
  PRIMARY KEY (scopeKey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Rotation state per instance, pool, group and policy version';

CREATE TABLE IF NOT EXISTS dispatch_turn_event (
  turnEventID int(11) NOT NULL AUTO_INCREMENT,
  scopeKey varchar(191) NOT NULL,
  unitKey varchar(191) NOT NULL,
  member varchar(64) NOT NULL,
  roundTotal int(11) NOT NULL,
  attemptToken varchar(40) DEFAULT NULL,
  status enum('PROVISIONAL','CONFIRMED','REFUNDED') NOT NULL DEFAULT 'PROVISIONAL',
  createdAt datetime NOT NULL,
  resolvedAt datetime DEFAULT NULL,
  PRIMARY KEY (turnEventID),
  UNIQUE KEY unit (scopeKey, unitKey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='One turn per dispatch unit: spent, confirmed or refunded once';

CREATE TABLE IF NOT EXISTS dispatch_decision (
  decisionID int(11) NOT NULL AUTO_INCREMENT,
  instanceDb varchar(64) NOT NULL,
  dispatchRequestID int(11) NOT NULL,
  pool varchar(64) NOT NULL,
  policyVersion varchar(16) NOT NULL,
  outcome varchar(16) NOT NULL,
  chosen varchar(64) DEFAULT NULL,
  reason text,
  candidatesJson mediumtext,
  policyJson text,
  createdAt datetime NOT NULL,
  PRIMARY KEY (decisionID),
  KEY request (instanceDb, dispatchRequestID),
  KEY created (createdAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Request-linked dispatch decision history';

CREATE TABLE IF NOT EXISTS dispatch_alert (
  alertID int(11) NOT NULL AUTO_INCREMENT,
  dedupKey varchar(191) NOT NULL,
  kind varchar(32) NOT NULL,
  urgency enum('urgent','normal') NOT NULL,
  destination varchar(64) DEFAULT NULL,
  instanceDb varchar(64) DEFAULT NULL,
  detail text,
  firstAt datetime NOT NULL,
  lastAt datetime NOT NULL,
  resolvedAt datetime DEFAULT NULL,
  resolution varchar(255) DEFAULT NULL,
  emailedAt datetime DEFAULT NULL,
  openFlag tinyint(1) DEFAULT 1,
  PRIMARY KEY (alertID),
  UNIQUE KEY openItem (dedupKey, openFlag),
  KEY instance (instanceDb, resolvedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Operator alert items; one open item per condition';

CREATE TABLE IF NOT EXISTS dispatch_alert_request (
  alertID int(11) NOT NULL,
  instanceDb varchar(64) NOT NULL,
  dispatchRequestID int(11) NOT NULL,
  PRIMARY KEY (alertID, instanceDb, dispatchRequestID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Requests affected by an alert item, per instance';

CREATE TABLE IF NOT EXISTS dispatch_heartbeat (
  worker varchar(128) NOT NULL,
  beatAt datetime NOT NULL,
  PRIMARY KEY (worker)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Dispatch worker liveness, checked independently';
