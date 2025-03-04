
-- mysql version
CREATE TABLE DAILY_TASKS (
    TASK_ID     INT(10) PRIMARY KEY,
    EMPLID      INT(10) NOT NULL,
    TASK_NAME     VARCHAR(225) NOT NULL,
    DESCRIPTION   VARCHAR(500) NOT NULL,
    TASK_TIME     TIME NOT NULL,
    PROJECT       VARCHAR(225) NOT NULL,
    DEPTID        INT(10) NOT NULL,
    ALLOCATED_TIME INT(10) NOT NULL,
    WEEK_NUMBER   INT(10) NOT NULL,
    DATE          DATE NOT NULL,
    DAY_NUM       INT(10) NOT NULL,
    WEEKLY_NOTE   VARCHAR(500) NOT NULL
);

-- oracle version
CREATE TABLE DAILY_TASKS (
    TASK_ID     NUMBER PRIMARY KEY,
    EMPLID      NUMBER(10) NOT NULL,
    TASK_NAME     VARCHAR(225) NOT NULL,
    TASK_DESCRIPTION   VARCHAR(500) NOT NULL,
    CLASSIFICATION VARCHAR(225) NOT NULL,
    WORK_TYPE VARCHAR(225) NOT NULL,
    TASK_TIME     NUMBER(11) NOT NULL,
    PROJECT       VARCHAR(225) NOT NULL,
    DEPTID        NUMBER(10) NOT NULL,
    ALLOCATED_TIME NUMBER(10) NOT NULL,
    WEEK_NUMBER   NUMBER(10) NOT NULL,
    TASK_DATE          DATE NOT NULL,
    DAY_NUM       NUMBER(10) NOT NULL,
    WEEKLY_NOTE   VARCHAR(500) NOT NULL
);
CREATE SEQUENCE DAILY_TASKSSeq START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER DAILY_TASKSTrigger
BEFORE INSERT ON DAILY_TASKS
FOR EACH ROW
BEGIN
  IF :NEW.TASK_ID IS NULL THEN
    SELECT DAILY_TASKSSeq.NEXTVAL INTO :NEW.TASK_ID FROM dual;
  END IF;
END;


CREATE TABLE DAILY_TASKS_PROJECTS (
    PROJECT_ID NUMBER(10)  PRIMARY KEY,
    PROJECT_NAME VARCHAR(225) NOT NULL,
    PROJECT_DESCRIPTION VARCHAR(500) NOT NULL,
    DATECREATED DATE DEFAULT SYSDATE,
    STATUS VARCHAR(225) NOT NULL
);

CREATE SEQUENCE DAILY_TASKS_PROJECTSSeq START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER DAILY_TASKS_PROJECTSTrigger
BEFORE INSERT ON DAILY_TASKS_PROJECTS
FOR EACH ROW
BEGIN
  IF :NEW.EntryID IS NULL THEN
    SELECT DAILY_TASKS_PROJECTSSeq.NEXTVAL INTO :NEW.PROJECT_ID FROM dual;
  END IF;
END;

CREATE TABLE DAILY_TASKS_USERACCESS (
	USERID     NUMBER(10) PRIMARY KEY,
	EMPLID   VARCHAR2(15) NOT NULL,
  PERMISSIONID   VARCHAR2(15) NOT NULL,
	ALLOWEDACCESS     CHAR(1) DEFAULT 'N' CHECK (ALLOWEDACCESS IN ('Y', 'N')), -- 'Y' for Yes, 'N' for No
 	LASTLOGIN DATE,
	CREATEDBYID VARCHAR(50),
	CREATEDBYDATE DATE DEFAULT SYSDATE ,
	MODIFIEDBYID VARCHAR(50),
	MODIFIEDBYDATE DATE
);
CREATE SEQUENCE DAILY_TASKS_USERACCESSSeq START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER DAILY_TASKS_USERACCESTRigger
BEFORE INSERT ON DAILY_TASKS_USERACCESS
FOR EACH ROW
BEGIN
  IF :NEW.USERID IS NULL THEN
  SELECT DAILY_TASKS_USERACCESSSeq.NEXTVAL INTO :NEW.USERID FROM dual;
  END IF;
END;

CREATE TABLE DAILY_TASKS_PERMISSIONS (
  PERMISSIONID     NUMBER(10) PRIMARY KEY,
  PERMISSIONNAME   VARCHAR2(100) NOT NULL,
  DESCRIPTION     VARCHAR2(500)
);
CREATE SEQUENCE DAILY_TASKS_PERMISSIONSSeq START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER DAILY_TASKS_PERMISSIONSTrigger
BEFORE INSERT ON DAILY_TASKS_PERMISSIONS
FOR EACH ROW
BEGIN
  IF :NEW.PERMISSIONID IS NULL THEN
  SELECT DAILY_TASKS_PERMISSIONSSeq.NEXTVAL INTO :NEW.PERMISSIONID FROM dual;
  END IF;
END;
