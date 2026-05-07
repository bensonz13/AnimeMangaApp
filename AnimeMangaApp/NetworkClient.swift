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

    func getTopAnime() async {
        do {
            let response = try await fetch("\(baseURL)/top/anime?page=\(animePage)", as: AnimeResponse.self)
            
            let filteredData = response.data.filter { anime in
                guard let rating = anime.rating else { return true }
                let isRestricted = (try? /^R\+|^Rx/.firstMatch(in: rating)) != nil
                
                return !isRestricted
            }
            
            for item in filteredData where !topAnime.contains(where: { $0.mal_id == item.mal_id }) {
                topAnime.append(item)
            }
            animePage += 1
        } catch { print("getTopAnime:", error) }
    }

    func getTopManga() async {
        do {
            let response = try await fetch("\(baseURL)/top/manga?page=\(mangaPage)&genres_exclude=\(excludeIDs)", as: MangaResponse.self)
            for item in response.data where !topManga.contains(where: { $0.mal_id == item.mal_id }) {
                topManga.append(item)
            }
            mangaPage += 1
        } catch { print("getTopManga:", error) }
    }


    func searchAnime(query: String) async -> [Anime] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        do {
            let response = try await fetch("\(baseURL)/anime?q=\(encoded)", as: AnimeResponse.self)
            
            return response.data.filter { anime in
                guard let rating = anime.rating else { return true }
                let isRestricted = (try? /^R\+|^Rx/.firstMatch(in: rating)) != nil
                
                return !isRestricted
            }
        } catch { print("searchAnime:", error); return [] }
    }

    func searchManga(query: String) async -> [Manga] {
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


    func getRandomAnime() async {
        var isRestricted = true
        
        while isRestricted {
            do {
                let response = try await fetch("\(baseURL)/random/anime", as: AnimeDetailResponse.self)
                let anime = response.data
                
                if let rating = anime.rating {
                    let matchesRestricted = (try? /^R\+|^Rx/.firstMatch(in: rating)) != nil
                    
                    if !matchesRestricted {
                        selectedAnime = anime
                        isRestricted=false
                    } else {
                        print("restricted found: \(anime.title) has rating \(rating), retrying")
                        try? await Task.sleep(for: .seconds(0.5))
                    }
                } else {
                    selectedAnime = anime
                    isRestricted = false
                }
                
            } catch {
                print("getRandomAnime:", error)
                break
            }
        }
    }

    func getRandomManga() async {
        var isRestricted = true
        
        let excludedArray = excludeIDs.split(separator: ",").compactMap { Int($0) }
        
        while isRestricted {
            do {
                let response = try await fetch("\(baseURL)/random/manga", as: MangaDetailResponse.self)
                let manga=response.data
                
                let containsExcluded = manga.genres?.contains { genre in
                    excludedArray.contains(genre.mal_id)
                } ?? false
                
                if !containsExcluded {
                    selectedManga = response.data
                    isRestricted = false
                } else {
                    print("found excluded genre: \(manga.genres?.map{ $0.name } ?? [])")
                    try? await Task.sleep(for: .seconds(0.5))
                }
                
            } catch {
                print("getRandomManga:", error)
                break
            }
        }
    }


    func getAnimeSeason(year: Int, season: String) async {
        do {
            let response = try await fetch("\(baseURL)/seasons/\(year)/\(season)?page=\(seasonPage)", as: AnimeResponse.self)
            
            let filteredData = response.data.filter { anime in
                guard let rating = anime.rating else { return true }
                let isRestricted = (try? /^R\+|^Rx/.firstMatch(in: rating)) != nil
                
                return !isRestricted
            }
            
            for item in filteredData where !selectedSeason.contains(where: { $0.mal_id == item.mal_id }) {
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
