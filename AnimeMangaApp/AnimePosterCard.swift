//
//  AnimePosterCard.swift
//  AnimeMangaApp
//
//  Created by Student on 4/30/26.
import SwiftUI
import SwiftData

struct AnimePosterCard: View {
    let anime: Anime
    
    @State private var client = NetworkClient()
    @State private var showDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            ZStack(alignment: .topLeading) {
                
                if let urlString = anime.images?.jpg.image_url,
                   let url = URL(string: urlString) {
                    
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 140, height: 200)
                    .clipped()
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                }
            }

            Text(anime.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(width: 140, alignment: .leading)
        }
        .onTapGesture {
            Task {
                await client.getAnimeByID(id: anime.mal_id)
                showDetail = true
            }
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
