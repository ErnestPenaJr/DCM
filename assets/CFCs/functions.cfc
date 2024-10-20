<cfcomponent>
    <cfset this.DBSERVER = "inside2_docmd" />
    <cfset this.DBSCHEMA = "HMOFP" />
    <cfset this.DBUSER = "HMOFP" />
    <cfset this.DBPASS = "1DocmD4AU6D23" />
    
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
        SELECT t.TASK_ID,t.TASK_NAME,t.TASK_DESCRIPTION,t.TASK_TIME,t.PROJECT,t.DEPTID ,t.TASK_DATE, t.DAY_NUM,p.PROJECT_NAME,t.WEEK_NUMBER, t.WEEKLY_NOTE
        FROM #this.DBSCHEMA#.DAILY_TASKS t, #this.DBSCHEMA#.DAILY_TASKS_PROJECTS p
        WHERE t.PROJECT = p.PROJECT_ID
        AND t.EMPLID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EMPLID#" />
        ORDER BY t.WEEK_NUMBER DESC, t.DAY_NUM ASC
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

</cfcomponent>
