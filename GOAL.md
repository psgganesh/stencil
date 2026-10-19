# GOAL

Creating a multi-device, cross platform flutter boilterplate. It's a flutter app, that works across web, macos desktop, windows desktop, ios, android.

# Features

Features can be classified into 2 categories. Features which can be completed built using agentic ai and automation. Features which needs manual intervention (like creating apple developer or google play certs and updating).

## Design

Flutter app only uses material ui for the design. You can follow the DESIGN.md which is already prepared for this app to be used.

## Features built using agentic ai and automation

### Web

#### Top bar / App bar links

[] Home page
[] Features page
[] What's new page
[] About Us page
[] Articles page (blog)

#### Footer links

##### Our App

[] Login
[] Create Account
[] Main app itself
[] Permium
[] Reviews
[] Press

##### Resources

[] Support & FAQ
[] Terms & Conditions page
[] Privacy Policy page
[] Changelog

##### Connect

[] YouTube page link
[] Instagram page link
[] TickTok link
[] Twitter link
[] Contact Us

##### Downloads

[] iOS App
[] Android App
[] macOS App
[] Windows App

## Desktop and Mobile app

[] Login
[] Create Account
[] Main app itself

## Main app Build

- App will have below routes
  The app uses Flutter's built-in `MaterialApp` named routes rather than a routing package.

| Route          | Destination                    |
| -------------- | ------------------------------ |
| `/login`       | Login mode                     |
| `/signup`      | Signup mode                    |
| `/onboarding`  | Authenticated onboarding guard |
| `/app`         | Authenticated app guard        |
| `/privacy`     | Privacy page                   |
| `/delete-data` | Data deletion page             |
| `/support`     | Support page                   |
| `/terms`       | Terms page                     |

- App should use clean MVVM architecture pattern
- Only Riverpod for global and screen level and widget level state management
- Firebase firestore for data persistence on server
- Firebase auth for Email and Google and Apple authentication - UNTIL necessary certs and manual steps are completed, it can just be a mock login and mock authentication
- Build all the initial app screens as per designs presented for each device at .refs/design - focus only on the onboarding and web screens first (only the screens which are shared on that folder)

## Main app Deployment using GitHub actions CI/CD

Look at the example at .refs/.github/workflows/main.yml. I need a GitHub action like this, also the agent can create empty string GitHub secrets for all secrets which is needed to get the GitHub action working. I will fill the values manually later.

## Features built using agentic ai and manual human intervention

[] Downloading certificates and keys and service-json files from Apple and Google
[] Creating entitlements, products, stores on RevenueCat
