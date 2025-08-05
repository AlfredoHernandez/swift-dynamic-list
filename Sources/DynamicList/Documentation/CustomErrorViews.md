# Vistas de Error Personalizadas en DynamicList

## Descripción General

`DynamicList` permite personalizar completamente la vista que se muestra cuando ocurre un error al cargar los datos. Puedes usar la vista de error por defecto o crear tu propia vista personalizada.

## Uso Básico

### Vista de Error Por Defecto

Si no especificas una vista de error personalizada, `DynamicList` usará automáticamente la vista por defecto:

```swift
let viewModel = DynamicListViewModel<Task>(
    publisher: dataService.loadTasks()
)

DynamicList(
    viewModel: viewModel,
    rowContent: { task in
        Text(task.title)
    },
    detailContent: { task in
        Text("Detail: \(task.title)")
    }
    // No errorContent especificado = usa vista por defecto
)
```

La vista por defecto incluye:
- ⚠️ Icono de advertencia naranja
- Título "Error al cargar los datos"
- Descripción del error
- Diseño centrado y responsive

### Vista de Error Personalizada

Para usar una vista de error personalizada, proporciona el parámetro `errorContent`:

```swift
DynamicList(
    viewModel: viewModel,
    rowContent: { task in
        Text(task.title)
    },
    detailContent: { task in
        Text("Detail: \(task.title)")
    },
    errorContent: { error in
        // Tu vista personalizada aquí
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
            Text("Error: \(error.localizedDescription)")
        }
    }
)
```

## Ejemplos de Vistas de Error

### 1. Vista de Error con Botón de Reintento

```swift
errorContent: { error in
    VStack(spacing: 20) {
        Image(systemName: "wifi.slash")
            .font(.system(size: 60))
            .foregroundColor(.red)
        
        Text("Sin Conexión")
            .font(.largeTitle)
            .fontWeight(.bold)
        
        Text(error.localizedDescription)
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
        
        Button("Reintentar") {
            viewModel.refresh()
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
    .padding()
}
```

### 2. Vista de Error Minimalista

```swift
errorContent: { error in
    HStack {
        Image(systemName: "xmark.circle.fill")
            .foregroundColor(.red)
        Text(error.localizedDescription)
            .foregroundColor(.secondary)
    }
    .padding()
    .background(.regularMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 12))
}
```

### 3. Vista de Error con Diferentes Estados

```swift
errorContent: { error in
    VStack(spacing: 16) {
        let (icon, color, title) = errorInfo(for: error)
        
        Image(systemName: icon)
            .font(.system(size: 48))
            .foregroundColor(color)
        
        Text(title)
            .font(.headline)
        
        Text(error.localizedDescription)
            .font(.caption)
            .foregroundColor(.secondary)
        
        Button("Reintentar") {
            viewModel.refresh()
        }
        .buttonStyle(.bordered)
    }
    .padding()
}

func errorInfo(for error: Error) -> (icon: String, color: Color, title: String) {
    switch error {
    case is URLError:
        return ("wifi.slash", .orange, "Sin Conexión")
    case let customError as CustomError where customError.isAuthError:
        return ("person.slash", .red, "No Autorizado")
    default:
        return ("exclamationmark.triangle", .yellow, "Error General")
    }
}
```

### 4. Vista de Error con Animaciones

```swift
errorContent: { error in
    VStack(spacing: 20) {
        Image(systemName: "exclamationmark.triangle")
            .font(.system(size: 60))
            .foregroundColor(.orange)
            .scaleEffect(animating ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 1).repeatForever(), value: animating)
            .onAppear { animating = true }
        
        Text("¡Ups! Algo salió mal")
            .font(.title2)
            .fontWeight(.semibold)
        
        Text(error.localizedDescription)
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
    }
    .padding()
}
```

## Mejores Prácticas

### 1. Consistencia de Diseño
Mantén el estilo consistente con tu aplicación:

```swift
errorContent: { error in
    ErrorCard(error: error) // Tu componente reutilizable
}
```

### 2. Accesibilidad
Asegúrate de que tu vista de error sea accesible:

```swift
errorContent: { error in
    VStack {
        Image(systemName: "exclamationmark.triangle")
            .accessibilityLabel("Error")
        Text(error.localizedDescription)
            .accessibilityRole(.text)
    }
    .accessibilityElement(children: .combine)
}
```

### 3. Manejo de Errores Específicos
Personaliza la vista según el tipo de error:

```swift
errorContent: { error in
    switch error {
    case let networkError as URLError:
        NetworkErrorView(error: networkError)
    case let authError as AuthenticationError:
        AuthErrorView(error: authError)
    default:
        GenericErrorView(error: error)
    }
}
```

### 4. Estados de Carga con Datos Previos
Cuando hay datos previos disponibles, considera mostrar un overlay en lugar de reemplazar toda la vista:

```swift
// El ViewState maneja esto automáticamente
// Si hay items existentes, shouldShowError será false
// y puedes mostrar un overlay o banner de error
```

## Integración con ViewState

Las vistas de error personalizadas se integran perfectamente con el sistema de estados:

```swift
// La vista de error solo se muestra cuando:
viewModel.viewState.shouldShowError == true

// Esto ocurre cuando:
// - loadingState == .error(let error)
// - items.isEmpty == true
```

## Ejemplos Completos

### Vista de Error con Múltiples Acciones

```swift
struct MultiActionErrorView: View {
    let error: Error
    let onRetry: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 72))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Error al Cargar")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(error.localizedDescription)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                Button("Cancelar") {
                    onCancel()
                }
                .buttonStyle(.bordered)
                
                Button("Reintentar") {
                    onRetry()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Uso:
errorContent: { error in
    MultiActionErrorView(
        error: error,
        onRetry: { viewModel.refresh() },
        onCancel: { /* acción de cancelar */ }
    )
}
```

## Compatibilidad

- ✅ **Compatibilidad hacia atrás**: El código existente sigue funcionando sin cambios
- ✅ **Tipo seguro**: El compilador verifica que los tipos sean correctos
- ✅ **Flexible**: Puedes usar cualquier vista de SwiftUI
- ✅ **Reutilizable**: Las vistas de error pueden ser componentes independientes