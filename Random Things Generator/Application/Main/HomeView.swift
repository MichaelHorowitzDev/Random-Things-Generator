//
//  HomeView.swift
//  HomeView
//
//  Created by Michael Horowitz on 8/25/21.
//

import SwiftUI

struct HomeView: View {
  let types = ["Number", "Card", "Coin", "Color", "Date", "Lists"]
  @EnvironmentObject var preferences: UserPreferences
  @State private var settingsPresented = false
  let columns: [GridItem] = [GridItem(.adaptive(minimum: 140))]
  var body: some View {
    NavigationView {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 10) {
          ForEach(0..<types.count) { num in
            HomeViewItem(item: types[num], color: preferences.themeColor, destinationView: AnyView(typeToView[types[num]]))
              .padding(.horizontal, 5)
          }
        }
        .padding(.horizontal, 10)
      }
      .navigationBarTitle("Random")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            print("pressed")
            settingsPresented = true
          } label: {
            Image(systemName: "gear")
              .font(.system(size: 18, weight: .bold))
              .foregroundColor(preferences.themeColor)
          }
          .sheet(isPresented: $settingsPresented) {
            SettingsMenu()
          }
        }
      }
    }
    .navigationViewStyle(.stack)
    .accentColor(preferences.themeColor)
  }
  let typeToView: [String: AnyView] = ["Number": AnyView(NumberGenerator()), "Coin": AnyView(CoinFlipper()), "Card": AnyView(CardRandomizer()), "Date": AnyView(DateGenerator()), "Map": AnyView(MapGenerator()), "Lists": AnyView(ListsGenerator()), "Color": AnyView(ColorGenerator())]
}

private struct HomeViewItem: View {
  let item: String
  let color: Color
  let destinationView: AnyView
  var body: some View {
    NavigationLink {
      destinationView
    } label: {
      Text(item)
        .font(.title)
        .fontWeight(.semibold)
        .foregroundColor(color.isLight ? .black : .white)
        .frame(height: 100)
        .frame(maxWidth: .infinity)
    }
    .background(color)
    .cornerRadius(10)
  }
}
