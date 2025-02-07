# Expe_Tracking

A new Flutter project for managing expenses with role-based authentication and offline support.
### No backend and cloud storage so I have use glclinet to setup notification so access token may expires and need to be refresh by me set it to remote config to refresh

## Getting Started

### Project Setup & Authentication
- 🔲 Set up Flutter project and configure Firebase
- 🔲 Implement role-based authentication (Admin, Manager, Employee)
- 🔲 Create predefined accounts for each role
- 🔲 Set up navigation for role-based routing

### Expense Management & Offline Mode
- 🔲 Implement expense creation for Employees (title, description, amount, receipt upload)  
  _(Note: receipt upload is limited due to Firebase storage restrictions on the free tier)_
- 🔲 Store expenses locally using `sqflite` for offline support
- 🔲 Sync offline data to the server when reconnected _(Not done)_

### Expense Approval & Dashboard
- 🔲 Implement Managers’ ability to approve/reject expenses
- 🔲 Admin can view all expenses with filtering options (user, date, status)
- 🔲 Create graphical dashboard views for each role _(Currently normal view)_

### Notifications & Enhancements
- 🔲 Implement push notifications using Firebase  
  _(Note: iOS notifications are limited due to APNs system requiring an Apple Developer account)_
- 🔲 Employees get notified on approval/rejection
- 🔲 Managers get notified on new submissions
- 🔲 Implement expense pagination and search filtering

### Testing & Documentation
- 🔲 Write unit tests for expense management _(Not done)_
- 🔲 Refactor code to follow clean architecture (data, domain, presentation layers)
- 🔲 Write README with setup instructions and explanations
- 🔲 Final testing on Android & iOS
- 🔲 Upload project to GitHub and submit

## Requirements

- Flutter SDK
- Firebase setup (Authentication, Firestore, Firebase Messaging)
- sqflite for local database storage
- Firebase Cloud Storage (if needed for receipt upload)

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/siriusanjan/expe_traking.git
    ```
2. Navigate to the project folder:
    ```bash
    cd expe_traking
    ```
3. Install dependencies:
    ```bash
    flutter pub get
    ```

4. Set up Firebase for your project as described in the [Firebase documentation](https://firebase.flutter.dev/docs/overview).

5. Run the project:
    ```bash
    flutter run
    ```

## Contributing

Feel free to fork this project and make improvements. Open a pull request with any suggestions or bug fixes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

