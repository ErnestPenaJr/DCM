<cfcomponent>

    <cfset variables.config = {}>

    <cffunction name="init" access="public" returntype="any">
        <cfset var configPath = expandPath("/config/config.json")>
        <cfif fileExists(configPath)>
            <cfset var fileContent = fileRead(configPath)>
            <cfset variables.config = deserializeJSON(fileContent)>
        <cfelse>
            <cfthrow message="Config file not found at #configPath#">
        </cfif>
        <cfreturn this>
    </cffunction>

    <cfset init()>

    <cffunction name="saveTask" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="TASK_NAME" type="any" required="false" default="" />
        <cfargument name="TASK_DESCRIPTION" type="any" required="false" default="" />
        <cfargument name="CLASSIFICATION" type="any" required="false" default="" />
        <cfargument name="WORK_TYPE" type="any" required="false" default="" />
        <cfargument name="TASK_TIME" type="any" required="false" default="" />
        <cfargument name="PROJECT" type="any" required="false" default="" />
        <cfargument name="DEPTID" type="any" required="false" default="" />
        <cfargument name="ALLOCATED_TIME" type="any" required="false" default="" />
        <cfargument name="WEEK_NUM" type="any" required="false" default="" />
        <cfargument name="DATE" type="any" required="false" default="" />
        <cfargument name="WEEKLY_NOTE" type="any" required="false" default="" />
        <cfargument name="DAY_NUM" type="any" required="false" default="" />
        <cfargument name="EMPLID" type="any" required="false" default="" />
        <!---<cfdump var="#arguments#" />--->
        
        <cfset var retVal = ArrayNew(1)>
        <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#"  name="insert">
            INSERT INTO #variables.config.db.schema#.DAILY_TASKS (TASK_NAME,TASK_DESCRIPTION,CLASSIFICATION, WORK_TYPE, TASK_TIME,PROJECT,DEPTID,ALLOCATED_TIME,WEEK_NUMBER,TASK_DATE,WEEKLY_NOTE,DAY_NUM,EMPLID)
            VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TASK_NAME#" />,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TASK_DESCRIPTION#" />,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CLASSIFICATION#" />,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.WORK_TYPE#" />,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TASK_TIME#" />,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT#" />,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.DEPTID#" />,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ALLOCATED_TIME#" />,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.WEEK_NUM#" />,
                    <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.DATE#" />,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.WEEKLY_NOTE#" />,
                    <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.DAY_NUM#" />,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EMPLID#" />)
        </cfquery>

        <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#"  name="results">
            SELECT t.TASK_ID,t.TASK_NAME,t.TASK_DESCRIPTION, t.CLASSIFICATION, t.WORK_TYPE, t.TASK_TIME,t.PROJECT,t.DEPTID,t.ALLOCATED_TIME,t.WEEK_NUMBER,t.TASK_DATE,t.DAY_NUM,t.WEEKLY_NOTE
            FROM #variables.config.db.schema#.DAILY_TASKS t
            WHERE t.TASK_ID = (SELECT MAX(t.TASK_ID) AS MaxID FROM #variables.config.db.schema#.DAILY_TASKS)
            ORDER BY t.WEEK_NUMBER ASC
        </cfquery>

        <cfloop query="results">
                <cfset temp = {} />
                <cfset temp["TASKID"] = TASK_ID />
                <cfset temp["TASK_NAME"] = TASK_NAME />
                <cfset temp["TASK_DESCRIPTION"] = TASK_DESCRIPTION />
                <cfset temp["CLASSIFICATION"] = CLASSIFICATION />
                <cfset temp["WORK_TYPE"] = WORK_TYPE />
                <cfset temp["TASK_TIME"] = TASK_TIME />
                <cfset temp["PROJECT"] = PROJECT />
                <cfset temp["DEPTID"] = DEPTID />
                <cfset temp["ALLOCATED_TIME"] = ALLOCATED_TIME />
                <cfset temp["WEEK_NUM"] = WEEK_NUMBER />
                <cfset temp["DATE"] = TASK_DATE />
                <cfset temp["DAY_NUM"] = DAY_NUM />
                <cfset temp["WEEKLY_NOTE"] = WEEKLY_NOTE />
                <cfset ArrayAppend(retval, temp)>
        </cfloop>

        <cfset result = {} />
        <cfset result['items'] = retVal />
        <cfreturn result />
    </cffunction>

    <cffunction name="getTaskByWeek" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="WEEK_NUM" type="string" required="false" default="" />
        <cfargument name="EMPLID" type="string" required="false" default="" />
        <cfset var retVal = ArrayNew(1)>
        <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#" name="results">
            SELECT t.TASK_ID, t.TASK_NAME, t.TASK_DESCRIPTION,t.CLASSIFICATION,t.WORK_TYPE, t.TASK_TIME, t.PROJECT, t.DEPTID, t.TASK_DATE, t.DAY_NUM, p.PROJECT_NAME, t.WEEK_NUMBER, t.WEEKLY_NOTE, t.ALLOCATED_TIME, t.EMPLID
            FROM #variables.config.db.schema#.DAILY_TASKS t
            JOIN #variables.config.db.schema#.DAILY_TASKS_PROJECTS p ON t.PROJECT = p.PROJECT_ID
            WHERE t.PROJECT = p.PROJECT_ID
            AND t.WEEK_NUMBER = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.WEEK_NUM#" />
            AND t.EMPLID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EMPLID#" />
            AND t.TASK_DATE BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#CreateDate(Year(Now()), 1, 1)#" /> 
            AND <cfqueryparam cfsqltype="cf_sql_date" value="#CreateDate(Year(Now()), 12, 31)#" />
            ORDER BY WEEK_NUMBER DESC, DAY_NUM ASC
        </cfquery>

        <cfloop query="results">
            <cfset temp = {} />
            <cfset temp["TASKID"] = TASK_ID />
            <cfset temp["TASK_NAME"] = TASK_NAME />
            <cfset temp["TASK_DESCRIPTION"] = TASK_DESCRIPTION />
            <cfset temp["CLASSIFICATION"] = CLASSIFICATION />
            <cfset temp["WORK_TYPE"] = WORK_TYPE />
            <cfset temp["TASK_TIME"] = TASK_TIME />
            <cfset temp["DATE"] = TASK_DATE />
            <cfset temp["PROJECT"] = PROJECT />
            <cfset temp["DEPTID"] = DEPTID />
            <cfset temp["ALLOCATED_TIME"] = ALLOCATED_TIME />
            <cfset temp["WEEK_NUM"] = WEEK_NUMBER />
            <cfset temp["PROJECT"] = PROJECT />
            <cfset temp["DAY_NUM"] = DAY_NUM />
            <cfset temp["WEEKLY_NOTE"] = WEEKLY_NOTE />
            <cfset temp["PROJECT_NAME"] = PROJECT_NAME />
            <cfset temp["EMPLID"] = EMPLID />
            <cfset ArrayAppend(retval, temp)>
        </cfloop>

        <cfset result = {} />
        <cfset result['items'] = retVal />
        <cfreturn result />
    </cffunction>

    <cffunction name="getTaskByDay" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="DAY_NUM" type="string" required="false" default="" />
        <cfargument name="EMPLID" type="string" required="false" default="" />

        <cfset var retVal = ArrayNew(1)>
        <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#"  name="results">
            SELECT t.TASK_ID,t.TASK_NAME,t.TASK_DESCRIPTION,t.TASK_TIME,t.PROJECT,t.DEPTID ,t.TASK_DATE, t.DAY_NUM,p.PROJECT_NAME,t.WEEK_NUMBER, t.WEEKLY_NOTE,t.DAY_NUM, t.WEEKLY_NOTE, t.ALLOCATED_TIME,t.EMPLID
            FROM #variables.config.db.schema#.DAILY_TASKS t, #variables.config.db.schema#.DAILY_TASKS_PROJECTS p
            WHERE t.PROJECT = p.PROJECT_ID
            AND t.DAY_NUM = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.DAY_NUM#" />
            AND t.EMPLID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EMPLID#" />
            ORDER BY WEEK_NUMBER DESC, DAY_NUM ASC
        </cfquery>

        <cfloop query="results">
            <cfset temp = {} />
            <cfset temp["TASKID"] = TASK_ID />
            <cfset temp["TASK_NAME"] = TASK_NAME />
            <cfset temp["TASK_DESCRIPTION"] = TASK_DESCRIPTION />
            <cfset temp["TASK_TIME"] = TASK_TIME />
            <cfset temp["DATE"] = TASK_DATE />
            <cfset temp["PROJECT"] = PROJECT />
            <cfset temp["DEPTID"] = DEPTID />
            <cfset temp["ALLOCATED_TIME"] = ALLOCATED_TIME />
            <cfset temp["WEEK_NUM"] = WEEK_NUMBER />
            <cfset temp["PROJECT"] = PROJECT />
            <cfset temp["DAY_NUM"] = DAY_NUM />
            <cfset temp["WEEKLY_NOTE"] = WEEKLY_NOTE />
            <cfset temp["PROJECT_NAME"] = PROJECT_NAME />
            <cfset temp["EMPLID"] = EMPLID />
            <cfset ArrayAppend(retval, temp)>
        </cfloop>

        <cfset result = {} />
        <cfset result['items'] = retVal />
        <cfreturn result />
    </cffunction>

    <cffunction name="getAllTasks" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="EMPLID" type="string" required="false" default="" />
        <cfset var retVal = ArrayNew(1)>
        <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#"  name="results">
            SELECT t.TASK_ID,t.TASK_NAME,t.TASK_DESCRIPTION,t.TASK_TIME,t.PROJECT,t.DEPTID ,t.TASK_DATE, t.DAY_NUM,p.PROJECT_NAME,t.WEEK_NUMBER, t.WEEKLY_NOTE, TO_CHAR(t.TASK_DATE,'YYYY') as TASK_YEAR
            FROM #variables.config.db.schema#.DAILY_TASKS t, #variables.config.db.schema#.DAILY_TASKS_PROJECTS p
            WHERE t.PROJECT = p.PROJECT_ID
            AND t.EMPLID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EMPLID#" />
            ORDER BY TASK_DATE DESC

        </cfquery>

        <cfloop query="results">
                <cfset temp = {} />
                <cfset temp["TASKID"] = TASK_ID />
                <cfset temp["TASK_NAME"] = TASK_NAME />
                <cfset temp["TASK_DESCRIPTION"] = TASK_DESCRIPTION />
                <cfset temp["TASK_TIME"] = "#TASK_TIME# min." />
                <cfset temp["PROJECT"] = PROJECT />
                <cfset temp["DEPTID"] = DEPTID />
                <cfset temp["DATE"] = DATEFORMAT(TASK_DATE,'mm/dd/yyyy') />
                <cfset temp["TASK_DATE"] = TASK_DATE />
                <cfset temp["WEEK_NUMBER"] = WEEK_NUMBER />
                <cfset temp["PROJECT_NAME"] = PROJECT_NAME />
                <cfset temp["NOTES"] = WEEKLY_NOTE />

                <cfif DAY_NUM EQ 1>
                    <cfset temp["WEEK_DAY"] = "Monday" />
                <cfelseif DAY_NUM EQ 2>
                    <cfset temp["WEEK_DAY"] = "Tuesday" />
                <cfelseif DAY_NUM EQ 3>
                    <cfset temp["WEEK_DAY"] = "Wednesday" />
                <cfelseif DAY_NUM EQ 4>
                    <cfset temp["WEEK_DAY"] = "Thursday" />
                <cfelseif DAY_NUM EQ 5> 
                    <cfset temp["WEEK_DAY"] = "Friday" />
                <cfelseif DAY_NUM EQ 6>
                    <cfset temp["WEEK_DAY"] = "Saturday" />
                <cfelseif DAY_NUM EQ 0>
                    <cfset temp["WEEK_DAY"] = "Sunday" />
                </cfif>
                <cfset ArrayAppend(retval, temp)>
        </cfloop>
        <cfset result = {} />
        <cfset result['data'] = retVal />
        <cfreturn result />
    </cffunction>

    <cffunction name="getWeeklySummary" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="WEEK_NUM" type="string" required="false" default="" />
        <cfargument name="EMPLID" type="string" required="false" default="" />
        <cfset var retVal = ArrayNew(1)>
        
        <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#" name="results">
            SELECT 
                t.TASK_NAME,
                t.CLASSIFICATION,
                t.WORK_TYPE,
                p.PROJECT_NAME,
                t.DEPTID,
                SUM(CAST(t.TASK_TIME AS NUMBER)) as TOTAL_TIME,
                COUNT(*) as OCCURRENCE_COUNT,
                AVG(CAST(t.TASK_TIME AS NUMBER)) as AVG_TIME_PER_DAY,
                MIN(t.TASK_DATE) as FIRST_OCCURRENCE,
                MAX(t.TASK_DATE) as LAST_OCCURRENCE,
                LISTAGG(DISTINCT TO_CHAR(t.TASK_DATE, 'DAY'), ', ') WITHIN GROUP (ORDER BY t.TASK_DATE) as DAYS_WORKED,
                t.WEEK_NUMBER
            FROM #variables.config.db.schema#.DAILY_TASKS t
            JOIN #variables.config.db.schema#.DAILY_TASKS_PROJECTS p ON t.PROJECT = p.PROJECT_ID
            WHERE t.WEEK_NUMBER = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.WEEK_NUM#" />
            AND t.EMPLID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EMPLID#" />
            AND t.TASK_DATE BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#CreateDate(Year(Now()), 1, 1)#" /> 
            AND <cfqueryparam cfsqltype="cf_sql_date" value="#CreateDate(Year(Now()), 12, 31)#" />
            GROUP BY t.TASK_NAME, t.CLASSIFICATION, t.WORK_TYPE, p.PROJECT_NAME, t.DEPTID, t.WEEK_NUMBER
            ORDER BY TOTAL_TIME DESC, t.CLASSIFICATION, t.TASK_NAME
        </cfquery>

        <cfloop query="results">
            <cfset temp = {} />
            <cfset temp["TASK_NAME"] = TASK_NAME />
            <cfset temp["CLASSIFICATION"] = CLASSIFICATION />
            <cfset temp["WORK_TYPE"] = WORK_TYPE />
            <cfset temp["PROJECT_NAME"] = PROJECT_NAME />
            <cfset temp["DEPTID"] = DEPTID />
            <cfset temp["TOTAL_TIME"] = TOTAL_TIME />
            <cfset temp["OCCURRENCE_COUNT"] = OCCURRENCE_COUNT />
            <cfset temp["AVG_TIME_PER_DAY"] = NumberFormat(AVG_TIME_PER_DAY, "0.0") />
            <cfset temp["FIRST_OCCURRENCE"] = DateFormat(FIRST_OCCURRENCE, "mm/dd/yyyy") />
            <cfset temp["LAST_OCCURRENCE"] = DateFormat(LAST_OCCURRENCE, "mm/dd/yyyy") />
            <cfset temp["DAYS_WORKED"] = DAYS_WORKED />
            <cfset temp["WEEK_NUMBER"] = WEEK_NUMBER />
            <cfset temp["TOTAL_HOURS"] = NumberFormat(TOTAL_TIME / 60, "0.0") />
            <cfset ArrayAppend(retval, temp)>
        </cfloop>

        <cfset result = {} />
        <cfset result['items'] = retVal />
        <cfreturn result />
    </cffunction>

    <cffunction name="getTaskHistory" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="WEEK" type="string" required="true" />
        <cfargument name="EMPLID" type="string" required="true" />
        <cfset var retVal = ArrayNew(1)>
        
        <!--- This is a placeholder. Actual implementation would involve database query. --->
        <cfreturn { "data": retVal } />
    </cffunction>

</cfcomponent>
