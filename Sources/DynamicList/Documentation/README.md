# 📚 Documentación de DynamicList

Bienvenido a la documentación completa del paquete **DynamicList**, una solución moderna y reactiva para crear listas dinámicas en SwiftUI con soporte completo para Combine.

## 🎯 Visión General

**DynamicList** es un paquete SwiftUI que simplifica la creación de listas dinámicas con:
- ✅ **Integración nativa con Combine** para datos reactivos
- ✅ **Patrón MVVM** con ViewModels observables
- ✅ **API fluida** con patrón Builder (forma recomendada de uso)
- ✅ **Soporte completo de localización** en múltiples idiomas
- ✅ **Vistas de error personalizables**
- ✅ **Navegación moderna** con NavigationStack
- ✅ **API limpia** - Solo expone lo necesario

## 📖 Índice de Documentación

### 🚀 Guías de Inicio

#### [1. Integración con Combine](./CombineIntegration.md)
- **Descripción**: Guía completa sobre cómo integrar Combine con DynamicList
- **Contenido**:
  - Configuración de Publishers
  - Manejo de estados de carga
  - Gestión de errores
  - Ejemplos prácticos con Firebase y APIs
- **Audiencia**: Desarrolladores que quieren usar datos reactivos

#### [2. DynamicList Builder](./DynamicListBuilder.md)
- **Descripción**: Guía completa del patrón Builder para crear listas dinámicas
- **Contenido**:
  - API fluida y métodos encadenables
  - Factory methods para casos comunes
  - Configuración de navegación
  - Soluciones para NavigationStack anidados
- **Audiencia**: Desarrolladores que quieren crear listas de forma rápida y elegante

### 🎨 Personalización

#### [3. Vistas de Error Personalizables](./CustomErrorViews.md)
- **Descripción**: Cómo crear y personalizar vistas de error
- **Contenido**:
  - Vista de error por defecto
  - Creación de vistas personalizadas
  - Integración con el Builder
  - Ejemplos de implementación
- **Audiencia**: Desarrolladores que necesitan manejar estados de error

#### [4. Sistema de Localización](./Localization.md)
- **Descripción**: Guía completa del sistema de localización
- **Contenido**:
  - Configuración de idiomas (EN, ES-MX, FR, PT)
  - Uso de DynamicListPresenter
  - Creación de strings localizados
  - Mejores prácticas
- **Audiencia**: Desarrolladores que necesitan soporte multiidioma

### 🏗️ Arquitectura

#### [5. Estructura de Archivos](./FileStructure.md)
- **Descripción**: Organización y estructura del paquete
- **Contenido**:
  - Estructura de directorios
  - Organización de componentes
  - Separación de responsabilidades
  - Convenciones de nomenclatura
- **Audiencia**: Desarrolladores que quieren entender la arquitectura

## 🎯 Casos de Uso Comunes

### Lista Simple con Datos Estáticos
```swift
// ✅ Forma recomendada - Usar DynamicListBuilder
DynamicListBuilder<User>()
    .items(users)
    .rowContent { user in
        Text(user.name)
    }
    .detailContent { user in
        Text("Detalle de \(user.name)")
    }
    .build()
```

### Lista Reactiva con API
```swift
// ✅ Forma recomendada - Usar DynamicListBuilder
DynamicListBuilder<Product>()
    .publisher(apiService.fetchProducts())
    .rowContent { product in
        ProductRowView(product: product)
    }
    .detailContent { product in
        ProductDetailView(product: product)
    }
    .build()
```

### Lista con Manejo de Errores
```swift
// ✅ Forma recomendada - Usar DynamicListBuilder
DynamicListBuilder<User>()
    .publisher(failingPublisher)
    .errorContent { error in
        CustomErrorView(error: error)
    }
    .build()
```

### Factory Methods (Aún Más Simple)
```swift
// ✅ Factory methods para casos comunes
DynamicListBuilder.simple(
    items: users,
    rowContent: { user in Text(user.name) },
    detailContent: { user in Text("Detalle de \(user.name)") }
)
```

## 🔧 Configuración Rápida

### 1. Agregar Dependencia
```swift
dependencies: [
    .package(url: "https://github.com/tu-usuario/DynamicList.git", from: "1.0.0")
]
```

### 2. Importar el Módulo
```swift
import DynamicList
```

### 3. Crear tu Primera Lista
```swift
struct ContentView: View {
    var body: some View {
        DynamicListBuilder<User>()
            .items(User.sampleUsers)
            .build()
    }
}
```

## 📱 Plataformas Soportadas

- **iOS**: 17.0+
- **macOS**: 14.0+
- **watchOS**: 10.0+
- **tvOS**: 17.0+

## 🛠️ Requisitos

- **Xcode**: 15.0+
- **Swift**: 6.0+
- **SwiftUI**: 5.0+
- **Combine**: Disponible en las plataformas soportadas

## 🎯 Características Principales

| Característica | Descripción | Estado |
|----------------|-------------|--------|
| **Combine Integration** | Soporte nativo para Publishers | ✅ Completo |
| **Builder Pattern** | API fluida y encadenable | ✅ Completo |
| **Localization** | Soporte multiidioma | ✅ Completo |
| **Custom Errors** | Vistas de error personalizables | ✅ Completo |
| **Navigation** | Soporte para NavigationStack | ✅ Completo |
| **MVVM** | Patrón Model-View-ViewModel | ✅ Completo |
| **Type Safety** | Completamente tipado | ✅ Completo |
| **Clean Code** | Sin @available redundantes | ✅ Completo |
| **API Design** | Solo expone lo necesario | ✅ Completo |

## 🎨 Características Principales

| Característica | Descripción | Estado |
|----------------|-------------|--------|
| **Combine Integration** | Soporte nativo para Publishers | ✅ Completo |
| **Builder Pattern** | API fluida y encadenable | ✅ Completo |
| **Localization** | Soporte multiidioma | ✅ Completo |
| **Custom Errors** | Vistas de error personalizables | ✅ Completo |
| **Navigation** | Soporte para NavigationStack | ✅ Completo |
| **MVVM** | Patrón Model-View-ViewModel | ✅ Completo |
| **Type Safety** | Completamente tipado | ✅ Completo |

## 🚀 Roadmap

- [ ] **Soporte para Core Data**
- [ ] **Integración con SwiftData**
- [ ] **Soporte para Pull-to-Refresh personalizado**
- [ ] **Animaciones de transición**
- [ ] **Soporte para listas anidadas**
- [ ] **Integración con CloudKit**

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor, revisa nuestras guías de contribución:

1. **Fork** el repositorio
2. **Crea** una rama para tu feature
3. **Implementa** tus cambios
4. **Añade** tests
5. **Documenta** tus cambios
6. **Envía** un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🆘 Soporte

- **Issues**: [GitHub Issues](https://github.com/tu-usuario/DynamicList/issues)
- **Discussions**: [GitHub Discussions](https://github.com/tu-usuario/DynamicList/discussions)
- **Documentación**: Esta documentación

---

**¿Necesitas ayuda?** Comienza con la [Guía de Integración con Combine](./CombineIntegration.md) para una introducción práctica, o revisa el [DynamicList Builder](./DynamicListBuilder.md) para aprender sobre la API fluida.

¡Happy coding! 🎉 