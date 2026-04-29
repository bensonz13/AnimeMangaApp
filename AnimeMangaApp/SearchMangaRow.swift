//
//  SearchMangaRow.swift
//  AnimeMangaApp
//
//  Created by Student on 4/29/26.
//


import SwiftUI

struct SearchMangaRow: View {
    let manga: Manga
    
    var body: some View {
        HStack(spacing: 12) {
            
            if let urlString = manga.images?.jpg.image_url,
               let url = URL(string: urlString) {
                
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 80)
                .cornerRadius(6)
                .clipped()
            } else {
                Color.gray
                    .frame(width: 60, height: 80)
                    .cornerRadius(6)
            }
            
            Text(manga.title)
                .font(.body)
                .lineLimit(2)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}