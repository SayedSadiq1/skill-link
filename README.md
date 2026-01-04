# Skill Link

## GitHub Repository
[https://github.com/SayedSadiq1/skill-link.git](https://github.com/SayedSadiq1/skill-link.git)

## Group Members
| Name | ID |
|------|----|
| Nasser Nawar | 202203117 |
| Sayed Sadeq | 202305013 |
| Ali Yusuf | 202304419 |
| Ammar Rabeea | 202200881 |
| Sayed Hussain Majed | 202300671 |
| Elias Alsaegh | 202300428 |

## Main Features
| Developer | Features | Tester |
|-----------|----------|--------|
| Ammar Rabea | Account Setup, Authentication & Role Management \| Profile Management | Nasser Nawar |
| Ali Yusuf | Favourites \| Settings | Sayed Sadeq |
| Sayed Sadeq | Admin Console \| Messaging | Ali Yusuf |
| Sayed Husain Majed | Payments & Transaction Handling \| Reviews & Ratings | Elias Alsaegh |
| Elias Alsaegh | Service Details \| Booking Overview | Sayed Husain Majed |
| Nasser Nawar | Home Page \| Service Discovery: Search | Ammar Rabea |

## Extra Features
N/A

## Design Changes

### Login & Profile:
- Removed welcome page background for a cleaner UI
- Replaced custom 6-digit reset with Firebase email password reset for better security
- Merged interest selection into seeker profile for improved UX

### Settings:
- Removed language, theme, email alerts, SMS alerts, phone number, 2FA, and device management
- Added About App, Logout, Data Sharing Preferences, and App Permissions
- Changed account info to read-only display

### Favorites:
- Removed saved services and transaction history
- Added rated services
- Removed sorting
- Added app permissions

### Admin:
- Deleted Service overview
- Made all buttons in service management suspend and activate
- Merged the reports moderations and report details in one page

### Chat:
- Refined the design more

### Search Service and Home Page:
- Availability screen shows date selection + time of day buttons
- Changed popular categories to suggested categories
- Removed the home button in tab bar and changed the settings button and putted In tab bar
- Deleted job request screens
- In add service screen, added more stuff such as description, price, disclaimers etc…

### Service Details
- Added an availability indicator
- A button for the provider to edit their service replaces the “Book this service” button when they provider is looking at their services
- Activation/Deactivation functionality for services
- Report page now includes a dropdown menu for the possible reasons for reporting a service, replacing the old description box
- Removed the “Important Notice” block as it felt like unnecessary bloat
- There are few other minor visual changes such as the disclaimer fields

### Bookings Overview
- The ”tab” buttons in the Figma design were abandoned for the classical iOS tabs at the bottom
- An additional tab, “Pending” is visible for providers and shows them requests for their services
- The context menu on each booking cell is different on each page and role
- The design otherwise remains entirely faithful to the Figma prototype

## Libraries, Packages, External Code Implementations

- **Firebase Authentication**: Used for user registration, login, logout, and secure user identification via unique user IDs (UIDs)
- **Cloudinary**: Used for uploading, storing, and retrieving user profile images. Provides secure image URLs that are saved in Firestore and loaded dynamically within the application

## Project Setup Steps

1. Clone or download the project repository
2. Open the project using Xcode 16.4
3. Ensure Swift Package Manager dependencies are resolved
4. Confirm GoogleService-Info.plist is included in the project
5. Select an iOS simulator (e.g. iPhone 16 Pro)
6. Build and run the application

## Testing Simulator
iPhone 16 Pro

## Admin Login Credentials
Email: admin@skilllink.com
Password: Bahrain2019
