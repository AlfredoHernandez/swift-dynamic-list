# 📁 Estructura de Archivos

Esta documentación describe la organización de archivos del paquete `DynamicList` y cómo están estructurados los diferentes componentes.

## 🏗️ Estructura General

```
DynamicList/
├── Sources/
│   └── DynamicList/
│       ├── Public/                    # APIs públicas del paquete
│       ├── Private/                   # Implementaciones internas
│       │   ├── UI/                    # Componentes de interfaz de usuario
│       │   │   ├── Dynamic List/      # Componentes para listas simples
│       │   │   ├── Sectioned Dynamic List/ # Componentes para listas con secciones
│       │   │   ├── Default Views/     # Vistas por defecto
│       │   │   └── Shared/            # Componentes compartidos
│       │   ├── Domain/                # Lógica de dominio
│       │   │   └── Strategies/        # Estrategias de búsqueda
│       │   └── Presentation/          # Componentes de presentación
│       ├── PreviewSupport/            # Soporte para SwiftUI Previews
│       └── Documentation/             # Documentación del proyecto
└── Tests/
    └── DynamicListTests/              # Tests unitarios y de UI
```

## 📋 Public APIs

### 🎯 DynamicListBuilder
API pública principal para crear listas dinámicas simples.

```
Public/
└── DynamicListBuilder.swift           # Builder pattern para listas simples
```

**Características:**
- API fluida y encadenable
- Soporte para datos estáticos y reactivos
- Configuración de búsqueda avanzada
- Personalización completa de UI
  - Factory methods para casos comunes

### 📋 SectionedDynamicListBuilder
API pública para crear listas dinámicas con secciones.

```
Public/
└── SectionedDynamicListBuilder.swift  # Builder pattern para listas con secciones
```

**Características:**
- API fluida para listas con secciones
- Soporte para arrays de arrays `[[Item]]`
- Headers y footers por sección
- Misma funcionalidad que listas simples

## 🔒 Private Implementation

### 🎨 UI Components

#### **Dynamic List**
Componentes para listas dinámicas simples (sin secciones).

```
UI/Dynamic List/
├── DynamicList.swift              # Vista principal para listas simples
├── DynamicListViewModel.swift     # ViewModel para listas simples
├── DynamicListViewState.swift     # Estados de vista para listas simples
├── DynamicListBuilder.swift       # Builder pattern para listas simples
├── DynamicListContent.swift       # Contenido interno de la lista
├── DynamicListWrapper.swift       # Wrapper con NavigationStack
└── SearchConfiguration.swift      # Configuración de búsqueda
```

**Características:**
- Listas simples con items planos
- Soporte para datos estáticos y reactivos
- Estados de carga, error y éxito
- Pull-to-refresh integrado
- Navegación automática a detalles
- Sistema de búsqueda avanzado

#### **Sectioned Dynamic List**
Componentes para listas dinámicas con secciones y headers/footers.

```
UI/Sectioned Dynamic List/
├── SectionedDynamicList.swift              # Vista principal para listas con secciones
├── SectionedDynamicListViewModel.swift     # ViewModel para listas con secciones
├── SectionedListViewState.swift            # Estados de vista para listas con secciones
├── SectionedDynamicListBuilder.swift       # Builder pattern para listas con secciones
├── SectionedDynamicListContent.swift       # Contenido interno de la lista con secciones
├── SectionedDynamicListWrapper.swift       # Wrapper con NavigationStack
└── ListSection.swift                       # Modelo de datos para secciones
```

**Características:**
- Listas organizadas en secciones
- Headers y footers por sección
- Soporte para arrays de arrays `[[Item]]`
- Sistema de búsqueda avanzado
- Filtrado inteligente por sección
- Misma funcionalidad que listas simples
- Skeleton loading específico para secciones

#### **Default Views**
Vistas por defecto y componentes de UI reutilizables.

```
UI/Default Views/
├── DefaultRowView.swift           # Vista de fila por defecto
├── DefaultDetailView.swift        # Vista de detalle por defecto
├── DefaultErrorView.swift         # Vista de error por defecto
├── DefaultSkeletonView.swift      # Skeleton loading por defecto
└── DefaultSectionedSkeletonView.swift # Skeleton para secciones
```

**Características:**
- Vistas por defecto configurables
- Skeleton loading personalizable
- Manejo de errores consistente
- UI reutilizable entre componentes

#### **Shared Components**
Componentes compartidos entre ambos tipos de listas.

```
UI/Shared/
└── LoadingState.swift             # Estados de carga compartidos
```

**Características:**
- Estados de carga reutilizables
- Enums y tipos compartidos
- Lógica común entre componentes

### 🧠 Domain Layer

#### **Search System**
Sistema de búsqueda avanzado con estrategias personalizables.

```
Domain/
├── Searchable.swift               # Protocolo para items buscables
├── SearchStrategy.swift           # Protocolo de estrategias de búsqueda
└── Strategies/                    # Implementaciones de estrategias
    ├── PartialMatchStrategy.swift # Búsqueda parcial (por defecto)
    ├── ExactMatchStrategy.swift   # Coincidencia exacta
    └── TokenizedMatchStrategy.swift # Búsqueda por tokens
```

**Características:**
- Protocolo `Searchable` para items buscables
- Protocolo `SearchStrategy` para estrategias personalizables
- Estrategias predefinidas: parcial, exacta y tokenizada
- Separación clara entre datos y lógica de búsqueda
- Extensible para estrategias personalizadas

### 🎭 Presentation Layer

#### **Localization**
Soporte para múltiples idiomas.

```
Presentation/
├── DynamicListPresenter.swift     # Presentador para localización
├── en.lproj/                      # Recursos en inglés
├── es-MX.lproj/                   # Recursos en español mexicano
├── fr.lproj/                      # Recursos en francés
└── pt.lproj/                      # Recursos en portugués
```

**Características:**
- Localización completa del paquete
- Soporte para 4 idiomas principales
- Textos localizados para errores y UI
- Fácil extensión a nuevos idiomas

## 📚 Documentation

Documentación completa del proyecto.

```
Documentation/
├── README.md                      # Documentación principal
├── DeveloperGuide.md              # Guía de desarrollador
└── FileStructure.md               # Esta documentación
```

## 👀 PreviewSupport

Soporte para SwiftUI Previews y ejemplos.

```
PreviewSupport/
├── DynamicListPreviews.swift      # Previews para listas simples
├── BuilderExamples.swift          # Ejemplos del Builder Pattern
├── BuilderPreviews.swift          # Previews del Builder
└── PreviewModels.swift            # Modelos para previews
```

## 🧪 Tests

Tests unitarios y de UI.

```
Tests/DynamicListTests/
├── DynamicListTests.swift         # Tests de UI para listas simples
├── DynamicListViewModelTests.swift # Tests unitarios para ViewModels
├── SearchStrategyTests.swift      # Tests para estrategias de búsqueda
└── Helpers/
    └── TestItem.swift             # Modelo de test
```

## 🔗 Relaciones entre Componentes

### Dependencias de Dynamic List
```
DynamicListBuilder (Public)
├── DynamicList (Private)
├── DynamicListViewModel (Private)
├── DynamicListViewState (Private)
├── SearchConfiguration (Private)
├── LoadingState (Private/Shared)
└── Default Views (Private)
```

### Dependencias de Sectioned Dynamic List
```
SectionedDynamicListBuilder (Public)
├── SectionedDynamicList (Private)
├── SectionedDynamicListViewModel (Private)
├── SectionedListViewState (Private)
├── ListSection (Private)
├── SearchConfiguration (Private)
├── LoadingState (Private/Shared)
└── Default Views (Private)
```

### Dependencias del Sistema de Búsqueda
```
SearchConfiguration (Private)
├── Searchable (Private/Domain)
├── SearchStrategy (Private/Domain)
└── Strategies (Private/Domain)
```

### Componentes Compartidos
```
Shared/
└── LoadingState
    ├── DynamicList (usa)
    └── SectionedDynamicList (usa)

Default Views/
├── DynamicList (usa)
└── SectionedDynamicList (usa)

Domain/
├── Searchable
│   ├── DynamicList (usa)
│   └── SearchStrategy (usa)
└── SearchStrategy
    └── DynamicList (usa)
```

## 🎯 Principios de Organización

### 1. **Separación de Responsabilidades**
- **Public APIs**: Solo los builders están expuestos públicamente
- **Private Implementation**: Toda la lógica interna está encapsulada
- **Domain Layer**: Lógica de negocio separada de la UI
- **UI Components**: Componentes específicos por tipo de lista

### 2. **Modularidad**
- **Componentes independientes**: Cada tipo de lista tiene sus propios componentes
- **Dependencias claras**: Jerarquía clara de dependencias
- **Fácil mantenimiento**: Cambios aislados por componente
- **Extensibilidad**: Fácil agregar nuevos tipos de listas

### 3. **Reutilización**
- **Componentes compartidos**: LoadingState y Default Views reutilizables
- **Domain reutilizable**: Sistema de búsqueda independiente de la UI
- **Configuraciones flexibles**: SearchConfiguration para diferentes casos de uso

### 4. **Escalabilidad**
- **Arquitectura preparada**: Estructura preparada para futuras extensiones
- **APIs estables**: APIs públicas bien definidas y estables
- **Testing completo**: Tests organizados por funcionalidad

## 🚀 Beneficios de la Nueva Estructura

### Para Desarrolladores
- **Claridad**: Separación clara entre APIs públicas e implementación privada
- **Mantenimiento**: Cambios aislados por componente y capa
- **Reutilización**: Componentes compartidos bien definidos
- **Testing**: Tests organizados por funcionalidad

### Para el Proyecto
- **Escalabilidad**: Fácil agregar nuevos tipos de listas y funcionalidades
- **Performance**: Solo importar lo necesario
- **Documentación**: Estructura clara y documentada
- **Calidad**: Separación clara de responsabilidades

## 📝 Convenciones de Nomenclatura

### Archivos de Componentes
- `[ComponentName].swift` - Componente principal
- `[ComponentName]ViewModel.swift` - ViewModel del componente
- `[ComponentName]ViewState.swift` - Estados de vista
- `[ComponentName]Builder.swift` - Builder pattern
- `[ComponentName]Content.swift` - Contenido interno
- `[ComponentName]Wrapper.swift` - Wrapper con navegación

### Archivos de Dominio
- `[Feature].swift` - Protocolos y tipos principales
- `[Feature]Strategy.swift` - Estrategias específicas
- `[Feature]Configuration.swift` - Configuraciones

### Archivos de Tests
- `[ComponentName]Tests.swift` - Tests de UI
- `[ComponentName]ViewModelTests.swift` - Tests de ViewModel
- `[Feature]Tests.swift` - Tests de funcionalidad específica

## 🔒 Control de Acceso

### Public APIs
- `DynamicListBuilder<Item>` - Builder principal para listas simples
- `SectionedDynamicListBuilder<Item>` - Builder para listas con secciones
- `SearchConfiguration<Item>` - Configuración de búsqueda
- `Searchable` - Protocolo para items buscables
- `SearchStrategy` - Protocolo para estrategias de búsqueda

### Private Implementation
- Todos los componentes de UI están marcados como `internal`
- Los ViewModels y ViewStates son `internal`
- Los componentes de dominio son `internal`
- Las estrategias de búsqueda son `internal`

Esta estructura proporciona una base sólida y escalable para el paquete `DynamicList`, con una clara separación de responsabilidades y APIs públicas bien definidas.