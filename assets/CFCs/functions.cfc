<cfcomponent>
<cffunction name="searchEmployees" access="remote" returntype="any" returnformat="JSON">
		<cfargument name="searchStr" type="string" required="true" >
		<cfargument name="maxrows" type="numeric" default="25">
		<cfset var retVal = ArrayNew(1)>
		
		<cfquery username="WEBSCHEDULE_USER" password="1DOCMAU4WEBSCHEDULE2" datasource="inside2_docms" name="results">
			SELECT
				PS.EMPLID, PS.FIRST_NAME || ' ' || PS.LAST_NAME AS NAME, PS.FIRST_NAME || ' ' || PS.LAST_NAME  AS DISPLAYNAME,
				LOWER(PS.EMAIL_ADDRESS) AS EMAIL,
				PS.JOBCODE_DESCR AS JOBTITLE,
				PS.USERNAME,
				PS.DEPARTMENTNAME,
				PS.FULL_NAME,
				PS.WORKPHONE AS PHONE,
				PS.DEPARTMENTNAME,
				PS.DEPTID,
				PS.LOCATION
			FROM WEBSCHEDULE.ACTIVE_PEOPLESOFT PS
			WHERE 1=1

			<cfloop list="#lcase(arguments.searchStr)#" delimiters=" ," index="i">
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
			<cfset temp["name"] = NAME />
			<cfset temp["username"] = USERNAME />
			<cfset temp["emplID"] = EMPLID />
			<cfset temp["departmentname"] = DEPARTMENTNAME />
			<cfset temp["orgcode"] = DEPTID />
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

        <!--- Simulating the loading of JSON data --->
        <cfset var jsonData = deserializeJson(toString(getFileContent("../json/Departments.json")))>

        <!--- Iterate over the JSON data instead of querying the database --->
        <cfloop array="#jsonData#" index="department">
            <cfset var matchFound = false>

            <!--- Check if the department matches the search criteria --->
            <cfloop list="#lcase(arguments.searchStr)#" delimiters=" ," index="i">
                <cfif isNumeric(i) and department.DEPTID contains val(i) & "%">
                    <cfset matchFound = true>
                <cfelseif findNoCase(i, department.DEPARTMENTNAME)>
                    <cfset matchFound = true>
                </cfif>
            </cfloop>

            <!--- Add department to result if it matches --->
            <cfif matchFound>
                <cfset temp = {} />
                <cfset temp["divcode"] = department.DIV_ID />
                <cfset temp["divname"] = department.DIV_NAME />
                <cfset temp["orgcode"] = department.DEPTID />
                <cfset temp["orgname"] = department.DEPARTMENTNAME />
                <cfset ArrayAppend(retval, temp)>

                <!--- Break the loop if maxrows limit is reached --->
                <cfif ArrayLen(retval) >= arguments.maxrows>
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
		
		<cfquery username="WEBSCHEDULE_USER" password="1DOCMAU4WEBSCHEDULE2" datasource="inside2_docmp" name="results">
			SELECT DISTINCT PS.DEPARTMENTNAME,PS.DEPTID,PS.LEV4_DEPT_NAME as DIV_NAME,PS.LEV4_DEPTID_DIVISIONLEVEL AS DIV_ID
			FROM WEBSCHEDULE.ACTIVE_PEOPLESOFT PS
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

<cffunction name="searchAccounts" access="remote" returntype="any" returnformat="JSON">
		<cfargument name="searchStr" type="string" required="true" >
		<cfargument name="maxrows" type="numeric" default="25">
		<cfset var retVal = ArrayNew(1)>
		
		<cfquery username="ErnestPenaJr" password="$268RedDragons" datasource="fellows_ledger" name="results">
			SELECT ACCOUNT, EFF_DATE,SHORT_DESC,SMALL_NAME,DESCRIPTION,ACCOUNT_OWNER,GL_ACCOUNT,ACCOUNT_TYPE,SETID,STATUS
            FROM FELLOWS_LEDGER.GENERAL_LEDGER_CHART_ACCOUNTS
            WHERE 1=1
			<cfloop list="#lcase(arguments.searchStr)#" delimiters=" ," index="i">
				<cfif isNumeric(i)>
					AND ACCOUNT like <cfqueryparam cfsqltype="cf_sql_varchar" value="#val(i)#%" />
				<cfelse>
					AND lower(SMALL_NAME) like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#i#%"> OR lower(SHORT_DESC) like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#i#%">
				</cfif>
			</cfloop>
			ORDER BY ACCOUNT, EFF_DATE ASC
		</cfquery>

		<cfloop query="results">
			<cfset temp = {} />
			<cfset temp["ACCOUNT"] = ACCOUNT />
            <cfset temp["EFF_DATE"] = EFF_DATE />
            <cfset temp["SHORT_DESC"] = SHORT_DESC />
            <cfset temp["SMALL_NAME"] = SMALL_NAME />
            <cfset temp["DESCRIPTION"] = DESCRIPTION />
            <cfset temp["ACCOUNT_OWNER"] = ACCOUNT_OWNER />
            <cfset temp["GL_ACCOUNT"] = GL_ACCOUNT />
            <cfset temp["ACCOUNT_TYPE"] = ACCOUNT_TYPE />
            <cfset temp["SETID"] = SETID />
            <cfset temp["STATUS"] = STATUS />
			 <cfset ArrayAppend(retval, temp)>
		</cfloop>

		<cfset result = {} />
		<cfset result['items'] = retVal />
		<cfreturn result />
	</cffunction>

<cffunction name="saveTask" access="remote" returntype="any" returnformat="JSON">
    <cfargument name="TASK_NAME" type="string" required="false" default="" />
    <cfargument name="TASK_DESCRIPTION" type="string" required="false" default="" />
    <cfargument name="TASK_TIME" type="string" required="false" default="" />
    <cfargument name="PROJECT" type="string" required="false" default="" />
    <cfargument name="DEPTID" type="string" required="false" default="" />
    <cfargument name="ALLOCATED_TiME" type="string" required="false" default="" />
    <cfargument name="WEEK_NUM" type="string" required="false" default="" />
    <cfargument name="DATE" type="string" required="false" default="" />
    <cfargument name="DAY" type="string" required="false" default="" />

    <cfset var retVal = ArrayNew(1)>
    <cfquery username="ErnestPenaJr" password="$268RedDragons" datasource="fellows_ledger" name="insert">
        INSERT INTO MY_CAPACITY.DAILY_TASKS (TASK_NAME,TASK_DESCRIPTION,TASK_TIME,PROJECT,DEPTID,ALLOCATED_TiME,WEEK_NUM,DATE,DAY_NUM)
        VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TASK_NAME#" />,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TASK_DESCRIPTION#" />,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TASK_TIME#" />,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PROJECT#" />,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.DEPTID#" />,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ALLOCATED_TiME#" />,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.WEEK_NUM#" />,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.DATE#" />,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.DAY#" />)
    </cfquery>

     <cfquery username="ErnestPenaJr" password="$268RedDragons" datasource="fellows_ledger" name="results">
        SELECT t.TASKID,t.TASK_NAME,t.TASK_DESCRIPTION,t.TASK_TIME,t.PROJECT,t.DEPTID,t.ALLOCATED_TiME,t.WEEK_NUMBER,t.DATE,t.DAY_NUM
        FROM MY_CAPACITY.DAILY_TASKS t
        WHERE t.TASKID = (SELECT MAX(t.TASKID) AS MaxID FROM MY_CAPACITY.DAILY_TASKS)
        ORDER BY t.WEEK_NUMBER ASC
     </cfquery>

    <cfloop query="results">
            <cfset temp = {} />
            <cfset temp["TASKID"] = TASKID />
            <cfset temp["TASK_NAME"] = TASK_NAME />
            <cfset temp["TASK_DESCRIPTION"] = TASK_DESCRIPTION />
            <cfset temp["TASK_TIME"] = TASK_TIME />
            <cfset temp["PROJECT"] = PROJECT />
            <cfset temp["DEPTID"] = DEPTID />
            <cfset temp["ALLOCATED_TiME"] = ALLOCATED_TiME />
            <cfset temp["WEEK_NUM"] = WEEK_NUMBER />
            <cfset temp["DATE"] = DATE />
            <cfset temp["DAY_NUM"] = DAY_NUM />
            <cfset ArrayAppend(retval, temp)>
    </cfloop>

    <cfset result = {} />
    <cfset result['items'] = retVal />
    <cfreturn result />
</cffunction>

<cffunction name="getTaskByWeek" access="remote" returntype="any" returnformat="JSON">
    <cfargument name="WEEK_NUM" type="string" required="false" default="" />
    <cfset var retVal = ArrayNew(1)>
    <cfquery username="ErnestPenaJr" password="$268RedDragons" datasource="fellows_ledger" name="results">
        SELECT TASKID,TASK_NAME,TASK_DESCRIPTION,TASK_TIME,PROJECT,DEPTID,ALLOCATED_TiME,WEEK_NUMBER,DATE,DAY_NUM 
        FROM MY_CAPACITY.DAILY_TASKS
        WHERE WEEK_NUMBER = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.WEEK_NUM#" />
        ORDER BY WEEK_NUMBER ASC, DAY_NUM ASC
    </cfquery>

    <cfloop query="results">
        <cfset temp = {} />
        <cfset temp["TASKID"] = TASKID />
        <cfset temp["TASK_NAME"] = TASK_NAME />
        <cfset temp["TASK_DESCRIPTION"] = TASK_DESCRIPTION />
        <cfset temp["TASK_TIME"] = TASK_TIME />
        <cfset temp["PROJECT"] = PROJECT />
        <cfset temp["DEPTID"] = DEPTID />
        <cfset temp["ALLOCATED_TiME"] = ALLOCATED_TiME />
        <cfset temp["WEEK_NUM"] = WEEK_NUMBER />
        <cfset temp["PROJECT"] = PROJECT />
        <cfset temp["DAY_NUM"] = DAY_NUM />
        <cfset ArrayAppend(retval, temp)>
    </cfloop>

    <cfset result = {} />
    <cfset result['items'] = retVal />
    <cfreturn result />
</cffunction>

<cffunction name="getAllTasks" access="remote" returntype="any" returnformat="JSON">
    <cfargument name="WEEK_NUM" type="string" required="false" default="" />
    <cfset var retVal = ArrayNew(1)>
    <cfquery username="ErnestPenaJr" password="$268RedDragons" datasource="fellows_ledger" name="results">
        SELECT t.TASKID,t.TASK_NAME,t.TASK_DESCRIPTION,t.TASK_TIME,t.PROJECT,t.DEPTID ,t.DATE, t.DAY_NUM,p.PROJECT_NAME,t.WEEK_NUMBER, t.WEEKLY_NOTE
        FROM MY_CAPACITY.DAILY_TASKS t, MY_CAPACITY.PROJECTS p
        WHERE t.PROJECT = p.PROJECT_ID
        ORDER BY t.WEEK_NUMBER ASC, t.DAY_NUM ASC
    </cfquery>

    <cfloop query="results">
            <cfset temp = {} />
            <cfset temp["TASKID"] = TASKID />
            <cfset temp["TASK_NAME"] = TASK_NAME />
            <cfset temp["TASK_DESCRIPTION"] = TASK_DESCRIPTION />
            <cfset temp["TASK_TIME"] = "#TASK_TIME# min." />
            <cfset temp["PROJECT"] = PROJECT />
            <cfset temp["DEPTID"] = DEPTID />
            <cfset temp["DATE"] = DATEFORMAT(DATE,'mm/dd/yyyy') />
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
            <cfelseif DAY_NUM EQ 7>
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
    <cfquery username="ErnestPenaJr" password="$268RedDragons" datasource="fellows_ledger" name="results">
        SELECT PROJECT_ID, PROJECT_NAME, PROJECT_DESCRIPTION
        FROM MY_CAPACITY.PROJECTS
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

</cfcomponent>