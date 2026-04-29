//
//  SearchItem.swift
//  AnimeMangaApp
//
//  Created by Student on 4/29/26.
//


enum SearchItem: Identifiable {
    case anime(Anime)
    case manga(Manga)
    
    var id: Int {
        switch self {
        case .anime(let a): return a.mal_id
        case .manga(let m): return m.mal_id
        }
    }
}