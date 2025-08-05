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
- **🏗️ Arquitectura Modular**: Componentes separados para diferentes tipos de listas

## 🏗️ Arquitectura Modular

`DynamicList` está organizado en una arquitectura modular que separa claramente las responsabilidades:

### 📁 Estructura de Componentes

```
Core Components/
├── Dynamic List/           # Listas simples sin secciones
├── Sectioned Dynamic List/ # Listas con secciones
├── Shared/                 # Componentes compartidos
└── Default Views/          # Vistas por defecto
```

### 🎯 Dynamic List (Listas Simples)

Para listas tradicionales con items planos:

```swift
import DynamicList

// Uso directo
DynamicList(
    viewModel: DynamicListViewModel(items: users),
    rowContent: { user in UserRowView(user: user) },
    detailContent: { user in UserDetailView(user: user) }
)

// Con Builder Pattern
DynamicListBuilder<User>()
    .items(users)
    .rowContent { user in UserRowView(user: user) }
    .detailContent { user in UserDetailView(user: user) }
    .build()
```

### 📋 Sectioned Dynamic List (Listas con Secciones)

Para listas organizadas en secciones con headers y footers:

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
import SwiftUI
import DynamicList

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

## 🔄 Integración con Combine

### Lista Simple con Publisher

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
                    SectionedDynamicListBuilder<Product>()
                        .sections(productSections)
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
// Lista simple rápida
DynamicListBuilder.simple(
    items: users,
    rowContent: { user in Text(user.name) },
    detailContent: { user in Text("Detalle de \(user.name)") }
)

// Lista reactiva rápida
DynamicListBuilder.reactive(
    publisher: userService.fetchUsers(),
    rowContent: { user in Text(user.name) },
    detailContent: { user in Text("Detalle de \(user.name)") }
)
```

## 🌍 Localización

```swift
import DynamicList

// Las cadenas se localizan automáticamente
DynamicListBuilder<User>()
    .title(DynamicListPresenter.userListTitle)
    .errorContent { error in
        VStack {
            Text(DynamicListPresenter.errorTitle)
            Text(error.localizedDescription)
            Button(DynamicListPresenter.retryButton) {
                // Retry logic
            }
        }
    }
    .build()
```

## 📋 Listas con Secciones

### Tipos de Datos Estructurados

#### **Con Secciones Explícitas**
```swift
let sections = [
    ListSection(
        title: "Frutas Rojas",
        items: [manzana, sandia, fresa],
        footer: "3 frutas rojas disponibles"
    ),
    ListSection(
        title: "Frutas Verdes", 
        items: [pera, uvaVerde],
        footer: "2 frutas verdes disponibles"
    ),
    ListSection(
        title: "Frutas Amarillas",
        items: [platano, pina, limon]
    )
]
```

#### **Con Arrays de Arrays**
```swift
let arrays = [
    [manzana, sandia, fresa],      // Sección 1
    [pera, uvaVerde],              // Sección 2  
    [platano, pina, limon]         // Sección 3
]
let titles = ["Rojas", "Verdes", "Amarillas"]
```

### API para Listas con Secciones

#### **SectionedDynamicListBuilder (Recomendado)**
```swift
SectionedDynamicListBuilder<Fruit>()
    .sections(sections)
    .rowContent { fruit in
        FruitRowView(fruit: fruit)
    }
    .detailContent { fruit in
        FruitDetailView(fruit: fruit)
    }
    .title("Frutas por Color")
    .build()
```

#### **Con Arrays de Arrays**
```swift
SectionedDynamicListBuilder<Fruit>()
    .groupedItems(arrays, titles: titles)
    .rowContent { fruit in
        FruitRowView(fruit: fruit)
    }
    .detailContent { fruit in
        FruitDetailView(fruit: fruit)
    }
    .build()
```

#### **Con Publisher Reactivo**
```swift
SectionedDynamicListBuilder<Fruit>()
    .publisher(apiService.fetchFruitsByCategory())
    .rowContent { fruit in
        FruitRowView(fruit: fruit)
    }
    .detailContent { fruit in
        FruitDetailView(fruit: fruit)
    }
    .skeletonContent {
        DefaultSectionedSkeletonView()
    }
    .build()
```

### Características de las Secciones

#### **Headers y Footers**
- **Headers**: Títulos de sección opcionales
- **Footers**: Texto informativo opcional al final de cada sección
- **Estilo nativo**: Usa los estilos de SwiftUI automáticamente

#### **Navegación**
- **Navegación por sección**: Cada item mantiene su contexto de sección
- **Detalles consistentes**: Misma experiencia de detalle que listas simples
- **Pull-to-refresh**: Funciona en toda la lista, no por sección

#### **Estados de Carga**
- **Skeleton por sección**: `DefaultSectionedSkeletonView` muestra estructura de secciones
- **Loading states**: Manejo automático de estados de carga
- **Error handling**: Errores se muestran a nivel de lista completa

### Ejemplos de Uso

#### **Lista de Contactos por Categoría**
```swift
SectionedDynamicListBuilder<Contact>()
    .sections([
        ListSection(title: "Familia", items: familyContacts),
        ListSection(title: "Trabajo", items: workContacts),
        ListSection(title: "Amigos", items: friendContacts)
    ])
    .rowContent { contact in
        ContactRowView(contact: contact)
    }
    .detailContent { contact in
        ContactDetailView(contact: contact)
    }
    .build()
```

#### **Productos por Categoría (Reactivo)**
```swift
SectionedDynamicListBuilder<Product>()
    .publisher(apiService.fetchProductsByCategory())
    .rowContent { product in
        ProductRowView(product: product)
    }
    .detailContent { product in
        ProductDetailView(product: product)
    }
    .skeletonContent {
        // Skeleton personalizado que coincide con el diseño real
        List {
            ForEach(0..<3, id: \.self) { sectionIndex in
                Section {
                    ForEach(0..<(sectionIndex + 2), id: \.self) { _ in
                        ProductSkeletonRow()
                    }
                } header: {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.4))
                        .frame(height: 20)
                        .frame(maxWidth: .infinity * 0.5)
                }
            }
        }
        .redacted(reason: .placeholder)
    }
    .build()
```

### Ventajas de las Listas con Secciones

1. **Organización Visual**: Datos agrupados lógicamente
2. **Mejor UX**: Headers y footers proporcionan contexto
3. **Flexibilidad**: Soporte para datos estáticos y reactivos
4. **Consistencia**: Misma API que listas simples
5. **Performance**: Renderizado eficiente de secciones
6. **Accesibilidad**: Headers y footers mejoran la navegación

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

### 5. **Testing**
- Usa la convención de nombres `test_whenCondition_expectedBehavior()`
- Prueba estados de carga, error y éxito
- Usa `CombineSchedulers.immediate` para tests síncronos

## 🔗 Recursos Adicionales

- [📁 Estructura de Archivos](FileStructure.md)
- [🔄 Integración con Combine](CombineIntegration.md)
- [🎨 Vistas de Error Personalizadas](CustomErrorViews.md)
- [🏗️ Builder Pattern](DynamicListBuilder.md)
- [🌍 Localización](Localization.md)

---

¡Con esta guía deberías poder integrar `DynamicList` en tu proyecto de manera efectiva! Si tienes preguntas o necesitas ayuda adicional, consulta la documentación específica o los ejemplos incluidos en el paquete. 