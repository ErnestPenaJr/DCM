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

    <cffunction name="submitTicket" access="remote" returntype="string">
        <cfargument name="formData" type="struct" required="yes">
        
        <!--- Set up ServiceNow API credentials --->
        <cfset var username = variables.config.servicenow.username>
        <cfset var password = variables.config.servicenow.password>
        <cfset var apiUrl = variables.config.servicenow.apiUrl>

        <!--- Create the post data --->
        <cfset var postData = {
            "subject" = formData.subject,
            "description" = formData.description,
            "priority" = formData.priority
            // Add other necessary fields based on API requirements
        }>

        <!--- Initialize an empty response variable --->
        <cfset var response = "">

        <!--- Set up the HTTP request --->
        <cfhttp method="post" url="#apiUrl#" result="httpResult">
            <cfhttpparam type="header" name="Content-Type" value="application/json">
            <cfhttpparam type="header" name="Authorization" value="Basic #ToBase64(username & ':' & password)#">
            <cfhttpparam type="body" value="#SerializeJSON(postData)#">
        </cfhttp>

        <!--- Check for a successful response --->
        <cfif httpResult.statusCode EQ "200 OK">
            <cfset response = DeserializeJSON(httpResult.fileContent)>
        <cfelse>
            <cfthrow message="Error in API request: #httpResult.statusCode#">
        </cfif>

        <!--- Return the response --->
        <cfreturn response>
    </cffunction>

</cfcomponent>
