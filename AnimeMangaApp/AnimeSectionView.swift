//
//  SectionView.swift
//  AnimeMangaApp
//
//  Created by Student on 4/28/26.
//

import SwiftUI

struct AnimeSectionView: View {
    let title: String
    let items: [Anime]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items) { anime in
                        PosterCard(
                            title: anime.title,
                            imageURL: anime.images?.jpg.image_url
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
