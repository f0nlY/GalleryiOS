//
//  FavouritesRepository.swift
//  InternGallery
//
//  Created by Ilya on 12.05.2026.
//


import CoreData
import Combine

protocol FavouritesRepositoryProtocol {
    func fetchAll() -> [Photo]
    func isFavourite(id: String) -> Bool
    func add(photo: Photo)
    func remove(id: String)
    var favouritesDidChange: PassthroughSubject<Void, Never> { get }
}

final class FavouritesRepository: FavouritesRepositoryProtocol {
    let favouritesDidChange = PassthroughSubject<Void, Never>()

    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    func fetchAll() -> [Photo] {
        let request: NSFetchRequest<FavouritePhoto> = FavouritePhoto.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "savedAt", ascending: false)]
        let results = (try? coreDataStack.viewContext.fetch(request)) ?? []
        return results.compactMap { $0.toDomain() }
    }

    func isFavourite(id: String) -> Bool {
        let request: NSFetchRequest<FavouritePhoto> = FavouritePhoto.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return (try? coreDataStack.viewContext.count(for: request)) ?? 0 > 0
    }

    func add(photo: Photo) {
        let context = coreDataStack.viewContext
        let entity = FavouritePhoto(context: context)
        entity.id = photo.id
        entity.title = photo.title
        entity.photoDescription = photo.description
        entity.thumbURLString = photo.thumbURL.absoluteString
        entity.regularURLString = photo.regularURL.absoluteString
        entity.authorName = photo.authorName
        entity.savedAt = Date()
        coreDataStack.saveContext()
        favouritesDidChange.send()
    }

    func remove(id: String) {
        let request: NSFetchRequest<FavouritePhoto> = FavouritePhoto.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        let context = coreDataStack.viewContext
        if let entity = try? context.fetch(request).first {
            context.delete(entity)
            coreDataStack.saveContext()
            favouritesDidChange.send()
        }
    }
}


extension FavouritePhoto {
    func toDomain() -> Photo? {
        guard
            let id,
            let thumbString = thumbURLString,
            let regularString = regularURLString,
            let thumbURL = URL(string: thumbString),
            let regularURL = URL(string: regularString)
        else { return nil }

        return Photo(
            id: id,
            title: title ?? "Untitled",
            description: photoDescription,
            thumbURL: thumbURL,
            regularURL: regularURL,
            authorName: authorName ?? "",
            isFavourite: true
        )
    }
}

