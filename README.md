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
- :white_check_mark: Compute reader's WPM using android's built-in Speech Recognizer
- :white_check_mark: Generate certificate from the app
- :white_check_mark: Analyze reader's accuracy of pronounciation using android's built-in Speech Recognizer
- :white_check_mark: Demonstration of the word's pronounciation when the word is clicked

---

### :warning: Notice

- :white_check_mark: This app heavily relies on android devices' built-in **Speech Recognizer** and is a very **crucial requirement** for this app to run properly.

- :white_check_mark: This app currently does not support Offline Mode

---

### :camera: Screenshots

### :door: Welcome Panel
| **Home Panel** | **Login Panel** | **Register Panel** |
|----------------|-----------------|--------------------|
| ![s1](./screenshots/welcome/1.png) | ![s5](./screenshots/welcome/2.png) | ![s6](./screenshots/welcome/3.png) |

### :door: Admin Panel

| **Admins List** | **Teachers List** | **Parents List** |
|-------------|-----------------|---------------|
| ![s1](./screenshots/admin/1.png) | ![s5](./screenshots/admin/5.png) | ![s6](./screenshots/admin/6.png) |
| **Stories List** | **Certificates List** | **Settings List** |
| ![s4](./screenshots/admin/4.png) | ![s3](./screenshots/admin/3.png) | ![s2](./screenshots/admin/2.png) |
| **Logout Screen** |
| ![s8](./screenshots/admin/8.png)

### :door: Teacher Panel

| **Classes** | **Create Class** | **Classes** |
|-------------|------------------|-------------|
| ![s1](./screenshots/teacher/1.png) | ![s2](./screenshots/teacher/2.png) | ![s3](./screenshots/teacher/3.png)
| **Stories** | **Pending Members** | **Active Members** |
| ![s4](./screenshots/teacher/4.png) | ![s5](./screenshots/teacher/5.png) | ![s6](./screenshots/teacher/6.png)
| **Settings** | **Settings** | **Settings** |
| ![s7](./screenshots/teacher/7.png) | ![s8](./screenshots/teacher/8.png) | ![s9](./screenshots/teacher/9.png)

### :door: Parent Panel

| **Classes** | **Settings** | **Settings** |
|-------------|--------------|--------------|
| ![s1](./screenshots/parent/1.png) | ![s2](./screenshots/parent/2.png) | ![s2](./screenshots/parent/2.png) |
| **Settings** | **Join Class** | **Stories** |
| ![s4](./screenshots/parent/4.png) | ![s5](./screenshots/parent/5.png) | ![s6](./screenshots/parent/6.png) |
| **Certificate** | **Active Members** | **Story Content** |
| ![s7](./screenshots/parent/7.png) | ![s8](./screenshots/parent/8.png) | ![s9](./screenshots/parent/9.png) |
| **Locked Story** | **Locked Certificate** | **No Stories** |
| ![s10](./screenshots/parent/10.png) | ![s11](./screenshots/parent/11.png) | ![s12](./screenshots/parent/12.png) |
| **Delete Account** | **Logout** |
| ![s13](./screenshots/parent/13.png) | ![s14](./screenshots/parent/14.png) |

---
### :books: Database Structure
![Database Structure](./screenshots/database_relationship.png)
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
- [x] Scroll down to **App Settings** and select your **Support Account**
![Support Account](./screenshots/support_email.png)
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

### :computer: Compiling Application
- [x] Open terminal and execute:
```bash
# Downloads the dependencies
flutter packages get

# Run in debugging mode
flutter run --debug

# Run in release mode
flutter run --release
```

---

### :computer: Building Application
- [x] Open terminal and execute:
```bash
# Generates an .apk file
flutter build apk
```

---

### :computer: Techs Used
![Flutter](https://img.icons8.com/color/30/flutter.png)
![Firebase](https://img.icons8.com/color/30/4a90e2/firebase.png)

##### Database: Firebase DB
##### Application Framework: Flutter

---

## Made with :heart: by SnoopyCodeX :computer:
