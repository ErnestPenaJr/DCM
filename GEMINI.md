# Project Overview

This is a Daily Time Tracking application. It allows users to log their daily tasks against projects, and provides a way to manage those projects. The application is built with a ColdFusion backend and a frontend using HTML, CSS, and JavaScript. It uses a number of frontend libraries, including Bootstrap, jQuery, DataTables, and Chart.js.

The application has the following features:

- User authentication via LDAP
- Session management
- A daily task entry form
- A weekly view of tasks
- A table of all tasks
- Project management (add, edit, delete projects)
- User access management

# Building and Running

There are no explicit build steps defined in the project. The application can be run by deploying the files to a ColdFusion server. The entry point of the application is `index.html`.

**TODO:** Document the exact steps for deploying and configuring the application on a ColdFusion server. This should include details about the required ColdFusion version, database setup, and any other server-side configuration.

# Development Conventions

The project does not have any explicit coding style guidelines. However, the existing code follows some conventions:

- **ColdFusion:** The backend code is written in ColdFusion components (`.cfc` files). Database queries are written in CFQuery tags.
- **JavaScript:** The frontend code uses jQuery for DOM manipulation and AJAX calls.
- **CSS:** The application uses Bootstrap for styling, with some custom styles in `assets/css/style.css`.
- **File Structure:** The project is organized into folders for assets (CSS, JavaScript, images, etc.), and ColdFusion components.

# Database

The application uses a database with the following tables:

- `DAILY_TASKS`: Stores the daily tasks entered by users.
- `DAILY_TASKS_PROJECTS`: Stores the projects that tasks can be associated with.
- `DAILY_TASKS_USERACCESS`: Manages user access and permissions.
- `DAILY_TASKS_PERMISSIONS`: Stores the different permission levels.
- `ACTIVE_PEOPLESOFT`: Appears to be a view or table with employee information.

The database connection details are hardcoded in `assets/CFCs/functions.cfc`. This is a security risk and should be addressed by moving the credentials to a configuration file outside of the webroot.
