//
//  HomeView.swift
//  AnimeMangaApp
//
//  Created by Student on 4/27/26.
//

import Combine
import Foundation
import SwiftUI

struct HomeView: View {
    @State private var client = NetworkClient()
    @State private var featuredAnime: Anime? = nil
    @State private var timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
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
                    
                    if let anime = featuredAnime,
                       let urlString = anime.images?.jpg.image_url,
                       let url = URL(string: urlString) {
                        
                        ZStack(alignment: .bottomLeading) {
                            
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 220)
                            .clipped()
                            
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.85)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            
                            Text(anime.title)
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                        }
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .onReceive(timer) { _ in
                            if !client.topAnime.isEmpty {
                                featuredAnime = client.topAnime.randomElement()
                            }
                        }
                    }
                    
                    AnimeSectionView(title: "🔥 Trending Anime", items: client.topAnime)
                    MangaSectionView(title: "📚 Popular Manga", items: client.topManga)
                }
                .padding(.vertical)
            }
            .task {
                await client.getTopAnime()
                await client.getTopManga()
                
                if !client.topAnime.isEmpty {
                    featuredAnime = client.topAnime.randomElement()
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
