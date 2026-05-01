//
//  MangaRow.swift
//  AnimeMangaApp
//
//  Created by Student on 4/30/26.
//

import SwiftUI

struct MangaRow: View {
    let manga: Manga

    var body: some View {
        HStack {
            
            ZStack(alignment: .topLeading) {
                
                if let urlString = manga.images?.jpg.image_url,
                   let url = URL(string: urlString) {
                    
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 60, height: 80)
                    .clipped()
                    .cornerRadius(6)
                }
            }

            Text(manga.title)
                .lineLimit(2)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
