# NovaMart 🛍️

![Swift](https://img.shields.io/badge/Swift-6.0-orange?style=flat&logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-blue?style=flat&logo=swift)
![iOS](https://img.shields.io/badge/iOS-17%2B-black?style=flat&logo=apple)
![Xcode](https://img.shields.io/badge/Xcode-16%2B-147EFB?style=flat&logo=xcode)
![License](https://img.shields.io/badge/License-MIT-green?style=flat)

A modern, full-featured iOS e-commerce application built entirely with **SwiftUI** and Swift 6. NovaMart demonstrates real-world app architecture with a clean, glassmorphism-inspired design system, role-based access, and a rich shopping experience.

---

## Screenshots

### Customer App

| Home Screen | Product Detail | Cart & Checkout |
|:-----------:|:--------------:|:---------------:|
| ![Home](https://placehold.co/200x420/6E3AFF/FFFFFF?text=🏠+Home\nHero+Banner\nCategories\nFlash+Sale&font=sans) | ![Detail](https://placehold.co/200x420/00D4AA/FFFFFF?text=📦+Product\nImage+Carousel\nVariants\nAdd+to+Cart&font=sans) | ![Cart](https://placehold.co/200x420/FF6B35/FFFFFF?text=🛒+Cart\nPrice+Summary\nCoupon+Code\nCheckout&font=sans) |

| Search | Wishlist | Orders |
|:------:|:--------:|:------:|
| ![Search](https://placehold.co/200x420/1A0A2E/FFFFFF?text=🔍+Search\nTrending\nRecent\nFilters&font=sans) | ![Wishlist](https://placehold.co/200x420/FF3B30/FFFFFF?text=❤️+Wishlist\nSaved+Items\nQuick+Add\nto+Cart&font=sans) | ![Orders](https://placehold.co/200x420/34C759/FFFFFF?text=📋+Orders\nOrder+Status\nTracking\nTimeline&font=sans) |

### Auth & Onboarding

| Login | Register | OTP Verification |
|:-----:|:--------:|:----------------:|
| ![Login](https://placehold.co/200x420/0A1628/FFFFFF?text=🔐+Login\nEmail+%26+Password\nBiometric\nFace+ID&font=sans) | ![Register](https://placehold.co/200x420/0D0A1A/FFFFFF?text=📝+Register\nFull+Name\nEmail\nPassword&font=sans) | ![OTP](https://placehold.co/200x420/1A0A2E/FFFFFF?text=✉️+OTP\n6-Digit+Code\nAuto+Paste\nResend&font=sans) |

### Admin Dashboard

| Overview | Product Manager | Add Product |
|:--------:|:---------------:|:-----------:|
| ![Admin](https://placehold.co/200x420/6E3AFF/FFFFFF?text=📊+Admin\nRevenue+Chart\nOrders+Chart\nStats+Grid&font=sans) | ![Products](https://placehold.co/200x420/9B59FF/FFFFFF?text=🗂️+Products\nList+%26+Search\nEdit+Delete\nBulk+Actions&font=sans) | ![Add](https://placehold.co/200x420/FF6B35/FFFFFF?text=➕+Add+Product\nPhoto+Picker\nVariants\nInventory&font=sans) |

> **Note:** Replace placeholder images above with actual simulator screenshots after running the project.

---

## Features

### Customer Experience
- **Animated Hero Banner** — swipeable product carousel with spring transitions, thumbnail navigation strip, and auto-advance timer
- **Category Browsing** — horizontally scrollable category chips that navigate to filtered product grids
- **Flash Sale** — countdown timer with live sale products
- **Featured & Trending** — curated product sections with horizontal scroll cards
- **Personalized Section** — "For You" recommendations
- **Product Detail** — image carousel, variant selector, ratings & reviews, related products, add-to-cart
- **Wishlist** — persistent wishlist with badge counter in the tab bar
- **Cart & Checkout** — multi-step checkout flow (Address → Payment → Review → Success)
- **Order Tracking** — live order status with timeline view and return requests
- **Search** — full-text search with recent searches, trending terms, and filter sheet
- **Notifications** — notification center with unread badge
- **Profile** — account management, addresses, payment methods, preferences

### Admin Dashboard
- **Overview** — revenue chart, orders chart, key stats grid
- **Product Manager** — add/edit/delete products with image picker (up to 6 photos), bulk actions, inventory view
- **Order Manager** — view and update order statuses
- **Customer Manager** — browse customer accounts
- **Coupon Manager** — create and manage discount codes
- **Secure sign-out** with confirmation alert

### Auth & Security
- Email + password login (demo mode)
- Biometric prompt (Face ID / Touch ID)
- OTP verification flow
- Forgot password flow
- Role-based routing: `admin@novamart.com` → Admin Dashboard, all other emails → Customer app
- Session persistence via Keychain + UserDefaults

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 6 |
| UI Framework | SwiftUI |
| State Management | `@Observable` (Swift Observation framework) |
| Architecture | MVVM + Environment-based AppState |
| Persistence | Keychain (auth token), UserDefaults (preferences), CoreData (cache) |
| Async | Swift `async/await`, `Task` |
| Image Loading | Custom `AsyncCachedImage` with NSCache |
| Haptics | Custom `HapticService` wrapping CoreHaptics |
| Design System | Custom `AppTheme`, `AppSpacing`, Glassmorphism modifiers |
| Animations | SwiftUI spring animations, staggered list appearance |
| Testing | Swift Testing framework + XCUIAutomation |

---

## Architecture

```
NovaMart/
├── AppState.swift              # Global observable state (auth, cart, wishlist, navigation)
├── NovaMartApp.swift           # App entry point, role-based root routing
├── MainTabView.swift           # Customer tab bar (Home, Search, Wishlist, Cart, Orders, Profile)
│
├── Core/
│   ├── Design/                 # AppTheme, AppSpacing, AppAnimations, GlassModifiers
│   ├── Models/                 # Product, Order, User, Cart, Category, SearchFilter…
│   ├── Services/               # ProductService, AuthService, CartService, SearchService…
│   ├── Storage/                # KeychainService, CacheService, CoreDataStack
│   └── Extensions/             # Color, View, Date helpers
│
├── Components/                 # Reusable UI: GlassCard, PriceView, RatingStarsView, ToastView…
│
└── Features/
    ├── Auth/                   # Login, Register, OTP, Biometric, ForgotPassword
    ├── Home/                   # HeroBanner, CategoryScroll, FeaturedCollection, FlashSale…
    ├── Products/               # ProductCard, ProductDetail, ProductGrid, FilterSheet…
    ├── Search/                 # SearchView, SearchViewModel
    ├── Cart/                   # CartView, CheckoutFlow (3 steps + success)
    ├── Orders/                 # OrderList, OrderDetail, OrderTracking, ReturnRequest
    ├── Wishlist/               # WishlistView
    ├── Profile/                # ProfileView, settings
    ├── Notifications/          # NotificationCenterView
    ├── Onboarding/             # SplashView, OnboardingFlow
    └── Admin/                  # AdminDashboard, ProductManager, OrderManager, CustomerManager, CouponManager
```

---

## Getting Started

### Requirements
- Xcode 16+
- iOS 17+ deployment target
- macOS 14+ (for development)

### Run the project

1. Clone the repository:
   ```bash
   git clone https://github.com/aboashraf169/NovaMart.git
   cd NovaMart
   ```

2. Open in Xcode:
   ```bash
   open NovaMart.xcodeproj
   ```

3. Select a simulator (iPhone 15 Pro or later recommended) and press **Run** (`⌘R`).

### Demo Accounts

| Role | Email | Password |
|---|---|---|
| Customer | any email | any password |
| Admin | `admin@novamart.com` | `Admin123` |

> The app runs fully in **demo/mock mode** — no backend required. All data is generated locally via `Product.samples` and mock services.

---

## Design System

NovaMart uses a custom design system built on top of SwiftUI:

| Token | Value |
|---|---|
| Primary color | `#6E3AFF` (Purple) |
| Secondary color | `#00D4AA` (Teal) |
| Accent color | `#FF6B35` (Orange) |
| Success | `#34C759` |
| Error | `#FF3B30` |
| Base spacing unit | 8pt grid |
| Corner radius (card) | 16pt continuous |
| Corner radius (large) | 24pt continuous |

- **Glass**: `.glassCard()`, `.buttonStyle(.glass)` — `ultraThinMaterial` based glassmorphism
- **Animations**: Spring-based transitions, staggered list appearance, bouncy micro-interactions
- **Typography**: System font with semantic weight/size scale (`display`, `title1–3`, `body`, `label`, `caption`, `price`)

---

## License

MIT License — free to use for personal and commercial projects.

---

Built with SwiftUI by [aboashraf169](https://github.com/aboashraf169)
