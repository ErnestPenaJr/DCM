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

    <cffunction name="SendWeeklyReportEmails" access="remote" returnType="any" output="false">

    </cffunction>

</cfcomponent>
