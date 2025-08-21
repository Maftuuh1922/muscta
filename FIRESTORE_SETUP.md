# Firebase Firestore Setup Instructions

## Problem
The app is getting this error:
```
The database (default) does not exist for project musicta-9cd36
```

This means the Firestore database has not been created in your Firebase project.

## Solution - Setup Firestore Database

### Step 1: Go to Firebase Console
1. Open https://console.firebase.google.com/
2. Select your project: `musicta-9cd36`

### Step 2: Create Firestore Database
1. In the left sidebar, click on **"Firestore Database"**
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
   - This allows read/write access for 30 days
   - You can change security rules later
4. Choose a location (select the closest to your users)
   - For Indonesia: `asia-southeast2` (Jakarta)
5. Click **"Done"**

### Step 3: Set Up Security Rules
After database is created, go to the "Rules" tab and use these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow authenticated users to read other users' public data
    match /users/{userId} {
      allow read: if request.auth != null;
    }
    
    // Allow authenticated users to create posts
    match /posts/{postId} {
      allow read: if true; // Anyone can read posts
      allow write: if request.auth != null;
    }
    
    // For development - remove in production
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Step 4: Set Up Storage Rules
Go to **"Storage"** in Firebase Console and set these rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow users to upload their own profile images
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if true; // Anyone can read profile images
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow authenticated users to upload images
    match /images/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Alternative: Local Storage Fallback

The app now includes a local storage fallback system that will:
1. Try to save data to Firestore first
2. If Firestore fails, save data locally using SharedPreferences
3. Continue to work offline
4. Sync data to Firestore when it becomes available

## Testing

After setting up Firestore:
1. Run the app: `flutter run`
2. Complete the profile setup
3. Check Firebase Console -> Firestore Database to see if data is saved

## Troubleshooting

If you still get errors:
1. Make sure you're using the correct Firebase project ID
2. Check that Firebase configuration files are up to date
3. Run `flutter clean` and rebuild the app
4. Check internet connection

## Current Fallback Behavior

Until Firestore is set up, the app will:
- Save profile data locally
- Show success message
- Navigate to main app
- Work in offline mode
- Automatically sync when Firestore becomes available
