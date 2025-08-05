# 📱 DynamicList

Una biblioteca SwiftUI moderna y modular para crear listas dinámicas con soporte completo para datos reactivos, estados de carga, búsqueda avanzada y múltiples tipos de listas.

## ✨ Características Principales

### 🎯 **Listas Simples y con Secciones**
- **DynamicList**: Listas tradicionales con items planos
- **SectionedDynamicList**: Listas organizadas en secciones con headers/footers

### 🔄 **Reactividad Completa**
- Integración nativa con Combine Publishers
- Soporte para datos estáticos y reactivos
- Manejo automático de estados de carga

### 🎨 **UI Personalizable**
- Contenido de filas y detalles completamente configurable
- Vistas de error personalizables
- Skeleton loading configurables
- Búsqueda avanzada con estrategias personalizables

### 🔍 **Sistema de Búsqueda Avanzado**
- Múltiples estrategias de búsqueda (parcial, exacta, tokenizada)
- Configuración de placement de barra de búsqueda
- Protocolo `Searchable` para items buscables
- Estrategias personalizables

### 🏗️ **Arquitectura Modular**
- APIs públicas bien definidas
- Implementación privada encapsulada
- Separación clara de responsabilidades
- Fácil extensión y personalización

## 🚀 Instalación

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/tu-usuario/DynamicList.git", from: "1.0.0")
]
```

### Requisitos

- iOS 17.0+
- macOS 14.0+
- watchOS 10.0+
- tvOS 17.0+
- Swift 5.9+

## 📖 Uso Rápido

### Lista Simple

```swift
import SwiftUI
import DynamicList

struct ContentView: View {
    let users = [
        User(id: "1", name: "Ana", email: "ana@example.com"),
        User(id: "2", name: "Bob", email: "bob@example.com")
    ]
    
    var body: some View {
        DynamicListBuilder<User>()
            .items(users)
            .rowContent { user in
                HStack {
                    Text(user.name)
                        .font(.headline)
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .detailContent { user in
                VStack(spacing: 20) {
                    Text(user.name)
                        .font(.largeTitle)
                    Text(user.email)
                        .font(.title2)
                }
            }
            .title("Usuarios")
            .searchable(prompt: "Buscar usuarios...")
            .build()
    }
}
```

### Lista con Secciones

```swift
struct SectionedContentView: View {
    let sections = [
        ListSection(
            title: "Administradores",
            items: adminUsers,
            footer: "\(adminUsers.count) administradores"
        ),
        ListSection(
            title: "Usuarios",
            items: regularUsers,
            footer: "\(regularUsers.count) usuarios"
        )
    ]
    
    var body: some View {
        SectionedDynamicListBuilder<User>()
            .sections(sections)
            .rowContent { user in
                HStack {
                    Text(user.name)
                        .font(.headline)
                    Text(user.role)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .detailContent { user in
                UserDetailView(user: user)
            }
            .title("Usuarios por Rol")
            .build()
    }
}
```

### Lista Reactiva

```swift
struct ReactiveListView: View {
    var body: some View {
        DynamicListBuilder<User>()
            .publisher(userService.fetchUsers())
            .rowContent { user in UserRowView(user: user) }
            .detailContent { user in UserDetailView(user: user) }
            .errorContent { error in
                VStack {
                    Text("Error: \(error.localizedDescription)")
                    Button("Reintentar") { /* lógica de reintento */ }
                }
            }
            .skeletonContent {
                // Skeleton personalizado
                List(0..<5, id: \.self) { _ in
                    UserSkeletonRow()
                }
            }
            .searchable(
                prompt: "Buscar usuarios...",
                strategy: TokenizedMatchStrategy()
            )
            .build()
    }
}
```

## 🏗️ Arquitectura Modular

`DynamicList` está organizado en una arquitectura modular que separa claramente las responsabilidades:

```
Sources/DynamicList/
├── Public/                    # APIs públicas del paquete
├── Private/                   # Implementaciones internas
│   ├── UI/                    # Componentes de interfaz de usuario
│   │   ├── Dynamic List/      # Listas simples
│   │   ├── Sectioned Dynamic List/ # Listas con secciones
│   │   ├── Default Views/     # Vistas por defecto
│   │   └── Shared/            # Componentes compartidos
│   ├── Domain/                # Lógica de dominio
│   │   └── Strategies/        # Estrategias de búsqueda
│   └── Presentation/          # Componentes de presentación
├── PreviewSupport/            # Soporte para SwiftUI Previews
└── Documentation/             # Documentación del proyecto
```

### 🎯 **Dynamic List**
- `DynamicList.swift` - Vista principal
- `DynamicListViewModel.swift` - ViewModel
- `DynamicListBuilder.swift` - Builder pattern
- `DynamicListViewState.swift` - Estados de vista
- `SearchConfiguration.swift` - Configuración de búsqueda

### 📋 **Sectioned Dynamic List**
- `SectionedDynamicList.swift` - Vista principal
- `SectionedDynamicListViewModel.swift` - ViewModel
- `SectionedDynamicListBuilder.swift` - Builder pattern
- `SectionedListViewState.swift` - Estados de vista
- `ListSection.swift` - Modelo de datos

### 🔄 **Shared Components**
- `LoadingState.swift` - Estados de carga compartidos

### 🎨 **Default Views**
- `DefaultRowView.swift` - Vista de fila por defecto
- `DefaultDetailView.swift` - Vista de detalle por defecto
- `DefaultErrorView.swift` - Vista de error por defecto
- `DefaultSkeletonView.swift` - Skeleton loading por defecto
- `DefaultSectionedSkeletonView.swift` - Skeleton para secciones

## 🎨 Características Avanzadas

### Estados de Carga Inteligentes

```swift
DynamicListBuilder<User>()
    .publisher(userService.fetchUsers())
    .skeletonContent {
        // Skeleton personalizado que coincide con tu diseño
        List(0..<8, id: \.self) { _ in
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 20)
                        .frame(maxWidth: .infinity * 0.8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 16)
                        .frame(maxWidth: .infinity * 0.6)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .redacted(reason: .placeholder)
    }
    .build()
```

### Búsqueda Avanzada

`DynamicList` incluye un sistema de búsqueda avanzado con múltiples estrategias:

#### Búsqueda Simple

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(prompt: "Buscar usuarios...")
    .build()
```

#### Búsqueda con Estrategia Personalizada

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Buscar usuarios (coincidencia exacta)...",
        strategy: ExactMatchStrategy()
    )
    .build()
```

#### Búsqueda con Predicado Personalizado

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Buscar por nombre o email...",
        predicate: { user, query in
            user.name.lowercased().contains(query.lowercased()) ||
            user.email.lowercased().contains(query.lowercased())
        }
    )
    .build()
```

#### Búsqueda con Placement Personalizado

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Buscar usuarios...",
        placement: .navigationBarDrawer // Siempre visible
    )
    .build()
```

#### Estrategias de Búsqueda Disponibles

- **`PartialMatchStrategy`** (por defecto): Búsqueda parcial insensible a mayúsculas
- **`ExactMatchStrategy`**: Coincidencia exacta insensible a mayúsculas
- **`TokenizedMatchStrategy`**: Búsqueda por tokens/palabras

#### Opciones de Placement Disponibles

- **`.automatic`** (por defecto): La barra de búsqueda aparece automáticamente
- **`.navigationBarDrawer`**: La barra de búsqueda siempre está visible
- **`.sidebar`**: La barra de búsqueda aparece en la barra lateral (macOS)
- **`.toolbar`**: La barra de búsqueda aparece en la barra de herramientas

#### Protocolo Searchable

Para usar las estrategias de búsqueda, tus modelos deben conformar `Searchable`:

```swift
struct User: Identifiable, Hashable, Searchable {
    let id: String
    let name: String
    let email: String
    let role: String
    
    var searchKeys: [String] {
        [name, email, role]
    }
}
```

### Vistas de Error Personalizadas

```swift
DynamicListBuilder<User>()
    .publisher(userService.fetchUsers())
    .errorContent { error in
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Error de Conexión")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Reintentar") {
                // Lógica de reintento
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    .build()
```

## 🧪 Testing

### Convención de Nombres de Tests

Usa la convención `test_whenCondition_expectedBehavior()` para todos los tests:

```swift
@Test("when initialized with items displays correct items")
func test_whenInitializedWithItems_displaysCorrectItems() {
    // Test implementation
}

@Test("when data provider fails shows error state")
func test_whenDataProviderFails_showsErrorState() {
    // Test implementation
}
```

### Testing de ViewModels

```swift
import Testing
import DynamicList
import CombineSchedulers

@Suite("DynamicListViewModel Tests")
struct DynamicListViewModelTests {
    
    @Test("when initialized with items displays correct items")
    func test_whenInitializedWithItems_displaysCorrectItems() {
        let items = [TestItem(name: "Test")]
        let viewModel = DynamicListViewModel(items: items)
        
        #expect(viewModel.viewState.items == items)
        #expect(viewModel.viewState.loadingState == .loaded)
    }
    
    @Test("when data provider sends items updates state")
    func test_whenDataProviderSendsItems_updatesState() {
        let pts = PassthroughSubject<[TestItem], Error>()
        let viewModel = DynamicListViewModel(
            dataProvider: { pts.eraseToAnyPublisher() },
            scheduler: .immediate
        )
        
        let items = [TestItem(name: "Updated")]
        pts.send(items)
        
        #expect(viewModel.viewState.items == items)
        #expect(viewModel.viewState.loadingState == .loaded)
    }
}
```

### Testing de Estrategias de Búsqueda

```swift
import Testing
import DynamicList

@Suite("SearchStrategy Tests")
struct SearchStrategyTests {
    
    @Test("when query matches name returns true")
    func test_whenQueryMatchesName_returnsTrue() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"]
        )
        
        let result = strategy.matches(query: "iPhone", in: item)
        
        #expect(result == true)
    }
    
    @Test("when query is empty returns true")
    func test_whenQueryIsEmpty_returnsTrue() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "Test Item",
            description: "A test description",
            tags: ["tag1", "tag2"]
        )
        
        let result = strategy.matches(query: "", in: item)
        
        #expect(result == true)
    }
}
```

## 🔧 Configuración Avanzada

### Embedding en Navigation Existente

```swift
struct AppView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                NavigationLink("Usuarios", value: "users")
                NavigationLink("Productos", value: "products")
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "users":
                    DynamicListBuilder<User>()
                        .items(users)
                        .buildWithoutNavigation()
                case "products":
                    DynamicListBuilder<Product>()
                        .items(products)
                        .buildWithoutNavigation()
                default:
                    EmptyView()
                }
            }
        }
    }
}
```

### Factory Methods

```swift
// Lista simple estática
DynamicListBuilder.simple(
    items: users,
    rowContent: { user in Text(user.name) },
    detailContent: { user in Text("Detalle de \(user.name)") }
)

// Lista reactiva
DynamicListBuilder.reactive(
    publisher: userService.fetchUsers(),
    rowContent: { user in UserRowView(user: user) },
    detailContent: { user in UserDetailView(user: user) }
)

// Lista con simulación de carga
DynamicListBuilder.simulated(
    items: users,
    delay: 2.0,
    rowContent: { user in Text(user.name) },
    detailContent: { user in Text("Detalle de \(user.name)") }
)
```

## 🌍 Localización

`DynamicList` incluye soporte completo para localización:

- **Inglés** (en)
- **Español Mexicano** (es-MX)
- **Francés** (fr)
- **Portugués** (pt)

Los textos se localizan automáticamente según el idioma del dispositivo.

## 📚 Documentación

- **[🚀 Guía de Desarrollador](Sources/DynamicList/Documentation/DeveloperGuide.md)** - Guía completa para desarrolladores
- **[📁 Estructura de Archivos](Sources/DynamicList/Documentation/FileStructure.md)** - Documentación de la arquitectura del proyecto

## 🤝 Contribución

Las contribuciones son bienvenidas. Por favor, lee las guías de contribución antes de enviar un pull request.

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

---

**DynamicList** - Listas dinámicas modernas para SwiftUI 🚀 