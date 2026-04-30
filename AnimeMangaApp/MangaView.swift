//
//  MangaView.swift
//  AnimeMangaApp
//

import SwiftUI

struct MangaView: View {
    @State var client = NetworkClient()
    
    @State private var query = ""
    @State private var searchResults: [Manga] = []
    @State private var searchTask: Task<Void, Never>? = nil
    
    @State private var selectedManga: Manga? = nil
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    TextField("Search manga...", text: $query)
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
                                
                                let result = await client.searchManga(query: trimmed)
                                
                                await MainActor.run {
                                    searchResults = result
                                }
                            }
                        }
                    
                    ForEach(query.isEmpty ? client.topManga : searchResults) { manga in
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
                    
                    if query.isEmpty {
                        ProgressView()
                            .padding()
                    }
                }
            }
            .navigationTitle("Top Manga")
            .sheet(isPresented: $showDetail) {
                if let detail = client.selectedManga {
                    MediaDetailSheet(
                        title: detail.title,
                        imageURL: detail.images?.jpg.image_url,
                        score: detail.score,
                        synopsis: detail.synopsis,
                        link: detail.url,
                        title_japanese: detail.title_japanese,
                        status: detail.status,
                        anime: nil,
                        manga: detail
                    )
                }
            }
        }
        .task {
            if client.topManga.isEmpty {
                await client.getTopManga()
            }
        }
    }
}
