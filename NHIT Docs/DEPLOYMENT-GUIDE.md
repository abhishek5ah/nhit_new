# Deployment Guide

## Overview
Complete deployment guide for NHIT ERP System covering all platforms and environments.

---

## Table of Contents
1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Environment Configuration](#environment-configuration)
3. [Platform-Specific Builds](#platform-specific-builds)
4. [Production Deployment](#production-deployment)
5. [Post-Deployment](#post-deployment)

---

## Pre-Deployment Checklist

### Code Quality

- [ ] All features tested and working
- [ ] No console errors or warnings
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] Version number updated in `pubspec.yaml`

### Security

- [ ] API endpoints configured for production
- [ ] Remove debug logs and print statements
- [ ] Secure storage implemented for tokens
- [ ] HTTPS enabled for all API calls
- [ ] Environment variables configured
- [ ] Sensitive data removed from code

### Performance

- [ ] Images optimized
- [ ] Unused dependencies removed
- [ ] Build size optimized
- [ ] Loading states implemented
- [ ] Error handling in place

### Testing

- [ ] Unit tests passing
- [ ] Widget tests passing
- [ ] Integration tests passing
- [ ] Manual testing completed
- [ ] User acceptance testing done

---

## Environment Configuration

### 1. Update API Constants

**File:** `lib/core/constants/api_constants.dart`

**Development:**
```dart
class ApiConstants {
  static const String authBaseUrl = 'http://192.168.1.51:8083/api/v1';
  static const String userBaseUrl = 'http://192.168.1.51:8083/api/v1';
  static const String organizationBaseUrl = 'http://192.168.1.51:8083/api/v1';
  static const String departmentBaseUrl = 'http://192.168.1.51:8083/api/v1';
  static const String designationBaseUrl = 'http://192.168.1.51:8083/api/v1';
  static const String vendorBaseUrl = 'http://192.168.1.51:8083/api/v1';
}
```

**Production:**
```dart
class ApiConstants {
  static const String authBaseUrl = 'https://api.nhiterp.com/api/v1';
  static const String userBaseUrl = 'https://api.nhiterp.com/api/v1';
  static const String organizationBaseUrl = 'https://api.nhiterp.com/api/v1';
  static const String departmentBaseUrl = 'https://api.nhiterp.com/api/v1';
  static const String designationBaseUrl = 'https://api.nhiterp.com/api/v1';
  static const String vendorBaseUrl = 'https://api.nhiterp.com/api/v1';
}
```

### 2. Update Version

**File:** `pubspec.yaml`

```yaml
version: 1.0.0+1  # Update version number
```

### 3. Environment-Specific Configuration

Create environment files:

**lib/core/config/env_config.dart**
```dart
class EnvConfig {
  static const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
  static const bool enableLogging = bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true);
  
  static String get apiBaseUrl {
    if (isProduction) {
      return 'https://api.nhiterp.com/api/v1';
    } else {
      return 'http://192.168.1.51:8083/api/v1';
    }
  }
}
```

Build with environment variables:
```bash
flutter build windows --release --dart-define=PRODUCTION=true --dart-define=ENABLE_LOGGING=false
```

---

## Platform-Specific Builds

### Windows Desktop

#### 1. Prerequisites
- Windows 10 or later
- Visual Studio 2019 or later with C++ development tools
- Flutter SDK configured for Windows

#### 2. Build Command
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release
flutter build windows --release
```

#### 3. Output Location
```
build/windows/runner/Release/
```

#### 4. Files to Distribute
```
nhit_erp.exe
flutter_windows.dll
All .dll files in the Release folder
data/ folder
```

#### 5. Create Installer (Optional)

**Using Inno Setup:**

1. Install Inno Setup
2. Create installer script:

```inno
[Setup]
AppName=NHIT ERP System
AppVersion=1.0.0
DefaultDirName={pf}\NHIT ERP
DefaultGroupName=NHIT ERP
OutputDir=installer
OutputBaseFilename=NHIT_ERP_Setup

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\NHIT ERP"; Filename: "{app}\nhit_erp.exe"
Name: "{commondesktop}\NHIT ERP"; Filename: "{app}\nhit_erp.exe"
```

3. Compile installer

---

### Web Application

#### 1. Build Command
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for web
flutter build web --release --web-renderer html
```

**Options:**
- `--web-renderer html`: Better compatibility
- `--web-renderer canvaskit`: Better performance
- `--web-renderer auto`: Automatic selection

#### 2. Output Location
```
build/web/
```

#### 3. Deploy to Web Server

**Apache Configuration:**
```apache
<VirtualHost *:80>
    ServerName erp.nhit.com
    DocumentRoot /var/www/nhit-erp/build/web
    
    <Directory /var/www/nhit-erp/build/web>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
        
        # Enable SPA routing
        RewriteEngine On
        RewriteBase /
        RewriteRule ^index\.html$ - [L]
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule . /index.html [L]
    </Directory>
</VirtualHost>
```

**Nginx Configuration:**
```nginx
server {
    listen 80;
    server_name erp.nhit.com;
    root /var/www/nhit-erp/build/web;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Enable gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
```

#### 4. Deploy Steps

```bash
# 1. Build web app
flutter build web --release

# 2. Copy to server
scp -r build/web/* user@server:/var/www/nhit-erp/

# 3. Set permissions
ssh user@server "chmod -R 755 /var/www/nhit-erp/"

# 4. Restart web server
ssh user@server "sudo systemctl restart nginx"
```

---

### Android Application

#### 1. Prerequisites
- Android SDK
- Java JDK 11 or later
- Keystore for signing

#### 2. Create Keystore

```bash
keytool -genkey -v -keystore nhit-erp-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias nhit-erp
```

#### 3. Configure Signing

**android/key.properties:**
```properties
storePassword=<store-password>
keyPassword=<key-password>
keyAlias=nhit-erp
storeFile=../nhit-erp-key.jks
```

**android/app/build.gradle:**
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
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

#### 4. Build APK

```bash
# Build APK
flutter build apk --release

# Build split APKs (smaller size)
flutter build apk --split-per-abi --release
```

#### 5. Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

#### 6. Output Location
```
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
```

---

### iOS Application

#### 1. Prerequisites
- macOS with Xcode
- Apple Developer Account
- Provisioning Profile
- Signing Certificate

#### 2. Configure Signing

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project
3. Go to Signing & Capabilities
4. Select your Team
5. Configure Bundle Identifier

#### 3. Build IPA

```bash
# Build for iOS
flutter build ios --release

# Create IPA
cd build/ios/iphoneos
mkdir Payload
cp -r Runner.app Payload/
zip -r nhit-erp.ipa Payload
```

#### 4. Deploy to App Store

1. Open Xcode
2. Product > Archive
3. Distribute App
4. Upload to App Store Connect

---

## Production Deployment

### 1. Backend Configuration

Ensure backend is configured:
- Database optimized
- API rate limiting enabled
- CORS configured
- SSL certificates installed
- Monitoring enabled

### 2. Frontend Deployment

#### Web Deployment

```bash
# 1. Build production
flutter build web --release

# 2. Deploy to hosting
# AWS S3
aws s3 sync build/web/ s3://nhit-erp-bucket/ --delete

# Firebase Hosting
firebase deploy --only hosting

# Netlify
netlify deploy --prod --dir=build/web
```

#### Desktop Deployment

```bash
# 1. Build installer
flutter build windows --release

# 2. Create installer with Inno Setup

# 3. Distribute installer
# - Upload to website
# - Send to users
# - Deploy via MDM
```

### 3. Database Migration

```sql
-- Run migration scripts
-- Backup database before migration
-- Test on staging first
```

### 4. DNS Configuration

```
A Record: erp.nhit.com -> Server IP
CNAME: www.erp.nhit.com -> erp.nhit.com
```

### 5. SSL Certificate

```bash
# Using Let's Encrypt
sudo certbot --nginx -d erp.nhit.com -d www.erp.nhit.com
```

---

## Post-Deployment

### 1. Verification Checklist

- [ ] Application loads correctly
- [ ] Login functionality works
- [ ] API calls successful
- [ ] All features accessible
- [ ] No console errors
- [ ] Performance acceptable
- [ ] Mobile responsiveness works
- [ ] SSL certificate valid

### 2. Monitoring Setup

**Application Monitoring:**
- Set up error tracking (Sentry, Firebase Crashlytics)
- Configure performance monitoring
- Set up uptime monitoring
- Configure alerts

**Server Monitoring:**
- CPU usage
- Memory usage
- Disk space
- Network traffic
- API response times

### 3. Backup Strategy

**Database Backups:**
```bash
# Daily automated backups
0 2 * * * /usr/local/bin/backup-database.sh

# Backup script
#!/bin/bash
DATE=$(date +%Y%m%d)
pg_dump nhit_erp > /backups/nhit_erp_$DATE.sql
```

**Application Backups:**
- Version control (Git)
- Build artifacts
- Configuration files

### 4. Documentation

- [ ] Update user documentation
- [ ] Update API documentation
- [ ] Update deployment documentation
- [ ] Create runbook for operations
- [ ] Document rollback procedures

### 5. User Communication

- [ ] Notify users of deployment
- [ ] Provide release notes
- [ ] Offer training if needed
- [ ] Set up support channels

---

## Rollback Procedures

### 1. Web Application

```bash
# Revert to previous version
aws s3 sync s3://nhit-erp-backup/ s3://nhit-erp-bucket/ --delete

# Or restore from Git
git checkout v1.0.0
flutter build web --release
# Deploy
```

### 2. Database

```bash
# Restore from backup
psql nhit_erp < /backups/nhit_erp_20251209.sql
```

### 3. Desktop Application

- Redistribute previous installer
- Users reinstall previous version

---

## Troubleshooting

### Build Issues

**Problem:** Build fails with dependency errors
```bash
# Solution
flutter clean
flutter pub get
flutter pub upgrade
flutter build <platform> --release
```

**Problem:** Missing native dependencies
```bash
# Windows
# Install Visual Studio C++ tools

# Android
# Update Android SDK
```

### Deployment Issues

**Problem:** Web app not loading
- Check web server configuration
- Verify file permissions
- Check browser console for errors
- Verify API endpoints

**Problem:** API connection fails
- Check CORS configuration
- Verify SSL certificates
- Check firewall rules
- Verify API base URL

---

## Performance Optimization

### 1. Web Optimization

```bash
# Build with optimizations
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true

# Enable compression
gzip on;
gzip_types text/plain text/css application/json application/javascript;
```

### 2. Asset Optimization

```bash
# Optimize images
# Use WebP format
# Compress assets
# Remove unused assets
```

### 3. Code Splitting

```dart
// Lazy load routes
GoRoute(
  path: '/vendors',
  builder: (context, state) => const VendorPage(),
  // Lazy load heavy widgets
)
```

---

## Security Hardening

### 1. API Security

- Enable HTTPS only
- Implement rate limiting
- Use API keys
- Validate all inputs
- Implement CORS properly

### 2. Application Security

- Obfuscate code
- Remove debug symbols
- Implement certificate pinning
- Use secure storage
- Validate SSL certificates

### 3. Build with Obfuscation

```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

---

## Maintenance

### Regular Tasks

**Daily:**
- Monitor error logs
- Check system health
- Review user feedback

**Weekly:**
- Review performance metrics
- Check backup integrity
- Update dependencies (if needed)

**Monthly:**
- Security updates
- Performance optimization
- Database maintenance
- User training sessions

---

## Support

### Issue Reporting

- GitHub Issues
- Support Email: support@nhit.com
- Documentation: https://docs.nhit.com

### Emergency Contacts

- DevOps Team: devops@nhit.com
- Backend Team: backend@nhit.com
- Frontend Team: frontend@nhit.com

---

**Last Updated:** December 2025  
**Version:** 1.0.0
