//
//  Photo.swift
//  InternGallery
//
//  Created by Ilya on 10.05.2026.
//

import Foundation

struct Photo: Decodable {
    let id: String
    let description: String?
    let altDescription: String?
    let urls: PhotoUrls
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case id
        case description
        case altDescription = "alt_description"
        case urls
        case user
    }
}

struct PhotoUrls: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct User: Decodable {
    let name: String
    let username: String
}
