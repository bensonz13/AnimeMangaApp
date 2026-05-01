//
//  MediaView.swift
//  AnimeMangaApp
//
//  Created by Student on 4/30/26.
//


import SwiftUI

struct MediaView: View {
    let type: MediaType
    
    @State var client = NetworkClient()
    
    @State private var query = ""
    @State private var searchResultsAnime: [Anime] = []
    @State private var searchResultsManga: [Manga] = []
    @State private var searchTask: Task<Void, Never>? = nil
    
    @State private var selectedAnime: Anime? = nil
    @State private var selectedManga: Manga? = nil
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    
                    searchField
                    
                    contentList
                    
                    if query.isEmpty {
                        ProgressView()
                            .padding()
                    }
                }
            }
            .navigationTitle(type == .anime ? "Top Anime" : "Top Manga")
            .sheet(isPresented: $showDetail) {
                sheetContent
            }
        }
        .task {
            loadInitial()
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
                        await MainActor.run {
                            searchResultsAnime = result
                        }
                    } else {
                        let result = await client.searchManga(query: trimmed)
                        await MainActor.run {
                            searchResultsManga = result
                        }
                    }
                }
            }
    }

    @ViewBuilder
    private var contentList: some View {
        if type == .anime {
            ForEach(query.isEmpty ? client.topAnime : searchResultsAnime) { anime in
                AnimeRow(anime: anime)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            await client.getAnimeByID(id: anime.mal_id)
                            selectedAnime = client.selectedAnime
                            showDetail = true
                        }
                    }
                    .onAppear {
                        if query.isEmpty,
                           anime.mal_id == client.topAnime.last?.mal_id {
                            Task {
                                await client.getTopAnime()
                            }
                        }
                    }
            }
        } else {
            ForEach(query.isEmpty ? client.topManga : searchResultsManga) { manga in
                MangaRow(manga: manga)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            await client.getMangaByID(id: manga.mal_id)
                            selectedManga = client.selectedManga
                            showDetail = true
                        }
                    }
                    .onAppear {
                        if query.isEmpty,
                           manga.mal_id == client.topManga.last?.mal_id {
                            Task {
                                await client.getTopManga()
                            }
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private var sheetContent: some View {
        if let anime = selectedAnime {
            MediaDetailSheet(
                title: anime.title,
                imageURL: anime.images?.jpg.image_url,
                score: anime.score,
                synopsis: anime.synopsis,
                link: anime.url,
                title_japanese: anime.title_japanese,
                status: anime.status,
                anime: anime,
                manga: nil
            )
        } else if let manga = selectedManga {
            MediaDetailSheet(
                title: manga.title,
                imageURL: manga.images?.jpg.image_url,
                score: manga.score,
                synopsis: manga.synopsis,
                link: manga.url,
                title_japanese: manga.title_japanese,
                status: manga.status,
                anime: nil,
                manga: manga
            )
        }
    }

    private func loadInitial() {
        Task {
            if type == .anime {
                if client.topAnime.isEmpty {
                    await client.getTopAnime()
                }
            } else {
                if client.topManga.isEmpty {
                    await client.getTopManga()
                }
            }
        }
    }
}
