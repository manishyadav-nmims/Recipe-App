# RecipeHub 🍳

A production-grade Flutter recipe application demonstrating Clean Architecture, BLoC state management, offline-first caching, and modern UI patterns.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [State Management](#state-management)
- [Token Refresh Strategy](#token-refresh-strategy)
- [Offline Caching Strategy](#offline-caching-strategy)

---

## Features

- Browse and search recipes with real-time filtering
- Sort by rating, name, cook time, or calories
- Cuisine-based filtering with horizontal chip bar
- Favourites with local persistence
- Offline-first with Hive caching
- Dark mode with persistent theme preference
- Skeleton loading screens and error states
- Infinite scroll pagination with load-more skeletons
- Connectivity-aware refresh with offline banners

---

## Architecture

RecipeHub follows **Clean Architecture** with a strict separation of concerns across three layers. Each feature is self-contained under `features/`, with shared infrastructure in `core/`.

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│   Pages · BLoC · Widgets                │
├─────────────────────────────────────────┤
│             Domain Layer                │
│   Entities · Use Cases · Repositories  │
├─────────────────────────────────────────┤
│              Data Layer                 │
│   Models · Services · Cache · Storage  │
└─────────────────────────────────────────┘
```

### Presentation Layer
Contains Flutter UI (pages, widgets) and BLoC state management. Pages never talk to data sources directly — they dispatch events to a BLoC and react to emitted states. Navigation is handled by `go_router` with each route scoped to its own BLoC instance.

### Domain Layer
Pure Dart — zero Flutter dependencies. Defines:
- **Entities** — plain Dart objects (e.g. `RecipeEntity`) that the UI consumes
- **Use Cases** — single-responsibility classes (e.g. `GetRecipesUseCase`, `ToggleFavoriteUseCase`)
- **Repository interfaces** — abstract contracts the data layer implements

### Data Layer
Implements the domain repository interfaces. Responsible for:
- Calling remote APIs via `RecipeService`
- Reading/writing local Hive cache via `RecipeCacheHelper`
- Mapping raw JSON models (e.g. `RecipeModel`) to domain entities

### Dependency Injection
All dependencies are wired using **GetIt** (`injection_container.dart`). Use cases, repositories, services, and BLoCs are registered at app startup. BLoCs use `registerFactory` so each `BlocProvider` receives a fresh instance — critical for page-scoped blocs (detail page, favourites page).

---
## State Management

RecipeHub uses the **BLoC pattern** (`flutter_bloc`) throughout.

### Why BLoC
- Enforces unidirectional data flow: `Event → BLoC → State → UI`
- States are immutable and exhaustively typed — the UI switches on state type, never on flags
- Business logic is fully testable in isolation from the widget tree

### BLoC Instances

| BLoC | Scope | Registered as |
|------|-------|---------------|
| `AuthBloc` | App-wide | `MultiBlocProvider` in `main.dart` |
| `RecipeBloc` (list) | App-wide | `MultiBlocProvider` in `main.dart` |
| `RecipeBloc` (detail) | Page-scoped | `BlocProvider` in router |
| `RecipeBloc` (favourites) | Page-scoped | `BlocProvider` in router |
| `ThemeBloc` | App-wide | `MultiBlocProvider` in `main.dart` |
| `SplashBloc` | App-wide | `MultiBlocProvider` in `main.dart` |

This prevents detail/favourites states from leaking into the list page — a common BLoC pitfall where shared bloc instances cause state collisions across routes.

### Key States — `RecipeBloc`

```
RecipeInitialState
RecipeLoadingState         ← initial full-screen load
RecipeLoadedState          ← success; holds recipes, filters, sort, pagination
RecipeLoadingMoreState     ← pagination; holds current list while fetching next page
RecipeSearchingState       ← search in progress
RecipeEmptyState           ← empty results (search or favourites)
RecipeErrorState           ← network/parse failure
RecipeDetailLoadingState   ← detail page loading
RecipeDetailLoadedState    ← detail page success
```

### In-Memory Cache for Search / Clear
The list BLoC holds a `_cachedAllRecipes` field. When the user searches, the full list is preserved in memory. Clearing search restores from `_cachedAllRecipes` instantly — no API call, no flicker.

---
## Token Refresh Strategy

RecipeHub implements a **header-based sliding token strategy** via a Dio interceptor. Both tokens travel as custom HTTP headers on every request, and the server silently rotates the access token in response headers — no separate refresh endpoint is ever called.

### How It Works

```
Every API Request
       │
       ▼
AuthInterceptor.onRequest()
  → reads access-token + refresh-token from FlutterSecureStorage
  → injects both into request headers
       │
       ▼
Server processes request
       │
       ├── Valid session
       │     → returns response
       │     → may include new 'access-token' header (silent rotation)
       │
       └── Expired / invalid
             → returns 401 → force re-login
```
This means token rotation is **automatic and invisible** — the user never sees a loading state during refresh, and no separate refresh API call is ever made.

### `onError` — 401 Session Expired

When the server returns `401` (both tokens fully rejected):

1. A `_isDialogShowing` static flag prevents duplicate dialogs when multiple requests fail simultaneously
2. `SecureTokenStorage.clear()` immediately wipes both tokens from encrypted storage
3. A non-dismissible `AlertDialog` forces the user to acknowledge the session expiry
4. On confirmation, the app navigates to `/login` via `AppRouter.navigatorKey`

```dart
if (err.response?.statusCode == 401 && !_isDialogShowing) {
  _isDialogShowing = true;
  Future.microtask(() => _handleUnauthorized());
}
```

### Token Storage — `SecureTokenStorage`

| Token | Storage |
|-------|---------|
| `access-token` | `FlutterSecureStorage` |
| `refresh-token` | `FlutterSecureStorage` |

## Offline Caching Strategy

RecipeHub is **offline-first** — the app is fully usable without a network connection using cached data.

### Storage — Hive
[Hive](https://pub.dev/packages/hive_ce_flutter) was chosen over SQLite for its:
- Zero-native-code setup (pure Dart)
- Fast binary key-value reads suitable for recipe lists
- Simple box-based API with type adapters

### Cache Flow

```
App opens
    │
    ▼
Fetch from API ──── success ──▶ Save to Hive ──▶ Display
    │
    └── failure
          │
          ▼
    Load from Hive
          │
    ┌─────┴──────┐
  found        empty
    │              │
    ▼              ▼
Display        Show error
(isOffline     state
= true)
```

### What is Cached
| Data | Storage | TTL |
|------|---------|-----|
| Recipe list | Hive (`RecipeCacheHelper`) | Session |
| Favourite IDs | Hive (`UserLocalStorage`) | Persistent |
| User session | Hive (`UserLocalStorage`) | Persistent |

### Offline Indicators
- **`OfflineBanner`** — animated slide-in pill shown in the filter bar when displaying cached data (`state.isOffline == true`)
- **`MaterialBanner`** — shown via `ConnectivityMixin.showOfflineBanner()` when a pull-to-refresh is attempted without connectivity; auto-dismisses after 4 seconds
- **Pagination guard** — `_onLoadMore` returns early when `state.isOffline == true` to prevent duplicate cached data appending on scroll

### ConnectivityMixin
A shared `mixin ConnectivityMixin<T extends StatefulWidget> on State<T>` provides `checkConnectivity()`, `showOfflineBanner()`, and `hideOfflineBanner()` to any page — no code duplication.

---
