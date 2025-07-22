/**
 * DCM Navigation Component
 * Handles standardized navigation across all pages
 */

class DCMNavbar {
    constructor() {
        this.currentPage = this.getCurrentPageName();
        this.init();
    }

    getCurrentPageName() {
        const path = window.location.pathname;
        const page = path.substring(path.lastIndexOf('/') + 1);
        return page || 'index.html';
    }

    async init() {
        await this.loadNavbar();
        this.setPageTitle();
        this.setActiveNavItem();
        this.bindEvents();
        this.initializeSessionComponents();
    }

    async loadNavbar() {
        try {
            const response = await fetch('assets/includes/navbar.html');
            const navbarHTML = await response.text();
            
            // Insert navbar at the beginning of body or replace existing nav
            const existingNav = document.querySelector('nav.navbar');
            if (existingNav) {
                existingNav.outerHTML = navbarHTML;
            } else {
                document.body.insertAdjacentHTML('afterbegin', navbarHTML);
            }
        } catch (error) {
            console.error('Error loading navbar:', error);
        }
    }

    setPageTitle() {
        const titleElement = document.getElementById('pageTitle');
        const titles = {
            'index.html': 'Daily Time Tracking',
            'projectManagement.html': 'Project Management',
            'userManagement.html': 'User Management',
            'landingPage.html': 'Login'
        };

        if (titleElement) {
            titleElement.textContent = titles[this.currentPage] || 'Daily Time Tracking';
        }
    }

    setActiveNavItem() {
        // Remove any existing active classes
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.remove('active-page');
        });

        // Add active class based on current page
        const activeMap = {
            'index.html': '#mgtHome',
            'projectManagement.html': '#mgtProjects', 
            'userManagement.html': '#mgtUserAccess'
        };

        const activeSelector = activeMap[this.currentPage];
        if (activeSelector) {
            const activeLink = document.querySelector(activeSelector);
            if (activeLink) {
                activeLink.classList.add('active-page');
                activeLink.style.backgroundColor = 'rgba(255,255,255,0.2)';
                activeLink.style.borderRadius = '8px';
            }
        }
    }

    bindEvents() {
        // Home navigation
        const homeLink = document.getElementById('mgtHome');
        if (homeLink) {
            homeLink.addEventListener('click', (e) => {
                e.preventDefault();
                window.location.href = 'index.html';
            });
        }

        // Projects navigation
        const projectsLink = document.getElementById('mgtProjects');
        if (projectsLink) {
            projectsLink.addEventListener('click', (e) => {
                e.preventDefault();
                window.location.href = 'projectManagement.html';
            });
        }

        // User Access navigation
        const userAccessLink = document.getElementById('mgtUserAccess');
        if (userAccessLink) {
            userAccessLink.addEventListener('click', (e) => {
                e.preventDefault();
                window.location.href = 'userManagement.html';
            });
        }

        // Sign Out
        const signOutBtn = document.getElementById('signOut');
        if (signOutBtn) {
            signOutBtn.addEventListener('click', (e) => {
                e.preventDefault();
                this.handleSignOut();
            });
        }
    }

    initializeSessionComponents() {
        // Only initialize session timer on pages that need it
        const pagesWithSession = ['index.html', 'projectManagement.html', 'userManagement.html'];
        
        if (pagesWithSession.includes(this.currentPage)) {
            // Check if user is logged in
            const isLoggedIn = sessionStorage.getItem('ISLOGGINEDIN');
            const emplid = sessionStorage.getItem('EMPLID');
            
            if (!isLoggedIn || isLoggedIn === '0') {
                window.location.href = 'landingPage.html';
                return;
            }

            // Start session timer if functions exist
            if (typeof startSessionTimer === 'function') {
                startSessionTimer();
            }
            if (typeof displaySessionTimeLeft === 'function') {
                displaySessionTimeLeft();
            }
        }
    }

    handleSignOut() {
        // Use existing signout functionality or create new
        if (typeof signOut === 'function') {
            signOut();
        } else {
            // Load signout page content
            const container = document.querySelector('.container') || document.body;
            container.innerHTML = '<div class="text-center mt-5"><h2>Signing out...</h2></div>';
            
            // Clear session storage
            sessionStorage.clear();
            
            // Redirect after brief delay
            setTimeout(() => {
                window.location.href = 'landingPage.html';
            }, 1500);
        }
    }

    // Method to update session timer display
    updateSessionTimer(timeLeft) {
        const timerElement = document.getElementById('timeLeftNavBar');
        if (timerElement && timeLeft) {
            timerElement.textContent = timeLeft;
        }
    }

    // Method to show/hide admin features
    toggleAdminFeatures(isAdmin) {
        const adminElements = document.querySelectorAll('[data-admin-only]');
        adminElements.forEach(element => {
            element.style.display = isAdmin ? 'block' : 'none';
        });
    }
}

// Initialize navbar when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.dcmNavbar = new DCMNavbar();
});

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = DCMNavbar;
}