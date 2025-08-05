# Estructura de Archivos del Paquete DynamicList

## Descripción de la Reorganización

El código ha sido reorganizado para mejorar la mantenibilidad y separar responsabilidades. Cada componente ahora tiene su propio archivo dedicado.

## Estructura Actual

```
Sources/DynamicList/
├── Core Components/
│   ├── DynamicList.swift                    # Vista principal del componente
│   ├── DynamicListViewModel.swift           # ViewModel con manejo de estado
│   ├── ViewState.swift                      # Estados y tipos relacionados
│   └── DefaultErrorView.swift               # Vista de error por defecto
│
├── Preview Support/
│   ├── DynamicListPreviews.swift           # Todos los previews de SwiftUI
│   └── PreviewModels.swift                 # Modelos usados solo en previews
│
├── Examples/
│   ├── DataServiceExamples.swift           # Ejemplos de servicios de datos
│   └── ViewStateExamples.swift             # Ejemplos avanzados con ViewState
│
└── Documentation/
    ├── CombineIntegration.md               # Guía de integración con Combine
    ├── CustomErrorViews.md                 # Guía de vistas de error personalizadas
    └── FileStructure.md                    # Este archivo
```

## Detalles de cada archivo

### Core Components

#### `DynamicList.swift` (90 líneas)
- **Propósito**: Vista principal del componente
- **Contenido**:
  - Struct principal `DynamicList<Item, RowContent, DetailContent, ErrorContent>`
  - Dos inicializadores (con y sin vista de error personalizada)
  - Lógica de renderizado principal
  - Vista de error privada

#### `DynamicListViewModel.swift` (118 líneas)
- **Propósito**: ViewModel observable con integración Combine
- **Contenido**:
  - Clase `DynamicListViewModel<Item>`
  - Manejo de `ListViewState`
  - Integración con `AnyPublisher`
  - Propiedades de conveniencia para compatibilidad hacia atrás

#### `ViewState.swift` (141 líneas)
- **Propósito**: Definición de estados y tipos relacionados
- **Contenido**:
  - Enum `LoadingState` (idle, loading, loaded, error)
  - Struct `ListViewState<Item>` con propiedades de conveniencia
  - Métodos de creación estática
  - Propiedades computadas para estados de UI

#### `DefaultErrorView.swift` (30 líneas)
- **Propósito**: Vista de error por defecto cuando no se especifica una personalizada
- **Contenido**:
  - Struct `DefaultErrorView` con diseño estándar
  - Ícono de advertencia, título y descripción del error
  - Diseño responsive y centrado

### Preview Support

#### `DynamicListPreviews.swift` (194 líneas)
- **Propósito**: Todos los previews de SwiftUI para demostrar funcionalidad
- **Contenido**:
  - Preview con datos estáticos
  - Preview con Combine Publisher exitoso
  - Preview con error usando vista por defecto
  - Preview con vista de error personalizada elaborada
  - Preview con vista de error minimalista

#### `PreviewModels.swift` (59 líneas)
- **Propósito**: Modelos y tipos usados exclusivamente en previews
- **Contenido**:
  - `FruitColor` enum para ejemplos
  - `Fruit` struct para datos de muestra
  - `Task` struct para ejemplos simples
  - `LoadError` y `SimpleError` para demostraciones de errores

### Examples

#### `DataServiceExamples.swift`
- **Propósito**: Ejemplos prácticos de integración con servicios de datos
- **Contenido**:
  - `LocalJSONService` - Carga desde archivos locales
  - `APIService` - Integración con APIs REST
  - `DatabaseService` - Simulación de base de datos reactiva
  - `FirebaseService` - Simulación de tiempo real
  - Tipos de error y comentarios de uso

#### `ViewStateExamples.swift`
- **Propósito**: Ejemplos avanzados usando ViewState directamente
- **Contenido**:
  - `AdvancedDynamicList` - Implementación con control granular
  - Vistas de soporte (EmptyStateView, LoadingView, ErrorView, etc.)
  - Overlays para diferentes estados
  - Ejemplos de uso en comentarios

## Beneficios de esta Organización

### ✅ **Mantenibilidad**
- Cada archivo tiene una responsabilidad clara
- Fácil localizar y modificar funcionalidades específicas
- Separación entre código de producción y código de preview

### ✅ **Reutilización**
- Componentes independientes pueden ser reutilizados
- `DefaultErrorView` puede usarse fuera de `DynamicList`
- Modelos de preview no interfieren con código de producción

### ✅ **Testabilidad**
- ViewState es testeable de forma independiente
- ViewModels pueden ser probados sin dependencias de UI
- Separación clara entre lógica y presentación

### ✅ **Navegabilidad**
- Estructura clara para desarrolladores nuevos
- Fácil localización de ejemplos y documentación
- Archivos más pequeños y enfocados

### ✅ **Build Performance**
- Compilación más eficiente con archivos más pequeños
- Menos dependencias entre archivos
- Previews no afectan compilación de producción

## Migración desde Versión Anterior

Si estabas usando la versión anterior donde todo estaba en un solo archivo:

### ✅ **Sin Cambios Requeridos**
- La API pública sigue siendo idéntica
- Todos los imports existentes siguen funcionando
- Compatibilidad hacia atrás 100% garantizada

### ✅ **Nuevas Funcionalidades Disponibles**
- Vistas de error personalizables
- ViewState para control granular
- Más ejemplos y documentación

## Estructura de Imports

Para usar el paquete, solo necesitas:

```swift
import DynamicList

// Todos los tipos públicos están disponibles:
// - DynamicList
// - DynamicListViewModel  
// - ListViewState
// - LoadingState
// - DefaultErrorView
```

Los archivos de preview y examples no se incluyen en el paquete compilado, solo están disponibles durante desarrollo y para referencia.