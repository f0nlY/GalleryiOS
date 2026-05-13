//
//  ImageCacheService.swift
//  InternGallery
//
//  Created by Ilya on 12.05.2026.
//

import UIKit
import Combine

protocol ImageCacheServiceProtocol {
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never>
}

final class ImageCacheService: ImageCacheServiceProtocol {
    static let shared = ImageCacheService()

    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession

    private init(session: URLSession = .shared) {
        cache.countLimit = 200
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
        self.session = session
    }

    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        if let cached = cache.object(forKey: url as NSURL) {
            return Just(cached).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .map { [weak self] data, _ -> UIImage? in
                guard let image = UIImage(data: data) else { return nil }
                self?.cache.setObject(image, forKey: url as NSURL, cost: data.count)
                return image
            }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

