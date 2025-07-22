<cfcomponent>
    <cfset this.DBSERVER = "inside2_docmd" />
    <cfset this.DBSCHEMA = "HMOFP" />
    <cfset this.DBUSER = "HMOFP" />
    <cfset this.DBPASS = "1DocmD4AU6D23" />    
    <cffunction name="search4Employees" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="query" type="string" required="yes" hint="The search query to use to find matching employee names." >
		<cfargument name="scope" type="string" required="false" default="everyone" hint="The scope to search within for matching employee names.  Valid argument values are 'Everyone' (default), 'WebSchedule' (only registered users), 'Department', and 'Division'." >
		<cfargument name="maxrows" type="numeric" default="10">
		<cfset var retVal = ArrayNew(1)>
		<cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#" name="results" maxrows="#arguments.maxrows#">
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
			FROM #this.DBSCHEMA#.ACTIVE_PEOPLESOFT PS
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

    <cffunction name="searchDepartments2" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="searchStr" type="string" required="true">
        <cfargument name="maxrows" type="numeric" default="25">
        <cfset var retVal = ArrayNew(1)>
         <cfset absolutePath = ExpandPath("../json/Departments.json")>

        <cffile action="read" file="#absolutePath#" variable="fileContent">
        <cfset var jsonData = deserializeJson(fileContent)>
        <cfloop array="#jsonData#" index="department">
            <cfset var matchFound = false>
        <cfloop list="#lcase(arguments.searchStr)#" delimiters=" ," index="i">
            <cfif isNumeric(i) and compareNoCase(left(department.DEPTID, len(i)), i) == 0>
                <cfset matchFound = true>
            <cfelseif findNoCase(i, department.DEPARTMENTNAME)>
                <cfset matchFound = true>
            </cfif>
        </cfloop>
            <cfif matchFound>
                <cfset temp = {} />
                <cfset temp["divcode"] = department.DIV_ID />
                <cfset temp["divname"] = department.DIV_NAME />
                <cfset temp["orgcode"] = department.DEPTID />
                <cfset temp["orgname"] = department.DEPARTMENTNAME />
                <cfset ArrayAppend(retval, temp)>
                <cfif ArrayLen(retval) GTE arguments.maxrows >
                    <cfbreak>
                </cfif>
            </cfif>
        </cfloop>

        <cfset result = {} />
        <cfset result['items'] = retVal />
        <cfreturn result />
    </cffunction>


    <cffunction name="searchDepartments" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="searchStr" type="string" required="true" >
		<cfargument name="maxrows" type="numeric" default="25">
		<cfset var retVal = ArrayNew(1)>
		
		<cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#" name="results">
			SELECT DISTINCT PS.DEPARTMENTNAME,PS.DEPTID,PS.LEV4_DEPT_NAME as DIV_NAME,PS.LEV4_DEPTID_DIVISIONLEVEL AS DIV_ID
			FROM #this.DBSCHEMA#.ACTIVE_PEOPLESOFT PS
			WHERE 1=1
			<cfloop list="#lcase(arguments.searchStr)#" delimiters=" ," index="i">
				<cfif isNumeric(i)>
					AND PS.DEPTID like <cfqueryparam cfsqltype="cf_sql_varchar" value="#val(i)#%" />
				<cfelse>
					AND lower(PS.DEPARTMENTNAME) like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#i#%">
				</cfif>
			</cfloop>
			GROUP By PS.DEPTID, PS.DEPARTMENTNAME, PS.LEV4_DEPT_NAME, PS.LEV4_DEPTID_DIVISIONLEVEL
			ORDER BY PS.LEV4_DEPT_NAME,PS.DEPARTMENTNAME
        </cfquery>

		<cfloop query="results">
			<cfset temp = {} />
			<cfset temp["divcode"] = DIV_ID />
			<cfset temp["divname"] = DIV_NAME />
			<cfset temp["orgcode"] = DEPTID />
			<cfset temp["orgname"] = DEPARTMENTNAME />
			 <cfset ArrayAppend(retval, temp)>
		</cfloop>

		<cfset result = {} />
		<cfset result['items'] = retVal />
		<cfreturn result />
	</cffunction>

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
    <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#"  name="insert">
        INSERT INTO #this.DBSCHEMA#.DAILY_TASKS (TASK_NAME,TASK_DESCRIPTION,CLASSIFICATION, WORK_TYPE, TASK_TIME,PROJECT,DEPTID,ALLOCATED_TIME,WEEK_NUMBER,TASK_DATE,WEEKLY_NOTE,DAY_NUM,EMPLID)
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

     <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#"  name="results">
        SELECT t.TASK_ID,t.TASK_NAME,t.TASK_DESCRIPTION, t.CLASSIFICATION, t.WORK_TYPE, t.TASK_TIME,t.PROJECT,t.DEPTID,t.ALLOCATED_TiME,t.WEEK_NUMBER,t.TASK_DATE,t.DAY_NUM,t.WEEKLY_NOTE
        FROM #this.DBSCHEMA#.DAILY_TASKS t
        WHERE t.TASK_ID = (SELECT MAX(t.TASK_ID) AS MaxID FROM #this.DBSCHEMA#.DAILY_TASKS)
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
            <cfset temp["ALLOCATED_TiME"] = ALLOCATED_TiME />
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
    <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#" name="results">
        SELECT t.TASK_ID, t.TASK_NAME, t.TASK_DESCRIPTION,t.CLASSIFICATION,t.WORK_TYPE, t.TASK_TIME, t.PROJECT, t.DEPTID, t.TASK_DATE, t.DAY_NUM, p.PROJECT_NAME, t.WEEK_NUMBER, t.WEEKLY_NOTE, t.ALLOCATED_TIME, t.EMPLID
        FROM #this.DBSCHEMA#.DAILY_TASKS t
        JOIN #this.DBSCHEMA#.DAILY_TASKS_PROJECTS p ON t.PROJECT = p.PROJECT_ID
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
        <cfset temp["ALLOCATED_TiME"] = ALLOCATED_TiME />
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
    <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#"  name="results">
        SELECT t.TASK_ID,t.TASK_NAME,t.TASK_DESCRIPTION,t.TASK_TIME,t.PROJECT,t.DEPTID ,t.TASK_DATE, t.DAY_NUM,p.PROJECT_NAME,t.WEEK_NUMBER, t.WEEKLY_NOTE,t.DAY_NUM, t.WEEKLY_NOTE, t.ALLOCATED_TiME,t.EMPLID
        FROM #this.DBSCHEMA#.DAILY_TASKS t, #this.DBSCHEMA#.DAILY_TASKS_PROJECTS p
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
        <cfset temp["ALLOCATED_TiME"] = ALLOCATED_TiME />
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
    <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#"  name="results">
        SELECT t.TASK_ID,t.TASK_NAME,t.TASK_DESCRIPTION,t.TASK_TIME,t.PROJECT,t.DEPTID ,t.TASK_DATE, t.DAY_NUM,p.PROJECT_NAME,t.WEEK_NUMBER, t.WEEKLY_NOTE, TO_CHAR(t.TASK_DATE,'YYYY') as TASK_YEAR
        FROM #this.DBSCHEMA#.DAILY_TASKS t, #this.DBSCHEMA#.DAILY_TASKS_PROJECTS p
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
                <cfset temp["WEEK_DAY"] = "Wedensday" />
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

<cffunction name="getProjects" access="remote" returntype="any" returnformat="JSON">
    <cfargument name="PID" type="string" required="false" default="" />
    <cfset var retVal = ArrayNew(1)>
    <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#"  name="results">
        SELECT PROJECT_ID, PROJECT_NAME, PROJECT_DESCRIPTION
        FROM #this.DBSCHEMA#.DAILY_TASKS_PROJECTS
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

<cffunction name="getDirectoryContents" access="remote" returnType="any" output="false" returnFormat="JSON">
    <cfargument name="path" type="string" required="yes" default="../images/fellows/">
    
    <cfset var directory = "">
    <cfset var retVal = ArrayNew(1)>
    <!--- Construct the full path to the directory --->
    <cfset directory = ExpandPath(arguments.path)>
    <!--- Check if the directory exists --->
    <cfif directoryExists(directory)>
        <!--- Get the list of files in the directory --->
        <cfdirectory action="list" directory="#directory#" name="results" sort="name ASC">
        
        <!--- Loop through the files and add their details to the result array --->
        <cfloop query="results">
            <cfset temp = {} />
            <cfset temp["name"] = name />
            <cfset temp["size"] = size />
            <cfset temp["type"] = type />
            <cfset temp["dateLastModified"] = dateLastModified />
            <cfset temp["imagePath"] = directory />
            <cfset ArrayAppend(retval, temp)>
        </cfloop>
        <cfset result = {} />
        <cfset result['items'] = retVal />
        <cfreturn result />

    <cfelse>
        <!--- Return an error message if the directory does not exist --->
        <cfreturn serializeJSON({error: "Directory does not exist."})>
    </cfif>
</cffunction>

<cffunction name="SendWeeklyReportEmails" access="remote" returnType="any" output="false">

</cffunction>

    <!--- Method to check if the session is still active --->
    <cffunction name="isSessionActive" access="remote" returnType="boolean">
        <cfif structKeyExists(session, "isLoggedIn") AND session.isLoggedIn>
            <cfreturn true>
        <cfelse>
            <cfreturn false>
        </cfif>
    </cffunction>

    <!--- Method to log out the user --->
    <cffunction name="logoutUser" access="remote" returnType="void">
        <cfset structClear(session)>
    </cffunction>

    <!--- refreshSession --->
    <cffunction name="refreshSession" access="remote" returnType="void">
        <cfset session.isLoggedIn = true>
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
            <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#"  name="results">
                SELECT PS.EMPLID, PS.FULL_NAME, PS.DISPLAY_NAME, PS.DEPARTMENTNAME,PS.DEPTID,PS.EMAIL_ADDRESS,PS.JOBCODE_DESCR,PS.WORKPHONE,PS.LOCATION,PS.NICKNAME
                FROM #this.DBSCHEMA#.ACTIVE_PEOPLESOFT PS
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
            <cfset temp["ISLOGGINEDIN"] = 1 />
            <cfset temp["AUTHORIZED_USER"] = true />
        <cfif results.EMPLID eq "132034">
            <cfset temp["ISADMIN"] = 1 />
        <cfelse>
            <cfset temp["ISADMIN"] = 0 />
        </cfif>
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
            <cfset temp["ISLOGGINEDIN"] = 0 />
            <cfset temp["AUTHORIZED_USER"] = false />
            <cfset temp["ISADMIN"] = 0 />
            <cfset temp["ADMESSAGE"] = LDAP.ADMessage />
        </cfif>
            <cfset result = {} />
            <cfset result['LDAP'] = temp />
            <cfreturn result />
    </cffunction>

    <cffunction name="getAllUserAccess" access="remote" returntype="any" returnformat="JSON">
        <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#" name="results">
            SELECT 
                ua.USERID, 
                ua.EMPLID, 
                ua.PERMISSIONID, 
                ua.ALLOWEDACCESS,
                ua.LASTLOGIN,
                p.PERMISSIONNAME,
                ps.DISPLAY_NAME as NAME,
                ps.DEPARTMENTNAME
            FROM #this.DBSCHEMA#.DAILY_TASKS_USERACCESS ua
            LEFT JOIN #this.DBSCHEMA#.DAILY_TASKS_PERMISSIONS p ON ua.PERMISSIONID = p.PERMISSIONID
            LEFT JOIN #this.DBSCHEMA#.ACTIVE_PEOPLESOFT ps ON ua.EMPLID = ps.EMPLID
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
        <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#" name="results">
            SELECT PERMISSIONID, PERMISSIONNAME, DESCRIPTION
            FROM #this.DBSCHEMA#.DAILY_TASKS_PERMISSIONS
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
        <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#">
            INSERT INTO #this.DBSCHEMA#.DAILY_TASKS_USERACCESS
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
        <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#">
            UPDATE #this.DBSCHEMA#.DAILY_TASKS_USERACCESS
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
        <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#">
            UPDATE #this.DBSCHEMA#.DAILY_TASKS_USERACCESS
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

<!---getUserAccess --->
<cffunction name="getUserAccess" access="remote" returntype="any" returnformat="JSON">
    <cfargument name="EMPLID" type="string" required="true">
    
    <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#" name="results">
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
        FROM #this.DBSCHEMA#.DAILY_TASKS_USERACCESS ua
        LEFT JOIN #this.DBSCHEMA#.DAILY_TASKS_PERMISSIONS p ON ua.PERMISSIONID = p.PERMISSIONID
        LEFT JOIN #this.DBSCHEMA#.ACTIVE_PEOPLESOFT ps ON ua.EMPLID = ps.EMPLID
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
    
    <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#">
        DELETE FROM #this.DBSCHEMA#.DAILY_TASKS_USERACCESS 
        WHERE EMPLID = <cfqueryparam value="#arguments.EMPLID#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>
    
    <cfreturn {"success": true, "message": "User access deleted successfully"}>
</cffunction>

<cffunction name="createProject" access="remote" returntype="any" returnformat="JSON">
    <cfargument name="PROJECT_NAME" type="string" required="true">
    <cfargument name="PROJECT_DESCRIPTION" type="string" required="true">
    <cfargument name="STATUS" type="string" required="false" default="A">
    <cfargument name="CREATED_BY" type="string" required="true">
    
    <cftry>
        <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#">
            INSERT INTO #this.DBSCHEMA#.DAILY_TASKS_PROJECTS
            (PROJECT_NAME, PROJECT_DESCRIPTION, STATUS)
            VALUES
            (
                <cfqueryparam value="#arguments.PROJECT_NAME#" cfsqltype="CF_SQL_VARCHAR" maxlength="225">,
                <cfqueryparam value="#arguments.PROJECT_DESCRIPTION#" cfsqltype="CF_SQL_VARCHAR" maxlength="500">,
                <cfqueryparam value="#arguments.STATUS#" cfsqltype="CF_SQL_VARCHAR" maxlength="225">
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
        <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#">
            UPDATE #this.DBSCHEMA#.DAILY_TASKS_PROJECTS
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
        <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#">
            DELETE FROM #this.DBSCHEMA#.DAILY_TASKS_PROJECTS
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
        <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#">
            UPDATE #this.DBSCHEMA#.DAILY_TASKS_PROJECTS
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

<cffunction name="getAllProjects" access="remote" returntype="any" returnformat="JSON">
    <cfset var retVal = ArrayNew(1)>
    <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#" name="results">
        SELECT 
            p.PROJECT_ID, 
            p.PROJECT_NAME, 
            p.PROJECT_DESCRIPTION, 
            p.STATUS,
            p.DATECREATED,
            (SELECT COUNT(*) FROM #this.DBSCHEMA#.DAILY_TASKS dt WHERE dt.PROJECT = p.PROJECT_ID) as TASK_COUNT
        FROM #this.DBSCHEMA#.DAILY_TASKS_PROJECTS p
        ORDER BY p.DATECREATED DESC
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
    <cfquery username="#this.DBUSER#" password="#this.DBPASS#" datasource="#this.DBSERVER#" name="results">
        SELECT 
            p.PROJECT_ID, 
            p.PROJECT_NAME, 
            p.PROJECT_DESCRIPTION, 
            p.STATUS,
            p.DATECREATED,
            (SELECT COUNT(*) FROM #this.DBSCHEMA#.DAILY_TASKS dt WHERE dt.PROJECT = p.PROJECT_ID) as TASK_COUNT
        FROM #this.DBSCHEMA#.DAILY_TASKS_PROJECTS p
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

</cfcomponent>
