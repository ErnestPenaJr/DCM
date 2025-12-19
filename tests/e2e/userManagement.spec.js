// tests/e2e/userManagement.spec.js
import { test, expect } from '@playwright/test';

test.describe('User Management CRUD Operations', () => {
  const BASE_URL = 'http://localhost:8500/DCM';
  const ADMIN_EMPLID = '132034'; // A valid EMPLID for a logged-in admin user

  test.beforeEach(async ({ page }) => {
    // Navigate to the user management page
    await page.goto(`${BASE_URL}/userManagement.html`);

    // Set session storage to simulate a logged-in admin user
    await page.evaluate((emplid) => {
      sessionStorage.setItem('ISLOGGEDIN', '1');
      sessionStorage.setItem('EMPLID', emplid);
    }, ADMIN_EMPLID);

    // Reload the page to apply the session storage and trigger loadUserAccessTable
    await page.reload();

    // Wait for the users table to be visible and loaded
    await expect(page.locator('#usersTable')).toBeVisible();
    await page.waitForSelector('#usersTable tbody tr', { state: 'attached' }); // Wait for some rows to be attached
  });

  test('should allow adding a new user access entry', async ({ page }) => {
    const newEmplid = '999999'; // Use an EMPLID that is not expected to exist in the system, or mock the search4Employees response
    const newPermissionId = '1'; // Assuming '1' is a valid permission ID (e.g., 'User')
    const newAllowedAccess = 'Y'; // 'Y' for enabled

    // Click "Add User" button
    await page.click('#addUserModal'); 

    // Search for an employee (simulating a valid selection)
    await page.locator('#employeeSearch').fill('Test User'); // Fill with a search term that would return newEmplid
    // For a real test, you'd ideally interact with the Select2 dropdown to select a specific result.
    // Since we're mocking or assuming a simple entry, we'll directly set the value if possible.
    // If Select2 makes it difficult to set directly, you might need a more advanced Playwright interaction.
    await page.selectOption('#employeeSearch', { value: newEmplid }); // Select the employee by value

    // Fill the form
    await page.selectOption('#permissionSelect', newPermissionId);
    await page.selectOption('#accessStatus', newAllowedAccess);

    // Click "Save User"
    await page.click('#saveUserBtn');

    // Expect success message
    await expect(page.locator('.swal2-popup')).toContainText('User access created successfully.');
    await page.click('.swal2-confirm'); // Dismiss the SweetAlert

    // Verify the new user appears in the table (might need to search or filter)
    await page.waitForSelector(`#usersTable tbody tr:has-text("${newEmplid}")`);
    const row = page.locator(`#usersTable tbody tr:has-text("${newEmplid}")`);
    await expect(row).toBeVisible();
    await expect(row).toContainText('Enabled');
  });

  test('should allow editing an existing user access entry', async ({ page }) => {
    // Assuming there's at least one user in the table from setup or a previous test
    // Find an existing user to edit (e.g., the one just created, or a known test user)
    await page.waitForSelector('#usersTable tbody tr');
    const firstRow = page.locator('#usersTable tbody tr').first();
    const emplidToEdit = await firstRow.locator('td').first().textContent(); // Assuming EMPLID is in the first column

    // Click the edit button for the user
    await firstRow.locator('button[title="Edit"]').click();

    // Expect the edit modal to appear
    await expect(page.locator('#editUserModal')).toBeVisible();

    // Update user details
    const updatedPermissionId = '2'; // Assuming '2' is another valid permission ID (e.g., 'Admin')
    const updatedAllowedAccess = 'N'; // 'N' for disabled
    await page.selectOption('#editPermissionSelect', updatedPermissionId);
    await page.selectOption('#editAccessStatus', updatedAllowedAccess);

    // Click "Save Changes"
    await page.click('#saveUserChanges');

    // Expect success message
    await expect(page.locator('.swal2-popup')).toContainText('User access updated successfully.');
    await page.click('.swal2-confirm'); // Dismiss the SweetAlert

    // Verify the updated user details in the table
    await page.reload(); // Reload to ensure data is fresh
    const updatedRow = page.locator(`#usersTable tbody tr:has-text("${emplidToEdit}")`);
    await expect(updatedRow).toBeVisible();
    await expect(updatedRow).toContainText('Disabled');
    // You might also check for the permission name if it's displayed in the table
  });

  test('should allow deleting a user access entry', async ({ page }) => {
    // Create a new user specifically for deletion
    const emplidToDelete = '999998';
    const nameToDelete = `Temp User ${emplidToDelete}`;

    // Directly call the AJAX for creating user for simplicity in this test,
    // or repeat the "add user" steps if you prefer full UI interaction.
    // For this example, we'll assume a user is added and then attempt to delete it via UI.
    // This part would ideally be set up via API calls in a real test suite to isolate test steps.
    await page.evaluate(async (data) => {
      await fetch('assets/CFCs/UserService.cfc?method=createUserAccess', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(data).toString()
      });
    }, { EMPLID: emplidToDelete, PERMISSIONID: '1', ALLOWEDACCESS: 'Y', CREATEDBYID: ADMIN_EMPLID });
    
    await page.reload(); // Reload to ensure the newly added user is in the table
    await page.waitForSelector(`#usersTable tbody tr:has-text("${nameToDelete}")`);

    // Find the newly created user in the table
    const rowToDelete = page.locator(`#usersTable tbody tr:has-text("${nameToDelete}")`);

    // Click the delete button
    await rowToDelete.locator('button[title="Delete"]').click();

    // Expect the delete confirmation modal to appear
    await expect(page.locator('.swal2-popup')).toContainText(`Are you sure you want to delete access for ${nameToDelete}?`);

    // Confirm deletion
    await page.click('.swal2-confirm'); // Click "Yes, delete access"

    // Expect success message
    await expect(page.locator('.swal2-popup')).toContainText('User access has been deleted.');
    await page.click('.swal2-confirm'); // Dismiss the SweetAlert

    // Verify the user is removed from the table
    await page.reload(); // Reload to ensure data is fresh
    await expect(page.locator(`#usersTable tbody tr:has-text("${nameToDelete}")`)).not.toBeVisible();
  });
});
