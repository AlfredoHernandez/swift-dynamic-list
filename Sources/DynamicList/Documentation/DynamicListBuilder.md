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
        .withItems(users)
        .withTitle("Usuarios")
        .withRowContent { user in
            HStack {
                Text(user.name)
                Spacer()
                Text(user.email)
                    .foregroundColor(.secondary)
            }
        }
        .withDetailContent { user in
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
        .withPublisher(usersPublisher)
        .withTitle("Usuarios")
        .withRowContent { user in
            Text(user.name)
        }
        .withDetailContent { user in
            Text("Detalle de \(user.name)")
        }
        .build()
}
```

### 3. Lista con Carga Simulada

```swift
var body: some View {
    DynamicListBuilder<User>()
        .withSimulatedPublisher(users, delay: 2.0)
        .withTitle("Cargando Usuarios")
        .withRowContent { user in
            Text(user.name)
        }
        .withDetailContent { user in
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
        .withPublisher(failingPublisher)
        .withErrorContent { error in
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
        .withItems(users)
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
    .withPublisher(usersPublisher)
    .withRowContent { user in
        Text(user.name)
    }
    .withDetailContent { user in
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
- `withItems(_:)` - Datos estáticos
- `withPublisher(_:)` - Publisher de Combine
- `withSimplePublisher(_:)` - Publisher simple
- `withSimulatedPublisher(_:delay:)` - Publisher con simulación de carga

### Configuración de UI
- `withRowContent(_:)` - Contenido de fila
- `withDetailContent(_:)` - Contenido de detalle
- `withErrorContent(_:)` - Vista de error personalizada
- `withTitle(_:)` - Título de navegación
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
    .withPublisher(apiService.fetchProducts())
    .withTitle("Productos")
    .withRowContent { product in
        ProductRowView(product: product)
    }
    .withDetailContent { product in
        ProductDetailView(product: product)
    }
    .build()
```

### Lista de Usuarios con Firebase
```swift
DynamicListBuilder<User>()
    .withPublisher(firebaseService.usersPublisher())
    .withTitle("Usuarios")
    .withRowContent { user in
        UserRowView(user: user)
    }
    .withDetailContent { user in
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