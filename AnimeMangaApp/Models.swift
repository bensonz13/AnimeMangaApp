//
//  Models.swift
//  AnimeMangaApp
//
//  Created by Student on 5/4/26.
//

import SwiftUI
import SwiftData
import Foundation

enum MediaType {
    case anime
    case manga
}

struct Anime: Identifiable, Codable {
    let mal_id: Int
    var id: Int { mal_id }
    let title: String
    let images: Images?
    let url: String?
    let title_japanese: String?
    let episodes: Int?
    let status: String?
    let score: Double?
    let synopsis: String?
    let rating: String?
}

struct Manga: Identifiable, Codable {
    let mal_id: Int
    var id: Int { mal_id }
    let title: String
    let images: Images?
    let url: String?
    let title_japanese: String?
    let chapters: Int?
    let status: String?
    let score: Double?
    let synopsis: String?
    let rating: String?
}

struct Images: Codable {
    let jpg: JPG
}

struct JPG: Codable {
    let image_url: String
}

struct Pagination: Codable {
    let has_next_page: Bool
}

struct AnimeResponse: Codable {
    let data: [Anime]
    let pagination: Pagination
}

struct AnimeDetailResponse: Codable {
    let data: Anime
}

struct MangaResponse: Codable {
    let data: [Manga]
    let pagination: Pagination
}

struct MangaDetailResponse: Codable {
    let data: Manga
}

@Model
class FavoriteAnime {
    @Attribute(.unique) var id: Int
    var title: String
    var imageURL: String?
    var score: Double?

    init(id: Int, title: String, imageURL: String? = nil, score: Double? = nil) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.score = score
    }
}

@Model
class FavoriteManga {
    @Attribute(.unique) var id: Int
    var title: String
    var imageURL: String?
    var score: Double?

    init(id: Int, title: String, imageURL: String? = nil, score: Double? = nil) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.score = score
    }
}

@Model
class UserSettings {
    var isSafeContentOnly: Bool
    var excludedRatings: [String]
    
    init(isSafeContentOnly: Bool = true, excludedRatings: [String] = []) {
        self.isSafeContentOnly = isSafeContentOnly
        self.excludedRatings = excludedRatings
    }
}
