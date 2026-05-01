//
//  HomeView.swift
//  AnimeMangaApp
//
//  Created by Student on 4/27/26.
//
import SwiftUI

struct HomeView: View {
    @State private var client = NetworkClient()
    @State private var showDetail = false
    @State private var selectedAnime: Anime? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Discover")
                            .font(.largeTitle)
                            .bold()
                    }
                    .padding(.horizontal)
                    
                    TabView {
                        ForEach(client.topAnime) { anime in
                            
                            ZStack(alignment: .bottomLeading) {
                                
                                if let urlString = anime.images?.jpg.image_url,
                                   let url = URL(string: urlString) {
                                    
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(height: 220)
                                    .clipped()
                                }

                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.85)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )

                                Text(anime.title)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Task {
                                    await client.getAnimeByID(id: anime.mal_id)
                                    selectedAnime = client.selectedAnime
                                    showDetail = true
                                }
                            }
                        }
                    }
                    .frame(height: 240)
                    .tabViewStyle(.page)
                    
                    AnimeSectionView(title: "🔥 Trending Anime", items: client.topAnime)
                    MangaSectionView(title: "📚 Popular Manga", items: client.topManga)
                }
                .padding(.vertical)
            }
            .task {
                await client.getTopAnime()
                await client.getTopManga()
            }
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
    }
}

#Preview {
    HomeView()
}
