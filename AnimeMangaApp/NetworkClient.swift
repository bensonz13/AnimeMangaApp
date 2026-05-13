//
//  NetworkClient.swift
//  AnimeMangaApp
//
//  Created by Student on 4/24/26.
//

import SwiftUI

@Observable
class NetworkClient {
    private let baseURL = "https://api.jikan.moe/v4"

    private(set) var topAnime: [Anime] = []
    private(set) var topManga: [Manga] = []
    private(set) var selectedSeason: [Anime] = []

    private(set) var selectedAnime: Anime? = nil
    private(set) var selectedManga: Manga? = nil

    private var animePage = 1
    private var mangaPage = 1
    private var seasonPage = 1
    
    let excludeIDs = "12,49,9"

    private func fetch<T: Decodable>(_ urlStr: String, as type: T.Type) async throws -> T {
        guard let url = URL(string: urlStr) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func filterAnime(_ items: [Anime], using settings: UserSettings) -> [Anime] {
        items.filter { settings.isRatingAllowed($0.rating) }
    }

    func filterManga(_ items: [Manga], using settings: UserSettings) -> [Manga] {
        items
    }

    func getTopAnime(settings: UserSettings) async {
        do {
            let response = try await fetch("\(baseURL)/top/anime?page=\(animePage)", as: AnimeResponse.self)
            let filtered = filterAnime(response.data, using: settings)
            for item in filtered where !topAnime.contains(where: { $0.mal_id == item.mal_id }) {
                topAnime.append(item)
            }
            animePage += 1
        } catch { print("getTopAnime:", error) }
    }

    func getTopManga(settings: UserSettings) async {
        do {
            let response = try await fetch("\(baseURL)/top/manga?page=\(mangaPage)&genres_exclude=\(excludeIDs)", as: MangaResponse.self)
            for item in response.data where !topManga.contains(where: { $0.mal_id == item.mal_id }) {
                topManga.append(item)
            }
            mangaPage += 1
        } catch { print("getTopManga:", error) }
    }

    func searchAnime(query: String, settings: UserSettings) async -> [Anime] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        do {
            let response = try await fetch("\(baseURL)/anime?q=\(encoded)", as: AnimeResponse.self)
            return filterAnime(response.data, using: settings)
        } catch { print("searchAnime:", error); return [] }
    }

    func searchManga(query: String, settings: UserSettings) async -> [Manga] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        do {
            let response = try await fetch("\(baseURL)/manga?q=\(encoded)&genres_exclude=\(excludeIDs)", as: MangaResponse.self)
            return response.data
        } catch { print("searchManga:", error); return [] }
    }

    func getAnimeByID(id: Int) async {
        do {
            let response = try await fetch("\(baseURL)/anime/\(id)", as: AnimeDetailResponse.self)
            selectedAnime = response.data
        } catch { print("getAnimeByID:", error) }
    }

    func getMangaByID(id: Int) async {
        do {
            let response = try await fetch("\(baseURL)/manga/\(id)", as: MangaDetailResponse.self)
            selectedManga = response.data
        } catch { print("getMangaByID:", error) }
    }

    func getRandomAnime(settings: UserSettings) async {
        var isRestricted = true
        var attempts = 0
        let maxAttempts = 10
        
        while isRestricted && attempts < maxAttempts {
            attempts += 1
            do {
                let response = try await fetch("\(baseURL)/random/anime", as: AnimeDetailResponse.self)
                let anime = response.data
                
                if settings.isRatingAllowed(anime.rating) {
                    selectedAnime = anime
                    isRestricted = false
                } else {
                    print("restricted found: \(anime.title) has rating \(anime.rating ?? "nil"), retrying")
                    try? await Task.sleep(for: .seconds(0.5))
                }
            } catch {
                print("getRandomAnime:", error)
                break
            }
        }
        if isRestricted {
            print("getRandomAnime: could not find allowed content after \(maxAttempts) attempts")
        }
    }

    func getRandomManga(settings: UserSettings) async {
        var isRestricted = true
        let excludedArray = excludeIDs.split(separator: ",").compactMap { Int($0) }
        var attempts = 0
        let maxAttempts = 10
        
        while isRestricted && attempts < maxAttempts {
            attempts += 1
            do {
                let response = try await fetch("\(baseURL)/random/manga", as: MangaDetailResponse.self)
                let manga = response.data
                
                let containsExcluded = manga.genres?.contains { genre in
                    excludedArray.contains(genre.mal_id)
                } ?? false
                
                if !containsExcluded {
                    selectedManga = manga
                    isRestricted = false
                } else {
                    print("found excluded genre: \(manga.genres?.map{ $0.name } ?? []) with title: \(manga.title)")
                    try? await Task.sleep(for: .seconds(0.5))
                }
            } catch {
                print("getRandomManga:", error)
                break
            }
        }
        if isRestricted {
            print("getRandomManga: could not find allowed content after \(maxAttempts) attempts")
        }
    }

    func getAnimeSeason(year: Int, season: String, settings: UserSettings) async {
        do {
            let response = try await fetch("\(baseURL)/seasons/\(year)/\(season)?page=\(seasonPage)", as: AnimeResponse.self)
            let filtered = filterAnime(response.data, using: settings)
            for item in filtered where !selectedSeason.contains(where: { $0.mal_id == item.mal_id }) {
                selectedSeason.append(item)
            }
            seasonPage += 1
        } catch { print("getAnimeSeason:", error) }
    }

    func resetSeason() {
        selectedSeason = []
        seasonPage = 1
    }
}
