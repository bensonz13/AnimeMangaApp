//
//  PosterCard.swift
//  AnimeMangaApp
//
//  Created by Student on 4/28/26.
//

import SwiftUI

struct PosterCard: View {
    let title: String
    let imageURL: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageURL,
               let url = URL(string: imageURL) {
                
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                    }
                }
                .frame(width: 140, height: 200)
                .clipped()
                .cornerRadius(12)
            }
            
            Text(title)
                .font(.caption)
                .lineLimit(2)
                .frame(width: 140, alignment: .leading)
        }
    }
}
