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
        // Sign Out — only bind here on non-index pages; index.html uses delegated jQuery handler
        if (this.currentPage !== 'index.html') {
            const signOutBtn = document.getElementById('signOut');
            if (signOutBtn) {
                signOutBtn.addEventListener('click', (e) => {
                    e.preventDefault();
                    this.handleSignOut();
                });
            }
        }

        // Profile button — only relevant on index.html (modal lives there)
        // On other pages, let the href="#" default prevent navigation without error
        const profileBtns = document.querySelectorAll('#profileSettingsBtn, #profileSettingsBtnLg');
        profileBtns.forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.preventDefault();
                const modal = document.getElementById('profileSettingsModal');
                if (modal && typeof bootstrap !== 'undefined') {
                    bootstrap.Modal.getOrCreateInstance(modal).show();
                }
            });
        });
    }

    initializeSessionComponents() {
        // Only initialize session timer on pages that need it
        const pagesWithSession = ['index.html', 'projectManagement.html', 'userManagement.html'];
        
        if (pagesWithSession.includes(this.currentPage)) {
            // Check if user is logged in
            const isLoggedIn = sessionStorage.getItem('ISLOGGEDIN');
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
        if (typeof $ !== 'undefined') {
            const container = document.querySelector('.container') || document.body;
            $(container).load('signout.html');
        } else {
            sessionStorage.clear();
            window.location.href = 'landingPage.html';
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