//
//  AnimeRow.swift
//  AnimeMangaApp
//
//  Created by Student on 4/29/26.
//


import SwiftUI

struct AnimeRow: View {
    let anime: Anime
    
    var body: some View {
        HStack(spacing: 12) {
            
            if let urlString = anime.images?.jpg.image_url,
               let url = URL(string: urlString) {
                
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 110)
                .cornerRadius(8)
                
            } else {
                Color.gray
                    .frame(width: 80, height: 110)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(anime.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("Tap for details")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
