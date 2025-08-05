# 🚀 Guía de Desarrollador - DynamicList

Esta guía está diseñada para desarrolladores que quieren integrar **DynamicList** en sus proyectos SwiftUI de manera efectiva y siguiendo las mejores prácticas.

## 🎯 Características Principales

- **📱 Listas Dinámicas**: Soporte completo para listas con datos estáticos y reactivos
- **🔄 Reactividad**: Integración nativa con Combine Publishers
- **⚡ Estados de Carga**: Manejo automático de loading, error y success states
- **🎨 UI Personalizable**: Contenido de filas, detalles y errores completamente configurable
- **🔄 Pull-to-Refresh**: Funcionalidad de recarga integrada
- **🧭 Navegación**: Navegación automática a vistas de detalle
- **📋 Secciones**: Soporte para listas con múltiples secciones y headers/footers
- **💀 Skeleton Loading**: Estados de carga con placeholders configurables
- **🔍 Búsqueda Avanzada**: Sistema de búsqueda con múltiples estrategias
- **🏗️ Arquitectura Modular**: APIs públicas bien definidas con implementación privada encapsulada

## 🏗️ Arquitectura del Proyecto

`DynamicList` está organizado en una arquitectura modular que separa claramente las responsabilidades:

### 📁 Estructura de Componentes

```
Sources/DynamicList/
├── Public/                    # APIs públicas del paquete
├── Private/                   # Implementaciones internas
│   ├── UI/                    # Componentes de interfaz de usuario
│   │   ├── Dynamic List/      # Componentes para listas simples
│   │   ├── Sectioned Dynamic List/ # Componentes para listas con secciones
│   │   ├── Default Views/     # Vistas por defecto
│   │   └── Shared/            # Componentes compartidos
│   ├── Domain/                # Lógica de dominio
│   │   └── Strategies/        # Estrategias de búsqueda
│   └── Presentation/          # Componentes de presentación
├── PreviewSupport/            # Soporte para SwiftUI Previews
└── Documentation/             # Documentación del proyecto
```

### 🎯 APIs Públicas

#### **DynamicListBuilder**
API principal para crear listas dinámicas simples:

```swift
import DynamicList

// Uso directo
DynamicListBuilder<User>()
    .items(users)
    .rowContent { user in UserRowView(user: user) }
    .detailContent { user in UserDetailView(user: user) }
    .build()

// Con Factory Methods
DynamicListBuilder.simple(
    items: users,
    rowContent: { user in Text(user.name) },
    detailContent: { user in Text("Detalle de \(user.name)") }
)
```

#### **SectionedDynamicListBuilder**
API para crear listas dinámicas con secciones:

```swift
import DynamicList

// Con secciones explícitas
SectionedDynamicListBuilder<Fruit>()
    .sections([
        ListSection(title: "Rojas", items: redFruits),
        ListSection(title: "Verdes", items: greenFruits)
    ])
    .rowContent { fruit in FruitRowView(fruit: fruit) }
    .detailContent { fruit in FruitDetailView(fruit: fruit) }
    .build()

// Con arrays de arrays
SectionedDynamicListBuilder<Fruit>()
    .groupedItems([redFruits, greenFruits], titles: ["Rojas", "Verdes"])
    .rowContent { fruit in FruitRowView(fruit: fruit) }
    .detailContent { fruit in FruitDetailView(fruit: fruit) }
    .build()
```

## 🚀 Inicio Rápido

### Instalación

Agrega `DynamicList` a tu `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/tu-usuario/DynamicList.git", from: "1.0.0")
]
```

### Uso Básico - Lista Simple

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
            .build()
    }
}
```

### Uso Básico - Lista con Secciones

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
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .detailContent { user in
                UserDetailView(user: user)
            }
            .title("Usuarios por Rol")
            .searchable(prompt: "Buscar usuarios...")
            .build()
    }
}
```

## 🔄 Integración con Combine

### Lista Reactiva Simple

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
            .build()
    }
}
```

### Lista con Secciones y Publisher

```swift
struct ReactiveSectionedListView: View {
    var body: some View {
        SectionedDynamicListBuilder<User>()
            .publisher(userService.fetchUsersByRole())
            .rowContent { user in UserRowView(user: user) }
            .detailContent { user in UserDetailView(user: user) }
            .skeletonContent {
                DefaultSectionedSkeletonView()
            }
            .build()
    }
}
```

## 🎨 Personalización Avanzada

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

### Skeleton Loading Personalizado

```swift
DynamicListBuilder<User>()
    .publisher(userService.fetchUsers())
    .skeletonContent {
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

## 🔍 Sistema de Búsqueda Avanzado

`DynamicList` incluye un sistema de búsqueda avanzado que permite múltiples estrategias de búsqueda y personalización completa.

### Protocolo Searchable

Para habilitar la búsqueda en tus modelos, conforma el protocolo `Searchable`:

```swift
struct User: Identifiable, Hashable, Searchable {
    let id: String
    let name: String
    let email: String
    let role: String
    let department: String
    
    var searchKeys: [String] {
        [name, email, role, department]
    }
}
```

### Estrategias de Búsqueda Disponibles

#### PartialMatchStrategy (Por Defecto)

Búsqueda parcial insensible a mayúsculas. Busca la query dentro de cualquier clave de búsqueda:

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(prompt: "Buscar usuarios...")
    .build()
```

#### ExactMatchStrategy

Coincidencia exacta insensible a mayúsculas. Requiere que la query coincida exactamente con una clave:

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Buscar usuarios (coincidencia exacta)...",
        strategy: ExactMatchStrategy()
    )
    .build()
```

#### TokenizedMatchStrategy

Búsqueda por tokens/palabras. Divide la query en palabras y busca que todas estén presentes:

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Buscar por palabras...",
        strategy: TokenizedMatchStrategy()
    )
    .build()
```

### Búsqueda con Predicado Personalizado

Para lógica de búsqueda completamente personalizada:

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Buscar por nombre o email...",
        predicate: { user, query in
            let searchLower = query.lowercased()
            return user.name.lowercased().contains(searchLower) ||
                   user.email.lowercased().contains(searchLower) ||
                   user.role.lowercased().contains(searchLower)
        }
    )
    .build()
```

### Búsqueda con Placement Personalizado

Para controlar cuándo y dónde aparece la barra de búsqueda:

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Buscar usuarios...",
        placement: .navigationBarDrawer // Siempre visible
    )
    .build()
```

### Combinando Estrategia y Placement

```swift
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Buscar usuarios...",
        strategy: TokenizedMatchStrategy(),
        placement: .navigationBarDrawer
    )
    .build()
```

### Búsqueda en Listas con Secciones

```swift
SectionedDynamicListBuilder<User>()
    .sections(sections)
    .searchable(
        prompt: "Buscar usuarios...",
        strategy: TokenizedMatchStrategy()
    )
    .build()
```

La búsqueda en listas con secciones funciona de manera inteligente:

- **Filtrado por sección**: Solo se muestran las secciones que contienen items que coinciden con la búsqueda
- **Preservación de estructura**: Se mantienen los headers y footers de las secciones que tienen resultados
- **Búsqueda global**: La búsqueda se aplica a todos los items de todas las secciones
- **Misma API**: Usa los mismos métodos de búsqueda que las listas simples

### Opciones de Placement Disponibles

- **`.automatic`** (por defecto): La barra de búsqueda aparece automáticamente cuando el usuario hace scroll
- **`.navigationBarDrawer`**: La barra de búsqueda siempre está visible en la barra de navegación
- **`.sidebar`**: La barra de búsqueda aparece en la barra lateral (macOS)
- **`.toolbar`**: La barra de búsqueda aparece en la barra de herramientas

### Casos de Uso por Placement

#### `.navigationBarDrawer` - Búsqueda Siempre Visible
Ideal para listas largas donde la búsqueda es una funcionalidad principal:

```swift
DynamicListBuilder<Contact>()
    .items(contacts)
    .searchable(
        prompt: "Buscar contactos...",
        placement: .navigationBarDrawer
    )
    .build()
```

#### `.automatic` - Búsqueda Automática
Perfecto para listas donde la búsqueda es secundaria:

```swift
DynamicListBuilder<Product>()
    .items(products)
    .searchable(
        prompt: "Buscar productos...",
        placement: .automatic
    )
    .build()
```

### Estrategias Personalizadas

Puedes crear tus propias estrategias de búsqueda:

```swift
struct FuzzyMatchStrategy: SearchStrategy {
    func matches(query: String, in item: Searchable) -> Bool {
        let queryLower = query.lowercased()
        return item.searchKeys.contains { key in
            // Implementa lógica de búsqueda difusa
            key.lowercased().contains(queryLower) ||
            key.lowercased().fuzzyMatch(queryLower)
        }
    }
}

// Uso
DynamicListBuilder<User>()
    .items(users)
    .searchable(
        prompt: "Búsqueda difusa...",
        strategy: FuzzyMatchStrategy()
    )
    .build()
```

### Casos de Uso Comunes

#### Búsqueda en Listas de Productos

```swift
struct Product: Identifiable, Hashable, Searchable {
    let id: String
    let name: String
    let category: String
    let tags: [String]
    let price: Double
    
    var searchKeys: [String] {
        [name, category] + tags + [String(format: "%.2f", price)]
    }
}

DynamicListBuilder<Product>()
    .items(products)
    .searchable(
        prompt: "Buscar productos...",
        strategy: TokenizedMatchStrategy()
    )
    .build()
```

#### Búsqueda en Listas de Contactos

```swift
struct Contact: Identifiable, Hashable, Searchable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let company: String
    
    var searchKeys: [String] {
        [firstName, lastName, email, phone, company]
    }
}

DynamicListBuilder<Contact>()
    .items(contacts)
    .searchable(
        prompt: "Buscar contactos...",
        strategy: PartialMatchStrategy()
    )
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

### Unit Tests

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

### UI Tests

```swift
import Testing
import SwiftUI
import DynamicList

@Suite("DynamicList Tests")
struct DynamicListTests {
    
    @Test("when initialized with items creates list view with correct items")
    func test_whenInitializedWithItems_createsListViewWithCorrectItems() {
        let items = [TestItem(name: "Test")]
        let viewModel = DynamicListViewModel(items: items)
        
        let sut = DynamicList(
            viewModel: viewModel,
            rowContent: { item in Text(item.name) },
            detailContent: { item in Text(item.name) }
        )
        
        // Use Mirror to inspect internal state
        let mirror = Mirror(reflecting: sut)
        let viewModelFromMirror = mirror.children.first { $0.label == "_viewModel" }?.value as? State<DynamicListViewModel<TestItem>>
        let itemsFromMirror = viewModelFromMirror?.wrappedValue.viewState.items
        
        #expect(itemsFromMirror == items)
    }
}
```

### Testing de Estrategias de Búsqueda

```swift
import Testing
import DynamicList

// Modelo de test para Searchable
struct TestSearchableItem: Searchable {
    let id = UUID()
    let name: String
    let description: String
    let tags: [String]
    
    var searchKeys: [String] {
        [name, description] + tags
    }
}

@Suite("SearchStrategy Tests")
struct SearchStrategyTests {
    
    // Tests para PartialMatchStrategy
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
    
    // Tests para ExactMatchStrategy
    @Test("when query exactly matches name returns true")
    func test_whenQueryExactlyMatchesName_returnsTrue() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"]
        )
        
        let result = strategy.matches(query: "iPhone 15 Pro", in: item)
        
        #expect(result == true)
    }
    
    @Test("when query is partial match returns false")
    func test_whenQueryIsPartialMatch_returnsFalse() throws {
        let strategy = ExactMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro",
            description: "Latest smartphone",
            tags: ["mobile", "apple"]
        )
        
        let result = strategy.matches(query: "iPhone", in: item)
        
        #expect(result == false)
    }
    
    // Tests para TokenizedMatchStrategy
    @Test("when all query tokens match returns true")
    func test_whenAllQueryTokensMatch_returnsTrue() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15 Pro Max",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"]
        )
        
        let result = strategy.matches(query: "iPhone Pro", in: item)
        
        #expect(result == true)
    }
    
    @Test("when query tokens match across different keys returns true")
    func test_whenQueryTokensMatchAcrossDifferentKeys_returnsTrue() throws {
        let strategy = TokenizedMatchStrategy()
        let item = TestSearchableItem(
            name: "iPhone 15",
            description: "Latest smartphone with advanced features",
            tags: ["mobile device", "apple product"]
        )
        
        let result = strategy.matches(query: "iPhone advanced", in: item)
        
        #expect(result == true)
    }
    
    // Tests para casos edge
    @Test("when searchable item has empty search keys returns false")
    func test_whenSearchableItemHasEmptySearchKeys_returnsFalse() throws {
        let strategy = PartialMatchStrategy()
        let item = TestSearchableItem(
            name: "",
            description: "",
            tags: []
        )
        
        let result = strategy.matches(query: "test", in: item)
        
        #expect(result == false)
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

## 🎯 Mejores Prácticas

### 1. **Elige el Tipo Correcto de Lista**
- **DynamicList**: Para listas simples sin agrupación
- **SectionedDynamicList**: Para listas con categorías o secciones

### 2. **Usa el Builder Pattern**
- Más legible y mantenible
- API fluida y encadenable
- Configuración por defecto automática

### 3. **Maneja Estados de Carga**
- Proporciona skeleton loading personalizado
- Maneja errores de forma elegante
- Usa pull-to-refresh para recargas

### 4. **Optimiza Performance**
- Usa `Identifiable` y `Hashable` en tus modelos
- Implementa `Equatable` para optimizaciones de SwiftUI
- Considera lazy loading para listas grandes

### 5. **Implementa Búsqueda Efectiva**
- Conforma `Searchable` en tus modelos
- Elige la estrategia de búsqueda apropiada
- Considera el placement de la barra de búsqueda

### 6. **Testing Completo**
- Usa la convención de nombres `test_whenCondition_expectedBehavior()`
- Testea ViewModels con `CombineSchedulers.immediate`
- Incluye tests para estrategias de búsqueda

## 🆘 Solución de Problemas

### Problemas Comunes

#### 1. **Error de Compilación: "Cannot find type"**
- Asegúrate de importar `DynamicList`
- Verifica que el tipo `Item` conforme a `Identifiable` y `Hashable`

#### 2. **La búsqueda no funciona**
- Verifica que tu modelo conforme a `Searchable`
- Implementa `searchKeys` correctamente
- Asegúrate de que las claves de búsqueda no estén vacías

#### 3. **Los tests fallan**
- Usa `CombineSchedulers.immediate` para tests síncronos
- Verifica que los publishers completen correctamente
- Asegúrate de que los estados cambien como esperas

#### 4. **Problemas de navegación**
- Usa `buildWithoutNavigation()` cuando embedas en navegación existente
- Verifica que no haya conflictos de NavigationStack

### Debugging

#### 1. **Verificar Estados**
```swift
.onReceive(viewModel.$viewState) { state in
    print("ViewState changed: \(state)")
}
```

#### 2. **Debugging de Búsqueda**
```swift
.onReceive($searchText) { query in
    print("Search query: '\(query)'")
}
```

#### 3. **Verificar Datos**
```swift
.onReceive(viewModel.$items) { items in
    print("Items updated: \(items.count) items")
}
```

## 📚 Recursos Adicionales

- **[Estructura de Archivos](FileStructure.md)** - Documentación de la arquitectura
- **[Ejemplos de Código](PreviewSupport/)** - Ejemplos completos y funcionales
- **[Tests](Tests/)** - Ejemplos de testing y mejores prácticas

---

**¿Listo para empezar?** Comienza con una [lista simple](#uso-básico---lista-simple) y luego avanza a [datos reactivos](#integración-con-combine).

¡Happy coding! 🎉 