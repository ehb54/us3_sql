--
-- us3_buffer_procs.sql
--
-- Script to set up the MySQL stored procedures for the US3 system
--   These are related to the buffer table
-- Run as us3admin
--

DELIMITER $$

-- Verifies that the user has permission to modify
--  the specified buffer
DROP FUNCTION IF EXISTS verify_buffer_permission$$
CREATE FUNCTION verify_buffer_permission( p_personGUID CHAR(36),
                                          p_password   VARCHAR(80),
                                          p_bufferID   INT )
  RETURNS INT
  READS SQL DATA

BEGIN
  DECLARE count_buffers     INT;
  DECLARE count_permissions INT;
  DECLARE status            INT;

  CALL config();
  SET status   = @ERROR;
  SET @US3_LAST_ERROR = 'MySQL: error verifying buffer permission';

  SELECT COUNT(*)
  INTO   count_buffers
  FROM   buffer
  WHERE  bufferID = p_bufferID;

  SELECT COUNT(*)
  INTO   count_permissions
  FROM   bufferPerson
  WHERE  bufferID = p_bufferID
  AND    personID = @US3_ID;

  IF ( count_buffers = 0 ) THEN
    SET @US3_LAST_ERRNO = @NO_BUFFER;
    SET @US3_LAST_ERROR = 'MySQL: the specified buffer does not exist';

    SET status = @NO_BUFFER;

  ELSEIF ( verify_userlevel( p_personGUID, p_password, @US3_ADMIN ) = @OK ) THEN
    SET @US3_LAST_ERRNO = @OK;
    SET @US3_LAST_ERROR = '';

    SET status = @OK;

  ELSEIF ( ( verify_user( p_personGUID, p_password ) = @OK ) &&
           ( count_permissions > 0                         ) ) THEN
    SET @US3_LAST_ERRNO = @OK;
    SET @US3_LAST_ERROR = '';

    SET status = @OK;

  ELSE
    SET @US3_LAST_ERRNO = @NOTPERMITTED;
    SET @US3_LAST_ERROR = 'MySQL: you do not have permission to view or modify this buffer';

    SET status = @NOTPERMITTED;

  END IF;

  RETURN( status );

END$$

-- Returns the count of buffers associated with p_ID
--  If p_ID = 0, retrieves count of all buffers in db
DROP FUNCTION IF EXISTS count_buffers$$
CREATE FUNCTION count_buffers( p_personGUID CHAR(36),
                               p_password   VARCHAR(80),
                               p_ID         INT )
  RETURNS INT
  READS SQL DATA

BEGIN
  
  DECLARE count_buffers INT;

  CALL config();
  SET count_buffers = 0;

  IF ( verify_userlevel( p_personGUID, p_password, @US3_ADMIN ) = @OK ) THEN
    -- This is an admin; he can get more info
    IF ( p_ID > 0 ) THEN
      SELECT COUNT(*)
      INTO   count_buffers
      FROM   bufferPerson
      WHERE  personID = p_ID;

    ELSE
      SELECT COUNT(*)
      INTO   count_buffers
      FROM   bufferPerson;

    END IF;

  ELSEIF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( (p_ID != 0) && (p_ID != @US3_ID) ) THEN
      -- Uh oh, can't do that
      SET @US3_LAST_ERRNO = @NOTPERMITTED;
      SET @US3_LAST_ERROR = 'MySQL: you do not have permission to view those buffers';

    ELSE
      -- This person is asking about his own buffers
      -- Ignore p_ID and return user's own
      SELECT COUNT(*)
      INTO   count_buffers
      FROM   bufferPerson
      WHERE  personID = @US3_ID;

    END IF;

  END IF;

  RETURN( count_buffers );

END$$

-- INSERTs a new buffer with the specified information
DROP PROCEDURE IF EXISTS new_buffer$$
CREATE PROCEDURE new_buffer ( p_personGUID      CHAR(36),
                              p_password        VARCHAR(80),
                              p_bufferGUID      CHAR(36),
                              p_description     TEXT,
                              p_compressibility FLOAT,
                              p_pH              FLOAT,
                              p_density         FLOAT,
                              p_viscosity       FLOAT,
                              p_manual          TINYINT,
                              p_private         TINYINT,
                              p_ownerID         INT )
  MODIFIES SQL DATA

BEGIN
  DECLARE l_bufferID INT;

  DECLARE duplicate_key TINYINT DEFAULT 0;
  DECLARE null_field    TINYINT DEFAULT 0;

  DECLARE CONTINUE HANDLER FOR 1062
    SET duplicate_key = 1;

  DECLARE CONTINUE HANDLER FOR 1048
    SET null_field = 1;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;
 
  IF ( ( verify_user( p_personGUID, p_password ) = @OK ) &&
       ( check_GUID ( p_personGUID, p_password, p_bufferGUID ) = @OK ) ) THEN
    INSERT INTO buffer SET
      bufferGUID      = p_bufferGUID,
      description     = p_description,
      compressibility = p_compressibility,
      pH              = p_pH,
      density         = p_density,
      viscosity       = p_viscosity,
      manual          = p_manual;

    IF ( duplicate_key = 1 ) THEN
      SET @US3_LAST_ERRNO = @INSERTDUP;
      SET @US3_LAST_ERROR = "MySQL: Duplicate entry for bufferGUID field";

    ELSEIF ( null_field = 1 ) THEN
      SET @US3_LAST_ERRNO = @INSERTNULL;
      SET @US3_LAST_ERROR = "MySQL: NULL value for bufferGUID field";

    ELSE
      SET @LAST_INSERT_ID = LAST_INSERT_ID();

      INSERT INTO bufferPerson SET
        bufferID    = @LAST_INSERT_ID,
        personID    = p_ownerID,
        private     = p_private;
    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$

-- UPDATEs an existing buffer with the specified information
DROP PROCEDURE IF EXISTS update_buffer$$
CREATE PROCEDURE update_buffer ( p_personGUID      CHAR(36),
                                 p_password        VARCHAR(80),
                                 p_bufferID        INT,
                                 p_description     TEXT,
                                 p_compressibility FLOAT,
                                 p_pH              FLOAT,
                                 p_density         FLOAT,
                                 p_viscosity       FLOAT,
                                 p_manual          TINYINT,
                                 p_private         TINYINT )
  MODIFIES SQL DATA

BEGIN
  DECLARE not_found     TINYINT DEFAULT 0;

  DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET not_found = 1;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_buffer_permission( p_personGUID, p_password, p_bufferID ) = @OK ) THEN
    UPDATE buffer SET
      description     = p_description,
      compressibility = p_compressibility,
      pH              = p_pH,
      density         = p_density,
      viscosity       = p_viscosity,
      manual          = p_manual
    WHERE bufferID    = p_bufferID;

    IF ( not_found = 1 ) THEN
      SET @US3_LAST_ERRNO = @NO_BUFFER;
      SET @US3_LAST_ERROR = "MySQL: No buffer with that ID exists";

    ELSE
      SET @LAST_INSERT_ID = LAST_INSERT_ID();

      UPDATE bufferPerson SET
        private       = p_private
      WHERE bufferID  = p_bufferID;

    END IF;

  END IF;
      
  SELECT @US3_LAST_ERRNO AS status;

END$$

-- Returns the bufferID associated with the given bufferGUID
DROP PROCEDURE IF EXISTS get_bufferID$$
CREATE PROCEDURE get_bufferID ( p_personGUID CHAR(36),
                                p_password   VARCHAR(80),
                                p_bufferGUID CHAR(36) )
  READS SQL DATA

BEGIN

  DECLARE count_buff INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET count_buff   = 0;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN

    SELECT    COUNT(*)
    INTO      count_buff
    FROM      buffer
    WHERE     bufferGUID = p_bufferGUID;

    IF ( TRIM( p_bufferGUID ) = '' ) THEN
      SET @US3_LAST_ERRNO = @EMPTY;
      SET @US3_LAST_ERROR = CONCAT( 'MySQL: The bufferGUID parameter to the get_bufferID ',
                                    'function cannot be empty' );

    ELSEIF ( count_buff < 1 ) THEN
      SET @US3_LAST_ERRNO = @NOROWS;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';
 
      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   bufferID
      FROM     buffer
      WHERE    bufferGUID = p_bufferGUID;

    END IF;

  END IF;

END$$

-- Returns the bufferID and description of all buffers associated with p_ID
--  If p_ID = 0, retrieves information about all buffers in db
--  Regular user can only get info about his own buffers and public ones
DROP PROCEDURE IF EXISTS get_buffer_desc$$
CREATE PROCEDURE get_buffer_desc ( p_personGUID CHAR(36),
                                   p_password   VARCHAR(80),
                                   p_ID         INT )
  READS SQL DATA

BEGIN

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_userlevel( p_personGUID, p_password, @US3_ADMIN ) = @OK ) THEN
    -- This is an admin; he can get more info
    IF ( count_buffers( p_personGUID, p_password, p_ID ) < 1 ) THEN
      SET @US3_LAST_ERRNO = @NOROWS;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';
   
      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;
  
      IF ( p_ID > 0 ) THEN
        SELECT   b.bufferID, description
        FROM     buffer b, bufferPerson
        WHERE    b.bufferID = bufferPerson.bufferID
        AND      bufferPerson.personID = p_ID
        ORDER BY b.bufferID DESC;
   
      ELSE
        SELECT   b.bufferID, description
        FROM     buffer b, bufferPerson
        WHERE    b.bufferID = bufferPerson.bufferID
        ORDER BY b.bufferID DESC;

      END IF;

    END IF;

  ELSEIF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_buffers( p_personGUID, p_password, p_ID ) < 1 ) THEN
      SET @US3_LAST_ERRNO = @NOROWS;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';
 
      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      -- Ok, user wants his own info
      SELECT @OK AS status;

      IF ( p_ID > 0 ) THEN
        SELECT   b.bufferID, description
        FROM     buffer b, bufferPerson
        WHERE    b.bufferID = bufferPerson.bufferID
        AND      bufferPerson.personID = @US3_ID 
        ORDER BY b.bufferID DESC;
 
      ELSE
        SELECT   b.bufferID, description
        FROM     buffer b, bufferPerson
        WHERE    b.bufferID = bufferPerson.bufferID
        AND      ( ( bufferPerson.personID = @US3_ID ) ||
                 ( private = 0 ) )
        ORDER BY b.bufferID DESC;
      END IF;

    END IF;

  END IF;

END$$

-- Returns a more complete list of information about one buffer
DROP PROCEDURE IF EXISTS get_buffer_info$$
CREATE PROCEDURE get_buffer_info ( p_personGUID CHAR(36),
                                   p_password   VARCHAR(80),
                                   p_bufferID   INT )
  READS SQL DATA

BEGIN
  DECLARE count_buffers INT;
  DECLARE is_private    TINYINT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET is_private      = 1;

  SELECT     COUNT(*)
  INTO       count_buffers
  FROM       buffer
  WHERE      bufferID = p_bufferID;

  SELECT     private
  INTO       is_private
  FROM       bufferPerson
  WHERE      bufferID = p_bufferID;

  -- Either the user needs access permissions or the buffer needs to be public
  IF ( ( verify_buffer_permission( p_personGUID, p_password, p_bufferID ) = @OK ) ||
       ( ( verify_user( p_personGUID, p_password ) = @OK ) && ! is_private ) ) THEN
    IF ( count_buffers = 0 ) THEN
      SET @US3_LAST_ERRNO = @NOROWS;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   bufferGUID, description, compressibility, pH, viscosity,
               density, manual, personID, private
      FROM     buffer b, bufferPerson bp
      WHERE    b.bufferID = bp.bufferID
      AND      b.bufferID = p_bufferID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$

-- DELETEs a buffer, plus information in related tables
DROP PROCEDURE IF EXISTS delete_buffer$$
CREATE PROCEDURE delete_buffer ( p_personGUID CHAR(36),
                                 p_password   VARCHAR(80),
                                 p_bufferID   INT )
  MODIFIES SQL DATA

BEGIN
  DECLARE count_buffers INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_buffer_permission( p_personGUID, p_password, p_bufferID ) = @OK ) THEN

    -- Find out if this buffer is used in any solution first
    SELECT COUNT(*) INTO count_buffers
    FROM solutionBuffer
    WHERE bufferID = p_bufferID;

    IF ( count_buffers = 0 ) THEN
    
      DELETE FROM bufferLink
      WHERE bufferID = p_bufferID;

      DELETE FROM bufferPerson
      WHERE bufferID = p_bufferID;

      DELETE FROM extinctionProfile 
      WHERE componentID = p_bufferID
      AND   componentType = 'Buffer';

      DELETE FROM buffer
      WHERE bufferID = p_bufferID;

    ELSE
      SET @US3_LAST_ERRNO = @BUFFER_IN_USE;
      SET @US3_LAST_ERROR = 'The buffer is in use in a solution';

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$

-- SELECTs descriptions for all buffer components
DROP PROCEDURE IF EXISTS get_buffer_component_desc$$
CREATE PROCEDURE get_buffer_component_desc ( p_personGUID CHAR(36),
                                             p_password   VARCHAR(80) )
  READS SQL DATA

BEGIN
  DECLARE count_components INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    SELECT    COUNT(*)
    INTO      count_components
    FROM      bufferComponent;

    IF ( count_components = 0 ) THEN
      SET @US3_LAST_ERRNO = @NOROWS;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';
 
      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT bufferComponentID, description
      FROM bufferComponent
      ORDER BY description;
 
    END IF;

  END IF;

END$$

-- Returns a more complete list of information about one buffer component
DROP PROCEDURE IF EXISTS get_buffer_component_info$$
CREATE PROCEDURE get_buffer_component_info ( p_personGUID  CHAR(36),
                                             p_password    VARCHAR(80),
                                             p_componentID INT )
  READS SQL DATA

BEGIN
  DECLARE count_components INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     COUNT(*)
  INTO       count_components
  FROM       bufferComponent
  WHERE      bufferComponentID = p_componentID;

  IF ( verify_user( p_personGUID, p_password ) = @OK ) THEN
    IF ( count_components = 0 ) THEN
      SET @US3_LAST_ERRNO = @NOROWS;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';

      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   units, description, viscosity, density, c_range,
               gradientForming
      FROM     bufferComponent
      WHERE    bufferComponentID = p_componentID;

    END IF;

  ELSE
    SELECT @US3_LAST_ERRNO AS status;

  END IF;

END$$

-- adds a new buffer component from bufferComponent
DROP PROCEDURE IF EXISTS add_buffer_component$$
CREATE PROCEDURE add_buffer_component ( p_personGUID    CHAR(36),
                                        p_password      VARCHAR(80),
                                        p_bufferID      INT,
                                        p_componentID   INT,
                                        p_concentration FLOAT )
  MODIFIES SQL DATA

BEGIN
  DECLARE count_buffers    INT;
  DECLARE count_components INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  SELECT     COUNT(*)
  INTO       count_buffers
  FROM       buffer
  WHERE      bufferID = p_bufferID;

  SELECT     COUNT(*)
  INTO       count_components
  FROM       bufferComponent
  WHERE      bufferComponentID = p_componentID;

  IF ( verify_buffer_permission( p_personGUID, p_password, p_bufferID ) = @OK ) THEN
    IF ( count_buffers < 1 ) THEN
      SET @US3_LAST_ERRNO = @NO_BUFFER;
      SET @US3_LAST_ERROR = CONCAT('MySQL: No buffer with ID ',
                                   p_bufferID,
                                   ' exists' );

    ELSEIF ( count_components < 1 ) THEN
      SET @US3_LAST_ERRNO = @NO_COMPONENT;
      SET @US3_LAST_ERROR = CONCAT('MySQL: No buffer component with ID ',
                                   p_componentID,
                                   ' exists' );

    ELSE
      INSERT INTO bufferLink SET
        bufferID          = p_bufferID,
        bufferComponentID = p_componentID,
        concentration     = p_concentration;

      SET @LAST_INSERT_ID = LAST_INSERT_ID();

    END IF;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$

-- Returns information about all buffer components of a single buffer
DROP PROCEDURE IF EXISTS get_buffer_components$$
CREATE PROCEDURE get_buffer_components ( p_personGUID CHAR(36),
                                         p_password   VARCHAR(80),
                                         p_bufferID   INT )
  READS SQL DATA

BEGIN
  DECLARE count_components INT;
  DECLARE is_private       TINYINT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  SELECT     private
  INTO       is_private
  FROM       bufferPerson
  WHERE      bufferID = p_bufferID;

  -- Either the user needs access permissions or the buffer needs to be public
  IF ( ( verify_buffer_permission( p_personGUID, p_password, p_bufferID ) = @OK ) ||
       ( ( verify_user( p_personGUID, p_password ) = @OK ) && ! is_private ) ) THEN
    SELECT    COUNT(*)
    INTO      count_components
    FROM      bufferLink
    WHERE     bufferID = p_bufferID;

    IF ( count_components = 0 ) THEN
      SET @US3_LAST_ERRNO = @NOROWS;
      SET @US3_LAST_ERROR = 'MySQL: no rows returned';
 
      SELECT @US3_LAST_ERRNO AS status;

    ELSE
      SELECT @OK AS status;

      SELECT   l.bufferComponentID, description, viscosity, density, concentration
      FROM     bufferLink l, bufferComponent c
      WHERE    l.bufferComponentID = c.bufferComponentID
      AND      l.bufferID = p_bufferID
      ORDER BY description;
 
    END IF;

  END IF;

END$$

-- DELETEs all components associated with a buffer
DROP PROCEDURE IF EXISTS delete_buffer_components$$
CREATE PROCEDURE delete_buffer_components ( p_personGUID CHAR(36),
                                            p_password   VARCHAR(80),
                                            p_bufferID   INT )
  MODIFIES SQL DATA

BEGIN
  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';

  IF ( verify_buffer_permission( p_personGUID, p_password, p_bufferID ) = @OK ) THEN
    DELETE FROM bufferLink
    WHERE bufferID = p_bufferID;

  END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$


-- creates a new buffer component
DROP PROCEDURE IF EXISTS create_buffer_component$$
CREATE PROCEDURE create_buffer_component ( p_personGUID    CHAR(36),
                                        p_password      VARCHAR(80),
                                        p_componentGUID CHAR(36),
                                        p_name          TEXT,
                                        p_unit          TEXT,
                                        p_range         TEXT,
                                        p_grad_form     TINYINT(1),
                                        p_density       TEXT,
                                        p_viscosity     TEXT)
  MODIFIES SQL DATA

BEGIN
  DECLARE count_bufferscomps    INT;

  CALL config();
  SET @US3_LAST_ERRNO = @OK;
  SET @US3_LAST_ERROR = '';
  SET @LAST_INSERT_ID = 0;

  SELECT     COUNT(*)
  INTO       count_bufferscomps
  FROM       bufferComponent;

  IF ( verify_userlevel( p_personGUID, p_password, 2 ) = @OK ) THEN

      INSERT INTO bufferComponent SET
        bufferComponentID= count_bufferscomps+1,
        description              = p_name,
        units     = p_unit,
        gradientForming        = p_grad_form,
        density           = p_density,
        viscosity         = p_viscosity,
        c_range              = p_range;

      SET @LAST_INSERT_ID = LAST_INSERT_ID();

    END IF;

  SELECT @US3_LAST_ERRNO AS status;

END$$
