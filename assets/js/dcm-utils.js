/**
 * DCM Utilities - Enterprise UI Components
 * Toast notifications, loading states, error handling, keyboard shortcuts
 */

// ===== Toast Notification System =====
class ToastManager {
    static container = null;

    static init() {
        if (!this.container) {
            this.container = $(`
                <div aria-live="polite" aria-atomic="true"
                     class="position-fixed top-0 end-0 p-3"
                     style="z-index: var(--dcm-z-toast, 1080);">
                    <div id="dcm-toast-container"></div>
                </div>
            `);
            $('body').append(this.container);
        }
    }

    static show(message, type = 'info', duration = 5000) {
        this.init();

        const id = 'toast-' + Date.now();
        const icons = {
            success: 'fa-check-circle',
            error: 'fa-exclamation-circle',
            warning: 'fa-exclamation-triangle',
            info: 'fa-info-circle'
        };

        const bgColors = {
            success: 'bg-success',
            error: 'bg-danger',
            warning: 'bg-warning text-dark',
            info: 'bg-info'
        };

        const toast = $(`
            <div id="${id}" class="toast align-items-center text-white ${bgColors[type]} border-0 mb-2"
                 role="alert" aria-live="assertive" aria-atomic="true">
                <div class="d-flex">
                    <div class="toast-body">
                        <i class="fas ${icons[type]} me-2"></i>${message}
                    </div>
                    <button type="button" class="btn-close btn-close-white me-2 m-auto"
                            data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
            </div>
        `);

        $('#dcm-toast-container').append(toast);
        const bsToast = new bootstrap.Toast(toast[0], { delay: duration });
        bsToast.show();

        toast.on('hidden.bs.toast', () => toast.remove());

        return id;
    }

    static success(message, duration = 4000) {
        return this.show(message, 'success', duration);
    }

    static error(message, duration = 6000) {
        return this.show(message, 'error', duration);
    }

    static warning(message, duration = 5000) {
        return this.show(message, 'warning', duration);
    }

    static info(message, duration = 5000) {
        return this.show(message, 'info', duration);
    }
}

// ===== Loading State Manager =====
class LoadingManager {
    static show(element, message = 'Loading...') {
        const $el = $(element);
        $el.addClass('dcm-loading-overlay position-relative');
        $el.append(`
            <div class="dcm-spinner-overlay position-absolute top-0 start-0 w-100 h-100 d-flex flex-column align-items-center justify-content-center"
                 style="background: rgba(255,255,255,0.9); z-index: 100;">
                <div class="spinner-border text-primary mb-2" role="status">
                    <span class="visually-hidden">${message}</span>
                </div>
                <p class="text-muted mb-0">${message}</p>
            </div>
        `);
    }

    static hide(element) {
        $(element).removeClass('dcm-loading-overlay').find('.dcm-spinner-overlay').remove();
    }

    static button(button, loading = true) {
        const $btn = $(button);
        if (loading) {
            $btn.data('original-text', $btn.html());
            $btn.prop('disabled', true);
            $btn.html(`
                <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
                Loading...
            `);
        } else {
            $btn.prop('disabled', false);
            $btn.html($btn.data('original-text'));
        }
    }
}

// ===== Error Handler =====
class ErrorHandler {
    static handle(error, context = {}) {
        console.error('Error:', error, 'Context:', context);

        const userMessage = this.getUserMessage(error);
        const suggestions = this.getSuggestions(error, context);

        if (context.silent) {
            ToastManager.error(userMessage);
            return;
        }

        Swal.fire({
            icon: 'error',
            title: 'Something went wrong',
            html: `
                <p>${userMessage}</p>
                ${suggestions ? `<div class="alert alert-info mt-3 text-start"><i class="fas fa-lightbulb me-2"></i>${suggestions}</div>` : ''}
            `,
            footer: context.showSupport ?
                '<a href="mailto:support@mdanderson.org">Contact Support</a>' : null,
            confirmButtonColor: 'var(--dcm-primary, #0066cc)'
        });
    }

    static getUserMessage(error) {
        if (typeof error === 'string') return error;

        const messages = {
            'NetworkError': 'Unable to connect to server. Please check your internet connection.',
            'Timeout': 'Request timed out. The server might be busy, please try again.',
            'Unauthorized': 'Your session has expired. Please log in again.',
            'ValidationError': 'Please check your input and try again.',
            'NotFound': 'The requested resource was not found.',
            'ServerError': 'Server error occurred. Our team has been notified.',
            401: 'Your session has expired. Please log in again.',
            403: 'You do not have permission to perform this action.',
            404: 'The requested resource was not found.',
            500: 'Server error occurred. Please try again later.'
        };

        if (error.status) return messages[error.status] || messages['ServerError'];
        if (error.name) return messages[error.name] || messages['ServerError'];

        return 'An unexpected error occurred.';
    }

    static getSuggestions(error, context) {
        if (error.status === 401 || error.name === 'Unauthorized') {
            return 'Click OK to return to the login page.';
        }
        if (error.name === 'NetworkError') {
            return 'Try refreshing the page or check your network settings.';
        }
        if (error.name === 'Timeout' && context.operation === 'save') {
            return 'Your data may have been saved. Please refresh to verify.';
        }
        return null;
    }

    static fromAjax(xhr, status, errorText) {
        return {
            status: xhr.status,
            statusText: xhr.statusText,
            message: errorText,
            response: xhr.responseText
        };
    }
}

// ===== Keyboard Shortcuts =====
class KeyboardShortcuts {
    constructor() {
        this.shortcuts = {};
        this.enabled = true;
        this.init();
    }

    init() {
        $(document).on('keydown', (e) => {
            if (!this.enabled) return;

            // Ignore if typing in input/textarea
            if ($(e.target).is('input, textarea, select, [contenteditable="true"]')) {
                // Allow Escape key in inputs
                if (e.key !== 'Escape') return;
            }

            const key = this.getKeyString(e);
            const handler = this.shortcuts[key];

            if (handler) {
                e.preventDefault();
                handler.callback();
            }
        });
    }

    getKeyString(e) {
        let key = '';
        if (e.ctrlKey || e.metaKey) key += 'ctrl+';
        if (e.altKey) key += 'alt+';
        if (e.shiftKey) key += 'shift+';
        key += e.key.toLowerCase();
        return key;
    }

    register(keyCombo, description, callback) {
        this.shortcuts[keyCombo.toLowerCase()] = { description, callback };
    }

    unregister(keyCombo) {
        delete this.shortcuts[keyCombo.toLowerCase()];
    }

    showHelp() {
        let html = '<table class="table table-sm text-start mb-0">';
        html += '<thead><tr><th>Shortcut</th><th>Action</th></tr></thead><tbody>';

        Object.entries(this.shortcuts).forEach(([key, { description }]) => {
            const displayKey = key.split('+').map(k => `<kbd>${k}</kbd>`).join(' + ');
            html += `<tr><td>${displayKey}</td><td>${description}</td></tr>`;
        });

        html += '</tbody></table>';

        Swal.fire({
            title: '<i class="fas fa-keyboard me-2"></i>Keyboard Shortcuts',
            html: html,
            width: 500,
            confirmButtonText: 'Got it!',
            confirmButtonColor: 'var(--dcm-primary, #0066cc)'
        });
    }
}

// ===== Debounce Utility =====
function debounce(func, wait, immediate = false) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            timeout = null;
            if (!immediate) func.apply(this, args);
        };
        const callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
        if (callNow) func.apply(this, args);
    };
}

// ===== Throttle Utility =====
function throttle(func, limit) {
    let inThrottle;
    return function executedFunction(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// ===== Screen Reader Announcer =====
class ScreenReaderAnnouncer {
    static container = null;

    static init() {
        if (!this.container) {
            this.container = $(`
                <div id="dcm-sr-announcer"
                     aria-live="polite"
                     aria-atomic="true"
                     class="visually-hidden"></div>
            `);
            $('body').append(this.container);
        }
    }

    static announce(message, priority = 'polite') {
        this.init();
        this.container.attr('aria-live', priority);
        this.container.text(message);

        // Clear after announcement
        setTimeout(() => this.container.empty(), 1000);
    }

    static assertive(message) {
        this.announce(message, 'assertive');
    }
}

// ===== Form Validator =====
class FormValidator {
    constructor(formSelector) {
        this.$form = $(formSelector);
        this.rules = {};
        this.init();
    }

    init() {
        this.$form.on('submit', (e) => {
            if (!this.validate()) {
                e.preventDefault();
                ScreenReaderAnnouncer.assertive('Form has errors. Please correct them before submitting.');
            }
        });

        // Real-time validation on blur
        this.$form.find('input, textarea, select').on('blur', (e) => {
            this.validateField($(e.target));
        });
    }

    addRule(fieldName, rule, message) {
        if (!this.rules[fieldName]) this.rules[fieldName] = [];
        this.rules[fieldName].push({ rule, message });
    }

    validateField($field) {
        const name = $field.attr('name') || $field.attr('id');
        const rules = this.rules[name];

        if (!rules) return true;

        $field.removeClass('is-invalid is-valid');
        $field.siblings('.invalid-feedback').remove();

        for (const { rule, message } of rules) {
            if (!rule($field.val(), $field)) {
                $field.addClass('is-invalid');
                $field.after(`<div class="invalid-feedback d-block">${message}</div>`);
                return false;
            }
        }

        $field.addClass('is-valid');
        return true;
    }

    validate() {
        let isValid = true;

        Object.keys(this.rules).forEach(fieldName => {
            const $field = this.$form.find(`[name="${fieldName}"], #${fieldName}`);
            if ($field.length && !this.validateField($field)) {
                isValid = false;
            }
        });

        return isValid;
    }

    // Common validation rules
    static rules = {
        required: (value) => value && value.trim().length > 0,
        email: (value) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value),
        minLength: (min) => (value) => value.length >= min,
        maxLength: (max) => (value) => value.length <= max,
        numeric: (value) => /^\d+$/.test(value),
        pattern: (regex) => (value) => regex.test(value)
    };
}

// ===== Initialize Global Instances =====
const dcmShortcuts = new KeyboardShortcuts();

// Register common shortcuts
dcmShortcuts.register('ctrl+s', 'Save current form', () => {
    const $saveBtn = $('button[type="submit"]:visible, #saveTask:visible').first();
    if ($saveBtn.length) $saveBtn.click();
});

dcmShortcuts.register('ctrl+/', 'Show keyboard shortcuts', () => {
    dcmShortcuts.showHelp();
});

dcmShortcuts.register('escape', 'Close modal/dropdown', () => {
    $('.modal.show').modal('hide');
    $('.dropdown-menu.show').dropdown('hide');
    $('#deptResults').hide();
});

// Export for global use
window.ToastManager = ToastManager;
window.LoadingManager = LoadingManager;
window.ErrorHandler = ErrorHandler;
window.KeyboardShortcuts = KeyboardShortcuts;
window.dcmShortcuts = dcmShortcuts;
window.ScreenReaderAnnouncer = ScreenReaderAnnouncer;
window.FormValidator = FormValidator;
window.debounce = debounce;
window.throttle = throttle;

// Show shortcut hint on first load
$(document).ready(() => {
    setTimeout(() => {
        if (!sessionStorage.getItem('shortcutHintShown')) {
            ToastManager.info('Press Ctrl+/ to see keyboard shortcuts', 5000);
            sessionStorage.setItem('shortcutHintShown', 'true');
        }
    }, 3000);
});
