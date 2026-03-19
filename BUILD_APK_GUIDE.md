# 📱 Build Android APK - Complete Guide

## 🎯 Quick Summary

To build an APK, you need:
1. Android Studio installed
2. Android SDK configured
3. Run `flutter build apk`

---

## 📋 Prerequisites Check

### Step 1: Check Flutter Doctor
```bash
cd ui_app
flutter doctor
```

Look for:
- ✅ Flutter (Channel stable)
- ✅ Android toolchain
- ✅ Android Studio

---

## 🔧 Setup Android Development (If Not Installed)

### Option 1: Install Android Studio (Recommended)

**1. Download Android Studio:**
- Go to: https://developer.android.com/studio
- Download latest version
- Install with default settings

**2. Install Android SDK:**
- Open Android Studio
- Go to: Tools → SDK Manager
- Install:
  - Android SDK Platform (API 33 or higher)
  - Android SDK Build-Tools
  - Android SDK Command-line Tools
  - Android SDK Platform-Tools

**3. Accept Android Licenses:**
```bash
flutter doctor --android-licenses
# Type 'y' to accept all licenses
```

**4. Verify Setup:**
```bash
flutter doctor
# Should show ✅ for Android toolchain
```

---

### Option 2: Install SDK Only (Without Android Studio)

**1. Download Command Line Tools:**
- Go to: https://developer.android.com/studio#command-tools
- Download "Command line tools only"
- Extract to: `C:\Android\cmdline-tools`

**2. Set Environment Variables:**
```
ANDROID_HOME = C:\Android
Path += C:\Android\cmdline-tools\latest\bin
Path += C:\Android\platform-tools
```

**3. Install SDK Components:**
```bash
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
```

**4. Accept Licenses:**
```bash
flutter doctor --android-licenses
```

---

## 🏗️ Build APK

### Method 1: Build Release APK (Recommended)

**1. Navigate to project:**
```bash
cd E:\KonnectMedia-main\ui_app
```

**2. Build APK:**
```bash
flutter build apk --release
```

**3. Find APK:**
```
Location: ui_app\build\app\outputs\flutter-apk\app-release.apk
Size: ~50-80 MB
```

---

### Method 2: Build Debug APK (For Testing)

**1. Build debug APK:**
```bash
flutter build apk --debug
```

**2. Find APK:**
```
Location: ui_app\build\app\outputs\flutter-apk\app-debug.apk
Size: ~80-120 MB (larger than release)
```

---

### Method 3: Build Split APKs (Smaller Size)

**1. Build per-ABI APKs:**
```bash
flutter build apk --split-per-abi
```

**2. Find APKs:**
```
ui_app\build\app\outputs\flutter-apk\
├─ app-armeabi-v7a-release.apk  (~25 MB)
├─ app-arm64-v8a-release.apk    (~25 MB)
└─ app-x86_64-release.apk       (~30 MB)
```

**Note:** Most modern phones use `arm64-v8a`

---

## 📦 Build App Bundle (For Google Play)

**1. Build AAB:**
```bash
flutter build appbundle --release
```

**2. Find AAB:**
```
Location: ui_app\build\app\outputs\bundle\release\app-release.aab
```

**Note:** AAB is required for Google Play Store upload

---

## ⚙️ Configuration Before Building

### 1. Update App Name

**File:** `ui_app\android\app\src\main\AndroidManifest.xml`
```xml
<application
    android:label="KonnectMedia"
    ...>
```

### 2. Update Package Name (Optional)

**File:** `ui_app\android\app\build.gradle`
```gradle
android {
    defaultConfig {
        applicationId "com.konnectmedia.app"
        ...
    }
}
```

### 3. Update App Icon (Optional)

Replace icons in:
```
ui_app\android\app\src\main\res\
├─ mipmap-hdpi\ic_launcher.png
├─ mipmap-mdpi\ic_launcher.png
├─ mipmap-xhdpi\ic_launcher.png
├─ mipmap-xxhdpi\ic_launcher.png
└─ mipmap-xxxhdpi\ic_launcher.png
```

### 4. Update Backend URL for Production

**File:** `ui_app\lib\services\api_service.dart`
```dart
// Change from localhost to your production server
static const String baseUrl = 'https://your-domain.com';
```

**Important:** Localhost won't work on real Android devices!

---

## 🔐 Code Signing (For Release)

### Generate Keystore

**1. Create keystore:**
```bash
keytool -genkey -v -keystore konnectmedia-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias konnectmedia
```

**2. Answer prompts:**
```
Enter keystore password: [your-password]
Re-enter password: [your-password]
What is your first and last name? [Your Name]
What is the name of your organizational unit? [Your Company]
...
```

**3. Create key.properties:**

**File:** `ui_app\android\key.properties`
```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=konnectmedia
storeFile=../konnectmedia-keystore.jks
```

**4. Update build.gradle:**

**File:** `ui_app\android\app\build.gradle`
```gradle
// Add before android block
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## 🚀 Quick Build Commands

### For Testing (No Setup Required):
```bash
cd ui_app
flutter build apk --debug
```

### For Production (After Setup):
```bash
cd ui_app
flutter build apk --release --split-per-abi
```

### For Google Play:
```bash
cd ui_app
flutter build appbundle --release
```

---

## 📱 Install APK on Phone

### Method 1: USB Cable

**1. Enable Developer Options on phone:**
- Settings → About Phone
- Tap "Build Number" 7 times

**2. Enable USB Debugging:**
- Settings → Developer Options
- Enable "USB Debugging"

**3. Connect phone and install:**
```bash
cd ui_app
flutter install
```

### Method 2: Transfer APK

**1. Copy APK to phone:**
- Via USB cable
- Via Google Drive
- Via Email

**2. Install on phone:**
- Open APK file
- Tap "Install"
- Allow "Install from Unknown Sources" if prompted

---

## ⚠️ Common Issues & Solutions

### Issue 1: "Android SDK not found"

**Solution:**
```bash
# Set ANDROID_HOME environment variable
setx ANDROID_HOME "C:\Users\[YourUsername]\AppData\Local\Android\Sdk"

# Restart terminal and run:
flutter doctor
```

### Issue 2: "License not accepted"

**Solution:**
```bash
flutter doctor --android-licenses
# Type 'y' for all prompts
```

### Issue 3: "Gradle build failed"

**Solution:**
```bash
cd ui_app\android
.\gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### Issue 4: "Localhost not accessible on phone"

**Solution:**
Update API URL in `api_service.dart`:
```dart
// Don't use localhost!
static const String baseUrl = 'http://192.168.1.100:4000'; // Your PC's IP
// OR
static const String baseUrl = 'https://your-domain.com'; // Production server
```

### Issue 5: "Razorpay errors"

**Solution:**
Razorpay works on Android! The errors you saw were Windows-specific.
On Android, payment gateway will work properly.

---

## 📊 Build Output Sizes

| Build Type | Size | Use Case |
|------------|------|----------|
| Debug APK | ~80-120 MB | Testing only |
| Release APK | ~50-80 MB | Distribution |
| Split APK (arm64) | ~25 MB | Most phones |
| Split APK (armeabi) | ~25 MB | Older phones |
| App Bundle (AAB) | ~40 MB | Google Play |

---

## 🎯 Recommended Build Process

### For Testing:
```bash
# 1. Build debug APK
flutter build apk --debug

# 2. Install on connected phone
flutter install

# 3. Test all features
```

### For Distribution:
```bash
# 1. Update backend URL to production
# 2. Build release APK
flutter build apk --release --split-per-abi

# 3. Test on multiple devices
# 4. Distribute arm64-v8a APK (works on most phones)
```

### For Google Play:
```bash
# 1. Set up code signing
# 2. Build app bundle
flutter build appbundle --release

# 3. Upload to Google Play Console
# 4. Submit for review
```

---

## 📝 Pre-Build Checklist

Before building APK, ensure:

- [ ] Backend URL updated (not localhost)
- [ ] App name set in AndroidManifest.xml
- [ ] App icon updated (optional)
- [ ] Package name set (optional)
- [ ] Permissions configured in AndroidManifest.xml
- [ ] Code signing set up (for release)
- [ ] Tested on emulator/device
- [ ] All features working
- [ ] No debug code left

---

## 🔗 Useful Commands

```bash
# Check Flutter setup
flutter doctor -v

# List connected devices
flutter devices

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build APK (release)
flutter build apk --release

# Build APK (debug)
flutter build apk --debug

# Build split APKs
flutter build apk --split-per-abi

# Build app bundle
flutter build appbundle --release

# Install on device
flutter install

# Run on device
flutter run --release
```

---

## 🎉 Quick Start (If Android SDK Already Installed)

```bash
# 1. Navigate to project
cd E:\KonnectMedia-main\ui_app

# 2. Clean and get dependencies
flutter clean
flutter pub get

# 3. Build APK
flutter build apk --release

# 4. Find APK at:
# ui_app\build\app\outputs\flutter-apk\app-release.apk

# 5. Transfer to phone and install!
```

---

## 📞 Need Help?

If you encounter issues:

1. Run `flutter doctor -v` and share output
2. Check error messages in terminal
3. Verify Android SDK is installed
4. Make sure licenses are accepted
5. Try building debug APK first

---

## 🚀 Next Steps After Building APK:

1. **Test on Real Device:**
   - Install APK on Android phone
   - Test all features
   - Check Razorpay payment (works on Android!)
   - Verify backend connectivity

2. **Deploy Backend:**
   - Deploy API to cloud (Heroku, AWS, DigitalOcean)
   - Update API URL in app
   - Rebuild APK with production URL

3. **Publish to Google Play:**
   - Create Google Play Developer account ($25 one-time)
   - Build app bundle (AAB)
   - Upload to Play Console
   - Fill in store listing
   - Submit for review

---

Ready to build? Just run:
```bash
cd ui_app
flutter build apk --release
```

The APK will be at: `ui_app\build\app\outputs\flutter-apk\app-release.apk`

Good luck! 🎉
