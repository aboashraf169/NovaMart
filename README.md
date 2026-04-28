# NovaMart 🛍️

A modern, full-featured iOS e-commerce application built entirely with **SwiftUI** and Swift 6. NovaMart demonstrates real-world app architecture with a clean, glassmorphism-inspired design system, role-based access, and a rich shopping experience.

---

## Screenshots

> Run the project in Xcode Simulator to explore the full UI.

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
   git clone https://github.com/mido-mj/NovaMart.git
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

- **Colors**: Purple primary (`#6E3AFF`), teal secondary (`#00D4AA`), orange accent (`#FF6B35`)
- **Typography**: System font with semantic weight/size scale
- **Spacing**: 8pt grid (`xs=4, sm=8, md=16, lg=24, xl=32, xxl=48`)
- **Glass**: `.glassCard()`, `.buttonStyle(.glass)` — `ultraThinMaterial` based glassmorphism
- **Animations**: Spring-based transitions, staggered list appearance, bouncy micro-interactions

---

## License

MIT License — free to use for personal and commercial projects.

---

Built with SwiftUI by [mido-mj](https://github.com/mido-mj)
