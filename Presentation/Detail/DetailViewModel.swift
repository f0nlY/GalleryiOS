//
//  DetailViewModel.swift
//  InternGallery
//
//  Created by Ilya on 12.05.2026.
//

import UIKit
import Combine

final class DetailViewModel {

    @Published private(set) var photos: [Photo]
    @Published private(set) var currentIndex: Int

    var currentPhoto: Photo { photos[currentIndex] }

    let favouritesRepository: FavouritesRepositoryProtocol
    let imageCacheService: ImageCacheServiceProtocol

    private var cancellables = Set<AnyCancellable>()

    init(
        photos: [Photo],
        selectedIndex: Int,
        favouritesRepository: FavouritesRepositoryProtocol,
        imageCacheService: ImageCacheServiceProtocol
    ) {
        self.photos = photos
        self.currentIndex = selectedIndex
        self.favouritesRepository = favouritesRepository
        self.imageCacheService = imageCacheService

        observeFavouritesChanges()
    }


    func goNext() {
        guard currentIndex + 1 < photos.count else { return }
        currentIndex += 1
    }

    func goPrevious() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }

    func toggleFavourite() {
        let photo = currentPhoto
        if photo.isFavourite {
            favouritesRepository.remove(id: photo.id)
        } else {
            favouritesRepository.add(photo: photo)
        }
    }

    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        imageCacheService.loadImage(from: url)
    }


    private func observeFavouritesChanges() {
        favouritesRepository.favouritesDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.refreshFavouriteState() }
            .store(in: &cancellables)
    }

    private func refreshFavouriteState() {
        let favouriteIDs = Set(favouritesRepository.fetchAll().map(\.id))
        photos = photos.map { photo in
            var updated = photo
            updated.isFavourite = favouriteIDs.contains(photo.id)
            return updated
        }
    }
}

