<!DOCTYPE html>
<html>
<head>
    <title>Insert Sample Projects</title>
    <link rel="stylesheet" href="node_modules/bootstrap/dist/css/bootstrap.css">
</head>
<body class="container mt-5">
    <h1>Insert Sample Projects</h1>
    
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-header">
                    <h5>Adding Sample Projects to Database</h5>
                </div>
                <div class="card-body">
                    <cftry>
                        <!-- Insert sample projects -->
                        <cfquery datasource="inside2_docmd" username="HMOFP" password="1DocmD4AU6D23">
                            INSERT INTO HMOFP.DAILY_TASKS_PROJECTS
                            (PROJECT_NAME, PROJECT_DESCRIPTION, STATUS)
                            VALUES
                            ('Website Development', 'Development and maintenance of company website', 'A')
                        </cfquery>
                        
                        <cfquery datasource="inside2_docmd" username="HMOFP" password="1DocmD4AU6D23">
                            INSERT INTO HMOFP.DAILY_TASKS_PROJECTS
                            (PROJECT_NAME, PROJECT_DESCRIPTION, STATUS)
                            VALUES
                            ('Database Migration', 'Migration of legacy database to new system', 'A')
                        </cfquery>
                        
                        <cfquery datasource="inside2_docmd" username="HMOFP" password="1DocmD4AU6D23">
                            INSERT INTO HMOFP.DAILY_TASKS_PROJECTS
                            (PROJECT_NAME, PROJECT_DESCRIPTION, STATUS)
                            VALUES
                            ('Mobile App Development', 'Development of mobile application for iOS and Android', 'A')
                        </cfquery>
                        
                        <cfquery datasource="inside2_docmd" username="HMOFP" password="1DocmD4AU6D23">
                            INSERT INTO HMOFP.DAILY_TASKS_PROJECTS
                            (PROJECT_NAME, PROJECT_DESCRIPTION, STATUS)
                            VALUES
                            ('System Integration', 'Integration of various business systems', 'I')
                        </cfquery>
                        
                        <cfquery datasource="inside2_docmd" username="HMOFP" password="1DocmD4AU6D23">
                            INSERT INTO HMOFP.DAILY_TASKS_PROJECTS
                            (PROJECT_NAME, PROJECT_DESCRIPTION, STATUS)
                            VALUES
                            ('Training Program', 'Employee training and development program', 'A')
                        </cfquery>
                        
                        <div class="alert alert-success">
                            <h4>✅ Success!</h4>
                            <p>Sample projects have been inserted successfully:</p>
                            <ul>
                                <li><strong>Website Development</strong> - Active</li>
                                <li><strong>Database Migration</strong> - Active</li>
                                <li><strong>Mobile App Development</strong> - Active</li>
                                <li><strong>System Integration</strong> - Inactive</li>
                                <li><strong>Training Program</strong> - Active</li>
                            </ul>
                        </div>
                        
                        <h6>Verify insertion - Current projects count:</h6>
                        <cfquery name="countQuery" datasource="inside2_docmd" username="HMOFP" password="1DocmD4AU6D23">
                            SELECT COUNT(*) as total_count FROM HMOFP.DAILY_TASKS_PROJECTS
                        </cfquery>
                        <cfquery name="activeQuery" datasource="inside2_docmd" username="HMOFP" password="1DocmD4AU6D23">
                            SELECT COUNT(*) as active_count FROM HMOFP.DAILY_TASKS_PROJECTS WHERE STATUS = 'A'
                        </cfquery>
                        
                        <div class="alert alert-info">
                            <p><strong>Total Projects:</strong> <cfoutput>#countQuery.total_count#</cfoutput></p>
                            <p><strong>Active Projects:</strong> <cfoutput>#activeQuery.active_count#</cfoutput></p>
                        </div>
                        
                        <div class="mt-4">
                            <a href="projectManagement_test.html" class="btn btn-primary">Go to Project Management Page</a>
                            <a href="test_database.cfm" class="btn btn-secondary">View Database Test</a>
                        </div>
                        
                        <cfcatch>
                            <div class="alert alert-danger">
                                <h4>❌ Error!</h4>
                                <p><strong>Error Message:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                                <p><strong>Detail:</strong> <cfoutput>#cfcatch.detail#</cfoutput></p>
                                <p><strong>SQL State:</strong> <cfoutput>#cfcatch.sqlstate#</cfoutput></p>
                            </div>
                        </cfcatch>
                    </cftry>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
