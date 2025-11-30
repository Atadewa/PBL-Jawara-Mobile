# Dashboard Architecture Diagram

## 🏗️ Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                   │
│  (UI Components - What user sees)                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │               HomeScreen                          │  │
│  │  - Consumer<DashboardProvider>                   │  │
│  │  - Pull-to-refresh support                       │  │
│  │  - Error/Loading UI                              │  │
│  └──────────────────────────────────────────────────┘  │
│           │                                  │         │
│           ├─ DashboardHeader                │         │
│           │  └─ Title + Subtitle            │         │
│           │                                 │         │
│           └─ DashboardContent              │         │
│              └─ Stat Cards                  │         │
│                                             │         │
│                                    Rebuild on         │
│                                    state change       │
│                                             │         │
└─────────────────────────────────────────────┼─────────┘
                                              │
                                              ▼
┌─────────────────────────────────────────────────────────┐
│                 STATE MANAGEMENT LAYER                  │
│  (Business Logic - State & Events)                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │          DashboardProvider                        │  │
│  │  (ChangeNotifier)                                │  │
│  │                                                  │  │
│  │  State: loading, loaded, error                  │  │
│  │  Methods:                                        │  │
│  │  - loadDashboard()                              │  │
│  │  - refreshDashboard()                           │  │
│  │                                                  │  │
│  │  Getters:                                        │  │
│  │  - isLoading, isLoaded, isError                 │  │
│  │  - data, error                                   │  │
│  └──────────────────────────────────────────────────┘  │
│                       │                                 │
│                       │ delegates to                    │
│                       ▼                                 │
│  ┌──────────────────────────────────────────────────┐  │
│  │        DashboardRepository                        │  │
│  │  (Abstraction - Data source neutral)             │  │
│  │                                                  │  │
│  │  - getDashboardData()                           │  │
│  │  - refreshDashboardData()                       │  │
│  │  - _handleError()                               │  │
│  └──────────────────────────────────────────────────┘  │
│                       │                                 │
│                       │ uses                            │
│                       ▼                                 │
│  ┌──────────────────────────────────────────────────┐  │
│  │        DashboardService                           │  │
│  │  (Data source - API or local)                    │  │
│  │                                                  │  │
│  │  - getDashboardData()                           │  │
│  │  - refreshDashboardData()                       │  │
│  │  - _getDummyWidgets()                           │  │
│  │  - apiCall() [template]                         │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
                                              │
                                              ▼
┌─────────────────────────────────────────────────────────┐
│                    DATA LAYER                           │
│  (Models & External Services)                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │           DashboardModel                          │  │
│  │                                                  │  │
│  │  - DashboardData                                │  │
│  │    ├── title                                    │  │
│  │    ├── subtitle                                 │  │
│  │    ├── widgets: List<DashboardWidget>          │  │
│  │    └── lastUpdated                              │  │
│  │                                                  │  │
│  │  - DashboardWidget                              │  │
│  │    ├── id                                       │  │
│  │    ├── type                                     │  │
│  │    ├── title                                    │  │
│  │    ├── value                                    │  │
│  │    ├── icon                                     │  │
│  │    └── color                                    │  │
│  │                                                  │  │
│  │  Methods:                                        │  │
│  │  - fromJson() [API response → Model]            │  │
│  │  - toJson() [Model → JSON]                      │  │
│  └──────────────────────────────────────────────────┘  │
│                       │                                 │
│                       ├─ API Call (Dummy atau Real)    │
│                       │  └─ HTTP GET                   │
│                       │                                 │
│                       └─ Local Cache (Optional)         │
│                          └─ SharedPreferences          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow Sequence

```
User opens app
     │
     ▼
HomeScreen.initState()
     │
     ├─ context.read<DashboardProvider>()
     │
     ▼
DashboardProvider.loadDashboard()
     │
     ├─ _setLoading() → state = loading
     │
     ▼
DashboardRepository.getDashboardData()
     │
     ▼
DashboardService.getDashboardData()
     │
     ├─ Network delay simulation (500ms)
     │
     ▼
_getDummyWidgets() atau API call
     │
     ▼
DashboardData.fromJson(response)
     │
     ▼
Return data to Provider
     │
     ├─ _setLoaded() → state = loaded, notify listeners
     │
     ▼
Consumer<DashboardProvider> rebuilds
     │
     ▼
UI updated dengan data baru
```

## 📱 Widget Tree

```
Scaffold
└─ Consumer<DashboardProvider>
   ├─ if (isLoading)
   │  └─ CircularProgressIndicator
   │
   ├─ if (isError)
   │  └─ Column
   │     ├─ Icon(error)
   │     ├─ Text(error message)
   │     └─ ElevatedButton(Retry)
   │
   └─ if (isLoaded)
      └─ RefreshIndicator
         └─ Column
            ├─ Container (Stack)
            │  ├─ DashboardHeader
            │  │  └─ Positioned
            │  │     ├─ Container (logo)
            │  │     └─ Container (title area)
            │  │        ├─ Text (title)
            │  │        └─ Text (subtitle)
            │  │
            │  └─ DashboardContent
            │     └─ Positioned (stat cards)
            │        ├─ Container (card 1)
            │        ├─ Container (card 2)
            │        ├─ Container (card 3)
            │        └─ Container (card 4)
            │
            └─ Container
               └─ Text("Aplikasi Manajemen RT/RW")
```

## 🔑 Key Components

```
┌─ PRESENTATION ──────────────────────────────────────┐
│                                                     │
│  HomeScreen                                         │
│  ├─ Load data on init                              │
│  ├─ Display loading/error/data state               │
│  ├─ Pull-to-refresh                                │
│  └─ Respond to provider changes                    │
│                                                     │
│  DashboardHeader (Reusable Widget)                 │
│  ├─ Display title                                  │
│  └─ Display subtitle                               │
│                                                     │
│  DashboardContent (Reusable Widget)                │
│  ├─ Display stat cards                             │
│  ├─ Dynamic icon rendering                         │
│  └─ Color-coded display                            │
│                                                     │
└─────────────────────────────────────────────────────┘
         △                                    
         │                                    
┌────────┴──────────────────────────────────┐
│ STATE MANAGEMENT                          │
│                                           │
│ DashboardProvider (ChangeNotifier)        │
│ ├─ Manage loading/loaded/error states    │
│ ├─ Hold dashboard data                    │
│ ├─ Provide methods for UI                │
│ └─ Notify listeners on change             │
│                                           │
└─────────────────────────────────────────────
         △                                    
         │                                    
┌────────┴──────────────────────────────────┐
│ DATA ABSTRACTION                          │
│                                           │
│ DashboardRepository                       │
│ ├─ Implement data fetching logic         │
│ ├─ Error handling                         │
│ └─ Data normalization                     │
│                                           │
└─────────────────────────────────────────────
         △                                    
         │                                    
┌────────┴──────────────────────────────────┐
│ DATA SOURCES                              │
│                                           │
│ DashboardService                          │
│ ├─ API calls (HTTP)                      │
│ ├─ Local cache (SharedPreferences)       │
│ └─ Dummy data (for testing)              │
│                                           │
│ DashboardModel                            │
│ ├─ JSON serialization                     │
│ └─ Type safety                            │
│                                           │
└─────────────────────────────────────────────
```

## 🔀 State Transitions

```
                    ┌─────────┐
                    │ INITIAL │
                    └────┬────┘
                         │
                         │ loadDashboard()
                         ▼
                    ┌─────────┐
                    │LOADING  │
                    └────┬────┘
                    ┌───┴───┐
                    │       │
        (success)   │       │   (error)
                    ▼       ▼
              ┌──────┐   ┌──────┐
              │LOADED│   │ERROR │
              └──┬───┘   └──┬───┘
         refresh │          │
                 └──────┬───┘
                        │
                        ▼
                   ┌─────────┐
                   │ LOADING │ (refresh)
                   └─────────┘
```

## 🎯 Dependency Injection

```
Dependency Chain:

HomeScreen
    ↓
    needs: DashboardProvider
    ↓
DashboardProvider
    ↓
    needs: DashboardRepository
    ↓
DashboardRepository
    ↓
    needs: DashboardService
    ↓
DashboardService
    ↓
    uses: HTTP client atau Local storage
```

## 📊 Error Handling Flow

```
API Call
    ↓
try-catch
    ├─ Success (200) → DashboardData
    ├─ 401 (Unauthorized) → UnauthorizedException
    ├─ 404 (Not Found) → NotFoundException
    ├─ 5xx (Server Error) → ServerException
    ├─ Timeout → TimeoutException
    ├─ No Internet → NoInternetException
    └─ Unknown → Generic Exception
        ↓
    Handled by Repository
        ↓
    Propagated to Provider
        ↓
    _setError() called
        ↓
    UI displays error state with retry button
```

---

**Diagram Version:** 1.0
**Last Updated:** November 27, 2025
