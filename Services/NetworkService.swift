//
//  NetworkService.swift
//  InternGallery
//
//  Created by Ilya on 10.05.2026.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchPhotos(page: Int, perPage: Int) async throws -> [Photo]
}

final class NetworkService: NetworkServiceProtocol {
    
    private let accessKey = "T5rme5jJC3gwmQ02rI02yAhiZg68-6g1PoBFLb6JPcI"
    private let baseURL = "https://api.unsplash.com"
    
    func fetchPhotos(page: Int, perPage: Int = 30) async throws -> [Photo] {
        var components = URLComponents(string: "\(baseURL)/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "client_id", value: accessKey)
        ]
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let photos = try decoder.decode([Photo].self, from: data)
        
        return photos
    }
}
