//
//  NetworkService.swift
//  InternGallery
//
//  Created by Ilya on 12.05.2026.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func fetchPhotos(page: Int, perPage: Int) -> AnyPublisher<[UnsplashPhotoDTO], NetworkError>
}

final class NetworkService: NetworkServiceProtocol {

    private let accessKey = "T5rme5jJC3gwmQ02rI02yAhiZg68-6g1PoBFLb6JPcI"

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPhotos(page: Int, perPage: Int) -> AnyPublisher<[UnsplashPhotoDTO], NetworkError> {
        guard let url = Endpoint.listPhotos(page: page, perPage: perPage).url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode)
                }
                return data
            }
            .decode(type: [UnsplashPhotoDTO].self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if error is DecodingError {
                    return .decodingFailed(error)
                } else {
                    return .unknown(error)
                }
            }
            .eraseToAnyPublisher()
    }
}


