# GalleryiOS

**Author:** Ilya Khmylko — [github.com/f0nlY](https://github.com/f0nlY)

---

## Overview

InterGallery is an image gallery app that fetches photos from the Unsplash API, allows users to browse them in a grid, view details with swipe navigation, and save favourites that persist between sessions.

---

## Features

- Grid gallery with infinite pagination (30 images/page)
- Image detail screen with swipe left/right navigation between photos
- Add/remove favourites via heart button
- Favourite indicator (❤️) on gallery thumbnails
- Favourites persisted locally with CoreData
- In-memory image caching with `NSCache` for smooth scrolling
- Empty state on Favourites screen
- Long-press context menu to remove from favourites
- Error handling with alert presentation

---

## Architecture

**MVVM + Combine**

Each screen has a dedicated ViewController (View) and ViewModel. The ViewModel exposes `@Published` properties that the ViewController subscribes to via Combine. ViewControllers have no knowledge of networking or persistence — all business logic lives in ViewModels and injected services.

```
InterGallery/
├── App/                  # AppDelegate, SceneDelegate (DI composition root)
├── Core/
│   ├── Network/          # NetworkService, Endpoint, NetworkError
│   ├── Persistence/      # CoreDataStack, FavouritesRepository
│   └── ImageCache/       # ImageCacheService (NSCache wrapper)
├── Models/               # Photo (domain model), GalleryDataModel (CoreData)
├── Presentation/
│   ├── Gallery/          # GalleryViewController + ViewModel + Cell
│   ├── Detail/           # DetailViewController + ViewModel
│   └── Favourites/       # FavouritesViewController + ViewModel + Cell
└── InternGalleryTests/
    └── GalleryViewModelTests.swift
```

Dependencies are injected through `init` at the composition root (`SceneDelegate`), following the Dependency Inversion Principle.

---

## Tech Stack

| Layer | Solution |
|---|---|
| Language | Swift 5.9 |
| UI | UIKit (programmatic, no Storyboard) |
| Reactive | Combine |
| Networking | URLSession |
| Persistence | CoreData |
| Image caching | NSCache (custom wrapper) |
| Linting | SwiftLint |
| Tests | XCTest |

---

## Design Patterns & Principles

**OOP**
- Encapsulation — ViewModel properties are `private(set)`, exposed only via `@Published`
- Inheritance — ViewControllers inherit `UIViewController`, Cells inherit `UICollectionViewCell`
- Polymorphism — protocol-based services allow mock substitution in tests
- Abstraction — ViewControllers interact only with ViewModels, unaware of network/storage details

**SOLID**
- **S** — each class has one responsibility: `NetworkService` handles networking, `FavouritesRepository` handles CoreData, `ImageCacheService` handles caching
- **O** — new screens can be added without modifying existing classes
- **L** — mock services in tests fully substitute real implementations without breaking logic
- **I** — three separate focused protocols instead of one large interface
- **D** — ViewModels depend on protocols, not concrete implementations

**Design Patterns**
- Singleton — `CoreDataStack.shared`, `ImageCacheService.shared`
- Observer — Combine `@Published` + `PassthroughSubject` for reactive updates
- Repository — `FavouritesRepository` abstracts CoreData behind a clean interface
- Factory — `SceneDelegate` acts as a composition root / factory for the dependency graph

---

---

## Screenshots

_Coming soon_

---

## Requirements

- iOS 17+
- Xcode 15+
- Swift 5.9+

---

## Git Workflow

- `main` — stable, final submission branch
- `develop` — integration branch
- `feature/*` — individual features, merged into `develop` via Pull Requests

Commit convention: `[ADDED]`, `[FIXED]`, `[REFACTORED]`, `[UPDATED]`, `[REMOVED]`


# GalleryiOS

**Автор:** Илья Хмылько - [github.com/f0nlY](https://github.com/f0nlY)

---

## О приложении

GalleryiOS - галерея изображений, которая загружает фотографии с Unsplash API. Пользователь может просматривать фото в сетке, открывать детальный экран со свайп-навигацией и сохранять понравившиеся фото в избранное, которое хранится между сессиями.

---

## Функциональность

- Сетка фотографий с бесконечной пагинацией (30 фото на страницу)
- Детальный экран с навигацией свайпом влево/вправо
- Добавление/удаление из избранного через кнопку ❤️
- Индикатор избранного на превью в галерее
- Избранное сохраняется локально через CoreData
- Кэширование изображений в памяти через `NSCache` для плавного скролла
- Экран избранного с пустым состоянием
- Удаление из избранного через контекстное меню (долгое нажатие)
- Обработка ошибок сети с показом алерта

---

## Архитектура

**MVVM + Combine**

Каждый экран имеет отдельный ViewController (View) и ViewModel. ViewModel предоставляет `@Published` свойства, на которые ViewController подписывается через Combine. ViewController ничего не знает о сети и хранилище - вся бизнес-логика в ViewModel и сервисах.

```
InterGallery/
├── App/                  # AppDelegate, SceneDelegate (корень DI)
├── Core/
│   ├── Network/          # NetworkService, Endpoint, NetworkError
│   ├── Persistence/      # CoreDataStack, FavouritesRepository
│   └── ImageCache/       # ImageCacheService (обёртка над NSCache)
├── Models/               # Photo (доменная модель), GalleryDataModel (CoreData)
├── Presentation/
│   ├── Gallery/          # GalleryViewController + ViewModel + Cell
│   ├── Detail/           # DetailViewController + ViewModel
│   └── Favourites/       # FavouritesViewController + ViewModel + Cell
└── InternGalleryTests/
    └── GalleryViewModelTests.swift
```

Все зависимости инжектируются через `init` в корне композиции (`SceneDelegate`), согласно принципу инверсии зависимостей.

---

## Стек технологий

| Слой | Решение |
|---|---|
| Язык | Swift 5.9 |
| UI | UIKit (программный, без Storyboard) |
| Реактивность | Combine |
| Сеть | URLSession |
| Хранилище | CoreData |
| Кэш изображений | NSCache (собственная обёртка) |
| Линтер | SwiftLint |
| Тесты | XCTest |

---

## Паттерны и принципы

**ООП**
- Инкапсуляция - свойства ViewModel объявлены `private(set)`, доступ только через `@Published`
- Наследование - ViewController-ы наследуют `UIViewController`, Cell-ы — `UICollectionViewCell`
- Полиморфизм - протоколы сервисов позволяют подменять их моками в тестах
- Абстракция - ViewController взаимодействует только с ViewModel, не зная о сети и БД

**SOLID**
- **S** - каждый класс отвечает за одно: `NetworkService` — сеть, `FavouritesRepository` — CoreData, `ImageCacheService` — кэш
- **O** - новые экраны добавляются без изменения существующих классов
- **L** - моки в тестах полностью заменяют реальные сервисы без поломки логики
- **I** - три отдельных сфокусированных протокола вместо одного большого
- **D** - ViewModel-и зависят от протоколов, а не от конкретных реализаций

**Паттерны проектирования**
- Singleton - `CoreDataStack.shared`, `ImageCacheService.shared`
- Observer - Combine `@Published` + `PassthroughSubject` для реактивных обновлений
- Repository - `FavouritesRepository` скрывает CoreData за чистым интерфейсом
- Factory - `SceneDelegate` выступает корнем композиции и фабрикой зависимостей

---

## Скриншоты

_Скоро будут добавлены_

---

## Требования

- iOS 17+
- Xcode 15+
- Swift 5.9+

---

## Git-процесс

- `main` — стабильная ветка, финальная версия для сдачи
- `develop` — интеграционная ветка
- `feature/*` — отдельные фичи, вливаются в `develop` через Pull Request

Формат коммитов: `[ADDED]`, `[FIXED]`, `[REFACTORED]`, `[UPDATED]`, `[REMOVED]`

