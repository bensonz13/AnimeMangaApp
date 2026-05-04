//
//  Components.swift
//  AnimeMangaApp
//
//  Created by Student on 5/4/26.
//

import SwiftUI
import SwiftData

struct MediaThumbnail: View {
    let urlString: String?
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Group {
            if let urlString, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
            } else {
                Color.gray.opacity(0.3)
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .cornerRadius(6)
    }
}

struct MediaRow: View {
    let title: String
    let imageURL: String?

    init(anime: Anime) {
        title = anime.title
        imageURL = anime.images?.jpg.image_url
    }

    init(manga: Manga) {
        title = manga.title
        imageURL = manga.images?.jpg.image_url
    }

    var body: some View {
        HStack(spacing: 12) {
            MediaThumbnail(urlString: imageURL, width: 60, height: 80)
            Text(title)
                .font(.body)
                .lineLimit(2)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct PosterCard: View {
    let title: String
    let imageURL: String?
    let onTap: () async -> Void

    init(anime: Anime, onTap: @escaping () async -> Void) {
        title = anime.title
        imageURL = anime.images?.jpg.image_url
        self.onTap = onTap
    }

    init(manga: Manga, onTap: @escaping () async -> Void) {
        title = manga.title
        imageURL = manga.images?.jpg.image_url
        self.onTap = onTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                if let urlString = imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                } else {
                    Color.gray.opacity(0.3)
                }
            }
            .frame(width: 140, height: 200)
            .clipped()
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.15), radius: 6, y: 3)

            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(width: 140, alignment: .leading)
        }
        .onTapGesture {
            Task { await onTap() }
        }
    }
}


struct HeartButton: View {
    @Environment(\.modelContext) private var context

    let anime: Anime?
    let manga: Manga?

    @Query private var animeFavorites: [FavoriteAnime]
    @Query private var mangaFavorites: [FavoriteManga]

    init(anime: Anime) {
        self.anime = anime
        self.manga = nil
    }

    init(manga: Manga) {
        self.anime = nil
        self.manga = manga
    }

    private var isFavorite: Bool {
        if let anime { return animeFavorites.contains { $0.id == anime.mal_id } }
        if let manga  { return mangaFavorites.contains  { $0.id == manga.mal_id } }
        return false
    }

    var body: some View {
        Image(systemName: isFavorite ? "heart.fill" : "heart")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.red)
            .shadow(color: .black.opacity(0.5), radius: 2)
            .frame(width: 30, height: 30, alignment: .topLeading)
            .contentShape(Rectangle())
            .onTapGesture { toggle() }
    }

    private func toggle() {
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

struct AnimeSectionView: View {
    let title: String
    let items: [Anime]
    let onSelect: (Anime) async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2).bold()
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items) { anime in
                        ZStack(alignment: .topTrailing) {
                            PosterCard(anime: anime) { await onSelect(anime) }
                            HeartButton(anime: anime).padding(6)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct MangaSectionView: View {
    let title: String
    let items: [Manga]
    let onSelect: (Manga) async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2).bold()
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items) { manga in
                        ZStack(alignment: .topTrailing) {
                            PosterCard(manga: manga) { await onSelect(manga) }
                            HeartButton(manga: manga).padding(6)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
