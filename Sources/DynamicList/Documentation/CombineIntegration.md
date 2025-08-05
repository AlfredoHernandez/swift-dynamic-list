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
- **Refresh funcional**: Recarga real de datos con `refresh()`

## Uso Básico

### Con Datos Estáticos (Sin Cambios)
```swift
let viewModel = DynamicListViewModel<Task>(
    items: [
        Task(title: "Ejemplo", description: "Datos estáticos")
    ]
)
```

### Con Data Provider (Nueva API)
```swift
let viewModel = DynamicListViewModel<Task> {
    dataService.loadTasks()
}
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
let viewModel = DynamicListViewModel<User> {
    loadUsers()
}
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

// Uso
let viewModel = DynamicListViewModel<Task> {
    loadTasksFromBundle()
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

// Uso
let viewModel = DynamicListViewModel<Task> {
    databaseService.tasksPublisher
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

// Uso
let viewModel = DynamicListViewModel<Task> {
    listenToTasks()
}
```

## API del ViewModel

### Inicializadores
```swift
// Con datos estáticos
init(items: [Item] = [])

// Con data provider (nueva API)
init(dataProvider: @escaping () -> AnyPublisher<[Item], Error>, initialItems: [Item] = [])
```

### Métodos Públicos
```swift
// Cambiar fuente de datos dinámicamente
func loadItems(from dataProvider: @escaping () -> AnyPublisher<[Item], Error>)

// Recargar datos (ahora funcional)
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
4. **Pull to Refresh**: Soporte completo para refrescar con datos reales

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
let viewModel = DynamicListViewModel<Task> {
    localService.loadTasks()
}

// Cambiar a otra fuente más tarde
viewModel.loadItems {
    firebaseService.loadTasks()
}
```

### Filtros Dinámicos con Parámetros
```swift
// Cargar todas las tareas
viewModel.loadItems {
    service.loadAllTasks()
}

// Cambiar a solo completadas
viewModel.loadItems {
    service.loadCompletedTasks()
}

// Con parámetros dinámicos
let currentFilter = TaskFilter.completed
viewModel.loadItems {
    service.loadTasks(filter: currentFilter)
}
```

### Datos en Tiempo Real
```swift
// El data provider se llama cada vez que se necesita refrescar
let viewModel = DynamicListViewModel<Task> {
    realtimeService.tasksStream
}

// La UI se actualiza automáticamente
// Y refresh() obtiene datos frescos
```

### Refresh Funcional
```swift
// Ahora refresh() realmente recarga los datos
viewModel.refresh() // Llama al data provider y obtiene datos frescos
```

## Consideraciones de Rendimiento

1. **Threading**: Todos los publishers se ejecutan en el hilo principal automáticamente
2. **Cancelación**: Las suscripciones anteriores se cancelan al cambiar de fuente o refrescar
3. **Memoria**: El ViewModel mantiene referencias débiles para evitar ciclos de retención
4. **Actualizaciones**: Solo se actualiza la UI cuando realmente cambian los datos
5. **Datos Frescos**: Cada `refresh()` obtiene datos actualizados del data provider

## Migración desde Versión Anterior

El código existente sigue funcionando sin cambios:

```swift
// Esto sigue funcionando igual
let viewModel = DynamicListViewModel<Item>(items: staticItems)
```

Para aprovechar las nuevas funcionalidades, cambia de publisher directo a data provider:

```swift
// Antes
let viewModel = DynamicListViewModel<Item>(
    publisher: yourDataService.loadItems()
)

// Ahora
let viewModel = DynamicListViewModel<Item> {
    yourDataService.loadItems()
}
```

## Ventajas de la Nueva API

- ✅ **Refresh funcional**: `refresh()` ahora realmente recarga datos
- ✅ **Más flexible**: Puedes capturar parámetros en la closure
- ✅ **Datos frescos**: Cada refresh obtiene datos actualizados
- ✅ **Mejor testing**: Más fácil mockear una función que un publisher
- ✅ **Parámetros dinámicos**: El data provider puede usar variables del contexto