//
//  AnimeMangaApp.swift
//  AnimeMangaApp
//
//  Created by Student on 4/24/26.
//

import SwiftUI
import SwiftData

@main
struct AnimeMangaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .autocorrectionDisabled()
        }
        .modelContainer(for: [FavoriteAnime.self, FavoriteManga.self, UserSettings.self]) { result in
            if case .success(let container) = result {
                let context = container.mainContext
                let descriptor = FetchDescriptor<UserSettings>()
                if (try? context.fetch(descriptor))?.isEmpty ?? true {
                    context.insert(UserSettings())
                }
            }
        }
    }
}
