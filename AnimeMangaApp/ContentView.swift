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
                    Label("Home", systemImage: "house")
                }
            
            AnimeView()
                .tabItem {
                    Label("Anime", systemImage: "play.rectangle")
                }
            
            MangaView()
                .tabItem {
                    Label("Manga", systemImage: "book")
                }
            
            MeView()
                .tabItem {
                    Label("Me", systemImage: "person")
                }
        }
    }
}

#Preview {
    ContentView()
}

