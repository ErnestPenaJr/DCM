// tests/e2e/login.spec.js
import { test, expect } from '@playwright/test';

test.describe('Login and Session Management', () => {
  // Replace with your application's base URL
  const BASE_URL = 'http://localhost:8500/DCM'; 
  const USERNAME = 'testuser'; // Replace with a valid test username
  const PASSWORD = 'testpassword'; // Replace with a valid test password

  test('should allow a user to log in successfully', async ({ page }) => {
    await page.goto(`${BASE_URL}/index.html`);

    // Expect a title "to contain" a substring.
    await expect(page).toHaveTitle(/Daily Time Tracking/);

    // Click the login button
    await page.click('#loginBtn'); 

    // Fill in login credentials
    await page.fill('#username', USERNAME);
    await page.fill('#password', PASSWORD);

    // Click the submit button
    await page.click('#loginSubmit');

    // Expect to be redirected to the main application page or a dashboard.
    // Replace with an element or URL that indicates successful login.
    await expect(page).toHaveURL(`${BASE_URL}/index.html`); // Assuming successful login redirects to index.html
    await expect(page.locator('#welcomeMessage')).toContainText(`Welcome, ${USERNAME}`); // Example: check for a welcome message
  });

  test('should display session timeout warning and allow staying logged in', async ({ page }) => {
    // Log in first to establish a session
    await page.goto(`${BASE_URL}/index.html`);
    await page.click('#loginBtn'); 
    await page.fill('#username', USERNAME);
    await page.fill('#password', PASSWORD);
    await page.click('#loginSubmit');
    await expect(page).toHaveURL(`${BASE_URL}/index.html`);

    // Manipulate time to trigger the session timeout warning quickly
    // This is a simplification; in a real scenario, you'd configure shorter timeouts for testing
    // or use Playwright's clock mocking capabilities if your application relies on client-side time.
    // For now, we'll wait for the configured timeout if it's short enough.
    // Assuming session timeout warning appears after 28 minutes (1680000 ms) as per session-management.js
    // For testing, you might reduce this server-side or mock it.
    console.log('Waiting for session timeout warning modal to appear...');
    // Replace with a realistic wait time or better yet, mock the server time or reduce session timeout for testing.
    await page.waitForTimeout(10000); // Wait for 10 seconds for the modal to appear (adjust as needed)

    // Expect the session timeout modal to be visible
    await expect(page.locator('#sessionTimeoutModal')).toBeVisible();
    await expect(page.locator('#sessionTimeoutModalLabel')).toContainText('Session Timeout Warning');

    // Click "Stay Logged In"
    await page.click('#stayLoggedInButton');

    // Expect the modal to be hidden and session to be active
    await expect(page.locator('#sessionTimeoutModal')).toBeHidden();
    // Verify that some element on the page still indicates an active session or user is logged in
    await expect(page.locator('#welcomeMessage')).toContainText(`Welcome, ${USERNAME}`); // Example check
  });

  test('should log out user automatically if no response to timeout warning', async ({ page }) => {
    // Log in first to establish a session
    await page.goto(`${BASE_URL}/index.html`);
    await page.click('#loginBtn'); 
    await page.fill('#username', USERNAME);
    await page.fill('#password', PASSWORD);
    await page.click('#loginSubmit');
    await expect(page).toHaveURL(`${BASE_URL}/index.html`);

    // Wait for the session timeout warning to appear
    console.log('Waiting for session timeout warning modal to appear...');
    await page.waitForTimeout(10000); // Adjust wait time

    // Expect the session timeout modal to be visible
    await expect(page.locator('#sessionTimeoutModal')).toBeVisible();

    // Do not interact with the modal, let it time out
    // The session-management.js code has a 2-minute countdown for the modal.
    console.log('Allowing session timeout modal to expire...');
    await page.waitForTimeout(125000); // Wait a bit longer than 2 minutes (120 seconds) for logout to occur

    // Expect to be redirected to the landing page after automatic logout
    await expect(page).toHaveURL(`${BASE_URL}/landingPage.html`);
    // Optionally, check for a login form or absence of user-specific elements
    await expect(page.locator('#loginForm')).toBeVisible(); // Example: check for login form visibility
  });

  test('should allow a user to manually log out', async ({ page }) => {
    // Log in first
    await page.goto(`${BASE_URL}/index.html`);
    await page.click('#loginBtn'); 
    await page.fill('#username', USERNAME);
    await page.fill('#password', PASSWORD);
    await page.click('#loginSubmit');
    await expect(page).toHaveURL(`${BASE_URL}/index.html`);

    // Click the manual logout button
    await page.click('#signOut');

    // Expect to be redirected to the landing page
    await expect(page).toHaveURL(`${BASE_URL}/landingPage.html`);
    await expect(page.locator('#loginForm')).toBeVisible();
  });
});
