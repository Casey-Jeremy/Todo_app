# Developer Challenge Submission: To-Do App

This is a complete, full-stack application built for the developer challenge. It features a polished Flutter mobile app for users and a professional Next.js admin panel, all powered by a Firebase backend.

## ✨ Customizations & Enhancements
To demonstrate a commitment to high-quality UX and design, several features were added beyond the basic requirements:

* **Custom App Icon & Theming:** The app has a unique launcher icon and a consistent, modern color scheme and font.
* **Intuitive UX:** Includes "Swipe to Delete," success feedback messages, and a helpful hint for new features.
* **New User Onboarding:** A multi-step carousel dialog welcomes new users and explains key features.
* **Dynamic UI:** The app bar intelligently displays a real-time count of completed tasks.
* **Professional Admin Panel:** The admin dashboard was redesigned with a modern, responsive layout, stat cards, and a user search function.

## Features

### Flutter App (for users)
-   User sign-up and login with Firebase Authentication.
-   A welcome/onboarding carousel for new users.
-   View, add, update (mark as complete), and delete personal to-do items.
-   Intuitive "Swipe to Delete" gesture.
-   Real-time data synchronization with Firestore.

### Next.js Admin Panel
-   Secure admin login with a professional UI.
-   Dashboard with summary statistic cards.
-   View a list of all registered users by email.
-   Search/filter users by email.
-   Select a user to view and manage (delete) their to-do list in real-time.

## Tech Stack

-   **Mobile App:** Flutter, `flutter_slidable`, `smooth_page_indicator`
-   **Admin Panel:** Next.js, React, CSS Modules
-   **Backend:** Firebase (Authentication & Firestore Database)

## How to Run

### Flutter App (`todo_app`)
1.  Navigate to the `todo_app` directory: `cd todo_app`
2.  Install dependencies: `flutter pub get`
3.  Run the app: `flutter run`

### Admin Panel (`admin_panel`)
1.  Navigate to the `admin_panel` directory: `cd admin_panel`
2.  Install dependencies: `npm install`
3.  Run the development server: `npm run dev`
4.  Open `http://localhost:3000` in your browser.

**Admin Credentials:**
-   **Email:** `admin@example.com`
-   **Password:** `password123`
