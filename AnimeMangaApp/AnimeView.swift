//
//  AnimeView.swift
//  AnimeMangaApp
//
//  Created by Student on 4/27/26.
//

import SwiftUI

struct AnimeView: View {
    @State var client = NetworkClient()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(client.topAnime) { anime in
                        AnimeRow(anime: anime)
                            .onAppear {
                                if anime.id == client.topAnime.last?.id {
                                    Task {
                                        await client.getTopAnime()
                                    }
                                }
                            }
                    }
                    
                    ProgressView()
                        .padding()
                }
            }
            .navigationTitle("Top Anime")
        }
        .task {
            if client.topAnime.isEmpty {
                await client.getTopAnime()
            }
        }
    }
}

#Preview {
    AnimeView()
}
