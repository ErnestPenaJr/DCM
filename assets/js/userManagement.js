// Global function for editing users
function editUser(emplid, name, permissionid, allowedaccess) {
    // Set the values in the edit modal
    $('#editUserEmplId').val(emplid);
    $('#editUserName').val(name);
    $('#editPermissionSelect').val(permissionid);
    $('#editAccessStatus').val(allowedaccess);
    
    // Show the modal
    $('#editUserModal').modal('show');
}

// Global function for deleting users
function deleteUser(emplid, name) {
    Swal.fire({
        title: 'Delete User Access',
        text: `Are you sure you want to delete access for ${name}?`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Yes, delete access',
        cancelButtonText: 'Cancel'
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url: 'assets/CFCs/UserService.cfc?method=deleteUserAccess',
                type: 'POST',
                dataType: 'json',
                data: {
                    EMPLID: emplid
                },
                success: function(response) {
                    if (response && response.success) {
                        Swal.fire({
                            title: 'Deleted!',
                            text: 'User access has been deleted.',
                            icon: 'success',
                            timer: 1500,
                            showConfirmButton: false
                        });
                        loadUserAccessTable();
                    } else {
                        Swal.fire({
                            title: 'Error!',
                            text: 'Failed to delete user access.',
                            icon: 'error'
                        });
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error deleting user:', error);
                    Swal.fire({
                        title: 'Error!',
                        text: 'An error occurred while deleting user access.',
                        icon: 'error'
                    });
                }
            });
        }
    });
}

function initializeUsersTable() {
    // Check if DataTable already exists and destroy it
    if ($.fn.DataTable.isDataTable('#usersTable')) {
        $('#usersTable').DataTable().destroy();
    }

    $('#usersTable').DataTable({
        "responsive": true,
        "pageLength": 25,
        "language": {
            "search": "Search users:",
            "lengthMenu": "Show _MENU_ users per page",
            "info": "Showing _START_ to _END_ of _TOTAL_ users",
            "emptyTable": "No users found"
        }
    });
}

$(document).ready(function() {
    // Initialize AOS
    AOS.init({
        duration: 800,
        once: true,
        offset: 100
    });

    // Initialize DataTable
    initializeUsersTable();

    // Initialize Select2 for employee search when modal is shown
    $('#addUserModal').on('shown.bs.modal', function() {
        // Destroy existing Select2 instance if it exists
        if ($('#employeeSearch').hasClass('select2-hidden-accessible')) {
            $('#employeeSearch').select2('destroy');
        }

        // Initialize Select2 for employee search
        $('#employeeSearch').select2({
            theme: 'bootstrap-5',
            dropdownParent: $('#addUserModal .modal-body'),
            ajax: {
                url: 'assets/CFCs/UserService.cfc',
                dataType: 'json',
                delay: 300,
                data: function(params) {
                    return {
                        method: 'search4Employees',
                        query: params.term || '',
                        maxrows: 15
                    };
                },
                processResults: function(data) {
                    console.log('Search results:', data);
                    if (!data || !data.items) {
                        return { results: [] };
                    }
                    return {
                        results: data.items.map(function(item) {
                            return {
                                id: item.emplID,
                                text: item.displayName + ' (' + item.emplID + ')',
                                employee: item
                            };
                        })
                    };
                },
                error: function(xhr, status, error) {
                    console.error('Employee search error:', error);
                    return { results: [] };
                },
                cache: true
            },
            minimumInputLength: 2,
            placeholder: 'Type at least 2 characters to search...',
            allowClear: true,
            width: '100%',
            language: {
                inputTooShort: function() {
                    return 'Please enter 2 or more characters to search';
                },
                searching: function() {
                    return 'Searching employees...';
                },
                noResults: function() {
                    return 'No employees found';
                },
                errorLoading: function() {
                    return 'Error loading results';
                }
            },
            templateResult: formatEmployeeResult,
            templateSelection: formatEmployeeSelection
        });

        // Focus on the search input
        setTimeout(function() {
            $('#employeeSearch').select2('open');
        }, 250);
    });

    // Format the dropdown results with more details
    function formatEmployeeResult(employee) {
        if (employee.loading) {
            return $('<div class="searching-animation p-3 text-center">' +
                '<div class="search-dots mb-2">' +
                    '<span class="dot"></span>' +
                    '<span class="dot"></span>' +
                    '<span class="dot"></span>' +
                '</div>' +
                '<span class="searching-text">Searching employees</span>' +
            '</div>');
        }
        if (!employee.employee) {
            return employee.text;
        }

        var emp = employee.employee;
        var $container = $(
            '<div class="employee-result p-2">' +
                '<div class="d-flex justify-content-between align-items-start">' +
                    '<div>' +
                        '<div class="fw-bold employee-name">' + (emp.displayName || emp.name) + '</div>' +
                        '<div class="mt-1">' +
                            '<span class="badge bg-primary me-1"><i class="fas fa-id-badge me-1"></i>' + emp.emplID + '</span>' +
                            '<span class="badge bg-info text-dark"><i class="fas fa-building me-1"></i>' + (emp.departmentname || 'N/A') + '</span>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
                '<div class="mt-2">' +
                    '<span class="badge bg-success"><i class="fas fa-briefcase me-1"></i>' + (emp.jobTitle || 'N/A') + '</span>' +
                '</div>' +
            '</div>'
        );
        return $container;
    }

    // Format the selected employee
    function formatEmployeeSelection(employee) {
        if (!employee.id) {
            return employee.text;
        }
        if (employee.employee) {
            return employee.employee.displayName + ' (' + employee.id + ')';
        }
        return employee.text;
    }

    // Load permissions for select boxes
    function loadPermissions() {
        $.getJSON('assets/CFCs/UserService.cfc?method=getAllPermissions', function(data) {
            const permissions = data.items;
            const permissionSelect = $('#permissionSelect, #editPermissionSelect');
            permissionSelect.empty().append('<option value="">Select permission</option>');
            
            permissions.forEach(function(permission) {
                permissionSelect.append(
                    `<option value="${permission.permissionid}">${permission.permissionname}</option>`
                );
            });
        }).fail(function(jqXHR, textStatus, errorThrown) {
            Swal.fire({
                title: 'Error!',
                text: 'Failed to load permissions.',
                icon: 'error'
            });
        });
    }

    // Load and display users
    function loadUserAccessTable() {
        $.ajax({
            url: 'assets/CFCs/UserService.cfc?method=getAllUserAccess',
            type: 'GET',
            dataType: 'json',
            success: function(response) {
                var table = $('#usersTable').DataTable();
                table.clear();
                
                if (!response || !response.items) {
                    console.error('Invalid response format:', response);
                    Swal.fire({
                        title: 'Error!',
                        text: 'Invalid data received from server.',
                        icon: 'error'
                    });
                    return;
                }

                if (response.items && response.items.length > 0) {
                    var rowData = [];
                    response.items.forEach(function(user) {
                        var statusBadge = user.allowedaccess === 'Y' ?
                            '<span class="badge bg-success user-status-badge"><i class="fas fa-check-circle me-1"></i>Enabled</span>' :
                            '<span class="badge bg-danger user-status-badge"><i class="fas fa-times-circle me-1"></i>Disabled</span>';

                        var cleanName = (user.name || '').replace(/'/g, '');
                        var actions = '<button class="btn btn-sm btn-outline-primary me-1" onclick="editUser(\'' + user.emplid + '\', \'' + cleanName + '\', \'' + user.permissionid + '\', \'' + user.allowedaccess + '\')" title="Edit"><i class="fas fa-edit"></i></button>' +
                            '<button class="btn btn-sm btn-outline-danger" onclick="deleteUser(\'' + user.emplid + '\', \'' + cleanName + '\')" title="Delete"><i class="fas fa-trash"></i></button>';

                        var row = [
                            String(user.name || ''),
                            String(user.departmentname || ''),
                            String(user.permissionname || ''),
                            statusBadge,
                            String(user.lastlogin ? new Date(user.lastlogin).toLocaleDateString() : 'Never'),
                            actions
                        ];

                        rowData.push(row);
                    });

                    // Add all rows at once
                    table.rows.add(rowData).draw();
                }

                Swal.fire({
                    title: 'Success!',
                    text: 'Users loaded successfully (' + (response.items ? response.items.length : 0) + ' found)',
                    icon: 'success',
                    timer: 1500,
                    showConfirmButton: false
                });
            },
            error: function(xhr, status, error) {
                console.error('Error loading users:', error);
                Swal.fire({
                    title: 'Error!',
                    text: 'Failed to load user data.',
                    icon: 'error'
                });
            }
        });
    }

    // Add new user - button click handler
    $('#saveUserBtn').on('click', function(e) {
        e.preventDefault();
        var form = $('#addUserForm')[0];

        if (form.checkValidity()) {
            saveNewUser();
        } else {
            form.classList.add('was-validated');
        }
    });

    // Add new user function
    function saveNewUser() {
        const data = {
            EMPLID: $('#employeeSearch').val(),
            PERMISSIONID: $('#permissionSelect').val(),
            ALLOWEDACCESS: $('#accessStatus').val(),
            CREATEDBYID: window.currentUser?.EMPLID || 'SYSTEM'
        };

        $('#saveUserBtn').prop('disabled', true).html('<i class="fas fa-spinner fa-spin me-2"></i>Saving...');

        $.ajax({
            url: 'assets/CFCs/UserService.cfc?method=createUserAccess',
            method: 'POST',
            dataType: 'json',
            data: data,
            success: function(response) {
                if (response && response.success) {
                    $('#addUserModal').modal('hide');
                    Swal.fire({
                        title: 'Success!',
                        text: 'User access created successfully.',
                        icon: 'success',
                        timer: 1500,
                        showConfirmButton: false
                    });
                    loadUserAccessTable();
                } else {
                    Swal.fire({
                        title: 'Error!',
                        text: 'Error: ' + (response?.message || 'Unknown error'),
                        icon: 'error'
                    });
                }
            },
            error: function() {
                Swal.fire({
                    title: 'Error!',
                    text: 'Error creating user access.',
                    icon: 'error'
                });
            },
            complete: function() {
                $('#saveUserBtn').prop('disabled', false).html('<i class="fas fa-save me-2"></i>Save User');
            }
        });
    }

    // Reset form when modal is hidden
    $('#addUserModal').on('hidden.bs.modal', function () {
        $('#addUserForm')[0].reset();
        $('#addUserForm').removeClass('was-validated');
        $('#employeeSearch').val(null).trigger('change');
    });

    // Save user changes
    $('#saveUserChanges').on('click', function() {
        const data = {
            EMPLID: $('#editUserEmplId').val(),
            PERMISSIONID: $('#editPermissionSelect').val(),
            ALLOWEDACCESS: $('#editAccessStatus').val(),
            MODIFIEDBYID: window.currentUser?.EMPLID || 'SYSTEM'
        };

        $.ajax({
            url: 'assets/CFCs/UserService.cfc?method=updateUserAccess',
            method: 'POST',
            data: data,
            dataType: 'json',
            success: function(response) {
                if (response && response.success) {
                    Swal.fire({
                        title: 'Success!',
                        text: 'User access updated successfully.',
                        icon: 'success',
                        timer: 1500,
                        showConfirmButton: false
                    });
                    $('#editUserModal').modal('hide');
                    loadUserAccessTable();
                } else {
                    Swal.fire({
                        title: 'Error!',
                        text: 'Error: ' + (response?.message || 'Unknown error'),
                        icon: 'error'
                    });
                }
            },
            error: function() {
                Swal.fire({
                    title: 'Error!',
                    text: 'Error updating user access.',
                    icon: 'error'
                });
            }
        });
    });

    // Initial load
    loadPermissions();
    loadUserAccessTable();
});
