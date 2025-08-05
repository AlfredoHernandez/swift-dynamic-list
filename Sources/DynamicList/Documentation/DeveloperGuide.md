# 👨‍💻 Guía del Desarrollador - DynamicList

Esta guía está diseñada para desarrolladores que quieren integrar **DynamicList** en sus proyectos SwiftUI de manera efectiva y siguiendo las mejores prácticas.

## 🚀 Inicio Rápido

### Instalación

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/tu-usuario/DynamicList.git", from: "1.0.0")
]
```

### Uso Básico

```swift
import DynamicList

struct ContentView: View {
    var body: some View {
        DynamicListBuilder<User>()
            .items(User.sampleUsers)
            .build()
    }
}
```

## 📋 Checklist de Implementación

### ✅ Configuración Inicial
- [ ] Agregar dependencia al Package.swift
- [ ] Importar el módulo DynamicList
- [ ] Verificar compatibilidad de plataforma (iOS 17.0+)

### ✅ Modelo de Datos
- [ ] Implementar `Identifiable` en tu modelo
- [ ] Implementar `Hashable` si necesitas navegación
- [ ] Definir propiedades requeridas (id, etc.)

### ✅ Publisher (Opcional)
- [ ] Crear Publisher para datos reactivos
- [ ] Manejar errores apropiadamente
- [ ] Configurar scheduler (DispatchQueue.main)

### ✅ UI Components
- [ ] Diseñar vista de fila (rowContent)
- [ ] Diseñar vista de detalle (detailContent)
- [ ] Crear vista de error personalizada (opcional)

### ✅ Navegación
- [ ] Decidir entre `.build()` o `.buildWithoutNavigation()`
- [ ] Configurar NavigationStack apropiadamente
- [ ] Probar navegación en diferentes escenarios

## 🎯 Patrones de Uso Comunes

### 1. Lista Simple con Datos Estáticos

```swift
struct SimpleListView: View {
    let users: [User]
    
    var body: some View {
        DynamicListBuilder<User>()
            .items(users)
            .title("Usuarios")
            .rowContent { user in
                HStack {
                    Text(user.name)
                    Spacer()
                    Text(user.email)
                        .foregroundColor(.secondary)
                }
            }
            .detailContent { user in
                UserDetailView(user: user)
            }
            .build()
    }
}
```

### 2. Lista Reactiva con API

```swift
struct ReactiveListView: View {
    @StateObject private var viewModel = UserListViewModel()
    
    var body: some View {
        DynamicListBuilder<User>()
            .publisher(viewModel.usersPublisher)
            .title("Usuarios")
            .rowContent { user in
                UserRowView(user: user)
            }
            .detailContent { user in
                UserDetailView(user: user)
            }
            .errorContent { error in
                CustomErrorView(error: error) {
                    viewModel.refresh()
                }
            }
            .build()
    }
}
```

### 3. Lista con Navegación Personalizada

```swift
struct ExamplesView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                NavigationLink("Users", value: NavigationItem.users)
                NavigationLink("Products", value: NavigationItem.products)
            }
            .navigationDestination(for: NavigationItem.self) { item in
                switch item {
                case .users:
                    DynamicListBuilder<User>()
                        .items(User.sampleUsers)
                        .buildWithoutNavigation()
                case .products:
                    DynamicListBuilder<Product>()
                        .publisher(ProductService.shared.productsPublisher)
                        .buildWithoutNavigation()
                }
            }
        }
    }
}

enum NavigationItem: Hashable {
    case users, products
}
```

## 🔧 Configuración Avanzada

### Custom Error Views

```swift
struct CustomErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Error de Conexión")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Reintentar") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

### Localización

```swift
// En tu vista
DynamicListBuilder<User>()
    .items(users)
    .title(DynamicListPresenter.profile) // String localizado
    .build()

// En DynamicListPresenter (extensión)
extension DynamicListPresenter {
    static let profile = NSLocalizedString(
        "profile",
        bundle: Bundle.module,
        comment: "Profile navigation title"
    )
}
```

## 🚨 Solución de Problemas

### Problema: NavigationStack Anidados

**Síntomas**: Comportamiento extraño en navegación, "pop" inesperado

**Solución**:
```swift
// ❌ Incorrecto
NavigationStack {
    DynamicListBuilder<User>()
        .items(users)
        .build() // Crea NavigationStack interno
}

// ✅ Correcto
NavigationStack {
    DynamicListBuilder<User>()
        .items(users)
        .buildWithoutNavigation() // Sin NavigationStack interno
}
```

### Problema: NavigationLink No Funciona

**Síntomas**: Los taps en las filas no navegan

**Solución**:
```swift
// ✅ Asegúrate de que tu modelo implemente Hashable
struct User: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let email: String
    
    // Implementación de Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}
```

### Problema: Publisher No Actualiza la UI

**Síntomas**: Los datos no se reflejan en la lista

**Solución**:
```swift
// ✅ Asegúrate de usar el scheduler correcto
Just(users)
    .receive(on: DispatchQueue.main) // Importante!
    .setFailureType(to: Error.self)
    .eraseToAnyPublisher()
```

## 📊 Mejores Prácticas

### 1. Organización del Código

```swift
// ✅ Separar lógica de negocio
class UserListViewModel: ObservableObject {
    @Published var users: [User] = []
    
    var usersPublisher: AnyPublisher<[User], Error> {
        // Lógica de API aquí
    }
}

// ✅ Vista limpia
struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()
    
    var body: some View {
        DynamicListBuilder<User>()
            .publisher(viewModel.usersPublisher)
            .build()
    }
}
```

### 2. Manejo de Estados

```swift
// ✅ Usar ViewState para estados complejos
struct ListViewState<Item> {
    let items: [Item]
    let isLoading: Bool
    let error: Error?
    
    var shouldShowLoading: Bool { isLoading }
    var shouldShowError: Bool { error != nil }
}
```

### 3. Performance

```swift
// ✅ Usar lazy loading para listas grandes
DynamicListBuilder<User>()
    .items(users)
    .rowContent { user in
        LazyVStack {
            UserRowView(user: user)
        }
    }
    .build()
```

### 4. Código Limpio

```swift
// ✅ No usar @available redundantes (ya definido en Package.swift)
struct UserListView: View {
    var body: some View {
        DynamicListBuilder<User>()
            .items(users)
            .build()
    }
}

// ❌ Evitar redundancia
// @available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
// struct UserListView: View { ... }
```

## 🧪 Testing

### Unit Tests

```swift
class DynamicListViewModelTests: XCTestCase {
    func testInitializationWithItems() {
        let users = [User(name: "Test", email: "test@example.com")]
        let viewModel = DynamicListViewModel(items: users)
        
        XCTAssertEqual(viewModel.viewState.items.count, 1)
        XCTAssertFalse(viewModel.viewState.shouldShowLoading)
        XCTAssertNil(viewModel.viewState.error)
    }
    
    func testPublisherIntegration() {
        let publisher = Just([User(name: "Test", email: "test@example.com")])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        let viewModel = DynamicListViewModel(publisher: publisher)
        
        // Test publisher integration
    }
}
```

### UI Tests

```swift
class DynamicListUITests: XCTestCase {
    func testNavigationFlow() {
        let app = XCUIApplication()
        app.launch()
        
        // Test navigation from list to detail
        let firstRow = app.cells.firstMatch
        firstRow.tap()
        
        // Verify detail view is shown
        XCTAssertTrue(app.navigationBars["User Detail"].exists)
    }
}
```

## 📚 Recursos Adicionales

- [Integración con Combine](./CombineIntegration.md)
- [DynamicList Builder](./DynamicListBuilder.md)
- [Vistas de Error Personalizables](./CustomErrorViews.md)
- [Sistema de Localización](./Localization.md)
- [Estructura de Archivos](./FileStructure.md)

## 🆘 Soporte

Si encuentras problemas:

1. **Revisa la documentación** - La mayoría de problemas están cubiertos
2. **Verifica compatibilidad** - Asegúrate de usar iOS 17.0+
3. **Revisa ejemplos** - El código de ejemplo es funcional
4. **Abre un issue** - Describe el problema con detalles

---

**¿Listo para empezar?** Comienza con una [lista simple](./DynamicListBuilder.md#1-lista-simple-con-datos-estáticos) y luego avanza a [datos reactivos](./CombineIntegration.md).

¡Happy coding! 🎉 