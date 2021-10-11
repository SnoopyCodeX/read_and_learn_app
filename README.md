# :book: Read and Learn
[![Developed by SnoopyCodeX](https://img.shields.io/badge/Developed%20by-SnoopyCodeX-blue.svg?longCache=true&style=for-the-badge)](https://facebook.com/SnoopyCodeX)
[![Github Release](https://img.shields.io/github/release/SnoopyCodeX/read_and_learn_app.svg?style=for-the-badge)](https://github.com/SnoopyCodeX/read_and_learn_app/releases) 
[![Github Star](https://img.shields.io/github/stars/SnoopyCodeX/read_and_learn_app.svg?style=for-the-badge)](https://github.com/SnoopyCodeX/read_and_learn_app) 
[![Github Fork](https://img.shields.io/github/forks/SnoopyCodeX/read_and_learn_app.svg?style=for-the-badge)](https://github.com/SnoopyCodeX/read_and_learn_app) 
[![License](https://img.shields.io/github/license/SnoopyCodeX/read_and_learn_app.svg?style=for-the-badge)](./LICENSE)

A mobile app made with flutter, this app is made to teach and guide children on how to read. This app can compute their wpm(words per minute) and the accuracy of their reading.

### :computer: Technologies Used
![Flutter](https://img.icons8.com/color/30/flutter.png)
![Firebase](https://img.icons8.com/color/30/4a90e2/firebase.png)
![NodeJS](https://img.icons8.com/color/30/4a90e2/nodejs.png)
![NPM](https://img.icons8.com/color/30/4a90e2/npm.png)
![ExpressJS](https://img.icons8.com/color/30/4a90e2/express.png)
![Heroku](https://img.icons8.com/color/30/4a90e2/heroku.png)

- Firebase Database
- Flutter
- NodeJS
- NPM
- Express
- Heroku
- Rev AI

This app uses a third-party API(Application Programming Interface) named, [Rev.ai](https://rev.ai) to transcribe an audio file, link to the repo is this: [NodeJs + Express REST API](https://github.com/read_and_learn_rest_api).

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
- :white_check_mark: Compute reader's WPM(Words per minute)
- :white_check_mark: Generate certificate from the app
- :white_check_mark: Analyze reader's accuracy
- :white_check_mark: Demonstration of the word's pronounciation when the word is clicked

---

### :warning: Notice

- :white_check_mark: This app heavily relies on android devices' **Microphone** to record the audio and is a very **crucial requirement** for this app to **run properly**.
- :white_check_mark: This app currently **does not** support **Offline Mode**.

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
- [x] Scroll down and add your app's **sha-1** and **sha-256** hashes.
![App Hashes](./screenshots/app_hashes.png)

#### :lock: Firestore Database
- [x] Go to **Firestore Database** tab of your firebase.
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

### :clipboard: License
```
   Copyright 2021 SnoopyCodeX

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```

---

## Made with :heart: by SnoopyCodeX :computer:
