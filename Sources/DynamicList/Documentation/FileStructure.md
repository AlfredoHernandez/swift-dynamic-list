# 📁 Estructura de Archivos

Esta documentación describe la organización de archivos del paquete `DynamicList` y cómo están estructurados los diferentes componentes.

## 🏗️ Estructura General

```
DynamicList/
├── Sources/
│   └── DynamicList/
│       ├── Core Components/
│       │   ├── Dynamic List/           # Componentes para listas simples
│       │   ├── Sectioned Dynamic List/ # Componentes para listas con secciones
│       │   ├── Shared/                 # Componentes compartidos
│       │   └── Default Views/          # Vistas por defecto
│       ├── Domain/                     # Dominio de búsqueda
│       │   ├── Searchable.swift        # Protocolo para items buscables
│       │   ├── SearchStrategy.swift    # Protocolo de estrategias de búsqueda
│       │   └── Strategies/             # Implementaciones de estrategias
│       │       ├── PartialMatchStrategy.swift
│       │       ├── ExactMatchStrategy.swift
│       │       └── TokenizedMatchStrategy.swift
│       ├── Documentation/              # Documentación del proyecto
│       ├── Presentation/               # Componentes de presentación
│       └── PreviewSupport/             # Soporte para SwiftUI Previews
└── Tests/
    └── DynamicListTests/               # Tests unitarios y de UI
```

## 📋 Core Components

### 🎯 Dynamic List
Componentes para listas dinámicas simples (sin secciones).

```
Dynamic List/
├── DynamicList.swift              # Vista principal para listas simples
├── DynamicListViewModel.swift     # ViewModel para listas simples
├── DynamicListViewState.swift     # Estados de vista para listas simples
├── DynamicListBuilder.swift       # Builder pattern para listas simples
├── DynamicListContent.swift       # Contenido interno de la lista
└── DynamicListWrapper.swift       # Wrapper con NavigationStack
```

**Características:**
- Listas simples con items planos
- Soporte para datos estáticos y reactivos
- Estados de carga, error y éxito
- Pull-to-refresh integrado
- Navegación automática a detalles

### 📋 Sectioned Dynamic List
Componentes para listas dinámicas con secciones y headers/footers.

```
Sectioned Dynamic List/
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
- Misma funcionalidad que listas simples
- Skeleton loading específico para secciones

### 🔄 Shared
Componentes compartidos entre ambos tipos de listas.

```
Shared/
└── LoadingState.swift             # Estados de carga compartidos
```

**Características:**
- Estados de carga reutilizables
- Enums y tipos compartidos
- Lógica común entre componentes

### 🎨 Default Views
Vistas por defecto y componentes de UI reutilizables.

```
Default Views/
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

### 🔍 Domain
Dominio de búsqueda y estrategias de filtrado.

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

## 📚 Documentation

Documentación completa del proyecto.

```
Documentation/
├── README.md                      # Documentación principal
├── DeveloperGuide.md              # Guía para desarrolladores
├── CombineIntegration.md          # Integración con Combine
├── CustomErrorViews.md            # Vistas de error personalizadas
├── DynamicListBuilder.md          # Documentación del Builder Pattern
├── FileStructure.md               # Este archivo
└── Localization.md                # Soporte para localización
```

## 🎭 Presentation

Componentes de presentación y localización.

```
Presentation/
├── DynamicListPresenter.swift     # Presentador para localización
├── en.lproj/                      # Localización en inglés
├── es-MX.lproj/                   # Localización en español
├── fr.lproj/                      # Localización en francés
└── pt.lproj/                      # Localización en portugués
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
DynamicList
├── DynamicListViewModel
├── DynamicListViewState
├── LoadingState (Shared)
├── Default Views
└── Domain (Searchable, SearchStrategy)
```

### Dependencias de Sectioned Dynamic List
```
SectionedDynamicList
├── SectionedDynamicListViewModel
├── SectionedListViewState
├── ListSection
├── LoadingState (Shared)
└── Default Views
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
- Cada tipo de lista tiene sus propios componentes
- Lógica específica separada de lógica compartida
- Vistas por defecto reutilizables

### 2. **Modularidad**
- Componentes independientes y autocontenidos
- Dependencias claras y mínimas
- Fácil mantenimiento y extensión

### 3. **Reutilización**
- Componentes compartidos bien definidos
- Vistas por defecto configurables
- Estados y tipos reutilizables

### 4. **Escalabilidad**
- Estructura preparada para futuras extensiones
- Fácil agregar nuevos tipos de listas
- Componentes extensibles

## 🚀 Beneficios de la Nueva Estructura

### Para Desarrolladores
- **Claridad**: Cada tipo de lista tiene su propia carpeta
- **Mantenimiento**: Cambios aislados por componente
- **Reutilización**: Componentes compartidos bien definidos
- **Testing**: Tests organizados por funcionalidad

### Para el Proyecto
- **Escalabilidad**: Fácil agregar nuevos tipos de listas
- **Performance**: Solo importar lo necesario
- **Documentación**: Estructura clara y documentada
- **Calidad**: Separación clara de responsabilidades

## 📝 Convenciones de Nomenclatura

### Archivos de Componentes
- `[ComponentName].swift` - Componente principal
- `[ComponentName]ViewModel.swift` - ViewModel del componente
- `[ComponentName]ViewState.swift` - Estados del componente
- `[ComponentName]Builder.swift` - Builder pattern del componente

### Archivos de Soporte
- `[ComponentName]Content.swift` - Contenido interno
- `[ComponentName]Wrapper.swift` - Wrapper con navegación
- `Default[ComponentName].swift` - Vistas por defecto

### Carpetas
- `Dynamic List/` - Componentes para listas simples
- `Sectioned Dynamic List/` - Componentes para listas con secciones
- `Shared/` - Componentes compartidos
- `Default Views/` - Vistas por defecto

Esta estructura modular permite un desarrollo más eficiente, mantenimiento más fácil y una experiencia de usuario consistente entre diferentes tipos de listas.