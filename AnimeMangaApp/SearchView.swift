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
    @State private var results: [SearchItem] = []
    
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
                                    results = []
                                }
                                return
                            }
                            
                            await search(query: newValue)
                        }
                    }
                
                List(results) { item in
                    switch item {
                    case .anime(let anime):
                        SearchAnimeRow(anime: anime)
                        
                    case .manga(let manga):
                        SearchMangaRow(manga: manga)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Search")
        }
    }
    
    func search(query: String) async {
        async let anime = client.searchAnime(query: query)
        async let manga = client.searchManga(query: query)
        
        let (animeResult, mangaResult) = await (anime, manga)
        
        let combined: [SearchItem] =
            animeResult.map { .anime($0) } +
            mangaResult.map { .manga($0) }
        
        await MainActor.run {
            self.results = combined
        }
    }
}


#Preview {
    SearchView()
}
