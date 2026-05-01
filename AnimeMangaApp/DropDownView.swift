//
//  DropDownView.swift
//  AnimeMangaApp
//
//  Created by Student on 4/30/26.
//

import SwiftUI

struct DropDownView: View {
    @State private var client = NetworkClient()

    private let currentYear = Calendar.current.component(.year, from: Date())
    @State private var selectedYear = 2026
    @State private var selectedSeason = "winter"
    private var years: [Int] = []
    private let seasons: [String] = ["winter", "spring", "summer", "fall"]
    @State private var show = false

    
    init() {
        for i in 1917...currentYear {
            years.append(i)
        }
    }
    
    
    var body: some View {
        NavigationStack {
            VStack {
                if (show) {
                    List(client.selectedSeason) { anime in
                        AnimeRow(anime: anime)
                            .onAppear {
                                if anime.id == client.selectedSeason.last?.id {
                                        Task {
                                            await client.getAnimeSeason(year: selectedYear, season: selectedSeason)
                                        }
                                    }
                            }
                    }
                }
                
                HStack {
                    Picker("\(selectedYear)", selection: $selectedYear) {
                        ForEach(years.reversed(), id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    .buttonStyle(.bordered)
                    .tint(.primary)
                    
                    Picker(selection: $selectedSeason) {
                        ForEach(seasons, id: \.self) { season in
                            Text(season.capitalized).tag(season)
                        }
                    } label: {
                        Text(selectedSeason.capitalized)
                            .fontWeight(.medium)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(.black)
                            .cornerRadius(8)
                    }
                    .pickerStyle(.menu)
                    .menuIndicator(.hidden)
                }
                .padding(.horizontal)
                
                Button("Show Selected Season") {
                    show.toggle()
                    if show && client.selectedSeason.isEmpty {
                            Task {
                                await client.getAnimeSeason(year: selectedYear, season: selectedSeason)
                            }
                        }
                }
            }
        }
    }
    
}

#Preview {
    DropDownView()
}
