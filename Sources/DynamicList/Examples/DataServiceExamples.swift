//
//  Copyright © 2025 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation

// MARK: - Example Data Models

/// Modelo de ejemplo para una tarea
public struct Task: Identifiable, Hashable, Codable {
    public let id: UUID
    public let title: String
    public let description: String
    public let isCompleted: Bool
    public let createdAt: Date

    public init(id: UUID = UUID(), title: String, description: String, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

/// Modelo de ejemplo para un usuario
public struct User: Identifiable, Hashable, Codable {
    public let id: Int
    public let name: String
    public let email: String
    public let username: String

    public init(id: Int, name: String, email: String, username: String) {
        self.id = id
        self.name = name
        self.email = email
        self.username = username
    }
}

// MARK: - Data Service Examples

/// Servicio que simula la carga de datos de un JSON local
@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public final class LocalJSONService {
    /// Carga tareas desde un archivo JSON local
    public static func loadTasks() -> AnyPublisher<[Task], Error> {
        let tasks = [
            Task(title: "Implementar DynamicList", description: "Crear el componente de lista dinámica"),
            Task(title: "Agregar Combine", description: "Integrar soporte para publishers"),
            Task(title: "Escribir tests", description: "Crear pruebas unitarias", isCompleted: true),
            Task(title: "Documentar API", description: "Escribir documentación completa"),
        ]

        return Just(tasks)
            .delay(for: .seconds(1), scheduler: DispatchQueue.main) // Simula tiempo de carga
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    /// Carga tareas desde un archivo JSON en el bundle
    public static func loadTasksFromBundle(fileName: String = "tasks") -> AnyPublisher<[Task], Error> {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return Fail(error: ServiceError.fileNotFound)
                .eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Task].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

/// Servicio que simula llamadas a una API REST
@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public final class APIService {
    private let baseURL = "https://jsonplaceholder.typicode.com"

    /// Carga usuarios desde JSONPlaceholder API
    public func loadUsers() -> AnyPublisher<[User], Error> {
        guard let url = URL(string: "\(baseURL)/users") else {
            return Fail(error: ServiceError.invalidURL)
                .eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [User].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Carga posts y los convierte a tareas
    public func loadPostsAsTasks() -> AnyPublisher<[Task], Error> {
        struct Post: Codable {
            let id: Int
            let title: String
            let body: String
            let userID: Int
        }

        guard let url = URL(string: "\(baseURL)/posts") else {
            return Fail(error: ServiceError.invalidURL)
                .eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Post].self, decoder: JSONDecoder())
            .map { posts in
                posts.prefix(10).map { post in
                    Task(
                        id: UUID(),
                        title: post.title.capitalized,
                        description: post.body,
                        isCompleted: Bool.random(),
                    )
                }
            }
            .map(Array.init)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

/// Servicio que simula una base de datos local (como Core Data o SQLite)
@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public final class DatabaseService {
    private var tasks: [Task] = []
    private let subject = PassthroughSubject<[Task], Error>()

    public init() {
        // Simula datos iniciales
        tasks = [
            Task(title: "Base de datos local", description: "Ejemplo de Core Data"),
            Task(title: "Persistencia", description: "Guardar datos localmente"),
        ]
    }

    /// Publisher que emite cambios en tiempo real
    public var tasksPublisher: AnyPublisher<[Task], Error> {
        // Emite los datos iniciales después de un delay
        let initial = Just(tasks)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)

        // Combina los datos iniciales con actualizaciones en tiempo real
        return Publishers.Merge(initial, subject)
            .eraseToAnyPublisher()
    }

    /// Simula agregar una nueva tarea
    public func addTask(_ task: Task) {
        tasks.append(task)
        subject.send(tasks)
    }

    /// Simula actualizar una tarea
    public func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            subject.send(tasks)
        }
    }

    /// Simula eliminar una tarea
    public func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
        subject.send(tasks)
    }
}

/// Servicio que simula Firebase o Firestore
@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public final class FirebaseService {
    /// Simula un listener de Firestore que emite cambios en tiempo real
    public static func listenToTasks() -> AnyPublisher<[Task], Error> {
        let subject = PassthroughSubject<[Task], Error>()

        // Simula la carga inicial
        Task { @MainActor in
            try await Task.sleep(for: .seconds(1))
            let initialTasks = [
                Task(title: "Firebase Task 1", description: "Desde Firestore"),
                Task(title: "Firebase Task 2", description: "Tiempo real", isCompleted: true),
            ]
            subject.send(initialTasks)
        }

        // Simula actualizaciones en tiempo real
        Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            let updatedTasks = [
                Task(title: "Firebase Task 1", description: "Desde Firestore"),
                Task(title: "Firebase Task 2", description: "Tiempo real", isCompleted: true),
                Task(title: "Nueva tarea", description: "Agregada en tiempo real"),
            ]
            subject.send(updatedTasks)
        }

        return subject.eraseToAnyPublisher()
    }

    /// Simula obtener datos con filtros
    public static func loadTasksWithFilter(completed: Bool?) -> AnyPublisher<[Task], Error> {
        let allTasks = [
            Task(title: "Tarea completada", description: "Esta está terminada", isCompleted: true),
            Task(title: "Tarea pendiente", description: "Esta está pendiente", isCompleted: false),
            Task(title: "Otra completada", description: "También terminada", isCompleted: true),
        ]

        let filteredTasks: [Task] = if let completed {
            allTasks.filter { $0.isCompleted == completed }
        } else {
            allTasks
        }

        return Just(filteredTasks)
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Error Types

public enum ServiceError: Error, LocalizedError {
    case invalidURL
    case fileNotFound
    case networkError
    case decodingError
    case firebaseError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            "URL inválida"
        case .fileNotFound:
            "Archivo no encontrado"
        case .networkError:
            "Error de conexión"
        case .decodingError:
            "Error al procesar los datos"
        case let .firebaseError(message):
            "Error de Firebase: \(message)"
        }
    }
}

// MARK: - Usage Examples

/*

 Ejemplos de uso:

 // 1. Con datos locales estáticos
 let viewModel = DynamicListViewModel<Task>(
     items: [
         Task(title: "Ejemplo", description: "Datos estáticos")
     ]
 )

 // 2. Con JSON local
 let viewModel = DynamicListViewModel<Task>(
     publisher: LocalJSONService.loadTasks()
 )

 // 3. Con API REST
 let apiService = APIService()
 let viewModel = DynamicListViewModel<User>(
     publisher: apiService.loadUsers()
 )

 // 4. Con base de datos local reactiva
 let dbService = DatabaseService()
 let viewModel = DynamicListViewModel<Task>(
     publisher: dbService.tasksPublisher
 )

 // 5. Con Firebase/Firestore
 let viewModel = DynamicListViewModel<Task>(
     publisher: FirebaseService.listenToTasks()
 )

 // 6. Cambiar fuente de datos dinámicamente
 viewModel.loadItems(from: FirebaseService.loadTasksWithFilter(completed: false))

 */
