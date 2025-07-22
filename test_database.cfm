<!DOCTYPE html>
<html>
<head>
    <title>Database Test - Projects Table</title>
    <link rel="stylesheet" href="node_modules/bootstrap/dist/css/bootstrap.css">
</head>
<body class="container mt-5">
    <h1>Database Test - DAILY_TASKS_PROJECTS Table</h1>
    
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-header">
                    <h5>Direct Database Query Test</h5>
                </div>
                <div class="card-body">
                    <h6>1. Check if table exists and count records:</h6>
                    <cfquery name="countQuery" datasource="inside2_docmd" username="HMOFP" password="1DocmD4AU6D23">
                        SELECT COUNT(*) as record_count FROM HMOFP.DAILY_TASKS_PROJECTS
                    </cfquery>
                    <p><strong>Record Count:</strong> <cfoutput>#countQuery.record_count#</cfoutput></p>
                    
                    <h6>2. Show all records in table:</h6>
                    <cfquery name="allRecords" datasource="inside2_docmd" username="HMOFP" password="1DocmD4AU6D23">
                        SELECT * FROM HMOFP.DAILY_TASKS_PROJECTS ORDER BY DATECREATED DESC
                    </cfquery>
                    
                    <cfif allRecords.recordCount GT 0>
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>PROJECT_ID</th>
                                    <th>PROJECT_NAME</th>
                                    <th>PROJECT_DESCRIPTION</th>
                                    <th>STATUS</th>
                                    <th>DATECREATED</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfoutput query="allRecords">
                                    <tr>
                                        <td>#PROJECT_ID#</td>
                                        <td>#PROJECT_NAME#</td>
                                        <td>#PROJECT_DESCRIPTION#</td>
                                        <td>#STATUS#</td>
                                        <td>#DateFormat(DATECREATED, "mm/dd/yyyy")#</td>
                                    </tr>
                                </cfoutput>
                            </tbody>
                        </table>
                    <cfelse>
                        <div class="alert alert-warning">
                            <strong>No records found!</strong> The DAILY_TASKS_PROJECTS table is empty.
                        </div>
                    </cfif>
                    
                    <h6>3. Test getAllProjects function:</h6>
                    <cfinvoke component="assets.CFCs.functions" method="getAllProjects" returnvariable="projectsResult">
                    <div class="alert alert-info">
                        <strong>getAllProjects Result:</strong>
                        <pre><cfoutput>#serializeJSON(projectsResult, true)#</cfoutput></pre>
                    </div>
                    
                    <h6>4. Insert a test project:</h6>
                    <cfform method="post">
                        <div class="mb-3">
                            <input type="text" name="testProjectName" class="form-control" placeholder="Test Project Name" value="Sample Project">
                        </div>
                        <div class="mb-3">
                            <textarea name="testProjectDesc" class="form-control" placeholder="Description">This is a test project created for debugging</textarea>
                        </div>
                        <button type="submit" name="insertTest" class="btn btn-primary">Insert Test Project</button>
                    </cfform>
                    
                    <cfif structKeyExists(form, "insertTest")>
                        <cftry>
                            <cfquery datasource="inside2_docmd" username="HMOFP" password="1DocmD4AU6D23">
                                INSERT INTO HMOFP.DAILY_TASKS_PROJECTS
                                (PROJECT_NAME, PROJECT_DESCRIPTION, STATUS)
                                VALUES
                                (
                                    <cfqueryparam value="#form.testProjectName#" cfsqltype="CF_SQL_VARCHAR">,
                                    <cfqueryparam value="#form.testProjectDesc#" cfsqltype="CF_SQL_VARCHAR">,
                                    <cfqueryparam value="A" cfsqltype="CF_SQL_VARCHAR">
                                )
                            </cfquery>
                            <div class="alert alert-success mt-3">
                                <strong>Success!</strong> Test project inserted successfully.
                                <script>setTimeout(function(){ location.reload(); }, 2000);</script>
                            </div>
                            <cfcatch>
                                <div class="alert alert-danger mt-3">
                                    <strong>Error inserting test project:</strong><br>
                                    <cfoutput>#cfcatch.message#<br>#cfcatch.detail#</cfoutput>
                                </div>
                            </cfcatch>
                        </cftry>
                    </cfif>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
