//
//  CoreDataManager.swift
//  InternGallery
//
//  Created by Ilya on 10.05.2026.
//

import Foundation
import CoreData

protocol CoreDataServiceProtocol {
    func saveFavorite(photo: Photo)
    func removeFavorite(id: String)
    func fetchFavorites() -> [FavoritePhoto]
    func isFavorite(id: String) -> Bool
}

final class CoreDataManager: CoreDataServiceProtocol {
    
    static let shared = CoreDataManager()
    
    private init() {}

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GalleryDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Не удалось загрузить CoreData: \(error)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    func saveFavorite(photo: Photo) {
        guard !isFavorite(id: photo.id) else { return }
        
        let favorite = FavoritePhoto(context: context)
        favorite.id = photo.id
        favorite.thumbUrl = photo.urls.thumb
        favorite.fullUrl = photo.urls.regular
        favorite.userName = photo.user.name
        
        saveContext()
        print("Фото \(photo.id) сохранено в избранное")
    }
    
    func removeFavorite(id: String) {
        let request: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(request)
            if let photoToDelete = results.first {
                context.delete(photoToDelete)
                saveContext()
                print("Фото \(id) удалено из избранного")
            }
        } catch {
            print("Ошибка при удалении фото: \(error)")
        }
    }
    
    func fetchFavorites() -> [FavoritePhoto] {
        let request: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Ошибка при получении избранного: \(error)")
            return[]
        }
    }
    
    func isFavorite(id: String) -> Bool {
        let request: NSFetchRequest<FavoritePhoto> = FavoritePhoto.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Ошибка сохранения CoreData: \(error)")
            }
        }
    }
}
