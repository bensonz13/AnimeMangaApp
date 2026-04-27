//
//  ContentView.swift
//  collaborationfun
//
//  Created by Student on 4/23/26.
//
//https://jikan.moe/

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            
            AnimeView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Anime")
                }
            MangaView()
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Manga")
                }
        }
    }
}   
