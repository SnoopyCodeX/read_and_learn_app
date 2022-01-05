import 'dart:typed_data';

import 'package:flutter/material.dart';

// @Development or Production Mode
//    If set to false, it will use the Firebase Emulators as
//    it's Developments Database.
//    Make sure that you have configured Firebase Emulator in your
//    local machine.
const kIsProduction = true;

// @Firebase Emulator Constants
//    Change these according to your Firebase Emulator's
//    configuration.
//    Make sure that you have configured Firebase Emulator in your
//    local machine.
const String FIREBASE_EMULATOR_HOST = 'localhost';
const int FIREBASE_AUTH_EMULATOR_PORT = 9099;
const int FIREBASE_FIRESTORE_EMULATOR_PORT = 5777;
const int FIREBASE_STORAGE_EMULATOR_PORT = 9199;

// @Facebook Login API Configs
// const String FB_CLIENT_ID = "568702960959014";
// const String FB_REDIRECT_URL = "https://online-reading-app.firebaseapp.com/__/auth/handler";

// @Default Story Thumbnail
const String DEFAULT_STORY_THUMBNAIL =
    'https://image.freepik.com/free-vector/cute-koala-reading-book-cartoon-illustration_138676-2988.jpg';

// @REST API FOR TRANSCRIBING AUDIO USING REV.AI
const String TRANSCRIBE_REST_API =
    'https://read-and-learn-api.herokuapp.com/audio/transcribe';

// @Pusher Constants (For push notifications)
const String PUSHER_APP_ID = "0aed2d8628b773a1191a";
const String PUSHER_CLUSTER = "ap3";

// @User Reading Status
const String STATUS_FINISHED_READING = 'finished_reading';
const String STATUS_STILL_READING = 'still_reading';

// @Default Admin Credentials
const String DEFAULT_ADMIN_EMAIL = "admin123@gmail.com";
const String DEFAULT_ADMIN_PASSWORD = "admin123";
const String DEFAULT_ADMIN_FIRST_NAME = "Admin";
const String DEFAULT_ADMIN_LAST_NAME = "Admin";

// @App Colors
const Color kPrimaryColor = const Color(0xFF6F35A5);
const Color kPrimaryLightColor = const Color(0xFFF1E6FF);
const Color kBaseColor = const Color(0xFFF4F4F4);
const Color kHighlightColor = const Color(0xFFDADADA);

// @File folders in Firebase Storage DB
const String PHOTOS_FOLDER = 'photos';
const String AUDIOS_FOLDER = 'audios';

// @Collection names in Firebase Firestore DB
const String USERS_TABLE = 'users';
const String USER_PROGRESS_TABLE = 'user_progresses';
const String STORIES_TABLE = 'stories';
const String CLASSROOMS_TABLE = 'classrooms';
const String CLASS_MEMBERS_TABLE = 'class_members';
const String FINISHED_STORIES_TABLE = 'finished_stories';
const String CERTIFICATE_HOLDERS_TABLE = 'certificate_holders';

// @Outside classroom options
const List<String> CLASSROOM_OPTIONS = [
  'Edit',
  'Delete',
];

// @Inside classroom options
const List<String> CLASSROOM_PANEL_OPTIONS = [
  'Copy class code',
  'Edit',
  'Delete',
];

// @Outside story options
const List<String> STORY_PANEL_OPTIONS = [
  'Edit',
  'Delete',
];

// @MESSAGES
const MESSAGES = {
  'email': {
    'not_exist': 'Your email address does not exist in the database',
    'exist': 'Your email address already exist in the database',
    'invalid':
        'Your email address does not match the valid email address format'
  },
  'password': {
    'incorrect': 'Your password is incorrect',
    'short': 'Your password is too short'
  },
  'users': {
    'no_users': 'No users is found.',
    'no_user': 'User does not exist in the database',
    'empty_field': 'Please fill in the required fields!',
    'photo_upload_success': 'Photo has been successfully uploaded!',
    'photo_upload_failed': 'Failed to upload your photo',
    'photo_delete_success': 'Photo has been successfully deleted!',
    'photo_delete_failed': 'Failed to delete your photo',
    'audio_upload_success': 'Audio has been successfully uploaded!',
    'audio_upload_failed': 'Failed to upload your audio',
    'audio_delete_success': 'Audio has been successfully uploaded!',
    'audio_delete_failed': 'Failed to delete your audio'
  },
  'story': {
    'no_stories_found': 'No stories to show.',
    'story_delete_success': 'Story has been deleted successfully!',
    'story_create_or_update_success': 'Story has been saved successfully!',
    'story_upload_thumbnail_success':
        'Thumbnail has been successfully uploaded!',
    'story_delete_thumbnail_success':
        'Thumbnail has been successfully deleted!',
  },
  'classroom': {
    'no_classrooms_found': 'No classrooms to show.',
    'classroom_create_or_update_successful':
        'Classroom has been successfully saved!',
    'classroom_delete_successful': 'Classroom has been successfully deleted!',
    'no_members_found': 'This classroom has no members yet!',
  }
};

// @Constant Transparent Image Data
final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
]);
