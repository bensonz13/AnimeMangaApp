//
//  MangaPosterCard.swift
//  AnimeMangaApp
//

import SwiftUI
import SwiftData

struct MangaPosterCard: View {
    let manga: Manga
    
    @State private var client = NetworkClient()
    @State private var showDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            ZStack(alignment: .topLeading) {
                
                if let urlString = manga.images?.jpg.image_url,
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

            Text(manga.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(width: 140, alignment: .leading)
        }
        .onTapGesture {
            Task {
                await client.getMangaByID(id: manga.mal_id)
                showDetail = true
            }
        }
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
}
