# Localization System

El `DynamicList` incluye un sistema completo de localización que soporta múltiples idiomas y proporciona una capa de presentación centralizada para todas las cadenas de texto.

## 🌍 Idiomas Soportados

- 🇺🇸 **English (en)** - Idioma por defecto
- 🇲🇽 **Spanish - Mexico (es-MX)** - Español mexicano
- 🇫🇷 **French (fr)** - Francés
- 🇧🇷 **Portuguese (pt)** - Portugués

## 🏗️ Arquitectura

### DynamicListPresenter

La clase `DynamicListPresenter` centraliza todas las cadenas localizadas del componente:

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

## 📁 Estructura de Archivos

```
Sources/DynamicList/
├── Core Components/
│   ├── DynamicList.swift
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

## 🚀 Uso Básico

### 1. Usar Cadenas Localizadas

```swift
// En lugar de strings hardcodeados
Text("Loading...")

// Usar el presenter
Text(DynamicListPresenter.loadingContent)
```

### 2. En Vistas de Error

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

### 3. En Estados de Carga

```swift
if isLoading {
    ProgressView(DynamicListPresenter.loadingContent)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
```

### 4. En Navegación

```swift
.navigationTitle(DynamicListPresenter.profile)
.navigationTitle(DynamicListPresenter.userDetail)
.navigationTitle(DynamicListPresenter.productDetail)
```

## 🎯 Categorías de Cadenas

### Loading States
- `loadingContent` - Carga general
- `loadingUsers` - Carga de usuarios
- `loadingProducts` - Carga de productos

### Error Messages
- `networkError` - Error de red
- `dataNotAvailable` - Datos no disponibles
- `serverError` - Error del servidor
- `unauthorizedAccess` - Acceso no autorizado
- `dataCorrupted` - Datos corruptos
- `connectionTimeout` - Timeout de conexión

### Error Actions
- `retry` - Reintentar
- `cancel` - Cancelar
- `refresh` - Actualizar

### Navigation
- `profile` - Perfil
- `detail` - Detalle
- `userDetail` - Detalle de usuario
- `productDetail` - Detalle de producto

### Content Labels
- `itemID` - ID del item
- `price` - Precio
- `category` - Categoría
- `available` - Disponible
- `buyNow` - Comprar ahora

### Error View Titles
- `errorLoading` - Error al cargar
- `somethingWentWrong` - Algo salió mal

### Default Views
- `itemDetail` - Detalle del item
- `errorLoadingData` - Error al cargar datos

## 🌐 Traducciones por Idioma

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

## 🔧 Configuración del Package

El `Package.swift` incluye la configuración necesaria para la localización:

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

**Nota:** Los recursos de localización se incluyen automáticamente en el bundle del módulo sin necesidad de configuración adicional en `Package.swift`.

## 📱 Integración con DynamicListBuilder

El `DynamicListBuilder` usa automáticamente las cadenas localizadas:

```swift
DynamicListBuilder<User>()
    .items(users)
    .title("Users") // Título hardcodeado
    .rowContent { user in
        Text(user.name)
    }
    .detailContent { user in
        VStack {
            Text(user.name)
            Text(DynamicListPresenter.profile) // Localizado
        }
        .navigationTitle(DynamicListPresenter.userDetail) // Localizado
    }
    .build()
```

## 🎨 Ejemplos de Uso

### Error View Personalizada
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

### Loading State Personalizado
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

### Navegación Localizada
```swift
DynamicListBuilder<User>()
    .items(users)
    .detailContent { user in
        UserProfileView(user: user)
            .navigationTitle(DynamicListPresenter.profile)
    }
    .build()
```

## 🔄 Agregar Nuevos Idiomas

Para agregar soporte para un nuevo idioma:

1. **Crear la carpeta de idioma:**
   ```bash
   mkdir -p Sources/DynamicList/Presentation/it.lproj
   ```

2. **Crear el archivo de strings:**
   ```strings
   /* DynamicList Localization - Italian */
   
   "loading_content" = "Caricamento...";
   "network_error" = "Errore di connessione di rete. Verifica la tua connessione internet.";
   "retry" = "Riprova";
   "profile" = "Profilo";
   ```

3. **Agregar nuevas cadenas al presenter:**
   ```swift
   public static let newString = NSLocalizedString(
       "new_string",
       bundle: Bundle.module,
       comment: "Description of the new string"
   )
   ```

## ✅ Beneficios

1. **Centralización** - Todas las cadenas en un solo lugar
2. **Type Safety** - Compilación segura con autocompletado
3. **Mantenibilidad** - Fácil actualización y gestión
4. **Escalabilidad** - Fácil agregar nuevos idiomas
5. **Consistencia** - Mismo estilo en toda la app
6. **Internacionalización** - Soporte nativo para múltiples idiomas

## 🎯 Mejores Prácticas

1. **Siempre usar el presenter** en lugar de strings hardcodeados
2. **Agrupar cadenas relacionadas** en secciones lógicas
3. **Proporcionar comentarios descriptivos** en `NSLocalizedString`
4. **Mantener consistencia** en el estilo de traducción
5. **Probar con diferentes idiomas** durante el desarrollo
6. **Usar variables de contexto** cuando sea necesario

¡El sistema de localización hace que `DynamicList` sea verdaderamente internacional! 🌍 