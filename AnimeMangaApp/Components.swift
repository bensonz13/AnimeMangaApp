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
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                toggle()
            }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.red)
                .shadow(color: .black.opacity(0.5), radius: 2)
                .frame(width: 30, height: 30, alignment: .topLeading)
        }
        .buttonStyle(.plain)
        .symbolEffect(.bounce, value: isFavorite)
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
                        PosterCard(anime: anime) { await onSelect(anime) }
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
                        PosterCard(manga: manga) { await onSelect(manga) }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

enum AnimeGenre: String, CaseIterable {
    case action = "Action"
    case adventure = "Adventure"
    case comedy = "Comedy"
    case drama = "Drama"
    case fantasy = "Fantasy"
    case horror = "Horror"
    case mystery = "Mystery"
    case romance = "Romance"
    case sciFi = "Sci-Fi"
    case sliceOfLife = "Slice of Life"
    case sports = "Sports"
    case supernatural = "Supernatural"
    case thriller = "Thriller"
    case mecha = "Mecha"

    var id: Int {
        switch self {
        case .action: return 1
        case .adventure: return 2
        case .comedy: return 4
        case .drama: return 8
        case .fantasy: return 10
        case .horror: return 14
        case .mystery: return 7
        case .romance: return 22
        case .sciFi: return 24
        case .sliceOfLife: return 36
        case .sports: return 30
        case .supernatural: return 37
        case .thriller: return 41
        case .mecha: return 18
        }
    }
}

struct GenreChip: View {
    let genre: AnimeGenre
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(genre.rawValue)
                    .font(.subheadline).fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.clear : Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

struct GenreResultsView: View {
    let genre: AnimeGenre
    let onSelect: (Anime) async -> Void

    @State private var items: [Anime] = []
    @State private var isLoading = true
    @State private var showAll = false

    @Query private var settings: [UserSettings]

    var currentSettings: UserSettings { settings.first ?? UserSettings() }

    var body: some View {
        Group {
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 220)
            } else if items.isEmpty {
                Text("No results found")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                VStack(alignment: .trailing, spacing: 8) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(items) { anime in
                                PosterCard(anime: anime) {
                                    await onSelect(anime)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Button("View All") {
                        showAll = true
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                }
            }
        }
        .task(id: genre) {
            isLoading = true
            items = await fetchByGenre(genreID: genre.id, sortBy: .score)
            isLoading = false
        }
        .sheet(isPresented: $showAll) {
            GenreAllView(genre: genre, onSelect: onSelect)
        }
    }

    private func fetchByGenre(genreID: Int, sortBy: GenreSortOption) async -> [Anime] {
        let urlStr = "https://api.jikan.moe/v4/anime?genres=\(genreID)&order_by=\(sortBy.apiValue)&sort=desc&limit=15"
        guard let url = URL(string: urlStr) else { return [] }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AnimeResponse.self, from: data)
            return NetworkClient().filterAnime(response.data, using: currentSettings)
        } catch {
            print("fetchByGenre error:", error)
            return []
        }
    }
}

struct RandomDiscoveryBanner: View {
    let onDiscover: (MediaType) async -> Void
    @State private var isLoading = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Feeling Lucky?")
                    .font(.headline)
                Text("Discover something random")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Anime") {
                Task {
                    isLoading = true
                    await onDiscover(.anime)
                    isLoading = false
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            
            Button("Manga") {
                Task {
                    isLoading = true
                    await onDiscover(.manga)
                    isLoading = false
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
        .overlay(isLoading ? AnyView(ProgressView().padding(.trailing)) : AnyView(EmptyView()),
                 alignment: .trailing)
    }
}

enum GenreSortOption: String, CaseIterable, Identifiable {
    case popular = "Popular"
    case score = "Top Rated"
    case date = "Newest"

    var id: String { rawValue }

    var apiValue: String {
        switch self {
        case .popular: return "members"
        case .score:   return "score"
        case .date:    return "start_date"
        }
    }

    var icon: String {
        switch self {
        case .popular: return "flame"
        case .score:   return "star"
        case .date:    return "calendar"
        }
    }
}
