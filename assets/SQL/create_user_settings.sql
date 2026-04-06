-- User profile settings table
-- Stores per-user preferences as key/value pairs (value is JSON for complex types)
CREATE TABLE DAILY_TASKS_USER_SETTINGS (
    EMPLID       VARCHAR2(20)  NOT NULL,
    SETTING_KEY  VARCHAR2(100) NOT NULL,
    SETTING_VALUE CLOB,
    UPDATED_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT PK_USER_SETTINGS PRIMARY KEY (EMPLID, SETTING_KEY)
);
