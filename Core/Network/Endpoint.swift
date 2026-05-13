//
//  Endpoint.swift
//  InternGallery
//
//  Created by Ilya on 12.05.2026.
//

import Foundation

enum Endpoint {
    case listPhotos(page: Int, perPage: Int)

    private var baseURL: String {
        return "https://api.unsplash.com"
    }

    var url: URL? {
        switch self {
        case .listPhotos(let page, let perPage):
            var components = URLComponents(string: baseURL + "/photos")
            components?.queryItems = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
            return components?.url
        }
    }
}
