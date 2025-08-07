# Localization System

`DynamicList` includes a complete localization system that supports multiple languages and provides a centralized presentation layer for all text strings.

## 🌍 Supported Languages

- 🇺🇸 **English (en)** - Default language
- 🇲🇽 **Spanish - Mexico (es-MX)** - Mexican Spanish
- 🇫🇷 **French (fr)** - French
- 🇧🇷 **Portuguese (pt)** - Portuguese

## 🏗️ Architecture

### DynamicListPresenter

The `DynamicListPresenter` class centralizes all localized strings of the component:

```swift
public final class DynamicListPresenter {
    // Loading States
    public static let loadingContent = NSLocalizedString("loading_content", ...)
    public static let loadingUsers = NSLocalizedString("loading_users", ...)
    public static let loadingProducts = NSLocalizedString("loading_products", ...)
    
    // Error Messages
    public static let networkError = NSLocalizedString("network_error", ...)
    public static let dataNotAvailable = NSLocalizedString("data_not_available", ...)
    public static let serverError = NSLocalizedString("server_error", ...)
    
    // Error Actions
    public static let retry = NSLocalizedString("retry", ...)
    public static let cancel = NSLocalizedString("cancel", ...)
    public static let refresh = NSLocalizedString("refresh", ...)
    
    // Navigation
    public static let profile = NSLocalizedString("profile", ...)
    public static let detail = NSLocalizedString("detail", ...)
    public static let userDetail = NSLocalizedString("user_detail", ...)
    public static let productDetail = NSLocalizedString("product_detail", ...)
    
    // Content Labels
    public static let itemId = NSLocalizedString("item_id", ...)
    public static let price = NSLocalizedString("price", ...)
    public static let category = NSLocalizedString("category", ...)
    public static let available = NSLocalizedString("available", ...)
    public static let buyNow = NSLocalizedString("buy_now", ...)
    
    // Error View Titles
    public static let errorLoading = NSLocalizedString("error_loading", ...)
    public static let somethingWentWrong = NSLocalizedString("something_went_wrong", ...)
    
    // Default Views
    public static let itemDetail = NSLocalizedString("item_detail", ...)
    public static let errorLoadingData = NSLocalizedString("error_loading_data", ...)
}
```

## 📁 File Structure

```
Sources/DynamicList/
├── Core Components/
│   ├── DynamicListContent.swift
│   ├── DynamicListViewModel.swift
│   ├── DynamicListBuilder.swift
│   ├── ViewState.swift
│   └── DefaultErrorView.swift
├── Presentation/
│   ├── DynamicListPresenter.swift
│   ├── en.lproj/
│   │   └── Localizable.strings
│   ├── es-MX.lproj/
│   │   └── Localizable.strings
│   ├── fr.lproj/
│   │   └── Localizable.strings
│   └── pt.lproj/
│       └── Localizable.strings
├── Examples/
├── Documentation/
└── PreviewSupport/
```

## 🚀 Basic Usage

### 1. Using Localized Strings

```swift
// Instead of hardcoded strings
Text("Loading...")

// Use the presenter
Text(DynamicListPresenter.loadingContent)
```

### 2. In Error Views

```swift
VStack {
    Text(DynamicListPresenter.errorLoading)
        .font(.title)
        .fontWeight(.bold)
    
    Text(DynamicListPresenter.networkError)
        .font(.body)
        .foregroundColor(.secondary)
    
    Button(DynamicListPresenter.retry) {
        // Retry action
    }
    .buttonStyle(.borderedProminent)
}
```

### 3. In Loading States

```swift
if isLoading {
    ProgressView(DynamicListPresenter.loadingContent)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
```

### 4. In Navigation

```swift
.navigationTitle(DynamicListPresenter.profile)
.navigationTitle(DynamicListPresenter.userDetail)
.navigationTitle(DynamicListPresenter.productDetail)
```

## 🎯 String Categories

### Loading States
- `loadingContent` - General loading

### Error Messages
- `networkError` - Network error

### Error Actions
- `retry` - Retry

### Navigation
- `profile` - Profile
- `detail` - Detail
- `userDetail` - User detail
- `productDetail` - Product detail

### Content Labels
- `itemID` - Item ID



### Default Views
- `itemDetail` - Item detail
- `errorLoadingData` - Error loading data

## 🌐 Translations by Language

### English (en)
```strings
"loading_content" = "Loading...";
"network_error" = "Network connection failed. Please check your internet connection.";
"retry" = "Retry";
"profile" = "Profile";
```

### Spanish - Mexico (es-MX)
```strings
"loading_content" = "Cargando...";
"network_error" = "Error de conexión de red. Verifica tu conexión a internet.";
"retry" = "Reintentar";
"profile" = "Perfil";
```

### French (fr)
```strings
"loading_content" = "Chargement...";
"network_error" = "Échec de la connexion réseau. Veuillez vérifier votre connexion internet.";
"retry" = "Réessayer";
"profile" = "Profil";
```

### Portuguese (pt)
```strings
"loading_content" = "Carregando...";
"network_error" = "Falha na conexão de rede. Verifique sua conexão com a internet.";
"retry" = "Tentar novamente";
"profile" = "Perfil";
```

## 🔧 Package Configuration

The `Package.swift` includes the necessary configuration for localization:

```swift
let package = Package(
    name: "swift-dynamic-list",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
    ],
    targets: [
        .target(
            name: "DynamicList",
            exclude: ["Documentation/", "Examples/"],
        ),
    ],
)
```

**Note:** Localization resources are automatically included in the module bundle without additional configuration needed in `Package.swift`.

## 📱 Integration with DynamicListBuilder

The `DynamicListBuilder` automatically uses localized strings:

```swift
DynamicListBuilder<User>()
    .items(users)
    .title("Users") // Hardcoded title
    .rowContent { user in
        Text(user.name)
    }
    .detailContent { user in
        VStack {
            Text(user.name)
            Text(DynamicListPresenter.profile) // Localized
        }
        .navigationTitle(DynamicListPresenter.userDetail) // Localized
    }
    .build()
```

## 🎨 Usage Examples

### Custom Error View
```swift
DynamicListBuilder<User>()
    .publisher(failingPublisher)
    .errorContent { error in
        VStack {
            Text(DynamicListPresenter.errorLoading)
                .font(.title)
                .fontWeight(.bold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
            
            Button(DynamicListPresenter.retry) {
                // Retry action
            }
            .buttonStyle(.borderedProminent)
        }
    }
    .build()
```

### Custom Loading State
```swift
DynamicListBuilder<Product>()
    .publisher(productsPublisher)
    .rowContent { product in
        HStack {
            Text(product.name)
            Spacer()
            Text("\(DynamicListPresenter.price): $\(product.price)")
        }
    }
    .build()
```

### Localized Navigation
```swift
DynamicListBuilder<User>()
    .items(users)
    .detailContent { user in
        UserProfileView(user: user)
            .navigationTitle(DynamicListPresenter.profile)
    }
    .build()
```

## 🔄 Adding New Languages

To add support for a new language:

1. **Create the language folder:**
   ```bash
   mkdir -p Sources/DynamicList/Presentation/it.lproj
   ```

2. **Create the strings file:**
   ```strings
   /* DynamicList Localization - Italian */
   
   "loading_content" = "Caricamento...";
   "network_error" = "Errore di connessione di rete. Verifica la tua connessione internet.";
   "retry" = "Riprova";
   "profile" = "Profilo";
   ```

3. **Add new strings to the presenter:**
   ```swift
   public static let newString = NSLocalizedString(
       "new_string",
       bundle: Bundle.module,
       comment: "Description of the new string"
   )
   ```

## ✅ Benefits

1. **Centralization** - All strings in one place
2. **Type Safety** - Safe compilation with autocomplete
3. **Maintainability** - Easy updating and management
4. **Scalability** - Easy to add new languages
5. **Consistency** - Same style throughout the app
6. **Internationalization** - Native support for multiple languages

## 🎯 Best Practices

1. **Always use the presenter** instead of hardcoded strings
2. **Group related strings** in logical sections
3. **Provide descriptive comments** in `NSLocalizedString`
4. **Maintain consistency** in translation style
5. **Test with different languages** during development
6. **Use context variables** when necessary

The localization system makes `DynamicList` truly international! 🌍 