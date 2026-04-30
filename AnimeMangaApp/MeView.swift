//
//  MeView.swift
//  AnimeMangaApp
//
//  Created by Student on 4/30/26.
//
import SwiftUI
import SwiftData

struct MeView: View {
    
    @Query private var animeFavorites: [FavoriteAnime]
    @Query private var mangaFavorites: [FavoriteManga]
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("My Anime App")
                                .font(.headline)
                            
                            Text("Favorites & Watchlist")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
                
                Section("Favorite Anime") {
                    if animeFavorites.isEmpty {
                        Text("No favorites yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(animeFavorites) { fav in
                            HStack {
                                if let url = fav.imageURL,
                                   let imageURL = URL(string: url) {
                                    
                                    AsyncImage(url: imageURL) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.gray
                                    }
                                    .frame(width: 40, height: 55)
                                    .cornerRadius(6)
                                }
                                
                                Text(fav.title)
                            }
                        }
                    }
                }
                
                Section("Favorite Manga") {
                    if mangaFavorites.isEmpty {
                        Text("No favorites yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(mangaFavorites) { fav in
                            HStack {
                                if let url = fav.imageURL,
                                   let imageURL = URL(string: url) {
                                    
                                    AsyncImage(url: imageURL) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.gray
                                    }
                                    .frame(width: 40, height: 55)
                                    .cornerRadius(6)
                                }
                                
                                Text(fav.title)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Me")
        }
    }
}
