-- Table for keeping user authentication data
CREATE TABLE user (
  id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
  username VARCHAR(255) NOT NULL,
  password VARCHAR(255) NOT NULL,
  created_on TIMESTAMP not null default CURRENT_TIMESTAMP,
  CONSTRAINT UC_Person UNIQUE (username)
);

-- Add test user data to user table
INSERT INTO user(username,password) VALUES('admin@kinaracapital.com', 'U2FsdGVkX186sXUUePpaCfVmrvRl+bZHCekxOIzavw4='); 
-- password: admin@amlcheck

-- stored procedure for user sanction list validate
DELIMITER $$
DROP PROCEDURE IF EXISTS `validate_user`$$
CREATE PROCEDURE `validate_user`(
	IN `user_email` TEXT,
    IN `user_nationality` TEXT,
    IN `user_passport_no` TEXT,
    IN `user_national_identification_no` TEXT,
    IN `user_drivers_license_no` TEXT,
    
    IN `user_name` TEXT,
    IN `user_dob` TEXT,
    IN `user_pob` TEXT,
    IN `user_address` TEXT,
    IN `user_gender` TEXT,
    IN `user_aadhar_no` TEXT,
    IN `user_pan_no` TEXT
    )
BEGIN
    DECLARE listLength INT DEFAULT 0;
	DECLARE primaryTempListLength INT DEFAULT 0;
    DECLARE secondaryTempListLength INT DEFAULT 0;
    DECLARE primaryCheck INT DEFAULT 0;
    DECLARE nameCheck INT DEFAULT 0;
    DECLARE dobCheck FLOAT(6,3) DEFAULT 0.000;
    DECLARE pobCheck FLOAT(6,3) DEFAULT 0;
    DECLARE addressCheck FLOAT(6,3) DEFAULT 0;
    DECLARE genderCheck INT DEFAULT 0;
    DECLARE nationalityCheck INT DEFAULT 0;
    DECLARE nationalIdentificationNumberCheck INT DEFAULT 0;
    DECLARE drivingLicenseNumberCheck INT DEFAULT 0;
    DECLARE passportNumberCheck INT DEFAULT 0;
    DECLARE userDobLength INT DEFAULT 0;
    DECLARE emailCheck INT DEFAULT 0;
    DECLARE aadharCheck INT DEFAULT 0;
    DECLARE panCheck INT DEFAULT 0;
    
    SELECT COUNT(*) INTO listLength FROM sanctions_list;
--   primary check - email, nationality + passport no, nationality + driving license no, nationality + national ID
	IF(listLength > 0)
    THEN
        SELECT 1 into primaryCheck
        FROM sanctions_list
        WHERE 
        (
            (user_email IS NOT NULL AND (LOWER(TRIM(user_email)) MEMBER OF(LOWER(TRIM(sanctions_list.email_address))))) OR
            (user_passport_no IS NOT NULL AND user_nationality IS NOT NULL AND (
                (JSON_SEARCH(LOWER(TRIM(sanctions_list.passport_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_passport_no))), '%')))) AND
                ((LOWER(TRIM(user_nationality))) MEMBER OF (LOWER(TRIM(sanctions_list.nationality))))
            )) OR
            (user_drivers_license_no IS NOT NULL AND user_nationality IS NOT NULL AND (
                ((LOWER(TRIM(user_nationality))) MEMBER OF (LOWER(TRIM(sanctions_list.nationality)))) AND
                (JSON_SEARCH(LOWER(TRIM(sanctions_list.drivers_license_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_drivers_license_no))), '%'))))
            )) OR
            (user_national_identification_no IS NOT NULL AND user_nationality IS NOT NULL AND (
				((LOWER(TRIM(user_nationality))) MEMBER OF (LOWER(TRIM(sanctions_list.nationality)))) AND
				(
                    (JSON_SEARCH(LOWER(TRIM(sanctions_list.national_identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_national_identification_no))), '%')))) OR
                    (JSON_SEARCH(LOWER(TRIM(sanctions_list.identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_national_identification_no))), '%'))))
                )
            )) OR
            (user_aadhar_no IS NOT NULL AND user_nationality IS NOT NULL AND (
				((LOWER(TRIM(user_nationality))) MEMBER OF (LOWER(TRIM(sanctions_list.nationality)))) AND
				(
                    (JSON_SEARCH(LOWER(TRIM(sanctions_list.national_identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_aadhar_no))), '%')))) OR
                    (JSON_SEARCH(LOWER(TRIM(sanctions_list.identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_aadhar_no))), '%'))))
                )
            )) OR
            (user_pan_no IS NOT NULL AND user_nationality IS NOT NULL AND (
				((LOWER(TRIM(user_nationality))) MEMBER OF (LOWER(TRIM(sanctions_list.nationality)))) AND
				(
                    (JSON_SEARCH(LOWER(TRIM(sanctions_list.national_identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_pan_no))), '%')))) OR
                    (JSON_SEARCH(LOWER(TRIM(sanctions_list.identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_pan_no))), '%'))))
                )
            ))
        )
        GROUP BY 1;
    END IF;

    IF(primaryCheck = 1)
    THEN
        SELECT 1 into emailCheck
            FROM sanctions_list
            WHERE
            (
                user_email IS NOT NULL AND (LOWER(TRIM(user_email)) MEMBER OF(LOWER(TRIM(sanctions_list.email_address))))
            )
            GROUP BY 1; 
        
        IF(emailCheck != 1 OR emailCheck IS NULL)
        THEN
            SELECT 1, 1 into passportNumberCheck, nationalityCheck
            FROM sanctions_list
            WHERE
                (
                    user_passport_no IS NOT NULL AND user_nationality IS NOT NULL AND (
                    (JSON_SEARCH(LOWER(TRIM(sanctions_list.passport_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_passport_no))), '%')))) AND
                    ((LOWER(TRIM(user_nationality))) MEMBER OF (LOWER(TRIM(sanctions_list.nationality)))))
                )
            GROUP BY 1;
        END IF;

        IF((passportNumberCheck != 1 OR passportNumberCheck IS NULL) AND (nationalityCheck != 1 OR nationalityCheck IS NULL))
        THEN
            SELECT 1, 1 into drivingLicenseNumberCheck, nationalityCheck
            FROM sanctions_list
            WHERE
                (
                    user_drivers_license_no IS NOT NULL AND user_nationality IS NOT NULL AND (
			        ((LOWER(TRIM(user_nationality))) MEMBER OF (LOWER(TRIM(sanctions_list.nationality)))) AND
			        (JSON_SEARCH(LOWER(TRIM(sanctions_list.drivers_license_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_drivers_license_no))), '%')))))
                )
            GROUP BY 1;
        END IF;

        IF((drivingLicenseNumberCheck != 1 OR drivingLicenseNumberCheck IS NULL) AND (nationalityCheck != 1 OR nationalityCheck IS NULL))
        THEN
			SELECT 1, 1 into nationalIdentificationNumberCheck, nationalityCheck
            FROM sanctions_list
            WHERE
                (user_national_identification_no IS NOT NULL AND user_nationality IS NOT NULL AND (
					((LOWER(TRIM(user_nationality))) MEMBER OF (LOWER(TRIM(sanctions_list.nationality)))) AND
					(
                        (JSON_SEARCH(LOWER(TRIM(sanctions_list.national_identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_national_identification_no))), '%')))) OR
                        (JSON_SEARCH(LOWER(TRIM(sanctions_list.identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_national_identification_no))), '%'))))
                    )
				))
			GROUP BY 1;
        END IF;

        IF((nationalIdentificationNumberCheck != 1 OR nationalIdentificationNumberCheck IS NULL) AND (nationalityCheck != 1 OR nationalityCheck IS NULL))
        THEN
			SELECT 1, 1 into aadharCheck, nationalityCheck
            FROM sanctions_list
            WHERE
                (user_aadhar_no IS NOT NULL AND user_nationality IS NOT NULL AND (
					((LOWER(TRIM(user_nationality))) MEMBER OF (LOWER(TRIM(sanctions_list.nationality)))) AND
					(
                        (JSON_SEARCH(LOWER(TRIM(sanctions_list.national_identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_aadhar_no))), '%')))) OR
                        (JSON_SEARCH(LOWER(TRIM(sanctions_list.identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_aadhar_no))), '%'))))
                    )
				))
			GROUP BY 1;
        END IF;

        IF((aadharCheck != 1 OR aadharCheck IS NULL) AND (nationalityCheck != 1 OR nationalityCheck IS NULL))
        THEN
			SELECT 1, 1 into panCheck, nationalityCheck
            FROM sanctions_list
            WHERE
                (user_pan_no IS NOT NULL AND user_nationality IS NOT NULL AND (
					((LOWER(TRIM(user_nationality))) MEMBER OF (LOWER(TRIM(sanctions_list.nationality)))) AND
					(
                        (JSON_SEARCH(LOWER(TRIM(sanctions_list.national_identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_pan_no))), '%')))) OR
                        (JSON_SEARCH(LOWER(TRIM(sanctions_list.identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_pan_no))), '%'))))
                    )
				))
			GROUP BY 1;
        END IF;
    END IF;

-- fuzzy logic - name, dob, pob, address, gender, nationality, National ID, Driving ID, passport no
	IF ((primaryCheck != 1 OR primaryCheck IS NULL) AND (listLength > 0))
		THEN
	-- name check
		DROP TEMPORARY TABLE IF EXISTS primary_temp_list;
		CREATE TEMPORARY TABLE IF NOT EXISTS primary_temp_list
		AS SELECT *
		FROM sanctions_list
		WHERE (
			(user_name IS NOT NULL AND
                (LOWER(TRIM(sanctions_list.name)) LIKE (CONCAT('%', (LOWER(TRIM(user_name))), '%'))) OR 
                (JSON_SEARCH(LOWER(TRIM(sanctions_list.alias_name_good_quality)), 'one', (CONCAT('%', (LOWER(TRIM(user_name))), '%')))) OR 
                (JSON_SEARCH(LOWER(TRIM(sanctions_list.alias_name_low_quality)), 'one', (CONCAT('%', (LOWER(TRIM(user_name))), '%'))))
            )
            -- (LOWER(TRIM(sanctions_list.name)) = LOWER(TRIM(user_name))) OR 
			-- (LOWER(TRIM(user_name)) MEMBER OF (LOWER(TRIM(sanctions_list.alias_name_good_quality)))) OR
			-- (LOWER(TRIM(user_name)) MEMBER OF (LOWER(TRIM(sanctions_list.alias_name_low_quality)))))
		);

		SELECT COUNT(*) INTO primaryTempListLength FROM primary_temp_list;
		SELECT COUNT(*) INTO secondaryTempListLength FROM sanctions_list;
		
		IF(primaryTempListLength != 0 OR (primaryTempListLength = secondaryTempListLength))
		THEN
			SET nameCheck = 1;
		ELSE
			SET nameCheck = 0;
			INSERT INTO primary_temp_list
			SELECT * FROM sanctions_list;
		END IF;

        IF(nameCheck = 1)
        THEN
            -- 	check gender
                DROP TEMPORARY TABLE IF EXISTS secondary_temp_list;
                CREATE TEMPORARY TABLE IF NOT EXISTS secondary_temp_list 
                SELECT *
                FROM primary_temp_list
                WHERE (
                    (user_gender IS NOT NULL AND (LOWER(TRIM(primary_temp_list.gender)) = LOWER(TRIM(user_gender))))
                );
                
                SELECT COUNT(*) INTO primaryTempListLength FROM primary_temp_list;
                SELECT COUNT(*) INTO secondaryTempListLength FROM secondary_temp_list;

                IF(secondaryTempListLength != 0 OR (primaryTempListLength = secondaryTempListLength))
                THEN
                    SET genderCheck = 1;
                ELSE
                    SET genderCheck = 0;
                    TRUNCATE secondary_temp_list;
                    INSERT INTO secondary_temp_list
                    SELECT * FROM primary_temp_list;
                END IF;
                
            -- 	dob check
                IF(YEAR(user_dob)>0)
                THEN
                    SET userDobLength = (userDobLength + 1);
                END IF;

                IF(MONTH(user_dob)>0)
                THEN
                    SET userDobLength = (userDobLength + 1);
                END IF;

                IF(DAY(user_dob)>0)
                THEN
                    SET userDobLength = (userDobLength + 1);
                END IF;

                IF(SELECT COUNT(*) FROM secondary_temp_list WHERE user_dob MEMBER OF (secondary_temp_list.dob))
                THEN
                    SET dobCheck = 1;
                ELSE
                    IF(SELECT COUNT(*) FROM secondary_temp_list WHERE (
                        JSON_SEARCH(secondary_temp_list.dob, 'one', (CONCAT(DATE_FORMAT(user_dob,'%Y'),'-',DATE_FORMAT(user_dob,'%m'),'-%'))) OR
                        JSON_SEARCH(secondary_temp_list.dob, 'one', (CONCAT(DATE_FORMAT(user_dob,'%Y'),'-%-',DATE_FORMAT(user_dob,'%d')))) OR
                        JSON_SEARCH(secondary_temp_list.dob, 'one', (CONCAT('%-',DATE_FORMAT(user_dob,'%m'),'-',DATE_FORMAT(user_dob,'%d'))))
                        ))
                    THEN
                        SET dobCheck = (2/userDobLength);
                    ELSEIF(SELECT COUNT(*) FROM secondary_temp_list WHERE (
                        JSON_SEARCH(secondary_temp_list.dob, 'one', (CONCAT(DATE_FORMAT(user_dob,'%Y'),'-%'))) OR
                        JSON_SEARCH(secondary_temp_list.dob, 'one', (CONCAT('%-', DATE_FORMAT(user_dob,'%m'), '-%'))) OR
                        JSON_SEARCH(secondary_temp_list.dob, 'one', (CONCAT('%-', DATE_FORMAT(user_dob,'%d')))) OR
                        JSON_SEARCH(secondary_temp_list.dob, 'one', (DATE_FORMAT(user_dob,'%Y')))
                        ))
                    THEN
                        SET dobCheck = (1/userDobLength);
                    END IF;
                END IF;

            -- pob check
                SET pobCheck = (SELECT validate_pob(user_pob, 'secondary_temp_list'));
                
            -- address check
                SET addressCheck = (SELECT validate_address(user_address, 'secondary_temp_list'));
            
            --     pob check
                -- SELECT 1 INTO pobCheck
                -- FROM secondary_temp_list
                -- WHERE (
                --     (user_pob IS NOT NULL AND (
                --         JSON_SEARCH(LOWER(TRIM(secondary_temp_list.pob)), 'one', (CONCAT('%', (LOWER(TRIM(REPLACE(user_pob, ',', '%')))))), '%')
                --     ))
                -- )
                -- GROUP BY 1;
            
            -- address check
                -- SELECT 1 INTO addressCheck
                -- FROM secondary_temp_list
                -- WHERE (
                --     (user_address IS NOT NULL AND (
                --         JSON_SEARCH(LOWER(TRIM(secondary_temp_list.address)), 'one', (CONCAT('%', (LOWER(TRIM(REPLACE(user_address, ',', '%')))))), '%')
                --     ))
                -- )
                -- GROUP BY 1;
                
            -- check Nationality
                -- SELECT 1 INTO nationalityCheck
                -- FROM secondary_temp_list
                -- WHERE (
                --     (user_nationality IS NOT NULL AND (LOWER(TRIM(user_nationality)) MEMBER OF (LOWER(secondary_temp_list.nationality))))
                -- )
                -- GROUP BY 1;
                
            -- 	check passport number
                -- SELECT 1 INTO passportNumberCheck
                -- FROM secondary_temp_list
                -- WHERE (
                --     (user_passport_no IS NOT NULL AND (
                --         JSON_SEARCH(LOWER(TRIM(secondary_temp_list.passport_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_passport_no))), '%')))
                --     ))
                -- )
                -- GROUP BY 1;
            
            -- 	check Driving license number
            -- SELECT 1 INTO drivingLicenseNumberCheck
            -- FROM secondary_temp_list
            -- WHERE (
            --     (user_drivers_license_no IS NOT NULL AND (
            --         JSON_SEARCH(LOWER(TRIM(secondary_temp_list.drivers_license_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_drivers_license_no))), '%')))
            --     ))
            -- )
            -- GROUP BY 1;

        -- 	check national identification number
			-- SELECT 1 INTO nationalIdentificationNumberCheck
			-- FROM secondary_temp_list
			-- WHERE (
			-- 	(user_national_identification_no IS NOT NULL AND (
			-- 		(JSON_SEARCH(LOWER(TRIM(secondary_temp_list.national_identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_national_identification_no))), '%')))) OR
            --         (JSON_SEARCH(LOWER(TRIM(secondary_temp_list.identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_national_identification_no))), '%'))))
			-- 	))
			-- )
			-- GROUP BY 1;

        -- 	check aadhar number
			-- SELECT 1 INTO aadharCheck
			-- FROM secondary_temp_list
			-- WHERE (
			-- 	(user_aadhar_no IS NOT NULL AND (
			-- 		(JSON_SEARCH(LOWER(TRIM(secondary_temp_list.national_identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_aadhar_no))), '%')))) OR
            --         (JSON_SEARCH(LOWER(TRIM(secondary_temp_list.identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_aadhar_no))), '%'))))
			-- 	))
			-- )
			-- GROUP BY 1;

        -- 	check pan number
			-- SELECT 1 INTO panCheck
			-- FROM secondary_temp_list
			-- WHERE (
			-- 	(user_pan_no IS NOT NULL AND (
			-- 		(JSON_SEARCH(LOWER(TRIM(secondary_temp_list.national_identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_pan_no))), '%')))) OR
            --         (JSON_SEARCH(LOWER(TRIM(secondary_temp_list.identification_no)), 'one', (CONCAT('%', (LOWER(TRIM(user_pan_no))), '%'))))
			-- 	))
			-- )
			-- GROUP BY 1;
        END IF;
    END IF;
    
    SELECT COALESCE(primaryCheck,0) AS primary_count, (
		COALESCE(nameCheck,0)+
		COALESCE(dobCheck,0)+
		COALESCE(pobCheck,0)+
		COALESCE(addressCheck,0)+
		COALESCE(genderCheck,0)+
        COALESCE(nationalityCheck,0)+
	    COALESCE(nationalIdentificationNumberCheck,0)+
        COALESCE(drivingLicenseNumberCheck)+
        COALESCE(passportNumberCheck)
	) AS secondary_count,
    emailCheck AS email,
    nameCheck AS name,
    dobCheck AS dob,
    pobCheck AS pob,
    addressCheck AS address,
    genderCheck AS gender,
    nationalityCheck AS nationality,
    drivingLicenseNumberCheck AS drivers_license_no,
    passportNumberCheck AS passport_no,
    nationalIdentificationNumberCheck AS national_identification_no,
    aadharCheck AS aadhar_no,
    panCheck AS pan_no;
    
END$$
DELIMITER ;



-- function to validate POB
DELIMITER //

DROP FUNCTION IF EXISTS validate_pob;
CREATE FUNCTION validate_pob(user_pob TEXT, data_table TEXT) 
RETURNS FLOAT(6,3) DETERMINISTIC
BEGIN
DECLARE pobCheck1 FLOAT(6,3) DEFAULT 0.000;
DECLARE pobCheck2 FLOAT(6,3) DEFAULT 0.000;
DECLARE inputStringLength INT DEFAULT 0;
DECLARE length INT DEFAULT 0;
DECLARE counter INT DEFAULT 0;
DECLARE stringCounter INT DEFAULT 0;
DECLARE subString TEXT DEFAULT '';
DECLARE isDataFound INT DEFAULT 0;
 
 SET inputStringLength = (SELECT SUM(LENGTH(user_pob) - LENGTH(REPLACE(	user_pob, ',', '')) + 1));
 SELECT COUNT(*) FROM secondary_temp_list INTO length;
 SET counter=0;
 tableLoop: WHILE (counter<length) DO
  SET stringCounter = 1;
  SET pobCheck1 = 0;

  inputStringLoop: WHILE stringCounter<=inputStringLength DO
	SET subString = null;
	SET subString = (SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(user_pob,',', stringCounter), ',',-1)); -- get substring
	
    SET isDataFound = 0;
    SELECT 1 INTO isDataFound FROM secondary_temp_list WHERE subString IS NOT NULL AND (LOWER(TRIM(subString))) MEMBER OF (LOWER(TRIM(secondary_temp_list.pob))) LIMIT counter,1;

    IF(isDataFound = 1)
	THEN
		SET pobCheck1 = (pobCheck1+(1/inputStringLength));
	END IF;

    SET stringCounter = stringCounter + 1;
  END WHILE inputStringLoop;
  
  IF(pobCheck1 = 1)
  THEN
	SET pobCheck2 = pobCheck1;
    LEAVE tableLoop;
  ELSEIF((pobCheck1 != 0.000) AND (pobCheck2 < pobCheck1)) THEN
	SET pobCheck2 = pobCheck1;
    SET counter = counter + 1;
  ELSE 
	SET counter = counter + 1;
  END IF;
END WHILE tableLoop;
    IF(pobCheck2 >= 0.95)
    THEN
		SET pobCheck2 = 1;
	END IF;
RETURN pobCheck2;

END 

//
DELIMITER ;


-- function to validate address
DELIMITER //
DROP FUNCTION IF EXISTS validate_address;
CREATE FUNCTION validate_address (user_address TEXT, data_table TEXT)
RETURNS FLOAT(6,3) DETERMINISTIC

BEGIN
DECLARE addressCheck1 FLOAT(6,3) DEFAULT 0.000;
DECLARE addressCheck2 FLOAT(6,3) DEFAULT 0.000;
DECLARE inputStringLength INT DEFAULT 0;
DECLARE length INT DEFAULT 0;
DECLARE counter INT DEFAULT 0;
DECLARE stringCounter INT DEFAULT 0;
DECLARE subString TEXT DEFAULT '';
DECLARE isDataFound INT DEFAULT 0;

SET inputStringLength = (SELECT SUM(LENGTH(user_address) - LENGTH(REPLACE(	user_address, ',', '')) + 1));
 SELECT COUNT(*) FROM secondary_temp_list INTO length;
 SET counter=0;
  tableLoop: WHILE (counter<length) DO
  SET stringCounter = 1;
  SET addressCheck1 = 0;

  inputStringLoop: WHILE stringCounter<=inputStringLength DO
	SET subString = null;
	SET subString = (SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(user_address,',', stringCounter), ',',-1)); -- get substring
	
    SET isDataFound = 0;
    SELECT 1 INTO isDataFound FROM secondary_temp_list WHERE subString IS NOT NULL AND (LOWER(TRIM(subString))) MEMBER OF (LOWER(TRIM(address))) LIMIT counter,1;

    IF(isDataFound = 1)
	THEN
		SET addressCheck1 = (addressCheck1+(1/inputStringLength));
	END IF;

    SET stringCounter = stringCounter + 1;
  END WHILE inputStringLoop;
  
  IF(addressCheck1 = 1)
  THEN
	SET addressCheck2 = addressCheck1;
    LEAVE tableLoop;
  ELSEIF((addressCheck1 != 0.000) AND (addressCheck2 < addressCheck1)) THEN
	SET addressCheck2 = addressCheck1;
    SET counter = counter + 1;
  ELSE 
	SET counter = counter + 1;
  END IF;
END WHILE tableLoop;

    IF(addressCheck2 >= 0.95)
    THEN
		SET addressCheck2 = 1;
	END IF;

   RETURN addressCheck2;

END; //

DELIMITER ;
