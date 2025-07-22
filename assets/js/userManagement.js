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
                url: 'assets/CFCs/functions.cfc?method=deleteUserAccess',
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

$(document).ready(function() {
    // Initialize Select2 for employee search
    $('#employeeSearch').select2({
        ajax: {
            url: 'assets/CFCs/functions.cfc?method=search4Employees',
            dataType: 'json',
            delay: 250,
            data: function(params) {
                return {
                    query: params.term
                };
            },
            processResults: function(data) {
                return {
                    results: data.items.map(function(item) {
                        return {
                            id: item.emplID,
                            text: item.displayName + ' (' + item.emplID + ')'
                        };
                    })
                };
            },
            cache: true
        },
        minimumInputLength: 2,
        placeholder: 'Search by name or employee ID'
    });

    // Load permissions for select boxes
    function loadPermissions() {
        $.getJSON('assets/CFCs/functions.cfc?method=getAllPermissions', function(data) {
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
            url: 'assets/CFCs/functions.cfc?method=getAllUserAccess',
            type: 'GET',
            dataType: 'json',
            success: function(response) {
                const tbody = $('#userTableBody');
                tbody.empty();
                
                if (!response || !response.items) {
                    console.error('Invalid response format:', response);
                    Swal.fire({
                        title: 'Error!',
                        text: 'Invalid data received from server.',
                        icon: 'error'
                    });
                    return;
                }

                response.items.forEach(function(user) {
                    const row = `
                        <tr>
                            <td>${user.name || ''}</td>
                            <td>${user.departmentname || ''}</td>
                            <td>${user.permissionname || ''}</td>
                            <td>
                                <span class="badge ${user.allowedaccess === 'Y' ? 'bg-success' : 'bg-danger'}">
                                    <i class="fas fa-${user.allowedaccess === 'Y' ? 'check-circle' : 'times-circle'} me-1"></i>
                                    ${user.allowedaccess === 'Y' ? 'Enabled' : 'Disabled'}
                                </span>
                            </td>
                            <td>${user.lastlogin ? new Date(user.lastlogin).toLocaleDateString() : 'Never'}</td>
                            <td>
                                <button class="btn btn-sm btn-primary me-1" onclick="editUser('${user.emplid}', '${(user.name || '').replace(/'/g, "\\'")}', '${user.permissionid}', '${user.allowedaccess}')">
                                    <i class="fas fa-edit me-1"></i>Edit
                                </button>
                                <button class="btn btn-sm btn-danger delete-user" onclick="deleteUser('${user.emplid}', '${(user.name || '').replace(/'/g, "\\'")}')">
                                    <i class="fas fa-trash-alt me-1"></i>Delete
                                </button>
                            </td>
                        </tr>
                    `;
                    tbody.append(row);
                });

                // Re-initialize any tooltips or popovers
                $('[data-bs-toggle="tooltip"]').tooltip();
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

    // Add new user
    $('#addUserForm').on('submit', function(e) {
        e.preventDefault();
        
        const data = {
            EMPLID: $('#employeeSearch').val(),
            PERMISSIONID: $('#permissionSelect').val(),
            ALLOWEDACCESS: $('#accessStatus').val(),
            CREATEDBYID: window.currentUser?.EMPLID || 'SYSTEM'
        };

        $.ajax({
            url: 'assets/CFCs/functions.cfc?method=createUserAccess',
            method: 'POST',
            data: data,
            success: function(response) {
                if (response.success) {
                    Swal.fire({
                        title: 'Success!',
                        text: 'User access created successfully.',
                        icon: 'success',
                        timer: 1500,
                        showConfirmButton: false
                    });
                    $('#addUserForm')[0].reset();
                    $('#employeeSearch').val(null).trigger('change');
                    loadUserAccessTable();
                } else {
                    Swal.fire({
                        title: 'Error!',
                        text: 'Error: ' + response.message,
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
            }
        });
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
            url: 'assets/CFCs/functions.cfc?method=updateUserAccess',
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

    // Search functionality
    $('#userSearchInput').on('keyup', function() {
        const searchText = $(this).val().toLowerCase();
        $('#userTableBody tr').each(function() {
            const rowText = $(this).text().toLowerCase();
            $(this).toggle(rowText.indexOf(searchText) > -1);
        });
    });

    // Initial load
    loadPermissions();
    loadUserAccessTable();
});
