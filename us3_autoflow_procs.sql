--
-- us3_autoflow_procs.sql
--
-- Script to set up the MySQL stored procedures for the US3 system
--   These are related to various tables pertaining to autoflow
-- Run as root
--

DELIMITER $$

--
-- Autoflow procedures
--


-- check if run [filename] is required by GMP (autoflow, autoflowHistory tables)
DROP FUNCTION IF EXISTS check_filename_for_autoflow$$
CREATE FUNCTION check_filename_for_autoflow ( p_personGUID  CHAR(36),
                                   	      p_password    VARCHAR(80),
					      p_filename    varchar(300) )
  RETURNS INT
  READS SQL DATA					      
  
BEGIN
  DECLARE count_runs   INT;
  DECLARE count_runs_h INT;
  DECLARE f_template   VARCHAR(300);

  SET count_runs = 0;
  SET count_runs_h = 0;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SET f_template = CONCAT('%', p_filename, '%');

  SELECT COUNT(*) INTO count_runs 
  FROM autoflow 
  WHERE filename like f_template;

  SELECT COUNT(*) INTO count_runs_h
  FROM autoflowHistory
  WHERE filename like f_template;


  RETURN( count_runs + count_runs_h );

END$$



-- Returns the count of autoflow records in db
DROP FUNCTION IF EXISTS count_autoflow_records$$
CREATE FUNCTION count_autoflow_records ( p_personGUID CHAR(36),
                                       p_password   VARCHAR(80) )
                                       
  RETURNS INT
  READS SQL DATA

BEGIN

  DECLARE count_records INT;

  CALL config();
  SET count_records = 0;

       
  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    SELECT    COUNT(*)
    INTO      count_records
    FROM      autoflow
    WHERE     devRecord = "NO";
    
  END IF;

  RETURN( count_records );

END$$

-- Returns the count of autoflow DEV records in db
DROP FUNCTION IF EXISTS count_autoflow_dev_records$$
CREATE FUNCTION count_autoflow_dev_records ( p_personGUID CHAR(36),
                                   	     p_password   VARCHAR(80) )
                                       
  RETURNS INT
  READS SQL DATA

BEGIN

  DECLARE count_records INT;

  CALL config();
  SET count_records = 0;

       
  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    SELECT    COUNT(*)
    INTO      count_records
    FROM      autoflow
    WHERE     devRecord = "YES";
    
  END IF;

  RETURN( count_records );

END$$


-- Returns the count of editedData profiles for a givel label ---
DROP FUNCTION IF EXISTS count_editprofiles$$
CREATE FUNCTION count_editprofiles ( p_personGUID CHAR(36),
                                     p_password   VARCHAR(80),
				     p_label      VARCHAR(80) )
                                       
  RETURNS INT
  READS SQL DATA

BEGIN

  DECLARE count_records INT;

  CALL config();
  SET count_records = 0;

       
  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    SELECT    COUNT(*)
    INTO      count_records
    FROM      editedData
    WHERE     label = p_label;
    
  END IF;

  RETURN( count_records );

END$$





-- adds autoflow record
DROP PROCEDURE IF EXISTS add_autoflow_record$$
CREATE PROCEDURE add_autoflow_record ( p_personGUID  CHAR(36),
                                     p_password      VARCHAR(80),
                                     p_protname      VARCHAR(80),
                                     p_cellchnum     VARCHAR(80),
                                     p_triplenum     VARCHAR(80),
				     p_duration      INT,
				     p_runname       VARCHAR(80),
				     p_expid         INT,
				     p_optimaname    VARCHAR(300),
				     p_invID         INT,
				     p_label         VARCHAR(80),
				     p_gmprun        VARCHAR(80),
				     p_aprofileguid  VARCHAR(80),
                                     p_operatorID    INT,
				     p_expType       VARCHAR(80) )
                                    
  MODIFIES SQL DATA

BEGIN
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflow SET
      protname          = p_protname,
      cellChNum         = p_cellchnum,
      tripleNum         = p_triplenum,
      duration          = p_duration,
      runName           = p_runname,
      expID             = p_expid,
      optimaName        = p_optimaname,
      invID             = p_invID,
      label		= p_label,
      created           = NOW(),
      gmpRun            = p_gmprun,
      aprofileGUID      = p_aprofileguid,
      operatorID        = p_operatorID,
      expType           = p_expType;

    SET @LAST_INSERT_ID = LAST_INSERT_ID();

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- adds autoflow record for data disk
DROP PROCEDURE IF EXISTS add_autoflow_record_datadisk$$
CREATE PROCEDURE add_autoflow_record_datadisk  ( p_personGUID  CHAR(36),
                                     	       p_password      VARCHAR(80),
                                     	       p_protname      VARCHAR(80),
                                     	       p_cellchnum     VARCHAR(80),
                                     	       p_triplenum     VARCHAR(80),
				     	       p_duration      INT,
				     	       p_runname       VARCHAR(80),
				     	       p_invID         INT,
				     	       p_label         VARCHAR(80),
				     	       p_gmprun        VARCHAR(80),
				     	       p_aprofileguid  VARCHAR(80),
                                     	       p_operatorID    INT,
				     	       p_expType       VARCHAR(80),
					       p_dataPath      VARCHAR(300),
					       p_optimaname    VARCHAR(300),
					       p_dataSource    VARCHAR(80)  )
                                    
  MODIFIES SQL DATA

BEGIN
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflow SET
      protname          = p_protname,
      cellChNum         = p_cellchnum,
      tripleNum         = p_triplenum,
      duration          = p_duration,
      runName           = p_runname,
      invID             = p_invID,
      label		= p_label,
      created           = NOW(),
      gmpRun            = p_gmprun,
      aprofileGUID      = p_aprofileguid,
      operatorID        = p_operatorID,
      expType           = p_expType,
      dataPath          = p_dataPath,
      status            = 'EDITING',
      corrRadii         = 'NO',
      optimaName        = p_optimaname,
      dataSource        = p_dataSource;

    SET @LAST_INSERT_ID = LAST_INSERT_ID();

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- adds autoflow record for ProtDev
DROP PROCEDURE IF EXISTS add_autoflow_record_dev$$
CREATE PROCEDURE add_autoflow_record_dev ( p_personGUID  CHAR(36),
                                     	  p_password      VARCHAR(80),
                                     	  p_protname      VARCHAR(80),
                                     	  p_cellchnum     VARCHAR(80),
                                     	  p_triplenum     VARCHAR(80),
				     	  p_duration      INT,
				     	  p_runname       VARCHAR(80),
				     	  p_expid         INT,
					  p_optimaname    VARCHAR(300),
					  p_invID         INT,
					  p_label         VARCHAR(80),
					  p_aprofileguid  VARCHAR(80),
					  p_operatorID    INT,
					  p_expType       TEXT,
					  p_dataPath      VARCHAR(300),
					  p_dataSource    TEXT,
					  p_status	  TEXT,
					  p_filenameProtDev VARCHAR(300) )
					                                      
  MODIFIES SQL DATA

BEGIN
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF (p_dataPath = '') THEN SET p_dataPath = NULL; END IF;
  IF (p_filenameProtDev = '') THEN SET p_filenameProtDev = NULL; END IF;
  
  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflow SET
      protname          = p_protname,
      cellChNum         = p_cellchnum,
      tripleNum         = p_triplenum,
      duration          = p_duration,
      runName           = p_runname,
      expID             = p_expid,
      optimaName        = p_optimaname,
      invID             = p_invID,
      created           = NOW(),
      label		= p_label,
      gmpRun            = 'YES',
      aprofileGUID      = p_aprofileguid,
      operatorID        = p_operatorID,
      devRecord         = 'YES',
      expType           = p_expType,
      dataPath          = p_dataPath,
      dataSource        = p_dataSource,
      status            = p_status,
      filenameProtDevDataDisk = p_filenameProtDev;
      
    SET @LAST_INSERT_ID = LAST_INSERT_ID();

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Mark DEV autoflowHistory record as 'Processed'
DROP PROCEDURE IF EXISTS mark_autoflowHistoryDevRun_Processed$$
CREATE PROCEDURE mark_autoflowHistoryDevRun_Processed ( p_personGUID  CHAR(36),
                                     	  	      p_password      VARCHAR(80),
                                     	  	      p_ID            INT )
                                    
  MODIFIES SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowHistory
  WHERE      ID = p_ID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowHistory
      SET      devRecord = 'Processed'
      WHERE    ID = p_ID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- adds autoflow record for ProtDev [OLD - when starting from 4. EDIT]
DROP PROCEDURE IF EXISTS add_autoflow_record_dev_old$$
CREATE PROCEDURE add_autoflow_record_dev_old ( p_personGUID  CHAR(36),
                                     	 p_password      VARCHAR(80),
                                     	 p_protname      VARCHAR(80),
                                     	 p_cellchnum     VARCHAR(80),
                                     	 p_triplenum     VARCHAR(80),
				     	 p_duration      INT,
				     	 p_runname       VARCHAR(80),
				     	 p_expid         INT,
					 p_runID         INT,
					 p_dataPath      VARCHAR(300),
					 p_optimaname    VARCHAR(300),
					 p_runStarted    TEXT,
					 p_invID         INT,
					 p_correctRadii  TEXT,
					 p_aborted       TEXT,
					 p_label         VARCHAR(80),
					 p_filename      VARCHAR(300),
				     	 p_aprofileguid  VARCHAR(80),
					 p_operatorID    INT )
                                    
  MODIFIES SQL DATA

BEGIN
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflow SET
      protname          = p_protname,
      cellChNum         = p_cellchnum,
      tripleNum         = p_triplenum,
      duration          = p_duration,
      runName           = p_runname,
      expID             = p_expid,
      runID             = p_runID,
      status            = 'EDIT_DATA',
      dataPath          = p_dataPath,
      optimaName        = p_optimaname,
      runStarted        = p_runStarted,
      invID             = p_invID,
      created           = NOW(),
      corrRadii         = p_correctRadii,
      expAborted        = p_aborted,
      label		= p_label,
      gmpRun            = 'NO',
      filename          = p_filename,
      aprofileGUID      = p_aprofileguid,
      operatorID        = p_operatorID,
      devRecord         = 'YES';

    SET @LAST_INSERT_ID = LAST_INSERT_ID();

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- adds autoflowHistory record
DROP PROCEDURE IF EXISTS new_autoflow_history_record$$
CREATE PROCEDURE new_autoflow_history_record ( p_personGUID  CHAR(36),
                                     p_password      VARCHAR(80),
                                     p_ID            INT )
                                    
  MODIFIES SQL DATA

BEGIN
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowHistory SELECT * FROM autoflow WHERE ID = p_ID;
    
    SET @LAST_INSERT_ID = LAST_INSERT_ID();

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- adds autoflowStages record
DROP PROCEDURE IF EXISTS add_autoflow_stages_record$$
CREATE PROCEDURE add_autoflow_stages_record ( p_personGUID  CHAR(36),
                                            p_password      VARCHAR(80),
                                            p_id      INT )

  MODIFIES SQL DATA

BEGIN
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowStages SET
      autoflowID        = p_id;

    SET @LAST_INSERT_ID = LAST_INSERT_ID();

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$






-- DELETE  autoflow record ( when Optima run aborted manually )
DROP PROCEDURE IF EXISTS delete_autoflow_record$$
CREATE PROCEDURE delete_autoflow_record ( p_personGUID    CHAR(36),
                                     	p_password      VARCHAR(80),
                			p_runID         INT,
                                        p_optima        VARCHAR(300) )
  MODIFIES SQL DATA

BEGIN
  DECLARE count_records INT;	
  
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    
    -- Find out if record exists for associated runID 
    SELECT COUNT(*) INTO count_records 
    FROM autoflow 
    WHERE runID = p_runID AND optimaName = p_optima;

    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'Record cannot be deleted as it does not exist for current experiment run';   

    ELSE
      DELETE FROM autoflow
      WHERE runID = p_runID AND optimaName = p_optima;
    
    END IF;  

  END IF;
      
  SELECT @US3_LAST_ERRNO AS status;

END$$




-- DELETE  autoflow record by ID 
DROP PROCEDURE IF EXISTS delete_autoflow_record_by_id$$
CREATE PROCEDURE delete_autoflow_record_by_id ( p_personGUID    CHAR(36),
                                     	      p_password      VARCHAR(80),
                			      p_ID            INT )
  MODIFIES SQL DATA

BEGIN
  DECLARE count_records INT;	
  DECLARE count_records_stages INT;	

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    
    -- Find out if record exists for associated runID 
    SELECT COUNT(*) INTO count_records 
    FROM autoflow 
    WHERE ID = p_ID;

    -- Find out if record exists for associated pID 
    SELECT COUNT(*) INTO count_records_stages 
    FROM autoflowStages 
    WHERE autoflowID = p_ID;



    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'Record cannot be deleted as it does not exist for current experiment run';   

    ELSE
      DELETE FROM autoflow
      WHERE ID = p_ID;
    
    END IF;

    IF ( count_records_stages > 0 ) THEN
       DELETE FROM autoflowStages
       WHERE autoflowID = p_ID;

    END IF;   

  END IF;
      
  SELECT @US3_LAST_ERRNO AS status;

END$$



-- DELETE  autoflowStages record by ID 
DROP PROCEDURE IF EXISTS delete_autoflow_stages_record$$
CREATE PROCEDURE delete_autoflow_stages_record ( p_personGUID    CHAR(36),
                                     	       p_password      VARCHAR(80),
                			       p_ID            INT )
  MODIFIES SQL DATA

BEGIN
  
  DECLARE count_records_stages INT;	

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    
    -- Find out if record exists for associated pID 
    SELECT COUNT(*) INTO count_records_stages 
    FROM autoflowStages 
    WHERE autoflowID = p_ID;

    IF ( count_records_stages > 0 ) THEN
       DELETE FROM autoflowStages
       WHERE autoflowID = p_ID;

    END IF;   

  END IF;
      
  SELECT @US3_LAST_ERRNO AS status;

END$$



-- Returns complete information about autoflow record
DROP PROCEDURE IF EXISTS read_autoflow_record$$
CREATE PROCEDURE read_autoflow_record ( p_personGUID    CHAR(36),
                                       	p_password      VARCHAR(80),
                                       	p_autoflowID  INT )
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      ID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   protName, cellChNum, tripleNum, duration, runName, expID, 
      	       runID, status, dataPath, optimaName, runStarted, invID, created, 
	       corrRadii, expAborted, label, gmpRun, filename, aprofileGUID, analysisIDs,
               intensityID, statusID, failedID, operatorID, devRecord, gmpReviewID, expType,
	       dataSource, opticsFailedType, filenameProtDevDataDisk
      FROM     autoflow 
      WHERE    ID = p_autoflowID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$

-- Returns complete information about autoflowHistory record
DROP PROCEDURE IF EXISTS read_autoflow_history_record$$
CREATE PROCEDURE read_autoflow_history_record ( p_personGUID    CHAR(36),
                                       	        p_password      VARCHAR(80),
                                       	        p_autoflowID  INT )
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowHistory
  WHERE      ID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   protName, cellChNum, tripleNum, duration, runName, expID, 
      	       runID, status, dataPath, optimaName, runStarted, invID, created, 
	       corrRadii, expAborted, label, gmpRun, filename, aprofileGUID, analysisIDs,
               intensityID, statusID, failedID, operatorID, devRecord, gmpReviewID, expType,
	       dataSource, opticsFailedType, filenameProtDevDataDisk
      FROM     autoflowHistory 
      WHERE    ID = p_autoflowID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$


-- Returns information about autoflow records for listing
DROP PROCEDURE IF EXISTS get_autoflow_desc$$
CREATE PROCEDURE get_autoflow_desc ( p_personGUID    CHAR(36),
                                     p_password      VARCHAR(80) )
                                     
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      devRecord = "NO";


  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   ID, protName, cellChNum, tripleNum, duration, runName, expID, 
      	       runID, status, dataPath, optimaName, runStarted, invID, created, gmpRun, filename, operatorID, failedID  
      FROM     autoflow
      WHERE    devRecord = "NO";
     
    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$

-- Returns information about autoflow DEV records for listing
DROP PROCEDURE IF EXISTS get_autoflow_dev_desc$$
CREATE PROCEDURE get_autoflow_dev_desc ( p_personGUID    CHAR(36),
                                         p_password      VARCHAR(80) )
                                     
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      devRecord = "YES";


  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   ID, protName, cellChNum, tripleNum, duration, runName, expID, 
      	       runID, status, dataPath, optimaName, runStarted, invID, created, gmpRun, filename,
	       operatorID, failedID, devRecord, dataSource, filenameProtDevDataDisk   
      FROM     autoflow
      WHERE    devRecord = "YES";
     
    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$





-- Returns information about autoflowHistory records for listing
DROP PROCEDURE IF EXISTS get_autoflow_history_desc$$
CREATE PROCEDURE get_autoflow_history_desc ( p_personGUID    CHAR(36),
                                       	     p_password      VARCHAR(80) )
                                     
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowHistory;


  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   ID, protName, cellChNum, tripleNum, duration, runName, expID, 
      	       runID, status, dataPath, optimaName, runStarted, invID, created, gmpRun, filename,
	       operatorID, failedID, devRecord, dataSource, filenameProtDevDataDisk   
      FROM     autoflowHistory;
     
    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$




-- Update autoflow record with Optima's RunID (ONLY once, first time )
DROP PROCEDURE IF EXISTS update_autoflow_runid_starttime$$
CREATE PROCEDURE update_autoflow_runid_starttime ( p_personGUID    CHAR(36),
                                         	 p_password      VARCHAR(80),
                                       	 	 p_expID    	 INT,
					 	 p_runid    	 INT,
                                                 p_optima        VARCHAR(300) )
  MODIFIES SQL DATA  

BEGIN
  DECLARE curr_runid INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     runID
  INTO       curr_runid
  FROM       autoflow
  WHERE      expID = p_expID AND optimaName = p_optima;


  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( curr_runid IS NULL ) THEN
      UPDATE   autoflow
      SET      runID = p_runid, runStarted = NOW()
      WHERE    expID = p_expID AND optimaName = p_optima;

    END IF;

  END IF;

 -- SELECT @US3_LAST_ERRNO AS status;

END$$


-- Update autoflow record with next stage && curDir at LIVE_UPDATE
DROP PROCEDURE IF EXISTS update_autoflow_at_live_update$$
CREATE PROCEDURE update_autoflow_at_live_update ( p_personGUID    CHAR(36),
                                             	p_password      VARCHAR(80),
                                       	     	p_runID    	 INT,
					  	p_curDir        VARCHAR(300),
                                                p_optima        VARCHAR(300)  )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      runID = p_runID AND optimaName = p_optima;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflow
      SET      dataPath = p_curDir, status = 'EDITING'
      WHERE    runID = p_runID AND optimaName = p_optima;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- Update autoflow record with corrRadii value at LIVE_UPDATE
DROP PROCEDURE IF EXISTS update_autoflow_at_live_update_radiicorr$$
CREATE PROCEDURE update_autoflow_at_live_update_radiicorr ( p_personGUID    CHAR(36),
                                             	p_password      VARCHAR(80),
                                       	     	p_runID    	 INT,
                                                p_optima         VARCHAR(300)   )
					 
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      runID = p_runID AND optimaName = p_optima;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflow
      SET      corrRadii = 'NO'
      WHERE    runID = p_runID AND optimaName = p_optima;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- Update autoflow record with expAborted value at LIVE_UPDATE
DROP PROCEDURE IF EXISTS update_autoflow_at_live_update_expaborted$$
CREATE PROCEDURE update_autoflow_at_live_update_expaborted ( p_personGUID    CHAR(36),
                                             	p_password      VARCHAR(80),
                                       	     	p_runID    	 INT,
                                                p_optima        VARCHAR(300) )
					 
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      runID = p_runID AND optimaName = p_optima;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflow
      SET      expAborted = 'YES'
      WHERE    runID = p_runID AND optimaName = p_optima;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- Update autoflow record with expAborted_[REMOTELY] at LIVE_UPDATE
DROP PROCEDURE IF EXISTS update_autoflow_at_live_update_expaborted_remotely$$
CREATE PROCEDURE update_autoflow_at_live_update_expaborted_remotely ( p_personGUID    CHAR(36),
                                             			    p_password      VARCHAR(80),
								    p_statusID      INT,
                                       	     			    p_runID    	    INT,
                                                		    p_optima        VARCHAR(300) )
					 
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      runID = p_runID AND optimaName = p_optima;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflow
      SET      expAborted = 'YES', statusID = p_statusID
      WHERE    runID = p_runID AND optimaName = p_optima;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$

-- Update autoflow record with opticsFailedType(s) at LIVE_UPDATE
DROP PROCEDURE IF EXISTS update_autoflow_at_live_update_optics_types_failed$$
CREATE PROCEDURE update_autoflow_at_live_update_optics_types_failed( p_personGUID      CHAR(36),
                                             			    p_password         VARCHAR(80),
								    p_opticsFailedType VARCHAR(300),
                                       	     			    p_runID    	       INT,
                                                		    p_optima           VARCHAR(300) )
					 
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      runID = p_runID AND optimaName = p_optima;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflow
      SET      opticsFailedType = p_opticsFailedType
      WHERE    runID = p_runID AND optimaName = p_optima;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- Update autoflow record with next stage && filename at EDITING (LIMS IMPORT)
DROP PROCEDURE IF EXISTS update_autoflow_at_lims_import$$
CREATE PROCEDURE update_autoflow_at_lims_import ( p_personGUID    CHAR(36),
                                             	p_password      VARCHAR(80),
                                       	       	p_filename      VARCHAR(300),
                                                p_intensityID   INT,
						p_statusID      INT,
						p_autoflowID    INT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      ID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflow
      SET      filename = p_filename, status = 'EDIT_DATA', intensityID = p_intensityID, statusID = p_statusID
      WHERE    ID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Update autoflow record with next stage && filename at EDITING (LIMS IMPORT: dataDisk)
DROP PROCEDURE IF EXISTS update_autoflow_at_lims_import_dataDisk$$
CREATE PROCEDURE update_autoflow_at_lims_import_dataDisk ( p_personGUID    CHAR(36),
                                             		 p_password      VARCHAR(80),
                                       	       		 p_filename      VARCHAR(300),
                                                	 p_intensityID   INT,
							 p_statusID      INT,
							 p_autoflowID    INT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      ID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflow
      SET      filename = p_filename,
      	       filenameProtDevDataDisk = p_filename,
      	       status = 'EDIT_DATA',
	       intensityID = p_intensityID,
	       statusID = p_statusID
      WHERE    ID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- Update autoflow record with next stage at EDIT DATA (EDIT DATA to ANALYSIS)
DROP PROCEDURE IF EXISTS update_autoflow_at_edit_data$$
CREATE PROCEDURE update_autoflow_at_edit_data ( p_personGUID    CHAR(36),
                                             	p_password      VARCHAR(80),
                                       	   	p_analysisIDs   TEXT,
                                                p_autoflowID    INT )
					 
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      ID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflow
      SET      status = 'ANALYSIS', analysisIDs = p_analysisIDs
      WHERE    ID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Update autoflow record with next stage at ANALYSIS (ANALYSIS  to REPORT)
DROP PROCEDURE IF EXISTS update_autoflow_at_analysis$$
CREATE PROCEDURE update_autoflow_at_analysis   ( p_personGUID    CHAR(36),
                                             	p_password       VARCHAR(80),
                                                p_autoflowID     INT  )
					 
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      ID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflow
      SET      status = 'REPORT'
      WHERE    ID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$

-- Update autoflow record with next stage at REPORT (REPORT to E-SIGNS)
DROP PROCEDURE IF EXISTS update_autoflow_at_report$$
CREATE PROCEDURE update_autoflow_at_report   ( p_personGUID    CHAR(36),
                                               p_password      VARCHAR(80),
					       p_autoflowID     INT )		       
					 
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      ID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflow
      SET      status = 'E-SIGNATURES'
      WHERE    ID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- - Create record in the autoflowAnalysis table -------------------------

DROP FUNCTION IF EXISTS new_autoflow_analysis_record$$
CREATE FUNCTION new_autoflow_analysis_record ( p_personGUID CHAR(36),
                                      	      p_password   VARCHAR(80),
					      p_triplename TEXT,
					      p_filename   TEXT,
					      p_aprofileguid CHAR(36),
					      p_invID    int(11),
					      p_json TEXT,
					      p_autoflowID int(11) )
                                       
  RETURNS INT
  MODIFIES SQL DATA

BEGIN

  DECLARE record_id INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowAnalysis SET
      tripleName        = p_triplename,
      filename          = p_filename,
      aprofileGUID      = p_aprofileguid,
      invID             = p_invID,	
      statusJson        = p_json,
      autoflowID        = p_autoflowID;
     
    SELECT LAST_INSERT_ID() INTO record_id;

  END IF;

  RETURN( record_id );

END$$

-- -- read AutoflowAnalysis record -------------------------------------------
DROP PROCEDURE IF EXISTS read_autoflowAnalysis_record$$
CREATE PROCEDURE read_autoflowAnalysis_record ( p_personGUID    CHAR(36),
                                      	       	p_password      VARCHAR(80),
                                       		p_requestID  INT )
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowAnalysis
  WHERE      requestID = p_requestID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   requestID, tripleName, clusterDefault, filename, aprofileGUID, invID, currentGfacID,
      	       currentHPCARID, statusJson, status, statusMsg, createTime, updateTime, createUser, updateUser,
               nextWaitStatus, nextWaitStatusMsg
      FROM     autoflowAnalysis 
      WHERE    requestID = p_requestID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$


-- -- read AutoflowAnalysis record -------------------------------------------
DROP PROCEDURE IF EXISTS read_autoflowAnalysisHistory_record$$
CREATE PROCEDURE read_autoflowAnalysisHistory_record ( p_personGUID    CHAR(36),
                                      	       	     p_password      VARCHAR(80),
                                       		     p_requestID  INT )
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowAnalysisHistory
  WHERE      requestID = p_requestID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   requestID, tripleName, clusterDefault, filename, aprofileGUID, invID, currentGfacID, 
      	       currentHPCARID, statusJson, status, statusMsg, createTime, updateTime, createUser, updateUser,
               nextWaitStatus, nextWaitStatusMsg
      FROM     autoflowAnalysisHistory 
      WHERE    requestID = p_requestID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$



-- Update autoflowAnalysis record with COMPLETE status and msg at FITMEN stage 
DROP PROCEDURE IF EXISTS update_autoflow_analysis_record_at_fitmen$$
CREATE PROCEDURE update_autoflow_analysis_record_at_fitmen ( p_personGUID  CHAR(36),
                                             		   p_password      VARCHAR(80),
                                       	     		   p_requestID     INT  )
					 
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;
  DECLARE current_status TEXT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowAnalysis
  WHERE      requestID = p_requestID;

  SELECT     status
  INTO       current_status
  FROM	     autoflowAnalysis
  WHERE	     requestID = p_requestID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowAnalysis
      SET      nextWaitStatus = 'COMPLETE', nextWaitStatusMsg = 'The manual stage has been completed'
      WHERE    requestID = p_requestID;
	

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- New record in the autoflowAnalysisStages table ---
DROP PROCEDURE IF EXISTS new_autoflow_analysis_stages_record$$
CREATE PROCEDURE new_autoflow_analysis_stages_record ( p_personGUID CHAR(36),
                                      	            p_password   VARCHAR(80),
					            p_requestID  INT(11) )
					                                                
  MODIFIES SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowAnalysisStages
  WHERE      requestID = p_requestID;


  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records > 0 ) THEN
      DELETE FROM autoflowAnalysisStages
      WHERE requestID = p_requestID;

    END IF;

    INSERT INTO autoflowAnalysisStages SET
      requestID         = p_requestID;
    
  END IF;

END$$


-- Update and return status of the LIVE UPDATE while trying to switch to IMPORT ---
DROP PROCEDURE IF EXISTS autoflow_liveupdate_status$$
CREATE PROCEDURE autoflow_liveupdate_status ( p_personGUID CHAR(36),
                                              p_password   VARCHAR(80),
                                              p_id  INT )

  -- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
  DECLARE current_status TEXT;
  DECLARE unique_start TINYINT DEFAULT 0;
       

  DECLARE exit handler for sqlexception
   BEGIN
      -- ERROR
    ROLLBACK;
   END;
   
  DECLARE exit handler for sqlwarning
   BEGIN
     -- WARNING
    ROLLBACK;
   END;


  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';


  START TRANSACTION;
  
  SELECT     liveUpdate 
  INTO       current_status
  FROM       autoflowStages
  WHERE      autoflowID = p_id FOR UPDATE;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( current_status = 'unknown' ) THEN
      UPDATE  autoflowStages
      SET     liveUpdate = 'STARTED'
      WHERE   autoflowID = p_id;

      SET unique_start = 1;

    END IF;

  END IF;

  SELECT unique_start as status;
  -- RETURN (unique_start);
  COMMIT;

END$$


-- Revert liveUpdate status in autoflowStages record ---
DROP PROCEDURE IF EXISTS autoflow_liveupdate_status_revert$$
CREATE PROCEDURE autoflow_liveupdate_status_revert ( p_personGUID CHAR(36),
                                                   p_password   VARCHAR(80),
                                                   p_id  INT )

  -- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
  DECLARE current_status TEXT;
  -- DECLARE unique_start TINYINT DEFAULT 0;
       
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  
  SELECT     liveUpdate 
  INTO       current_status
  FROM       autoflowStages
  WHERE      autoflowID = p_id;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( current_status != 'unknown' ) THEN
      UPDATE  autoflowStages
      SET     liveUpdate = DEFAULT
      WHERE   autoflowID = p_id;

    END IF;

  END IF;

  -- SELECT unique_start as status;
  -- RETURN (unique_start);
  
END$$





-- Update and return status of the IMPORT while trying to switch to EDITING ---
DROP PROCEDURE IF EXISTS autoflow_import_status$$
CREATE PROCEDURE autoflow_import_status ( p_personGUID CHAR(36),
                                          p_password   VARCHAR(80),
                                          p_id  INT )

  -- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
  DECLARE current_status TEXT;
  DECLARE unique_start TINYINT DEFAULT 0;
       

  DECLARE exit handler for sqlexception
   BEGIN
      -- ERROR
    ROLLBACK;
   END;
   
  DECLARE exit handler for sqlwarning
   BEGIN
     -- WARNING
    ROLLBACK;
   END;


  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';


  START TRANSACTION;
  
  SELECT     import 
  INTO       current_status
  FROM       autoflowStages
  WHERE      autoflowID = p_id FOR UPDATE;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( current_status = 'unknown' ) THEN
      UPDATE  autoflowStages
      SET     import = 'STARTED'
      WHERE   autoflowID = p_id;

      SET unique_start = 1;

    END IF;

  END IF;

  SELECT unique_start as status;
  -- RETURN (unique_start);
  COMMIT;

END$$


-- Revert IMPORT status in autoflowStages record ---
DROP PROCEDURE IF EXISTS autoflow_import_status_revert$$
CREATE PROCEDURE autoflow_import_status_revert ( p_personGUID CHAR(36),
                                                 p_password   VARCHAR(80),
                                                 p_id  INT )

  -- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
  DECLARE current_status TEXT;
  -- DECLARE unique_start TINYINT DEFAULT 0;
       
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  
  SELECT     import 
  INTO       current_status
  FROM       autoflowStages
  WHERE      autoflowID = p_id;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( current_status != 'unknown' ) THEN
      UPDATE  autoflowStages
      SET     import = DEFAULT
      WHERE   autoflowID = p_id;

    END IF;

  END IF;

  -- SELECT unique_start as status;
  -- RETURN (unique_start);
  
END$$



-- Update and return status of the EDIT while trying to switch to ANALYSIS ---
DROP PROCEDURE IF EXISTS autoflow_edit_status$$
CREATE PROCEDURE autoflow_edit_status ( p_personGUID CHAR(36),
                                        p_password   VARCHAR(80),
                                        p_id  INT )

  -- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
  DECLARE current_status TEXT;
  DECLARE unique_start TINYINT DEFAULT 0;
       

  DECLARE exit handler for sqlexception
   BEGIN
      -- ERROR
    ROLLBACK;
   END;
   
  DECLARE exit handler for sqlwarning
   BEGIN
     -- WARNING
    ROLLBACK;
   END;


  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';


  START TRANSACTION;
  
  SELECT     editing 
  INTO       current_status
  FROM       autoflowStages
  WHERE      autoflowID = p_id FOR UPDATE;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( current_status = 'unknown' ) THEN
      UPDATE  autoflowStages
      SET     editing = 'STARTED'
      WHERE   autoflowID = p_id;

      SET unique_start = 1;

    END IF;

  END IF;

  SELECT unique_start as status;
  -- RETURN (unique_start);
  COMMIT;

END$$


-- Revert EDIT status in autoflowStages record ---
DROP PROCEDURE IF EXISTS autoflow_edit_status_revert$$
CREATE PROCEDURE autoflow_edit_status_revert ( p_personGUID CHAR(36),
                                               p_password   VARCHAR(80),
                                               p_id  INT )

  -- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
  DECLARE current_status TEXT;
  -- DECLARE unique_start TINYINT DEFAULT 0;
       
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  
  SELECT     editing 
  INTO       current_status
  FROM       autoflowStages
  WHERE      autoflowID = p_id;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( current_status != 'unknown' ) THEN
      UPDATE  autoflowStages
      SET     editing = DEFAULT
      WHERE   autoflowID = p_id;

    END IF;

  END IF;

  -- SELECT unique_start as status;
  -- RETURN (unique_start);
  
END$$








-- Update and return status of the FITMEN while trying to update edit profiles ---
DROP PROCEDURE IF EXISTS fitmen_autoflow_analysis_status$$
CREATE PROCEDURE fitmen_autoflow_analysis_status ( p_personGUID CHAR(36),
                                              p_password   VARCHAR(80),
                                              p_requestID  INT )

  -- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
  DECLARE current_status TEXT;
  DECLARE unique_start TINYINT DEFAULT 0;
       

  DECLARE exit handler for sqlexception
   BEGIN
      -- ERROR
    ROLLBACK;
   END;
   
  DECLARE exit handler for sqlwarning
   BEGIN
     -- WARNING
    ROLLBACK;
   END;


  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';


  START TRANSACTION;
  
  SELECT     analysisFitmen 
  INTO       current_status
  FROM       autoflowAnalysisStages
  WHERE      requestID = p_requestID FOR UPDATE;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( current_status = 'unknown' ) THEN
      UPDATE  autoflowAnalysisStages
      SET     analysisFitmen = 'STARTED'
      WHERE   requestID = p_requestID;

      SET unique_start = 1;

    END IF;

  END IF;

  SELECT unique_start as status;
  -- RETURN (unique_start);
  COMMIT;

END$$



-- Revert FITMEN status in autoflowAnalysisStages record ---
DROP PROCEDURE IF EXISTS fitmen_autoflow_analysis_status_revert$$
CREATE PROCEDURE fitmen_autoflow_analysis_status_revert ( p_personGUID CHAR(36),
                                                        p_password   VARCHAR(80),
                                                        p_id  INT )

  -- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
  DECLARE current_status TEXT;
  -- DECLARE unique_start TINYINT DEFAULT 0;
       
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  
  SELECT     analysisFitmen 
  INTO       current_status
  FROM       autoflowAnalysisStages
  WHERE      requestID = p_id;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( current_status != 'unknown' ) THEN
      UPDATE  autoflowAnalysisStages
      SET     analysisFitmen = DEFAULT
      WHERE   requestID = p_id;

    END IF;

  END IF;

  -- SELECT unique_start as status;
  -- RETURN (unique_start);
  
END$$


-- Update and return status of the ABDE analysis while trying to update ABDE profiles ---
DROP PROCEDURE IF EXISTS autoflow_abde_analysis_status$$
CREATE PROCEDURE autoflow_abde_analysis_status( p_personGUID CHAR(36),
                                              p_password   VARCHAR(80),
                                              p_ID         INT )

  -- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
  DECLARE current_status TEXT;
  DECLARE unique_start TINYINT DEFAULT 0;
       

  DECLARE exit handler for sqlexception
   BEGIN
      -- ERROR
    ROLLBACK;
   END;
   
  DECLARE exit handler for sqlwarning
   BEGIN
     -- WARNING
    ROLLBACK;
   END;


  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';


  START TRANSACTION;
  
  SELECT     analysisABDE
  INTO       current_status
  FROM       autoflowAnalysisABDEStages
  WHERE      autoflowID = p_ID FOR UPDATE;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( current_status = 'unknown' ) THEN
      UPDATE  autoflowAnalysisABDEStages
      SET     analysisABDE = 'STARTED'
      WHERE   autoflowID = p_ID;

      SET unique_start = 1;

    END IF;

  END IF;

  SELECT unique_start as status;
  -- RETURN (unique_start);
  COMMIT;

END$$


-- Revert ABDEAnalysis status in autoflowAnalysisABDEStages record ---
DROP PROCEDURE IF EXISTS autoflow_abde_analysis_status_revert$$
CREATE PROCEDURE autoflow_abde_analysis_status_revert ( p_personGUID CHAR(36),
                                                        p_password   VARCHAR(80),
                                                        p_id  INT )

  -- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
  DECLARE current_status TEXT;
  -- DECLARE unique_start TINYINT DEFAULT 0;
       
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  
  SELECT     analysisABDE
  INTO       current_status
  FROM       autoflowAnalysisABDEStages
  WHERE      autoflowID = p_id;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( current_status != 'unknown' ) THEN
      UPDATE  autoflowAnalysisABDEStages
      SET     analysisABDE = DEFAULT
      WHERE   autoflowID = p_id;

    END IF;

  END IF;

  -- SELECT unique_start as status;
  -- RETURN (unique_start);
  
END$$



-- Update and return status of the REPORT while trying to save GMP Report into DB ---
DROP PROCEDURE IF EXISTS autoflow_report_status$$
CREATE PROCEDURE autoflow_report_status ( p_personGUID CHAR(36),
                                 	  p_password   VARCHAR(80),
                                          p_id  INT )

  -- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
  DECLARE current_status TEXT;
  DECLARE unique_start TINYINT DEFAULT 0;
       

  DECLARE exit handler for sqlexception
   BEGIN
      -- ERROR
    ROLLBACK;
   END;
   
  DECLARE exit handler for sqlwarning
   BEGIN
     -- WARNING
    ROLLBACK;
   END;


  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';


  START TRANSACTION;
  
  SELECT     reporting
  INTO       current_status
  FROM       autoflowStages
  WHERE      autoflowID = p_id FOR UPDATE;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( current_status = 'unknown' ) THEN
      UPDATE  autoflowStages
      SET     reporting = 'STARTED'
      WHERE   autoflowID = p_id;

      SET unique_start = 1;

    END IF;

  END IF;

  SELECT unique_start as status;
  -- RETURN (unique_start);
  COMMIT;

END$$




-- Update autoflowAnalysis record with CANCELED status and msg at DELETION of the primary channel wvl 
DROP PROCEDURE IF EXISTS update_autoflow_analysis_record_at_deletion$$
CREATE PROCEDURE update_autoflow_analysis_record_at_deletion ( p_personGUID  CHAR(36),
                                             		     p_password      VARCHAR(80),
                                                             p_statusMsg     TEXT,
                                       	     		     p_requestID     INT  )
					 
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;
  DECLARE current_status TEXT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowAnalysis
  WHERE      requestID = p_requestID;

  SELECT     status
  INTO       current_status
  FROM	     autoflowAnalysis
  WHERE	     requestID = p_requestID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowAnalysis
      SET      status = 'CANCELED', statusMsg = p_statusMsg
      WHERE    requestID = p_requestID;
	

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- Update autoflowAnalysis record with CANCELED status and msg at DELETION of other wvl in a channel  
DROP PROCEDURE IF EXISTS update_autoflow_analysis_record_at_deletion_other_wvl$$
CREATE PROCEDURE update_autoflow_analysis_record_at_deletion_other_wvl ( p_personGUID  CHAR(36),
                                             		               p_password      VARCHAR(80),
                                       	     		               p_requestID     INT  )
					 
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;
  DECLARE current_status TEXT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowAnalysis
  WHERE      requestID = p_requestID;

  SELECT     status
  INTO       current_status
  FROM	     autoflowAnalysis
  WHERE	     requestID = p_requestID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowAnalysis
      SET      nextWaitStatus = 'CANCELED', nextWaitStatusMsg = 'Job has been scheduled for deletion'
      WHERE    requestID = p_requestID;
	

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$




-- --  get initial elapsed time upon reattachment ----------------------------- 
DROP FUNCTION IF EXISTS read_autoflow_times$$
CREATE FUNCTION read_autoflow_times ( p_personGUID CHAR(36),
                                       p_password   VARCHAR(80), 
				       p_runID      INT )
                                       
  RETURNS INT
  READS SQL DATA

BEGIN
  DECLARE count_records INT;
  DECLARE l_sec_difference INT; 

  SET l_sec_difference = 0;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      runID = p_runID;

  SELECT TIMESTAMPDIFF( SECOND, runStarted, NOW() ) 
  INTO l_sec_difference 
  FROM autoflow WHERE runID = p_runID AND runStarted IS NOT NULL;


  RETURN( l_sec_difference );

END$$



-- --  get initial elapsed time upon reattachment ----------------------------- 
DROP FUNCTION IF EXISTS read_autoflow_times_mod$$
CREATE FUNCTION read_autoflow_times_mod ( p_personGUID CHAR(36),
                                       	p_password   VARCHAR(80), 
				       	p_runID      INT,
                                        p_optima      VARCHAR(300) )
                                       
  RETURNS INT
  READS SQL DATA

BEGIN
  DECLARE count_records INT;
  DECLARE l_sec_difference INT;
  DECLARE cur_runStarted TIMESTAMP; 
  	  
  SET l_sec_difference = 0;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      runID = p_runID AND optimaName = p_optima;

  SELECT     runStarted
  INTO       cur_runStarted
  FROM       autoflow
  WHERE      runID = p_runID AND optimaName = p_optima;
  
  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records > 0 ) THEN
      IF ( cur_runStarted IS NOT NULL ) THEN 
        	
	SELECT TIMESTAMPDIFF( SECOND, runStarted, NOW() )
	INTO l_sec_difference FROM autoflow WHERE runID = p_runID AND optimaName = p_optima; 

      END IF;	
    END IF;
  END IF;
    
  RETURN( l_sec_difference );

END$$

-- --  TEST: TO BE DELETED: get initial elapsed time upon reattachment ----------------------------- 
DROP FUNCTION IF EXISTS read_autoflow_times_mod_test$$
CREATE FUNCTION read_autoflow_times_mod_test ( p_personGUID CHAR(36),
                                       	     p_password   VARCHAR(80) ) 
				       	
                                       
  RETURNS INT
  READS SQL DATA

BEGIN
  DECLARE count_records INT;
  DECLARE l_sec_difference INT;
  DECLARE cur_runStarted TIMESTAMP; 
  	  
  SET l_sec_difference = 0;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow;
 
  SELECT     created
  INTO       cur_runStarted
  FROM       autoflow LIMIT 1;
   
  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records > 0 ) THEN
      IF ( cur_runStarted IS NOT NULL ) THEN 
        
	SELECT TIMESTAMPDIFF( SECOND, cur_runStarted, NOW() ) 
 	INTO l_sec_difference; 
  	
      END IF;	
    END IF;
  END IF;
    
  RETURN( l_sec_difference );

END$$


-- -----------------------------------------------------------------------
-- - PROCS and FUNCTIONS related to report and reportItem tables
-- -----------------------------------------------------------------------

-- - Create record in the report table ------------------------

DROP FUNCTION IF EXISTS new_report$$
CREATE FUNCTION new_report ( p_personGUID CHAR(36),
                             p_password   VARCHAR(80),
                             p_guid        varchar(80),
			     p_channame    varchar(80),
			     p_totconc     float,
			     p_rmsdlim     float,
			     p_avintensity float,
                             p_expduration INT ,
                             p_wvl         INT ,
                             p_totconc_tol float ,
                             p_expduration_tol float,
                             p_maskJson    TEXT)
                                       
  RETURNS INT
  MODIFIES SQL DATA

BEGIN

  DECLARE report_id INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowReport SET
      reportGUID        = p_guid,
      channelName       = p_channame,
      totalConc         = p_totconc,
      rmsdLimit         = p_rmsdlim,	
      avIntensity       = p_avintensity,
      expDuration       = p_expduration,
      wavelength        = p_wvl,
      totalConcTol      = p_totconc_tol,
      expDurationTol    = p_expduration_tol,
      reportMaskJson    = p_maskJson;
     
    SELECT LAST_INSERT_ID() INTO report_id;

  END IF;

  RETURN( report_id );

END$$



-- Update autoflow report at IMPORT for dropped triples/channels

DROP PROCEDURE IF EXISTS update_autoflow_report_at_import$$
CREATE PROCEDURE update_autoflow_report_at_import ( p_personGUID    CHAR(36),
                                             	  p_password      VARCHAR(80),
                                       	     	  p_reportID      INT,
					  	  p_dropped       TEXT  )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowReport
  WHERE      reportID = p_reportID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowReport
      SET      tripleDropped = p_dropped
      WHERE    reportID = p_reportID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- - Create record in the reportItem table ------------------------

DROP FUNCTION IF EXISTS new_report_item$$
CREATE FUNCTION new_report_item ( p_personGUID CHAR(36),
                                p_password    VARCHAR(80),
                                p_reportguid  varchar(80),
			        p_reportid    int,
			        p_type        text,
			        p_method      text,
			        p_low         float,
                                p_hi          float,
                                p_intval      float,
                                p_tolerance   float,
                                p_percent     float,
				p_combinedplot TINYINT,
				p_ind_combinedplot TINYINT )
                                       
  RETURNS INT
  MODIFIES SQL DATA

BEGIN

  DECLARE reportitem_id INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowReportItem SET
      reportGUID        = p_reportguid,
      reportID          = p_reportid,
      type              = p_type,
      method            = p_method,
      rangeLow          = p_low,	
      rangeHi           = p_hi,
      integration       = p_intval,
      tolerance         = p_tolerance,
      totalPercent      = p_percent,
      combinedPlot      = p_combinedplot,
      indCombinedPlot   = p_ind_combinedplot;
     
    SELECT LAST_INSERT_ID() INTO reportitem_id;

  END IF;

  RETURN( reportitem_id );

END$$



-- --- Returns complete information about autoflowReport record by ID
DROP PROCEDURE IF EXISTS get_report_info_by_id$$
CREATE PROCEDURE get_report_info_by_id( p_personGUID    CHAR(36),
                                       	p_password      VARCHAR(80),
                                       	p_reportID      INT )
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowReport
  WHERE      reportID = p_reportID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NOROWS;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   channelName, totalConc, rmsdLimit, avIntensity, expDuration, wavelength,
      	       totalConcTol, expDurationTol, reportMaskJson, tripleDropped
      FROM     autoflowReport 
      WHERE    reportID = p_reportID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$



-- --- Returns list of autoflowReportItem IDs by parent report's ID
DROP PROCEDURE IF EXISTS get_report_items_ids_by_report_id$$
CREATE PROCEDURE get_report_items_ids_by_report_id( p_personGUID    CHAR(36),
                                       	            p_password      VARCHAR(80),
                                       	            p_reportID      INT )
  READS SQL DATA

BEGIN
  DECLARE count_report_records INT;
  DECLARE count_report_item_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_report_records
  FROM       autoflowReport
  WHERE      reportID = p_reportID;

  SELECT     COUNT(*)
  INTO       count_report_item_records
  FROM       autoflowReportItem
  WHERE      reportID = p_reportID;


  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_report_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
       IF ( count_report_item_records = 0 ) THEN
          SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
          SET @US3_LAST_ERROR = 'MySQL: no rows returned';

          SELECT @US3_LAST_ERRNO AS status;

       ELSE
          SELECT @OK AS status;

          SELECT   reportItemID
          FROM     autoflowReportItem 
          WHERE    reportID = p_reportID;

       END IF;
    END IF;   

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$


-- --- Returns complete information about autoflowReportItem record by ID
DROP PROCEDURE IF EXISTS get_report_item_info_by_id$$
CREATE PROCEDURE get_report_item_info_by_id( p_personGUID    CHAR(36),
                                       	     p_password      VARCHAR(80),
                                       	     p_reportItemID  INT )
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowReportItem
  WHERE      reportItemID  = p_reportItemID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NOROWS;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   type, method, rangeLow, rangeHi, integration, tolerance,
      	       totalPercent, combinedPlot, indCombinedPlot
      FROM     autoflowReportItem 
      WHERE    reportItemID = p_reportItemID;

    END IF;
 
  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$

-- - Create record in the autoflowIntensity table ------------------------

DROP FUNCTION IF EXISTS new_autoflow_intensity_record$$
CREATE FUNCTION new_autoflow_intensity_record ( p_personGUID CHAR(36),
                                      	      p_password   VARCHAR(80),
					      p_autoflowID int(11),
					      p_intensityJson TEXT )
                                       
  RETURNS INT
  MODIFIES SQL DATA

BEGIN

  DECLARE record_id INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowIntensity SET
      autoflowID        = p_autoflowID,
      intensityRI       = p_intensityJson;
     
    SELECT LAST_INSERT_ID() INTO record_id;

  END IF;

  RETURN( record_id );

END$$

-- Returns complete information about autoflow Intensity record
DROP PROCEDURE IF EXISTS read_autoflow_intensity_record$$
CREATE PROCEDURE read_autoflow_intensity_record ( p_personGUID    CHAR(36),
                                       	          p_password      VARCHAR(80),
                                       	          p_ID  INT )
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowIntensity
  WHERE      ID = p_ID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   intensityRI, intensityIP
      FROM     autoflowIntensity 
      WHERE    ID = p_ID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$



-- Returns JSON about models processed at 5. ANALYSIS 
DROP PROCEDURE IF EXISTS get_modelAnalysisInfo$$
CREATE PROCEDURE get_modelAnalysisInfo ( p_personGUID    CHAR(36),
                                         p_password      VARCHAR(80),
                                       	 p_triplename    TEXT,
					 p_autoflowID    int(11) )
  READS SQL DATA

BEGIN
  DECLARE autoAnalID INT;
  SET     autoAnalID = 0;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     requestID
  INTO       autoAnalID
  FROM       autoflowAnalysisHistory
  WHERE      autoflowID = p_autoflowID AND tripleName = p_triplename
  ORDER BY   requestID
  DESC LIMIT 1;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( autoAnalID = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   modelsDesc
      FROM     autoflowModelsLink
      WHERE    autoflowAnalysisID = autoAnalID AND autoflowID = p_autoflowID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$


-- Returns JSONs about ALL models processed at 5. ANALYSIS 
DROP PROCEDURE IF EXISTS get_modelIDs_for_autoflow$$
CREATE PROCEDURE get_modelIDs_for_autoflow ( p_personGUID    CHAR(36),
                                           p_password      VARCHAR(80) )
                                       	 
  READS SQL DATA

BEGIN

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
      SELECT @OK AS status;

      SELECT   modelsDesc
      FROM     autoflowModelsLink;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$


-- - Get ID of the autoflowStatus record by autoflowID -----------------------------

DROP FUNCTION IF EXISTS get_autoflowStatus_id$$
CREATE FUNCTION get_autoflowStatus_id ( p_personGUID CHAR(36),
                                        p_password   VARCHAR(80),
					p_autoflowID int(11) )
                                       
  RETURNS INT
  READS SQL DATA

BEGIN

  DECLARE record_id INT;
  DECLARE count_records INT;

  CALL config();
  SET  record_id = 0;
  SET  count_records = 0;

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowStatus
  WHERE      autoflowID = p_autoflowID;
       
  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records > 0 ) THEN
      SELECT    ID
      INTO      record_id
      FROM      autoflowStatus
      WHERE     autoflowID = p_autoflowID;

    END IF;
      
  END IF;

  RETURN( record_id );

END$$





-- - Create record in the autoflowStatus table via importRI && importIP for ProtDEv module ------------------------

DROP FUNCTION IF EXISTS new_autoflowStatusRI_IP_dev_record$$
CREATE FUNCTION new_autoflowStatusRI_IP_dev_record ( p_personGUID CHAR(36),
                                      	      	   p_password   VARCHAR(80),
					      	   p_autoflowID int(11),
					      	   p_RIJson TEXT,
						   p_RIts   TEXT,
						   p_IPJson TEXT,
						   p_IPts   TEXT )
                                       
  RETURNS INT
  MODIFIES SQL DATA

BEGIN

  DECLARE record_id INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowStatus SET
      autoflowID        = p_autoflowID,
      importRI          = p_RIJson,
      importRIts        = p_RIts,
      importIP          = p_IPJson,
      importIPts        = p_IPts;
     
    SELECT LAST_INSERT_ID() INTO record_id;

  END IF;

  RETURN( record_id );

END$$

-- - Create record in the autoflowStatus table via importRI for ProtDEv module ------------------------

DROP FUNCTION IF EXISTS new_autoflowStatusRI_dev_record$$
CREATE FUNCTION new_autoflowStatusRI_dev_record ( p_personGUID CHAR(36),
                                      	      	   p_password   VARCHAR(80),
					      	   p_autoflowID int(11),
					      	   p_RIJson TEXT,
						   p_RIts   TEXT)
						                                       
  RETURNS INT
  MODIFIES SQL DATA

BEGIN

  DECLARE record_id INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowStatus SET
      autoflowID        = p_autoflowID,
      importRI          = p_RIJson,
      importRIts        = p_RIts;
     
    SELECT LAST_INSERT_ID() INTO record_id;

  END IF;

  RETURN( record_id );

END$$

-- - Create record in the autoflowStatus table via importIP for ProtDEv module ------------------------

DROP FUNCTION IF EXISTS new_autoflowStatusIP_dev_record$$
CREATE FUNCTION new_autoflowStatusIP_dev_record ( p_personGUID CHAR(36),
                                      	      	   p_password   VARCHAR(80),
					      	   p_autoflowID int(11),
					      	   p_IPJson TEXT,
						   p_IPts   TEXT)
						                                       
  RETURNS INT
  MODIFIES SQL DATA

BEGIN

  DECLARE record_id INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowStatus SET
      autoflowID        = p_autoflowID,
      importIP          = p_IPJson,
      importIPts        = p_IPts;
     
    SELECT LAST_INSERT_ID() INTO record_id;

  END IF;

  RETURN( record_id );

END$$


-- - Create record in the autoflowStatus table via EXPERIMENT's creation GMP run --------------
DROP FUNCTION IF EXISTS new_autoflowStatusGMPCreate_record$$
CREATE FUNCTION new_autoflowStatusGMPCreate_record( p_personGUID CHAR(36),
                                      	      	    p_password   VARCHAR(80),
					      	    p_autoflowID int(11),
					      	    p_createdGMPrun TEXT )
                                       
  RETURNS INT
  MODIFIES SQL DATA

BEGIN

  DECLARE record_id INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowStatus SET
      autoflowID        = p_autoflowID,
      createdGMPrun     = p_createdGMPrun,
      createdGMPrunts   = NOW();
     
    SELECT LAST_INSERT_ID() INTO record_id;

  END IF;

  RETURN( record_id );

END$$


-- - Create record in the autoflowAnalysisABDE table via EXPERIMENT's creation GMP run --------------
DROP FUNCTION IF EXISTS new_autoflowAnalysisABDE_record$$
CREATE FUNCTION new_autoflowAnalysisABDE_record( p_personGUID   CHAR(36),
                                                 p_password     VARCHAR(80),
                                                 p_autoflowID   int(11),
                                                 p_etypeABDE    TEXT )

  RETURNS INT
  MODIFIES SQL DATA

BEGIN

  DECLARE record_id INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowAnalysisABDE SET
      autoflowID        = p_autoflowID,
      etype             = p_etypeABDE;

    SELECT LAST_INSERT_ID() INTO record_id;

  END IF;

  RETURN( record_id );

END$$


-- read autoflowAnalysisABDE record
DROP PROCEDURE IF EXISTS read_autoflowAnalysisABDE_record$$
CREATE PROCEDURE read_autoflowAnalysisABDE_record ( p_personGUID    CHAR(36),
                                       		  p_password     VARCHAR(80),
                                       		  p_autoflowID  INT )
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowAnalysisABDE
  WHERE      autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   ID, etype, xNormPercent, filename_blc
      FROM     autoflowAnalysisABDE
      WHERE    autoflowID = p_autoflowID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$


-- Update autoflowAnalysisABDE record with ABDE profiles info
DROP PROCEDURE IF EXISTS update_autoflowAnalysisABDE_record$$
CREATE PROCEDURE update_autoflowAnalysisABDE_record ( p_personGUID    CHAR(36),
                                             	    p_password      VARCHAR(80),
                                       	       	    p_xNormPercent  TEXT,
						    p_filename_blc  TEXT,
						    p_autoflowID    INT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowAnalysisABDE
  WHERE      autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowAnalysisABDE
      SET      xNormPercent = p_xNormPercent, filename_blc = p_filename_blc
      WHERE    autoflowID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- add autoflowAnalysisABDEStages record
DROP PROCEDURE IF EXISTS new_autoflowAnalyisABDEstages_record$$
CREATE PROCEDURE new_autoflowAnalyisABDEstages_record ( p_personGUID  CHAR(36),
                                                      p_password      VARCHAR(80),
                                                      p_id      INT )

  MODIFIES SQL DATA

BEGIN
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowAnalysisABDEStages SET
      autoflowID        = p_id;

    SET @LAST_INSERT_ID = LAST_INSERT_ID();

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- =====================================================================
-- VEL-MWL Accept/Reject deconvolution decisions (autoflowAnalysisVelMwl)
--   One row per run (autoflowID), JSON-keyed by channel -- mirrors
--   autoflowAnalysisABDE's "one row per run" shape, but updated
--   incrementally (one channel's key at a time) rather than written
--   once at Save-Profiles time.
-- =====================================================================


-- Create the (single, empty) autoflowAnalysisVelMwl record for a run --
-- called once, at run-creation time (see US_ExperGuiUpload::
-- add_autoflow_record*() in us_experiment_gui_optima.cpp), analogous to
-- new_autoflowAnalysisABDE_record() above. channelDecisions starts as
-- an empty JSON object and gets one key added per channel as
-- US_MwlSpeciesFit records each Accept/Reject decision.
DROP FUNCTION IF EXISTS new_autoflowAnalysisVelMwl_record$$
CREATE FUNCTION new_autoflowAnalysisVelMwl_record ( p_personGUID  CHAR(36),
                                                  p_password      VARCHAR(80),
                                                  p_autoflowID    INT )
  RETURNS INT
  MODIFIES SQL DATA

BEGIN
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowAnalysisVelMwl SET
      autoflowID         = p_autoflowID,
      channelDecisions   = JSON_OBJECT(),
      channelDecisionsTs = NOW();

    SET @LAST_INSERT_ID = LAST_INSERT_ID();

  END IF;

  RETURN @LAST_INSERT_ID;

END$$


-- Save one channel's Accept/Reject decision -- and, for an Accept, its
-- deconvolved-edit filename -- within the run's single
-- autoflowAnalysisVelMwl row -- called from US_MwlSpeciesFit::
-- record_velmwl_channel_decision() as soon as the user clicks
-- Accept/Reject. Locks the row (FOR UPDATE) for the duration of the
-- read-modify-write so two sessions deciding the same channel at
-- nearly the same moment can't race each other.
--
-- ALEXEY: p_filename used to be persisted separately and later, by a
-- second, fire-and-forget call (update_autoflowAnalysisVelMwl_channel_
-- filename() below, from US_Analysis_auto::velmwl_deconv_accepted())
-- made only after US_ConvertGui::import_ssf_data_auto()/US_Edit::
-- load_auto_velmwl() had already run. That left a window where a
-- channel could be on record as "Accepted" with no filename yet -- or
-- permanently, if that second write failed, since its failure was only
-- logged, never surfaced or retried. process_velmwl_after_all_channels_
-- decided() had to defensively detect and skip such channels. Folding
-- the filename into this call removes that gap: US_MwlSpeciesFit
-- already knows protocol_details["ssf_dir_name"] (and therefore the
-- filename derived from it) at the moment the user clicks Accept, so it
-- can go out atomically with the decision, in one write, instead of as
-- a second, independent one. Pass an empty string for p_filename on a
-- Reject -- there's nothing to store, and Rejected channels are
-- disregarded by process_velmwl_after_all_channels_decided() regardless
-- of what's in "filename".
--
-- ALEXEY: FIRST DECISION WINS. If this channel already has a decision
-- recorded -- by this session or, more to the point, a different one
-- that got there first -- this call does NOT overwrite it (filename
-- included); the existing decision/filename pair stands as a unit.
-- Either way (newly recorded here, or already decided by someone else)
-- the second result set below reports what actually ended up recorded
-- for the channel, so the caller can tell which case happened and, when
-- it lost the race, show the user who/what/when won -- and use the
-- filename that actually won, not the one it computed locally --
-- instead of silently clobbering it or silently doing nothing.
--
-- If no row exists yet for this autoflowID -- e.g. an older run
-- predating this feature -- one is created inline rather than
-- failing. Client side maps the QStringList {"update_
-- autoflowAnalysisVelMwl_channel_decision", autoflowID, channel,
-- decision, userID, userName, filename} onto this procedure's params
-- (after personGUID/password, which US_DB2 prepends automatically).
-- Deliberately read via US_DB2::query() + next(), NOT statusQuery() --
-- this proc returns a second result set beyond the status one (see the
-- comment on US_MwlSpeciesFit::record_velmwl_channel_decision() in
-- us_mwl_species_fit.cpp), and statusQuery() alone would not reach it.
-- That second result set (US_DB2::next()/value()) carries: newly_recorded
-- (0/1), recorded_decision, recorded_decisionByID, recorded_decisionByName,
-- recorded_decisionTs, recorded_filename -- the decision (and filename)
-- now on record for this channel, whoever's it turned out to be.
DROP PROCEDURE IF EXISTS update_autoflowAnalysisVelMwl_channel_decision$$
CREATE PROCEDURE update_autoflowAnalysisVelMwl_channel_decision (
                                                  p_personGUID     CHAR(36),
                                                  p_password       VARCHAR(80),
                                                  p_autoflowID     INT,
                                                  p_channel        VARCHAR(20),
                                                  p_decision       VARCHAR(20),
                                                  p_decisionByID   INT,
                                                  p_decisionByName VARCHAR(160),
                                                  p_filename       VARCHAR(255) )
  MODIFIES SQL DATA

BEGIN
  DECLARE count_records      INT;
  DECLARE json_path          VARCHAR(64);
  DECLARE decision_json_path VARCHAR(80);
  DECLARE existing_decision  VARCHAR(20) DEFAULT NULL;

  DECLARE exit handler for sqlexception
   BEGIN
    ROLLBACK;
   END;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SET json_path          = CONCAT( '$."', p_channel, '"' );
  SET decision_json_path = CONCAT( json_path, '."decision"' );

  START TRANSACTION;

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowAnalysisVelMwl
  WHERE      autoflowID = p_autoflowID FOR UPDATE;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      -- No run-level record yet (older run, or created outside the
      -- normal add_autoflow_record*() path) -- create it now rather
      -- than losing this decision. Trivially not yet decided.
      INSERT INTO autoflowAnalysisVelMwl SET
        autoflowID         = p_autoflowID,
        channelDecisions   = JSON_OBJECT(),
        channelDecisionsTs = NOW();

    ELSE
      SELECT     JSON_UNQUOTE( JSON_EXTRACT( channelDecisions, decision_json_path ) )
      INTO       existing_decision
      FROM       autoflowAnalysisVelMwl
      WHERE      autoflowID = p_autoflowID;

    END IF;

    IF ( existing_decision IS NULL ) THEN
      -- Nobody has decided this channel yet -- this call wins it,
      -- filename included.
      UPDATE  autoflowAnalysisVelMwl
      SET     channelDecisions   = JSON_SET( COALESCE( channelDecisions, JSON_OBJECT() ),
                                              json_path,
                                              JSON_OBJECT( 'decision',       p_decision,
                                                            'decisionByID',   p_decisionByID,
                                                            'decisionByName', p_decisionByName,
                                                            'decisionTs',     NOW(),
                                                            'filename',       p_filename ) ),
              channelDecisionsTs = NOW()
      WHERE   autoflowID = p_autoflowID;

    END IF;
    -- else: already decided (by this or another session) -- leave it
    -- exactly as recorded, filename included; the SELECT below reports
    -- that decision (and filename) back.

  END IF;

  COMMIT;

  SELECT @US3_LAST_ERRNO AS status;

  SELECT   ( existing_decision IS NULL )                                                            AS newly_recorded,
           JSON_UNQUOTE( JSON_EXTRACT( channelDecisions, decision_json_path ) )                      AS recorded_decision,
           JSON_UNQUOTE( JSON_EXTRACT( channelDecisions, CONCAT( json_path, '."decisionByID"' ) ) )  AS recorded_decisionByID,
           JSON_UNQUOTE( JSON_EXTRACT( channelDecisions, CONCAT( json_path, '."decisionByName"' ) ) )AS recorded_decisionByName,
           JSON_UNQUOTE( JSON_EXTRACT( channelDecisions, CONCAT( json_path, '."decisionTs"' ) ) )    AS recorded_decisionTs,
           JSON_UNQUOTE( JSON_EXTRACT( channelDecisions, CONCAT( json_path, '."filename"' ) ) )      AS recorded_filename
  FROM     autoflowAnalysisVelMwl
  WHERE    autoflowID = p_autoflowID;

END$$


-- ALEXEY: NO LONGER CALLED by the client. This used to persist one
-- channel's deconvolved-edit filename (protocol_details_at_analysis_
-- velmwl["filename"]) into channelDecisions as a second, separate,
-- fire-and-forget write, made from US_Analysis_auto::velmwl_deconv_
-- accepted() sometime after the Accept decision itself was recorded.
-- That filename is now passed as p_filename directly into
-- update_autoflowAnalysisVelMwl_channel_decision() above and written
-- atomically with the decision, from US_MwlSpeciesFit::
-- record_velmwl_channel_decision() -- see that procedure's header
-- comment. This procedure is left in place, unused, in case anything
-- outside this codebase still calls it directly; it's safe to DROP it
-- for good once that's confirmed not to be the case. Original doc
-- below, for reference:
--
-- Persists one channel's deconvolved-edit filename into that channel's
-- entry in channelDecisions, alongside its decision/decisionByID/
-- decisionByName/decisionTs. Without this, process_velmwl_after_all_
-- channels_decided() has no way to know which data to reload for each
-- Approved channel when it later constructs US_2dsa -- see
-- start_next_2dsa_channel() in us_autoflow_analysis.cpp.
--
-- Unlike update_autoflowAnalysisVelMwl_channel_decision() above, this is
-- NOT a contested first-decision-wins write: by the time this is called,
-- the decision for this channel is already settled, and only the session
-- that actually ran US_Edit::load_auto_velmwl() (and therefore knows
-- where the resulting edit landed) ever calls this. A plain JSON_SET is
-- sufficient. read_autoflowAnalysisVelMwl_record() below needs no
-- changes -- it already returns the whole channelDecisions blob, so
-- "filename" shows up automatically once this call has run.
--
-- Client side maps the QStringList {"update_autoflowAnalysisVelMwl_
-- channel_filename", autoflowID, channel, filename} onto this
-- procedure's params (after personGUID/password, prepended by US_DB2),
-- and reads the status via US_DB2::statusQuery() (same shape as most
-- other fire-and-forget updates in this file).
DROP PROCEDURE IF EXISTS update_autoflowAnalysisVelMwl_channel_filename$$
CREATE PROCEDURE update_autoflowAnalysisVelMwl_channel_filename (
                                                  p_personGUID     CHAR(36),
                                                  p_password       VARCHAR(80),
                                                  p_autoflowID     INT,
                                                  p_channel        VARCHAR(20),
                                                  p_filename       VARCHAR(255) )
  MODIFIES SQL DATA

BEGIN
  DECLARE count_records INT;
  DECLARE json_path     VARCHAR(80);

  DECLARE exit handler for sqlexception
   BEGIN
    ROLLBACK;
   END;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SET json_path = CONCAT( '$."', p_channel, '"."filename"' );

  START TRANSACTION;

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowAnalysisVelMwl
  WHERE      autoflowID = p_autoflowID FOR UPDATE;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      -- Should not normally happen -- update_autoflowAnalysisVelMwl_
      -- channel_decision() always creates the row first, and this call
      -- only ever follows a successful decision recording. Don't lose
      -- the filename if it does happen, though.
      INSERT INTO autoflowAnalysisVelMwl SET
        autoflowID         = p_autoflowID,
        channelDecisions   = JSON_OBJECT(),
        channelDecisionsTs = NOW();
    END IF;

    UPDATE  autoflowAnalysisVelMwl
    SET     channelDecisions   = JSON_SET( COALESCE( channelDecisions, JSON_OBJECT() ),
                                            json_path, p_filename ),
            channelDecisionsTs = NOW()
    WHERE   autoflowID = p_autoflowID;

  END IF;

  COMMIT;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- ALEXEY: Records one deconvolved species' (S1, S2, ...) 2DSA-IT model
-- into the SAME channel entry in channelDecisions as its Accept/Reject
-- decision/filename above -- called from US_2dsa::
-- record_2dsa_model_in_velmwl(), right after that species' save()
-- returns (US_2dsa::analysis_done()'s savedata branch, us_gmp_auto_mode
-- only). Nested one level deeper than "decision"/"filename":
--   channelDecisions[ p_channel ].models[ p_species ] = p_modelGUID
-- e.g. channelDecisions["2 / A"].models.S1 = "<modelGUID>",
-- .models.S2 = "<modelGUID>" once that channel's second species is
-- also done -- so a channel with N deconvolved species accumulates N
-- entries under "models" as each one's fit+save completes, independent
-- of the others' timing. p_species is "S"+wavelength as US_2dsa builds
-- it (e.g. "S1", "S2"), NOT the "N / X" channel form p_channel is.
--
-- ALEXEY: FIRST MODEL WINS, same rule and same reason as
-- update_autoflowAnalysisVelMwl_channel_decision()'s header comment --
-- this channel+species key, once recorded, is never overwritten by a
-- later call here. Covers two cases: (1) two sessions racing to fit the
-- same channel/species at once, and (2) a channel that gets re-run
-- later (e.g. the first attempt fit S1 but crashed/was killed before
-- reaching S2) -- on that later attempt, S1's already-recorded model
-- stands even though US_2dsa will (currently) still re-fit and re-save
-- S1 along with S2; only S2's fresh model actually gets recorded here,
-- since S1's key is already taken. (If US_2dsa should also SKIP
-- re-fitting a species whose model is already on record here, rather
-- than just declining to overwrite the DB row, that's a separate,
-- larger change to US_2dsa's own species-selection loop, not something
-- this procedure can do by itself.) Same read-modify-write/locking
-- shape as update_autoflowAnalysisVelMwl_channel_decision() above: the
-- row is locked FOR UPDATE, the existing value at this exact channel+
-- species path is read first, and JSON_SET only runs when that read
-- comes back NULL. If no run-level row exists yet (should not normally
-- happen -- this only ever follows a channel that already has an
-- Accepted decision recorded, which always creates the row first), one
-- is created inline rather than losing the model. Client side maps the
-- QStringList {"update_autoflowAnalysisVelMwl_channel_2dsaModel",
-- autoflowID, channel, species, modelGUID} onto this procedure's params
-- (after personGUID/password, which US_DB2 prepends automatically).
-- Deliberately read via US_DB2::query()+next(), NOT statusQuery() --
-- like update_autoflowAnalysisVelMwl_channel_decision(), this procedure
-- returns a second result set beyond the status one: newly_recorded
-- (0/1), recorded_modelGUID -- the modelGUID now on record for this
-- channel+species, whoever's it turned out to be -- so the caller can
-- tell whether it won or lost the race and log accordingly, the same
-- way US_MwlSpeciesFit::record_velmwl_channel_decision() does for
-- decisions.
DROP PROCEDURE IF EXISTS update_autoflowAnalysisVelMwl_channel_2dsaModel$$
CREATE PROCEDURE update_autoflowAnalysisVelMwl_channel_2dsaModel (
                                                  p_personGUID     CHAR(36),
                                                  p_password       VARCHAR(80),
                                                  p_autoflowID     INT,
                                                  p_channel        VARCHAR(20),
                                                  p_species        VARCHAR(20),
                                                  p_modelGUID      CHAR(36) )
  MODIFIES SQL DATA

BEGIN
  DECLARE count_records   INT;
  DECLARE json_path       VARCHAR(96);
  DECLARE existing_modelG CHAR(36) DEFAULT NULL;

  DECLARE exit handler for sqlexception
   BEGIN
    ROLLBACK;
   END;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SET json_path = CONCAT( '$."', p_channel, '"."models"."', p_species, '"' );

  START TRANSACTION;

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowAnalysisVelMwl
  WHERE      autoflowID = p_autoflowID FOR UPDATE;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      -- Should not normally happen -- see header comment. Don't lose
      -- the model if it does happen. Trivially not yet recorded.
      INSERT INTO autoflowAnalysisVelMwl SET
        autoflowID         = p_autoflowID,
        channelDecisions   = JSON_OBJECT(),
        channelDecisionsTs = NOW();

    ELSE
      SELECT     JSON_UNQUOTE( JSON_EXTRACT( channelDecisions, json_path ) )
      INTO       existing_modelG
      FROM       autoflowAnalysisVelMwl
      WHERE      autoflowID = p_autoflowID;

    END IF;

    IF ( existing_modelG IS NULL ) THEN
      -- Nobody has recorded a model for this channel+species yet --
      -- this call wins it.
      UPDATE  autoflowAnalysisVelMwl
      SET     channelDecisions   = JSON_SET( COALESCE( channelDecisions, JSON_OBJECT() ),
                                              json_path, p_modelGUID ),
              channelDecisionsTs = NOW()
      WHERE   autoflowID = p_autoflowID;

    END IF;
    -- else: already recorded (by this or another session, possibly a
    -- prior, incomplete run of this same channel) -- leave it exactly
    -- as recorded; the SELECT below reports that value back.

  END IF;

  COMMIT;

  SELECT @US3_LAST_ERRNO AS status;

  SELECT   ( existing_modelG IS NULL )                                AS newly_recorded,
           JSON_UNQUOTE( JSON_EXTRACT( channelDecisions, json_path ) ) AS recorded_modelGUID
  FROM     autoflowAnalysisVelMwl
  WHERE    autoflowID = p_autoflowID;

END$$


-- ALEXEY: Read-side counterpart of update_autoflowAnalysisVelMwl_
-- channel_2dsaModel() above -- looks up whether one deconvolved species
-- (S1, S2, ...) already has a 2DSA-IT model recorded for it, within the
-- run's autoflowAnalysisVelMwl row. Called from US_2dsa::
-- species_model_already_recorded(), before run_2dsa_auto() fits each
-- species, so a channel picked back up after a prior, incomplete run
-- (e.g. one that fit S1 but crashed/was killed before reaching S2)
-- doesn't waste a full 2DSA-IT grid fit re-doing a species that already
-- finished and got recorded -- see update_autoflowAnalysisVelMwl_
-- channel_2dsaModel()'s "first model wins" rule, which this exists to
-- let the client check ahead of a fit rather than only find out about
-- after wastefully re-fitting. Mirrors get_autoflowAnalysisVelMwl_
-- channel_decision() above exactly, for "models"."<species>" instead of
-- "decision". Client side maps the QStringList {"get_
-- autoflowAnalysisVelMwl_channel_2dsaModel", autoflowID, channel,
-- species} onto this procedure's params, then reads the modelGUID from
-- column 0 of the (single) returned row via US_DB2::next()/value(0). If
-- no run record exists yet, or this channel+species isn't in
-- channelDecisions[channel].models yet (not fit yet -- including "not
-- fit yet by this same, still-in-progress run", the common case), no
-- rows are returned and @US3_LAST_ERRNO is set to @NO_AUTOFLOW_RECORD,
-- same convention as get_autoflowAnalysisVelMwl_channel_decision().
DROP PROCEDURE IF EXISTS get_autoflowAnalysisVelMwl_channel_2dsaModel$$
CREATE PROCEDURE get_autoflowAnalysisVelMwl_channel_2dsaModel (
                                                  p_personGUID  CHAR(36),
                                                  p_password      VARCHAR(80),
                                                  p_autoflowID    INT,
                                                  p_channel       VARCHAR(20),
                                                  p_species       VARCHAR(20) )
  READS SQL DATA

BEGIN
  DECLARE json_path VARCHAR(96);
  DECLARE modelG_v  CHAR(36);

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SET json_path = CONCAT( '$."', p_channel, '"."models"."', p_species, '"' );

  SELECT     JSON_UNQUOTE( JSON_EXTRACT( channelDecisions, json_path ) )
  INTO       modelG_v
  FROM       autoflowAnalysisVelMwl
  WHERE      autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( modelG_v IS NULL ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no model recorded yet for this channel/species';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   modelG_v AS modelGUID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$


-- Look up one channel's already-recorded Accept/Reject decision within
-- the run's autoflowAnalysisVelMwl row -- e.g. on run re-attachment, so
-- the channel is not re-processed. Client side maps the QStringList
-- {"get_autoflowAnalysisVelMwl_channel_decision", autoflowID, channel}
-- onto this procedure's params, then reads the decision from column 0
-- of the (single) returned row via US_DB2::next()/value(0). If no run
-- record exists yet, or the channel's key isn't in channelDecisions
-- yet (not decided so far), no rows are returned and @US3_LAST_ERRNO
-- is set to @NO_AUTOFLOW_RECORD, same convention as
-- read_autoflowAnalysisABDE_record() above.
DROP PROCEDURE IF EXISTS get_autoflowAnalysisVelMwl_channel_decision$$
CREATE PROCEDURE get_autoflowAnalysisVelMwl_channel_decision (
                                                  p_personGUID  CHAR(36),
                                                  p_password      VARCHAR(80),
                                                  p_autoflowID    INT,
                                                  p_channel       VARCHAR(20) )
  READS SQL DATA

BEGIN
  DECLARE json_path  VARCHAR(64);
  DECLARE decision_v VARCHAR(20);

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SET json_path = CONCAT( '$."', p_channel, '"."decision"' );

  SELECT     JSON_UNQUOTE( JSON_EXTRACT( channelDecisions, json_path ) )
  INTO       decision_v
  FROM       autoflowAnalysisVelMwl
  WHERE      autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( decision_v IS NULL ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no decision recorded yet for this channel';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   decision_v AS decision;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$


-- REMOVED: autoflow_velmwl_channel_claim() / autoflow_velmwl_channel_
-- claim_revert(). These used to write a transient {"status":"STARTED",
-- "claimedTs":...} placeholder into a channel's key in channelDecisions
-- before its US_MwlSpeciesFit dialog opened, purely to stop two
-- overlapping sessions from re-simulating/re-deciding the same channel
-- at once. In practice this is a single-session interactive workflow,
-- and the placeholder had no way to get cleared on a hard crash (or,
-- before revert calls were added on the other exit paths, on a plain
-- tab-switch or program close either) -- once left behind, it
-- permanently blocked that channel's reprocessing with no in-app way
-- to fix it. The client no longer calls either procedure: the only
-- guard against reprocessing a channel now is whether it has a real
-- decision recorded, via get_autoflowAnalysisVelMwl_channel_decision()
-- below. These two DROPs just clean up the procedures on a database
-- that still has them from before this change.
DROP PROCEDURE IF EXISTS autoflow_velmwl_channel_claim$$
DROP PROCEDURE IF EXISTS autoflow_velmwl_channel_claim_revert$$


-- Read the whole autoflowAnalysisVelMwl record for a run -- one row,
-- channelDecisions holding every channel decided so far -- for the
-- Report stage to reflect each channel's Accept/Reject status (per the
-- "(2) for the report..." note in
-- US_Analysis_auto::velmwl_deconv_rejected()/accepted()). Analogous to
-- read_autoflowAnalysisABDE_record() above; the caller parses the
-- returned JSON client-side (e.g. QJsonDocument) rather than this
-- procedure flattening it into rows, since the set of channels/fields
-- can grow over time without a signature change here.
DROP PROCEDURE IF EXISTS read_autoflowAnalysisVelMwl_record$$
CREATE PROCEDURE read_autoflowAnalysisVelMwl_record ( p_personGUID  CHAR(36),
                                                    p_password      VARCHAR(80),
                                                    p_autoflowID    INT )
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowAnalysisVelMwl
  WHERE      autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   channelDecisions, timestamp2UTC( channelDecisionsTs )
      FROM     autoflowAnalysisVelMwl
      WHERE    autoflowID = p_autoflowID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$



-- =====================================================================
-- autoflowAnalysisVelMwlStages -- run-level "is the whole VEL-MWL
-- analysis for this run finished" gate (NOT a per-channel guard --
-- that one lives inside autoflowAnalysisVelMwl.channelDecisions'
-- per-channel decision, via update_/get_autoflowAnalysisVelMwl_
-- channel_decision() above). One row per autoflowID, exactly
-- mirroring autoflowAnalysisABDEStages.
-- =====================================================================


-- Seed the (single) autoflowAnalysisVelMwlStages record for a run --
-- called once, at run-creation time alongside
-- new_autoflowAnalysisVelMwl_record() (see US_ExperGuiUpload::
-- add_autoflow_record*() in us_experiment_gui_optima.cpp), exactly as
-- ABDE seeds both its data and Stages rows together at creation.
DROP PROCEDURE IF EXISTS new_autoflowAnalyisVelMwlStages_record$$
CREATE PROCEDURE new_autoflowAnalyisVelMwlStages_record ( p_personGUID  CHAR(36),
                                                        p_password      VARCHAR(80),
                                                        p_autoflowID    INT )

  MODIFIES SQL DATA

BEGIN
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowAnalysisVelMwlStages SET
      autoflowID        = p_autoflowID;

    SET @LAST_INSERT_ID = LAST_INSERT_ID();

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Claim the run-wide "VEL-MWL analysis complete" transition -- called
-- from US_Analysis_auto::velmwl_deconv_rejected()/accepted() (in
-- us_autoflow_analysis.cpp) once the LAST channel's decision comes in,
-- BEFORE calling update_autoflow_record_atAnalysis() and emitting
-- analysis_complete_auto() to switch to the Report stage. Analogous to
-- autoflow_abde_analysis_status() above: only the caller that
-- transitions unknown->STARTED (unique_start = 1) should proceed with
-- the switch; anyone else (e.g. this run being re-attached after it
-- already switched to Report) sees STARTED already and backs off,
-- so the switch can't fire twice for the same run.
DROP PROCEDURE IF EXISTS autoflow_velmwl_analysis_status$$
CREATE PROCEDURE autoflow_velmwl_analysis_status( p_personGUID CHAR(36),
                                                p_password      VARCHAR(80),
                                                p_autoflowID    INT )

  -- RETURNS INT
  MODIFIES SQL DATA

BEGIN
  DECLARE current_status TEXT;
  DECLARE unique_start TINYINT DEFAULT 0;

  DECLARE exit handler for sqlexception
   BEGIN
      -- ERROR
    ROLLBACK;
   END;

  DECLARE exit handler for sqlwarning
   BEGIN
     -- WARNING
    ROLLBACK;
   END;


  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';


  START TRANSACTION;

  SELECT     analysisVelMwl
  INTO       current_status
  FROM       autoflowAnalysisVelMwlStages
  WHERE      autoflowID = p_autoflowID FOR UPDATE;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( current_status = 'unknown' ) THEN
      UPDATE  autoflowAnalysisVelMwlStages
      SET     analysisVelMwl = 'STARTED'
      WHERE   autoflowID = p_autoflowID;

      SET unique_start = 1;

    END IF;

  END IF;

  SELECT unique_start as status;
  COMMIT;

END$$


-- Revert the run-wide completion claim -- e.g. update_autoflow_record_
-- atAnalysis() or the emit that follows somehow didn't complete, so a
-- later attempt should be allowed to retry the switch. Analogous to
-- autoflow_abde_analysis_status_revert() above.
DROP PROCEDURE IF EXISTS autoflow_velmwl_analysis_status_revert$$
CREATE PROCEDURE autoflow_velmwl_analysis_status_revert ( p_personGUID CHAR(36),
                                                        p_password     VARCHAR(80),
                                                        p_autoflowID   INT )

  -- RETURNS INT
  MODIFIES SQL DATA

BEGIN
  DECLARE current_status TEXT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';


  SELECT     analysisVelMwl
  INTO       current_status
  FROM       autoflowAnalysisVelMwlStages
  WHERE      autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( current_status != 'unknown' ) THEN
      UPDATE  autoflowAnalysisVelMwlStages
      SET     analysisVelMwl = DEFAULT
      WHERE   autoflowID = p_autoflowID;

    END IF;

  END IF;

END$$



-- - Create record in the autoflowStatus table via LIVE_UPDATE's STOP Optima event--------------

DROP FUNCTION IF EXISTS new_autoflowStatusStopOptima_record$$
CREATE FUNCTION new_autoflowStatusStopOptima_record ( p_personGUID CHAR(36),
                                      	      	    p_password   VARCHAR(80),
					      	    p_autoflowID int(11),
					      	    p_stopOptimaJson TEXT )
                                       
  RETURNS INT
  MODIFIES SQL DATA

BEGIN

  DECLARE record_id INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowStatus SET
      autoflowID        = p_autoflowID,
      stopOptima        = p_stopOptimaJson,
      stopOptimats      = NOW();
     
    SELECT LAST_INSERT_ID() INTO record_id;

  END IF;

  RETURN( record_id );

END$$


-- - Create record in the autoflowStatus table via LIVE_UPDATE's SKIP Optima event--------------

DROP FUNCTION IF EXISTS new_autoflowStatusSkipOptima_record$$
CREATE FUNCTION new_autoflowStatusSkipOptima_record ( p_personGUID CHAR(36),
                                      	      	    p_password   VARCHAR(80),
					      	    p_autoflowID int(11),
					      	    p_skipOptimaJson TEXT )
                                       
  RETURNS INT
  MODIFIES SQL DATA

BEGIN

  DECLARE record_id INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowStatus SET
      autoflowID        = p_autoflowID,
      skipOptima        = p_skipOptimaJson,
      skipOptimats      = NOW();
     
    SELECT LAST_INSERT_ID() INTO record_id;

  END IF;

  RETURN( record_id );

END$$



-- Update record in the autoflowStatus table via LIVE_UPDATE's STOP Optima event --------------

DROP PROCEDURE IF EXISTS update_autoflowStatusStopOptima_record$$
CREATE PROCEDURE update_autoflowStatusStopOptima_record ( p_personGUID    CHAR(36),
                                             	  	p_password        VARCHAR(80),
                                       	     	  	p_ID    	  INT,
					  	  	p_autoflowID      INT,
                                                  	p_stopOptimaJson  TEXT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowStatus
  WHERE      ID = p_ID AND autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowStatus
      SET      stopOptima  = p_stopOptimaJson, stopOptimats = NOW()
      WHERE    ID = p_ID AND autoflowID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- Update record in the autoflowStatus table via LIVE_UPDATE's SKIP Optima event --------------

DROP PROCEDURE IF EXISTS update_autoflowStatusSkipOptima_record$$
CREATE PROCEDURE update_autoflowStatusSkipOptima_record ( p_personGUID    CHAR(36),
                                             	  	  p_password        VARCHAR(80),
                                       	     	  	  p_ID    	  INT,
					  	  	  p_autoflowID      INT,
                                                  	  p_skipOptimaJson  TEXT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowStatus
  WHERE      ID = p_ID AND autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowStatus
      SET      skipOptima  = p_skipOptimaJson, skipOptimats = NOW()
      WHERE    ID = p_ID AND autoflowID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$




-- - Create record in the autoflowStatus table via importRI ------------------------

DROP FUNCTION IF EXISTS new_autoflowStatusRI_record$$
CREATE FUNCTION new_autoflowStatusRI_record ( p_personGUID CHAR(36),
                                      	      p_password   VARCHAR(80),
					      p_autoflowID int(11),
					      p_RIJson TEXT )
                                       
  RETURNS INT
  MODIFIES SQL DATA

BEGIN

  DECLARE record_id INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowStatus SET
      autoflowID        = p_autoflowID,
      importRI          = p_RIJson,
      importRIts        = NOW();
     
    SELECT LAST_INSERT_ID() INTO record_id;

  END IF;

  RETURN( record_id );

END$$


-- - Create record in the autoflowStatus table via importIP ------------------------

DROP FUNCTION IF EXISTS new_autoflowStatusIP_record$$
CREATE FUNCTION new_autoflowStatusIP_record ( p_personGUID CHAR(36),
                                      	      p_password   VARCHAR(80),
					      p_autoflowID int(11),
					      p_IPJson TEXT )
                                       
  RETURNS INT
  MODIFIES SQL DATA

BEGIN

  DECLARE record_id INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowStatus SET
      autoflowID        = p_autoflowID,
      importIP          = p_IPJson,
      importIPts        = NOW();
     
    SELECT LAST_INSERT_ID() INTO record_id;

  END IF;

  RETURN( record_id );

END$$





-- Update autoflowStatus record via importRI
DROP PROCEDURE IF EXISTS update_autoflowStatusRI_record$$
CREATE PROCEDURE update_autoflowStatusRI_record ( p_personGUID    CHAR(36),
                                             	  p_password      VARCHAR(80),
                                       	     	  p_ID    	  INT,
					  	  p_autoflowID    INT,
                                                  p_RIJson        TEXT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowStatus
  WHERE      ID = p_ID AND autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowStatus
      SET      importRI  = p_RIJson, importRIts = NOW()
      WHERE    ID = p_ID AND autoflowID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Update autoflowStatus record via importIP
DROP PROCEDURE IF EXISTS update_autoflowStatusIP_record$$
CREATE PROCEDURE update_autoflowStatusIP_record ( p_personGUID    CHAR(36),
                                             	  p_password      VARCHAR(80),
                                       	     	  p_ID    	  INT,
					  	  p_autoflowID    INT,
                                                  p_IPJson        TEXT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowStatus
  WHERE      ID = p_ID AND autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowStatus
      SET      importIP  = p_IPJson, importIPts = NOW()
      WHERE    ID = p_ID AND autoflowID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Update autoflowStatus record via editIR
DROP PROCEDURE IF EXISTS update_autoflowStatusEditRI_record$$
CREATE PROCEDURE update_autoflowStatusEditRI_record ( p_personGUID    CHAR(36),
                                             	      p_password      VARCHAR(80),
                                       	     	      p_ID    	      INT,
					  	      p_autoflowID    INT,
                                                      p_RIJson        TEXT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowStatus
  WHERE      ID = p_ID AND autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowStatus
      SET      editRI  = p_RIJson, editRIts = NOW()
      WHERE    ID = p_ID AND autoflowID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Update autoflowStatus record via editIP
DROP PROCEDURE IF EXISTS update_autoflowStatusEditIP_record$$
CREATE PROCEDURE update_autoflowStatusEditIP_record ( p_personGUID    CHAR(36),
                                             	      p_password      VARCHAR(80),
                                       	     	      p_ID    	      INT,
					  	      p_autoflowID    INT,
                                                      p_IPJson        TEXT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowStatus
  WHERE      ID = p_ID AND autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowStatus
      SET      editIP  = p_IPJson, editIPts = NOW()
      WHERE    ID = p_ID AND autoflowID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Update autoflowStatus record via analysisABDE
DROP PROCEDURE IF EXISTS update_autoflowStatusAnalysisABDE_record$$
CREATE PROCEDURE update_autoflowStatusAnalysisABDE_record ( p_personGUID    CHAR(36),
                                             	      	  p_password      VARCHAR(80),
                                       	     	      	  p_ID    	  INT,
					  	      	  p_autoflowID    INT,
                                                      	  p_abdeJson      TEXT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowStatus
  WHERE      ID = p_ID AND autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowStatus
      SET      analysisABDE  = p_abdeJson, analysisABDEts = NOW()
      WHERE    ID = p_ID AND autoflowID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- Update autoflowStatus record via GMPreport
DROP PROCEDURE IF EXISTS update_autoflowStatusReport_record$$
CREATE PROCEDURE update_autoflowStatusReport_record ( p_personGUID    CHAR(36),
                                             	      p_password      VARCHAR(80),
                                       	     	      p_ID    	      INT,
					  	      p_autoflowID    INT,
                                                      p_reportJson    TEXT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowStatus
  WHERE      ID = p_ID AND autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowStatus
      SET      GMPreport = p_IPJson, GMPreportts = NOW()
      WHERE    ID = p_ID AND autoflowID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- Update autoflowStatus record via analysis FITMEN
DROP PROCEDURE IF EXISTS update_autoflowStatusAnalysisFitmen_record$$
CREATE PROCEDURE update_autoflowStatusAnalysisFitmen_record ( p_personGUID    CHAR(36),
                                             	            p_password      VARCHAR(80),
                                       	     	            p_ID    	      INT,
					  	            p_autoflowID      INT,
                                                            p_AnalysisTriple  TEXT,
                                                            p_AnalysisAction  TEXT )

  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;
  DECLARE analysis_json TEXT;
  DECLARE p_AnalysisAction_plus_date TEXT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowStatus
  WHERE      ID = p_ID AND autoflowID = p_autoflowID;

  SELECT     analysis
  INTO       analysis_json
  FROM       autoflowStatus
  WHERE     ID = p_ID AND autoflowID = p_autoflowID;
  
  SELECT concat( p_AnalysisAction, '; ', DATE_FORMAT(timestamp2UTC( NOW() ), '%Y-%m-%d %H:%i:%s'))
  INTO   p_AnalysisAction_plus_date;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      IF ( analysis_json IS NULL ) THEN 
        UPDATE   autoflowStatus
        SET      analysis  = JSON_OBJECT(p_AnalysisTriple, p_AnalysisAction_plus_date )
        WHERE    ID = p_ID AND autoflowID = p_autoflowID;

      ELSE
         UPDATE  autoflowStatus
         SET     analysis = JSON_ARRAY_APPEND(analysis, '$', JSON_OBJECT(p_AnalysisTriple, p_AnalysisAction_plus_date))
         WHERE   ID = p_ID AND autoflowID = p_autoflowID;

      END IF;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- Update autoflowStatus record via analysis CANCEL Job
DROP PROCEDURE IF EXISTS update_autoflowStatusAnalysisCancel_record$$
CREATE PROCEDURE update_autoflowStatusAnalysisCancel_record ( p_personGUID    CHAR(36),
                                             	            p_password      VARCHAR(80),
                                       	     	            p_ID    	      INT,
					  	            p_autoflowID      INT,
                                                            p_CancelTriples   TEXT,
                                                            p_CancelAction    TEXT )

  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;
  DECLARE analysisCancel_json TEXT;
  DECLARE p_CancelAction_plus_date TEXT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowStatus
  WHERE      ID = p_ID AND autoflowID = p_autoflowID;

  SELECT     analysisCancel
  INTO       analysisCancel_json
  FROM       autoflowStatus
  WHERE     ID = p_ID AND autoflowID = p_autoflowID;
  
  SELECT concat( p_CancelAction, '; ', DATE_FORMAT(timestamp2UTC( NOW() ), '%Y-%m-%d %H:%i:%s'))
  INTO   p_CancelAction_plus_date;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      IF ( analysisCancel_json IS NULL ) THEN 
        UPDATE   autoflowStatus
        SET      analysisCancel  = JSON_OBJECT(p_CancelTriples, p_CancelAction_plus_date )
        WHERE    ID = p_ID AND autoflowID = p_autoflowID;

      ELSE
         UPDATE  autoflowStatus
         SET     analysisCancel = JSON_ARRAY_APPEND(analysisCancel, '$', JSON_OBJECT(p_CancelTriples, p_CancelAction_plus_date ))
         WHERE   ID = p_ID AND autoflowID = p_autoflowID;

      END IF;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$




-- [OLD] Update autoflowStatus record via analysis FITMEN
DROP PROCEDURE IF EXISTS update_autoflowStatusAnalysisFitmen_record_old$$
CREATE PROCEDURE update_autoflowStatusAnalysisFitmen_record_old ( p_personGUID    CHAR(36),
                                             	            p_password      VARCHAR(80),
                                       	     	            p_ID    	      INT,
					  	            p_autoflowID      INT,
                                                            p_AnalysisJson    TEXT,
                                                            p_AnalysisTriple  TEXT,
                                                            p_AnalysisAction  TEXT )

  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;
  DECLARE analysis_json TEXT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowStatus
  WHERE      ID = p_ID AND autoflowID = p_autoflowID;

  SELECT     analysis
  INTO       analysis_json
  FROM       autoflowStatus
  WHERE     ID = p_ID AND autoflowID = p_autoflowID;
  
  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      IF ( analysis_json IS NULL ) THEN 
        UPDATE   autoflowStatus
        SET      analysis  = p_AnalysisJson
        WHERE    ID = p_ID AND autoflowID = p_autoflowID;

      ELSE
         UPDATE  autoflowStatus
         SET     analysis = JSON_ARRAY_APPEND(analysis, '$', JSON_OBJECT(p_AnalysisTriple, p_AnalysisAction))
         WHERE   ID = p_ID AND autoflowID = p_autoflowID;

      END IF;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$



-- Returns complete information about autoflowStatus record
DROP PROCEDURE IF EXISTS read_autoflow_status_record$$
CREATE PROCEDURE read_autoflow_status_record ( p_personGUID    CHAR(36),
                                       	       p_password      VARCHAR(80),
                                       	       p_ID  INT )
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowStatus
  WHERE      ID = p_ID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   importRI, timestamp2UTC( importRIts ), importIP, timestamp2UTC( importIPts ),
               editRI, timestamp2UTC( editRIts ), editIP, timestamp2UTC( editIPts ), analysis,
	       stopOptima, timestamp2UTC( stopOptimats ), skipOptima, timestamp2UTC( skipOptimats ),
	       analysisCancel, createdGMPrun, timestamp2UTC( createdGMPrunts ),
	       analysisABDE, timestamp2UTC( analysisABDEts )
      FROM     autoflowStatus 
      WHERE    ID = p_ID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$


-- Set AUTO_INCREMENT in autoflow to greater of:
-- current autoflow AUTO_INCREMENT
-- max( ID ) of autoflowHistory
DROP PROCEDURE IF EXISTS set_autoflow_auto_increment$$
CREATE PROCEDURE set_autoflow_auto_increment ( p_personGUID CHAR(36),
                                               p_password   VARCHAR(80),
                                               p_current_db VARCHAR(255) )

-- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
  DECLARE exit handler for sqlexception
   BEGIN
      -- ERROR
    ROLLBACK;
   END;
   
  DECLARE exit handler for sqlwarning
   BEGIN
     -- WARNING
    ROLLBACK;
   END;


  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SET @db_name            = p_current_db;

  START TRANSACTION;

  SELECT @autoinc := `AUTO_INCREMENT` FROM  INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'autoflow' FOR UPDATE;
  SELECT @new_autoinc := GREATEST( MAX( ID ) + 1, @autoinc ) FROM autoflowHistory;
  SET @sql = CONCAT('ALTER TABLE autoflow AUTO_INCREMENT = ', @new_autoinc);
  PREPARE st FROM @sql;
  EXECUTE st;     

  SELECT @new_autoinc AS status;  

  COMMIT;

END$$


-- Set AUTO_INCREMENT in autoflowAnalysis to greater of:
-- current autoflowAnalysis AUTO_INCREMENT
-- max( requestID ) of autoflowAnalysisHistory
DROP PROCEDURE IF EXISTS set_autoflowAnalysis_auto_increment$$
CREATE PROCEDURE set_autoflowAnalysis_auto_increment ( p_personGUID CHAR(36),
                                                       p_password   VARCHAR(80),
                                                       p_current_db VARCHAR(255) )

-- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
  DECLARE exit handler for sqlexception
   BEGIN
      -- ERROR
    ROLLBACK;
   END;
   
  DECLARE exit handler for sqlwarning
   BEGIN
     -- WARNING
    ROLLBACK;
   END;


  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SET @db_name            = p_current_db;

  START TRANSACTION;

  SELECT @autoinc := `AUTO_INCREMENT` FROM  INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'autoflowAnalysis' FOR UPDATE;
  SELECT @new_autoinc := GREATEST( MAX( requestID ) + 1, @autoinc ) FROM autoflowAnalysisHistory;
  SET @sql = CONCAT('ALTER TABLE autoflowAnalysis AUTO_INCREMENT = ', @new_autoinc);
  PREPARE st FROM @sql;
  EXECUTE st;     

  SELECT @new_autoinc AS status;  

  COMMIT;

END$$


-- ------------------------------------------------------------------------------------------------------------
-- -- stored procs related to autoflowFailed table, clearing autoflow fields, and exp./rawData-----------------
-- ------------------------------------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS new_autoflow_failed_record$$
CREATE FUNCTION new_autoflow_failed_record  ( p_personGUID CHAR(36),
                                      	      p_password   VARCHAR(80),
					      p_autoflowID int(11),
					      p_stage      TEXT,
					      p_failedmsg  TEXT )
                                       
  RETURNS INT
  MODIFIES SQL DATA

BEGIN

  DECLARE record_id INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowFailed SET
      autoflowID        = p_autoflowID,
      failedStage       = p_stage,
      failedMsg         = p_failedmsg,
      failedTs          = NOW();
     
    SELECT LAST_INSERT_ID() INTO record_id;

  END IF;

  RETURN( record_id );

END$$


-- Update autoflow's "failedID" with the new autoflowFailed ID
DROP PROCEDURE IF EXISTS update_autoflow_failedID$$
CREATE PROCEDURE update_autoflow_failedID     ( p_personGUID    CHAR(36),
                                             	p_password      VARCHAR(80),
                                       	     	p_ID            INT,
					  	p_failedID      INT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      ID = p_ID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflow
      SET      failedID = p_failedID
      WHERE    ID = p_ID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Returns complete information about autoflow Failed record
DROP PROCEDURE IF EXISTS read_autoflow_failed_record$$
CREATE PROCEDURE read_autoflow_failed_record    ( p_personGUID    CHAR(36),
                                       	          p_password      VARCHAR(80),
                                       	          p_ID  INT )
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowFailed
  WHERE      ID = p_ID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   failedStage, failedMsg, failedTs
      FROM     autoflowFailed
      WHERE    ID = p_ID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$



-- Revert autoflowStages record fields to DEFAULT -------------------------------------
DROP PROCEDURE IF EXISTS autoflow_stages_revert$$
CREATE PROCEDURE autoflow_stages_revert ( p_personGUID CHAR(36),
                                          p_password   VARCHAR(80),
                                          p_id  INT )

  -- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
       
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  
  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    UPDATE  autoflowStages
    SET   liveUpdate = DEFAULT,
    	  import     = DEFAULT,
	  editing    = DEFAULT
    WHERE   autoflowID = p_id;

  END IF;

END$$



-- Delete autoflowIntensity record ------------------------------------------------------
DROP PROCEDURE IF EXISTS delete_autoflow_intensity_record$$
CREATE PROCEDURE delete_autoflow_intensity_record ( p_personGUID    CHAR(36),
                                     	            p_password      VARCHAR(80),
						    p_autoflowID    INT,
                			       	    p_ID            INT )
  MODIFIES SQL DATA

BEGIN
  
  DECLARE count_records INT;	

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    
    -- Find out if record exists for associated pID 
    SELECT COUNT(*) INTO count_records 
    FROM autoflowIntensity
    WHERE ID = p_ID AND autoflowID = p_autoflowID;

    IF ( count_records > 0 ) THEN
       DELETE FROM autoflowIntensity
       WHERE ID = p_ID AND autoflowID = p_autoflowID;

    END IF;   

  END IF;
      
  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Delete autoflowStatus record ---------------------------------------------------------
DROP PROCEDURE IF EXISTS delete_autoflow_status_record$$
CREATE PROCEDURE delete_autoflow_status_record ( p_personGUID    CHAR(36),
                                     	         p_password      VARCHAR(80),
						 p_autoflowID    INT,
                			       	 p_ID            INT )
  MODIFIES SQL DATA

BEGIN
  
  DECLARE count_records INT;	

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    
    -- Find out if record exists for associated pID 
    SELECT COUNT(*) INTO count_records 
    FROM autoflowStatus
    WHERE ID = p_ID AND autoflowID = p_autoflowID;

    IF ( count_records > 0 ) THEN
       DELETE FROM autoflowStatus
       WHERE ID = p_ID AND autoflowID = p_autoflowID;

    END IF;   

  END IF;
      
  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Delete autoflowFailed record ---------------------------------------------------------
DROP PROCEDURE IF EXISTS delete_autoflow_failed_record$$
CREATE PROCEDURE delete_autoflow_failed_record ( p_personGUID    CHAR(36),
                                     	         p_password      VARCHAR(80),
						 p_autoflowID    INT,
                			       	 p_ID            INT )
  MODIFIES SQL DATA

BEGIN
  
  DECLARE count_records INT;	

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    
    -- Find out if record exists for associated pID 
    SELECT COUNT(*) INTO count_records 
    FROM autoflowFailed
    WHERE ID = p_ID AND autoflowID = p_autoflowID;

    IF ( count_records > 0 ) THEN
       DELETE FROM autoflowFailed
       WHERE ID = p_ID AND autoflowID = p_autoflowID;

       UPDATE autoflow SET failedID = DEFAULT WHERE ID = p_autoflowID;
    END IF;   

  END IF;
      
  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Clean certain field in autoflow record when re-initializing from 2. LIVE_UPDATE ------
DROP PROCEDURE IF EXISTS update_autoflow_at_reset_live_update$$
CREATE PROCEDURE update_autoflow_at_reset_live_update ( p_personGUID    CHAR(36),
                                             	      p_password      VARCHAR(80),
                                       	     	      p_ID    	 INT  )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      ID = p_ID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflow
      SET      dataPath    = DEFAULT,
      	       filename    = DEFAULT,
	       analysisIDs = DEFAULT,
	       intensityID = DEFAULT,
	       statusID    = DEFAULT,
	       failedID    = DEFAULT,
      	       status = 'LIVE_UPDATE'
	       	      
      WHERE    ID = p_ID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Delete record from autoflowHistory table if any ------
DROP PROCEDURE IF EXISTS delete_autoflow_history_record$$
CREATE PROCEDURE delete_autoflow_history_record ( p_personGUID    CHAR(36),
                                             	  p_password      VARCHAR(80),
                                       	     	  p_ID    	 INT  )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowHistory
  WHERE      ID = p_ID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      DELETE FROM  autoflowHistory WHERE ID = p_ID;
      
    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$

-- Delete autoflowAnalysisHistory records for given autoflowID --
DROP PROCEDURE IF EXISTS delete_autoflow_analysis_history_records_by_autoflowID$$
CREATE PROCEDURE delete_autoflow_analysis_history_records_by_autoflowID ( p_personGUID    CHAR(36),
                                             	  			p_password      VARCHAR(80),
                                       	     	  			p_autoflowID     INT  )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowAnalysisHistory
  WHERE      autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      DELETE FROM  autoflowAnalysisHistory WHERE autoflowID = p_autoflowID;
      
    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$

-- Delete autoflowModelsLink records for given autoflowID  --
DROP PROCEDURE IF EXISTS delete_autoflow_model_links_records_by_autoflowID$$
CREATE PROCEDURE  delete_autoflow_model_links_records_by_autoflowID( p_personGUID    CHAR(36),
                                             	  		     p_password      VARCHAR(80),
                                       	     	  		     p_autoflowID     INT  )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowModelsLink
  WHERE      autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      DELETE FROM  autoflowModelsLink WHERE autoflowID = p_autoflowID;
      
    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$

-- set_table_auto_increment procedure --
DROP PROCEDURE IF EXISTS set_table_auto_increment$$
CREATE PROCEDURE  set_table_auto_increment( p_personGUID CHAR(36),
                                            p_password   VARCHAR(80),
                                            p_current_db VARCHAR(255) )
    MODIFIES SQL DATA

BEGIN
  DECLARE max_id_table_history INT DEFAULT 0;
  DECLARE max_id_table         INT DEFAULT 0;
  DECLARE table_auto_increment INT DEFAULT 0;
  DECLARE greatest_value       INT DEFAULT 0;

  DECLARE exit handler for sqlexception
   BEGIN
      
    ROLLBACK;
   END;
   
  DECLARE exit handler for sqlwarning
   BEGIN
     
    ROLLBACK;
   END;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SET @db_name            = p_current_db;

  START TRANSACTION;

  SELECT @autoinc := `AUTO_INCREMENT` FROM  INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'autoflow';
  SELECT @new_autoinc := GREATEST( MAX( ID ) + 1, @autoinc ) FROM autoflowHistory;
  SET @sql = CONCAT('ALTER TABLE autoflow AUTO_INCREMENT = ', @new_autoinc);
  PREPARE st FROM @sql;
  EXECUTE st;     
  
  COMMIT;

END$$


-- ----------------------------------------------------------------------------
-- -- GMP Report --------------------------------------------------------------

-- add new autoflowGMPreport record
DROP PROCEDURE IF EXISTS new_autoflow_gmp_report_record$$
CREATE PROCEDURE new_autoflow_gmp_report_record ( p_personGUID   CHAR(36),
                                    		 p_password      VARCHAR(80),
                                     		 p_autoflowHID   INT,
                                     		 p_autoflowHName VARCHAR(300),
						 p_protocolName  VARCHAR(80),
						 p_filenamepdf   VARCHAR(300) )
                                                        
  MODIFIES SQL DATA

BEGIN
  DECLARE duplicate_key TINYINT DEFAULT 0;

  DECLARE CONTINUE HANDLER FOR 1062
    SET duplicate_key = 1;
	
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowGMPReport SET
      autoflowHistoryID   = p_autoflowHID,
      autoflowHistoryName = p_autoflowHName,
      protocolName        = p_protocolName,
      timeCreated         = NOW(),
      fileNamePdf         = p_filenamepdf;
      
    IF ( duplicate_key = 1 ) THEN
      SET @US3_LAST_ERRNO = @INSERTDUP;
      SET @US3_LAST_ERROR = "MySQL: Duplicate entry for autoflowHistoryID field(s)";

    ELSE
      SET @LAST_INSERT_ID = LAST_INSERT_ID();

    END IF; 

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$

-- UPDATEs the blob data of the autoflowGMPRecord table
DROP PROCEDURE IF EXISTS upload_gmpReportData$$
CREATE PROCEDURE  upload_gmpReportData( p_personGUID   CHAR(36),
                                        p_password     VARCHAR(80),
                                        p_gmpReportID  INT,
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

  ELSEIF ( verify_userlevel( p_personGUID, p_password, @US3_ANALYST ) = @OK ) THEN

    -- Since this is autoflow framework, any user of level >=2 can initiate: 
    UPDATE autoflowGMPReport SET
   	  data  = p_data
    WHERE  ID = p_gmpReportID;

    IF ( not_found = 1 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = "MySQL: No GMP Report data with that ID exists";

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$

-- SELECTs the blob data of the autoflowGMPReport table
DROP PROCEDURE IF EXISTS download_gmpReportData$$
CREATE PROCEDURE download_gmpReportData ( p_personGUID   CHAR(36),
                                          p_password     VARCHAR(80),
                                          p_gmpReportID  INT )
  READS SQL DATA

BEGIN
  DECLARE l_count_GMPReportData INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
 
  -- Get information to verify that there are records
  SELECT COUNT(*)
  INTO   l_count_GMPReportData
  FROM   autoflowGMPReport
  WHERE  ID = p_gmpReportID;

  IF ( l_count_GMPReportData != 1 ) THEN
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
    FROM   autoflowGMPReport
    WHERE  ID = p_gmpReportID;

  END IF;

END$$


-- UPDATEs the blob html_s of the autoflowGMPRecord table
DROP PROCEDURE IF EXISTS upload_gmpReportData_html$$
CREATE PROCEDURE  upload_gmpReportData_html( p_personGUID   CHAR(36),
                                             p_password     VARCHAR(80),
                                             p_gmpReportID  INT,
                                             p_htmlData     LONGBLOB,
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
  SET l_checksum = MD5( p_htmlData );
  SET @DEBUG = CONCAT( l_checksum , ' ', p_checksum );

  IF ( l_checksum != p_checksum ) THEN
  
    -- Checksums don't match; abort
    SET @US3_LAST_ERRNO = @BAD_CHECKSUM;
    SET @US3_LAST_ERROR = "MySQL: Transmission error, bad checksum";

  ELSEIF ( verify_userlevel( p_personGUID, p_password, @US3_ANALYST ) = @OK ) THEN

    -- Since this is autoflow framework, any user of level >=2 can initiate: 
    UPDATE autoflowGMPReport SET
   	  html_s = p_htmlData
    WHERE  ID = p_gmpReportID;

    IF ( not_found = 1 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = "MySQL: No GMP Report data with that ID exists";

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$

-- SELECTs the blob html_s of the autoflowGMPReport table
DROP PROCEDURE IF EXISTS download_gmpReportData_html$$
CREATE PROCEDURE download_gmpReportData_html ( p_personGUID   CHAR(36),
                                             p_password     VARCHAR(80),
                                             p_gmpReportID  INT )
  READS SQL DATA

BEGIN
  DECLARE l_count_GMPReportData INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
 
  -- Get information to verify that there are records
  SELECT COUNT(*)
  INTO   l_count_GMPReportData
  FROM   autoflowGMPReport
  WHERE  ID = p_gmpReportID;

  IF ( l_count_GMPReportData != 1 ) THEN
    -- Probably no rows
    SET @US3_LAST_ERRNO = @NOROWS;
    SET @US3_LAST_ERROR = 'MySQL: no rows exist with that ID (or too many rows)';

    SELECT @NOROWS AS status;
    
  ELSEIF ( verify_userlevel( p_personGUID, p_password, @US3_ANALYST ) != @OK ) THEN
 
    -- verify_user_permission
    SELECT @US3_LAST_ERRNO AS status;

  ELSE

    SELECT @OK AS status;

    SELECT html_s, MD5( html_s )
    FROM   autoflowGMPReport
    WHERE  ID = p_gmpReportID;

  END IF;

END$$




-- UPDATEs to clear a record from the autoflowGMPReport table
DROP PROCEDURE IF EXISTS clear_autoflowGMPReportRecord$$
CREATE PROCEDURE clear_autoflowGMPReportRecord ( p_personGUID   CHAR(36),
                                               p_password       VARCHAR(80),
                                               p_gmpReportID    INT )
  MODIFIES SQL DATA

BEGIN
  DECLARE l_count_GMPReportData INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
 
  -- Get information to verify that there are records
  SELECT COUNT(*)
  INTO   l_count_GMPReportData
  FROM   autoflowGMPReport
  WHERE  ID = p_gmpReportID;

SET @DEBUG = CONCAT('Reference Scan ID = ', p_gmpReportID,
                    'Count = ', l_count_GMPReportData );

  IF ( l_count_GMPReportData != 1 ) THEN
    -- Probably no rows
    SET @US3_LAST_ERRNO =  @NO_AUTOFLOW_RECORD;
    SET @US3_LAST_ERROR = 'MySQL: no rows exist with that ID (or too many rows)';

    SELECT @NOROWS AS status;
    
  ELSEIF ( verify_userlevel( p_personGUID, p_password, @US3_ADMIN ) != @OK ) THEN
 
    -- verify_user_permission
    SELECT @US3_LAST_ERRNO AS status;

  ELSE

    SELECT @OK AS status;

    DELETE FROM autoflowGMPReport
    WHERE ID = p_gmpReportID ;

  END IF;

END$$


-- Returns information about autoflowGMPReport records for listing
DROP PROCEDURE IF EXISTS get_autoflowGMPReport_desc$$
CREATE PROCEDURE  get_autoflowGMPReport_desc( p_personGUID    CHAR(36),
                                       	      p_password      VARCHAR(80) )
                                     
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowGMPReport;


  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   ID, autoflowHistoryID, autoflowHistoryName, protocolName,
      	       timeCreated, fileNamePdf
      FROM     autoflowGMPReport;
     
    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$


-- -------------------------------------------------------------------------------------------
-- - e-Signatures related --------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------

-- --- Returns complete information about autoflowGMPReportEsign record by autoflowID
DROP PROCEDURE IF EXISTS get_gmp_review_info_by_autoflowID$$
CREATE PROCEDURE get_gmp_review_info_by_autoflowID( p_personGUID    CHAR(36),
                                       		    p_password      VARCHAR(80),
                                       		    p_ID            INT )
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowGMPReportEsign
  WHERE      autoflowID = p_ID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NOROWS;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   ID, autoflowID, autoflowName, operatorListJson, reviewersListJson,
      	       eSignStatusJson, eSignStatusAll, createUpdateLogJson, approversListJson,
	       smeListJson
      FROM     autoflowGMPReportEsign
      WHERE    autoflowID = p_ID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$

-- --- Returns complete information about autoflowGMPReportEsignHistory record by autoflowID
DROP PROCEDURE IF EXISTS get_gmp_review_info_by_autoflowID_history$$
CREATE PROCEDURE get_gmp_review_info_by_autoflowID_history( p_personGUID    CHAR(36),
                                       		    	    p_password      VARCHAR(80),
                                       		    	    p_ID            INT )
  READS SQL DATA

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowGMPReportEsignHistory
  WHERE      autoflowID = p_ID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NOROWS;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   ID, autoflowID, autoflowName, operatorListJson, reviewersListJson,
      	       eSignStatusJson, eSignStatusAll, createUpdateLogJson, approversListJson,
	       smeListJson
      FROM     autoflowGMPReportEsignHistory
      WHERE    autoflowID = p_ID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$


-- --- new autoflowGMPReportEsign record ---------------------------------
DROP PROCEDURE IF EXISTS new_gmp_review_record$$
CREATE PROCEDURE  new_gmp_review_record ( p_personGUID   CHAR(36),
                                      	 p_password     VARCHAR(80),
					 p_autoflowID   INT(11),
                                         p_autoflowName VARCHAR(300),
                                         p_operListJson TEXT,
                                         p_revListJson  TEXT,
					 p_apprListJson TEXT,
					 p_smeListJson  TEXT,
                                         p_logJson      TEXT )

  MODIFIES SQL DATA

BEGIN

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowGMPReportEsign SET
       autoflowID          = p_autoflowID,
       autoflowName        = p_autoflowName,
       operatorListJson    = p_operListJson,
       reviewersListJson   = p_revListJson,
       approversListJson   = p_apprListJson,
       smeListJson         = p_smeListJson,
       createUpdateLogJson = p_logJson;

    SET @LAST_INSERT_ID = LAST_INSERT_ID();

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- - new autoflowGMPReportEsignHistory record
DROP PROCEDURE IF EXISTS new_gmp_review_history_record$$
CREATE PROCEDURE new_gmp_review_history_record ( p_personGUID  CHAR(36),
                                       	       p_password      VARCHAR(80),
                                       	       p_ID            INT )
                                    
  MODIFIES SQL DATA

BEGIN
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    INSERT INTO autoflowGMPReportEsignHistory SELECT * FROM autoflowGMPReportEsign WHERE ID = p_ID;
    
    SET @LAST_INSERT_ID = LAST_INSERT_ID();

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$

-- DELETE  autoflowGMPReportEsign record by ID 
DROP PROCEDURE IF EXISTS delete_gmp_review_record_by_id$$
CREATE PROCEDURE delete_gmp_review_record_by_id ( p_personGUID    CHAR(36),
                                     	      	p_password      VARCHAR(80),
                			      	p_ID            INT )
  MODIFIES SQL DATA

BEGIN
  DECLARE count_records INT;	
  
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    
    -- Find out if record exists for associated runID 
    SELECT COUNT(*) INTO count_records 
    FROM  autoflowGMPReportEsign
    WHERE ID = p_ID;

    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'Record cannot be deleted as it does not exist for current experiment run';   

    ELSE
      DELETE FROM autoflowGMPReportEsign
      WHERE ID = p_ID;
    
    END IF;

  END IF;
      
  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Update autoflowGMPReportEsign record by ADMIN assigner
DROP PROCEDURE IF EXISTS update_gmp_review_record_by_admin$$
CREATE PROCEDURE update_gmp_review_record_by_admin ( p_personGUID  CHAR(36),
                                             	     p_password      VARCHAR(80),
                                       	     	     p_eSignID       INT,
					  	     p_autoflowID    INT,
						     p_operListJson  TEXT,
                                                     p_revListJson   TEXT,
						     p_apprListJson  TEXT,
						     p_smeListJson   TEXT,
						     p_eSignJson     TEXT,
						     p_logJson       TEXT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowGMPReportEsign
  WHERE      ID = p_eSignID AND autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowGMPReportEsign
      SET      operatorListJson    = p_operListJson,
      	       reviewersListJson   = p_revListJson,
	       approversListJson   = p_apprListJson,
	       smeListJson         = p_smeListJson,
	       eSignStatusJson     = p_eSignJson,
	       createUpdateLogJson = p_logJson
      WHERE    ID = p_eSignID AND autoflowID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$

-- Update autoflowGMPReportEsign record by e-Signer
DROP PROCEDURE IF EXISTS update_gmp_review_record_by_esigner$$
CREATE PROCEDURE update_gmp_review_record_by_esigner ( p_personGUID  CHAR(36),
                                             	     p_password      VARCHAR(80),
                                       	     	     p_eSignID       INT,
					  	     p_autoflowID    INT,
                                                     p_eSignJson     TEXT,
						     p_eSignAll      TEXT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflowGMPReportEsign
  WHERE      ID = p_eSignID AND autoflowID = p_autoflowID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

    ELSE
      UPDATE   autoflowGMPReportEsign
      SET      eSignStatusJson = p_eSignJson, eSignStatusAll = p_eSignAll
      WHERE    ID = p_eSignID AND autoflowID = p_autoflowID;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Update autoflow's 'gmpReviewID' with the newly returned e-Signature ID
DROP PROCEDURE IF EXISTS update_autoflow_with_gmpReviewID$$
CREATE PROCEDURE update_autoflow_with_gmpReviewID ( p_personGUID   CHAR(36),
                                             	  p_password       VARCHAR(80),
                                       	     	  p_ID		   INT,
					  	  p_gmpReviewID    INT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;
  DECLARE count_records_history INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      ID = p_ID;

  SELECT     COUNT(*)
  INTO       count_records_history
  FROM       autoflowHistory
  WHERE      ID = p_ID; 

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records != 0 ) THEN
      UPDATE   autoflow
      SET      gmpReviewID = p_gmpReviewID
      WHERE    ID = p_ID;
   END IF;    
      
   IF ( count_records_history != 0 ) THEN
      UPDATE   autoflowHistory
      SET      gmpReviewID = p_gmpReviewID
      WHERE    ID = p_ID;            
   END IF;

  END IF;

END$$


-- Update autoflow's 'statusID' with the newly returned statusID
DROP PROCEDURE IF EXISTS update_autoflow_with_statusID$$
CREATE PROCEDURE update_autoflow_with_statusID ( p_personGUID   CHAR(36),
                                             	 p_password       VARCHAR(80),
                                       	     	 p_ID		   INT,
					  	 p_statusID    INT )
  MODIFIES SQL DATA  

BEGIN
  DECLARE count_records INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_records
  FROM       autoflow
  WHERE      ID = p_ID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records != 0 ) THEN
      UPDATE   autoflow
      SET      statusID = p_statusID
      WHERE    ID = p_ID;
   END IF;    
      
  END IF;

END$$



-- UPDATEs the blob data of the autoflowGMPReportEsign
DROP PROCEDURE IF EXISTS upload_gmpReportEsignData$$
CREATE PROCEDURE  upload_gmpReportEsignData( p_personGUID   CHAR(36),
                                       	     p_password     VARCHAR(80),
                                             p_eSignID      INT,
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

  ELSEIF ( verify_userlevel( p_personGUID, p_password, @US3_ANALYST ) = @OK ) THEN

    -- Since this is autoflow framework, any user of level >=2 can initiate: 
    UPDATE autoflowGMPReportEsign SET
   	  data  = p_data
    WHERE  ID = p_eSignID;

    IF ( not_found = 1 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = "MySQL: No GMP Report ESign data with that ID exists";

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$

-- SELECTs the blob data of the autoflowGMPReportEsign table
DROP PROCEDURE IF EXISTS download_gmpReportEsignData$$
CREATE PROCEDURE download_gmpReportEsignData ( p_personGUID   CHAR(36),
                                             p_password     VARCHAR(80),
                                             p_eSignID      INT )
  READS SQL DATA

BEGIN
  DECLARE l_count_GMPReportData INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
 
  -- Get information to verify that there are records
  SELECT COUNT(*)
  INTO   l_count_GMPReportData
  FROM   autoflowGMPReportEsign
  WHERE  ID = p_eSignID;

  IF ( l_count_GMPReportData != 1 ) THEN
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
    FROM   autoflowGMPReportEsign
    WHERE  ID = p_eSignID;

  END IF;

END$$


-- Update and return status of the E-Signing while trying to ESign || update reviewers || upload blob ---
DROP PROCEDURE IF EXISTS autoflow_esigning_status$$
CREATE PROCEDURE autoflow_esigning_status ( p_personGUID CHAR(36),
                                            p_password   VARCHAR(80),
                                            p_id  INT )

  -- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
  DECLARE current_status TEXT;
  DECLARE unique_start TINYINT DEFAULT 0;
       

  DECLARE exit handler for sqlexception
   BEGIN
      -- ERROR
    ROLLBACK;
   END;
   
  DECLARE exit handler for sqlwarning
   BEGIN
     -- WARNING
    ROLLBACK;
   END;


  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';


  START TRANSACTION;
  
  SELECT     esigning
  INTO       current_status
  FROM       autoflowStages
  WHERE      autoflowID = p_id FOR UPDATE;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( current_status = 'unknown' ) THEN
      UPDATE  autoflowStages
      SET     esigning = 'STARTED'
      WHERE   autoflowID = p_id;

      SET unique_start = 1;

    END IF;

  END IF;

  SELECT unique_start as status;
  -- RETURN (unique_start);
  COMMIT;

END$$


-- Revert eSigning status in autoflowStages record ---
DROP PROCEDURE IF EXISTS autoflow_esigning_status_revert$$
CREATE PROCEDURE autoflow_esigning_status_revert ( p_personGUID CHAR(36),
                                                   p_password   VARCHAR(80),
                                                   p_id  INT )

  -- RETURNS INT
  MODIFIES SQL DATA
  
BEGIN
  DECLARE current_status TEXT;
  -- DECLARE unique_start TINYINT DEFAULT 0;
       
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  
  SELECT     esigning
  INTO       current_status
  FROM       autoflowStages
  WHERE      autoflowID = p_id;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( current_status != 'unknown' ) THEN
      UPDATE  autoflowStages
      SET     esigning = DEFAULT
      WHERE   autoflowID = p_id;

    END IF;

  END IF;

  -- SELECT unique_start as status;
  -- RETURN (unique_start);
  
END$$


