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

    <cffunction name="search4Employees" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="query" type="string" required="yes" hint="The search query to use to find matching employee names." >
		<cfargument name="scope" type="string" required="false" default="everyone" hint="The scope to search within for matching employee names.  Valid argument values are 'Everyone' (default), 'WebSchedule' (only registered users), 'Department', and 'Division'." >
		<cfargument name="maxrows" type="numeric" default="10">
		<cfset var retVal = ArrayNew(1)>
		<cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#" name="results" maxrows="#arguments.maxrows#">
			SELECT
				PS.EMPLID, PS.FIRST_NAME || ' ' || PS.LAST_NAME AS NAME, PS.FIRST_NAME || ' ' || PS.LAST_NAME  AS DISPLAYNAME,
				LOWER(PS.EMAIL_ADDRESS) AS EMAIL,
				PS.JOBCODE_DESCR AS JOBTITLE,
				PS.USERNAME,
                PS.FIRST_NAME,
                PS.LAST_NAME,
				PS.DEPARTMENTNAME,
                PS.DEPTID AS ORGCODE,
				PS.FULL_NAME,
				PS.WORKPHONE AS PHONE,
				PS.DEPTID,
				PS.LOCATION,
                PS.LEV4_DEPTID_DIVISIONLEVEL AS DIVISIONID,
                PS.STATUSID 
			FROM #variables.config.db.schema#.ACTIVE_PEOPLESOFT PS
			WHERE PS.STATUSID = 'A'
				<cfloop list="#lcase(arguments.query)#" delimiters=" ," index="i">
                    <cfif isNumeric(i)>
                        AND PS.EMPLID like <cfqueryparam cfsqltype="cf_sql_varchar" value="#val(i)#%" /> OR RFID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#val(i)#">
                    <cfelse>
                        AND lower(PS.FULL_NAME) like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#i#%">
                    </cfif>
				</cfloop>
			ORDER BY PS.DEPARTMENTNAME, PS.LAST_NAME, PS.FIRST_NAME ASC
		</cfquery>

		<cfloop query="results">
			<cfset temp = {} />
			<cfset temp["total"] = RECORDCOUNT />
            <cfset temp["divid"] = DIVISIONID />
            <cfset temp["orgcode"] = ORGCODE />
			<cfset temp["name"] = NAME />
            <cfset temp["username"] = USERNAME />
            <cfset temp["Lastname"] = LAST_NAME />
            <cfset temp["Firstname"] = FIRST_NAME />
			<cfset temp["emplID"] = EMPLID />
			<cfset temp["departmentname"] = DEPARTMENTNAME />
			<cfset temp["displayName"] = DISPLAYNAME />
			<cfset temp["email"] = EMAIL />
			<cfset temp["jobTitle"] = JOBTITLE />
			<cfset temp["fullName"] = FULL_NAME />
			<cfset temp["phone"] = PHONE />
			<cfset temp["location"] = LOCATION />
			 <cfset ArrayAppend(retval, temp)>
		</cfloop>

		<cfset result = {} />
		<cfset result['items'] = retVal />
		<cfreturn result />
	</cffunction>

    <cffunction name="remote_LDAP" access="remote" returntype="Any" returnformat="JSON" >
        <cfargument name="UserID" required="yes" />
        <cfargument name="UserPassword" required="yes" />

        <cfset LDAP = {} />
        <cfparam name="LDAP.authenticates" default = 0>
        <cftry>
            <cfldap action="QUERY" name="auth" start="OU=People,dc=mdanderson,dc=edu" separator="|" attributes="dn,employeeID" server="ldap.mdanderson.edu"	username="MDANDERSON\#listFirst(arguments.UserID,'|')#"	password="#arguments.UserPassword#" scope="subtree"	filter="sAMAccountName=#listLast(arguments.UserID,'|')#"/>
            <cfif auth.RecordCount>
                <cfset LDAP.Authenticates = "true" />
                <cfset LDAP.UserID = auth.employeeID />
            </cfif>
            <cfcatch type="ANY">
                <cfset originalError = cfcatch />
                <cfset LDAP.ErrorCode = Mid(cfcatch.Message,Find(", data ", cfcatch.message)+7,Find(",", cfcatch.Message,Find(", data ", cfcatch.message)+1)-Find(", data ", cfcatch.message)-7) />
                <cfif LDAP.ErrorCode eq "525">
                    <cfset LDAP["ADMessage"] = "User Not Found" />
                <cfelseif LDAP.ErrorCode eq "52e">
                    <cfset LDAP["ADMessage"] = "Password or Username is incorrect" />
                <cfelseif LDAP.ErrorCode eq "530">
                    <cfset LDAP["ADMessage"] = "User not permitted to log on at this time" />
                <cfelseif LDAP.ErrorCode eq "532">
                    <cfset LDAP["ADMessage"] = "Password expired" />
                <cfelseif LDAP.ErrorCode eq "533">
                    <cfset LDAP["ADMessage"] = "Account disabled" />
                <cfelseif LDAP.ErrorCode eq "701">
                    <cfset LDAP["ADMessage"] = "Account expired" />
                <cfelseif LDAP.ErrorCode eq "733">
                    <cfset LDAP["ADMessage"] = "Account disabled" />
                <cfelseif LDAP.ErrorCode eq "775">
                    <cfset LDAP["ADMessage"] =  "Account locked out" />
                <cfelse>
                    <cfset LDAP["ADMessage"] = "Rejected with unknown reason code (#LDAP.ErrorCode#)." />
                </cfif>
            </cfcatch>
        </cftry>

        <cfif LDAP.authenticates eq "true">
            <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#"  name="results">
                SELECT PS.EMPLID, PS.FULL_NAME, PS.DISPLAY_NAME, PS.DEPARTMENTNAME,PS.DEPTID,PS.EMAIL_ADDRESS,PS.JOBCODE_DESCR,PS.WORKPHONE,PS.LOCATION,PS.NICKNAME
                FROM #variables.config.db.schema#.ACTIVE_PEOPLESOFT PS
                WHERE PS.EMPLID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#auth.employeeID#" />
            </cfquery>
            <cfset temp = {} />
            <cfset temp['NAME'] = results.DISPLAY_NAME />
            <cfset temp['FULL_NAME'] = results.FULL_NAME />
            <cfset temp["DEPARTMENTNAME"] = results.DEPARTMENTNAME />
            <cfset temp['EMAIL_ADDRESS'] = results.EMAIL_ADDRESS />
            <cfset temp['JOBCODE_DESCR'] = results.JOBCODE_DESCR />
            <cfset temp['NICKNAME'] = results.NICKNAME />
            <cfset temp["EMPLID"] = results.EMPLID />
            <cfset temp["DEPTID"] = results.DEPTID />
            <cfset temp["ISLOGGEDIN"] = 1 />
            <cfset temp["AUTHORIZED_USER"] = true />

            <!--- Check user permissions from database instead of hardcoding --->
            <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#" name="permCheck">
                SELECT ua.PERMISSIONID, p.PERMISSIONNAME
                FROM #variables.config.db.schema#.DAILY_TASKS_USERACCESS ua
                LEFT JOIN #variables.config.db.schema#.DAILY_TASKS_PERMISSIONS p ON ua.PERMISSIONID = p.PERMISSIONID
                WHERE ua.EMPLID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#results.EMPLID#" />
                AND ua.ALLOWEDACCESS = 'Y'
            </cfquery>

            <cfif permCheck.recordCount AND (permCheck.PERMISSIONNAME EQ "Admin" OR permCheck.PERMISSIONID EQ "2")>
                <cfset temp["ISADMIN"] = 1 />
            <cfelse>
                <cfset temp["ISADMIN"] = 0 />
            </cfif>
            <cfset temp["PERMISSIONNAME"] = permCheck.PERMISSIONNAME />
            <cfset temp["ADMESSAGE"] = 'Authentication Successful' />
        <cfelseif LDAP.authenticates eq 0>
            <cfset temp = {} />
            <cfset temp['NAME'] = '' />
            <cfset temp['FULL_NAME'] = '' />
            <cfset temp["DEPARTMENTNAME"] = '' />
            <cfset temp['EMAIL_ADDRESS'] = '' />
            <cfset temp['JOBCODE_DESCR'] = '' />
            <cfset temp['NICKNAME'] = '' />
            <cfset temp["EMPLID"] = '' />
            <cfset temp["DEPTID"] = '' />
            <cfset temp["ISLOGGEDIN"] = 0 />
            <cfset temp["AUTHORIZED_USER"] = false />
            <cfset temp["ISADMIN"] = 0 />
            <cfset temp["ADMESSAGE"] = LDAP.ADMessage />
        </cfif>
            <cfset result = {} />
            <cfset result['LDAP'] = temp />
            <cfreturn result />
    </cffunction>

    <cffunction name="getAllUserAccess" access="remote" returntype="any" returnformat="JSON">
        <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#" name="results">
            SELECT 
                ua.USERID, 
                ua.EMPLID, 
                ua.PERMISSIONID, 
                ua.ALLOWEDACCESS,
                ua.LASTLOGIN,
                p.PERMISSIONNAME,
                ps.DISPLAY_NAME as NAME,
                ps.DEPARTMENTNAME
            FROM #variables.config.db.schema#.DAILY_TASKS_USERACCESS ua
            LEFT JOIN #variables.config.db.schema#.DAILY_TASKS_PERMISSIONS p ON ua.PERMISSIONID = p.PERMISSIONID
            LEFT JOIN #variables.config.db.schema#.ACTIVE_PEOPLESOFT ps ON ua.EMPLID = ps.EMPLID
            ORDER BY ps.DISPLAY_NAME
        </cfquery>
        
        <cfset var retVal = []>
        <cfloop query="results">
            <cfset var temp = {}>
            <cfset temp["userid"] = USERID>
            <cfset temp["emplid"] = EMPLID>
            <cfset temp["name"] = NAME>
            <cfset temp["departmentname"] = DEPARTMENTNAME>
            <cfset temp["permissionid"] = PERMISSIONID>
            <cfset temp["permissionname"] = PERMISSIONNAME>
            <cfset temp["allowedaccess"] = ALLOWEDACCESS>
            <cfset temp["lastlogin"] = LASTLOGIN>
            <cfset ArrayAppend(retVal, temp)>
        </cfloop>
        
        <cfset var result = {}>
        <cfset result["items"] = retVal>
        <cfreturn result>
    </cffunction>

    <cffunction name="getAllPermissions" access="remote" returntype="any" returnformat="JSON">
        <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#" name="results">
            SELECT PERMISSIONID, PERMISSIONNAME, DESCRIPTION
            FROM #variables.config.db.schema#.DAILY_TASKS_PERMISSIONS
            ORDER BY PERMISSIONNAME
        </cfquery>
        
        <cfset var retVal = []>
        <cfloop query="results">
            <cfset var temp = {}>
            <cfset temp["permissionid"] = PERMISSIONID>
            <cfset temp["permissionname"] = PERMISSIONNAME>
            <cfset temp["description"] = DESCRIPTION>
            <cfset ArrayAppend(retVal, temp)>
        </cfloop>
        
        <cfset var result = {}>
        <cfset result["items"] = retVal>
        <cfreturn result>
    </cffunction>

    <cffunction name="createUserAccess" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="EMPLID" type="string" required="true">
        <cfargument name="PERMISSIONID" type="string" required="true">
        <cfargument name="ALLOWEDACCESS" type="string" required="true">
        <cfargument name="CREATEDBYID" type="string" required="true">
        
        <cftry>
            <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#">
                INSERT INTO #variables.config.db.schema#.DAILY_TASKS_USERACCESS
                (EMPLID, PERMISSIONID, ALLOWEDACCESS, CREATEDBYID, CREATEDBYDATE)
                VALUES
                (
                    <cfqueryparam value="#arguments.EMPLID#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#arguments.PERMISSIONID#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#arguments.ALLOWEDACCESS#" cfsqltype="CF_SQL_CHAR">,
                    <cfqueryparam value="#arguments.CREATEDBYID#" cfsqltype="CF_SQL_VARCHAR">,
                    SYSDATE
                )
            </cfquery>
            
            <cfset var retVal = {}>
            <cfset retVal["success"] = true>
            <cfset retVal["message"] = "User access created successfully">
            <cfreturn retVal>
            
            <cfcatch>
                <cfset var retVal = {}>
                <cfset retVal["success"] = false>
                <cfset retVal["message"] = cfcatch.message>
                <cfreturn retVal>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="updateUserAccess" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="EMPLID" type="string" required="true">
        <cfargument name="PERMISSIONID" type="string" required="true">
        <cfargument name="ALLOWEDACCESS" type="string" required="true">
        <cfargument name="MODIFIEDBYID" type="string" required="true">
        
        <cftry>
            <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#">
                UPDATE #variables.config.db.schema#.DAILY_TASKS_USERACCESS
                SET PERMISSIONID = <cfqueryparam value="#arguments.PERMISSIONID#" cfsqltype="CF_SQL_VARCHAR">,
                    ALLOWEDACCESS = <cfqueryparam value="#arguments.ALLOWEDACCESS#" cfsqltype="CF_SQL_CHAR">,
                    MODIFIEDBYID = <cfqueryparam value="#arguments.MODIFIEDBYID#" cfsqltype="CF_SQL_VARCHAR">,
                    MODIFIEDBYDATE = SYSDATE
                WHERE EMPLID = <cfqueryparam value="#arguments.EMPLID#" cfsqltype="CF_SQL_VARCHAR">
            </cfquery>
            
            <cfset var retVal = {}>
            <cfset retVal["success"] = true>
            <cfset retVal["message"] = "User access updated successfully">
            <cfreturn retVal>
            
            <cfcatch>
                <cfset var retVal = {}>
                <cfset retVal["success"] = false>
                <cfset retVal["message"] = cfcatch.message>
                <cfreturn retVal>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="updateLastLogin" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="EMPLID" type="string" required="true">
        
        <cftry>
            <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#">
                UPDATE #variables.config.db.schema#.DAILY_TASKS_USERACCESS
                SET LASTLOGIN = SYSDATE
                WHERE EMPLID = <cfqueryparam value="#arguments.EMPLID#" cfsqltype="CF_SQL_VARCHAR">
            </cfquery>
            
            <cfset var retVal = {}>
            <cfset retVal["success"] = true>
            <cfreturn retVal>
            
            <cfcatch>
                <cfset var retVal = {}>
                <cfset retVal["success"] = false>
                <cfset retVal["message"] = cfcatch.message>
                <cfreturn retVal>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="getUserAccess" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="EMPLID" type="string" required="true">
        
        <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#" name="results">
            SELECT ua.USERID, 
                   ua.EMPLID, 
                   ua.PERMISSIONID, 
                   ua.ALLOWEDACCESS,
                   p.PERMISSIONNAME,
                   p.DESCRIPTION,
                   ua.LASTLOGIN, 
                   ua.CREATEDBYID, 
                   ua.CREATEDBYDATE,
                   ps.DISPLAY_NAME as NAME,
                   ps.DEPARTMENTNAME
            FROM #variables.config.db.schema#.DAILY_TASKS_USERACCESS ua
            LEFT JOIN #variables.config.db.schema#.DAILY_TASKS_PERMISSIONS p ON ua.PERMISSIONID = p.PERMISSIONID
            LEFT JOIN #variables.config.db.schema#.ACTIVE_PEOPLESOFT ps ON ua.EMPLID = ps.EMPLID
            WHERE ua.EMPLID = <cfqueryparam value="#arguments.EMPLID#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>
        
        <cfset var retVal = {}>
        <cfif results.recordCount>
            <cfset retVal = {
                "userid": results.USERID,
                "emplid": results.EMPLID,
                "name": results.NAME,
                "departmentname": results.DEPARTMENTNAME,
                "permissionid": results.PERMISSIONID,
                "permissionname": results.PERMISSIONNAME,
                "allowedaccess": results.ALLOWEDACCESS,
                "lastlogin": results.LASTLOGIN,
                "description": results.DESCRIPTION
            }>
        </cfif>
        
        <cfreturn retVal>
    </cffunction>

    <cffunction name="deleteUserAccess" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="EMPLID" type="string" required="true">
        
        <cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#">
            DELETE FROM #variables.config.db.schema#.DAILY_TASKS_USERACCESS 
            WHERE EMPLID = <cfqueryparam value="#arguments.EMPLID#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>
        
        <cfreturn {"success": true, "message": "User access deleted successfully"}>
    </cffunction>

    <cffunction name="isSessionActive" access="remote" returnType="boolean">
        <cfif structKeyExists(session, "isLoggedIn") AND session.isLoggedIn>
            <cfreturn true>
        <cfelse>
            <cfreturn false>
        </cfif>
    </cffunction>

    <cffunction name="logoutUser" access="remote" returnType="void">
        <cfset structClear(session)>
    </cffunction>

    <cffunction name="refreshSession" access="remote" returnType="void">
        <cfset session.isLoggedIn = true>
    </cffunction>
</cfcomponent>
