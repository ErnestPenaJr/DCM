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

    <cffunction name="getFileActivity" access="remote" returntype="any" returnformat="JSON">
        <cfargument name="START_DATE" type="string" required="true" />
        <cfargument name="END_DATE"   type="string" required="true" />

        <cfset var wwwrootPath = expandPath("/")>
        <cfset var startDT = CreateDateTime(
            ListFirst(arguments.START_DATE, "-"),
            ListGetAt(arguments.START_DATE, 2, "-"),
            ListLast(arguments.START_DATE, "-"),
            0, 0, 0
        )>
        <cfset var endDT = CreateDateTime(
            ListFirst(arguments.END_DATE, "-"),
            ListGetAt(arguments.END_DATE, 2, "-"),
            ListLast(arguments.END_DATE, "-"),
            23, 59, 59
        )>

        <!--- Directory names that must NEVER be entered --->
        <cfset var excludeNames = "node_modules,.git,CFIDE,cf_scripts,WEB-INF,fontawesome,__MACOSX,.cache,dist,build,vendor,bower_components,svgs,less,scss,fonts,images,img">

        <!--- Source file extensions only --->
        <cfset var includeExts = "cfm,cfc,html,htm,js,css,sql,json,py,md,cfml,ts,jsx,tsx,vue">

        <cfset var retVal = ArrayNew(1)>

        <cftry>

            <!--- ── Level 1: top-level project folders ── --->
            <cfdirectory action="list" directory="#wwwrootPath#" recurse="no" name="level1Dirs" type="dir" sort="name ASC" />

            <cfloop query="level1Dirs">
                <cfif NOT ListFindNoCase(excludeNames, name)>
                    <cfset var projName = name>
                    <cfset var projPath = directory & "/" & name>

                    <!--- Files directly inside the project folder --->
                    <cftry>
                        <cfdirectory action="list" directory="#projPath#" recurse="no" name="l1Files" type="file" />
                        <cfloop query="l1Files">
                            <cfset var ext1 = LCase(ListLast(name, "."))>
                            <cfif ListFindNoCase(includeExts, ext1) AND dateLastModified GTE startDT AND dateLastModified LTE endDT>
                                <cfset var t1 = {}>
                                <cfset t1["FILE_NAME"]     = name>
                                <cfset t1["DIRECTORY"]     = projName>
                                <cfset t1["PROJECT"]       = projName>
                                <cfset t1["DATE_MODIFIED"] = DateFormat(dateLastModified,"yyyy-mm-dd") & "T" & TimeFormat(dateLastModified,"HH:mm")>
                                <cfset t1["SIZE"]          = size>
                                <cfset ArrayAppend(retVal, t1)>
                            </cfif>
                        </cfloop>
                        <cfcatch type="any"></cfcatch>
                    </cftry>

                    <!--- ── Level 2: subdirectories of each project ── --->
                    <cftry>
                        <cfdirectory action="list" directory="#projPath#" recurse="no" name="level2Dirs" type="dir" />
                        <cfloop query="level2Dirs">
                            <cfif NOT ListFindNoCase(excludeNames, name)>
                                <cfset var subName = name>
                                <cfset var subPath = directory & "/" & name>

                                <!--- Files inside this subdirectory --->
                                <cftry>
                                    <cfdirectory action="list" directory="#subPath#" recurse="no" name="l2Files" type="file" />
                                    <cfloop query="l2Files">
                                        <cfset var ext2 = LCase(ListLast(name, "."))>
                                        <cfif ListFindNoCase(includeExts, ext2) AND dateLastModified GTE startDT AND dateLastModified LTE endDT>
                                            <cfset var t2 = {}>
                                            <cfset t2["FILE_NAME"]     = name>
                                            <cfset t2["DIRECTORY"]     = projName & "/" & subName>
                                            <cfset t2["PROJECT"]       = projName>
                                            <cfset t2["DATE_MODIFIED"] = DateFormat(dateLastModified,"yyyy-mm-dd") & "T" & TimeFormat(dateLastModified,"HH:mm")>
                                            <cfset t2["SIZE"]          = size>
                                            <cfset ArrayAppend(retVal, t2)>
                                        </cfif>
                                    </cfloop>
                                    <cfcatch type="any"></cfcatch>
                                </cftry>

                                <!--- ── Level 3: one more level deep ── --->
                                <cftry>
                                    <cfdirectory action="list" directory="#subPath#" recurse="no" name="level3Dirs" type="dir" />
                                    <cfloop query="level3Dirs">
                                        <cfif NOT ListFindNoCase(excludeNames, name)>
                                            <cfset var sub3Path = directory & "/" & name>
                                            <cftry>
                                                <cfdirectory action="list" directory="#sub3Path#" recurse="no" name="l3Files" type="file" />
                                                <cfloop query="l3Files">
                                                    <cfset var ext3 = LCase(ListLast(name, "."))>
                                                    <cfif ListFindNoCase(includeExts, ext3) AND dateLastModified GTE startDT AND dateLastModified LTE endDT>
                                                        <cfset var t3 = {}>
                                                        <cfset t3["FILE_NAME"]     = name>
                                                        <cfset t3["DIRECTORY"]     = projName & "/" & subName & "/" & level3Dirs.name>
                                                        <cfset t3["PROJECT"]       = projName>
                                                        <cfset t3["DATE_MODIFIED"] = DateFormat(dateLastModified,"yyyy-mm-dd") & "T" & TimeFormat(dateLastModified,"HH:mm")>
                                                        <cfset t3["SIZE"]          = size>
                                                        <cfset ArrayAppend(retVal, t3)>
                                                    </cfif>
                                                </cfloop>
                                                <cfcatch type="any"></cfcatch>
                                            </cftry>
                                        </cfif>
                                    </cfloop>
                                    <cfcatch type="any"></cfcatch>
                                </cftry>

                            </cfif>
                        </cfloop>
                        <cfcatch type="any"></cfcatch>
                    </cftry>

                </cfif>
            </cfloop>

            <!--- Sort newest first --->
            <cfset ArraySort(retVal, function(a, b) {
                return Compare(b.DATE_MODIFIED, a.DATE_MODIFIED);
            })>

            <cfcatch type="any">
                <cfreturn { "files": [], "fileCount": 0, "error": cfcatch.message }>
            </cfcatch>
        </cftry>

        <cfset var result = {}>
        <cfset result["files"]     = retVal>
        <cfset result["fileCount"] = ArrayLen(retVal)>
        <cfreturn result>
    </cffunction>

    <!--- TODO: Implement SendWeeklyReportEmails functionality
    <cffunction name="SendWeeklyReportEmails" access="remote" returnType="any" output="false">
        <cfargument name="EMPLID" type="string" required="true">
        <cfargument name="WEEK_NUM" type="string" required="true">

        <!--- Implementation pending: Send weekly task summary via email --->
        <cfreturn {"success": false, "message": "Not implemented"}>
    </cffunction>
    --->

</cfcomponent>
