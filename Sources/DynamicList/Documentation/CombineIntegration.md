# Integración con Combine en DynamicList

## Descripción General

`DynamicList` ahora soporta integración completa con Combine, permitiendo obtener datos de servicios externos de forma reactiva. Esto incluye soporte para:

- APIs REST
- Bases de datos locales (Core Data, SQLite)
- Servicios en tiempo real (Firebase, Firestore)
- Archivos JSON locales
- Cualquier fuente que produzca un `AnyPublisher<[Item], Error>`

## Características Nuevas

### 1. Estados de Carga
- **`isLoading`**: Indica si los datos se están cargando
- **`error`**: Contiene cualquier error que haya ocurrido
- **Estados visuales**: Spinner de carga y pantallas de error automáticas

### 2. Reactividad
- Actualizaciones automáticas cuando cambian los datos
- Soporte para datos en tiempo real
- Cancelación automática de suscripciones

### 3. Flexibilidad
- Compatible con datos estáticos y dinámicos
- Cambio de fuente de datos en tiempo de ejecución
- Manejo de errores integrado

## Uso Básico

### Con Datos Estáticos (Sin Cambios)
```swift
let viewModel = DynamicListViewModel<Task>(
    items: [
        Task(title: "Ejemplo", description: "Datos estáticos")
    ]
)
```

### Con Publisher de Combine
```swift
let viewModel = DynamicListViewModel<Task>(
    publisher: dataService.loadTasks()
)
```

## Ejemplos de Implementación

### 1. API REST con URLSession
```swift
func loadUsers() -> AnyPublisher<[User], Error> {
    let url = URL(string: "https://api.example.com/users")!
    
    return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: [User].self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}

// Uso
let viewModel = DynamicListViewModel<User>(
    publisher: loadUsers()
)
```

### 2. JSON Local
```swift
func loadTasksFromBundle() -> AnyPublisher<[Task], Error> {
    guard let url = Bundle.main.url(forResource: "tasks", withExtension: "json") else {
        return Fail(error: ServiceError.fileNotFound)
            .eraseToAnyPublisher()
    }
    
    return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: [Task].self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}
```

### 3. Base de Datos Local Reactiva
```swift
class DatabaseService {
    private let subject = PassthroughSubject<[Task], Error>()
    
    var tasksPublisher: AnyPublisher<[Task], Error> {
        subject.eraseToAnyPublisher()
    }
    
    func addTask(_ task: Task) {
        // Guardar en base de datos
        // Emitir nueva lista
        subject.send(updatedTasks)
    }
}
```

### 4. Firebase/Firestore Simulado
```swift
func listenToTasks() -> AnyPublisher<[Task], Error> {
    let subject = PassthroughSubject<[Task], Error>()
    
    // Configurar listener de Firestore
    // db.collection("tasks").addSnapshotListener { snapshot, error in
    //     if let error = error {
    //         subject.send(completion: .failure(error))
    //         return
    //     }
    //     
    //     let tasks = snapshot?.documents.compactMap { ... }
    //     subject.send(tasks ?? [])
    // }
    
    return subject.eraseToAnyPublisher()
}
```

## API del ViewModel

### Inicializadores
```swift
// Con datos estáticos
init(items: [Item] = [])

// Con publisher
init(publisher: AnyPublisher<[Item], Error>, initialItems: [Item] = [])
```

### Métodos Públicos
```swift
// Cambiar fuente de datos dinámicamente
func loadItems(from publisher: AnyPublisher<[Item], Error>)

// Recargar datos (para implementación futura)
func refresh()
```

### Propiedades Observables
```swift
var items: [Item]           // Los elementos a mostrar
var isLoading: Bool         // Estado de carga
var error: Error?           // Error si ocurrió
```

## Estados Visuales Automáticos

La vista `DynamicList` maneja automáticamente:

1. **Carga Inicial**: Muestra `ProgressView` si `isLoading` es `true` y no hay elementos
2. **Estado de Error**: Muestra pantalla de error si hay un error y no hay elementos
3. **Lista con Datos**: Muestra la lista normal cuando hay elementos
4. **Pull to Refresh**: Soporte básico para refrescar (expandible)

## Manejo de Errores

```swift
enum ServiceError: Error, LocalizedError {
    case networkError
    case invalidURL
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Error de conexión"
        case .invalidURL:
            return "URL inválida"
        case .decodingError:
            return "Error al procesar los datos"
        }
    }
}
```

## Casos de Uso Avanzados

### Cambio Dinámico de Fuente
```swift
// Inicializar con una fuente
let viewModel = DynamicListViewModel<Task>(
    publisher: localService.loadTasks()
)

// Cambiar a otra fuente más tarde
viewModel.loadItems(from: firebaseService.loadTasks())
```

### Filtros Dinámicos
```swift
// Cargar todas las tareas
viewModel.loadItems(from: service.loadAllTasks())

// Cambiar a solo completadas
viewModel.loadItems(from: service.loadCompletedTasks())
```

### Datos en Tiempo Real
```swift
// El publisher emite automáticamente cuando cambian los datos
let viewModel = DynamicListViewModel<Task>(
    publisher: realtimeService.tasksStream
)

// La UI se actualiza automáticamente
```

## Consideraciones de Rendimiento

1. **Threading**: Todos los publishers se ejecutan en el hilo principal automáticamente
2. **Cancelación**: Las suscripciones anteriores se cancelan al cambiar de fuente
3. **Memoria**: El ViewModel mantiene referencias débiles para evitar ciclos de retención
4. **Actualizaciones**: Solo se actualiza la UI cuando realmente cambian los datos

## Migración desde Versión Anterior

El código existente sigue funcionando sin cambios:

```swift
// Esto sigue funcionando igual
let viewModel = DynamicListViewModel<Item>(items: staticItems)
```

Para aprovechar las nuevas funcionalidades, simplemente pasa un publisher:

```swift
// Nueva funcionalidad
let viewModel = DynamicListViewModel<Item>(
    publisher: yourDataService.loadItems()
)
```