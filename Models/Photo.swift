//
//  Photo.swift
//  InternGallery
//
//  Created by Ilya on 10.05.2026.
//

import Foundation

struct Photo: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String?
    let thumbURL: URL
    let regularURL: URL
    let authorName: String
    var isFavourite: Bool

    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
    }
}


struct UnsplashPhotoDTO: Decodable {
    let id: String
    let description: String?
    let altDescription: String?
    let urls: URLs
    let user: User

    struct URLs: Decodable {
        let thumb: String
        let regular: String
    }

    struct User: Decodable {
        let name: String
    }

    enum CodingKeys: String, CodingKey {
        case id, description, urls, user
        case altDescription = "alt_description"
    }

    func toDomain(isFavourite: Bool = false) -> Photo? {
        guard
            let thumbURL = URL(string: urls.thumb),
            let regularURL = URL(string: urls.regular)
        else { return nil }

        return Photo(
            id: id,
            title: altDescription ?? description ?? "Untitled",
            description: description,
            thumbURL: thumbURL,
            regularURL: regularURL,
            authorName: user.name,
            isFavourite: isFavourite
        )
    }
}
