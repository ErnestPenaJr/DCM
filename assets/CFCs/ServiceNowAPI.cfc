<cfcomponent>

    <cffunction name="submitTicket" access="remote" returntype="string">
        <cfargument name="formData" type="struct" required="yes">
        
        <!--- Set up ServiceNow API credentials --->
        <cfset var username = "erniep@mdanderson.org">
        <cfset var password = "MDA268RedDragons">
        <cfset var apiUrl = "https://mdandersondev.servicenowservices.com/now/nav/ui/classic/params/target/$restapi.do">

        <!--- Create the post data --->
        <cfset var postData = {
            "subject" = formData.subject,
            "description" = formData.description
            "priorty" = formData.priority
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
