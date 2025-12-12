// tests/e2e/projectManagement.spec.js
import { test, expect } from '@playwright/test';

test.describe('Project Management CRUD Operations', () => {
  const BASE_URL = 'http://localhost:8500/DCM';
  const EMPLID = '132034'; // A valid EMPLID for a logged-in user

  test.beforeEach(async ({ page }) => {
    // Navigate to the project management page
    await page.goto(`${BASE_URL}/projectManagement.html`);

    // Set session storage to simulate a logged-in user
    await page.evaluate((emplid) => {
      sessionStorage.setItem('ISLOGGINEDIN', '1');
      sessionStorage.setItem('EMPLID', emplid);
    }, EMPLID);

    // Reload the page to apply the session storage and trigger loadProjects
    await page.reload();

    // Wait for the projects table to be visible and loaded
    await expect(page.locator('#projectsTable')).toBeVisible();
    await page.waitForSelector('#projectsTable tbody tr', { state: 'attached' }); // Wait for some rows to be attached
  });

  test('should allow creating a new project', async ({ page }) => {
    const projectName = `Test Project ${Date.now()}`;
    const projectDescription = `Description for ${projectName}`;

    // Click "Add New Project" button
    await page.click('#addProjectModal'); 

    // Fill the form
    await page.fill('#projectName', projectName);
    await page.fill('#projectDescription', projectDescription);
    await page.selectOption('#projectStatus', 'A'); // Select 'Active'

    // Click "Save Project"
    await page.click('#saveProjectBtn');

    // Expect success message
    await expect(page.locator('.swal2-popup')).toContainText('Project has been created successfully!');
    await page.click('.swal2-confirm'); // Dismiss the SweetAlert

    // Verify the new project appears in the table
    await page.waitForSelector(`#projectsTable tbody tr:has-text("${projectName}")`);
    const row = page.locator(`#projectsTable tbody tr:has-text("${projectName}")`);
    await expect(row).toBeVisible();
    await expect(row).toContainText(projectDescription);
    await expect(row).toContainText('Active');
  });

  test('should allow editing an existing project', async ({ page }) => {
    // Assuming there's at least one project in the table from setup or a previous test
    // Find an existing project to edit (e.g., the last one added)
    await page.waitForSelector('#projectsTable tbody tr');
    const firstRow = page.locator('#projectsTable tbody tr').first();
    const projectId = await firstRow.locator('td').first().textContent();
    const originalName = await firstRow.locator('td').nth(1).textContent();

    // Click the edit button for the first project
    await firstRow.locator('button[title="Edit"]').click();

    // Expect the edit modal to appear
    await expect(page.locator('#editProjectModal')).toBeVisible();

    // Update project details
    const updatedName = `${originalName} - Edited`;
    const updatedDescription = `Updated description for ${updatedName}`;
    await page.fill('#editProjectName', updatedName);
    await page.fill('#editProjectDescription', updatedDescription);
    await page.selectOption('#editProjectStatus', 'I'); // Change status to Inactive

    // Click "Update Project"
    await page.click('#updateProjectBtn');

    // Expect success message
    await expect(page.locator('.swal2-popup')).toContainText('Project has been updated successfully!');
    await page.click('.swal2-confirm'); // Dismiss the SweetAlert

    // Verify the updated project details in the table
    await page.waitForSelector(`#projectsTable tbody tr:has-text("${updatedName}")`);
    const updatedRow = page.locator(`#projectsTable tbody tr:has-text("${updatedName}")`);
    await expect(updatedRow).toBeVisible();
    await expect(updatedRow).toContainText(updatedDescription);
    await expect(updatedRow).toContainText('Inactive');
  });

  test('should allow toggling project status', async ({ page }) => {
    // Find an existing project to toggle status
    await page.waitForSelector('#projectsTable tbody tr');
    const firstRow = page.locator('#projectsTable tbody tr').first();
    const projectId = await firstRow.locator('td').first().textContent();
    const initialStatusText = await firstRow.locator('.project-status-badge').textContent();

    // Click the toggle status button
    await firstRow.locator('button[title*="activate"]').click(); // Clicks either Activate or Deactivate button

    // Expect success message
    const expectedStatusText = initialStatusText.includes('Active') ? 'deactivated' : 'activated';
    await expect(page.locator('.swal2-popup')).toContainText(`Project has been ${expectedStatusText} successfully!`);
    await page.click('.swal2-confirm'); // Dismiss the SweetAlert

    // Verify the status is toggled in the table
    await page.reload(); // Reload to ensure data is fresh
    await expect(page.locator(`#projectsTable tbody tr:has-text("${projectId}") .project-status-badge`)).not.toContainText(initialStatusText);
    await expect(page.locator(`#projectsTable tbody tr:has-text("${projectId}") .project-status-badge`)).toContainText(initialStatusText.includes('Active') ? 'Inactive' : 'Active');
  });

  test('should allow deleting a project', async ({ page }) => {
    // Create a new project specifically for deletion
    const projectNameToDelete = `Delete Me Project ${Date.now()}`;
    await page.click('#addProjectModal'); // Assuming this opens the modal directly or has a visible trigger
    await page.fill('#projectName', projectNameToDelete);
    await page.fill('#projectDescription', 'Project to be deleted');
    await page.selectOption('#projectStatus', 'A');
    await page.click('#saveProjectBtn');
    await expect(page.locator('.swal2-popup')).toContainText('Project has been created successfully!');
    await page.click('.swal2-confirm'); // Dismiss the SweetAlert
    await page.waitForSelector(`#projectsTable tbody tr:has-text("${projectNameToDelete}")`);

    // Find the newly created project in the table
    const rowToDelete = page.locator(`#projectsTable tbody tr:has-text("${projectNameToDelete}")`);
    const projectIdToDelete = await rowToDelete.locator('td').first().textContent();

    // Click the delete button
    await rowToDelete.locator('button[title="Delete"]').click();

    // Expect the delete confirmation modal to appear
    await expect(page.locator('#deleteProjectModal')).toBeVisible();
    await expect(page.locator('#deleteProjectName')).toContainText(projectNameToDelete);

    // Confirm deletion
    await page.click('#confirmDeleteBtn');

    // Expect success message
    await expect(page.locator('.swal2-popup')).toContainText(`Project "${projectNameToDelete}" has been deleted successfully!`);
    await page.click('.swal2-confirm'); // Dismiss the SweetAlert

    // Verify the project is removed from the table
    await page.reload(); // Reload to ensure data is fresh
    await expect(page.locator(`#projectsTable tbody tr:has-text("${projectNameToDelete}")`)).not.toBeVisible();
  });
});
