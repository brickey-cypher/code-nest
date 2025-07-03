# 🔐 Flutter TOTP Authenticator

A lightweight Time-Based One-Time Password (TOTP) generator app built in Flutter. Supports multi-account OTP generation using Base32 secrets.

## ✨ Features
- Generate 6-digit OTPs every 30 seconds
- Add multiple accounts with issuer/account name/secret
- Validation for Base32 secrets
- Delete existing accounts
- Works on Android and Web

## 📦 Tech Stack
- Flutter (Dart)
- Provider (state management)
- Custom Base32 decoder
- Secure storage (coming soon)

## 🔜 Coming Soon
- QR code scanning (`otpauth://`)
- Countdown progress bar for code expiration
- Persistent encrypted account storage
- iOS support

## 🚀 Try It
Run locally:
```bash
flutter pub get
flutter run
