# Project: Shamel Service Super App (شامل)

## Overview
A comprehensive service marketplace connecting users with service providers across various categories (Daily chores, Maintenance, Professional services, etc.). The app includes a multi-role system (User, Admin, Super Admin), a secure payment gateway with escrow, and real-time messaging.

## Key Flows & Screens

### 1. User Experience (Mobile)
- **Splash & Onboarding:** Introduction to the app's value proposition.
- **Login/Signup:** Authentication via Phone Number or Email.
- **Home Screen:** Search bar, category grid (Maintenance, Cleaning, Delivery, Professional, etc.), featured offers, and recent services.
- **Service Details & Provider Profile:** View details, ratings, and previous work.
- **Booking & Checkout:** Service selection, scheduling, and payment (Wallet, Card, Cash).
- **Messaging/Chat:** Real-time communication between user and provider.
- **My Orders:** Tracking active and past service requests.
- **User Wallet:** View balance, add funds, and transaction history.

### 2. Provider Experience (Mobile)
- **Provider Dashboard:** Statistics on earnings, active jobs, and ratings.
- **Create Offer/Service:** Form to add new services with pricing and descriptions.
- **Incoming Requests:** Accept/Decline user requests.
- **Provider Wallet:** Withdrawal requests and earning history.

### 3. Admin & Super Admin (Web Dashboard - Responsive)
- **Super Admin Dashboard:** Full control over users, providers, and financial oversight.
- **Finance Management:** Monitor transactions, manage escrow, and add/edit payment methods.
- **User/Provider Management:** Verify accounts, suspend users, and handle disputes.
- **Settings:** App configuration, category management, and system logs.

## Technical Structure (Data Logic)
- **Auth:** Separate login portals for Admins and Users.
- **Database Logic:** Relational structure for Users, Services, Orders, Messages, and Transactions.
- **Payment System:** Integrated wallet system with Super Admin oversight on all peer-to-peer transfers.
