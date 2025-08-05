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
// ✅ Patrón consistente para múltiples vistas de ejemplos
enum BuilderExample: Hashable {
    case simpleList, reactiveList, customError
}

enum FactoryExample: Hashable {
    case simpleFactory, reactiveFactory, simulatedFactory
}

struct ExamplesView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                NavigationLink("Builder Examples", value: BuilderExample.simpleList)
                NavigationLink("Factory Examples", value: FactoryExample.simpleFactory)
            }
            .navigationDestination(for: BuilderExample.self) { example in
                switch example {
                case .simpleList:
                    DynamicListBuilder<User>()
                        .items(users)
                        .buildWithoutNavigation()
                case .reactiveList:
                    DynamicListBuilder<Product>()
                        .publisher(publisher)
                        .buildWithoutNavigation()
                case .customError:
                    DynamicListBuilder<User>()
                        .publisher(failingPublisher)
                        .buildWithoutNavigation()
                }
            }
            .navigationDestination(for: FactoryExample.self) { example in
                switch example {
                case .simpleFactory:
                    SimpleFactoryExample()
                case .reactiveFactory:
                    ReactiveFactoryExample()
                case .simulatedFactory:
                    SimulatedFactoryExample()
                }
            }
        }
    }
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

## 🎨 Estados Visuales y Skeleton Loading

### Estados de Carga Inteligentes

`DynamicList` maneja automáticamente diferentes estados de carga para una mejor experiencia de usuario:

#### 1. **Skeleton Loading (Carga Inicial)**
Cuando no hay datos y está cargando, muestra un skeleton con placeholders:

```swift
// Se muestra automáticamente cuando:
// - viewModel.viewState.shouldShowLoading == true
// - No hay items disponibles
```

#### 2. **Redacted Content (Contenido con Placeholder)**
Cuando hay datos pero está recargando, aplica `.redacted(reason: .placeholder)`:

```swift
// Se muestra automáticamente cuando:
// - Hay items en la lista
// - viewModel.viewState.isLoading == true
```

#### 3. **Contenido Normal**
Cuando los datos están cargados y disponibles:

```swift
// Se muestra cuando:
// - Hay items en la lista
// - viewModel.viewState.isLoading == false
```

### Personalización del Skeleton

El skeleton por defecto incluye:
- **5 filas de placeholder**
- **Avatar circular** (40x40)
- **Título y subtítulo** con diferentes anchos
- **Animación de placeholder** nativa de SwiftUI

### Ejemplo de Uso

```swift
struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()
    
    var body: some View {
        DynamicListBuilder<User>()
            .publisher(viewModel.usersPublisher)
            .rowContent { user in
                HStack {
                    AsyncImage(url: user.avatarURL) { image in
                        image.resizable()
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)
                        Text(user.email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .build()
    }
}
```

**Resultado**:
- **Carga inicial**: Skeleton con placeholders
- **Refresh**: Contenido real con `.redacted`
- **Cargado**: Contenido normal sin efectos

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

### 5. API Pública vs Interna

```swift
// ✅ API Pública - Lo que debes usar
DynamicListBuilder<User>()           // Builder principal
DynamicListPresenter                 // Localización
DefaultErrorView                     // Vista de error por defecto

// ❌ API Interna - No usar directamente
// DynamicList<Item, RowContent, DetailContent, ErrorContent>  // Vista base
// DynamicListViewModel<Item>                                  // ViewModel interno
// ListViewState<Item>                                         // Estado interno
```

#### ¿Por qué esta separación?

- **API Pública**: Diseñada para ser usada por desarrolladores
- **API Interna**: Implementación que puede cambiar sin romper compatibilidad
- **Flexibilidad**: Podemos mejorar la implementación sin afectar el código del usuario

## 🧪 Testing

### Convención de Nombres de Tests

Seguimos una convención descriptiva para nombrar nuestros tests que hace que sean fáciles de entender y mantener:

```swift
func test_whenCondition_expectedBehavior()
```

#### Ejemplos de la Convención:

```swift
// ✅ Correcto - Descriptivo y claro
func test_whenInitializedWithItems_displaysCorrectItems()
func test_whenDataProviderFails_displaysErrorState()
func test_whenRefreshIsCalled_loadsDataFromProvider()
func test_whenLoadItemsIsCalled_changesDataProvider()
func test_whenViewStateIsIdle_providesCorrectConvenienceProperties()

// ❌ Incorrecto - Poco descriptivo
func testInit()
func testRefresh()
func testError()
```

#### Ventajas de esta Convención:

- **Claridad**: Cada test describe exactamente cuándo y qué se espera
- **Mantenibilidad**: Los nombres son auto-documentados
- **Debugging**: Fácil de encontrar tests específicos cuando fallan
- **Consistencia**: Formato uniforme en todo el proyecto

### Unit Tests

```swift
@Suite("DynamicListViewModel Tests")
struct DynamicListViewModelTests {
    
    @Test("when initialized with items displays correct items")
    func test_whenInitializedWithItems_displaysCorrectItems() {
        let items = [TestItem(name: "Item 1")]
        let viewModel = DynamicListViewModel(items: items)
        
        #expect(viewModel.items == items)
        #expect(!viewModel.isLoading)
        #expect(viewModel.error == nil)
    }
    
    @Test("when data provider fails displays error state")
    func test_whenDataProviderFails_displaysErrorState() {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        let pts = PassthroughSubject<[TestItem], Error>()
        
        let viewModel = DynamicListViewModel(
            dataProvider: pts.eraseToAnyPublisher,
            scheduler: .immediate
        )
        
        #expect(viewModel.viewState.loadingState == .loading)
        
        pts.send(completion: .failure(testError))
        #expect(viewModel.viewState.loadingState == .error(testError))
    }
    
    @Test("when refresh is called loads data from provider")
    func test_whenRefreshIsCalled_loadsDataFromProvider() {
        var callCount = 0
        let pts = PassthroughSubject<[TestItem], Error>()
        
        let viewModel = DynamicListViewModel(
            dataProvider: {
                callCount += 1
                return pts.eraseToAnyPublisher()
            },
            scheduler: .immediate
        )
        
        #expect(callCount == 1)
        
        viewModel.refresh()
        #expect(callCount == 2)
    }
}
```

### Testing con CombineSchedulers

Para tests síncronos y determinísticos, usamos `CombineSchedulers`:

```swift
import CombineSchedulers

// ✅ Tests síncronos con .immediate scheduler
let viewModel = DynamicListViewModel(
    dataProvider: pts.eraseToAnyPublisher,
    scheduler: .immediate
)

// ✅ Control total sobre el flujo de datos
pts.send(expectedItems)
#expect(viewModel.viewState.loadingState == .loaded)

pts.send(completion: .failure(testError))
#expect(viewModel.viewState.loadingState == .error(testError))
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
- [DynamicList Builder](./DynamicListBuilder.md) - **Documentación completa con ejemplos**
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