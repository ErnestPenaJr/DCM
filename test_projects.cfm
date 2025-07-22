<!DOCTYPE html>
<html>
<head>
    <title>Test Projects</title>
</head>
<body>
    <h1>Testing Project Functions</h1>
    
    <h2>All Projects:</h2>
    <cfinvoke component="assets.CFCs.functions" method="getAllProjects" returnvariable="projects">
    <cfdump var="#projects#">
    
    <h2>Database Connection Test:</h2>
    <cfquery name="testQuery" datasource="inside2_docmd" username="HMOFP" password="1DocmD4AU6D23">
        SELECT COUNT(*) as project_count FROM HMOFP.DAILY_TASKS_PROJECTS
    </cfquery>
    <cfdump var="#testQuery#">
    
</body>
</html>
