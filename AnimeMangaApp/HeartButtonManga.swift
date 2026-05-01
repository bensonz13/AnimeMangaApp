//
//  HeartButtonManga.swift
//  AnimeMangaApp
//
//  Created by Student on 4/30/26.
//
import SwiftUI
import SwiftData

struct HeartButtonManga: View {
    let manga: Manga
    
    @Environment(\.modelContext) private var context
    @Query private var favorites: [FavoriteManga]
    
    var isFavorite: Bool {
        favorites.contains { $0.id == manga.mal_id }
    }
    
    var body: some View {
        Image(systemName: isFavorite ? "heart.fill" : "heart")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.red)
            .shadow(color: .black.opacity(0.5), radius: 2)
            .frame(width: 30, height: 30, alignment: .topLeading)
            .contentShape(Rectangle())
            .onTapGesture {
                toggleFavorite()
            }
    }
    
    private func toggleFavorite() {
        if let existing = favorites.first(where: { $0.id == manga.mal_id }) {
            context.delete(existing)
        } else {
            context.insert(FavoriteManga(
                id: manga.mal_id,
                title: manga.title,
                imageURL: manga.images?.jpg.image_url,
                score: manga.score
            ))
        }
    }
}
