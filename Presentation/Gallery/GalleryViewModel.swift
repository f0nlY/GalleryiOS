//
//  GalleryViewModel.swift
//  InternGallery
//
//  Created by Ilya on 12.05.2026.
//

import Foundation
import Combine
import UIKit

final class GalleryViewModel {

    @Published private(set) var photos: [Photo] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    private let networkService: NetworkServiceProtocol
    let favouritesRepository: FavouritesRepositoryProtocol
    let imageCacheService: ImageCacheServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    private var currentPage = 1
    private let perPage = 30
    private var canLoadMore = true

    init(
        networkService: NetworkServiceProtocol,
        favouritesRepository: FavouritesRepositoryProtocol,
        imageCacheService: ImageCacheServiceProtocol
    ) {
        self.networkService = networkService
        self.favouritesRepository = favouritesRepository
        self.imageCacheService = imageCacheService

        observeFavouritesChanges()
    }


    func loadFirstPage() {
        currentPage = 1
        canLoadMore = true
        photos = []
        loadNextPage()
    }

    func loadNextPage() {
        guard !isLoading, canLoadMore else { return }
        isLoading = true

        networkService.fetchPhotos(page: currentPage, perPage: perPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] dtos in
                guard let self else { return }
                if dtos.count < self.perPage { self.canLoadMore = false }
                let favouriteIDs = Set(self.favouritesRepository.fetchAll().map(\.id))
                let newPhotos = dtos.compactMap { $0.toDomain(isFavourite: favouriteIDs.contains($0.id)) }
                self.photos.append(contentsOf: newPhotos)
                self.currentPage += 1
            }
            .store(in: &cancellables)
    }

    func toggleFavourite(for photo: Photo) {
        if photo.isFavourite {
            favouritesRepository.remove(id: photo.id)
        } else {
            favouritesRepository.add(photo: photo)
        }
        refreshFavouriteState()
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

