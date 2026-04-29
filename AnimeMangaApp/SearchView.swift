//
//  SearchView.swift
//  AnimeMangaApp
//
//  Created by Student on 4/27/26.
//

import SwiftUI

struct SearchView: View {
    @State private var client = NetworkClient()
    
    @State private var query = ""
    @State private var animeResults: [Anime] = []
    @State private var mangaResults: [Manga] = []
    
    @State private var searchTask: Task<Void, Never>? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                
                TextField("Search anime or manga...", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onChange(of: query) { _, newValue in
                        searchTask?.cancel()
                        
                        searchTask = Task {
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            
                            guard !Task.isCancelled else { return }
                            
                            if newValue.trimmingCharacters(in: .whitespaces).isEmpty {
                                await MainActor.run {
                                    animeResults = []
                                    mangaResults = []
                                }
                                return
                            }
                            
                            await search(query: newValue)
                        }
                    }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        if !animeResults.isEmpty {
                            Text("Anime")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            ForEach(animeResults) { anime in
                                SearchAnimeRow(anime: anime)
                            }
                        }
                        
                        if !mangaResults.isEmpty {
                            Text("Manga")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            ForEach(mangaResults) { manga in
                                SearchMangaRow(manga: manga)
                            }
                        }
                        
                        if animeResults.isEmpty && mangaResults.isEmpty && !query.isEmpty {
                            Text("No results found")
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                        }
                    }
                }
            }
            .navigationTitle("Search")
        }
    }
    
    func search(query: String) async {
        async let anime = client.searchAnime(query: query)
        async let manga = client.searchManga(query: query)
        
        let (animeResult, mangaResult) = await (anime, manga)
        
        await MainActor.run {
            self.animeResults = animeResult
            self.mangaResults = mangaResult
        }
    }
}

#Preview {
    SearchView()
}
