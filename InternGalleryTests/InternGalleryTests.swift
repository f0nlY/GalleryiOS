//
//  InternGalleryTests.swift
//  InternGalleryTests
//
//  Created by Ilya on 10.05.2026.
//

import XCTest
import Combine
@testable import InternGallery


final class MockNetworkService: NetworkServiceProtocol {
    var result: Result<[UnsplashPhotoDTO], NetworkError> = .success([])

    func fetchPhotos(page: Int, perPage: Int) -> AnyPublisher<[UnsplashPhotoDTO], NetworkError> {
        result.publisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

final class MockFavouritesRepository: FavouritesRepositoryProtocol {
    let favouritesDidChange = PassthroughSubject<Void, Never>()
    var stored: [Photo] = []

    func fetchAll() -> [Photo] { stored }
    func isFavourite(id: String) -> Bool { stored.contains { $0.id == id } }
    func add(photo: Photo) {
        stored.append(photo)
        favouritesDidChange.send()
    }
    func remove(id: String) {
        stored.removeAll { $0.id == id }
        favouritesDidChange.send()
    }
}

final class MockImageCacheService: ImageCacheServiceProtocol {
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        Just(nil).eraseToAnyPublisher()
    }
}


final class GalleryViewModelTests: XCTestCase {
    private var sut: GalleryViewModel!
    private var networkService: MockNetworkService!
    private var favouritesRepository: MockFavouritesRepository!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        networkService = MockNetworkService()
        favouritesRepository = MockFavouritesRepository()
        sut = GalleryViewModel(
            networkService: networkService,
            favouritesRepository: favouritesRepository,
            imageCacheService: MockImageCacheService()
        )
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        super.tearDown()
    }

    func test_loadFirstPage_populatesPhotos() {
        let dto = makePhotoDTO(id: "abc123")
        networkService.result = .success([dto])
        let expectation = expectation(description: "photos loaded")

        sut.$photos
            .dropFirst()
            .filter { !$0.isEmpty }
            .sink { photos in
                XCTAssertEqual(photos.count, 1)
                XCTAssertEqual(photos.first?.id, "abc123")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.loadFirstPage()
        wait(for: [expectation], timeout: 3)
    }

    func test_toggleFavourite_addsToRepository() {
        let dto = makePhotoDTO(id: "fav1")
        networkService.result = .success([dto])
        let expectation = expectation(description: "favourite toggled")

        sut.$photos
            .dropFirst()
            .filter { !$0.isEmpty }
            .first()
            .sink { [weak self] photos in
                guard let photo = photos.first else { return }
                self?.sut.toggleFavourite(for: photo)
                XCTAssertTrue(self?.favouritesRepository.isFavourite(id: "fav1") ?? false)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.loadFirstPage()
        wait(for: [expectation], timeout: 3)
    }

    func test_loadFirstPage_setsErrorMessageOnFailure() {
        networkService.result = .failure(.invalidResponse)
        let expectation = expectation(description: "error set")

        sut.$errorMessage
            .compactMap { $0 }
            .sink { message in
                XCTAssertFalse(message.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.loadFirstPage()
        wait(for: [expectation], timeout: 3)
    }


    private func makePhotoDTO(id: String) -> UnsplashPhotoDTO {
        let json = """
        {
            "id": "\(id)",
            "description": "Test description",
            "alt_description": "Test alt",
            "urls": { "thumb": "https://example.com/thumb.jpg", "regular": "https://example.com/regular.jpg" },
            "user": { "name": "Test Author" }
        }
        """.data(using: .utf8)!
        return try! JSONDecoder().decode(UnsplashPhotoDTO.self, from: json)
    }
}

