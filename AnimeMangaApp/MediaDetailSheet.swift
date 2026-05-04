//
//  MediaDetailSheet.swift
//  AnimeMangaApp
//
//  Created by Student on 4/30/26.
//


import SwiftUI
import SwiftData

struct MediaDetailSheet: View {
    let anime: Anime?
    let manga: Manga?

    @Environment(\.modelContext) private var context
    @Query private var animeFavorites: [FavoriteAnime]
    @Query private var mangaFavorites: [FavoriteManga]


    private var title: String { anime?.title ?? manga?.title ?? "" }
    private var imageURL: String? { anime?.images?.jpg.image_url ?? manga?.images?.jpg.image_url }
    private var score: Double? { anime?.score ?? manga?.score }
    private var synopsis: String? { anime?.synopsis ?? manga?.synopsis }
    private var link: String? { anime?.url ?? manga?.url }
    private var titleJapanese: String? { anime?.title_japanese ?? manga?.title_japanese }
    private var status: String? { anime?.status ?? manga?.status }


    private var episodes: Int? { anime?.episodes }

    private var chapters: Int? { manga?.chapters }

    private var isFavorite: Bool {
        if let anime { return animeFavorites.contains { $0.id == anime.mal_id } }
        if let manga  { return mangaFavorites.contains  { $0.id == manga.mal_id } }
        return false
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                if let urlString = imageURL, let url = URL(string: urlString) {
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
                        Text(title).font(.title2).bold()
                        Spacer()
                        Button { toggleFavorite() } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundStyle(.red)
                                .font(.title2)
                        }
                    }

                    if let titleJapanese {
                        Text(titleJapanese).font(.title3).foregroundStyle(.secondary)
                    }

                    if let status {
                        Text(status)
                            .font(.system(size: 16)).bold()
                            .foregroundStyle(.red)
                    }

                    HStack(spacing: 16) {
                        if let score {
                            Label(String(format: "%.1f", score), systemImage: "star.fill")
                                .foregroundStyle(.orange)
                        }
                        if let episodes {
                            Label("\(episodes) eps", systemImage: "film")
                                .foregroundStyle(.secondary)
                        }
                        if let chapters {
                            Label("\(chapters) ch", systemImage: "book.closed")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.subheadline)

                    if let synopsis {
                        Text(synopsis).foregroundStyle(.secondary)
                    }

                    if let link, let url = URL(string: link) {
                        Link("View on MyAnimeList →", destination: url)
                            .font(.subheadline).bold()
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
                context.insert(FavoriteAnime(id: anime.mal_id, title: anime.title,
                                             imageURL: anime.images?.jpg.image_url,
                                             score: anime.score))
            }
        }
        if let manga {
            if let existing = mangaFavorites.first(where: { $0.id == manga.mal_id }) {
                context.delete(existing)
            } else {
                context.insert(FavoriteManga(id: manga.mal_id, title: manga.title,
                                             imageURL: manga.images?.jpg.image_url,
                                             score: manga.score))
            }
        }
    }
}
