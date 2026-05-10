//
//  GalleryViewModel.swift
//  InternGallery
//
//  Created by Ilya on 10.05.2026.
//

import Foundation
import Combine

final class GalleryViewModel {
    
    @Published var photos: [Photo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let networkService: NetworkServiceProtocol
    private var currentPage = 1
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchPhotos() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                let newPhotos = try await networkService.fetchPhotos(page: currentPage, perPage: 30)
                
                await MainActor.run {
                    self.photos.append(contentsOf: newPhotos)
                    self.currentPage += 1
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
