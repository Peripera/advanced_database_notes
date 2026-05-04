

--This script creates three triggers for the PET_CARE_LOG table --

--Create database --

CREATE TABLE PRODUCT (
    PRODUCT_ID INT PRIMARY KEY,
    DESCRIPTION VARCHAR2(255)
);

CREATE TABLE CUSTOMER (
    CUST_ID INT PRIMARY KEY,
    NAME VARCHAR2(100),
    ADDRESS VARCHAR2(255)
);

CREATE TABLE CUSTOMER_SALE (
    SALES_ID INT PRIMARY KEY,
    CUST_ID INT,
    FOREIGN KEY (CUST_ID) REFERENCES CUSTOMER(CUST_ID)
);

CREATE TABLE SALE_ITEM (
    SALES_ID INT,
    PRODUCT_ID INT,
    PRIMARY KEY (SALES_ID, PRODUCT_ID),
    FOREIGN KEY (SALES_ID) REFERENCES CUSTOMER_SALE(SALES_ID),
    FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCT(PRODUCT_ID)
);

CREATE TABLE PET_CARE_LOG (
    PRODUCT_ID INT,
    LOG_DATETIME TIMESTAMP,
    COMMENTS VARCHAR2(255),
    PRIMARY KEY (PRODUCT_ID, LOG_DATETIME),
    FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCT(PRODUCT_ID)
);



ALTER TABLE PET_CARE_LOG
ADD (
    UPDATE_DATE TIMESTAMP,
    UPDATED_BY_USER VARCHAR2(100)
);



-- Trigger 1: Before INSERT automatically assign the current date/time and current user before inserting a new log --

CREATE OR REPLACE TRIGGER protect_insert
BEFORE INSERT ON PET_CARE_LOG
FOR EACH ROW
BEGIN
    :NEW.UPDATE_DATE := SYSTIMESTAMP;
    :NEW.UPDATED_BY_USER := USER;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Error in trigger protect_insert: ' || SQLERRM
        );
END;
/
SHOW ERRORS;



--Trigger 2: Allows users to update only records they created --

CREATE OR REPLACE TRIGGER protect_update
BEFORE UPDATE ON PET_CARE_LOG
FOR EACH ROW
BEGIN
    IF USER = :OLD.UPDATED_BY_USER THEN
        :NEW.UPDATE_DATE := SYSTIMESTAMP;
        :NEW.UPDATED_BY_USER := USER;
    ELSE
        RAISE_APPLICATION_ERROR(
            -20002,
            'Update not allowed: current user is different from UPDATED_BY_USER.'
        );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE BETWEEN -20999 AND -20000 THEN
            RAISE;
        ELSE
            RAISE_APPLICATION_ERROR(
                -20003,
                'Error in trigger protect_update: ' || SQLERRM
            );
        END IF;
END;
/
SHOW ERRORS;



--Trigger 3: Allows deleting only if the current user is 'JOEMANAGER' --

CREATE OR REPLACE TRIGGER protect_delete
BEFORE DELETE ON PET_CARE_LOG
FOR EACH ROW
BEGIN
    IF UPPER(USER) = 'JOEMANAGER' THEN
        NULL;
    ELSE
        RAISE_APPLICATION_ERROR(
            -20004,
            'Delete not allowed: only JOEMANAGER can delete PET_CARE_LOG records.'
        );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE BETWEEN -20999 AND -20000 THEN
            RAISE;
        ELSE
            RAISE_APPLICATION_ERROR(
                -20005,
                'Error in trigger protect_delete: ' || SQLERRM
            );
        END IF;
END;
/
SHOW ERRORS;


-- test --
INSERT INTO PRODUCT (PRODUCT_ID, DESCRIPTION)
VALUES (1, 'Dog food');

INSERT INTO PET_CARE_LOG (PRODUCT_ID, LOG_DATETIME, COMMENTS)
VALUES (1, SYSTIMESTAMP, 'Pet was fed');

SELECT *
FROM PET_CARE_LOG;