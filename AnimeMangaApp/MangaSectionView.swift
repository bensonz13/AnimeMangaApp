//
//  MangaSectionView.swift
//  AnimeMangaApp
//
//  Created by Student on 4/28/26.
//

import SwiftUI

struct MangaSectionView: View {
    let title: String
    let items: [Manga]
 
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.horizontal)
 
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items) { manga in
                        MangaPosterCard(manga: manga)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
