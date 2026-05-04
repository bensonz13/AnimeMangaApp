//
//  AnimeMangaAppApp.swift
//  AnimeMangaApp
//
//  Created by Student on 4/24/26.
//
 
import SwiftUI
import SwiftData
 
@main
struct AnimeMangaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [FavoriteAnime.self, FavoriteManga.self])
    }
}
 
