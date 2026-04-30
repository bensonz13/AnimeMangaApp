//
//  MediaDetailSheet.swift
//  AnimeMangaApp
//
//  Created by Student on 4/30/26.
//
import SwiftUI
import SwiftData

struct MediaDetailSheet: View {
    let title: String
    let imageURL: String?
    let score: Double?
    let synopsis: String?
    let link: String?
    let title_japanese: String?
    let status: String?
    
    let anime: Anime?
    let manga: Manga?

    @Environment(\.modelContext) private var context
    
    @Query private var animeFavorites: [FavoriteAnime]
    @Query private var mangaFavorites: [FavoriteManga]

    var isAnimeFavorite: Bool {
        guard let anime else { return false }
        return animeFavorites.contains { $0.id == anime.mal_id }
    }

    var isMangaFavorite: Bool {
        guard let manga else { return false }
        return mangaFavorites.contains { $0.id == manga.mal_id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                if let urlString = imageURL,
                   let url = URL(string: urlString) {
                    
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipped()
                }

                VStack(alignment: .leading, spacing: 12) {
                    
                    HStack {
                        Text(title)
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                        
                        Button {
                            toggleFavorite()
                        } label: {
                            Image(systemName: (isAnimeFavorite || isMangaFavorite) ? "heart.fill" : "heart")
                                .foregroundStyle(.red)
                                .font(.title2)
                        }
                    }

                    if let title_japanese {
                        Text(title_japanese)
                            .font(.title3)
                    }

                    if let status {
                        Text(status)
                            .font(.system(size: 18))
                            .bold()
                            .foregroundStyle(.red)
                    }

                    if let score {
                        Label(String(format: "%.1f", score), systemImage: "star.fill")
                            .foregroundStyle(.orange)
                    }

                    if let synopsis {
                        Text(synopsis)
                            .foregroundStyle(.secondary)
                    }

                    if let link, let url = URL(string: link) {
                        Link("Visit MAL site", destination: url)
                    }
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private func toggleFavorite() {
        if let anime {
            if let existing = animeFavorites.first(where: { $0.id == anime.mal_id }) {
                context.delete(existing)
            } else {
                context.insert(FavoriteAnime(
                    id: anime.mal_id,
                    title: anime.title,
                    imageURL: anime.images?.jpg.image_url,
                    score: anime.score
                ))
            }
        }

        if let manga {
            if let existing = mangaFavorites.first(where: { $0.id == manga.mal_id }) {
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
}
