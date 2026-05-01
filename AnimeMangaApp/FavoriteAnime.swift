//
//  FavoriteAnime.swift
//  AnimeMangaApp
//
//  Created by Student on 4/30/26.
//


import SwiftData

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