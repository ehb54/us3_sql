--
-- us3_refScan_procs.sql
--
-- Script to set up the MySQL stored procedures for the US3 system
--   These are related to the extinctionProfile table
-- Run as us3admin
--

DELIMITER $$

-- SELECTs information from the experiment table
DROP PROCEDURE IF EXISTS get_info_for_referenceScan$$
CREATE PROCEDURE get_info_for_referenceScan ( p_personGUID CHAR(36),
                                              p_password   VARCHAR(80),
                                              p_runID      VARCHAR(255) )
  READS SQL DATA

BEGIN
  DECLARE count_experiments INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_userlevel( p_personGUID, p_password, @US3_ADMIN ) = @OK ) THEN
    -- Only admin can get info
    SELECT COUNT(*)
    INTO   count_experiments
    FROM   experiment
    WHERE  runID            = p_runID;    
    
    IF ( count_experiments = 0 ) THEN
      SET @US3_LAST_ERRNO = @NOROWS;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';
      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status; 
      SELECT experimentID, projectID, runID, instrumentID, operatorID, type,
             runType, timestamp2UTC( dateBegin ) AS UTC_dateBegin, timestamp2UTC( dateUpdated ) AS UTC_dateUpdated
      FROM   experiment
      WHERE  runID              = p_runID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$


-- SELECTs information of records from the referenceScan table
DROP PROCEDURE IF EXISTS get_referenceScan_info$$
CREATE PROCEDURE get_referenceScan_info ( p_personGUID CHAR(36),
                                          p_password   VARCHAR(80) )
  READS SQL DATA

BEGIN
  DECLARE count_reference_data INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_userlevel( p_personGUID, p_password, @US3_ANALYST ) = @OK ) THEN
    -- All analysts can get info
    SELECT COUNT(*)
    INTO   count_reference_data
    FROM   referenceScan;
    
    IF ( count_reference_data = 0 ) THEN
      SET @US3_LAST_ERRNO = @NOROWS;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';
      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status; 
      SELECT ID, instrumentID, personID, type, experimentIDs,
             timestamp2UTC( referenceTime ) AS UTC_referenceTime,
             nWavelength, nPoints, startWavelength, stopWavelength, 
             data IS NULL AS null_data,
             timestamp2UTC( lastUpdated ) AS UTC_lastUpdated
      FROM   referenceScan;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$


-- INSERTs a new record to the referenceScan table
DROP PROCEDURE IF EXISTS new_referenceScanRecord$$
CREATE PROCEDURE new_referenceScanRecord ( p_personGUID      CHAR(36),
                                           p_password        VARCHAR(80),
                                           p_instrumentID    INT,
                                           p_personID        INT,
                                           p_type            CHAR(2),
                                           p_experimentIDs   VARCHAR(250),
                                           p_referenceTime   VARCHAR(20),
                                           p_nWavelength     INT,
                                           p_nPoints         INT,
                                           p_startWavelength DECIMAL(4, 1),
                                           p_stopWavelength  DECIMAL(4, 1))
  MODIFIES SQL DATA

BEGIN

  DECLARE null_field    TINYINT DEFAULT 0;
  DECLARE duplicate_key TINYINT DEFAULT 0;

  DECLARE CONTINUE HANDLER FOR 1048
    SET null_field = 1;

  DECLARE CONTINUE HANDLER FOR 1062
    SET duplicate_key = 1;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;
 
  IF ( verify_userlevel( p_personGUID, p_password, @US3_ADMIN ) = @OK ) THEN
    -- Only admin can add new data
 
    INSERT INTO referenceScan SET
      instrumentID    = p_instrumentID,
      personID        = p_personID, 
      type            = p_type,
      experimentIDs    = p_experimentIDs,
      referenceTime   = DATE(p_referenceTime),
      nWavelength     = p_nWavelength,
      nPoints         = p_nPoints,
      startWavelength = p_startWavelength,
      stopWavelength  = p_stopWavelength,
      lastUpdated     = NOW();
   
    IF ( null_field = 1 ) THEN
      SET @US3_LAST_ERRNO = @INSERTNULL;
      SET @US3_LAST_ERROR = "MySQL: Attempt to insert NULL value in the rawData table";

    ELSEIF ( duplicate_key = 1 ) THEN
      SET @US3_LAST_ERRNO = @DUPFIELD;
      SET @US3_LAST_ERROR = CONCAT( "MySQL: The experimentIDs ",
                                    p_experimentIDs,
                                    " already exists in the referenceScan table" );
      
    ELSE
      SET @LAST_INSERT_ID  = LAST_INSERT_ID();

    END IF;
   
   END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- UPDATEs the blob data of the referenceScan table
DROP PROCEDURE IF EXISTS upload_referenceScanData$$
CREATE PROCEDURE upload_referenceScanData ( p_personGUID   CHAR(36),
                                        p_password     VARCHAR(80),
                                        p_refDataID    INT,
                                        p_data         LONGBLOB,
                                        p_checksum     CHAR(33) )
  MODIFIES SQL DATA

BEGIN
  DECLARE l_checksum     CHAR(33);
  DECLARE not_found      TINYINT DEFAULT 0;

  DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET not_found = 1;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
 
  -- Compare checksum with calculated checksum
  SET l_checksum = MD5( p_data );
  SET @DEBUG = CONCAT( l_checksum , ' ', p_checksum );

  IF ( l_checksum != p_checksum ) THEN

    -- Checksums don't match; abort
    SET @US3_LAST_ERRNO = @BAD_CHECKSUM;
    SET @US3_LAST_ERROR = "MySQL: Transmission error, bad checksum";

  ELSEIF ( verify_userlevel( p_personGUID, p_password, @US3_ADMIN ) = @OK ) THEN
 
    -- Only admin can add new data
    UPDATE referenceScan SET
      data           = p_data
    WHERE  ID = p_refDataID;

    IF ( not_found = 1 ) THEN
      SET @US3_LAST_ERRNO = @NO_RAWDATA;
      SET @US3_LAST_ERROR = "MySQL: No raw data with that ID exists";

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- SELECTs the blob data of the referenceScan table
DROP PROCEDURE IF EXISTS download_referenceScanData$$
CREATE PROCEDURE download_referenceScanData ( p_personGUID   CHAR(36),
                                          p_password     VARCHAR(80),
                                          p_refDataID    INT )
  READS SQL DATA

BEGIN
  DECLARE l_count_refData INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
 
  -- Get information to verify that there are records
  SELECT COUNT(*)
  INTO   l_count_refData
  FROM   referenceScan
  WHERE  ID = p_refDataID;

SET @DEBUG = CONCAT('Reference Scan ID = ', p_refDataID,
                    'Count = ', l_count_refData );

  IF ( l_count_refData != 1 ) THEN
    -- Probably no rows
    SET @US3_LAST_ERRNO = @NOROWS;
    SET @US3_LAST_ERROR = 'MySQL: no rows exist with that ID (or too many rows)';

    SELECT @NOROWS AS status;
    
  ELSEIF ( verify_userlevel( p_personGUID, p_password, @US3_ANALYST ) != @OK ) THEN
 
    -- verify_user_permission
    SELECT @US3_LAST_ERRNO AS status;

  ELSE

    SELECT @OK AS status;

    SELECT data, MD5( data )
    FROM   referenceScan
    WHERE  ID = p_refDataID;

  END IF;

END$$


-- UPDATEs to clear a record from the referenceScan table
DROP PROCEDURE IF EXISTS clear_referenceScanRecord$$
CREATE PROCEDURE clear_referenceScanRecord ( p_personGUID   CHAR(36),
                                             p_password     VARCHAR(80),
                                             p_refDataID    INT )
  MODIFIES SQL DATA

BEGIN
  DECLARE l_count_refData INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
 
  -- Get information to verify that there are records
  SELECT COUNT(*)
  INTO   l_count_refData
  FROM   referenceScan
  WHERE  ID = p_refDataID;

SET @DEBUG = CONCAT('Reference Scan ID = ', p_refDataID,
                    'Count = ', l_count_refData );

  IF ( l_count_refData != 1 ) THEN
    -- Probably no rows
    SET @US3_LAST_ERRNO = @NOROWS;
    SET @US3_LAST_ERROR = 'MySQL: no rows exist with that ID (or too many rows)';

    SELECT @NOROWS AS status;
    
  ELSEIF ( verify_userlevel( p_personGUID, p_password, @US3_ADMIN ) != @OK ) THEN
 
    -- verify_user_permission
    SELECT @US3_LAST_ERRNO AS status;

  ELSE

    SELECT @OK AS status;

    UPDATE referenceScan SET
      experimentIDs    = "-1",
      nWavelength     = 0,
      nPoints         = 0,
      startWavelength = 0,
      stopWavelength  = 0,
      data            = NULL,
      lastUpdated     = NOW()
    WHERE ID = p_refDataID;

  END IF;

END$$

