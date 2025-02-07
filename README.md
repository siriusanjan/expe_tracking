# expe_traking

A new Flutter project.

## Getting Started


 Project Setup & Authentication
🔲 Set up Flutter project and configure Firebase 
🔲 Implement role-based authentication (Admin, Manager, Employee).
🔲 Create predefined accounts for each role.
🔲 Set up navigation for role-based routing.




 
Expense Management & Offline Mode
🔲 Implement expense creation for Employees (title, description, amount, receipt upload). (receipt can't be uploaded due to firebase storage limitation for free)
🔲 Store expenses locally using sqflite for offline support.
🔲 Sync offline data to the server when reconnected. (not done)




 Expense Approval & Dashboard
🔲 Implement Managers’ ability to approve/reject expenses.
🔲 Admin can view all expenses with filtering options (user, date, status).
🔲 Create graphical dashboard views for each role. (normal one)



Notifications & Enhancements (Notification is limited  for firebase in IOS due to APNs system which required app connect account)
🔲 Implement push notifications using Firebase
🔲 Employees get notified on approval/rejection.
🔲 Managers get notified on new submissions.
🔲 Implement expense pagination and search filtering.





 Testing & Documentation
🔲 Write unit tests for expense management.(not done)
🔲 Refactor code to follow clean architecture (data, domain, presentation layers).
🔲 Write README with setup instructions and explanations.
🔲 Final testing on Android & iOS. 
🔲 Upload project to GitHub and submit.


