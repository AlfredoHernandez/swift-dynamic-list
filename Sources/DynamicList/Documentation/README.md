# 📱 DynamicList

Una biblioteca SwiftUI moderna y modular para crear listas dinámicas con soporte completo para datos reactivos, estados de carga, y múltiples tipos de listas.

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

### 🏗️ **Arquitectura Modular**
- Componentes separados por funcionalidad
- Código reutilizable y mantenible
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
            .build()
    }
}
```

## 🏗️ Arquitectura Modular

`DynamicList` está organizado en una arquitectura modular que separa claramente las responsabilidades:

```
Core Components/
├── Dynamic List/           # Listas simples sin secciones
├── Sectioned Dynamic List/ # Listas con secciones
├── Shared/                 # Componentes compartidos
└── Default Views/          # Vistas por defecto

Domain/
├── Searchable.swift        # Protocolo para items buscables
├── SearchStrategy.swift    # Protocolo de estrategias de búsqueda
└── Strategies/             # Implementaciones de estrategias
    ├── PartialMatchStrategy.swift
    ├── ExactMatchStrategy.swift
    └── TokenizedMatchStrategy.swift
```

### 🎯 **Dynamic List**
- `DynamicList.swift` - Vista principal
- `DynamicListViewModel.swift` - ViewModel
- `DynamicListBuilder.swift` - Builder pattern
- `DynamicListViewState.swift` - Estados de vista

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

#### Estrategias de Búsqueda Disponibles

- **`PartialMatchStrategy`** (por defecto): Búsqueda parcial insensible a mayúsculas
- **`ExactMatchStrategy`**: Coincidencia exacta insensible a mayúsculas
- **`TokenizedMatchStrategy`**: Búsqueda por tokens/palabras

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

### Embedding en Navegación Existente

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

## 🧪 Testing

### Convención de Nombres

Usa la convención `test_whenCondition_expectedBehavior()`:

```swift
@Test("when initialized with items displays correct items")
func test_whenInitializedWithItems_displaysCorrectItems() {
    let items = [TestItem(name: "Test")]
    let viewModel = DynamicListViewModel(items: items)
    
    #expect(viewModel.viewState.items == items)
    #expect(viewModel.viewState.loadingState == .loaded)
}
```

### Testing con CombineSchedulers

```swift
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
```

## 📚 Documentación

- [🚀 Guía de Desarrollador](DeveloperGuide.md) - Guía completa de uso
- [📁 Estructura de Archivos](FileStructure.md) - Organización del código
- [🔄 Integración con Combine](CombineIntegration.md) - Uso con publishers
- [🎨 Vistas de Error Personalizadas](CustomErrorViews.md) - Personalización de errores
- [🏗️ Builder Pattern](DynamicListBuilder.md) - Documentación del builder
- [🌍 Localización](Localization.md) - Soporte multiidioma

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

## 🤝 Contribución

¡Las contribuciones son bienvenidas! Por favor:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🆘 Soporte

Si encuentras problemas:

1. **Revisa la documentación** - La mayoría de problemas están cubiertos
2. **Verifica compatibilidad** - Asegúrate de usar iOS 17.0+
3. **Revisa ejemplos** - El código de ejemplo es funcional
4. **Abre un issue** - Describe el problema con detalles

---

**¿Listo para empezar?** Comienza con una [lista simple](DeveloperGuide.md#uso-básico---lista-simple) y luego avanza a [datos reactivos](DeveloperGuide.md#integración-con-combine).

¡Happy coding! 🎉 