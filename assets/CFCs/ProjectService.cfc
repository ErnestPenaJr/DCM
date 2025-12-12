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

    <cffunction name="getProjects" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="PID" type="string" required="false" default="" />
        <cfset var retVal = ArrayNew(1)>
        <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#"  name="results">
            SELECT PROJECT_ID, PROJECT_NAME, PROJECT_DESCRIPTION
            FROM #variables.config.db.schema#.DAILY_TASKS_PROJECTS
            WHERE STATUS = 'A'
            ORDER BY PROJECT_NAME ASC
        </cfquery>

        <cfloop query="results">
                <cfset temp = {} />
                <cfset temp["PID"] = PROJECT_ID />
                <cfset temp["PROJECT_NAME"] = PROJECT_NAME />
                <cfset temp["PROJECT_DESCRIPTION"] = PROJECT_DESCRIPTION />
                <cfset ArrayAppend(retval, temp)>
        </cfloop>
        <cfset result = {} />
        <cfset result['items'] = retVal />
        <cfreturn result />
    </cffunction>

    <cffunction name="getAllProjects" access="remote" returntype="any" returnformat="JSON">
        <cfset var retVal = ArrayNew(1)>
        <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#" name="results">
            SELECT 
                p.PROJECT_ID, 
                p.PROJECT_NAME, 
                p.PROJECT_DESCRIPTION, 
                p.STATUS,
                p.DATECREATED,
                COALESCE(task_counts.TASK_COUNT, 0) as TASK_COUNT
            FROM #variables.config.db.schema#.DAILY_TASKS_PROJECTS p
            LEFT JOIN (
                SELECT 
                    dt.PROJECT,
                    COUNT(*) as TASK_COUNT
                FROM #variables.config.db.schema#.DAILY_TASKS dt
                GROUP BY dt.PROJECT
            ) task_counts ON p.PROJECT_ID = task_counts.PROJECT
        </cfquery>

        <cfloop query="results">
            <cfset temp = {} />
            <cfset temp["PROJECT_ID"] = PROJECT_ID />
            <cfset temp["PROJECT_NAME"] = PROJECT_NAME />
            <cfset temp["PROJECT_DESCRIPTION"] = PROJECT_DESCRIPTION />
            <cfset temp["STATUS"] = STATUS />
            <cfset temp["CREATED_DATE"] = DateFormat(DATECREATED, "mm/dd/yyyy") />
            <cfset temp["CREATED_BY"] = "" />
            <cfset temp["MODIFIED_DATE"] = "" />
            <cfset temp["MODIFIED_BY"] = "" />
            <cfset temp["TASK_COUNT"] = TASK_COUNT />
            <cfset ArrayAppend(retval, temp)>
        </cfloop>
        
        <cfset result = {} />
        <cfset result['items'] = retVal />
        <cfreturn result />
    </cffunction>

    <cffunction name="getProjectById" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="PROJECT_ID" type="string" required="true">
        
        <cfset var retVal = {}>
        <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#" name="results">
            SELECT 
                p.PROJECT_ID, 
                p.PROJECT_NAME, 
                p.PROJECT_DESCRIPTION, 
                p.STATUS,
                p.DATECREATED,
                (SELECT COUNT(*) FROM #variables.config.db.schema#.DAILY_TASKS dt WHERE dt.PROJECT = p.PROJECT_ID) as TASK_COUNT
            FROM #variables.config.db.schema#.DAILY_TASKS_PROJECTS p
            WHERE p.PROJECT_ID = <cfqueryparam value="#arguments.PROJECT_ID#" cfsqltype="CF_SQL_NUMERIC">
        </cfquery>

        <cfif results.recordCount>
            <cfset retVal = {
                "PROJECT_ID": results.PROJECT_ID,
                "PROJECT_NAME": results.PROJECT_NAME,
                "PROJECT_DESCRIPTION": results.PROJECT_DESCRIPTION,
                "STATUS": results.STATUS,
                "DATECREATED": DateFormat(results.DATECREATED, "mm/dd/yyyy"),
                "TASK_COUNT": results.TASK_COUNT
            }>
        </cfif>
        
        <cfreturn retVal>
    </cffunction>

    <cffunction name="createProject" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="PROJECT_NAME" type="string" required="true">
        <cfargument name="PROJECT_DESCRIPTION" type="string" required="true">
        <cfargument name="STATUS" type="string" required="false" default="A">
        <cfargument name="CREATED_BY" type="string" required="true">
        
        <cftry>
            <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#">
                INSERT INTO #variables.config.db.schema#.DAILY_TASKS_PROJECTS
                (PROJECT_ID, PROJECT_NAME, PROJECT_DESCRIPTION, STATUS)
                VALUES
                (
                    (SELECT NVL(MAX(PROJECT_ID), 0) + 1 FROM #variables.config.db.schema#.DAILY_TASKS_PROJECTS),
                    <cfqueryparam value="#arguments.PROJECT_NAME#" cfsqltype="CF_SQL_VARCHAR" maxlength="225">,
                    <cfqueryparam value="#arguments.PROJECT_DESCRIPTION#" cfsqltype="CF_SQL_VARCHAR" maxlength="500">,
                    <cfqueryparam value="#arguments.STATUS#" cfsqltype="CF_SQL_CHAR" maxlength="1">
                )
            </cfquery>
            
            <cfset var retVal = {}>
            <cfset retVal["success"] = true>
            <cfset retVal["message"] = "Project created successfully">
            <cfreturn retVal>
            
            <cfcatch>
                <cfset var retVal = {}>
                <cfset retVal["success"] = false>
                <cfset retVal["message"] = cfcatch.message>
                <cfset retVal["detail"] = cfcatch.detail>
                <cfset retVal["errorcode"] = cfcatch.errorcode>
                <cfset retVal["sqlstate"] = cfcatch.sqlstate>
                <cfset retVal["sql"] = cfcatch.sql>
                <cfreturn retVal>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="updateProject" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="PROJECT_ID" type="string" required="true">
        <cfargument name="PROJECT_NAME" type="string" required="true">
        <cfargument name="PROJECT_DESCRIPTION" type="string" required="true">
        <cfargument name="STATUS" type="string" required="true">
        <cfargument name="MODIFIED_BY" type="string" required="true">
        
        <cftry>
            <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#">
                UPDATE #variables.config.db.schema#.DAILY_TASKS_PROJECTS
                SET PROJECT_NAME = <cfqueryparam value="#arguments.PROJECT_NAME#" cfsqltype="CF_SQL_VARCHAR" maxlength="225">,
                    PROJECT_DESCRIPTION = <cfqueryparam value="#arguments.PROJECT_DESCRIPTION#" cfsqltype="CF_SQL_VARCHAR" maxlength="500">,
                    STATUS = <cfqueryparam value="#arguments.STATUS#" cfsqltype="CF_SQL_VARCHAR" maxlength="225">
                WHERE PROJECT_ID = <cfqueryparam value="#arguments.PROJECT_ID#" cfsqltype="CF_SQL_NUMERIC">
            </cfquery>
            
            <cfset var retVal = {}>
            <cfset retVal["success"] = true>
            <cfset retVal["message"] = "Project updated successfully">
            <cfreturn retVal>
            
            <cfcatch>
                <cfset var retVal = {}>
                <cfset retVal["success"] = false>
                <cfset retVal["message"] = cfcatch.message>
                <cfreturn retVal>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="deleteProject" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="PROJECT_ID" type="string" required="true">
        
        <cftry>
            <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#">
                DELETE FROM #variables.config.db.schema#.DAILY_TASKS_PROJECTS
                WHERE PROJECT_ID = <cfqueryparam value="#arguments.PROJECT_ID#" cfsqltype="CF_SQL_NUMERIC">
            </cfquery>
            
            <cfset var retVal = {}>
            <cfset retVal["success"] = true>
            <cfset retVal["message"] = "Project deleted successfully">
            <cfreturn retVal>
            
            <cfcatch>
                <cfset var retVal = {}>
                <cfset retVal["success"] = false>
                <cfset retVal["message"] = cfcatch.message>
                <cfreturn retVal>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="toggleProjectStatus" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="PROJECT_ID" type="string" required="true">
        <cfargument name="NEW_STATUS" type="string" required="true">
        <cfargument name="MODIFIED_BY" type="string" required="true">
        
        <cftry>
            <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#">
                UPDATE #variables.config.db.schema#.DAILY_TASKS_PROJECTS
                SET STATUS = <cfqueryparam value="#arguments.NEW_STATUS#" cfsqltype="CF_SQL_VARCHAR" maxlength="225">
                WHERE PROJECT_ID = <cfqueryparam value="#arguments.PROJECT_ID#" cfsqltype="CF_SQL_NUMERIC">
            </cfquery>
            
            <cfset var retVal = {}>
            <cfset retVal["success"] = true>
            <cfset retVal["message"] = "Project status updated successfully">
            <cfreturn retVal>
            
            <cfcatch>
                <cfset var retVal = {}>
                <cfset retVal["success"] = false>
                <cfset retVal["message"] = cfcatch.message>
                <cfreturn retVal>
            </cfcatch>
        </cftry>
    </cffunction>

</cfcomponent>
