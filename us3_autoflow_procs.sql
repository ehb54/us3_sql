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
    FROM      autoflow;
    
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
      optimaName        = p_optimaname,
      invID             = p_invID,
      label		= p_label,
      created           = NOW(),
      gmpRun            = p_gmprun,
      aprofileGUID      = p_aprofileguid,
      operatorID        = p_operatorID;

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
               intensityID, statusID, failedID
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
               intensityID, statusID, failedID
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
  FROM       autoflow;


  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_records = 0 ) THEN
      SET @US3_LAST_ERRNO = @NO_AUTOFLOW_RECORD;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   ID, protName, cellChNum, tripleNum, duration, runName, expID, 
      	       runID, status, dataPath, optimaName, runStarted, invID, created, gmpRun, filename, operatorID  
      FROM     autoflow;
     
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
      	       runID, status, dataPath, optimaName, runStarted, invID, created, gmpRun, filename  
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



-- Update autoflow record with next stage && filename at EDITING (LIMS IMPORT)
DROP PROCEDURE IF EXISTS update_autoflow_at_lims_import$$
CREATE PROCEDURE update_autoflow_at_lims_import ( p_personGUID    CHAR(36),
                                             	p_password      VARCHAR(80),
                                       	     	p_runID    	INT,
					  	p_filename      VARCHAR(300),
                                                p_optima        VARCHAR(300),
                                                p_intensityID   INT,
						p_statusID      INT )
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
      SET      filename = p_filename, status = 'EDIT_DATA', intensityID = p_intensityID, statusID = p_statusID
      WHERE    runID = p_runID AND optimaName = p_optima;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$




-- Update autoflow record with next stage at EDIT DATA (EDIT DATA to ANALYSIS)
DROP PROCEDURE IF EXISTS update_autoflow_at_edit_data$$
CREATE PROCEDURE update_autoflow_at_edit_data ( p_personGUID    CHAR(36),
                                             	p_password      VARCHAR(80),
                                       	     	p_runID    	INT,
						p_analysisIDs   TEXT,
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
      SET      status = 'ANALYSIS', analysisIDs = p_analysisIDs
      WHERE    runID = p_runID AND optimaName = p_optima;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- Update autoflow record with next stage at ANALYSIS (ANALYSIS  to REPORT)
DROP PROCEDURE IF EXISTS update_autoflow_at_analysis$$
CREATE PROCEDURE update_autoflow_at_analysis   ( p_personGUID    CHAR(36),
                                             	p_password      VARCHAR(80),
                                       	     	p_runID    	INT,
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
      SET      status = 'REPORT'
      WHERE    runID = p_runID AND optimaName = p_optima;

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


--- Create reacord in the autoflowAnalysis table ------------------------

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

---- read AutoflowAnalysis record -------------------------------------------
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


---- read AutoflowAnalysis record -------------------------------------------
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




----  get initial elapsed time upon reattachment ----------------------------- 
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



----  get initial elapsed time upon reattachment ----------------------------- 
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

----  TEST: TO BE DELETED: get initial elapsed time upon reattachment ----------------------------- 
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


-------------------------------------------------------------------------
--- PROCS and FUNCTIONS related to report and reportItem tables
-------------------------------------------------------------------------

--- Create record in the report table ------------------------

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



--- Create record in the reportItem table ------------------------

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
				p_combinedplot TINYINT )
                                       
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
      combinedPlot      = p_combinedplot;
     
    SELECT LAST_INSERT_ID() INTO reportitem_id;

  END IF;

  RETURN( reportitem_id );

END$$



----- Returns complete information about autoflowReport record by ID
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

      SELECT   channelName, totalConc, rmsdLimit, avIntensity, expDuration, wavelength, totalConcTol, expDurationTol, reportMaskJson
      FROM     autoflowReport 
      WHERE    reportID = p_reportID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$



----- Returns list of autoflowReportItem IDs by parent report's ID
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


----- Returns complete information about autoflowReportItem record by ID
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

      SELECT   type, method, rangeLow, rangeHi, integration, tolerance, totalPercent, combinedPlot
      FROM     autoflowReportItem 
      WHERE    reportItemID = p_reportItemID;

    END IF;
 
  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$

--- Create reacord in the autoflowIntensity table ------------------------

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
  WHERE      autoflowID = p_autoflowID AND tripleName = p_triplename;

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


--- Get ID of the autoflowStatus record by autoflowID -----------------------------

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

--- Create record in the autoflowStatus table via importRI ------------------------

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


--- Create record in the autoflowStatus table via importIP ------------------------

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



-- Update autoflowStatus record via analysis FITMEN
DROP PROCEDURE IF EXISTS update_autoflowStatusAnalysisFitmen_record$$
CREATE PROCEDURE update_autoflowStatusAnalysisFitmen_record ( p_personGUID    CHAR(36),
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

      SELECT   importRI, importRIts, importIP, importIPts,
               editRI, editRIts, editIP, editIPts, analysis
      FROM     autoflowStatus 
      WHERE    ID = p_ID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$


-- Set AUTO_INCREMENT in autolfow to greater of:
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


-- Set AUTO_INCREMENT in autolfowAnalysis to greater of:
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


--------------------------------------------------------------------------------------------------------------
---- stored procs related to autoflowFailed table, clearing autolfow fields, and exp./rawData-----------------
--------------------------------------------------------------------------------------------------------------

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
