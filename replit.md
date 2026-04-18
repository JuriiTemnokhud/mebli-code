# Furniture Maker Portfolio Website

## Overview
A professional portfolio and business website for a furniture maker (Ukrainian market). Showcases custom furniture projects (kitchens, wardrobes, bathrooms, etc.) and provides an interactive cost calculator for customers.

## Tech Stack
- **Frontend:** Pure HTML5, CSS3, Vanilla JavaScript (no build system)
- **Architecture:** SPA with a custom hash-based router (`js/router.js`)
- **Styling:** Custom CSS with glassmorphism effects, Flexbox/Grid
- **External libraries (CDN):** Font Awesome 6.4.0, Google Fonts (Montserrat, Marck Script)
- **Form handling:** FormSubmit (no backend required)

## Project Structure
```
/
├── index.html            # Main SPA shell / entry point
├── pages/                # SPA page fragments loaded dynamically
│   ├── home.html
│   ├── about.html
│   ├── calculator.html
│   └── services.html
├── js/
│   ├── router.js         # Hash-based SPA router
│   └── script.js         # UI logic (galleries, modals, carousel)
├── css/
│   └── style.css         # Main stylesheet
├── images/               # Portfolio images and logos
├── assets/               # SVG backgrounds and design assets
└── scripts/              # Python/PowerShell automation scripts
```

## Running the App
The site is served using Python's built-in HTTP server:
```
python3 -m http.server 5000 --bind 0.0.0.0
```
Configured as the "Start application" workflow on port 5000.

## Deployment
Configured as a **static** deployment with `publicDir: "."` (root directory).

## Notes
- Language: Ukrainian (uk)
- Currency: UAH (₴)
- No backend — contact form uses FormSubmit service
- 3D constructor integrates external tool via iframe (planplace.kz)
