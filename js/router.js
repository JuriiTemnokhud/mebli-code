// SPA Router for Furniture Website
// Handles navigation and dynamic content loading

(function () {
    'use strict';

    // Route definitions
    const routes = {
        '': 'pages/home.html',
        'home': 'pages/home.html',
        'about': 'pages/about.html',
        'calculator': 'pages/calculator.html',
        'services': 'pages/services.html'
    };

    // Content container
    const contentContainer = document.getElementById('app-content');

    // Loading indicator
    function showLoading() {
        if (contentContainer) {
            contentContainer.innerHTML = '<div class="loading-spinner" style="text-align: center; padding: 3rem;"><p>Завантаження...</p></div>';
        }
    }

    // Load page content
    async function loadPage(pageName) {
        const route = routes[pageName] || routes['home'];

        showLoading();

        try {
            const response = await fetch(route);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const html = await response.text();

            if (contentContainer) {
                // Wrap loaded HTML in container with glass effect so "підложки" (backdrops) apply consistently
                contentContainer.innerHTML = `<div class="container content">${html}</div>`;

                // Execute any inline scripts included in the loaded fragment so page behaviors initialize
                const scripts = contentContainer.querySelectorAll('script');
                scripts.forEach(oldScript => {
                    const newScript = document.createElement('script');
                    if (oldScript.src) {
                        // External script
                        newScript.src = oldScript.src;
                        newScript.async = false;
                    } else {
                        // Inline script
                        newScript.textContent = oldScript.textContent;
                    }
                    document.head.appendChild(newScript);
                    // remove the old script node from the fragment to avoid duplicates
                    oldScript.parentNode && oldScript.parentNode.removeChild(oldScript);
                });

                // If page provides an immediate init function (e.g., updateVisualization for calculator), call it
                try {
                    if (typeof window.updateVisualization === 'function') {
                        window.updateVisualization();
                    }
                } catch (e) {
                    console.error('Error calling updateVisualization:', e);
                }

                try {
                    if (typeof window.initializeCalculator === 'function') {
                        window.initializeCalculator();
                    }
                } catch (e) {
                    console.error('Error calling initializeCalculator:', e);
                }

                // Scroll to top
                window.scrollTo({ top: 0, behavior: 'smooth' });

                // Re-initialize any scripts that need to run on the new content
                initializePageScripts(pageName);

                // Update active nav link
                updateActiveNavLink(pageName);
            }
        } catch (error) {
            console.error('Error loading page:', error);
            if (contentContainer) {
                contentContainer.innerHTML = `
                    <div style="text-align: center; padding: 3rem;">
                        <h2>Помилка завантаження</h2>
                        <p>Не вдалося завантажити сторінку. Спробуйте ще раз.</p>
                        <button onclick="location.reload()" class="cta-button">Оновити</button>
                    </div>
                `;
            }
        }
    }

    // Initialize page-specific scripts
    function initializePageScripts(pageName) {
        switch (pageName) {
            case 'home':
                // Re-initialize portfolio gallery listeners
                if (window.initializeGalleries) {
                    window.initializeGalleries();
                }
                // Re-initialize reviews carousel
                if (window.initializeReviewsCarousel) {
                    window.initializeReviewsCarousel();
                }
                // If a pending contact message exists (from calculator), populate the contact form
                try {
                    if (typeof window.handlePendingContactMessage === 'function') {
                        window.handlePendingContactMessage();
                    }
                } catch (e) {
                    console.error('Error handling pending contact message:', e);
                }
                break;
            case 'calculator':
                // Calculator will have its own initialization
                if (window.initializeCalculator) {
                    window.initializeCalculator();
                }
                break;
        }
    }

    // Update active navigation link
    function updateActiveNavLink(pageName) {
        // Remove active class from all nav links
        document.querySelectorAll('.nav-links a').forEach(link => {
            link.classList.remove('active');
        });

        // Add active class to current page link
        const currentLink = document.querySelector(`.nav-links a[data-route="${pageName}"]`);
        if (currentLink) {
            currentLink.classList.add('active');
        }
    }

    // Handle navigation
    function navigate(pageName) {
        // Update URL hash
        window.location.hash = pageName || 'home';
    }

    // Handle hash change
    function handleHashChange() {
        const hash = window.location.hash.slice(1); // Remove #
        const pageName = hash || 'home';
        loadPage(pageName);
    }

    // Initialize router
    function init() {
        // Handle hash changes
        window.addEventListener('hashchange', handleHashChange);

        // Handle navigation link clicks
        document.addEventListener('click', function (e) {
            const link = e.target.closest('a[data-route]');
            if (link) {
                e.preventDefault();
                const route = link.getAttribute('data-route');
                navigate(route);
            }
        });

        // Load initial page
        handleHashChange();
    }

    // Export router functions
    window.router = {
        navigate: navigate,
        init: init
    };

    // Auto-initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
