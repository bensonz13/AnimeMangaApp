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

            SeasonView()
                .tabItem{ Label("Season", systemImage: "cloud.fill") }
            
            MeView()
                .tabItem { Label("Me", systemImage: "person") }
        }
        .toolbar(.visible, for: .tabBar)
    }
}

struct SeasonView: View {
    @State private var client = NetworkClient()
    
    private let currentYear = Calendar.current.component(.year, from: Date())
    private let seasons = ["winter", "spring", "summer", "fall"]
    private var years: [Int] { Array((1917...Calendar.current.component(.year, from: Date())).reversed()) }
    
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedSeason = "winter"
    @State private var show = false
    
    @Query private var settings: [UserSettings]

    var currentSettings: UserSettings {
        settings.first ?? UserSettings()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if show {
                    List(client.selectedSeason) { anime in
                        MediaRow(anime: anime)
                            .onAppear {
                                if anime.id == client.selectedSeason.last?.id {
                                    Task { await client.getAnimeSeason(year: selectedYear, season: selectedSeason, settings: currentSettings) }
                                }
                            }
                    }
                }
                
                HStack {
                    Picker("\(selectedYear)", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    .buttonStyle(.bordered)
                    .tint(.primary)
                    
                    Picker(selection: $selectedSeason) {
                        ForEach(seasons, id: \.self) { season in
                            Text(season.capitalized).tag(season)
                        }
                    } label: {
                        Text(selectedSeason.capitalized).fontWeight(.medium)
                    }
                    .pickerStyle(.menu)
                    .menuIndicator(.hidden)
                }
                .padding(.horizontal)
                
                Button("Show Selected Season") {
                    client.resetSeason()
                    show = true
                    Task { await client.getAnimeSeason(year: selectedYear, season: selectedSeason, settings: currentSettings) }
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Seasons")
        }
    }
}

struct HomeView: View {
    @State private var client = NetworkClient()
    @State private var showDetail = false
    @State private var detailType: MediaType = .anime
    @State private var selectedGenre: AnimeGenre? = nil

    @Query private var settings: [UserSettings]

    var currentSettings: UserSettings {
        settings.first ?? UserSettings()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

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

                    RandomDiscoveryBanner { type in
                        if type == .anime {
                            await client.getRandomAnime(settings: currentSettings)
                            detailType = .anime
                        } else {
                            await client.getRandomManga(settings: currentSettings)
                            detailType = .manga
                        }
                        showDetail = true
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Browse by Genre")
                            .font(.title2).bold()
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(AnimeGenre.allCases, id: \.self) { genre in
                                    GenreChip(genre: genre, isSelected: selectedGenre == genre) {
                                        selectedGenre = (selectedGenre == genre) ? nil : genre
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        if let genre = selectedGenre {
                            GenreResultsView(genre: genre) { anime in
                                await client.getAnimeByID(id: anime.mal_id)
                                detailType = .anime
                                showDetail = true
                            }
                        }
                    }

                    AnimeSectionView(title: "Trending Anime", items: client.topAnime) { anime in
                        await client.getAnimeByID(id: anime.mal_id)
                        detailType = .anime
                        showDetail = true
                    }

                    MangaSectionView(title: "Popular Manga", items: client.topManga) { manga in
                        await client.getMangaByID(id: manga.mal_id)
                        detailType = .manga
                        showDetail = true
                    }
                }
                .padding(.vertical)
            }
            .task {
                await client.getTopAnime(settings: currentSettings)
                await client.getTopManga(settings: currentSettings)
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

    @Query private var settings: [UserSettings]

    var currentSettings: UserSettings {
        settings.first ?? UserSettings()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    searchField
                        .disableAutocorrection(true)
                    contentList
                    if query.isEmpty {
                        ProgressView().padding()
                            .onAppear {
                                Task {
                                    if type == .anime {
                                        await client.getTopAnime(settings: currentSettings)
                                    } else {
                                        await client.getTopManga(settings: currentSettings)
                                    }
                                }
                            }
                    }
                }
            }
            .navigationTitle(type == .anime ? "Top Anime" : "Top Manga")
            .task {
                if type == .anime, client.topAnime.isEmpty {
                    await client.getTopAnime(settings: currentSettings)
                } else if type == .manga, client.topManga.isEmpty {
                    await client.getTopManga(settings: currentSettings)
                }
            }
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
                        let result = await client.searchAnime(query: trimmed, settings: currentSettings)
                        await MainActor.run { searchResultsAnime = result }
                    } else {
                        let result = await client.searchManga(query: trimmed, settings: currentSettings)
                        await MainActor.run { searchResultsManga = result }
                    }
                }
            }
    }

    @ViewBuilder
    private var contentList: some View {
        if type == .anime {
            let sourceAnime = query.isEmpty ? client.topAnime : searchResultsAnime
            let enumeratedAnime = Array(sourceAnime.enumerated())
            ForEach(enumeratedAnime, id: \.offset) { index, anime in
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
}

struct MeView: View {
    @Query private var animeFavorites: [FavoriteAnime]
    @Query private var mangaFavorites: [FavoriteManga]
    @Query private var settings: [UserSettings]

    @State private var client = NetworkClient()
    @State private var showDetail = false
    @State private var detailType: MediaType = .anime
    @State private var showSettings = false

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

                Section {
                    Button("Content Filtering") {
                        showSettings = true
                    }
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
            .sheet(isPresented: $showSettings) {
                SettingsView(settings: settings.first ?? UserSettings())
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

struct SettingsView: View {
    @Bindable var settings: UserSettings

    private let allRatings: [(code: String, description: String)] = [
        ("G", "All Ages"),
        ("PG", "Children"),
        ("PG-13", "Teens 13+"),
        ("R", "17+ (violence & profanity)"),
        ("R+", "Mild Nudity"),
        ("Rx", "Hentai")
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Safe Mode", isOn: $settings.isSafeContentOnly)
                        .onChange(of: settings.isSafeContentOnly) { _, newValue in
                            if newValue {
                                settings.excludedRatings = ["R+", "Rx"]
                            }
                        }
                } header: {
                    Text("Automatically exclude R+ and Rx")
                } footer: {
                    Text("When Safe Mode is on, only the most mature ratings are hidden.")
                }

                if !settings.isSafeContentOnly {
                    Section("Custom Exclusions") {
                        ForEach(allRatings, id: \.code) { rating in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(rating.code).fontWeight(.medium)
                                    Text(rating.description).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if settings.excludedRatings.contains(rating.code) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let index = settings.excludedRatings.firstIndex(of: rating.code) {
                                    settings.excludedRatings.remove(at: index)
                                } else {
                                    settings.excludedRatings.append(rating.code)
                                }
                            }
                        }
                    }
                }

                Section {
                    Button("Reset to Safe Mode") {
                        settings.isSafeContentOnly = true
                        settings.excludedRatings = ["R+", "Rx"]
                    }
                }
            }
            .navigationTitle("Content Filtering")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GenreAllView: View {
    let genre: AnimeGenre
    let onSelect: (Anime) async -> Void

    @State private var items: [Anime] = []
    @State private var isLoading = true
    @State private var selectedSort: GenreSortOption = .popular
    @Environment(\.dismiss) private var dismiss

    @Query private var settings: [UserSettings]
    var currentSettings: UserSettings { settings.first ?? UserSettings() }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(items) { anime in
                                SmallPosterCard(anime: anime)
                            }
                        }
                        .padding(12)
                    }
                }
            }
            .navigationTitle("\(genre.rawValue)")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .task(id: selectedSort) {
                isLoading = true
                items = await fetchAll(sortBy: selectedSort)
                isLoading = false
            }
        }
    }

    private func fetchAll(sortBy: GenreSortOption) async -> [Anime] {
        var results: [Anime] = []
        for page in 1...5 {
            let urlStr = "https://api.jikan.moe/v4/anime?genres=\(genre.id)&order_by=\(sortBy.apiValue)&sort=desc&limit=25&page=\(page)"
            guard let url = URL(string: urlStr) else { continue }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder().decode(AnimeResponse.self, from: data)
                let filtered = NetworkClient().filterAnime(response.data, using: currentSettings)
                results.append(contentsOf: filtered)
                if !response.pagination.has_next_page { break }
                try? await Task.sleep(for: .milliseconds(400))
            } catch {
                print("fetchAll page \(page):", error)
            }
        }
        return results
    }
}

struct SmallPosterCard: View {
    let anime: Anime

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                Group {
                    if let urlString = anime.images?.jpg.image_url,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(height: 140)
                .clipped()
                .cornerRadius(10)

                HeartButton(anime: anime)
                    .padding(6)
            }

            Text(anime.title)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    ContentView()
}
