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
    
    private var topAnime: [Anime] = []
    private var topManga: [Manga] = []
    
    private var animePage: Int = 1
    private var mangaPage: Int = 1
    
    private(set) var selectedAnime: Anime? = nil
    private(set) var selectedManga: Manga? = nil
    
    func getTopAnime() async {
        let urlStr = "\(baseURL)/top/anime?page=\(animePage)"
        guard let url = URL(string: urlStr) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AnimeResponse.self, from: data)
            
            for item in response.data {
                if !topAnime.contains(where: { $0.mal_id == item.mal_id }) {
                    topAnime.append(item)
                }
            }
            
            animePage += 1
        } catch {
            print(error)
        }
    }
    
    func getTopManga() async {
        let urlStr = "\(baseURL)/top/manga?page=\(mangaPage)"
        guard let url = URL(string: urlStr) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(MangaResponse.self, from: data)
            
            for item in response.data {
                if !topManga.contains(where: { $0.mal_id == item.mal_id }) {
                    topManga.append(item)
                }
            }
            
            mangaPage += 1
        } catch {
            print(error)
        }
    }
    
    func getAnimeByID(id: Int) async {
        let urlStr = "\(baseURL)/anime/\(id)"
        guard let url = URL(string: urlStr) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AnimeDetailResponse.self, from: data)
            selectedAnime = response.data
        } catch {
            print(error)
        }
    }
    
    func getMangaByID(id: Int) async {
        let urlStr = "\(baseURL)/manga/\(id)"
        guard let url = URL(string: urlStr) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(MangaDetailResponse.self, from: data)
            selectedManga = response.data
        } catch {
            print(error)
        }
    }
    
    func getRandomAnime() async {
        let urlStr = "\(baseURL)/random/anime"
        guard let url = URL(string: urlStr) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AnimeDetailResponse.self, from: data)
            selectedAnime = response.data
        } catch {
            print(error)
        }
    }
    
    func getRandomManga() async {
        let urlStr = "\(baseURL)/random/manga"
        guard let url = URL(string: urlStr) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(MangaDetailResponse.self, from: data)
            selectedManga = response.data
        } catch {
            print(error)
        }
    }
}
