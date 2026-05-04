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


    private func fetch<T: Decodable>(_ urlStr: String, as type: T.Type) async throws -> T {
        guard let url = URL(string: urlStr) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func getTopAnime() async {
        do {
            let response = try await fetch("\(baseURL)/top/anime?page=\(animePage)", as: AnimeResponse.self)
            for item in response.data where !topAnime.contains(where: { $0.mal_id == item.mal_id }) {
                topAnime.append(item)
            }
            animePage += 1
        } catch { print("getTopAnime:", error) }
    }

    func getTopManga() async {
        do {
            let response = try await fetch("\(baseURL)/top/manga?page=\(mangaPage)", as: MangaResponse.self)
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
            return response.data
        } catch { print("searchAnime:", error); return [] }
    }

    func searchManga(query: String) async -> [Manga] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        do {
            let response = try await fetch("\(baseURL)/manga?q=\(encoded)", as: MangaResponse.self)
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
        do {
            let response = try await fetch("\(baseURL)/random/anime", as: AnimeDetailResponse.self)
            selectedAnime = response.data
        } catch { print("getRandomAnime:", error) }
    }

    func getRandomManga() async {
        do {
            let response = try await fetch("\(baseURL)/random/manga", as: MangaDetailResponse.self)
            selectedManga = response.data
        } catch { print("getRandomManga:", error) }
    }


    func getAnimeSeason(year: Int, season: String) async {
        do {
            let response = try await fetch("\(baseURL)/seasons/\(year)/\(season)?page=\(seasonPage)", as: AnimeResponse.self)
            for item in response.data where !selectedSeason.contains(where: { $0.mal_id == item.mal_id }) {
                selectedSeason.append(item)
            }
            seasonPage += 1
        } catch { print("getAnimeSeason:", error) }
    }

    func getNowAiringAnime() async {
        do {
            let response = try await fetch("\(baseURL)/seasons/now", as: AnimeResponse.self)
            topAnime = response.data
        } catch { print("getNowAiringAnime:", error) }
    }


    func resetSeason() {
        selectedSeason = []
        seasonPage = 1
    }
}
