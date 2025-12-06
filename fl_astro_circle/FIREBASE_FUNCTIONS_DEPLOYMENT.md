# Firebase Cloud Functions - Deployment Guide

## 🚀 Quick Start

### Prerequisites
- Node.js installed (v18+)
- Firebase CLI installed (`npm install -g firebase-tools`)
- Firebase project configured with Blaze plan
- Active Firebase authentication

### First-Time Setup

1. **Login to Firebase:**
   ```bash
   firebase login
   ```

2. **Initialize Firebase project (if not already done):**
   ```bash
   firebase use --add
   ```
   Select your Firebase project from the list.

3. **Install Cloud Functions dependencies:**
   ```bash
   cd functions
   npm install
   cd ..
   ```

### Deploy Cloud Functions

Deploy all functions:
```bash
firebase deploy --only functions
```

Deploy specific function:
```bash
firebase deploy --only functions:generateDailyHoroscopes
```

### Testing

#### Test Locally (Emulator)
```bash
firebase emulators:start --only functions
```

#### Manual Trigger (for testing without waiting for schedule)
After deployment, you can manually trigger horoscope generation:

1. Go to Firebase Console → Functions
2. Find `generateHoroscopesManual` function
3. Copy the function URL
4. Open in browser or use curl:
   ```bash
   curl https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/generateHoroscopesManual
   ```

### Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### View Logs

```bash
firebase functions:log
```

Or in Firebase Console → Functions → Logs

## 📊 Monitoring

### Check Scheduled Function
- Firebase Console → Functions → Dashboard
- Look for `generateDailyHoroscopes`
- Check "Next execution" timestamp

### Verify Data in Firestore
- Firebase Console → Firestore Database
- Collection: `horoscopes`
- Documents should follow pattern: `{zodiacSign}_{YYYY-MM-DD}_{period}`

## 🔧 Troubleshooting

### Function Fails to Deploy
- Ensure you're on Blaze plan
- Check that `firebase.json` is configured correctly
- Verify Node.js version (should be 18)

### No Data Generated
- Check function logs: `firebase functions:log`
- Verify OpenRouter API key is valid
- Check Firestore security rules allow writes from Cloud Functions

### Flutter App Can't Read Data
- Ensure user is authenticated (security rules require auth)
- Check Firestore security rules
- Verify document IDs match the expected format

## 💰 Cost Optimization

- Scheduled function runs once per day (00:00 UTC)
- Generates 36 documents (12 zodiac signs × 3 periods)
- Uses free tier AI model (`mistralai/mistral-7b-instruct:free`)
- Should stay within Firebase free tier limits

## 📝 Important Notes

- The scheduled function runs at **00:00 UTC** every day
- Horoscopes are generated for all zodiac signs automatically
- Flutter app fetches data based on user's local timezone
- Data is cached in Firestore for offline access
