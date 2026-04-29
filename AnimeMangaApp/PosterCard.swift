//
//  PosterCard.swift
//  AnimeMangaApp
//
//  Created by Student on 4/28/26.
//

import SwiftUI

struct AnimePosterCard: View {
    let anime: Anime
    @State private var client = NetworkClient()
    @State private var showDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let urlString = anime.images?.jpg.image_url,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                    }
                }
                .frame(width: 140, height: 200)
                .clipped()
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
            }

            Text(anime.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(width: 140, alignment: .leading)
        }
        .onTapGesture {
            Task {
                await client.getAnimeByID(id: anime.mal_id)
                showDetail = true
            }
        }
        .sheet(isPresented: $showDetail) {
            if let detail = client.selectedAnime {
                MediaDetailSheet(
                    title: detail.title,
                    imageURL: detail.images?.jpg.image_url,
                    score: detail.score,
                    synopsis: detail.synopsis
                )
            }
        }
    }
}

struct MangaPosterCard: View {
    let manga: Manga
    @State private var client = NetworkClient()
    @State private var showDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let urlString = manga.images?.jpg.image_url,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                    }
                }
                .frame(width: 140, height: 200)
                .clipped()
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
            }

            Text(manga.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(width: 140, alignment: .leading)
        }
        .onTapGesture {
            Task {
                await client.getMangaByID(id: manga.mal_id)
                showDetail = true
            }
        }
        .sheet(isPresented: $showDetail) {
            if let detail = client.selectedManga {
                MediaDetailSheet(
                    title: detail.title,
                    imageURL: detail.images?.jpg.image_url,
                    score: detail.score,
                    synopsis: detail.synopsis
                )
            }
        }
    }
}

// MARK: - Shared Detail Sheet

struct MediaDetailSheet: View {
    let title: String
    let imageURL: String?
    let score: Double?
    let synopsis: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let urlString = imageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipped()
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.title2)
                        .bold()

                    if let score {
                        Label(String(format: "%.1f", score), systemImage: "star.fill")
                            .foregroundStyle(.orange)
                            .font(.subheadline)
                    }

                    if let synopsis {
                        Text(synopsis)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
