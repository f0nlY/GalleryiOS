//
//  FavouritesViewModel.swift
//  InternGallery
//
//  Created by Ilya on 12.05.2026.
//

import UIKit
import Combine

final class FavouritesViewModel {

    @Published private(set) var photos: [Photo] = []

    let favouritesRepository: FavouritesRepositoryProtocol
    let imageCacheService: ImageCacheServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        favouritesRepository: FavouritesRepositoryProtocol,
        imageCacheService: ImageCacheServiceProtocol
    ) {
        self.favouritesRepository = favouritesRepository
        self.imageCacheService = imageCacheService

        observeFavouritesChanges()
    }


    func loadFavourites() {
        photos = favouritesRepository.fetchAll()
    }

    func removeFromFavourites(id: String) {
        favouritesRepository.remove(id: id)
    }

    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        imageCacheService.loadImage(from: url)
    }


    private func observeFavouritesChanges() {
        favouritesRepository.favouritesDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.loadFavourites() }
            .store(in: &cancellables)
    }
}

