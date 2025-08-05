# DynamicList Builder

El `DynamicListBuilder` es una clase que simplifica significativamente la creación de instancias de `DynamicList`, proporcionando una API fluida y fácil de usar.

## 🎯 Características Principales

- **API Fluida**: Patrón builder con métodos encadenables
- **Configuración Flexible**: Soporte para diferentes fuentes de datos
- **Vistas por Defecto**: Vistas automáticas cuando no se especifican
- **Factory Methods**: Métodos de conveniencia para casos comunes
- **Type Safety**: Completamente tipado y seguro

## 🚀 Uso Básico

### 1. Lista Simple con Datos Estáticos

```swift
struct User: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let email: String
}

let users = [
    User(name: "Ana", email: "ana@example.com"),
    User(name: "Carlos", email: "carlos@example.com")
]

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
            VStack {
                Text(user.name)
                    .font(.title)
                Text(user.email)
                    .font(.body)
            }
            .navigationTitle("Perfil")
        }
        .build()
}
```

### 2. Lista Reactiva con Publisher

```swift
private var usersPublisher: AnyPublisher<[User], Error> {
    // Tu publisher aquí (API, Firebase, etc.)
    return Just(users)
        .delay(for: .seconds(1.0), scheduler: DispatchQueue.main)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
}

var body: some View {
    DynamicListBuilder<User>()
        .publisher(usersPublisher)
        .title("Usuarios")
        .rowContent { user in
            Text(user.name)
        }
        .detailContent { user in
            Text("Detalle de \(user.name)")
        }
        .build()
}
```

### 3. Lista con Carga Simulada

```swift
var body: some View {
    DynamicListBuilder<User>()
        .simulatedPublisher(users, delay: 2.0)
        .title("Cargando Usuarios")
        .rowContent { user in
            Text(user.name)
        }
        .detailContent { user in
            Text("Detalle de \(user.name)")
        }
        .build()
}
```

## 🏭 Factory Methods

### Simple Factory

```swift
var body: some View {
    DynamicListBuilder.simple(
        items: users,
        rowContent: { user in
            Text(user.name)
        },
        detailContent: { user in
            Text("Detalle de \(user.name)")
        }
    )
}
```

### Reactive Factory

```swift
var body: some View {
    DynamicListBuilder.reactive(
        publisher: usersPublisher,
        rowContent: { user in
            Text(user.name)
        },
        detailContent: { user in
            Text("Detalle de \(user.name)")
        }
    )
}
```

### Simulated Factory

```swift
var body: some View {
    DynamicListBuilder.simulated(
        items: users,
        delay: 2.0,
        rowContent: { user in
            Text(user.name)
        },
        detailContent: { user in
            Text("Detalle de \(user.name)")
        }
    )
}
```

## ⚙️ Configuración Avanzada

### Vista de Error Personalizada

```swift
var body: some View {
    DynamicListBuilder<User>()
        .publisher(failingPublisher)
        .errorContent { error in
            VStack {
                Text("😞")
                    .font(.system(size: 60))
                Text("¡Ups! Algo salió mal")
                    .font(.title2)
                Text(error.localizedDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                Button("Reintentar") {
                    // Acción de reintento
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .build()
}
```

### Ocultar Barra de Navegación

```swift
var body: some View {
    DynamicListBuilder<User>()
        .items(users)
        .hideNavigationBar()
        .build()
}
```

## 📊 Comparación: Antes vs Después

### ❌ Antes (Complejo)

```swift
// Crear ViewModel
let viewModel = DynamicListViewModel(publisher: usersPublisher)

// Crear DynamicList con toda la configuración
DynamicList(
    viewModel: viewModel,
    rowContent: { user in
        Text(user.name)
    },
    detailContent: { user in
        Text("Detalle de \(user.name)")
    }
)
```

### ✅ Después (Simple)

```swift
// Una sola línea con builder
DynamicListBuilder<User>()
    .publisher(usersPublisher)
    .rowContent { user in
        Text(user.name)
    }
    .detailContent { user in
        Text("Detalle de \(user.name)")
    }
    .build()
```

## 🎨 Vistas por Defecto

Si no especificas `rowContent` o `detailContent`, el builder proporciona vistas por defecto:

### Vista de Fila por Defecto
```swift
VStack(alignment: .leading) {
    Text("\(item)")
        .font(.body)
    Text("ID: \(item.id)")
        .font(.caption)
        .foregroundColor(.secondary)
}
```

### Vista de Detalle por Defecto
```swift
VStack(spacing: 16) {
    Text("Detalle del Item")
        .font(.largeTitle)
        .fontWeight(.bold)
    
    Text("\(item)")
        .font(.body)
    
    Text("ID: \(item.id)")
        .font(.caption)
        .foregroundColor(.secondary)
}
```

## 🔧 Métodos Disponibles

### Configuración de Datos
- `items(_:)` - Datos estáticos
- `publisher(_:)` - Publisher de Combine
- `simplePublisher(_:)` - Publisher simple
- `simulatedPublisher(_:delay:)` - Publisher con simulación de carga

### Configuración de UI
- `rowContent(_:)` - Contenido de fila
- `detailContent(_:)` - Contenido de detalle
- `errorContent(_:)` - Vista de error personalizada
- `title(_:)` - Título de navegación
- `hideNavigationBar()` - Ocultar barra de navegación

### Factory Methods
- `simple(items:rowContent:detailContent:)` - Lista simple
- `reactive(publisher:rowContent:detailContent:)` - Lista reactiva
- `simulated(items:delay:rowContent:detailContent:)` - Lista con simulación

## 🎯 Beneficios

1. **Menos Código**: Reducción significativa de líneas de código
2. **Más Legible**: API fluida y expresiva
3. **Menos Errores**: Type safety y validaciones automáticas
4. **Más Flexible**: Configuración opcional y por defecto
5. **Más Rápido**: Desarrollo más rápido con menos boilerplate

## 🚀 Casos de Uso Comunes

### Lista de Productos con API
```swift
DynamicListBuilder<Product>()
    .publisher(apiService.fetchProducts())
    .title("Productos")
    .rowContent { product in
        ProductRowView(product: product)
    }
    .detailContent { product in
        ProductDetailView(product: product)
    }
    .build()
```

### Lista de Usuarios con Firebase
```swift
DynamicListBuilder<User>()
    .publisher(firebaseService.usersPublisher())
    .title("Usuarios")
    .rowContent { user in
        UserRowView(user: user)
    }
    .detailContent { user in
        UserProfileView(user: user)
    }
    .build()
```

### Lista Simple para Testing
```swift
DynamicListBuilder.simple(
    items: testData,
    rowContent: { item in
        Text(item.name)
    },
    detailContent: { item in
        Text("Test: \(item.name)")
    }
)
```

¡El `DynamicListBuilder` hace que crear listas dinámicas sea tan simple como encadenar métodos! 🎉

## ⚠️ Nota Importante: Navegación

### Problema de NavigationStack Anidados

Si experimentas problemas de navegación (como "pop" inesperado del stack), es probable que tengas `NavigationStack` anidados. Esto sucede cuando:

1. Ya tienes un `NavigationStack` en el contexto padre
2. El `DynamicListBuilder` crea su propio `NavigationStack` interno

### Solución

Usa `buildWithoutNavigation()` cuando ya tienes navegación en el contexto padre:

```swift
// ❌ Incorrecto - NavigationStack anidados
NavigationStack {
    DynamicListBuilder<User>()
        .items(users)
        .build() // Esto crea otro NavigationStack
}

// ✅ Correcto - Un solo NavigationStack
NavigationStack {
    DynamicListBuilder<User>()
        .items(users)
        .buildWithoutNavigation() // No crea NavigationStack adicional
}
```

### Cuándo Usar Cada Método

- **`build()`**: Cuando el `DynamicListBuilder` es la vista raíz o no hay navegación existente
- **`buildWithoutNavigation()`**: Cuando ya hay un `NavigationStack` en el contexto padre

## 🆕 Solución Moderna: NavigationStack(path:)

### Problema de Navegación Anidada

Cuando tienes una lista de ejemplos que navega a otras listas, cada una con su propio `NavigationStack`, puedes experimentar comportamientos extraños:

```swift
// ❌ Problema: NavigationStack anidados
NavigationStack {
    List {
        NavigationLink("Example") {
            DynamicListBuilder<User>() // Tiene su propio NavigationStack
                .items(users)
                .build()
        }
    }
}
```

### Solución con NavigationStack(path:)

`NavigationStack(path:)` es la solución moderna que permite manejar múltiples niveles de navegación sin crear stacks anidados:

```swift
// ✅ Solución moderna - NavigationStack(path:) con enum
enum BuilderExample: Hashable {
    case simpleList
    case reactiveList
    case customError
}

struct BuilderExamplesView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                NavigationLink("Simple List", value: BuilderExample.simpleList)
                NavigationLink("Reactive List", value: BuilderExample.reactiveList)
                NavigationLink("Custom Error", value: BuilderExample.customError)
            }
            .navigationDestination(for: BuilderExample.self) { example in
                switch example {
                case .simpleList:
                    DynamicListBuilder<User>()
                        .items(users)
                        .buildWithoutNavigation() // Sin NavigationStack interno
                case .reactiveList:
                    DynamicListBuilder<Product>()
                        .publisher(publisher)
                        .buildWithoutNavigation() // Sin NavigationStack interno
                case .customError:
                    DynamicListBuilder<User>()
                        .publisher(failingPublisher)
                        .buildWithoutNavigation() // Sin NavigationStack interno
                }
            }
        }
    }
}
```

### Ejemplo con Factory Methods

```swift
// ✅ Factory Examples también usa NavigationStack(path:)
enum FactoryExample: Hashable {
    case simpleFactory
    case reactiveFactory
    case simulatedFactory
}

struct FactoryExamplesView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                NavigationLink("Simple Factory", value: FactoryExample.simpleFactory)
                NavigationLink("Reactive Factory", value: FactoryExample.reactiveFactory)
                NavigationLink("Simulated Factory", value: FactoryExample.simulatedFactory)
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

### Ventajas de NavigationStack(path:)

- ✅ **Sin NavigationStack anidados** - Evita comportamientos extraños
- ✅ **Navegación fluida** - Transiciones suaves entre vistas
- ✅ **Control total** - Manejo programático del stack de navegación
- ✅ **Compatibilidad** - Funciona perfectamente con DynamicListBuilder
- ✅ **Escalabilidad** - Fácil agregar más niveles de navegación

### Cuándo Usar NavigationStack(path:)

- **Listas de ejemplos** que navegan a otras listas
- **Menús de navegación** con múltiples niveles
- **Flujos complejos** que requieren control del stack
- **Apps modernas** que usan iOS 16+ y SwiftUI NavigationStack

### Comparación de Soluciones

| Método | Ventajas | Desventajas | Uso Recomendado |
|--------|----------|-------------|-----------------|
| `build()` | Simple, directo | Puede crear stacks anidados | Vistas principales |
| `buildWithoutNavigation()` | Evita stacks anidados | Requiere navegación externa | Dentro de NavigationStack |
| `NavigationStack(path:)` | Control total, sin problemas | Más código inicial | Listas de ejemplos, flujos complejos | 