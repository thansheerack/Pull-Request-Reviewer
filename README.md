# GitHub PR Reviewer 🚀

A Flutter application for reviewing GitHub pull requests with an intuitive UI, support for both authenticated and public repository access, and comprehensive error handling.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue?logo=dart)

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Project Structure](#-project-structure)
- [Setup Instructions](#-setup-instructions)
- [How Token Handling Works](#-how-token-handling-works)
- [Features](#-features)
- [Bonus Features Implemented](#-bonus-features-implemented)
- [Known Issues & Limitations](#-known-issues--limitations)

---

## 📱 Project Overview

GitHub PR Reviewer is a Flutter application that allows developers to browse and review GitHub pull requests directly from their mobile or web device. The app supports both authenticated access (with personal access tokens) and public repository access through a dummy login system.

**Key Capabilities:**
- ✅ Browse pull requests (open, closed, all)
- ✅ View detailed PR information and reviews
- ✅ Filter PRs by status
- ✅ Approve or request changes on PRs
- ✅ Merge pull requests
- ✅ Access public repositories without a token
- ✅ Persistent credential storage

---

## 📁 Project Structure

```
github_pr_reviewer/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── models/
│   │   └── pull_request.dart              # PullRequest, Review data models
│   ├── providers/
│   │   └── github_provider.dart           # State management (ChangeNotifier)
│   ├── services/
│   │   └── github_service.dart            # GitHub API client
│   └── screens/
│       ├── home_screen.dart               # Main home screen (refactored)
│       ├── pr_detail_screen.dart          # PR details & review interface
│       └── components/
│           ├── login_form.dart            # Login form widget
│           ├── pr_card.dart               # Individual PR card widget
│           └── pr_list.dart               # PR list with filters
├── pubspec.yaml                           # Dependencies
├── README.md                              # This file
└── android/, ios/, web/                   # Platform-specific code
```

### Architecture Pattern
- **State Management:** Provider (ChangeNotifier)
- **Separation of Concerns:** Service layer for API calls, Provider for business logic, UI components modularized
- **Component-Based:** Reusable UI components in `/screens/components/`

---

## 🛠 Setup Instructions

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Git
- GitHub Account (optional, for private repo access)

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd github_pr_reviewer
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **For Web**
   ```bash
   flutter run -d web-server
   # App will be available at http://localhost:58523
   ```

4. **For Android**
   ```bash
   flutter run -d android
   ```

5. **For iOS**
   ```bash
   flutter run -d ios
   ```
---

## 🔐 How Token Handling Works

### Token Storage & Security

The app implements a **secure token handling mechanism** using `shared_preferences`:

#### 1. **Authentication Methods**

**Method A: Authenticated Access (Private & Public Repos)**
```dart
// User provides a valid GitHub Personal Access Token
await provider.authenticate(
  token: 'ghp_ABC123XYZ...', 
  owner: 'flutter',
  repo: 'flutter'
);
```
- Token is validated against GitHub API
- Stored in `shared_preferences` for persistent access
- Sent in Authorization header for API requests
- Provides higher rate limits (5,000 requests/hour)

**Method B: Public Repository Access (No Token)**
```dart
// User accesses public repos with dummy token
await provider.authenticatePublic(
  owner: 'google',
  repo: 'material-design-icons'
);
```
- Dummy token `abc123` is stored for display purposes
- **Not sent** in API requests (excluded by header check)
- Public repos accessible without authentication
- Lower rate limits (60 requests/hour)

#### 2. **Persistent Storage & Retrieval**

```dart
Future<void> initializePreferences() async {
  final savedToken = _prefs.getString('github_token');
  final savedOwner = _prefs.getString('github_owner');
  final savedRepo = _prefs.getString('github_repo');
  
  // Auto-login if credentials exist
  if (savedToken != null && savedOwner != null && savedRepo != null) {
    _token = savedToken;
    _owner = savedOwner;
    _repo = savedRepo;
  }
}
```

#### 3. **Secure Logout**

```dart
Future<void> logout() async {
  // Clear all credentials from memory and storage
  await _prefs.remove('github_token');
  await _prefs.remove('github_owner');
  await _prefs.remove('github_repo');
}
```

### Security Notes
⚠️ **Important:** `shared_preferences` stores data in plain text on the device. For production apps handling sensitive data, consider using:
- `flutter_secure_storage` for encrypted storage
- Platform-specific secure storage (Keychain on iOS, Keystore on Android)

---

## ✨ Features

### Core Features
- ✅ **Dual Authentication:** Token-based and public repo access
- ✅ **PR Browsing:** View all, open, and closed pull requests
- ✅ **PR Details:** Comprehensive PR information with author, date, status
- ✅ **Filtering:** Filter PRs by status (open/closed/all)
- ✅ **Review Management:** View existing reviews on PRs
- ✅ **Error Handling:** Comprehensive error messages 
- ✅ **Responsive Design:** Works on mobile, tablet, and web

---

## 🎁 Bonus Features Implemented

### 1. **Modular Architecture** 📦
- Separated UI components into `/screens/components/`
- `LoginForm` - Reusable login component
- `PullRequestCard` - Individual PR display
- `PullRequestList` - PR list with filters
- Easy to maintain and test

### 2. **Rate Limit Handling** 🚦
- Detects HTTP 403 (rate limit exceeded)
- User-friendly error messages
- Retry functionality with provider.fetchPullRequests()
- Distinguishes between rate limits and other 403s (permission errors)

```dart
// Service handles rate limits gracefully
if (response.statusCode == 403) {
  throw Exception('Rate limit exceeded - Please try again later');
}
```

### 3. **Dummy Token System** 🎭
- Public repo access without authentication
- Dummy token `abc123` for display on PR detail screen
- Token shown in styled blue container for verification
- Demonstrates secure token handling patterns

### 4. **Persistent Credential Storage** 💾
- Auto-login on app restart
- Save credentials securely using `shared_preferences`
- Clear credentials on logout
- Seamless user experience

### 5. **Token Visibility** 👁️
- Token displayed on PR detail screen
- Shows current authentication state
- Educational feature demonstrating token usage
- Styled information container for clarity

### 6. **Comprehensive Error States** ⚠️
- Loading state with spinner
- Error state with message and retry button
- Empty state when no PRs found
- Clear visual feedback for all scenarios

### 7. **Multiple Status Codes Handled** 🔍
| Status Code | Meaning | Handling |
|---|---|---|
| 200 | Success | Load data |
| 401 | Unauthorized | "Invalid token" error |
| 403 | Forbidden/Rate Limited | "Rate limit exceeded" with retry |
| 404 | Not Found | "Repository not found" |
| 409 | Conflict | "PR cannot be merged" (conflicts) |

### 8. **Smart Header Management** 🔄
- Authorization header only added for valid tokens
- Dummy token excluded from API requests
- Conditional header building based on token type

### 9. **Pull Request Metadata** 📊
- Author and creation date
- Comment count
- Change count
- Status badge (open/closed/merged)
- Labels and tags
- Author avatar

### 10. **Code Quality** ✨
- Organized folder structure
- Proper separation of concerns
- Reusable components
- Clean architecture pattern
  
### 10. **Dark Mode** ✨
- Dark mode implimented
  
---

## 🐞 Known Issues & Limitations

### Limitations

1. **Read-Only Operations**
   - Current implementation focuses on viewing and filtering PRs
   - Review functionality (approve/request changes) works but requires proper permissions
   - Direct PR modification not fully implemented

2. **Rate Limiting**
   - Public access limited to 60 requests/hour
   - Authenticated access limited to 5,000 requests/hour
   - No local caching mechanism (each request hits API)
   - Consider implementing `sqflite` or `hive` for local caching

3. **Token Storage**
   - Uses `shared_preferences` (plain text)
   - Should use `flutter_secure_storage` for production
   - No encryption for sensitive data

4. **Pagination**
   - Limited to 30 PRs per page
   - No pagination UI for large repositories
   - Would benefit from infinite scroll or pagination controls

---

## 📚 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter | sdk | Main framework |
| provider | ^6.0.0 | State management |
| http | ^1.1.0 | HTTP client for API calls |
| intl | ^0.19.0 | Date/time formatting |
| shared_preferences | ^2.2.0 | Persistent credential storage |
| cupertino_icons | ^1.0.2 | iOS-style icons |

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍💻 Author

Thansheera CK

---

**Last Updated:** March 3, 2026  
**Version:** 1.0.0
