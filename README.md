# :book: Read and Learn

#### An online reading app for children.

### :fire: Features

| :zap: Admin Panel                             | :zap: Teacher Panel                  | :zap: Parent Panel                      |
|-----------------------------------------------|--------------------------------------|-----------------------------------------|
| :white_check_mark: Manage Classrooms          | :white_check_mark: Manage Classrooms | :white_check_mark: Join/Leave Classroom |
| :white_check_mark: Manage Admins              | :white_check_mark: Manage Stories    | :white_check_mark: Manage User Progress |
| :white_check_mark: Manage Stories             | :white_check_mark: Manage Members    | :white_check_mark: Manage Account       |
| :white_check_mark: Manage Teachers            | :white_check_mark: Manage Account    |
| :white_check_mark: Manage Parents             |
| :white_check_mark: View Certificate holders   |
| :white_check_mark: Manage Account             |

---

### :fire: Main Features
- :white_check_mark: Compute reader's WPM programmatically using Speech to Text
- :white_check_mark: Generate certificate programmatically
- :white_check_mark: Analyze reader's accuracy of pronounciation programmatically

---
### :hammer: Setup
- [x] First, create a new project in [Firebase Console](https://console.firebase.com/).
- [x] Download `google-services.json` and put it in `android/app/` folder.

#### :lock: Authentication
- [x] Go to **Authentication** tab of your firebase.
- [x] Click **Sign-in Method** tab.
- [x] Click **Add new provider**.
- [x] Enable **Google**.
![Enable Googlle](./screenshots/google_enable.png)

#### :lock: Setup Hashes
- [x] Go to **Project Settings**.
- [x] Scroll down and add your **sha-1** and **sha-256** hashes.
![App Hashes](./screenshots/app_hashes.png)

#### :lock: Firestore Database
- [x] Go to Firestore Database tab of your firebase.
- [x] Go to **Rules** tab
- [x] Add the following rules into your own.
![Rules](./screenshots/database_rules.png)
- [x] Next, go to **Indexes** tab.
- [x] Then create the following indexes.
![Indexes](./screenshots/database_index.png)

---

### :computer: Techs Used
![Flutter](https://img.icons8.com/color/30/flutter.png)
![Firebase](https://img.icons8.com/color/30/4a90e2/firebase.png)

##### Database: Firebase DB
##### Application Framework: Flutter
---