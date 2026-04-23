# 🔐 Google Auth & Email Verification Implementation Guide

## ✅ What's Been Implemented

### **Backend (Node.js/Express)**

#### 1. **Enhanced User Model**
- ✅ Email verification tracking (`isEmailVerified`, `emailVerificationToken`, `emailVerificationExpiry`)
- ✅ Google OAuth support (`googleId`, `googleProfilePicture`)
- ✅ Auth method tracking (email, Google, etc.)
- ✅ Password reset flow (`passwordResetToken`, `passwordResetExpiry`)
- ✅ Login attempt tracking (security: locks account after 5 failed attempts for 15 min)
- ✅ Last login timestamp

#### 2. **Email Service** (`src/services/emailService.js`)
- ✅ Sends verification emails with clickable links
- ✅ Sends password reset emails
- ✅ Supports Gmail SMTP or custom email providers
- ✅ Development mode (logs to console if EMAIL_USER not set)

#### 3. **Enhanced Auth Routes** (`src/routes/auth.routes.js`)

**Email/Password Auth:**
- ✅ `POST /auth/register` - Creates user, sends verification email
- ✅ `POST /auth/login` - Enhanced with account locking after 5 failed attempts
- ✅ `POST /auth/verify-email` - Verifies email with token
- ✅ `POST /auth/resend-verification-email` - Resends verification code

**Google OAuth:**
- ✅ `POST /auth/google` - Handles Google login/signup, auto-verifies email

**Password Reset:**
- ✅ `POST /auth/forgot-password` - Sends reset email
- ✅ `POST /auth/reset-password` - Resets password with token

**User Info:**
- ✅ `GET /auth/me` - Returns user data including email verification status

#### 4. **Security Features**
- ✅ 24-hour email verification token expiry
- ✅ 1-hour password reset token expiry
- ✅ Account locking after 5 failed login attempts (15 min cooldown)
- ✅ Bcrypt password hashing (10 rounds)
- ✅ JWT token authentication

### **Frontend (Flutter)**

#### 1. **Updated Auth Service** (`lib/services/auth_service.dart`)
- ✅ `login()` - Returns user object (includes email verification status)
- ✅ `register()` - Sends registration data
- ✅ `verifyEmail(token)` - Verifies email with token
- ✅ `resendVerificationEmail(email)` - Resends verification
- ✅ `loginWithGoogle()` - Google OAuth handler
- ✅ `forgotPassword(email)` - Password reset request
- ✅ `resetPassword(token, newPassword)` - Resets password
- ✅ Email verification status tracking (`isEmailVerified` getter)

#### 2. **New Pages**
- ✅ **Email Verification Page** (`lib/pages/verify_email_page.dart`)
  - Shows email verification form
  - Allows manual token entry or click from email link
  - Resend verification email button
  - Info card explaining benefits

- ✅ **Forgot Password Page** (`lib/pages/forgot_password_page.dart`)
  - Step 1: Enter email → sends reset link
  - Step 2: Enter reset token + new password
  - Confirmation states at each step

#### 3. **Enhanced Login Page** (`lib/pages/login_page.dart`)
- ✅ Email/password login form
- ✅ "Forgot password?" link
- ✅ Redirects to email verification if needed
- ✅ Google Sign-In button (placeholder for now)
- ✅ Sign up link
- ✅ Better UI with icons and improved spacing

#### 4. **Enhanced Register Page** (`lib/pages/register_page.dart`)
- ✅ Full name, email, password fields
- ✅ Password confirmation field
- ✅ Show/hide password toggle
- ✅ Terms & conditions checkbox
- ✅ Google Sign-Up button (placeholder for now)
- ✅ Login link
- ✅ Auto-redirects to email verification after signup

---

## 🚀 Setup Instructions

### **Backend Setup**

#### 1. Install Dependencies
```bash
cd backend
npm install
```

#### 2. Configure Environment Variables
```bash
cp .env.example .env
```

Edit `.env` with:
```
MONGODB_URI=mongodb://127.0.0.1:27017/nutripal_db
JWT_SECRET=your_secret_key_here
PORT=4000
NODE_ENV=development

# Email Configuration (Gmail example)
EMAIL_SERVICE=gmail
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-specific-password
FRONTEND_URL=http://localhost:3000

# Google OAuth (optional, for later)
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret
```

#### 3. Gmail Setup (if using Gmail for emails)
1. Enable 2-Factor Authentication on your Gmail account
2. Go to [Google Account Settings](https://myaccount.google.com/apppasswords)
3. Create an "App password" for Mail on Desktop
4. Use this 16-character password in `EMAIL_PASSWORD`

#### 4. Run Backend
```bash
npm run dev
```

Backend starts at `http://localhost:4000`

### **Frontend Setup**

#### 1. Add Google Sign-In Package (Coming Next)
```bash
flutter pub add google_sign_in
```

#### 2. Configure Routes in main.dart
Routes are already added:
- `/login` - Login page
- `/register` - Register page
- `/forgot-password` - Password reset
- `/verify-email` - Email verification

#### 3. Run Frontend
```bash
flutter run
```

---

## 📧 Email Flow

### **Registration Email Verification**
```
User clicks "Register"
  → Email + password saved to DB
  → Verification token generated + expires in 24h
  → Verification email sent
  → Redirects to VerifyEmailPage
  → User clicks link in email OR enters token manually
  → Email marked as verified
  → User can now access app
```

### **Password Reset Flow**
```
User clicks "Forgot Password?""
  → Enters email address
  → Backend sends reset link (valid 1 hour)
  → User clicks link in email
  → Enters new password
  → Password updated
  → Redirected to login
```

---

## 🔗 API Endpoints Summary

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/auth/register` | Register with email/password |
| POST | `/auth/login` | Login with email/password |
| POST | `/auth/google` | Google OAuth login/signup |
| POST | `/auth/verify-email` | Verify email with token |
| POST | `/auth/resend-verification-email` | Resend verification email |
| POST | `/auth/forgot-password` | Request password reset |
| POST | `/auth/reset-password` | Reset password with token |
| GET | `/auth/me` | Get current user info |

---

## ⏭️ Still To Do

### **Frontend - Google Sign-In Integration**
1. Install `google_sign_in` package
2. Configure iOS & Android OAuth credentials
3. Implement `_loginWithGoogle()` in login_page.dart
4. Implement `_signupWithGoogle()` in register_page.dart
5. Handle Google profile picture in user profile

### **Testing**
- [ ] Test email verification flow
- [ ] Test password reset flow
- [ ] Test duplicate email registration
- [ ] Test account locking after failed logins
- [ ] Test expired tokens
- [ ] Google Sign-In functionality
- [ ] Email delivery (actual vs dev mode)

### **Optional Enhancements**
- Social login with Apple, GitHub, Facebook
- Two-factor authentication (2FA)
- Email change functionality
- Account deletion
- Password strength meter
- Email templates with better styling

---

## 🐛 Troubleshooting

### Email Not Sending?
1. Check `.env` has `EMAIL_USER` and `EMAIL_PASSWORD` set
2. Check MongoDB is running: `mongod`
3. Look at backend console logs for error messages
4. In dev mode, check logs for "[DEV]" messages

### Verification Token Not Working?
- Tokens expire after 24 hours
- User can request resend on VerifyEmailPage
- Token is case-sensitive

### Password Reset Not Working?
- Tokens expire after 1 hour
- Ensure new password is at least 6 characters
- Check that passwords match in confirmation field

---

## 📝 Example User Flows

### **New User Signup**
```
Register Page
  ↓
User enters: Name, Email, Password, Agrees to terms
  ↓
Backend creates user, sends verification email
  ↓
VerifyEmailPage (with resend option)
  ↓
User clicks email link or enters code
  ↓
Email verified → HomePage
```

### **Forgot Password**
```
Login Page → "Forgot Password?" link
  ↓
ForgotPasswordPage → User enters email
  ↓
"Reset email sent" message
  ↓
User clicks link in email
  ↓
ForgotPasswordPage → Step 2: Shows token + password fields
  ↓
User enters new password
  ↓
"Password reset successful" → Login Page
```

---

## 🔒 Security Checklist

- ✅ Passwords hashed with bcrypt (10 rounds)
- ✅ JWT tokens with 7-day expiry
- ✅ Account locking after 5 failed attempts
- ✅ Email verification tokens expire in 24h
- ✅ Password reset tokens expire in 1h
- ✅ Google auto-verifies emails
- ✅ HTTPS required in production (use Firebase hosting)
- ⚠️ TODO: Rate limiting on auth endpoints
- ⚠️ TODO: CORS properly configured for production

