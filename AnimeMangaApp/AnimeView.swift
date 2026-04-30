//
//  AnimeView.swift
//  AnimeMangaApp
//

import SwiftUI

struct AnimeView: View {
    @State var client = NetworkClient()
    
    @State private var query = ""
    @State private var searchResults: [Anime] = []
    @State private var searchTask: Task<Void, Never>? = nil
    
    @State private var selectedAnime: Anime? = nil
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    TextField("Search anime...", text: $query)
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
                                        searchResults = []
                                    }
                                    return
                                }
                                
                                let result = await client.searchAnime(query: trimmed)
                                
                                await MainActor.run {
                                    searchResults = result
                                }
                            }
                        }
                    
                    ForEach(query.isEmpty ? client.topAnime : searchResults) { anime in
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
                    
                    if query.isEmpty {
                        ProgressView()
                            .padding()
                    }
                }
            }
            .navigationTitle("Top Anime")
            .sheet(isPresented: $showDetail) {
                if let detail = client.selectedAnime {
                    MediaDetailSheet(
                        title: detail.title,
                        imageURL: detail.images?.jpg.image_url,
                        score: detail.score,
                        synopsis: detail.synopsis,
                        link: detail.url,
                        title_japanese: detail.title_japanese,
                        status: detail.status,
                        anime: detail,
                        manga: nil
                    )
                }
            }
        }
        .task {
            if client.topAnime.isEmpty {
                await client.getTopAnime()
            }
        }
    }
}
