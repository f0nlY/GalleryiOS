# InterGallery

**Автор:** Илья Хмылько — [github.com/f0nlY](https://github.com/f0nlY)

---

## О приложении

GalleryiOS — галерея изображений, которая загружает фотографии с Unsplash API. Пользователь может просматривать фото в сетке, открывать детальный экран со свайп-навигацией и сохранять понравившиеся фото в избранное, которое хранится между сессиями.

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

Каждый экран имеет отдельный ViewController (View) и ViewModel. ViewModel предоставляет `@Published` свойства, на которые ViewController подписывается через Combine. ViewController ничего не знает о сети и хранилище — вся бизнес-логика в ViewModel и сервисах.

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
- Инкапсуляция — свойства ViewModel объявлены `private(set)`, доступ только через `@Published`
- Наследование — ViewController-ы наследуют `UIViewController`, Cell-ы — `UICollectionViewCell`
- Полиморфизм — протоколы сервисов позволяют подменять их моками в тестах
- Абстракция — ViewController взаимодействует только с ViewModel, не зная о сети и БД

**SOLID**
- **S** — каждый класс отвечает за одно: `NetworkService` — сеть, `FavouritesRepository` — CoreData, `ImageCacheService` — кэш
- **O** — новые экраны добавляются без изменения существующих классов
- **L** — моки в тестах полностью заменяют реальные сервисы без поломки логики
- **I** — три отдельных сфокусированных протокола вместо одного большого
- **D** — ViewModel-и зависят от протоколов, а не от конкретных реализаций

**Паттерны проектирования**
- Singleton — `CoreDataStack.shared`, `ImageCacheService.shared`
- Observer — Combine `@Published` + `PassthroughSubject` для реактивных обновлений
- Repository — `FavouritesRepository` скрывает CoreData за чистым интерфейсом
- Factory — `SceneDelegate` выступает корнем композиции и фабрикой зависимостей

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
