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

        <!--- Initialize departmentsData in application scope if not already present --->
        <!--- Only attempt to use application scope if it's available --->
        <cftry>
            <cfif isDefined("application") AND !structKeyExists(application, "departmentsData")>
                <cfset var absolutePath = ExpandPath("../json/Departments.json")>
                <cfif fileExists(absolutePath)>
                    <cffile action="read" file="#absolutePath#" variable="fileContent">
                    <cfset application.departmentsData = deserializeJson(fileContent)>
                </cfif>
            </cfif>
            <cfcatch type="any">
                <!--- Application scope not available, skip caching --->
            </cfcatch>
        </cftry>

        <cfreturn this>
    </cffunction>

    <cfset init()>

    <cffunction name="searchDepartments2" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="searchStr" type="string" required="true">
        <cfargument name="maxrows" type="numeric" default="25">
        <cfset var retVal = ArrayNew(1)>
        
        <!--- Retrieve data from application scope --->
        <cfset var jsonData = application.departmentsData>

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
		
		<cfquery username="#variables.config.db.user#" password="#variables.config.db.pass#" datasource="#variables.config.db.server#" name="results">
			SELECT DISTINCT PS.DEPARTMENTNAME,PS.DEPTID,PS.LEV4_DEPT_NAME as DIV_NAME,PS.LEV4_DEPTID_DIVISIONLEVEL AS DIV_ID
			FROM #variables.config.db.schema#.ACTIVE_PEOPLESOFT PS
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

</cfcomponent>