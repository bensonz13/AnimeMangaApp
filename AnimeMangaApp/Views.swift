//
//  Views.swift
//  AnimeMangaApp
//
//  Created by Student on 5/4/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }

            MediaView(type: .anime)
                .tabItem { Label("Anime", systemImage: "play.rectangle") }

            MediaView(type: .manga)
                .tabItem { Label("Manga", systemImage: "book") }

            MeView()
                .tabItem { Label("Me", systemImage: "person") }
        }
        .toolbar(.visible, for: .tabBar)
    }
}

struct HomeView: View {
    @State private var client = NetworkClient()
    @State private var showDetail = false
    @State private var detailType: MediaType = .anime

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {

                    Text("Discover")
                        .font(.largeTitle).bold()
                        .padding(.horizontal)

                    if !client.topAnime.isEmpty {
                        TabView {
                            ForEach(client.topAnime.prefix(10)) { anime in
                                ZStack(alignment: .bottomLeading) {
                                    if let urlString = anime.images?.jpg.image_url,
                                       let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: { ProgressView() }
                                        .frame(height: 220)
                                        .clipped()
                                    }
                                    LinearGradient(colors: [.clear, .black.opacity(0.85)],
                                                   startPoint: .top, endPoint: .bottom)
                                    Text(anime.title)
                                        .font(.title2).bold()
                                        .foregroundColor(.white)
                                        .padding()
                                }
                                .cornerRadius(15)
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    Task {
                                        await client.getAnimeByID(id: anime.mal_id)
                                        detailType = .anime
                                        showDetail = true
                                    }
                                }
                            }
                        }
                        .frame(height: 240)
                        .tabViewStyle(.page)
                    }

                    AnimeSectionView(title: "🔥 Trending Anime", items: client.topAnime) { anime in
                        await client.getAnimeByID(id: anime.mal_id)
                        detailType = .anime
                        showDetail = true
                    }

                    MangaSectionView(title: "📚 Popular Manga", items: client.topManga) { manga in
                        await client.getMangaByID(id: manga.mal_id)
                        detailType = .manga
                        showDetail = true
                    }
                }
                .padding(.vertical)
            }
            .task {
                await client.getTopAnime()
                await client.getTopManga()
            }
            .sheet(isPresented: $showDetail) {
                if detailType == .manga {
                    MediaDetailSheet(anime: nil, manga: client.selectedManga)
                } else {
                    MediaDetailSheet(anime: client.selectedAnime, manga: nil)
                }
            }
        }
    }
}

struct MediaView: View {
    let type: MediaType

    @State private var client = NetworkClient()
    @State private var query = ""
    @State private var searchResultsAnime: [Anime] = []
    @State private var searchResultsManga: [Manga] = []
    @State private var searchTask: Task<Void, Never>? = nil
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    searchField
                    contentList
                    if query.isEmpty {
                        ProgressView().padding()
                            .onAppear {
                                Task {
                                    if type == .anime { await client.getTopAnime() }
                                    else              { await client.getTopManga() }
                                }
                            }
                    }
                }
            }
            .navigationTitle(type == .anime ? "Top Anime" : "Top Manga")
            .task { loadInitial() }
            .sheet(isPresented: $showDetail) {
                if type == .manga {
                    MediaDetailSheet(anime: nil, manga: client.selectedManga)
                } else {
                    MediaDetailSheet(anime: client.selectedAnime, manga: nil)
                }
            }
        }
    }
    
    private var searchField: some View {
        TextField(type == .anime ? "Search anime..." : "Search manga...", text: $query)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
            .onChange(of: query) { _, newValue in
                searchTask?.cancel()
                searchTask = Task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    guard !Task.isCancelled else { return }
                    let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                    if trimmed.isEmpty {
                        await MainActor.run {
                            searchResultsAnime = []
                            searchResultsManga = []
                        }
                        return
                    }
                    if type == .anime {
                        let result = await client.searchAnime(query: trimmed)
                        await MainActor.run { searchResultsAnime = result }
                    } else {
                        let result = await client.searchManga(query: trimmed)
                        await MainActor.run { searchResultsManga = result }
                    }
                }
            }
    }

    @ViewBuilder
    private var contentList: some View {
        if type == .anime {
            ForEach(query.isEmpty ? client.topAnime : searchResultsAnime) { anime in
                MediaRow(anime: anime)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            await client.getAnimeByID(id: anime.mal_id)
                            showDetail = true
                        }
                    }
            }
        } else {
            ForEach(query.isEmpty ? client.topManga : searchResultsManga) { manga in
                MediaRow(manga: manga)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            await client.getMangaByID(id: manga.mal_id)
                            showDetail = true
                        }
                    }
            }
        }
    }

    private func loadInitial() {
        Task {
            if type == .anime, client.topAnime.isEmpty { await client.getTopAnime() }
            else if type == .manga, client.topManga.isEmpty { await client.getTopManga() }
        }
    }
}

struct MeView: View {
    @Query private var animeFavorites: [FavoriteAnime]
    @Query private var mangaFavorites: [FavoriteManga]

    @State private var client = NetworkClient()
    @State private var showDetail = false
    @State private var detailType: MediaType = .anime

    var body: some View {
        NavigationStack {
            List {
                
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("My Anime App").font(.headline)
                            Text("Favorites & Watchlist")
                                .font(.subheadline).foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }

                favoritesSection(title: "Favorite Anime", favorites: animeFavorites, isAnime: true)
                favoritesSection(title: "Favorite Manga", favorites: mangaFavorites, isAnime: false)
            }
            .navigationTitle("Me")
            .sheet(isPresented: $showDetail) {
                if detailType == .manga {
                    MediaDetailSheet(anime: nil, manga: client.selectedManga)
                } else {
                    MediaDetailSheet(anime: client.selectedAnime, manga: nil)
                }
            }
        }
    }

    private func favoritesSection<T: PersistentModel & FavoriteItem>(
        title: String,
        favorites: [T],
        isAnime: Bool
    ) -> some View {
        Section(title) {
            if favorites.isEmpty {
                Text("No favorites yet").foregroundColor(.secondary)
            } else {
                ForEach(favorites) { fav in
                    HStack(spacing: 12) {
                        if let url = fav.imageURL, let imageURL = URL(string: url) {
                            AsyncImage(url: imageURL) { image in
                                image.resizable().scaledToFill()
                            } placeholder: { Color.gray.opacity(0.3) }
                            .frame(width: 40, height: 55)
                            .clipped()
                            .cornerRadius(6)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(fav.title).font(.subheadline)

                            if let score = fav.score {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                    Text(String(format: "%.1f", score))
                                }
                                .font(.caption)
                                .foregroundStyle(.orange)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            if isAnime {
                                await client.getAnimeByID(id: fav.malID)
                                detailType = .anime
                            } else {
                                await client.getMangaByID(id: fav.malID)
                                detailType = .manga
                            }
                            showDetail = true
                        }
                    }
                }
            }
        }
    }
}

protocol FavoriteItem {
    var malID: Int { get }
    var title: String { get }
    var imageURL: String? { get }
    var score: Double? { get }
}

extension FavoriteAnime: FavoriteItem {
    var malID: Int { id }
}

extension FavoriteManga: FavoriteItem {
    var malID: Int { id }
}

#Preview {
    ContentView()
}
